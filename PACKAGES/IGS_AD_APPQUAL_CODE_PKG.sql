--------------------------------------------------------
--  DDL for Package IGS_AD_APPQUAL_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPQUAL_CODE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAII1S.pls 120.0 2005/10/14 10:27:12 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_qualifying_type_code              IN     VARCHAR2,
    x_qualifying_code_id                IN     NUMBER,
    x_qualifying_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_qualifying_type_code              IN     VARCHAR2,
    x_qualifying_code_id                IN     NUMBER,
    x_qualifying_value                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_qualifying_type_code              IN     VARCHAR2,
    x_qualifying_code_id                IN     NUMBER,
    x_qualifying_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_id                         IN OUT NOCOPY NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_qualifying_type_code              IN     VARCHAR2,
    x_qualifying_code_id                IN     NUMBER,
    x_qualifying_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_qualifying_type_code              IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_ps_appl_inst (
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );
  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id IN NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_qualifying_type_code              IN     VARCHAR2    DEFAULT NULL,
    x_qualifying_code_id                IN     NUMBER      DEFAULT NULL,
    x_qualifying_value                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_appqual_code_pkg;

 

/
