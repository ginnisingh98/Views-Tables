--------------------------------------------------------
--  DDL for Package Body IGS_PS_VER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VER_PKG" AS
 /* $Header: IGSPI42B.pls 120.2 2005/08/11 03:35:57 appldev ship $ */
/************************************************************************
Created By                                :
Date Created By                           :
Purpose                                   :
Known limitations, enhancements or remarks:
Change History                            :
Who          When          What
msrinivi    08-Aug-2001  Added new col rev_Account_cd bug # 1882122
ayedubat    25-MAY-2001  Changed for the DLD,PSPS001-US
smadathi    16-MAY-2001  Changed For New DLD Version
sbeerell    10-MAY-2000  Changed for new DLD version 2
(reverse chronological order - newest change first)
*************************************************************************/
  l_rowid VARCHAR2(25);
  old_references igs_ps_ver_all%ROWTYPE;
  new_references igs_ps_ver_all%ROWTYPE;


PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : sarakshi, Oracle India
  --Date created: 16-Jun-2002
  --
  --Purpose: Only planned course status are allowed for deletion
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  CURSOR cur_delete (cp_course_cd igs_ps_ver_all.course_cd%TYPE,
                     cp_version_number igs_ps_ver_all.version_number%TYPE)
  IS
  SELECT 'x'
  FROM   igs_ps_ver_all uv,
         igs_ps_stat us
  WHERE  uv.course_status=us.course_status
  AND    us.s_course_status='PLANNED'
  AND    uv.course_cd = cp_course_cd
  AND    uv.version_number = cp_version_number;

  l_check VARCHAR2(1);

BEGIN
  -- Only planned course status are allowed for deletion
  OPEN  cur_delete (old_references.course_cd,old_references.version_number);
  FETCH cur_delete INTO l_check;
  IF cur_delete%NOTFOUND THEN
    CLOSE cur_delete;
    fnd_message.set_name('IGS','IGS_PS_NO_DEL_ALLOWED');
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
  --Purpose: Active/Inactive program Status can not be changed to Planned Status
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
        CURSOR cur_get_status (cp_course_status igs_ps_stat.course_status%TYPE)
        IS
        SELECT s_course_status
        FROM   igs_ps_stat
        WHERE  course_status = cp_course_status;
        l_s_course_status igs_ps_stat.s_course_status%TYPE;

        CURSOR cur_check_update (cp_course_cd igs_ps_ver_all.course_cd%TYPE,
                                 cp_version_number igs_ps_ver_all.version_number%TYPE)
        IS
        SELECT 'x'
        FROM     igs_ps_ver_all uv,
                 igs_ps_stat us
        WHERE    uv.course_status=us.course_status
        AND      us.s_course_status <> 'PLANNED'
        AND      uv.course_cd = cp_course_cd
        AND      uv.version_number = cp_version_number;

        l_check VARCHAR2(1);
BEGIN
  -- Active/Inactive program Status can not be changed to Planned Status
  OPEN cur_get_status(new_references.course_status);
  FETCH cur_get_status INTO l_s_course_status;
  IF cur_get_status%FOUND THEN
    CLOSE cur_get_status;
    IF (l_s_course_status = 'PLANNED') THEN
      OPEN cur_check_update(old_references.course_cd,old_references.version_number);
      FETCH cur_check_update INTO l_check;
      IF cur_check_update%FOUND THEN
        CLOSE cur_check_update;
        fnd_message.set_name('IGS','IGS_PS_NO_INACTIVE_PLN');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      CLOSE cur_check_update;
    END IF;
  ELSE
    -- If the program status is not found then the record might have been deleted
    CLOSE cur_get_status;
    fnd_message.set_name('FND','FORM_RECORD_DELETED');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END IF;
