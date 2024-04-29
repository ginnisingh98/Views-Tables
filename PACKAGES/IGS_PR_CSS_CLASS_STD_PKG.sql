--------------------------------------------------------
--  DDL for Package IGS_PR_CSS_CLASS_STD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_CSS_CLASS_STD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI31S.pls 115.5 2002/11/29 03:22:26 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_pr_css_class_std_id           IN OUT NOCOPY NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_pr_css_class_std_id           IN     NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_pr_css_class_std_id           IN OUT NOCOPY NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_igs_pr_class_std_id               IN     NUMBER,
    x_min_cp                            IN     NUMBER,
    x_max_cp                            IN     NUMBER,
    x_acad_year                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_pr_css_class_std_id           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_igs_pr_class_std_id               IN     NUMBER,
    x_igs_pr_cs_schdl_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_cs_schdl (
    x_igs_pr_cs_schdl_id                IN     NUMBER
  );

  PROCEDURE get_fk_igs_pr_class_std (
    x_igs_pr_class_std_id               IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_pr_css_class_std_id           IN     NUMBER      DEFAULT NULL,
    x_igs_pr_cs_schdl_id                IN     NUMBER      DEFAULT NULL,
    x_igs_pr_class_std_id               IN     NUMBER      DEFAULT NULL,
    x_min_cp                            IN     NUMBER      DEFAULT NULL,
    x_max_cp                            IN     NUMBER      DEFAULT NULL,
    x_acad_year                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_css_class_std_pkg;

 

/
