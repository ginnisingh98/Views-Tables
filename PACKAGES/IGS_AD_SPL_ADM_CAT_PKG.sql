--------------------------------------------------------
--  DDL for Package IGS_AD_SPL_ADM_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SPL_ADM_CAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIA3S.pls 120.0 2005/06/01 16:11:40 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SPL_ADM_CAT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_SPL_ADM_CAT IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SPL_ADM_CAT_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_SPL_ADM_CAT IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_SPL_ADM_CAT_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_SPL_ADM_CAT IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SPL_ADM_CAT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_SPL_ADM_CAT IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_spl_adm_cat_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER,
    x_spl_adm_cat IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_spl_adm_cat_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_spl_adm_cat IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_spl_adm_cat_pkg;

 

/
