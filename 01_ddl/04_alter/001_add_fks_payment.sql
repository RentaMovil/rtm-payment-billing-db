-- Foreign keys for the tables created in 03_tables.
--
-- All target tables already exist: payment-billing-db runs 5.º (last), after rtm-booking-db and
-- rtm-iam-db have already migrated (06-data/migration-strategy.md, data-model.md "Repo de
-- migraciones" section). Unlike rtm-booking-db's 04_alter, there is nothing to defer here.
--
-- payment_app has no SELECT on booking.* or iam.*, so these FKs are integrity for free, not a
-- read channel (same note as booking.reservation.client_id -> iam.person) -- this service never
-- reads reservation/[user] directly by SQL; it calls booking-reservation's API instead
-- (decisions.md "verificación del monto vía API, nunca por SQL directo").

-- payment -> booking.reservation (the reservation being paid)
ALTER TABLE payment.payment
    ADD CONSTRAINT fk_payment_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation(reservation_id);

-- payment -> own bank_account catalog
ALTER TABLE payment.payment
    ADD CONSTRAINT fk_payment_bank_account FOREIGN KEY (bank_account_id)
        REFERENCES payment.bank_account(bank_account_id);

-- payment -> iam.[user] (nullable: set only once an Admin reviews it)
ALTER TABLE payment.payment
    ADD CONSTRAINT fk_payment_reviewed_by FOREIGN KEY (reviewed_by)
        REFERENCES iam.[user](user_id);

-- invoice -> booking.reservation (1:1, enforced by uq_invoice_reservation_id above)
ALTER TABLE payment.invoice
    ADD CONSTRAINT fk_invoice_reservation FOREIGN KEY (reservation_id)
        REFERENCES booking.reservation(reservation_id);
