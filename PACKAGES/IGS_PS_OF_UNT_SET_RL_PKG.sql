--------------------------------------------------------
--  DDL for Package IGS_PS_OF_UNT_SET_RL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OF_UNT_SET_RL_PKG" AUTHID CURRENT_USER as
 /* $Header: IGSPI51S.pls 115.3 2002/11/29 02:30:17 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SUP_US_VERSION_NUMBER in NUMBER,
  X_SUB_UNIT_SET_CD in VARCHAR2,
  X_SUP_UNIT_SET_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SUB_US_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SUP_US_VERSION_NUMBER in NUMBER,
  X_SUB_UNIT_SET_CD in VARCHAR2,
  X_SUP_UNIT_SET_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_SUB_US_VERSION_NUMBER in NUMBER
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_sup_unit_set_cd IN VARCHAR2,
    x_sup_us_version_number IN NUMBER,
    x_sub_unit_set_cd IN VARCHAR2,
    x_sub_us_version_number IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_unit_set_cd IN VARCHAR2,
    x_us_version_number IN NUMBER
    );
 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sup_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sup_us_version_number IN NUMBER DEFAULT NULL,
    x_sub_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_sub_us_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );


 end IGS_PS_OF_UNT_SET_RL_PKG;

 

/
