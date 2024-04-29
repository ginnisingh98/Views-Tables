--------------------------------------------------------
--  DDL for Package IGS_AS_UNIT_AI_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_UNIT_AI_GRP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI81S.pls 115.0 2003/12/05 10:39:23 kdande noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_ass_item_group_id            IN OUT NOCOPY NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_ass_item_group_id            IN OUT NOCOPY NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_unit_ass_item_group_id            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_group_name                        IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_unit_ofr_pat (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_ass_item_group_id            IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_group_name                        IN     VARCHAR2    DEFAULT NULL,
    x_midterm_formula_code              IN     VARCHAR2    DEFAULT NULL,
    x_midterm_formula_qty               IN     NUMBER      DEFAULT NULL,
    x_midterm_weight_qty                IN     NUMBER      DEFAULT NULL,
    x_final_formula_code                IN     VARCHAR2    DEFAULT NULL,
    x_final_formula_qty                 IN     NUMBER      DEFAULT NULL,
    x_final_weight_qty                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_unit_ai_grp_pkg;

 

/
