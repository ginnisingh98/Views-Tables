--------------------------------------------------------
--  DDL for Package IGS_PS_FACLTY_DEGRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FACLTY_DEGRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0OS.pls 120.0 2005/06/02 03:52:47 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_FACLTY_DEGRD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_FACLTY_DEGRD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_FACLTY_DEGRD_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_FACLTY_DEGRD_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DEGREE_CD IN VARCHAR2,
       x_PROGRAM IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_DEGREE_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_faclty_degrd_id IN NUMBER
    ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_degree_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_program   IN VARCHAR2  --bug:2082568
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Degrees (
    x_degree_cd IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Or_Institution (
    x_institution_cd IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_faclty_degrd_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_degree_cd IN VARCHAR2 DEFAULT NULL,
    x_program IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_degree_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_faclty_degrs_pkg;

 

/
