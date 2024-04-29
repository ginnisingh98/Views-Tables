--------------------------------------------------------
--  DDL for Package IGS_CO_INTERAC_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_INTERAC_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI28S.pls 120.0 2005/06/01 22:39:22 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_version_id                        IN     NUMBER
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_version_id                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_version_id                        IN     NUMBER
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_version_id                        IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_request_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_student_id                        IN     NUMBER      DEFAULT NULL,
    x_request_id                        IN     NUMBER      DEFAULT NULL,
    x_document_id                       IN     NUMBER      DEFAULT NULL,
    x_document_type                     IN     VARCHAR2    DEFAULT NULL,
    x_sys_ltr_code                      IN     VARCHAR2    DEFAULT NULL,
    x_adm_application_number            IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_requested_date                    IN     DATE        DEFAULT NULL,
    x_delivery_type                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_version_id                        IN     NUMBER      DEFAULT NULL
  );

END igs_co_interac_hist_pkg;

 

/
