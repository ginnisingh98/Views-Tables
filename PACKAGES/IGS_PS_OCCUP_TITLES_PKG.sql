--------------------------------------------------------
--  DDL for Package IGS_PS_OCCUP_TITLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_OCCUP_TITLES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0FS.pls 115.7 2002/11/29 01:56:26 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PRGM_OCCUPATIONAL_TITLE_ID IN OUT NOCOPY NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
      X_ORG_ID IN NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PRGM_OCCUPATIONAL_TITLE_ID IN NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2
       );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PRGM_OCCUPATIONAL_TITLE_ID IN NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PRGM_OCCUPATIONAL_TITLE_ID IN OUT NOCOPY NUMBER,
       x_PROGRAM_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
      X_ORG_ID IN NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_prgm_occupational_title_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_occupational_title_code IN VARCHAR2,
    x_program_code IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ps_Dic_Occ_Titls (
    x_occupational_title_code IN VARCHAR2
    );


PROCEDURE Get_Fk_Igs_Ps_Ver(
    x_program_code IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_prgm_occupational_title_id IN NUMBER DEFAULT NULL,
    x_program_code IN VARCHAR2 DEFAULT NULL,
    x_occupational_title_code IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
      X_ORG_ID IN NUMBER DEFAULT NULL
 );
END igs_ps_occup_titles_pkg;

 

/
