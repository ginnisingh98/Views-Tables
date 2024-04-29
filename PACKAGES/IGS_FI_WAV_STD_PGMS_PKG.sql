--------------------------------------------------------
--  DDL for Package IGS_FI_WAV_STD_PGMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_WAV_STD_PGMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF8S.pls 120.0 2005/09/09 19:07:47 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_waiver_student_id                 IN OUT NOCOPY NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_assignment_status_code            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_waiver_student_id                 IN     NUMBER,
    x_object_version_number             IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_assignment_status_code            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_waiver_student_id                 IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_assignment_status_code            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_waiver_student_id                 IN OUT NOCOPY NUMBER,
    x_object_version_number             IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_waiver_name                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_assignment_status_code            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_waiver_student_id                 IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_waiver_student_id                 IN     NUMBER      DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_waiver_name                       IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_assignment_status_code            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_wav_std_pgms_pkg;

 

/
