--------------------------------------------------------
--  DDL for Package IGS_FI_GV_DSP_HEC_CN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GV_DSP_HEC_CN_PKG" AUTHID CURRENT_USER As
/* $Header: IGSSI53S.pls 115.3 2002/11/29 03:50:44 nsidana ship $*/
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_START_DT in DATE,
  X_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_govt_discipline_group_cd IN VARCHAR2,
    x_govt_hecs_cntrbtn_band IN NUMBER,
    x_start_dt IN DATE
    ) RETURN BOOLEAN;
  FUNCTION Get_UK1_For_Validation (
    x_govt_discipline_group_cd IN VARCHAR2,
    x_start_dt IN DATE
  ) RETURN BOOLEAN;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_cntrbtn_band IN NUMBER DEFAULT NULL,
    x_start_dt IN DATE DEFAULT NULL,
    x_end_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
  PROCEDURE GET_FK_IGS_PS_GOVT_DSCP (
    x_govt_discipline_group_cd IN VARCHAR2
    );
  PROCEDURE GET_FK_IGS_FI_GOVT_HEC_CNTB (
    x_govt_hecs_cntrbtn_band IN NUMBER
    );
end IGS_FI_GV_DSP_HEC_CN_PKG;

 

/
