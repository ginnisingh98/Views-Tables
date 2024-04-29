--------------------------------------------------------
--  DDL for Package IGS_RU_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_ITEM_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI07S.pls 120.2 2006/02/20 04:33:02 sarakshi noship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_rul_sequence_number IN NUMBER,
    x_item IN NUMBER
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
    x_item IN NUMBER DEFAULT NULL,
    x_turin_function IN VARCHAR2 DEFAULT NULL,
    x_named_rule IN NUMBER DEFAULT NULL,
    x_rule_number IN NUMBER DEFAULT NULL,
    x_set_number IN NUMBER DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_derived_rule IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

  PROCEDURE GET_FK_IGS_RU_NAMED_RULE (
    x_rul_sequence_number IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_SET (
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_UFK_IGS_RU_CALL (
    x_rud_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_TURIN_FNC (
    x_s_turin_function IN VARCHAR2
    );

  PROCEDURE LOAD_ROW (
    x_rul_sequence_number IN NUMBER,
    x_item                IN NUMBER,
    x_turin_function      IN VARCHAR2,
    x_named_rule          IN NUMBER,
    x_rule_number         IN NUMBER,
    x_set_number          IN NUMBER,
    x_value               IN VARCHAR2,
    x_derived_rule        IN NUMBER,
    x_owner               IN VARCHAR2,
    x_last_update_date    IN VARCHAR2,
    x_custom_mode         IN VARCHAR2
  );

  PROCEDURE LOAD_SEED_ROW (
    x_upload_mode         IN VARCHAR2, -- an extra parameter to distinguish NLS and non-NLS upload
    x_rul_sequence_number IN NUMBER,
    x_item                IN NUMBER,
    x_turin_function      IN VARCHAR2,
    x_named_rule          IN NUMBER,
    x_rule_number         IN NUMBER,
    x_set_number          IN NUMBER,
    x_value               IN VARCHAR2,
    x_derived_rule        IN NUMBER,
    x_owner               IN VARCHAR2,
    x_last_update_date    IN VARCHAR2,
    x_custom_mode         IN VARCHAR2
  );

end IGS_RU_ITEM_PKG;

 

/
