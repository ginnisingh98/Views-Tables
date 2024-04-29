--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_VER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_VER_PKG" as
/* $Header: IGSPI92B.pls 120.6 2006/05/15 00:37:51 sarakshi ship $ */
-- Change History
-- Who             When                What
--sommukhe        28-Nov-2005         Bug#4760997, created a new procedure update_row_subtitle_id.
--sommukhe    02-sep-2005  bug#4257131, added code in after_dml for update operation.
--sarakshi    10-Aug-2005  Bug#4216517, removed get_fk_igs_ps_unit_type_lvl procedure
--jbaber      02-feb-05    Modified procedure Check_Child_Existance, to remove reference to obsoleted igs_he_st_uv_cc_all_pkg package for HE355 - Org Unit Cost Centre Link
--sarakshi    30-Apr-2004  Bug#3568858, Added columns ovrd_wkld_val_flag, workload_val_code
--sarakshi    01-sep-03    Enh#3052452,removed the reference of sub_unit_allowed_ind and sup_unit_allowed_ind
--sarakshi    04-Aug-03    Bug#3045069,modified check_constraint procedure
--smvk        27-Jun-2003  Bug # 3011578. Truncating start_date, end_date, expiry_date, approval_date and review date.
--sarakshi    09-Jun-2003  Enh#2858436,removed procedure get_fk_igs_ps_unit_level
--vvutukur    09-Jun-2003  Enh#2831572.Financial Accounting Build.Modified check_child_existance.
--svenkata    02-06-2003   Modified to remove references to TBH of pkg IGS_EN_ELGB_OVR_STEP_PKG. Instead , added
--			  references to package IGS_EN_ELGB_OVR_UOO.Bug #2829272
--sarakshi         18-Apr-2003         Enh#2858431,modified procedure DFLT_UNIT_REF_CODE
-- pathipat        17-Feb-2003         Enh 2747325 - Locking Issues build - Removed proc get_fk_igs_fi_acc_all
-- sarakshi 27-Nov-2002 Enh#2649028,for all numeric value comparision, changed the AND condition with OR
--                      to check the value between 0 and 999
--shtatiko  31-OCT-2002 Bug# 2636716. Modified procedures to incorporate addition of three new fields
--			auditable_ind, audit_permission_ind and max_auditors_allowed.
--sarakshi  16-Jun-2002 bug#2416978,added local procedure beforerowdelete,beforerowupdate and modified
--                      get_pk_for_validation
--jbegum          17 April 02     As part of bug fix of bug #2322290 and bug#2250784
--                                Removed the following 4 columns
--                                BILLING_CREDIT_POINTS,BILLING_HRS,FIN_AID_CP,FIN_AID_HRS.
-- sbaliga  13-feb-2002 Modified call to before_dml in insert_row procedure as part of SWCR006 build.
-- SMADATHI 01-Feb-2002 Modified Check_Child_Existance Procedure . This is as per enhancement bug 2154941
-- jdeekoll 11-SEP-2001 Added one column claimable_hours
-- msrinivi 20-Jul-2001 Bug # 1882122 Added one column rev_account_cd
-- rgangara 09-Jul-2001  Added the Default 'N' to fields ss_enrol_ind and ivr_enrol_ind
-- SMADATHI 03-JUL-2001 Modified Check_Child_Existance Procedure . This is as per enhancement bug no. 1830175
-- SMADATHI 13-JUN-2001 Modified set column values procedure . Subtitle column in igs_ps_unit_ver_all was obsoleted and irrespective
--                      of the values assigned to it , the column will be assigned value NULL . Also reference to this column
--                      was removed from lock_row procedure .This is as per Enhancement Bug No. 1775394
/* SMADATHI 29-MAY-2001 removed foreign key references to IGS_PS_UNT_REPT_FMLY , IGS_PS_UNT_PRV_GRADE  as per DLD. (Enhancement Bug No. 1775394)
 SMADATHI 25-MAY-2001 removed foreign key references to IGS_PS_USEC_RPT_FMLY as per DLD (Enhancement Bug No. 1775394). Also added validation for Curriculum Id*/
-- rgangara 03-May-2001 added two Columns ss_enrol_ind and ivr_enrol_ind as per DLD Unit Section Enrollment Info.
-- cdcruz 31-Jan-2002 added Two new columns  anon_unit_grading_ind/anon_assess_grading_ind added to base table
--                    as per DLD Anonymous Grading Bug 2198374
-- smvk   16-Dec-2002 Function Call IGS_PS_VAL_US.crsp_val_ver_dt,IGS_PS_VAL_UV.crsp_val_uv_pnt_ovrd and IGS_PS_VAL_UV.crsp_val_uv_unit_sts
--                    are modified with additional parameter value 'FALSE'. for Bug # 2696207
-- smvk      19-Dec-2002    Removed the OWNER_ORG_UNIT_CD checking for upper case
--                          from check_constraints procedure. Bug # 2487149
-- smaddali 21-jan-04     Modified procedure Check_Child_Existance , to remove cursor c_hesa and call igs_he_st_unt_vs_all_pkg.get_fk_igs_ps_unit_ver_all
--                       and igs_he_st_uv_cc_all_pkg.get_fk_igs_ps_unit_ver_all directly instead of thru execute immediate for bug#3306063

  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_VER_ALL%RowType;
  new_references IGS_PS_UNIT_VER_ALL%RowType;


PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle India
  --Date created: 16-Jun-2002
  --
  --Purpose: Only planned unit status are allowed for deletion
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR cur_delete (cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
                     cp_version_number igs_ps_unit_ver_all.version_number%TYPE)
  IS
  SELECT 'x'
  FROM   igs_ps_unit_ver_all uv,
         igs_ps_unit_stat us
  WHERE  uv.unit_status=us.unit_status
  AND    us.s_unit_status='PLANNED'
  AND    uv.unit_cd = cp_unit_cd
  AND    uv.version_number = cp_version_number;

  l_check VARCHAR2(1);

BEGIN
  -- Only planned unit status are allowed for deletion
  OPEN  cur_delete (old_references.unit_cd,old_references.version_number);
  FETCH cur_delete INTO l_check;
  IF cur_delete%NOTFOUND THEN
    CLOSE cur_delete;
    fnd_message.set_name('IGS','IGS_PS_UNIT_NO_DEL_ALLOWED');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END IF;
  CLOSE cur_delete;
END beforerowdelete;


