# Configurar la Copa compartida

La página requiere un proyecto Supabase para que los equipos, alineaciones y resultados se compartan entre visitantes. Sin configurarlo, sigue funcionando en modo local y muestra un aviso: los cambios no se sincronizan.

## 1. Crear la base de datos

1. Crea un proyecto en [Supabase](https://supabase.com/).
2. En el proyecto, abre **SQL Editor**.
3. Abre `supabase-setup.sql`, copia su contenido y ejecútalo.

El script crea la tabla compartida, habilita lectura pública, restringe escrituras al STAFF y activa los cambios en tiempo real.

## 2. Crear cuentas STAFF

1. En **Authentication → Users**, crea una cuenta por cada integrante STAFF. No habilites el registro público de usuarios.
2. En **SQL Editor**, asigna el permiso STAFF a cada cuenta ejecutando lo siguiente y reemplazando el correo:

   ```sql
   update auth.users
   set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"staff"}'::jsonb
   where email = 'correo-staff@example.com';
   ```

Solo cuentas con `app_metadata.role = staff` pueden guardar cambios. Si una persona no debe tener acceso, quítale ese rol y cierra su sesión.

## 3. Conectar la página

En **Project Settings → API** copia el **Project URL** y la clave pública **anon / publishable**. En `index.html`, llena `SUPABASE_CONFIG`:

```js
const SUPABASE_CONFIG = {
    url: "https://TU-PROJECT-REF.supabase.co",
    anonKey: "TU-CLAVE-PUBLICA"
};
```

La clave `anon`/`publishable` está diseñada para usarse en la página; la seguridad depende de las políticas de la base de datos. **Nunca pongas la clave `service_role` en `index.html` ni la compartas.**

## 4. Publicar en Vercel e inicializar

1. Sube el proyecto a un repositorio Git con `index.html` y las imágenes (`lince.png`, `fifa.png`, `smashbros.png`, `justdance.png`, `karaoke.png`). No es necesario subir `supabase-setup.sql` al sitio, pero consérvalo en el proyecto.
2. En [Vercel](https://vercel.com/), importa ese repositorio. Como es una página estática sin build, elige **Other** si pide framework y deja vacíos el comando de build y el directorio de salida. Vercel servirá `index.html` desde la raíz.
3. En `index.html`, configura el Project URL y la clave pública `anon`/`publishable` de Supabase como se indica arriba. Para esta página estática estos valores forman parte del código público; la seguridad depende de las políticas de la base de datos. No añadas secretos ni claves `service_role` a Vercel o al HTML.
4. Después del primer despliegue, en Supabase abre **Authentication → URL Configuration**. Establece **Site URL** al dominio de producción de Vercel (por ejemplo, `https://tu-proyecto.vercel.app`) y agrega ese dominio a **Redirect URLs**. Si usas dominios de Preview, agrega sus URL de forma explícita o prueba primero en producción.
5. Abre el dominio publicado, presiona **Alt + A** e inicia sesión con una cuenta STAFF. El primer acceso crea el estado compartido usando los datos guardados en ese navegador; hazlo desde el navegador que tenga los equipos y resultados que quieras conservar.

Después de inicializar, los visitantes leen el mismo estado y las actualizaciones se propagan en tiempo real. Si la base aún no está inicializada, la página bloquea la vista compartida y pide que entre STAFF. Vercel solo aloja la página; Supabase es lo que guarda y sincroniza los datos.
