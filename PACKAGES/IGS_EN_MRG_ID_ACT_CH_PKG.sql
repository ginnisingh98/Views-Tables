--------------------------------------------------------
--  DDL for Package IGS_EN_MRG_ID_ACT_CH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_MRG_ID_ACT_CH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI27S.pls 115.3 2002/11/28 23:38:32 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SMIR_ID in NUMBER,
  X_TABLE_ALIAS in VARCHAR2,
  X_ACTION_ID in NUMBER,
  X_PERFORM_ACTION_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);

 FUNCTION Get_PK_For_Validation (
    x_smir_id IN NUMBER,
    x_table_alias IN VARCHAR2,
    x_action_id IN NUMBER
    )
RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_EN_MRG_ID_ACTION (
    x_table_alias IN VARCHAR2,
    x_action_id IN NUMBER
    );

  PROCEDURE GET_FK_IGS_EN_MERGE_ID_ROWS (
    x_smir_id IN NUMBER
    );
procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   );
PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_smir_id IN NUMBER DEFAULT NULL,
    x_table_alias IN VARCHAR2 DEFAULT NULL,
    x_action_id IN NUMBER DEFAULT NULL,
    x_perform_action_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_EN_MRG_ID_ACT_CH_PKG;

 

/
