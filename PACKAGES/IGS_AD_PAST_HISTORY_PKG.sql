--------------------------------------------------------
--  DDL for Package IGS_AD_PAST_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PAST_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI88S.pls 115.8 2002/11/28 22:19:04 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_ORG_ID in NUMBER,
       x_PAST_HISTORY_ID IN OUT NOCOPY NUMBER,
       x_YEARS_OF_STUDY IN NUMBER,
       x_SUBJECT_ID IN NUMBER,
       x_HONORS IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PAST_HISTORY_ID IN NUMBER,
       x_YEARS_OF_STUDY IN NUMBER,
       x_SUBJECT_ID IN NUMBER,
       x_HONORS IN VARCHAR2,
       x_PERSON_ID IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PAST_HISTORY_ID IN NUMBER,
       x_YEARS_OF_STUDY IN NUMBER,
       x_SUBJECT_ID IN NUMBER,
       x_HONORS IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      X_ORG_ID in NUMBER,
       x_PAST_HISTORY_ID IN OUT NOCOPY NUMBER,
       x_YEARS_OF_STUDY IN NUMBER,
       x_SUBJECT_ID IN NUMBER,
       x_HONORS IN VARCHAR2,
       x_PERSON_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_past_history_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_person_id IN NUMBER,
    x_subject_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
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
    x_org_id IN NUMBER DEFAULT NULL,
    x_past_history_id IN NUMBER DEFAULT NULL,
    x_years_of_study IN NUMBER DEFAULT NULL,
    x_subject_id IN NUMBER DEFAULT NULL,
    x_honors IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_past_history_pkg;

 

/
