--------------------------------------------------------
--  DDL for Package IGS_AD_ADMDE_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ADMDE_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIE9S.pls 115.8 2003/12/15 11:55:30 rboddu noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_interface_mkdes_id                IN OUT NOCOPY NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_reconsider_flag                   IN     VARCHAR2    DEFAULT 'N',
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_interface_mkdes_id                IN     NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_reconsider_flag                   IN     VARCHAR2     DEFAULT 'N',
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_interface_mkdes_id                IN     NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_reconsider_flag                   IN     VARCHAR2    DEFAULT 'N',
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_interface_mkdes_id                IN OUT NOCOPY NUMBER,
    x_interface_run_id                  IN     NUMBER,
    x_batch_id                          IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_adm_outcome_status                IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_status                            IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_reconsider_flag                   IN     VARCHAR2    DEFAULT 'N',
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  );

  FUNCTION Get_PK_For_Validation (
    x_interface_mkdes_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_interface_mkdes_id                IN     NUMBER      DEFAULT NULL,
    x_interface_run_id                  IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_nominated_course_cd               IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_adm_outcome_status                IN     VARCHAR2    DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_pending_reason_id                 IN     NUMBER      DEFAULT NULL,
    x_offer_dt                          IN     DATE        DEFAULT NULL,
    x_offer_response_dt                 IN     DATE        DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_error_code                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reconsider_flag                   IN     VARCHAR2    DEFAULT 'N',
    x_prpsd_commencement_date             IN     DATE DEFAULT NULL,
    x_error_text                        IN     VARCHAR2 DEFAULT NULL
  );

END igs_ad_admde_int_pkg;

 

/
