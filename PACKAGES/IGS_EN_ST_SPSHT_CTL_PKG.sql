--------------------------------------------------------
--  DDL for Package IGS_EN_ST_SPSHT_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ST_SPSHT_CTL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSEI09S.pls 115.3 2002/11/28 23:33:24 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SNAPSHOT_DT_TIME in DATE,
  X_DELETE_SNAPSHOT_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION  Get_PK_For_Validation (
    x_snapshot_dt_time IN DATE
    ) RETURN BOOLEAN;

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_snapshot_dt_time IN DATE DEFAULT NULL,
    x_delete_snapshot_ind IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_EN_ST_SPSHT_CTL_PKG;

 

/
