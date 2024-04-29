--------------------------------------------------------
--  DDL for Package IGS_PS_DIC_OCC_TITLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_DIC_OCC_TITLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI0ES.pls 115.6 2002/11/29 01:56:08 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE IN VARCHAR2,
       x_ALTERNATE_TITLE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE IN VARCHAR2,
       x_ALTERNATE_TITLE IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE IN VARCHAR2,
       x_ALTERNATE_TITLE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_OCCUPATIONAL_TITLE_CODE IN VARCHAR2,
       x_OCCUPATIONAL_TITLE IN VARCHAR2,
       x_ALTERNATE_TITLE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_occupational_title_code IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_occupational_title_code IN VARCHAR2 DEFAULT NULL,
    x_occupational_title IN VARCHAR2 DEFAULT NULL,
    x_alternate_title IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ps_dic_occ_titls_pkg;

 

/
