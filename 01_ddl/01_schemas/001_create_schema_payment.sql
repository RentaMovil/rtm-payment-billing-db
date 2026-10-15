-- Schema that holds every table owned by the payment-billing service inside the shared
-- rentamovil database. CREATE SCHEMA must be the only statement in its batch, hence the EXEC wrapper.
IF SCHEMA_ID('payment') IS NULL
    EXEC('CREATE SCHEMA payment');
