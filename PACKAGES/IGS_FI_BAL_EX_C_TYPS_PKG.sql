--------------------------------------------------------
--  DDL for Package IGS_FI_BAL_EX_C_TYPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BAL_EX_C_TYPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI98S.pls 115.6 2003/02/14 06:26:51 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bal_exc_credit_type_id            IN OUT NOCOPY NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_bal_exc_credit_type_id            IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_credit_type_id                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_bal_exc_credit_type_id            IN     NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bal_exc_credit_type_id            IN OUT NOCOPY NUMBER,
    x_balance_rule_id                   IN     NUMBER,
    x_credit_type_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_bal_exc_credit_type_id            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation ( x_balance_rule_id IN NUMBER,
                                   x_credit_type_id  IN NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_cr_types_all (
    x_credit_type_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bal_exc_credit_type_id            IN     NUMBER      DEFAULT NULL,
    x_balance_rule_id                   IN     NUMBER      DEFAULT NULL,
    x_credit_type_id                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_bal_ex_c_typs_pkg;

 

/
