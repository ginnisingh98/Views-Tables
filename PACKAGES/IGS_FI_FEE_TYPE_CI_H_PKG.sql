--------------------------------------------------------
--  DDL for Package IGS_FI_FEE_TYPE_CI_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FEE_TYPE_CI_H_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI38S.pls 120.1 2005/07/11 04:35:48 appldev ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_INITIAL_DEFAULT_AMOUNT   in NUMBER DEFAULT NULL,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_NONZERO_BILLABLE_CP_FLAG IN VARCHAR2 DEFAULT NULL,
  X_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
  X_elm_rng_order_name IN VARCHAR2 DEFAULT NULL
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_INITIAL_DEFAULT_AMOUNT  in NUMBER DEFAULT NULL,
  X_NONZERO_BILLABLE_CP_FLAG IN VARCHAR2 DEFAULT NULL,
  X_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
  X_elm_rng_order_name IN VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_INITIAL_DEFAULT_AMOUNT in NUMBER DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R',
  X_NONZERO_BILLABLE_CP_FLAG IN VARCHAR2 DEFAULT NULL,
  X_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
  X_elm_rng_order_name IN VARCHAR2 DEFAULT NULL
);
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_TYPE_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_INITIAL_DEFAULT_AMOUNT in NUMBER DEFAULT NULL,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_NONZERO_BILLABLE_CP_FLAG IN VARCHAR2 DEFAULT NULL,
  X_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
  X_elm_rng_order_name IN VARCHAR2 DEFAULT NULL
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_hist_start_dt IN DATE
    )RETURN BOOLEAN;
 PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_type_ci_status IN VARCHAR2 DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_retro_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_retro_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_initial_default_amount  IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_nonzero_billable_cp_flag IN VARCHAR2 DEFAULT NULL,
    x_scope_rul_sequence_num IN NUMBER DEFAULT NULL,
    x_elm_rng_order_name IN VARCHAR2 DEFAULT NULL
  ) ;
end IGS_FI_FEE_TYPE_CI_H_PKG;

 

/
