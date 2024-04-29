--------------------------------------------------------
--  DDL for Package IGS_PE_PERSON_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PERSON_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI43S.pls 115.9 2002/11/20 13:08:05 gmuralid ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_SYSTEM_TYPE IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_RANK IN NUMBER DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_person_type_code IN VARCHAR2
    ) RETURN BOOLEAN ;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_system_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_rank IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_pe_person_types_pkg;

 

/
