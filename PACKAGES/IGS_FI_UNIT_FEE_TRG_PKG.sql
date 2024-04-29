--------------------------------------------------------
--  DDL for Package IGS_FI_UNIT_FEE_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_UNIT_FEE_TRG_PKG" AUTHID CURRENT_USER As
/* $Header: IGSSI64S.pls 120.0 2005/06/01 13:17:46 appldev noship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN;
  FUNCTION Get_UK1_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2,
    x_create_dt IN DATE
  ) RETURN BOOLEAN;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    );
  PROCEDURE GET_FK_IGS_FI_FEE_TRG_GRP (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_trigger_group_number IN NUMBER
    );
  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );
end IGS_FI_UNIT_FEE_TRG_PKG;

 

/
