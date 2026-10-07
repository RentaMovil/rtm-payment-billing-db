# rtm-payment-billing-db

Migraciones Liquibase de las tablas del servicio **Payment & Billing** de RentaMovil (pago por
transferencia bancaria con revisión manual del Admin, y facturación — ver
`rtm-docs/09-microservices/service-catalog.md`).

- **Base de datos:** `rentamovil` (SQL Server), **compartida** por todos los servicios.
- **Schema propio:** `payment` — toda tabla de este repo se crea como `payment.<tabla>`. Ninguna
  tabla va en `dbo`.
- **Tablas:** `bank_account`, `payment`, `invoice`. Más la secuencia `seq_invoice_number`.
- **Historial Liquibase propio:** `dbo.DATABASECHANGELOG_PAYMENT` / `dbo.DATABASECHANGELOGLOCK_PAYMENT`.
- **Orden entre repos:** 5.º (último) — `payment.reservation_id` e `invoice.reservation_id`
  tienen FK a `booking.reservation`, y `payment.reviewed_by` a `iam.[user]`. `rtm-booking-db` y
  `rtm-iam-db` corren antes. Decisión en ADR-009.

Convenciones completas (estructura, nombres, orden, rollback): `rtm-docs/06-data/migration-strategy.md`.

## Estado actual

Esquema completo: a diferencia de `rtm-booking-db` (que corrió antes de que este servicio
existiera), **todas las FKs se crean en el mismo PR** — los dos repos de los que depende ya
estaban migrados.

## Estructura

```
changelog/changelog-master.yaml   ← punto de entrada: incluye 01_ddl → 02_dml → 03_dcl → 04_tcl
01_ddl/                           DDL
  01_schemas/                       CREATE SCHEMA payment
  03_tables/                        CREATE TABLE y CREATE SEQUENCE, sin FKs
  04_alter/                         FKs hacia booking.reservation e iam.[user]
  05_views/                         CREATE VIEW (vacío)
  10_indexes/                       CREATE INDEX
02_dml/                           DML (vacío: sin catálogos de referencia propios)
03_dcl/                           DCL
  00_roles/                         usuario de BD del servicio (payment_app)
  01_grants/                        permisos sobre el schema payment
04_tcl/                           TCL (vacío)
05_rollbacks/                     espejo de 01_ddl … 03_dcl: un .rollback.sql por cada .sql
```

Todas estas carpetas existen aunque estén vacías: una carpeta sin changesets tiene
`databaseChangeLog: []` en su `changelog.yaml` (y `.gitkeep` en su espejo de `05_rollbacks`).

## Por qué una `SEQUENCE` para `invoice_number`

`invoice.invoice_number` (`INV-000123`) es `NOT NULL` + `UNIQUE` desde el primer INSERT, así que
no se puede derivar del `invoice_id` recién generado sin partir el insert en dos pasos. Una
`SEQUENCE` propia (`payment.seq_invoice_number`) evita ese problema: el servicio pide el próximo
valor con `NEXT VALUE FOR` antes de construir la fila.

## Requisitos

- Java 17+
- Maven 3.9+
- Docker Desktop
- **SQL Server ya levantado y migrado desde `rtm-iam-db`**, y **`rtm-booking-db` ya migrado**
  (este repo no levanta SQL Server y sus FKs necesitan `booking.reservation` ya creada)

## Uso local

```bash
# 1. Configuración local (una sola vez)
cp .env.example .env
cp liquibase.properties.example liquibase.properties
# edita la contraseña de sa en los dos archivos (deben coincidir) y pon en
# liquibase.properties una contraseña para payment_app (parameter.paymentAppPassword)

# 2. Verificar que rtm-iam-db y rtm-booking-db ya corrieron
cd ../../Iam/rtm-iam-db && docker compose up -d
cd ../../booking-reservation/rtm-booking-db && docker compose up -d

# 3. Ver qué changesets faltan
mvn liquibase:status

# 4. Ver el SQL sin ejecutarlo
mvn liquibase:updateSQL

# 5. Aplicar
mvn liquibase:update
```

Otros comandos:

```bash
mvn liquibase:rollback -Dliquibase.rollbackCount=1   # deshace el último changeset
```

### Con Docker (red compartida `rentamovil`)

```bash
# SQL Server + base + migraciones de IAM primero, después booking
cd ../../Iam/rtm-iam-db && docker compose up -d
cd ../../booking-reservation/rtm-booking-db && docker compose up -d

# Después, las migraciones de payment-billing
docker compose up -d
```

| Contenedor | Qué hace | Estado normal |
|---|---|---|
| `migrations` | Corre las migraciones de este repo (igual que `mvn liquibase:update`) | `Exited (0)` |

Orden para levantar todo: **rtm-iam-db → rtm-booking-reservation-db → rtm-fleet-maintenance-db →
rtm-payment-billing-db → rtm-iam → rtm-api-gateway → rtm-fleet-maintenance →
rtm-booking-reservation → rtm-payment-billing**.

## Usuario de base de datos del servicio (`03_dcl`)

Las migraciones corren con `sa`. El servicio `rtm-payment-billing` **nunca** usa `sa`: se conecta
con `payment_app`, que solo puede leer y escribir datos del schema `payment` (sin DDL, sin acceso
a otros schemas ni a `dbo`). Su contraseña **no está en el repo**: sale de
`parameter.paymentAppPassword` en `liquibase.properties` (git-ignored). Si falta, el changeset
falla a propósito.

Esa restricción es lo que hace coherente la base compartida con la matriz de propiedad de datos
(`09-microservices/service-catalog.md`): `payment_app` no puede leer `iam.*`, `booking.*` ni
`fleet.*` ni por error. Las FKs que cruzan servicios funcionan igual, porque las valida el motor y
no el usuario de aplicación — por eso este servicio nunca hace un `JOIN` directo contra
`booking.reservation` para el monto: siempre llama a la API de `booking-reservation`
(`decisions.md` del servicio en `rtm-docs`).

> Al usar parámetros, el plugin de Maven imprime un `NoSuchFieldException: The field
> 'parameter.paymentAppPassword' could not be found...` con stack trace. Es inofensivo: el plugin
> intenta leerlo como opción propia y después lo usa correctamente como parámetro. Lo que importa
> es el `BUILD SUCCESS` final.

## Ramas

`feat/`, `fix/`, `chore/` → PR a `develop` (Squash and Merge). Ver
`rtm-docs/00-governance/git-conventions.md`.
