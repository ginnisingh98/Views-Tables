--------------------------------------------------------
--  DDL for Package IGS_PS_TCH_RESP_OVRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_TCH_RESP_OVRD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSPI71S.pls 120.1 2005/10/04 00:32:35 appldev ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_PERCENTAGE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_OU_START_DT in DATE,
  X_ORG_UNIT_CD in VARCHAR2,
  X_UOO_ID in NUMBER,
  X_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2,
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE
    ) RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_OPT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2
    );

  PROCEDURE GET_UFK_IGS_PS_UNIT_OFR_OPT (
    x_uoo_id IN NUMBER
    );
PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_TCH_RESP_OVRD_PKG;

 

/
