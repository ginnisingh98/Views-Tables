--------------------------------------------------------
--  DDL for Package IGS_FI_BALANCE_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BALANCE_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI95S.pls 115.6 2003/02/14 05:30:38 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_rule_id                   IN OUT NOCOPY NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_balance_rule_id                   IN     NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE        DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_balance_rule_id                   IN     NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_balance_rule_id                   IN OUT NOCOPY NUMBER,
    x_balance_name                      IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_last_conversion_date              IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_balance_rule_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
         column_name    IN      VARCHAR2        DEFAULT NULL,
         column_value   IN      VARCHAR2        DEFAULT NULL
    );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_balance_rule_id                   IN     NUMBER      DEFAULT NULL,
    x_balance_name                      IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_last_conversion_date              IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_balance_rules_pkg;

 

/
