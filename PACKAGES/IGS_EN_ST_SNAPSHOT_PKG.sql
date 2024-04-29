--------------------------------------------------------
--  DDL for Package IGS_EN_ST_SNAPSHOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ST_SNAPSHOT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSEI08S.pls 115.3 2002/11/28 23:33:09 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ESS_ID in out NOCOPY NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  x_rowid in VARCHAR2,
  X_ESS_ID in NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2
);
procedure UPDATE_ROW (
  x_rowid in VARCHAR2,
  X_ESS_ID in NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ESS_ID in out NOCOPY NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
 x_rowid in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_ESS_ID IN NUMBER
    ) RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_EN_ST_SPSHT_CTL (
    x_snapshot_dt_time IN DATE
    );


PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ESS_ID IN NUMBER DEFAULT NULL,
    x_govt_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_govt_funding_source IN NUMBER DEFAULT NULL,
    x_major_course IN NUMBER DEFAULT NULL,
    x_commencing_student_ind IN VARCHAR2 DEFAULT NULL,
    x_school_leaver IN NUMBER DEFAULT NULL,
    x_new_to_higher_education IN NUMBER DEFAULT NULL,
    x_sua_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_weftsu IN NUMBER DEFAULT NULL,
    x_unit_int_course_level_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_reportable_ind IN VARCHAR2 DEFAULT NULL,
    x_snapshot_dt_time IN DATE DEFAULT NULL,
    x_ci_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_sua_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sua_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_tr_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_tr_ou_start_dt IN DATE DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_ou_start_dt IN DATE DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_govt_course_type IN NUMBER DEFAULT NULL,
    x_course_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_sca_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_EN_ST_SNAPSHOT_PKG;

 

/