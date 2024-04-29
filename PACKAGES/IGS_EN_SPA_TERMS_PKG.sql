--------------------------------------------------------
--  DDL for Package IGS_EN_SPA_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPA_TERMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI76S.pls 120.3 2005/07/18 05:58:34 appldev ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_term_record_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_plan_sht_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_term_record_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_plan_sht_status                   IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_term_record_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_plan_sht_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_term_record_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_cd                        IN     VARCHAR2,
    x_program_version                   IN     NUMBER,
    x_acad_cal_type                     IN     VARCHAR2,
    x_term_cal_type                     IN     VARCHAR2,
    x_term_sequence_number              IN     NUMBER,
    x_key_program_flag                  IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_coo_id                            IN     NUMBER,
    x_class_standing_id                 IN     NUMBER,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_plan_sht_status                   IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE GET_FK_IGS_CA_INST (
    X_CAL_TYPE IN VARCHAR2,
    X_SEQUENCE_NUMBER IN NUMBER
  );

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
  );

  PROCEDURE GET_FK_IGS_FI_FEE_CAT (
    x_fee_cat IN VARCHAR2
  );

  PROCEDURE GET_FK_IGS_PR_CLASS_STD(
    X_IGS_PR_CLASS_STD_ID IN NUMBER
  );

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
      x_coo_id IN VARCHAR2
  );

  PROCEDURE check_child_existence (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    );


  FUNCTION get_pk_for_validation (
    x_term_record_id                    IN    NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN    NUMBER,
    x_program_cd                        IN    VARCHAR2,
    x_term_cal_type                     IN    VARCHAR2,
    x_term_sequence_number              IN    NUMBER

  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_term_record_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_program_cd                        IN     VARCHAR2    DEFAULT NULL,
    x_program_version                   IN     NUMBER      DEFAULT NULL,
    x_acad_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_term_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_term_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_key_program_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_attendance_mode                   IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_fee_cat                           IN     VARCHAR2    DEFAULT NULL,
    x_coo_id                            IN     NUMBER      DEFAULT NULL,
    x_class_standing_id                 IN     NUMBER      DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_plan_sht_status                   IN     VARCHAR2    DEFAULT NULL
  );

END igs_en_spa_terms_pkg;

 

/
