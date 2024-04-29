--------------------------------------------------------
--  DDL for Package IGS_PS_DEGREES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_DEGREES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI1IS.pls 120.0 2005/06/02 03:29:49 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DEGREE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_DEGREE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
       x_CLOSED_IND IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_DEGREE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DEGREE_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PROGRAM_TYPE IN VARCHAR2 DEFAULT NULL,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_degree_cd IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_degree_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_program_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_degrees_pkg;

 

/
