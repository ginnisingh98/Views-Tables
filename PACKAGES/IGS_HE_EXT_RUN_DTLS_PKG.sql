--------------------------------------------------------
--  DDL for Package IGS_HE_EXT_RUN_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXT_RUN_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI06S.pls 115.5 2002/11/29 04:36:08 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_extract_run_id                    IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_extract_run_id                    IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_extract_run_id                    IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_extract_run_id                    IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_extract_phase                     IN     VARCHAR2,
    x_conc_request_id                   IN     NUMBER,
    x_conc_request_status               IN     VARCHAR2,
    x_extract_run_date                  IN     DATE,
    x_file_name                         IN     VARCHAR2,
    x_file_location                     IN     VARCHAR2,
    x_date_file_sent                    IN     DATE,
    x_extract_override                  IN     VARCHAR2,
    x_validation_kit_result             IN     VARCHAR2,
    x_hesa_validation_result            IN     VARCHAR2,
    x_student_ext_run_id                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_extract_run_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_submsn_return (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_extract_run_id                    IN     NUMBER      DEFAULT NULL,
    x_submission_name                   IN     VARCHAR2    DEFAULT NULL,
    x_user_return_subclass              IN     VARCHAR2    DEFAULT NULL,
    x_return_name                       IN     VARCHAR2    DEFAULT NULL,
    x_extract_phase                     IN     VARCHAR2    DEFAULT NULL,
    x_conc_request_id                   IN     NUMBER      DEFAULT NULL,
    x_conc_request_status               IN     VARCHAR2    DEFAULT NULL,
    x_extract_run_date                  IN     DATE        DEFAULT NULL,
    x_file_name                         IN     VARCHAR2    DEFAULT NULL,
    x_file_location                     IN     VARCHAR2    DEFAULT NULL,
    x_date_file_sent                    IN     DATE        DEFAULT NULL,
    x_extract_override                  IN     VARCHAR2    DEFAULT NULL,
    x_validation_kit_result             IN     VARCHAR2    DEFAULT NULL,
    x_hesa_validation_result            IN     VARCHAR2    DEFAULT NULL,
    x_student_ext_run_id                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ext_run_dtls_pkg;

 

/
