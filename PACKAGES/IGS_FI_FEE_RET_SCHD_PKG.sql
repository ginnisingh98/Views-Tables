--------------------------------------------------------
--  DDL for Package IGS_FI_FEE_RET_SCHD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FEE_RET_SCHD_PKG" AUTHID CURRENT_USER AS
 /* $Header: IGSSI33S.pls 115.5 2003/02/12 10:13:07 shtatiko ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_SCHEDULE_NUMBER in NUMBER,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETENTION_PERCENTAGE in NUMBER,
  X_RETENTION_AMOUNT in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
 FUNCTION Get_PK_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    )RETURN BOOLEAN ;

  FUNCTION Get_UK1_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
	x_fee_cat		IN VARCHAR2,
	x_fee_type		IN VARCHAR2,
	x_dt_alias		IN VARCHAR2,
    x_s_relation_type IN VARCHAR2,
    x_dai_sequence_number IN NUMBER
    )RETURN BOOLEAN ;
  FUNCTION Get_UK2_For_Validation (
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
  	x_fee_cat		IN VARCHAR2,
  	x_fee_type		IN VARCHAR2,
  	x_schedule_number IN NUMBER
    )RETURN BOOLEAN ;

 PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

   PROCEDURE Before_DML (
     p_action IN VARCHAR2,
     x_rowid IN  VARCHAR2 DEFAULT NULL,
     x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
     x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
     x_s_relation_type IN VARCHAR2 DEFAULT NULL,
     x_sequence_number IN NUMBER DEFAULT NULL,
     x_fee_cat IN VARCHAR2 DEFAULT NULL,
     x_fee_type IN VARCHAR2 DEFAULT NULL,
     x_schedule_number IN NUMBER DEFAULT NULL,
     x_dt_alias IN VARCHAR2 DEFAULT NULL,
     x_dai_sequence_number IN NUMBER DEFAULT NULL,
     x_retention_percentage IN NUMBER DEFAULT NULL,
     x_retention_amount IN NUMBER DEFAULT NULL,
     x_creation_date IN DATE DEFAULT NULL,
     x_created_by IN NUMBER DEFAULT NULL,
     x_last_update_date IN DATE DEFAULT NULL,
     x_last_updated_by IN NUMBER DEFAULT NULL,
     x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

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
end IGS_FI_FEE_RET_SCHD_PKG;

 

/
