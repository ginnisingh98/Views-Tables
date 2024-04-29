--------------------------------------------------------
--  DDL for Package IGS_GE_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_EXCEPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI12S.pls 115.3 2002/11/29 01:12:14 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_EXCPT_ID in out NOCOPY NUMBER,
  X_ROW_ID in ROWID,
  X_OWNER in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_CONSTRAINT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_EXCPT_ID in NUMBER,
  X_ROW_ID in ROWID,
  X_OWNER in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_CONSTRAINT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_EXCPT_ID in NUMBER,
  X_ROW_ID in ROWID,
  X_OWNER in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_CONSTRAINT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
);
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_EXCPT_ID	in out NOCOPY NUMBER,
  X_ROW_ID in ROWID,
  X_OWNER in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_CONSTRAINT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
);

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
	x_excpt_id IN VARCHAR2
) RETURN BOOLEAN ;
 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_EXCPT_ID in number DEFAULT NULL,
    x_row_id IN ROWID DEFAULT NULL,
    x_owner IN VARCHAR2 DEFAULT NULL,
    x_table_name IN VARCHAR2 DEFAULT NULL,
    x_constraint IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_GE_EXCEPTIONS_PKG;

 

/
