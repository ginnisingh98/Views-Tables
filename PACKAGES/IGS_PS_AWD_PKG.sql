--------------------------------------------------------
--  DDL for Package IGS_PS_AWD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_AWD_PKG" AUTHID CURRENT_USER AS
  /* $Header: IGSPI01S.pls 115.6 2003/02/25 08:10:05 sarakshi ship $ */

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_TITLE in VARCHAR2,
  X_S_AWARD_TYPE in VARCHAR2,
  X_TESTAMUR_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER  in NUMBER
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
    X_AWARD_CD in VARCHAR2,
  X_AWARD_TITLE in VARCHAR2,
  X_S_AWARD_TYPE in VARCHAR2,
  X_TESTAMUR_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2 ,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER  in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_TITLE in VARCHAR2,
  X_S_AWARD_TYPE in VARCHAR2,
  X_TESTAMUR_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER  in NUMBER
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_AWARD_CD in VARCHAR2,
  X_AWARD_TITLE in VARCHAR2,
  X_S_AWARD_TYPE in VARCHAR2,
  X_TESTAMUR_TYPE in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER  in NUMBER
  );

  FUNCTION Get_PK_For_Validation (
    x_award_cd IN VARCHAR2 )
  RETURN BOOLEAN ;

  PROCEDURE GET_FK_IGS_GR_TESTAMUR_TYPE (
    x_testamur_type IN VARCHAR2
    );

  -- Added by aiyer for the build of PSCR015 Tertiary And Secondary Bug No #2216952
  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd  IN VARCHAR2 ,
    x_gs_version_number  IN NUMBER
    );

PROCEDURE Check_Constraints (
    Column_Name	IN VARCHAR2	DEFAULT NULL,
    Column_Value 	IN VARCHAR2	DEFAULT NULL
);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_award_title IN VARCHAR2 DEFAULT NULL,
    x_s_award_type IN VARCHAR2 DEFAULT NULL,
    x_testamur_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_grading_schema_cd IN VARCHAR2  DEFAULT NULL,
    x_gs_version_number IN NUMBER   DEFAULT NULL
  ) ;

end IGS_PS_AWD_PKG;

 

/
