--------------------------------------------------------
--  DDL for Package IGS_AS_ANON_ID_US_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_ANON_ID_US_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI62S.pls 115.2 2003/05/20 05:19:48 svanukur noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_anonymous_id                      IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_anonymous_id                      IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_anonymous_id                      IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_anonymous_id                      IN     VARCHAR2,
    x_system_generated_ind              IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_teach_cal_type                    IN     VARCHAR2,
    x_teach_ci_sequence_number          IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_load_cal_type                     IN     VARCHAR2,
    x_load_ci_sequence_number           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN      NUMBER

  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_en_su_attempt (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
      );

  PROCEDURE get_fk_igs_en_stdnt_ps_att (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_anonymous_id                      IN     VARCHAR2    DEFAULT NULL,
    x_system_generated_ind              IN     VARCHAR2    DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_teach_cal_type                    IN     VARCHAR2    DEFAULT NULL,
    x_teach_ci_sequence_number          IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_load_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_load_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_anon_id_us_pkg;

 

/
