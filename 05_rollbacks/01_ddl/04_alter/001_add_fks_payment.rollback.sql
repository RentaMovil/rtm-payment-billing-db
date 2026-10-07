ALTER TABLE payment.invoice DROP CONSTRAINT fk_invoice_reservation;
ALTER TABLE payment.payment DROP CONSTRAINT fk_payment_reviewed_by;
ALTER TABLE payment.payment DROP CONSTRAINT fk_payment_bank_account;
ALTER TABLE payment.payment DROP CONSTRAINT fk_payment_reservation;
