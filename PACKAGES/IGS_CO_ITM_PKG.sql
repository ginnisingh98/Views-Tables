--------------------------------------------------------
--  DDL for Package IGS_CO_ITM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_ITM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSLI07S.pls 115.5 2002/11/29 01:04:01 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_create_dt                         IN     DATE,
    x_s_job_name                        IN     VARCHAR2,
    x_request_job_id                    IN     NUMBER,
    x_output_num                        IN     NUMBER,
    x_request_job_run_id                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_originator_person_id              IN     NUMBER,
    x_request_num                       IN     NUMBER,
    x_job_request_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_create_dt                         IN     DATE,
    x_s_job_name                        IN     VARCHAR2,
    x_request_job_id                    IN     NUMBER,
    x_output_num                        IN     NUMBER,
    x_request_job_run_id                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_originator_person_id              IN     NUMBER,
    x_request_num                       IN     NUMBER,
    x_job_request_id                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_create_dt                         IN     DATE,
    x_s_job_name                        IN     VARCHAR2,
    x_request_job_id                    IN     NUMBER,
    x_output_num                        IN     NUMBER,
    x_request_job_run_id                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_originator_person_id              IN     NUMBER,
    x_request_num                       IN     NUMBER,
    x_job_request_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_id                            IN     NUMBER,
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER,
    x_create_dt                         IN     DATE,
    x_s_job_name                        IN     VARCHAR2,
    x_request_job_id                    IN     NUMBER,
    x_output_num                        IN     NUMBER,
    x_request_job_run_id                IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_cv_version_number                 IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_originator_person_id              IN     NUMBER,
    x_request_num                       IN     NUMBER,
    x_job_request_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_CO_TYPE (
    x_correspondence_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  FUNCTION get_pk_for_validation (
    x_correspondence_type               IN     VARCHAR2,
    x_reference_number                  IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_reference_number                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_correspondence_type               IN     VARCHAR2    DEFAULT NULL,
    x_reference_number                  IN     NUMBER      DEFAULT NULL,
    x_create_dt                         IN     DATE        DEFAULT NULL,
    x_s_job_name                        IN     VARCHAR2    DEFAULT NULL,
    x_request_job_id                    IN     NUMBER      DEFAULT NULL,
    x_output_num                        IN     NUMBER      DEFAULT NULL,
    x_request_job_run_id                IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_cv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_uv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_originator_person_id              IN     NUMBER      DEFAULT NULL,
    x_request_num                       IN     NUMBER      DEFAULT NULL,
    x_job_request_id                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_co_itm_pkg;

 

/
