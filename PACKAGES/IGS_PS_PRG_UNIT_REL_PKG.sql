--------------------------------------------------------
--  DDL for Package IGS_PS_PRG_UNIT_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_PRG_UNIT_REL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2YS.pls 115.5 2002/11/29 02:20:51 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ps_prun_rel_id                    IN OUT NOCOPY NUMBER,
    x_student_career_level              IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_student_career_transcript         IN     VARCHAR2,
    x_student_career_statistics         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ps_prun_rel_id                    IN     NUMBER,
    x_student_career_level              IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_student_career_transcript         IN     VARCHAR2,
    x_student_career_statistics         IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ps_prun_rel_id                    IN     NUMBER,
    x_student_career_level              IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_student_career_transcript         IN     VARCHAR2,
    x_student_career_statistics         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ps_prun_rel_id                    IN OUT NOCOPY NUMBER,
    x_student_career_level              IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER,
    x_student_career_transcript         IN     VARCHAR2,
    x_student_career_statistics         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ps_prun_rel_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_student_career_level              IN     VARCHAR2,
    x_unit_type_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_unit_type_lvl (
    x_unit_type_id                      IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_type (
    x_course_type                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ps_prun_rel_id                    IN     NUMBER      DEFAULT NULL,
    x_student_career_level              IN     VARCHAR2    DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER      DEFAULT NULL,
    x_student_career_transcript         IN     VARCHAR2    DEFAULT NULL,
    x_student_career_statistics         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END Igs_Ps_Prg_Unit_Rel_Pkg;

 

/
