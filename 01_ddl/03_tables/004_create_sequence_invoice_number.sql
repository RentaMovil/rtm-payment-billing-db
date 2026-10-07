-- invoice.invoice_number es el identificador humano de la factura (INV-000123), independiente del
-- invoice_id interno. Una SEQUENCE evita el problema de derivarlo del IDENTITY recién insertado
-- (habría que hacer el INSERT en dos pasos porque la columna es NOT NULL + UNIQUE desde el inicio).
CREATE SEQUENCE payment.seq_invoice_number
    AS INT
    START WITH 1
    INCREMENT BY 1
    NO CYCLE;
