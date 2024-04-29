--------------------------------------------------------
--  DDL for Package IGS_RU_CALL_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_CALL_RULE_PKG" AUTHID CURRENT_USER as
/* $Header: IGSUI02S.pls 115.3 2002/11/29 04:25:08 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

FUNCTION Get_PK_For_Validation (
    x_called_rule_cd IN VARCHAR2
    )
RETURN BOOLEAN;

FUNCTION GET_UK1_FOR_VALIDATION(
	x_nr_rul_sequence_number IN NUMBER
	) RETURN BOOLEAN;


  PROCEDURE GET_FK_IGS_RU_NAMED_RULE (
    x_rul_sequence_number IN NUMBER
    );

-- added to take care of check constraints
PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_called_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_nr_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  );

end IGS_RU_CALL_RULE_PKG;

 

/
