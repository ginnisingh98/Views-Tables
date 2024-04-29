--------------------------------------------------------
--  DDL for Package Body IGS_AD_RECRUITMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_RECRUITMENTS_PKG" AS
/* $Header: IGSAI87B.pls 115.15 2003/12/09 11:07:12 akadam ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_recruitments%RowType;
  new_references igs_ad_recruitments%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,--DEFAULT NULL,
    x_certainty_of_choice_id IN NUMBER,-- DEFAULT NULL,
    x_religion_cd IN VARCHAR2 ,--DEFAULT NULL,
    x_adv_studies_classes IN NUMBER ,--DEFAULT NULL,
    x_honors_classes IN NUMBER,-- DEFAULT NULL,
    x_class_size IN NUMBER,-- DEFAULT NULL,
    x_sec_school_location_id IN NUMBER,-- DEFAULT NULL,
    x_percent_plan_higher_edu IN NUMBER,-- DEFAULT NULL,
    x_recruitment_id IN NUMBER ,--DEFAULT NULL,
    x_person_id IN NUMBER ,--DEFAULT NULL,
    x_special_interest_id IN NUMBER ,--DEFAULT NULL,
    x_priority IN VARCHAR2 ,--DEFAULT NULL,
    x_vip IN VARCHAR2,-- DEFAULT NULL,
    x_deactivate_recruit_status IN VARCHAR2 ,--DEFAULT NULL,
    x_program_interest_id IN NUMBER ,--DEFAULT NULL,
    x_institution_size_id IN NUMBER ,--DEFAULT NULL,
    x_institution_control_id IN NUMBER,-- DEFAULT NULL,
    x_institution_setting_id IN NUMBER ,--DEFAULT NULL,
    x_institution_location_id IN NUMBER ,--DEFAULT NULL,
    x_special_services_id IN NUMBER,-- DEFAULT NULL,
    x_employment_id IN NUMBER,-- DEFAULT NULL,
    x_housing_id IN NUMBER ,--DEFAULT NULL,
    x_degree_goal_id IN NUMBER,-- DEFAULT NULL,
    x_unit_set_id IN NUMBER ,--DEFAULT NULL,
    x_creation_date IN DATE ,--DEFAULT NULL,
    x_created_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_date IN DATE ,--DEFAULT NULL,
    x_last_updated_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_login IN NUMBER-- DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose : to set values for the columns
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel       24_JUL-2001       Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
                                 Removed the processing for the Obsolete column 'PROBABILITY'
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_RECRUITMENTS
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.certainty_of_choice_id := x_certainty_of_choice_id;
    new_references.religion_cd := x_religion_cd;
    new_references.adv_studies_classes := x_adv_studies_classes;
    new_references.honors_classes := x_honors_classes;
    new_references.class_size := x_class_size;
    new_references.sec_school_location_id := x_sec_school_location_id;
    new_references.percent_plan_higher_edu := x_percent_plan_higher_edu;
    new_references.recruitment_id := x_recruitment_id;
    new_references.person_id := x_person_id;
    new_references.special_interest_id := x_special_interest_id;
    new_references.priority := x_priority;
    new_references.vip := x_vip;
    new_references.deactivate_recruit_status := x_deactivate_recruit_status;
    new_references.program_interest_id := x_program_interest_id;
    new_references.institution_size_id := x_institution_size_id;
    new_references.institution_control_id := x_institution_control_id;
    new_references.institution_setting_id := x_institution_setting_id;
    new_references.institution_location_id := x_institution_location_id;
    new_references.special_services_id := x_special_services_id;
    new_references.employment_id := x_employment_id;
    new_references.housing_id := x_housing_id;
    new_references.degree_goal_id := x_degree_goal_id;
    new_references.unit_set_id := x_unit_set_id;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2 ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose : for adding check constraints on the columns
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  vdixit	  11-Oct-2001     Added the check constraint for
  				  adv_studies_classes bug 2030644
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'HONORS_CLASSES'  THEN
        new_references.honors_classes := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'VIP'  THEN
        new_references.vip := column_value;
      ELSIF  UPPER(column_name) = 'DEACTIVATE_RECRUIT_STATUS'  THEN
        new_references.deactivate_recruit_status := column_value;
      ELSIF  UPPER(column_name) = 'PERCENT_PLAN_HIGHER_EDU'  THEN
        new_references.percent_plan_higher_edu := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'CLASS_SIZE'  THEN
        new_references.class_size := IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF  UPPER(column_name) = 'ADV_STUDIES_CLASSES'  THEN   --added as a part of bug 2030644
        new_references.adv_studies_classes := IGS_GE_NUMBER.TO_NUM(column_value);
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'HONORS_CLASSES' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.honors_classes >= 0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_HONORS_CLS');
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'VIP' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.vip IN ('Y','N'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_VIP'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'DEACTIVATE_RECRUIT_STATUS' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.deactivate_recruit_status IN  ('Y','N'))  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEACTIVATE_REC_STAT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PERCENT_PLAN_HIGHER_EDU' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.percent_plan_higher_edu > 0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_PER_HIGH_EDU');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLASS_SIZE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.class_size > 0)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_CLASS_SIZE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

          -- The following code checks for check constraints on the Columns.
          -- Added as a part of bug 2030644

      IF Upper(Column_Name) = 'ADV_STUDIES_CLASSES' OR
      	Column_Name IS NULL THEN
        IF new_references.adv_studies_classes < 0  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_ADCLS_NOT_VAL');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : samaresh.in
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		   new_references.person_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose : to check whether parent exists
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.institution_location_id = new_references.institution_location_id)) OR
        ((new_references.institution_location_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.institution_location_id,
                        'INSTITUTION_LOCATION',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INST_LOC'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.sec_school_location_id = new_references.sec_school_location_id)) OR
        ((new_references.sec_school_location_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.sec_school_location_id,
                        'SEC_SCHOOL_LOCATION',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SEC_SCH_LOC'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.religion_cd = new_references.religion_cd)) OR
        ((new_references.religion_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_pkg.Get_PK_For_Validation (
        		'PE_RELIGION',new_references.religion_cd
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_RELG'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
        		new_references.person_id
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.degree_goal_id = new_references.degree_goal_id)) OR
        ((new_references.degree_goal_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.degree_goal_id,
                        'DESIRED_DEGREE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEGREE_GOAL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.unit_set_id = new_references.unit_set_id)) OR
        ((new_references.unit_set_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.unit_set_id,
                        'DESIRED_UNIT_SET',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_PS_UNIT_SET'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.institution_setting_id = new_references.institution_setting_id)) OR
        ((new_references.institution_setting_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.institution_setting_id ,
                        'INSTITUTION_SETTING',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INST_SETTING'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.program_interest_id = new_references.program_interest_id)) OR
        ((new_references.program_interest_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.program_interest_id ,
                        'PROGRAM_INTEREST',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_INTEREST'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.certainty_of_choice_id = new_references.certainty_of_choice_id)) OR
        ((new_references.certainty_of_choice_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.certainty_of_choice_id ,
                        'CERTAINTY_OF_CHOICE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CERTAIN_OF_CHOICE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.special_services_id = new_references.special_services_id)) OR
        ((new_references.special_services_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.special_services_id ,
                        'SPECIAL_SERVICES',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_SERVICES'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.employment_id = new_references.employment_id)) OR
        ((new_references.employment_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.employment_id ,
                        'DESIRED_EMPLOYMENT',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EMPLOYMENT_INF'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.institution_size_id = new_references.institution_size_id)) OR
        ((new_references.institution_size_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.institution_size_id ,
                        'INSTITUTION_SIZE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INST_SIZE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.special_interest_id = new_references.special_interest_id)) OR
        ((new_references.special_interest_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.special_interest_id ,
                        'SPECIAL_INTEREST',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_SPL_INTEREST'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.housing_id = new_references.housing_id)) OR
        ((new_references.housing_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.housing_id ,
                        'DESIRED_HOUSING',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_HOUSE_INF'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.institution_control_id = new_references.institution_control_id)) OR
        ((new_references.institution_control_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.institution_control_id ,
                        'INSTITUTION_CONTROL',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INST_CONTROL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_recruitment_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose : to check for primary key
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    recruitment_id = x_recruitment_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  FUNCTION Get_UK_For_Validation (
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : samaresh.in
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    person_id = x_person_id
      and      ((l_rowid is null) or (rowid <> l_rowid));
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose : check for the existance of the foreign keys
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid1 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    institution_location_id = x_code_id ;

    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    degree_goal_id = x_code_id ;

    CURSOR cur_rowid3 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    unit_set_id = x_code_id ;

    CURSOR cur_rowid4 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    institution_setting_id = x_code_id ;

    CURSOR cur_rowid5 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    program_interest_id = x_code_id ;

    CURSOR cur_rowid6 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    certainty_of_choice_id = x_code_id ;

    CURSOR cur_rowid7 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    special_services_id = x_code_id ;

    CURSOR cur_rowid8 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    employment_id = x_code_id ;

    CURSOR cur_rowid9 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    special_interest_id = x_code_id ;

    CURSOR cur_rowid10 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    housing_id = x_code_id ;

    CURSOR cur_rowid11 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    institution_control_id = x_code_id ;

    CURSOR cur_rowid12 IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    institution_size_id = x_code_id ;

    lv_rowid cur_rowid1%RowType;

  BEGIN

    Open cur_rowid1;
    Fetch cur_rowid1 INTO lv_rowid;
    IF (cur_rowid1%FOUND) THEN
      Close cur_rowid1;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK3');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid1;

    Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK8');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;

    Open cur_rowid3;
    Fetch cur_rowid3 INTO lv_rowid;
    IF (cur_rowid3%FOUND) THEN
      Close cur_rowid3;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK9');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid3;

    Open cur_rowid4;
    Fetch cur_rowid4 INTO lv_rowid;
    IF (cur_rowid4%FOUND) THEN
      Close cur_rowid4;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK4');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid4;

    Open cur_rowid5;
    Fetch cur_rowid5 INTO lv_rowid;
    IF (cur_rowid5%FOUND) THEN
      Close cur_rowid5;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid5;

    Open cur_rowid6;
    Fetch cur_rowid6 INTO lv_rowid;
    IF (cur_rowid6%FOUND) THEN
      Close cur_rowid6;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK10');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid6;

    Open cur_rowid7;
    Fetch cur_rowid7 INTO lv_rowid;
    IF (cur_rowid7%FOUND) THEN
      Close cur_rowid7;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK5');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid7;

    Open cur_rowid8;
    Fetch cur_rowid8 INTO lv_rowid;
    IF (cur_rowid8%FOUND) THEN
      Close cur_rowid8;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK6');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid8;

    Open cur_rowid9;
    Fetch cur_rowid9 INTO lv_rowid;
    IF (cur_rowid9%FOUND) THEN
      Close cur_rowid9;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid9;

    Open cur_rowid10;
    Fetch cur_rowid10 INTO lv_rowid;
    IF (cur_rowid10%FOUND) THEN
      Close cur_rowid10;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK7');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid10;

    Open cur_rowid11;
    Fetch cur_rowid11 INTO lv_rowid;
    IF (cur_rowid11%FOUND) THEN
      Close cur_rowid11;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid11;

    Open cur_rowid12;
    Fetch cur_rowid12 INTO lv_rowid;
    IF (cur_rowid12%FOUND) THEN
      Close cur_rowid12;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_ACDC_FK11');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid12;


  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruitments
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AREC_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,-- DEFAULT NULL,
    x_certainty_of_choice_id IN NUMBER,-- DEFAULT NULL,
    x_religion_cd IN VARCHAR2,-- DEFAULT NULL,
    x_adv_studies_classes IN NUMBER,-- DEFAULT NULL,
    x_honors_classes IN NUMBER ,--DEFAULT NULL,
    x_class_size IN NUMBER ,--DEFAULT NULL,
    x_sec_school_location_id IN NUMBER ,--DEFAULT NULL,
    x_percent_plan_higher_edu IN NUMBER ,--DEFAULT NULL,
    x_recruitment_id IN NUMBER ,--DEFAULT NULL,
    x_person_id IN NUMBER ,--DEFAULT NULL,
    x_special_interest_id IN NUMBER ,--DEFAULT NULL,
    x_priority IN VARCHAR2 ,--DEFAULT NULL,
    x_vip IN VARCHAR2 ,--DEFAULT NULL,
    x_deactivate_recruit_status IN VARCHAR2 ,--DEFAULT NULL,
    x_program_interest_id IN NUMBER ,--DEFAULT NULL,
    x_institution_size_id IN NUMBER ,--DEFAULT NULL,
    x_institution_control_id IN NUMBER ,--DEFAULT NULL,
    x_institution_setting_id IN NUMBER ,--DEFAULT NULL,
    x_institution_location_id IN NUMBER ,--DEFAULT NULL,
    x_special_services_id IN NUMBER ,--DEFAULT NULL,
    x_employment_id IN NUMBER ,--DEFAULT NULL,
    x_housing_id IN NUMBER ,--DEFAULT NULL,
    x_degree_goal_id IN NUMBER,-- DEFAULT NULL,
    x_unit_set_id IN NUMBER,-- DEFAULT NULL,
    x_creation_date IN DATE ,--DEFAULT NULL,
    x_created_by IN NUMBER ,--DEFAULT NULL,
    x_last_update_date IN DATE,-- DEFAULT NULL,
    x_last_updated_by IN NUMBER,-- DEFAULT NULL,
    x_last_update_login IN NUMBER-- DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel       24_JUL-2001       Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
                                 Removed the processing for the Obsolete column 'PROBABILITY'
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_certainty_of_choice_id,
      x_religion_cd,
      x_adv_studies_classes,
      x_honors_classes,
      x_class_size,
      x_sec_school_location_id,
      x_percent_plan_higher_edu,
      x_recruitment_id,
      x_person_id,
      x_special_interest_id,
      x_priority,
      x_vip,
      x_deactivate_recruit_status,
      x_program_interest_id,
      x_institution_size_id,
      x_institution_control_id,
      x_institution_setting_id,
      x_institution_location_id,
      x_special_services_id,
      x_employment_id,
      x_housing_id,
      x_degree_goal_id,
      x_unit_set_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.recruitment_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.recruitment_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  l_rowid:=NULL;
  END After_DML;

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
      X_MODE in VARCHAR2-- default 'R'
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel       24_JUL-2001       Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
                                 Removed the processing for the Obsolete column 'PROBABILITY'
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_RECRUITMENTS
             where                 RECRUITMENT_ID= X_RECRUITMENT_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;

   X_RECRUITMENT_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_certainty_of_choice_id=>X_CERTAINTY_OF_CHOICE_ID,
 	       x_religion_cd=>X_RELIGION_CD,
 	       x_adv_studies_classes=>X_ADV_STUDIES_CLASSES,
 	       x_honors_classes=>X_HONORS_CLASSES,
 	       x_class_size=>X_CLASS_SIZE,
 	       x_sec_school_location_id=>X_SEC_SCHOOL_LOCATION_ID,
 	       x_percent_plan_higher_edu=>X_PERCENT_PLAN_HIGHER_EDU,
 	       x_recruitment_id=>X_RECRUITMENT_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_special_interest_id=>X_SPECIAL_INTEREST_ID,
 	       x_priority=>X_PRIORITY,
 	       x_vip=>X_VIP,
 	       x_deactivate_recruit_status=>X_DEACTIVATE_RECRUIT_STATUS,
 	       x_program_interest_id=>X_PROGRAM_INTEREST_ID,
 	       x_institution_size_id=>X_INSTITUTION_SIZE_ID,
 	       x_institution_control_id=>X_INSTITUTION_CONTROL_ID,
 	       x_institution_setting_id=>X_INSTITUTION_SETTING_ID,
 	       x_institution_location_id=>X_INSTITUTION_LOCATION_ID,
 	       x_special_services_id=>X_SPECIAL_SERVICES_ID,
 	       x_employment_id=>X_EMPLOYMENT_ID,
 	       x_housing_id=>X_HOUSING_ID,
 	       x_degree_goal_id=>X_DEGREE_GOAL_ID,
 	       x_unit_set_id=>X_UNIT_SET_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_AD_RECRUITMENTS (
		CERTAINTY_OF_CHOICE_ID
		,RELIGION_CD
		,ADV_STUDIES_CLASSES
		,HONORS_CLASSES
		,CLASS_SIZE
		,SEC_SCHOOL_LOCATION_ID
		,PERCENT_PLAN_HIGHER_EDU
		,RECRUITMENT_ID
		,PERSON_ID
		,SPECIAL_INTEREST_ID
		,PRIORITY
		,VIP
		,DEACTIVATE_RECRUIT_STATUS
		,PROGRAM_INTEREST_ID
		,INSTITUTION_SIZE_ID
		,INSTITUTION_CONTROL_ID
		,INSTITUTION_SETTING_ID
		,INSTITUTION_LOCATION_ID
		,SPECIAL_SERVICES_ID
		,EMPLOYMENT_ID
		,HOUSING_ID
		,DEGREE_GOAL_ID
		,UNIT_SET_ID
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.CERTAINTY_OF_CHOICE_ID
	        ,NEW_REFERENCES.RELIGION_CD
	        ,NEW_REFERENCES.ADV_STUDIES_CLASSES
	        ,NEW_REFERENCES.HONORS_CLASSES
	        ,NEW_REFERENCES.CLASS_SIZE
	        ,NEW_REFERENCES.SEC_SCHOOL_LOCATION_ID
	        ,NEW_REFERENCES.PERCENT_PLAN_HIGHER_EDU
	        ,IGS_AD_RECRUITMENT_S.NEXTVAL
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.SPECIAL_INTEREST_ID
	        ,NEW_REFERENCES.PRIORITY
	        ,NEW_REFERENCES.VIP
	        ,NEW_REFERENCES.DEACTIVATE_RECRUIT_STATUS
	        ,NEW_REFERENCES.PROGRAM_INTEREST_ID
	        ,NEW_REFERENCES.INSTITUTION_SIZE_ID
	        ,NEW_REFERENCES.INSTITUTION_CONTROL_ID
	        ,NEW_REFERENCES.INSTITUTION_SETTING_ID
	        ,NEW_REFERENCES.INSTITUTION_LOCATION_ID
	        ,NEW_REFERENCES.SPECIAL_SERVICES_ID
	        ,NEW_REFERENCES.EMPLOYMENT_ID
	        ,NEW_REFERENCES.HOUSING_ID
	        ,NEW_REFERENCES.DEGREE_GOAL_ID
	        ,NEW_REFERENCES.UNIT_SET_ID
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN )
RETURNING RECRUITMENT_ID INTO X_RECRUITMENT_ID ;
		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
end INSERT_ROW;
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
       x_UNIT_SET_ID IN NUMBER  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pkpatel       24_JUL-2001       Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
                                  Removed the processing for the Obsolete column 'PROBABILITY'
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      CERTAINTY_OF_CHOICE_ID
,      RELIGION_CD
,      ADV_STUDIES_CLASSES
,      HONORS_CLASSES
,      CLASS_SIZE
,      SEC_SCHOOL_LOCATION_ID
,      PERCENT_PLAN_HIGHER_EDU
,      PERSON_ID
,      SPECIAL_INTEREST_ID
,      PRIORITY
,      VIP
,      DEACTIVATE_RECRUIT_STATUS
,      PROGRAM_INTEREST_ID
,      INSTITUTION_SIZE_ID
,      INSTITUTION_CONTROL_ID
,      INSTITUTION_SETTING_ID
,      INSTITUTION_LOCATION_ID
,      SPECIAL_SERVICES_ID
,      EMPLOYMENT_ID
,      HOUSING_ID
,      DEGREE_GOAL_ID
,      UNIT_SET_ID
    from IGS_AD_RECRUITMENTS
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if ( (  (tlinfo.CERTAINTY_OF_CHOICE_ID = X_CERTAINTY_OF_CHOICE_ID)
 	    OR ((tlinfo.CERTAINTY_OF_CHOICE_ID is null)
		AND (X_CERTAINTY_OF_CHOICE_ID is null)))
  AND ((tlinfo.RELIGION_CD = X_RELIGION_CD)
 	    OR ((tlinfo.RELIGION_CD is null)
		AND (X_RELIGION_CD is null)))
  AND ((tlinfo.ADV_STUDIES_CLASSES = X_ADV_STUDIES_CLASSES)
 	    OR ((tlinfo.ADV_STUDIES_CLASSES is null)
		AND (X_ADV_STUDIES_CLASSES is null)))
  AND ((tlinfo.HONORS_CLASSES = X_HONORS_CLASSES)
 	    OR ((tlinfo.HONORS_CLASSES is null)
		AND (X_HONORS_CLASSES is null)))
  AND ((tlinfo.CLASS_SIZE = X_CLASS_SIZE)
 	    OR ((tlinfo.CLASS_SIZE is null)
		AND (X_CLASS_SIZE is null)))
  AND ((tlinfo.SEC_SCHOOL_LOCATION_ID = X_SEC_SCHOOL_LOCATION_ID)
 	    OR ((tlinfo.SEC_SCHOOL_LOCATION_ID is null)
		AND (X_SEC_SCHOOL_LOCATION_ID is null)))
  AND ((tlinfo.PERCENT_PLAN_HIGHER_EDU = X_PERCENT_PLAN_HIGHER_EDU)
 	    OR ((tlinfo.PERCENT_PLAN_HIGHER_EDU is null)
		AND (X_PERCENT_PLAN_HIGHER_EDU is null)))
  AND (tlinfo.PERSON_ID = X_PERSON_ID)
  AND ((tlinfo.SPECIAL_INTEREST_ID = X_SPECIAL_INTEREST_ID)
 	    OR ((tlinfo.SPECIAL_INTEREST_ID is null)
		AND (X_SPECIAL_INTEREST_ID is null)))
  AND ((tlinfo.PRIORITY = X_PRIORITY)
 	    OR ((tlinfo.PRIORITY is null)
		AND (X_PRIORITY is null)))
  AND ((tlinfo.VIP = X_VIP)
 	    OR ((tlinfo.VIP is null)
		AND (X_VIP is null)))
  AND ((tlinfo.DEACTIVATE_RECRUIT_STATUS = X_DEACTIVATE_RECRUIT_STATUS)
 	    OR ((tlinfo.DEACTIVATE_RECRUIT_STATUS is null)
		AND (X_DEACTIVATE_RECRUIT_STATUS is null)))
  AND ((tlinfo.PROGRAM_INTEREST_ID = X_PROGRAM_INTEREST_ID)
 	    OR ((tlinfo.PROGRAM_INTEREST_ID is null)
		AND (X_PROGRAM_INTEREST_ID is null)))
  AND ((tlinfo.INSTITUTION_SIZE_ID = X_INSTITUTION_SIZE_ID)
 	    OR ((tlinfo.INSTITUTION_SIZE_ID is null)
		AND (X_INSTITUTION_SIZE_ID is null)))
  AND ((tlinfo.INSTITUTION_CONTROL_ID = X_INSTITUTION_CONTROL_ID)
 	    OR ((tlinfo.INSTITUTION_CONTROL_ID is null)
		AND (X_INSTITUTION_CONTROL_ID is null)))
  AND ((tlinfo.INSTITUTION_SETTING_ID = X_INSTITUTION_SETTING_ID)
 	    OR ((tlinfo.INSTITUTION_SETTING_ID is null)
		AND (X_INSTITUTION_SETTING_ID is null)))
  AND ((tlinfo.INSTITUTION_LOCATION_ID = X_INSTITUTION_LOCATION_ID)
 	    OR ((tlinfo.INSTITUTION_LOCATION_ID is null)
		AND (X_INSTITUTION_LOCATION_ID is null)))
  AND ((tlinfo.SPECIAL_SERVICES_ID = X_SPECIAL_SERVICES_ID)
 	    OR ((tlinfo.SPECIAL_SERVICES_ID is null)
		AND (X_SPECIAL_SERVICES_ID is null)))
  AND ((tlinfo.EMPLOYMENT_ID = X_EMPLOYMENT_ID)
 	    OR ((tlinfo.EMPLOYMENT_ID is null)
		AND (X_EMPLOYMENT_ID is null)))
  AND ((tlinfo.HOUSING_ID = X_HOUSING_ID)
 	    OR ((tlinfo.HOUSING_ID is null)
		AND (X_HOUSING_ID is null)))
  AND ((tlinfo.DEGREE_GOAL_ID = X_DEGREE_GOAL_ID)
 	    OR ((tlinfo.DEGREE_GOAL_ID is null)
		AND (X_DEGREE_GOAL_ID is null)))
  AND ((tlinfo.UNIT_SET_ID = X_UNIT_SET_ID)
 	    OR ((tlinfo.UNIT_SET_ID is null)
		AND (X_UNIT_SET_ID is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;
 Procedure UPDATE_ROW (
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
      X_MODE in VARCHAR2 --default 'R'
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel       24_JUL-2001       Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
                                 Removed the processing for the Obsolete column 'PROBABILITY'
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_certainty_of_choice_id=>X_CERTAINTY_OF_CHOICE_ID,
 	       x_religion_cd=>X_RELIGION_CD,
 	       x_adv_studies_classes=>X_ADV_STUDIES_CLASSES,
 	       x_honors_classes=>X_HONORS_CLASSES,
 	       x_class_size=>X_CLASS_SIZE,
 	       x_sec_school_location_id=>X_SEC_SCHOOL_LOCATION_ID,
 	       x_percent_plan_higher_edu=>X_PERCENT_PLAN_HIGHER_EDU,
 	       x_recruitment_id=>X_RECRUITMENT_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_special_interest_id=>X_SPECIAL_INTEREST_ID,
 	       x_priority=>X_PRIORITY,
  	       x_vip=>X_VIP,
 	       x_deactivate_recruit_status=>X_DEACTIVATE_RECRUIT_STATUS,
 	       x_program_interest_id=>X_PROGRAM_INTEREST_ID,
 	       x_institution_size_id=>X_INSTITUTION_SIZE_ID,
 	       x_institution_control_id=>X_INSTITUTION_CONTROL_ID,
 	       x_institution_setting_id=>X_INSTITUTION_SETTING_ID,
 	       x_institution_location_id=>X_INSTITUTION_LOCATION_ID,
 	       x_special_services_id=>X_SPECIAL_SERVICES_ID,
 	       x_employment_id=>X_EMPLOYMENT_ID,
 	       x_housing_id=>X_HOUSING_ID,
 	       x_degree_goal_id=>X_DEGREE_GOAL_ID,
 	       x_unit_set_id=>X_UNIT_SET_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_AD_RECRUITMENTS set
      CERTAINTY_OF_CHOICE_ID =  NEW_REFERENCES.CERTAINTY_OF_CHOICE_ID,
      RELIGION_CD =  NEW_REFERENCES.RELIGION_CD,
      ADV_STUDIES_CLASSES =  NEW_REFERENCES.ADV_STUDIES_CLASSES,
      HONORS_CLASSES =  NEW_REFERENCES.HONORS_CLASSES,
      CLASS_SIZE =  NEW_REFERENCES.CLASS_SIZE,
      SEC_SCHOOL_LOCATION_ID =  NEW_REFERENCES.SEC_SCHOOL_LOCATION_ID,
      PERCENT_PLAN_HIGHER_EDU =  NEW_REFERENCES.PERCENT_PLAN_HIGHER_EDU,
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      SPECIAL_INTEREST_ID =  NEW_REFERENCES.SPECIAL_INTEREST_ID,
      PRIORITY =  NEW_REFERENCES.PRIORITY,
      VIP =  NEW_REFERENCES.VIP,
      DEACTIVATE_RECRUIT_STATUS =  NEW_REFERENCES.DEACTIVATE_RECRUIT_STATUS,
      PROGRAM_INTEREST_ID =  NEW_REFERENCES.PROGRAM_INTEREST_ID,
      INSTITUTION_SIZE_ID =  NEW_REFERENCES.INSTITUTION_SIZE_ID,
      INSTITUTION_CONTROL_ID =  NEW_REFERENCES.INSTITUTION_CONTROL_ID,
      INSTITUTION_SETTING_ID =  NEW_REFERENCES.INSTITUTION_SETTING_ID,
      INSTITUTION_LOCATION_ID =  NEW_REFERENCES.INSTITUTION_LOCATION_ID,
      SPECIAL_SERVICES_ID =  NEW_REFERENCES.SPECIAL_SERVICES_ID,
      EMPLOYMENT_ID =  NEW_REFERENCES.EMPLOYMENT_ID,
      HOUSING_ID =  NEW_REFERENCES.HOUSING_ID,
      DEGREE_GOAL_ID =  NEW_REFERENCES.DEGREE_GOAL_ID,
      UNIT_SET_ID =  NEW_REFERENCES.UNIT_SET_ID,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
	  where ROWID = X_ROWID;
	if (sql%notfound) then
		raise no_data_found;
	end if;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
end UPDATE_ROW;
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
      X_MODE in VARCHAR2 --default 'R'
  ) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel       24_JUL-2001       Bug no.1890270 Admissions Standards and Rules Dld_adsr_setup
                                 Removed the processing for the Obsolete column 'PROBABILITY'

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_RECRUITMENTS
             where     RECRUITMENT_ID= X_RECRUITMENT_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_CERTAINTY_OF_CHOICE_ID,
       X_RELIGION_CD,
       X_ADV_STUDIES_CLASSES,
       X_HONORS_CLASSES,
       X_CLASS_SIZE,
       X_SEC_SCHOOL_LOCATION_ID,
       X_PERCENT_PLAN_HIGHER_EDU,
       X_RECRUITMENT_ID,
       X_PERSON_ID,
       X_SPECIAL_INTEREST_ID,
       X_PRIORITY,
       X_VIP,
       X_DEACTIVATE_RECRUIT_STATUS,
       X_PROGRAM_INTEREST_ID,
       X_INSTITUTION_SIZE_ID,
       X_INSTITUTION_CONTROL_ID,
       X_INSTITUTION_SETTING_ID,
       X_INSTITUTION_LOCATION_ID,
       X_SPECIAL_SERVICES_ID,
       X_EMPLOYMENT_ID,
       X_HOUSING_ID,
       X_DEGREE_GOAL_ID,
       X_UNIT_SET_ID,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_CERTAINTY_OF_CHOICE_ID,
       X_RELIGION_CD,
       X_ADV_STUDIES_CLASSES,
       X_HONORS_CLASSES,
       X_CLASS_SIZE,
       X_SEC_SCHOOL_LOCATION_ID,
       X_PERCENT_PLAN_HIGHER_EDU,
       X_RECRUITMENT_ID,
       X_PERSON_ID,
       X_SPECIAL_INTEREST_ID,
       X_PRIORITY,
       X_VIP,
       X_DEACTIVATE_RECRUIT_STATUS,
       X_PROGRAM_INTEREST_ID,
       X_INSTITUTION_SIZE_ID,
       X_INSTITUTION_CONTROL_ID,
       X_INSTITUTION_SETTING_ID,
       X_INSTITUTION_LOCATION_ID,
       X_SPECIAL_SERVICES_ID,
       X_EMPLOYMENT_ID,
       X_HOUSING_ID,
       X_DEGREE_GOAL_ID,
       X_UNIT_SET_ID,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : samaresh
  Date Created By : 15-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_AD_RECRUITMENTS
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_recruitments_pkg;

/
