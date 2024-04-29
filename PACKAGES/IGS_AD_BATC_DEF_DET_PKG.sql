--------------------------------------------------------
--  DDL for Package IGS_AD_BATC_DEF_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_BATC_DEF_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIE8S.pls 115.3 2002/11/28 22:33:55 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN OUT NOCOPY NUMBER,
    x_description                       IN     VARCHAR2,
    x_acad_cal_type                     IN     VARCHAR2,
    x_acad_ci_sequence_number           IN     NUMBER,
    x_adm_cal_type                      IN     VARCHAR2,
    x_adm_ci_sequence_number            IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_decision_make_id                  IN     NUMBER,
    x_decision_date                     IN     DATE,
    x_decision_reason_id                IN     NUMBER,
    x_pending_reason_id                 IN     NUMBER,
    x_offer_dt                          IN     DATE,
    x_offer_response_dt                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION Get_PK_For_Validation (
    x_batch_id IN NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_acad_cal_type                     IN     VARCHAR2    DEFAULT NULL,
    x_acad_ci_sequence_number           IN     NUMBER      DEFAULT NULL,
    x_adm_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_adm_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_s_admission_process_type          IN     VARCHAR2    DEFAULT NULL,
    x_decision_make_id                  IN     NUMBER      DEFAULT NULL,
    x_decision_date                     IN     DATE        DEFAULT NULL,
    x_decision_reason_id                IN     NUMBER      DEFAULT NULL,
    x_pending_reason_id                 IN     NUMBER      DEFAULT NULL,
    x_offer_dt                          IN     DATE        DEFAULT NULL,
    x_offer_response_dt                 IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_batc_def_det_pkg;

 

/
