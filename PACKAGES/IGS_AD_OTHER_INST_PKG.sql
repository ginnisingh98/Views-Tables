--------------------------------------------------------
--  DDL for Package IGS_AD_OTHER_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_OTHER_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI99S.pls 120.2 2005/12/06 02:39:57 appldev ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_OTHER_INST_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_INSTITUTION_CODE IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       x_new_institution IN VARCHAR2 DEFAULT NULL
  );

 procedure LOCK_ROW (
       X_ROWID in  VARCHAR2,
       x_OTHER_INST_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_INSTITUTION_CODE IN VARCHAR2,
       x_new_institution IN VARCHAR2 DEFAULT NULL  );
 procedure UPDATE_ROW (
       X_ROWID in  VARCHAR2,
       x_OTHER_INST_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_INSTITUTION_CODE IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       x_new_institution IN VARCHAR2 DEFAULT NULL
  );

 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_OTHER_INST_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_INSTITUTION_CODE IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       x_new_institution IN VARCHAR2 DEFAULT NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_other_inst_id IN NUMBER
    ) RETURN BOOLEAN ;

  FUNCTION Get_UK_For_Validation (
    x_admission_appl_number IN NUMBER,
    x_institution_code IN VARCHAR2,
    x_person_id IN NUMBER,
    x_new_institution IN VARCHAR2
    ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_appl (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Or_Institution (
    x_institution_cd IN VARCHAR2
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_other_inst_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_institution_code IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_new_institution IN VARCHAR2 DEFAULT NULL
 );
END igs_ad_other_inst_pkg;

 

/
