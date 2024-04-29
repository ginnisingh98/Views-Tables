--------------------------------------------------------
--  DDL for Package IGS_PS_PAT_OF_STUDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_PAT_OF_STUDY_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI61S.pls 115.4 2002/11/29 02:33:13 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL ,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );
  PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
   );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_admission_cal_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_aprvd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_number_of_periods IN NUMBER DEFAULT NULL,
    x_always_pre_enrol_ind IN VARCHAR2 DEFAULT NULL,
    X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_PS_PAT_OF_STUDY_PKG;

 

/
