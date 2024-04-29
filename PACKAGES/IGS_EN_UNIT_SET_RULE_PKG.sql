--------------------------------------------------------
--  DDL for Package IGS_EN_UNIT_SET_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_UNIT_SET_RULE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSEI12S.pls 115.3 2002/11/28 23:34:08 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
    X_ROWID in VARCHAR2
);
FUNCTION Get_PK_For_Validation (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_s_rule_call_cd IN VARCHAR2
    ) RETURN BOOLEAN;
PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    );
PROCEDURE GET_FK_IGS_RU_CALL (
    x_s_rule_call_cd IN VARCHAR2
    );
PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );
 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 );

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );
end IGS_EN_UNIT_SET_RULE_PKG;

 

/
