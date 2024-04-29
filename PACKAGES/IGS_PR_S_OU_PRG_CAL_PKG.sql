--------------------------------------------------------
--  DDL for Package IGS_PR_S_OU_PRG_CAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_S_OU_PRG_CAL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSQI23S.pls 115.3 2002/11/29 03:20:04 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_STREAM_NUM in NUMBER,
  X_SHOW_CAUSE_LENGTH in NUMBER,
  X_APPEAL_LENGTH in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_prg_cal_type IN VARCHAR2
    )
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_PR_S_OU_PRG_CONF (
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE
    );

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_stream_num IN NUMBER DEFAULT NULL,
    x_show_cause_length IN NUMBER DEFAULT NULL,
    x_appeal_length IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_PR_S_OU_PRG_CAL_PKG;

 

/
