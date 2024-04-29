--------------------------------------------------------
--  DDL for Package IGS_AD_ADM_UT_STT_LD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_ADM_UT_STT_LD_PKG" AUTHID CURRENT_USER as
/* $Header: IGSAI03S.pls 115.4 2003/02/18 12:15:27 kkillams ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_LOAD_INCURRED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_administrative_unit_status IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
			Column_Name IN VARCHAR2 DEFAULT NULL,
			Column_Value IN VARCHAR2 DEFAULT NULL
			);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_load_incurred_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


  PROCEDURE GET_FK_IGS_ST_DFT_LOAD_APPO (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    );

end IGS_AD_ADM_UT_STT_LD_PKG;

 

/
