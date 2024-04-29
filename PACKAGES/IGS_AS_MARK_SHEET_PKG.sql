--------------------------------------------------------
--  DDL for Package IGS_AS_MARK_SHEET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_MARK_SHEET_PKG" AUTHID CURRENT_USER as
/* $Header: IGSDI44S.pls 115.6 2002/11/28 23:21:42 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_GRADING_PERIOD_CD in VARCHAR2
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_PERIOD_CD in VARCHAR2
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_PERIOD_CD in VARCHAR2
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_sheet_number IN NUMBER
    ) RETURN BOOLEAN;
  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );
 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_sheet_number IN NUMBER DEFAULT NULL,
    x_group_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_production_dt IN DATE DEFAULT NULL,
    x_duplicate_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_grading_period_cd IN VARCHAR2 DEFAULT NULL
  ) ;

end IGS_AS_MARK_SHEET_PKG;

 

/