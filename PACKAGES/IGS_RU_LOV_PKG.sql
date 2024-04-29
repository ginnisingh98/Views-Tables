--------------------------------------------------------
--  DDL for Package IGS_RU_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_LOV_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI08S.pls 115.5 2002/11/29 04:27:01 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_description IN VARCHAR2,
    x_sequence_number IN NUMBER
    )
RETURN BOOLEAN;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_help_text IN VARCHAR2 DEFAULT NULL,
    x_selectable IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

PROCEDURE Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);

end IGS_RU_LOV_PKG;

 

/
