-- payment(reservation_id) -- la vista de detalle de reserva embebe el pago asociado.
CREATE INDEX ix_payment_reservation_id ON payment.payment (reservation_id);

-- payment(status) -- la cola de revisión de pagos filtra PENDING_REVIEW.
CREATE INDEX ix_payment_status ON payment.payment (status);

-- bank_account(is_active) -- el checkout solo muestra cuentas activas.
CREATE INDEX ix_bank_account_is_active ON payment.bank_account (is_active);

-- invoice(reservation_id) ya tiene su propio índice por el UNIQUE de la tabla (uq_invoice_reservation_id).
