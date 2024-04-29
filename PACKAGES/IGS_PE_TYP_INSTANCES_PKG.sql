--------------------------------------------------------
--  DDL for Package IGS_PE_TYP_INSTANCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_TYP_INSTANCES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNI46S.pls 120.0 2005/06/01 19:24:26 appldev noship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
      x_PERSON_ID IN NUMBER,
      x_COURSE_CD IN VARCHAR2,
      x_TYPE_INSTANCE_ID IN OUT NOCOPY NUMBER,
      x_PERSON_TYPE_CODE IN VARCHAR2,
      x_CC_VERSION_NUMBER IN NUMBER,
      x_FUNNEL_STATUS IN VARCHAR2,
      x_ADMISSION_APPL_NUMBER IN NUMBER,
      x_NOMINATED_COURSE_CD IN VARCHAR2,
      x_NCC_VERSION_NUMBER IN NUMBER,
      x_SEQUENCE_NUMBER IN NUMBER,
      x_START_DATE IN DATE,
      x_END_DATE IN DATE,
      x_CREATE_METHOD IN VARCHAR2,
      x_ENDED_BY IN NUMBER,
      x_END_METHOD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      X_ORG_ID in NUMBER,
      X_EMPLMNT_CATEGORY_CODE IN VARCHAR2 DEFAULT NULL
  );

 procedure LOCK_ROW (
       X_ROWID in  VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
       X_EMPLMNT_CATEGORY_CODE IN VARCHAR2 DEFAULT NULL
   );

 procedure UPDATE_ROW (
       X_ROWID in  VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       X_EMPLMNT_CATEGORY_CODE IN VARCHAR2  DEFAULT NULL
  );


 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_TYPE_INSTANCE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_TYPE_CODE IN VARCHAR2,
       x_CC_VERSION_NUMBER IN NUMBER,
       x_FUNNEL_STATUS IN VARCHAR2,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_NCC_VERSION_NUMBER IN NUMBER,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_CREATE_METHOD IN VARCHAR2,
       x_ENDED_BY IN NUMBER,
       x_END_METHOD IN VARCHAR2,
       X_MODE in VARCHAR2 default 'R',
       X_ORG_ID in NUMBER,
       X_EMPLMNT_CATEGORY_CODE IN VARCHAR2 DEFAULT NULL
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
) ;
  FUNCTION Get_PK_For_Validation (
    x_type_instance_id IN NUMBER
    ) RETURN BOOLEAN ;

  PROCEDURE Get_FK_Igs_Ad_Ps_Appl_Inst (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Pe_Person_Types (
    x_person_type_code IN VARCHAR2
    );

  PROCEDURE Get_FK_Igs_Ps_Ver (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    );

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    );

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) ;


  PROCEDURE Check_Mand_Person_Type
  (
    p_person_type_code 	IN IGS_PE_PERSON_TYPES.person_type_code%TYPE,
    p_person_id 		IN HZ_PARTIES.party_id%TYPE
  );

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_type_instance_id IN NUMBER DEFAULT NULL,
    x_person_type_code IN VARCHAR2 DEFAULT NULL,
    x_cc_version_number IN NUMBER DEFAULT NULL,
    x_funnel_status IN VARCHAR2 DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_ncc_version_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_create_method IN VARCHAR2 DEFAULT NULL,
    x_ended_by IN NUMBER DEFAULT NULL,
    x_end_method IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    X_EMPLMNT_CATEGORY_CODE IN VARCHAR2 DEFAULT NULL
 );
END igs_pe_typ_instances_pkg;

 

/
