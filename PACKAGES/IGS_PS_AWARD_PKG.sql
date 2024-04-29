--------------------------------------------------------
--  DDL for Package IGS_PS_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_AWARD_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSPI06S.pls 115.7 2003/06/16 11:39:15 jbegum ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_DEFAULT_IND in VARCHAR2 default 'Y',
  x_closed_ind IN VARCHAR2 DEFAULT NULL
  );
procedure LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DEFAULT_IND in VARCHAR2 default 'Y',
  x_closed_ind IN VARCHAR2 DEFAULT NULL
);
procedure UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_DEFAULT_IND in VARCHAR2 default 'Y',
  x_closed_ind IN VARCHAR2 DEFAULT NULL
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_DEFAULT_IND in VARCHAR2 default 'Y',
  x_closed_ind IN VARCHAR2 DEFAULT NULL
  );

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_award_cd IN VARCHAR2)
  RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_default_ind IN VARCHAR2  DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL
  ) ;

end IGS_PS_AWARD_PKG;

 

/
