# Laboratorio 5 · Registro e inicio de sesión con Supabase

Aplicación Flutter del curso **Aplicaciones Móviles (Icesi)** que implementa el registro, el inicio y el cierre de sesión de usuarios con **Supabase**, organizada con **Clean Architecture** y **Bloc**.

## Qué hace

- **Registro** (`/register`): crea la cuenta en Supabase Auth (correo y contraseña) y guarda el perfil (`username`, `full_name`) en la tabla `profiles`, usando como `id` el UID que devolvió Auth.
- **Inicio de sesión** (`/login`): abre la sesión con correo y contraseña y trae el perfil de esa cuenta.
- **Perfil** (`/home`): muestra el nombre, el usuario y el correo real de la cuenta.
- **Cierre de sesión**: cierra la sesión en Supabase y vuelve al login borrando el historial.

Registrar e iniciar sesión son **dos pasos** contra dos servicios distintos (Auth y la tabla `profiles`). El orden lo decide el `UseCase` correspondiente. Si el segundo paso falla, el `UseCase` cierra la sesión que se abrió y lanza un error de dominio (`AuthFailure`) que el `Bloc` muestra en pantalla.

## Arquitectura

Las capas externas dependen de las internas, nunca al revés. El dominio no importa Flutter ni Supabase.

```
Vista ──evento──▶ Bloc ──▶ UseCase ──▶ Repository (contrato)
                                            ▲ implementa
                                    RepositoryImpl ──▶ DataSource ──▶ Supabase
```

| Capa | Contenido |
|---|---|
| **Dominio** | Entidades `AuthUser` y `Profile`, contratos `AuthRepository` y `ProfileRepository`, `SignUpUseCase`, `SignInUseCase`, `SignOutUseCase` y el error `AuthFailure` |
| **Datos** | `SupabaseAuthDataSource` y `SupabaseProfileDataSource` (los únicos que usan el SDK de Supabase) y sus `RepositoryImpl` |
| **Presentación** | `RegisterBloc`, `LoginBloc` y `HomeBloc` (estado único con `status` y `copyWith`) y sus pantallas |

Las dependencias se arman en un solo lugar: `main.dart` crea los repositorios de Supabase y cada ruta construye su cadena (`UseCase` → `Bloc`) en el `create` de su `BlocProvider`.

```
lib/
├── main.dart                 inicializa Supabase y define las rutas
├── theme/                    colores y tema
├── components/               PrimaryButton, ErrorMessage, ProfileField
└── features/
    ├── auth/
    │   ├── domain/           entities · errors · repository · usecases
    │   └── data/             source · repository
    ├── register/ui/          bloc · screens
    ├── login/ui/             bloc · screens
    └── home/ui/              bloc · screens · home_args.dart
```

## Base de datos

La tabla `profiles` se crea con la migración de `supabase/migrations/`:

```sql
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null,
  full_name text not null
);

grant select, insert, update on public.profiles to authenticated;
```

En `supabase/config.toml` el registro por email está activo y la confirmación de correo desactivada, de modo que `signUp` devuelve la sesión de inmediato.

## Cómo correrlo

Requisitos: Flutter 3.47 o superior. Para iOS se necesita Xcode con un simulador.

```bash
flutter pub get
flutter run
```

La app ya apunta al proyecto de Supabase del laboratorio (URL y `publishable key` en `main.dart`, que son públicas por diseño). Para usar otro proyecto:

```bash
npx supabase login
npx supabase link --project-ref TU_PROJECT_REF
npx supabase db push
npx supabase config push
```

y reemplaza la URL y la `publishable key` en `main.dart`.

## Tests

```bash
flutter test
```

Siete tests de widgets que recorren el registro, el login y el logout **sin Supabase**: `App` recibe los repositorios por constructor, así que los tests le pasan repositorios falsos. Cubren las validaciones del formulario, el login correcto e incorrecto, el registro con el `id` de Auth y el caso en que falla el perfil (se cierra la sesión y se muestra el error).
