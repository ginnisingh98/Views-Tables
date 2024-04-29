--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_OFR_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_OFR_OPT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI85S.pls 120.1 2005/06/28 03:37:46 appldev ship $ */

FUNCTION  check_call_number (p_teach_cal_type IN igs_ca_teach_to_load_v.teach_cal_type%TYPE,
                             p_teach_sequence_num IN igs_ca_teach_to_load_v.teach_ci_sequence_number%TYPE,
                             p_call_number  IN igs_ps_unit_ofr_opt_pe_v.call_number%TYPE,
                             p_rowid   IN VARCHAR2) RETURN BOOLEAN;

procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN OUT NOCOPY NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 DEFAULT NULL,
       x_attendance_required_ind           IN     VARCHAR2 DEFAULT NULL,
       x_reserved_seating_allowed          IN     VARCHAR2 DEFAULT NULL,
       x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
       x_ss_display_ind                    IN     VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID IN NUMBER ,
       X_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
       X_DIR_ENROLLMENT  IN NUMBER DEFAULT NULL,
       X_ENR_FROM_WLST  IN NUMBER DEFAULT NULL,
       X_INQ_NOT_WLST IN NUMBER DEFAULT NULL,
       x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
       x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
       x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
       X_NON_STD_USEC_IND IN VARCHAR2 DEFAULT 'N',
       x_auditable_ind IN VARCHAR2 DEFAULT 'N',
       x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
       x_not_multiple_section_flag IN VARCHAR2 DEFAULT 'N',
       x_sup_uoo_id IN NUMBER DEFAULT NULL,
       x_relation_type VARCHAR2 DEFAULT NULL,
       x_default_enroll_flag VARCHAR2 DEFAULT 'N',
       x_abort_flag VARCHAR2 DEFAULT 'N'
  );

procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 DEFAULT NULL,
       x_attendance_required_ind           IN     VARCHAR2 DEFAULT NULL,
       x_reserved_seating_allowed          IN     VARCHAR2 DEFAULT NULL,
       x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
       x_ss_display_ind                    IN     VARCHAR2 DEFAULT NULL,
       x_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
       X_DIR_ENROLLMENT  IN NUMBER DEFAULT NULL,
       X_ENR_FROM_WLST  IN NUMBER DEFAULT NULL,
       X_INQ_NOT_WLST IN NUMBER DEFAULT NULL,
       x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
       x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
       x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
       X_NON_STD_USEC_IND IN VARCHAR2 DEFAULT 'N',
       x_auditable_ind IN VARCHAR2 DEFAULT 'N',
       x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
       x_not_multiple_section_flag IN VARCHAR2 DEFAULT 'N',
       x_sup_uoo_id IN NUMBER DEFAULT NULL,
       x_relation_type VARCHAR2 DEFAULT NULL,
       x_default_enroll_flag VARCHAR2 DEFAULT 'N',
       x_abort_flag VARCHAR2 DEFAULT 'N'
);

procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 DEFAULT NULL,
       x_attendance_required_ind           IN     VARCHAR2 DEFAULT NULL,
       x_reserved_seating_allowed          IN     VARCHAR2 DEFAULT NULL,
       x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
       x_ss_display_ind                    IN     VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R',
       x_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
       X_DIR_ENROLLMENT  IN NUMBER DEFAULT NULL,
       X_ENR_FROM_WLST  IN NUMBER DEFAULT NULL,
       X_INQ_NOT_WLST IN NUMBER DEFAULT NULL,
       x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
       x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
       x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
       X_NON_STD_USEC_IND IN VARCHAR2 DEFAULT 'N',
       x_auditable_ind IN VARCHAR2 DEFAULT 'N',
       x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
       x_not_multiple_section_flag IN VARCHAR2 DEFAULT 'N',
       x_sup_uoo_id IN NUMBER DEFAULT NULL,
       x_relation_type VARCHAR2 DEFAULT NULL,
       x_default_enroll_flag VARCHAR2 DEFAULT 'N',
       x_abort_flag VARCHAR2 DEFAULT 'N'
  );

procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_LOCATION_CD IN VARCHAR2,
       x_UNIT_CLASS IN VARCHAR2,
       x_UOO_ID IN NUMBER,
       x_IVRS_AVAILABLE_IND IN VARCHAR2,
       x_CALL_NUMBER IN OUT NOCOPY NUMBER,
       x_UNIT_SECTION_STATUS IN VARCHAR2,
       x_UNIT_SECTION_START_DATE IN DATE,
       x_UNIT_SECTION_END_DATE IN DATE,
       x_ENROLLMENT_ACTUAL IN NUMBER,
       x_WAITLIST_ACTUAL IN NUMBER,
       x_OFFERED_IND IN VARCHAR2,
       x_STATE_FINANCIAL_AID IN VARCHAR2,
       x_GRADING_SCHEMA_PRCDNCE_IND IN VARCHAR2,
       x_FEDERAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_QUOTA IN NUMBER,
       x_UNIT_QUOTA_RESERVED_PLACES IN NUMBER,
       x_INSTITUTIONAL_FINANCIAL_AID IN VARCHAR2,
       x_UNIT_CONTACT IN NUMBER,
       x_GRADING_SCHEMA_CD IN VARCHAR2,
       x_GS_VERSION_NUMBER IN NUMBER,
       x_owner_org_unit_cd                 IN     VARCHAR2 DEFAULT NULL,
       x_attendance_required_ind           IN     VARCHAR2 DEFAULT NULL,
       x_reserved_seating_allowed          IN     VARCHAR2 DEFAULT NULL,
       x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
       x_ss_display_ind                    IN     VARCHAR2 DEFAULT NULL,
       X_MODE in VARCHAR2 default 'R' ,
       X_ORG_ID IN NUMBER ,
       x_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
       X_DIR_ENROLLMENT  IN NUMBER DEFAULT NULL,
       X_ENR_FROM_WLST  IN NUMBER DEFAULT NULL,
       X_INQ_NOT_WLST IN NUMBER DEFAULT NULL,
       x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
       x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
       x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
       X_NON_STD_USEC_IND IN VARCHAR2 DEFAULT 'N',
       x_auditable_ind IN VARCHAR2 DEFAULT 'N',
       x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
       x_not_multiple_section_flag IN VARCHAR2 DEFAULT 'N',
       x_sup_uoo_id IN NUMBER DEFAULT NULL,
       x_relation_type VARCHAR2 DEFAULT NULL,
       x_default_enroll_flag VARCHAR2 DEFAULT 'N',
       x_abort_flag VARCHAR2 DEFAULT 'N'
  );

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  );
  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );

  FUNCTION Get_UK_For_Validation (
    x_uoo_id IN NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_ivrs_available_ind IN VARCHAR2 DEFAULT NULL,
    x_call_number IN NUMBER DEFAULT NULL,
    x_unit_section_status IN VARCHAR2 DEFAULT NULL,
    x_unit_section_start_date IN DATE DEFAULT NULL,
    x_unit_section_end_date IN DATE DEFAULT NULL,
    x_enrollment_actual IN NUMBER DEFAULT NULL,
    x_waitlist_actual IN NUMBER DEFAULT NULL,
    x_offered_ind IN VARCHAR2 DEFAULT NULL,
    x_state_financial_aid IN VARCHAR2 DEFAULT NULL,
    x_grading_schema_prcdnce_ind IN VARCHAR2 DEFAULT NULL,
    x_federal_financial_aid IN VARCHAR2 DEFAULT NULL,
    x_unit_quota IN NUMBER DEFAULT NULL,
    x_unit_quota_reserved_places IN NUMBER DEFAULT NULL,
    x_institutional_financial_aid IN VARCHAR2 DEFAULT NULL,
    x_unit_contact IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_owner_org_unit_cd                 IN     VARCHAR2 DEFAULT NULL,
    x_attendance_required_ind           IN     VARCHAR2 DEFAULT NULL,
    x_reserved_seating_allowed          IN     VARCHAR2 DEFAULT NULL,
    x_special_permission_ind            IN     VARCHAR2 DEFAULT NULL,
    x_ss_display_ind                    IN     VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID IN NUMBER DEFAULT NULL ,
    X_SS_ENROL_IND IN VARCHAR2 DEFAULT 'N',
    X_DIR_ENROLLMENT  IN NUMBER DEFAULT NULL,
    X_ENR_FROM_WLST  IN NUMBER DEFAULT NULL,
    X_INQ_NOT_WLST IN NUMBER DEFAULT NULL,
    x_rev_account_cd IN VARCHAR2 DEFAULT NULL,
    x_anon_unit_grading_ind IN VARCHAR2 DEFAULT NULL,
    x_anon_assess_grading_ind IN VARCHAR2 DEFAULT NULL,
    X_NON_STD_USEC_IND IN VARCHAR2 DEFAULT 'N',
    x_auditable_ind IN VARCHAR2 DEFAULT 'N',
    x_audit_permission_ind IN VARCHAR2 DEFAULT 'N',
    x_not_multiple_section_flag IN VARCHAR2 DEFAULT 'N',
    x_sup_uoo_id IN NUMBER DEFAULT NULL,
    x_relation_type VARCHAR2 DEFAULT NULL,
    x_default_enroll_flag VARCHAR2 DEFAULT 'N',
    x_abort_flag VARCHAR2 DEFAULT 'N'
  );

FUNCTION get_call_number ( p_c_cal_type IN igs_ca_type.cal_type%TYPE,
                           p_n_seq_num IN igs_ca_inst_all.sequence_number%TYPE ) RETURN NUMBER;

PROCEDURE check_status_transition( p_n_uoo_id IN NUMBER,
                                     p_c_old_usec_sts IN VARCHAR2,
                                     p_c_new_usec_sts IN VARCHAR2);

end IGS_PS_UNIT_OFR_OPT_PKG;

 

/
