--------------------------------------------------------
--  DDL for Package IGS_AD_PANEL_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PANEL_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIH1S.pls 120.0 2005/06/01 18:24:52 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_panel_code                        IN     VARCHAR2,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_final_decision_code               IN     VARCHAR2,
    x_final_decision_type               IN     VARCHAR2,
    x_final_decision_date               IN     DATE,
    x_closed_flag                        IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_panel_code                        IN     VARCHAR2,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_final_decision_code               IN     VARCHAR2,
    x_final_decision_type               IN     VARCHAR2,
    x_final_decision_date               IN     DATE,
    x_closed_flag                        IN     VARCHAR2,
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
    x_attribute20                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_panel_code                        IN     VARCHAR2,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_final_decision_code               IN     VARCHAR2,
    x_final_decision_type               IN     VARCHAR2,
    x_final_decision_date               IN     DATE,
    x_closed_flag                        IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_panel_code                        IN     VARCHAR2,
    x_interview_date                    IN     DATE,
    x_interview_time                    IN     DATE,
    x_location_cd                       IN     VARCHAR2,
    x_room_id                           IN     NUMBER,
    x_final_decision_code               IN     VARCHAR2,
    x_final_decision_type               IN     VARCHAR2,
    x_final_decision_date               IN     DATE,
    x_closed_flag                        IN     VARCHAR2,
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
    x_mode                              IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_panel_dtls_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_panel_code                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_intvw_pnls (
    x_panel_code                        IN     VARCHAR2
  );


  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ad_room (
    x_room_id                           IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ad_code_classes (
    x_name                              IN     VARCHAR2,
    x_class                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_panel_dtls_id                     IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_panel_code                        IN     VARCHAR2    DEFAULT NULL,
    x_interview_date                    IN     DATE        DEFAULT NULL,
    x_interview_time                    IN     DATE    DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_room_id                           IN     NUMBER      DEFAULT NULL,
    x_final_decision_code               IN     VARCHAR2    DEFAULT NULL,
    x_final_decision_type               IN     VARCHAR2    DEFAULT NULL,
    x_final_decision_date               IN     DATE        DEFAULT NULL,
    x_closed_flag                        IN     VARCHAR2    DEFAULT NULL,
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
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_panel_dtls_pkg;

 

/