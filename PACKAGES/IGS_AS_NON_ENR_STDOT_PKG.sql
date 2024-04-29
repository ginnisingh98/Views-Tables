--------------------------------------------------------
--  DDL for Package IGS_AS_NON_ENR_STDOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_NON_ENR_STDOT_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSDI17S.pls 115.4 2002/11/28 23:14:46 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_s_grade_creation_method_type in VARCHAR2,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_GRADE in VARCHAR2,
  X_MARK in NUMBER,
  X_RESOLVED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    )RETURN BOOLEAN;
  PROCEDURE GET_FK_IGS_AS_GRD_SCH_GRADE (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_grade IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    );
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    X_s_grade_creation_method_type IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );
  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    );


	PROCEDURE Check_Constraints (


	Column_Name	IN	VARCHAR2	DEFAULT NULL,


	Column_Value 	IN	VARCHAR2	DEFAULT NULL


	);





 PROCEDURE Before_DML (


    p_action IN VARCHAR2,


    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id in NUMBER DEFAULT NULL,

    x_person_id IN NUMBER DEFAULT NULL,


    x_unit_cd IN VARCHAR2 DEFAULT NULL,


    x_version_number IN NUMBER DEFAULT NULL,


    x_cal_type IN VARCHAR2 DEFAULT NULL,


    x_ci_sequence_number IN NUMBER DEFAULT NULL,


    x_course_cd IN VARCHAR2 DEFAULT NULL,


    x_location_cd IN VARCHAR2 DEFAULT NULL,


    x_unit_mode IN VARCHAR2 DEFAULT NULL,


    x_unit_class IN VARCHAR2 DEFAULT NULL,


    x_s_grade_creation_method_type IN VARCHAR2 DEFAULT NULL,


    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,


    x_gs_version_number IN NUMBER DEFAULT NULL,


    x_grade IN VARCHAR2 DEFAULT NULL,


    x_mark IN NUMBER DEFAULT NULL,


    x_resolved_ind IN VARCHAR2 DEFAULT NULL,


    x_comments IN VARCHAR2 DEFAULT NULL,


    x_creation_date IN DATE DEFAULT NULL,


    x_created_by IN NUMBER DEFAULT NULL,


    x_last_update_date IN DATE DEFAULT NULL,


    x_last_updated_by IN NUMBER DEFAULT NULL,


    x_last_update_login IN NUMBER DEFAULT NULL


  ) ;
end IGS_AS_NON_ENR_STDOT_PKG;

 

/
