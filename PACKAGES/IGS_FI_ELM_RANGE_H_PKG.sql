--------------------------------------------------------
--  DDL for Package IGS_FI_ELM_RANGE_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ELM_RANGE_H_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI15S.pls 115.7 2003/02/12 10:02:14 shtatiko ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_RANGE_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
 X_ROWID in VARCHAR2
);
Function GET_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_range_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
return Boolean;
Procedure Check_Constraints (
	Column_name 	IN	VARCHAR2 DEFAULT NULL,
	COLUMN_VALUE	IN	VARCHAR2 DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_lower_range IN NUMBER DEFAULT NULL,
    x_upper_range IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

Function GET_UK_FOR_VALIDATION (
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL
)Return Boolean;

end IGS_FI_ELM_RANGE_H_PKG;

 

/
