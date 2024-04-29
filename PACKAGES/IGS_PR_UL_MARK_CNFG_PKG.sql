--------------------------------------------------------
--  DDL for Package IGS_PR_UL_MARK_CNFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_UL_MARK_CNFG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI46S.pls 115.0 2003/11/07 10:54:44 ijeddy noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mark_config_id                    IN OUT NOCOPY NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_total_unit_level_credits          IN     NUMBER,
    x_selection_method_code             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_total_unit_level_credits          IN     NUMBER,
    x_selection_method_code             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_total_unit_level_credits          IN     NUMBER,
    x_selection_method_code             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mark_config_id                    IN OUT NOCOPY NUMBER,
    x_unit_level                        IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_total_unit_level_credits          IN     NUMBER,
    x_selection_method_code             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_mark_config_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_level                        IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_unit_level (
    x_unit_level                        IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mark_config_id                    IN     NUMBER      DEFAULT NULL,
    x_unit_level                        IN     VARCHAR2    DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_total_unit_level_credits          IN     NUMBER      DEFAULT NULL,
    x_selection_method_code             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_ul_mark_cnfg_pkg;

 

/
