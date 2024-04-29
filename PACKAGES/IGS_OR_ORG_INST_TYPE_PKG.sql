--------------------------------------------------------
--  DDL for Package IGS_OR_ORG_INST_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_ORG_INST_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI19S.pls 115.8 2002/11/29 01:42:06 nsidana ship $ */
 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2 );

 procedure UPDATE_ROW (
       X_ROWID in  VARCHAR2,
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_INSTITUTION_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_INST_TYPE VARCHAR2,
       x_CLOSE_IND IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_institution_type IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_institution_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_SYSTEM_INST_TYPE VARCHAR2 DEFAULT NULL,
    x_close_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL
 );
END igs_or_org_inst_type_pkg;

 

/
