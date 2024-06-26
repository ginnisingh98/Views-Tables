--------------------------------------------------------
--  DDL for Package IGS_AS_UNTAS_PATTERN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_UNTAS_PATTERN_PKG" AUTHID CURRENT_USER as
/* $Header: IGSDI33S.pls 120.0 2005/07/05 11:50:18 appldev noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE,
  X_MODE in VARCHAR2 default 'R' ,
  X_ORG_ID IN NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_ASS_PATTERN_ID in NUMBER,
  X_ASS_PATTERN_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_DFLT_PATTERN_IND in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_ACTION_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_ass_pattern_id IN NUMBER
    ) RETURN BOOLEAN;

  FUNCTION Get_UK_For_Validation (
    x_ass_pattern_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AS_UNIT_CLASS (
    x_unit_class IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AS_UNIT_MODE (
    x_unit_mode IN VARCHAR2
    );

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
    x_rowid IN VARCHAR2 DEFAULT NULL ,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_ass_pattern_id IN NUMBER DEFAULT NULL,
    x_ass_pattern_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_dflt_pattern_ind IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_action_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL ,
    x_created_by IN NUMBER DEFAULT NULL ,
    x_last_update_date IN DATE DEFAULT NULL ,
    x_last_updated_by IN NUMBER DEFAULT NULL ,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) ;

end IGS_AS_UNTAS_PATTERN_PKG;

 

/
