# SIGGAF — Sistema Inteligente de Gestión Ganadera Argentina

Primera entrega funcional del sistema para el establecimiento **La Celina**. Incluye autenticación y gestión de potreros con recursos, usando PHP 8, arquitectura MVC sencilla, PDO y MySQL 8.

## Alcance implementado

- Inicio y cierre de sesión.
- Verificación de cuentas activas.
- Contraseñas protegidas con `password_hash()` y `password_verify()`.
- Sesiones seguras y protección CSRF.
- Roles y permisos almacenados en la base de datos.
- Listado, registro, consulta y modificación de potreros.
- Cálculo de superficie en servidor y vista previa en el navegador.
- Registro y actualización de disponibilidad de recursos.
- Diseño adaptable inspirado en la identidad visual de La Celina.

La recuperación de contraseña y la visualización de potreros en un mapa quedan indicadas como funciones de una entrega posterior.

## Requisitos

- PHP 8.1 o posterior.
- MySQL 8.0 o posterior.
- Apache con `mod_rewrite` habilitado, o el servidor integrado de PHP.
- Extensiones PHP `pdo_mysql` y `mbstring`.

En Windows puede utilizarse XAMPP con Apache y MySQL activos.

## Instalación con XAMPP

1. Copiar el proyecto dentro de `C:\\xampp\\htdocs\\SIGGAF`.
2. Copiar `.env.example` como `.env`.
3. Revisar en `.env` los datos de conexión a MySQL y configurar una contraseña inicial segura en `SEED_ADMIN_PASSWORD`.
4. Abrir phpMyAdmin e importar `database/schema.sql`.
5. Abrir una terminal dentro del proyecto y ejecutar:

```bash
C:\xampp\php\php.exe database\seed.php
```

6. Abrir en el navegador:

```text
http://localhost/SIGGAF/public
```

Si la carpeta tiene otro nombre, actualizar también `APP_URL` dentro de `.env`.

## Ejecución con el servidor integrado de PHP

Desde la carpeta raíz:

```bash
php -S localhost:8000 -t public
```

Configurar en `.env`:

```env
APP_URL=http://localhost:8000
```

Después, acceder a `http://localhost:8000`.

## Base de datos

El archivo `database/schema.sql` contiene el modelo relacional completo de SIGGAF. Los módulos de esta entrega utilizan principalmente:

- `estado_usuario`
- `persona`
- `rol`
- `permiso`
- `rol_permiso`
- `usuario`
- `establecimiento`
- `potrero`
- `recurso_potrero`

El script `database/seed.php` carga los permisos de potreros, los asigna a los roles, crea el establecimiento La Celina y registra el usuario inicial indicado en `.env`. Puede ejecutarse nuevamente sin duplicar esos datos.

## Rutas principales

| Método | Ruta | Función | Permiso |
|---|---|---|---|
| GET | `/login` | Mostrar acceso | Público |
| POST | `/login` | Autenticar | Público |
| POST | `/logout` | Cerrar sesión | Autenticado |
| GET | `/dashboard` | Panel provisional | Autenticado |
| GET | `/potreros` | Listar potreros | `POTRERO_CONSULTAR` |
| GET | `/potreros/crear` | Formulario de alta | `POTRERO_CREAR` |
| POST | `/potreros` | Registrar | `POTRERO_CREAR` |
| GET | `/potreros/{id}` | Consultar detalle | `POTRERO_CONSULTAR` |
| GET | `/potreros/{id}/editar` | Formulario de edición | `POTRERO_EDITAR` |
| POST | `/potreros/{id}/actualizar` | Actualizar | `POTRERO_EDITAR` |
| POST | `/potreros/{id}/recursos` | Agregar recurso | `POTRERO_RECURSOS` |
| POST | `/potreros/{id}/recursos/{recurso}/disponibilidad` | Cambiar disponibilidad | `POTRERO_RECURSOS` |

## Seguridad

- No guardar el archivo `.env` en Git.
- Cambiar la contraseña inicial antes de realizar una demostración pública.
- En producción, utilizar HTTPS y configurar `APP_DEBUG=false`.
- El sistema nunca almacena contraseñas en texto plano.

## Organización

- `app/Controllers`: coordinación de solicitudes.
- `app/Services`: validación y lógica de aplicación.
- `app/Repositories`: consultas SQL mediante PDO.
- `app/Core`: enrutamiento, sesiones, seguridad y conexión.
- `resources/views`: plantillas de interfaz.
- `public`: punto de entrada y recursos públicos.
- `database`: esquema y datos iniciales.

