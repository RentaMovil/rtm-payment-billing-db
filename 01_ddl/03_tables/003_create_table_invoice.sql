-- 06-data/models.md -> invoice. Factura generada al aprobar un payment; 1:1 con reservation
-- (toda la reserva se factura como un solo documento, no por cada payment individual).
--
-- Creada sin FK a reservation; se agrega en 04_alter junto con las demás FKs cruzadas.
CREATE TABLE payment.invoice (
    invoice_id      INT IDENTITY(1,1) NOT NULL,
    reservation_id  INT               NOT NULL,
    invoice_number  VARCHAR(50)       NOT NULL,
    generated_date  DATETIME          NOT NULL,
    -- NULL justo después de generarse, antes de que termine de subirse el PDF (data-model.md).
    invoice_pdf_url VARCHAR(255)      NULL,

    CONSTRAINT pk_invoice PRIMARY KEY (invoice_id),
    CONSTRAINT uq_invoice_reservation_id UNIQUE (reservation_id),
    CONSTRAINT uq_invoice_number UNIQUE (invoice_number)
);
