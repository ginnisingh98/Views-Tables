--------------------------------------------------------
--  DDL for Package IGS_AD_PERD_AD_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PERD_AD_CAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI29S.pls 115.4 2002/11/28 22:01:46 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2
    )
RETURN BOOLEAN;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

PROCEDURE Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    );

  PROCEDURE GET_UFK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    );
end IGS_AD_PERD_AD_CAT_PKG;

 

/
