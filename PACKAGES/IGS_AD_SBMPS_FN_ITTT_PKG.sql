--------------------------------------------------------
--  DDL for Package IGS_AD_SBMPS_FN_ITTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SBMPS_FN_ITTT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI61S.pls 115.3 2002/11/28 22:11:18 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_PRIORITY_OF_TARGET in NUMBER,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_PRIORITY_OF_TARGET in NUMBER,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_PRIORITY_OF_TARGET in NUMBER,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_PRIORITY_OF_TARGET in NUMBER,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_funding_source IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_intake_target_type IN VARCHAR2
    )
 RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_AD_SBM_PS_FNTRGT (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_funding_source IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

PROCEDURE GET_FK_IGS_AD_INTAK_TRG_TYP(
    x_intake_target_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_override_s_amount_type IN VARCHAR2
  );

-- added to take care of check constraints
PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_priority_of_target IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_intake_target_type IN VARCHAR2 DEFAULT NULL,
    x_target IN NUMBER DEFAULT NULL,
    x_max_target IN NUMBER DEFAULT NULL,
    x_override_s_amount_type IN VARCHAR2 DEFAULT NULL,
    x_actual_enrolment IN NUMBER DEFAULT NULL,
    x_actual_enr_effective_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
);

end IGS_AD_SBMPS_FN_ITTT_PKG;

 

/