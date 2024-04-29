--------------------------------------------------------
--  DDL for Package IGS_FI_APP_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_APP_RULES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI90S.pls 120.1 2005/10/07 02:53:58 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_rule_id                      IN OUT NOCOPY NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_rule_id                      IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type                         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_rule_id                      IN     NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_rule_id                      IN OUT NOCOPY NUMBER,
    x_appl_hierarchy_id                 IN     NUMBER,
    x_rule_sequence                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_enabled_flag                      IN     VARCHAR2,
    x_rule_type                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_appl_rule_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_appl_hierarchy_id                 IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_rule_type                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_a_hierarchies (
    x_appl_hierarchy_id                 IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_rule_id                      IN     NUMBER      DEFAULT NULL,
    x_appl_hierarchy_id                 IN     NUMBER      DEFAULT NULL,
    x_rule_sequence                     IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_rule_type                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_app_rules_pkg;

 

/
