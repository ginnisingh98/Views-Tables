--------------------------------------------------------
--  DDL for Package IGS_PS_COURSE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_COURSE_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSPI03S.pls 115.3 2002/11/29 01:53:05 nsidana ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  );

procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2
);

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
);

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2)
  RETURN BOOLEAN;

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;

end IGS_PS_COURSE_PKG;

 

/
