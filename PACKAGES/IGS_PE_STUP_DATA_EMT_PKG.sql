--------------------------------------------------------
--  DDL for Package IGS_PE_STUP_DATA_EMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_STUP_DATA_EMT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI45S.pls 115.7 2002/11/29 01:24:44 nsidana ship $ */
 procedure INSERT_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_SETUP_DATA_ELEMENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID in NUMBER default NULL

  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SETUP_DATA_ELEMENT_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2
         );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_SETUP_DATA_ELEMENT_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'

  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SETUP_DATA_ELEMENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_REQUIRED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_setup_data_element_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Pe_Person_Types (
    x_person_type_code IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Pe_Data_Element (
    x_data_element IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_setup_data_element_id IN NUMBER DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_required_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
 );
END igs_pe_stup_data_emt_pkg;

 

/
