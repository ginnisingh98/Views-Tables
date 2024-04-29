--------------------------------------------------------
--  DDL for Package IGS_PE_MIL_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_MIL_SERVICES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI59S.pls 120.0 2005/06/02 04:21:04 appldev noship $ */

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MILIT_SERVICE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MILITARY_TYPE_CD IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEPARATION_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_STATUS_CD IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_MILIT_SERVICE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MILITARY_TYPE_CD IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
        x_SEPARATION_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_STATUS_CD IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2  );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_MILIT_SERVICE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MILITARY_TYPE_CD IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEPARATION_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_STATUS_CD IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MILIT_SERVICE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_MILITARY_TYPE_CD IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_SEPARATION_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_TYPE_CD IN VARCHAR2,
       x_ASSISTANCE_STATUS_CD IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_milit_service_id IN NUMBER
    ) RETURN BOOLEAN ;

  /*PROCEDURE Get_FK_Igs_Pe_Code_Classes_1 (
    x_code_classes_id IN NUMBER
    ); */

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );

  /* PROCEDURE Get_FK_Igs_Pe_Code_Classes_2 (
    x_code_classes_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Pe_Code_Classes_3 (
    x_code_classes_id IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Pe_Code_Classes_4 (
    x_code_classes_id IN NUMBER
    );
*/
  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;

   FUNCTION Get_UK_For_Validation (
    x_person_id  IN NUMBER,
    x_military_type_cd IN VARCHAR2,
    x_start_date IN DATE
    )RETURN BOOLEAN;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_milit_service_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_military_type_cd IN VARCHAR2 DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_separation_type_cd IN VARCHAR2 DEFAULT NULL,
    x_assistance_type_cd IN VARCHAR2 DEFAULT NULL,
    x_assistance_status_cd IN VARCHAR2 DEFAULT NULL,
    x_attribute_category IN VARCHAR2 DEFAULT NULL,
    x_attribute1 IN VARCHAR2 DEFAULT NULL,
    x_attribute2 IN VARCHAR2 DEFAULT NULL,
    x_attribute3 IN VARCHAR2 DEFAULT NULL,
    x_attribute4 IN VARCHAR2 DEFAULT NULL,
    x_attribute5 IN VARCHAR2 DEFAULT NULL,
    x_attribute6 IN VARCHAR2 DEFAULT NULL,
    x_attribute7 IN VARCHAR2 DEFAULT NULL,
    x_attribute8 IN VARCHAR2 DEFAULT NULL,
    x_attribute9 IN VARCHAR2 DEFAULT NULL,
    x_attribute10 IN VARCHAR2 DEFAULT NULL,
    x_attribute11 IN VARCHAR2 DEFAULT NULL,
    x_attribute12 IN VARCHAR2 DEFAULT NULL,
    x_attribute13 IN VARCHAR2 DEFAULT NULL,
    x_attribute14 IN VARCHAR2 DEFAULT NULL,
    x_attribute15 IN VARCHAR2 DEFAULT NULL,
    x_attribute16 IN VARCHAR2 DEFAULT NULL,
    x_attribute17 IN VARCHAR2 DEFAULT NULL,
    x_attribute18 IN VARCHAR2 DEFAULT NULL,
    x_attribute19 IN VARCHAR2 DEFAULT NULL,
    x_attribute20 IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_pe_mil_services_pkg;

 

/