--------------------------------------------------------
--  DDL for Package IGS_CA_DT_OF_MTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_DT_OF_MTH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI11S.pls 115.3 2002/11/28 23:02:19 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_OF_MONTH in DATE,
  X_CURRENT_USER in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DT_OF_MONTH in DATE,
  X_CURRENT_USER in VARCHAR2
);
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION Get_PK_For_Validation (
    x_dt_of_month IN DATE,
    x_current_user IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
    column_name  IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_of_month IN DATE DEFAULT NULL,
    x_current_user IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;
end IGS_CA_DT_OF_MTH_PKG;

 

/
