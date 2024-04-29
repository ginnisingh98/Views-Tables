--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI04S.pls 120.2 2005/08/08 04:29:05 appldev ship $ */


PROCEDURE insert_row (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER DEFAULT NULL,
  x_spcl_grp_2 IN NUMBER DEFAULT NULL,
  x_common_app IN VARCHAR2 DEFAULT NULL,
  x_application_type IN VARCHAR2 DEFAULT NULL,
  X_MODE             IN VARCHAR2 DEFAULT 'R' ,
  x_choice_number    IN VARCHAR2 DEFAULT NULL,
  x_routeb_pref      IN VARCHAR2 DEFAULT NULL,
  x_alt_appl_id      IN VARCHAR2 DEFAULT NULL,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
  );


PROCEDURE lock_row (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER DEFAULT NULL,
  x_spcl_grp_2 IN NUMBER DEFAULT NULL,
  x_common_app IN VARCHAR2 DEFAULT NULL,
  x_application_type IN VARCHAR2 DEFAULT NULL,
  x_choice_number    IN VARCHAR2 DEFAULT NULL,
  x_routeb_pref      IN VARCHAR2 DEFAULT NULL,
  x_alt_appl_id      IN VARCHAR2 DEFAULT NULL,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
);


PROCEDURE update_row (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER DEFAULT NULL,
  x_spcl_grp_2 IN NUMBER DEFAULT NULL,
  x_common_app IN VARCHAR2 DEFAULT NULL,
  x_application_type IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  x_choice_number    IN VARCHAR2 DEFAULT NULL,
  x_routeb_pref      IN VARCHAR2 DEFAULT NULL,
  x_alt_appl_id      IN VARCHAR2 DEFAULT NULL,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
  );


PROCEDURE add_row (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  x_spcl_grp_1 IN NUMBER DEFAULT NULL,
  x_spcl_grp_2 IN NUMBER DEFAULT NULL,
  x_common_app IN VARCHAR2 DEFAULT NULL,
  x_application_type IN VARCHAR2 DEFAULT NULL,
  X_MODE IN VARCHAR2 DEFAULT 'R',
  x_choice_number    IN VARCHAR2 DEFAULT NULL,
  x_routeb_pref      IN VARCHAR2 DEFAULT NULL,
  x_alt_appl_id      IN VARCHAR2 DEFAULT NULL,
  x_appl_fee_amt     IN NUMBER   DEFAULT NULL
  );


PROCEDURE delete_row (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
);

FUNCTION get_pk_for_validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    )
RETURN BOOLEAN;

PROCEDURE get_fk_igs_ad_ss_appl_typ(
   x_application_type IN VARCHAR2
    );

  PROCEDURE get_fk_igs_ca_inst_rel (
    x_sub_cal_type IN VARCHAR2,
    x_sub_ci_sequence_number IN NUMBER,
    x_sup_cal_type IN VARCHAR2,
    x_sup_ci_sequence_number IN NUMBER
    );

  PROCEDURE get_fk_igs_pe_person (
    x_person_id IN NUMBER
    );

  PROCEDURE get_fk_igs_ad_appl_stat (
    x_adm_appl_status IN VARCHAR2
    );

  PROCEDURE get_fk_igs_ad_fee_stat (
    x_adm_fee_status IN VARCHAR2
    );

  PROCEDURE get_fk_igs_ad_prd_ad_prc_ca (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    );

  PROCEDURE get_fk_igs_ad_prcs_cat (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    );

  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id IN NUMBER
    );

-- added to take care of check constraints
PROCEDURE check_constraints(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);
PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id in NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_appl_dt IN DATE DEFAULT NULL,
    x_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_status IN VARCHAR2 DEFAULT NULL,
    x_adm_fee_status IN VARCHAR2 DEFAULT NULL,
    x_tac_appl_ind IN VARCHAR2 DEFAULT NULL,
    x_spcl_grp_1 IN NUMBER DEFAULT NULL,
    x_spcl_grp_2 IN NUMBER DEFAULT NULL,
    x_common_app IN VARCHAR2 DEFAULT NULL,
    x_application_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_choice_number    IN VARCHAR2 DEFAULT NULL,
    x_routeb_pref      IN VARCHAR2 DEFAULT NULL,
    x_alt_appl_id      IN VARCHAR2 DEFAULT NULL,
    x_appl_fee_amt     IN NUMBER   DEFAULT NULL
  );


end igs_ad_appl_pkg;

 

/
