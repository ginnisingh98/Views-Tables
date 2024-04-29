--------------------------------------------------------
--  DDL for Package IGS_AS_STU_TRN_CMTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_STU_TRN_CMTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI78S.pls 115.0 2003/10/14 06:25:16 anilk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_comment_id                        IN OUT NOCOPY NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_comment_id                        IN     NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_comment_id                        IN     NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_comment_id                        IN OUT NOCOPY NUMBER,
    x_comment_type_code                 IN     VARCHAR2,
    x_comment_txt                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_comment_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_comment_type_code                 IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_course_type                       IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_en_unit_set (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_awd (
    x_award_cd                          IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ps_type (
    x_course_type                       IN     VARCHAR2
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_comment_id                        IN     NUMBER      DEFAULT NULL,
    x_comment_type_code                 IN     VARCHAR2    DEFAULT NULL,
    x_comment_txt                       IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_course_type                       IN     VARCHAR2    DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_load_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_load_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_us_version_number                 IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_stu_trn_cmts_pkg;

 

/
