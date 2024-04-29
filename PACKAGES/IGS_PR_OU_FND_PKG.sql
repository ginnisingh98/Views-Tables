--------------------------------------------------------
--  DDL for Package IGS_PR_OU_FND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_OU_FND_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI44S.pls 115.2 2002/11/29 03:26:22 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_fund_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_ru_ou (
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_fund_cat (
    x_fund_code                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_progression_rule_cat              IN     VARCHAR2    DEFAULT NULL,
    x_pra_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_pro_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_fund_code                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_ou_fnd_pkg;

 

/
