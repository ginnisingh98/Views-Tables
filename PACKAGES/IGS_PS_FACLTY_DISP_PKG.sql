--------------------------------------------------------
--  DDL for Package IGS_PS_FACLTY_DISP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_FACLTY_DISP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0PS.pls 120.0 2005/06/01 13:48:02 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DISPLN_UNIT_ID IN OUT NOCOPY NUMBER,
       x_DISPLN_UNIT_TYPE IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_DISPLN_UNIT_CD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_DISPLN_UNIT_ID IN NUMBER,
       x_DISPLN_UNIT_TYPE IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_DISPLN_UNIT_CD IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_DISPLN_UNIT_ID IN NUMBER,
       x_DISPLN_UNIT_TYPE IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_DISPLN_UNIT_CD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DISPLN_UNIT_ID IN OUT NOCOPY NUMBER,
       x_DISPLN_UNIT_TYPE IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_DISPLN_UNIT_CD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_displn_unit_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_displn_unit_cd IN VARCHAR2,
    x_displn_unit_type IN VARCHAR2,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_displn_unit_cd  IN VARCHAR2
    ) ;


  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_displn_unit_id IN NUMBER DEFAULT NULL,
    x_displn_unit_type IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_displn_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_faclty_disp_pkg;

 

/
