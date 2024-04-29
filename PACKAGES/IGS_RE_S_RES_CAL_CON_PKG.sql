--------------------------------------------------------
--  DDL for Package IGS_RE_S_RES_CAL_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_S_RES_CAL_CON_PKG" AUTHID CURRENT_USER as
/* $Header: IGSRI25S.pls 115.3 2002/11/29 03:38:29 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EFFECTIVE_STRT_DT_ALIAS in VARCHAR2,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EFFECTIVE_STRT_DT_ALIAS in VARCHAR2,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EFFECTIVE_STRT_DT_ALIAS in VARCHAR2,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EFFECTIVE_STRT_DT_ALIAS in VARCHAR2,
  X_EFFECTIVE_END_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_s_control_num IN NUMBER
    )RETURN BOOLEAN ;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 );

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_effective_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_effective_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_RE_S_RES_CAL_CON_PKG;

 

/
