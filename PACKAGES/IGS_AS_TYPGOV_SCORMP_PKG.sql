--------------------------------------------------------
--  DDL for Package IGS_AS_TYPGOV_SCORMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_TYPGOV_SCORMP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI24S.pls 115.3 2002/11/28 23:17:05 nsidana ship $ */


 /* $HEADER$ */
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER
);
procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SCNDRY_EDU_ASS_TYPE in VARCHAR2,
  X_RESULT_OBTAINED_YR in NUMBER,
  X_INSTITUTION_SCORE in NUMBER,
  X_GOVT_SCORE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  );
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  );
  FUNCTION Get_PK_For_Validation (
    x_scndry_edu_ass_type IN VARCHAR2,
    x_result_obtained_yr IN NUMBER,
    x_institution_score IN NUMBER
    )RETURN BOOLEAN;

  PROCEDURE GET_FK_IGS_AD_AUSE_ED_AS_TY (
    x_aus_scndry_edu_ass_type IN VARCHAR2    );



	PROCEDURE Check_Constraints (
	Column_Name	IN	VARCHAR2	DEFAULT NULL,
	Column_Value 	IN	VARCHAR2	DEFAULT NULL
	);

PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_scndry_edu_ass_type IN VARCHAR2 DEFAULT NULL,
    x_result_obtained_yr IN NUMBER DEFAULT NULL,
    x_institution_score IN NUMBER DEFAULT NULL,
    x_govt_score IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) ;


end IGS_AS_TYPGOV_SCORMP_PKG;

 

/
