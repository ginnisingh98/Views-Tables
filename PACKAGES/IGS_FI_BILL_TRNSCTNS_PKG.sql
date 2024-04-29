--------------------------------------------------------
--  DDL for Package IGS_FI_BILL_TRNSCTNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BILL_TRNSCTNS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIB7S.pls 115.3 2002/11/29 04:05:29 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_transaction_id                    IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_transaction_id                    IN OUT NOCOPY NUMBER,
    x_bill_id                           IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_transaction_number                IN     VARCHAR2,
    x_fee_credit_type                   IN     VARCHAR2,
    x_transaction_description           IN     VARCHAR2,
    x_transaction_amount                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_transaction_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_transaction_type                  IN     VARCHAR2,
    x_invoice_creditact_id              IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_inv_int (
    x_invoice_id                        IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_cr_activities (
    x_credit_activity_id                IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_transaction_id                    IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_invoice_creditact_id              IN     NUMBER      DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_transaction_number                IN     VARCHAR2    DEFAULT NULL,
    x_fee_credit_type                   IN     VARCHAR2    DEFAULT NULL,
    x_transaction_description           IN     VARCHAR2    DEFAULT NULL,
    x_transaction_amount                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_bill_trnsctns_pkg;

 

/
