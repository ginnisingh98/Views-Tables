--------------------------------------------------------
--  DDL for Package IGS_FI_F_CAT_FEE_LBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_F_CAT_FEE_LBL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSSI45S.pls 120.1 2005/07/28 07:04:08 appldev ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R',
  X_WAIVER_CALC_FLAG IN VARCHAR2 DEFAULT 'N'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_WAIVER_CALC_FLAG IN VARCHAR2 DEFAULT 'N'
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_WAIVER_CALC_FLAG IN VARCHAR2 DEFAULT 'N'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_LIABILITY_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ORG_ID in NUMBER default NULL,
  X_MODE in VARCHAR2 default 'R',
  X_WAIVER_CALC_FLAG IN VARCHAR2 DEFAULT 'N'
  );

  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2
    ) RETURN BOOLEAN;
  FUNCTION Get_UK1_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_s_chg_method_type IN VARCHAR2
    ) RETURN BOOLEAN;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  );
  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );
  PROCEDURE GET_FK_IGS_FI_F_CAT_CA_INST (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER
    );
  PROCEDURE GET_FK_IGS_FI_FEE_STR_STAT (
    x_fee_structure_status IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    );
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_chg_method_type IN VARCHAR2
    );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_liability_status IN VARCHAR2 DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_org_id in NUMBER default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_waiver_calc_flag IN VARCHAR2 DEFAULT 'N'
  );
end IGS_FI_F_CAT_FEE_LBL_PKG;

 

/
