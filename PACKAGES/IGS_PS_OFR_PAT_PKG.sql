--------------------------------------------------------
--  DDL for Package IGS_PS_OFR_PAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OFR_PAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI25S.pls 115.3 2002/11/29 02:13:23 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    )
 RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_OFR_INST (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PS_OFR_OPT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    );

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
    x_coo_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );

  FUNCTION Get_UK_For_Validation (
    X_COP_ID IN NUMBER
  )
  RETURN BOOLEAN;

  PROCEDURE CHECK_CONSTRAINTS (
      Column_Name IN VARCHAR2 DEFAULT NULL,
      Column_Value IN VARCHAR2 DEFAULT NULL
  );

   PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_cop_id IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_offered_ind IN VARCHAR2 DEFAULT NULL,
    x_confirmed_offering_ind IN VARCHAR2 DEFAULT NULL,
    x_entry_point_ind IN VARCHAR2 DEFAULT NULL,
    x_pre_enrol_units_ind IN VARCHAR2 DEFAULT NULL,
    x_enrollable_ind IN VARCHAR2 DEFAULT NULL,
    x_ivrs_available_ind IN VARCHAR2 DEFAULT NULL,
    x_min_entry_ass_score IN NUMBER DEFAULT NULL,
    x_guaranteed_entry_ass_scr IN NUMBER DEFAULT NULL,
    x_max_cross_faculty_cp IN NUMBER DEFAULT NULL,
    x_max_cross_location_cp IN NUMBER DEFAULT NULL,
    x_max_cross_mode_cp IN NUMBER DEFAULT NULL,
    x_max_hist_cross_faculty_cp IN NUMBER DEFAULT NULL,
    x_adm_ass_officer_person_id IN NUMBER DEFAULT NULL,
    x_adm_contact_person_id IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_PS_OFR_PAT_PKG;

 

/
