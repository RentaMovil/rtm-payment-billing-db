-- 06-data/models.md -> bank_account. Cuentas de la empresa mostradas en el checkout.
-- Sin FKs: no depende de ninguna otra tabla.
CREATE TABLE payment.bank_account (
    bank_account_id INT IDENTITY(1,1) NOT NULL,
    bank_name       VARCHAR(100)      NOT NULL,
    account_holder  VARCHAR(150)      NOT NULL,
    -- QR mostrado en el checkout; lo sube el navegador a Cloudinary, aquí solo se guarda la URL.
    qr_image_url    VARCHAR(255)      NOT NULL,
    -- Sin DELETE: desactivar saca la cuenta del checkout pero conserva su historial de pagos.
    is_active       BIT               NOT NULL,

    CONSTRAINT pk_bank_account PRIMARY KEY (bank_account_id)
);
