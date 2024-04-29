--------------------------------------------------------
--  DDL for Package IGS_AS_INS_GRD_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_INS_GRD_ENTRY_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI22S.pls 115.3 2002/11/28 23:16:22 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_KEYING_WHO in VARCHAR2,
  X_KEYING_TIME in DATE,
  X_STUDENT_SEQUENCE in NUMBER,
  X_PERSON_ID in NUMBER,
  X_NAME in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_ATTEMPT_STATUS in VARCHAR2,
  X_MARK in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_SPECIFIED_GRADE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );

FUNCTION Get_PK_For_Validation (
    x_keying_who IN VARCHAR2,
    x_keying_time IN DATE,
    x_student_sequence IN NUMBER
    )RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    );
	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);
PROCEDURE Before_DML (  p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_keying_who IN VARCHAR2 DEFAULT NULL,
    x_keying_time IN DATE DEFAULT NULL,
    x_student_sequence IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_name IN VARCHAR2 DEFAULT NULL,
	x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
	x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
	x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_attempt_status IN VARCHAR2 DEFAULT NULL,
    x_mark IN NUMBER DEFAULT NULL,
	x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_grade IN VARCHAR2 DEFAULT NULL,
	x_specified_grade_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
	x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_AS_INS_GRD_ENTRY_PKG;

 

/