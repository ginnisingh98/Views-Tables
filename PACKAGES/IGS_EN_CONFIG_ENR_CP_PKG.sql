--------------------------------------------------------
--  DDL for Package IGS_EN_CONFIG_ENR_CP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_CONFIG_ENR_CP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI65S.pls 115.2 2002/11/28 23:48:33 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_min_cp_per_term                   IN     NUMBER,
    x_max_cp_per_term                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_min_cp_per_term                   IN     NUMBER,
    x_max_cp_per_term                   IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_min_cp_per_term                   IN     NUMBER,
    x_max_cp_per_term                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_min_cp_per_term                   IN     NUMBER,
    x_max_cp_per_term                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_type (
    x_cal_type                          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_min_cp_per_term                   IN     NUMBER      DEFAULT NULL,
    x_max_cp_per_term                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_config_enr_cp_pkg;

 

/
