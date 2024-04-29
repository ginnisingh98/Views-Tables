--------------------------------------------------------
--  DDL for Package IGS_FI_OTC_CHARGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_OTC_CHARGES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIA4S.pls 115.3 2002/11/29 04:01:32 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_otc_charge_id                     IN OUT NOCOPY NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_otc_charge_id                     IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_otc_charge_id                     IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_otc_charge_id                     IN OUT NOCOPY NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_otc_charge_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_credit_id                         IN     NUMBER,
    x_invoice_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_credits_all (
    x_credit_id                         IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_inv_int_all (
    x_invoice_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_otc_charge_id                     IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_credit_id                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_otc_charges_pkg;

 

/
