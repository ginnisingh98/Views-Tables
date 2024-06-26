--------------------------------------------------------
--  DDL for Package IGF_AW_CAREER_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_CAREER_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI46S.pls 115.4 2002/11/28 12:17:20 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_career_level_id                   IN OUT NOCOPY NUMBER,
    x_program_type                      IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_career_level_id                   IN     NUMBER,
    x_program_type                      IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_career_level_id                   IN     NUMBER,
    x_program_type                      IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_career_level_id                   IN OUT NOCOPY NUMBER,
    x_program_type                      IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_career_level_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_program_type                      IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_type (
    x_course_type                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_career_level_id                   IN     NUMBER      DEFAULT NULL,
    x_program_type                      IN     VARCHAR2    DEFAULT NULL,
    x_class_standing                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_career_map_pkg;

 

/
