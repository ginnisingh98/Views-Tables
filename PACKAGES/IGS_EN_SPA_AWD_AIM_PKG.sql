--------------------------------------------------------
--  DDL for Package IGS_EN_SPA_AWD_AIM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPA_AWD_AIM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI59S.pls 120.1 2005/06/06 02:51:24 appldev  $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2    DEFAULT NULL,
    x_conferral_date                    IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_award_mark                        IN     NUMBER      DEFAULT NULL,
    x_award_grade                       IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2    DEFAULT NULL,
    x_conferral_date                    IN     DATE        DEFAULT NULL,
    x_award_mark                        IN     NUMBER      DEFAULT NULL,
    x_award_grade                       IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL

  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2    DEFAULT NULL,
    x_conferral_date                    IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_award_mark                        IN     NUMBER      DEFAULT NULL,
    x_award_grade                       IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_complete_ind                      IN     VARCHAR2,
    x_honours_level                     IN     VARCHAR2    DEFAULT NULL,
    x_conferral_date                    IN     DATE        DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_award_mark                        IN     NUMBER      DEFAULT NULL,
    x_award_grade                       IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
    x_mode				IN     VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_award_cd                          IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_person_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_gr_honours_level (
    x_honours_level                      IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_as_grading_sch (
        x_grading_schema_cd                 IN     VARCHAR2,
        x_gs_version_number                 IN     NUMBER
   );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_complete_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_honours_level                     IN     VARCHAR2    DEFAULT NULL,
    x_conferral_date                    IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_award_mark                        IN     NUMBER      DEFAULT NULL,
    x_award_grade                       IN     VARCHAR2    DEFAULT NULL,
    x_grading_schema_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_gs_version_number                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_spa_awd_aim_pkg;

 

/