PROCEDURE beforerowupdate AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle India
  --Date created: 16-Jun-2002
  --
  --Purpose: Active/Inactive unit Status can not be changed to Planned Status
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --sarakshi    26-Jul-2004     bug#3793607,added code such that statsu cannot be changed to INACTIVE when enrolled/waitlisted student unit attempt exists
  -------------------------------------------------------------------
        CURSOR cur_get_status (cp_unit_status igs_ps_unit_stat.unit_status%TYPE)
        IS
        SELECT s_unit_status
        FROM   igs_ps_unit_stat
        WHERE  unit_status = cp_unit_status;
        l_s_unit_status igs_ps_unit_stat.s_unit_status%TYPE;

        CURSOR cur_check_update (cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
                                 cp_version_number igs_ps_unit_ver_all.version_number%TYPE)
        IS
        SELECT 'x'
        FROM     igs_ps_unit_ver_all uv,
                 igs_ps_unit_stat us
        WHERE    uv.unit_status=us.unit_status
        AND      us.s_unit_status <> 'PLANNED'
        AND      uv.unit_cd = cp_unit_cd
        AND      uv.version_number = cp_version_number;

        l_check VARCHAR2(1);

	CURSOR c_enrollment_status (cp_unit_cd  igs_ps_unit_ver_all.unit_cd%TYPE,
                                    cp_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
        SELECT 'X'
        FROM   igs_en_su_attempt_all a,
               igs_ps_unit_ofr_opt_all b
        WHERE  a.uoo_id = b.uoo_id
        AND    b.unit_cd = cp_unit_cd
        AND    b.version_number = cp_version_number
        AND    a.unit_attempt_status IN ('ENROLLED','WAITLISTED');
        l_c_var  VARCHAR2(1);

BEGIN
  -- Active/Inactive unit Status can not be changed to Planned Status
  OPEN cur_get_status(new_references.unit_status);
  FETCH cur_get_status INTO l_s_unit_status;
  IF cur_get_status%FOUND THEN
    CLOSE cur_get_status;
    IF (l_s_unit_status = 'PLANNED') THEN
      OPEN cur_check_update(old_references.unit_cd,old_references.version_number);
      FETCH cur_check_update INTO l_check;
      IF cur_check_update%FOUND THEN
        CLOSE cur_check_update;
        fnd_message.set_name('IGS','IGS_PS_UNIT_NO_INACTIVE_PLN');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_check_update;
    END IF;
  ELSE
    -- If the unit status is not found then the record might have been deleted
    CLOSE cur_get_status;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END IF;


  --Unit status cannot be made INACTIVE when there are Enrolled or waitlisted student unit attempt
  IF new_references.unit_status <> old_references.unit_status AND l_s_unit_status = 'INACTIVE' THEN
    OPEN c_enrollment_status (new_references.unit_cd,new_references.version_number);
    FETCH c_enrollment_status INTO l_c_var;
    IF c_enrollment_status%FOUND THEN
      CLOSE c_enrollment_status;
      fnd_message.set_name('IGS','IGS_PS_UNIT_STATUS_INACTIVE_NO');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    CLOSE c_enrollment_status;
  END IF;

END beforerowupdate;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd in VARCHAR2 ,
    x_version_number in NUMBER ,
    x_start_dt in DATE ,
    x_review_dt in DATE ,
    x_expiry_dt in DATE ,
    x_end_dt in DATE ,
    x_unit_status in VARCHAR2 ,
    x_title in VARCHAR2 ,
    x_short_title in VARCHAR2 ,
    x_title_override_ind in VARCHAR2 ,
    x_abbreviation in VARCHAR2 ,
    x_unit_level in VARCHAR2 ,
    x_credit_point_descriptor in VARCHAR2 ,
    x_enrolled_credit_points in NUMBER ,
    x_points_override_ind in VARCHAR2 ,
    x_supp_exam_permitted_ind in VARCHAR2 ,
    x_coord_person_id in NUMBER ,
    x_owner_org_unit_cd in VARCHAR2 ,
    x_owner_ou_start_dt in DATE ,
    x_award_course_only_ind in VARCHAR2 ,
    x_research_unit_ind in VARCHAR2 ,
    x_industrial_ind in VARCHAR2 ,
    x_practical_ind in VARCHAR2 ,
    x_repeatable_ind in VARCHAR2 ,
    x_assessable_ind in VARCHAR2 ,
    x_achievable_credit_points in NUMBER ,
    x_points_increment in NUMBER ,
    x_points_min in NUMBER ,
    x_points_max in NUMBER ,
    x_unit_int_course_level_cd in VARCHAR2 ,
    x_subtitle in VARCHAR2 ,
    x_subtitle_modifiable_flag in VARCHAR2 ,
    x_approval_date in DATE ,
    x_lecture_credit_points in NUMBER ,
    x_lab_credit_points in NUMBER ,
    x_other_credit_points in NUMBER ,
    x_clock_hours in NUMBER ,
    x_work_load_cp_lecture in NUMBER ,
    x_work_load_cp_lab in NUMBER ,
    x_continuing_education_units in NUMBER ,
    x_enrollment_expected in NUMBER ,
    x_enrollment_minimum in NUMBER ,
    x_enrollment_maximum in NUMBER ,
    x_advance_maximum in NUMBER ,
    x_state_financial_aid in VARCHAR2 ,
    x_federal_financial_aid in VARCHAR2 ,
    x_institutional_financial_aid in VARCHAR2 ,
    x_same_teaching_period in VARCHAR2 ,
    x_max_repeats_for_credit in NUMBER ,
    x_max_repeats_for_funding in NUMBER ,
    x_max_repeat_credit_points in NUMBER ,
    x_same_teach_period_repeats in NUMBER ,
    x_same_teach_period_repeats_cp in NUMBER ,
    x_attribute_category in VARCHAR2 ,
    x_attribute1 in VARCHAR2 ,
    x_attribute2 in VARCHAR2 ,
    x_attribute3 in VARCHAR2 ,
    x_attribute4 in VARCHAR2 ,
    x_attribute5 in VARCHAR2 ,
    x_attribute6 in VARCHAR2 ,
    x_attribute7 in VARCHAR2 ,
    x_attribute8 in VARCHAR2 ,
    x_attribute9 in VARCHAR2 ,
    x_attribute10 in VARCHAR2 ,
    x_attribute11 in VARCHAR2 ,
    x_attribute12 in VARCHAR2 ,
    x_attribute13 in VARCHAR2 ,
    x_attribute14 in VARCHAR2 ,
    x_attribute15 in VARCHAR2 ,
    x_attribute16 in VARCHAR2 ,
    x_attribute17 in VARCHAR2 ,
    x_attribute18 in VARCHAR2 ,
    x_attribute19 in VARCHAR2 ,
    x_attribute20 in VARCHAR2 ,
    x_subtitle_id                       IN     NUMBER ,
    x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind       IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal    IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal    IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_unit_type_id                      IN     NUMBER ,
    x_special_permission_ind            IN     VARCHAR2 ,
    x_created_by in NUMBER ,
    x_creation_date in DATE ,
    x_last_updated_by in NUMBER ,
    x_last_update_date in DATE ,
    x_last_update_login in NUMBER ,
    x_org_id in NUMBER  ,
    x_ss_enrol_ind in VARCHAR2 ,
    x_ivr_enrol_ind in VARCHAR2 ,
    x_rev_account_cd IN VARCHAR2 ,
    x_claimable_hours IN NUMBER ,
    x_anon_unit_grading_ind IN VARCHAR2 ,
    x_anon_assess_grading_ind IN VARCHAR2 ,
    x_auditable_ind IN VARCHAR2,
    x_audit_permission_ind IN VARCHAR2 ,
    x_max_auditors_allowed IN NUMBER ,
    x_billing_credit_points IN NUMBER,
    x_ovrd_wkld_val_flag    IN VARCHAR2 ,
    x_workload_val_code     IN VARCHAR2 ,
    x_billing_hrs           IN NUMBER

  ) AS
  ------------------------------------------------------------------
  --Purpose: As per enhancement bug no.1775394 , the column subtitle in
  --         igs_ps_unit_ver_all is obsoleted . Irrespective of the value passed
  --         to this column , it will always be assigned  NULL .
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smadathi    13-JUN-2001     refer purpose
  --msrinivi    20-Jul-2001     Added new col : rev_account_Cd
  -------------------------------------------------------------------
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_VER_ALL
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
    new_references.credit_point_descriptor := x_credit_point_descriptor;
    new_references.enrolled_credit_points := x_enrolled_credit_points;
    new_references.points_override_ind := x_points_override_ind;
    new_references.supp_exam_permitted_ind := x_supp_exam_permitted_ind;
    new_references.coord_person_id := x_coord_person_id;
    new_references.owner_org_unit_cd := x_owner_org_unit_cd;
    new_references.owner_ou_start_dt := x_owner_ou_start_dt;
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

    -- subtitle value will be assigned as NULL irrespective of the value passed to it
    new_references.subtitle := NULL ;

    new_references.subtitle_modifiable_flag := x_subtitle_modifiable_flag;
    new_references.approval_date := x_approval_date;
    new_references.lecture_credit_points := x_lecture_credit_points;
    new_references.lab_credit_points := x_lab_credit_points;
    new_references.other_credit_points := x_other_credit_points;
    new_references.clock_hours := x_clock_hours;
    new_references.work_load_cp_lecture := x_work_load_cp_lecture;
    new_references.work_load_cp_lab := x_work_load_cp_lab;
    new_references.continuing_education_units := x_continuing_education_units;
    new_references.enrollment_expected := x_enrollment_expected;
    new_references.enrollment_minimum := x_enrollment_minimum;
    new_references.enrollment_maximum := x_enrollment_maximum;
    new_references.advance_maximum := x_advance_maximum;
    new_references.state_financial_aid := x_state_financial_aid;
    new_references.federal_financial_aid := x_federal_financial_aid;
    new_references.institutional_financial_aid := x_institutional_financial_aid;
    new_references.same_teaching_period := x_same_teaching_period;
    new_references.max_repeats_for_credit := x_max_repeats_for_credit;
    new_references.max_repeats_for_funding := x_max_repeats_for_funding;
    new_references.max_repeat_credit_points := x_max_repeat_credit_points;
    new_references.same_teach_period_repeats := x_same_teach_period_repeats;
    new_references.same_teach_period_repeats_cp := x_same_teach_period_repeats_cp;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.subtitle_id := x_subtitle_id;
    new_references.work_load_other := x_work_load_other;
    new_references.contact_hrs_lecture := x_contact_hrs_lecture;
    new_references.contact_hrs_lab := x_contact_hrs_lab;
    new_references.contact_hrs_other := x_contact_hrs_other;
    new_references.non_schd_required_hrs := x_non_schd_required_hrs;
    new_references.exclude_from_max_cp_limit := x_exclude_from_max_cp_limit;
    new_references.record_exclusion_flag := x_record_exclusion_flag;
    new_references.ss_display_ind := x_ss_display_ind;
    new_references.cal_type_enrol_load_cal := x_cal_type_enrol_load_cal;
    new_references.sequence_num_enrol_load_cal := x_sequence_num_enrol_load_cal;
    new_references.cal_type_offer_load_cal := x_cal_type_offer_load_cal;
    new_references.sequence_num_offer_load_cal := x_sequence_num_offer_load_cal;
    new_references.curriculum_id := x_curriculum_id;
    new_references.override_enrollment_max := x_override_enrollment_max;
    new_references.rpt_fmly_id := x_rpt_fmly_id;
    new_references.unit_type_id := x_unit_type_id;
    new_references.special_permission_ind := x_special_permission_ind;
    new_references.org_id:=x_org_id;
    new_references.ss_enrol_ind := x_ss_enrol_ind;
    new_references.ivr_enrol_ind := x_ivr_enrol_ind;
    new_references.rev_account_cd := x_rev_account_cd;
    new_references.claimable_hours := x_claimable_hours;
    new_references.anon_unit_grading_ind := x_anon_unit_grading_ind;
    new_references.anon_assess_grading_ind := x_anon_assess_grading_ind;
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

  END Set_Column_Values;


  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
    --modified rgangara as per DLD Unit Section Enrollment on 03-May-2001 added two nwe Columns SS_enrol_ind and IVr_enrol_ind
	v_message_name	Varchar2(30);
	v_return_type	VARCHAR2(1);
	-- Variables for history routine
	v_start_dt			IGS_PS_UNIT_VER_ALL.start_dt%TYPE;
	v_expiry_dt			IGS_PS_UNIT_VER_ALL.expiry_dt%TYPE;
	v_review_dt			IGS_PS_UNIT_VER_ALL.review_dt%TYPE;
	v_end_dt				IGS_PS_UNIT_VER_ALL.end_dt%TYPE;
	v_unit_status			IGS_PS_UNIT_VER_ALL.unit_status%TYPE;
	v_title				IGS_PS_UNIT_VER_ALL.title%TYPE;
	v_short_title			IGS_PS_UNIT_VER_ALL.short_title%TYPE;
	v_title_override_ind		IGS_PS_UNIT_VER_ALL.title_override_ind%TYPE;
	v_abbreviation			IGS_PS_UNIT_VER_ALL.abbreviation%TYPE;
	v_unit_level			IGS_PS_UNIT_VER_ALL.unit_level%TYPE;
	v_credit_point_descriptor	IGS_PS_UNIT_VER_ALL.credit_point_descriptor%TYPE;
	v_achievable_credit_points	IGS_PS_UNIT_VER_ALL.achievable_credit_points%TYPE;
	v_enrolled_credit_points		IGS_PS_UNIT_VER_ALL.enrolled_credit_points%TYPE;
	v_supp_exam_permitted_ind		IGS_PS_UNIT_VER_ALL.supp_exam_permitted_ind%TYPE;
	v_points_increment		IGS_PS_UNIT_VER_ALL.points_increment%TYPE;
	v_points_min			IGS_PS_UNIT_VER_ALL.points_min%TYPE;
	v_points_max			IGS_PS_UNIT_VER_ALL.points_max%TYPE;
	v_points_override_ind		IGS_PS_UNIT_VER_ALL.points_override_ind%TYPE;
	v_coord_person_id			IGS_PS_UNIT_VER_ALL.coord_person_id%TYPE;
	v_owner_org_unit_cd		IGS_PS_UNIT_VER_ALL.owner_org_unit_cd%TYPE;
	v_owner_ou_start_dt		IGS_PS_UNIT_VER_ALL.owner_ou_start_dt%TYPE;
	v_award_course_only_ind		IGS_PS_UNIT_VER_ALL.award_course_only_ind%TYPE;
	v_research_unit_ind		IGS_PS_UNIT_VER_ALL.research_unit_ind%TYPE;
	v_industrial_ind			IGS_PS_UNIT_VER_ALL.industrial_ind%TYPE;
	v_practical_ind			IGS_PS_UNIT_VER_ALL.practical_ind%TYPE;
	v_repeatable_ind			IGS_PS_UNIT_VER_ALL.repeatable_ind%TYPE;
	v_assessable_ind			IGS_PS_UNIT_VER_ALL.assessable_ind%TYPE;
	v_unit_int_course_level_cd		IGS_PS_UNIT_VER_ALL.unit_int_course_level_cd%TYPE;
	cst_error			VARCHAR2(1);
	v_s_unit_status		IGS_PS_UNIT_STAT.s_unit_status%TYPE;
        v_preferred_name                IGS_PE_PERSON.preferred_given_name%TYPE;
        v_ss_enrol_ind                  IGS_PS_UNIT_VER_ALL.ss_enrol_ind%TYPE;
        v_ivr_enrol_ind                 IGS_PS_UNIT_VER_ALL.ivr_enrol_ind%TYPE;

        -- Modified by rbezawad on 24-May-2001.  Added following 47 fields as per PSP001-US DLD.

        v_advance_maximum                        IGS_PS_UNIT_VER_ALL.advance_maximum%TYPE;
        v_approval_date                          IGS_PS_UNIT_VER_ALL.approval_date%TYPE;
        v_cal_type_enrol_load_cal                IGS_PS_UNIT_VER_ALL.cal_type_enrol_load_cal%TYPE;
        v_cal_type_offer_load_cal                IGS_PS_UNIT_VER_ALL.cal_type_offer_load_cal%TYPE;
        v_clock_hours                            IGS_PS_UNIT_VER_ALL.clock_hours%TYPE;
        v_contact_hrs_lab                        IGS_PS_UNIT_VER_ALL.contact_hrs_lab%TYPE;
        v_contact_hrs_lecture                    IGS_PS_UNIT_VER_ALL.contact_hrs_lecture%TYPE;
        v_contact_hrs_other                      IGS_PS_UNIT_VER_ALL.contact_hrs_other%TYPE;
        v_continuing_education_units             IGS_PS_UNIT_VER_ALL.continuing_education_units%TYPE;
        v_curriculum_id                          IGS_PS_UNIT_VER_ALL.curriculum_id%TYPE;
        v_enrollment_expected                    IGS_PS_UNIT_VER_ALL.enrollment_expected%TYPE;
        v_enrollment_maximum                     IGS_PS_UNIT_VER_ALL.enrollment_maximum%TYPE;
        v_enrollment_minimum                     IGS_PS_UNIT_VER_ALL.enrollment_minimum%TYPE;
        v_exclude_from_max_cp_limit              IGS_PS_UNIT_VER_ALL.exclude_from_max_cp_limit%TYPE;
        v_federal_financial_aid                  IGS_PS_UNIT_VER_ALL.federal_financial_aid%TYPE;
        v_institutional_financial_aid            IGS_PS_UNIT_VER_ALL.institutional_financial_aid%TYPE;
        v_lab_credit_points                      IGS_PS_UNIT_VER_ALL.lab_credit_points%TYPE;
        v_lecture_credit_points                  IGS_PS_UNIT_VER_ALL.lecture_credit_points%TYPE;
        v_max_repeat_credit_points               IGS_PS_UNIT_VER_ALL.max_repeat_credit_points%TYPE;
        v_max_repeats_for_credit                 IGS_PS_UNIT_VER_ALL.max_repeats_for_credit%TYPE;
        v_max_repeats_for_funding                IGS_PS_UNIT_VER_ALL.max_repeats_for_funding%TYPE;
        v_non_schd_required_hrs                  IGS_PS_UNIT_VER_ALL.non_schd_required_hrs%TYPE;
        v_other_credit_points                    IGS_PS_UNIT_VER_ALL.other_credit_points%TYPE;
        v_override_enrollment_max                IGS_PS_UNIT_VER_ALL.override_enrollment_max%TYPE;
        v_record_exclusion_flag                  IGS_PS_UNIT_VER_ALL.record_exclusion_flag%TYPE;
        v_ss_display_ind            IGS_PS_UNIT_VER_ALL.ss_display_ind%TYPE;
        v_rpt_fmly_id                            IGS_PS_UNIT_VER_ALL.rpt_fmly_id%TYPE;
        v_same_teach_period_repeats              IGS_PS_UNIT_VER_ALL.same_teach_period_repeats%TYPE;
        v_same_teach_period_repeats_cp           IGS_PS_UNIT_VER_ALL.same_teach_period_repeats_cp%TYPE;
        v_same_teaching_period                   IGS_PS_UNIT_VER_ALL.same_teaching_period%TYPE;
        v_sequence_num_enrol_load_cal            IGS_PS_UNIT_VER_ALL.sequence_num_enrol_load_cal%TYPE;
        v_sequence_num_offer_load_cal            IGS_PS_UNIT_VER_ALL.sequence_num_offer_load_cal%TYPE;
        v_special_permission_ind                 IGS_PS_UNIT_VER_ALL.special_permission_ind%TYPE;
        v_state_financial_aid                    IGS_PS_UNIT_VER_ALL.state_financial_aid%TYPE;
        v_subtitle_id                            IGS_PS_UNIT_VER_ALL.subtitle_id%TYPE;
        v_subtitle_modifiable_flag               IGS_PS_UNIT_VER_ALL.subtitle_modifiable_flag%TYPE;
        v_unit_type_id                           IGS_PS_UNIT_VER_ALL.unit_type_id%TYPE;
        v_work_load_cp_lab                       IGS_PS_UNIT_VER_ALL.work_load_cp_lab%TYPE;
        v_work_load_cp_lecture                   IGS_PS_UNIT_VER_ALL.work_load_cp_lecture%TYPE;
        v_work_load_other                        IGS_PS_UNIT_VER_ALL.work_load_other%TYPE;
        --msrinivi Added new column Bug :1882122
        v_rev_account_cd                         IGS_PS_UNIT_VER_ALL.rev_account_cd%TYPE;
        v_claimable_hours                        IGS_PS_UNIT_VER_ALL.claimable_hours%TYPE;
        v_anon_unit_grading_ind                  IGS_PS_UNIT_VER_ALL.anon_unit_grading_ind%TYPE;
        v_anon_assess_grading_ind                IGS_PS_UNIT_VER_ALL.anon_assess_grading_ind%TYPE;
        v_auditable_ind				 IGS_PS_UNIT_VER_ALL.auditable_ind%TYPE;
        v_audit_permission_ind			 IGS_PS_UNIT_VER_ALL.audit_permission_ind%TYPE;
        v_max_auditors_allowed			 IGS_PS_UNIT_VER_ALL.max_auditors_allowed%TYPE;
        v_billing_credit_points			 IGS_PS_UNIT_VER_ALL.billing_credit_points%TYPE;
        v_ovrd_wkld_val_flag			 IGS_PS_UNIT_VER_ALL.ovrd_wkld_val_flag%TYPE;
        v_workload_val_code			 IGS_PS_UNIT_VER_ALL.workload_val_code%TYPE;
	v_billing_hrs                            IGS_PS_UNIT_VER_ALL.billing_hrs%TYPE;

	CURSOR 	c_get_s_unit_status IS
		SELECT	s_unit_status
		FROM	IGS_PS_UNIT_STAT
   		WHERE	unit_status = new_references.unit_status ;
		--AND			unit_status = 'INACTIVE';

	CURSOR SPUVH_CUR IS
		SELECT Rowid
		FROM IGS_PS_UNIT_VER_HIST
		WHERE  unit_cd		= old_references.unit_cd 	AND
               version_number	= old_references.version_number;
       -- cursor which picks all the unit codes whose curriculum id is closed

        CURSOR c_igs_ps_unit_ver_all is
        SELECT '1'
        FROM   igs_ps_unit_ver_v uv
        WHERE  unit_cd         = new_references.unit_cd
        AND    version_number  = new_references.version_number
        AND    curriculum_id   = new_references.curriculum_id
        AND    EXISTS (SELECT '1'
                       FROM   igs_ps_unt_crclm ucur
                       WHERE  ucur.curriculum_id =   uv.curriculum_id
                       AND    ucur.closed_ind    =   'Y' )   ;

        l_c_igs_ps_unit_ver_all  c_igs_ps_unit_ver_all%ROWTYPE ;  -- cursor variable

  BEGIN
    cst_error := 'E';

         -- Validate the IGS_PS_UNIT version fields cannot be updated if the IGS_PS_UNIT
	-- version has a system status of 'INACTIVE'. IGS_GE_EXCEPTIONS are : IGS_PS_UNIT_STAT,
	-- expiry_dt and end_dt.
      -- updated by ssawhney 10-Nov-2000. Incorrect validations for ref start date and review date

	IF p_updating THEN
           IF old_references.curriculum_id <> new_references.curriculum_id THEN
	       -- checks if the curriculum attached to the unit is closed . If curriculum is closed , error out NOCOPY
	       -- Closed curriculum id should not allow any update to existing repeat fail of units .
	       -- added by smadathi on 25-MAY-2001 as per new DLD requirement
	      OPEN  c_igs_ps_unit_ver_all ;
	      FETCH c_igs_ps_unit_ver_all INTO l_c_igs_ps_unit_ver_all ;
	      IF c_igs_ps_unit_ver_all%FOUND THEN
	         CLOSE c_igs_ps_unit_ver_all ;
	         FND_MESSAGE.SET_NAME('IGS','IGS_PS_CURRICULUM_CLOSED');
                 IGS_GE_MSG_STACK.ADD;
                 APP_EXCEPTION.RAISE_EXCEPTION ;
	      END IF;
              CLOSE c_igs_ps_unit_ver_all ;
           END IF;
		OPEN	c_get_s_unit_status;
		FETCH	c_get_s_unit_status
			INTO v_s_unit_status;
		IF c_get_s_unit_status%FOUND AND (v_s_unit_status ='INACTIVE')  THEN
			IF (NVL(old_references.start_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) <>
                       (NVL(new_references.start_dt,IGS_GE_DATE.IGSDATE('1900/01/01')))OR
 				(NVL(old_references.review_dt,IGS_GE_DATE.IGSDATE('1900/01/01')))<>
				(NVL(new_references.review_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
				(old_references.title <> new_references.title) OR
				(old_references.short_title <> new_references.short_title) OR
				(old_references.title_override_ind <> new_references.title_override_ind) OR
				(old_references.abbreviation <> new_references.abbreviation) OR
				(old_references.unit_level <> new_references.unit_level) OR
				(old_references.credit_point_descriptor<> new_references.credit_point_descriptor) OR
				(old_references.points_override_ind <> new_references.points_override_ind) OR
				(old_references.supp_exam_permitted_ind <> new_references.supp_exam_permitted_ind) OR
				(old_references.award_course_only_ind <> new_references.award_course_only_ind) OR
				(old_references.research_unit_ind <> new_references.research_unit_ind) OR
				(old_references.industrial_ind <> new_references.industrial_ind) OR
				(old_references.owner_org_unit_cd <> new_references.owner_org_unit_cd) OR
				(NVL(old_references.owner_ou_start_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
				NVL(new_references.owner_ou_start_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
				(old_references.practical_ind <>new_references.practical_ind) OR
				(old_references.repeatable_ind <>new_references.repeatable_ind) OR
				(old_references.assessable_ind <>new_references.assessable_ind) OR
				(NVL(old_references.enrolled_credit_points,999999) <>
						NVL(new_references.enrolled_credit_points,999999)) OR
				(NVL(old_references.coord_person_id,999999) <>
						NVL(new_references.coord_person_id,999999)) OR
				(NVL(old_references.achievable_credit_points,999999) <>
						NVL(new_references.achievable_credit_points,999999)) OR
				(NVL(old_references.points_increment,999999) <> NVL(new_references.points_increment,999999)) OR
				(NVL(old_references.claimable_hours,9999999) <> NVL(new_references.claimable_hours,9999999)) OR
				(NVL(old_references.points_min,999999) <>
						NVL(new_references.points_min,999999)) OR
				(NVL(old_references.points_max,999999) <>
						NVL(new_references.points_max,999999)) OR
				(old_references.unit_int_course_level_cd <> new_references.unit_int_course_level_cd) OR
				(NVL(old_references.billing_hrs,999999) <>
						NVL(new_references.billing_hrs,999999)) OR
				(NVL(old_references.rev_account_cd,'UNSET') <> NVL(new_references.rev_account_cd,'UNSET'))
				THEN
				CLOSE	c_get_s_unit_status;
				Fnd_Message.Set_Name('IGS','IGS_PS_NOCHG_UNITVER_DETAILS');
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF; -- s_unit_status found.
		CLOSE	c_get_s_unit_status;
	END IF;
	-- Validate IGS_PS_UNIT internal IGS_PS_COURSE level.

	IF p_inserting OR
		(p_updating AND
		(old_references.unit_int_course_level_cd <>
		new_references.unit_int_course_level_cd)) THEN
		IF IGS_PS_VAL_UV.crsp_val_uv_uicl (
			new_references.unit_int_course_level_cd, v_message_name) = FALSE THEN
  		  Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
	   	  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate IGS_PS_UNIT level.
	IF p_inserting OR
		(p_updating AND
		(old_references.unit_level <> new_references.unit_level)) THEN
		IF IGS_PS_VAL_UV.crsp_val_unit_lvl (
			new_references.unit_level,v_message_name) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate credit point descriptor.
	IF p_inserting OR
		(p_updating AND
		(old_references.credit_point_descriptor <>
		new_references.credit_point_descriptor )) THEN
		IF IGS_PS_VAL_UV.crsp_val_uv_cp_desc (
			new_references.credit_point_descriptor,v_message_name) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the version dates.
	IF p_inserting OR
	    (p_updating AND
		(old_references.start_dt <> new_references.start_dt)) OR
	    (p_updating AND
		(NVL(old_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))<>
		NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01')))) OR
	    (p_updating AND
	         NVL(old_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                NVL(new_references.expiry_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
                -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UV.crsp_val_ver_dt (
		IF IGS_PS_VAL_US.crsp_val_ver_dt (
				new_references.start_dt,
				new_references.end_dt,
				new_references.expiry_dt,v_message_name,FALSE) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
                  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_updating AND new_references.end_dt IS NOT NULL THEN
		IF IGS_PS_VAL_UV.crsp_val_uv_end(new_references.unit_cd,
					new_references.version_number,
					v_return_type,
					v_message_name) = FALSE THEN
			IF v_return_type = cst_error THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;
	-- Validate the owner org IGS_PS_UNIT.
	IF p_inserting OR
	    (p_updating AND
		((old_references.owner_org_unit_cd <> new_references.owner_org_unit_cd) OR
		(old_references.owner_ou_start_dt <> new_references.owner_ou_start_dt))) THEN
		-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_UV.crsp_val_ou_sys_sts
		IF IGS_PS_VAL_CRV.crsp_val_ou_sys_sts (
				new_references.owner_org_unit_cd,
				new_references.owner_ou_start_dt,v_message_name) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate IGS_PS_UNIT status and end date combination.
	IF p_inserting OR
		(p_updating AND
                        ((NVL(old_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                        NVL(new_references.end_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
			(old_references.unit_status <> new_references.unit_status))) THEN
		IF IGS_PS_VAL_UV.crsp_val_uv_end_sts(
					new_references.end_dt,
					new_references.unit_status,v_message_name) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate IGS_PS_UNIT coordinator.
	IF new_references.coord_person_id IS NOT NULL AND
		(NVL(old_references.coord_person_id, 0) <> new_references.coord_person_id) THEN
		IF IGS_GE_MNT_SDTT.pid_val_staff(
				new_references.coord_person_id,v_preferred_name) = FALSE THEN
		  Fnd_Message.Set_Name('IGS','IGS_GE_COORD_NOT_STAFF_MEMBER');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the points override indicator.
	IF p_inserting OR
		(p_updating AND
			((old_references.points_override_ind <> new_references.points_override_ind) OR
			(NVL(old_references.points_increment, 0) <> NVL(new_references.points_increment, 0)) OR
			(NVL(old_references.points_min, 0) <> NVL(new_references.points_min, 0)) OR
			(NVL(old_references.points_max, 0) <> NVL(new_references.points_max, 0)) OR
			(NVL(old_references.enrolled_credit_points, 0) <>
				 NVL(new_references.enrolled_credit_points, 0)) OR
			(NVL(old_references.achievable_credit_points, 0) <>
				NVL(new_references.achievable_credit_points,0)))) THEN
		IF IGS_PS_VAL_UV.crsp_val_uv_pnt_ovrd(
					new_references.points_override_ind,
					new_references.points_increment,
					new_references.points_min,
					new_references.points_max,
					new_references.enrolled_credit_points,
					new_references.achievable_credit_points,v_message_name,FALSE) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the supplementary exams permitted indicator against the
	-- assessable indicator.
	IF p_inserting OR
		(p_updating AND
		((old_references.supp_exam_permitted_ind <>
		new_references.supp_exam_permitted_ind) OR
		(old_references.assessable_ind <>
		 new_references.assessable_ind))) THEN
		IF IGS_PS_VAL_UV.crsp_val_uv_sup_exam (
			new_references.supp_exam_permitted_ind,
			new_references.assessable_ind,v_message_name) = FALSE THEN
		  Fnd_Message.Set_Name('IGS',v_message_name);
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;


        -- Code added as per DLD Unit Section Enrollment Information
        -- Validating atleast one Enrollment method is checked
       IF p_inserting OR p_updating THEN
               IF (new_references.ss_enrol_ind = 'N' AND new_references.ivr_enrol_ind = 'N') THEN
                        Fnd_Message.Set_Name('IGS','IGS_PS_ONE_UNIT_ENR_MTHD');
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
               END IF;
        END IF;

	IF p_updating THEN
		IF old_references.start_dt <> new_references.start_dt OR
			old_references.unit_status <> new_references.unit_status OR
			old_references.title <> new_references.title OR
			old_references.short_title <> new_references.short_title OR
			old_references.title_override_ind <> new_references.title_override_ind OR
			old_references.abbreviation <> new_references.abbreviation OR
			old_references.unit_level <> new_references.unit_level OR
			old_references.credit_point_descriptor  <> new_references.credit_point_descriptor OR
			NVL(old_references.achievable_credit_points,999999) <>
						NVL(new_references.achievable_credit_points,999999) OR
			old_references.enrolled_credit_points <> new_references.enrolled_credit_points OR
			old_references.supp_exam_permitted_ind <> new_references.supp_exam_permitted_ind OR
			NVL(old_references.points_increment,999999) <>
						NVL(new_references.points_increment,999999) OR
			NVL(old_references.points_min,999999) <> NVL(new_references.points_min,999999) OR
			NVL(old_references.points_max,999999) <> NVL(new_references.points_max,999999) OR
			old_references.points_override_ind <> new_references.points_override_ind OR
			old_references.coord_person_id <> new_references.coord_person_id OR
			old_references.owner_org_unit_cd <> new_references.owner_org_unit_cd OR
			old_references.owner_ou_start_dt <> new_references.owner_ou_start_dt OR
			old_references.award_course_only_ind <> new_references.award_course_only_ind OR
			old_references.research_unit_ind <> new_references.research_unit_ind OR
			old_references.industrial_ind <> new_references.industrial_ind OR
			old_references.practical_ind <> new_references.practical_ind OR
			old_references.repeatable_ind <> new_references.repeatable_ind OR
			old_references.assessable_ind <> new_references.assessable_ind OR
			NVL(old_references.unit_int_course_leveL_cd,'null') <>
						NVL(new_references.unit_int_course_level_cd,'null') OR
			NVL(old_references.review_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
		    		NVL(new_references.review_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) OR
			NVL(old_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
		    		NVL(new_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) OR
			NVL(old_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
				NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) OR

                        --ADded as per DLD Unit Section Enrollment 03-May-01
                        NVL(old_references.ss_enrol_ind,'N') <> NVL(new_references.ss_enrol_ind,'N') OR
                        NVL(new_references.ivr_enrol_ind,'N') <> NVL(new_references.ivr_enrol_ind,'N') OR
                        --
                        --Added as per DLD PSP001-US by rbezawad on 24-May-2001
                        NVL(old_references.advance_maximum,999999) <> NVL(new_references.advance_maximum,999999) OR
                        NVL(old_references.approval_date, IGS_GE_DATE.IGSDATE('1900/01/01'))
                                           <> NVL(new_references.approval_date,IGS_GE_DATE.IGSDATE('1900/01/01')) OR
                        NVL(old_references.cal_type_enrol_load_cal,'null')
			                   <> NVL(new_references.cal_type_enrol_load_cal,'null') OR
                        NVL(old_references.cal_type_offer_load_cal,'null')
			                   <> NVL(new_references.cal_type_offer_load_cal,'null') OR
                        NVL(old_references.clock_hours,999999) <> NVL(new_references.clock_hours,999999) OR
                        NVL(old_references.contact_hrs_lab,999999) <> NVL(new_references.contact_hrs_lab,999999) OR
                        NVL(old_references.contact_hrs_lecture,999999)
			                   <> NVL(new_references.contact_hrs_lecture,999999) OR
                        NVL(old_references.contact_hrs_other,999999) <> NVL(new_references.contact_hrs_other,999999) OR
                        NVL(old_references.continuing_education_units,999999)
			                   <> NVL(new_references.continuing_education_units,999999) OR
                        NVL(old_references.curriculum_id,'null') <> NVL(new_references.curriculum_id,'null') OR
                        NVL(old_references.enrollment_expected,999999)
			                   <> NVL(new_references.enrollment_expected,999999) OR
                        NVL(old_references.enrollment_maximum,999999) <> NVL(new_references.enrollment_maximum,999999) OR
                        NVL(old_references.enrollment_minimum,999999) <> NVL(new_references.enrollment_minimum,999999) OR
                        NVL(old_references.exclude_from_max_cp_limit,'N')
			                   <> NVL(new_references.exclude_from_max_cp_limit,'N') OR
                        NVL(old_references.federal_financial_aid,'N') <> NVL(new_references.federal_financial_aid,'N') OR
                        NVL(old_references.institutional_financial_aid,'N')
			                   <> NVL(new_references.institutional_financial_aid,'N') OR
                        NVL(old_references.lab_credit_points,999999) <> NVL(new_references.lab_credit_points,999999) OR
                        NVL(old_references.lecture_credit_points,999999)
			                   <> NVL(new_references.lecture_credit_points,999999) OR
			NVL(old_references.max_repeat_credit_points,999999)
			                   <> NVL(new_references.max_repeat_credit_points,999999) OR
                        NVL(old_references.max_repeats_for_credit,999999)
			                   <> NVL(new_references.max_repeats_for_credit,999999) OR
                        NVL(old_references.max_repeats_for_funding,999999)
			                   <> NVL(new_references.max_repeats_for_funding,999999) OR
                        NVL(old_references.non_schd_required_hrs,999999)
			                   <> NVL(new_references.non_schd_required_hrs,999999) OR
                        NVL(old_references.other_credit_points,999999)
			                   <> NVL(new_references.other_credit_points,999999) OR
                        NVL(old_references.override_enrollment_max,999999)
			                   <> NVL(new_references.override_enrollment_max,999999) OR
                        NVL(old_references.record_exclusion_flag,'N') <> NVL(new_references.record_exclusion_flag,'N') OR
                        NVL(old_references.ss_display_ind,'N')
			                   <> NVL(new_references.ss_display_ind,'N') OR
                        NVL(old_references.rpt_fmly_id,999999) <> NVL(new_references.rpt_fmly_id,999999) OR
                        NVL(old_references.same_teach_period_repeats,999999)
			                   <> NVL(new_references.same_teach_period_repeats,999999) OR
                        NVL(old_references.same_teach_period_repeats_cp,999999)
			                   <> NVL(new_references.same_teach_period_repeats_cp,999999) OR
                        NVL(old_references.same_teaching_period,'N')
			                   <> NVL(new_references.same_teaching_period,'N') OR
                        NVL(old_references.sequence_num_enrol_load_cal,999999)
			                   <> NVL(new_references.sequence_num_enrol_load_cal,999999) OR
                        NVL(old_references.sequence_num_offer_load_cal,999999)
			                   <> NVL(new_references.sequence_num_offer_load_cal,999999) OR
                        NVL(old_references.special_permission_ind,'N')
			                   <> NVL(new_references.special_permission_ind,'N') OR
                        NVL(old_references.state_financial_aid,'N') <> NVL(new_references.state_financial_aid,'N') OR
                        NVL(old_references.subtitle_id,999999) <> NVL(new_references.subtitle_id,999999) OR
                        NVL(old_references.subtitle_modifiable_flag,'N') <> NVL(new_references.subtitle_modifiable_flag,'N') OR
                        NVL(old_references.unit_type_id,999999) <> NVL(new_references.unit_type_id,999999) OR
                        NVL(old_references.work_load_cp_lab,999999) <> NVL(new_references.work_load_cp_lab,999999) OR
                        NVL(old_references.work_load_cp_lecture,999999)
			                   <> NVL(new_references.work_load_cp_lecture,999999) OR
                        NVL(old_references.work_load_other,999999) <> NVL(new_references.work_load_other,999999) OR
                        NVL(old_references.claimable_hours,9999999) <> NVL(new_references.claimable_hours,9999999) OR
                        NVL(old_references.rev_account_cd,'UNSET') <> NVL(new_references.rev_account_cd,'UNSET') OR
                        NVL(old_references.auditable_ind,'N')
			                   <> NVL(new_references.auditable_ind,'N') OR
                        NVL(old_references.audit_permission_ind,'N')
			                   <> NVL(new_references.audit_permission_ind,'N') OR
                        NVL(old_references.max_auditors_allowed, 999999)
			                   <> NVL(new_references.max_auditors_allowed, 999999) OR
                        NVL(old_references.billing_credit_points, 999999)
			                   <> NVL(new_references.billing_credit_points, 999999) OR
                        NVL(old_references.ovrd_wkld_val_flag,'N') <> NVL(new_references.ovrd_wkld_val_flag,'N') OR
                        NVL(old_references.billing_hrs, 999999)
			                   <> NVL(new_references.billing_hrs, 999999) OR
                        NVL(old_references.workload_val_code,'UNSET') <> NVL(new_references.workload_val_code,'UNSET')
                        THEN
                        --

			IF (NVL(old_references.review_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))<>
			    NVL(new_references.review_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
				v_review_dt := old_references.review_dt;
			END IF;
			IF (NVL(old_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			    NVL(new_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
				v_expiry_dt := old_references.expiry_dt;
			END IF;
			IF (NVL(old_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			    NVL(new_references.end_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
				v_end_dt := old_references.end_dt;
			END IF;
                        --
                        IF NVL(old_references.ss_enrol_ind,'N') <> NVL(new_references.ss_enrol_ind,'N') THEN
                                v_ss_enrol_ind := old_references.ss_enrol_ind;
                        END IF;
                        IF NVL(old_references.ivr_enrol_ind,'N') <> NVL(new_references.ivr_enrol_ind,'N') THEN
                                v_ivr_enrol_ind := old_references.ivr_enrol_ind;
                        END IF;

			-- Use decode to compare the new and old values, and if they have changed
			-- put the old value in the variable to be passed to the history routine.
			SELECT	DECODE(old_references.start_dt,new_references.start_dt,
							NULL,old_references.start_dt),
				DECODE(old_references.unit_status,new_references.unit_status,
							NULL,old_references.unit_status),
				DECODE(old_references.title,new_references.title,
				NULL,old_references.title),
				DECODE(old_references.short_title,new_references.short_title,
							NULL,old_references.short_title),
				DECODE(old_references.title_override_ind,new_references.title_override_ind,
							NULL,old_references.title_override_ind),
				DECODE(old_references.abbreviation,new_references.abbreviation,NULL,
							old_references.abbreviation),
				DECODE(old_references.unit_level,new_references.unit_level,
							NULL,old_references.unit_level),
				DECODE(old_references.credit_point_descriptor,new_references.credit_point_descriptor,
							NULL,old_references.credit_point_descriptor),
				DECODE(NVL(old_references.achievable_credit_points,999999),
							NVL(new_references.achievable_credit_points,999999),
							NULL,old_references.achievable_credit_points),
				DECODE(old_references.enrolled_credit_points,new_references.enrolled_credit_points,
							NULL,old_references.enrolled_credit_points),
				DECODE(old_references.supp_exam_permitted_ind,new_references.supp_exam_permitted_ind,
							NULL,old_references.supp_exam_permitted_ind),
				DECODE(NVL(old_references.points_increment,999999),
							NVL(new_references.points_increment,999999),
							NULL,old_references.points_increment),
				DECODE(NVL(old_references.points_min,999999),NVL(new_references.points_min,999999),
							NULL,old_references.points_min),
				DECODE(NVL(old_references.points_max,999999),NVL(new_references.points_max,999999),
							NULL,old_references.points_max),
				DECODE(old_references.points_override_ind,new_references.points_override_ind,
							NULL,old_references.points_override_ind),
				DECODE(old_references.coord_person_id,new_references.coord_person_id,
							NULL,old_references.coord_person_id),
				DECODE(old_references.owner_org_unit_cd,new_references.owner_org_unit_cd,
							NULL,old_references.owner_org_unit_cd),
				DECODE(old_references.owner_ou_start_dt,new_references.owner_ou_start_dt,
							NULL,old_references.owner_ou_start_dt),
				DECODE(old_references.award_course_only_ind,new_references.award_course_only_ind,
							NULL,old_references.award_course_only_ind),
				DECODE(old_references.research_unit_ind,new_references.research_unit_ind,
							NULL,old_references.research_unit_ind),
				DECODE(old_references.industrial_ind,new_references.industrial_ind,
							NULL,old_references.industrial_ind),
				DECODE(old_references.practical_ind,new_references.practical_ind,
							NULL,old_references.practical_ind),
				DECODE(old_references.repeatable_ind,new_references.repeatable_ind,
							NULL,old_references.repeatable_ind),
				DECODE(old_references.assessable_ind,new_references.assessable_ind,
							NULL,old_references.assessable_ind),
				DECODE(NVL(old_references.unit_int_course_leveL_cd,'NULL'),
							NVL(new_references.unit_int_course_level_cd,'NULL'),
							NULL,old_references.unit_int_course_level_cd),
                                -- Added by rbezawad as per DLD PSP001-US on 24-May-2001
                                DECODE( NVL(old_references.advance_maximum,999999),
                                        NVL(new_references.advance_maximum,999999),
                                	NULL, old_references.advance_maximum),
                                DECODE( NVL(old_references.approval_date, IGS_GE_DATE.IGSDATE('1900/01/01')),
                                        NVL(new_references.approval_date,IGS_GE_DATE.IGSDATE('1900/01/01')) ,
                                	NULL, old_references.approval_date),
                                DECODE( NVL(old_references.cal_type_enrol_load_cal,'null'),
                                        NVL(new_references.cal_type_enrol_load_cal,'null') ,
                                	NULL, old_references.cal_type_enrol_load_cal),
                                DECODE( NVL(old_references.cal_type_offer_load_cal,'null'),
                                        NVL(new_references.cal_type_offer_load_cal,'null') ,
                                	NULL, old_references.cal_type_offer_load_cal),
                                DECODE( NVL(old_references.clock_hours,999999),
                                        NVL(new_references.clock_hours,999999) ,
                                	NULL, old_references.clock_hours),
                                DECODE( NVL(old_references.contact_hrs_lab,999999),
				        NVL(new_references.contact_hrs_lab,999999) ,
                                	NULL, old_references.contact_hrs_lab),
                                DECODE( NVL(old_references.contact_hrs_lecture,999999),
                                        NVL(new_references.contact_hrs_lecture,999999) ,
                                	NULL, old_references.contact_hrs_lecture),
                                DECODE( NVL(old_references.contact_hrs_other,999999),
                                        NVL(new_references.contact_hrs_other,999999) ,
                                	NULL, old_references.contact_hrs_other),
                                DECODE( NVL(old_references.continuing_education_units,999999),
                                        NVL(new_references.continuing_education_units,999999) ,
					NULL, old_references.continuing_education_units),
                                DECODE( NVL(old_references.curriculum_id,'null'),
                                        NVL(new_references.curriculum_id,'null') ,
                                	NULL, old_references.curriculum_id),
                                DECODE( NVL(old_references.enrollment_expected,999999),
                                        NVL(new_references.enrollment_expected,999999) ,
                                	NULL, old_references.enrollment_expected),
                                DECODE( NVL(old_references.enrollment_maximum,999999),
                                        NVL(new_references.enrollment_maximum,999999) ,
                                	NULL, old_references.enrollment_maximum),
                                DECODE( NVL(old_references.enrollment_minimum,999999),
                                        NVL(new_references.enrollment_minimum,999999) ,
                                	NULL, old_references.enrollment_minimum),
				DECODE( NVL(old_references.exclude_from_max_cp_limit,'N'),
                                        NVL(new_references.exclude_from_max_cp_limit,'N') ,
                                	NULL, old_references.exclude_from_max_cp_limit),
                                DECODE( NVL(old_references.federal_financial_aid,'N'),
                                        NVL(new_references.federal_financial_aid,'N') ,
                                	NULL, old_references.federal_financial_aid),
                                DECODE( NVL(old_references.institutional_financial_aid,'N'),
                                        NVL(new_references.institutional_financial_aid,'N') ,
                                	NULL, old_references.institutional_financial_aid),
                                DECODE( NVL(old_references.lab_credit_points,999999),
                                        NVL(new_references.lab_credit_points,999999) ,
                                	NULL, old_references.lab_credit_points),
                                DECODE( NVL(old_references.lecture_credit_points,999999),
                                        NVL(new_references.lecture_credit_points,999999) ,
                                	NULL, old_references.lecture_credit_points),
                                DECODE( NVL(old_references.max_repeat_credit_points,999999),
                                        NVL(new_references.max_repeat_credit_points,999999) ,
                                	NULL, old_references.max_repeat_credit_points),
                                DECODE( NVL(old_references.max_repeats_for_credit,999999),
                                        NVL(new_references.max_repeats_for_credit,999999) ,
                                	NULL, old_references.max_repeats_for_credit),
                                DECODE( NVL(old_references.max_repeats_for_funding,999999),
                                        NVL(new_references.max_repeats_for_funding,999999) ,
                                	NULL, old_references.max_repeats_for_funding),
				DECODE( NVL(old_references.non_schd_required_hrs,999999),
                                        NVL(new_references.non_schd_required_hrs,999999) ,
                                	NULL, old_references.non_schd_required_hrs),
                                DECODE( NVL(old_references.other_credit_points,999999),
                                        NVL(new_references.other_credit_points,999999) ,
                                	NULL, old_references.other_credit_points),
                                DECODE( NVL(old_references.override_enrollment_max,999999),
                                        NVL(new_references.override_enrollment_max,999999) ,
                                	NULL, old_references.override_enrollment_max),
                                DECODE( NVL(old_references.record_exclusion_flag,'N'),
                                        NVL(new_references.record_exclusion_flag,'N') ,
                                	NULL, old_references.record_exclusion_flag),
                                DECODE( NVL(old_references.ss_display_ind,'N'),
				        NVL(new_references.ss_display_ind,'N') ,
                                	NULL, old_references.ss_display_ind ),
                                DECODE( NVL(old_references.rpt_fmly_id,999999),
                                        NVL(new_references.rpt_fmly_id,999999),
                                	NULL, old_references.rpt_fmly_id),
                                DECODE( NVL(old_references.same_teach_period_repeats,999999),
                                        NVL(new_references.same_teach_period_repeats,999999) ,
					NULL, old_references.same_teach_period_repeats),
                                DECODE( NVL(old_references.same_teach_period_repeats_cp,999999),
                                        NVL(new_references.same_teach_period_repeats_cp,999999),
                                	NULL, old_references.same_teach_period_repeats_cp),
                                DECODE( NVL(old_references.same_teaching_period,'N'),
                                        NVL(new_references.same_teaching_period,'N') ,
                                	NULL, old_references.same_teaching_period),
                                DECODE( NVL(old_references.sequence_num_enrol_load_cal,999999),
                                        NVL(new_references.sequence_num_enrol_load_cal,999999) ,
                                	NULL, old_references.sequence_num_enrol_load_cal),
                                DECODE( NVL(old_references.sequence_num_offer_load_cal,999999),
                                        NVL(new_references.sequence_num_offer_load_cal,999999) ,
                                	NULL, old_references.sequence_num_offer_load_cal),
				DECODE( NVL(old_references.special_permission_ind,'N'),
                                        NVL(new_references.special_permission_ind,'N') ,
                                	NULL, old_references.special_permission_ind),
                                DECODE( NVL(old_references.state_financial_aid,'N'),
                                        NVL(new_references.state_financial_aid,'N') ,
                                	NULL, old_references.state_financial_aid),
                                DECODE( NVL(old_references.subtitle_id,999999),
				        NVL(new_references.subtitle_id,999999) ,
                                	NULL, old_references.subtitle_id),
                                DECODE( NVL(old_references.subtitle_modifiable_flag,'N'),
                                        NVL(new_references.subtitle_modifiable_flag,'N') ,
                                	NULL, old_references.subtitle_modifiable_flag),
                                DECODE( NVL(old_references.unit_type_id,999999),
                                        NVL(new_references.unit_type_id,999999) ,
                                	NULL, old_references.unit_type_id),
                                DECODE( NVL(old_references.work_load_cp_lab,999999),
                                        NVL(new_references.work_load_cp_lab,999999) ,
                                	NULL, old_references.work_load_cp_lab),
                                DECODE( NVL(old_references.work_load_cp_lecture,999999),
                                        NVL(new_references.work_load_cp_lecture,999999) ,
					NULL, old_references.work_load_cp_lecture),
                                DECODE( NVL(old_references.work_load_other,999999),
                                        NVL(new_references.work_load_other,999999),
                                	NULL, old_references.work_load_other),
                                DECODE( NVL(old_references.claimable_hours,9999999),
                                        NVL(new_references.claimable_hours,9999999),
                                	NULL, old_references.claimable_hours),
                                DECODE( NVL(old_references.auditable_ind,'N'),
                                        NVL(new_references.auditable_ind,'N'),
                                	NULL, old_references.auditable_ind),
                                DECODE( NVL(old_references.audit_permission_ind,'N'),
                                        NVL(new_references.audit_permission_ind,'N'),
                                	NULL, old_references.audit_permission_ind),
                                DECODE( NVL(old_references.max_auditors_allowed,9999999),
                                        NVL(new_references.max_auditors_allowed,9999999),
                                	NULL, old_references.max_auditors_allowed),
				DECODE( NVL(old_references.billing_credit_points,9999999),
                                        NVL(new_references.billing_credit_points,9999999),
                                	NULL, old_references.billing_credit_points),
				DECODE( NVL(old_references.ovrd_wkld_val_flag,'N'),
                                        NVL(new_references.ovrd_wkld_val_flag,'N'),
                                	NULL, old_references.ovrd_wkld_val_flag),
				DECODE( NVL(old_references.workload_val_code,'NULL'),
                                        NVL(new_references.workload_val_code,'NULL'),
                                	NULL, old_references.workload_val_code),
				DECODE( NVL(old_references.billing_hrs,9999999),
                                        NVL(new_references.billing_hrs,9999999),
                                	NULL, old_references.billing_hrs)
                                --
			INTO	v_start_dt,
				v_unit_status,
				v_title,
				v_short_title,
				v_title_override_ind,
				v_abbreviation,
				v_unit_level,
				v_credit_point_descriptor,
				v_achievable_credit_points,
				v_enrolled_credit_points,
				v_supp_exam_permitted_ind,
				v_points_increment,
				v_points_min,
				v_points_max,
				v_points_override_ind,
				v_coord_person_id,
				v_owner_org_unit_cd,
				v_owner_ou_start_dt,
				v_award_course_only_ind,
				v_research_unit_ind,
				v_industrial_ind,
				v_practical_ind,
				v_repeatable_ind,
				v_assessable_ind,
				v_unit_int_course_level_cd,
                                -- Added by rbezawad as per PSP001-US DLD on 24-May-2001
                                v_advance_maximum,
                                v_approval_date,
                                v_cal_type_enrol_load_cal,
                                v_cal_type_offer_load_cal,
                                v_clock_hours,
                                v_contact_hrs_lab,
                                v_contact_hrs_lecture,
                                v_contact_hrs_other,
                                v_continuing_education_units,
                                v_curriculum_id,
                                v_enrollment_expected,
                                v_enrollment_maximum,
                                v_enrollment_minimum,
                                v_exclude_from_max_cp_limit,
                                v_federal_financial_aid,
                                v_institutional_financial_aid,
                                v_lab_credit_points,
                                v_lecture_credit_points,
                                v_max_repeat_credit_points,
                                v_max_repeats_for_credit,
                                v_max_repeats_for_funding,
                                v_non_schd_required_hrs,
                                v_other_credit_points,
                                v_override_enrollment_max,
                                v_record_exclusion_flag,
                                v_ss_display_ind,
                                v_rpt_fmly_id,
                                v_same_teach_period_repeats,
                                v_same_teach_period_repeats_cp,
                                v_same_teaching_period,
                                v_sequence_num_enrol_load_cal,
                                v_sequence_num_offer_load_cal,
                                v_special_permission_ind,
                                v_state_financial_aid,
                                v_subtitle_id,
                                v_subtitle_modifiable_flag,
                                v_unit_type_id,
                                v_work_load_cp_lab,
                                v_work_load_cp_lecture,
                                v_work_load_other,
                                v_claimable_hours,
                                v_auditable_ind,
                                v_audit_permission_ind,
                                v_max_auditors_allowed,
				v_billing_credit_points,
			        v_ovrd_wkld_val_flag,
                                v_workload_val_code,
				v_billing_hrs
                                --
			FROM	dual;
			-- Create history record for update
			IGS_PS_GEN_006.CRSP_INS_UV_HIST(
				old_references.unit_cd,
				old_references.version_number,
				old_references.last_update_date,
				new_references.last_update_date,
				old_references.last_updated_by,
				v_start_dt,
				v_review_dt,
				v_expiry_dt,
				v_end_dt,
				v_unit_status,
				v_title,
				v_short_title,
				v_title_override_ind,
				v_abbreviation,
				v_unit_level,
				v_credit_point_descriptor,
				v_achievable_credit_points,
				v_enrolled_credit_points,
				v_supp_exam_permitted_ind,
				v_points_increment,
				v_points_min,
				v_points_max,
				v_points_override_ind,
				v_coord_person_id,
				v_owner_org_unit_cd,
				v_owner_ou_start_dt,
				v_award_course_only_ind,
				v_research_unit_ind,
				v_industrial_ind,
				v_practical_ind,
				v_repeatable_ind,
				v_assessable_ind,
				v_unit_int_course_level_cd,
                                v_ss_enrol_ind,
                                v_ivr_enrol_ind,
                                -- added by rbezawad as per PSP001-US DLD ON 24-MAY-2001
                                v_advance_maximum,
                                v_approval_date,
                                v_cal_type_enrol_load_cal,
                                v_cal_type_offer_load_cal,
                                v_clock_hours,
                                v_contact_hrs_lab,
                                v_contact_hrs_lecture,
                                v_contact_hrs_other,
                                v_continuing_education_units,
                                v_curriculum_id,
                                v_enrollment_expected,
                                v_enrollment_maximum,
                                v_enrollment_minimum,
                                v_exclude_from_max_cp_limit,
                                v_federal_financial_aid,
                                v_institutional_financial_aid,
                                v_lab_credit_points,
                                v_lecture_credit_points,
                                v_max_repeat_credit_points,
                                v_max_repeats_for_credit,
                                v_max_repeats_for_funding,
                                v_non_schd_required_hrs,
                                v_other_credit_points,
                                v_override_enrollment_max,
                                v_record_exclusion_flag,
                                v_ss_display_ind,
                                v_rpt_fmly_id,
                                v_same_teach_period_repeats,
                                v_same_teach_period_repeats_cp,
                                v_same_teaching_period,
                                v_sequence_num_enrol_load_cal,
                                v_sequence_num_offer_load_cal,
                                v_special_permission_ind,
                                v_state_financial_aid,
                                v_subtitle_id,
                                v_subtitle_modifiable_flag,
                                v_unit_type_id,
                                v_work_load_cp_lab,
                                v_work_load_cp_lecture,
                                v_work_load_other,
                                v_claimable_hours,
                                v_auditable_ind,
                                v_audit_permission_ind,
                                v_max_auditors_allowed,
				v_billing_credit_points,
			        v_ovrd_wkld_val_flag,
                                v_workload_val_code
				,v_billing_hrs
				);
		END IF;
	END IF;
	IF p_deleting THEN

	BEGIN
	FOR SPUVH_Rec IN SPUVH_CUR
	Loop
	IGS_PS_UNIT_VER_HIST_PKG.Delete_Row(X_ROWID=>SPUVH_Rec.Rowid);
	End Loop;
	END;


	END IF;
END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS

	cst_active		VARCHAR2 (6) ;
  	v_s_unit_status	IGS_PS_UNIT_STAT.s_unit_status%TYPE;
  	CURSOR 	c_get_s_unit_status
  			(cp_unit_status IGS_PS_UNIT_STAT.unit_status%TYPE)	IS
  		SELECT	s_unit_status
  		FROM	IGS_PS_UNIT_STAT
  		WHERE	unit_status = cp_unit_status;

	  v_rowid_saved	BOOLEAN := FALSE;

	  v_message_name	Varchar2(30);

  BEGIN
  	cst_active := 'ACTIVE';
	-- Validate IGS_PS_UNIT status and expiry date.
	IF p_inserting OR
		(p_updating AND
			((NVL(old_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01')) <>
			NVL(new_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
			(old_references.unit_status <> new_references.unit_status))) THEN

		v_rowid_saved:= TRUE;

	END IF;
	-- Validate the IGS_PS_UNIT status.
	IF p_inserting OR
	    (p_updating AND (old_references.unit_status <> new_references.unit_status)) THEN
		-- Save the rowid, old expiry date and old IGS_PS_UNIT status so
		-- the IGS_PS_UNIT status can be validated in the after statement
		-- trigger as calling IGS_PS_VAL_UV.crsp_val_uv_unit_sts from
		-- here will cause mutating table error. Also, the quality check
		-- may need to be performed if the status has been altered to
		-- active.

		v_rowid_saved:= TRUE;

 	END IF;


 IF v_rowid_saved	= TRUE Then

	-- Validate IGS_PS_UNIT status and expiry date.
  		IF p_inserting OR
  		   (p_updating AND
  		   ((NVL(old_references.expiry_dt,
  			IGS_GE_DATE.IGSDATE('1900/01/01')) <>
  		      NVL(new_references.expiry_dt,IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
  		      (old_references.unit_status <> new_references.unit_status))) THEN
  			IF IGS_PS_VAL_UV.crsp_val_uv_exp_sts (
  					new_references.unit_cd,
  					new_references.version_number,
  					new_references.expiry_dt,
  					new_references.unit_status,v_message_name) = FALSE THEN
			  Fnd_Message.Set_Name('IGS',v_message_name);
			  IGS_GE_MSG_STACK.ADD;
			  App_Exception.Raise_Exception;
  			END IF;
  		END IF;
  		-- Validate the IGS_PS_UNIT status
  		IF p_inserting OR
  		   (p_updating AND
  		   (old_references.unit_status <> new_references.unit_status)) THEN
  			IF IGS_PS_VAL_UV.crsp_val_uv_unit_sts (
  					new_references.unit_cd,
  					new_references.version_number,
  					new_references.unit_status,
  					old_references.unit_status,v_message_name,FALSE) = FALSE THEN
			  Fnd_Message.Set_Name('IGS',v_message_name);
			  IGS_GE_MSG_STACK.ADD;
			  App_Exception.Raise_Exception;
  			END IF;
  			OPEN c_get_s_unit_status (new_references.unit_status);
  			FETCH c_get_s_unit_status INTO v_s_unit_status;
  			CLOSE c_get_s_unit_status;
  			-- Perform a quality check if updating to a system status of ACTIVE.
  			-- IGS_GE_NOTE: A IGS_PS_UNIT version can only be created with a status of PLANNED.
  			-- 	Hence, only need to perform the check if updating.
  			IF p_updating AND
  			   (v_s_unit_status = cst_active) THEN
  				IF IGS_PS_VAL_UV.crsp_val_uv_quality (
  					new_references.unit_cd,
  					new_references.version_number,
  					old_references.unit_status,v_message_name) = FALSE THEN
				  Fnd_Message.Set_Name('IGS',v_message_name);
				  IGS_GE_MSG_STACK.ADD;
				  App_Exception.Raise_Exception;
  				END IF;
  			END IF;
  		END IF;
 END IF;

END AfterRowInsertUpdate2;

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2,
				Column_Value 	IN	VARCHAR2	)
AS
--sarakshi  15-May-2006  Bug#3064563, modified the format mask(clock_hours,continuing_education_units,work_load_cp_lecture,work_load_cp_lab,contact_hrs_lab) as specified in the bug.
--smvk      09-Jan-2003  Bug # 2702263, Checking the range of values for columns claimable_hours,lecture_credit_points,
--                       lab_credit_points,other_credit_points,clock_hours,continuing_education_units,
--                       advance_maximum,enrollment_expected,enrollment_minimum,enrollment_maximum,
--                       override_enrollment_max,max_auditors_allowed,work_load_cp_lecture,work_load_cp_lab,
--                       max_repeat_credit_points,same_teach_period_repeats_cp,work_load_other,contact_hrs_lecture,
--                       contact_hrs_lab,contact_hrs_other,non_schd_required_hrs,max_repeats_for_credit,
--                       max_repeats_for_funding and same_teach_period_repeats.
--sarakshi  11-Dec-2002  Bug#2702240,checking values for state_financial_aid,federal_financial_aid,
--                       institutional_financial_aid,same_teaching_period,exclude_from_cp_limit,
--                       record_exclusion_flag,ss_display_ind,special_permission_ind,
--                       anon_unit_grading_ind,anon_assess_grading_ind
-- sarakshi 27-Nov-2002 Enh#2649028,for all numeric value comparision, changed the AND condition with OR
--                      to check the value between 0 and 999.Also Practicle indicator check of Y/N added
-- rgangara 03-May-2001 modified as per DLD Unit Section Enrollment
BEGIN

     	IF Column_Name IS NULL Then
		NULL;
	ELSIF Upper(Column_Name)='ABBREVIATION' Then
		New_References.abbreviation := Column_Value;
	ELSIF Upper(Column_Name)='ASSESSABLE_IND' Then
		New_References.assessable_ind := Column_Value;
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
	ELSIF Upper(Column_Name)='SHORT_TITLE' TheN
		New_References.Short_Title := Column_Value;
	ELSIF Upper(Column_Name)='SUPP_EXAM_PERMITTED_IND' Then
		New_References.supp_exam_permitted_ind := Column_Value;
	ELSIF Upper(Column_Name)='TITLE' Then
		New_References.title := Column_Value;
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
	ELSIF Upper(Column_Name)='ACHIEVABLE_CREDIT_POINTS' Then
		New_References.achievable_credit_points:= IGS_GE_NUMBER.to_num(Column_Value);
	ELSIF Upper(Column_Name)='POINTS_INCREMENT' Then
		New_References.points_increment:= IGS_GE_NUMBER.to_num(Column_Value);
	ELSIF Upper(Column_Name)='ENROLLED_CREDIT_POINTS' Then
		New_References.enrolled_credit_points:= IGS_GE_NUMBER.to_num(Column_Value);
	ELSIF Upper(Column_Name)='VERSION_NUMBER' Then
		New_References.version_number:= IGS_GE_NUMBER.to_num(Column_Value);
	ELSIF Upper(Column_Name)='POINTS_MIN' Then
		New_References.points_min:= IGS_GE_NUMBER.to_num(Column_Value);
	ELSIF Upper(Column_Name)='POINTS_MAX' Then
		New_References.points_min:= IGS_GE_NUMBER.to_num(Column_Value);
        ELSIF Upper(Column_Name)='STATE_FINANCIAL_AID' Then
                New_References.state_financial_aid := Column_Value;
        ELSIF Upper(Column_Name)='FEDERAL_FINANCIAL_AID' Then
                New_References.federal_financial_aid := Column_Value;
        ELSIF Upper(Column_Name)='INSTITUTIONAL_FINANCIAL_AID' Then
                New_References.institutional_financial_aid := Column_Value;
        ELSIF Upper(Column_Name)='SAME_TEACHING_PERIOD' Then
                New_References.same_teaching_period := Column_Value;
        ELSIF Upper(Column_Name)='EXCLUDE_FROM_MAX_CP_LIMIT' Then
                New_References.exclude_from_max_cp_limit := Column_Value;
        ELSIF Upper(Column_Name)='RECORD_EXCLUSION_FLAG' Then
                New_References.record_exclusion_flag := Column_Value;
        ELSIF Upper(Column_Name)='SS_DISPLAY_IND' Then
                New_References.ss_display_ind := Column_Value;
        ELSIF Upper(Column_Name)='SPECIAL_PERMISSION_IND' Then
                New_References.special_permission_ind := Column_Value;
        ELSIF Upper(Column_Name)='SS_ENROL_IND' Then
                New_References.ss_enrol_ind := Column_Value;
        ELSIF Upper(Column_Name)='IVR_ENROL_IND' Then
                New_References.ivr_enrol_ind := Column_Value;
        ELSIF Upper(Column_Name)='ANON_UNIT_GRADING_IND' Then
                New_References.anon_unit_grading_ind := Column_Value;
        ELSIF Upper(Column_Name)='ANON_ASSESS_GRADING_IND' Then
                New_References.anon_assess_grading_ind := Column_Value;
        ELSIF Upper(Column_Name)='AUDITABLE_IND' Then
                New_References.auditable_ind := Column_Value;
        ELSIF Upper(Column_Name)='AUDIT_PERMISSION_IND' Then
                New_References.audit_permission_ind := Column_Value;
        -- Added as a part of 2702263
        ELSIF Upper(Column_Name)='CLAIMABLE_HOURS' Then
                New_References.claimable_hours := Column_Value;
        ELSIF Upper(Column_Name)='LECTURE_CREDIT_POINTS' Then
                New_References.lecture_credit_points := Column_Value;
        ELSIF Upper(Column_Name)='LAB_CREDIT_POINTS' Then
                New_References.lab_credit_points := Column_Value;
        ELSIF Upper(Column_Name)='OTHER_CREDIT_POINTS' Then
                New_References.other_credit_points := Column_Value;
        ELSIF Upper(Column_Name)='CLOCK_HOURS' Then
                New_References.clock_hours := Column_Value;
        ELSIF Upper(Column_Name)='WORK_LOAD_CP_LECTURE' Then
                New_References.work_load_cp_lecture := Column_Value;
        ELSIF Upper(Column_Name)='WORK_LOAD_CP_LAB' Then
                New_References.work_load_cp_lab := Column_Value;
        ELSIF Upper(Column_Name)='CONTINUING_EDUCATION_UNITS' Then
                New_References.continuing_education_units := Column_Value;
        ELSIF Upper(Column_Name)='ADVANCE_MAXIMUM' Then
                New_References.advance_maximum := Column_Value;
        ELSIF Upper(Column_Name)='ENROLLMENT_EXPECTED' Then
                New_References.enrollment_expected := Column_Value;
        ELSIF Upper(Column_Name)='ENROLLMENT_MINIMUM' Then
                New_References.enrollment_minimum := Column_Value;
        ELSIF Upper(Column_Name)='ENROLLMENT_MAXIMUM' Then
                New_References.enrollment_maximum := Column_Value;
        ELSIF Upper(Column_Name)='OVERRIDE_ENROLLMENT_MAX' Then
                New_References.override_enrollment_max := Column_Value;
        ELSIF Upper(Column_Name)='MAX_AUDITORS_ALLOWED' Then
                New_References.max_auditors_allowed := Column_Value;
        ELSIF Upper(Column_Name)='MAX_REPEAT_CREDIT_POINTS' Then
                New_References.max_repeat_credit_points := Column_Value;
        ELSIF Upper(Column_Name)='SAME_TEACH_PERIOD_REPEATS_CP' Then
                New_References.same_teach_period_repeats_cp:= Column_Value;
        ELSIF Upper(Column_Name)='WORK_LOAD_OTHER' Then
                New_References.work_load_other := Column_Value;
        ELSIF Upper(Column_Name)='CONTACT_HRS_LECTURE' Then
                New_References.contact_hrs_lecture := Column_Value;
        ELSIF Upper(Column_Name)='CONTACT_HRS_LAB' Then
                New_References.contact_hrs_lab := Column_Value;
        ELSIF Upper(Column_Name)='CONTACT_HRS_OTHER' Then
                New_References.contact_hrs_other := Column_Value;
        ELSIF Upper(Column_Name)='NON_SCHD_REQUIRED_HRS' Then
                New_References.non_schd_required_hrs := Column_Value;
        ELSIF Upper(Column_Name)='MAX_REPEATS_FOR_CREDIT' Then
                New_References.max_repeats_for_credit := Column_Value;
        ELSIF Upper(Column_Name)='MAX_REPEATS_FOR_FUNDING' Then
                New_References.max_repeats_for_funding := Column_Value;
        ELSIF Upper(Column_Name)='SAME_TEACH_PERIOD_REPEATS' Then
                New_References.same_teach_period_repeats := Column_Value;
        ELSIF Upper(Column_Name)='BILLING_CREDIT_POINTS' Then
                New_References.billing_credit_points := Column_Value;
        ELSIF Upper(Column_Name)='OVRD_WKLD_VAL_FLAG' Then
                New_References.ovrd_wkld_val_flag := Column_Value;
        ELSIF Upper(Column_Name)='BILLING_HRS' Then
                New_References.billing_hrs := Column_Value;
	END IF;

	IF Upper(Column_Name)='ABBREVIATION' OR Column_Name IS NULL Then
		IF New_References.abbreviation <> UPPER(New_References.abbreviation) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ASSESSABLE_IND' OR Column_Name IS NULL Then
		IF New_References.Assessable_Ind <> UPPER(New_References.Assessable_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

		IF New_References.Assessable_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;


	END IF;


	IF Upper(Column_Name)='AWARD_COURSE_ONLY_IND' OR Column_Name IS NULL Then
		IF New_References.Award_Course_Only_Ind <> UPPER(New_References.Award_Course_Only_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

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
		IF New_References.Industrial_Ind <> UPPER(New_References.Industrial_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

		IF New_References.Industrial_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

	END IF;

	IF Upper(Column_Name)='POINTS_OVERRIDE_IND' OR Column_Name IS NULL Then
		IF New_References.Points_Override_Ind <> UPPER(New_References.Points_Override_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

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

		IF New_References.Practical_ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='REPEATABLE_IND' OR Column_Name IS NULL Then
		IF New_References.Repeatable_Ind <> UPPER(New_References.Repeatable_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

		IF New_References.Repeatable_Ind NOT IN ( 'Y' , 'N','X' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF Upper(Column_Name)='RESEARCH_UNIT_IND' OR Column_Name IS NULL Then
		IF New_References.Research_Unit_Ind <> UPPER(New_References.Research_Unit_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

		IF New_References.Research_Unit_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF Upper(Column_Name)='SUPP_EXAM_PERMITTED_IND' OR Column_Name IS NULL Then
		IF New_References.Supp_Exam_Permitted_Ind <> UPPER(New_References.Supp_Exam_Permitted_Ind) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;

		IF New_References.Supp_Exam_Permitted_Ind NOT IN ( 'Y' , 'N' ) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF Upper(Column_Name)='TITLE_OVERRIDE_IND' OR Column_Name IS NULL Then
		IF New_References.Title_Override_Ind <> UPPER(New_References.Title_Override_Ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.Title_Override_Ind NOT IN ( 'Y' , 'N' ) Then
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


	IF Upper(Column_Name)='ACHIEVABLE_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.Achievable_Credit_Points < 0 OR New_References.Achievable_Credit_Points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='POINTS_INCREMENT' OR Column_Name IS NULL Then
		IF New_References.Points_Increment < 0 OR New_References.Points_Increment > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ENROLLED_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.Enrolled_Credit_Points < 0 OR New_References.Enrolled_Credit_Points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='VERSION_NUMBER' OR Column_Name IS NULL Then
		IF New_References.Version_Number < 1 OR New_References.Version_Number > 999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='POINTS_MIN' OR Column_Name IS NULL Then
		IF New_References.Points_Min < 0 OR New_References.Points_Min > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='POINTS_MAX' OR Column_Name IS NULL Then
		IF New_References.Points_Max < 0 OR New_References.Points_Max > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;


        -- Code added as per DLD Unit Section Enrollment Information
        -- Validating atleast one Enrollment method is checked
        IF (Upper(Column_Name) = 'SS_ENROL_IND' OR Upper(Column_Name)= 'IVR_ENROL_IND') OR Column_Name IS NULL THEN
               IF (new_references.ss_enrol_ind = 'N' AND new_references.ivr_enrol_ind = 'N') THEN
                        Fnd_Message.Set_Name('IGS','IGS_PS_ONE_UNIT_ENR_MTHD');
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
               END IF;
        END IF;

	-- Added as part of Bug# 2636716, EN Integration.
	IF Upper(Column_Name)='AUDITABLE_IND' OR Column_Name IS NULL Then
		IF New_References.auditable_Ind <> UPPER(New_References.auditable_Ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.auditable_Ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='AUDIT_PERMISSION_IND' OR Column_Name IS NULL Then
		IF New_References.audit_permission_Ind <> UPPER(New_References.audit_permission_Ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.audit_permission_Ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	-- Added as part of Bug#2702240,following checks have been added
	IF Upper(Column_Name)='STATE_FINANCIAL_AID' OR Column_Name IS NULL Then
		IF New_References.state_financial_aid <> UPPER(New_References.state_financial_aid) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.state_financial_aid NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='FEDERAL_FINANCIAL_AID' OR Column_Name IS NULL Then
		IF New_References.federal_financial_aid <> UPPER(New_References.federal_financial_aid) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.federal_financial_aid NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='INSTITUTIONAL_FINANCIAL_AID' OR Column_Name IS NULL Then
		IF New_References.institutional_financial_aid <> UPPER(New_References.institutional_financial_aid) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.institutional_financial_aid NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='SAME_TEACHING_PERIOD' OR Column_Name IS NULL Then
		IF New_References.same_teaching_period <> UPPER(New_References.same_teaching_period) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.same_teaching_period NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='EXCLUDE_FROM_MAX_CP_LIMIT' OR Column_Name IS NULL Then
		IF New_References.exclude_from_max_cp_limit <> UPPER(New_References.exclude_from_max_cp_limit) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.exclude_from_max_cp_limit NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='RECORD_EXCLUSION_FLAG' OR Column_Name IS NULL Then
		IF New_References.record_exclusion_flag <> UPPER(New_References.record_exclusion_flag) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.record_exclusion_flag NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='SS_DISPLAY_IND' OR Column_Name IS NULL Then
		IF New_References.ss_display_ind <> UPPER(New_References.ss_display_ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.ss_display_ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='SPECIAL_PERMISSION_IND' OR Column_Name IS NULL Then
		IF New_References.special_permission_ind <> UPPER(New_References.special_permission_ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.special_permission_ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ANON_UNIT_GRADING_IND' OR Column_Name IS NULL Then
		IF New_References.anon_unit_grading_ind <> UPPER(New_References.anon_unit_grading_ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.anon_unit_grading_ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ANON_ASSESS_GRADING_IND' OR Column_Name IS NULL Then
		IF New_References.anon_assess_grading_ind <> UPPER(New_References.anon_assess_grading_ind) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;

		IF New_References.anon_assess_grading_ind NOT IN ( 'Y' , 'N' ) Then
		  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
		END IF;
	END IF;

        -- Added as a part of 2702263
	IF Upper(Column_Name)='CLAIMABLE_HOURS' OR Column_Name IS NULL Then
		IF New_References.claimable_hours < 0 OR New_References.claimable_hours > 99999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='LECTURE_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.lecture_credit_points < 0 OR New_References.lecture_credit_points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='LAB_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.lab_credit_points < 0 OR New_References.lab_credit_points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='OTHER_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.other_credit_points < 0 OR New_References.other_credit_points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CLOCK_HOURS' OR Column_Name IS NULL Then
		IF New_References.clock_hours < 0 OR New_References.clock_hours > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CONTINUING_EDUCATION_UNITS' OR Column_Name IS NULL Then
		IF New_References.continuing_education_units < 0 OR New_References.continuing_education_units > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ADVANCE_MAXIMUM' OR Column_Name IS NULL Then
		IF New_References.advance_maximum < 0 OR New_References.advance_maximum > 999999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ENROLLMENT_EXPECTED' OR Column_Name IS NULL Then
		IF New_References.enrollment_expected < 0 OR New_References.enrollment_expected > 999999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ENROLLMENT_MINIMUM' OR Column_Name IS NULL Then
		IF New_References.enrollment_minimum < 0 OR New_References.enrollment_minimum > 999999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='ENROLLMENT_MAXIMUM' OR Column_Name IS NULL Then
		IF New_References.enrollment_maximum < 0 OR New_References.enrollment_maximum > 999999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='OVERRIDE_ENROLLMENT_MAX' OR Column_Name IS NULL Then
		IF New_References.override_enrollment_max < 0 OR New_References.override_enrollment_max > 999999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='MAX_AUDITORS_ALLOWED' OR Column_Name IS NULL Then
		IF New_References.max_auditors_allowed < 1 OR New_References.max_auditors_allowed > 999999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='WORK_LOAD_CP_LECTURE' OR Column_Name IS NULL Then
		IF New_References.work_load_cp_lecture < 0 OR New_References.work_load_cp_lecture > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='WORK_LOAD_CP_LAB' OR Column_Name IS NULL Then
		IF New_References.work_load_cp_lab < 0 OR New_References.work_load_cp_lab > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='MAX_REPEAT_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.max_repeat_credit_points < 0 OR New_References.max_repeat_credit_points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='SAME_TEACH_PERIOD_REPEATS_CP' OR Column_Name IS NULL Then
		IF New_References.same_teach_period_repeats_cp < 0 OR New_References.same_teach_period_repeats_cp > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='WORK_LOAD_OTHER' OR Column_Name IS NULL Then
		IF New_References.work_load_other < 0 OR New_References.WORK_LOAD_OTHER > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CONTACT_HRS_LECTURE' OR Column_Name IS NULL Then
		IF New_References.contact_hrs_lecture < 0 OR New_References.contact_hrs_lecture > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CONTACT_HRS_LAB' OR Column_Name IS NULL Then
		IF New_References.contact_hrs_lab < 0 OR New_References.contact_hrs_lab > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='CONTACT_HRS_OTHER' OR Column_Name IS NULL Then
		IF New_References.contact_hrs_other < 0 OR New_References.contact_hrs_other > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='NON_SCHD_REQUIRED_HRS' OR Column_Name IS NULL Then
		IF New_References.non_schd_required_hrs < 0 OR New_References.non_schd_required_hrs > 999.99 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='MAX_REPEATS_FOR_CREDIT' OR Column_Name IS NULL Then
		IF New_References.max_repeats_for_credit < 0 OR New_References.max_repeats_for_credit > 999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='MAX_REPEATS_FOR_FUNDING' OR Column_Name IS NULL Then
		IF New_References.max_repeats_for_funding < 0 OR New_References.max_repeats_for_funding > 999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='SAME_TEACH_PERIOD_REPEATS' OR Column_Name IS NULL Then
		IF New_References.same_teach_period_repeats < 0 OR New_References.same_teach_period_repeats > 999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='BILLING_CREDIT_POINTS' OR Column_Name IS NULL Then
		IF New_References.billing_credit_points < 0 OR New_References.billing_credit_points > 999.999 Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
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

	IF Upper(Column_Name)='OVRD_WKLD_VAL_FLAG' OR Column_Name IS NULL Then
          IF New_References.ovrd_wkld_val_flag NOT IN ( 'Y' , 'N' ) Then
	     Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
             IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	  END IF;
	END IF;


END Check_Constraints;
----------------------------------------------------------------------
  PROCEDURE Check_Parent_Existance AS
  BEGIN

  -- Merged with fnd Lookups
  /*  IF (((old_references.credit_point_descriptor = new_references.credit_point_descriptor)) OR
        ((new_references.credit_point_descriptor IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_CR_PT_DSCR_PKG.Get_PK_For_Validation (
        new_references.credit_point_descriptor) THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF; */

    IF (((old_references.owner_org_unit_cd = new_references.owner_org_unit_cd) AND
         (old_references.owner_ou_start_dt = new_references.owner_ou_start_dt)) OR
        ((new_references.owner_org_unit_cd IS NULL) OR
         (new_references.owner_ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.owner_org_unit_cd,
        new_references.owner_ou_start_dt) THEN

				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    IF (((old_references.coord_person_id = new_references.coord_person_id)) OR
        ((new_references.coord_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.coord_person_id) THEN

				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    IF (((old_references.unit_int_course_level_cd = new_references.unit_int_course_level_cd)) OR
        ((new_references.unit_int_course_level_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_INT_LVL_PKG.Get_PK_For_Validation (
        new_references.unit_int_course_level_cd) THEN

				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    IF (((old_references.unit_level = new_references.unit_level)) OR
        ((new_references.unit_level IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_LEVEL_PKG.Get_PK_For_Validation (
        new_references.unit_level) THEN

				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    IF (((old_references.unit_cd = new_references.unit_cd)) OR
        ((new_references.unit_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_PKG.Get_PK_For_Validation (
        new_references.unit_cd) THEN

				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;

    IF (((old_references.unit_status = new_references.unit_status)) OR
        ((new_references.unit_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_STAT_PKG.Get_PK_For_Validation (
        new_references.unit_status) THEN

				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;


    END IF;
    IF (((old_references.curriculum_id = new_references.curriculum_id)) OR
        ((new_references.curriculum_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unt_crclm_pkg.get_pk_for_validation (
                new_references.curriculum_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.subtitle_id = new_references.subtitle_id)) OR
        ((new_references.subtitle_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_subtitle_pkg.get_pk_for_validation (
                new_references.subtitle_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.rpt_fmly_id = new_references.rpt_fmly_id)) OR
        ((new_references.rpt_fmly_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_rpt_fmly_pkg.get_pk_for_validation (
                new_references.rpt_fmly_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_type_id = new_references.unit_type_id)) OR
        ((new_references.unit_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_type_lvl_pkg.get_pk_for_validation (
                new_references.unit_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.cal_type_enrol_load_cal = new_references.cal_type_enrol_load_cal) AND
         (old_references.sequence_num_enrol_load_cal = new_references.sequence_num_enrol_load_cal)) OR
        ((new_references.cal_type_enrol_load_cal IS NULL) OR
         (new_references.sequence_num_enrol_load_cal IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.cal_type_enrol_load_cal,
                new_references.sequence_num_enrol_load_cal
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.cal_type_offer_load_cal = new_references.cal_type_offer_load_cal) AND
         (old_references.sequence_num_offer_load_cal = new_references.sequence_num_offer_load_cal)) OR
        ((new_references.cal_type_offer_load_cal IS NULL) OR
         (new_references.sequence_num_offer_load_cal IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_inst_pkg.get_pk_for_validation (
                new_references.cal_type_offer_load_cal,
                new_references.sequence_num_offer_load_cal
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rev_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS

--  Who     When        What
--vvutukur    09-Jun-2003  Enh#2831572.Financial Accounting Build.Added call to igs_fi_ftci_accts_pkg.get_fk_igs_ps_ver.
-- smadathi 01-Feb-2002 Added igf_sp_unit.get_fk_igs_ps_unit_ver and
--                      igf_sp_std_unit.get_fk_igs_ps_unit_ver as per enhancement bug 2154941
-- smadathi 03-JUL-2001 added igs_en_elgb_ovr_step_pkg.get_fk_igs_ps_unit_ver as per enhancement bug no. 1830175
--svenkata     02-06-2003 Modified to remove references to TBH of pkg IGS_EN_ELGB_OVR_STEP_PKG. Instead , added
--			  references to package IGS_EN_ELGB_OVR_UOO.Bug #2829272
-- SMADATHI 29-MAY-2001 removed foreign key references to IGS_PS_UNT_REPT_FMLY , IGS_PS_UNT_PRV_GRADE as per DLD
-- SMADATHI 25-MAY-2001 removed foreign key references to IGS_PS_USEC_RPT_FMLY  as per DLD
-- pmarada  15-feb-2002  Addedcheckchaild exist for the HESA requirment .

  BEGIN

    igs_fi_ftci_accts_pkg.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

    IGS_AD_PS_APLINSTUNT_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_AV_STND_ALT_UNIT_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_AV_STND_UNIT_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_CO_ITM_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_ANL_LOAD_U_LN_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_LVL_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_LVL_HIST_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_CO_OU_CO_REF_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_EN_SU_ATTEMPT_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_EN_SU_ATTEMPT_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_EN_ELGB_OVR_UOO_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_TCH_RESP_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_TCH_RESP_HIST_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_CATEGORY_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_DSCP_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNT_DSCP_HIST_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_FI_UNIT_FEE_TRG_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_OFR_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_REF_CD_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_REF_HIST_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_VER_NOTE_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

    IGS_PS_UNIT_VER_RU_PKG.GET_FK_IGS_PS_UNIT_VER (
      old_references.unit_cd,
      old_references.version_number
      );

   IGS_PS_UNIT_GRD_SCHM_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number
     );

  IGS_PS_UNIT_OFR_MODE_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  IGS_PS_UNIT_FLD_STDY_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  IGS_PS_UNIT_LOCATION_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  IGS_PS_UNIT_FACILITY_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  IGS_PS_FACLTY_DISP_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd);

  IGS_PS_UNIT_SUBTITLE_PKG.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  igs_ps_unit_x_grpmem_pkg.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  igs_ps_unit_accts_pkg.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);


  igf_sp_unit_pkg.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

  igf_sp_std_unit_pkg.get_fk_igs_ps_unit_ver(
      old_references.unit_cd,
      old_references.version_number);

 -- Added the following check chaild existance for the HESA requirment, pmarada
   -- smaddali removed the Execute immediate statement and calling packages directly, bug#3306063
   igs_he_st_unt_vs_all_pkg.get_fk_igs_ps_unit_ver_all(x_unit_cd => old_references.unit_cd,
	x_version_number => old_references.version_number);

  END Check_Child_Existance;
--------------------------------------------------------------
  FUNCTION Get_PK_For_Validation (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN AS

    -- Bug#2416978, Depending on the unit status lock on the table is acquired
    -- lock is required when the unit status is Planned since it is allowed to be delete
    -- lock is not required when the unit status is non planned so an explicit lock is not required
    -- opening different cursors depending on the unit status

    CURSOR cur_get_status IS
        SELECT   us.s_unit_status
        FROM     igs_ps_unit_ver_all uv,
                 igs_ps_unit_stat us
        WHERE    uv.unit_status=us.unit_status
        AND      uv.unit_cd = x_unit_cd
        AND      uv.version_number = x_version_number;
    l_unit_status igs_ps_unit_stat.s_unit_status%TYPE;

    CURSOR cur_rowid_planned IS
      SELECT   ROWID
      FROM     igs_ps_unit_ver_all
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      FOR UPDATE NOWAIT;

    CURSOR cur_rowid_non_planned IS
      SELECT   ROWID
      FROM     igs_ps_unit_ver_all
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number;

    lv_rowid cur_rowid_planned%ROWTYPE;

BEGIN

  OPEN cur_get_status;
  FETCH cur_get_status INTO l_unit_status;
  IF cur_get_status%NOTFOUND THEN
    CLOSE cur_get_status;
    RETURN(FALSE);
  ELSE
    CLOSE cur_get_status;
    IF l_unit_status = 'PLANNED' THEN
      OPEN cur_rowid_planned;
      FETCH cur_rowid_planned INTO lv_rowid;
      IF cur_rowid_planned%FOUND THEN
        CLOSE cur_rowid_planned;
        RETURN (TRUE);
      ELSE
        CLOSE cur_rowid_planned;
        RETURN (FALSE);
      END IF;
    ELSE
      OPEN cur_rowid_non_planned;
      FETCH cur_rowid_non_planned INTO lv_rowid;
      IF cur_rowid_non_planned%FOUND THEN
        CLOSE cur_rowid_non_planned;
        RETURN (TRUE);
      ELSE
        CLOSE cur_rowid_non_planned;
        RETURN (FALSE);
      END IF;
    END IF;
  END IF;

END Get_PK_For_Validation;
--------------------------------------------------------------------
  PROCEDURE GET_FK_IGS_PS_CR_PT_DSCR (
    x_credit_point_descriptor IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_ALL
      WHERE    credit_point_descriptor = x_credit_point_descriptor ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UV_CPD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_CR_PT_DSCR;
---------------------------------------------------------------
  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_ALL
      WHERE    owner_org_unit_cd = x_org_unit_cd
      AND      owner_ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UV_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;
---------------------------------------------------------------
  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_ALL
      WHERE    coord_person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UV_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;
---------------------------------------------------------------
  PROCEDURE GET_FK_IGS_PS_UNIT_INT_LVL (
    x_unit_int_course_level_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_ALL
      WHERE    unit_int_course_level_cd = x_unit_int_course_level_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UV_UICL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_INT_LVL;
---------------------------------------------------------------
  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_ALL
      WHERE    unit_cd = x_unit_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UV_UN_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT;
---------------------------------------------------------------
  PROCEDURE GET_FK_IGS_PS_UNIT_STAT (
    x_unit_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_VER_ALL
      WHERE    unit_status = x_unit_status ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UV_UST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_STAT;
  ---------------------------------------------------------------
  PROCEDURE get_fk_igs_ps_rpt_fmly_all (
    x_rpt_fmly_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 17-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_ver_all
      WHERE   ((rpt_fmly_id = x_rpt_fmly_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_UV_UCUR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_rpt_fmly_all;
 ---------------------------------------------------------------
 PROCEDURE get_fk_igs_ps_unit_subtitle (
    x_subtitle_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 17-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_ver_all
      WHERE   ((subtitle_id = x_subtitle_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_UV_UVSB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_unit_subtitle;
---------------------------------------------------------------
   PROCEDURE get_fk_igs_ps_unt_crclm_all (
   x_curriculum_id                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 17-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_ver_all
      WHERE   ((curriculum_id = x_curriculum_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_UV_CRCLM_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_unt_crclm_all;
 ---------------------------------------------------------------

   PROCEDURE get_fk_igs_ca_inst_all (
    x_cal_type                       IN     VARCHAR2,
    x_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 17-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_ver_all
      WHERE   (cal_type_enrol_load_cal = x_cal_type and
               sequence_num_enrol_load_cal = x_sequence_number);

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_UV_CAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst_all;


   PROCEDURE get_fk_igs_ca_inst_all1 (
    x_cal_type                       IN     VARCHAR2,
    x_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : apelleti
  ||  Created On : 17-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_ver_all
      WHERE   (cal_type_offer_load_cal = x_cal_type and
               sequence_num_offer_load_cal = x_sequence_number);

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_UV_CAI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_inst_all1;
---------------------------------------------------------------
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_unit_cd in VARCHAR2 ,
    x_version_number in NUMBER ,
    x_start_dt in DATE ,
    x_review_dt in DATE ,
    x_expiry_dt in DATE ,
    x_end_dt in DATE ,
    x_unit_status in VARCHAR2 ,
    x_title in VARCHAR2 ,
    x_short_title in VARCHAR2 ,
    x_title_override_ind in VARCHAR2 ,
    x_abbreviation in VARCHAR2 ,
    x_unit_level in VARCHAR2 ,
    x_credit_point_descriptor in VARCHAR2 ,
    x_enrolled_credit_points in NUMBER ,
    x_points_override_ind in VARCHAR2 ,
    x_supp_exam_permitted_ind in VARCHAR2 ,
    x_coord_person_id in NUMBER ,
    x_owner_org_unit_cd in VARCHAR2 ,
    x_owner_ou_start_dt in DATE ,
    x_award_course_only_ind in VARCHAR2 ,
    x_research_unit_ind in VARCHAR2 ,
    x_industrial_ind in VARCHAR2 ,
    x_practical_ind in VARCHAR2 ,
    x_repeatable_ind in VARCHAR2 ,
    x_assessable_ind in VARCHAR2 ,
    x_achievable_credit_points in NUMBER ,
    x_points_increment in NUMBER ,
    x_points_min in NUMBER ,
    x_points_max in NUMBER ,
    x_unit_int_course_level_cd in VARCHAR2 ,
    x_subtitle in VARCHAR2 ,
    x_subtitle_modifiable_flag in VARCHAR2 ,
    x_approval_date in DATE ,
    x_lecture_credit_points in NUMBER ,
    x_lab_credit_points in NUMBER ,
    x_other_credit_points in NUMBER ,
    x_clock_hours in NUMBER ,
    x_work_load_cp_lecture in NUMBER ,
    x_work_load_cp_lab in NUMBER ,
    x_continuing_education_units in NUMBER ,
    x_enrollment_expected in NUMBER ,
    x_enrollment_minimum in NUMBER ,
    x_enrollment_maximum in NUMBER ,
    x_advance_maximum in NUMBER ,
    x_state_financial_aid in VARCHAR2 ,
    x_federal_financial_aid in VARCHAR2 ,
    x_institutional_financial_aid in VARCHAR2 ,
    x_same_teaching_period in VARCHAR2 ,
    x_max_repeats_for_credit in NUMBER ,
    x_max_repeats_for_funding in NUMBER ,
    x_max_repeat_credit_points in NUMBER ,
    x_same_teach_period_repeats in NUMBER ,
    x_same_teach_period_repeats_cp in NUMBER ,
    x_attribute_category in VARCHAR2 ,
    x_attribute1 in VARCHAR2 ,
    x_attribute2 in VARCHAR2 ,
    x_attribute3 in VARCHAR2 ,
    x_attribute4 in VARCHAR2 ,
    x_attribute5 in VARCHAR2 ,
    x_attribute6 in VARCHAR2 ,
    x_attribute7 in VARCHAR2 ,
    x_attribute8 in VARCHAR2 ,
    x_attribute9 in VARCHAR2 ,
    x_attribute10 in VARCHAR2 ,
    x_attribute11 in VARCHAR2 ,
    x_attribute12 in VARCHAR2 ,
    x_attribute13 in VARCHAR2 ,
    x_attribute14 in VARCHAR2 ,
    x_attribute15 in VARCHAR2 ,
    x_attribute16 in VARCHAR2 ,
    x_attribute17 in VARCHAR2 ,
    x_attribute18 in VARCHAR2 ,
    x_attribute19 in VARCHAR2 ,
    x_attribute20 in VARCHAR2 ,
    x_subtitle_id                       IN     NUMBER      ,
    x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind       IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal    IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal    IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_unit_type_id                      IN     NUMBER ,
    x_special_permission_ind            IN     VARCHAR2 ,
    x_created_by in NUMBER ,
    x_creation_date in DATE ,
    x_last_updated_by in NUMBER ,
    x_last_update_date in DATE ,
    x_last_update_login in NUMBER ,
    x_org_id in NUMBER ,
    x_ss_enrol_ind in VARCHAR2 ,
    x_ivr_enrol_ind in VARCHAR2 ,
    x_rev_account_cd  IN VARCHAR2 ,
    x_claimable_hours IN NUMBER ,
    x_anon_unit_grading_ind IN VARCHAR2 ,
    x_anon_assess_grading_ind IN VARCHAR2 ,
    x_auditable_ind IN VARCHAR2,
    x_audit_permission_ind IN VARCHAR2,
    x_max_auditors_allowed IN NUMBER,
    x_billing_credit_points IN NUMBER,
    x_ovrd_wkld_val_flag    IN VARCHAR2 ,
    x_workload_val_code     IN VARCHAR2 ,
    x_billing_hrs           IN NUMBER
      ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_cd,
      x_version_number,
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
      x_credit_point_descriptor,
      x_enrolled_credit_points,
      x_points_override_ind,
      x_supp_exam_permitted_ind,
      x_coord_person_id,
      x_owner_org_unit_cd,
      x_owner_ou_start_dt,
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
      x_subtitle,
      x_subtitle_modifiable_flag,
      x_approval_date,
      x_lecture_credit_points,
      x_lab_credit_points,
      x_other_credit_points,
      x_clock_hours,
      x_work_load_cp_lecture,
      x_work_load_cp_lab,
      x_continuing_education_units,
      x_enrollment_expected,
      x_enrollment_minimum,
      x_enrollment_maximum,
      x_advance_maximum,
      x_state_financial_aid,
      x_federal_financial_aid,
      x_institutional_financial_aid,
      x_same_teaching_period,
      x_max_repeats_for_credit,
      x_max_repeats_for_funding,
      x_max_repeat_credit_points,
      x_same_teach_period_repeats,
      x_same_teach_period_repeats_cp,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      X_SUBTITLE_ID,
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
    x_unit_type_id,
    x_special_permission_ind,
      x_created_by,
      x_creation_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_update_login,
      x_org_id,
      x_ss_enrol_ind,
      x_ivr_enrol_ind,
      x_rev_account_cd,
      x_claimable_hours,
      x_anon_unit_grading_ind,
      x_anon_assess_grading_ind,
      x_auditable_ind,
      x_audit_permission_ind,
      x_max_auditors_allowed,
      x_billing_credit_points,
      x_ovrd_wkld_val_flag ,
      x_workload_val_code ,
      x_billing_hrs
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
				     p_deleting => FALSE,
				     p_updating => FALSE );

	 IF Get_PK_For_Validation (New_References.unit_cd,
						New_References.version_number) THEN
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	   END IF;
	   Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE,
				     p_inserting => FALSE,
				     p_deleting => FALSE );
      --bug#2416978,check updation specific validation
      beforerowupdate;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE ,
				     p_inserting => FALSE,
				     p_updating => FALSE );
      --bug#2416978,check deletion specific validation
      beforerowdelete;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (New_References.unit_cd, New_References.version_number) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	   Check_Constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
	  Check_Child_Existance;
   END IF;

  END Before_DML;
----------------------------------------------------------------------------
  PROCEDURE dflt_unit_ref_code (
    p_c_unit_cd igs_ps_unit_ver.unit_cd%TYPE,
    p_n_version_number igs_ps_unit_ver.version_number%TYPE,
    p_c_message_name OUT NOCOPY VARCHAR2
  ) AS
    CURSOR c_igs_ge_ref_cd_type  IS
      SELECT reference_cd_type
      FROM   igs_ge_ref_cd_type
      WHERE  mandatory_flag ='Y'
      AND    unit_flag ='Y'
      AND    restricted_flag ='Y'
      AND    closed_ind = 'N';

    CURSOR c_igs_ge_ref_cd ( cp_reference_cd_type igs_ge_ref_cd.reference_cd_type%TYPE ) IS
      SELECT reference_cd,
             description
      FROM   igs_ge_ref_cd
      WHERE  reference_cd_type = cp_reference_cd_type
      AND    default_flag = 'Y';

    l_c_rowid VARCHAR2(30);

  BEGIN
    FOR cur_igs_ge_ref_cd_type IN c_igs_ge_ref_cd_type
    LOOP
      FOR cur_igs_ge_ref_cd IN c_igs_ge_ref_cd(cur_igs_ge_ref_cd_type.reference_cd_type)
      LOOP
        -- insert a value in igs_ps_unit_ref_cd for every value of  unit_cd and version_number having
        -- a applicable unit defined as mandatory  and a default reference code
        BEGIN
          l_c_rowid:=NULL;
	  igs_ps_unit_ref_cd_pkg.insert_row(x_rowid             => l_c_rowid,
                                          x_unit_cd           => p_c_unit_cd,
                                          x_reference_cd_type => cur_igs_ge_ref_cd_type.reference_cd_type,
                                          x_version_number    => p_n_version_number,
                                          x_reference_cd      => cur_igs_ge_ref_cd.reference_cd,
                                          x_description       => cur_igs_ge_ref_cd.description,
                                          x_mode              => 'R');
          EXCEPTION
          -- The failure of insertion of reference code should not stop the creation of new unit.
	      -- Hence any exception raised by  the TBH is trapped and the current processing is allowed to proceed.
            WHEN OTHERS THEN
              NULL;
          END;
      END LOOP;
    END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- If an error occurs during insertion in igs_ps_ent_pt_ref_cd then raise an exception.
	p_c_message_name := FND_MESSAGE.GET;

  END dflt_unit_ref_code;
-------------------------------------------------------------
  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
    l_message_name  VARCHAR2(30) ;
    CURSOR c_uv(cp_rowid igs_ps_unit_ver.row_id%TYPE) IS
      SELECT unit_cd, version_number
      FROM   igs_ps_unit_ver
      WHERE  ROWID = cp_rowid;
    l_unit_cd igs_ps_unit_ver.unit_cd%TYPE;
    l_version_number igs_ps_unit_ver.version_number%TYPE;

    CURSOR c_occurs(cp_unit_cd  igs_ps_unit_ver.unit_cd%TYPE , cp_version_number igs_ps_unit_ver.version_number%TYPE) IS
	SELECT uso.unit_section_occurrence_id
	FROM Igs_ps_usec_occurs_all uso,
	     Igs_ps_unit_ofr_opt_all us,
	     Igs_ca_inst_all ci
	WHERE uso.uoo_id=us.uoo_id
	AND us.cal_type=ci.cal_type
	AND us.ci_sequence_number = ci.sequence_number
	AND TRUNC (ci.end_dt) > TRUNC (SYSDATE)
        AND (uso.schedule_status IS NOT NULL AND uso.schedule_status NOT IN ('PROCESSING','USER_UPDATE'))
	AND uso.no_set_day_ind ='N'
	AND us.unit_section_status <>  'NOT_OFFERED'
	AND us.unit_cd =cp_unit_cd
	AND us.version_number =cp_version_number
	AND NOT EXISTS (SELECT 'X' FROM igs_ps_usec_lim_wlst ulw WHERE ulw.uoo_id = us.uoo_id);

  CURSOR c_title(cp_unit_cd VARCHAR2, cp_version_number NUMBER) IS
  SELECT a.*,a.rowid
  FROM   igs_ps_usec_ref a ,
         igs_ps_unit_ofr_opt_all b,
	 igs_ca_inst_all c
  WHERE  a.uoo_id= b.uoo_id
  AND    b.unit_cd= cp_unit_cd
  AND    b.version_number = cp_version_number
  AND    b.cal_type=c.cal_type
  AND    b.ci_sequence_number=c.sequence_number;



  CURSOR c_unit_subtitle(cp_unit_cd VARCHAR2, cp_version_number NUMBER,cp_subtitle VARCHAR2) IS
  SELECT subtitle_id
  FROM   igs_ps_unit_subtitle_v
  WHERE  unit_cd = cp_unit_cd AND
  version_number = cp_version_number AND
  subtitle =cp_subtitle;

  update_flag BOOLEAN := FALSE;
  r_unit_subtitle igs_ps_unit_subtitle_v.subtitle_id%TYPE;
  v_title igs_ps_usec_ref.title%TYPE;


  BEGIN
    l_message_name := NULL;
    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE,
			      p_updating => FALSE,
			      p_deleting => FALSE);

      OPEN c_uv(x_rowid);
      FETCH c_uv INTO l_unit_cd, l_version_number;
      IF (c_uv%FOUND) THEN
        dflt_unit_ref_code( p_c_unit_cd        => l_unit_cd,
	                    p_n_version_number => l_version_number,
			    p_c_message_name   => l_message_name);
        IF l_message_name IS NOT NULL THEN
           app_exception.raise_exception;
	END IF;
      END IF;
      CLOSE c_uv;
      l_rowid := NULL;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE ,
			      p_inserting => FALSE,
			      p_deleting => FALSE);

      --After update, update the occurrence schedule status to Reschedule if changing any of the Enrollment Maximum, Override Enrollmnet
      -- Maximum and Enrollment Expected, condition being the corresponding unit section does not have enrollment limit record.
      IF (
         NVL(new_references.enrollment_maximum,-999) <>  NVL(old_references.enrollment_maximum,-999) OR
         NVL(new_references.enrollment_expected,-999) <> NVL(old_references.enrollment_expected,-999) OR
         NVL(new_references.override_enrollment_max,-999) <> NVL(old_references.override_enrollment_max,-999)
         ) THEN

        FOR l_occurs_rec IN c_occurs(new_references.unit_cd,new_references.version_number) LOOP
          igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
        END LOOP;
      END IF;

      --whenever there is a change in unit level title/subtitle then the section level data needs to be changed.
      IF (old_references.title <> new_references.title AND new_references.title_override_ind = 'N')
        OR (NVL(old_references.subtitle_id,-999) <>  NVL(new_references.subtitle_id,-999) AND new_references.subtitle_modifiable_flag = 'N') THEN
        FOR c_title_rec IN c_title(new_references.unit_cd,new_references.version_number) LOOP
	update_flag := FALSE;
	v_title :=c_title_rec.title;
        r_unit_subtitle := c_title_rec.Subtitle_id;

	IF new_references.title_override_ind = 'N' AND  new_references.title <> NVL(c_title_rec.title,'NULL') THEN
	  v_title :=  new_references.title;
	  update_flag := TRUE;
	END IF;

	IF  new_references.subtitle_modifiable_flag = 'N' AND  NVL(new_references.subtitle_id,-999) <> NVL(c_title_rec.subtitle_id,-999) THEN
          r_unit_subtitle :=new_references.subtitle_id;
	  update_flag := TRUE;
	END IF;

	IF update_flag THEN
	  Igs_Ps_Usec_Ref_Pkg.Update_Row (
	    X_Mode                              => 'R',
	    X_rowid                             => c_title_rec.rowid,
	    X_Unit_Section_Reference_Id         => c_title_rec.unit_section_reference_id,
	    X_Uoo_Id                            => c_title_rec.uoo_id,
	    X_Short_Title                       => c_title_rec.Short_Title,
	    X_Subtitle                          => NULL,
	    X_Subtitle_ModIFiable_Flag          => c_title_rec.subtitle_modifiable_flag,
	    X_Class_Sched_Exclusion_Flag        => c_title_rec.class_schedule_exclusion_flag,
	    X_Registration_Exclusion_Flag       => c_title_rec.registration_exclusion_flag,
	    X_Attribute_Category                => c_title_rec.attribute_category,
	    X_Attribute1                        => c_title_rec.Attribute1,
	    X_Attribute2                        => c_title_rec.Attribute2,
	    X_Attribute3                        => c_title_rec.Attribute3,
	    X_Attribute4                        => c_title_rec.Attribute4,
	    X_Attribute5                        => c_title_rec.Attribute5,
	    X_Attribute6                        => c_title_rec.Attribute6,
	    X_Attribute7                        => c_title_rec.Attribute7,
	    X_Attribute8                        => c_title_rec.Attribute8,
	    X_Attribute9                        => c_title_rec.Attribute9,
	    X_Attribute10                       => c_title_rec.Attribute10,
	    X_Attribute11                       => c_title_rec.Attribute11,
	    X_Attribute12                       => c_title_rec.Attribute12,
	    X_Attribute13                       => c_title_rec.Attribute13,
	    X_Attribute14                       => c_title_rec.Attribute14,
	    X_Attribute15                       => c_title_rec.Attribute15,
	    X_Attribute16                       => c_title_rec.Attribute16,
	    X_Attribute17                       => c_title_rec.Attribute17,
	    X_Attribute18                       => c_title_rec.Attribute18,
	    X_Attribute19                       => c_title_rec.Attribute19,
	    X_Attribute20                       => c_title_rec.Attribute20,
	    X_Title                             => v_title,
	    X_Subtitle_id                       => r_unit_subtitle,
	    X_Record_Exclusion_Flag             => c_title_rec.record_exclusion_flag
	    );
	  END IF;
        END LOOP;
      END IF;


    END IF;

  END After_DML;
-------------------------------------------------------------------
PROCEDURE insert_row (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
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
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
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
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  x_subtitle_id                       IN     NUMBER      ,
  x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind       IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal    IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal    IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_unit_type_id                      IN     NUMBER ,
    x_special_permission_ind            IN     VARCHAR2 ,
  X_MODE in VARCHAR2 ,
  X_ORG_ID IN NUMBER,
  X_SS_ENROL_IND IN VARCHAR2 ,
  X_IVR_ENROL_IND IN VARCHAR2 ,
  x_claimable_hours IN NUMBER ,
  x_rev_account_cd IN VARCHAR2 ,
  x_anon_unit_grading_ind IN VARCHAR2 ,
  x_anon_assess_grading_ind IN VARCHAR2 ,
  x_auditable_ind IN VARCHAR2,
  x_audit_permission_ind IN VARCHAR2,
  x_max_auditors_allowed IN NUMBER,
  x_billing_credit_points IN NUMBER ,
  x_ovrd_wkld_val_flag    IN VARCHAR2 ,
  x_workload_val_code     IN VARCHAR2 ,
  x_billing_hrs           IN NUMBER
  ) AS
  /**********************************************************************************************************************************
  sarakshi              14-oct-2003             Enh#3052452,removed the nvl clause from max_repeats_for_credits in the before_dml call.
  sbaliga 		13-feb-2002		Assigned igs_ge_gen_003.get_org_id to x_org_id in call to before_dml
  						as part of SWCR006 build.
  **************************************************************************************************************/
    cursor C is select ROWID from IGS_PS_UNIT_VER_ALL
      where UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER;
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
  x_rowid =>  X_ROWID,
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
  x_start_dt => X_START_DT,
  x_review_dt => X_REVIEW_DT,
  x_expiry_dt => X_EXPIRY_DT,
  x_end_dt => X_END_DT,
  x_unit_status => X_UNIT_STATUS,
  x_title => X_TITLE,
  x_short_title => X_SHORT_TITLE,
  x_title_override_ind => NVL(X_TITLE_OVERRIDE_IND,'Y'),
  x_abbreviation => X_ABBREVIATION,
  x_unit_level => X_UNIT_LEVEL,
  x_credit_point_descriptor => X_CREDIT_POINT_DESCRIPTOR,
  x_enrolled_credit_points => X_ENROLLED_CREDIT_POINTS,
  x_points_override_ind => NVL(X_POINTS_OVERRIDE_IND,'Y'),
  x_supp_exam_permitted_ind => NVL(X_SUPP_EXAM_PERMITTED_IND,'Y'),
  x_coord_person_id => X_COORD_PERSON_ID,
  x_owner_org_unit_cd => X_OWNER_ORG_UNIT_CD,
  x_owner_ou_start_dt => X_OWNER_OU_START_DT,
  x_award_course_only_ind => NVL(X_AWARD_COURSE_ONLY_IND,'Y'),
  x_research_unit_ind => NVL(X_RESEARCH_UNIT_IND,'N'),
  x_industrial_ind => NVL(X_INDUSTRIAL_IND,'N'),
  x_practical_ind => NVL(X_PRACTICAL_IND,'N'),
  x_repeatable_ind => NVL(X_REPEATABLE_IND,'Y'),
  x_assessable_ind => NVL(X_ASSESSABLE_IND,'Y'),
  x_achievable_credit_points => X_ACHIEVABLE_CREDIT_POINTS,
  x_points_increment => X_POINTS_INCREMENT,
  x_points_min => X_POINTS_MIN,
  x_points_max => X_POINTS_MAX,
  x_unit_int_course_level_cd => X_UNIT_INT_COURSE_LEVEL_CD,
  x_subtitle => X_SUBTITLE,
  x_subtitle_modifiable_flag => X_SUBTITLE_MODIFIABLE_FLAG,
  x_approval_date => X_APPROVAL_DATE,
  x_lecture_credit_points => X_LECTURE_CREDIT_POINTS,
  x_lab_credit_points => X_LAB_CREDIT_POINTS,
  x_other_credit_points => X_OTHER_CREDIT_POINTS,
  x_clock_hours => X_CLOCK_HOURS,
  x_work_load_cp_lecture => X_WORK_LOAD_CP_LECTURE,
  x_work_load_cp_lab => X_WORK_LOAD_CP_LAB,
  x_continuing_education_units => X_CONTINUING_EDUCATION_UNITS,
  x_enrollment_expected => X_ENROLLMENT_EXPECTED,
  x_enrollment_minimum => X_ENROLLMENT_MINIMUM,
  x_enrollment_maximum => X_ENROLLMENT_MAXIMUM,
  x_advance_maximum => X_ADVANCE_MAXIMUM,
  x_state_financial_aid => NVL(X_STATE_FINANCIAL_AID, 'Y'),
  x_federal_financial_aid => NVL(X_FEDERAL_FINANCIAL_AID, 'Y'),
  x_institutional_financial_aid => NVL(X_INSTITUTIONAL_FINANCIAL_AID, 'Y'),
  x_same_teaching_period => X_SAME_TEACHING_PERIOD,
  x_max_repeats_for_credit => X_MAX_REPEATS_FOR_CREDIT,
  x_max_repeats_for_funding => X_MAX_REPEATS_FOR_FUNDING,
  x_max_repeat_credit_points => X_MAX_REPEAT_CREDIT_POINTS,
  x_same_teach_period_repeats => X_SAME_TEACH_PERIOD_REPEATS,
  x_same_teach_period_repeats_cp => X_SAME_TEACH_PERIOD_REPEATS_CP,
  x_attribute_category => X_ATTRIBUTE_CATEGORY,
  x_attribute1 => X_ATTRIBUTE1,
  x_attribute2 => X_ATTRIBUTE2,
  x_attribute3 => X_ATTRIBUTE3,
  x_attribute4 => X_ATTRIBUTE4,
  x_attribute5 => X_ATTRIBUTE5,
  x_attribute6 => X_ATTRIBUTE6,
  x_attribute7 => X_ATTRIBUTE7,
  x_attribute8 => X_ATTRIBUTE8,
  x_attribute9 => X_ATTRIBUTE9,
  x_attribute10 => X_ATTRIBUTE10,
  x_attribute11 => X_ATTRIBUTE11,
  x_attribute12 => X_ATTRIBUTE12,
  x_attribute13 => X_ATTRIBUTE13,
  x_attribute14 => X_ATTRIBUTE14,
  x_attribute15 => X_ATTRIBUTE15,
  x_attribute16 => X_ATTRIBUTE16,
  x_attribute17 => X_ATTRIBUTE17,
  x_attribute18 => X_ATTRIBUTE18,
  x_attribute19 => X_ATTRIBUTE19,
  x_attribute20 => X_ATTRIBUTE20,
  X_subtitle_id => X_SUBTITLE_ID,
  x_work_load_other => x_work_load_other,
   x_contact_hrs_lecture => x_contact_hrs_lecture,
    x_contact_hrs_lab => x_contact_hrs_lab,
    x_contact_hrs_other => x_contact_hrs_other,
    x_non_schd_required_hrs => x_non_schd_required_hrs,
    x_exclude_from_max_cp_limit => NVL(x_exclude_from_max_cp_limit,'N'),
    x_record_exclusion_flag => NVL(x_record_exclusion_flag,'N'),
    x_ss_display_ind => NVL(x_ss_display_ind,'N'),
    x_cal_type_enrol_load_cal => x_cal_type_enrol_load_cal,
    x_sequence_num_enrol_load_cal => x_sequence_num_enrol_load_cal,
    x_cal_type_offer_load_cal => x_cal_type_offer_load_cal,
    x_sequence_num_offer_load_cal => x_sequence_num_offer_load_cal,
    x_curriculum_id => x_curriculum_id,
    x_override_enrollment_max => x_override_enrollment_max,
    x_rpt_fmly_id => x_rpt_fmly_id,
    x_unit_type_id => x_unit_type_id,
    x_special_permission_ind => NVL(x_special_permission_ind,'N'),
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_ss_enrol_ind => X_SS_ENROL_IND,
  x_ivr_enrol_ind => X_IVR_ENROL_IND,
  x_rev_account_cd => x_rev_account_cd  ,
  x_claimable_hours => x_claimable_hours ,
  x_anon_unit_grading_ind => x_anon_unit_grading_ind ,
  x_anon_assess_grading_ind => x_anon_assess_grading_ind ,
  x_auditable_ind => x_auditable_ind,
  x_audit_permission_ind => x_audit_permission_ind,
  x_max_auditors_allowed => x_max_auditors_allowed,
  x_billing_credit_points => x_billing_credit_points,
  x_ovrd_wkld_val_flag   => x_ovrd_wkld_val_flag ,
  x_workload_val_code   => x_workload_val_code ,
  x_billing_hrs         => x_billing_hrs
  );


  INSERT INTO IGS_PS_UNIT_VER_ALL (
    UNIT_CD,
    VERSION_NUMBER,
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
    CREDIT_POINT_DESCRIPTOR,
    ENROLLED_CREDIT_POINTS,
    POINTS_OVERRIDE_IND,
    SUPP_EXAM_PERMITTED_IND,
    COORD_PERSON_ID,
    OWNER_ORG_UNIT_CD,
    OWNER_OU_START_DT,
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
    SUBTITLE_MODIFIABLE_FLAG,
    APPROVAL_DATE,
    LECTURE_CREDIT_POINTS,
    LAB_CREDIT_POINTS,
    OTHER_CREDIT_POINTS,
    CLOCK_HOURS,
    WORK_LOAD_CP_LECTURE,
    WORK_LOAD_CP_LAB,
    CONTINUING_EDUCATION_UNITS,
    ENROLLMENT_EXPECTED,
    ENROLLMENT_MINIMUM,
    ENROLLMENT_MAXIMUM,
    ADVANCE_MAXIMUM,
    STATE_FINANCIAL_AID,
    FEDERAL_FINANCIAL_AID,
    INSTITUTIONAL_FINANCIAL_AID,
    SAME_TEACHING_PERIOD,
    MAX_REPEATS_FOR_CREDIT,
    MAX_REPEATS_FOR_FUNDING,
    MAX_REPEAT_CREDIT_POINTS,
    SAME_TEACH_PERIOD_REPEATS,
    SAME_TEACH_PERIOD_REPEATS_CP,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
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
    unit_type_id,
    special_permission_ind,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    SS_ENROL_IND,
    IVR_ENROL_IND,
    REV_ACCOUNT_CD,
    CLAIMABLE_HOURS,
    ANON_UNIT_GRADING_IND,
    ANON_ASSESS_GRADING_IND,
    AUDITABLE_IND,
    AUDIT_PERMISSION_IND,
    MAX_AUDITORS_ALLOWED,
    BILLING_CREDIT_POINTS,
    OVRD_WKLD_VAL_FLAG,
    WORKLOAD_VAL_CODE,
    BILLING_HRS
  ) VALUES (
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
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
    NEW_REFERENCES.CREDIT_POINT_DESCRIPTOR,
    NEW_REFERENCES.ENROLLED_CREDIT_POINTS,
    NEW_REFERENCES.POINTS_OVERRIDE_IND,
    NEW_REFERENCES.SUPP_EXAM_PERMITTED_IND,
    NEW_REFERENCES.COORD_PERSON_ID,
    NEW_REFERENCES.OWNER_ORG_UNIT_CD,
    NEW_REFERENCES.OWNER_OU_START_DT,
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
    NEW_REFERENCES.SUBTITLE_MODIFIABLE_FLAG,
    NEW_REFERENCES.APPROVAL_DATE,
    NEW_REFERENCES.LECTURE_CREDIT_POINTS,
    NEW_REFERENCES.LAB_CREDIT_POINTS,
    NEW_REFERENCES.OTHER_CREDIT_POINTS,
    NEW_REFERENCES.CLOCK_HOURS,
    NEW_REFERENCES.WORK_LOAD_CP_LECTURE,
    NEW_REFERENCES.WORK_LOAD_CP_LAB,
    NEW_REFERENCES.CONTINUING_EDUCATION_UNITS,
    NEW_REFERENCES.ENROLLMENT_EXPECTED,
    NEW_REFERENCES.ENROLLMENT_MINIMUM,
    NEW_REFERENCES.ENROLLMENT_MAXIMUM,
    NEW_REFERENCES.ADVANCE_MAXIMUM,
    NEW_REFERENCES.STATE_FINANCIAL_AID,
    NEW_REFERENCES.FEDERAL_FINANCIAL_AID,
    NEW_REFERENCES.INSTITUTIONAL_FINANCIAL_AID,
    NEW_REFERENCES.SAME_TEACHING_PERIOD,
    NEW_REFERENCES.MAX_REPEATS_FOR_CREDIT,
    NEW_REFERENCES.MAX_REPEATS_FOR_FUNDING,
    NEW_REFERENCES.MAX_REPEAT_CREDIT_POINTS,
    NEW_REFERENCES.SAME_TEACH_PERIOD_REPEATS,
    NEW_REFERENCES.SAME_TEACH_PERIOD_REPEATS_CP,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.ATTRIBUTE1,
    NEW_REFERENCES.ATTRIBUTE2,
    NEW_REFERENCES.ATTRIBUTE3,
    NEW_REFERENCES.ATTRIBUTE4,
    NEW_REFERENCES.ATTRIBUTE5,
    NEW_REFERENCES.ATTRIBUTE6,
    NEW_REFERENCES.ATTRIBUTE7,
    NEW_REFERENCES.ATTRIBUTE8,
    NEW_REFERENCES.ATTRIBUTE9,
    NEW_REFERENCES.ATTRIBUTE10,
    NEW_REFERENCES.ATTRIBUTE11,
    NEW_REFERENCES.ATTRIBUTE12,
    NEW_REFERENCES.ATTRIBUTE13,
    NEW_REFERENCES.ATTRIBUTE14,
    NEW_REFERENCES.ATTRIBUTE15,
    NEW_REFERENCES.ATTRIBUTE16,
    NEW_REFERENCES.ATTRIBUTE17,
    NEW_REFERENCES.ATTRIBUTE18,
    NEW_REFERENCES.ATTRIBUTE19,
    NEW_REFERENCES.ATTRIBUTE20,
    NEW_REFERENCES.subtitle_id,
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
    new_references.unit_type_id,
    new_references.special_permission_ind,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    new_references.org_id,
    new_references.ss_enrol_ind,
    new_references.ivr_enrol_ind,
    new_references.rev_account_cd,
    new_references.claimable_hours,
    new_references.anon_unit_grading_ind,
    new_references.anon_assess_grading_ind,
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

END insert_row;

PROCEDURE lock_row (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
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
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
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
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  x_subtitle_id                       IN     NUMBER      ,
  x_work_load_other                   IN     NUMBER ,
  x_contact_hrs_lecture               IN     NUMBER ,
  x_contact_hrs_lab                   IN     NUMBER ,
  x_contact_hrs_other                 IN     NUMBER ,
  x_non_schd_required_hrs             IN     NUMBER ,
  x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
  x_record_exclusion_flag             IN     VARCHAR2 ,
  x_ss_display_ind       IN     VARCHAR2 ,
  x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
  x_sequence_num_enrol_load_cal    IN     NUMBER ,
  x_cal_type_offer_load_cal           IN     VARCHAR2 ,
  x_sequence_num_offer_load_cal    IN     NUMBER ,
  x_curriculum_id                     IN     VARCHAR2 ,
  x_override_enrollment_max           IN     NUMBER ,
  x_rpt_fmly_id                       IN     NUMBER ,
  x_unit_type_id                      IN     NUMBER ,
  x_special_permission_ind            IN     VARCHAR2 ,
  X_SS_ENROL_IND in VARCHAR2 ,
  X_IVR_ENROL_IND in VARCHAR2 ,
  x_claimable_hours IN NUMBER ,
  x_rev_account_cd IN VARCHAR2  ,
  x_anon_unit_grading_ind IN VARCHAR2 ,
  x_anon_assess_grading_ind IN VARCHAR2 ,
  X_AUDITABLE_IND IN VARCHAR2,
  X_AUDIT_PERMISSION_IND IN VARCHAR2,
  X_MAX_AUDITORS_ALLOWED IN NUMBER,
  x_billing_credit_points IN NUMBER,
  x_ovrd_wkld_val_flag    IN VARCHAR2 ,
  x_workload_val_code     IN VARCHAR2 ,
  x_billing_hrs           IN NUMBER
) AS
  ------------------------------------------------------------------
  --Purpose: As per enhancement bug no.1775394 , the column subtitle in
  --         igs_ps_unit_ver_all is obsoleted . The reference to it was
  --         removed .
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --smvk        27-Jun-2003     Bug # 3011578. Truncating start_date, end_date, expiry_date, approval_date and review date.
  --smadathi    13-JUN-2001     refer purpose
  -------------------------------------------------------------------
  cursor c1 is select
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
      CREDIT_POINT_DESCRIPTOR,
      ENROLLED_CREDIT_POINTS,
      POINTS_OVERRIDE_IND,
      SUPP_EXAM_PERMITTED_IND,
      COORD_PERSON_ID,
      OWNER_ORG_UNIT_CD,
      OWNER_OU_START_DT,
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
      SUBTITLE_MODIFIABLE_FLAG,
      APPROVAL_DATE,
      LECTURE_CREDIT_POINTS,
      LAB_CREDIT_POINTS,
      OTHER_CREDIT_POINTS,
      CLOCK_HOURS,
      WORK_LOAD_CP_LECTURE,
      WORK_LOAD_CP_LAB,
      CONTINUING_EDUCATION_UNITS,
      ENROLLMENT_EXPECTED,
      ENROLLMENT_MINIMUM,
      ENROLLMENT_MAXIMUM,
      ADVANCE_MAXIMUM,
      STATE_FINANCIAL_AID,
      FEDERAL_FINANCIAL_AID,
      INSTITUTIONAL_FINANCIAL_AID,
      SAME_TEACHING_PERIOD,
      MAX_REPEATS_FOR_CREDIT,
      MAX_REPEATS_FOR_FUNDING,
      MAX_REPEAT_CREDIT_POINTS,
      SAME_TEACH_PERIOD_REPEATS,
      SAME_TEACH_PERIOD_REPEATS_CP,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20,
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
    unit_type_id,
    special_permission_ind,
    SS_ENROL_IND,
    IVR_ENROL_IND,
    rev_account_cd,
    claimable_hours ,
    anon_unit_grading_ind,
    anon_assess_grading_ind,
    auditable_ind,
    audit_permission_ind,
    max_auditors_allowed,
    billing_credit_points,
    ovrd_wkld_val_flag,
    workload_val_code,
    billing_hrs
    FROM IGS_PS_UNIT_VER_ALL
    WHERE ROWID = X_ROWID for update nowait;
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

  if (
   (TRUNC(tlinfo.START_DT) = TRUNC(X_START_DT))
      AND ((TRUNC(tlinfo.REVIEW_DT) = TRUNC(X_REVIEW_DT))
           OR ((tlinfo.REVIEW_DT is null)
               AND (X_REVIEW_DT is null)))
      AND ((TRUNC(tlinfo.EXPIRY_DT) = TRUNC(X_EXPIRY_DT))
           OR ((tlinfo.EXPIRY_DT is null)
               AND (X_EXPIRY_DT is null)))
      AND ((TRUNC(tlinfo.END_DT) = TRUNC(X_END_DT))
           OR ((tlinfo.END_DT is null)
               AND (X_END_DT is null)))
      AND (tlinfo.UNIT_STATUS = X_UNIT_STATUS)
      AND (tlinfo.TITLE = X_TITLE)
      AND (tlinfo.SHORT_TITLE = X_SHORT_TITLE)
      AND (tlinfo.TITLE_OVERRIDE_IND = X_TITLE_OVERRIDE_IND)
      AND (tlinfo.ABBREVIATION = X_ABBREVIATION)
      AND (tlinfo.UNIT_LEVEL = X_UNIT_LEVEL)
      AND (tlinfo.CREDIT_POINT_DESCRIPTOR = X_CREDIT_POINT_DESCRIPTOR)
      AND (tlinfo.ENROLLED_CREDIT_POINTS = X_ENROLLED_CREDIT_POINTS)
      AND (tlinfo.POINTS_OVERRIDE_IND = X_POINTS_OVERRIDE_IND)
      AND (tlinfo.SUPP_EXAM_PERMITTED_IND = X_SUPP_EXAM_PERMITTED_IND)
      AND (tlinfo.COORD_PERSON_ID = X_COORD_PERSON_ID)
      AND (tlinfo.OWNER_ORG_UNIT_CD = X_OWNER_ORG_UNIT_CD)
      AND (tlinfo.OWNER_OU_START_DT = X_OWNER_OU_START_DT)
      AND (tlinfo.AWARD_COURSE_ONLY_IND = X_AWARD_COURSE_ONLY_IND)
      AND (tlinfo.RESEARCH_UNIT_IND = X_RESEARCH_UNIT_IND)
      AND (tlinfo.INDUSTRIAL_IND = X_INDUSTRIAL_IND)
      AND (tlinfo.PRACTICAL_IND = X_PRACTICAL_IND)
      AND (tlinfo.REPEATABLE_IND = X_REPEATABLE_IND)
      AND (tlinfo.ASSESSABLE_IND = X_ASSESSABLE_IND)
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
      AND ((tlinfo.SUBTITLE_MODIFIABLE_FLAG = X_SUBTITLE_MODIFIABLE_FLAG )
           OR ((tlinfo.SUBTITLE_MODIFIABLE_FLAG is null)
               AND (X_SUBTITLE_MODIFIABLE_FLAG is null)))
      AND ((TRUNC(tlinfo.APPROVAL_DATE) = TRUNC(X_APPROVAL_DATE) )
           OR ((tlinfo.APPROVAL_DATE is null)
               AND (X_APPROVAL_DATE is null)))
      AND ((tlinfo.LECTURE_CREDIT_POINTS = X_LECTURE_CREDIT_POINTS )
           OR ((tlinfo.LECTURE_CREDIT_POINTS is null)
               AND (X_LECTURE_CREDIT_POINTS is null)))
      AND ((tlinfo.LAB_CREDIT_POINTS = X_LAB_CREDIT_POINTS )
           OR ((tlinfo.LAB_CREDIT_POINTS is null)
               AND (X_LAB_CREDIT_POINTS is null)))
      AND ((tlinfo.OTHER_CREDIT_POINTS = X_OTHER_CREDIT_POINTS )
           OR ((tlinfo.OTHER_CREDIT_POINTS is null)
               AND (X_OTHER_CREDIT_POINTS is null)))
      AND ((tlinfo.CLOCK_HOURS = X_CLOCK_HOURS )
           OR ((tlinfo.CLOCK_HOURS is null)
               AND (X_CLOCK_HOURS is null)))
      AND ((tlinfo.WORK_LOAD_CP_LECTURE = X_WORK_LOAD_CP_LECTURE )
           OR ((tlinfo.WORK_LOAD_CP_LECTURE is null)
               AND (X_WORK_LOAD_CP_LECTURE is null)))
      AND ((tlinfo.WORK_LOAD_CP_LAB = X_WORK_LOAD_CP_LAB )
           OR ((tlinfo.WORK_LOAD_CP_LAB is null)
               AND (X_WORK_LOAD_CP_LAB is null)))
      AND ((tlinfo.CONTINUING_EDUCATION_UNITS = X_CONTINUING_EDUCATION_UNITS )
           OR ((tlinfo.CONTINUING_EDUCATION_UNITS is null)
               AND (X_CONTINUING_EDUCATION_UNITS is null)))
      AND ((tlinfo.ENROLLMENT_EXPECTED = X_ENROLLMENT_EXPECTED )
           OR ((tlinfo.ENROLLMENT_EXPECTED is null)
               AND (X_ENROLLMENT_EXPECTED is null)))
      AND ((tlinfo.ENROLLMENT_MINIMUM = X_ENROLLMENT_MINIMUM )
           OR ((tlinfo.ENROLLMENT_MINIMUM is null)
               AND (X_ENROLLMENT_MINIMUM is null)))
      AND ((tlinfo.ENROLLMENT_MAXIMUM = X_ENROLLMENT_MAXIMUM )
           OR ((tlinfo.ENROLLMENT_MAXIMUM is null)
               AND (X_ENROLLMENT_MAXIMUM is null)))
      AND ((tlinfo.ADVANCE_MAXIMUM = X_ADVANCE_MAXIMUM )
           OR ((tlinfo.ADVANCE_MAXIMUM is null)
               AND (X_ADVANCE_MAXIMUM is null)))
      AND ((tlinfo.STATE_FINANCIAL_AID = X_STATE_FINANCIAL_AID )
           OR ((tlinfo.STATE_FINANCIAL_AID is null)
               AND (X_STATE_FINANCIAL_AID is null)))
      AND ((tlinfo.FEDERAL_FINANCIAL_AID = X_FEDERAL_FINANCIAL_AID )
           OR ((tlinfo.FEDERAL_FINANCIAL_AID is null)
               AND (X_FEDERAL_FINANCIAL_AID is null)))
      AND ((tlinfo.INSTITUTIONAL_FINANCIAL_AID = X_INSTITUTIONAL_FINANCIAL_AID )
           OR ((tlinfo.INSTITUTIONAL_FINANCIAL_AID is null)
               AND (X_INSTITUTIONAL_FINANCIAL_AID is null)))
      AND ((tlinfo.SAME_TEACHING_PERIOD = X_SAME_TEACHING_PERIOD )
           OR ((tlinfo.SAME_TEACHING_PERIOD is null)
               AND (X_SAME_TEACHING_PERIOD is null)))
      AND ((tlinfo.MAX_REPEATS_FOR_CREDIT = X_MAX_REPEATS_FOR_CREDIT )
           OR ((tlinfo.MAX_REPEATS_FOR_CREDIT is null)
               AND (X_MAX_REPEATS_FOR_CREDIT is null)))
      AND ((tlinfo.MAX_REPEATS_FOR_FUNDING = X_MAX_REPEATS_FOR_FUNDING )
           OR ((tlinfo.MAX_REPEATS_FOR_FUNDING is null)
               AND (X_MAX_REPEATS_FOR_FUNDING is null)))
      AND ((tlinfo.MAX_REPEAT_CREDIT_POINTS = X_MAX_REPEAT_CREDIT_POINTS )
           OR ((tlinfo.MAX_REPEAT_CREDIT_POINTS is null)
               AND (X_MAX_REPEAT_CREDIT_POINTS is null)))
      AND ((tlinfo.SAME_TEACH_PERIOD_REPEATS = X_SAME_TEACH_PERIOD_REPEATS )
           OR ((tlinfo.SAME_TEACH_PERIOD_REPEATS is null)
               AND (X_SAME_TEACH_PERIOD_REPEATS is null)))
      AND ((tlinfo.SAME_TEACH_PERIOD_REPEATS_CP = X_SAME_TEACH_PERIOD_REPEATS_CP )
           OR ((tlinfo.SAME_TEACH_PERIOD_REPEATS_CP is null)
               AND (X_SAME_TEACH_PERIOD_REPEATS_CP is null)))
      AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY )
           OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
               AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1 )
           OR ((tlinfo.ATTRIBUTE1 is null)
               AND (X_ATTRIBUTE1 is null)))
      AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2 )
           OR ((tlinfo.ATTRIBUTE2 is null)
               AND (X_ATTRIBUTE2 is null)))
      AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3 )
           OR ((tlinfo.ATTRIBUTE3 is null)
               AND (X_ATTRIBUTE3 is null)))
      AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4 )
           OR ((tlinfo.ATTRIBUTE4 is null)
               AND (X_ATTRIBUTE4 is null)))
      AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5 )
           OR ((tlinfo.ATTRIBUTE5 is null)
               AND (X_ATTRIBUTE5 is null)))
      AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6 )
           OR ((tlinfo.ATTRIBUTE6 is null)
               AND (X_ATTRIBUTE6 is null)))
      AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7 )
           OR ((tlinfo.ATTRIBUTE7 is null)
               AND (X_ATTRIBUTE7 is null)))
      AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8 )
           OR ((tlinfo.ATTRIBUTE8 is null)
               AND (X_ATTRIBUTE8 is null)))
      AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9 )
           OR ((tlinfo.ATTRIBUTE9 is null)
               AND (X_ATTRIBUTE9 is null)))
      AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10 )
           OR ((tlinfo.ATTRIBUTE10 is null)
               AND (X_ATTRIBUTE10 is null)))
      AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11 )
           OR ((tlinfo.ATTRIBUTE11 is null)
               AND (X_ATTRIBUTE11 is null)))
      AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12 )
           OR ((tlinfo.ATTRIBUTE12 is null)
               AND (X_ATTRIBUTE12 is null)))
      AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13 )
           OR ((tlinfo.ATTRIBUTE13 is null)
               AND (X_ATTRIBUTE13 is null)))
      AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14 )
           OR ((tlinfo.ATTRIBUTE14 is null)
               AND (X_ATTRIBUTE14 is null)))
      AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15 )
           OR ((tlinfo.ATTRIBUTE15 is null)
               AND (X_ATTRIBUTE15 is null)))
      AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16 )
           OR ((tlinfo.ATTRIBUTE16 is null)
               AND (X_ATTRIBUTE16 is null)))
      AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17 )
           OR ((tlinfo.ATTRIBUTE17 is null)
               AND (X_ATTRIBUTE17 is null)))
      AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18 )
           OR ((tlinfo.ATTRIBUTE18 is null)
               AND (X_ATTRIBUTE18 is null)))
      AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19 )
           OR ((tlinfo.ATTRIBUTE19 is null)
               AND (X_ATTRIBUTE19 is null)))
      AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20 )
           OR ((tlinfo.ATTRIBUTE20 is null)
               AND (X_ATTRIBUTE20 is null)))
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
           OR ((tlinfo.ss_display_ind IS NULL)
               AND (X_ss_display_ind IS NULL)))
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
      AND ((tlinfo.unit_type_id = x_unit_type_id)
           OR ((tlinfo.unit_type_id IS NULL)
               AND (X_unit_type_id IS NULL)))
      AND ((tlinfo.special_permission_ind = x_special_permission_ind)
           OR ((tlinfo.special_permission_ind IS NULL)
               AND (X_special_permission_ind IS NULL)))
      AND ((tlinfo.SS_ENROL_IND = X_SS_ENROL_IND)
           OR ((tlinfo.SS_ENROL_IND is null)
               AND (X_SS_ENROL_IND is null)))
      AND  ((tlinfo.IVR_ENROL_IND = X_IVR_ENROL_IND)
           OR ((tlinfo.IVR_ENROL_IND is null)
               AND (X_IVR_ENROL_IND is null)))
      AND  ((tlinfo.REV_ACCOUNT_CD = X_REV_ACCOUNT_CD)
           OR ((tlinfo.REV_ACCOUNT_CD is null)
               AND (X_REV_ACCOUNT_CD is null)))
      AND  ((tlinfo.CLAIMABLE_HOURS= X_CLAIMABLE_HOURS)
           OR ((tlinfo.CLAIMABLE_HOURS is null)
               AND (X_CLAIMABLE_HOURS is null)))
      AND  ((tlinfo.ANON_UNIT_GRADING_IND= X_ANON_UNIT_GRADING_IND)
           OR ((tlinfo.ANON_UNIT_GRADING_IND is null)
               AND (X_ANON_UNIT_GRADING_IND is null)))
      AND  ((tlinfo.ANON_ASSESS_GRADING_IND= X_ANON_ASSESS_GRADING_IND)
           OR ((tlinfo.ANON_ASSESS_GRADING_IND is null)
               AND (X_ANON_ASSESS_GRADING_IND is null)))
      AND  ((tlinfo.AUDITABLE_IND= X_AUDITABLE_IND)
           OR ((tlinfo.AUDITABLE_IND is null)
               AND (X_AUDITABLE_IND is null)))
      AND  ((tlinfo.AUDIT_PERMISSION_IND= X_AUDIT_PERMISSION_IND)
           OR ((tlinfo.AUDIT_PERMISSION_IND is null)
               AND (X_AUDIT_PERMISSION_IND is null)))
      AND  ((tlinfo.MAX_AUDITORS_ALLOWED= X_MAX_AUDITORS_ALLOWED)
           OR ((tlinfo.MAX_AUDITORS_ALLOWED is null)
               AND (X_MAX_AUDITORS_ALLOWED is null)))
      AND  ((tlinfo.BILLING_CREDIT_POINTS= X_BILLING_CREDIT_POINTS)
           OR ((tlinfo.BILLING_CREDIT_POINTS IS NULL)
               AND (X_BILLING_CREDIT_POINTS IS NULL)))
      AND  ((tlinfo.OVRD_WKLD_VAL_FLAG= X_OVRD_WKLD_VAL_FLAG)
           OR ((tlinfo.OVRD_WKLD_VAL_FLAG IS NULL)
               AND (X_OVRD_WKLD_VAL_FLAG IS NULL)))
      AND  ((tlinfo.WORKLOAD_VAL_CODE= X_WORKLOAD_VAL_CODE)
           OR ((tlinfo.WORKLOAD_VAL_CODE IS NULL)
               AND (X_WORKLOAD_VAL_CODE IS NULL)))
      AND  ((tlinfo.BILLING_HRS= X_BILLING_HRS)
           OR ((tlinfo.BILLING_HRS IS NULL)
               AND (X_BILLING_HRS IS NULL)))
  ) then
      null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
END lock_row;
-----------------------------------------------------------------------------
PROCEDURE update_row (
  X_ROWID in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
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
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
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
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  x_subtitle_id    IN NUMBER ,
  x_work_load_other                   IN     NUMBER ,
    x_contact_hrs_lecture               IN     NUMBER ,
    x_contact_hrs_lab                   IN     NUMBER ,
    x_contact_hrs_other                 IN     NUMBER ,
    x_non_schd_required_hrs             IN     NUMBER ,
    x_exclude_from_max_cp_limit         IN     VARCHAR2 ,
    x_record_exclusion_flag             IN     VARCHAR2 ,
    x_ss_display_ind       IN     VARCHAR2 ,
    x_cal_type_enrol_load_cal           IN     VARCHAR2 ,
    x_sequence_num_enrol_load_cal    IN     NUMBER ,
    x_cal_type_offer_load_cal           IN     VARCHAR2 ,
    x_sequence_num_offer_load_cal    IN     NUMBER ,
    x_curriculum_id                     IN     VARCHAR2 ,
    x_override_enrollment_max           IN     NUMBER ,
    x_rpt_fmly_id                       IN     NUMBER ,
    x_unit_type_id                      IN     NUMBER ,
    x_special_permission_ind            IN     VARCHAR2 ,
  X_MODE in VARCHAR2,
  X_SS_ENROL_IND in VARCHAR2 ,
  X_IVR_ENROL_IND in VARCHAR2 ,
  x_rev_account_cd IN VARCHAR2 ,
  x_claimable_hours IN NUMBER ,
  x_anon_unit_grading_ind IN VARCHAR2 ,
  x_anon_assess_grading_ind IN VARCHAR2 ,
  x_auditable_ind IN VARCHAR2,
  x_audit_permission_ind IN VARCHAR2,
  x_max_auditors_allowed IN NUMBER,
  x_billing_credit_points IN NUMBER,
  x_ovrd_wkld_val_flag    IN VARCHAR2 ,
  x_workload_val_code     IN VARCHAR2 ,
  x_billing_hrs           IN NUMBER
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
  x_rowid =>  X_ROWID,
  x_unit_cd => X_UNIT_CD,
  x_version_number => X_VERSION_NUMBER,
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
  x_credit_point_descriptor => X_CREDIT_POINT_DESCRIPTOR,
  x_enrolled_credit_points => X_ENROLLED_CREDIT_POINTS,
  x_points_override_ind => X_POINTS_OVERRIDE_IND,
  x_supp_exam_permitted_ind => X_SUPP_EXAM_PERMITTED_IND,
  x_coord_person_id => X_COORD_PERSON_ID,
  x_owner_org_unit_cd => X_OWNER_ORG_UNIT_CD,
  x_owner_ou_start_dt => X_OWNER_OU_START_DT,
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
  x_subtitle_modifiable_flag => X_SUBTITLE_MODIFIABLE_FLAG,
  x_approval_date => X_APPROVAL_DATE,
  x_lecture_credit_points => X_LECTURE_CREDIT_POINTS,
  x_lab_credit_points => X_LAB_CREDIT_POINTS,
  x_other_credit_points => X_OTHER_CREDIT_POINTS,
  x_clock_hours => X_CLOCK_HOURS,
  x_work_load_cp_lecture => X_WORK_LOAD_CP_LECTURE,
  x_work_load_cp_lab => X_WORK_LOAD_CP_LAB,
  x_continuing_education_units => X_CONTINUING_EDUCATION_UNITS,
  x_enrollment_expected => X_ENROLLMENT_EXPECTED,
  x_enrollment_minimum => X_ENROLLMENT_MINIMUM,
  x_enrollment_maximum => X_ENROLLMENT_MAXIMUM,
  x_advance_maximum => X_ADVANCE_MAXIMUM,
  x_state_financial_aid => X_STATE_FINANCIAL_AID,
  x_federal_financial_aid => X_FEDERAL_FINANCIAL_AID,
  x_institutional_financial_aid => X_INSTITUTIONAL_FINANCIAL_AID,
  x_same_teaching_period => X_SAME_TEACHING_PERIOD,
  x_max_repeats_for_credit => X_MAX_REPEATS_FOR_CREDIT,
  x_max_repeats_for_funding => X_MAX_REPEATS_FOR_FUNDING,
  x_max_repeat_credit_points => X_MAX_REPEAT_CREDIT_POINTS,
  x_same_teach_period_repeats => X_SAME_TEACH_PERIOD_REPEATS,
  x_same_teach_period_repeats_cp => X_SAME_TEACH_PERIOD_REPEATS_CP,
  x_attribute_category => X_ATTRIBUTE_CATEGORY,
  x_attribute1 => X_ATTRIBUTE1,
  x_attribute2 => X_ATTRIBUTE2,
  x_attribute3 => X_ATTRIBUTE3,
  x_attribute4 => X_ATTRIBUTE4,
  x_attribute5 => X_ATTRIBUTE5,
  x_attribute6 => X_ATTRIBUTE6,
  x_attribute7 => X_ATTRIBUTE7,
  x_attribute8 => X_ATTRIBUTE8,
  x_attribute9 => X_ATTRIBUTE9,
  x_attribute10 => X_ATTRIBUTE10,
  x_attribute11 => X_ATTRIBUTE11,
  x_attribute12 => X_ATTRIBUTE12,
  x_attribute13 => X_ATTRIBUTE13,
  x_attribute14 => X_ATTRIBUTE14,
  x_attribute15 => X_ATTRIBUTE15,
  x_attribute16 => X_ATTRIBUTE16,
  x_attribute17 => X_ATTRIBUTE17,
  x_attribute18 => X_ATTRIBUTE18,
  x_attribute19 => X_ATTRIBUTE19,
  x_attribute20 => X_ATTRIBUTE20,
  x_subtitle_id                       => x_subtitle_id,
  x_work_load_other => x_work_load_other,
   x_contact_hrs_lecture => x_contact_hrs_lecture,
    x_contact_hrs_lab => x_contact_hrs_lab,
    x_contact_hrs_other => x_contact_hrs_other,
    x_non_schd_required_hrs => x_non_schd_required_hrs,
    x_exclude_from_max_cp_limit => x_exclude_from_max_cp_limit,
    x_record_exclusion_flag => x_record_exclusion_flag,
    x_ss_display_ind => x_ss_display_ind,
    x_cal_type_enrol_load_cal => x_cal_type_enrol_load_cal,
    x_sequence_num_enrol_load_cal => x_sequence_num_enrol_load_cal,
    x_cal_type_offer_load_cal => x_cal_type_offer_load_cal,
    x_sequence_num_offer_load_cal => x_sequence_num_offer_load_cal,
    x_curriculum_id => x_curriculum_id,
    x_override_enrollment_max => x_override_enrollment_max,
    x_rpt_fmly_id => x_rpt_fmly_id,
    x_unit_type_id => x_unit_type_id,
    x_special_permission_ind => x_special_permission_ind,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_ss_enrol_ind => X_SS_ENROL_IND,
  x_ivr_enrol_ind => X_IVR_ENROL_IND,
  x_rev_account_cd => x_rev_account_cd,
  x_claimable_hours => x_claimable_hours,
  x_anon_unit_grading_ind => x_anon_unit_grading_ind ,
  x_anon_assess_grading_ind => x_anon_assess_grading_ind,
  x_auditable_ind => x_auditable_ind,
  x_audit_permission_ind => x_audit_permission_ind,
  x_max_auditors_allowed => x_max_auditors_allowed,
  x_billing_credit_points => x_billing_credit_points,
  x_ovrd_wkld_val_flag    => x_ovrd_wkld_val_flag ,
  x_workload_val_code     => x_workload_val_code,
  x_billing_hrs           => x_billing_hrs
  );

  update IGS_PS_UNIT_VER_ALL set
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
    CREDIT_POINT_DESCRIPTOR = NEW_REFERENCES.CREDIT_POINT_DESCRIPTOR,
    ENROLLED_CREDIT_POINTS = NEW_REFERENCES.ENROLLED_CREDIT_POINTS,
    POINTS_OVERRIDE_IND = NEW_REFERENCES.POINTS_OVERRIDE_IND,
    SUPP_EXAM_PERMITTED_IND = NEW_REFERENCES.SUPP_EXAM_PERMITTED_IND,
    COORD_PERSON_ID = NEW_REFERENCES.COORD_PERSON_ID,
    OWNER_ORG_UNIT_CD = NEW_REFERENCES.OWNER_ORG_UNIT_CD,
    OWNER_OU_START_DT = NEW_REFERENCES.OWNER_OU_START_DT,
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
    SUBTITLE_MODIFIABLE_FLAG = NEW_REFERENCES.SUBTITLE_MODIFIABLE_FLAG,
    APPROVAL_DATE = NEW_REFERENCES.APPROVAL_DATE,
    LECTURE_CREDIT_POINTS = NEW_REFERENCES.LECTURE_CREDIT_POINTS,
    LAB_CREDIT_POINTS = NEW_REFERENCES.LAB_CREDIT_POINTS,
    OTHER_CREDIT_POINTS = NEW_REFERENCES.OTHER_CREDIT_POINTS,
    CLOCK_HOURS = NEW_REFERENCES.CLOCK_HOURS,
    WORK_LOAD_CP_LECTURE = NEW_REFERENCES.WORK_LOAD_CP_LECTURE,
    WORK_LOAD_CP_LAB = NEW_REFERENCES.WORK_LOAD_CP_LAB,
    CONTINUING_EDUCATION_UNITS = NEW_REFERENCES.CONTINUING_EDUCATION_UNITS,
    ENROLLMENT_EXPECTED = NEW_REFERENCES.ENROLLMENT_EXPECTED,
    ENROLLMENT_MINIMUM = NEW_REFERENCES.ENROLLMENT_MINIMUM,
    ENROLLMENT_MAXIMUM = NEW_REFERENCES.ENROLLMENT_MAXIMUM,
    ADVANCE_MAXIMUM = NEW_REFERENCES.ADVANCE_MAXIMUM,
    STATE_FINANCIAL_AID = NEW_REFERENCES.STATE_FINANCIAL_AID,
    FEDERAL_FINANCIAL_AID = NEW_REFERENCES.FEDERAL_FINANCIAL_AID,
    INSTITUTIONAL_FINANCIAL_AID = NEW_REFERENCES.INSTITUTIONAL_FINANCIAL_AID,
    SAME_TEACHING_PERIOD = NEW_REFERENCES.SAME_TEACHING_PERIOD,
    MAX_REPEATS_FOR_CREDIT = NEW_REFERENCES.MAX_REPEATS_FOR_CREDIT,
    MAX_REPEATS_FOR_FUNDING = NEW_REFERENCES.MAX_REPEATS_FOR_FUNDING,
    MAX_REPEAT_CREDIT_POINTS = NEW_REFERENCES.MAX_REPEAT_CREDIT_POINTS,
    SAME_TEACH_PERIOD_REPEATS = NEW_REFERENCES.SAME_TEACH_PERIOD_REPEATS,
    SAME_TEACH_PERIOD_REPEATS_CP = NEW_REFERENCES.SAME_TEACH_PERIOD_REPEATS_CP,
    ATTRIBUTE_CATEGORY = NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 = NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 = NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 = NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 = NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 = NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 = NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 = NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 = NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 = NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 = NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 = NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 = NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 = NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 = NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 = NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 = NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 = NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 = NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 = NEW_REFERENCES.ATTRIBUTE20,
    subtitle_id                       = new_references.subtitle_id,
    work_load_other = new_references.work_load_other ,
    contact_hrs_lecture = new_references.contact_hrs_lecture,
    contact_hrs_lab = new_references.contact_hrs_lab,
    contact_hrs_other = new_references.contact_hrs_other,
    non_schd_required_hrs = new_references.non_schd_required_hrs,
    exclude_from_max_cp_limit = new_references.exclude_from_max_cp_limit,
    record_exclusion_flag = new_references.record_exclusion_flag,
    ss_display_ind = new_references.ss_display_ind,
    cal_type_enrol_load_cal = new_references.cal_type_enrol_load_cal,
    sequence_num_enrol_load_cal = new_references.sequence_num_enrol_load_cal,
    cal_type_offer_load_cal = new_references.cal_type_offer_load_cal,
    sequence_num_offer_load_cal = new_references.sequence_num_offer_load_cal,
    curriculum_id = new_references.curriculum_id,
    override_enrollment_max = new_references.override_enrollment_max,
    rpt_fmly_id = new_references.rpt_fmly_id,
    unit_type_id = new_references.unit_type_id,
    special_permission_ind = new_references.special_permission_ind,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SS_ENROL_IND = NEW_REFERENCES.SS_ENROL_IND,
    IVR_ENROL_IND = NEW_REFERENCES.IVR_ENROL_IND,
    rev_account_cd = new_references.rev_account_cd,
    claimable_hours = new_references.claimable_hours,
    anon_unit_grading_ind = new_references.anon_unit_grading_ind,
    anon_assess_grading_ind = new_references.anon_assess_grading_ind,
    auditable_ind = new_references.auditable_ind,
    audit_permission_ind = new_references.audit_permission_ind,
    max_auditors_allowed = new_references.max_auditors_allowed,
    billing_credit_points = new_references.billing_credit_points,
    ovrd_wkld_val_flag    = new_references.ovrd_wkld_val_flag ,
    workload_val_code     = new_references.workload_val_code,
    billing_hrs           = new_references.billing_hrs
  WHERE ROWID = X_ROWID;
  IF (sql%notfound) THEN
    RAISE no_data_found;
  END IF;
  After_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID
    );

END update_row;
------------------------------------------------------------------------------
PROCEDURE add_row (
  X_ROWID in out NOCOPY VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
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
  X_CREDIT_POINT_DESCRIPTOR in VARCHAR2,
  X_ENROLLED_CREDIT_POINTS in NUMBER,
  X_POINTS_OVERRIDE_IND in VARCHAR2,
  X_SUPP_EXAM_PERMITTED_IND in VARCHAR2,
  X_COORD_PERSON_ID in NUMBER,
  X_OWNER_ORG_UNIT_CD in VARCHAR2,
  X_OWNER_OU_START_DT in DATE,
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
  X_SUBTITLE in VARCHAR2,
  X_SUBTITLE_MODIFIABLE_FLAG in VARCHAR2,
  X_APPROVAL_DATE in DATE,
  X_LECTURE_CREDIT_POINTS in NUMBER,
  X_LAB_CREDIT_POINTS in NUMBER,
  X_OTHER_CREDIT_POINTS in NUMBER,
  X_CLOCK_HOURS in NUMBER,
  X_WORK_LOAD_CP_LECTURE in NUMBER,
  X_WORK_LOAD_CP_LAB in NUMBER,
  X_CONTINUING_EDUCATION_UNITS in NUMBER,
  X_ENROLLMENT_EXPECTED in NUMBER,
  X_ENROLLMENT_MINIMUM in NUMBER,
  X_ENROLLMENT_MAXIMUM in NUMBER,
  X_ADVANCE_MAXIMUM in NUMBER,
  X_STATE_FINANCIAL_AID in VARCHAR2,
  X_FEDERAL_FINANCIAL_AID in VARCHAR2,
  X_INSTITUTIONAL_FINANCIAL_AID in VARCHAR2,
  X_SAME_TEACHING_PERIOD in VARCHAR2,
  X_MAX_REPEATS_FOR_CREDIT in NUMBER,
  X_MAX_REPEATS_FOR_FUNDING in NUMBER,
  X_MAX_REPEAT_CREDIT_POINTS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS in NUMBER,
  X_SAME_TEACH_PERIOD_REPEATS_CP in NUMBER,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_SUBTITLE_ID IN NUMBER ,
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
  x_unit_type_id                      IN     NUMBER ,
  x_special_permission_ind            IN     VARCHAR2 ,
  X_MODE in VARCHAR2 ,
  X_ORG_ID IN NUMBER,
  X_SS_ENROL_IND in VARCHAR2 ,
  X_IVR_ENROL_IND in VARCHAR2 ,
  x_claimable_hours IN NUMBER ,
  x_rev_account_cd IN VARCHAR2 ,
  x_anon_unit_grading_ind IN VARCHAR2 ,
  x_anon_assess_grading_ind IN VARCHAR2 ,
  x_auditable_ind IN VARCHAR2,
  x_audit_permission_ind IN VARCHAR2,
  x_max_auditors_allowed IN NUMBER,
  x_billing_credit_points IN NUMBER,
  x_ovrd_wkld_val_flag    IN VARCHAR2 ,
  x_workload_val_code     IN VARCHAR2 ,
  x_billing_hrs           IN NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_VER_ALL
     where UNIT_CD = X_UNIT_CD
     and VERSION_NUMBER = X_VERSION_NUMBER;
BEGIN
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW(
     X_ROWID,
     X_UNIT_CD,
     X_VERSION_NUMBER,
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
     X_CREDIT_POINT_DESCRIPTOR,
     X_ENROLLED_CREDIT_POINTS,
     X_POINTS_OVERRIDE_IND,
     X_SUPP_EXAM_PERMITTED_IND,
     X_COORD_PERSON_ID,
     X_OWNER_ORG_UNIT_CD,
     X_OWNER_OU_START_DT,
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
    X_SUBTITLE,
    X_SUBTITLE_MODIFIABLE_FLAG,
    X_APPROVAL_DATE,
    X_LECTURE_CREDIT_POINTS,
    X_LAB_CREDIT_POINTS,
    X_OTHER_CREDIT_POINTS,
    X_CLOCK_HOURS,
    X_WORK_LOAD_CP_LECTURE,
    X_WORK_LOAD_CP_LAB,
    X_CONTINUING_EDUCATION_UNITS,
    X_ENROLLMENT_EXPECTED,
    X_ENROLLMENT_MINIMUM,
    X_ENROLLMENT_MAXIMUM,
    X_ADVANCE_MAXIMUM,
    X_STATE_FINANCIAL_AID,
    X_FEDERAL_FINANCIAL_AID,
    X_INSTITUTIONAL_FINANCIAL_AID,
    X_SAME_TEACHING_PERIOD,
    X_MAX_REPEATS_FOR_CREDIT,
    X_MAX_REPEATS_FOR_FUNDING,
    X_MAX_REPEAT_CREDIT_POINTS,
    X_SAME_TEACH_PERIOD_REPEATS,
    X_SAME_TEACH_PERIOD_REPEATS_CP,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_SUBTITLE_ID,
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
    x_unit_type_id,
    x_special_permission_ind,
    X_MODE,
    X_ORG_ID,
    X_SS_ENROL_IND,
    X_IVR_ENROL_IND,
    x_rev_account_cd,
    x_claimable_hours,
    x_anon_unit_grading_ind,
    x_anon_assess_grading_ind,
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
   X_CREDIT_POINT_DESCRIPTOR,
   X_ENROLLED_CREDIT_POINTS,
   X_POINTS_OVERRIDE_IND,
   X_SUPP_EXAM_PERMITTED_IND,
   X_COORD_PERSON_ID,
   X_OWNER_ORG_UNIT_CD,
   X_OWNER_OU_START_DT,
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
    X_SUBTITLE,
    X_SUBTITLE_MODIFIABLE_FLAG,
    X_APPROVAL_DATE,
    X_LECTURE_CREDIT_POINTS,
    X_LAB_CREDIT_POINTS,
    X_OTHER_CREDIT_POINTS,
    X_CLOCK_HOURS,
    X_WORK_LOAD_CP_LECTURE,
    X_WORK_LOAD_CP_LAB,
    X_CONTINUING_EDUCATION_UNITS,
    X_ENROLLMENT_EXPECTED,
    X_ENROLLMENT_MINIMUM,
    X_ENROLLMENT_MAXIMUM,
    X_ADVANCE_MAXIMUM,
    X_STATE_FINANCIAL_AID,
    X_FEDERAL_FINANCIAL_AID,
    X_INSTITUTIONAL_FINANCIAL_AID,
    X_SAME_TEACHING_PERIOD,
    X_MAX_REPEATS_FOR_CREDIT,
    X_MAX_REPEATS_FOR_FUNDING,
    X_MAX_REPEAT_CREDIT_POINTS,
    X_SAME_TEACH_PERIOD_REPEATS,
    X_SAME_TEACH_PERIOD_REPEATS_CP,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_SUBTITLE_ID,
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
    x_unit_type_id,
    x_special_permission_ind,
   X_MODE,
   X_SS_ENROL_IND,
   X_IVR_ENROL_IND,
   x_rev_account_cd,
   x_claimable_hours,
   x_anon_unit_grading_ind,
   x_anon_assess_grading_ind,
   x_auditable_ind,
   x_audit_permission_ind,
   x_max_auditors_allowed,
   x_billing_credit_points,
   x_ovrd_wkld_val_flag,
   x_workload_val_code,
  x_billing_hrs
);
END add_row;

PROCEDURE delete_row (
  X_ROWID in VARCHAR2
) AS
BEGIN
  Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

  delete from IGS_PS_UNIT_VER_ALL
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

END delete_row;

PROCEDURE update_row_subtitle_id(X_RowId   IN  VARCHAR2,X_Subtitle_Id  IN  NUMBER) AS
BEGIN

  UPDATE IGS_PS_UNIT_VER_ALL set
  subtitle_id = X_Subtitle_Id
  WHERE ROWID = X_ROWID;

END update_row_subtitle_id;

END igs_ps_unit_ver_pkg;

/
