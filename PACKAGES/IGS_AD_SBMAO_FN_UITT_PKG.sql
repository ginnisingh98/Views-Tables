--------------------------------------------------------
--  DDL for Package IGS_AD_SBMAO_FN_UITT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SBMAO_FN_UITT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI62S.pls 115.4 2003/09/01 05:59:41 akadam ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
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
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_funding_source IN VARCHAR2,
    x_unit_int_course_level_cd IN VARCHAR2,
    x_intake_target_type IN VARCHAR2
    )
RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2
    );

PROCEDURE GET_FK_IGS_ST_GVT_SPSHT_CTL (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER
    );

PROCEDURE GET_FK_IGS_AD_INTAK_TRG_TYP(
    x_intake_target_type IN VARCHAR2
    );

PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    );

PROCEDURE GET_FK_IGS_PS_UNIT_INT_LVL (
    x_unit_int_course_level_cd IN VARCHAR2
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
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_unit_int_course_level_cd IN VARCHAR2 DEFAULT NULL,
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

end IGS_AD_SBMAO_FN_UITT_PKG;

 

/