--------------------------------------------------------
--  DDL for Package IGS_GE_NOTE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_GE_NOTE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSMI03S.pls 115.3 2002/11/29 01:09:54 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_REFERENCE_NUMBER in NUMBER,
  X_S_NOTE_FORMAT_TYPE in VARCHAR2,
  X_NOTE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);
  FUNCTION GET_PK_FOR_VALIDATION (
    x_reference_number IN NUMBER
  ) RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_note_format_type IN VARCHAR2
    );
PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_reference_number IN NUMBER DEFAULT NULL,
    x_s_note_format_type IN VARCHAR2 DEFAULT NULL,
    x_note_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


end IGS_GE_NOTE_PKG;

 

/
