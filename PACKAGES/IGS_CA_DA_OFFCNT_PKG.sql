--------------------------------------------------------
--  DDL for Package IGS_CA_DA_OFFCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_DA_OFFCNT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI08S.pls 115.3 2002/11/28 23:01:31 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_offset_dt_alias IN VARCHAR2,
    x_s_dt_offset_constraint_type IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_CA_DA_OFST (
    x_dt_alias IN VARCHAR2,
    x_offset_dt_alias IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_dt_offset_constraint_type IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
    column_name  IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL);

 PROCEDURE Before_DML (
	p_action IN VARCHAR2,
	x_rowid IN VARCHAR2 DEFAULT NULL,
	x_dt_alias IN VARCHAR2 DEFAULT NULL,
	x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
	x_s_dt_offset_constraint_type IN VARCHAR2 DEFAULT NULL,
	x_constraint_condition IN VARCHAR2 DEFAULT NULL,
	x_constraint_resolution IN NUMBER DEFAULT NULL,
	x_creation_date IN DATE DEFAULT NULL,
	x_created_by IN NUMBER DEFAULT NULL,
	x_last_update_date IN DATE DEFAULT NULL,
	x_last_updated_by IN NUMBER DEFAULT NULL,
	x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_CA_DA_OFFCNT_PKG;

 

/