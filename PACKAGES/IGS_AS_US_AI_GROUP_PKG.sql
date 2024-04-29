--------------------------------------------------------
--  DDL for Package IGS_AS_US_AI_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_US_AI_GROUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI82S.pls 120.0 2005/07/05 13:02:17 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_us_ass_item_group_id              IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
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
    x_us_ass_item_group_id              IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
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
    x_us_ass_item_group_id              IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
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
    x_us_ass_item_group_id              IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
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
    x_us_ass_item_group_id              IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_us_ass_item_group_id              IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
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

END igs_as_us_ai_group_pkg;

 

/
