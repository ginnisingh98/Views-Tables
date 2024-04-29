--------------------------------------------------------
--  DDL for Package IGS_RU_NAMED_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_NAMED_RULE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI09S.pls 115.5 2002/11/29 04:27:20 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_MESSAGE_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_RULE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_MESSAGE_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_RULE_TEXT in VARCHAR2
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_MESSAGE_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_RULE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_MESSAGE_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_RULE_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_rul_sequence_number IN NUMBER
    )
RETURN BOOLEAN;

PROCEDURE Check_constraints(
  	Column_Name 	IN	VARCHAR2 DEFAULT NULL,
	Column_Value 	IN	VARCHAR2 DEFAULT NULL
	);

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_rud_sequence_number IN NUMBER DEFAULT NULL,
    x_message_rule IN NUMBER DEFAULT NULL,
    x_rug_sequence_number IN NUMBER DEFAULT NULL,
    x_rule_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

  PROCEDURE GET_FK_IGS_RU_DESCRIPTION (
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_GROUP (
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    );


end IGS_RU_NAMED_RULE_PKG;

 

/
