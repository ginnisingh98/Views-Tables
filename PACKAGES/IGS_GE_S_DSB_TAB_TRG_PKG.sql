--------------------------------------------------------
--  DDL for Package IGS_GE_S_DSB_TAB_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_S_DSB_TAB_TRG_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI13S.pls 115.3 2002/11/29 01:12:29 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_SESSION_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_SESSION_ID in NUMBER
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION GET_PK_FOR_VALIDATION (
    x_table_name IN VARCHAR2,
    x_session_id IN NUMBER
) RETURN BOOLEAN ;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_table_name IN VARCHAR2 DEFAULT NULL,
    x_session_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_GE_S_DSB_TAB_TRG_PKG;

 

/
