--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_NOTES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIA6S.pls 120.0 2005/06/01 21:30:08 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APPL_NOTES_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_REF_NOTES_ID IN OUT NOCOPY  NUMBER,
      X_MODE in VARCHAR2 default NULL
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_APPL_NOTES_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_REF_NOTES_ID IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_APPL_NOTES_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_REF_NOTES_ID IN NUMBER,
      X_MODE in VARCHAR2 default NULL
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APPL_NOTES_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_NOTE_TYPE_ID IN NUMBER,
       x_REF_NOTES_ID IN OUT NOCOPY NUMBER,
      X_MODE in VARCHAR2 default NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_appl_notes_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_note_type_id IN NUMBER,
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Note_Types (
    x_notes_type_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_appl_notes_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_note_type_id IN NUMBER DEFAULT NULL,
    x_ref_notes_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_appl_notes_pkg;

 

/
