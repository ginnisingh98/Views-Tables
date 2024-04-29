--------------------------------------------------------
--  DDL for Package IGS_EN_SU_ATTEMPT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SU_ATTEMPT_H_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI37S.pls 115.9 2003/10/15 04:10:25 ptandon ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DCNT_REASON_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  x_org_id IN NUMBER,
  X_GRADING_SCHEMA_CODE in VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE in VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DCNT_REASON_CD in VARCHAR2,
  X_GRADING_SCHEMA_CODE in VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE in VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DCNT_REASON_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_SCHEMA_CODE in VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE in VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_SUP_UNIT_CD in VARCHAR2,
  X_SUP_VERSION_NUMBER in NUMBER,
  X_ALTERNATIVE_TITLE in VARCHAR2,
  X_OVERRIDE_ENROLLED_CP in NUMBER,
  X_OVERRIDE_EFTSU in NUMBER,
  X_OVERRIDE_ACHIEVABLE_CP in NUMBER,
  X_OVERRIDE_OUTCOME_DUE_DT in DATE,
  X_OVERRIDE_CREDIT_REASON in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_AUS_DESCRIPTION in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_RULE_WAIVED_DT in DATE,
  X_RULE_WAIVED_PERSON_ID in NUMBER,
  X_NO_ASSESSMENT_IND in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_DCNT_REASON_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER,
  X_GRADING_SCHEMA_CODE in VARCHAR2 DEFAULT NULL,
  X_ENR_METHOD_TYPE in VARCHAR2 DEFAULT NULL,
  X_ADMINISTRATIVE_PRIORITY     IN NUMBER DEFAULT NULL,
  X_WAITLIST_DT                 IN DATE DEFAULT NULL,
  X_REQUEST_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_APPLICATION_ID      IN NUMBER DEFAULT NULL,
  X_PROGRAM_ID                  IN NUMBER DEFAULT NULL,
  X_PROGRAM_UPDATE_DATE         IN DATE DEFAULT NULL,
  X_CART                        IN VARCHAR2 DEFAULT NULL,
  X_ORG_UNIT_CD                 IN VARCHAR2 DEFAULT NULL,
  X_RSV_SEAT_EXT_ID             IN NUMBER DEFAULT NULL,
  X_GS_VERSION_NUMBER           IN NUMBER DEFAULT NULL,
  X_FAILED_UNIT_RULE            IN VARCHAR2 DEFAULT NULL,
  X_DEG_AUD_DETAIL_ID           IN NUMBER DEFAULT NULL,
  X_UOO_ID                  IN NUMBER,
  X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_hist_start_dt IN DATE,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    );

    PROCEDURE GET_FK_IGS_EN_SU_ATTEMPT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_uoo_id IN NUMBER
    );

        PROCEDURE Check_Constraints (
        Column_Name     IN      VARCHAR2        DEFAULT NULL,
        Column_Value    IN      VARCHAR2        DEFAULT NULL
        );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_aus_description IN VARCHAR2 DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_rule_waived_dt IN DATE DEFAULT NULL,
    x_rule_waived_person_id IN NUMBER DEFAULT NULL,
    x_no_assessment_ind IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_elo_description IN VARCHAR2 DEFAULT NULL,
    x_sup_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_version_number IN NUMBER DEFAULT NULL,
    x_alternative_title IN VARCHAR2 DEFAULT NULL,
    x_override_enrolled_cp IN NUMBER DEFAULT NULL,
    x_override_eftsu IN NUMBER DEFAULT NULL,
    x_override_achievable_cp IN NUMBER DEFAULT NULL,
    x_override_outcome_due_dt IN DATE DEFAULT NULL,
    x_override_credit_reason IN VARCHAR2 DEFAULT NULL,
    x_dcnt_reason_Cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    X_GRADING_SCHEMA_CODE in VARCHAR2 DEFAULT NULL,
    X_ENR_METHOD_TYPE in VARCHAR2 DEFAULT NULL,
    X_ADMINISTRATIVE_PRIORITY   IN NUMBER DEFAULT NULL,
    X_WAITLIST_DT               IN DATE DEFAULT NULL,
    X_REQUEST_ID                IN NUMBER DEFAULT NULL,
    X_PROGRAM_APPLICATION_ID    IN NUMBER DEFAULT NULL,
    X_PROGRAM_ID                IN NUMBER DEFAULT NULL,
    X_PROGRAM_UPDATE_DATE       IN DATE DEFAULT NULL,
    X_CART                      IN VARCHAR2 DEFAULT NULL,
    X_ORG_UNIT_CD               IN VARCHAR2 DEFAULT NULL,
    X_RSV_SEAT_EXT_ID           IN NUMBER DEFAULT NULL,
    X_GS_VERSION_NUMBER         IN NUMBER DEFAULT NULL,
    X_FAILED_UNIT_RULE          IN VARCHAR2 DEFAULT NULL,
    X_DEG_AUD_DETAIL_ID         IN NUMBER DEFAULT NULL,
    X_UOO_ID                IN NUMBER DEFAULT NULL,
    X_CORE_INDICATOR_CODE IN VARCHAR2 DEFAULT NULL
  ) ;

end IGS_EN_SU_ATTEMPT_H_PKG;

 

/
