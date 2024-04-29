--------------------------------------------------------
--  DDL for Package IGS_AS_SC_ATTEMPT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SC_ATTEMPT_H_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI19S.pls 115.9 2003/12/04 13:05:25 rvangala ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_COURSE_ATTEMPT_STATUS in VARCHAR2,
  X_PROGRESSION_STATUS in VARCHAR2,
  X_DERIVED_ATT_TYPE in VARCHAR2,
  X_DERIVED_ATT_MODE in VARCHAR2,
  X_PROVISIONAL_IND in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_LAPSED_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_FS_DESCRIPTION in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_DERIVED_COMPLETION_YR in NUMBER,
  X_DERIVED_COMPLETION_PERD in VARCHAR2,
  X_NOMINATED_COMPLETION_YR in NUMBER,
  X_NOMINATED_COMPLETION_PERD in VARCHAR2,
  X_RULE_CHECK_IND in VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND in VARCHAR2,
  X_LAST_RULE_CHECK_DT in DATE,
  X_PUBLISH_OUTCOMES_IND in VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND in VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION in NUMBER,
  X_ADVANCED_STANDING_IND in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FC_DESCRIPTION in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_CC_DESCRIPTION in VARCHAR2,
  X_SELF_HELP_GROUP_IND in VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER in NUMBER,
  X_ADM_NOMINATED_COURSE_CD in VARCHAR2,
  X_ADM_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_LAST_DATE_OF_ATTENDANCE in DATE DEFAULT NULL,
  X_DROPPED_BY in VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE  IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM  IN VARCHAR2  DEFAULT 'N',
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_COURSE_ATTEMPT_STATUS in VARCHAR2,
  X_PROGRESSION_STATUS in VARCHAR2,
  X_DERIVED_ATT_TYPE in VARCHAR2,
  X_DERIVED_ATT_MODE in VARCHAR2,
  X_PROVISIONAL_IND in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_LAPSED_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_FS_DESCRIPTION in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_DERIVED_COMPLETION_YR in NUMBER,
  X_DERIVED_COMPLETION_PERD in VARCHAR2,
  X_NOMINATED_COMPLETION_YR in NUMBER,
  X_NOMINATED_COMPLETION_PERD in VARCHAR2,
  X_RULE_CHECK_IND in VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND in VARCHAR2,
  X_LAST_RULE_CHECK_DT in DATE,
  X_PUBLISH_OUTCOMES_IND in VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND in VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION in NUMBER,
  X_ADVANCED_STANDING_IND in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FC_DESCRIPTION in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_CC_DESCRIPTION in VARCHAR2,
  X_SELF_HELP_GROUP_IND in VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER in NUMBER,
  X_ADM_NOMINATED_COURSE_CD in VARCHAR2,
  X_ADM_SEQUENCE_NUMBER in NUMBER,
  X_LAST_DATE_OF_ATTENDANCE in DATE DEFAULT NULL,
  X_DROPPED_BY in VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROGRAM_TYPE  IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE  IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE  IN VARCHAR2 DEFAULT  NULL,
  X_CATALOG_SEQ_NUM  IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM  IN VARCHAR2 DEFAULT 'N' ,
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_COURSE_ATTEMPT_STATUS in VARCHAR2,
  X_PROGRESSION_STATUS in VARCHAR2,
  X_DERIVED_ATT_TYPE in VARCHAR2,
  X_DERIVED_ATT_MODE in VARCHAR2,
  X_PROVISIONAL_IND in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_LAPSED_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_FS_DESCRIPTION in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_DERIVED_COMPLETION_YR in NUMBER,
  X_DERIVED_COMPLETION_PERD in VARCHAR2,
  X_NOMINATED_COMPLETION_YR in NUMBER,
  X_NOMINATED_COMPLETION_PERD in VARCHAR2,
  X_RULE_CHECK_IND in VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND in VARCHAR2,
  X_LAST_RULE_CHECK_DT in DATE,
  X_PUBLISH_OUTCOMES_IND in VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND in VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION in NUMBER,
  X_ADVANCED_STANDING_IND in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FC_DESCRIPTION in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_CC_DESCRIPTION in VARCHAR2,
  X_SELF_HELP_GROUP_IND in VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER in NUMBER,
  X_ADM_NOMINATED_COURSE_CD in VARCHAR2,
  X_ADM_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_LAST_DATE_OF_ATTENDANCE in DATE DEFAULT NULL,
  X_DROPPED_BY in VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROGRAM_TYPE  IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE  IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE  IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM  IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM   IN VARCHAR2 DEFAULT 'N',
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_STUDENT_CONFIRMED_IND in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_COURSE_ATTEMPT_STATUS in VARCHAR2,
  X_PROGRESSION_STATUS in VARCHAR2,
  X_DERIVED_ATT_TYPE in VARCHAR2,
  X_DERIVED_ATT_MODE in VARCHAR2,
  X_PROVISIONAL_IND in VARCHAR2,
  X_DISCONTINUED_DT in DATE,
  X_DISCONTINUATION_REASON_CD in VARCHAR2,
  X_LAPSED_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_FS_DESCRIPTION in VARCHAR2,
  X_EXAM_LOCATION_CD in VARCHAR2,
  X_ELO_DESCRIPTION in VARCHAR2,
  X_DERIVED_COMPLETION_YR in NUMBER,
  X_DERIVED_COMPLETION_PERD in VARCHAR2,
  X_NOMINATED_COMPLETION_YR in NUMBER,
  X_NOMINATED_COMPLETION_PERD in VARCHAR2,
  X_RULE_CHECK_IND in VARCHAR2,
  X_WAIVE_OPTION_CHECK_IND in VARCHAR2,
  X_LAST_RULE_CHECK_DT in DATE,
  X_PUBLISH_OUTCOMES_IND in VARCHAR2,
  X_COURSE_RQRMNT_COMPLETE_IND in VARCHAR2,
  X_COURSE_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_OVERRIDE_TIME_LIMITATION in NUMBER,
  X_ADVANCED_STANDING_IND in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FC_DESCRIPTION in VARCHAR2,
  X_CORRESPONDENCE_CAT in VARCHAR2,
  X_CC_DESCRIPTION in VARCHAR2,
  X_SELF_HELP_GROUP_IND in VARCHAR2,
  X_ADM_ADMISSION_APPL_NUMBER in NUMBER,
  X_ADM_NOMINATED_COURSE_CD in VARCHAR2,
  X_ADM_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_LAST_DATE_OF_ATTENDANCE in DATE DEFAULT NULL,
  X_DROPPED_BY in VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROGRAM_TYPE  IN VARCHAR2 DEFAULT NULL,
  X_PRIMARY_PROG_TYPE_SOURCE  IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_CAL_TYPE  IN VARCHAR2 DEFAULT NULL,
  X_CATALOG_SEQ_NUM IN NUMBER DEFAULT NULL,
  X_KEY_PROGRAM  IN VARCHAR2 DEFAULT 'N' ,
  X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
  X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
  X_COO_ID IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN;

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id in NUMBER DEFAULT NULL,
    x_progression_status IN VARCHAR2 DEFAULT NULL,
    x_derived_att_type IN VARCHAR2 DEFAULT NULL,
    x_derived_att_mode IN VARCHAR2 DEFAULT NULL,
    x_provisional_ind IN VARCHAR2 DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_discontinuation_reason_cd IN VARCHAR2 DEFAULT NULL,
    x_lapsed_dt IN DATE DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_fs_description IN VARCHAR2 DEFAULT NULL,
    x_exam_location_cd IN VARCHAR2 DEFAULT NULL,
    x_elo_description IN VARCHAR2 DEFAULT NULL,
    x_derived_completion_yr IN NUMBER DEFAULT NULL,
    x_derived_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_nominated_completion_yr IN NUMBER DEFAULT NULL,
    x_nominated_completion_perd IN VARCHAR2 DEFAULT NULL,
    x_rule_check_ind IN VARCHAR2 DEFAULT NULL,
    x_waive_option_check_ind IN VARCHAR2 DEFAULT NULL,
    x_last_rule_check_dt IN DATE DEFAULT NULL,
    x_publish_outcomes_ind IN VARCHAR2 DEFAULT NULL,
    x_course_rqrmnt_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_course_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    x_override_time_limitation IN NUMBER DEFAULT NULL,
    x_advanced_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fc_description IN VARCHAR2 DEFAULT NULL,
    x_correspondence_cat IN VARCHAR2 DEFAULT NULL,
    x_cc_description IN VARCHAR2 DEFAULT NULL,
    x_self_help_group_ind IN VARCHAR2 DEFAULT NULL,
    x_adm_admission_appl_number IN NUMBER DEFAULT NULL,
    x_adm_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_adm_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_student_confirmed_ind IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
    x_course_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_LAST_DATE_OF_ATTENDANCE in DATE DEFAULT NULL,
    X_DROPPED_BY in VARCHAR2 DEFAULT NULL,
    X_PRIMARY_PROGRAM_TYPE  IN VARCHAR2 DEFAULT NULL,
    X_PRIMARY_PROG_TYPE_SOURCE  IN VARCHAR2 DEFAULT NULL,
    X_CATALOG_CAL_TYPE  IN VARCHAR2 DEFAULT NULL,
    X_CATALOG_SEQ_NUM  IN NUMBER DEFAULT NULL,
    X_KEY_PROGRAM  IN VARCHAR2 DEFAULT 'N' ,
    X_OVERRIDE_CMPL_DT  IN DATE DEFAULT NULL,
    X_MANUAL_OVR_CMPL_DT_IND  IN VARCHAR2 DEFAULT 'N',
    X_COO_ID IN NUMBER DEFAULT NULL,
    X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  );


end IGS_AS_SC_ATTEMPT_H_PKG;

 

/
