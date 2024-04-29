--------------------------------------------------------
--  DDL for Package IGS_PE_ACAD_HONORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_ACAD_HONORS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI99S.pls 120.0 2005/06/01 20:15:04 appldev noship $ */
 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_ACAD_HONOR_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_COMMENTS IN VARCHAR2,
       x_HONOR_DATE IN DATE,
       X_MODE in VARCHAR2 default 'R',
       X_ACAD_HONOR_TYPE IN VARCHAR2
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_ACAD_HONOR_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_COMMENTS IN VARCHAR2,
       x_HONOR_DATE IN DATE,
       X_ACAD_HONOR_TYPE IN VARCHAR2);

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
      x_ACAD_HONOR_ID IN NUMBER,
      x_PERSON_ID IN NUMBER,
      x_COMMENTS IN VARCHAR2,
      x_HONOR_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ACAD_HONOR_TYPE IN VARCHAR2
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_ACAD_HONOR_ID IN OUT NOCOPY NUMBER,
      x_PERSON_ID IN NUMBER,
      x_COMMENTS IN VARCHAR2,
      x_HONOR_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R',
      X_ACAD_HONOR_TYPE IN VARCHAR2
  ) ;

  procedure DELETE_ROW (
    X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
     );

  FUNCTION Get_PK_For_Validation (
    x_acad_honor_id IN NUMBER
  ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_acad_honor_type IN VARCHAR2, --change id to cd
    x_honor_date IN DATE,
    x_person_id IN NUMBER

  ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2  DEFAULT NULL,
    Column_Value IN VARCHAR2  DEFAULT NULL
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_acad_honor_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_honor_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_acad_honor_type IN VARCHAR2 DEFAULT NULL
 );

END IGS_PE_ACAD_HONORS_PKG;

 

/
