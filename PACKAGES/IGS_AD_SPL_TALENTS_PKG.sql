--------------------------------------------------------
--  DDL for Package IGS_AD_SPL_TALENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SPL_TALENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI97S.pls 120.0 2005/06/01 14:24:45 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SPL_TALENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_TALENT_TYPE_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SPL_TALENT_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_TALENT_TYPE_ID IN NUMBER  );
 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_SPL_TALENT_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_TALENT_TYPE_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_SPL_TALENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_SPECIAL_TALENT_TYPE_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_spl_talent_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_special_talent_type_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Ad_Appl (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_spl_talent_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_special_talent_type_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_spl_talents_pkg;

 

/
