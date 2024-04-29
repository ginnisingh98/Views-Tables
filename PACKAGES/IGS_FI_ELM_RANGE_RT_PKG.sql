--------------------------------------------------------
--  DDL for Package IGS_FI_ELM_RANGE_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ELM_RANGE_RT_PKG" AUTHID CURRENT_USER as
/* $Header: IGSSI67S.pls 115.3 2002/11/29 03:52:19 nsidana ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ERR_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ERR_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ERR_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ERR_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_err_id IN NUMBER
  ) RETURN BOOLEAN;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  );
  FUNCTION Get_UK1_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN VARCHAR2,
    x_range_number IN VARCHAR2,
    x_rate_number IN VARCHAR2,
    x_create_dt IN VARCHAR2,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN;
  FUNCTION Get_UK2_For_Validation (
    x_err_id IN NUMBER
  ) RETURN BOOLEAN;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_ERR_ID IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_rate_number IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
  PROCEDURE GET_UFK_IGS_FI_ELM_RANGE (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_range_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  );
  PROCEDURE GET_UFK_IGS_FI_FEE_AS_RATE (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_rate_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  );
end IGS_FI_ELM_RANGE_RT_PKG;

 

/
