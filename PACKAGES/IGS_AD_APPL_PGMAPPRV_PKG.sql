--------------------------------------------------------
--  DDL for Package IGS_AD_APPL_PGMAPPRV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_APPL_PGMAPPRV_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIA5S.pls 120.0 2005/06/01 18:31:37 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APPL_PGMAPPRV_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2,
      X_MODE in VARCHAR2 default NULL
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_APPL_PGMAPPRV_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_APPL_PGMAPPRV_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2,
      X_MODE in VARCHAR2 default NULL
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APPL_PGMAPPRV_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PGM_APPROVER_ID IN NUMBER,
       x_ASSIGN_TYPE IN VARCHAR2,
       x_ASSIGN_DATE IN DATE,
       x_PROGRAM_APPROVAL_DATE IN DATE,
       x_PROGRAM_APPROVAL_STATUS IN VARCHAR2,
       x_APPROVAL_NOTES IN VARCHAR2,
      X_MODE in VARCHAR2 default NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_appl_pgmapprv_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_pgm_approver_id IN NUMBER,
    x_sequence_number IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
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
    x_appl_pgmapprv_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_pgm_approver_id IN NUMBER DEFAULT NULL,
    x_assign_type IN VARCHAR2 DEFAULT NULL,
    x_assign_date IN DATE DEFAULT NULL,
    x_program_approval_date IN DATE DEFAULT NULL,
    x_program_approval_status IN VARCHAR2 DEFAULT NULL,
    x_approval_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_appl_pgmapprv_pkg;

 

/
