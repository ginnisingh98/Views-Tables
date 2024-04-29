--------------------------------------------------------
--  DDL for Package IGS_PS_RU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_RU_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI31S.pls 115.3 2002/11/29 02:21:38 nsidana ship $ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
);

 FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_s_rule_call_cd IN VARCHAR2
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    );

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    );

  PROCEDURE GET_FK_IGS_RU_CALL (
    x_s_rule_call_cd IN VARCHAR2
    );
PROCEDURE CHECK_CONSTRAINTS (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
);
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER  DEFAULT NULL
  ) ;
end IGS_PS_RU_PKG;

 

/
