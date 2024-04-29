--------------------------------------------------------
--  DDL for Package IGS_RU_CALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_CALL_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI01S.pls 115.4 2002/11/29 04:24:49 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_s_rule_call_cd IN VARCHAR2
    )
RETURN BOOLEAN;

FUNCTION Get_UK1_For_Validation (
   x_rud_sequence_number IN NUMBER
    )
RETURN BOOLEAN;

PROCEDURE GET_FK_IGS_RU_NAMED_RULE (
    x_rul_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_DESCRIPTION (
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_GROUP_SG (
    x_sequence_number IN NUMBER
    );

 PROCEDURE Get_FK_IGS_RU_GROUP_SEQ (
    x_sequence_number IN NUMBER
    );



-- added to take care of check constraints
PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_s_rule_type_cd IN VARCHAR2 DEFAULT NULL,
    x_rud_sequence_number IN NUMBER DEFAULT NULL,
    x_true_message IN VARCHAR2 DEFAULT NULL,
    x_false_message IN VARCHAR2 DEFAULT NULL,
    x_default_rule IN NUMBER DEFAULT NULL,
    x_rug_sequence_number IN NUMBER DEFAULT NULL,
    x_select_group IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_RU_CALL_PKG;

 

/
