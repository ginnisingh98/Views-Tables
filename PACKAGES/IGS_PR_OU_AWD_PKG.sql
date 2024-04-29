--------------------------------------------------------
--  DDL for Package IGS_PR_OU_AWD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_OU_AWD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI40S.pls 115.4 2003/02/25 06:53:27 sarakshi noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_award_cd                          IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

   PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_pro_sequence_number               IN     NUMBER,
    x_award_cd                          IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_pr_ru_ou (
    x_progression_rule_cat              IN     VARCHAR2,
    x_pra_sequence_number               IN     NUMBER,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_progression_rule_cat              IN     VARCHAR2    DEFAULT NULL,
    x_pra_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_pro_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_ou_awd_pkg;

 

/
