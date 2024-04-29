--------------------------------------------------------
--  DDL for Package IGS_HE_AD_DTL_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_AD_DTL_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI20S.pls 120.1 2005/06/09 23:39:39 appldev  $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_hesa_ad_dtl_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_occupation_cd                     IN     VARCHAR2,
    x_domicile_cd                       IN     VARCHAR2,
    x_social_class_cd                   IN     VARCHAR2,
    x_special_student_cd                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_hesa_ad_dtl_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_ps_appl_inst_all (
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_hesa_ad_dtl_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_occupation_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_domicile_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_social_class_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_special_student_cd                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ad_dtl_all_pkg;

 

/
