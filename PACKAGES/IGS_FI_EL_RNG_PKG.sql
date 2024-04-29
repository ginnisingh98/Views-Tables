--------------------------------------------------------
--  DDL for Package IGS_FI_EL_RNG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_EL_RNG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI66S.pls 115.4 2003/02/12 09:59:37 shtatiko ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ER_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ER_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ER_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ER_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
  procedure DELETE_ROW (
    X_ROWID in VARCHAR2
  );
  FUNCTION Get_PK_For_Validation (
    x_ER_ID NUMBER
  ) RETURN BOOLEAN;
  FUNCTION Get_UK1_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_range_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN;
  FUNCTION Get_UK2_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_range_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN;
  FUNCTION Get_UK3_For_Validation (
    x_er_id IN NUMBER
  ) RETURN BOOLEAN;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ER_ID IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_lower_range IN NUMBER DEFAULT NULL,
    x_upper_range IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_chg_method_type IN VARCHAR2
    );
end IGS_FI_EL_RNG_PKG;

 

/
