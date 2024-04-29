--------------------------------------------------------
--  DDL for Package IGS_EN_SPAA_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPAA_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI72S.pls 115.0 2003/10/09 09:29:32 anilk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_complete_flag                     IN     VARCHAR2,
    x_conferral_date                    IN     DATE,
    x_award_mark                        IN     NUMBER,
    x_award_grade                       IN     VARCHAR2,
    x_grading_schema_cd                 IN     VARCHAR2,
    x_gs_version_number                 IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_creation_date                     IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_as_grd_schema (
    x_grading_schema_cd                 IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_complete_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_conferral_date                    IN     DATE        DEFAULT NULL,
    x_award_mark                        IN     NUMBER      DEFAULT NULL,
    x_award_grade                       IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_spaa_hist_pkg;

 

/
