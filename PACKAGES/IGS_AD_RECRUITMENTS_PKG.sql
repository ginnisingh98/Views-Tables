--------------------------------------------------------
--  DDL for Package IGS_AD_RECRUITMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_RECRUITMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAI87S.pls 115.8 2002/11/28 22:18:44 nsidana ship $ */
 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CERTAINTY_OF_CHOICE_ID IN NUMBER,
       x_RELIGION_CD IN VARCHAR2,
       x_ADV_STUDIES_CLASSES IN NUMBER,
       x_HONORS_CLASSES IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_SEC_SCHOOL_LOCATION_ID IN NUMBER,
       x_PERCENT_PLAN_HIGHER_EDU IN NUMBER,
       x_RECRUITMENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_SPECIAL_INTEREST_ID IN NUMBER,
       x_PRIORITY IN VARCHAR2,
       x_VIP IN VARCHAR2,
       x_DEACTIVATE_RECRUIT_STATUS IN VARCHAR2,
       x_PROGRAM_INTEREST_ID IN NUMBER,
       x_INSTITUTION_SIZE_ID IN NUMBER,
       x_INSTITUTION_CONTROL_ID IN NUMBER,
       x_INSTITUTION_SETTING_ID IN NUMBER,
       x_INSTITUTION_LOCATION_ID IN NUMBER,
       x_SPECIAL_SERVICES_ID IN NUMBER,
       x_EMPLOYMENT_ID IN NUMBER,
       x_HOUSING_ID IN NUMBER,
       x_DEGREE_GOAL_ID IN NUMBER,
       x_UNIT_SET_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_CERTAINTY_OF_CHOICE_ID IN NUMBER,
       x_RELIGION_CD IN VARCHAR2,
       x_ADV_STUDIES_CLASSES IN NUMBER,
       x_HONORS_CLASSES IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_SEC_SCHOOL_LOCATION_ID IN NUMBER,
       x_PERCENT_PLAN_HIGHER_EDU IN NUMBER,
       x_RECRUITMENT_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_SPECIAL_INTEREST_ID IN NUMBER,
       x_PRIORITY IN VARCHAR2,
       x_VIP IN VARCHAR2,
       x_DEACTIVATE_RECRUIT_STATUS IN VARCHAR2,
       x_PROGRAM_INTEREST_ID IN NUMBER,
       x_INSTITUTION_SIZE_ID IN NUMBER,
       x_INSTITUTION_CONTROL_ID IN NUMBER,
       x_INSTITUTION_SETTING_ID IN NUMBER,
       x_INSTITUTION_LOCATION_ID IN NUMBER,
       x_SPECIAL_SERVICES_ID IN NUMBER,
       x_EMPLOYMENT_ID IN NUMBER,
       x_HOUSING_ID IN NUMBER,
       x_DEGREE_GOAL_ID IN NUMBER,
       x_UNIT_SET_ID IN NUMBER  );

 procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_CERTAINTY_OF_CHOICE_ID IN NUMBER,
       x_RELIGION_CD IN VARCHAR2,
       x_ADV_STUDIES_CLASSES IN NUMBER,
       x_HONORS_CLASSES IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_SEC_SCHOOL_LOCATION_ID IN NUMBER,
       x_PERCENT_PLAN_HIGHER_EDU IN NUMBER,
       x_RECRUITMENT_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_SPECIAL_INTEREST_ID IN NUMBER,
       x_PRIORITY IN VARCHAR2,
       x_VIP IN VARCHAR2,
       x_DEACTIVATE_RECRUIT_STATUS IN VARCHAR2,
       x_PROGRAM_INTEREST_ID IN NUMBER,
       x_INSTITUTION_SIZE_ID IN NUMBER,
       x_INSTITUTION_CONTROL_ID IN NUMBER,
       x_INSTITUTION_SETTING_ID IN NUMBER,
       x_INSTITUTION_LOCATION_ID IN NUMBER,
       x_SPECIAL_SERVICES_ID IN NUMBER,
       x_EMPLOYMENT_ID IN NUMBER,
       x_HOUSING_ID IN NUMBER,
       x_DEGREE_GOAL_ID IN NUMBER,
       x_UNIT_SET_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  );

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_CERTAINTY_OF_CHOICE_ID IN NUMBER,
       x_RELIGION_CD IN VARCHAR2,
       x_ADV_STUDIES_CLASSES IN NUMBER,
       x_HONORS_CLASSES IN NUMBER,
       x_CLASS_SIZE IN NUMBER,
       x_SEC_SCHOOL_LOCATION_ID IN NUMBER,
       x_PERCENT_PLAN_HIGHER_EDU IN NUMBER,
       x_RECRUITMENT_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_SPECIAL_INTEREST_ID IN NUMBER,
       x_PRIORITY IN VARCHAR2,
       x_VIP IN VARCHAR2,
       x_DEACTIVATE_RECRUIT_STATUS IN VARCHAR2,
       x_PROGRAM_INTEREST_ID IN NUMBER,
       x_INSTITUTION_SIZE_ID IN NUMBER,
       x_INSTITUTION_CONTROL_ID IN NUMBER,
       x_INSTITUTION_SETTING_ID IN NUMBER,
       x_INSTITUTION_LOCATION_ID IN NUMBER,
       x_SPECIAL_SERVICES_ID IN NUMBER,
       x_EMPLOYMENT_ID IN NUMBER,
       x_HOUSING_ID IN NUMBER,
       x_DEGREE_GOAL_ID IN NUMBER,
       x_UNIT_SET_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) ;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) ;
  FUNCTION Get_PK_For_Validation (
    x_recruitment_id IN NUMBER
    ) RETURN BOOLEAN ;

FUNCTION Get_UK_For_Validation (
    x_person_id IN NUMBER
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
    x_certainty_of_choice_id IN NUMBER DEFAULT NULL,
    x_religion_cd IN VARCHAR2 DEFAULT NULL,
    x_adv_studies_classes IN NUMBER DEFAULT NULL,
    x_honors_classes IN NUMBER DEFAULT NULL,
    x_class_size IN NUMBER DEFAULT NULL,
    x_sec_school_location_id IN NUMBER DEFAULT NULL,
    x_percent_plan_higher_edu IN NUMBER DEFAULT NULL,
    x_recruitment_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_special_interest_id IN NUMBER DEFAULT NULL,
    x_priority IN VARCHAR2 DEFAULT NULL,
    x_vip IN VARCHAR2 DEFAULT NULL,
    x_deactivate_recruit_status IN VARCHAR2 DEFAULT NULL,
    x_program_interest_id IN NUMBER DEFAULT NULL,
    x_institution_size_id IN NUMBER DEFAULT NULL,
    x_institution_control_id IN NUMBER DEFAULT NULL,
    x_institution_setting_id IN NUMBER DEFAULT NULL,
    x_institution_location_id IN NUMBER DEFAULT NULL,
    x_special_services_id IN NUMBER DEFAULT NULL,
    x_employment_id IN NUMBER DEFAULT NULL,
    x_housing_id IN NUMBER DEFAULT NULL,
    x_degree_goal_id IN NUMBER DEFAULT NULL,
    x_unit_set_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
 );
END igs_ad_recruitments_pkg;

 

/