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
- Recuperación de contraseña mediante tres preguntas de seguridad.
- Creación, consulta, modificación y desactivación de usuarios.
- Asignación de roles y permisos individuales.
- Administración de roles, permisos, establecimientos y preguntas de seguridad.
- Eliminación controlada de potreros y recursos.
- Diseño adaptable inspirado en la identidad visual de La Celina.

La recuperación no utiliza correo electrónico en esta entrega. La visualización de potreros en un mapa queda indicada como una función posterior.

## Requisitos

- PHP 8.1 o posterior.
- MySQL 8.0 o MariaDB incluida en XAMPP.
- Apache con `mod_rewrite` habilitado, o el servidor integrado de PHP.
- Extensiones PHP `pdo_mysql` y `mbstring`.

En Windows puede utilizarse XAMPP con Apache y MySQL activos.

## Instalación con XAMPP

1. Copiar el proyecto dentro de `C:\\xampp\\htdocs\\SIGGAF`.
2. Crear localmente un archivo `.env` en la raíz del proyecto. Este archivo no debe subirse al repositorio.
3. Configurar allí la URL de la aplicación, conexión a MySQL, datos del administrador inicial y las tres respuestas `SEED_SECURITY_ANSWER_1`, `SEED_SECURITY_ANSWER_2` y `SEED_SECURITY_ANSWER_3`.
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

El archivo `database/schema.sql` contiene solamente el modelo relacional necesario para los módulos programados en esta primera entrega:

- `estado_usuario`
- `persona`
- `rol`
- `permiso`
- `rol_permiso`
- `usuario`
- `establecimiento`
- `potrero`
- `recurso_potrero`
- `pregunta_seguridad`
- `respuesta_seguridad_usuario`
- `usuario_permiso`

Las entidades de animales, movimientos, sanidad, reproducción, costos, compras, ventas, documentación y auditoría se incorporarán en entregas posteriores, cuando sus respectivos módulos sean programados. De esta manera, la base ejecutable no contiene tablas todavía ajenas al alcance desarrollado.

El script `database/seed.php` carga los permisos de potreros, los asigna a los roles, crea el establecimiento La Celina y registra el usuario inicial indicado en `.env`. Puede ejecutarse nuevamente sin duplicar esos datos.

## Rutas principales

| Método | Ruta | Función | Permiso |
|---|---|---|---|
| GET | `/login` | Mostrar acceso | Público |
| POST | `/login` | Autenticar | Público |
| POST | `/logout` | Cerrar sesión | Autenticado |
| GET | `/recuperar` | Iniciar recuperación | Público |
| POST | `/recuperar/verificar` | Validar tres respuestas | Público |
| POST | `/recuperar/nueva-contrasena` | Cambiar contraseña recuperada | Público |
| GET | `/dashboard` | Panel provisional | Autenticado |
| GET | `/usuarios` | Listar usuarios | `USUARIO_GESTIONAR` |
| POST | `/usuarios` | Crear usuario | `USUARIO_GESTIONAR` |
| POST | `/usuarios/{id}/actualizar` | Editar usuario | `USUARIO_GESTIONAR` |
| POST | `/usuarios/{id}/desactivar` | Desactivar usuario | `USUARIO_GESTIONAR` |
| GET | `/potreros` | Listar potreros | `POTRERO_CONSULTAR` |
| GET | `/potreros/crear` | Formulario de alta | `POTRERO_CREAR` |
| POST | `/potreros` | Registrar | `POTRERO_CREAR` |
| GET | `/potreros/{id}` | Consultar detalle | `POTRERO_CONSULTAR` |
| GET | `/potreros/{id}/editar` | Formulario de edición | `POTRERO_EDITAR` |
| POST | `/potreros/{id}/actualizar` | Actualizar | `POTRERO_EDITAR` |
| POST | `/potreros/{id}/recursos` | Agregar recurso | `POTRERO_RECURSOS` |
| POST | `/potreros/{id}/recursos/{recurso}/disponibilidad` | Cambiar disponibilidad | `POTRERO_RECURSOS` |
| GET | `/administracion` | Administrar catálogos | `ROL_GESTIONAR` |

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
