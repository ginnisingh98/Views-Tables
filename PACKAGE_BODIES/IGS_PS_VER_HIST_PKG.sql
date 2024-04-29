--------------------------------------------------------
--  DDL for Package Body IGS_PS_VER_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VER_HIST_PKG" AS
 /* $Header: IGSPI43B.pls 120.0 2005/06/01 16:14:29 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_VER_HIST_ALL%RowType;
  new_references IGS_PS_VER_HIST_ALL%RowType;

  PROCEDURE set_column_values (
    p_action                            IN VARCHAR2,
    x_rowid                             IN VARCHAR2 ,
    x_course_cd                         IN VARCHAR2 ,
    x_version_number                    IN NUMBER ,
    x_hist_start_dt                     IN DATE ,
    x_hist_end_dt                       IN DATE ,
    x_hist_who                          IN NUMBER ,
    x_start_dt                          IN DATE ,
    x_review_dt                         IN DATE ,
    x_expiry_dt                         IN DATE ,
    x_end_dt                            IN DATE ,
    x_course_status                     IN VARCHAR2 ,
    x_title                             IN VARCHAR2 ,
    x_short_title                       IN VARCHAR2 ,
    x_abbreviation                      IN VARCHAR2 ,
    x_supp_exam_permitted_ind           IN VARCHAR2 ,
    x_generic_course_ind                IN VARCHAR2 ,
    x_graduate_students_ind             IN VARCHAR2 ,
    x_count_intrmsn_in_time_ind         IN VARCHAR2 ,
    x_intrmsn_allowed_ind               IN VARCHAR2 ,
    x_course_type                       IN VARCHAR2 ,
    x_ct_description                    IN VARCHAR2 ,
    x_responsible_org_unit_cd           IN VARCHAR2 ,
    x_responsible_ou_start_dt           IN DATE ,
    x_ou_description                    IN VARCHAR2 ,
    x_govt_special_course_type          IN VARCHAR2 ,
    x_gsct_description                  IN VARCHAR2 ,
    x_qualification_recency             IN NUMBER ,
    x_external_adv_stnd_limit           IN NUMBER ,
    x_internal_adv_stnd_limit           IN NUMBER ,
    x_contact_hours                     IN NUMBER ,
    x_credit_points_required            IN NUMBER ,
    x_govt_course_load                  IN NUMBER ,
    x_std_annual_load                   IN NUMBER ,
    x_course_total_eftsu                IN NUMBER ,
    x_max_intrmsn_duration              IN NUMBER ,
    x_num_of_units_before_intrmsn       IN NUMBER ,
    x_min_sbmsn_percentage              IN NUMBER ,
    x_min_cp_per_calendar               IN NUMBER ,
    x_approval_date                     IN DATE  ,
    x_external_approval_date            IN DATE  ,
    x_federal_financial_aid             IN VARCHAR2  ,
    x_institutional_financial_aid       IN VARCHAR2  ,
    x_max_cp_per_teaching_period        IN NUMBER  ,
    x_residency_cp_required             IN NUMBER  ,
    x_state_financial_aid               IN VARCHAR2  ,
    x_primary_program_rank              IN NUMBER ,
    x_max_wlst_per_stud                 IN NUMBER,
    x_creation_date                     IN DATE ,
    x_created_by                        IN NUMBER ,
    x_last_update_date                  IN DATE ,
    x_last_updated_by                   IN NUMBER ,
    x_last_update_login                 IN NUMBER ,
    x_org_id                            IN NUMBER     ,
    x_annual_instruction_time           IN NUMBER
  ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    19_oct-2002   Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time
  ||                            as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22
  ||                            warning.
  ----------------------------------------------------------------------------*/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_VER_HIST_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.start_dt := x_start_dt;
    new_references.review_dt := x_review_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.end_dt := x_end_dt;
    new_references.course_status := x_course_status;
    new_references.title := x_title;
    new_references.short_title := x_short_title;
    new_references.abbreviation := x_abbreviation;
    new_references.supp_exam_permitted_ind := x_supp_exam_permitted_ind;
    new_references.generic_course_ind := x_generic_course_ind;
    new_references.graduate_students_ind := x_graduate_students_ind;
    new_references.count_intrmsn_in_time_ind := x_count_intrmsn_in_time_ind;
    new_references.intrmsn_allowed_ind := x_intrmsn_allowed_ind;
    new_references.course_type := x_course_type;
    new_references.ct_description := x_ct_description;
    new_references.responsible_org_unit_cd := x_responsible_org_unit_cd;
    new_references.responsible_ou_start_dt := x_responsible_ou_start_dt;
    new_references.ou_description := x_ou_description;
    new_references.govt_special_course_type := x_govt_special_course_type;
    new_references.gsct_description := x_gsct_description;
    new_references.qualification_recency := x_qualification_recency;
    new_references.external_adv_stnd_limit := x_external_adv_stnd_limit;
    new_references.internal_adv_stnd_limit := x_internal_adv_stnd_limit;
    new_references.contact_hours := x_contact_hours;
    new_references.credit_points_required := x_credit_points_required;
    new_references.govt_course_load := x_govt_course_load;
    new_references.std_annual_load := x_std_annual_load;
    new_references.course_total_eftsu := x_course_total_eftsu;
    new_references.max_intrmsn_duration := x_max_intrmsn_duration;
    new_references.num_of_units_before_intrmsn := x_num_of_units_before_intrmsn;
    new_references.min_sbmsn_percentage := x_min_sbmsn_percentage;
    new_references.min_cp_per_calendar :=  x_min_cp_per_calendar;
    new_references.approval_date   := x_approval_date;
    new_references.external_approval_date := x_external_approval_date;
    new_references.federal_financial_aid  := x_federal_financial_aid;
    new_references.institutional_financial_aid := x_institutional_financial_aid;
    new_references.max_cp_per_teaching_period := x_max_cp_per_teaching_period;
    new_references.residency_cp_required  := x_residency_cp_required;
    new_references.state_financial_aid := x_state_financial_aid;
    new_references.primary_program_rank := x_primary_program_rank;
    new_references.max_wlst_per_stud := x_max_wlst_per_stud;
    new_references.annual_instruction_time := x_annual_instruction_time;
    new_references.org_id:=x_org_id;
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

  END set_column_values;

  PROCEDURE check_constraints (
	column_name IN VARCHAR2 ,
	column_value IN VARCHAR2
  ) IS
  BEGIN
	IF column_name is NULL THEN
	   NULL;
	ELSIF upper(column_name) = 'GENERIC_COURSE_IND' THEN
	   new_references.generic_course_ind := column_value;
	ELSIF upper(column_name) = 'EXTERNAL_ADV_STND_LIMIT' THEN
	   new_references.external_adv_stnd_limit := igs_ge_number.to_num(column_value);
	ELSIF upper(column_name) = 'STD_ANNUAL_LOAD' THEN
	   new_references.std_annual_load := igs_ge_number.to_num(column_value);
	ELSIF upper(column_name) = 'INTERNAL_ADV_STND_LIMIT' THEN
	   new_references.internal_adv_stnd_limit := igs_ge_number.to_num(column_value);
	ELSIF upper(column_name) = 'INTRMSN_ALLOWED_IND' THEN
	   new_references.intrmsn_allowed_ind := column_value;
	ELSIF upper(column_name) = 'GRADUATE_STUDENTS_IND' THEN
	   new_references.graduate_students_ind:= column_value;
	ELSIF upper(column_name) = 'ABBREVIATION' THEN
	   new_references.abbreviation := column_value;
        ELSIF upper(column_name) = 'COUNT_INTRMSN_IN_TIME_IND' THEN
	   new_references.count_intrmsn_in_time_ind := column_value;
	ELSIF upper(column_name) = 'COURSE_CD' THEN
	   new_references.course_cd := column_value;
	ELSIF upper(column_name) = 'COURSE_STATUS' THEN
	   new_references.course_status := column_value;
	ELSIF upper(column_name) = 'COURSE_TYPE' THEN
 		new_references.course_type := column_value;
	ELSIF upper(column_name) = 'GOVT_SPECIAL_COURSE_TYPE' THEN
	   new_references.govt_special_course_type := column_value;
	ELSIF upper(column_name) = 'SUPP_EXAM_PERMITTED_IND' THEN
	   new_references.supp_exam_permitted_ind := column_value;
        ELSIF UPPER(column_name) = 'MAX_WLST_PER_STUD' THEN
	   new_references.max_wlst_per_stud  := column_value;
        ELSIF UPPER(column_name) = 'ANNUAL_INSTRUCTION_TIME' THEN
	   new_references.annual_instruction_time  := column_value;
	END IF;
	IF upper(column_name)= 'GENERIC_COURSE_IND' OR
		column_name is null THEN
		IF new_references.generic_course_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'COUNT_INTRMSN_IN_TIME_IND' OR
		column_name is null THEN
		IF new_references.count_intrmsn_in_time_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'EXTERNAL_ADV_STND_LIMIT' OR
		column_name is null THEN
		IF new_references.external_adv_stnd_limit < 0 OR
		 new_references.external_adv_stnd_limit > 9999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'STD_ANNUAL_LOAD' OR
		column_name is null THEN
		IF new_references.std_annual_load < 0 OR
		 new_references.std_annual_load > 9999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'INTERNAL_ADV_STND_LIMIT' OR
		column_name is null THEN
		IF new_references.internal_adv_stnd_limit < 0 OR
		 new_references.internal_adv_stnd_limit > 9999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'INTRMSN_ALLOWED_IND' OR
		column_name is null THEN
		IF new_references.intrmsn_allowed_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'GRADUATE_STUDENTS_IND' OR
		column_name is null THEN
		IF new_references.graduate_students_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'ABBREVIATION' OR
		column_name is null THEN
		IF new_references.abbreviation<> UPPER(new_references.abbreviation)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_CD' OR
		column_name is null THEN
		IF new_references.course_cd <> UPPER(new_references.course_cd )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_STATUS' OR
		column_name is null THEN
		IF new_references.course_status <> UPPER(new_references.course_status)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_TYPE' OR
		column_name is null THEN
		IF new_references.course_type <> UPPER(new_references.course_type)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'GOVT_SPECIAL_COURSE_TYPE' OR
		column_name is null THEN
		IF new_references.govt_special_course_type <> UPPER(new_references.govt_special_course_type )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'SUPP_EXAM_PERMITTED_IND' OR
		column_name is null THEN
		IF new_references.supp_exam_permitted_ind <> UPPER(new_references.supp_exam_permitted_ind )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'MAX_WLST_PER_STUD' OR column_name is null THEN
           IF new_references.max_wlst_per_stud < 0 OR
              new_references.max_wlst_per_stud > 9999 THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
           END IF;
	END IF;

	IF upper(column_name)= 'ANNUAL_INSTRUCTION_TIME' OR column_name is null THEN
           IF new_references.annual_instruction_time < 1 OR
              new_references.annual_instruction_time > 99.99 THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
           END IF;
	END IF;


  END check_constraints;

  FUNCTION get_pk_for_validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_VER_HIST_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
	IF (cur_rowid%FOUND) THEN
		Close cur_rowid;
		Return(TRUE);
	ELSE
		Close cur_rowid;
		Return(FALSE);
	END IF;

  END get_pk_for_validation;

  PROCEDURE before_dml (
    p_action                            IN VARCHAR2,
    x_rowid                             IN VARCHAR2 ,
    x_course_cd                         IN VARCHAR2 ,
    x_version_number                    IN NUMBER ,
    x_hist_start_dt                     IN DATE ,
    x_hist_end_dt                       IN DATE ,
    x_hist_who                          IN NUMBER ,
    x_start_dt                          IN DATE ,
    x_review_dt                         IN DATE ,
    x_expiry_dt                         IN DATE ,
    x_end_dt                            IN DATE ,
    x_course_status                     IN VARCHAR2 ,
    x_title                             IN VARCHAR2 ,
    x_short_title                       IN VARCHAR2 ,
    x_abbreviation                      IN VARCHAR2 ,
    x_supp_exam_permitted_ind           IN VARCHAR2 ,
    x_generic_course_ind                IN VARCHAR2 ,
    x_graduate_students_ind             IN VARCHAR2 ,
    x_count_intrmsn_in_time_ind         IN VARCHAR2 ,
    x_intrmsn_allowed_ind               IN VARCHAR2 ,
    x_course_type                       IN VARCHAR2 ,
    x_ct_description                    IN VARCHAR2 ,
    x_responsible_org_unit_cd           IN VARCHAR2 ,
    x_responsible_ou_start_dt           IN DATE ,
    x_ou_description                    IN VARCHAR2 ,
    x_govt_special_course_type          IN VARCHAR2 ,
    x_gsct_description                  IN VARCHAR2 ,
    x_qualification_recency             IN NUMBER ,
    x_external_adv_stnd_limit           IN NUMBER ,
    x_internal_adv_stnd_limit           IN NUMBER ,
    x_contact_hours                     IN NUMBER ,
    x_credit_points_required            IN NUMBER ,
    x_govt_course_load                  IN NUMBER ,
    x_std_annual_load                   IN NUMBER ,
    x_course_total_eftsu                IN NUMBER ,
    x_max_intrmsn_duration              IN NUMBER ,
    x_num_of_units_before_intrmsn       IN NUMBER ,
    x_min_sbmsn_percentage              IN NUMBER ,
    x_min_cp_per_calendar               IN NUMBER ,
    x_approval_date                     IN DATE  ,
    x_external_approval_date            IN DATE  ,
    x_federal_financial_aid             IN VARCHAR2  ,
    x_institutional_financial_aid       IN VARCHAR2  ,
    x_max_cp_per_teaching_period        IN NUMBER  ,
    x_residency_cp_required             IN NUMBER  ,
    x_state_financial_aid               IN VARCHAR2  ,
    x_primary_program_rank              IN NUMBER  ,
    x_max_wlst_per_stud                 IN NUMBER,
    x_creation_date                     IN DATE ,
    x_created_by                        IN NUMBER ,
    x_last_update_date                  IN DATE ,
    x_last_updated_by                   IN NUMBER ,
    x_last_update_login                 IN NUMBER ,
    x_org_id                            IN NUMBER ,
    x_annual_instruction_time           IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    19_oct-2002  Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time
  ||                           as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22
  ||                           warnings.
  ----------------------------------------------------------------------------*/
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_course_cd,
      x_version_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_start_dt,
      x_review_dt,
      x_expiry_dt,
      x_end_dt,
      x_course_status,
      x_title,
      x_short_title,
      x_abbreviation,
      x_supp_exam_permitted_ind,
      x_generic_course_ind,
      x_graduate_students_ind,
      x_count_intrmsn_in_time_ind,
      x_intrmsn_allowed_ind,
      x_course_type,
      x_ct_description,
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_ou_description,
      x_govt_special_course_type,
      x_gsct_description,
      x_qualification_recency,
      x_external_adv_stnd_limit,
      x_internal_adv_stnd_limit,
      x_contact_hours,
      x_credit_points_required,
      x_govt_course_load,
      x_std_annual_load,
      x_course_total_eftsu,
      x_max_intrmsn_duration,
      x_num_of_units_before_intrmsn,
      x_min_sbmsn_percentage,
      x_min_cp_per_calendar ,
      x_approval_date ,
      x_external_approval_date ,
      x_federal_financial_aid,
      x_institutional_financial_aid,
      x_max_cp_per_teaching_period ,
      x_residency_cp_required ,
      x_state_financial_aid ,
      x_primary_program_rank,
      x_max_wlst_per_stud,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_annual_instruction_time
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

           	IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.version_number,
		new_references.hist_start_dt
   	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

	Check_Constraints;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.version_number,
		new_references.hist_start_dt
   	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
     	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     	Check_Constraints;

    END IF;
  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END after_dml;

PROCEDURE insert_row (
  x_rowid                             IN OUT NOCOPY VARCHAR2,
  x_course_cd                         IN VARCHAR2,
  x_version_number                    IN NUMBER,
  x_hist_start_dt                     IN DATE,
  x_hist_end_dt                       IN DATE,
  x_hist_who                          IN NUMBER,
  x_start_dt                          IN DATE,
  x_review_dt                         IN DATE,
  x_expiry_dt                         IN DATE,
  x_end_dt                            IN DATE,
  x_course_status                     IN VARCHAR2,
  x_title                             IN VARCHAR2,
  x_short_title                       IN VARCHAR2,
  x_abbreviation                      IN VARCHAR2,
  x_supp_exam_permitted_ind           IN VARCHAR2,
  x_generic_course_ind                IN VARCHAR2,
  x_graduate_students_ind             IN VARCHAR2,
  x_count_intrmsn_in_time_ind         IN VARCHAR2,
  x_intrmsn_allowed_ind               IN VARCHAR2,
  x_course_type                       IN VARCHAR2,
  x_ct_description                    IN VARCHAR2,
  x_responsible_org_unit_cd           IN VARCHAR2,
  x_responsible_ou_start_dt           IN DATE,
  x_ou_description                    IN VARCHAR2,
  x_govt_special_course_type          IN VARCHAR2,
  x_gsct_description                  IN VARCHAR2,
  x_qualification_recency             IN NUMBER,
  x_external_adv_stnd_limit           IN NUMBER,
  x_internal_adv_stnd_limit           IN NUMBER,
  x_contact_hours                     IN NUMBER,
  x_credit_points_required            IN NUMBER,
  x_govt_course_load                  IN NUMBER,
  x_std_annual_load                   IN NUMBER,
  x_course_total_eftsu                IN NUMBER,
  x_max_intrmsn_duration              IN NUMBER,
  x_num_of_units_before_intrmsn       IN NUMBER,
  x_min_sbmsn_percentage              IN NUMBER,
  x_min_cp_per_calendar               IN NUMBER ,
  x_approval_date                     IN DATE  ,
  x_external_approval_date            IN DATE  ,
  x_federal_financial_aid             IN VARCHAR2  ,
  x_institutional_financial_aid       IN VARCHAR2  ,
  x_max_cp_per_teaching_period        IN NUMBER  ,
  x_residency_cp_required             IN NUMBER  ,
  x_state_financial_aid               IN VARCHAR2  ,
  x_primary_program_rank              IN NUMBER  ,
  x_max_wlst_per_stud                 IN NUMBER,
  x_mode                              IN VARCHAR2,
  x_org_id                            IN NUMBER,
  x_annual_instruction_time           IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    19_oct-2002  Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time
  ||                           as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22
  ||                           warnings.
  ----------------------------------------------------------------------------*/
    CURSOR C IS SELECT ROWID FROM IGS_PS_VER_HIST_ALL
      WHERE COURSE_CD = X_COURSE_CD
      AND VERSION_NUMBER = X_VERSION_NUMBER
      AND HIST_START_DT = X_HIST_START_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
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
     before_dml( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_start_dt => X_START_DT,
    x_review_dt => X_REVIEW_DT,
    x_expiry_dt => X_EXPIRY_DT,
    x_end_dt => X_END_DT,
    x_course_status => X_COURSE_STATUS,
    x_title => X_TITLE,
    x_short_title => X_SHORT_TITLE,
    x_abbreviation => X_ABBREVIATION,
    x_supp_exam_permitted_ind => X_SUPP_EXAM_PERMITTED_IND,
    x_generic_course_ind => NVL(X_GENERIC_COURSE_IND,'N'),
    x_graduate_students_ind => NVL(X_GRADUATE_STUDENTS_IND,'Y'),
    x_count_intrmsn_in_time_ind => X_COUNT_INTRMSN_IN_TIME_IND,
    x_intrmsn_allowed_ind => X_INTRMSN_ALLOWED_IND,
    x_course_type => X_COURSE_TYPE,
    x_ct_description => X_CT_DESCRIPTION,
    x_responsible_org_unit_cd => X_RESPONSIBLE_ORG_UNIT_CD,
    x_responsible_ou_start_dt => X_RESPONSIBLE_OU_START_DT,
    x_ou_description => X_OU_DESCRIPTION,
    x_govt_special_course_type => X_GOVT_SPECIAL_COURSE_TYPE,
    x_gsct_description =>X_GSCT_DESCRIPTION,
    x_qualification_recency => X_QUALIFICATION_RECENCY,
    x_external_adv_stnd_limit => X_EXTERNAL_ADV_STND_LIMIT,
    x_internal_adv_stnd_limit => X_INTERNAL_ADV_STND_LIMIT,
    x_contact_hours => X_CONTACT_HOURS,
    x_credit_points_required => X_CREDIT_POINTS_REQUIRED,
    x_govt_course_load => X_GOVT_COURSE_LOAD,
    x_std_annual_load => X_STD_ANNUAL_LOAD,
    x_course_total_eftsu => X_COURSE_TOTAL_EFTSU,
    x_max_intrmsn_duration => X_MAX_INTRMSN_DURATION,
    x_num_of_units_before_intrmsn => X_NUM_OF_UNITS_BEFORE_INTRMSN,
    x_min_sbmsn_percentage => X_MIN_SBMSN_PERCENTAGE,
    x_min_cp_per_calendar => X_MIN_CP_PER_CALENDAR,
    x_approval_date  => X_APPROVAL_DATE,
    x_external_approval_date => X_EXTERNAL_APPROVAL_DATE,
    x_federal_financial_aid => X_FEDERAL_FINANCIAL_AID,
    x_institutional_financial_aid => X_INSTITUTIONAL_FINANCIAL_AID,
    x_max_cp_per_teaching_period =>X_MAX_CP_PER_TEACHING_PERIOD,
    x_residency_cp_required =>X_RESIDENCY_CP_REQUIRED,
    x_state_financial_aid =>X_STATE_FINANCIAL_AID,
    x_primary_program_rank =>X_PRIMARY_PROGRAM_RANK,
    x_max_wlst_per_stud => x_max_wlst_per_stud,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_annual_instruction_time => x_annual_instruction_time
  );

  INSERT INTO IGS_PS_VER_HIST_ALL (
    course_cd,
    version_number,
    hist_start_dt,
    hist_end_dt,
    hist_who,
    start_dt,
    review_dt,
    expiry_dt,
    end_dt,
    course_status,
    title,
    short_title,
    abbreviation,
    supp_exam_permitted_ind,
    generic_course_ind,
    graduate_students_ind,
    count_intrmsn_in_time_ind,
    intrmsn_allowed_ind,
    course_type,
    ct_description,
    responsible_org_unit_cd,
    responsible_ou_start_dt,
    ou_description,
    govt_special_course_type,
    gsct_description,
    qualification_recency,
    external_adv_stnd_limit,
    internal_adv_stnd_limit,
    contact_hours,
    credit_points_required,
    govt_course_load,
    std_annual_load,
    course_total_eftsu,
    max_intrmsn_duration,
    num_of_units_before_intrmsn,
    min_sbmsn_percentage,
    min_cp_per_calendar,
    approval_date,
    external_approval_date,
    federal_financial_aid,
    institutional_financial_aid,
    max_cp_per_teaching_period,
    residency_cp_required,
    state_financial_aid,
    primary_program_rank,
    max_wlst_per_stud,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    org_id,
    annual_instruction_time
  ) values (
    new_references.course_cd,
    new_references.version_number,
    new_references.hist_start_dt,
    new_references.hist_end_dt,
    new_references.hist_who,
    new_references.start_dt,
    new_references.review_dt,
    new_references.expiry_dt,
    new_references.end_dt,
    new_references.course_status,
    new_references.title,
    new_references.short_title,
    new_references.abbreviation,
    new_references.supp_exam_permitted_ind,
    new_references.generic_course_ind,
    new_references.graduate_students_ind,
    new_references.count_intrmsn_in_time_ind,
    new_references.intrmsn_allowed_ind,
    new_references.course_type,
    new_references.ct_description,
    new_references.responsible_org_unit_cd,
    new_references.responsible_ou_start_dt,
    new_references.ou_description,
    new_references.govt_special_course_type,
    new_references.gsct_description,
    new_references.qualification_recency,
    new_references.external_adv_stnd_limit,
    new_references.internal_adv_stnd_limit,
    new_references.contact_hours,
    new_references.credit_points_required,
    new_references.govt_course_load,
    new_references.std_annual_load,
    new_references.course_total_eftsu,
    new_references.max_intrmsn_duration,
    new_references.num_of_units_before_intrmsn,
    new_references.min_sbmsn_percentage,
    new_references.min_cp_per_calendar,
    new_references.approval_date,
    new_references.external_approval_date,
    new_references.federal_financial_aid,
    new_references.institutional_financial_aid,
    new_references.max_cp_per_teaching_period,
    new_references.residency_cp_required,
    new_references.state_financial_aid,
    new_references.primary_program_rank,
    new_references.max_wlst_per_stud,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    new_references.org_id,
    new_references.annual_instruction_time
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%notfound) THEN
    close c;
    raise no_data_found;
  END IF;
  CLOSE c;
 after_dml(
  p_action => 'INSERT',
  x_rowid => x_rowid
  );

END insert_row;

PROCEDURE lock_row (
  x_rowid                             IN VARCHAR2,
  x_course_cd                         IN VARCHAR2,
  x_version_number                    IN NUMBER,
  x_hist_start_dt                     IN DATE,
  x_hist_end_dt                       IN DATE,
  x_hist_who                          IN NUMBER,
  x_start_dt                          IN DATE,
  x_review_dt                         IN DATE,
  x_expiry_dt                         IN DATE,
  x_end_dt                            IN DATE,
  x_course_status                     IN VARCHAR2,
  x_title                             IN VARCHAR2,
  x_short_title                       IN VARCHAR2,
  x_abbreviation                      IN VARCHAR2,
  x_supp_exam_permitted_ind           IN VARCHAR2,
  x_generic_course_ind                IN VARCHAR2,
  x_graduate_students_ind             IN VARCHAR2,
  x_count_intrmsn_in_time_ind         IN VARCHAR2,
  x_intrmsn_allowed_ind               IN VARCHAR2,
  x_course_type                       IN VARCHAR2,
  x_ct_description                    IN VARCHAR2,
  x_responsible_org_unit_cd           IN VARCHAR2,
  x_responsible_ou_start_dt           IN DATE,
  x_ou_description                    IN VARCHAR2,
  x_govt_special_course_type          IN VARCHAR2,
  x_gsct_description                  IN VARCHAR2,
  x_qualification_recency             IN NUMBER,
  x_external_adv_stnd_limit           IN NUMBER,
  x_internal_adv_stnd_limit           IN NUMBER,
  x_contact_hours                     IN NUMBER,
  x_credit_points_required            IN NUMBER,
  x_govt_course_load                  IN NUMBER,
  x_std_annual_load                   IN NUMBER,
  x_course_total_eftsu                IN NUMBER,
  x_max_intrmsn_duration              IN NUMBER,
  x_num_of_units_before_intrmsn       IN NUMBER,
  x_min_sbmsn_percentage              IN NUMBER,
  x_min_cp_per_calendar               IN NUMBER ,
  x_approval_date                     IN DATE  ,
  x_external_approval_date            IN DATE  ,
  x_federal_financial_aid             IN VARCHAR2  ,
  x_institutional_financial_aid       IN VARCHAR2  ,
  x_max_cp_per_teaching_period        IN NUMBER  ,
  x_residency_cp_required             IN NUMBER  ,
  x_state_financial_aid               IN VARCHAR2   ,
  x_primary_program_rank              IN NUMBER,
  x_max_wlst_per_stud                 IN NUMBER,
  x_annual_instruction_time           IN NUMBER
  )AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    19_oct-2002  Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time
  ||                           as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22
  ||                           warnings.
  ----------------------------------------------------------------------------*/
  CURSOR c1 IS SELECT
      hist_end_dt,
      hist_who,
      start_dt,
      review_dt,
      expiry_dt,
      end_dt,
      course_status,
      title,
      short_title,
      abbreviation,
      supp_exam_permitted_ind,
      generic_course_ind,
      graduate_students_ind,
      count_intrmsn_in_time_ind,
      intrmsn_allowed_ind,
      course_type,
      ct_description,
      responsible_org_unit_cd,
      responsible_ou_start_dt,
      ou_description,
      govt_special_course_type,
      gsct_description,
      qualification_recency,
      external_adv_stnd_limit,
      internal_adv_stnd_limit,
      contact_hours,
      credit_points_required,
      govt_course_load,
      std_annual_load,
      course_total_eftsu,
      max_intrmsn_duration,
      num_of_units_before_intrmsn,
      min_sbmsn_percentage,
      min_cp_per_calendar,
      approval_date ,
      external_approval_date  ,
      federal_financial_aid ,
      institutional_financial_aid ,
      max_cp_per_teaching_period,
      residency_cp_required ,
      state_financial_aid,
      primary_program_rank,
      max_wlst_per_stud,
      annual_instruction_time
    FROM IGS_PS_VER_HIST_ALL
    WHERE ROWID = X_ROWID FOR UPDATE NOWAIT;
  tlinfo c1%rowtype;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%notfound) THEN
    CLOSE c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;

  IF ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.START_DT = X_START_DT)
           OR ((tlinfo.START_DT is null)
               AND (X_START_DT is null)))
      AND ((tlinfo.REVIEW_DT = X_REVIEW_DT)
           OR ((tlinfo.REVIEW_DT is null)
               AND (X_REVIEW_DT is null)))
      AND ((tlinfo.EXPIRY_DT = X_EXPIRY_DT)
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((tlinfo.END_DT = X_END_DT)
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND ((tlinfo.COURSE_STATUS = X_COURSE_STATUS)
           OR ((tlinfo.COURSE_STATUS is null)
               AND (X_COURSE_STATUS is null)))
      AND ((tlinfo.TITLE = X_TITLE)
           OR ((tlinfo.TITLE is null)
               AND (X_TITLE is null)))
      AND ((tlinfo.SHORT_TITLE = X_SHORT_TITLE)
           OR ((tlinfo.SHORT_TITLE is null)
               AND (X_SHORT_TITLE is null)))
      AND ((tlinfo.ABBREVIATION = X_ABBREVIATION)
           OR ((tlinfo.ABBREVIATION is null)
               AND (X_ABBREVIATION is null)))
      AND ((tlinfo.SUPP_EXAM_PERMITTED_IND = X_SUPP_EXAM_PERMITTED_IND)
           OR ((tlinfo.SUPP_EXAM_PERMITTED_IND is null)
               AND (X_SUPP_EXAM_PERMITTED_IND is null)))
      AND ((tlinfo.GENERIC_COURSE_IND = X_GENERIC_COURSE_IND)
           OR ((tlinfo.GENERIC_COURSE_IND is null)
               AND (X_GENERIC_COURSE_IND is null)))
      AND ((tlinfo.GRADUATE_STUDENTS_IND = X_GRADUATE_STUDENTS_IND)
           OR ((tlinfo.GRADUATE_STUDENTS_IND is null)
               AND (X_GRADUATE_STUDENTS_IND is null)))
      AND ((tlinfo.COUNT_INTRMSN_IN_TIME_IND = X_COUNT_INTRMSN_IN_TIME_IND)
           OR ((tlinfo.COUNT_INTRMSN_IN_TIME_IND is null)
               AND (X_COUNT_INTRMSN_IN_TIME_IND is null)))
      AND ((tlinfo.INTRMSN_ALLOWED_IND = X_INTRMSN_ALLOWED_IND)
           OR ((tlinfo.INTRMSN_ALLOWED_IND is null)
               AND (X_INTRMSN_ALLOWED_IND is null)))
      AND ((tlinfo.COURSE_TYPE = X_COURSE_TYPE)
           OR ((tlinfo.COURSE_TYPE is null)
               AND (X_COURSE_TYPE is null)))
      AND ((tlinfo.CT_DESCRIPTION = X_CT_DESCRIPTION)
           OR ((tlinfo.CT_DESCRIPTION is null)
               AND (X_CT_DESCRIPTION is null)))
      AND ((tlinfo.RESPONSIBLE_ORG_UNIT_CD = X_RESPONSIBLE_ORG_UNIT_CD)
           OR ((tlinfo.RESPONSIBLE_ORG_UNIT_CD is null)
               AND (X_RESPONSIBLE_ORG_UNIT_CD is null)))
      AND ((tlinfo.RESPONSIBLE_OU_START_DT = X_RESPONSIBLE_OU_START_DT)
           OR ((tlinfo.RESPONSIBLE_OU_START_DT is null)
               AND (X_RESPONSIBLE_OU_START_DT is null)))
      AND ((tlinfo.OU_DESCRIPTION = X_OU_DESCRIPTION)
           OR ((tlinfo.OU_DESCRIPTION is null)
               AND (X_OU_DESCRIPTION is null)))
      AND ((tlinfo.GOVT_SPECIAL_COURSE_TYPE = X_GOVT_SPECIAL_COURSE_TYPE)
           OR ((tlinfo.GOVT_SPECIAL_COURSE_TYPE is null)
               AND (X_GOVT_SPECIAL_COURSE_TYPE is null)))
      AND ((tlinfo.GSCT_DESCRIPTION = X_GSCT_DESCRIPTION)
           OR ((tlinfo.GSCT_DESCRIPTION is null)
               AND (X_GSCT_DESCRIPTION is null)))
      AND ((tlinfo.QUALIFICATION_RECENCY = X_QUALIFICATION_RECENCY)
           OR ((tlinfo.QUALIFICATION_RECENCY is null)
               AND (X_QUALIFICATION_RECENCY is null)))
      AND ((tlinfo.EXTERNAL_ADV_STND_LIMIT = X_EXTERNAL_ADV_STND_LIMIT)
           OR ((tlinfo.EXTERNAL_ADV_STND_LIMIT is null)
               AND (X_EXTERNAL_ADV_STND_LIMIT is null)))
      AND ((tlinfo.INTERNAL_ADV_STND_LIMIT = X_INTERNAL_ADV_STND_LIMIT)
           OR ((tlinfo.INTERNAL_ADV_STND_LIMIT is null)
               AND (X_INTERNAL_ADV_STND_LIMIT is null)))
      AND ((tlinfo.CONTACT_HOURS = X_CONTACT_HOURS)
           OR ((tlinfo.CONTACT_HOURS is null)
               AND (X_CONTACT_HOURS is null)))
      AND ((tlinfo.CREDIT_POINTS_REQUIRED = X_CREDIT_POINTS_REQUIRED)
           OR ((tlinfo.CREDIT_POINTS_REQUIRED is null)
               AND (X_CREDIT_POINTS_REQUIRED is null)))
      AND ((tlinfo.GOVT_COURSE_LOAD = X_GOVT_COURSE_LOAD)
           OR ((tlinfo.GOVT_COURSE_LOAD is null)
               AND (X_GOVT_COURSE_LOAD is null)))
      AND ((tlinfo.STD_ANNUAL_LOAD = X_STD_ANNUAL_LOAD)
           OR ((tlinfo.STD_ANNUAL_LOAD is null)
               AND (X_STD_ANNUAL_LOAD is null)))
      AND ((tlinfo.COURSE_TOTAL_EFTSU = X_COURSE_TOTAL_EFTSU)
           OR ((tlinfo.COURSE_TOTAL_EFTSU is null)
               AND (X_COURSE_TOTAL_EFTSU is null)))
      AND ((tlinfo.MAX_INTRMSN_DURATION = X_MAX_INTRMSN_DURATION)
           OR ((tlinfo.MAX_INTRMSN_DURATION is null)
               AND (X_MAX_INTRMSN_DURATION is null)))
      AND ((tlinfo.NUM_OF_UNITS_BEFORE_INTRMSN = X_NUM_OF_UNITS_BEFORE_INTRMSN)
           OR ((tlinfo.NUM_OF_UNITS_BEFORE_INTRMSN is null)
               AND (X_NUM_OF_UNITS_BEFORE_INTRMSN is null)))
      AND ((tlinfo.MIN_SBMSN_PERCENTAGE = X_MIN_SBMSN_PERCENTAGE)
           OR ((tlinfo.MIN_SBMSN_PERCENTAGE is null)
               AND (X_MIN_SBMSN_PERCENTAGE is null)))
      AND ((tlinfo.min_cp_per_calendar = x_min_cp_per_calendar)
           OR ((tlinfo.min_cp_per_calendar IS NULL)
              AND (X_min_cp_per_calendar IS NULL)))
      AND ((tlinfo.approval_date = x_approval_date)
            OR ((tlinfo.approval_date IS NULL)
                AND (X_approval_date IS NULL)))
      AND ((tlinfo.external_approval_date = x_external_approval_date)
            OR ((tlinfo.external_approval_date IS NULL) AND (X_external_approval_date IS NULL)))
      AND ((tlinfo.federal_financial_aid = x_federal_financial_aid)
            OR ((tlinfo.federal_financial_aid IS NULL)
                AND (X_federal_financial_aid IS NULL)))
      AND ((tlinfo.institutional_financial_aid = x_institutional_financial_aid)
            OR ((tlinfo.institutional_financial_aid IS NULL)
                AND (X_institutional_financial_aid IS NULL)))
      AND ((tlinfo.max_cp_per_teaching_period = x_max_cp_per_teaching_period)
            OR ((tlinfo.max_cp_per_teaching_period IS NULL)
              AND (X_max_cp_per_teaching_period IS NULL)))
      AND ((tlinfo.residency_cp_required = x_residency_cp_required)
            OR ((tlinfo.residency_cp_required IS NULL)
            AND (X_residency_cp_required IS NULL)))
      AND ((tlinfo.state_financial_aid = x_state_financial_aid)
            OR ((tlinfo.state_financial_aid IS NULL)
               AND (X_state_financial_aid IS NULL)))
      AND ((tlinfo.primary_program_rank= x_primary_program_rank)
            OR ((tlinfo.primary_program_rank IS NULL)
               AND (X_primary_program_rank IS NULL)))
      AND ((tlinfo.max_wlst_per_stud = x_max_wlst_per_stud)
            OR ((tlinfo.max_wlst_per_stud IS NULL)
               AND (x_max_wlst_per_stud IS NULL)))
      AND ((tlinfo.annual_instruction_time = x_annual_instruction_time)
            OR ((tlinfo.annual_instruction_time IS NULL)
               AND (x_annual_instruction_time IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
END lock_row;

PROCEDURE update_row (
  x_rowid                             IN VARCHAR2,
  x_course_cd                         IN VARCHAR2,
  x_version_number                    IN NUMBER,
  x_hist_start_dt                     IN DATE,
  x_hist_end_dt                       IN DATE,
  x_hist_who                          IN NUMBER,
  x_start_dt                          IN DATE,
  x_review_dt                         IN DATE,
  x_expiry_dt                         IN DATE,
  x_end_dt                            IN DATE,
  x_course_status                     IN VARCHAR2,
  x_title                             IN VARCHAR2,
  x_short_title                       IN VARCHAR2,
  x_abbreviation                      IN VARCHAR2,
  x_supp_exam_permitted_ind           IN VARCHAR2,
  x_generic_course_ind                IN VARCHAR2,
  x_graduate_students_ind             IN VARCHAR2,
  x_count_intrmsn_in_time_ind         IN VARCHAR2,
  x_intrmsn_allowed_ind               IN VARCHAR2,
  x_course_type                       IN VARCHAR2,
  x_ct_description                    IN VARCHAR2,
  x_responsible_org_unit_cd           IN VARCHAR2,
  x_responsible_ou_start_dt           IN DATE,
  x_ou_description                    IN VARCHAR2,
  x_govt_special_course_type          IN VARCHAR2,
  x_gsct_description                  IN VARCHAR2,
  x_qualification_recency             IN NUMBER,
  x_external_adv_stnd_limit           IN NUMBER,
  x_internal_adv_stnd_limit           IN NUMBER,
  x_contact_hours                     IN NUMBER,
  x_credit_points_required            IN NUMBER,
  x_govt_course_load                  IN NUMBER,
  x_std_annual_load                   IN NUMBER,
  x_course_total_eftsu                IN NUMBER,
  x_max_intrmsn_duration              IN NUMBER,
  x_num_of_units_before_intrmsn       IN NUMBER,
  x_min_sbmsn_percentage              IN NUMBER,
  x_min_cp_per_calendar               IN NUMBER ,
  x_approval_date                     IN DATE  ,
  x_external_approval_date            IN DATE  ,
  x_federal_financial_aid             IN VARCHAR2  ,
  x_institutional_financial_aid       IN VARCHAR2  ,
  x_max_cp_per_teaching_period        IN NUMBER  ,
  x_residency_cp_required             IN NUMBER  ,
  x_state_financial_aid               IN VARCHAR2  ,
  x_primary_program_rank              IN NUMBER  ,
  x_max_wlst_per_stud                 IN NUMBER,
  x_mode                              IN VARCHAR2,
  x_annual_instruction_time           IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    19_oct-2002  Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time
  ||                           as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22
  ||                           warnings.
  ----------------------------------------------------------------------------*/
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY is NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
 before_dml( p_action => 'UPDATE',
 x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_start_dt => X_START_DT,
    x_review_dt => X_REVIEW_DT,
    x_expiry_dt => X_EXPIRY_DT,
    x_end_dt => X_END_DT,
    x_course_status => X_COURSE_STATUS,
    x_title => X_TITLE,
    x_short_title => X_SHORT_TITLE,
    x_abbreviation => X_ABBREVIATION,
    x_supp_exam_permitted_ind => X_SUPP_EXAM_PERMITTED_IND,
    x_generic_course_ind => X_GENERIC_COURSE_IND,
    x_graduate_students_ind => X_GRADUATE_STUDENTS_IND,
    x_count_intrmsn_in_time_ind => X_COUNT_INTRMSN_IN_TIME_IND,
    x_intrmsn_allowed_ind => X_INTRMSN_ALLOWED_IND,
    x_course_type => X_COURSE_TYPE,
    x_ct_description => X_CT_DESCRIPTION,
    x_responsible_org_unit_cd => X_RESPONSIBLE_ORG_UNIT_CD,
    x_responsible_ou_start_dt => X_RESPONSIBLE_OU_START_DT,
    x_ou_description => X_OU_DESCRIPTION,
    x_govt_special_course_type => X_GOVT_SPECIAL_COURSE_TYPE,
    x_gsct_description =>X_GSCT_DESCRIPTION,
    x_qualification_recency => X_QUALIFICATION_RECENCY,
    x_external_adv_stnd_limit => X_EXTERNAL_ADV_STND_LIMIT,
    x_internal_adv_stnd_limit => X_INTERNAL_ADV_STND_LIMIT,
    x_contact_hours => X_CONTACT_HOURS,
    x_credit_points_required => X_CREDIT_POINTS_REQUIRED,
    x_govt_course_load => X_GOVT_COURSE_LOAD,
    x_std_annual_load => X_STD_ANNUAL_LOAD,
    x_course_total_eftsu => X_COURSE_TOTAL_EFTSU,
    x_max_intrmsn_duration => X_MAX_INTRMSN_DURATION,
    x_num_of_units_before_intrmsn => X_NUM_OF_UNITS_BEFORE_INTRMSN,
    x_min_sbmsn_percentage => X_MIN_SBMSN_PERCENTAGE,
    x_min_cp_per_calendar => X_MIN_CP_PER_CALENDAR,
    x_approval_date  => X_APPROVAL_DATE,
    x_external_approval_date => X_EXTERNAL_APPROVAL_DATE,
    x_federal_financial_aid => X_FEDERAL_FINANCIAL_AID,
    x_institutional_financial_aid => X_INSTITUTIONAL_FINANCIAL_AID,
    x_max_cp_per_teaching_period =>X_MAX_CP_PER_TEACHING_PERIOD,
    x_residency_cp_required =>X_RESIDENCY_CP_REQUIRED,
    x_state_financial_aid =>X_STATE_FINANCIAL_AID,
    x_primary_program_rank=>X_PRIMARY_PROGRAM_RANK,
    x_max_wlst_per_stud => x_max_wlst_per_stud,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_annual_instruction_time => x_annual_instruction_time
  );

  UPDATE IGS_PS_VER_HIST_ALL SET
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    START_DT = NEW_REFERENCES.START_DT,
    REVIEW_DT = NEW_REFERENCES.REVIEW_DT,
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    END_DT = NEW_REFERENCES.END_DT,
    COURSE_STATUS = NEW_REFERENCES.COURSE_STATUS,
    TITLE = NEW_REFERENCES.TITLE,
    SHORT_TITLE = NEW_REFERENCES.SHORT_TITLE,
    ABBREVIATION = NEW_REFERENCES.ABBREVIATION,
    SUPP_EXAM_PERMITTED_IND = NEW_REFERENCES.SUPP_EXAM_PERMITTED_IND,
    GENERIC_COURSE_IND = NEW_REFERENCES.GENERIC_COURSE_IND,
    GRADUATE_STUDENTS_IND = NEW_REFERENCES.GRADUATE_STUDENTS_IND,
    COUNT_INTRMSN_IN_TIME_IND = NEW_REFERENCES.COUNT_INTRMSN_IN_TIME_IND,
    INTRMSN_ALLOWED_IND = NEW_REFERENCES.INTRMSN_ALLOWED_IND,
    COURSE_TYPE = NEW_REFERENCES.COURSE_TYPE,
    CT_DESCRIPTION = NEW_REFERENCES.CT_DESCRIPTION,
    RESPONSIBLE_ORG_UNIT_CD = NEW_REFERENCES.RESPONSIBLE_ORG_UNIT_CD,
    RESPONSIBLE_OU_START_DT = NEW_REFERENCES.RESPONSIBLE_OU_START_DT,
    OU_DESCRIPTION = NEW_REFERENCES.OU_DESCRIPTION,
    GOVT_SPECIAL_COURSE_TYPE = NEW_REFERENCES.GOVT_SPECIAL_COURSE_TYPE,
    GSCT_DESCRIPTION = NEW_REFERENCES.GSCT_DESCRIPTION,
    QUALIFICATION_RECENCY = NEW_REFERENCES.QUALIFICATION_RECENCY,
    EXTERNAL_ADV_STND_LIMIT = NEW_REFERENCES.EXTERNAL_ADV_STND_LIMIT,
    INTERNAL_ADV_STND_LIMIT = NEW_REFERENCES.INTERNAL_ADV_STND_LIMIT,
    CONTACT_HOURS = NEW_REFERENCES.CONTACT_HOURS,
    CREDIT_POINTS_REQUIRED = NEW_REFERENCES.CREDIT_POINTS_REQUIRED,
    GOVT_COURSE_LOAD = NEW_REFERENCES.GOVT_COURSE_LOAD,
    STD_ANNUAL_LOAD = NEW_REFERENCES.STD_ANNUAL_LOAD,
    COURSE_TOTAL_EFTSU = NEW_REFERENCES.COURSE_TOTAL_EFTSU,
    MAX_INTRMSN_DURATION = NEW_REFERENCES.MAX_INTRMSN_DURATION,
    NUM_OF_UNITS_BEFORE_INTRMSN = NEW_REFERENCES.NUM_OF_UNITS_BEFORE_INTRMSN,
    MIN_SBMSN_PERCENTAGE = NEW_REFERENCES.MIN_SBMSN_PERCENTAGE,
    min_cp_per_calendar = NEW_REFERENCES.MIN_CP_PER_CALENDAR,
    approval_date  = NEW_REFERENCES.APPROVAL_DATE,
    external_approval_date = NEW_REFERENCES.EXTERNAL_APPROVAL_DATE,
    federal_financial_aid = NEW_REFERENCES.FEDERAL_FINANCIAL_AID,
    institutional_financial_aid = NEW_REFERENCES.INSTITUTIONAL_FINANCIAL_AID,
    max_cp_per_teaching_period = NEW_REFERENCES.MAX_CP_PER_TEACHING_PERIOD,
    residency_cp_required = NEW_REFERENCES.RESIDENCY_CP_REQUIRED,
    state_financial_aid =NEW_REFERENCES.STATE_FINANCIAL_AID,
    primary_program_rank = NEW_REFERENCES.PRIMARY_PROGRAM_RANK,
    max_wlst_per_stud = NEW_REFERENCES.max_wlst_per_stud,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    annual_instruction_time = x_annual_instruction_time

  WHERE ROWID = x_rowid
  ;
  IF (sql%notfound) THEN
    RAISE no_data_found;
  END IF;
 after_dml(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

END update_row;

PROCEDURE add_row (
  x_rowid                             IN OUT NOCOPY VARCHAR2,
  x_course_cd                         IN VARCHAR2,
  x_version_number                    IN NUMBER,
  x_hist_start_dt                     IN DATE,
  x_hist_end_dt                       IN DATE,
  x_hist_who                          IN NUMBER,
  x_start_dt                          IN DATE,
  x_review_dt                         IN DATE,
  x_expiry_dt                         IN DATE,
  x_end_dt                            IN DATE,
  x_course_status                     IN VARCHAR2,
  x_title                             IN VARCHAR2,
  x_short_title                       IN VARCHAR2,
  x_abbreviation                      IN VARCHAR2,
  x_supp_exam_permitted_ind           IN VARCHAR2,
  x_generic_course_ind                IN VARCHAR2,
  x_graduate_students_ind             IN VARCHAR2,
  x_count_intrmsn_in_time_ind         IN VARCHAR2,
  x_intrmsn_allowed_ind               IN VARCHAR2,
  x_course_type                       IN VARCHAR2,
  x_ct_description                    IN VARCHAR2,
  x_responsible_org_unit_cd           IN VARCHAR2,
  x_responsible_ou_start_dt           IN DATE,
  x_ou_description                    IN VARCHAR2,
  x_govt_special_course_type          IN VARCHAR2,
  x_gsct_description                  IN VARCHAR2,
  x_qualification_recency             IN NUMBER,
  x_external_adv_stnd_limit           IN NUMBER,
  x_internal_adv_stnd_limit           IN NUMBER,
  x_contact_hours                     IN NUMBER,
  x_credit_points_required            IN NUMBER,
  x_govt_course_load                  IN NUMBER,
  x_std_annual_load                   IN NUMBER,
  x_course_total_eftsu                IN NUMBER,
  x_max_intrmsn_duration              IN NUMBER,
  x_num_of_units_before_intrmsn       IN NUMBER,
  x_min_sbmsn_percentage              IN NUMBER,
  x_min_cp_per_calendar               IN NUMBER ,
  x_approval_date                     IN DATE  ,
  x_external_approval_date            IN DATE  ,
  x_federal_financial_aid             IN VARCHAR2  ,
  x_institutional_financial_aid       IN VARCHAR2  ,
  x_max_cp_per_teaching_period        IN NUMBER  ,
  x_residency_cp_required             IN NUMBER  ,
  x_state_financial_aid               IN VARCHAR2  ,
  x_primary_program_rank              IN NUMBER  ,
  x_max_wlst_per_stud                 IN NUMBER,
  x_mode                              IN VARCHAR2,
  x_org_id                            IN NUMBER,
  x_annual_instruction_time           IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur    19_oct-2002  Enh#2608227.removed references to std_ft_completion_time,std_pt_completion_time
  ||                           as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22
  ||                           warnings.
  ----------------------------------------------------------------------------*/
  CURSOR C1 IS SELECT rowid FROM IGS_PS_VER_HIST_ALL
     WHERE COURSE_CD = X_COURSE_CD
     AND VERSION_NUMBER = X_VERSION_NUMBER
     AND HIST_START_DT = X_HIST_START_DT
  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%notfound) THEN
    CLOSE c1;
    INSERT_ROW (
     x_rowid,
     x_course_cd,
     x_version_number,
     x_hist_start_dt,
     x_hist_end_dt,
     x_hist_who,
     x_start_dt,
     x_review_dt,
     x_expiry_dt,
     x_end_dt,
     x_course_status,
     x_title,
     x_short_title,
     x_abbreviation,
     x_supp_exam_permitted_ind,
     x_generic_course_ind,
     x_graduate_students_ind,
     x_count_intrmsn_in_time_ind,
     x_intrmsn_allowed_ind,
     x_course_type,
     x_ct_description,
     x_responsible_org_unit_cd,
     x_responsible_ou_start_dt,
     x_ou_description,
     x_govt_special_course_type,
     x_gsct_description,
     x_qualification_recency,
     x_external_adv_stnd_limit,
     x_internal_adv_stnd_limit,
     x_contact_hours,
     x_credit_points_required,
     x_govt_course_load,
     x_std_annual_load,
     x_course_total_eftsu,
     x_max_intrmsn_duration,
     x_num_of_units_before_intrmsn,
     x_min_sbmsn_percentage,
     x_min_cp_per_calendar,
     x_approval_date ,
     x_external_approval_date  ,
     x_federal_financial_aid ,
     x_institutional_financial_aid ,
     x_max_cp_per_teaching_period,
     x_residency_cp_required ,
     x_state_financial_aid ,
     x_primary_program_rank,
     x_max_wlst_per_stud,
     x_mode,
     x_org_id,
     x_annual_instruction_time);
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   x_rowid,
   x_course_cd,
   x_version_number,
   x_hist_start_dt,
   x_hist_end_dt,
   x_hist_who,
   x_start_dt,
   x_review_dt,
   x_expiry_dt,
   x_end_dt,
   x_course_status,
   x_title,
   x_short_title,
   x_abbreviation,
   x_supp_exam_permitted_ind,
   x_generic_course_ind,
   x_graduate_students_ind,
   x_count_intrmsn_in_time_ind,
   x_intrmsn_allowed_ind,
   x_course_type,
   x_ct_description,
   x_responsible_org_unit_cd,
   x_responsible_ou_start_dt,
   x_ou_description,
   x_govt_special_course_type,
   x_gsct_description,
   x_qualification_recency,
   x_external_adv_stnd_limit,
   x_internal_adv_stnd_limit,
   x_contact_hours,
   x_credit_points_required,
   x_govt_course_load,
   x_std_annual_load,
   x_course_total_eftsu,
   x_max_intrmsn_duration,
   x_num_of_units_before_intrmsn,
   x_min_sbmsn_percentage,
   x_min_cp_per_calendar,
   x_approval_date ,
   x_external_approval_date  ,
   x_federal_financial_aid ,
   x_institutional_financial_aid ,
   x_max_cp_per_teaching_period,
   x_residency_cp_required ,
   x_state_financial_aid ,
   x_primary_program_rank,
   x_max_wlst_per_stud,
   x_mode,
   x_annual_instruction_time
);
END add_row;

PROCEDURE delete_row (
x_rowid in VARCHAR2
) AS
BEGIN
 before_dml( p_action => 'DELETE',
    x_rowid => x_rowid
  );

  DELETE FROM IGS_PS_VER_HIST_ALL
  WHERE ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 after_dml(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

END delete_row;

END igs_ps_ver_hist_pkg;

/
