--------------------------------------------------------
--  DDL for Package IGS_ST_UNT_LOAD_APPO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_ST_UNT_LOAD_APPO_PKG" AUTHID CURRENT_USER as
/* $Header: IGSVI12S.pls 115.3 2002/11/29 04:33:57 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DLA_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TEACH_CAL_TYPE in VARCHAR2,
  X_PERCENTAGE in NUMBER,
  X_SECOND_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
function Get_PK_For_Validation (
    x_dla_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
)return BOOLEAN;

procedure Check_Constraints (
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE get_fk_igs_st_dft_load_appo (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_teach_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dla_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_teach_cal_type IN VARCHAR2 DEFAULT NULL,
    x_percentage IN NUMBER DEFAULT NULL,
    x_second_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_ST_UNT_LOAD_APPO_PKG;

 

/
