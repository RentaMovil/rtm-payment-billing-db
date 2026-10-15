-- 06-data/models.md -> payment. El Aggregate Root de este contexto: comprobante de transferencia
-- subido por el cliente y su revisión manual por un Administrador.
--
-- Creada sin FKs; se agregan en 04_alter, una vez que las tablas que referencia ya existen
-- (reservation la crea rtm-booking-db, [user] la crea rtm-iam-db, ambas corren antes que este repo).
CREATE TABLE payment.payment (
    payment_id       INT IDENTITY(1,1) NOT NULL,
    reservation_id   INT               NOT NULL,
    bank_account_id  INT               NOT NULL,
    payment_date     DATETIME          NOT NULL,
    -- Debe coincidir exacto con reservation.total_amount (Payment.INV-001, sin pagos parciales)
    amount           DECIMAL(10,2)     NOT NULL,
    reference_number VARCHAR(100)      NULL,
    -- Comprobante subido por el cliente a Cloudinary; aquí solo se guarda la URL.
    receipt_file_url VARCHAR(255)      NOT NULL,
    status           VARCHAR(30)       NOT NULL,
    -- NULL mientras status = PENDING_REVIEW; se completa al aprobar o rechazar.
    reviewed_by      INT               NULL,
    reviewed_at      DATETIME          NULL,
    rejection_reason VARCHAR(255)      NULL,

    CONSTRAINT pk_payment PRIMARY KEY (payment_id),
    CONSTRAINT ck_payment_status CHECK (status IN ('PENDING_REVIEW', 'APPROVED', 'REJECTED')),
    CONSTRAINT ck_payment_amount CHECK (amount > 0)
    -- reservation_id NO es Unique: un intento rechazado deja su propia fila (historial/reintento),
    -- así que puede haber varios payment REJECTED antes de uno APPROVED para la misma reserva.
    -- "como mucho un APPROVED por reserva" se aplica en la capa de aplicación (data-model.md).
);
