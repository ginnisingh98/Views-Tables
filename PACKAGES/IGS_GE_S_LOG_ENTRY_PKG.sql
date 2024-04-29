--------------------------------------------------------
--  DDL for Package IGS_GE_S_LOG_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_S_LOG_ENTRY_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI11S.pls 115.4 2002/11/29 01:11:57 nsidana ship $ */
-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- kumma      13-JUN-2002     Removed Procedure GET_FK_IGS_ESSAGE, 2410165
  -------------------------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
FUNCTION GET_PK_FOR_VALIDATION (
    x_s_log_type IN VARCHAR2,
    x_creation_dt IN DATE,
    x_sequence_number IN NUMBER
)RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_GE_S_LOG (
    x_s_log_type IN VARCHAR2,
    x_creation_dt IN DATE
    );

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 );
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_log_type IN VARCHAR2 DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_key IN VARCHAR2 DEFAULT NULL,
    x_message_name IN VARCHAR2 DEFAULT NULL,
    x_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_GE_S_LOG_ENTRY_PKG;

 

/
