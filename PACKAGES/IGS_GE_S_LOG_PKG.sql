--------------------------------------------------------
--  DDL for Package IGS_GE_S_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_S_LOG_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI10S.pls 115.4 2002/11/29 01:11:42 nsidana ship $ */
-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- kumma      13-JUN-2002     Removed procedure GET_FK_IGS_OG_TYPE, 2410165
  -------------------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_KEY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_KEY in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_KEY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_KEY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION GET_PK_FOR_VALIDATION (
    x_s_log_type IN VARCHAR2,
    x_creation_dt IN DATE
    ) RETURN BOOLEAN ;
 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_log_type IN VARCHAR2 DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_key IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_GE_S_LOG_PKG;

 

/
