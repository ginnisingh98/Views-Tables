--------------------------------------------------------
--  DDL for Package IGS_AD_PRD_AD_PRC_CA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PRD_AD_PRC_CA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI30S.pls 115.7 2003/10/30 13:12:19 akadam ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  x_closed_ind IN VARCHAR2 DEFAULT 'N',
  x_single_response_flag IN VARCHAR2 DEFAULT 'N',
  x_include_sr_in_rollover_flag IN VARCHAR2 DEFAULT 'N'
  );
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  x_closed_ind IN VARCHAR2 DEFAULT 'N',
  x_single_response_flag IN VARCHAR2 DEFAULT 'N',
  x_include_sr_in_rollover_flag IN VARCHAR2 DEFAULT 'N'
  );

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  x_closed_ind IN VARCHAR2 DEFAULT 'N',
  x_single_response_flag IN VARCHAR2 DEFAULT 'N',
  x_include_sr_in_rollover_flag IN VARCHAR2 DEFAULT 'N'
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
    )
RETURN BOOLEAN;

PROCEDURE Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT 'N',
    x_single_response_flag IN VARCHAR2 DEFAULT 'N',
    x_include_sr_in_rollover_flag IN VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE GET_FK_IGS_AD_PERD_AD_CAT (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_AD_PRCS_CAT (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    );
end igs_ad_prd_ad_prc_ca_pkg;

 

/