END beforerowupdate;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_start_dt IN DATE ,
    x_review_dt IN DATE ,
    x_expiry_dt IN DATE ,
    x_end_dt IN DATE ,
    x_course_status IN VARCHAR2 ,
    x_title IN VARCHAR2 ,
    x_short_title IN VARCHAR2 ,
    x_abbreviation IN VARCHAR2 ,
    x_supp_exam_permitted_ind IN VARCHAR2 ,
    x_generic_course_ind IN VARCHAR2 ,
    x_graduate_students_ind IN VARCHAR2 ,
    x_count_intrmsn_in_time_ind IN VARCHAR2 ,
    x_intrmsn_allowed_ind IN VARCHAR2 ,
    x_course_type IN VARCHAR2 ,
    x_responsible_org_unit_cd IN VARCHAR2 ,
    x_responsible_ou_start_dt IN DATE ,
    x_govt_special_course_type IN VARCHAR2 ,
    x_qualification_recency IN NUMBER ,
    x_external_adv_stnd_limit IN NUMBER ,
    x_internal_adv_stnd_limit IN NUMBER ,
    x_contact_hours IN NUMBER ,
    x_credit_points_required IN NUMBER ,
    x_govt_course_load IN NUMBER ,
    x_std_annual_load IN NUMBER ,
    x_course_total_eftsu IN NUMBER ,
    x_max_intrmsn_duration IN NUMBER ,
    x_num_of_units_before_intrmsn IN NUMBER ,
    x_min_sbmsn_percentage IN NUMBER ,
    x_max_cp_per_teaching_period IN NUMBER ,
    x_approval_date IN DATE ,
    x_external_approval_date IN DATE ,
    x_residency_cp_required IN NUMBER ,
    x_state_financial_aid IN VARCHAR2 ,
    x_federal_financial_aid IN VARCHAR2 ,
    x_institutional_financial_aid IN VARCHAR2 ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2 ,
    x_min_cp_per_calendar IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_rev_account_cd IN VARCHAR2 ,
    x_primary_program_rank IN NUMBER,
    x_max_wlst_per_stud IN NUMBER,
    x_annual_instruction_time IN NUMBER
  )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur    18-Oct-2002  Enh#2608227.Removed references to obsoleted columns std_ft_completion_time,
                           std_pt_completion_time.Also removed DEFAULT keyword to avoid gscc File.Pkg.22 warning.
  msrinivi    08-Aug-2001  Added new col rev_Account_cd bug # 1882122
  smadathi    26-MAY-2001  Changed for new DLD Version
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/

  CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_ver_all
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.min_sbmsn_percentage := x_min_sbmsn_percentage;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
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
    new_references.responsible_org_unit_cd := x_responsible_org_unit_cd;
    new_references.responsible_ou_start_dt := x_responsible_ou_start_dt;
    new_references.govt_special_course_type := x_govt_special_course_type;
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
    new_references.max_cp_per_teaching_period := x_max_cp_per_teaching_period;
    new_references.approval_date := x_approval_date;
    new_references.external_approval_date := x_external_approval_date;
    new_references.residency_cp_required := x_residency_cp_required;
    new_references.state_financial_aid := x_state_financial_aid;
    new_references.federal_financial_aid := x_federal_financial_aid;
    new_references.institutional_financial_aid := x_institutional_financial_aid;
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
    new_references.min_cp_per_calendar := x_min_cp_per_calendar;
    new_references.org_id := x_org_id;
    new_references.rev_account_cd  := x_rev_account_cd;
    new_references.primary_program_rank := x_primary_program_rank;
    new_references.max_wlst_per_stud := x_max_wlst_per_stud;
    new_references.annual_instruction_time := x_annual_instruction_time;

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

 PROCEDURE rowvalmutation(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    )  AS
   /************************************************************************
   Created By                                :
   Date Created By                           :
   Purpose                                   :
   Known limitations, enhancements or remarks:
   Change History                            :
   Who          When          What
   sbeerell    10-MAY-2000  Changed for new DLD version 2
   (reverse chronological order - newest change first)
   *************************************************************************/
   v_message_name VARCHAR2(30);
   cst_active  VARCHAR2 (6) := 'ACTIVE';
   cst_inactive  VARCHAR2 (8) := 'INACTIVE';
   v_s_course_status  igs_ps_stat.s_course_status%TYPE;
   CURSOR  c_get_s_course_status
     (cp_course_status igs_ps_stat.course_status%TYPE) IS
     SELECT s_course_status
     FROM igs_ps_stat
     WHERE course_status = cp_course_status;

  BEGIN
    -- Validate mutating rows.
    -- Validate IGS_PS_COURSE status and expiry date.
    IF p_inserting OR
     (p_updating AND
      ((NVL(old_references.expiry_dt,
       igs_ge_date.igsdate('1900/01/01')) <>
      NVL(new_references.expiry_dt, igs_ge_date.igsdate('1900/01/01'))) OR
      (old_references.course_status <> new_references.course_status))) THEN
     IF igs_ps_val_crv.crsp_val_crv_exp_sts (
       new_references.course_cd,
              new_references.version_number,
       new_references.expiry_dt,
              new_references.course_status,
       v_message_name) = FALSE THEN
     fnd_message.set_name('IGS',v_message_name);
     igs_ge_msg_stack.add;
     app_exception.raise_exception;
     END IF;
    END IF;
    IF p_inserting OR
        (p_updating AND
         (old_references.course_status <> new_references.course_status)) THEN
      OPEN c_get_s_course_status (new_references.course_status);
      FETCH c_get_s_course_status INTO v_s_course_status;
      CLOSE c_get_s_course_status;
      -- Perform a quality check if updating to a system status of ACTIVE.
      -- IGS_GE_NOTE: A IGS_PS_COURSE version can only be created with a status of PLANNED.
      --        Hence, only need to perform the check if updating.
      IF p_updating AND
         (v_s_course_status = cst_active) THEN
        IF igs_ps_val_crv.crsp_val_crv_quality(
          new_references.course_cd,
          new_references.version_number,
          old_references.course_status,
          v_message_name) = FALSE THEN
          fnd_message.set_name('IGS',v_message_name);
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
      END IF;
    END IF;

  END rowvalmutation;

  PROCEDURE beforerowinsertupdatedelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur   18-Oct-2002   Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                           as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.pkg.22 warning.
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  ayedubat    25-MAY-2001  Changed for the DLD,PSP001-US.
  (reverse chronological order - newest change first)
  *************************************************************************/
  v_message_name VARCHAR2(30);
  v_return_type VARCHAR2(1);
  v_start_dt   igs_ps_ver_all.start_dt%TYPE;
  v_review_dt   igs_ps_ver_all.review_dt%TYPE;
  v_expiry_dt   igs_ps_ver_all.expiry_dt%TYPE;
  v_end_dt   igs_ps_ver_all.end_dt%TYPE;
  v_course_status   igs_ps_ver_all.course_status%TYPE;
  v_title    igs_ps_ver_all.title%TYPE;
  v_short_title   igs_ps_ver_all.short_title%TYPE;
  v_abbreviation   igs_ps_ver_all.abbreviation%TYPE;
  v_supp_exam_permitted_ind igs_ps_ver_all.supp_exam_permitted_ind%TYPE;
  v_generic_course_ind  igs_ps_ver_all.generic_course_ind%TYPE;
  v_graduate_students_ind  igs_ps_ver_all.graduate_students_ind%TYPE;
  v_count_intrmsn_in_time_ind igs_ps_ver_all.count_intrmsn_in_time_ind%TYPE;
  v_intrmsn_allowed_ind  igs_ps_ver_all.intrmsn_allowed_ind%TYPE;
  v_course_type   igs_ps_ver_all.course_type%TYPE;
  v_responsible_org_unit_cd igs_ps_ver_all.responsible_org_unit_cd%TYPE;
  v_responsible_ou_start_dt igs_ps_ver_all.responsible_ou_start_dt%TYPE;
  v_govt_special_course_type igs_ps_ver_all.govt_special_course_type%TYPE;
  v_qualification_recency  igs_ps_ver_all.qualification_recency%TYPE;
  v_external_adv_stnd_limit igs_ps_ver_all.external_adv_stnd_limit%TYPE;
  v_internal_adv_stnd_limit igs_ps_ver_all.internal_adv_stnd_limit%TYPE;
  v_contact_hours   igs_ps_ver_all.contact_hours%TYPE;
  v_credit_points_required igs_ps_ver_all.credit_points_required%TYPE;
  v_govt_course_load  igs_ps_ver_all.govt_course_load%TYPE;
  v_std_annual_load  igs_ps_ver_all.std_annual_load%TYPE;
  v_course_total_eftsu  igs_ps_ver_all.course_total_eftsu%TYPE;
  v_max_intrmsn_duration  igs_ps_ver_all.max_intrmsn_duration%TYPE;
  v_num_of_units_before_intrmsn igs_ps_ver_all.num_of_units_before_intrmsn%TYPE;
  v_min_sbmsn_percentage  igs_ps_ver_all.min_sbmsn_percentage%TYPE;
  v_min_cp_per_calendar           igs_ps_ver_all.min_cp_per_calendar%TYPE;
  v_approval_date                 igs_ps_ver_all.approval_date%TYPE;
  v_external_approval_date        igs_ps_ver_all.external_approval_date%TYPE;
  v_federal_financial_aid         igs_ps_ver_all.federal_financial_aid%TYPE;
  v_institutional_financial_aid   igs_ps_ver_all.institutional_financial_aid%TYPE;
  v_max_cp_per_teaching_period    igs_ps_ver_all.max_cp_per_teaching_period%TYPE;
  v_residency_cp_required         igs_ps_ver_all.residency_cp_required%TYPE;
  v_state_financial_aid           igs_ps_ver_all.state_financial_aid%TYPE;
  l_rev_account_cd                igs_ps_unit_ver_all.rev_account_cd%TYPE;
  l_primary_program_rank           igs_ps_ver_all.primary_program_rank%TYPE;
  l_n_max_wlst_per_stud           igs_ps_ver_all.max_wlst_per_stud%TYPE;
  l_n_annual_instruction_time     igs_ps_ver_all.annual_instruction_time%TYPE;

  cst_active  VARCHAR2 (6) := 'ACTIVE';
  cst_inactive  VARCHAR2 (8) := 'INACTIVE';
  cst_error   VARCHAR2 (1) := 'E';
  v_s_course_status  igs_ps_stat.s_course_status%TYPE;

  CURSOR  c_get_s_course_status IS
  SELECT s_course_status
  FROM igs_ps_stat
  WHERE course_status = new_references.course_status;

  CURSOR spvh_cur IS
  SELECT ROWID
  FROM igs_ps_ver_hist
  WHERE course_cd = old_references.course_cd AND
  version_number = old_references.version_number;

  BEGIN
  -- Validate the IGS_PS_COURSE version fields cannot be updated if the IGS_PS_COURSE
  -- version has a system status of 'INACTIVE'. IGS_GE_EXCEPTIONS are : IGS_PS_STAT,
  -- expiry_dt and end_dt.
  IF p_updating THEN
    OPEN c_get_s_course_status;
    FETCH c_get_s_course_status
    INTO v_s_course_status;
    IF c_get_s_course_status%FOUND AND
     (v_s_course_status = cst_inactive) THEN
      IF (NVL(old_references.start_dt, igs_ge_date.igsdate('1900/01/01')) <>
      NVL(new_references.start_dt, igs_ge_date.igsdate('1900/01/01'))) OR
      (NVL(old_references.review_dt, igs_ge_date.igsdate('1900/01/01')) <>
      NVL(new_references.review_dt, igs_ge_date.igsdate('1900/01/01'))) OR
      (old_references.title <> new_references.title) OR
      (old_references.short_title <> new_references.short_title) OR
      (old_references.abbreviation <> new_references.abbreviation) OR
      (old_references.supp_exam_permitted_ind <> new_references.supp_exam_permitted_ind) OR
      (old_references.generic_course_ind <> new_references.generic_course_ind) OR
      (old_references.graduate_students_ind <> new_references.graduate_students_ind) OR
      (old_references.count_intrmsn_in_time_ind <> new_references.count_intrmsn_in_time_ind) OR
      (old_references.intrmsn_allowed_ind <> new_references.intrmsn_allowed_ind) OR
      (old_references.course_type <> new_references.course_type) OR
      (old_references.responsible_org_unit_cd <> new_references.responsible_org_unit_cd) OR
      (NVL(old_references.responsible_ou_start_dt, igs_ge_date.igsdate('1900/01/01')) <>
       NVL(new_references.responsible_ou_start_dt, igs_ge_date.igsdate('1900/01/01'))) OR
      (old_references.govt_special_course_type <>new_references.govt_special_course_type) OR
      (NVL(old_references.qualification_recency,999999) <>
      NVL(new_references.qualification_recency,999999)) OR
      (NVL(old_references.external_adv_stnd_limit,999999) <>
      NVL(new_references.external_adv_stnd_limit,999999)) OR
      (NVL(old_references.internal_adv_stnd_limit,999999) <>
      NVL(new_references.internal_adv_stnd_limit,999999)) OR
      (NVL(old_references.contact_hours,999999) <> NVL(new_references.contact_hours,999999)) OR
      (NVL(old_references.credit_points_required,999999) <>
      NVL(new_references.credit_points_required,999999)) OR
      (NVL(old_references.govt_course_load,999999) <>
      NVL(new_references.govt_course_load,999999)) OR
      (NVL(old_references.std_annual_load,999999) <> NVL(new_references.std_annual_load,999999)) OR
      (NVL(old_references.course_total_eftsu,999999) <>
      NVL(new_references.course_total_eftsu,999999)) OR
      (NVL(old_references.max_intrmsn_duration,999999) <>
      NVL(new_references.max_intrmsn_duration,999999)) OR
      (NVL(old_references.num_of_units_before_intrmsn,999999) <>
      NVL(new_references.num_of_units_before_intrmsn,999999)) OR
      (NVL(old_references.rev_account_cd,'N') <>
      NVL(new_references.rev_account_cd,'N')) OR
      (NVL(old_references.primary_program_rank,99999) <>
      NVL(new_references.primary_program_rank,99999)) OR
      (NVL(old_references.max_wlst_per_stud,99999) <>
      NVL(new_references.max_wlst_per_stud,99999))  OR
      (NVL(old_references.annual_instruction_time,99999) <>
      NVL(new_references.annual_instruction_time,99999))

      THEN
      CLOSE c_get_s_course_status;
      fnd_message.set_name('IGS','IGS_PS_CHG_CANNOT_BEMADE_PRG');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      END IF;
    END IF; -- s_course_status found.
    CLOSE c_get_s_course_status;
  END IF;
  -- Validate the IGS_PS_COURSE status.
  IF p_inserting OR
     (p_updating AND (old_references.course_status <> new_references.course_status)) THEN
    IF igs_ps_val_crv.crsp_val_crv_status (
      new_references.course_status,
      old_references.course_status,
      v_message_name) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    -- Perform a quality check if p_updating to a system status of ACTIVE.
    -- IGS_GE_NOTE: A IGS_PS_COURSE version can only be created with a status of PLANNED.
    --  Hence, only need to perform the check if p_updating.
    IF p_updating AND
     (v_s_course_status = cst_active) THEN
      -- Save the rowid, old expiry_dt and old IGS_PS_STAT,
      -- and process in the "after statement" trigger
      -- as function will cause a mutating table error if called here.
      rowvalmutation(
                    p_inserting => p_inserting,
                    p_updating => p_updating,
                    p_deleting => p_deleting
                    );
    END IF;
  END IF;
  -- Validate the IGS_PS_COURSE type.
  IF p_inserting OR
     (p_updating AND (old_references.course_type <> new_references.course_type)) THEN
    IF igs_ps_val_crv.crsp_val_crv_type (
      new_references.course_cd,
      new_references.version_number,
      new_references.course_type,
      v_message_name) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END IF;
  -- Validate the GOVT special IGS_PS_COURSE type.
  IF p_inserting OR
     (p_updating AND
     (old_references.govt_special_course_type<> new_references.govt_special_course_type)) THEN
    IF igs_ps_val_crv.crsp_val_crv_gsct (
      new_references.govt_special_course_type,
      v_message_name) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END IF;
  -- Validate the version dates.
  IF p_inserting OR
   (p_updating AND (old_references.start_dt <> new_references.start_dt)) OR
   (p_updating AND
   (NVL(old_references.end_dt, igs_ge_date.igsdate('1900/01/01')) <>
   NVL(new_references.end_dt,igs_ge_date.igsdate('1900/01/01')))) OR
   (p_updating AND
   (NVL(old_references.expiry_dt, igs_ge_date.igsdate('1900/01/01')) <>
   NVL(new_references.expiry_dt,igs_ge_date.igsdate('1900/01/01')))) THEN
   /* As part of bug# 1956374 changed the following call from igs_ps_val_crv.crsp_val_ver_dt*/
    IF igs_ps_val_us.crsp_val_ver_dt (
      new_references.start_dt,
      new_references.end_dt,
      new_references.expiry_dt,
      v_message_name,FALSE) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END IF;
  IF p_updating AND new_references.end_dt IS NOT NULL THEN
    IF igs_ps_val_crv.crsp_val_crv_end(new_references.course_cd,
     new_references.version_number,
     v_return_type,
     v_message_name) = FALSE THEN
      IF v_return_type = cst_error THEN
        fnd_message.set_name('IGS',v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
  END IF;
  -- Validate the responsible org IGS_PS_UNIT.
  IF p_inserting OR
     (p_updating AND
  ((old_references.responsible_org_unit_cd <> new_references.responsible_org_unit_cd) OR
  (NVL(old_references.responsible_ou_start_dt,igs_ge_date.igsdate('1900/01/01')) <>
   NVL(new_references.responsible_ou_start_dt, igs_ge_date.igsdate('1900/01/01')))))THEN
    IF igs_ps_val_crv.crsp_val_ou_sys_sts (
      new_references.responsible_org_unit_cd,
      new_references.responsible_ou_start_dt,
      v_message_name) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END IF;
  -- Validate IGS_PS_COURSE status and end date combination.
  IF p_inserting OR
  (p_updating AND
   ((NVL(old_references.end_dt, igs_ge_date.igsdate('1900/01/01')) <>
   NVL(new_references.end_dt,igs_ge_date.igsdate('1900/01/01'))) OR
   (old_references.course_status <> new_references.course_status))) THEN
    IF igs_ps_val_crv.crsp_val_crv_end_sts(
      new_references.end_dt,
      new_references.course_status,
      v_message_name) = FALSE THEN
      fnd_message.set_name('IGS',v_message_name);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
  END IF;

  -- Store IGS_PS_COURSE Version History
  IF p_updating THEN
    IF old_references.start_dt <> new_references.start_dt OR
    old_references.course_status <> new_references.course_status OR
    old_references.title <> new_references.title OR
    old_references.short_title <> new_references.short_title OR
    old_references.abbreviation <> new_references.abbreviation OR
    old_references.supp_exam_permitted_ind <> new_references.supp_exam_permitted_ind OR
    old_references.generic_course_ind <> new_references.generic_course_ind OR
    old_references.graduate_students_ind <> new_references.graduate_students_ind OR
    old_references.count_intrmsn_in_time_ind <> new_references.count_intrmsn_in_time_ind OR
    old_references.intrmsn_allowed_ind <> new_references.intrmsn_allowed_ind OR
    old_references.course_type <> new_references.course_type OR
    old_references.responsible_org_unit_cd <> new_references.responsible_org_unit_cd OR
    old_references.responsible_ou_start_dt <> new_references.responsible_ou_start_dt OR
    old_references.govt_special_course_type <> new_references.govt_special_course_type OR
    NVL(old_references.qualification_recency,999999) <>
    NVL(new_references.qualification_recency,999999) OR
    NVL(old_references.external_adv_stnd_limit,999999) <>
    NVL(new_references.external_adv_stnd_limit,999999) OR
    NVL(old_references.internal_adv_stnd_limit,999999) <>
    NVL(new_references.internal_adv_stnd_limit,999999) OR
    NVL(old_references.contact_hours,999999) <> NVL(new_references.contact_hours,999999) OR
    NVL(old_references.credit_points_required,999999) <>
    NVL(new_references.credit_points_required,999999) OR
    NVL(old_references.govt_course_load,999999) <>
    NVL(new_references.govt_course_load,999999) OR
    NVL(old_references.std_annual_load,999999) <>
    NVL(new_references.std_annual_load,999999) OR
    NVL(old_references.course_total_eftsu,999999) <>
    NVL(new_references.course_total_eftsu,999999) OR
    NVL(old_references.max_intrmsn_duration,999999) <>
    NVL(new_references.max_intrmsn_duration,999999) OR
    NVL(old_references.num_of_units_before_intrmsn,999999) <>
    NVL(new_references.num_of_units_before_intrmsn,999999) OR
    NVL(old_references.min_sbmsn_percentage,999999) <>
    NVL(new_references.min_sbmsn_percentage,999999) OR
    NVL(old_references.review_dt, igs_ge_date.igsdate('1900/01/01')) <>
    NVL(new_references.review_dt,igs_ge_date.igsdate('1900/01/01')) OR
    NVL(old_references.expiry_dt, igs_ge_date.igsdate('1900/01/01')) <>
    NVL(new_references.expiry_dt, igs_ge_date.igsdate('1900/01/01')) OR
    NVL(old_references.end_dt, igs_ge_date.igsdate('1900/01/01')) <>
    NVL(new_references.end_dt, igs_ge_date.igsdate('1900/01/01')) OR
    (NVL(old_references.min_cp_per_calendar,999999) <>
                         NVL(new_references.min_cp_per_calendar,999999)) OR
    (NVL(old_references.approval_date, igs_ge_date.igsdate('1900/01/01')) <>
                    NVL(new_references.approval_date,igs_ge_date.igsdate('1900/01/01'))) OR
    (NVL(old_references.external_approval_date, igs_ge_date.igsdate('1900/01/01')) <>
                    NVL(new_references.external_approval_date, igs_ge_date.igsdate('1900/01/01'))) OR
    (old_references.federal_financial_aid <> new_references.federal_financial_aid) OR
    (old_references.institutional_financial_aid <> new_references.institutional_financial_aid) OR
    (NVL(old_references.max_cp_per_teaching_period,999999) <>
    NVL(new_references.max_cp_per_teaching_period,999999)) OR
    (NVL(old_references.residency_cp_required,999999) <>
    NVL(new_references.residency_cp_required,999999)) OR
      (NVL(old_references.primary_program_rank,99999) <>
      NVL(new_references.primary_program_rank,99999)) OR
    (old_references.state_financial_aid <> new_references.state_financial_aid)   OR
    NVL(old_references.max_wlst_per_stud,999999) <>
    NVL(new_references.max_wlst_per_stud,999999) OR
    NVL(old_references.annual_instruction_time,999999) <>
    NVL(new_references.annual_instruction_time,999999)
    THEN
      IF (NVL(old_references.review_dt, igs_ge_date.igsdate('1900/01/01')) <>
        NVL(new_references.review_dt,igs_ge_date.igsdate('1900/01/01'))) THEN
        v_review_dt := old_references.review_dt;
      END IF;
      IF (NVL(old_references.expiry_dt, igs_ge_date.igsdate('1900/01/01')) <>
        NVL(new_references.expiry_dt, igs_ge_date.igsdate('1900/01/01'))) THEN
        v_expiry_dt := old_references.expiry_dt;
      END IF;
      IF (NVL(old_references.end_dt, igs_ge_date.igsdate('1900/01/01')) <>
        NVL(new_references.end_dt, igs_ge_date.igsdate('1900/01/01'))) THEN
         v_end_dt := old_references.end_dt;
       END IF;
      -- Use decode to compare the new and old values, and if they have changed
      -- put the old value in the variable to be passed to the history routine.
      SELECT decode(old_references.start_dt,new_references.start_dt,
      NULL,old_references.start_dt),
      decode(old_references.course_status,new_references.course_status,
      NULL,old_references.course_status),
      decode(old_references.title,new_references.title,
      NULL,old_references.title),
      decode(old_references.short_title,new_references.short_title,
      NULL,old_references.short_title),
      decode(old_references.abbreviation,new_references.abbreviation,NULL,
      old_references.abbreviation),
      decode(old_references.supp_exam_permitted_ind,new_references.supp_exam_permitted_ind,
      NULL,old_references.supp_exam_permitted_ind),
      decode(old_references.generic_course_ind,new_references.generic_course_ind,
      NULL,old_references.generic_course_ind),
      decode(old_references.graduate_students_ind,new_references.graduate_students_ind,
      NULL,old_references.graduate_students_ind),
      decode(old_references.count_intrmsn_in_time_ind,new_references.count_intrmsn_in_time_ind,
      NULL,old_references.count_intrmsn_in_time_ind),
      decode(old_references.intrmsn_allowed_ind,new_references.intrmsn_allowed_ind,
      NULL,old_references.intrmsn_allowed_ind),
      decode(old_references.course_type,new_references.course_type,
      NULL,old_references.course_type),
      decode(old_references.responsible_org_unit_cd,new_references.responsible_org_unit_cd,
      NULL,old_references.responsible_org_unit_cd),
      decode(old_references.govt_special_course_type,new_references.govt_special_course_type,
      NULL,old_references.govt_special_course_type),
      decode(NVL(old_references.qualification_recency,999999),
      NVL(new_references.qualification_recency,999999),
      NULL,old_references.qualification_recency),
      decode(NVL(old_references.external_adv_stnd_limit,999999),
      NVL(new_references.external_adv_stnd_limit,999999),
      NULL,old_references.external_adv_stnd_limit),
      decode(NVL(old_references.internal_adv_stnd_limit,999999),
      NVL(new_references.internal_adv_stnd_limit,999999),
      NULL,old_references.internal_adv_stnd_limit),
      decode(NVL(old_references.contact_hours,999999),NVL(new_references.contact_hours,999999),
      NULL,old_references.contact_hours),
      decode(NVL(old_references.credit_points_required,999999),
      NVL(new_references.credit_points_required,999999),
      NULL,old_references.credit_points_required),
      decode(NVL(old_references.govt_course_load,999999),
      NVL(new_references.govt_course_load,999999),
      NULL,old_references.govt_course_load),
      decode(NVL(old_references.std_annual_load,999999),NVL(new_references.std_annual_load,999999),
      NULL,old_references.std_annual_load),
      decode(NVL(old_references.course_total_eftsu,999999),
      NVL(new_references.course_total_eftsu,999999),
      NULL,old_references.course_total_eftsu),
      decode(NVL(old_references.max_intrmsn_duration,999999),
      NVL(new_references.max_intrmsn_duration,999999),
      NULL,old_references.max_intrmsn_duration),
      decode(NVL(old_references.num_of_units_before_intrmsn,999999),
      NVL(new_references.num_of_units_before_intrmsn,999999),
      NULL,old_references.num_of_units_before_intrmsn),
      decode(NVL(old_references.min_sbmsn_percentage,999999),
      NVL(new_references.min_sbmsn_percentage,999999),
      NULL,old_references.min_sbmsn_percentage),
      decode(NVL(old_references.min_cp_per_calendar,999999),
      NVL(new_references.min_cp_per_calendar,999999),
      NULL,old_references.min_cp_per_calendar),
      decode(old_references.approval_date,new_references.approval_date,
      NULL,old_references.approval_date),
                                decode(old_references.external_approval_date,new_references.external_approval_date,
      NULL,old_references.external_approval_date),
                                decode(old_references.federal_financial_aid,new_references.federal_financial_aid,
      NULL,old_references.federal_financial_aid),
      decode(old_references.institutional_financial_aid,new_references.institutional_financial_aid,
      NULL,old_references.institutional_financial_aid),
      decode(NVL(old_references.max_cp_per_teaching_period,999999),
      NVL(new_references.max_cp_per_teaching_period,999999),
      NULL,old_references.max_cp_per_teaching_period),
      decode(NVL(old_references.residency_cp_required,999999),
      NVL(new_references.residency_cp_required,999999),
      NULL,old_references.residency_cp_required),
      decode(old_references.state_financial_aid,new_references.state_financial_aid,
      NULL,old_references.state_financial_aid),
      decode(NVL(old_references.primary_program_rank,99999),
      NVL(new_references.primary_program_rank,99999),
      NULL,old_references.primary_program_rank),
      decode(NVL(old_references.max_wlst_per_stud,99999),
      NVL(new_references.max_wlst_per_stud,99999),
      NULL,old_references.max_wlst_per_stud),
      decode(NVL(old_references.annual_instruction_time,99999),
      NVL(new_references.annual_instruction_time,99999),
      NULL,old_references.annual_instruction_time)

     INTO v_start_dt,
         v_course_status,
         v_title,
         v_short_title,
         v_abbreviation,
         v_supp_exam_permitted_ind,
         v_generic_course_ind,
         v_graduate_students_ind,
         v_count_intrmsn_in_time_ind,
         v_intrmsn_allowed_ind,
         v_course_type,
         v_responsible_org_unit_cd,
         v_govt_special_course_type,
         v_qualification_recency,
         v_external_adv_stnd_limit,
         v_internal_adv_stnd_limit,
         v_contact_hours,
         v_credit_points_required,
         v_govt_course_load,
         v_std_annual_load,
         v_course_total_eftsu,
         v_max_intrmsn_duration,
         v_num_of_units_before_intrmsn,
         v_min_sbmsn_percentage,
         v_min_cp_per_calendar,
         v_approval_date,
         v_external_approval_date,
         v_federal_financial_aid,
         v_institutional_financial_aid,
         v_max_cp_per_teaching_period,
         v_residency_cp_required,
         v_state_financial_aid,
         l_primary_program_rank,
         l_n_max_wlst_per_stud,
         l_n_annual_instruction_time
     FROM dual;

    IF old_references.responsible_org_unit_cd <> new_references.responsible_org_unit_cd THEN
      v_responsible_ou_start_dt := new_references.responsible_ou_start_dt;
    END IF;
    -- Create history record for update
    igs_ps_gen_002.crsp_ins_cv_hist(
          old_references.course_cd,
          old_references.version_number,
          old_references.last_update_date,
          new_references.last_update_date,
          old_references.last_updated_by,
          v_start_dt,
          v_review_dt,
          v_expiry_dt,
          v_end_dt,
          v_course_status,
          v_title,
          v_short_title,
          v_abbreviation,
          v_supp_exam_permitted_ind,
          v_generic_course_ind,
          v_graduate_students_ind,
          v_count_intrmsn_in_time_ind,
          v_intrmsn_allowed_ind,
          v_course_type,
          v_responsible_org_unit_cd,
          v_responsible_ou_start_dt,
          v_govt_special_course_type,
          v_qualification_recency,
          v_external_adv_stnd_limit,
          v_internal_adv_stnd_limit,
          v_contact_hours,
          v_credit_points_required,
          v_govt_course_load,
          v_std_annual_load,
          v_course_total_eftsu,
          v_max_intrmsn_duration,
          v_num_of_units_before_intrmsn,
          v_min_sbmsn_percentage,
          v_min_cp_per_calendar,
          v_approval_date,
          v_external_approval_date,
          v_federal_financial_aid,
          v_institutional_financial_aid,
          v_max_cp_per_teaching_period,
          v_residency_cp_required,
          v_state_financial_aid,
          l_primary_program_rank,
          l_n_max_wlst_per_stud,
	  l_n_annual_instruction_time);

        END IF;
      END IF;
      IF p_deleting THEN

      BEGIN
      FOR spvh_rec IN spvh_cur
        LOOP
          igs_ps_ver_hist_pkg.delete_row(x_rowid  => spvh_rec.rowid);
        END LOOP;
      END;

    END IF;

  END beforerowinsertupdatedelete1;

  PROCEDURE afterrowinsertupdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sarakshi    11-Aug-2005  Bug#4112225, replaced user defined course status with system defined course status
  vvutukur    19-Oct-2002  Enh#2608227.Removed DEFAULT keyword to avoid gscc File.Pkg.22 warning.
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  nalkumar    16-Dec-2003  Modified the code to fix Bug# 3310718
  (reverse chronological order - newest change first)
  *************************************************************************/
    CURSOR cur_igs_ps_unit_lvl IS
    SELECT ulvl.*
    FROM igs_ps_unit_lvl_all ulvl
    WHERE course_cd = new_references.course_cd;
    l_rowid VARCHAR2(25);

    CURSOR cur_get_status(cp_course_status igs_ps_stat.course_status%TYPE) IS
        SELECT   s_course_status
        FROM     igs_ps_stat
        WHERE    course_status=cp_course_status;

    l_old_course_status igs_ps_stat.s_course_status%TYPE;
    l_new_course_status igs_ps_stat.s_course_status%TYPE;

  BEGIN
    --
    -- Copy the New Program Version details to the Unit Level when the New Program Version is created.
    -- Start of new code added to fix Bug# 3310718.
    --
    IF p_updating  THEN
       OPEN cur_get_status(old_references.course_status);
       FETCH cur_get_status INTO l_old_course_status;
       CLOSE cur_get_status;

       OPEN cur_get_status(new_references.course_status);
       FETCH cur_get_status INTO l_new_course_status;
       CLOSE cur_get_status;

      IF l_old_course_status = 'PLANNED' AND l_new_course_status = 'ACTIVE' THEN
        FOR rec_igs_ps_unit_lvl IN cur_igs_ps_unit_lvl LOOP
          l_rowid := NULL;
          igs_ps_unit_lvl_pkg.insert_row(
            X_ROWID                  => l_rowid                           ,
            X_UNIT_CD                => rec_igs_ps_unit_lvl.unit_cd       ,
            X_VERSION_NUMBER         => rec_igs_ps_unit_lvl.version_number,
            X_COURSE_TYPE            => rec_igs_ps_unit_lvl.course_type   ,
            X_UNIT_LEVEL             => rec_igs_ps_unit_lvl.unit_level    ,
            X_WAM_WEIGHTING          => rec_igs_ps_unit_lvl.wam_weighting ,
            X_MODE                   => 'R'                               ,
            X_ORG_ID                 => rec_igs_ps_unit_lvl.org_id        ,
            X_COURSE_CD              => rec_igs_ps_unit_lvl.course_cd     ,
            X_COURSE_VERSION_NUMBER  => new_references.version_number
          );
        END LOOP;
      END IF;
    END IF;
    --
    -- End of new code added to fix Bug# 3310718.
    --

    -- Validate IGS_PS_COURSE status and expiry date.
   IF p_inserting OR
   (p_updating AND
   ((NVL(old_references.expiry_dt, igs_ge_date.igsdate('1900/01/01')) <>
   NVL(new_references.expiry_dt, igs_ge_date.igsdate('1900/01/01'))) OR
   (old_references.course_status <> new_references.course_status))) THEN
     -- Cannot call crsp_val_crv_exp_sts because trigger will be mutating.
     -- Save the rowid of the current row.
      rowvalmutation(
                p_inserting => p_inserting,
                p_updating => p_updating,
                p_deleting => p_deleting
                );
    END IF;


  END afterrowinsertupdate2;

  PROCEDURE check_constraints (
  column_name IN VARCHAR2 ,
  column_value IN VARCHAR2
  ) IS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who         When          What
  vvutukur  18-Oct-2002  Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                         as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22 warning.
  sbeerell  10-MAY-2000  Changed for new DLD version 2
  smvk      20-Dec-2002  Removed the responsible_org_unit_cd should be in upper case checking. Bug # 2487149
  (reverse chronological order - newest change first)
  *************************************************************************/
  BEGIN
    IF column_name IS NULL THEN
      NULL;
    ELSIF UPPER(column_name) = 'MAX_INTRMSN_DURATION' THEN
      new_references.max_intrmsn_duration :=igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'COURSE_TOTAL_EFTSU' THEN
      new_references.course_total_eftsu := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'ABBREVIATION' THEN
      new_references.abbreviation := column_value;
    ELSIF UPPER(column_name) = 'COUNT_INTRMSN_IN_TIME_IND' THEN
      new_references.count_intrmsn_in_time_ind := column_value;
    ELSIF UPPER(column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
    ELSIF UPPER(column_name) = 'COURSE_STATUS' THEN
      new_references.course_status := column_value;
    ELSIF UPPER(column_name) = 'COURSE_TYPE' THEN
      new_references.course_type := column_value;
    ELSIF UPPER(column_name) = 'GENERIC_COURSE_IND' THEN
      new_references.generic_course_ind := column_value;
    ELSIF UPPER(column_name) = 'GOVT_SPECIAL_COURSE_TYPE' THEN
      new_references.govt_special_course_type := column_value;
    ELSIF UPPER(column_name) = 'GRADUATE_STUDENTS_IND' THEN
      new_references.graduate_students_ind:= column_value;
    ELSIF UPPER(column_name) = 'INTRMSN_ALLOWED_IND' THEN
      new_references.intrmsn_allowed_ind := column_value;
    ELSIF UPPER(column_name) = 'SUPP_EXAM_PERMITTED_IND' THEN
      new_references.supp_exam_permitted_ind := column_value;
    ELSIF UPPER(column_name) = 'STD_ANNUAL_LOAD' THEN
    new_references.std_annual_load := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'GOVT_COURSE_LOAD' THEN
      new_references.govt_course_load := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'CREDIT_POINTS_REQUIRED' THEN
      new_references.credit_points_required := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'CONTACT_HOURS' THEN
      new_references.contact_hours := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'INTERNAL_ADV_STND_LIMIT' THEN
      new_references.internal_adv_stnd_limit := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'EXTERNAL_ADV_STND_LIMIT' THEN
      new_references.external_adv_stnd_limit := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'QUALIFICATION_RECENCY' THEN
      new_references.qualification_recency := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'VERSION_NUMBER' THEN
      new_references.version_number := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) = 'MIN_SBMSN_PERCENTAGE' THEN
      new_references.min_sbmsn_percentage := igs_ge_number.to_num(column_value);
    ELSIF UPPER(column_name) =  'NUM_OF_UNITS_BEFORE_INTRMSN' THEN
      new_references.num_of_units_before_intrmsn := igs_ge_number.to_num(column_value);
    ELSIF  UPPER(column_name) = 'STATE_FINANCIAL_AID'  THEN
      new_references.state_financial_aid := column_value;
    ELSIF  UPPER(column_name) = 'FEDERAL_FINANCIAL_AID'  THEN
      new_references.federal_financial_aid := column_value;
    ELSIF  UPPER(column_name) = 'INSTITUTIONAL_FINANCIAL_AID'  THEN
      new_references.institutional_financial_aid := column_value;
    ELSIF UPPER(column_name) = 'MAX_WLST_PER_STUD' THEN
      new_references.max_wlst_per_stud := column_value;
    ELSIF UPPER(column_name) = 'ANNUAL_INSTRUCTION_TIME' THEN
      new_references.annual_instruction_time := column_value;
    END IF;

    IF UPPER(column_name)= 'ABBREVIATION' OR
      column_name IS NULL THEN
      IF new_references.abbreviation<> UPPER(new_references.abbreviation)
      THEN
         fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'COURSE_CD' OR
    column_name IS NULL THEN
      IF new_references.course_cd <> UPPER(new_references.course_cd )
      THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'COURSE_STATUS' OR
      column_name IS NULL THEN
      IF new_references.course_status <> UPPER(new_references.course_status)
      THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'COURSE_TYPE' OR
      column_name IS NULL THEN
      IF new_references.course_type <> UPPER(new_references.course_type)
      THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'GOVT_SPECIAL_COURSE_TYPE' OR
      column_name IS NULL THEN
      IF new_references.govt_special_course_type <> UPPER(new_references.govt_special_course_type )
      THEN
        fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'MAX_INTRMSN_DURATION' OR
      column_name IS NULL THEN
      IF new_references.max_intrmsn_duration <0 OR
        new_references.max_intrmsn_duration > 999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'COURSE_TOTAL_EFTSU' OR
      column_name IS NULL THEN
      IF new_references.course_total_eftsu < 0 OR
        new_references.course_total_eftsu > 99.999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'STD_ANNUAL_LOAD' OR
    column_name IS NULL THEN
      IF new_references.std_annual_load < 0 OR
        new_references.std_annual_load > 9999.999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
       END IF;
    END IF;
    IF UPPER(column_name)= 'GOVT_COURSE_LOAD' OR
      column_name IS NULL THEN
      IF new_references.govt_course_load < 0 OR
        new_references.govt_course_load > 99
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
              app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'CREDIT_POINTS_REQUIRED' OR
      column_name IS NULL THEN
      IF new_references.credit_points_required < 0 OR
      new_references.credit_points_required > 999.999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'CONTACT_HOURS' OR
    column_name IS NULL THEN
      IF new_references.contact_hours < 0 OR
        new_references.contact_hours > 9999.999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
       END IF;
    END IF;
    IF UPPER(column_name)= 'INTERNAL_ADV_STND_LIMIT' OR
      column_name IS NULL THEN
      IF new_references.internal_adv_stnd_limit < 0 OR
        new_references.internal_adv_stnd_limit > 9999.999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'EXTERNAL_ADV_STND_LIMIT' OR
    column_name IS NULL THEN
     IF new_references.external_adv_stnd_limit < 0 OR
       new_references.external_adv_stnd_limit > 9999.999
     THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
     END IF;
   END IF;
   IF UPPER(column_name)= 'QUALIFICATION_RECENCY' OR
    column_name IS NULL THEN
    IF new_references.qualification_recency < 0 OR
      new_references.qualification_recency > 99
    THEN
             fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
             igs_ge_msg_stack.add;
             app_exception.raise_exception;
    END IF;
    END IF;
    IF UPPER(column_name)= 'INTRMSN_ALLOWED_IND' OR
      column_name IS NULL THEN
      IF new_references.intrmsn_allowed_ind NOT IN ( 'Y' , 'N' )
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'COUNT_INTRMSN_IN_TIME_IND' OR
    column_name IS NULL THEN
      IF new_references.count_intrmsn_in_time_ind NOT IN ( 'Y' , 'N' )
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'GRADUATE_STUDENTS_IND' OR
    column_name IS NULL THEN
      IF new_references.graduate_students_ind NOT IN ( 'Y' , 'N' )
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'GENERIC_COURSE_IND' OR
    column_name IS NULL THEN
      IF new_references.generic_course_ind NOT IN ( 'Y' , 'N' )
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'SUPP_EXAM_PERMITTED_IND' OR
      column_name IS NULL THEN
      IF new_references.supp_exam_permitted_ind NOT IN ( 'Y' , 'N' )
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'VERSION_NUMBER' OR
      column_name IS NULL THEN
      IF new_references.version_number < 1 OR
        new_references.version_number > 999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'MIN_SBMSN_PERCENTAGE' OR
      column_name IS NULL THEN
      IF new_references.min_sbmsn_percentage < 0 OR
        new_references.min_sbmsn_percentage > 100.00
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;
    IF UPPER(column_name)= 'NUM_OF_UNITS_BEFORE_INTRMSN' OR
      column_name IS NULL THEN
      IF new_references.num_of_units_before_intrmsn < 0 OR
        new_references.num_of_units_before_intrmsn > 999
      THEN
               fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
      END IF;
    END IF;

    -- The following code checks for check constraints on the Columns.
      IF UPPER(column_name) = 'STATE_FINANCIAL_AID' OR
       column_name IS NULL THEN
        IF NOT (new_references.state_financial_aid IN ('Y', 'N'))  THEN
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
      END IF;

      -- The following code checks for check constraints on the Columns.
      IF UPPER(column_name) = 'FEDERAL_FINANCIAL_AID' OR
       column_name IS NULL THEN
        IF NOT (new_references.federal_financial_aid IN ('Y', 'N'))  THEN
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
      END IF;

     -- The following code checks for check constraints on the Columns.
     IF UPPER(column_name) = 'INSTITUTIONAL_FINANCIAL_AID' OR
       column_name IS NULL THEN
        IF NOT (new_references.institutional_financial_aid IN ('Y', 'N'))  THEN
           fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
        END IF;
     END IF;

    IF UPPER(column_name)= 'MAX_WLST_PER_STUD' OR column_name IS NULL THEN
      IF new_references.max_wlst_per_stud < 0 OR  new_references.max_wlst_per_stud > 9999 THEN
         fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

    IF UPPER(column_name)= 'ANNUAL_INSTRUCTION_TIME' OR column_name IS NULL THEN
      IF new_references.annual_instruction_time < 1 OR  new_references.annual_instruction_time > 99.99 THEN
         fnd_message.set_name ('IGS', 'IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;

  PROCEDURE check_parent_existance  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
   sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  BEGIN

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

    IF (((old_references.course_cd = new_references.course_cd)) OR
        ((new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_ps_course_pkg.get_pk_for_validation (
        new_references.course_cd
              )THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_ps_type_pkg.get_pk_for_validation (
        new_references.course_type
      )THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      END IF;
    END IF;
    IF (((old_references.govt_special_course_type = new_references.govt_special_course_type)) OR
        ((new_references.govt_special_course_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_ps_govt_spl_type_pkg.get_pk_for_validation (
        new_references.govt_special_course_type
      )THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    END IF;

    IF (((old_references.responsible_org_unit_cd = new_references.responsible_org_unit_cd) AND
         (old_references.responsible_ou_start_dt = new_references.responsible_ou_start_dt)) OR
        ((new_references.responsible_org_unit_cd IS NULL) OR
         (new_references.responsible_ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_or_unit_pkg.get_pk_for_validation (
        new_references.responsible_org_unit_cd,
        new_references.responsible_ou_start_dt
      )THEN
         fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;

    END IF;

    IF (((old_references.course_status = new_references.course_status)) OR
        ((new_references.course_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT igs_ps_stat_pkg.get_pk_for_validation (
        new_references.course_status
      )THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sarakshi    02-Apr-2004  Bug#3345205, added child existance for IGS_EN_PSV_TERM_IT
  ugummall    27-NOV-2003  Bug 3252832. FA 131 - COD Updates.
                           Added igf_gr_pell_setup_pkg.get_fk_igs_ps_ver for child existance.
  ijeddy      05-nov-2003  Bug# 3181938; Modified this object as per Summary Measurement Of Attainment FD.
  vvutukur    09-Jun-2003  Enh#2831572.Financial Accounting Build.Added call to igs_fi_ftci_accts_pkg.get_fk_igs_ps_ver.
  rghosh      28-oct-2002  Added the get fk call to the table igs_ad_deplvl_prg for bug#2602077
  pmarada     15-feb-2002  Added IGS_HE_ST_PROG_ALL_PKG.GET_FK_IGS_PS_VER_ALL for hesa requirment.
  smadathi    01-Feb-2002  Added igf_sp_prg_pkg.get_fk_igs_ps_ver and
                           igf_sp_std_prg_pkg.get_fk_igs_ps_ver calls.
                           Bug 2154941
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/

     CURSOR c_hesa IS
     SELECT 1 FROM USER_OBJECTS
     WHERE OBJECT_NAME  = 'IGS_HE_ST_PROG_ALL_PKG'
     AND   object_type = 'PACKAGE BODY';

     l_hesa  VARCHAR2(1);

  BEGIN

      IGS_PS_UNIT_LVL_PKG.get_fk_igs_ps_ver(
      old_references.course_cd,
      old_references.version_number
      );

    igs_pr_ul_mark_cnfg_pkg.get_fk_igs_ps_ver(
      old_references.course_cd,
      old_references.version_number
      );

    igs_ad_ps_appl_inst_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_av_adv_standing_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_pe_alternatv_ext_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_co_itm_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_anl_load_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_award_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_categorise_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_field_study_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_fld_std_hist_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_grp_mbr_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_ofr_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_own_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_own_hist_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );
    igs_ps_occup_titles_pkg.get_fk_igs_ps_ver (
      old_references.course_cd
      );

    igs_ps_ref_cd_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_ref_cd_hist_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_stage_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_ver_note_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_ver_ru_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_re_dflt_ms_set_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );


    igs_fi_fnd_src_rstn_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_fi_fd_src_rstn_h_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_co_ou_co_ref_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_pr_ru_appl_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ad_sbm_ps_fntrgt_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

     igs_en_stdnt_ps_att_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_stdnt_apv_alt_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );


    igs_pr_s_crv_prg_con_pkg.get_fk_igs_ps_ver (
      old_references.course_cd,
      old_references.version_number
      );

    igs_ps_rsv_orgun_prf_pkg.get_fk_igs_ps_ver_all(
       old_references.course_cd,
       old_references.version_number);
    igs_ps_rsv_uop_prf_pkg.get_fk_igs_ps_ver_all(
       old_references.course_cd,
       old_references.version_number);
    igs_ps_rsv_usec_prf_pkg.get_fk_igs_ps_ver_all(
       old_references.course_cd,
       old_references.version_number);
-- msrinivi : 1882122 Commented due to leap frog
-- msrinivi : 1882122  Uncommented the following lines after leapfrog
-- Added by Nishikant for enhancement bug#1851586
    igs_fi_fee_as_rate_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number);

    igs_ps_accts_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number);

    igf_sp_prg_pkg.get_fk_igs_ps_ver (
       old_references.course_cd,
       old_references.version_number
    );

    igf_sp_std_prg_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number
    );

    igs_en_config_enr_cp_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number
    );
   -- added by rghosh for bug# 2602077
    igs_ad_deplvl_prg_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number
    );

    -- added by ugummall for build FA 131 COD Updates. Bug 3252832.
    igf_gr_pell_setup_pkg.get_fk_igs_ps_ver(
      old_references.course_cd,
      old_references.version_number
    );

     -- Added the following check chaild existance for the HESA requirment, pmarada
   OPEN c_hesa;
   FETCH c_hesa INTO l_hesa;
   IF c_hesa%FOUND THEN
      EXECUTE IMMEDIATE
     'BEGIN  IGS_HE_ST_PROG_ALL_PKG.GET_FK_IGS_PS_VER_ALL(:1,:2);  END;'
      USING
        old_references.course_cd,
        old_references.version_number;
      CLOSE c_hesa;
   ELSE
     CLOSE c_hesa;
   END IF;

    igs_fi_ftci_accts_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number);

   igs_en_psv_term_it_pkg.get_fk_igs_ps_ver(
       old_references.course_cd,
       old_references.version_number);


  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    )  RETURN BOOLEAN AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sarakshi    16-jun-2002  bug#2416973,locking to be done if course status is planned else not
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/

    -- Bug#2416978, Depending on the course status lock on the table is acquired
    -- lock is required when the course status is Planned since it is allowed to be delete
    -- lock is not required when the course status is non planned so an explicit lock is not required
    -- opening different cursors depending on the course status
    CURSOR cur_get_status IS
        SELECT   st.s_course_status
        FROM     igs_ps_ver_all v ,
                 igs_ps_stat st
        WHERE    v.course_status=st.course_status
        AND      v.course_cd = x_course_cd
        AND      v.version_number = x_version_number;
    l_course_status igs_ps_stat.s_course_status%TYPE;

    CURSOR cur_rowid_planned IS
      SELECT   ROWID
      FROM     igs_ps_ver_all
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      FOR UPDATE NOWAIT;

    CURSOR cur_rowid_non_planned IS
      SELECT   ROWID
      FROM     igs_ps_ver_all
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number;

    lv_rowid cur_rowid_planned%ROWTYPE;

BEGIN

  OPEN cur_get_status;
  FETCH cur_get_status INTO l_course_status;
  IF cur_get_status%NOTFOUND THEN
    CLOSE cur_get_status;
    RETURN(FALSE);
  ELSE
    CLOSE cur_get_status;
    IF l_course_status = 'PLANNED' THEN
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

  PROCEDURE get_fk_igs_ps_course (
    x_course_cd IN VARCHAR2
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ver_all
      WHERE    course_cd = x_course_cd ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRV_CRS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_course;


  PROCEDURE get_fk_igs_ps_govt_spl_type (
    x_govt_special_course_type IN VARCHAR2
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  ************************************************************************/
  CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ver_all
      WHERE    govt_special_course_type = x_govt_special_course_type ;

  lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRV_GSCT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_govt_spl_type;

  PROCEDURE get_fk_igs_or_unit (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/

  CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ver_all
      WHERE    responsible_org_unit_cd = x_org_unit_cd
      AND      responsible_ou_start_dt = x_start_dt ;

  lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRV_OU_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_or_unit;

  PROCEDURE get_fk_igs_ps_stat (
    x_course_status IN VARCHAR2
    )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_ps_ver_all
      WHERE    course_status = x_course_status ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_CRV_CRST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_stat;

  PROCEDURE before_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_start_dt IN DATE ,
    x_review_dt IN DATE ,
    x_expiry_dt IN DATE ,
    x_end_dt IN DATE ,
    x_course_status IN VARCHAR2 ,
    x_title IN VARCHAR2 ,
    x_short_title IN VARCHAR2 ,
    x_abbreviation IN VARCHAR2 ,
    x_supp_exam_permitted_ind IN VARCHAR2 ,
    x_generic_course_ind IN VARCHAR2 ,
    x_graduate_students_ind IN VARCHAR2 ,
    x_count_intrmsn_in_time_ind IN VARCHAR2 ,
    x_intrmsn_allowed_ind IN VARCHAR2 ,
    x_course_type IN VARCHAR2 ,
    x_responsible_org_unit_cd IN VARCHAR2 ,
    x_responsible_ou_start_dt IN DATE ,
    x_govt_special_course_type IN VARCHAR2 ,
    x_qualification_recency IN NUMBER ,
    x_external_adv_stnd_limit IN NUMBER ,
    x_internal_adv_stnd_limit IN NUMBER ,
    x_contact_hours IN NUMBER ,
    x_credit_points_required IN NUMBER ,
    x_govt_course_load IN NUMBER ,
    x_std_annual_load IN NUMBER ,
    x_course_total_eftsu IN NUMBER ,
    x_max_intrmsn_duration IN NUMBER ,
    x_num_of_units_before_intrmsn IN NUMBER ,
    x_min_sbmsn_percentage IN NUMBER ,
    x_max_cp_per_teaching_period IN NUMBER ,
    x_approval_date IN DATE ,
    x_external_approval_date IN DATE ,
    x_residency_cp_required IN NUMBER ,
    x_state_financial_aid IN VARCHAR2 ,
    x_federal_financial_aid IN VARCHAR2 ,
    x_institutional_financial_aid IN VARCHAR2 ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_attribute11 IN VARCHAR2 ,
    x_attribute12 IN VARCHAR2 ,
    x_attribute13 IN VARCHAR2 ,
    x_attribute14 IN VARCHAR2 ,
    x_attribute15 IN VARCHAR2 ,
    x_attribute16 IN VARCHAR2 ,
    x_attribute17 IN VARCHAR2 ,
    x_attribute18 IN VARCHAR2 ,
    x_attribute19 IN VARCHAR2 ,
    x_attribute20 IN VARCHAR2 ,
    x_min_cp_per_calendar IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_rev_account_cd IN VARCHAR2  ,
    x_primary_program_rank NUMBER,
    x_max_wlst_per_stud IN NUMBER,
    x_annual_instruction_time IN NUMBER
     )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur   18-Oct-2002   Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                           as these columns are obsolete.Also modified call to beforerowinsertupdatedelete1 to pass
                           all the parameters as DEFAULT value is removed from the procedure definition.
  sarakshi    16-jun-2002  bug#2416973,added call to beforerowupdate,beforerowdelete
  smadathi    10-MAY-2001  Changed for New DLD Version
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  BEGIN
    set_column_values (
      p_action,
      x_rowid,
      x_course_cd,
      x_version_number,
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
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_govt_special_course_type,
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
      x_max_cp_per_teaching_period,
      x_approval_date,
      x_external_approval_date,
      x_residency_cp_required,
      x_state_financial_aid,
      x_federal_financial_aid,
      x_institutional_financial_aid,
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
      x_min_cp_per_calendar,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_rev_account_cd,
      x_primary_program_rank,
      x_max_wlst_per_stud,
      x_annual_instruction_time
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the PROCEDUREs related to Before Insert.
      beforerowinsertupdatedelete1 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
                                     p_deleting  => FALSE);
      IF get_pk_for_validation(
        new_references.course_cd ,
        new_references.version_number
        ) THEN
        fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
      check_parent_existance;
      ELSIF (p_action = 'UPDATE') THEN
      -- Call all the PROCEDUREs related to Before Update.
      beforerowinsertupdatedelete1 ( p_inserting => FALSE,
                                     p_updating  => TRUE,
                                     p_deleting  => FALSE);
      --bug#2416973,check updation specific validation
      beforerowupdate;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the PROCEDUREs related to Before Delete.
      beforerowinsertupdatedelete1 ( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting  => TRUE );
      --bug#2416973,check deletion specific validation
      beforerowdelete;
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF get_pk_for_validation(
        new_references.course_cd ,
        new_references.version_number
        ) THEN
         fnd_message.set_name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
      END IF;
      check_constraints;
      ELSIF (p_action = 'VALIDATE_UPDATE') THEN
        check_constraints;
      ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;
  END before_dml;

  Procedure dflt_prgm_ref_code ( p_course_cd      IGS_PS_VER_ALL.COURSE_CD%TYPE,
                                 p_version_number IGS_PS_VER_ALL.VERSION_NUMBER%TYPE
                                )AS

  /************************************************************************
  Created By                                : Aiyer
  Date Created By                           : 12/06/2001
  Purpose                                   : Insertion into table IGS_PS_REF_CD for mandatory ref code types and default ref codes
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  *************************************************************************/
  CURSOR c_igs_ge_ref_cd_type_all
  IS
  SELECT
      reference_cd_type,
      mandatory_flag,
      program_flag,
      closed_ind
  FROM
      igs_ge_ref_cd_type_all
  WHERE
      mandatory_flag ='Y'
  AND
      program_flag ='Y'
  AND
      restricted_flag='Y'
  AND
      closed_ind = 'N';

  CURSOR c_igs_ge_ref_cd (p_c_reference_cd_type IGS_PS_REF_CD.REFERENCE_CD_TYPE%TYPE)
  IS
  SELECT
       reference_cd,
       description
  FROM
       igs_ge_ref_cd
  WHERE
       reference_cd_type = p_c_reference_cd_type
 AND   default_flag = 'Y';
  l_c_rowid   VARCHAR2(25) := NULL;
  BEGIN
    FOR cur_igs_ge_ref_cd_type_all IN c_igs_ge_ref_cd_type_all
      LOOP
        FOR cur_igs_ge_ref_cd IN c_igs_ge_ref_cd(cur_igs_ge_ref_cd_type_all.reference_cd_type)
          LOOP
            -- insert a value in igs_ps_ref_cd for every value of  course_cd and version_number having
            -- a applicable program level defined as mandatory  and a default reference code
            BEGIN
              l_c_rowid:=NULL;
              igs_ps_ref_cd_pkg.INSERT_ROW (
                                          X_ROWID              => l_c_rowid,
                                          X_COURSE_CD          => p_course_cd,
                                          X_VERSION_NUMBER     => p_version_number,
                                          X_REFERENCE_CD_TYPE  => cur_igs_ge_ref_cd_type_all.reference_cd_type  ,
                                          X_REFERENCE_CD       => cur_igs_ge_ref_cd.reference_cd ,
                                          X_DESCRIPTION        => cur_igs_ge_ref_cd.description ,
                                          X_MODE               => 'R'
                                        );
             EXCEPTION
                  WHEN OTHERS THEN
                  -- The failure of insertion of reference code should not stop the creation for a program.Hence any exception
                  --raised by the TBH is trapped and the current processing is allowed to proceed
                   NULL;
             END;
          END LOOP;
      END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        -- If an error occurs during insertion in igs_ps_ref_cd then raise an exception.
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
 END dflt_prgm_ref_code;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  CURSOR c_fetch_cou_ver
  IS
  SELECT
        course_cd,
        version_number
  FROM
      igs_ps_ver pv
  WHERE
      row_id =  x_rowid;

  cur_fetch_cou_ver  c_fetch_cou_ver%rowtype;
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the PROCEDUREs related to After Insert.
      afterrowinsertupdate2 ( p_inserting => TRUE,
                              p_updating  => FALSE,
                              p_deleting  => FALSE);
      -- This code has been added by aiyer to insert rows into table igs_ps_ref_cd for corresponding course_cd and version_number
      OPEN  c_fetch_cou_ver;
      FETCH c_fetch_cou_ver INTO cur_fetch_cou_ver;
        dflt_prgm_ref_code ( p_course_cd          =>   cur_fetch_cou_ver.course_cd,
                             p_version_number     =>   cur_fetch_cou_ver.version_number
                           );
      CLOSE c_fetch_cou_ver;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the PROCEDUREs related to After Update.
      afterrowinsertupdate2 ( p_inserting => FALSE,
                              p_updating  => TRUE,
                              p_deleting  => FALSE);
      check_constraints;

    END IF;
  END after_dml;

  PROCEDURE insert_row (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_course_cd IN VARCHAR2,
  x_version_number IN NUMBER,
  x_start_dt IN DATE,
  x_review_dt IN DATE,
  x_expiry_dt IN DATE,
  x_end_dt IN DATE,
  x_course_status IN VARCHAR2,
  x_title IN VARCHAR2,
  x_short_title IN VARCHAR2,
  x_abbreviation IN VARCHAR2,
  x_supp_exam_permitted_ind IN VARCHAR2,
  x_generic_course_ind IN VARCHAR2,
  x_graduate_students_ind IN VARCHAR2,
  x_count_intrmsn_in_time_ind IN VARCHAR2,
  x_intrmsn_allowed_ind IN VARCHAR2,
  x_course_type IN VARCHAR2,
  x_responsible_org_unit_cd IN VARCHAR2,
  x_responsible_ou_start_dt IN DATE,
  x_govt_special_course_type IN VARCHAR2,
  x_qualification_recency IN NUMBER,
  x_external_adv_stnd_limit IN NUMBER,
  x_internal_adv_stnd_limit IN NUMBER,
  x_contact_hours IN NUMBER,
  x_credit_points_required IN NUMBER,
  x_govt_course_load IN NUMBER,
  x_std_annual_load IN NUMBER,
  x_course_total_eftsu IN NUMBER,
  x_max_intrmsn_duration IN NUMBER,
  x_num_of_units_before_intrmsn IN NUMBER,
  x_min_sbmsn_percentage IN NUMBER,
  x_max_cp_per_teaching_period IN NUMBER,
  x_approval_date IN DATE,
  x_external_approval_date IN DATE,
  x_residency_cp_required IN NUMBER,
  x_state_financial_aid IN VARCHAR2,
  x_federal_financial_aid IN VARCHAR2,
  x_institutional_financial_aid IN VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  x_mode IN VARCHAR2,
  x_org_id IN NUMBER,
  x_min_cp_per_calendar IN NUMBER,
  x_rev_account_cd IN VARCHAR2    ,
  x_primary_program_rank IN NUMBER,
  x_max_wlst_per_stud IN NUMBER,
  x_annual_instruction_time IN NUMBER
  ) AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur   18-Oct-2002   Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                           as these columns are obsolete.
  msrinivi    08-Aug-2001    Added new col rev_Account_cd bug # 1882122
  smadathi    10-MAY-2001    Changed for New DLD Version
  sbeerell     10-MAY-2000   Modifiaction for DLD Version 2
  (reverse chronological order - newest change first)
  *************************************************************************/

  CURSOR c IS SELECT ROWID FROM igs_ps_ver_all
      WHERE course_cd = x_course_cd
      AND version_number = x_version_number;
  x_last_update_date DATE;
  x_last_updated_by NUMBER;
  x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml( p_action => 'INSERT',
      x_rowid => x_rowid,
      x_course_cd => x_course_cd,
      x_version_number => x_version_number,
      x_start_dt => x_start_dt,
      x_review_dt => x_review_dt,
      x_expiry_dt => x_expiry_dt,
      x_end_dt => x_end_dt,
      x_course_status => x_course_status,
      x_title => x_title,
      x_short_title => x_short_title,
      x_abbreviation => x_abbreviation,
      x_supp_exam_permitted_ind => NVL(x_supp_exam_permitted_ind,'Y'),
      x_generic_course_ind => NVL(x_generic_course_ind,'N'),
      x_graduate_students_ind => NVL(x_graduate_students_ind,'Y'),
      x_count_intrmsn_in_time_ind => NVL(x_count_intrmsn_in_time_ind,'Y'),
      x_intrmsn_allowed_ind => NVL(x_intrmsn_allowed_ind,'Y'),
      x_course_type => x_course_type,
      x_responsible_org_unit_cd => x_responsible_org_unit_cd,
      x_responsible_ou_start_dt => x_responsible_ou_start_dt,
      x_govt_special_course_type => x_govt_special_course_type,
      x_qualification_recency => x_qualification_recency,
      x_external_adv_stnd_limit => x_external_adv_stnd_limit,
      x_internal_adv_stnd_limit => x_internal_adv_stnd_limit,
      x_contact_hours => x_contact_hours,
      x_credit_points_required => x_credit_points_required,
      x_govt_course_load => x_govt_course_load,
      x_std_annual_load => x_std_annual_load,
      x_course_total_eftsu => x_course_total_eftsu,
      x_max_intrmsn_duration => x_max_intrmsn_duration,
      x_num_of_units_before_intrmsn => x_num_of_units_before_intrmsn,
      x_min_sbmsn_percentage=>x_min_sbmsn_percentage,
      x_max_cp_per_teaching_period=>x_max_cp_per_teaching_period,
      x_approval_date=>x_approval_date,
      x_external_approval_date=>x_external_approval_date,
      x_residency_cp_required=>x_residency_cp_required,
      x_state_financial_aid=>x_state_financial_aid,
      x_federal_financial_aid=>x_federal_financial_aid,
      x_institutional_financial_aid=>x_institutional_financial_aid,
      x_attribute_category=>x_attribute_category,
      x_attribute1=>x_attribute1,
      x_attribute2=>x_attribute2,
      x_attribute3=>x_attribute3,
      x_attribute4=>x_attribute4,
      x_attribute5=>x_attribute5,
      x_attribute6=>x_attribute6,
      x_attribute7=>x_attribute7,
      x_attribute8=>x_attribute8,
      x_attribute9=>x_attribute9,
      x_attribute10=>x_attribute10,
      x_attribute11=>x_attribute11,
      x_attribute12=>x_attribute12,
      x_attribute13=>x_attribute13,
      x_attribute14=>x_attribute14,
      x_attribute15=>x_attribute15,
      x_attribute16=>x_attribute16,
      x_attribute17=>x_attribute17,
      x_attribute18=>x_attribute18,
      x_attribute19=>x_attribute19,
      x_attribute20=>x_attribute20,
      x_min_cp_per_calendar=>x_min_cp_per_calendar,
      x_creation_date => x_last_update_date,
      x_created_by => x_last_updated_by,
      x_last_update_date => x_last_update_date,
      x_last_updated_by => x_last_updated_by,
      x_last_update_login => x_last_update_login,
      x_org_id=>igs_ge_gen_003.get_org_id,
      x_rev_account_cd =>x_rev_account_cd,
      x_primary_program_rank => x_primary_program_rank,
      x_max_wlst_per_stud => x_max_wlst_per_stud,
      x_annual_instruction_time => x_annual_instruction_time
    );

    INSERT INTO igs_ps_ver_all (
    graduate_students_ind,
    count_intrmsn_in_time_ind,
    intrmsn_allowed_ind,
    course_type,
    responsible_org_unit_cd,
    responsible_ou_start_dt,
    govt_special_course_type,
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
    course_cd,
    version_number,
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
    max_cp_per_teaching_period,
    approval_date,
    external_approval_date,
    residency_cp_required,
    state_financial_aid,
    federal_financial_aid,
    institutional_financial_aid,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    attribute16,
    attribute17,
    attribute18,
    attribute19,
    attribute20,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    org_id,
    min_cp_per_calendar,
    rev_account_cd,
    primary_program_rank,
    max_wlst_per_stud,
    annual_instruction_time
    ) VALUES (
    new_references.graduate_students_ind,
    new_references.count_intrmsn_in_time_ind,
    new_references.intrmsn_allowed_ind,
    new_references.course_type,
    new_references.responsible_org_unit_cd,
    new_references.responsible_ou_start_dt,
    new_references.govt_special_course_type,
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
    new_references.course_cd,
    new_references.version_number,
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
    new_references.max_cp_per_teaching_period,
    new_references.approval_date,
    new_references.external_approval_date,
    new_references.residency_cp_required,
    new_references.state_financial_aid,
    new_references.federal_financial_aid,
    new_references.institutional_financial_aid,
    new_references.attribute_category,
    new_references.attribute1,
    new_references.attribute2,
    new_references.attribute3,
    new_references.attribute4,
    new_references.attribute5,
    new_references.attribute6,
    new_references.attribute7,
    new_references.attribute8,
    new_references.attribute9,
    new_references.attribute10,
    new_references.attribute11,
    new_references.attribute12,
    new_references.attribute13,
    new_references.attribute14,
    new_references.attribute15,
    new_references.attribute16,
    new_references.attribute17,
    new_references.attribute18,
    new_references.attribute19,
    new_references.attribute20,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    new_references.org_id,
    new_references.min_cp_per_calendar,
    new_references.rev_account_cd,
    new_references.primary_program_rank,
    new_references.max_wlst_per_stud,
    new_references.annual_instruction_time
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;
    after_dml(
      p_action => 'INSERT',
      x_rowid => x_rowid
    );
  END insert_row;

  PROCEDURE lock_row (
  x_rowid IN VARCHAR2,
  x_course_cd IN VARCHAR2,
  x_version_number IN NUMBER,
  x_start_dt IN DATE,
  x_review_dt IN DATE,
  x_expiry_dt IN DATE,
  x_end_dt IN DATE,
  x_course_status IN VARCHAR2,
  x_title IN VARCHAR2,
  x_short_title IN VARCHAR2,
  x_abbreviation IN VARCHAR2,
  x_supp_exam_permitted_ind IN VARCHAR2,
  x_generic_course_ind IN VARCHAR2,
  x_graduate_students_ind IN VARCHAR2,
  x_count_intrmsn_in_time_ind IN VARCHAR2,
  x_intrmsn_allowed_ind IN VARCHAR2,
  x_course_type IN VARCHAR2,
  x_responsible_org_unit_cd IN VARCHAR2,
  x_responsible_ou_start_dt IN DATE,
  x_govt_special_course_type IN VARCHAR2,
  x_qualification_recency IN NUMBER,
  x_external_adv_stnd_limit IN NUMBER,
  x_internal_adv_stnd_limit IN NUMBER,
  x_contact_hours IN NUMBER,
  x_credit_points_required IN NUMBER,
  x_govt_course_load IN NUMBER,
  x_std_annual_load IN NUMBER,
  x_course_total_eftsu IN NUMBER,
  x_max_intrmsn_duration IN NUMBER,
  x_num_of_units_before_intrmsn IN NUMBER,
  x_min_sbmsn_percentage IN NUMBER,
  x_max_cp_per_teaching_period IN NUMBER,
  x_approval_date IN DATE,
  x_external_approval_date IN DATE,
  x_residency_cp_required IN NUMBER,
  x_state_financial_aid IN VARCHAR2,
  x_federal_financial_aid IN VARCHAR2,
  x_institutional_financial_aid IN VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  x_min_cp_per_calendar IN NUMBER,
  x_rev_account_cd IN VARCHAR2 ,
  x_primary_program_rank IN NUMBER,
  x_max_wlst_per_stud IN NUMBER,
  x_annual_instruction_time IN NUMBER
  ) AS

  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur   18-Oct-2002   Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                           as these columns are obsolete.
  smadathi    10-MAY-2001  Changed for New DLD Version
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  CURSOR c1 IS SELECT
      graduate_students_ind,
      count_intrmsn_in_time_ind,
      intrmsn_allowed_ind,
      course_type,
      responsible_org_unit_cd,
      responsible_ou_start_dt,
      govt_special_course_type,
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
      max_cp_per_teaching_period,
      approval_date,
      external_approval_date,
      residency_cp_required,
      state_financial_aid,
      federal_financial_aid,
      institutional_financial_aid,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      min_cp_per_calendar,
      rev_account_cd,
      primary_program_rank,
      max_wlst_per_stud,
      annual_instruction_time
    FROM igs_ps_ver_all
    WHERE ROWID = x_rowid FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;

  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF( (tlinfo.graduate_students_ind = x_graduate_students_ind)
      AND (tlinfo.count_intrmsn_in_time_ind = x_count_intrmsn_in_time_ind)
      AND (tlinfo.intrmsn_allowed_ind = x_intrmsn_allowed_ind)
      AND (tlinfo.course_type = x_course_type)
      AND (tlinfo.responsible_org_unit_cd = x_responsible_org_unit_cd)
      AND (tlinfo.responsible_ou_start_dt = x_responsible_ou_start_dt)
      AND (tlinfo.govt_special_course_type = x_govt_special_course_type)
      AND ((tlinfo.qualification_recency = x_qualification_recency)
           OR ((tlinfo.qualification_recency IS NULL)
               AND (x_qualification_recency IS NULL)))
      AND ((tlinfo.external_adv_stnd_limit = x_external_adv_stnd_limit)
           OR ((tlinfo.external_adv_stnd_limit IS NULL)
               AND (x_external_adv_stnd_limit IS NULL)))
      AND ((tlinfo.internal_adv_stnd_limit = x_internal_adv_stnd_limit)
           OR ((tlinfo.internal_adv_stnd_limit IS NULL)
               AND (x_internal_adv_stnd_limit IS NULL)))
      AND ((tlinfo.contact_hours = x_contact_hours)
           OR ((tlinfo.contact_hours IS NULL)
               AND (x_contact_hours IS NULL)))
      AND ((tlinfo.credit_points_required = x_credit_points_required)
           OR ((tlinfo.credit_points_required IS NULL)
               AND (x_credit_points_required IS NULL)))
      AND ((tlinfo.govt_course_load = x_govt_course_load)
           OR ((tlinfo.govt_course_load IS NULL)
               AND (x_govt_course_load IS NULL)))
      AND ((tlinfo.std_annual_load = x_std_annual_load)
           OR ((tlinfo.std_annual_load IS NULL)
               AND (x_std_annual_load IS NULL)))
      AND ((tlinfo.course_total_eftsu = x_course_total_eftsu)
           OR ((tlinfo.course_total_eftsu IS NULL)
               AND (x_course_total_eftsu IS NULL)))
      AND ((tlinfo.max_intrmsn_duration = x_max_intrmsn_duration)
           OR ((tlinfo.max_intrmsn_duration IS NULL)
               AND (x_max_intrmsn_duration IS NULL)))
      AND ((tlinfo.num_of_units_before_intrmsn = x_num_of_units_before_intrmsn)
           OR ((tlinfo.num_of_units_before_intrmsn IS NULL)
               AND (x_num_of_units_before_intrmsn IS NULL)))
      AND ((tlinfo.min_sbmsn_percentage = x_min_sbmsn_percentage)
           OR ((tlinfo.min_sbmsn_percentage IS NULL)
               AND (x_min_sbmsn_percentage IS NULL)))
               AND (tlinfo.start_dt = x_start_dt)
      AND ((tlinfo.review_dt = x_review_dt)
           OR ((tlinfo.review_dt IS NULL)
               AND (x_review_dt IS NULL)))
      AND ((tlinfo.expiry_dt = x_expiry_dt)
           OR ((tlinfo.expiry_dt IS NULL)
               AND (x_expiry_dt IS NULL)))
      AND ((tlinfo.end_dt = x_end_dt)
           OR ((tlinfo.end_dt IS NULL)
               AND (x_end_dt IS NULL)))
      AND (tlinfo.course_status = x_course_status)
      AND (tlinfo.title = x_title)
      AND (tlinfo.short_title = x_short_title)
      AND (tlinfo.abbreviation = x_abbreviation)
      AND (tlinfo.supp_exam_permitted_ind = x_supp_exam_permitted_ind)
      AND (tlinfo.generic_course_ind = x_generic_course_ind)
      AND ((tlinfo.max_cp_per_teaching_period = x_max_cp_per_teaching_period)
            OR ((tlinfo.max_cp_per_teaching_period IS NULL)
                AND (x_max_cp_per_teaching_period IS NULL)))
      AND ((tlinfo.approval_date = x_approval_date)
            OR ((tlinfo.approval_date IS NULL)
                AND (x_approval_date IS NULL)))
      AND ((tlinfo.external_approval_date = x_external_approval_date)
            OR ((tlinfo.external_approval_date IS NULL)
                AND (x_external_approval_date IS NULL)))
      AND ((tlinfo.residency_cp_required = x_residency_cp_required)
            OR ((tlinfo.residency_cp_required IS NULL)
                AND (x_residency_cp_required IS NULL)))
      AND ((tlinfo.state_financial_aid = x_state_financial_aid)
            OR ((tlinfo.state_financial_aid IS NULL)
                AND (x_state_financial_aid IS NULL)))
      AND ((tlinfo.federal_financial_aid = x_federal_financial_aid)
            OR ((tlinfo.federal_financial_aid IS NULL)
                AND (x_federal_financial_aid IS NULL)))
      AND ((tlinfo.institutional_financial_aid = x_institutional_financial_aid)
            OR ((tlinfo.institutional_financial_aid IS NULL)
                AND (x_institutional_financial_aid IS NULL)))
      AND ((tlinfo.attribute_category = x_attribute_category)
            OR ((tlinfo.attribute_category IS NULL)
                AND (x_attribute_category IS NULL)))
      AND ((tlinfo.attribute1 = x_attribute1)
            OR ((tlinfo.attribute1 IS NULL)
                AND (x_attribute1 IS NULL)))
      AND ((tlinfo.attribute2 = x_attribute2)
            OR ((tlinfo.attribute2 IS NULL)
                AND (x_attribute2 IS NULL)))
      AND ((tlinfo.attribute3 = x_attribute3)
            OR ((tlinfo.attribute3 IS NULL)
                AND (x_attribute3 IS NULL)))
      AND ((tlinfo.attribute4 = x_attribute4)
            OR ((tlinfo.attribute4 IS NULL)
                AND (x_attribute4 IS NULL)))
      AND ((tlinfo.attribute5 = x_attribute5)
            OR ((tlinfo.attribute5 IS NULL)
                AND (x_attribute5 IS NULL)))
      AND ((tlinfo.attribute6 = x_attribute6)
            OR ((tlinfo.attribute6 IS NULL)
                AND (x_attribute6 IS NULL)))
      AND ((tlinfo.attribute7 = x_attribute7)
            OR ((tlinfo.attribute7 IS NULL)
                AND (x_attribute7 IS NULL)))
      AND ((tlinfo.attribute8 = x_attribute8)
            OR ((tlinfo.attribute8 IS NULL)
                AND (x_attribute8 IS NULL)))
      AND ((tlinfo.attribute9 = x_attribute9)
            OR ((tlinfo.attribute9 IS NULL)
                AND (x_attribute9 IS NULL)))
      AND ((tlinfo.attribute10 = x_attribute10)
       OR ((tlinfo.attribute10 IS NULL)
                AND (x_attribute10 IS NULL)))
      AND ((tlinfo.attribute11 = x_attribute11)
            OR ((tlinfo.attribute11 IS NULL)
                AND (x_attribute11 IS NULL)))
      AND ((tlinfo.attribute12 = x_attribute12)
            OR ((tlinfo.attribute12 IS NULL)
                AND (x_attribute12 IS NULL)))
      AND ((tlinfo.attribute13 = x_attribute13)
            OR ((tlinfo.attribute13 IS NULL)
                AND (x_attribute13 IS NULL)))
     AND ((tlinfo.attribute14 = x_attribute14)
            OR ((tlinfo.attribute14 IS NULL)
                AND (x_attribute14 IS NULL)))
     AND ((tlinfo.attribute15 = x_attribute15)
            OR ((tlinfo.attribute15 IS NULL)
                AND (x_attribute15 IS NULL)))
     AND ((tlinfo.attribute16 = x_attribute16)
            OR ((tlinfo.attribute16 IS NULL)
                AND (x_attribute16 IS NULL)))
     AND ((tlinfo.attribute17 = x_attribute17)
            OR ((tlinfo.attribute17 IS NULL)
                AND (x_attribute17 IS NULL)))
     AND ((tlinfo.attribute18 = x_attribute18)
            OR ((tlinfo.attribute18 IS NULL)
                AND (x_attribute18 IS NULL)))
     AND ((tlinfo.attribute19 = x_attribute19)
            OR ((tlinfo.attribute19 IS NULL)
                AND (x_attribute19 IS NULL)))
     AND ((tlinfo.attribute20 = x_attribute20)
            OR ((tlinfo.attribute20 IS NULL)
                AND (x_attribute20 IS NULL)))
      AND ((tlinfo.min_cp_per_calendar = x_min_cp_per_calendar)
            OR ((tlinfo.min_cp_per_calendar IS NULL)
                AND (x_min_cp_per_calendar IS NULL)))
      AND ((tlinfo.rev_account_cd = x_rev_account_cd)
            OR ((tlinfo.rev_account_cd IS NULL)
                AND (x_rev_account_cd IS NULL)))
     AND ((tlinfo.primary_program_rank = x_primary_program_rank)
            OR ((tlinfo.primary_program_rank IS NULL)
                AND (x_primary_program_rank IS NULL)))
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
      app_exception.raise_exception;
    END IF;
    RETURN;
  END lock_row;

  PROCEDURE update_row (
  x_rowid IN VARCHAR2,
  x_course_cd IN VARCHAR2,
  x_version_number IN NUMBER,
  x_start_dt IN DATE,
  x_review_dt IN DATE,
  x_expiry_dt IN DATE,
  x_end_dt IN DATE,
  x_course_status IN VARCHAR2,
  x_title IN VARCHAR2,
  x_short_title IN VARCHAR2,
  x_abbreviation IN VARCHAR2,
  x_supp_exam_permitted_ind IN VARCHAR2,
  x_generic_course_ind IN VARCHAR2,
  x_graduate_students_ind IN VARCHAR2,
  x_count_intrmsn_in_time_ind IN VARCHAR2,
  x_intrmsn_allowed_ind IN VARCHAR2,
  x_course_type IN VARCHAR2,
  x_responsible_org_unit_cd IN VARCHAR2,
  x_responsible_ou_start_dt IN DATE,
  x_govt_special_course_type IN VARCHAR2,
  x_qualification_recency IN NUMBER,
  x_external_adv_stnd_limit IN NUMBER,
  x_internal_adv_stnd_limit IN NUMBER,
  x_contact_hours IN NUMBER,
  x_credit_points_required IN NUMBER,
  x_govt_course_load IN NUMBER,
  x_std_annual_load IN NUMBER,
  x_course_total_eftsu IN NUMBER,
  x_max_intrmsn_duration IN NUMBER,
  x_num_of_units_before_intrmsn IN NUMBER,
  x_min_sbmsn_percentage IN NUMBER,
  x_max_cp_per_teaching_period IN NUMBER,
  x_approval_date IN DATE,
  x_external_approval_date IN DATE,
  x_residency_cp_required IN NUMBER,
  x_state_financial_aid IN VARCHAR2,
  x_federal_financial_aid IN VARCHAR2,
  x_institutional_financial_aid IN VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  x_min_cp_per_calendar IN NUMBER,
  x_mode IN VARCHAR2,
  x_rev_account_cd IN VARCHAR2 ,
  x_primary_program_rank IN NUMBER,
  x_max_wlst_per_stud IN NUMBER,
  x_annual_instruction_time IN NUMBER
  ) AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur 18-Oct-2002  Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                        as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22 warning.
  smadathi    10-MAY-2001  Changed for New DLD Version
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  x_last_update_date DATE;
  x_last_updated_by NUMBER;
  x_last_update_login NUMBER;
  BEGIN
    x_last_update_date := SYSDATE;
    IF(x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login :=fnd_global.login_id;
      IF x_last_update_login IS NULL THEN
       x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml( p_action => 'UPDATE',
            x_rowid => x_rowid,
        x_course_cd => x_course_cd,
        x_version_number => x_version_number,
        x_start_dt => x_start_dt,
        x_review_dt => x_review_dt,
        x_expiry_dt => x_expiry_dt,
        x_end_dt => x_end_dt,
        x_course_status => x_course_status,
        x_title => x_title,
        x_short_title => x_short_title,
        x_abbreviation => x_abbreviation,
        x_supp_exam_permitted_ind => x_supp_exam_permitted_ind,
        x_generic_course_ind => x_generic_course_ind,
        x_graduate_students_ind => x_graduate_students_ind,
        x_count_intrmsn_in_time_ind => x_count_intrmsn_in_time_ind,
        x_intrmsn_allowed_ind => x_intrmsn_allowed_ind,
        x_course_type => x_course_type,
        x_responsible_org_unit_cd => x_responsible_org_unit_cd,
        x_responsible_ou_start_dt => x_responsible_ou_start_dt,
        x_govt_special_course_type => x_govt_special_course_type,
        x_qualification_recency => x_qualification_recency,
        x_external_adv_stnd_limit => x_external_adv_stnd_limit,
        x_internal_adv_stnd_limit => x_internal_adv_stnd_limit,
        x_contact_hours => x_contact_hours,
        x_credit_points_required => x_credit_points_required,
        x_govt_course_load => x_govt_course_load,
        x_std_annual_load => x_std_annual_load,
        x_course_total_eftsu => x_course_total_eftsu,
        x_max_intrmsn_duration => x_max_intrmsn_duration,
        x_num_of_units_before_intrmsn => x_num_of_units_before_intrmsn,
        x_min_sbmsn_percentage=>x_min_sbmsn_percentage,
        x_max_cp_per_teaching_period=>x_max_cp_per_teaching_period,
        x_approval_date=>x_approval_date,
        x_external_approval_date=>x_external_approval_date,
        x_residency_cp_required=>x_residency_cp_required,
        x_state_financial_aid=>x_state_financial_aid,
        x_federal_financial_aid=>x_federal_financial_aid,
        x_institutional_financial_aid=>x_institutional_financial_aid,
        x_attribute_category=>x_attribute_category,
        x_attribute1=>x_attribute1,
        x_attribute2=>x_attribute2,
        x_attribute3=>x_attribute3,
        x_attribute4=>x_attribute4,
        x_attribute5=>x_attribute5,
        x_attribute6=>x_attribute6,
        x_attribute7=>x_attribute7,
        x_attribute8=>x_attribute8,
        x_attribute9=>x_attribute9,
        x_attribute10=>x_attribute10,
        x_attribute11=>x_attribute11,
        x_attribute12=>x_attribute12,
        x_attribute13=>x_attribute13,
        x_attribute14=>x_attribute14,
        x_attribute15=>x_attribute15,
        x_attribute16=>x_attribute16,
        x_attribute17=>x_attribute17,
        x_attribute18=>x_attribute18,
        x_attribute19=>x_attribute19,
        x_attribute20=>x_attribute20,
        x_min_cp_per_calendar=>x_min_cp_per_calendar,
        x_creation_date => x_last_update_date,
        x_created_by => x_last_updated_by,
        x_last_update_date => x_last_update_date,
        x_last_updated_by => x_last_updated_by,
        x_last_update_login => x_last_update_login,
        x_rev_account_cd => x_rev_account_cd,
        x_primary_program_rank => x_primary_program_rank,
        x_max_wlst_per_stud => x_max_wlst_per_stud,
	x_annual_instruction_time => x_annual_instruction_time
    );
    UPDATE igs_ps_ver_all SET
        graduate_students_ind = new_references.graduate_students_ind,
        count_intrmsn_in_time_ind = new_references.count_intrmsn_in_time_ind,
        intrmsn_allowed_ind = new_references.intrmsn_allowed_ind,
        course_type = new_references.course_type,
        responsible_org_unit_cd = new_references.responsible_org_unit_cd,
        responsible_ou_start_dt = new_references.responsible_ou_start_dt,
        govt_special_course_type = new_references.govt_special_course_type,
        qualification_recency = new_references.qualification_recency,
        external_adv_stnd_limit = new_references.external_adv_stnd_limit,
        internal_adv_stnd_limit = new_references.internal_adv_stnd_limit,
        contact_hours = new_references.contact_hours,
        credit_points_required = new_references.credit_points_required,
        govt_course_load = new_references.govt_course_load,
        std_annual_load = new_references.std_annual_load,
        course_total_eftsu = new_references.course_total_eftsu,
        max_intrmsn_duration = new_references.max_intrmsn_duration,
        num_of_units_before_intrmsn = new_references.num_of_units_before_intrmsn,
        min_sbmsn_percentage = new_references.min_sbmsn_percentage,
        start_dt = new_references.start_dt,
        review_dt = new_references.review_dt,
        expiry_dt = new_references.expiry_dt,
        end_dt = new_references.end_dt,
        course_status = new_references.course_status,
        title = new_references.title,
        short_title = new_references.short_title,
        abbreviation = new_references.abbreviation,
        supp_exam_permitted_ind = new_references.supp_exam_permitted_ind,
        generic_course_ind = new_references.generic_course_ind,
        max_cp_per_teaching_period =  new_references.max_cp_per_teaching_period,
        approval_date =  new_references.approval_date,
        external_approval_date =  new_references.external_approval_date,
        residency_cp_required =  new_references.residency_cp_required,
        state_financial_aid =  new_references.state_financial_aid,
        federal_financial_aid =  new_references.federal_financial_aid,
        institutional_financial_aid =  new_references.institutional_financial_aid,
        attribute_category =  new_references.attribute_category,
        attribute1 =  new_references.attribute1,
        attribute2 =  new_references.attribute2,
        attribute3 =  new_references.attribute3,
        attribute4 =  new_references.attribute4,
        attribute5 =  new_references.attribute5,
        attribute6 =  new_references.attribute6,
        attribute7 =  new_references.attribute7,
        attribute8 =  new_references.attribute8,
        attribute9 =  new_references.attribute9,
        attribute10 =  new_references.attribute10,
        attribute11 =  new_references.attribute11,
        attribute12 =  new_references.attribute12,
        attribute13 =  new_references.attribute13,
        attribute14 =  new_references.attribute14,
        attribute15 =  new_references.attribute15,
        attribute16 =  new_references.attribute16,
        attribute17 =  new_references.attribute17,
        attribute18 =  new_references.attribute18,
        attribute19 =  new_references.attribute19,
        attribute20 =  new_references.attribute20,
        min_cp_per_calendar = new_references.min_cp_per_calendar,
        last_update_date = x_last_update_date,
        last_updated_by = x_last_updated_by,
        last_update_login = x_last_update_login,
        rev_account_cd = x_rev_account_cd,
        primary_program_rank = new_references.primary_program_rank,
        max_wlst_per_stud = new_references.max_wlst_per_stud,
	annual_instruction_time = new_references.annual_instruction_time

    WHERE ROWID = x_rowid
    ;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml(
    p_action => 'UPDATE',
     x_rowid => x_rowid
    );
  END update_row;

  PROCEDURE add_row (
  x_rowid IN OUT NOCOPY VARCHAR2,
  x_course_cd IN VARCHAR2,
  x_version_number IN NUMBER,
  x_start_dt IN DATE,
  x_review_dt IN DATE,
  x_expiry_dt IN DATE,
  x_end_dt IN DATE,
  x_course_status IN VARCHAR2,
  x_title IN VARCHAR2,
  x_short_title IN VARCHAR2,
  x_abbreviation IN VARCHAR2,
  x_supp_exam_permitted_ind IN VARCHAR2,
  x_generic_course_ind IN VARCHAR2,
  x_graduate_students_ind IN VARCHAR2,
  x_count_intrmsn_in_time_ind IN VARCHAR2,
  x_intrmsn_allowed_ind IN VARCHAR2,
  x_course_type IN VARCHAR2,
  x_responsible_org_unit_cd IN VARCHAR2,
  x_responsible_ou_start_dt IN DATE,
  x_govt_special_course_type IN VARCHAR2,
  x_qualification_recency IN NUMBER,
  x_external_adv_stnd_limit IN NUMBER,
  x_internal_adv_stnd_limit IN NUMBER,
  x_contact_hours IN NUMBER,
  x_credit_points_required IN NUMBER,
  x_govt_course_load IN NUMBER,
  x_std_annual_load IN NUMBER,
  x_course_total_eftsu IN NUMBER,
  x_max_intrmsn_duration IN NUMBER,
  x_num_of_units_before_intrmsn IN NUMBER,
  x_min_sbmsn_percentage IN NUMBER,
  x_max_cp_per_teaching_period IN NUMBER,
  x_approval_date IN DATE,
  x_external_approval_date IN DATE,
  x_residency_cp_required IN NUMBER,
  x_state_financial_aid IN VARCHAR2,
  x_federal_financial_aid IN VARCHAR2,
  x_institutional_financial_aid IN VARCHAR2,
  x_attribute_category IN VARCHAR2,
  x_attribute1 IN VARCHAR2,
  x_attribute2 IN VARCHAR2,
  x_attribute3 IN VARCHAR2,
  x_attribute4 IN VARCHAR2,
  x_attribute5 IN VARCHAR2,
  x_attribute6 IN VARCHAR2,
  x_attribute7 IN VARCHAR2,
  x_attribute8 IN VARCHAR2,
  x_attribute9 IN VARCHAR2,
  x_attribute10 IN VARCHAR2,
  x_attribute11 IN VARCHAR2,
  x_attribute12 IN VARCHAR2,
  x_attribute13 IN VARCHAR2,
  x_attribute14 IN VARCHAR2,
  x_attribute15 IN VARCHAR2,
  x_attribute16 IN VARCHAR2,
  x_attribute17 IN VARCHAR2,
  x_attribute18 IN VARCHAR2,
  x_attribute19 IN VARCHAR2,
  x_attribute20 IN VARCHAR2,
  x_min_cp_per_calendar IN NUMBER,
  x_mode IN VARCHAR2,
  x_org_id IN NUMBER,
  x_rev_account_cd IN VARCHAR2 ,
  x_primary_program_rank IN NUMBER,
  x_max_wlst_per_stud IN NUMBER,
  x_annual_instruction_time IN NUMBER
  )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  vvutukur 18-Oct-2002  Enh#2608227.Removed references to std_ft_completion_time,std_pt_completion_time,
                        as these columns are obsolete.Also removed DEFAULT keyword to avoid gscc File.Pkg.22 warning.
  smadathi    10-MAY-2001  Changed for New DLD Version
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  CURSOR c1 IS SELECT ROWID FROM igs_ps_ver_all
     WHERE course_cd = x_course_cd
     AND version_number = x_version_number ;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
      x_rowid,
      x_course_cd,
      x_version_number,
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
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_govt_special_course_type,
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
      x_max_cp_per_teaching_period,
      x_approval_date,
      x_external_approval_date,
      x_residency_cp_required,
      x_state_financial_aid,
      x_federal_financial_aid,
      x_institutional_financial_aid,
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
      x_min_cp_per_calendar,
      x_mode,
      x_org_id,
      x_rev_account_cd,
      x_primary_program_rank,
      x_max_wlst_per_stud,
      x_annual_instruction_time);
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_course_cd,
      x_version_number,
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
      x_responsible_org_unit_cd,
      x_responsible_ou_start_dt,
      x_govt_special_course_type,
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
      x_max_cp_per_teaching_period,
      x_approval_date,
      x_external_approval_date,
      x_residency_cp_required,
      x_state_financial_aid,
      x_federal_financial_aid,
      x_institutional_financial_aid,
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
      x_min_cp_per_calendar,
      x_mode,
      x_rev_account_cd,
      x_primary_program_rank,
      x_max_wlst_per_stud,
      x_annual_instruction_time
    );
  END add_row;

  PROCEDURE delete_row (
  x_rowid IN VARCHAR2
  )  AS
  /************************************************************************
  Created By                                :
  Date Created By                           :
  Purpose                                   :
  Known limitations, enhancements or remarks:
  Change History                            :
  Who          When          What
  sbeerell    10-MAY-2000  Changed for new DLD version 2
  (reverse chronological order - newest change first)
  *************************************************************************/
  BEGIN
    before_dml( p_action => 'DELETE',
      x_rowid => x_rowid
    );
    DELETE FROM igs_ps_ver_all
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    after_dml(
  p_action => 'DELETE',
  x_rowid => x_rowid
  );
END delete_row;
END igs_ps_ver_pkg;

/
