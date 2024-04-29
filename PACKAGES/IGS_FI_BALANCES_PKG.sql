--------------------------------------------------------
--  DDL for Package IGS_FI_BALANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BALANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI99S.pls 115.7 2003/02/14 05:53:42 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_id                        IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_balance_id                        IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_balance_id                        IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_id                        IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_standard_balance                  IN     NUMBER,
    x_fee_balance                       IN     NUMBER,
    x_holds_balance                     IN     NUMBER,
    x_balance_date                      IN     DATE,
    x_fee_balance_rule_id               IN     NUMBER,
    x_holds_balance_rule_id             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_balance_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  /*  Removed the procedure get_fk_igs_fi_subaccts_all as a part of Bug # 2564643 */

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_balance_id                        IN     NUMBER      DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_standard_balance                  IN     NUMBER      DEFAULT NULL,
    x_fee_balance                       IN     NUMBER      DEFAULT NULL,
    x_holds_balance                     IN     NUMBER      DEFAULT NULL,
    x_balance_date                      IN     DATE        DEFAULT NULL,
    x_fee_balance_rule_id               IN     NUMBER      DEFAULT NULL,
    x_holds_balance_rule_id             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );


END igs_fi_balances_pkg;

 

/
