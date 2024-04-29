--------------------------------------------------------
--  DDL for Package IGS_GE_S_GEN_CAL_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_S_GEN_CAL_CON_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI08S.pls 115.3 2002/11/29 01:11:09 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  X_CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  X_CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION GET_PK_FOR_VALIDATION (
    x_s_control_num IN NUMBER
 )RETURN BOOLEAN ;

PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_census_dt_alias IN VARCHAR2 DEFAULT NULL,
    crs_completion_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
);

end IGS_GE_S_GEN_CAL_CON_PKG;

 

/
