-- Database identity the rtm-payment-billing service connects with (never sa).
-- LOGIN = credentials to enter the SQL Server instance; USER = its identity inside rentamovil.
-- The password comes from liquibase.properties (parameter.paymentAppPassword), never from this repo.

-- Fail fast if the parameter wasn't provided: Liquibase would otherwise leave the literal text.
IF '${paymentAppPassword}' = '$' + '{paymentAppPassword}'
    THROW 50000, 'Missing parameter.paymentAppPassword in liquibase.properties', 1;

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'payment_app')
    CREATE LOGIN payment_app WITH PASSWORD = '${paymentAppPassword}', CHECK_POLICY = ON;

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'payment_app')
    CREATE USER payment_app FOR LOGIN payment_app WITH DEFAULT_SCHEMA = payment;
