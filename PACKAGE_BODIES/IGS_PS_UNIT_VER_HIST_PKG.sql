--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_VER_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_VER_HIST_PKG" as
/* $Header: IGSPI93B.pls 120.1 2006/08/10 14:05:07 pkpatel noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_VER_HIST_ALL%RowType;
  new_references IGS_PS_UNIT_VER_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE ,
    x_hist_who IN NUMBER ,
    x_start_dt IN DATE ,
    x_review_dt IN DATE ,
    x_expiry_dt IN DATE ,
    x_end_dt IN DATE ,
    x_unit_status IN VARCHAR2 ,
    x_title IN VARCHAR2 ,
    x_short_title IN VARCHAR2 ,
    x_title_override_ind IN VARCHAR2 ,
    x_abbreviation IN VARCHAR2 ,
    x_unit_level IN VARCHAR2 ,
    x_ul_description IN VARCHAR2 ,
    x_credit_point_descriptor IN VARCHAR2 ,
    x_enrolled_credit_points IN NUMBER ,
    x_points_override_ind IN VARCHAR2 ,
    x_supp_exam_permitted_ind IN VARCHAR2 ,
    x_coord_person_id IN NUMBER ,
    x_owner_org_unit_cd IN VARCHAR2 ,
    x_owner_ou_start_dt IN DATE ,
    x_ou_description IN VARCHAR2 ,
    x_award_course_only_ind IN VARCHAR2 ,
    x_research_unit_ind IN VARCHAR2 ,
    x_industrial_ind IN VARCHAR2 ,
    x_practical_ind IN VARCHAR2 ,
    x_repeatable_ind IN VARCHAR2 ,
    x_assessable_ind IN VARCHAR2 ,
    x_achievable_credit_points IN NUMBER ,
    x_points_increment IN NUMBER ,
    x_points_min IN NUMBER ,
    x_points_max IN NUMBER ,
    x_unit_int_course_level_cd IN VARCHAR2 ,
    x_uicl_description IN VARCHAR2 ,
    x_subtitle_id                       IN     NUMBER ,
    x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind                    IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal       IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal       IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_repeat_code                       IN     VARCHAR2 ,
    x_unit_type_id                      IN     NUMBER ,
    x_level_code                        IN     VARCHAR2 ,
    x_advance_maximum                   IN     NUMBER ,
    x_approval_date                     IN     DATE ,
    x_continuing_education_units        IN     NUMBER ,
    x_enrollment_expected               IN     NUMBER ,
    x_enrollment_maximum                IN     NUMBER ,
    x_enrollment_minimum                IN     NUMBER ,
    x_federal_financial_aid             IN     VARCHAR2 ,
    x_institutional_financial_aid       IN     VARCHAR2 ,
    x_lab_credit_points                 IN     NUMBER ,
    x_lecture_credit_points             IN     NUMBER ,
    x_max_repeats_for_credit            IN     NUMBER ,
    x_max_repeats_for_funding           IN     NUMBER ,
    x_max_repeat_credit_points          IN     NUMBER ,
    x_clock_hours                       IN     NUMBER ,
    x_other_credit_points               IN     NUMBER ,
    x_same_teaching_period              IN     VARCHAR2 ,
    x_same_teach_period_repeats         IN     NUMBER ,
    x_same_teach_period_repeats_cp      IN     NUMBER ,
    x_state_financial_aid               IN     VARCHAR2 ,
    x_work_load_cp_lab                  IN     NUMBER ,
    x_work_load_cp_lecture              IN     NUMBER ,
    x_subtitle_modifiable_flag          IN     VARCHAR2 ,
    x_subtitle                          IN     VARCHAR2 ,
    x_special_permission_ind            IN     VARCHAR2 ,
    x_creation_date                     IN     DATE ,
    x_created_by                        IN     NUMBER ,
    x_last_update_date                  IN     DATE ,
    x_last_updated_by                   IN     NUMBER ,
    x_last_update_login                 IN     NUMBER  ,
    x_org_id                            IN     NUMBER  ,
    x_ss_enrol_ind                      IN     VARCHAR2 ,
    x_ivr_enrol_ind                     IN     VARCHAR2 ,
    x_claimable_hours                   IN     NUMBER ,
    x_auditable_ind			IN     VARCHAR2 ,
    x_audit_permission_ind		IN     VARCHAR2 ,
    x_max_auditors_allowed		IN     NUMBER ,
    x_billing_credit_points             IN     NUMBER ,
    x_ovrd_wkld_val_flag                IN     VARCHAR2 ,
    x_workload_val_code                 IN     VARCHAR2 ,
    x_billing_hrs                       IN     NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_VER_HIST_ALL
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
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.start_dt := x_start_dt;
    new_references.review_dt := x_review_dt;
    new_references.expiry_dt := x_expiry_dt;
    new_references.end_dt := x_end_dt;
    new_references.unit_status := x_unit_status;
    new_references.title := x_title;
    new_references.short_title := x_short_title;
    new_references.title_override_ind := x_title_override_ind;
    new_references.abbreviation := x_abbreviation;
    new_references.unit_level := x_unit_level;
    new_references.ul_description := x_ul_description;
    new_references.credit_point_descriptor:= x_credit_point_descriptor;
    new_references.enrolled_credit_points := x_enrolled_credit_points;
    new_references.points_override_ind := x_points_override_ind;
    new_references.supp_exam_permitted_ind := x_supp_exam_permitted_ind;
    new_references.coord_person_id := x_coord_person_id;
    new_references.owner_org_unit_cd := x_owner_org_unit_cd;
    new_references.owner_ou_start_dt := x_owner_ou_start_dt;
    new_references.ou_description := x_ou_description;
    new_references.award_course_only_ind := x_award_course_only_ind;
    new_references.research_unit_ind := x_research_unit_ind;
    new_references.industrial_ind := x_industrial_ind;
    new_references.practical_ind := x_practical_ind;
    new_references.repeatable_ind := x_repeatable_ind;
    new_references.assessable_ind := x_assessable_ind;
    new_references.achievable_credit_points := x_achievable_credit_points;
    new_references.points_increment := x_points_increment;
    new_references.points_min := x_points_min;
    new_references.points_max := x_points_max;
    new_references.unit_int_course_level_cd := x_unit_int_course_level_cd;
    new_references.uicl_description := x_uicl_description;
    new_references.subtitle_id := x_subtitle_id;
    new_references.work_load_other := x_work_load_other;
    new_references.contact_hrs_lecture := x_contact_hrs_lecture;
    new_references.contact_hrs_lab := x_contact_hrs_lab;
    new_references.contact_hrs_other := x_contact_hrs_other;
    new_references.non_schd_required_hrs := x_non_schd_required_hrs;
    new_references.exclude_from_max_cp_limit := x_exclude_from_max_cp_limit;
    new_references.record_exclusion_flag := x_record_exclusion_flag ;
    new_references.ss_display_ind := x_ss_display_ind;
    new_references.cal_type_enrol_load_cal := x_cal_type_enrol_load_cal;
    new_references.sequence_num_enrol_load_cal := x_sequence_num_enrol_load_cal;
    new_references.cal_type_offer_load_cal := x_cal_type_offer_load_cal;
    new_references.sequence_num_offer_load_cal := x_sequence_num_offer_load_cal;
    new_references.curriculum_id := x_curriculum_id;
    new_references.override_enrollment_max := x_override_enrollment_max;
    new_references.rpt_fmly_id := x_rpt_fmly_id;
    new_references.repeat_code := x_repeat_code;
    new_references.unit_type_id := x_unit_type_id;
    new_references.level_code := x_level_code;
    new_references.advance_maximum := x_advance_maximum;
    new_references.approval_date := x_approval_date;
    new_references.continuing_education_units := x_continuing_education_units;
    new_references.enrollment_expected := x_enrollment_expected;
    new_references.enrollment_maximum := x_enrollment_maximum;
    new_references.enrollment_minimum := x_enrollment_minimum ;
    new_references.federal_financial_aid := x_federal_financial_aid;
    new_references.institutional_financial_aid := x_institutional_financial_aid;
    new_references.lab_credit_points := x_lab_credit_points;
    new_references.lecture_credit_points := x_lecture_credit_points;
    new_references.max_repeats_for_credit := x_max_repeats_for_credit;
    new_references.max_repeats_for_funding := x_max_repeats_for_funding;
    new_references.max_repeat_credit_points := x_max_repeat_credit_points;
    new_references.clock_hours := x_clock_hours ;
    new_references.other_credit_points := x_other_credit_points;
    new_references.same_teaching_period := x_same_teaching_period;
    new_references.same_teach_period_repeats := x_same_teach_period_repeats;
    new_references.same_teach_period_repeats_cp := x_same_teach_period_repeats_cp;
    new_references.state_financial_aid := x_state_financial_aid;
    new_references.work_load_cp_lab := x_work_load_cp_lab;
    new_references.work_load_cp_lecture := x_work_load_cp_lecture;
    new_references.subtitle_modifiable_flag := x_subtitle_modifiable_flag;
    new_references.subtitle := x_subtitle;
    new_references.special_permission_ind := x_special_permission_ind;
    new_references.claimable_hours := x_claimable_hours;
    new_references.auditable_ind := x_auditable_ind;
    new_references.audit_permission_ind := x_audit_permission_ind;
    new_references.max_auditors_allowed := x_max_auditors_allowed;
    new_references.billing_credit_points := x_billing_credit_points;
    new_references.ovrd_wkld_val_flag := x_ovrd_wkld_val_flag;
    new_references.workload_val_code := x_workload_val_code;
    new_references.billing_hrs := x_billing_hrs;

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
    new_references.org_id := x_org_id;
    new_references.ss_enrol_ind := x_ss_enrol_ind;
    new_references.ivr_enrol_ind := x_ivr_enrol_ind;


  END Set_Column_Values;

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	,
				Column_Value 	IN	VARCHAR2	)
AS
BEGIN

     	IF Column_Name IS NULL Then
		NULL;
	ELSIF Upper(Column_Name)='ABBREVIATION' Then
		New_References.abbreviation := Column_Value;
	ELSIF Upper(Column_Name)='ASSESSABLE_IND' Then
		New_References.assessable_ind := Column_Value;
	ELSIF Upper(Column_Name)='AUDITABLE_IND' Then
		New_References.auditable_ind := Column_Value;
	ELSIF Upper(Column_Name)='AUDIT_PERMISSION_IND' Then
		New_References.audit_permission_ind := Column_Value;
	ELSIF Upper(Column_Name)='AWARD_COURSE_ONLY_IND' Then
		New_References.award_course_only_ind := Column_Value;
	ELSIF Upper(Column_Name)='CREDIT_POINT_DESCRIPTOR' Then
		New_References.credit_point_descriptor := Column_Value;
	ELSIF Upper(Column_Name)='INDUSTRIAL_IND' Then
		New_References.industrial_ind := Column_Value;
	ELSIF Upper(Column_Name)='POINTS_OVERRIDE_IND' Then
		New_References.points_override_ind := Column_Value;
	ELSIF Upper(Column_Name)='PRACTICAL_IND' Then
		New_References.practical_ind := Column_Value;
	ELSIF Upper(Column_Name)='REPEATABLE_IND' Then
		New_References.repeatable_ind := Column_Value;
	ELSIF Upper(Column_Name)='RESEARCH_UNIT_IND' Then
		New_References.research_unit_ind := Column_Value;
	ELSIF Upper(Column_Name)='SUPP_EXAM_PERMITTED_IND' Then
		New_References.supp_exam_permitted_ind := Column_Value;
	ELSIF Upper(Column_Name)='TITLE_OVERRIDE_IND' Then
		New_References.title_override_ind := Column_Value;
	ELSIF Upper(Column_Name)='UNIT_CD' Then
		New_References.unit_cd := Column_Value;
	ELSIF Upper(Column_Name)='UNIT_INT_COURSE_LEVEL_CD' Then
		New_References.unit_int_course_level_cd := Column_Value;
	ELSIF Upper(Column_Name)='UNIT_LEVEL' Then
		New_References.unit_level:= Column_Value;
	ELSIF Upper(Column_Name)='UNIT_STATUS' Then
		New_References.unit_status:= Column_Value;
	ELSIF UPPER(Column_Name)='SS_ENROL_IND' THEN
		New_References.ss_enrol_ind := column_value;
	ELSIF UPPER(Column_Name)='IVR_ENROL_IND' THEN
		New_References.ivr_enrol_ind := column_value;
	ELSIF UPPER(Column_Name)='BILLING_HRS' THEN
		New_References.billing_hrs := column_value;
	END IF;

	IF Upper(Column_Name)='ABBREVIATION' OR Column_Name IS NULL Then
		IF New_References.abbreviation <> UPPER(New_References.abbreviation) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ASSESSABLE_IND' OR Column_Name IS NULL Then
		IF New_References.Assessable_Ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='AWARD_COURSE_ONLY_IND' OR Column_Name IS NULL Then
		IF New_References.Award_Course_Only_Ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CREDIT_POINT_DESCRIPTOR' OR Column_Name IS NULL Then
		IF New_References.Credit_Point_Descriptor <> UPPER(New_References.Credit_Point_Descriptor) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='INDUSTRIAL_IND' OR Column_Name IS NULL Then
		IF New_References.Industrial_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

	END IF;

	IF Upper(Column_Name)='POINTS_OVERRIDE_IND' OR Column_Name IS NULL Then

		IF New_References.Points_Override_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;


	END IF;

	IF Upper(Column_Name)='PRACTICAL_IND' OR Column_Name IS NULL Then
		IF New_References.Practical_Ind <> UPPER(New_References.Practical_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='REPEATABLE_IND' OR Column_Name IS NULL Then

		IF New_References.Repeatable_Ind NOT IN ( 'Y' , 'N','X' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

	END IF;


	IF Upper(Column_Name)='RESEARCH_UNIT_IND' OR Column_Name IS NULL Then

		IF New_References.Research_Unit_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;


	END IF;


	IF Upper(Column_Name)='SUPP_EXAM_PERMITTED_IND' OR Column_Name IS NULL Then

		IF New_References.Supp_Exam_Permitted_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;


	END IF;


	IF Upper(Column_Name)='TITLE_OVERRIDE_IND' OR Column_Name IS NULL Then

		IF New_References.Title_Override_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;


	END IF;

	IF Upper(Column_Name)='AUDITABLE_IND' OR Column_Name IS NULL Then
	  IF New_References.auditable_Ind NOT IN ( 'Y' , 'N' ) Then
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	  END IF;
	END IF;

	IF Upper(Column_Name)='AUDIT_PERMISSION_IND' OR Column_Name IS NULL Then
	  IF New_References.audit_permission_Ind NOT IN ( 'Y' , 'N' ) Then
	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	  END IF;
	END IF;

	IF Upper(Column_Name)='UNIT_CD' OR Column_Name IS NULL Then
		IF New_References.Unit_Cd <> UPPER(New_References.Unit_CD) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='UNIT_INT_COURSE_LEVEL_CD' OR Column_Name IS NULL Then
		IF New_References.Unit_Int_Course_Level_Cd <> UPPER(New_References.Unit_Int_Course_Level_Cd) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='UNIT_LEVEL' OR Column_Name IS NULL Then
		IF New_References.Unit_Level <> UPPER(New_References.Unit_Level) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='UNIT_STATUS' OR Column_Name IS NULL Then
		IF New_References.Unit_Status <> UPPER(New_References.Unit_Status) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

        -- check that atleast one enrollemnt method is selected
        IF (Upper(Column_name)='SS_ENROL_IND' OR Upper(Column_name)='IVR_ENROL_IND') OR Column_name IS NULL THEN
                IF NOT (New_References.ss_enrol_ind = 'Y' OR New_references.ivr_enrol_ind = 'Y') THEN
                             Fnd_Message.Set_Name('IGS', 'IGS_PS_ONE_UNIT_ENR_MTHD');
                             IGS_GE_MSG_STACK.ADD;
                             App_Exception.Raise_Exception;
                END IF;
        END IF;

	IF Upper(Column_Name)='BILLING_HRS' OR Column_Name IS NULL Then
		IF New_References.billing_hrs < 0 OR New_References.billing_hrs > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


END Check_Constraints;


  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_HIST_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      hist_start_dt = x_hist_start_dt
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE ,
    x_hist_who IN NUMBER ,
    x_start_dt IN DATE ,
    x_review_dt IN DATE ,
    x_expiry_dt IN DATE ,
    x_end_dt IN DATE ,
    x_unit_status IN VARCHAR2 ,
    x_title IN VARCHAR2 ,
    x_short_title IN VARCHAR2 ,
    x_title_override_ind IN VARCHAR2 ,
    x_abbreviation IN VARCHAR2 ,
    x_unit_level IN VARCHAR2 ,
    x_ul_description IN VARCHAR2 ,
    x_credit_point_descriptor IN VARCHAR2 ,
    x_enrolled_credit_points IN NUMBER ,
    x_points_override_ind IN VARCHAR2 ,
    x_supp_exam_permitted_ind IN VARCHAR2 ,
    x_coord_person_id IN NUMBER ,
    x_owner_org_unit_cd IN VARCHAR2 ,
    x_owner_ou_start_dt IN DATE ,
    x_ou_description IN VARCHAR2 ,
    x_award_course_only_ind IN VARCHAR2 ,
    x_research_unit_ind IN VARCHAR2 ,
    x_industrial_ind IN VARCHAR2 ,
    x_practical_ind IN VARCHAR2 ,
    x_repeatable_ind IN VARCHAR2 ,
    x_assessable_ind IN VARCHAR2 ,
    x_achievable_credit_points IN NUMBER ,
    x_points_increment IN NUMBER ,
    x_points_min IN NUMBER ,
    x_points_max IN NUMBER ,
    x_unit_int_course_level_cd IN VARCHAR2 ,
    x_uicl_description IN VARCHAR2 ,
    x_subtitle_id                       IN     NUMBER      ,
    x_work_load_other                   IN     NUMBER      ,
    x_contact_hrs_lecture               IN     NUMBER      ,
    x_contact_hrs_lab                   IN     NUMBER      ,
    x_contact_hrs_other                 IN     NUMBER      ,
    x_non_schd_required_hrs             IN     NUMBER      ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2    ,
    x_record_exclusion_flag             IN     VARCHAR2    ,
    x_ss_display_ind       IN     VARCHAR2    ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2    ,
    x_sequence_num_enrol_load_cal    IN     NUMBER      ,
    x_cal_type_offer_load_cal           IN     VARCHAR2    ,
    x_sequence_num_offer_load_cal    IN     NUMBER      ,
    x_curriculum_id                     IN     VARCHAR2      ,
    x_override_enrollment_max           IN     NUMBER      ,
    x_rpt_fmly_id                       IN     NUMBER      ,
    x_repeat_code                       IN     VARCHAR2    ,
    x_unit_type_id                      IN     NUMBER      ,
    x_level_code                        IN     VARCHAR2    ,
    x_advance_maximum                   IN     NUMBER      ,
    x_approval_date                     IN     DATE        ,
    x_continuing_education_units        IN     NUMBER      ,
    x_enrollment_expected               IN     NUMBER      ,
    x_enrollment_maximum                IN     NUMBER      ,
    x_enrollment_minimum                IN     NUMBER      ,
    x_federal_financial_aid             IN     VARCHAR2    ,
    x_institutional_financial_aid       IN     VARCHAR2    ,
    x_lab_credit_points                 IN     NUMBER      ,
    x_lecture_credit_points             IN     NUMBER      ,
    x_max_repeats_for_credit            IN     NUMBER      ,
    x_max_repeats_for_funding           IN     NUMBER      ,
    x_max_repeat_credit_points          IN     NUMBER      ,
    x_clock_hours                       IN     NUMBER      ,
    x_other_credit_points               IN     NUMBER      ,
    x_same_teaching_period              IN     VARCHAR2    ,
    x_same_teach_period_repeats         IN     NUMBER      ,
    x_same_teach_period_repeats_cp      IN     NUMBER      ,
    x_state_financial_aid               IN     VARCHAR2    ,
    x_work_load_cp_lab                  IN     NUMBER      ,
    x_work_load_cp_lecture              IN     NUMBER      ,
    x_subtitle_modifiable_flag          IN     VARCHAR2    ,
    x_subtitle                          IN     VARCHAR2    ,
    x_special_permission_ind            IN     VARCHAR2    ,
    x_creation_date                     IN     DATE ,
    x_created_by                        IN     NUMBER ,
    x_last_update_date                  IN     DATE ,
    x_last_updated_by                   IN     NUMBER ,
    x_last_update_login                 IN     NUMBER ,
    x_org_id                            IN     NUMBER ,
    x_ss_enrol_ind                      IN     VARCHAR2 ,
    x_ivr_enrol_ind                     IN     VARCHAR2 ,
    x_claimable_hours                   IN     NUMBER ,
    x_auditable_ind			IN     VARCHAR2 ,
    x_audit_permission_ind		IN     VARCHAR2 ,
    x_max_auditors_allowed		IN     NUMBER ,
    x_billing_credit_points             IN     NUMBER ,
    x_ovrd_wkld_val_flag                IN     VARCHAR2 ,
    x_workload_val_code                 IN     VARCHAR2 ,
    x_billing_hrs                       IN     NUMBER
  ) AS

       l_count             NUMBER;
       l_dummy             VARCHAR2(1);
       CURSOR unique_check_cur (cp_unit_cd igs_ps_unit_ver_hist.unit_cd%TYPE,
				cp_version_number igs_ps_unit_ver_hist.version_number%TYPE,
				cp_hist_start_dt igs_ps_unit_ver_hist.hist_start_dt%TYPE) IS
       SELECT 'Y'
       FROM IGS_PS_UNIT_VER_HIST
       WHERE unit_cd = cp_unit_cd
       AND version_number = cp_version_number
       AND hist_start_dt = cp_hist_start_dt;
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_start_dt,
      x_review_dt,
      x_expiry_dt,
      x_end_dt,
      x_unit_status,
      x_title,
      x_short_title,
      x_title_override_ind,
      x_abbreviation,
      x_unit_level,
      x_ul_description,
      x_credit_point_descriptor,
      x_enrolled_credit_points,
      x_points_override_ind,
      x_supp_exam_permitted_ind,
      x_coord_person_id,
      x_owner_org_unit_cd,
      x_owner_ou_start_dt,
      x_ou_description,
      x_award_course_only_ind,
      x_research_unit_ind,
      x_industrial_ind,
      x_practical_ind,
      x_repeatable_ind,
      x_assessable_ind,
      x_achievable_credit_points,
      x_points_increment,
      x_points_min,
      x_points_max,
      x_unit_int_course_level_cd,
      x_uicl_description,
      x_subtitle_id,
      x_work_load_other,
    x_contact_hrs_lecture,
    x_contact_hrs_lab,
    x_contact_hrs_other,
    x_non_schd_required_hrs,
    x_exclude_from_max_cp_limit,
    x_record_exclusion_flag,
    x_ss_display_ind,
    x_cal_type_enrol_load_cal,
    x_sequence_num_enrol_load_cal,
    x_cal_type_offer_load_cal,
    x_sequence_num_offer_load_cal,
    x_curriculum_id,
    x_override_enrollment_max,
    x_rpt_fmly_id,
    x_repeat_code,
    x_unit_type_id,
    x_level_code,
    x_advance_maximum ,
    x_approval_date,
    x_continuing_education_units,
    x_enrollment_expected,
    x_enrollment_maximum,
    x_enrollment_minimum ,
    x_federal_financial_aid,
    x_institutional_financial_aid,
    x_lab_credit_points ,
    x_lecture_credit_points,
    x_max_repeats_for_credit,
    x_max_repeats_for_funding,
    x_max_repeat_credit_points,
    x_clock_hours ,
    x_other_credit_points,
    x_same_teaching_period,
    x_same_teach_period_repeats ,
    x_same_teach_period_repeats_cp,
    x_state_financial_aid,
    x_work_load_cp_lab,
    x_work_load_cp_lecture,
    x_subtitle_modifiable_flag,
    x_subtitle,
    x_special_permission_ind ,
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    x_org_id ,
    x_ss_enrol_ind,
    x_ivr_enrol_ind,
    x_claimable_hours,
    x_auditable_ind,
    x_audit_permission_ind,
    x_max_auditors_allowed,
    x_billing_credit_points,
    x_ovrd_wkld_val_flag,
    x_workload_val_code,
    x_billing_hrs
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	   IF Get_PK_For_Validation (New_References.unit_cd,
				     New_References.version_number,
                                     New_References.hist_start_dt) THEN

            -- Bug 5455027, When updating the Unit Record repetedly the Unique Key fails due to
	    -- hist_start_date becomes same as last update date of the Unit Record
	    -- Here increment the histroy start date by 1 second till unique combination is found.
            l_count := 1;
	    WHILE l_count > 0 LOOP

	       New_References.hist_start_dt := New_References.hist_start_dt + 1/(60*24*60);

		 OPEN unique_check_cur(New_References.unit_cd,
				     New_References.version_number,
                                     New_References.hist_start_dt);
		 FETCH unique_check_cur INTO l_dummy;
		 IF unique_check_cur%NOTFOUND THEN
		   l_count := 0;
		 ELSE
		   l_count := 1;
		 END IF;
		 CLOSE unique_check_cur;
	    END LOOP;

	   END IF;
	   Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	   Check_Constraints;

   ELSIF (p_action = 'VALIDATE_INSERT') THEN
	   IF Get_PK_For_Validation (New_References.unit_cd,
						New_References.version_number,
						New_References.hist_start_dt) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	   END IF;
	   Check_Constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	   Check_Constraints;

   END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;


PROCEDURE INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_UL_DESCRIPTION in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_UICL_DESCRIPTION in VARCHAR2,
  x_subtitle_id                       IN     NUMBER      ,
    x_work_load_other                   IN     NUMBER      ,
    x_contact_hrs_lecture               IN     NUMBER      ,
    x_contact_hrs_lab                   IN     NUMBER      ,
    x_contact_hrs_other                 IN     NUMBER      ,
    x_non_schd_required_hrs             IN     NUMBER      ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2    ,
    x_record_exclusion_flag             IN     VARCHAR2    ,
    x_ss_display_ind       IN     VARCHAR2    ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2    ,
    x_sequence_num_enrol_load_cal    IN     NUMBER      ,
    x_cal_type_offer_load_cal           IN     VARCHAR2    ,
    x_sequence_num_offer_load_cal    IN     NUMBER      ,
    x_curriculum_id                     IN     VARCHAR2      ,
    x_override_enrollment_max           IN     NUMBER      ,
    x_rpt_fmly_id                       IN     NUMBER      ,
    x_repeat_code                       IN     VARCHAR2    ,
    x_unit_type_id                      IN     NUMBER      ,
    x_level_code                        IN     VARCHAR2    ,
    x_advance_maximum                   IN     NUMBER      ,
    x_approval_date                     IN     DATE        ,
    x_continuing_education_units        IN     NUMBER      ,
    x_enrollment_expected               IN     NUMBER      ,
    x_enrollment_maximum                IN     NUMBER      ,
    x_enrollment_minimum                IN     NUMBER      ,
    x_federal_financial_aid             IN     VARCHAR2    ,
    x_institutional_financial_aid       IN     VARCHAR2    ,
    x_lab_credit_points                 IN     NUMBER      ,
    x_lecture_credit_points             IN     NUMBER      ,
    x_max_repeats_for_credit            IN     NUMBER      ,
    x_max_repeats_for_funding           IN     NUMBER      ,
    x_max_repeat_credit_points          IN     NUMBER      ,
    x_clock_hours                       IN     NUMBER      ,
    x_other_credit_points               IN     NUMBER      ,
    x_same_teaching_period              IN     VARCHAR2    ,
    x_same_teach_period_repeats         IN     NUMBER      ,
    x_same_teach_period_repeats_cp      IN     NUMBER      ,
    x_state_financial_aid               IN     VARCHAR2    ,
    x_work_load_cp_lab                  IN     NUMBER      ,
    x_work_load_cp_lecture              IN     NUMBER      ,
    x_subtitle_modifiable_flag          IN     VARCHAR2    ,
    x_subtitle                          IN     VARCHAR2    ,
    x_special_permission_ind            IN     VARCHAR2    ,
    X_MODE                              IN     VARCHAR2 ,
    X_ORG_ID                            IN     NUMBER,
    X_SS_ENROL_IND                      IN     VARCHAR2 ,
    X_IVR_ENROL_IND                     IN     VARCHAR2 ,
    x_claimable_hours                   IN     NUMBER ,
    x_auditable_ind			IN     VARCHAR2 ,
    x_audit_permission_ind		IN     VARCHAR2 ,
    x_max_auditors_allowed		IN     NUMBER ,
    x_billing_credit_points             IN     NUMBER ,
    x_ovrd_wkld_val_flag                IN     VARCHAR2 ,
    x_workload_val_code                 IN     VARCHAR2 ,
    x_billing_hrs                       IN     NUMBER
  ) AS
    cursor C is select ROWID from IGS_PS_UNIT_VER_HIST_ALL
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and HIST_START_DT = X_HIST_START_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_hist_start_dt => X_HIST_START_DT,
  x_hist_end_dt => X_HIST_END_DT,
  x_hist_who => X_HIST_WHO,
  x_start_dt => X_START_DT,
  x_review_dt => X_REVIEW_DT,
  x_expiry_dt => X_EXPIRY_DT,
  x_end_dt => X_END_DT,
  x_unit_status => X_UNIT_STATUS,
  x_title => X_TITLE,
  x_short_title => X_SHORT_TITLE,
  x_title_override_ind => X_TITLE_OVERRIDE_IND,
  x_abbreviation => X_ABBREVIATION,
  x_unit_level => X_UNIT_LEVEL,
  x_ul_description => X_UL_DESCRIPTION,
  x_credit_point_descriptor => X_CREDIT_POINT_DESCRIPTOR,
  x_enrolled_credit_points => X_ENROLLED_CREDIT_POINTS,
  x_points_override_ind => X_POINTS_OVERRIDE_IND,
  x_supp_exam_permitted_ind => NVL(X_SUPP_EXAM_PERMITTED_IND,'Y'),
  x_coord_person_id => X_COORD_PERSON_ID,
  x_owner_org_unit_cd => X_OWNER_ORG_UNIT_CD,
  x_owner_ou_start_dt => X_OWNER_OU_START_DT,
  x_ou_description => X_OU_DESCRIPTION,
  x_award_course_only_ind => X_AWARD_COURSE_ONLY_IND,
  x_research_unit_ind => X_RESEARCH_UNIT_IND,
  x_industrial_ind => X_INDUSTRIAL_IND,
  x_practical_ind => X_PRACTICAL_IND,
  x_repeatable_ind => X_REPEATABLE_IND,
  x_assessable_ind => X_ASSESSABLE_IND,
  x_achievable_credit_points => X_ACHIEVABLE_CREDIT_POINTS,
  x_points_increment => X_POINTS_INCREMENT,
  x_points_min => X_POINTS_MIN,
  x_points_max => X_POINTS_MAX,
  x_unit_int_course_level_cd => X_UNIT_INT_COURSE_LEVEL_CD,
  x_uicl_description => X_UICL_DESCRIPTION,
  x_subtitle_id                       => x_subtitle_id,
      x_work_load_other                   => x_work_load_other,
      x_contact_hrs_lecture               => x_contact_hrs_lecture,
      x_contact_hrs_lab                   => x_contact_hrs_lab,
      x_contact_hrs_other                 => x_contact_hrs_other,
      x_non_schd_required_hrs             => x_non_schd_required_hrs,
      x_exclude_from_max_cp_limit         => x_exclude_from_max_cp_limit,
      x_record_exclusion_flag             => x_record_exclusion_flag,
      x_ss_display_ind       => x_ss_display_ind,
      x_cal_type_enrol_load_cal           => x_cal_type_enrol_load_cal,
      x_sequence_num_enrol_load_cal    => x_sequence_num_enrol_load_cal,
      x_cal_type_offer_load_cal           => x_cal_type_offer_load_cal,
      x_sequence_num_offer_load_cal    => x_sequence_num_offer_load_cal,
      x_curriculum_id                     => x_curriculum_id,
      x_override_enrollment_max           => x_override_enrollment_max,
      x_rpt_fmly_id                       => x_rpt_fmly_id,
      x_repeat_code                       => x_repeat_code,
      x_unit_type_id                      => x_unit_type_id,
      x_level_code                        => x_level_code,
      x_advance_maximum                   => x_advance_maximum,
      x_approval_date                     => x_approval_date,
      x_continuing_education_units        => x_continuing_education_units,
      x_enrollment_expected               => x_enrollment_expected,
      x_enrollment_maximum                => x_enrollment_maximum,
      x_enrollment_minimum                => x_enrollment_minimum,
      x_federal_financial_aid             => x_federal_financial_aid,
      x_institutional_financial_aid       => x_institutional_financial_aid,
      x_lab_credit_points                 => x_lab_credit_points,
      x_lecture_credit_points             => x_lecture_credit_points,
      x_max_repeats_for_credit            => x_max_repeats_for_credit,
      x_max_repeats_for_funding           => x_max_repeats_for_funding,
      x_max_repeat_credit_points          => x_max_repeat_credit_points,
      x_clock_hours                       => x_clock_hours,
      x_other_credit_points               => x_other_credit_points,
      x_same_teaching_period              => x_same_teaching_period,
      x_same_teach_period_repeats         => x_same_teach_period_repeats,
      x_same_teach_period_repeats_cp      => x_same_teach_period_repeats_cp,
      x_state_financial_aid               => x_state_financial_aid,
      x_work_load_cp_lab                  => x_work_load_cp_lab,
      x_work_load_cp_lecture              => x_work_load_cp_lecture,
      x_subtitle_modifiable_flag          => x_subtitle_modifiable_flag,
      x_subtitle                          => x_subtitle,
      x_special_permission_ind            => x_special_permission_ind,
      x_creation_date => X_LAST_UPDATE_DATE,
      x_created_by => X_LAST_UPDATED_BY,
      x_last_update_date => X_LAST_UPDATE_DATE,
      x_last_updated_by => X_LAST_UPDATED_BY,
      x_last_update_login => X_LAST_UPDATE_LOGIN,
      x_org_id => igs_ge_gen_003.get_org_id,
      x_ss_enrol_ind => X_SS_ENROL_IND,
      x_ivr_enrol_ind => X_IVR_ENROL_IND,
      x_claimable_hours => x_claimable_hours,
      x_auditable_ind			  => x_auditable_ind,
      x_audit_permission_ind              => x_audit_permission_ind,
      x_max_auditors_allowed              => x_max_auditors_allowed,
      x_billing_credit_points             => x_billing_credit_points,
      x_ovrd_wkld_val_flag                => x_ovrd_wkld_val_flag,
      x_workload_val_code                 => x_workload_val_code,
      x_billing_hrs                       => x_billing_hrs
  );

  INSERT INTO IGS_PS_UNIT_VER_HIST_ALL (
    UNIT_CD,
    VERSION_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    START_DT,
    REVIEW_DT,
    EXPIRY_DT,
    END_DT,
    UNIT_STATUS,
    TITLE,
    SHORT_TITLE,
    TITLE_OVERRIDE_IND,
    ABBREVIATION,
    UNIT_LEVEL,
    UL_DESCRIPTION,
    CREDIT_POINT_DESCRIPTOR,
    ENROLLED_CREDIT_POINTS,
    POINTS_OVERRIDE_IND,
    SUPP_EXAM_PERMITTED_IND,
    COORD_PERSON_ID,
    OWNER_ORG_UNIT_CD,
    OWNER_OU_START_DT,
    OU_DESCRIPTION,
    AWARD_COURSE_ONLY_IND,
    RESEARCH_UNIT_IND,
    INDUSTRIAL_IND,
    PRACTICAL_IND,
    REPEATABLE_IND,
    ASSESSABLE_IND,
    ACHIEVABLE_CREDIT_POINTS,
    POINTS_INCREMENT,
    POINTS_MIN,
    POINTS_MAX,
    UNIT_INT_COURSE_LEVEL_CD,
    UICL_DESCRIPTION,
      subtitle_id,
      work_load_other,
      contact_hrs_lecture,
      contact_hrs_lab,
      contact_hrs_other,
      non_schd_required_hrs,
      exclude_from_max_cp_limit,
      record_exclusion_flag,
      ss_display_ind,
      cal_type_enrol_load_cal,
      sequence_num_enrol_load_cal,
      cal_type_offer_load_cal,
      sequence_num_offer_load_cal,
      curriculum_id,
      override_enrollment_max,
      rpt_fmly_id,
      repeat_code,
      unit_type_id,
      level_code,
      advance_maximum,
      approval_date,
      continuing_education_units,
      enrollment_expected,
      enrollment_maximum,
      enrollment_minimum,
      federal_financial_aid,
      institutional_financial_aid,
      lab_credit_points,
      lecture_credit_points,
      max_repeats_for_credit,
      max_repeats_for_funding,
      max_repeat_credit_points,
      clock_hours,
      other_credit_points,
      same_teaching_period,
      same_teach_period_repeats,
      same_teach_period_repeats_cp,
      state_financial_aid,
      work_load_cp_lab,
      work_load_cp_lecture,
      subtitle_modifiable_flag,
      subtitle,
      special_permission_ind,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    SS_ENROL_IND,
    IVR_ENROL_IND,
    claimable_hours,
    auditable_ind,
    audit_permission_ind,
    max_auditors_allowed,
    billing_credit_points,
    ovrd_wkld_val_flag,
    workload_val_code,
    billing_hrs
  ) values (
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.REVIEW_DT,
    NEW_REFERENCES.EXPIRY_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.UNIT_STATUS,
    NEW_REFERENCES.TITLE,
    NEW_REFERENCES.SHORT_TITLE,
    NEW_REFERENCES.TITLE_OVERRIDE_IND,
    NEW_REFERENCES.ABBREVIATION,
    NEW_REFERENCES.UNIT_LEVEL,
    NEW_REFERENCES.UL_DESCRIPTION,
    NEW_REFERENCES.CREDIT_POINT_DESCRIPTOR,
    NEW_REFERENCES.ENROLLED_CREDIT_POINTS,
    NEW_REFERENCES.POINTS_OVERRIDE_IND,
    NEW_REFERENCES.SUPP_EXAM_PERMITTED_IND,
    NEW_REFERENCES.COORD_PERSON_ID,
    NEW_REFERENCES.OWNER_ORG_UNIT_CD,
    NEW_REFERENCES.OWNER_OU_START_DT,
    NEW_REFERENCES.OU_DESCRIPTION,
    NEW_REFERENCES.AWARD_COURSE_ONLY_IND,
    NEW_REFERENCES.RESEARCH_UNIT_IND,
    NEW_REFERENCES.INDUSTRIAL_IND,
    NEW_REFERENCES.PRACTICAL_IND,
    NEW_REFERENCES.REPEATABLE_IND,
    NEW_REFERENCES.ASSESSABLE_IND,
    NEW_REFERENCES.ACHIEVABLE_CREDIT_POINTS,
    NEW_REFERENCES.POINTS_INCREMENT,
    NEW_REFERENCES.POINTS_MIN,
    NEW_REFERENCES.POINTS_MAX,
    NEW_REFERENCES.UNIT_INT_COURSE_LEVEL_CD,
    NEW_REFERENCES.UICL_DESCRIPTION,
      new_references.subtitle_id,
      new_references.work_load_other,
      new_references.contact_hrs_lecture,
      new_references.contact_hrs_lab,
      new_references.contact_hrs_other,
      new_references.non_schd_required_hrs,
      new_references.exclude_from_max_cp_limit,
      new_references.record_exclusion_flag,
      new_references.ss_display_ind,
      new_references.cal_type_enrol_load_cal,
      new_references.sequence_num_enrol_load_cal,
      new_references.cal_type_offer_load_cal,
      new_references.sequence_num_offer_load_cal,
      new_references.curriculum_id,
      new_references.override_enrollment_max,
      new_references.rpt_fmly_id,
      new_references.repeat_code,
      new_references.unit_type_id,
      new_references.level_code,
      new_references.advance_maximum,
      new_references.approval_date,
      new_references.continuing_education_units,
      new_references.enrollment_expected,
      new_references.enrollment_maximum,
      new_references.enrollment_minimum,
      new_references.federal_financial_aid,
      new_references.institutional_financial_aid,
      new_references.lab_credit_points,
      new_references.lecture_credit_points,
      new_references.max_repeats_for_credit,
      new_references.max_repeats_for_funding,
      new_references.max_repeat_credit_points,
      new_references.clock_hours,
      new_references.other_credit_points,
      new_references.same_teaching_period,
      new_references.same_teach_period_repeats,
      new_references.same_teach_period_repeats_cp,
      new_references.state_financial_aid,
      new_references.work_load_cp_lab,
      new_references.work_load_cp_lecture,
      new_references.subtitle_modifiable_flag,
      new_references.subtitle,
      new_references.special_permission_ind,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_DATE,
      X_LAST_UPDATED_BY,
      X_LAST_UPDATE_LOGIN,
      NEW_REFERENCES.ORG_ID,
      NEW_REFERENCES.SS_ENROL_IND,
      NEW_REFERENCES.IVR_ENROL_IND,
      new_references.claimable_hours,
      new_references.auditable_ind,
      new_references.audit_permission_ind,
      new_references.max_auditors_allowed,
      new_references.billing_credit_points,
      new_references.ovrd_wkld_val_flag,
      new_references.workload_val_code,
      new_references.billing_hrs
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID
    );

END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_UL_DESCRIPTION in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_UICL_DESCRIPTION in VARCHAR2,
  x_subtitle_id                         IN     NUMBER ,
    x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind                    IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal       IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal       IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_repeat_code                       IN     VARCHAR2 ,
    x_unit_type_id                      IN     NUMBER ,
    x_level_code                        IN     VARCHAR2 ,
    x_advance_maximum                   IN     NUMBER ,
    x_approval_date                     IN     DATE ,
    x_continuing_education_units        IN     NUMBER ,
    x_enrollment_expected               IN     NUMBER ,
    x_enrollment_maximum                IN     NUMBER ,
    x_enrollment_minimum                IN     NUMBER ,
    x_federal_financial_aid             IN     VARCHAR2 ,
    x_institutional_financial_aid       IN     VARCHAR2 ,
    x_lab_credit_points                 IN     NUMBER ,
    x_lecture_credit_points             IN     NUMBER ,
    x_max_repeats_for_credit            IN     NUMBER ,
    x_max_repeats_for_funding           IN     NUMBER ,
    x_max_repeat_credit_points          IN     NUMBER ,
    x_clock_hours                       IN     NUMBER ,
    x_other_credit_points               IN     NUMBER ,
    x_same_teaching_period              IN     VARCHAR2 ,
    x_same_teach_period_repeats         IN     NUMBER ,
    x_same_teach_period_repeats_cp      IN     NUMBER ,
    x_state_financial_aid               IN     VARCHAR2 ,
    x_work_load_cp_lab                  IN     NUMBER ,
    x_work_load_cp_lecture              IN     NUMBER ,
    x_subtitle_modifiable_flag          IN     VARCHAR2 ,
    x_subtitle                          IN     VARCHAR2 ,
    x_special_permission_ind            IN     VARCHAR2 ,
    X_SS_ENROL_IND                      IN     VARCHAR2,
    X_IVR_ENROL_IND                     IN     VARCHAR2,
    x_claimable_hours                   IN     NUMBER ,
    x_auditable_ind			IN     VARCHAR2 ,
    x_audit_permission_ind		IN     VARCHAR2 ,
    x_max_auditors_allowed		IN     NUMBER ,
    x_billing_credit_points             IN     NUMBER ,
    x_ovrd_wkld_val_flag                IN     VARCHAR2 ,
    x_workload_val_code                 IN     VARCHAR2 ,
    x_billing_hrs                       IN     NUMBER
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      START_DT,
      REVIEW_DT,
      EXPIRY_DT,
      END_DT,
      UNIT_STATUS,
      TITLE,
      SHORT_TITLE,
      TITLE_OVERRIDE_IND,
      ABBREVIATION,
      UNIT_LEVEL,
      UL_DESCRIPTION,
      CREDIT_POINT_DESCRIPTOR,
      ENROLLED_CREDIT_POINTS,
      POINTS_OVERRIDE_IND,
      SUPP_EXAM_PERMITTED_IND,
      COORD_PERSON_ID,
      OWNER_ORG_UNIT_CD,
      OWNER_OU_START_DT,
      OU_DESCRIPTION,
      AWARD_COURSE_ONLY_IND,
      RESEARCH_UNIT_IND,
      INDUSTRIAL_IND,
      PRACTICAL_IND,
      REPEATABLE_IND,
      ASSESSABLE_IND,
      ACHIEVABLE_CREDIT_POINTS,
      POINTS_INCREMENT,
      POINTS_MIN,
      POINTS_MAX,
      UNIT_INT_COURSE_LEVEL_CD,
      UICL_DESCRIPTION,
      subtitle_id,
        work_load_other,
        contact_hrs_lecture,
        contact_hrs_lab,
        contact_hrs_other,
        non_schd_required_hrs,
        exclude_from_max_cp_limit,
        record_exclusion_flag,
        ss_display_ind,
        cal_type_enrol_load_cal,
        sequence_num_enrol_load_cal,
        cal_type_offer_load_cal,
        sequence_num_offer_load_cal,
        curriculum_id,
        override_enrollment_max,
        rpt_fmly_id,
        repeat_code,
        unit_type_id,
        level_code,
        advance_maximum,
        approval_date,
        continuing_education_units,
        enrollment_expected,
        enrollment_maximum,
        enrollment_minimum,
        federal_financial_aid,
        institutional_financial_aid,
        lab_credit_points,
        lecture_credit_points,
        max_repeats_for_credit,
        max_repeats_for_funding,
        max_repeat_credit_points,
        clock_hours,
        other_credit_points,
        same_teaching_period,
        same_teach_period_repeats,
        same_teach_period_repeats_cp,
        state_financial_aid,
        work_load_cp_lab,
        work_load_cp_lecture,
        subtitle_modifiable_flag,
        subtitle,
        special_permission_ind,
        SS_ENROL_IND,
        IVR_ENROL_IND,
        claimable_hours,
        auditable_ind,
        audit_permission_ind,
        max_auditors_allowed,
        billing_credit_points,
        ovrd_wkld_val_flag,
        workload_val_code,
        billing_hrs
    from IGS_PS_UNIT_VER_HIST_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
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
      AND ((tlinfo.UNIT_STATUS = X_UNIT_STATUS)
           OR ((tlinfo.UNIT_STATUS is null)
               AND (X_UNIT_STATUS is null)))
      AND ((tlinfo.TITLE = X_TITLE)
           OR ((tlinfo.TITLE is null)
               AND (X_TITLE is null)))
      AND ((tlinfo.SHORT_TITLE = X_SHORT_TITLE)
           OR ((tlinfo.SHORT_TITLE is null)
               AND (X_SHORT_TITLE is null)))
      AND ((tlinfo.TITLE_OVERRIDE_IND = X_TITLE_OVERRIDE_IND)
           OR ((tlinfo.TITLE_OVERRIDE_IND is null)
               AND (X_TITLE_OVERRIDE_IND is null)))
      AND ((tlinfo.ABBREVIATION = X_ABBREVIATION)
           OR ((tlinfo.ABBREVIATION is null)
               AND (X_ABBREVIATION is null)))
      AND ((tlinfo.UNIT_LEVEL = X_UNIT_LEVEL)
           OR ((tlinfo.UNIT_LEVEL is null)
               AND (X_UNIT_LEVEL is null)))
      AND ((tlinfo.UL_DESCRIPTION = X_UL_DESCRIPTION)
           OR ((tlinfo.UL_DESCRIPTION is null)
               AND (X_UL_DESCRIPTION is null)))
      AND ((tlinfo.CREDIT_POINT_DESCRIPTOR = X_CREDIT_POINT_DESCRIPTOR)
           OR ((tlinfo.CREDIT_POINT_DESCRIPTOR is null)
               AND (X_CREDIT_POINT_DESCRIPTOR is null)))
      AND ((tlinfo.ENROLLED_CREDIT_POINTS = X_ENROLLED_CREDIT_POINTS)
           OR ((tlinfo.ENROLLED_CREDIT_POINTS is null)
               AND (X_ENROLLED_CREDIT_POINTS is null)))
      AND ((tlinfo.POINTS_OVERRIDE_IND = X_POINTS_OVERRIDE_IND)
           OR ((tlinfo.POINTS_OVERRIDE_IND is null)
               AND (X_POINTS_OVERRIDE_IND is null)))
      AND ((tlinfo.SUPP_EXAM_PERMITTED_IND = X_SUPP_EXAM_PERMITTED_IND)
           OR ((tlinfo.SUPP_EXAM_PERMITTED_IND is null)
               AND (X_SUPP_EXAM_PERMITTED_IND is null)))
      AND ((tlinfo.COORD_PERSON_ID = X_COORD_PERSON_ID)
           OR ((tlinfo.COORD_PERSON_ID is null)
               AND (X_COORD_PERSON_ID is null)))
      AND ((tlinfo.OWNER_ORG_UNIT_CD = X_OWNER_ORG_UNIT_CD)
           OR ((tlinfo.OWNER_ORG_UNIT_CD is null)
               AND (X_OWNER_ORG_UNIT_CD is null)))
      AND ((tlinfo.OWNER_OU_START_DT = X_OWNER_OU_START_DT)
           OR ((tlinfo.OWNER_OU_START_DT is null)
               AND (X_OWNER_OU_START_DT is null)))
      AND ((tlinfo.OU_DESCRIPTION = X_OU_DESCRIPTION)
           OR ((tlinfo.OU_DESCRIPTION is null)
               AND (X_OU_DESCRIPTION is null)))
      AND ((tlinfo.AWARD_COURSE_ONLY_IND = X_AWARD_COURSE_ONLY_IND)
           OR ((tlinfo.AWARD_COURSE_ONLY_IND is null)
               AND (X_AWARD_COURSE_ONLY_IND is null)))
      AND ((tlinfo.RESEARCH_UNIT_IND = X_RESEARCH_UNIT_IND)
           OR ((tlinfo.RESEARCH_UNIT_IND is null)
               AND (X_RESEARCH_UNIT_IND is null)))
      AND ((tlinfo.INDUSTRIAL_IND = X_INDUSTRIAL_IND)
           OR ((tlinfo.INDUSTRIAL_IND is null)
               AND (X_INDUSTRIAL_IND is null)))
      AND ((tlinfo.PRACTICAL_IND = X_PRACTICAL_IND)
           OR ((tlinfo.PRACTICAL_IND is null)
               AND (X_PRACTICAL_IND is null)))
      AND ((tlinfo.REPEATABLE_IND = X_REPEATABLE_IND)
           OR ((tlinfo.REPEATABLE_IND is null)
               AND (X_REPEATABLE_IND is null)))
      AND ((tlinfo.ASSESSABLE_IND = X_ASSESSABLE_IND)
           OR ((tlinfo.ASSESSABLE_IND is null)
               AND (X_ASSESSABLE_IND is null)))
      AND ((tlinfo.ACHIEVABLE_CREDIT_POINTS = X_ACHIEVABLE_CREDIT_POINTS)
           OR ((tlinfo.ACHIEVABLE_CREDIT_POINTS is null)
               AND (X_ACHIEVABLE_CREDIT_POINTS is null)))
      AND ((tlinfo.POINTS_INCREMENT = X_POINTS_INCREMENT)
           OR ((tlinfo.POINTS_INCREMENT is null)
               AND (X_POINTS_INCREMENT is null)))
      AND ((tlinfo.POINTS_MIN = X_POINTS_MIN)
           OR ((tlinfo.POINTS_MIN is null)
               AND (X_POINTS_MIN is null)))
      AND ((tlinfo.POINTS_MAX = X_POINTS_MAX)
           OR ((tlinfo.POINTS_MAX is null)
               AND (X_POINTS_MAX is null)))
      AND ((tlinfo.UNIT_INT_COURSE_LEVEL_CD = X_UNIT_INT_COURSE_LEVEL_CD)
           OR ((tlinfo.UNIT_INT_COURSE_LEVEL_CD is null)
               AND (X_UNIT_INT_COURSE_LEVEL_CD is null)))
      AND ((tlinfo.UICL_DESCRIPTION = X_UICL_DESCRIPTION)
           OR ((tlinfo.UICL_DESCRIPTION is null)
               AND (X_SS_ENROL_IND is null)))
      AND ((tlinfo.subtitle_id = x_subtitle_id)
           OR ((tlinfo.subtitle_id IS NULL)
              AND (X_subtitle_id IS NULL)))
      AND ((tlinfo.work_load_other = x_work_load_other)
           OR ((tlinfo.work_load_other IS NULL)
               AND (X_work_load_other IS NULL)))
      AND ((tlinfo.contact_hrs_lecture = x_contact_hrs_lecture)
           OR ((tlinfo.contact_hrs_lecture IS NULL)
               AND (X_contact_hrs_lecture IS NULL)))
      AND ((tlinfo.contact_hrs_lab = x_contact_hrs_lab)
           OR ((tlinfo.contact_hrs_lab IS NULL)
             AND (X_contact_hrs_lab IS NULL)))
      AND ((tlinfo.contact_hrs_other = x_contact_hrs_other)
           OR ((tlinfo.contact_hrs_other IS NULL)
              AND (X_contact_hrs_other IS NULL)))
      AND ((tlinfo.non_schd_required_hrs = x_non_schd_required_hrs)
           OR ((tlinfo.non_schd_required_hrs IS NULL)
              AND (X_non_schd_required_hrs IS NULL)))
      AND ((tlinfo.exclude_from_max_cp_limit = x_exclude_from_max_cp_limit)
           OR ((tlinfo.exclude_from_max_cp_limit IS NULL)
              AND (X_exclude_from_max_cp_limit IS NULL)))
      AND ((tlinfo.record_exclusion_flag = x_record_exclusion_flag)
           OR ((tlinfo.record_exclusion_flag IS NULL)
              AND (X_record_exclusion_flag IS NULL)))
      AND ((tlinfo.ss_display_ind = x_ss_display_ind)
           OR ((tlinfo.ss_display_ind IS NULL) AND (X_ss_display_ind IS NULL)))
      AND ((tlinfo.cal_type_enrol_load_cal = x_cal_type_enrol_load_cal)
           OR ((tlinfo.cal_type_enrol_load_cal IS NULL)
              AND (X_cal_type_enrol_load_cal IS NULL)))
      AND ((tlinfo.sequence_num_enrol_load_cal = x_sequence_num_enrol_load_cal)
           OR ((tlinfo.sequence_num_enrol_load_cal IS NULL)
              AND (X_sequence_num_enrol_load_cal IS NULL)))
      AND ((tlinfo.cal_type_offer_load_cal = x_cal_type_offer_load_cal)
           OR ((tlinfo.cal_type_offer_load_cal IS NULL)
              AND (X_cal_type_offer_load_cal IS NULL)))
      AND ((tlinfo.sequence_num_offer_load_cal = x_sequence_num_offer_load_cal)
           OR ((tlinfo.sequence_num_offer_load_cal IS NULL)
              AND (X_sequence_num_offer_load_cal IS NULL)))
      AND ((tlinfo.curriculum_id = x_curriculum_id)
           OR ((tlinfo.curriculum_id IS NULL)
              AND (X_curriculum_id IS NULL)))
      AND ((tlinfo.override_enrollment_max = x_override_enrollment_max)
           OR ((tlinfo.override_enrollment_max IS NULL)
              AND (X_override_enrollment_max IS NULL)))
      AND ((tlinfo.rpt_fmly_id = x_rpt_fmly_id)
           OR ((tlinfo.rpt_fmly_id IS NULL)
              AND (X_rpt_fmly_id IS NULL)))
      AND ((tlinfo.repeat_code = x_repeat_code)
           OR ((tlinfo.repeat_code IS NULL)
              AND (X_repeat_code IS NULL)))
      AND ((tlinfo.unit_type_id = x_unit_type_id)
           OR ((tlinfo.unit_type_id IS NULL)
              AND (X_unit_type_id IS NULL)))
      AND ((tlinfo.level_code = x_level_code)
           OR ((tlinfo.level_code IS NULL)
              AND (X_level_code IS NULL)))
      AND ((tlinfo.advance_maximum = x_advance_maximum)
           OR ((tlinfo.advance_maximum IS NULL)
              AND (X_advance_maximum IS NULL)))
      AND ((tlinfo.approval_date = x_approval_date)
           OR ((tlinfo.approval_date IS NULL)
              AND (X_approval_date IS NULL)))
      AND ((tlinfo.continuing_education_units = x_continuing_education_units)
           OR ((tlinfo.continuing_education_units IS NULL)
              AND (X_continuing_education_units IS NULL)))
      AND ((tlinfo.enrollment_expected = x_enrollment_expected)
           OR ((tlinfo.enrollment_expected IS NULL)
              AND (X_enrollment_expected IS NULL)))
      AND ((tlinfo.enrollment_maximum = x_enrollment_maximum)
           OR ((tlinfo.enrollment_maximum IS NULL)
              AND (X_enrollment_maximum IS NULL)))
      AND ((tlinfo.enrollment_minimum = x_enrollment_minimum)
           OR ((tlinfo.enrollment_minimum IS NULL)
              AND (X_enrollment_minimum IS NULL)))
      AND ((tlinfo.federal_financial_aid = x_federal_financial_aid)
           OR ((tlinfo.federal_financial_aid IS NULL)
              AND (X_federal_financial_aid IS NULL)))
      AND ((tlinfo.institutional_financial_aid = x_institutional_financial_aid)
           OR ((tlinfo.institutional_financial_aid IS NULL)
              AND (X_institutional_financial_aid IS NULL)))
      AND ((tlinfo.lab_credit_points = x_lab_credit_points)
           OR ((tlinfo.lab_credit_points IS NULL)
              AND (X_lab_credit_points IS NULL)))
      AND ((tlinfo.lecture_credit_points = x_lecture_credit_points)
           OR ((tlinfo.lecture_credit_points IS NULL)
              AND (X_lecture_credit_points IS NULL)))
      AND ((tlinfo.max_repeats_for_credit = x_max_repeats_for_credit)
           OR ((tlinfo.max_repeats_for_credit IS NULL)
              AND (X_max_repeats_for_credit IS NULL)))
      AND ((tlinfo.max_repeats_for_funding = x_max_repeats_for_funding)
           OR ((tlinfo.max_repeats_for_funding IS NULL)
              AND (X_max_repeats_for_funding IS NULL)))
      AND ((tlinfo.max_repeat_credit_points = x_max_repeat_credit_points)
           OR ((tlinfo.max_repeat_credit_points IS NULL)
              AND (X_max_repeat_credit_points IS NULL)))
      AND ((tlinfo.clock_hours = x_clock_hours)
           OR ((tlinfo.clock_hours IS NULL)
              AND (X_clock_hours IS NULL)))
      AND ((tlinfo.other_credit_points = x_other_credit_points)
           OR ((tlinfo.other_credit_points IS NULL)
              AND (X_other_credit_points IS NULL)))
      AND ((tlinfo.same_teaching_period = x_same_teaching_period)
           OR ((tlinfo.same_teaching_period IS NULL)
              AND (X_same_teaching_period IS NULL)))
      AND ((tlinfo.same_teach_period_repeats = x_same_teach_period_repeats)
           OR ((tlinfo.same_teach_period_repeats IS NULL)
              AND (X_same_teach_period_repeats IS NULL)))
      AND ((tlinfo.same_teach_period_repeats_cp = x_same_teach_period_repeats_cp)
           OR ((tlinfo.same_teach_period_repeats_cp IS NULL)
              AND (X_same_teach_period_repeats_cp IS NULL)))
      AND ((tlinfo.state_financial_aid = x_state_financial_aid)
           OR ((tlinfo.state_financial_aid IS NULL)
              AND (X_state_financial_aid IS NULL)))
      AND ((tlinfo.work_load_cp_lab = x_work_load_cp_lab)
           OR ((tlinfo.work_load_cp_lab IS NULL)
              AND (X_work_load_cp_lab IS NULL)))
      AND ((tlinfo.work_load_cp_lecture = x_work_load_cp_lecture)
           OR ((tlinfo.work_load_cp_lecture IS NULL)
              AND (X_work_load_cp_lecture IS NULL)))
      AND ((tlinfo.subtitle_modifiable_flag = x_subtitle_modifiable_flag)
           OR ((tlinfo.subtitle_modifiable_flag IS NULL)
              AND (X_subtitle_modifiable_flag IS NULL)))
      AND ((tlinfo.subtitle = x_subtitle)
           OR ((tlinfo.subtitle IS NULL)
              AND (X_subtitle IS NULL)))
      AND ((tlinfo.special_permission_ind = x_special_permission_ind)
           OR ((tlinfo.special_permission_ind IS NULL)
              AND (X_special_permission_ind IS NULL)))
      AND ((tlinfo.SS_ENROL_IND = X_SS_ENROL_IND )
           OR ((tlinfo.SS_ENROL_IND is null)
               AND (X_SS_ENROL_IND is null)))
      AND ((tlinfo.IVR_ENROL_IND = X_IVR_ENROL_IND )
           OR ((tlinfo.IVR_ENROL_IND is null)
               AND (X_IVR_ENROL_IND is null)))
      AND ((tlinfo.claimable_hours= x_claimable_hours)
           OR ((tlinfo.claimable_hours is null)
               AND (x_claimable_hours is null)))
      AND ((tlinfo.auditable_ind = x_auditable_ind)
           OR ((tlinfo.auditable_ind IS NULL)
              AND (X_auditable_ind IS NULL)))
      AND ((tlinfo.audit_permission_ind = x_audit_permission_ind)
           OR ((tlinfo.audit_permission_ind IS NULL)
              AND (X_audit_permission_ind IS NULL)))
      AND ((tlinfo.max_auditors_allowed = x_max_auditors_allowed)
           OR ((tlinfo.max_auditors_allowed IS NULL)
              AND (X_max_auditors_allowed IS NULL)))
      AND ((tlinfo.billing_credit_points = x_billing_credit_points)
           OR ((tlinfo.billing_credit_points IS NULL)
              AND (X_billing_credit_points IS NULL)))
      AND  ((tlinfo.OVRD_WKLD_VAL_FLAG= X_OVRD_WKLD_VAL_FLAG)
           OR ((tlinfo.OVRD_WKLD_VAL_FLAG IS NULL)
               AND (X_OVRD_WKLD_VAL_FLAG IS NULL)))
      AND  ((tlinfo.WORKLOAD_VAL_CODE= X_WORKLOAD_VAL_CODE)
           OR ((tlinfo.WORKLOAD_VAL_CODE IS NULL)
               AND (X_WORKLOAD_VAL_CODE IS NULL)))
      AND  ((tlinfo.BILLING_HRS= X_BILLING_HRS)
           OR ((tlinfo.BILLING_HRS IS NULL)
               AND (X_BILLING_HRS IS NULL)))
    ) THEN
    NULL;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_UL_DESCRIPTION in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_UICL_DESCRIPTION in VARCHAR2,
  x_subtitle_id                         IN     NUMBER ,
    x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind                    IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal       IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal       IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_repeat_code                       IN     VARCHAR2 ,
    x_unit_type_id                      IN     NUMBER ,
    x_level_code                        IN     VARCHAR2 ,
    x_advance_maximum                   IN     NUMBER ,
    x_approval_date                     IN     DATE ,
    x_continuing_education_units        IN     NUMBER ,
    x_enrollment_expected               IN     NUMBER ,
    x_enrollment_maximum                IN     NUMBER ,
    x_enrollment_minimum                IN     NUMBER ,
    x_federal_financial_aid             IN     VARCHAR2 ,
    x_institutional_financial_aid       IN     VARCHAR2 ,
    x_lab_credit_points                 IN     NUMBER ,
    x_lecture_credit_points             IN     NUMBER ,
    x_max_repeats_for_credit            IN     NUMBER ,
    x_max_repeats_for_funding           IN     NUMBER ,
    x_max_repeat_credit_points          IN     NUMBER ,
    x_clock_hours                       IN     NUMBER ,
    x_other_credit_points               IN     NUMBER ,
    x_same_teaching_period              IN     VARCHAR2 ,
    x_same_teach_period_repeats         IN     NUMBER ,
    x_same_teach_period_repeats_cp      IN     NUMBER ,
    x_state_financial_aid               IN     VARCHAR2 ,
    x_work_load_cp_lab                  IN     NUMBER ,
    x_work_load_cp_lecture              IN     NUMBER ,
    x_subtitle_modifiable_flag          IN     VARCHAR2 ,
    x_subtitle                          IN     VARCHAR2 ,
    x_special_permission_ind            IN     VARCHAR2 ,
    X_MODE                              IN     VARCHAR2 ,
    X_SS_ENROL_IND                      IN     VARCHAR2 ,
    X_IVR_ENROL_IND                     IN     VARCHAR2 ,
    x_claimable_hours                   IN     NUMBER ,
    x_auditable_ind			IN     VARCHAR2 ,
    x_audit_permission_ind		IN     VARCHAR2 ,
    x_max_auditors_allowed		IN     NUMBER,
    x_billing_credit_points             IN     NUMBER ,
    x_ovrd_wkld_val_flag                IN     VARCHAR2 ,
    x_workload_val_code                 IN     VARCHAR2 ,
    x_billing_hrs                       IN     NUMBER
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  Before_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_hist_start_dt => X_HIST_START_DT,
  x_hist_end_dt => X_HIST_END_DT,
  x_hist_who => X_HIST_WHO,
  x_start_dt => X_START_DT,
  x_review_dt => X_REVIEW_DT,
  x_expiry_dt => X_EXPIRY_DT,
  x_end_dt => X_END_DT,
  x_unit_status => X_UNIT_STATUS,
  x_title => X_TITLE,
  x_short_title => X_SHORT_TITLE,
  x_title_override_ind => X_TITLE_OVERRIDE_IND,
  x_abbreviation => X_ABBREVIATION,
  x_unit_level => X_UNIT_LEVEL,
  x_ul_description => X_UL_DESCRIPTION,
  x_credit_point_descriptor => X_CREDIT_POINT_DESCRIPTOR,
  x_enrolled_credit_points => X_ENROLLED_CREDIT_POINTS,
  x_points_override_ind => X_POINTS_OVERRIDE_IND,
  x_supp_exam_permitted_ind => X_SUPP_EXAM_PERMITTED_IND,
  x_coord_person_id => X_COORD_PERSON_ID,
  x_owner_org_unit_cd => X_OWNER_ORG_UNIT_CD,
  x_owner_ou_start_dt => X_OWNER_OU_START_DT,
  x_ou_description => X_OU_DESCRIPTION,
  x_award_course_only_ind => X_AWARD_COURSE_ONLY_IND,
  x_research_unit_ind => X_RESEARCH_UNIT_IND,
  x_industrial_ind => X_INDUSTRIAL_IND,
  x_practical_ind => X_PRACTICAL_IND,
  x_repeatable_ind => X_REPEATABLE_IND,
  x_assessable_ind => X_ASSESSABLE_IND,
  x_achievable_credit_points => X_ACHIEVABLE_CREDIT_POINTS,
  x_points_increment => X_POINTS_INCREMENT,
  x_points_min => X_POINTS_MIN,
  x_points_max => X_POINTS_MAX,
  x_unit_int_course_level_cd => X_UNIT_INT_COURSE_LEVEL_CD,
  x_uicl_description => X_UICL_DESCRIPTION,
  x_subtitle_id                       => x_subtitle_id,
      x_work_load_other                   => x_work_load_other,
      x_contact_hrs_lecture               => x_contact_hrs_lecture,
      x_contact_hrs_lab                   => x_contact_hrs_lab,
      x_contact_hrs_other                 => x_contact_hrs_other,
      x_non_schd_required_hrs             => x_non_schd_required_hrs,
      x_exclude_from_max_cp_limit         => x_exclude_from_max_cp_limit,
      x_record_exclusion_flag             => x_record_exclusion_flag,
      x_ss_display_ind       => x_ss_display_ind,
      x_cal_type_enrol_load_cal           => x_cal_type_enrol_load_cal,
      x_sequence_num_enrol_load_cal    => x_sequence_num_enrol_load_cal,
      x_cal_type_offer_load_cal           => x_cal_type_offer_load_cal,
      x_sequence_num_offer_load_cal    => x_sequence_num_offer_load_cal,
      x_curriculum_id                     => x_curriculum_id,
      x_override_enrollment_max           => x_override_enrollment_max,
      x_rpt_fmly_id                       => x_rpt_fmly_id,
      x_repeat_code                       => x_repeat_code,
      x_unit_type_id                      => x_unit_type_id,
      x_level_code                        => x_level_code,
      x_advance_maximum                   => x_advance_maximum,
      x_approval_date                     => x_approval_date,
      x_continuing_education_units        => x_continuing_education_units,
      x_enrollment_expected               => x_enrollment_expected,
      x_enrollment_maximum                => x_enrollment_maximum,
      x_enrollment_minimum                => x_enrollment_minimum,
      x_federal_financial_aid             => x_federal_financial_aid,
      x_institutional_financial_aid       => x_institutional_financial_aid,
      x_lab_credit_points                 => x_lab_credit_points,
      x_lecture_credit_points             => x_lecture_credit_points,
      x_max_repeats_for_credit            => x_max_repeats_for_credit,
      x_max_repeats_for_funding           => x_max_repeats_for_funding,
      x_max_repeat_credit_points          => x_max_repeat_credit_points,
      x_clock_hours                       => x_clock_hours,
      x_other_credit_points               => x_other_credit_points,
      x_same_teaching_period              => x_same_teaching_period,
      x_same_teach_period_repeats         => x_same_teach_period_repeats,
      x_same_teach_period_repeats_cp      => x_same_teach_period_repeats_cp,
      x_state_financial_aid               => x_state_financial_aid,
      x_work_load_cp_lab                  => x_work_load_cp_lab,
      x_work_load_cp_lecture              => x_work_load_cp_lecture,
      x_subtitle_modifiable_flag          => x_subtitle_modifiable_flag,
      x_subtitle                          => x_subtitle,
      x_special_permission_ind            => x_special_permission_ind,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_ss_enrol_ind => X_SS_ENROL_IND,
  x_ivr_enrol_ind => X_IVR_ENROL_IND,
  x_claimable_hours => x_claimable_hours,
  x_auditable_ind			  => x_auditable_ind,
  x_audit_permission_ind		  => x_audit_permission_ind,
  x_max_auditors_allowed		  => x_max_auditors_allowed,
  x_billing_credit_points                 => x_billing_credit_points,
  x_ovrd_wkld_val_flag                    => x_ovrd_wkld_val_flag ,
  x_workload_val_code                     => x_workload_val_code,
  x_billing_hrs                           => x_billing_hrs
  );

  UPDATE IGS_PS_UNIT_VER_HIST_ALL SET
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    START_DT = NEW_REFERENCES.START_DT,
    REVIEW_DT = NEW_REFERENCES.REVIEW_DT,
    EXPIRY_DT = NEW_REFERENCES.EXPIRY_DT,
    END_DT = NEW_REFERENCES.END_DT,
    UNIT_STATUS = NEW_REFERENCES.UNIT_STATUS,
    TITLE = NEW_REFERENCES.TITLE,
    SHORT_TITLE = NEW_REFERENCES.SHORT_TITLE,
    TITLE_OVERRIDE_IND = NEW_REFERENCES.TITLE_OVERRIDE_IND,
    ABBREVIATION = NEW_REFERENCES.ABBREVIATION,
    UNIT_LEVEL = NEW_REFERENCES.UNIT_LEVEL,
    UL_DESCRIPTION = NEW_REFERENCES.UL_DESCRIPTION,
    CREDIT_POINT_DESCRIPTOR = NEW_REFERENCES.CREDIT_POINT_DESCRIPTOR,
    ENROLLED_CREDIT_POINTS = NEW_REFERENCES.ENROLLED_CREDIT_POINTS,
    POINTS_OVERRIDE_IND = NEW_REFERENCES.POINTS_OVERRIDE_IND,
    SUPP_EXAM_PERMITTED_IND = NEW_REFERENCES.SUPP_EXAM_PERMITTED_IND,
    COORD_PERSON_ID = NEW_REFERENCES.COORD_PERSON_ID,
    OWNER_ORG_UNIT_CD = NEW_REFERENCES.OWNER_ORG_UNIT_CD,
    OWNER_OU_START_DT = NEW_REFERENCES.OWNER_OU_START_DT,
    OU_DESCRIPTION = NEW_REFERENCES.OU_DESCRIPTION,
    AWARD_COURSE_ONLY_IND = NEW_REFERENCES.AWARD_COURSE_ONLY_IND,
    RESEARCH_UNIT_IND = NEW_REFERENCES.RESEARCH_UNIT_IND,
    INDUSTRIAL_IND = NEW_REFERENCES.INDUSTRIAL_IND,
    PRACTICAL_IND = NEW_REFERENCES.PRACTICAL_IND,
    REPEATABLE_IND = NEW_REFERENCES.REPEATABLE_IND,
    ASSESSABLE_IND = NEW_REFERENCES.ASSESSABLE_IND,
    ACHIEVABLE_CREDIT_POINTS = NEW_REFERENCES.ACHIEVABLE_CREDIT_POINTS,
    POINTS_INCREMENT = NEW_REFERENCES.POINTS_INCREMENT,
    POINTS_MIN = NEW_REFERENCES.POINTS_MIN,
    POINTS_MAX = NEW_REFERENCES.POINTS_MAX,
    UNIT_INT_COURSE_LEVEL_CD = NEW_REFERENCES.UNIT_INT_COURSE_LEVEL_CD,
    UICL_DESCRIPTION = NEW_REFERENCES.UICL_DESCRIPTION,
    subtitle_id                       = new_references.subtitle_id,
        work_load_other                   = new_references.work_load_other,
        contact_hrs_lecture               = new_references.contact_hrs_lecture,
        contact_hrs_lab                   = new_references.contact_hrs_lab,
        contact_hrs_other                 = new_references.contact_hrs_other,
        non_schd_required_hrs             = new_references.non_schd_required_hrs,
        exclude_from_max_cp_limit         = new_references.exclude_from_max_cp_limit,
        record_exclusion_flag             = new_references.record_exclusion_flag,
        ss_display_ind       = new_references.ss_display_ind,
        cal_type_enrol_load_cal           = new_references.cal_type_enrol_load_cal,
        sequence_num_enrol_load_cal    = new_references.sequence_num_enrol_load_cal,
        cal_type_offer_load_cal           = new_references.cal_type_offer_load_cal,
        sequence_num_offer_load_cal    = new_references.sequence_num_offer_load_cal,
        curriculum_id                     = new_references.curriculum_id,
        override_enrollment_max           = new_references.override_enrollment_max,
        rpt_fmly_id                       = new_references.rpt_fmly_id,
        repeat_code                       = new_references.repeat_code,
        unit_type_id                      = new_references.unit_type_id,
        level_code                        = new_references.level_code,
        advance_maximum                   = new_references.advance_maximum,
        approval_date                     = new_references.approval_date,
        continuing_education_units        = new_references.continuing_education_units,
        enrollment_expected               = new_references.enrollment_expected,
        enrollment_maximum                = new_references.enrollment_maximum,
        enrollment_minimum                = new_references.enrollment_minimum,
        federal_financial_aid             = new_references.federal_financial_aid,
        institutional_financial_aid       = new_references.institutional_financial_aid,
        lab_credit_points                 = new_references.lab_credit_points,
        lecture_credit_points             = new_references.lecture_credit_points,
        max_repeats_for_credit            = new_references.max_repeats_for_credit,
        max_repeats_for_funding           = new_references.max_repeats_for_funding,
        max_repeat_credit_points          = new_references.max_repeat_credit_points,
        clock_hours                       = new_references.clock_hours,
        other_credit_points               = new_references.other_credit_points,
        same_teaching_period              = new_references.same_teaching_period,
        same_teach_period_repeats         = new_references.same_teach_period_repeats,
        same_teach_period_repeats_cp      = new_references.same_teach_period_repeats_cp,
        state_financial_aid               = new_references.state_financial_aid,
        work_load_cp_lab                  = new_references.work_load_cp_lab,
        work_load_cp_lecture              = new_references.work_load_cp_lecture,
        subtitle_modifiable_flag          = new_references.subtitle_modifiable_flag,
        subtitle                          = new_references.subtitle,
        special_permission_ind            = new_references.special_permission_ind,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SS_ENROL_IND = X_SS_ENROL_IND,
    IVR_ENROL_IND = IVR_ENROL_IND,
    claimable_hours = new_references.claimable_hours,
    auditable_ind	= new_references.auditable_ind,
    audit_permission_ind	= new_references.audit_permission_ind,
    max_auditors_allowed	= new_references.max_auditors_allowed,
    billing_credit_points       = new_references.billing_credit_points,
    ovrd_wkld_val_flag          = new_references.ovrd_wkld_val_flag,
    workload_val_code           = new_references.workload_val_code ,
    billing_hrs                 = new_references.billing_hrs
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );

END UPDATE_ROW;

PROCEDURE ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_START_DT in DATE,
  X_REVIEW_DT in DATE,
  X_EXPIRY_DT in DATE,
  X_END_DT in DATE,
  X_UNIT_STATUS in VARCHAR2,
  X_TITLE in VARCHAR2,
  X_SHORT_TITLE in VARCHAR2,
  X_TITLE_OVERRIDE_IND in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_UL_DESCRIPTION in VARCHAR2,
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
  X_OU_DESCRIPTION in VARCHAR2,
  X_AWARD_COURSE_ONLY_IND in VARCHAR2,
  X_RESEARCH_UNIT_IND in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_PRACTICAL_IND in VARCHAR2,
  X_REPEATABLE_IND in VARCHAR2,
  X_ASSESSABLE_IND in VARCHAR2,
  X_ACHIEVABLE_CREDIT_POINTS in NUMBER,
  X_POINTS_INCREMENT in NUMBER,
  X_POINTS_MIN in NUMBER,
  X_POINTS_MAX in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_UICL_DESCRIPTION in VARCHAR2,
  x_subtitle_id                       IN     NUMBER ,
  x_work_load_other                   IN     NUMBER ,
  x_contact_hrs_lecture               IN     NUMBER ,
  x_contact_hrs_lab                   IN     NUMBER ,
  x_contact_hrs_other                 IN     NUMBER ,
  x_non_schd_required_hrs             IN     NUMBER ,
  x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
  x_record_exclusion_flag             IN     VARCHAR2 ,
  x_ss_display_ind                    IN     VARCHAR2 ,
  x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
  x_sequence_num_enrol_load_cal       IN     NUMBER ,
  x_cal_type_offer_load_cal           IN     VARCHAR2 ,
  x_sequence_num_offer_load_cal       IN     NUMBER ,
  x_curriculum_id                     IN     VARCHAR2 ,
  x_override_enrollment_max           IN     NUMBER ,
  x_rpt_fmly_id                       IN     NUMBER ,
  x_repeat_code                       IN     VARCHAR2 ,
  x_unit_type_id                      IN     NUMBER ,
  x_level_code                        IN     VARCHAR2 ,
  x_advance_maximum                   IN     NUMBER ,
  x_approval_date                     IN     DATE ,
  x_continuing_education_units        IN     NUMBER ,
  x_enrollment_expected               IN     NUMBER ,
  x_enrollment_maximum                IN     NUMBER ,
  x_enrollment_minimum                IN     NUMBER ,
  x_federal_financial_aid             IN     VARCHAR2 ,
  x_institutional_financial_aid       IN     VARCHAR2 ,
  x_lab_credit_points                 IN     NUMBER ,
  x_lecture_credit_points             IN     NUMBER ,
  x_max_repeats_for_credit            IN     NUMBER ,
  x_max_repeats_for_funding           IN     NUMBER ,
  x_max_repeat_credit_points          IN     NUMBER ,
  x_clock_hours                       IN     NUMBER ,
  x_other_credit_points               IN     NUMBER ,
  x_same_teaching_period              IN     VARCHAR2 ,
  x_same_teach_period_repeats         IN     NUMBER ,
  x_same_teach_period_repeats_cp      IN     NUMBER ,
  x_state_financial_aid               IN     VARCHAR2 ,
  x_work_load_cp_lab                  IN     NUMBER ,
  x_work_load_cp_lecture              IN     NUMBER ,
  x_subtitle_modifiable_flag          IN     VARCHAR2 ,
  x_subtitle                          IN     VARCHAR2 ,
  x_special_permission_ind            IN     VARCHAR2 ,
  X_MODE                              IN     VARCHAR2 ,
  X_ORG_ID                            IN     NUMBER,
  X_SS_ENROL_IND                      IN     VARCHAR2,
  X_IVR_ENROL_IND                     IN     VARCHAR2,
  x_claimable_hours                   IN     NUMBER ,
  x_auditable_ind		      IN     VARCHAR2 ,
  x_audit_permission_ind	      IN     VARCHAR2 ,
  x_max_auditors_allowed	      IN     NUMBER ,
  x_billing_credit_points             IN     NUMBER ,
  x_ovrd_wkld_val_flag                IN     VARCHAR2,
  x_workload_val_code                 IN     VARCHAR2 ,
  x_billing_hrs                       IN     NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_VER_HIST_ALL
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_START_DT,
     X_REVIEW_DT,
     X_EXPIRY_DT,
     X_END_DT,
     X_UNIT_STATUS,
     X_TITLE,
     X_SHORT_TITLE,
     X_TITLE_OVERRIDE_IND,
     X_ABBREVIATION,
     X_UNIT_LEVEL,
     X_UL_DESCRIPTION,
     X_CREDIT_POINT_DESCRIPTOR,
     X_ENROLLED_CREDIT_POINTS,
     X_POINTS_OVERRIDE_IND,
     X_SUPP_EXAM_PERMITTED_IND,
     X_COORD_PERSON_ID,
     X_OWNER_ORG_UNIT_CD,
     X_OWNER_OU_START_DT,
     X_OU_DESCRIPTION,
     X_AWARD_COURSE_ONLY_IND,
     X_RESEARCH_UNIT_IND,
     X_INDUSTRIAL_IND,
     X_PRACTICAL_IND,
     X_REPEATABLE_IND,
     X_ASSESSABLE_IND,
     X_ACHIEVABLE_CREDIT_POINTS,
     X_POINTS_INCREMENT,
     X_POINTS_MIN,
     X_POINTS_MAX,
     X_UNIT_INT_COURSE_LEVEL_CD,
     X_UICL_DESCRIPTION,
     x_subtitle_id,
        x_work_load_other,
        x_contact_hrs_lecture,
        x_contact_hrs_lab,
        x_contact_hrs_other,
        x_non_schd_required_hrs,
        x_exclude_from_max_cp_limit,
        x_record_exclusion_flag,
        x_ss_display_ind,
        x_cal_type_enrol_load_cal,
        x_sequence_num_enrol_load_cal,
        x_cal_type_offer_load_cal,
        x_sequence_num_offer_load_cal,
        x_curriculum_id,
        x_override_enrollment_max,
        x_rpt_fmly_id,
        x_repeat_code,
        x_unit_type_id,
        x_level_code,
        x_advance_maximum,
        x_approval_date,
        x_continuing_education_units,
        x_enrollment_expected,
        x_enrollment_maximum,
        x_enrollment_minimum,
        x_federal_financial_aid,
        x_institutional_financial_aid,
        x_lab_credit_points,
        x_lecture_credit_points,
        x_max_repeats_for_credit,
        x_max_repeats_for_funding,
        x_max_repeat_credit_points,
        x_clock_hours,
        x_other_credit_points,
        x_same_teaching_period,
        x_same_teach_period_repeats,
        x_same_teach_period_repeats_cp,
        x_state_financial_aid,
        x_work_load_cp_lab,
        x_work_load_cp_lecture,
        x_subtitle_modifiable_flag,
        x_subtitle,
        x_special_permission_ind,
        X_MODE,
        X_ORG_ID,
        X_SS_ENROL_IND,
        X_IVR_ENROL_IND,
        x_claimable_hours,
        x_auditable_ind,
        x_audit_permission_ind,
        x_max_auditors_allowed,
        x_billing_credit_points,
        x_ovrd_wkld_val_flag,
        x_workload_val_code,
        x_billing_hrs
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_START_DT,
   X_REVIEW_DT,
   X_EXPIRY_DT,
   X_END_DT,
   X_UNIT_STATUS,
   X_TITLE,
   X_SHORT_TITLE,
   X_TITLE_OVERRIDE_IND,
   X_ABBREVIATION,
   X_UNIT_LEVEL,
   X_UL_DESCRIPTION,
   X_CREDIT_POINT_DESCRIPTOR,
   X_ENROLLED_CREDIT_POINTS,
   X_POINTS_OVERRIDE_IND,
   X_SUPP_EXAM_PERMITTED_IND,
   X_COORD_PERSON_ID,
   X_OWNER_ORG_UNIT_CD,
   X_OWNER_OU_START_DT,
   X_OU_DESCRIPTION,
   X_AWARD_COURSE_ONLY_IND,
   X_RESEARCH_UNIT_IND,
   X_INDUSTRIAL_IND,
   X_PRACTICAL_IND,
   X_REPEATABLE_IND,
   X_ASSESSABLE_IND,
   X_ACHIEVABLE_CREDIT_POINTS,
   X_POINTS_INCREMENT,
   X_POINTS_MIN,
   X_POINTS_MAX,
   X_UNIT_INT_COURSE_LEVEL_CD,
   X_UICL_DESCRIPTION,
   x_subtitle_id,
        x_work_load_other,
        x_contact_hrs_lecture,
        x_contact_hrs_lab,
        x_contact_hrs_other,
        x_non_schd_required_hrs,
        x_exclude_from_max_cp_limit,
        x_record_exclusion_flag,
        x_ss_display_ind,
        x_cal_type_enrol_load_cal,
        x_sequence_num_enrol_load_cal,
        x_cal_type_offer_load_cal,
        x_sequence_num_offer_load_cal,
        x_curriculum_id,
        x_override_enrollment_max,
        x_rpt_fmly_id,
        x_repeat_code,
        x_unit_type_id,
        x_level_code,
        x_advance_maximum,
        x_approval_date,
        x_continuing_education_units,
        x_enrollment_expected,
        x_enrollment_maximum,
        x_enrollment_minimum,
        x_federal_financial_aid,
        x_institutional_financial_aid,
        x_lab_credit_points,
        x_lecture_credit_points,
        x_max_repeats_for_credit,
        x_max_repeats_for_funding,
        x_max_repeat_credit_points,
        x_clock_hours,
        x_other_credit_points,
        x_same_teaching_period,
        x_same_teach_period_repeats,
        x_same_teach_period_repeats_cp,
        x_state_financial_aid,
        x_work_load_cp_lab,
        x_work_load_cp_lecture,
        x_subtitle_modifiable_flag,
        x_subtitle,
        x_special_permission_ind,
        X_MODE,
	X_SS_ENROL_IND,
	X_IVR_ENROL_IND,
	x_claimable_hours,
	x_auditable_ind,
	x_audit_permission_ind,
	x_max_auditors_allowed,
        x_billing_credit_points,
        x_ovrd_wkld_val_flag,
        x_workload_val_code,
        x_billing_hrs
   );
END ADD_ROW;

PROCEDURE DELETE_ROW (
  X_ROWID in VARCHAR2
) AS


BEGIN
  Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );
  delete from IGS_PS_UNIT_VER_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

END DELETE_ROW;

END IGS_PS_UNIT_VER_HIST_PKG;

/
