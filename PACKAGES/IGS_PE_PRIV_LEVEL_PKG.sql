--------------------------------------------------------
--  DDL for Package IGS_PE_PRIV_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PRIV_LEVEL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI61S.pls 120.0 2005/06/01 23:07:46 appldev noship $ */

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To create Table Handler
Know limitations, enhancements or remarks : None
Change History
Who		When		What
kumma           13-JUN-2002     Removed Procedure Get_FK_Igs_Ge_Note, 2410165

(reverse chronological order - newest change first)
********************************************************/

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PRIVACY_LEVEL_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PRIVACY_LEVEL_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE  );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PRIVACY_LEVEL_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PRIVACY_LEVEL_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;

  FUNCTION Get_PK_For_Validation (
    x_privacy_level_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_privacy_level_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_data_group IN VARCHAR2 DEFAULT NULL,
    x_data_group_id IN NUMBER DEFAULT NULL,
    x_lvl IN NUMBER DEFAULT NULL,
    x_action IN VARCHAR2 DEFAULT NULL,
    x_whom IN VARCHAR2 DEFAULT NULL,
    x_ref_notes_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );

END igs_pe_priv_level_pkg;

 

/
