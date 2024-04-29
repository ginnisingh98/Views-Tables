--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_LGCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_LGCY_PKG" AS
/* $Header: IGSPS85B.pls 120.15 2006/08/02 11:47:44 sommukhe ship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Shirish Tatiko, Saravana Kumar
    Date Created By:  11-NOV-2002
    Purpose        :  This package has the 8 sub processes, which will be called from
                      PSP Unit API.
                      process 1 : create_unit_version
                                    Imports Unit Version and its associated Subtitle and Curriculum
                      process 2 : create_teach_resp
                                    Imports Teaching Reponsibility.
                      process 3 : create_unit_discip
                                    Imports Unit Discipline.
                      process 4 : create_unit_grd_sch
                                    Imports Unit Grading Schema.
                                : validate_unit_dtls
                                     Validations performed across different sub process at unil level.
                      process 5 : create_unit_section
                                    Imports Unit Section and its associated Credits Point and Referrence
                      process 6 : create_usec_grd_sch
                                    Imports Unit Section Grading Schema
                      process 7 : create_usec_occur
                                    Imports Unit Section Occurrence
                      process 8 : create_unit_ref_code
                                    Imports Unit / Unit Section / Unit Section Occurrence Referrences
                     process 9 : create_uso_ins
                                    Imports Unit Section Occurrence instructors and creates unit
                                    section teaching responsibilites record if current instructor
                                    getting imported does not already exists.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    27-SEP-2005     BUG #4632652.FND logging included.
    smvk        28-Jul-2004     Bug # 3793580. Allowing the user to import instructors for No Set Day USO.
                                Coded to call procedure get_uso_id to get USO ID. Removed cursors used to derive USO id.
    smvk        07-Nov-2003     Bug # 3138353. Added new procedure validate_unit_dtls to do unit level cross subprocesses validation.
    smvk        10-Oct-2003     Bug # 3052445. Modified the signature of igs_ps_validate_lgcy_pkg.validate_waitlist_allowed without org unit code.
    smvk        23-Sep-2003     Bug # 3121311, Removed the call to procedures uso_effective_dates and validate_instructor.
    sarakshi    02-sep-2003     Enh#3052452,removed the reference of the column sup_unit_allowed_ind and sub_unit_allowed_ind
    vvutukur    05-Aug-2003     Enh#3045069.PSP Enh Build. Modified trim_values,create_uoo,validate_uoo_db_cons,
                                validate_derivations,validate_db_cons.
    smvk        27-Jun-2003     Enh Bug # 2999888. Modified unit reference code process for importing
                                Unit requirements / Unit Sectin requirements reference codes.
    smvk        25-jun-2003     Enh bug#2918094. Modified create_usec_occur process to add a column cancel_flag.
    jbegum      02-June-2003    Bug # 2972950.
                                For the Legacy Enhancements TD:
                                Created Sub process create_uso_ins and Sub process create_usec_el as mentioned in TD.
                                Modified the code to use messages rather than lookup codes mentioned in TD, due to
                                Non Backward compatible changes in igslkups.ldt.
  ********************************************************************************************** */

  g_n_user_id igs_ps_unit_ver_all.created_by%TYPE := NVL(fnd_global.user_id,-1);          -- Stores the User Id
  g_n_login_id igs_ps_unit_ver_all.last_update_login%TYPE := NVL(fnd_global.login_id,-1); -- Stores the Login Id
  TYPE uso_tbl_type IS TABLE OF igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE INDEX BY BINARY_INTEGER;
  l_tbl_uso uso_tbl_type;



  PROCEDURE create_unit_version(p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type,
                                p_rec_status   OUT NOCOPY    VARCHAR2) AS
  /***********************************************************************************************

  Created By:         sarakshi
  Date Created By:    11-Nov-2002
  Purpose:            This procedure imports unit version data.

  Known limitations,enhancements,remarks:

  Change History

  Who       When         What

  sarakshi  04-May-2004  Enh#3568858,columns ovrd_wkld_val_flag, workload_val_code has been trimed and also included in  the insert statement.
  sarakshi  10-Nov-2003  Enh#3116171, added logic related to the newly introduced field BILLING_CREDIT_POINTS, modified trim values procedure and insert_row
  ***********************************************************************************************/

    CURSOR cur_check (cp_unit_cd igs_ps_unit.unit_cd%TYPE) IS
    SELECT 'X'
    FROM   igs_ps_unit
    WHERE  unit_cd=cp_unit_cd;
    l_c_var  VARCHAR2(1);

    l_n_coord_person_id             igs_ps_unit_ver_all.coord_person_id%TYPE;
    l_d_owner_ou_start_dt           igs_ps_unit_ver_all.owner_ou_start_dt%TYPE;
    l_n_subtitle_id                 igs_ps_unit_ver_all.subtitle_id%TYPE;
    l_n_rpt_fmly_id                 igs_ps_rpt_fmly.rpt_fmly_id%TYPE;
    l_n_unit_type_id                igs_ps_unit_type_lvl.unit_type_id%TYPE;
    l_c_cal_type_enrol_load_cal     igs_ps_unit_ver_all.cal_type_enrol_load_cal%TYPE;
    l_n_seq_num_enrol_load_cal igs_ps_unit_ver_all.sequence_num_enrol_load_cal%TYPE;
    l_c_cal_type_offer_load_cal     igs_ps_unit_ver_all.cal_type_offer_load_cal%TYPE;
    l_n_seq_num_offer_load_cal igs_ps_unit_ver_all.sequence_num_offer_load_cal%TYPE;

    PROCEDURE trim_values (p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type) AS
    BEGIN
              p_unit_ver_rec.unit_cd := TRIM(p_unit_ver_rec.unit_cd);
              p_unit_ver_rec.version_number := TRIM(p_unit_ver_rec.version_number);
              p_unit_ver_rec.start_dt := TRUNC(p_unit_ver_rec.start_dt);
              p_unit_ver_rec.review_dt  := TRUNC(p_unit_ver_rec.review_dt);
              p_unit_ver_rec.expiry_dt  := TRUNC(p_unit_ver_rec.expiry_dt);
              p_unit_ver_rec.end_dt  := TRUNC(p_unit_ver_rec.end_dt);
              p_unit_ver_rec.unit_status := TRIM(p_unit_ver_rec.unit_status);
              p_unit_ver_rec.title := TRIM(p_unit_ver_rec.title);
              p_unit_ver_rec.short_title := TRIM(p_unit_ver_rec.short_title);
              p_unit_ver_rec.title_override_ind  := TRIM(p_unit_ver_rec.title_override_ind);
              p_unit_ver_rec.abbreviation  := TRIM(p_unit_ver_rec.abbreviation);
              p_unit_ver_rec.unit_level := TRIM(p_unit_ver_rec.unit_level);
              p_unit_ver_rec.credit_point_descriptor := TRIM(p_unit_ver_rec.credit_point_descriptor);
              p_unit_ver_rec.enrolled_credit_points := TRIM(p_unit_ver_rec.enrolled_credit_points);
              p_unit_ver_rec.points_override_ind := TRIM(p_unit_ver_rec.points_override_ind);
              p_unit_ver_rec.supp_exam_permitted_ind := TRIM(p_unit_ver_rec.supp_exam_permitted_ind);
              p_unit_ver_rec.coord_person_number := TRIM(p_unit_ver_rec.coord_person_number);
              p_unit_ver_rec.owner_org_unit_cd := TRIM(p_unit_ver_rec.owner_org_unit_cd);
              p_unit_ver_rec.award_course_only_ind := TRIM(p_unit_ver_rec.award_course_only_ind);
              p_unit_ver_rec.research_unit_ind := TRIM(p_unit_ver_rec.research_unit_ind);
              p_unit_ver_rec.industrial_ind := TRIM(p_unit_ver_rec.industrial_ind);
              p_unit_ver_rec.practical_ind := TRIM(p_unit_ver_rec.practical_ind);
              p_unit_ver_rec.repeatable_ind := TRIM(p_unit_ver_rec.repeatable_ind);
              p_unit_ver_rec.assessable_ind := TRIM(p_unit_ver_rec.assessable_ind);
              p_unit_ver_rec.achievable_credit_points  := TRIM(p_unit_ver_rec.achievable_credit_points);
              p_unit_ver_rec.points_increment := TRIM(p_unit_ver_rec.points_increment);
              p_unit_ver_rec.points_min := TRIM(p_unit_ver_rec.points_min);
              p_unit_ver_rec.points_max := TRIM(p_unit_ver_rec.points_max);
              p_unit_ver_rec.unit_int_course_level_cd  := TRIM(p_unit_ver_rec.unit_int_course_level_cd);
              p_unit_ver_rec.subtitle_modifiable_flag  := TRIM(p_unit_ver_rec.subtitle_modifiable_flag);
              p_unit_ver_rec.approval_date := TRUNC(p_unit_ver_rec.approval_date);
              p_unit_ver_rec.lecture_credit_points  := TRIM(p_unit_ver_rec.lecture_credit_points);
              p_unit_ver_rec.lab_credit_points := TRIM(p_unit_ver_rec.lab_credit_points);
              p_unit_ver_rec.other_credit_points := TRIM(p_unit_ver_rec.other_credit_points);
              p_unit_ver_rec.clock_hours := TRIM(p_unit_ver_rec.clock_hours);
              p_unit_ver_rec.work_load_cp_lecture := TRIM(p_unit_ver_rec.work_load_cp_lecture);
              p_unit_ver_rec.work_load_cp_lab := TRIM(p_unit_ver_rec.work_load_cp_lab);
              p_unit_ver_rec.continuing_education_units := TRIM(p_unit_ver_rec.continuing_education_units);
              p_unit_ver_rec.enrollment_expected := TRIM(p_unit_ver_rec.enrollment_expected);
              p_unit_ver_rec.enrollment_minimum  := TRIM(p_unit_ver_rec.enrollment_minimum);
              p_unit_ver_rec.enrollment_maximum  := TRIM(p_unit_ver_rec.enrollment_maximum);
              p_unit_ver_rec.advance_maximum  := TRIM(p_unit_ver_rec.advance_maximum);
              p_unit_ver_rec.state_financial_aid := TRIM(p_unit_ver_rec.state_financial_aid);
              p_unit_ver_rec.federal_financial_aid  := TRIM(p_unit_ver_rec.federal_financial_aid);
              p_unit_ver_rec.institutional_financial_aid  := TRIM(p_unit_ver_rec.institutional_financial_aid);
              p_unit_ver_rec.same_teaching_period := TRIM(p_unit_ver_rec.same_teaching_period);
              p_unit_ver_rec.max_repeats_for_credit := TRIM(p_unit_ver_rec.max_repeats_for_credit);
              p_unit_ver_rec.max_repeats_for_funding := TRIM(p_unit_ver_rec.max_repeats_for_funding);
              p_unit_ver_rec.max_repeat_credit_points  := TRIM(p_unit_ver_rec.max_repeat_credit_points);
              p_unit_ver_rec.same_teach_period_repeats := TRIM(p_unit_ver_rec.same_teach_period_repeats);
              p_unit_ver_rec.same_teach_period_repeats_cp := TRIM(p_unit_ver_rec.same_teach_period_repeats_cp);
              p_unit_ver_rec.attribute_category  := TRIM(p_unit_ver_rec.attribute_category);
              p_unit_ver_rec.attribute1 := TRIM(p_unit_ver_rec.attribute1);
              p_unit_ver_rec.attribute2 := TRIM(p_unit_ver_rec.attribute2);
              p_unit_ver_rec.attribute3 := TRIM(p_unit_ver_rec.attribute3);
              p_unit_ver_rec.attribute4 := TRIM(p_unit_ver_rec.attribute4);
              p_unit_ver_rec.attribute5 := TRIM(p_unit_ver_rec.attribute5);
              p_unit_ver_rec.attribute6 := TRIM(p_unit_ver_rec.attribute6);
              p_unit_ver_rec.attribute7 := TRIM(p_unit_ver_rec.attribute7);
              p_unit_ver_rec.attribute8 := TRIM(p_unit_ver_rec.attribute8);
              p_unit_ver_rec.attribute9 := TRIM(p_unit_ver_rec.attribute9);
              p_unit_ver_rec.attribute10 := TRIM(p_unit_ver_rec.attribute10);
              p_unit_ver_rec.attribute11 := TRIM(p_unit_ver_rec.attribute11);
              p_unit_ver_rec.attribute12 := TRIM(p_unit_ver_rec.attribute12);
              p_unit_ver_rec.attribute13 := TRIM(p_unit_ver_rec.attribute13);
              p_unit_ver_rec.attribute14 := TRIM(p_unit_ver_rec.attribute14);
              p_unit_ver_rec.attribute15 := TRIM(p_unit_ver_rec.attribute15);
              p_unit_ver_rec.attribute16 := TRIM(p_unit_ver_rec.attribute16);
              p_unit_ver_rec.attribute17 := TRIM(p_unit_ver_rec.attribute17);
              p_unit_ver_rec.attribute18 := TRIM(p_unit_ver_rec.attribute18);
              p_unit_ver_rec.attribute19 := TRIM(p_unit_ver_rec.attribute19);
              p_unit_ver_rec.attribute20 := TRIM(p_unit_ver_rec.attribute20);
              p_unit_ver_rec.ivr_enrol_ind := TRIM(p_unit_ver_rec.ivr_enrol_ind);
              p_unit_ver_rec.ss_enrol_ind  := TRIM(p_unit_ver_rec.ss_enrol_ind);
              p_unit_ver_rec.work_load_other  := TRIM(p_unit_ver_rec.work_load_other);
              p_unit_ver_rec.contact_hrs_lecture := TRIM(p_unit_ver_rec.contact_hrs_lecture);
              p_unit_ver_rec.contact_hrs_lab  := TRIM(p_unit_ver_rec.contact_hrs_lab);
              p_unit_ver_rec.contact_hrs_other := TRIM(p_unit_ver_rec.contact_hrs_other);
              p_unit_ver_rec.non_schd_required_hrs  := TRIM(p_unit_ver_rec.non_schd_required_hrs);
              p_unit_ver_rec.exclude_from_max_cp_limit := TRIM(p_unit_ver_rec.exclude_from_max_cp_limit);
              p_unit_ver_rec.record_exclusion_flag  := TRIM(p_unit_ver_rec.record_exclusion_flag);
              p_unit_ver_rec.ss_display_ind := TRIM(p_unit_ver_rec.ss_display_ind);
              p_unit_ver_rec.enrol_load_alt_cd := TRIM(p_unit_ver_rec.enrol_load_alt_cd);
              p_unit_ver_rec.offer_load_alt_cd := TRIM(p_unit_ver_rec.offer_load_alt_cd);
              p_unit_ver_rec.override_enrollment_max := TRIM(p_unit_ver_rec.override_enrollment_max);
              p_unit_ver_rec.repeat_code := TRIM(p_unit_ver_rec.repeat_code);
              p_unit_ver_rec.level_code := TRIM(p_unit_ver_rec.level_code);
              p_unit_ver_rec.special_permission_ind := TRIM(p_unit_ver_rec.special_permission_ind);
              p_unit_ver_rec.rev_account_cd := TRIM(p_unit_ver_rec.rev_account_cd);
              p_unit_ver_rec.claimable_hours  := TRIM(p_unit_ver_rec.claimable_hours);
              p_unit_ver_rec.anon_unit_grading_ind  := TRIM(p_unit_ver_rec.anon_unit_grading_ind);
              p_unit_ver_rec.anon_assess_grading_ind := TRIM(p_unit_ver_rec.anon_assess_grading_ind);
              p_unit_ver_rec.subtitle := TRIM(p_unit_ver_rec.subtitle);
              p_unit_ver_rec.subtitle_approved_ind  := TRIM(p_unit_ver_rec.subtitle_approved_ind);
              p_unit_ver_rec.subtitle_closed_ind := TRIM(p_unit_ver_rec.subtitle_closed_ind);
              p_unit_ver_rec.curriculum_id := TRIM(p_unit_ver_rec.curriculum_id);
              p_unit_ver_rec.curriculum_description := TRIM(p_unit_ver_rec.curriculum_description);
              p_unit_ver_rec.curriculum_closed_ind  := TRIM(p_unit_ver_rec.curriculum_closed_ind);
              p_unit_ver_rec.auditable_ind := TRIM(p_unit_ver_rec.auditable_ind);
              p_unit_ver_rec.audit_permission_ind := TRIM(p_unit_ver_rec.audit_permission_ind);
              p_unit_ver_rec.max_auditors_allowed := TRIM(p_unit_ver_rec.max_auditors_allowed);
	      p_unit_ver_rec.billing_credit_points := TRIM(p_unit_ver_rec.billing_credit_points);
              p_unit_ver_rec.ovrd_wkld_val_flag := TRIM(p_unit_ver_rec.ovrd_wkld_val_flag);
              p_unit_ver_rec.workload_val_code := TRIM(p_unit_ver_rec.workload_val_code);
	      p_unit_ver_rec.billing_hrs := TRIM(p_unit_ver_rec.billing_hrs);
    END trim_values ;

    PROCEDURE validate_parameters(p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type) AS
    /***********************************************************************************************

    Created By:         sarakshi
    Date Created By:    11-Nov-2002
    Purpose:            This procedure validates the parameters for the unit version record passed.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    sarakshi  12-dec-2002  MAndatory check for level code is added as a part of bug#2702240
    ***********************************************************************************************/

    BEGIN
      p_unit_ver_rec.status:='S';

      --Validate all mandatory parameter,which are required for subprocess to continue

      IF p_unit_ver_rec.unit_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.version_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.start_dt IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_START_DATE','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.unit_status IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_STATUS','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.title IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TITLE','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.short_title IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','SHORT_TITLE','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.credit_point_descriptor IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','CREDIT_POINT_DESCRIPTOR','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.enrolled_credit_points IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','ENROL_CREDIT_PTS','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.unit_level IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_LEVEL','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.coord_person_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','CORD_PERSON_NUM','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.owner_org_unit_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','OWNER_ORG_UNIT_CD','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.curriculum_id IS NULL AND
        p_unit_ver_rec.curriculum_description IS NOT NULL AND
        FND_PROFILE.VALUE('IGS_PS_CURRICULUM_ID')= 'Y'  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','CURRICULUM_ID','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      --This validation is added as a part of bug#2702240
      IF p_unit_ver_rec.level_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','LEVEL_CODE','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

    END validate_parameters;


    PROCEDURE validate_derivations(p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type) AS
    /***********************************************************************************************

    Created By:         sarakshi
    Date Created By:    11-Nov-2002
    Purpose:            This procedure derives the values of certain fields that are compatible to OSS.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    sarakshi  04-May-2004  Enh#3568858,Added validation related to ovrd_wkld_val_flag
    vvutukur  10-Aug-2003  Enh#3045069.PSP Enh Build.Assigned initial value 'X' for repeatable_ind instead of 'N'.
    sarakshi  11-Dec-2002  Bug#2702240,derived values for state_financail_aid,federal_financial_aid,
                           institutional_financial_aid,same_teaching_period,exclude_from_cp_limit,
                           record_exclusion_flag,ss_display_ind,special_permission_ind
    smvk      26-Dec-2002  Bug # 2721495. Calling the procedure igs_ps_validate_lgcy_pkg.get_party_id
                           instead of function igs_ge_gen_003.get_person_id to derive the person id.
    ***********************************************************************************************/
    CURSOR c_unit_lvl(cp_level_code igs_ps_unit_type_lvl.level_code%TYPE) IS
    SELECT unit_type_id
    FROM   igs_ps_unit_type_lvl
    WHERE  level_code=cp_level_code;

    CURSOR c_repeat_code(cp_repeat_code igs_ps_rpt_fmly.repeat_code%TYPE) IS
    SELECT rpt_fmly_id
    FROM   igs_ps_rpt_fmly
    WHERE  repeat_code=cp_repeat_code;

    CURSOR  c_curriculum_seq_num IS
    SELECT  igs_ps_unt_crclm_all_s.NEXTVAL
    FROM    DUAL;


    l_d_start_date   DATE;
    l_d_end_date     DATE;
    l_b_ret_status   VARCHAR2(100);
    BEGIN
      IF p_unit_ver_rec.title_override_ind IS NULL THEN
         p_unit_ver_rec.title_override_ind :='N';
      END IF;

      IF p_unit_ver_rec.abbreviation IS NULL THEN
         p_unit_ver_rec.abbreviation :=UPPER(SUBSTR(p_unit_ver_rec.title,1,20));
      END IF;

      IF p_unit_ver_rec.points_override_ind IS NULL THEN
         p_unit_ver_rec.points_override_ind :='N';
      END IF;

      IF p_unit_ver_rec.supp_exam_permitted_ind IS NULL THEN
         p_unit_ver_rec.supp_exam_permitted_ind :='N';
      END IF;

      IF p_unit_ver_rec.award_course_only_ind IS NULL THEN
         p_unit_ver_rec.award_course_only_ind :='N';
      END IF;

      IF p_unit_ver_rec.research_unit_ind IS NULL THEN
         p_unit_ver_rec.research_unit_ind :='N';
      END IF;

      IF p_unit_ver_rec.industrial_ind IS NULL THEN
         p_unit_ver_rec.industrial_ind :='N';
      END IF;

      IF p_unit_ver_rec.practical_ind IS NULL THEN
         p_unit_ver_rec.practical_ind :='N';
      END IF;

      IF p_unit_ver_rec.repeatable_ind IS NULL THEN
         p_unit_ver_rec.repeatable_ind :='X';
      END IF;

      IF p_unit_ver_rec.assessable_ind IS NULL THEN
         p_unit_ver_rec.assessable_ind :='N';
      END IF;

      IF p_unit_ver_rec.ivr_enrol_ind IS NULL THEN
         p_unit_ver_rec.ivr_enrol_ind :='N';
      END IF;

      IF p_unit_ver_rec.ss_enrol_ind IS NULL THEN
         p_unit_ver_rec.ss_enrol_ind :='N';
      END IF;

      IF p_unit_ver_rec.anon_unit_grading_ind IS NULL THEN
         p_unit_ver_rec.anon_unit_grading_ind :='N';
      END IF;

      IF p_unit_ver_rec.anon_assess_grading_ind IS NULL THEN
         p_unit_ver_rec.anon_assess_grading_ind :='N';
      END IF;

      IF p_unit_ver_rec.subtitle_approved_ind IS NULL THEN
         p_unit_ver_rec.subtitle_approved_ind :='N';
      END IF;

      IF p_unit_ver_rec.subtitle_closed_ind IS NULL THEN
         p_unit_ver_rec.subtitle_closed_ind :='N';
      END IF;

      IF p_unit_ver_rec.curriculum_closed_ind IS NULL THEN
         p_unit_ver_rec.curriculum_closed_ind :='N';
      END IF;

      IF p_unit_ver_rec.auditable_ind IS NULL THEN
         p_unit_ver_rec.auditable_ind :='N';
      END IF;

      IF p_unit_ver_rec.audit_permission_ind IS NULL THEN
         p_unit_ver_rec.audit_permission_ind :='N';
      END IF;



      --Following defaulting are done as a part of bug#2702240

      IF p_unit_ver_rec.state_financial_aid IS NULL THEN
         p_unit_ver_rec.state_financial_aid :='N';
      END IF;

      IF p_unit_ver_rec.federal_financial_aid IS NULL THEN
         p_unit_ver_rec.federal_financial_aid :='N';
      END IF;

      IF p_unit_ver_rec.institutional_financial_aid IS NULL THEN
         p_unit_ver_rec.institutional_financial_aid :='N';
      END IF;

      IF p_unit_ver_rec.same_teaching_period IS NULL THEN
         p_unit_ver_rec.same_teaching_period :='N';
      END IF;

      IF p_unit_ver_rec.exclude_from_max_cp_limit IS NULL THEN
         p_unit_ver_rec.exclude_from_max_cp_limit :='N';
      END IF;

      IF p_unit_ver_rec.record_exclusion_flag IS NULL THEN
         p_unit_ver_rec.record_exclusion_flag :='N';
      END IF;

      IF p_unit_ver_rec.ss_display_ind IS NULL THEN
         p_unit_ver_rec.ss_display_ind :='N';
      END IF;

      IF p_unit_ver_rec.special_permission_ind IS NULL THEN
         p_unit_ver_rec.special_permission_ind :='N';
      END IF;

      -------------------------------------------------------

      IF p_unit_ver_rec.review_dt IS NULL THEN
         p_unit_ver_rec.review_dt := p_unit_ver_rec.start_dt;
      END IF;

      OPEN c_unit_lvl(p_unit_ver_rec.level_code);
      FETCH c_unit_lvl INTO l_n_unit_type_id;
      CLOSE c_unit_lvl;

      OPEN c_repeat_code(p_unit_ver_rec.repeat_code);
      FETCH c_repeat_code INTO l_n_rpt_fmly_id;
      CLOSE c_repeat_code;

      igs_ps_validate_lgcy_pkg.get_party_id(p_unit_ver_rec.coord_person_number,l_n_coord_person_id);
      IF l_n_coord_person_id IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','CORD_PERSON_NUM','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      --derive cal type and seq number for enrol load alternate code
      IF p_unit_ver_rec.enrol_load_alt_cd IS NOT NULL THEN
        igs_ge_gen_003.get_calendar_instance(p_unit_ver_rec.enrol_load_alt_cd,
                                             NULL,
                                             l_c_cal_type_enrol_load_cal,
                                             l_n_seq_num_enrol_load_cal,
                                             l_d_start_date,
                                             l_d_end_date,
                                             l_b_ret_status);
        IF l_b_ret_status <> 'SINGLE' THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','ENROL_ALT_CODE','LEGACY_TOKENS',FALSE);
          p_unit_ver_rec.status:='E';
        END IF;
      END IF;

      --derive cal type and seq number for offer load alternate code
      IF p_unit_ver_rec.offer_load_alt_cd IS NOT NULL THEN
        igs_ge_gen_003.get_calendar_instance(p_unit_ver_rec.offer_load_alt_cd,
                                             NULL,
                                             l_c_cal_type_offer_load_cal,
                                             l_n_seq_num_offer_load_cal,
                                             l_d_start_date,
                                             l_d_end_date,
                                             l_b_ret_status);
        IF l_b_ret_status <> 'SINGLE' THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','OFFER_ALT_CODE','LEGACY_TOKENS',FALSE);
          p_unit_ver_rec.status:='E';
        END IF;
      END IF;

      --Derive the owner org unit start date
      IF NOT igs_re_val_rsup.get_org_unit_dtls(p_unit_ver_rec.owner_org_unit_cd,l_d_owner_ou_start_dt) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','OWNER_ORG_UNIT_CD','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;


      IF FND_PROFILE.VALUE('IGS_PS_CURRICULUM_ID')= 'N'  AND
        p_unit_ver_rec.curriculum_description IS NOT NULL THEN

        OPEN c_curriculum_seq_num;
        FETCH c_curriculum_seq_num INTO p_unit_ver_rec.curriculum_id;
        CLOSE c_curriculum_seq_num;
      END IF;

      IF p_unit_ver_rec.subtitle IS NOT NULL THEN
        p_unit_ver_rec.subtitle_modifiable_flag := 'Y';
      ELSE
        p_unit_ver_rec.subtitle_modifiable_flag :='N';
      END IF;

      IF p_unit_ver_rec.ovrd_wkld_val_flag IS NULL THEN
        p_unit_ver_rec.ovrd_wkld_val_flag :='N';
      END IF;


    END validate_derivations;

    PROCEDURE validate_db_cons(p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type) AS
    /***********************************************************************************************

    Created By:         sarakshi
    Date Created By:    12-Nov-2002
    Purpose:            This procedure validates database constraints.

    Known limitations,enhancements,remarks:

    Change History

    Who       When         What
    sarakshi  15-May-2006  Bug#3064563, modified the format mask(clock_hours,continuing_education_units,work_load_cp_lecture,work_load_cp_lab,contact_hrs_lab) as specified in the bug.
    sarakshi  04-May-2004  Enh#3568858,Added validation related to columns ovrd_wkld_val_flag, workload_val_code
    sarakshi  07-Nov-2003  Enh#3116171, added logic related to the newly introduced field BILLING_CREDIT_POINTS, check_constraint
    vvutukur  19-Aug-2003  Enh#3045069.PSP Enh Build. Incorporated review comments.
    smvk      09-Jan-2003  Bug # 2702263, Checking the range of values for columns claimable_hours,lecture_credit_points,
                           lab_credit_points,other_credit_points,clock_hours,continuing_education_units,
                           advance_maximum,enrollment_expected,enrollment_minimum,enrollment_maximum,
                           override_enrollment_max,max_auditors_allowed,work_load_cp_lecture,work_load_cp_lab,
                           max_repeat_credit_points,same_teach_period_repeats_cp,work_load_other,contact_hrs_lecture,
                           contact_hrs_lab,contact_hrs_other,non_schd_required_hrs,max_repeats_for_credit,
                           max_repeats_for_funding and same_teach_period_repeats.
    sarakshi  11-Dec-2002  Bug#2702240,checking values for state_financial_aid,federal_financial_aid,
                           institutional_financial_aid,same_teaching_period,exclude_from_cp_limit,
                           record_exclusion_flag,ss_display_ind,special_permission_ind,IVR_enrol_ind,
                           ss_enrol_ind,anon_unit_grading_ind,anon_assess_grading_ind,auditable_ind,
                           audit_permission_ind
    smvk      20-Dec-2002  Removed the IGS_PS_UNIT_VER_PKG.check_constraints call of owner_org_unit_cd.
                           As owner org unit code can have value in mixed case. Bug 2487149.
    ***********************************************************************************************/

    CURSOR  cur_credit_point_des(cp_credit_point_descriptor igs_lookup_values.lookup_code%TYPE) IS
    SELECT 'X'
    FROM   igs_lookup_values
    WHERE  lookup_type='CREDIT_POINT_DSCR'
    AND    lookup_code=cp_credit_point_descriptor;
    l_var  VARCHAR2(1);

    BEGIN
      --Check for Pk validations
      IF igs_ps_unit_ver_pkg.get_pk_for_validation(p_unit_ver_rec.unit_cd,
                                                        p_unit_ver_rec.version_number) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS','UNIT_VERSION','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='W';
        RETURN;
      END IF;

      IF FND_PROFILE.VALUE('IGS_PS_CURRICULUM_ID')= 'Y'  AND p_unit_ver_rec.curriculum_description IS NOT NULL THEN
        IF igs_ps_unt_crclm_pkg.get_pk_for_validation(p_unit_ver_rec.curriculum_id) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS','CURRICULUM_ID','LEGACY_TOKENS',FALSE);
          p_unit_ver_rec.status:='W';
          RETURN;
        END IF;
      END IF;

      --Check UK for validations
      IF igs_ps_unit_subtitle_pkg.get_uk_for_validation(p_unit_ver_rec.unit_cd,
                                                        p_unit_ver_rec.version_number,
                                                        p_unit_ver_rec.subtitle) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS','SUBTITLE','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='W';
        RETURN;
      END IF;

      --Check constraint
      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('UNIT_CD',p_unit_ver_rec.unit_cd);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_CD','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('ABBREVIATION',p_unit_ver_rec.abbreviation);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','ABBREVIATION','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('ASSESSABLE_IND',p_unit_ver_rec.assessable_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','ASSESSABLE_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('AWARD_COURSE_ONLY_IND',p_unit_ver_rec.award_course_only_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','AWARD_COURSE_ONLY_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('CREDIT_POINT_DESCRIPTOR',p_unit_ver_rec.credit_point_descriptor);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','CREDIT_POINT_DESCRIPTOR','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('INDUSTRIAL_IND',p_unit_ver_rec.industrial_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','INDUSTRIAL_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('POINTS_OVERRIDE_IND',p_unit_ver_rec.points_override_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','POINTS_OVERRIDE_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('PRACTICAL_IND',p_unit_ver_rec.practical_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','PRACTICAL_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('REPEATABLE_IND',p_unit_ver_rec.repeatable_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','REPEATABLE_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('RESEARCH_UNIT_IND',p_unit_ver_rec.research_unit_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','RESEARCH_UNIT_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('SUPP_EXAM_PERMITTED_IND',p_unit_ver_rec.supp_exam_permitted_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SUPP_EXAM_PERMITTED_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('TITLE_OVERRIDE_IND',p_unit_ver_rec.title_override_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','TITLE_OVERRIDE_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      -----------------------------------Following checks are done as a part of bug#2702240---------------

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('STATE_FINANCIAL_AID',p_unit_ver_rec.state_financial_aid);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','STATE_FINANCIAL_AID','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('FEDERAL_FINANCIAL_AID',p_unit_ver_rec.federal_financial_aid);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','FEDERAL_FINANCIAL_AID','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('INSTITUTIONAL_FINANCIAL_AID',p_unit_ver_rec.institutional_financial_aid);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','INSTITUTIONAL_FINANCIAL_AID','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('SAME_TEACHING_PERIOD',p_unit_ver_rec.same_teaching_period);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SAME_TEACHING_PERIOD','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('EXCLUDE_FROM_MAX_CP_LIMIT',p_unit_ver_rec.exclude_from_max_cp_limit);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','EXCLUDE_FROM_MAX_CP_LIMIT','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('RECORD_EXCLUSION_FLAG',p_unit_ver_rec.record_exclusion_flag);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','RECORD_EXCLUSION_FLAG','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('SS_DISPLAY_IND',p_unit_ver_rec.ss_display_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SS_DISPLAY_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('SPECIAL_PERMISSION_IND',p_unit_ver_rec.special_permission_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SPECIAL_PERMISSION_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      --should not call the TBH chcek constraint as some other validation are also there
      IF  p_unit_ver_rec.ivr_enrol_ind NOT IN ('Y','N') THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','IVR_ENROL_IND','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status :='E';
      END IF;

      --should not call the TBH chcek constraint as some other validation are also there
      IF  p_unit_ver_rec.ss_enrol_ind NOT IN ('Y','N') THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SS_ENROL_IND','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status :='E';
      END IF;

      IF p_unit_ver_rec.subtitle_approved_ind NOT IN ('Y','N') THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SUBTITLE_APPROVED_IND','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status :='E';
      END IF;

      IF p_unit_ver_rec.subtitle_closed_ind NOT IN ('Y','N') THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','SUBTITLE_CLOSED_IND','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status :='E';
      END IF;

      IF p_unit_ver_rec.curriculum_closed_ind NOT IN ('Y','N') THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','CURRICULUM_CLOSED_IND','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status :='E';
      END IF;


      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('ANON_UNIT_GRADING_IND',p_unit_ver_rec.anon_unit_grading_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','ANON_UNIT_GRADING_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('ANON_ASSESS_GRADING_IND',p_unit_ver_rec.anon_assess_grading_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','ANON_ASSESS_GRADING_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('AUDITABLE_IND',p_unit_ver_rec.auditable_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','AUDITABLE_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('AUDIT_PERMISSION_IND',p_unit_ver_rec.audit_permission_ind);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','AUDIT_PERMISSION_IND','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;
      -----------------------------------------------------------------------------------------------------

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('UNIT_INT_COURSE_LEVEL_CD',p_unit_ver_rec.unit_int_course_level_cd);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_INT_COURSE_LEVEL_CD','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('UNIT_STATUS',p_unit_ver_rec.unit_status);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_STATUS','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('UNIT_LEVEL',p_unit_ver_rec.unit_level);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_LEVEL','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('ACHIEVABLE_CREDIT_POINTS',p_unit_ver_rec.achievable_credit_points);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','ACHIEVABLE_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('POINTS_INCREMENT',p_unit_ver_rec.points_increment);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','POINTS_INCREMENT','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('POINTS_MIN',p_unit_ver_rec.points_min);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','POINTS_MIN','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('POINTS_MAX',p_unit_ver_rec.points_max);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','POINTS_MAX','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('ENROLLED_CREDIT_POINTS',p_unit_ver_rec.enrolled_credit_points);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','ENROLLED_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('VERSION_NUMBER',p_unit_ver_rec.version_number);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VER_NUM_1_999',NULL,NULL,TRUE);
          p_unit_ver_rec.status :='E';
      END;

      IF p_unit_ver_rec.billing_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints ( 'BILLING_CREDIT_POINTS', p_unit_ver_rec.billing_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999', 'BILLING_CREDIT_POINTS', 'LEGACY_TOKENS', TRUE);
            p_unit_ver_rec.status := 'E';
        END;
      END IF;


      --Fk validations
      IF (NOT igs_ps_unit_stat_pkg.get_pk_for_validation(p_unit_ver_rec.unit_status)) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_STATUS','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF l_n_rpt_fmly_id IS NOT NULL THEN
        IF (NOT igs_ps_rpt_fmly_pkg.get_pk_for_validation(l_n_rpt_fmly_id)) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_REPEAT','LEGACY_TOKENS',FALSE);
          p_unit_ver_rec.status:='E';
        END IF;
      END IF;

      IF (NOT igs_ps_unit_level_pkg.get_pk_for_validation(p_unit_ver_rec.unit_level)) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_LEVEL','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      IF p_unit_ver_rec.unit_int_course_level_cd IS NOT NULL THEN
        IF (NOT igs_ps_unit_int_lvl_pkg.get_pk_for_validation(p_unit_ver_rec.unit_int_course_level_cd)) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_INT_COURSE_LEVEL_CD','LEGACY_TOKENS',FALSE);
          p_unit_ver_rec.status:='E';
        END IF;
      END IF;

      IF p_unit_ver_rec.rev_account_cd IS NOT NULL THEN
        IF (NOT igs_fi_acc_pkg.get_pk_for_validation(p_unit_ver_rec.rev_account_cd)) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','REV_ACC_CD','LEGACY_TOKENS',FALSE);
          p_unit_ver_rec.status:='E';
        END IF;
      END IF;

      --Validating the credit point descriptor, bug#2702240
      OPEN cur_credit_point_des(p_unit_ver_rec.credit_point_descriptor);
      FETCH cur_credit_point_des INTO l_var;
      IF cur_credit_point_des%NOTFOUND THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','CREDIT_POINT_DESCRIPTOR','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      --validating the level_code passed is a valid one
      IF l_n_unit_type_id IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','LEVEL_CODE','LEGACY_TOKENS',FALSE);
        p_unit_ver_rec.status:='E';
      END IF;

      -- Added as a part of 2702263
      IF p_unit_ver_rec.claimable_hours IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('CLAIMABLE_HOURS',p_unit_ver_rec.claimable_hours);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','CLAIMABLE_HOURS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.lecture_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('LECTURE_CREDIT_POINTS',p_unit_ver_rec.lecture_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','LECTURE_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.lab_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('LAB_CREDIT_POINTS',p_unit_ver_rec.lab_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','LAB_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.other_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('OTHER_CREDIT_POINTS',p_unit_ver_rec.other_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','OTHER_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.clock_hours IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('CLOCK_HOURS',p_unit_ver_rec.clock_hours);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','CLOCK_HOURS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.continuing_education_units IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('CONTINUING_EDUCATION_UNITS',p_unit_ver_rec.continuing_education_units);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','CONTINUING_EDUCATION_UNITS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.advance_maximum IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('ADVANCE_MAXIMUM',p_unit_ver_rec.advance_maximum);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ADVANCE_MAXIMUM','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.enrollment_expected IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('ENROLLMENT_EXPECTED',p_unit_ver_rec.enrollment_expected);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ENROLLMENT_EXPECTED','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.enrollment_minimum IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('ENROLLMENT_MINIMUM',p_unit_ver_rec.enrollment_minimum);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ENROLLMENT_MINIMUM','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.enrollment_maximum IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('ENROLLMENT_MAXIMUM',p_unit_ver_rec.enrollment_maximum);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ENROLLMENT_MAXIMUM','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.override_enrollment_max IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('OVERRIDE_ENROLLMENT_MAX',p_unit_ver_rec.override_enrollment_max);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','OVERRIDE_ENROLLMENT_MAX','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.max_auditors_allowed IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('MAX_AUDITORS_ALLOWED',p_unit_ver_rec.max_auditors_allowed);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999','MAX_AUDITORS_ALLOWED','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.work_load_cp_lecture IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('WORK_LOAD_CP_LECTURE',p_unit_ver_rec.work_load_cp_lecture);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','WORK_LOAD_CP_LECTURE','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;


      IF p_unit_ver_rec.work_load_cp_lab IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('WORK_LOAD_CP_LAB',p_unit_ver_rec.work_load_cp_lab);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','WORK_LOAD_CP_LAB','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.max_repeat_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('MAX_REPEAT_CREDIT_POINTS',p_unit_ver_rec.max_repeat_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','MAX_REPEAT_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.same_teach_period_repeats_cp IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('SAME_TEACH_PERIOD_REPEATS_CP',p_unit_ver_rec.same_teach_period_repeats_cp);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','SAME_TEACH_PERIOD_REPEATS_CP','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.work_load_other IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('WORK_LOAD_OTHER',p_unit_ver_rec.work_load_other);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','WORK_LOAD_OTHER','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.contact_hrs_lecture IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('CONTACT_HRS_LECTURE',p_unit_ver_rec.contact_hrs_lecture);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','CONTACT_HRS_LECTURE','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.contact_hrs_lab IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('CONTACT_HRS_LAB',p_unit_ver_rec.contact_hrs_lab);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','CONTACT_HRS_LAB','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.contact_hrs_other IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('CONTACT_HRS_OTHER',p_unit_ver_rec.contact_hrs_other);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','CONTACT_HRS_OTHER','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.non_schd_required_hrs IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('NON_SCHD_REQUIRED_HRS',p_unit_ver_rec.non_schd_required_hrs);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','NON_SCHD_REQUIRED_HRS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.max_repeats_for_credit IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('MAX_REPEATS_FOR_CREDIT',p_unit_ver_rec.max_repeats_for_credit);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999','MAX_REPEATS_FOR_CREDIT','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.max_repeats_for_funding IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('MAX_REPEATS_FOR_FUNDING',p_unit_ver_rec.max_repeats_for_funding);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999','MAX_REPEATS_FOR_FUNDING','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;

      IF p_unit_ver_rec.same_teach_period_repeats IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('SAME_TEACH_PERIOD_REPEATS',p_unit_ver_rec.same_teach_period_repeats);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999','SAME_TEACH_PERIOD_REPEATS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;


      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('OVRD_WKLD_VAL_FLAG',p_unit_ver_rec.ovrd_wkld_val_flag);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','OVRD_WKLD_VAL_FLAG','LEGACY_TOKENS',TRUE);
          p_unit_ver_rec.status :='E';
      END;

      IF p_unit_ver_rec.workload_val_code IS NOT NULL THEN
        IF NOT igs_lookups_view_pkg.get_pk_for_validation('WKLD_VAL_TYPE',p_unit_ver_rec.workload_val_code) THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'WKLD_VAL_TYPE','LEGACY_TOKENS', FALSE);
           p_unit_ver_rec.status := 'E';
        END IF;
      END IF;

      IF p_unit_ver_rec.billing_hrs IS NOT NULL THEN
        BEGIN
          igs_ps_unit_ver_pkg.check_constraints('BILLING_HRS',p_unit_ver_rec.billing_hrs);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','BILLING_HRS','LEGACY_TOKENS',TRUE);
            p_unit_ver_rec.status :='E';
        END;
      END IF;


    END validate_db_cons;

  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.start_logging_for','Unit Versions');
    END IF;

    p_rec_status :='S';
    p_unit_ver_rec.msg_from := FND_MSG_PUB.COUNT_MSG;
    trim_values(p_unit_ver_rec);
    validate_parameters(p_unit_ver_rec);

     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.status_after_validate_parameters',
       'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number||'  '||
       'Status:'||p_unit_ver_rec.status);
     END IF;

    IF p_unit_ver_rec.status = 'S' THEN
      validate_derivations(p_unit_ver_rec);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.status_after_validate_derivations',
       'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number||'  '||
       'Status:'||p_unit_ver_rec.status);
     END IF;

    END IF;

    IF p_unit_ver_rec.status = 'S' THEN
      validate_db_cons(p_unit_ver_rec);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.status_after_validate_db_cons',
       'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number||'  '||
       'Status:'||p_unit_ver_rec.status);
      END IF;

    END IF;

    IF p_unit_ver_rec.status = 'S' THEN
      igs_ps_validate_lgcy_pkg.unit_version(p_unit_ver_rec,l_n_coord_person_id);

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.status_after_Business_validation',
        'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number||'  '||
        'Status:'||p_unit_ver_rec.status);
      END IF;

    END IF;

    IF p_unit_ver_rec.status  ='S' THEN

      --If for this unit entry is not there in igs_ps_unit then insert it
      OPEN cur_check(p_unit_ver_rec.unit_cd);
      FETCH cur_check INTO l_c_var;
      IF cur_check%NOTFOUND THEN
        INSERT INTO igs_ps_unit
            (
            unit_cd,
            creation_date,
            created_by,
            last_update_date,
            last_updated_by,
            last_update_login
            )
        VALUES
            (
            p_unit_ver_rec.unit_cd,
            SYSDATE,
            g_n_user_id,
            SYSDATE,
            g_n_user_id,
            g_n_login_id
            );

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.Record_created_igs_ps_unit',
	      'Unit code:'||p_unit_ver_rec.unit_cd);
	    END IF;
      END IF;

      CLOSE cur_check;

      --If subtitle is not null then insert a record into igs_ps_unit_subtitle
      IF p_unit_ver_rec.subtitle IS NOT NULL THEN
        INSERT INTO igs_ps_unit_subtitle
             (
             subtitle_id,
             unit_cd,
             version_number,
             subtitle,
             approved_ind,
             closed_ind,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login
             )
        VALUES
             (
             igs_ps_unit_subtitle_s.NEXTVAL,
             p_unit_ver_rec.unit_cd,
             p_unit_ver_rec.version_number,
             p_unit_ver_rec.subtitle,
             p_unit_ver_rec.subtitle_approved_ind,
             p_unit_ver_rec.subtitle_closed_ind,
             SYSDATE,
             g_n_user_id,
             SYSDATE,
             g_n_user_id,
             g_n_login_id
             ) RETURNING subtitle_id INTO l_n_subtitle_id;

	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.rec_inserted_igs_ps_unit_subtitle',
	       'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number||'  '||
	       'Subtitle_id:'||l_n_subtitle_id||'  '||'Status:'||p_unit_ver_rec.status);
	     END IF;

      END IF;


      --If curriculum description is not null then insert a record into igs_ps_unt_crclm_all
      IF p_unit_ver_rec.curriculum_description IS NOT NULL THEN
        INSERT INTO igs_ps_unt_crclm_all
             (
             curriculum_id,
             description,
             closed_ind,
             org_id,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login
             )
        VALUES
             (
             p_unit_ver_rec.curriculum_id,
             p_unit_ver_rec.curriculum_description,
             p_unit_ver_rec.curriculum_closed_ind,
             igs_ge_gen_003.get_org_id,
             SYSDATE,
             g_n_user_id,
             SYSDATE,
             g_n_user_id,
             g_n_login_id
             );

	     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	       fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.rec_inserted_igs_ps_unt_crclm_all',
	       'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number||'  '||
	       'curriculum_id:'||p_unit_ver_rec.curriculum_id||'  '||'Status:'||p_unit_ver_rec.status);
	     END IF;
      END IF;

      --Enter the unit version record in igs_ps_unit_ver_all
      INSERT INTO igs_ps_unit_ver_all
           (
           unit_cd,
           version_number,
           start_dt,
           review_dt,
           expiry_dt,
           end_dt,
           unit_status,
           title,
           short_title,
           title_override_ind,
           abbreviation,
           unit_level,
           credit_point_descriptor,
           enrolled_credit_points,
           points_override_ind,
           supp_exam_permitted_ind,
           coord_person_id,
           owner_org_unit_cd,
           owner_ou_start_dt,
           award_course_only_ind,
           research_unit_ind,
           industrial_ind,
           practical_ind,
           repeatable_ind,
           assessable_ind,
           achievable_credit_points,
           points_increment,
           points_min,
           points_max,
           unit_int_course_level_cd,
           subtitle_modifiable_flag,
           approval_date,
           lecture_credit_points,
           lab_credit_points,
           other_credit_points,
           clock_hours,
           work_load_cp_lecture,
           work_load_cp_lab,
           continuing_education_units,
           enrollment_expected,
           enrollment_minimum,
           enrollment_maximum,
           advance_maximum,
           state_financial_aid,
           federal_financial_aid,
           institutional_financial_aid,
           same_teaching_period,
           max_repeats_for_credit,
           max_repeats_for_funding,
           max_repeat_credit_points,
           same_teach_period_repeats,
           same_teach_period_repeats_cp,
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
           org_id,
           ss_enrol_ind,
           ivr_enrol_ind,
           rev_account_cd,
           claimable_hours,
           anon_unit_grading_ind,
           anon_assess_grading_ind,
           auditable_ind,
           audit_permission_ind,
           max_auditors_allowed,
	   billing_credit_points,
           ovrd_wkld_val_flag,
           workload_val_code,
	   billing_hrs,
           creation_date,
           created_by,
           last_update_date,
           last_updated_by,
           last_update_login
           )
      VALUES
           (
           p_unit_ver_rec.unit_cd,
           p_unit_ver_rec.version_number,
           p_unit_ver_rec.start_dt,
           p_unit_ver_rec.review_dt,
           p_unit_ver_rec.expiry_dt,
           p_unit_ver_rec.end_dt,
           p_unit_ver_rec.unit_status,
           p_unit_ver_rec.title,
           p_unit_ver_rec.short_title,
           p_unit_ver_rec.title_override_ind,
           p_unit_ver_rec.abbreviation,
           p_unit_ver_rec.unit_level,
           p_unit_ver_rec.credit_point_descriptor,
           p_unit_ver_rec.enrolled_credit_points,
           p_unit_ver_rec.points_override_ind,
           p_unit_ver_rec.supp_exam_permitted_ind,
           l_n_coord_person_id,
           p_unit_ver_rec.owner_org_unit_cd,
           l_d_owner_ou_start_dt,
           p_unit_ver_rec.award_course_only_ind,
           p_unit_ver_rec.research_unit_ind,
           p_unit_ver_rec.industrial_ind,
           p_unit_ver_rec.practical_ind,
           p_unit_ver_rec.repeatable_ind,
           p_unit_ver_rec.assessable_ind,
           p_unit_ver_rec.achievable_credit_points,
           p_unit_ver_rec.points_increment,
           p_unit_ver_rec.points_min,
           p_unit_ver_rec.points_max,
           p_unit_ver_rec.unit_int_course_level_cd,
           p_unit_ver_rec.subtitle_modifiable_flag,
           p_unit_ver_rec.approval_date,
           p_unit_ver_rec.lecture_credit_points,
           p_unit_ver_rec.lab_credit_points,
           p_unit_ver_rec.other_credit_points,
           p_unit_ver_rec.clock_hours,
           p_unit_ver_rec.work_load_cp_lecture,
           p_unit_ver_rec.work_load_cp_lab,
           p_unit_ver_rec.continuing_education_units,
           p_unit_ver_rec.enrollment_expected,
           p_unit_ver_rec.enrollment_minimum,
           p_unit_ver_rec.enrollment_maximum,
           p_unit_ver_rec.advance_maximum,
           p_unit_ver_rec.state_financial_aid,
           p_unit_ver_rec.federal_financial_aid,
           p_unit_ver_rec.institutional_financial_aid,
           p_unit_ver_rec.same_teaching_period,
           p_unit_ver_rec.max_repeats_for_credit,
           p_unit_ver_rec.max_repeats_for_funding,
           p_unit_ver_rec.max_repeat_credit_points,
           p_unit_ver_rec.same_teach_period_repeats,
           p_unit_ver_rec.same_teach_period_repeats_cp,
           p_unit_ver_rec.attribute_category,
           p_unit_ver_rec.attribute1,
           p_unit_ver_rec.attribute2,
           p_unit_ver_rec.attribute3,
           p_unit_ver_rec.attribute4,
           p_unit_ver_rec.attribute5,
           p_unit_ver_rec.attribute6,
           p_unit_ver_rec.attribute7,
           p_unit_ver_rec.attribute8,
           p_unit_ver_rec.attribute9,
           p_unit_ver_rec.attribute10,
           p_unit_ver_rec.attribute11,
           p_unit_ver_rec.attribute12,
           p_unit_ver_rec.attribute13,
           p_unit_ver_rec.attribute14,
           p_unit_ver_rec.attribute15,
           p_unit_ver_rec.attribute16,
           p_unit_ver_rec.attribute17,
           p_unit_ver_rec.attribute18,
           p_unit_ver_rec.attribute19,
           p_unit_ver_rec.attribute20,
           l_n_subtitle_id,
           p_unit_ver_rec.work_load_other,
           p_unit_ver_rec.contact_hrs_lecture,
           p_unit_ver_rec.contact_hrs_lab,
           p_unit_ver_rec.contact_hrs_other,
           p_unit_ver_rec.non_schd_required_hrs,
           p_unit_ver_rec.exclude_from_max_cp_limit,
           p_unit_ver_rec.record_exclusion_flag,
           p_unit_ver_rec.ss_display_ind,
           l_c_cal_type_enrol_load_cal,
           l_n_seq_num_enrol_load_cal,
           l_c_cal_type_offer_load_cal,
           l_n_seq_num_offer_load_cal,
           p_unit_ver_rec.curriculum_id,
           p_unit_ver_rec.override_enrollment_max,
           l_n_rpt_fmly_id,
           l_n_unit_type_id,
           p_unit_ver_rec.special_permission_ind,
           igs_ge_gen_003.get_org_id,
           p_unit_ver_rec.ss_enrol_ind,
           p_unit_ver_rec.ivr_enrol_ind,
           p_unit_ver_rec.rev_account_cd,
           p_unit_ver_rec.claimable_hours,
           p_unit_ver_rec.anon_unit_grading_ind,
           p_unit_ver_rec.anon_assess_grading_ind,
           p_unit_ver_rec.auditable_ind,
           p_unit_ver_rec.audit_permission_ind,
           p_unit_ver_rec.max_auditors_allowed,
	   p_unit_ver_rec.billing_credit_points,
           p_unit_ver_rec.ovrd_wkld_val_flag,
           p_unit_ver_rec.workload_val_code,
	   p_unit_ver_rec.billing_hrs,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           g_n_login_id
           );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.Record_Inserted',
	     'Unit code:'||p_unit_ver_rec.unit_cd||'  '||'Version number:'||p_unit_ver_rec.version_number);
	   END IF;

      p_unit_ver_rec.msg_from := NULL;
      p_unit_ver_rec.msg_to := NULL;
    ELSE
      p_unit_ver_rec.msg_from := p_unit_ver_rec.msg_from + 1;
      p_unit_ver_rec.msg_to := FND_MSG_PUB.COUNT_MSG;
    END IF;
    p_rec_status:= p_unit_ver_rec.status;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_version.after_import_status',p_rec_status);
     END IF;

  END create_unit_version;

  PROCEDURE create_teach_resp ( p_tab_teach_resp IN OUT NOCOPY igs_ps_generic_pub.unit_tr_tbl_type,
                                p_c_rec_status OUT NOCOPY VARCHAR2 ) AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  11-NOV-2002
    Purpose        :  This procedure is a sub process to insert records of Teaching Responsibility.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk      12-Dec-2002      Added a boolean parameter to the function call igs_ps_val_tr.crsp_val_tr_perc.
                               As a part of the Bug # 2696207
    smvk      20-Dec-2002      Removed the IGS_PS_TCH_RESP_PKG.check_constraints for org_unit_cd,
                               as the org unit code can have value in mixed case. Bug # 2487149.
  ********************************************************************************************** */

    l_d_ou_start_dt   igs_ps_unit_ver_all.owner_ou_start_dt%TYPE;
    l_c_message_name  VARCHAR2 (30);
    CURSOR c_org(cp_org_unit_cd igs_ps_tch_resp.org_unit_cd%TYPE) IS
    SELECT 'X'
    FROM   igs_or_inst_org_base_v a, igs_or_status b
    WHERE  a.party_number = cp_org_unit_cd
    AND    a.org_status = b.org_status
    AND    b.s_org_status <> 'INACTIVE';
    c_org_rec c_org%ROWTYPE;

    /* Private Procedures for create_teach_resp */
    PROCEDURE trim_values ( p_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_tr_rec_type ) AS
    BEGIN
             p_teach_resp_rec.unit_cd := trim(p_teach_resp_rec.unit_cd);
             p_teach_resp_rec.version_number := trim(p_teach_resp_rec.version_number);
             p_teach_resp_rec.org_unit_cd := trim(p_teach_resp_rec.org_unit_cd);
             p_teach_resp_rec.percentage := trim(p_teach_resp_rec.percentage);

    END trim_values;
    -- validate parameters passed.
    PROCEDURE validate_parameters ( p_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_tr_rec_type ) AS
    BEGIN
      /* Check for Mandatory Parameters */
      IF p_teach_resp_rec.unit_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;
      IF p_teach_resp_rec.version_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;
      IF p_teach_resp_rec.org_unit_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'ORG_UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;
      IF p_teach_resp_rec.percentage IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PERCENTAGE', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;
    END validate_parameters;

    -- Carry out derivations and validate them
    PROCEDURE validate_derivations ( p_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_tr_rec_type ) AS
    BEGIN
      IF NOT igs_re_val_rsup.get_org_unit_dtls ( p_teach_resp_rec.org_unit_cd, l_d_ou_start_dt ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ORG_UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;
    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_teach_resp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_tr_rec_type ) AS
    BEGIN

      /* Validate PK Constraints */
      IF igs_ps_tch_resp_pkg.get_pk_for_validation (
           x_unit_cd        => p_teach_resp_rec.unit_cd,
           x_version_number => p_teach_resp_rec.version_number,
           x_org_unit_cd    => p_teach_resp_rec.org_unit_cd,
           x_ou_start_dt    => l_d_ou_start_dt ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_TEACH_RESP', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'W';
        RETURN;
      END IF;

      /* Validate Check Constraints */
      BEGIN
        igs_ps_tch_resp_pkg.check_constraints ( 'UNIT_CD', p_teach_resp_rec.unit_cd );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'UNIT_CD', 'LEGACY_TOKENS', TRUE);
          p_teach_resp_rec.status := 'E';
      END;

      BEGIN
        igs_ps_tch_resp_pkg.check_constraints ( 'PERCENTAGE', p_teach_resp_rec.percentage );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PER_0_100', null, null, TRUE);
          p_teach_resp_rec.status := 'E';
      END;

      /* Validate FK Constraints */
      IF NOT igs_or_unit_pkg.get_pk_for_validation (
           p_teach_resp_rec.org_unit_cd,
           l_d_ou_start_dt ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ORG_UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;
      IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (
           p_teach_resp_rec.unit_cd,
           p_teach_resp_rec.version_number ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_VERSION', 'LEGACY_TOKENS', FALSE);
        p_teach_resp_rec.status := 'E';
      END IF;

    END validate_db_cons;

  /* Main Teaching Responsibility Sub Process */
  BEGIN
     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.start_logging_for','Teaching Responsibility');
     END IF;
    p_c_rec_status := 'S';

    FOR I in 1..p_tab_teach_resp.LAST LOOP
      IF ( p_tab_teach_resp.EXISTS(I) ) THEN
        p_tab_teach_resp(I).status := 'S';
        p_tab_teach_resp(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_tab_teach_resp(I) );
        validate_parameters ( p_tab_teach_resp(I) );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.status_after_validate_parameters',
	  'Unit code:'||p_tab_teach_resp(I).unit_cd||'  '||'Version number:'||p_tab_teach_resp(I).version_number||'  '||
	  'org_unit_cd:'||p_tab_teach_resp(I).org_unit_cd||'  '||'Status:'||p_tab_teach_resp(I).status);
	END IF;

        IF p_tab_teach_resp(I).status = 'S' THEN
          validate_derivations ( p_tab_teach_resp(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.status_after_validate_derivations',
	    'Unit code:'||p_tab_teach_resp(I).unit_cd||'  '||'Version number:'||p_tab_teach_resp(I).version_number||'  '||
	    'org_unit_cd:'||p_tab_teach_resp(I).org_unit_cd||'  '||'ou_start_dt:'||l_d_ou_start_dt||'  '||
	    'Status:'||p_tab_teach_resp(I).status);
 	  END IF;

        END IF;

        IF p_tab_teach_resp(I).status = 'S' THEN
          validate_db_cons ( p_tab_teach_resp(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.status_after_validate_db_cons',
	    'Unit code:'||p_tab_teach_resp(I).unit_cd||'  '||'Version number:'||p_tab_teach_resp(I).version_number||'  '||
	    'org_unit_cd:'||p_tab_teach_resp(I).org_unit_cd||'  '||'ou_start_dt:'||l_d_ou_start_dt||'  '||
	    'Status:'||p_tab_teach_resp(I).status);
 	  END IF;

        END IF;
       IF p_tab_teach_resp(I).status = 'S' THEN
	  OPEN c_org (p_tab_teach_resp(I).org_unit_cd);
	  FETCH c_org  INTO c_org_rec;
	  IF c_org%NOTFOUND THEN
            fnd_message.set_name('IGS','IGS_PS_ORGUNIT_STATUS_INACTIV');
            fnd_msg_pub.add;
	    p_tab_teach_resp(I).status := 'E';
	  END IF;
          CLOSE c_org;
       END IF;

        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_tab_teach_resp(I).status = 'S' THEN
          /* Validation# 1: Check if the Teaching Responsibility Percentage adds upto 100 */
          IF igs_ps_val_tr.crsp_val_tr_perc (
              p_unit_cd        => p_tab_teach_resp(I).unit_cd,
              p_version_number => p_tab_teach_resp(I).version_number,
              p_message_name   => l_c_message_name  ,
              p_b_lgcy_validator => TRUE) THEN
              fnd_message.set_name('IGS','IGS_PS_LGCY_TR_100_EXISTS');
              fnd_msg_pub.add;
              p_tab_teach_resp(I).status := 'W' ;
          END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.status_after_Business_validation',
	    'Unit code:'||p_tab_teach_resp(I).unit_cd||'  '||'Version number:'||p_tab_teach_resp(I).version_number||'  '||
	    'org_unit_cd:'||p_tab_teach_resp(I).org_unit_cd||'  '||'ou_start_dt:'||l_d_ou_start_dt||'  '||
	    'Status:'||p_tab_teach_resp(I).status);
 	  END IF;

        END IF;

        IF p_tab_teach_resp(I).status = 'S' THEN
          /* Insert the Record */
          INSERT INTO igs_ps_tch_resp
          (unit_cd,
           version_number,
           org_unit_cd,
           ou_start_dt,
           percentage,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          VALUES
          (p_tab_teach_resp(I).unit_cd,
           p_tab_teach_resp(I).version_number,
           p_tab_teach_resp(I).org_unit_cd,
           l_d_ou_start_dt,
           p_tab_teach_resp(I).percentage,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id
          );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.Record_Inserted',
	    'Unit code:'||p_tab_teach_resp(I).unit_cd||'  '||'Version number:'||p_tab_teach_resp(I).version_number||'  '||
	    'org_unit_cd:'||p_tab_teach_resp(I).org_unit_cd||'  '||'ou_start_dt:'||l_d_ou_start_dt);
 	  END IF;

          p_tab_teach_resp(I).msg_from := NULL;
          p_tab_teach_resp(I).msg_to := NULL;
        ELSE
          p_c_rec_status := p_tab_teach_resp(I).status;
          p_tab_teach_resp(I).msg_from := p_tab_teach_resp(I).msg_from+1;
          p_tab_teach_resp(I).msg_to := fnd_msg_pub.count_msg;
          IF p_tab_teach_resp(I).status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;

    END LOOP;

    /* Post Insert Validations */
    IF NOT igs_ps_validate_lgcy_pkg.post_teach_resp(p_tab_teach_resp) THEN
      p_c_rec_status := 'E';
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement,
      'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.status_after_Post_insert_validation','Status:'||p_c_rec_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_teach_resp.after_import_status',p_c_rec_status);
    END IF;

  END create_teach_resp;


  PROCEDURE create_unit_discip ( p_tab_unit_dscp IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_tbl_type,
                                 p_c_rec_status OUT NOCOPY VARCHAR2 ) AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  11-NOV-2002
    Purpose        :  This procedure is a sub process to insert records of Unit Disciplines.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk      12-Dec-2002      Added a boolean parameter to the function call igs_ps_val_ud.crsp_val_ud_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */

    l_c_message_name      VARCHAR2(30);

    /* Private Procedures for create_unit_dscp */
    PROCEDURE trim_values ( p_unit_dscp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_rec_type ) AS
    BEGIN
      p_unit_dscp_rec.unit_cd := TRIM(p_unit_dscp_rec.unit_cd);
      p_unit_dscp_rec.version_number := TRIM(p_unit_dscp_rec.version_number);
      p_unit_dscp_rec.discipline_group_cd := TRIM(p_unit_dscp_rec.discipline_group_cd);
      p_unit_dscp_rec.percentage  := TRIM(p_unit_dscp_rec.percentage);
    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( p_unit_dscp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_rec_type ) AS
    BEGIN
      /* Check for Mandatory Parameters */
      IF p_unit_dscp_rec.unit_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'E';
      END IF;
      IF p_unit_dscp_rec.version_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'E';
      END IF;
      IF p_unit_dscp_rec.discipline_group_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'DISCIPLINE_GROUP_CD', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'E';
      END IF;
      IF p_unit_dscp_rec.percentage IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'PERCENTAGE', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'E';
      END IF;
    END validate_parameters;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_unit_dscp_rec IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_rec_type ) AS
    BEGIN

      /* Validate PK Constraints */
      IF igs_ps_unit_dscp_pkg.get_pk_for_validation (
           x_unit_cd                => p_unit_dscp_rec.unit_cd,
           x_version_number         => p_unit_dscp_rec.version_number,
           x_discipline_group_cd    => p_unit_dscp_rec.discipline_group_cd ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_DISCIPLINE', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'W';
        RETURN;
      END IF;

      /* Validate Check Constraints */
      BEGIN
        igs_ps_unit_dscp_pkg.check_constraints ( 'UNIT_CD', p_unit_dscp_rec.unit_cd );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'UNIT_CD', 'LEGACY_TOKENS', TRUE);
          p_unit_dscp_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_dscp_pkg.check_constraints ( 'DISCIPLINE_GROUP_CD', p_unit_dscp_rec.discipline_group_cd );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'DISCIPLINE_GROUP_CD', 'LEGACY_TOKENS', TRUE);
          p_unit_dscp_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_dscp_pkg.check_constraints ( 'PERCENTAGE', p_unit_dscp_rec.percentage );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PER_0_100', null, null, TRUE);
          p_unit_dscp_rec.status := 'E';
      END;

      /* Validate FK Constraints */
      IF NOT igs_ps_dscp_pkg.get_pk_for_validation (p_unit_dscp_rec.discipline_group_cd) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'DISCIPLINE_GROUP_CD', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation (p_unit_dscp_rec.unit_cd, p_unit_dscp_rec.version_number) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_VERSION', 'LEGACY_TOKENS', FALSE);
        p_unit_dscp_rec.status := 'E';
      END IF;

    END validate_db_cons;

  /* Main Unit Discipline Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.start_logging_for','Unit Discipline');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_tab_unit_dscp.LAST LOOP
      IF ( p_tab_unit_dscp.EXISTS(I) ) THEN
        p_tab_unit_dscp(I).status := 'S';
        p_tab_unit_dscp(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_tab_unit_dscp(I) );
        validate_parameters ( p_tab_unit_dscp(I) );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.status_after_validate_parameters',
	  'Unit code:'||p_tab_unit_dscp(I).unit_cd||'  '||'Version number:'||p_tab_unit_dscp(I).version_number||'  '||
	  'discipline_group_cd:'||p_tab_unit_dscp(I).discipline_group_cd||'  '||'Status:'||p_tab_unit_dscp(I).status);
	END IF;

        IF p_tab_unit_dscp(I).status = 'S' THEN
          validate_db_cons ( p_tab_unit_dscp(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.status_after_validate_db_cons',
	    'Unit code:'||p_tab_unit_dscp(I).unit_cd||'  '||'Version number:'||p_tab_unit_dscp(I).version_number||'  '||
	    'discipline_group_cd:'||p_tab_unit_dscp(I).discipline_group_cd||'  '||'Status:'||p_tab_unit_dscp(I).status);
	  END IF;

        END IF;

        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_tab_unit_dscp(I).status = 'S' THEN
          /* Validation# 1: Check if the Unit Discipline Percentage adds upto 100 */
          IF igs_ps_val_ud.crsp_val_ud_perc ( p_tab_unit_dscp(I).unit_cd, p_tab_unit_dscp(I).version_number, l_c_message_name ,TRUE) THEN
            fnd_message.set_name('IGS','IGS_PS_LGCY_UD_100_EXISTS');
            fnd_msg_pub.add;
            p_tab_unit_dscp(I).status := 'W';
          END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.status_after_Business_validation',
	    'Unit code:'||p_tab_unit_dscp(I).unit_cd||'  '||'Version number:'||p_tab_unit_dscp(I).version_number||'  '||
	    'discipline_group_cd:'||p_tab_unit_dscp(I).discipline_group_cd||'  '||'Status:'||p_tab_unit_dscp(I).status);
	  END IF;

        END IF;

        IF p_tab_unit_dscp(I).status = 'S' THEN
          /* Insert record */
          INSERT INTO igs_ps_unit_dscp
          (unit_cd,
           version_number,
           discipline_group_cd,
           percentage,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          VALUES
          (p_tab_unit_dscp(I).unit_cd,
           p_tab_unit_dscp(I).version_number,
           p_tab_unit_dscp(I).discipline_group_cd,
           p_tab_unit_dscp(I).percentage,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id
          );
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.Record_Inserted',
	    'Unit code:'||p_tab_unit_dscp(I).unit_cd||'  '||'Version number:'||p_tab_unit_dscp(I).version_number||'  '||
	    'discipline_group_cd:'||p_tab_unit_dscp(I).discipline_group_cd);
	  END IF;

          p_tab_unit_dscp(I).msg_from := NULL;
          p_tab_unit_dscp(I).msg_to := NULL;
        ELSE
          p_c_rec_status := p_tab_unit_dscp(I).status;
          p_tab_unit_dscp(I).msg_from := p_tab_unit_dscp(I).msg_from+1;
          p_tab_unit_dscp(I).msg_to := fnd_msg_pub.count_msg;
          IF p_tab_unit_dscp(I).status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;
    END LOOP;

    /* Post Insert Checks */
    IF NOT igs_ps_validate_lgcy_pkg.post_unit_discip(p_tab_unit_dscp) THEN
      p_c_rec_status := 'E';
    END IF;

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.Status_after_Post_insert_check',
	    'Status:'||p_c_rec_status);
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_discip.after_import_status',p_c_rec_status);
    END IF;

  END create_unit_discip;

  PROCEDURE create_unit_grd_sch ( p_tab_grd_sch IN OUT NOCOPY igs_ps_generic_pub.unit_gs_tbl_type,
                                  p_c_rec_status OUT NOCOPY VARCHAR2 ) AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  12-NOV-2002
    Purpose        :  This procedure is a sub process to insert records of Unit Grading Schema.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    /* Private Procedures for create_unit_grd_sch */
    PROCEDURE trim_values ( p_grd_sch_rec IN OUT NOCOPY igs_ps_generic_pub.unit_gs_rec_type ) AS
    BEGIN
      p_grd_sch_rec.unit_cd := trim(p_grd_sch_rec.unit_cd);
      p_grd_sch_rec.version_number := trim(p_grd_sch_rec.version_number);
      p_grd_sch_rec.grading_schema_code := trim(p_grd_sch_rec.grading_schema_code);
      p_grd_sch_rec.grd_schm_version_number := trim(p_grd_sch_rec.grd_schm_version_number);
      p_grd_sch_rec.default_flag := trim(p_grd_sch_rec.default_flag);
    END trim_values;

    -- Validation of Parameters passed.
    PROCEDURE validate_parameters ( p_grd_sch_rec IN OUT NOCOPY igs_ps_generic_pub.unit_gs_rec_type ) AS
    BEGIN

      /* Check for Mandatory Parameters */
      IF p_grd_sch_rec.unit_cd IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;
      IF p_grd_sch_rec.version_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;
      IF p_grd_sch_rec.grading_schema_code IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_GRADING_SCHM_CD', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;
      IF p_grd_sch_rec.grd_schm_version_number IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_GRADING_SCHM_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;
      IF p_grd_sch_rec.default_flag IS NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'DEFAULT_FLAG', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;

    END validate_parameters;

    -- Validate Database Constraints.
    PROCEDURE validate_db_cons ( p_grd_sch_rec IN OUT NOCOPY igs_ps_generic_pub.unit_gs_rec_type ) AS
    BEGIN

      /* Unique Key Validation */
      IF igs_ps_unit_grd_schm_pkg.get_uk_for_validation (
              x_unit_version_number     => p_grd_sch_rec.version_number,
              x_grading_schema_code     => p_grd_sch_rec.grading_schema_code,
              x_grd_schm_version_number => p_grd_sch_rec.grd_schm_version_number,
              x_unit_code               => p_grd_sch_rec.unit_cd ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_GRADING_SCHM', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'W';
        RETURN;
      END IF;

      /* Validate Check Constraints */
      BEGIN
        igs_ps_unit_grd_schm_pkg.check_constraints ( 'DEFAULT_FLAG', p_grd_sch_rec.default_flag );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'DEFAULT_FLAG', 'LEGACY_TOKENS', TRUE);
          p_grd_sch_rec.status := 'E';
      END;

      /* Validate FK Constraints */
      IF NOT igs_as_grd_schema_pkg.get_pk_for_validation ( p_grd_sch_rec.grading_schema_code, p_grd_sch_rec.grd_schm_version_number) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_GRADING_SCHM', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation ( p_grd_sch_rec.unit_cd, p_grd_sch_rec.version_number ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_VERSION', 'LEGACY_TOKENS', FALSE);
        p_grd_sch_rec.status := 'E';
      END IF;
    END validate_db_cons;

  /* Main Grading Schema Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_grd_sch.start_logging_for','Unit Grading Schema');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_tab_grd_sch.LAST LOOP
      IF p_tab_grd_sch.EXISTS(I) THEN
        p_tab_grd_sch(I).status := 'S';
        p_tab_grd_sch(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_tab_grd_sch(I));
        validate_parameters ( p_tab_grd_sch(I) );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_grd_sch.status_after_validate_parameters',
	  'Unit code:'||p_tab_grd_sch(I).unit_cd||'  '||'Version number:'||p_tab_grd_sch(I).version_number||'  '||
	  'grading_schema_code:'||p_tab_grd_sch(I).grading_schema_code||'  '||'grd_schm_version_number:'||
	  p_tab_grd_sch(I).grd_schm_version_number||'  '||'Status:'||p_tab_grd_sch(I).status);
 	END IF;

        IF p_tab_grd_sch(I).status = 'S' THEN
          validate_db_cons ( p_tab_grd_sch(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_grd_sch.status_after_validate_db_cons',
	    'Unit code:'||p_tab_grd_sch(I).unit_cd||'  '||'Version number:'||p_tab_grd_sch(I).version_number||'  '||
	    'grading_schema_code:'||p_tab_grd_sch(I).grading_schema_code||'  '||'grd_schm_version_number:'||
	    p_tab_grd_sch(I).grd_schm_version_number||'  '||'Status:'||p_tab_grd_sch(I).status);
 	  END IF;

        END IF;

        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_tab_grd_sch(I).status = 'S' THEN
          igs_ps_validate_lgcy_pkg.validate_unit_grd_sch ( p_tab_grd_sch(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_grd_sch.status_after_Business_Validation',
	    'Unit code:'||p_tab_grd_sch(I).unit_cd||'  '||'Version number:'||p_tab_grd_sch(I).version_number||'  '||
	    'grading_schema_code:'||p_tab_grd_sch(I).grading_schema_code||'  '||'grd_schm_version_number:'||
	    p_tab_grd_sch(I).grd_schm_version_number||'  '||'Status:'||p_tab_grd_sch(I).status);
 	  END IF;

        END IF;

        IF p_tab_grd_sch(I).status = 'S' THEN
          /* Insert Record */
          INSERT INTO igs_ps_unit_grd_schm
          (unit_grading_schema_id,
           unit_code,
           unit_version_number,
           grading_schema_code,
           grd_schm_version_number,
           default_flag,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login
          )
          VALUES
          (igs_ps_unit_grd_schm_s.NEXTVAL,
           p_tab_grd_sch(I).unit_cd,
           p_tab_grd_sch(I).version_number,
           p_tab_grd_sch(I).grading_schema_code,
           p_tab_grd_sch(I).grd_schm_version_number,
           p_tab_grd_sch(I).default_flag,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id
          );

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_grd_sch.record_inserted',
	    'Unit code:'||p_tab_grd_sch(I).unit_cd||'  '||'Version number:'||p_tab_grd_sch(I).version_number||'  '||
	    'grading_schema_code:'||p_tab_grd_sch(I).grading_schema_code||'  '||'grd_schm_version_number:'||
	    p_tab_grd_sch(I).grd_schm_version_number);
 	  END IF;

          p_tab_grd_sch(I).msg_from := NULL;
          p_tab_grd_sch(I).msg_to := NULL;
        ELSE
          p_c_rec_status := p_tab_grd_sch(I).status;
          p_tab_grd_sch(I).msg_from := p_tab_grd_sch(I).msg_from+1;
          p_tab_grd_sch(I).msg_to := fnd_msg_pub.count_msg;
          IF p_tab_grd_sch(I).status = 'E' THEN
            RETURN;
          END IF;
        END IF;
      END IF;
    END LOOP;

    /* Post Insert Checks */
    IF NOT igs_ps_validate_lgcy_pkg.post_unit_grd_sch (p_tab_grd_sch) THEN
      p_c_rec_status := 'E';
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_grd_sch.after_import_status',p_c_rec_status);
    END IF;


  END create_unit_grd_sch;

  PROCEDURE validate_unit_dtls (
          p_unit_ver_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ver_rec_type,
          p_rec_status   OUT NOCOPY    VARCHAR2) AS

  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  07-NOV-2003
    Purpose        :  To do validations across different sub process at unil level.
                      Presently doing the following validations
                      1) For active unit's the teaching responsibility percentage should total to 100
                      2) For active unit's the unit discipline percentage should total to 100

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************* */

    CURSOR c_unit_status (cp_c_unit_status IN igs_ps_unit_stat.unit_status%TYPE) IS
      SELECT s_unit_status
      FROM   igs_ps_unit_stat
      WHERE unit_status = cp_c_unit_status;

    rec_unit_status c_unit_status%ROWTYPE;
    l_c_message VARCHAR2(30);

  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.validate_unit_dtls.start_logging_for','Unit Details Validations');
    END IF;

    OPEN c_unit_status (p_unit_ver_rec.unit_status);
    FETCH c_unit_status INTO rec_unit_status;
    CLOSE c_unit_status;

    IF rec_unit_status.s_unit_status = 'ACTIVE' THEN
      p_unit_ver_rec.msg_from := fnd_msg_pub.count_msg;
      p_rec_status := p_unit_ver_rec.status;

      IF NOT igs_ps_val_tr.crsp_val_tr_perc ( p_unit_ver_rec.unit_cd, p_unit_ver_rec.version_number, l_c_message ,TRUE) THEN
        -- Adding more meaningful message rather then the message returned in the variable l_c_message
        fnd_message.set_name('IGS','IGS_PS_LGCY_ACT_UNT_WITHOUT_TR');
        fnd_msg_pub.add;
        p_unit_ver_rec.status := 'E';
      END IF;

      IF NOT igs_ps_val_ud.crsp_val_ud_perc ( p_unit_ver_rec.unit_cd, p_unit_ver_rec.version_number, l_c_message ,TRUE) THEN
        -- Adding more meaningful message rather then the message returned in the variable l_c_message
        fnd_message.set_name('IGS','IGS_PS_LGCY_ACT_UNT_WITHOUT_UD');
        fnd_msg_pub.add;
        p_unit_ver_rec.status := 'E';
      END IF;

      IF p_unit_ver_rec.status = 'S' THEN
         p_unit_ver_rec.msg_from := NULL;
         p_unit_ver_rec.msg_to := NULL;
      ELSE
         p_unit_ver_rec.msg_from := p_unit_ver_rec.msg_from + 1;
         p_unit_ver_rec.msg_to := fnd_msg_pub.count_msg;
         p_rec_status := p_unit_ver_rec.status;
      END IF;
    END IF;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure,
                      'igs.plsql.igs_ps_unit_lgcy_pkg.validate_unit_dtls.record_status_after_validation_of_unit_details',
		      p_unit_ver_rec.status);
    END IF;


  END validate_unit_dtls;


PROCEDURE create_unit_section ( p_usec_tbl IN OUT NOCOPY igs_ps_generic_pub.usec_tbl_type,
                                p_c_rec_status OUT NOCOPY VARCHAR2,
				p_calling_context  IN VARCHAR2
			      ) AS

    l_insert_update     VARCHAR2(1);
    l_conc_flag         BOOLEAN;
    l_request_id        NUMBER;
    l_message_name      VARCHAR2(30);

    l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
    l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
    l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
    l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
    l_c_org_unit_cd igs_ps_unit_ver_all.owner_org_unit_cd%TYPE;
    l_n_unit_contact_id igs_pe_person_base_v.person_id%TYPE;
    l_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_sup_uoo_id igs_ps_unit_ofr_opt_all.sup_uoo_id%TYPE;
    l_c_relation_type igs_ps_unit_ofr_opt_all.relation_type%TYPE;
    l_n_subtitle_id igs_ps_unit_subtitle.subtitle_id%TYPE;
    l_b_uop_deleted BOOLEAN;


    /* Private Procedures for create_unit_section */
    PROCEDURE trim_values ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS
    /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sarakshi  10-Nov-2003   Enh#3116171, added code trim billing_credit_points field
    sarakshi  11-Sep-2003   ENh#3052452,added coe to trim the value of sup_unit_cd,sup_version_number,sup_teach_cal_alternate_code,sup_location_cd,sup_unit_class,default_enoll_flag
    vvutukur  05-Aug-2003   Enh#3045069.PSP Enh Build. Added code to trim the value of newly added column not_multiple_section_flag.
    ********************************************************************************************* */
    BEGIN
      p_usec_rec.unit_cd := trim(p_usec_rec.unit_cd);
      p_usec_rec.version_number := trim(p_usec_rec.version_number);
      p_usec_rec.teach_cal_alternate_code := trim(p_usec_rec.teach_cal_alternate_code);
      p_usec_rec.location_cd := trim(p_usec_rec.location_cd);
      p_usec_rec.unit_class := trim(p_usec_rec.unit_class);
      p_usec_rec.ivrs_available_ind := trim(p_usec_rec.ivrs_available_ind);
      p_usec_rec.call_number := trim(p_usec_rec.call_number);
      p_usec_rec.unit_section_status := trim(p_usec_rec.unit_section_status);
      p_usec_rec.unit_section_start_date := TRUNC(p_usec_rec.unit_section_start_date);
      p_usec_rec.unit_section_end_date := TRUNC(p_usec_rec.unit_section_end_date);
      p_usec_rec.offered_ind := trim(p_usec_rec.offered_ind);
      p_usec_rec.state_financial_aid := trim(p_usec_rec.state_financial_aid);
      p_usec_rec.grading_schema_prcdnce_ind := trim(p_usec_rec.grading_schema_prcdnce_ind);
      p_usec_rec.federal_financial_aid := trim(p_usec_rec.federal_financial_aid);
      p_usec_rec.unit_quota := trim(p_usec_rec.unit_quota);
      p_usec_rec.unit_quota_reserved_places := trim(p_usec_rec.unit_quota_reserved_places);
      p_usec_rec.institutional_financial_aid := trim(p_usec_rec.institutional_financial_aid);
      p_usec_rec.grading_schema_cd := trim(p_usec_rec.grading_schema_cd);
      p_usec_rec.gs_version_number := trim(p_usec_rec.gs_version_number);
      p_usec_rec.unit_contact_number := trim(p_usec_rec.unit_contact_number);
      p_usec_rec.ss_enrol_ind := trim(p_usec_rec.ss_enrol_ind);
      p_usec_rec.owner_org_unit_cd := trim(p_usec_rec.owner_org_unit_cd);
      p_usec_rec.attendance_required_ind := trim(p_usec_rec.attendance_required_ind);
      p_usec_rec.reserved_seating_allowed := trim(p_usec_rec.reserved_seating_allowed);
      p_usec_rec.special_permission_ind := trim(p_usec_rec.special_permission_ind);
      p_usec_rec.ss_display_ind := trim(p_usec_rec.ss_display_ind);
      p_usec_rec.rev_account_cd := trim(p_usec_rec.rev_account_cd);
      p_usec_rec.anon_unit_grading_ind := trim(p_usec_rec.anon_unit_grading_ind);
      p_usec_rec.anon_assess_grading_ind := trim(p_usec_rec.anon_assess_grading_ind);
      p_usec_rec.non_std_usec_ind := trim(p_usec_rec.non_std_usec_ind);
      p_usec_rec.auditable_ind := trim(p_usec_rec.auditable_ind);
      p_usec_rec.audit_permission_ind := trim(p_usec_rec.audit_permission_ind);
      p_usec_rec.waitlist_allowed := trim(p_usec_rec.waitlist_allowed);
      p_usec_rec.max_students_per_waitlist := trim(p_usec_rec.max_students_per_waitlist);
      p_usec_rec.minimum_credit_points := trim(p_usec_rec.minimum_credit_points);
      p_usec_rec.maximum_credit_points := trim(p_usec_rec.maximum_credit_points);
      p_usec_rec.variable_increment := trim(p_usec_rec.variable_increment);
      p_usec_rec.lecture_credit_points := trim(p_usec_rec.lecture_credit_points);
      p_usec_rec.lab_credit_points := trim(p_usec_rec.lab_credit_points);
      p_usec_rec.other_credit_points := trim(p_usec_rec.other_credit_points);
      p_usec_rec.clock_hours := trim(p_usec_rec.clock_hours);
      p_usec_rec.work_load_cp_lecture := trim(p_usec_rec.work_load_cp_lecture);
      p_usec_rec.work_load_cp_lab := trim(p_usec_rec.work_load_cp_lab);
      p_usec_rec.continuing_education_units := trim(p_usec_rec.continuing_education_units);
      p_usec_rec.work_load_other := trim(p_usec_rec.work_load_other);
      p_usec_rec.contact_hrs_lecture := trim(p_usec_rec.contact_hrs_lecture);
      p_usec_rec.contact_hrs_lab := trim(p_usec_rec.contact_hrs_lab);
      p_usec_rec.contact_hrs_other := trim(p_usec_rec.contact_hrs_other);
      p_usec_rec.non_schd_required_hrs := trim(p_usec_rec.non_schd_required_hrs);
      p_usec_rec.exclude_from_max_cp_limit := trim(p_usec_rec.exclude_from_max_cp_limit);
      p_usec_rec.claimable_hours := trim(p_usec_rec.claimable_hours);
      p_usec_rec.reference_subtitle := trim(p_usec_rec.reference_subtitle);
      p_usec_rec.reference_short_title := trim(p_usec_rec.reference_short_title);
      p_usec_rec.reference_subtitle_mod_flag := trim(p_usec_rec.reference_subtitle_mod_flag);
      p_usec_rec.reference_class_sch_excl_flag := trim(p_usec_rec.reference_class_sch_excl_flag);
      p_usec_rec.reference_rec_exclusion_flag := trim(p_usec_rec.reference_rec_exclusion_flag);
      p_usec_rec.reference_title := trim(p_usec_rec.reference_title);
      p_usec_rec.reference_attribute_category  := trim(p_usec_rec.reference_attribute_category);
      p_usec_rec.reference_attribute1 := trim(p_usec_rec.reference_attribute1);
      p_usec_rec.reference_attribute2 := trim(p_usec_rec.reference_attribute2);
      p_usec_rec.reference_attribute3 := trim(p_usec_rec.reference_attribute3);
      p_usec_rec.reference_attribute4 := trim(p_usec_rec.reference_attribute4);
      p_usec_rec.reference_attribute5 := trim(p_usec_rec.reference_attribute5);
      p_usec_rec.reference_attribute6 := trim(p_usec_rec.reference_attribute6);
      p_usec_rec.reference_attribute7 := trim(p_usec_rec.reference_attribute7);
      p_usec_rec.reference_attribute8 := trim(p_usec_rec.reference_attribute8);
      p_usec_rec.reference_attribute9 := trim(p_usec_rec.reference_attribute9);
      p_usec_rec.reference_attribute10 := trim(p_usec_rec.reference_attribute10);
      p_usec_rec.reference_attribute11 := trim(p_usec_rec.reference_attribute11);
      p_usec_rec.reference_attribute12 := trim(p_usec_rec.reference_attribute12);
      p_usec_rec.reference_attribute13 := trim(p_usec_rec.reference_attribute13);
      p_usec_rec.reference_attribute14 := trim(p_usec_rec.reference_attribute14);
      p_usec_rec.reference_attribute15 := trim(p_usec_rec.reference_attribute15);
      p_usec_rec.reference_attribute16 := trim(p_usec_rec.reference_attribute16);
      p_usec_rec.reference_attribute17 := trim(p_usec_rec.reference_attribute17);
      p_usec_rec.reference_attribute18 := trim(p_usec_rec.reference_attribute18);
      p_usec_rec.reference_attribute19 := trim(p_usec_rec.reference_attribute19);
      p_usec_rec.reference_attribute20 := trim(p_usec_rec.reference_attribute20);
      p_usec_rec.enrollment_expected := trim(p_usec_rec.enrollment_expected);
      p_usec_rec.enrollment_minimum := trim(p_usec_rec.enrollment_minimum);
      p_usec_rec.enrollment_maximum := trim(p_usec_rec.enrollment_maximum);
      p_usec_rec.advance_maximum := trim(p_usec_rec.advance_maximum);
      p_usec_rec.usec_waitlist_allowed := trim(p_usec_rec.usec_waitlist_allowed);
      p_usec_rec.usec_max_students_per_waitlist := trim(p_usec_rec.usec_max_students_per_waitlist);
      p_usec_rec.override_enrollment_maximum := trim(p_usec_rec.override_enrollment_maximum);
      p_usec_rec.max_auditors_allowed := trim(p_usec_rec.max_auditors_allowed);
      p_usec_rec.not_multiple_section_flag := TRIM(p_usec_rec.not_multiple_section_flag);
      p_usec_rec.sup_unit_cd:=trim(p_usec_rec.sup_unit_cd);
      p_usec_rec.sup_version_number:=trim(p_usec_rec.sup_version_number);
      p_usec_rec.sup_teach_cal_alternate_code := trim(p_usec_rec.sup_teach_cal_alternate_code);
      p_usec_rec.sup_location_cd := trim(p_usec_rec.sup_location_cd);
      p_usec_rec.sup_unit_class := trim(p_usec_rec.sup_unit_class);
      p_usec_rec.default_enroll_flag:=trim(p_usec_rec.default_enroll_flag);
      p_usec_rec.billing_credit_points := TRIM(p_usec_rec.billing_credit_points);
      p_usec_rec.billing_hrs := TRIM(p_usec_rec.billing_hrs);
    END trim_values;

    -- Private procedures for Unit Offering Records

    -- This procedure validates UO parameter values in Unit Section record
    PROCEDURE validate_uo_parameters ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS
    BEGIN
      /* Check for Mandatory Fields */
      IF p_usec_rec.unit_cd IS NULL OR p_usec_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;
      IF p_usec_rec.version_number IS NULL OR p_usec_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;
      IF p_usec_rec.teach_cal_alternate_code IS NULL OR p_usec_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR  THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;
    END validate_uo_parameters;

    -- This procedure will derive values required for Unit Offering.
    PROCEDURE validate_uo_derivations ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS
    l_c_message  VARCHAR2(30);
    BEGIN
      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;
      l_c_message := NULL;
    END validate_uo_derivations;

    -- Validate UO Database Constraints
    PROCEDURE validate_uo_db_cons ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS
    /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    ********************************************************************************************* */
    BEGIN

      /* Primary Key Validation */
      IF igs_ps_unit_ofr_pkg.get_pk_for_validation ( x_unit_cd        => p_usec_rec.unit_cd,
                                                     x_version_number => p_usec_rec.version_number,
                                                     x_cal_type       => l_c_cal_type ) THEN
        p_usec_rec.status := 'K';
        RETURN;
      END IF;

    /* Validate Check Constraints */
      BEGIN
        igs_ps_unit_ofr_pkg.check_constraints ( 'UNIT_CD', p_usec_rec.unit_cd );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'UNIT_CD', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_pkg.check_constraints ( 'CAL_TYPE', l_c_cal_type );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ALT_CODE', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

    /* Validate FK Constraints */
      BEGIN
        IF NOT igs_ca_type_pkg.get_pk_for_validation ( l_c_cal_type ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'CAL_TYPE', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;
      END;

      BEGIN
        IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation ( p_usec_rec.unit_cd, p_usec_rec.version_number ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_VERSION', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;
      END;
    END validate_uo_db_cons;

    -- Main private procedure to create records of Unit Offering.

    PROCEDURE create_uo ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type )
    AS
     /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    14-NOV-2005     Bug # 4730169 addded column abort_flag in the insert to igs_ps_unit_ofr
    ********************************************************************************************* */
    BEGIN

      validate_uo_parameters ( p_usec_rec );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.status_after_validate_uo_parameters',
	'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
        validate_uo_derivations ( p_usec_rec );
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.status_after_validate_uo_derivations',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
        END IF;
      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
        validate_uo_db_cons ( p_usec_rec );
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.status_after_validate_uo_db_cons',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
        END IF;
      END IF;

      IF ( p_usec_rec.status = 'K' ) THEN
        -- If the record is already existing update status as 'Success' and return
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.record is already existing update status as Success and return',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
        END IF;
	p_usec_rec.status := 'S';
        RETURN;
      END IF;
      IF p_calling_context IN ('G','S') THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.calling_context_G_or_S_return',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code);
        END IF;
        RETURN ;
      ELSE
	/* Business validations */
	-- Check if the calendar category is 'TEACHING'
	IF ( p_usec_rec.status = 'S' ) THEN
	  IF NOT igs_ps_validate_lgcy_pkg.validate_cal_cat ( l_c_cal_type, 'TEACHING' ) THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_CALTYPE_TEACHING_CAL' );
	    fnd_msg_pub.add;
	    p_usec_rec.status := 'E';
	  END IF;
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.status_after_Business_validation',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
          END IF;
	END IF;

	IF ( p_usec_rec.status = 'S' ) THEN
	  INSERT INTO igs_ps_unit_ofr
	  (unit_cd,
	   version_number,
	   cal_type,
	   created_by,
	   creation_date,
	   last_updated_by,
	   last_update_date,
	   last_update_login
	  )
	  VALUES
	  (p_usec_rec.unit_cd,
	   p_usec_rec.version_number,
	   l_c_cal_type,
	   g_n_user_id,
	   SYSDATE,
	   g_n_user_id,
	   SYSDATE,
	   g_n_login_id
	  );
	  p_usec_rec.status := 'S';
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.Record_Inserted',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code);
          END IF;
	END IF;
      END IF;

    END create_uo;

    -- Private procedures for Unit Offering Pattern Record
    -- This procedure will derive values required for Unit Offering Pattern.
    PROCEDURE validate_uop_derivations ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS

    BEGIN

      -- Default waitlist_allowed and max students per waitlist
      IF p_usec_rec.waitlist_allowed IS NULL THEN
        p_usec_rec.waitlist_allowed := 'N';
      END IF;

      IF p_usec_rec.max_students_per_waitlist IS NULL THEN
        p_usec_rec.max_students_per_waitlist := 0;
      END IF;

    END validate_uop_derivations;

    -- Procedure to validate Database constraints for Unit Offering Pattern Records.
    PROCEDURE validate_uop_db_cons ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS

      CURSOR cur_rowid ( cp_c_unit_cd    IN  igs_ps_unit_ofr_pat.unit_cd%TYPE,
                         cp_n_ver_num    IN  igs_ps_unit_ofr_pat.version_number%TYPE,
			 cp_c_cal_type   IN  igs_ps_unit_ofr_pat.cal_type%TYPE,
			 cp_n_ci_seq_num IN igs_ps_unit_ofr_pat.ci_sequence_number%TYPE) IS
      SELECT delete_flag
      FROM  igs_ps_unit_ofr_pat_all
      WHERE unit_cd = cp_c_unit_cd  AND
      version_number = cp_n_ver_num  AND
      cal_type = cp_c_cal_type  AND
      ci_sequence_number = cp_n_ci_seq_num;
      rec_rowid cur_rowid%ROWTYPE;

    BEGIN

      /* Pk validation for IGS_PS_UNIT_OFR_PAT , having delete_flag implementation*/
      l_b_uop_deleted := FALSE;
      OPEN cur_rowid( p_usec_rec.unit_cd,p_usec_rec.version_number,l_c_cal_type,l_n_seq_num);
      FETCH  cur_rowid INTO rec_rowid;
      IF cur_rowid%FOUND THEN
        CLOSE cur_rowid;
        IF rec_rowid.delete_flag ='N' THEN
          p_usec_rec.status := 'K';
          RETURN;
        ELSE
          l_b_uop_deleted := TRUE;
        END IF;
      ELSE
        CLOSE cur_rowid;
      END IF;


      /* Check for Foreign Key Validations */

      -- Check for existence of Calender Instance
      IF NOT igs_ca_inst_pkg.get_pk_for_validation ( x_cal_type        => l_c_cal_type,
                                                     x_sequence_number => l_n_seq_num ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      -- Check for existence of Unit Offering
      IF NOT igs_ps_unit_ofr_pkg.get_pk_for_validation ( x_unit_cd        => p_usec_rec.unit_cd,
                                                         x_version_number => p_usec_rec.version_number,
                                                         x_cal_type       => l_c_cal_type ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_OFR_PAT', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      -- Check Constraints checking.
      IF p_usec_rec.waitlist_allowed IS NOT NULL THEN
         BEGIN
           igs_ps_unit_ofr_pat_pkg.check_constraints ( 'WAITLIST_ALLOWED', p_usec_rec.waitlist_allowed);
         EXCEPTION
           WHEN OTHERS THEN
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'WAITLIST_ALLOWED', 'LEGACY_TOKENS', TRUE);
             p_usec_rec.status := 'E';
         END;
       END IF;

      IF p_usec_rec.max_students_per_waitlist IS NOT NULL THEN
         BEGIN
           igs_ps_unit_ofr_pat_pkg.check_constraints ( 'MAX_STUDENTS_PER_WAITLIST', p_usec_rec.max_students_per_waitlist);
         EXCEPTION
           WHEN OTHERS THEN
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999', 'MAX_STUDENTS_PER_WAITLIST', 'LEGACY_TOKENS', TRUE);
             p_usec_rec.status := 'E';
         END;
       END IF;

    END validate_uop_db_cons;

    -- Main private procedure to create records of Unit Offering Pattern.

    PROCEDURE create_uop ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type )
    AS
    BEGIN

      validate_uop_derivations ( p_usec_rec );
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.status_after_validate_uop_parameters',
	'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
        validate_uop_db_cons ( p_usec_rec );
	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.status_after_validate_uop_db_cons',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
        END IF;
      END IF;


      IF ( p_usec_rec.status = 'K' ) THEN
        -- If the record is already existing update status as 'Success' and return
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.record is already existing update status as Success and return',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
        END IF;
	p_usec_rec.status := 'S';
        RETURN;
      END IF;
      IF p_calling_context IN ('G','S') THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.calling_context_G_or_S_return',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code);
        END IF;
        RETURN ;
      ELSE
	/* Business validations */
	IF ( p_usec_rec.status = 'S' ) THEN

	  -- Check if waitlist_allowed is 'Y' then check if waitlisting is allowed at organization level.
	  IF p_usec_rec.waitlist_allowed = 'Y' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.validate_waitlist_allowed ( l_c_cal_type, l_n_seq_num ) THEN
	      fnd_message.set_name ( 'IGS', 'IGS_EN_WAIT_NOT_ALW' );
	      fnd_msg_pub.add;
	      p_usec_rec.status := 'E';
	    END IF;
	  ELSE
	    -- default max_students_per_waitlist to 0
	    p_usec_rec.max_students_per_waitlist := 0;
	  END IF;

	  -- If Waitlist allowed is Yes and Max Students per waitlist is Zero then log a warning.
	  IF ( p_usec_rec.waitlist_allowed = 'Y' AND p_usec_rec.max_students_per_waitlist = 0 ) THEN
	      fnd_message.set_name ( 'IGS', 'IGS_PS_LGCY_MAX_STD_GT_0' );
	      fnd_msg_pub.add;
	      p_usec_rec.status := 'W';
	  END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.status_after_Business_validation',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Status:'||p_usec_rec.status);
          END IF;

	END IF;

	IF ( p_usec_rec.status = 'S' ) THEN
	  IF l_b_uop_deleted THEN
	    UPDATE igs_ps_unit_ofr_pat_all
	    SET
	      waitlist_allowed = p_usec_rec.waitlist_allowed,
	      max_students_per_waitlist = p_usec_rec.max_students_per_waitlist,
	      delete_flag = 'N',
	      created_by = g_n_user_id,
	      creation_date = SYSDATE,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
	      last_update_login = g_n_login_id
	    WHERE unit_cd = p_usec_rec.unit_cd
	    AND  version_number = p_usec_rec.version_number
	    AND  cal_type = l_c_cal_type
	    AND  ci_sequence_number = l_n_seq_num;
	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.Record_updated_when_uop_deleted',
	      'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_rec.teach_cal_alternate_code);
            END IF;
	  ELSE
	    INSERT INTO igs_ps_unit_ofr_pat_all
	    (unit_cd,
	     version_number,
	     cal_type,
	     ci_sequence_number,
	     ci_start_dt,
	     ci_end_dt,
	     waitlist_allowed,
	     max_students_per_waitlist,
	     delete_flag,
	     abort_flag,
	     created_by,
	     creation_date,
	     last_updated_by,
	     last_update_date,
	     last_update_login
	    )
	    VALUES
	    (p_usec_rec.unit_cd,
	     p_usec_rec.version_number,
	     l_c_cal_type,
	     l_n_seq_num,
	     l_d_start_dt,
	     l_d_end_dt,
	     p_usec_rec.waitlist_allowed,
	     p_usec_rec.max_students_per_waitlist,
	     'N',
	     'N',
	     g_n_user_id,
	     SYSDATE,
	     g_n_user_id,
	     SYSDATE,
	     g_n_login_id
	    );

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.Record_Inserted',
	      'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_rec.teach_cal_alternate_code);
            END IF;
	  END IF;
	  p_usec_rec.status := 'S';
	END IF;
      END IF;
    END create_uop;

    -- Private procedures for Unit Offering Option Records

    -- This procedure validates UOO parameter values in Unit Section record
    PROCEDURE validate_uoo_parameters ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS
    BEGIN

      /* Check for Mandatory Fields */
      IF p_usec_rec.location_cd IS NULL OR p_usec_rec.location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;
      IF p_usec_rec.unit_class IS NULL OR p_usec_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

    END validate_uoo_parameters;

    -- This procedure will derive values required for Unit Offering Option.
    PROCEDURE validate_uoo_derivations ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS

    /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sarakshi  11-Sep-2003       Enh#3052452,dervied teh value of sup_uoo_id.
    sarakshi  22-Aug-2003       Bug#304509, defaulting the value of Not Multiple Unit Section Flag
    ********************************************************************************************* */
    l_c_sup_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
    l_n_sup_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
    l_d_sup_start_dt igs_ca_inst_all.start_dt%TYPE;
    l_d_sup_end_dt   igs_ca_inst_all.end_dt%TYPE;
    l_c_message      VARCHAR2(30);

    BEGIN


      --Either all column values of sup_unit_cd,sup_version_number,sup_teach_cal_alternate_code,sup_location_cd,sup_unit_class neds to be passed or none
      l_n_sup_uoo_id :=NULL;
      l_c_relation_type := NULL;

      IF (p_usec_rec.sup_unit_cd IS NOT NULL OR p_usec_rec.sup_version_number IS NOT NULL OR
         p_usec_rec.sup_teach_cal_alternate_code IS NOT NULL OR p_usec_rec.sup_location_cd IS NOT NULL OR p_usec_rec.sup_unit_class IS NOT NULL)
         AND
         (p_usec_rec.sup_unit_cd IS NULL OR p_usec_rec.sup_version_number IS NULL OR
         p_usec_rec.sup_teach_cal_alternate_code IS NULL OR p_usec_rec.sup_location_cd IS NULL OR
         p_usec_rec.sup_unit_class IS NULL) THEN

         fnd_message.set_name ( 'IGS', 'IGS_PS_NO_SUFF_VAL_SUP');
         fnd_msg_pub.add;
         p_usec_rec.status := 'E';
      ELSIF p_usec_rec.sup_unit_cd IS NOT NULL THEN


        -- Derive Calander Type and Sequence Number for sup alternate code
        igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_rec.sup_teach_cal_alternate_code,
                                               p_cal_type           => l_c_sup_cal_type,
                                               p_ci_sequence_number => l_n_sup_seq_num,
                                               p_start_dt           => l_d_sup_start_dt,
                                               p_end_dt             => l_d_sup_end_dt,
                                               p_return_status      => l_c_message );
        IF ( l_c_message <> 'SINGLE' ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'SUP_TEACH_CAL_ALT_CD', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;


        -- Derive sup_uoo_id
        l_c_message := NULL;
        igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_rec.sup_unit_cd,
                                              p_ver_num    => p_usec_rec.sup_version_number,
                                              p_cal_type   => l_c_sup_cal_type,
                                              p_seq_num    => l_n_sup_seq_num,
                                              p_loc_cd     => p_usec_rec.sup_location_cd,
                                              p_unit_class => p_usec_rec.sup_unit_class,
                                              p_uoo_id     => l_n_sup_uoo_id,
                                              p_message    => l_c_message );
        IF ( l_c_message IS NOT NULL ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;

      END IF;

    END validate_uoo_derivations;

    -- Procedure to validate Database constraints for Unit Offering Option Records.
    PROCEDURE validate_uoo_db_cons ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,p_insert_update VARCHAR2 ) AS
    /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sarakshi  11-Sep-2003    Enh#3052452, Added call to igs_ps_unit_ofr_opt_pkg.check_constraints
                             for validating default_enroll_flag.
    vvutukur  19-Aug-2003    Enh#3045069.PSP Enh Build. Added call to igs_ps_unit_ofr_opt_pkg.check_constraints
                             for validating not_multiple_section_flag.
    ********************************************************************************************* */
    BEGIN

      IF p_insert_update = 'I'  THEN
      /* Check for Unique Key Validation */
        IF igs_ps_unit_ofr_opt_pkg.get_pk_for_validation ( x_unit_cd            => p_usec_rec.unit_cd,
                                                         x_version_number     => p_usec_rec.version_number,
                                                         x_cal_type           => l_c_cal_type,
                                                         x_ci_sequence_number => l_n_seq_num,
                                                         x_location_cd        => p_usec_rec.location_cd,
                                                         x_unit_class         => p_usec_rec.unit_class ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'W';
          RETURN;
        END IF;
      END IF;

      /* Check for Check Constraints */

      --Validate whether the column not_multiple_section_flag has value other than 'Y' or 'N'.
      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints('NOT_MULTIPLE_SECTION_FLAG',p_usec_rec.not_multiple_section_flag);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N',
                                           'NOT_MULTIPLE_SECTION_FLAG',
                                           'LEGACY_TOKENS',
                                           TRUE);
          p_usec_rec.status :='E';
      END;

      -- Unit Class should be in Upper Case
      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'UNIT_CLASS', p_usec_rec.unit_class );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'UNIT_CLASS', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      --call number cannot be negative
      IF p_usec_rec.call_number IS NOT NULL  AND p_usec_rec.call_number < 1 THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_1_999999', 'CALL_NUMBER', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
      END IF;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'GRADING_SCHEMA_CD', p_usec_rec.grading_schema_cd );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'USEC_GRADING_SCHM_CD', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'LOCATION_CD', p_usec_rec.location_cd );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'LOCATION_CD', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'UNIT_QUOTA', p_usec_rec.unit_quota );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999', 'UNIT_QUOTA', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      IF p_usec_rec.unit_quota_reserved_places IS NOT NULL THEN
      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'UNIT_QUOTA_RESERVED_PLACES', p_usec_rec.unit_quota_reserved_places );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999', 'UNIT_QUOTA_RESERVED_PLACES', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;
      END IF;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'CI_SEQUENCE_NUMBER', l_n_seq_num );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999', 'CAL_SEQ_NUM', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'GRADING_SCHEMA_PRCDNCE_IND', p_usec_rec.grading_schema_prcdnce_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'GRADING_SCHEMA_PRCDNCE_IND', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'IVRS_AVAILABLE_IND', p_usec_rec.ivrs_available_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'IVRS_AVAILABLE_IND', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'OFFERED_IND', p_usec_rec.offered_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'OFFERED_IND', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'NON_STD_USEC_IND', p_usec_rec.non_std_usec_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'NON_STD_USEC_IND', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'AUDITABLE_IND', p_usec_rec.auditable_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'AUDITABLE_IND', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints ( 'AUDIT_PERMISSION_IND', p_usec_rec.audit_permission_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'AUDIT_PERMISSION_IND', 'LEGACY_TOKENS', TRUE);
          p_usec_rec.status := 'E';
      END;

      -- Check whether Owner Organization Unit Code is valid, if it is passed.
      IF ( p_usec_rec.owner_org_unit_cd IS NOT NULL ) THEN
        IF NOT igs_ps_validate_lgcy_pkg.validate_org_unit_cd ( p_usec_rec.owner_org_unit_cd, 'UNIT_SECTION_LGCY' ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ORG_UNIT_CD', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;
      END IF;

      -- Check for existence of Revenue Account Code, if passed
      IF ( p_usec_rec.rev_account_cd IS NOT NULL ) THEN
        IF NOT igs_fi_acc_pkg.get_pk_for_validation ( x_account_cd => p_usec_rec.rev_account_cd ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'REV_ACC_CD', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;
      END IF;

      /* Check for Foreign Key Validations */

      -- Check for existence of Unit Offering Pattern
      IF NOT igs_ps_unit_ofr_pat_pkg.get_pk_for_validation ( x_unit_cd            => p_usec_rec.unit_cd,
                                                             x_version_number     => p_usec_rec.version_number,
                                                             x_cal_type           => l_c_cal_type,
                                                             x_ci_sequence_number => l_n_seq_num ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_OFR_PAT', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      -- Check for existence of Location Code
      IF NOT igs_ad_location_pkg.get_pk_for_validation ( p_usec_rec.location_cd ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      -- Check for existence of Unit Status
      IF NOT igs_as_unit_class_pkg.get_pk_for_validation ( p_usec_rec.unit_class ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      -- Check for existence of Grading Schema
      IF NOT igs_as_grd_schema_pkg.get_pk_for_validation ( p_usec_rec.grading_schema_cd, p_usec_rec.gs_version_number ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'GRADINGS_SCHEMA_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      -- Check the existence of Unit Contact Number, if passed
      IF p_usec_rec.unit_contact_number IS NOT NULL THEN
        IF NOT igs_pe_person_pkg.get_pk_for_validation ( l_n_unit_contact_id ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_CONT_NUM', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
        END IF;
      END IF;

      -- Check the Unit Section Status
      IF NOT igs_lookups_view_pkg.get_pk_for_validation('UNIT_SECTION_STATUS',p_usec_rec.unit_section_status) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'USEC_STATUS', 'LEGACY_TOKENS', FALSE);
          p_usec_rec.status := 'E';
      END IF;

      --Validate default enroll flag
      BEGIN
        igs_ps_unit_ofr_opt_pkg.check_constraints('DEFAULT_ENROLL_FLAG',p_usec_rec.default_enroll_flag);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','DEFAULT_ENROLL_FLAG','LEGACY_TOKENS',TRUE);
          p_usec_rec.status :='E';
      END;


    END validate_uoo_db_cons;



    -- Main private procedure to create records of Unit Offering Option.

    PROCEDURE create_uoo ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type )
    /***********************************************************************************************
    Created By     :
    Date Created By:
    Purpose        :
    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sarakshi  31-Aug-2005   Bug#4543368, while creating cerdit points and limits record, checking whether all the values are null, if all
                            the values are null then do no proceed with the insert/update for these two tables.
    sarakshi  12-Apr-2004   bug#3555871, Added code to populate the call_number field if teh profile option is AUTO
    sarakshi  11-Sep-2003   Enh#3052452,Added new column sup_uoo_id,relation_type,default_enroll_flag to the insert statement.
                            Also updated the superior unit section record.
    vvutukur  05-Aug-2003   Enh#3045069.PSP Enh Build. Added new column not_multiple_section_flag while insertion.
    ********************************************************************************************* */
    AS

    CURSOR c_usec_check(cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT 'X'
    FROM   igs_ps_unit_ofr_opt_all
    WHERE  uoo_id=cp_uoo_id
    AND    relation_type='SUPERIOR';
    l_c_var  VARCHAR2(1);

    CURSOR cur_int_pat(cp_unit_cd IN VARCHAR2,
                    cp_version_number IN NUMBER,
		    cp_cal_type IN VARCHAR2,
		    cp_seq_num  IN NUMBER) IS
    SELECT *
    FROM  igs_ps_sch_pat_int
    WHERE unit_cd=cp_unit_cd
    AND version_number=cp_version_number
    AND calendar_type =cp_cal_type
    AND sequence_number= cp_seq_num
    AND  abort_flag='N';
    l_cur_int_pat  cur_int_pat%ROWTYPE;

    CURSOR cur_int_usec(cp_unit_cd IN VARCHAR2,
			cp_version_number IN NUMBER,
			cp_cal_type IN VARCHAR2,
			cp_seq_num  IN NUMBER,
			cp_location_cd IN VARCHAR2,
			cp_unit_class IN VARCHAR2) IS
    SELECT *
    FROM  igs_ps_sch_usec_int_all
    WHERE unit_cd=cp_unit_cd
    AND version_number=cp_version_number
    AND calendar_type =cp_cal_type
    AND sequence_number= cp_seq_num
    AND location_cd=cp_location_cd
    AND unit_class=cp_unit_class
    AND  abort_flag='N';
    l_cur_int_usec  cur_int_usec%ROWTYPE;


    FUNCTION check_insert_update ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type) RETURN VARCHAR2 IS
     CURSOR c_usec(cp_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE,cp_seq_num igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE) IS
     SELECT 'X'
     FROM  igs_ps_unit_ofr_opt_all
     WHERE unit_cd = p_usec_rec.unit_cd
     AND version_number =  p_usec_rec.version_number
     AND ci_sequence_number =cp_seq_num
     AND unit_class = p_usec_rec.unit_class
     AND location_cd = p_usec_rec.location_cd
     AND cal_type = cp_cal_type ;
     c_usec_rec c_usec%ROWTYPE;

    BEGIN
      OPEN c_usec( l_c_cal_type,l_n_seq_num);
      FETCH c_usec INTO c_usec_rec;
      IF c_usec%NOTFOUND THEN
        CLOSE c_usec;
        RETURN 'I';
      ELSE
        CLOSE c_usec;
	RETURN 'U';
      END IF;

    END check_insert_update;

    PROCEDURE Assign_default(  p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,p_insert_update VARCHAR2 ) AS

      CURSOR c_usec(cp_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE,cp_seq_num igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE) IS
      SELECT *
      FROM   igs_ps_unit_ofr_opt_all
      WHERE  unit_cd = p_usec_rec.unit_cd
      AND    version_number =  p_usec_rec.version_number
      AND    ci_sequence_number =cp_seq_num
      AND    unit_class = p_usec_rec.unit_class
      AND    location_cd = p_usec_rec.location_cd
      AND    cal_type = cp_cal_type ;

      CURSOR c_audit_info ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
			    cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
      SELECT auditable_ind, audit_permission_ind
      FROM   igs_ps_unit_ver_all
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number;

      CURSOR c_grd_sch ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
			 cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
      SELECT grading_schema_code, grd_schm_version_number
      FROM   igs_ps_unit_grd_schm
      WHERE  unit_code = cp_unit_cd
      AND    unit_version_number = cp_version_number
      AND    default_flag = 'Y';

      CURSOR c_ivr_enrol_ind ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
			       cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
      SELECT ivr_enrol_ind
      FROM   igs_ps_unit_ver_all
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number;

      CURSOR c_ss_enrol_ind ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
			      cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
      SELECT ss_enrol_ind
      FROM   igs_ps_unit_ver_all
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number;

      CURSOR c_muiltiple_section_flag ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
					cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
      SELECT same_teaching_period
      FROM   igs_ps_unit_ver_all
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number;

      CURSOR c_org_unit_cd ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
			     cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
      SELECT owner_org_unit_cd
      FROM   igs_ps_unit_ver_all
      WHERE  unit_cd = cp_unit_cd
      AND    version_number = cp_version_number;

      c_usec_rec c_usec%ROWTYPE;
      l_same_teaching_period  igs_ps_unit_ver_all.same_teaching_period%TYPE;

    BEGIN

      IF p_insert_update = 'I' THEN
        IF p_usec_rec.offered_ind IS NULL THEN
          p_usec_rec.offered_ind := 'Y';
        END IF;

	IF p_usec_rec.state_financial_aid IS NULL THEN
	  p_usec_rec.state_financial_aid := 'N';
	END IF;

	IF p_usec_rec.grading_schema_prcdnce_ind IS NULL THEN
	  p_usec_rec.grading_schema_prcdnce_ind := 'N';
	END IF;

	IF p_usec_rec.federal_financial_aid IS NULL THEN
	  p_usec_rec.federal_financial_aid := 'N';
	END IF;

	IF p_usec_rec.ss_enrol_ind IS NULL THEN
	  p_usec_rec.ss_enrol_ind := 'N';
	END IF;

	IF p_usec_rec.attendance_required_ind IS NULL THEN
	  p_usec_rec.attendance_required_ind := 'N';
	END IF;

	IF p_usec_rec.reserved_seating_allowed IS NULL THEN
	  p_usec_rec.reserved_seating_allowed := 'Y';
	END IF;

	IF p_usec_rec.special_permission_ind IS NULL THEN
	  p_usec_rec.special_permission_ind := 'N';
	END IF;

	IF p_usec_rec.ss_display_ind IS NULL THEN
	  p_usec_rec.ss_display_ind := 'N';
	END IF;

	IF p_usec_rec.anon_unit_grading_ind IS NULL THEN
	  p_usec_rec.anon_unit_grading_ind := 'N';
	END IF;

	IF p_usec_rec.anon_assess_grading_ind IS NULL THEN
	  p_usec_rec.anon_assess_grading_ind := 'N';
	END IF;

	-- If ivrs_available_ind is null then default it to unit level
	IF p_usec_rec.ivrs_available_ind IS NULL THEN
	  OPEN c_ivr_enrol_ind ( p_usec_rec.unit_cd, p_usec_rec.version_number );
	  FETCH c_ivr_enrol_ind INTO p_usec_rec.ivrs_available_ind;
	  CLOSE c_ivr_enrol_ind;
	END IF;

	-- If ss_enrol_ind is null then default it to unit level
	IF p_usec_rec.ss_enrol_ind IS NULL THEN
	  OPEN c_ss_enrol_ind ( p_usec_rec.unit_cd, p_usec_rec.version_number );
	  FETCH c_ss_enrol_ind INTO p_usec_rec.ss_enrol_ind;
	  CLOSE c_ivr_enrol_ind;
	END IF;

	-- If unit contact number is not null the derive person id associated with it.
	IF p_usec_rec.unit_contact_number IS NOT NULL THEN
	  igs_ps_validate_lgcy_pkg.get_party_id( p_usec_rec.unit_contact_number,l_n_unit_contact_id );
	  IF l_n_unit_contact_id IS NULL THEN
	      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'UNIT_CONT_NUM', 'LEGACY_TOKENS', FALSE);
	      p_usec_rec.status := 'E';
	  END IF;
	END IF;

	-- If auditable_ind and audit_permission_ind are not passed then derive thier unit level values
	IF p_usec_rec.auditable_ind IS NULL AND p_usec_rec.audit_permission_ind IS NULL THEN
	  OPEN c_audit_info ( p_usec_rec.unit_cd, p_usec_rec.version_number );
	  FETCH c_audit_info INTO p_usec_rec.auditable_ind, p_usec_rec.audit_permission_ind;
	  CLOSE c_audit_info;
	END IF;

	-- Derive unit level default grading schema and version number if they are not passed at unit section level
	IF ( p_usec_rec.grading_schema_cd IS NULL AND p_usec_rec.gs_version_number IS NULL ) THEN
	  OPEN c_grd_sch ( p_usec_rec.unit_cd, p_usec_rec.version_number );
	  FETCH c_grd_sch into p_usec_rec.grading_schema_cd, p_usec_rec.gs_version_number;
	  IF ( c_grd_sch%NOTFOUND ) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'GRADINGS_SCHEMA_CD', 'LEGACY_TOKENS', FALSE);
	    p_usec_rec.status := 'E';
	  END IF;
	  CLOSE c_grd_sch;
	END IF;

	--Derive the value of Multiple Unit sections flag
	IF p_usec_rec.not_multiple_section_flag IS NULL THEN
	   OPEN c_muiltiple_section_flag( p_usec_rec.unit_cd, p_usec_rec.version_number );
	   FETCH c_muiltiple_section_flag INTO l_same_teaching_period;
	   CLOSE c_muiltiple_section_flag;
	   IF l_same_teaching_period = 'Y' THEN
	     p_usec_rec.not_multiple_section_flag := 'N';
	   ELSE
	     p_usec_rec.not_multiple_section_flag := 'Y';
	   END IF;
	END IF;

	--Default the value of default_enrol_flag to N if not passed
	IF p_usec_rec.default_enroll_flag IS NULL THEN
	  p_usec_rec.default_enroll_flag := 'N';
	END IF;

	   -- Derive Organization Unit Code from unit level if it is not provided at unit section.
	IF p_usec_rec.owner_org_unit_cd IS NULL THEN
	  OPEN c_org_unit_cd ( p_usec_rec.unit_cd, p_usec_rec.version_number );
	  FETCH c_org_unit_cd INTO l_c_org_unit_cd;
	  CLOSE c_org_unit_cd;
	END IF;

      END IF;

      IF p_insert_update = 'U' THEN
         OPEN c_usec( l_c_cal_type,l_n_seq_num);
         FETCH c_usec INTO c_usec_rec;
         CLOSE c_usec;

         IF p_usec_rec.ivrs_available_ind  IS NULL  THEN
	    p_usec_rec.ivrs_available_ind  := c_usec_rec.ivrs_available_ind ;
	 ELSIF  p_usec_rec.ivrs_available_ind  = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.ivrs_available_ind  :='N';
	 END IF;

	 IF p_usec_rec.call_number IS NULL THEN
	    p_usec_rec.call_number := c_usec_rec.call_number;
	 ELSIF p_usec_rec.call_number = FND_API.G_MISS_NUM THEN
	    IF fnd_profile.value('IGS_PS_CALL_NUMBER') = 'USER_DEFINED' THEN
  	      p_usec_rec.call_number :=NULL;
            ELSE
              p_usec_rec.call_number := c_usec_rec.call_number;
            END IF;
         ELSE
           IF (fnd_profile.value('IGS_PS_CALL_NUMBER') = 'AUTO' AND p_usec_rec.call_number IS NOT NULL) THEN

  	     -- Profile is AUTO and values is passed to call_number so raise error
	     igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'CALL_NUMBER', 'LEGACY_TOKENS', FALSE);
	     p_usec_rec.status := 'E';
           END IF;
	 END IF;

         IF p_usec_rec.unit_section_status IS NULL THEN
	    p_usec_rec.unit_section_status :=c_usec_rec.unit_section_status;
	 ELSIF p_usec_rec.unit_section_status  = FND_API.G_MISS_CHAR THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'USEC_STATUS', 'LEGACY_TOKENS', FALSE);
	    p_usec_rec.status := 'E';
	 END IF;

	 IF p_usec_rec.unit_section_start_date IS NULL THEN
	    p_usec_rec.unit_section_start_date :=c_usec_rec.unit_section_start_date;
	 ELSIF p_usec_rec.unit_section_start_date = FND_API.G_MISS_DATE THEN
	    p_usec_rec.unit_section_start_date :=NULL;
	 END IF;

	 IF p_usec_rec.unit_section_end_date IS NULL THEN
	    p_usec_rec.unit_section_end_date := c_usec_rec.unit_section_end_date;
	 ELSIF p_usec_rec.unit_section_end_date = FND_API.G_MISS_DATE THEN
	    p_usec_rec.unit_section_end_date :=NULL;
	 END IF;

	 IF p_usec_rec.offered_ind IS NULL THEN
	    p_usec_rec.offered_ind := c_usec_rec.offered_ind;
	 ELSIF p_usec_rec.offered_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.offered_ind :='N';
	 END IF;

	 IF p_usec_rec.state_financial_aid IS NULL THEN
	    p_usec_rec.state_financial_aid := c_usec_rec.state_financial_aid;
	 ELSIF p_usec_rec.state_financial_aid = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.state_financial_aid :='N';
	 END IF;

	 IF p_usec_rec.grading_schema_prcdnce_ind IS NULL THEN
	    p_usec_rec.grading_schema_prcdnce_ind := c_usec_rec.grading_schema_prcdnce_ind;
	 ELSIF p_usec_rec.grading_schema_prcdnce_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.grading_schema_prcdnce_ind :='N';
	 END IF;

	 IF p_usec_rec.federal_financial_aid IS NULL THEN
	    p_usec_rec.federal_financial_aid := c_usec_rec.federal_financial_aid;
	 ELSIF p_usec_rec.federal_financial_aid = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.federal_financial_aid :='N';
	 END IF;

	 IF p_usec_rec.unit_quota IS NULL THEN
	    p_usec_rec.unit_quota := c_usec_rec.unit_quota;
	 ELSIF p_usec_rec.unit_quota = FND_API.G_MISS_NUM THEN
	    p_usec_rec.unit_quota :=NULL;
	 END IF;

	 IF p_usec_rec.unit_quota_reserved_places IS NULL THEN
	    p_usec_rec.unit_quota_reserved_places := c_usec_rec.unit_quota_reserved_places;
	 ELSIF p_usec_rec.unit_quota_reserved_places = FND_API.G_MISS_NUM THEN
	    p_usec_rec.unit_quota_reserved_places :=NULL;
	 END IF;

	 IF p_usec_rec.institutional_financial_aid IS NULL THEN
	    p_usec_rec.institutional_financial_aid := c_usec_rec.institutional_financial_aid;
	 ELSIF p_usec_rec.institutional_financial_aid = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.institutional_financial_aid :='N';
	 END IF;

	 IF p_usec_rec.grading_schema_cd IS NULL THEN
	    p_usec_rec.grading_schema_cd := c_usec_rec.grading_schema_cd;
	 ELSIF p_usec_rec.grading_schema_cd = FND_API.G_MISS_CHAR THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'GRADINGS_SCHEMA_CD', 'LEGACY_TOKENS', FALSE);
	    p_usec_rec.status := 'E';
	 END IF;

	 IF p_usec_rec.gs_version_number IS NULL THEN
	    p_usec_rec.gs_version_number := c_usec_rec.gs_version_number;
	 ELSIF p_usec_rec.gs_version_number = FND_API.G_MISS_NUM THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'GS_VERSION_NUMBER', 'LEGACY_TOKENS', FALSE);
	    p_usec_rec.status := 'E';
	 END IF;

	 IF p_usec_rec.unit_contact_number IS NULL THEN
	    p_usec_rec.unit_contact_number := c_usec_rec.unit_contact;
	 ELSIF p_usec_rec.unit_contact_number = FND_API.G_MISS_NUM THEN
	    p_usec_rec.unit_contact_number :=NULL;
	 END IF;

	 IF p_usec_rec.ss_enrol_ind IS NULL THEN
	    p_usec_rec.ss_enrol_ind := c_usec_rec.ss_enrol_ind;
	 ELSIF p_usec_rec.ss_enrol_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.ss_enrol_ind :='N';
	 END IF;

	 IF p_usec_rec.owner_org_unit_cd IS NULL THEN
	    p_usec_rec.owner_org_unit_cd := c_usec_rec.owner_org_unit_cd;
	 ELSIF p_usec_rec.owner_org_unit_cd = FND_API.G_MISS_CHAR THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'OWNER_ORG_UNIT_CD', 'LEGACY_TOKENS', FALSE);
	    p_usec_rec.status := 'E';
	 END IF;

	 IF p_usec_rec.attendance_required_ind IS NULL THEN
	    p_usec_rec.attendance_required_ind := c_usec_rec.attendance_required_ind;
	 ELSIF p_usec_rec.attendance_required_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.attendance_required_ind :='N';
	 END IF;

	 IF p_usec_rec.reserved_seating_allowed IS NULL THEN
	    p_usec_rec.reserved_seating_allowed := c_usec_rec.reserved_seating_allowed;
	 ELSIF p_usec_rec.reserved_seating_allowed = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.reserved_seating_allowed :='N';
	 END IF;

	 IF p_usec_rec.special_permission_ind IS NULL THEN
	    p_usec_rec.special_permission_ind := c_usec_rec.special_permission_ind;
	 ELSIF p_usec_rec.special_permission_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.special_permission_ind :='N';
	 END IF;

	 IF p_usec_rec.ss_display_ind IS NULL THEN
	    p_usec_rec.ss_display_ind := c_usec_rec.ss_display_ind;
	 ELSIF p_usec_rec.ss_display_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.ss_display_ind :='N';
	 END IF;

	 IF p_usec_rec.rev_account_cd IS NULL THEN
	    p_usec_rec.rev_account_cd := c_usec_rec.rev_account_cd;
	 ELSIF p_usec_rec.rev_account_cd = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.rev_account_cd :=NULL;
	 END IF;

	 IF p_usec_rec.anon_unit_grading_ind IS NULL THEN
	    p_usec_rec.anon_unit_grading_ind := c_usec_rec.anon_unit_grading_ind;
	 ELSIF p_usec_rec.anon_unit_grading_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.anon_unit_grading_ind :='N';
	 END IF;

	 IF p_usec_rec.anon_assess_grading_ind IS NULL THEN
	    p_usec_rec.anon_assess_grading_ind := c_usec_rec.anon_assess_grading_ind;
	 ELSIF p_usec_rec.anon_assess_grading_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.anon_assess_grading_ind :='N';
	 END IF;

	 IF p_usec_rec.non_std_usec_ind IS NULL THEN
	    p_usec_rec.non_std_usec_ind := c_usec_rec.non_std_usec_ind;
	 ELSIF p_usec_rec.non_std_usec_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.non_std_usec_ind :='N';
	 END IF;

	 IF p_usec_rec.auditable_ind IS NULL THEN
	    p_usec_rec.auditable_ind := c_usec_rec.auditable_ind;
	 ELSIF p_usec_rec.auditable_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.auditable_ind :='N';
	 END IF;

	 IF p_usec_rec.audit_permission_ind IS NULL THEN
	    p_usec_rec.audit_permission_ind := c_usec_rec.audit_permission_ind;
	 ELSIF p_usec_rec.audit_permission_ind = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.audit_permission_ind :='N';
	 END IF;

	 IF p_usec_rec.not_multiple_section_flag IS NULL THEN
	    p_usec_rec.not_multiple_section_flag := c_usec_rec.not_multiple_section_flag;
	 ELSIF p_usec_rec.not_multiple_section_flag = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.not_multiple_section_flag :='N';
	 END IF;

	 IF p_usec_rec.default_enroll_flag IS NULL THEN
	    p_usec_rec.default_enroll_flag := c_usec_rec.default_enroll_flag;
	 ELSIF p_usec_rec.default_enroll_flag = FND_API.G_MISS_CHAR THEN
	    p_usec_rec.default_enroll_flag :='N';
	 END IF;

      END IF;

    END Assign_default;


    BEGIN

      validate_uoo_parameters ( p_usec_rec );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_validate_uoo_parameters',
	'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
        validate_uoo_derivations ( p_usec_rec );


	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_validate_uoo_derivations',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	END IF;

      END IF;

      --Find out whether it is insert/update of record
      l_insert_update:='I';
      IF p_usec_rec.status = 'S' AND p_calling_context IN ('G', 'S') THEN
         l_insert_update:= check_insert_update(p_usec_rec);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_check_insert_update',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	  END IF;

      END IF;

      IF p_usec_rec.status = 'S' AND p_calling_context ='S' THEN
        IF igs_ps_validate_lgcy_pkg.check_import_allowed( p_unit_cd => p_usec_rec.unit_cd,
	                                                  p_version_number =>p_usec_rec.version_number,
							  p_alternate_code =>p_usec_rec.teach_cal_alternate_code,
							  p_location_cd => p_usec_rec.location_cd,
							  p_unit_class => p_usec_rec.unit_class,
							  p_uso_id =>NULL) = FALSE THEN
           fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
           fnd_msg_pub.add;
           p_usec_rec.status := 'A';
        END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_check_import_allowed',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
        END IF;

      END IF;

      IF p_usec_rec.status = 'S' THEN
	Assign_default(p_usec_rec,l_insert_update);

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_Assign_default',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
        END IF;

      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
        validate_uoo_db_cons ( p_usec_rec,l_insert_update );

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_validate_uoo_db_cons',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
        END IF;

      END IF;



      /* Business validations */
      IF ( p_usec_rec.status = 'S' ) THEN
        -- Check for validation by calling validate_uoo
        igs_ps_validate_lgcy_pkg.validate_uoo ( p_usec_rec, l_c_cal_type, l_n_seq_num,l_n_sup_uoo_id,l_insert_update,l_conc_flag ) ;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_Business validations',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
         END IF;

      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN

        --update the superior unit section if the current unit section is a subordinate.Also set the value of relation_type colunn

	IF l_insert_update = 'I' THEN
	  IF l_n_sup_uoo_id IS NOT NULL THEN
	    OPEN c_usec_check(l_n_sup_uoo_id);
	    FETCH c_usec_check INTO l_c_var;
	    IF c_usec_check%NOTFOUND THEN
	      UPDATE igs_ps_unit_ofr_opt_all SET relation_type = 'SUPERIOR'
	      WHERE uoo_id = l_n_sup_uoo_id;
	    END IF;
	    CLOSE c_usec_check;
	    l_c_relation_type := 'SUBORDINATE';
	  ELSE
	    l_c_relation_type := 'NONE';
	  END IF;
        ELSE
	   DECLARE
               CURSOR cur_usec(cp_unit_cd IN VARCHAR2,
	                       cp_version_number IN NUMBER,
			       cp_cal_type  IN VARCHAR2,
			       cp_seq_num  IN NUMBER,
			       cp_location_cd IN VARCHAR2,
			       cp_unit_class IN VARCHAR2
			       ) IS
	       SELECT relation_type,sup_uoo_id
	       FROM   igs_ps_unit_ofr_opt_all
 	       WHERE  unit_cd = cp_unit_cd
	       AND    version_number =  cp_version_number
	       AND    ci_sequence_number =cp_seq_num
	       AND    unit_class = cp_unit_class
	       AND    location_cd = cp_location_cd
	       AND    cal_type = cp_cal_type ;
               l_cur_usec  cur_usec%ROWTYPE;

               CURSOR c_count_sup(cp_uoo_id NUMBER)  IS
	       SELECT COUNT(*)
	       FROM igs_ps_unit_ofr_opt_all
	       WHERE sup_uoo_id= cp_uoo_id;
               l_c_count NUMBER;
            BEGIN

	      OPEN cur_usec(p_usec_rec.unit_cd,p_usec_rec.version_number,l_c_cal_type,l_n_seq_num,
	                    p_usec_rec.location_cd ,p_usec_rec.unit_class );
	      FETCH cur_usec INTO l_cur_usec;
	      CLOSE cur_usec;

	      IF l_n_sup_uoo_id IS NOT NULL THEN
	        OPEN c_usec_check(l_n_sup_uoo_id);
	        FETCH c_usec_check INTO l_c_var;
	        IF c_usec_check%NOTFOUND THEN
	          UPDATE igs_ps_unit_ofr_opt_all SET relation_type = 'SUPERIOR'
	          WHERE uoo_id = l_n_sup_uoo_id;
	        END IF;
	        CLOSE c_usec_check;
	        l_c_relation_type := 'SUBORDINATE';

                --If existing usec is having one superior section and this time it is going for update of another
		-- value, then should set the earlier section's relation type as 'NONE' if this was the only subordinate
                IF l_cur_usec.sup_uoo_id IS NOT NULL AND l_cur_usec.sup_uoo_id <> l_n_sup_uoo_id THEN
                    OPEN c_count_sup(l_cur_usec.sup_uoo_id);
		    FETCH c_count_sup INTO l_c_count;
                    IF c_count_sup%FOUND THEN
		      IF l_c_count < 2 THEN
			UPDATE igs_ps_unit_ofr_opt_all SET relation_type = 'NONE'
			WHERE uoo_id = l_cur_usec.sup_uoo_id;
		      END IF;
		    END IF;
		    CLOSE c_count_sup;
                END IF;
	      ELSE
	        --Keep the existing values if no values are passed
	        l_c_relation_type :=l_cur_usec.relation_type;
	        l_n_sup_uoo_id := l_cur_usec.sup_uoo_id;
  	      END IF;
	    END;
	END IF;

	--should not perform while update...
        --Set the value of the call_number if the profile option is AUTO

	IF l_insert_update = 'I' THEN
          IF FND_PROFILE.VALUE('IGS_PS_CALL_NUMBER') = 'AUTO' THEN
            p_usec_rec.call_number := igs_ps_unit_ofr_opt_pkg.get_call_number( l_c_cal_type, l_n_seq_num);
          END IF;

          INSERT INTO igs_ps_unit_ofr_opt_all
          (unit_cd,
           version_number,
           cal_type,
           ci_sequence_number,
           location_cd,
           unit_class,
           uoo_id,
           ivrs_available_ind,
           call_number,
           unit_section_status,
           unit_section_start_date,
           unit_section_end_date,
           offered_ind,
           state_financial_aid,
           grading_schema_prcdnce_ind,
           federal_financial_aid,
           unit_quota,
           unit_quota_reserved_places,
           institutional_financial_aid,
           grading_schema_cd,
           gs_version_number,
           unit_contact,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           ss_enrol_ind,
           owner_org_unit_cd,
           attendance_required_ind,
           reserved_seating_allowed,
           special_permission_ind,
           ss_display_ind,
           rev_account_cd,
           anon_unit_grading_ind,
           anon_assess_grading_ind,
           non_std_usec_ind,
           auditable_ind,
           audit_permission_ind,
           not_multiple_section_flag,
           sup_uoo_id,
           relation_type,
           default_enroll_flag,
	   abort_flag
          )
        VALUES
          (p_usec_rec.unit_cd,
           p_usec_rec.version_number,
           l_c_cal_type,
           l_n_seq_num,
           p_usec_rec.location_cd,
           p_usec_rec.unit_class,
           igs_ps_unit_ofr_opt_uoo_id_s.NEXTVAL,
           p_usec_rec.ivrs_available_ind,
           p_usec_rec.call_number,
           p_usec_rec.unit_section_status,
           p_usec_rec.unit_section_start_date,
           p_usec_rec.unit_section_end_date,
           p_usec_rec.offered_ind,
           p_usec_rec.state_financial_aid,
           p_usec_rec.grading_schema_prcdnce_ind,
           p_usec_rec.federal_financial_aid,
           p_usec_rec.unit_quota,
           p_usec_rec.unit_quota_reserved_places,
           p_usec_rec.institutional_financial_aid,
           p_usec_rec.grading_schema_cd,
           p_usec_rec.gs_version_number,
           l_n_unit_contact_id,
           g_n_user_id,
           SYSDATE,
           g_n_user_id,
           SYSDATE,
           g_n_login_id,
           p_usec_rec.ss_enrol_ind,
           NVL(p_usec_rec.owner_org_unit_cd,l_c_org_unit_cd),
           p_usec_rec.attendance_required_ind,
           p_usec_rec.reserved_seating_allowed,
           p_usec_rec.special_permission_ind,
           p_usec_rec.ss_display_ind,
           p_usec_rec.rev_account_cd,
           p_usec_rec.anon_unit_grading_ind,
           p_usec_rec.anon_assess_grading_ind,
           p_usec_rec.non_std_usec_ind,
           p_usec_rec.auditable_ind,
           p_usec_rec.audit_permission_ind,
           p_usec_rec.not_multiple_section_flag,
           l_n_sup_uoo_id,
           l_c_relation_type,
           p_usec_rec.default_enroll_flag,
	   'N'
        );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.record_inserted',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class);
          END IF;

	  --If calling context is scheduling then update the interface table import done flag
	  IF   p_calling_context = 'S' THEN
	    OPEN cur_int_pat(p_usec_rec.unit_cd,p_usec_rec.version_number,l_c_cal_type,l_n_seq_num);
	    FETCH cur_int_pat INTO l_cur_int_pat;
	    IF cur_int_pat%FOUND THEN
 	      UPDATE igs_ps_sch_pat_int set import_done_flag='Y' WHERE int_pat_id = l_cur_int_pat.int_pat_id;
	    END IF;
	    CLOSE cur_int_pat;

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.interface_table_updated',
	      'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	      p_usec_rec.unit_class||'  '||'int_pat_id:'||l_cur_int_pat.int_pat_id);
            END IF;

	  END IF;

	ELSE --update
	  UPDATE igs_ps_unit_ofr_opt_all SET
          ivrs_available_ind =  p_usec_rec.ivrs_available_ind,
          call_number=p_usec_rec.call_number,
          unit_section_status=p_usec_rec.unit_section_status,
          unit_section_start_date=p_usec_rec.unit_section_start_date,
          unit_section_end_date=p_usec_rec.unit_section_end_date,
          offered_ind=p_usec_rec.offered_ind,
          state_financial_aid=p_usec_rec.state_financial_aid,
          grading_schema_prcdnce_ind=p_usec_rec.grading_schema_prcdnce_ind,
          federal_financial_aid=p_usec_rec.federal_financial_aid,
          unit_quota=p_usec_rec.unit_quota,
          unit_quota_reserved_places=p_usec_rec.unit_quota_reserved_places,
          institutional_financial_aid=p_usec_rec.institutional_financial_aid,
          grading_schema_cd=p_usec_rec.grading_schema_cd,
          gs_version_number=p_usec_rec.gs_version_number,
          unit_contact= l_n_unit_contact_id,
          ss_enrol_ind=p_usec_rec.ss_enrol_ind,
          owner_org_unit_cd=p_usec_rec.owner_org_unit_cd,
          attendance_required_ind=p_usec_rec.attendance_required_ind,
          reserved_seating_allowed=p_usec_rec.reserved_seating_allowed,
          special_permission_ind=p_usec_rec.special_permission_ind,
          ss_display_ind=p_usec_rec.ss_display_ind,
          rev_account_cd=p_usec_rec.rev_account_cd,
          anon_unit_grading_ind=p_usec_rec.anon_unit_grading_ind,
          anon_assess_grading_ind=p_usec_rec.anon_assess_grading_ind,
          non_std_usec_ind=p_usec_rec.non_std_usec_ind,
          auditable_ind=p_usec_rec.auditable_ind,
          audit_permission_ind=p_usec_rec.audit_permission_ind,
          not_multiple_section_flag=p_usec_rec.not_multiple_section_flag,
          sup_uoo_id = l_n_sup_uoo_id,
          relation_type=l_c_relation_type,
          default_enroll_flag=p_usec_rec.default_enroll_flag,
          last_updated_by = g_n_user_id,
          last_update_date= SYSDATE ,
          last_update_login= g_n_login_id
	  WHERE unit_cd = p_usec_rec.unit_cd
          AND version_number =  p_usec_rec.version_number
          AND ci_sequence_number =l_n_seq_num
          AND unit_class = p_usec_rec.unit_class
          AND location_cd = p_usec_rec.location_cd
          AND cal_type = l_c_cal_type ;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.record_updated',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class);
          END IF;

	  --If calling context is scheduling then update the interface table import done flag
	  IF   p_calling_context = 'S' THEN
	    OPEN cur_int_usec(p_usec_rec.unit_cd,p_usec_rec.version_number,l_c_cal_type,l_n_seq_num,p_usec_rec.location_cd, p_usec_rec.unit_class);
	    FETCH cur_int_usec INTO l_cur_int_usec;
	    IF cur_int_usec%FOUND THEN
		UPDATE igs_ps_sch_usec_int_all set import_done_flag='Y' WHERE int_usec_id = l_cur_int_usec.int_usec_id;
		UPDATE igs_ps_sch_pat_int set import_done_flag='Y' WHERE int_pat_id = l_cur_int_usec.int_pat_id;
	    END IF;

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.interface_table_updated',
	      'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	      p_usec_rec.unit_class||'  '||'int_pat_id:'||l_cur_int_pat.int_pat_id);
            END IF;

	    CLOSE cur_int_usec;
	  END IF;

	END IF; --insert /update
      END IF;


    END create_uoo;

    -- This procedure will derive values required for Unit Section Credit Points.
    PROCEDURE get_uoo_id ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type) AS
    l_c_message  VARCHAR2(30);
    BEGIN
      -- Derive uoo_id
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_rec.unit_cd,
                                            p_ver_num    => p_usec_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_usec_rec.location_cd,
                                            p_unit_class => p_usec_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF l_c_message IS NOT NULL THEN
        fnd_message.set_name ( 'IGS', l_c_message );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;


    END get_uoo_id;

    -- Procedure to validate Database constraints for Unit Section Credit Points Records.
    PROCEDURE validate_cp_db_cons ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,p_insert_update VARCHAR2 ) AS
    --sarakshi  15-May-2006  Bug#3064563, modified the format mask(clock_hours,continuing_education_units,work_load_cp_lecture,work_load_cp_lab,contact_hrs_lab) as specified in the bug.
    BEGIN

      IF p_insert_update = 'I' THEN
      /* Check for Unique Key Constraints */
	IF igs_ps_usec_cps_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_CPS', 'LEGACY_TOKENS', FALSE);
	  p_usec_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      /* Check for Foreign Key Constraints */
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;

      IF p_usec_rec.minimum_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('MINIMUM_CREDIT_POINTS',p_usec_rec.minimum_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','MINIMUM_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.maximum_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('MAXIMUM_CREDIT_POINTS',p_usec_rec.maximum_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','MAXIMUM_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.variable_increment IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('VARIABLE_INCREMENT',p_usec_rec.variable_increment);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','VARIABLE_INCREMENT','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;


      IF p_usec_rec.lecture_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('LECTURE_CREDIT_POINTS',p_usec_rec.lecture_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','LECTURE_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.lab_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('LAB_CREDIT_POINTS',p_usec_rec.lab_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','LAB_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.other_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('OTHER_CREDIT_POINTS',p_usec_rec.other_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','OTHER_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.clock_hours IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('CLOCK_HOURS',p_usec_rec.clock_hours);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','CLOCK_HOURS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.work_load_cp_lecture IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('WORK_LOAD_CP_LECTURE',p_usec_rec.work_load_cp_lecture);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','WORK_LOAD_CP_LECTURE','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;


      IF p_usec_rec.work_load_cp_lab IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('WORK_LOAD_CP_LAB',p_usec_rec.work_load_cp_lab);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','WORK_LOAD_CP_LAB','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      --Validate achievable credit points
      IF p_usec_rec.achievable_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('ACHIEVABLE_CREDIT_POINTS',p_usec_rec.achievable_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','ACHIEVABLE_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      --Validate enrolled credit points
      BEGIN
        igs_ps_usec_cps_pkg.check_constraints('ENROLLED_CREDIT_POINTS',p_usec_rec.enrolled_credit_points);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','ENROLLED_CREDIT_POINTS','LEGACY_TOKENS',TRUE);
          p_usec_rec.status :='E';
      END;

      --Validate billing credit points
      IF p_usec_rec.billing_credit_points IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints( 'BILLING_CREDIT_POINTS', p_usec_rec.billing_credit_points);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999', 'BILLING_CREDIT_POINTS', 'LEGACY_TOKENS', TRUE);
            p_usec_rec.status := 'E';
        END;
      END IF;

      IF p_usec_rec.billing_hrs IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints( 'BILLING_HRS', p_usec_rec.billing_hrs);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999', 'BILLING_HRS', 'LEGACY_TOKENS', TRUE);
            p_usec_rec.status := 'E';
        END;
      END IF;
      IF p_usec_rec.continuing_education_units IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('CONTINUING_EDUCATION_UNITS',p_usec_rec.continuing_education_units);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D999','CONTINUING_EDUCATION_UNITS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.work_load_other IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('WORK_LOAD_OTHER',p_usec_rec.work_load_other);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','WORK_LOAD_OTHER','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.contact_hrs_lecture IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('CONTACT_HRS_LECTURE',p_usec_rec.contact_hrs_lecture);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','CONTACT_HRS_LECTURE','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.contact_hrs_lab IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('CONTACT_HRS_LAB',p_usec_rec.contact_hrs_lab);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','CONTACT_HRS_LAB','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.contact_hrs_other IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('CONTACT_HRS_OTHER',p_usec_rec.contact_hrs_other);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999D99','CONTACT_HRS_OTHER','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.non_schd_required_hrs IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('NON_SCHD_REQUIRED_HRS',p_usec_rec.non_schd_required_hrs);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','NON_SCHD_REQUIRED_HRS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

      IF p_usec_rec.exclude_from_max_cp_limit IS NOT NULL THEN
        BEGIN
          igs_ps_usec_ref_pkg.check_constraints ( 'EXCLUDE_FROM_MAX_CP_LIMIT', p_usec_rec.exclude_from_max_cp_limit);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'EXCLUDE_FROM_MAX_CP_LIMIT', 'LEGACY_TOKENS', TRUE);
            p_usec_rec.status := 'E';
        END;
      END IF;

      IF p_usec_rec.claimable_hours IS NOT NULL THEN
        BEGIN
          igs_ps_usec_cps_pkg.check_constraints('CLAIMABLE_HOURS',p_usec_rec.claimable_hours);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','CLAIMABLE_HOURS','LEGACY_TOKENS',TRUE);
            p_usec_rec.status :='E';
        END;
      END IF;

    END validate_cp_db_cons;

    -- Main private procedure to create records of Unit Section Credit Points.

    PROCEDURE create_cp ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type )
    AS
    FUNCTION check_insert_update (p_usec_rec IN igs_ps_generic_pub.usec_rec_type ) RETURN VARCHAR2 IS

    CURSOR c_usec_cp(cp_n_uoo_id NUMBER) IS
    SELECT *
    FROM igs_ps_usec_cps
    WHERE uoo_id = cp_n_uoo_id;

    c_usec_cp_rec c_usec_cp%ROWTYPE;
    BEGIN
      OPEN c_usec_cp(l_n_uoo_id);
      FETCH c_usec_cp INTO c_usec_cp_rec;
      IF c_usec_cp%NOTFOUND THEN
	 CLOSE c_usec_cp;
	 RETURN 'I';
      ELSE
	 CLOSE c_usec_cp;
	 RETURN 'U';
      END IF;

    END check_insert_update;
    PROCEDURE Assign_default(  p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                               p_insert_update VARCHAR2 ) AS
    CURSOR c_usec_cp(p_n_uoo_id NUMBER) IS
    SELECT *
    FROM igs_ps_usec_cps
    WHERE uoo_id = p_n_uoo_id;

    c_usec_cp_rec c_usec_cp%ROWTYPE;
    BEGIN
      IF p_insert_update = 'U' THEN

	OPEN c_usec_cp(l_n_uoo_id);
	FETCH c_usec_cp INTO c_usec_cp_rec;
	CLOSE c_usec_cp;

        IF p_usec_rec.minimum_credit_points  IS NULL  THEN
	  p_usec_rec.minimum_credit_points  := c_usec_cp_rec.minimum_credit_points ;
        ELSIF  p_usec_rec.minimum_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.minimum_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.maximum_credit_points  IS NULL  THEN
	  p_usec_rec.maximum_credit_points  := c_usec_cp_rec.maximum_credit_points ;
        ELSIF  p_usec_rec.maximum_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.maximum_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.variable_increment  IS NULL  THEN
	  p_usec_rec.variable_increment  := c_usec_cp_rec.variable_increment ;
        ELSIF  p_usec_rec.variable_increment  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.variable_increment  :=NULL;
        END IF;
	IF p_usec_rec.lecture_credit_points  IS NULL  THEN
	  p_usec_rec.lecture_credit_points  := c_usec_cp_rec.lecture_credit_points ;
        ELSIF  p_usec_rec.lecture_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.lecture_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.lab_credit_points  IS NULL  THEN
	  p_usec_rec.lab_credit_points  := c_usec_cp_rec.lab_credit_points ;
        ELSIF  p_usec_rec.lab_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.lab_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.other_credit_points  IS NULL  THEN
	  p_usec_rec.other_credit_points  := c_usec_cp_rec.other_credit_points ;
        ELSIF  p_usec_rec.other_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.other_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.clock_hours  IS NULL  THEN
	  p_usec_rec.clock_hours  := c_usec_cp_rec.clock_hours ;
        ELSIF  p_usec_rec.clock_hours  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.clock_hours  :=NULL;
        END IF;
	IF p_usec_rec.billing_credit_points  IS NULL  THEN
	  p_usec_rec.billing_credit_points  := c_usec_cp_rec.billing_credit_points ;
        ELSIF  p_usec_rec.billing_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.billing_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.work_load_cp_lecture  IS NULL  THEN
	  p_usec_rec.work_load_cp_lecture  := c_usec_cp_rec.work_load_cp_lecture ;
        ELSIF  p_usec_rec.work_load_cp_lecture  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.work_load_cp_lecture  :=NULL;
        END IF;
	IF p_usec_rec.work_load_cp_lab  IS NULL  THEN
	  p_usec_rec.work_load_cp_lab  := c_usec_cp_rec.work_load_cp_lab ;
        ELSIF  p_usec_rec.work_load_cp_lab  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.work_load_cp_lab  :=NULL;
        END IF;
	IF p_usec_rec.continuing_education_units  IS NULL  THEN
	  p_usec_rec.continuing_education_units  := c_usec_cp_rec.continuing_education_units ;
        ELSIF  p_usec_rec.continuing_education_units  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.continuing_education_units  :=NULL;
        END IF;
	IF p_usec_rec.achievable_credit_points  IS NULL  THEN
	  p_usec_rec.achievable_credit_points  := c_usec_cp_rec.achievable_credit_points ;
        ELSIF  p_usec_rec.achievable_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.achievable_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.enrolled_credit_points  IS NULL  THEN
	  p_usec_rec.enrolled_credit_points  := c_usec_cp_rec.enrolled_credit_points ;
        ELSIF  p_usec_rec.enrolled_credit_points  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.enrolled_credit_points  :=NULL;
        END IF;
	IF p_usec_rec.work_load_other  IS NULL  THEN
	  p_usec_rec.work_load_other  := c_usec_cp_rec.work_load_other ;
        ELSIF  p_usec_rec.work_load_other  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.work_load_other  :=NULL;
        END IF;
	IF p_usec_rec.contact_hrs_lecture  IS NULL  THEN
	  p_usec_rec.contact_hrs_lecture  := c_usec_cp_rec.contact_hrs_lecture ;
        ELSIF  p_usec_rec.contact_hrs_lecture  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.contact_hrs_lecture  :=NULL;
        END IF;
	IF p_usec_rec.contact_hrs_lab  IS NULL  THEN
	  p_usec_rec.contact_hrs_lab  := c_usec_cp_rec.contact_hrs_lab ;
        ELSIF  p_usec_rec.contact_hrs_lab  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.contact_hrs_lab  :=NULL;
        END IF;
	IF p_usec_rec.contact_hrs_other  IS NULL  THEN
	  p_usec_rec.contact_hrs_other  := c_usec_cp_rec.contact_hrs_other ;
        ELSIF  p_usec_rec.contact_hrs_other  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.contact_hrs_other  :=NULL;
        END IF;
	IF p_usec_rec.billing_hrs  IS NULL  THEN
	  p_usec_rec.billing_hrs  := c_usec_cp_rec.billing_hrs ;
        ELSIF  p_usec_rec.billing_hrs  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.billing_hrs  :=NULL;
        END IF;
	IF p_usec_rec.non_schd_required_hrs  IS NULL  THEN
	  p_usec_rec.non_schd_required_hrs  := c_usec_cp_rec.non_schd_required_hrs ;
        ELSIF  p_usec_rec.non_schd_required_hrs  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.non_schd_required_hrs  :=NULL;
        END IF;
	IF p_usec_rec.exclude_from_max_cp_limit  IS NULL  THEN
	  p_usec_rec.exclude_from_max_cp_limit  := c_usec_cp_rec.exclude_from_max_cp_limit ;
        ELSIF  p_usec_rec.exclude_from_max_cp_limit  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.exclude_from_max_cp_limit  :=NULL;
        END IF;
	IF p_usec_rec.claimable_hours  IS NULL  THEN
	  p_usec_rec.claimable_hours  := c_usec_cp_rec.claimable_hours ;
        ELSIF  p_usec_rec.claimable_hours  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.claimable_hours  :=NULL;
        END IF;
      END IF;

    END Assign_default;

    BEGIN
      IF   p_usec_rec.minimum_credit_points IS NULL AND
	   p_usec_rec.maximum_credit_points IS NULL AND
	   p_usec_rec.variable_increment IS NULL AND
	   p_usec_rec.lecture_credit_points IS NULL AND
	   p_usec_rec.lab_credit_points IS NULL AND
	   p_usec_rec.other_credit_points IS NULL AND
	   p_usec_rec.clock_hours IS NULL AND
	   p_usec_rec.billing_credit_points IS NULL AND
	   p_usec_rec.work_load_cp_lecture IS NULL AND
	   p_usec_rec.work_load_cp_lab IS NULL AND
	   p_usec_rec.continuing_education_units IS NULL AND
	   p_usec_rec.achievable_credit_points IS NULL AND
	   p_usec_rec.enrolled_credit_points IS NULL AND
	   p_usec_rec.work_load_other IS NULL AND
	   p_usec_rec.contact_hrs_lecture IS NULL AND
	   p_usec_rec.contact_hrs_lab IS NULL AND
	   p_usec_rec.contact_hrs_other IS NULL AND
	   p_usec_rec.billing_hrs IS NULL AND
	   p_usec_rec.non_schd_required_hrs IS NULL AND
	   p_usec_rec.exclude_from_max_cp_limit IS NULL AND
	   p_usec_rec.claimable_hours  IS NULL THEN


        --No need to insert/update the empty record if all the attribute are null
	NULL;
      ELSE

	IF p_usec_rec.status = 'S' THEN
	  get_uoo_id ( p_usec_rec);

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.status_after_get_uoo_id',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	  END IF;

	END IF;

	--Find out whether it is insert/update of record
	 l_insert_update:='I';
	 IF p_usec_rec.status = 'S' AND p_calling_context IN ('G', 'S') THEN
	   l_insert_update:= check_insert_update(p_usec_rec);

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.status_after_check_insert_update',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	   END IF;

	 END IF;

	IF p_usec_rec.status = 'S' THEN
	  Assign_default(p_usec_rec,l_insert_update);

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.status_after_Assign_default',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	   END IF;

	END IF;

	IF ( p_usec_rec.status = 'S' ) THEN
	  validate_cp_db_cons ( p_usec_rec,l_insert_update );

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.status_after_validate_cp_db_cons',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	   END IF;

	END IF;

	/* Business validations */
	IF ( p_usec_rec.status = 'S' ) THEN
	  -- Check for validation by calling validate_cps
	  igs_ps_validate_lgcy_pkg.validate_cps ( p_usec_rec,l_n_uoo_id,l_insert_update ) ;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.status_after_Business_validation',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	  END IF;

	END IF;

	IF ( p_usec_rec.status = 'S' ) THEN
	  IF l_insert_update = 'I' THEN
	    /* Insert Record */
	    INSERT INTO igs_ps_usec_cps
	    (unit_sec_credit_points_id,
	    uoo_id,
	    minimum_credit_points,
	    maximum_credit_points,
	    variable_increment,
	    lecture_credit_points,
	    lab_credit_points,
	    other_credit_points,
	    clock_hours,
	    billing_credit_points,
	    work_load_cp_lecture,
	    work_load_cp_lab,
	    continuing_education_units,
	    achievable_credit_points,
	    enrolled_credit_points,
	    created_by,
	    creation_date,
	    last_updated_by,
	    last_update_date,
	    last_update_login,
	    work_load_other,
	    contact_hrs_lecture,
	    contact_hrs_lab,
	    contact_hrs_other,
	    billing_hrs,
	    non_schd_required_hrs,
	    exclude_from_max_cp_limit,
	    claimable_hours
	    )
	    VALUES
	    (igs_ps_usec_cps_s.NEXTVAL,
	     l_n_uoo_id,
	     p_usec_rec.minimum_credit_points,
	     p_usec_rec.maximum_credit_points,
	     p_usec_rec.variable_increment,
	     p_usec_rec.lecture_credit_points,
	     p_usec_rec.lab_credit_points,
	     p_usec_rec.other_credit_points,
	     p_usec_rec.clock_hours,
	     p_usec_rec.billing_credit_points,
	     p_usec_rec.work_load_cp_lecture,
	     p_usec_rec.work_load_cp_lab,
	     p_usec_rec.continuing_education_units,
	     p_usec_rec.achievable_credit_points,
	     p_usec_rec.enrolled_credit_points,
	     g_n_user_id,
	     SYSDATE,
	     g_n_user_id,
	     SYSDATE,
	     g_n_login_id,
	     p_usec_rec.work_load_other,
	     p_usec_rec.contact_hrs_lecture,
	     p_usec_rec.contact_hrs_lab,
	     p_usec_rec.contact_hrs_other,
	     p_usec_rec.billing_hrs,
	     p_usec_rec.non_schd_required_hrs,
	     p_usec_rec.exclude_from_max_cp_limit,
	     p_usec_rec.claimable_hours
	   );

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.record_inserted',
	      'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	      p_usec_rec.unit_class);
            END IF;

	  ELSE ---update
	   UPDATE igs_ps_usec_cps SET
	   minimum_credit_points =p_usec_rec.minimum_credit_points,
	   maximum_credit_points =p_usec_rec.maximum_credit_points,
	   variable_increment =p_usec_rec.variable_increment,
	   lecture_credit_points =p_usec_rec.lecture_credit_points,
	   lab_credit_points =p_usec_rec.lab_credit_points,
	   other_credit_points =p_usec_rec.other_credit_points,
	   clock_hours =p_usec_rec.clock_hours,
	   billing_credit_points =p_usec_rec.billing_credit_points,
	   work_load_cp_lecture =p_usec_rec.work_load_cp_lecture,
	   work_load_cp_lab =p_usec_rec.work_load_cp_lab,
	   continuing_education_units =p_usec_rec.continuing_education_units,
	   achievable_credit_points =p_usec_rec.achievable_credit_points,
	   enrolled_credit_points =p_usec_rec.enrolled_credit_points,
	   last_updated_by =g_n_user_id,
	   last_update_date =SYSDATE,
	   last_update_login =g_n_login_id,
	   work_load_other =p_usec_rec.work_load_other,
	   contact_hrs_lecture = p_usec_rec.contact_hrs_lecture,
	   contact_hrs_lab =p_usec_rec.contact_hrs_lab,
	   contact_hrs_other =p_usec_rec.contact_hrs_other,
	   billing_hrs =p_usec_rec.billing_hrs,
	   non_schd_required_hrs =p_usec_rec.non_schd_required_hrs,
	   exclude_from_max_cp_limit = p_usec_rec.exclude_from_max_cp_limit,
	   claimable_hours =p_usec_rec.claimable_hours
	   WHERE uoo_id = l_n_uoo_id;

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.record_updated',
	     'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class);
           END IF;

	  END IF;
        END IF;

      END IF;

     END create_cp;

    -- Procedure to validate Database constraints for Unit Section Reference Records.
    PROCEDURE validate_ref_db_cons ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,p_insert_update VARCHAR2 ) AS
    BEGIN
      IF p_insert_update = 'I' THEN
      /* Check for Unique Key Constraints */
	IF igs_ps_usec_ref_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_SEC_REF', 'LEGACY_TOKENS', FALSE);
	  p_usec_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      /* Check for Foreign Key Constraints */
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_rec.status := 'E';
      END IF;



     IF p_usec_rec.reference_subtitle_mod_flag IS NOT NULL THEN
        BEGIN
          igs_ps_usec_ref_pkg.check_constraints ( 'REFERENCE_SUBTITLE_MOD_FLAG', p_usec_rec.reference_subtitle_mod_flag);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'REFERENCE_SUBTITLE_MOD_FLAG', 'LEGACY_TOKENS', TRUE);
            p_usec_rec.status := 'E';
        END;
     END IF;

     IF p_usec_rec.reference_class_sch_excl_flag IS NOT NULL THEN
        BEGIN
          igs_ps_usec_ref_pkg.check_constraints ( 'REFERENCE_CLASS_SCH_EXCL_FLAG', p_usec_rec.reference_class_sch_excl_flag);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'REFERENCE_CLASS_SCH_EXCL_FLAG', 'LEGACY_TOKENS', TRUE);
            p_usec_rec.status := 'E';
        END;
     END IF;

     IF p_usec_rec.reference_rec_exclusion_flag IS NOT NULL THEN
        BEGIN
          igs_ps_usec_ref_pkg.check_constraints ( 'REFERENCE_REC_EXCLUSION_FLAG', p_usec_rec.reference_rec_exclusion_flag);
        EXCEPTION
          WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'REFERENCE_REC_EXCLUSION_FLAG', 'LEGACY_TOKENS', TRUE);
            p_usec_rec.status := 'E';
        END;
     END IF;

    END validate_ref_db_cons;

    -- Main private procedure to create records of Unit Section Reference .

    PROCEDURE create_ref ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type )
    AS

    FUNCTION check_insert_update (p_usec_rec IN igs_ps_generic_pub.usec_rec_type ) RETURN VARCHAR2 IS

      CURSOR c_usec_ref(p_n_uoo_id NUMBER) IS
      SELECT 'X'
      FROM igs_ps_usec_ref
      WHERE uoo_id = p_n_uoo_id;

      c_usec_ref_rec c_usec_ref%ROWTYPE;
    BEGIN

      OPEN c_usec_ref(l_n_uoo_id);
      FETCH c_usec_ref INTO c_usec_ref_rec;
      IF c_usec_ref%NOTFOUND THEN
	 CLOSE c_usec_ref;
	 RETURN 'I';
      ELSE
	 CLOSE c_usec_ref;
	 RETURN 'U';
      END IF;

    END check_insert_update;

    PROCEDURE Assign_default(  p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                               p_insert_update VARCHAR2 ) AS
      CURSOR c_usec_ref(p_n_uoo_id NUMBER) IS
      SELECT *
      FROM igs_ps_usec_ref
      WHERE uoo_id = p_n_uoo_id;

      c_usec_ref_rec c_usec_ref%ROWTYPE;
    BEGIN

      IF p_insert_update = 'I' THEN
        IF p_usec_rec.reference_subtitle_mod_flag IS NULL THEN
	  p_usec_rec.reference_subtitle_mod_flag := 'N';
        END IF;

        IF p_usec_rec.reference_class_sch_excl_flag IS NULL THEN
	  p_usec_rec.reference_class_sch_excl_flag := 'N';
        END IF;

        IF p_usec_rec.reference_rec_exclusion_flag IS NULL THEN
	  p_usec_rec.reference_rec_exclusion_flag := 'N';
        END IF;
      ELSE

	OPEN c_usec_ref(l_n_uoo_id);
	FETCH c_usec_ref INTO c_usec_ref_rec;
	CLOSE c_usec_ref;

        IF p_usec_rec.reference_subtitle  IS NULL  THEN
	  p_usec_rec.reference_subtitle  := c_usec_ref_rec.subtitle ;
        ELSIF  p_usec_rec.reference_subtitle  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_subtitle  :=NULL;
        END IF;
	IF p_usec_rec.reference_short_title  IS NULL  THEN
	  p_usec_rec.reference_short_title  := c_usec_ref_rec.short_title ;
        ELSIF  p_usec_rec.reference_short_title  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_short_title  :=NULL;
        END IF;
	IF p_usec_rec.reference_subtitle_mod_flag  IS NULL  THEN
	  p_usec_rec.reference_subtitle_mod_flag  := c_usec_ref_rec.subtitle_modifiable_flag ;
        ELSIF  p_usec_rec.reference_subtitle_mod_flag  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_subtitle_mod_flag  :='N';
        END IF;
	IF p_usec_rec.reference_class_sch_excl_flag  IS NULL  THEN
	  p_usec_rec.reference_class_sch_excl_flag  := c_usec_ref_rec.class_schedule_exclusion_flag ;
        ELSIF  p_usec_rec.reference_class_sch_excl_flag  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_class_sch_excl_flag  :='N';
        END IF;
	IF p_usec_rec.reference_rec_exclusion_flag  IS NULL  THEN
	  p_usec_rec.reference_rec_exclusion_flag  := c_usec_ref_rec.record_exclusion_flag   ;
        ELSIF  p_usec_rec.reference_rec_exclusion_flag  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_rec_exclusion_flag  :='N';
        END IF;
	IF p_usec_rec.reference_attribute_category  IS NULL  THEN
	  p_usec_rec.reference_attribute_category  := c_usec_ref_rec.attribute_category ;
        ELSIF  p_usec_rec.reference_attribute_category  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute_category  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute1  IS NULL  THEN
	  p_usec_rec.reference_attribute1  := c_usec_ref_rec.attribute1 ;
        ELSIF  p_usec_rec.reference_attribute1  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute1  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute2  IS NULL  THEN
	  p_usec_rec.reference_attribute2  := c_usec_ref_rec.attribute2 ;
        ELSIF  p_usec_rec.reference_attribute2  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute2  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute3  IS NULL  THEN
	  p_usec_rec.reference_attribute3  := c_usec_ref_rec.attribute3 ;
        ELSIF  p_usec_rec.reference_attribute3  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute3  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute4  IS NULL  THEN
	  p_usec_rec.reference_attribute4  := c_usec_ref_rec.attribute4 ;
        ELSIF  p_usec_rec.reference_attribute4  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute4  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute5  IS NULL  THEN
	  p_usec_rec.reference_attribute5  := c_usec_ref_rec.attribute5 ;
        ELSIF  p_usec_rec.reference_attribute5  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute5  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute6  IS NULL  THEN
	  p_usec_rec.reference_attribute6  := c_usec_ref_rec.attribute6 ;
        ELSIF  p_usec_rec.reference_attribute6  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute6  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute7  IS NULL  THEN
	  p_usec_rec.reference_attribute7  := c_usec_ref_rec.attribute7 ;
        ELSIF  p_usec_rec.reference_attribute7  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute7  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute8  IS NULL  THEN
	  p_usec_rec.reference_attribute8  := c_usec_ref_rec.attribute8 ;
        ELSIF  p_usec_rec.reference_attribute8  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute8  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute9  IS NULL  THEN
	  p_usec_rec.reference_attribute9  := c_usec_ref_rec.attribute9 ;
        ELSIF  p_usec_rec.reference_attribute9  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute9  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute10  IS NULL  THEN
	  p_usec_rec.reference_attribute10  := c_usec_ref_rec.attribute10 ;
        ELSIF  p_usec_rec.reference_attribute10  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute10  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute11  IS NULL  THEN
	  p_usec_rec.reference_attribute11  := c_usec_ref_rec.attribute11 ;
        ELSIF  p_usec_rec.reference_attribute11  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute11  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute12  IS NULL  THEN
	  p_usec_rec.reference_attribute12  := c_usec_ref_rec.attribute12 ;
        ELSIF  p_usec_rec.reference_attribute12  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute12  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute13  IS NULL  THEN
	  p_usec_rec.reference_attribute13  := c_usec_ref_rec.attribute13 ;
        ELSIF  p_usec_rec.reference_attribute13  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute13  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute14  IS NULL  THEN
	  p_usec_rec.reference_attribute14  := c_usec_ref_rec.attribute14 ;
        ELSIF  p_usec_rec.reference_attribute14  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute14  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute15  IS NULL  THEN
	  p_usec_rec.reference_attribute15  := c_usec_ref_rec.attribute15 ;
        ELSIF  p_usec_rec.reference_attribute15  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute15  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute16  IS NULL  THEN
	  p_usec_rec.reference_attribute16  := c_usec_ref_rec.attribute16 ;
        ELSIF  p_usec_rec.reference_attribute16  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute16  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute17  IS NULL  THEN
	  p_usec_rec.reference_attribute17  := c_usec_ref_rec.attribute17 ;
        ELSIF  p_usec_rec.reference_attribute17  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute17  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute18  IS NULL  THEN
	  p_usec_rec.reference_attribute18  := c_usec_ref_rec.attribute18 ;
        ELSIF  p_usec_rec.reference_attribute18  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute18  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute19  IS NULL  THEN
	  p_usec_rec.reference_attribute19  := c_usec_ref_rec.attribute19 ;
        ELSIF  p_usec_rec.reference_attribute19  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute19  :=NULL;
        END IF;
	IF p_usec_rec.reference_attribute20  IS NULL  THEN
	  p_usec_rec.reference_attribute20  := c_usec_ref_rec.attribute20 ;
        ELSIF  p_usec_rec.reference_attribute20  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_attribute20  :=NULL;
        END IF;
	IF p_usec_rec.reference_title  IS NULL  THEN
	  p_usec_rec.reference_title  := c_usec_ref_rec.title ;
        ELSIF  p_usec_rec.reference_title  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.reference_title  :=NULL;
        END IF;
      END IF;
    END Assign_default;

    BEGIN

	IF p_usec_rec.status = 'S' THEN
	  get_uoo_id ( p_usec_rec);

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.status_after_get_uoo_id',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	  END IF;

	END IF;

       --Find out whether it is insert/update of record
       l_insert_update:='I';
       IF p_usec_rec.status = 'S' AND p_calling_context IN ('G', 'S') THEN
         l_insert_update:= check_insert_update(p_usec_rec);

	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.status_after_check_insert_update',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	  END IF;

       END IF;

      IF p_usec_rec.status = 'S' THEN
	Assign_default(p_usec_rec,l_insert_update);

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.status_after_Assign_default',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	  p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	END IF;

      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
	validate_ref_db_cons ( p_usec_rec,l_insert_update );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.status_after_validate_ref_db_cons',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
	END IF;

      END IF;
      /* Business validations */
      IF ( p_usec_rec.status = 'S' ) THEN
	-- Check for validation by calling validate_ref
	 l_n_subtitle_id := NULL;
	 igs_ps_validate_lgcy_pkg.validate_ref ( p_usec_rec, l_n_subtitle_id ,l_n_uoo_id,l_insert_update);

	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	   fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.status_after_Business_validation',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
         END IF;

      END IF;

      IF ( p_usec_rec.status = 'S' ) THEN
	IF l_insert_update = 'I' THEN
	  /* Insert Record */
	INSERT INTO igs_ps_usec_ref
	(unit_section_reference_id,
	uoo_id,
	short_title,
	subtitle,
	subtitle_modifiable_flag,
	class_schedule_exclusion_flag,
	registration_exclusion_flag,
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
	created_by,
	creation_date,
	last_updated_by,
	last_update_date,
	last_update_login,
	record_exclusion_flag,
	title,
	subtitle_id
	)
	VALUES
	(igs_ps_usec_ref_s.NEXTVAL,
	l_n_uoo_id,
	p_usec_rec.reference_short_title,
	p_usec_rec.reference_subtitle,
	p_usec_rec.reference_subtitle_mod_flag,
	p_usec_rec.reference_class_sch_excl_flag,
	null,
	p_usec_rec.reference_attribute_category,
	p_usec_rec.reference_attribute1,
	p_usec_rec.reference_attribute2,
	p_usec_rec.reference_attribute3,
	p_usec_rec.reference_attribute4,
	p_usec_rec.reference_attribute5,
	p_usec_rec.reference_attribute6,
	p_usec_rec.reference_attribute7,
	p_usec_rec.reference_attribute8,
	p_usec_rec.reference_attribute9,
	p_usec_rec.reference_attribute10,
	p_usec_rec.reference_attribute11,
	p_usec_rec.reference_attribute12,
	p_usec_rec.reference_attribute13,
	p_usec_rec.reference_attribute14,
	p_usec_rec.reference_attribute15,
	p_usec_rec.reference_attribute16,
	p_usec_rec.reference_attribute17,
	p_usec_rec.reference_attribute18,
	p_usec_rec.reference_attribute19,
	p_usec_rec.reference_attribute20,
	g_n_user_id,
	SYSDATE,
	g_n_user_id,
	SYSDATE,
	g_n_login_id,
	p_usec_rec.reference_rec_exclusion_flag,
	p_usec_rec.reference_title,
	l_n_subtitle_id
	);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.record_inserted',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rec.unit_class);
         END IF;

	ELSE ---update
	 UPDATE igs_ps_usec_ref SET
	 short_title =p_usec_rec.reference_short_title,
	 subtitle =p_usec_rec.reference_subtitle,
	 subtitle_modifiable_flag =p_usec_rec.reference_subtitle_mod_flag,
	 class_schedule_exclusion_flag =p_usec_rec.reference_class_sch_excl_flag,
	 attribute_category =p_usec_rec.reference_attribute_category,
	 attribute1 =p_usec_rec.reference_attribute1,
	 attribute2 =p_usec_rec.reference_attribute2,
	 attribute3 =p_usec_rec.reference_attribute3,
	 attribute4 =p_usec_rec.reference_attribute4,
	 attribute5 =p_usec_rec.reference_attribute5,
	 attribute6 =p_usec_rec.reference_attribute6,
	 attribute7 =p_usec_rec.reference_attribute7,
	 attribute8 =p_usec_rec.reference_attribute8,
	 attribute9 =p_usec_rec.reference_attribute9,
	 attribute10 =p_usec_rec.reference_attribute10,
	 attribute11 =p_usec_rec.reference_attribute11,
	 attribute12 =p_usec_rec.reference_attribute12,
	 attribute13 =p_usec_rec.reference_attribute13,
	 attribute14 =p_usec_rec.reference_attribute14,
	 attribute15 =p_usec_rec.reference_attribute15,
	 attribute16 =p_usec_rec.reference_attribute16,
	 attribute17 =p_usec_rec.reference_attribute17,
	 attribute18 =p_usec_rec.reference_attribute18,
	 attribute19 =p_usec_rec.reference_attribute19,
	 attribute20 =p_usec_rec.reference_attribute20,
	 last_updated_by =g_n_user_id,
	 last_update_date =SYSDATE,
	 last_update_login =g_n_login_id,
	 title=p_usec_rec.reference_title,
	 record_exclusion_flag =p_usec_rec.reference_rec_exclusion_flag,
	 subtitle_id=l_n_subtitle_id
	 WHERE uoo_id = l_n_uoo_id;

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.record_updated',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rec.unit_class);
         END IF;

	END IF;
     END IF;

    END create_ref;
  -- Adding the new procedure to import unit section enrollment limits
    PROCEDURE create_usec_el(p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type ) AS
   /***********************************************************************************************

   Created By:         SMVK
   Date Created By:    28-May-2003
   Purpose:            This procedure imports Unit Section Enrollment Limits.

   Known limitations,enhancements,remarks:

   Change History

   Who       When         What

  ***********************************************************************************************/
    FUNCTION check_insert_update (p_usec_rec IN igs_ps_generic_pub.usec_rec_type ) RETURN VARCHAR2 IS
      CURSOR c_usec_lim(p_n_uoo_id NUMBER) IS
      SELECT 'X'
      FROM igs_ps_usec_lim_wlst
      WHERE uoo_id = p_n_uoo_id;

     c_usec_lim_rec c_usec_lim%ROWTYPE;
    BEGIN

      OPEN c_usec_lim(l_n_uoo_id);
      FETCH c_usec_lim INTO c_usec_lim_rec;
      IF c_usec_lim%NOTFOUND THEN
	 CLOSE c_usec_lim;
	 RETURN 'I';
      ELSE
	 CLOSE c_usec_lim;
	 RETURN 'U';
      END IF;

    END check_insert_update;

    PROCEDURE Assign_default(  p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                               p_insert_update VARCHAR2 ) AS
      CURSOR c_uop(cp_c_unit_cd  IN igs_ps_unit_ofr_pat_all.unit_cd%TYPE,
		 cp_n_ver_num  IN igs_ps_unit_ofr_pat_all.version_number%TYPE,
		 cp_c_cal_type IN igs_ps_unit_ofr_pat_all.cal_type%TYPE,
		 cp_n_seq_num  IN igs_ps_unit_ofr_pat_all.ci_sequence_number%TYPE ) IS
      SELECT waitlist_allowed, max_students_per_waitlist
      FROM   igs_ps_unit_ofr_pat_all
      WHERE  unit_cd = cp_c_unit_cd
      AND    version_number = cp_n_ver_num
      AND    cal_type = cp_c_cal_type
      AND    ci_sequence_number = cp_n_seq_num ;

    rec_uop  c_uop%ROWTYPE;

    CURSOR c_usec_lim(p_n_uoo_id NUMBER) IS
      SELECT *
      FROM igs_ps_usec_lim_wlst
      WHERE uoo_id = p_n_uoo_id;

     c_usec_lim_rec c_usec_lim%ROWTYPE;
   BEGIN

     IF p_insert_update = 'I' THEN
       OPEN  c_uop (p_usec_rec.unit_cd, p_usec_rec.version_number, l_c_cal_type, l_n_seq_num);
       FETCH c_uop INTO rec_uop;
       CLOSE c_uop;

       IF p_usec_rec.usec_waitlist_allowed IS NULL THEN
	 p_usec_rec.usec_waitlist_allowed := rec_uop.waitlist_allowed;
       END IF;

       IF p_usec_rec.usec_max_students_per_waitlist IS NULL THEN
	 p_usec_rec.usec_max_students_per_waitlist := rec_uop.max_students_per_waitlist;
       END IF;
     ELSE
       OPEN c_usec_lim(l_n_uoo_id);
       FETCH c_usec_lim INTO c_usec_lim_rec;
       CLOSE c_usec_lim;

       IF p_usec_rec.usec_waitlist_allowed  IS NULL  THEN
	  p_usec_rec.usec_waitlist_allowed  := c_usec_lim_rec.waitlist_allowed;
       ELSIF  p_usec_rec.usec_waitlist_allowed  = FND_API.G_MISS_CHAR THEN
	  p_usec_rec.usec_waitlist_allowed  :='N';
       END IF;

       IF p_usec_rec.usec_max_students_per_waitlist  IS NULL  THEN
	  p_usec_rec.usec_max_students_per_waitlist  := c_usec_lim_rec.max_students_per_waitlist ;
       ELSIF  p_usec_rec.usec_max_students_per_waitlist  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.usec_max_students_per_waitlist  :=0;
       END IF;

       IF p_usec_rec.enrollment_expected  IS NULL  THEN
	  p_usec_rec.enrollment_expected  := c_usec_lim_rec.enrollment_expected ;
       ELSIF  p_usec_rec.enrollment_expected  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.enrollment_expected  :=NULL;
       END IF;

       IF p_usec_rec.enrollment_minimum  IS NULL  THEN
	  p_usec_rec.enrollment_minimum  := c_usec_lim_rec.enrollment_minimum ;
       ELSIF  p_usec_rec.enrollment_minimum  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.enrollment_minimum  :=NULL;
       END IF;

       IF p_usec_rec.enrollment_maximum  IS NULL  THEN
	  p_usec_rec.enrollment_maximum  := c_usec_lim_rec.enrollment_maximum ;
       ELSIF  p_usec_rec.enrollment_maximum  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.enrollment_maximum  :=NULL;
       END IF;

       IF p_usec_rec.advance_maximum  IS NULL  THEN
	  p_usec_rec.advance_maximum  := c_usec_lim_rec.advance_maximum ;
       ELSIF  p_usec_rec.advance_maximum  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.advance_maximum  :=NULL;
       END IF;

       IF p_usec_rec.override_enrollment_maximum  IS NULL  THEN
	  p_usec_rec.override_enrollment_maximum  := c_usec_lim_rec.override_enrollment_max ;
       ELSIF  p_usec_rec.override_enrollment_maximum  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.override_enrollment_maximum  :=NULL;
       END IF;

       IF p_usec_rec.max_auditors_allowed  IS NULL  THEN
	  p_usec_rec.max_auditors_allowed  := c_usec_lim_rec.max_auditors_allowed ;
       ELSIF  p_usec_rec.max_auditors_allowed  = FND_API.G_MISS_NUM THEN
	  p_usec_rec.max_auditors_allowed  :=NULL;
       END IF;
     END IF;

   END Assign_default;


   PROCEDURE validate_db_cons(p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,p_insert_update VARCHAR2 ) AS
   BEGIN
      IF p_insert_update = 'I' THEN
	IF igs_ps_usec_lim_wlst_pkg.get_uk_for_validation(l_n_uoo_id) THEN
	   p_usec_rec.status :='W';
	   fnd_message.set_name('IGS','IGS_PS_USEC_ENR_LMTS');
	   igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', fnd_message.get, NULL, FALSE);
	END IF;
      END IF;

      IF p_usec_rec.enrollment_expected IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ver_pkg.check_constraints('ENROLLMENT_EXPECTED',p_usec_rec.enrollment_expected);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ENROLLMENT_EXPECTED','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF p_usec_rec.enrollment_minimum IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ver_pkg.check_constraints('ENROLLMENT_MINIMUM',p_usec_rec.enrollment_minimum);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ENROLLMENT_MINIMUM','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF p_usec_rec.enrollment_maximum IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ver_pkg.check_constraints('ENROLLMENT_MAXIMUM',p_usec_rec.enrollment_maximum);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ENROLLMENT_MAXIMUM','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF p_usec_rec.advance_maximum IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ver_pkg.check_constraints('ADVANCE_MAXIMUM',p_usec_rec.advance_maximum);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','ADVANCE_MAXIMUM','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF p_usec_rec.override_enrollment_maximum IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ver_pkg.check_constraints('OVERRIDE_ENROLLMENT_MAX',p_usec_rec.override_enrollment_maximum);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','OVERRIDE_ENROLLMENT_MAX','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF p_usec_rec.max_auditors_allowed IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ver_pkg.check_constraints('MAX_AUDITORS_ALLOWED',p_usec_rec. max_auditors_allowed);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','MAX_AUDITORS_ALLOWED','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF p_usec_rec.usec_waitlist_allowed IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ofr_pat_pkg.check_constraints ('WAITLIST_ALLOWED', p_usec_rec.usec_waitlist_allowed);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N','WAITLIST_ALLOWED', 'LEGACY_TOKENS', TRUE);
	       p_usec_rec.status := 'E';
	 END;
      END IF;

      IF p_usec_rec.usec_max_students_per_waitlist IS NOT NULL THEN
	 BEGIN
	    igs_ps_unit_ofr_pat_pkg.check_constraints('MAX_STUDENTS_PER_WAITLIST',p_usec_rec.usec_max_students_per_waitlist);
	 EXCEPTION
	    WHEN OTHERS THEN
	       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_999999','MAX_STUDENTS_PER_WAITLIST','LEGACY_TOKENS',TRUE);
	       p_usec_rec.status :='E';
	 END;
      END IF;

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
	 igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
	 p_usec_rec.status := 'E';
      END IF;

   END validate_db_cons;

   BEGIN

      IF p_usec_rec.enrollment_expected   IS NULL AND
         p_usec_rec.enrollment_minimum    IS NULL AND
	 p_usec_rec.enrollment_maximum    IS NULL AND
         p_usec_rec.advance_maximum       IS NULL AND
         p_usec_rec.usec_waitlist_allowed IS NULL AND
         p_usec_rec.usec_max_students_per_waitlist IS NULL AND
         p_usec_rec.override_enrollment_maximum IS NULL AND
         p_usec_rec.max_auditors_allowed  IS NULL THEN

	 --No need to insert/update the empty record
	 NULL ;
      ELSE

        IF p_usec_rec.status = 'S' THEN
	  get_uoo_id ( p_usec_rec);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_get_uoo_id',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
          END IF;

	END IF;

	 --Find out whether it is insert/update of record
	 l_insert_update:='I';
	 IF p_usec_rec.status = 'S' AND p_calling_context IN ('G', 'S') THEN
	   l_insert_update:= check_insert_update(p_usec_rec);

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	     fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_check_insert_update',
	    'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
           END IF;

	 END IF;

	IF p_usec_rec.status = 'S' THEN
	  Assign_default(p_usec_rec,l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_Assign_default',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
          END IF;

	END IF;

	IF p_usec_rec.status = 'S' THEN
	  validate_db_cons(p_usec_rec,l_insert_update);

     	 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
           fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_validate_db_cons',
	  'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	   ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	   p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
         END IF;

	END IF;

	IF p_usec_rec.status = 'S' THEN
	  igs_ps_validate_lgcy_pkg.validate_usec_el (p_usec_rec,l_n_uoo_id,l_insert_update);

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_business_validations',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
          END IF;

	END IF;

	IF p_usec_rec.status = 'S' THEN
	  IF l_insert_update = 'I' THEN
	    /* Insert Record */
	    INSERT INTO igs_ps_usec_lim_wlst
	    (unit_section_limit_waitlist_id,
	    uoo_id,
	    enrollment_expected,
	    enrollment_minimum ,
	    enrollment_maximum ,
	    advance_maximum,
	    waitlist_allowed ,
	    max_students_per_waitlist,
	    override_enrollment_max,
	    max_auditors_allowed,
	    created_by ,
	    creation_date,
	    last_updated_by,
	    last_update_date ,
	    last_update_login
	    )
	    VALUES
	    (
	    igs_ps_usec_lim_wlst_s.nextval,
	    l_n_uoo_id,
	    p_usec_rec.enrollment_expected,
	    p_usec_rec.enrollment_minimum,
	    p_usec_rec.enrollment_maximum,
	    p_usec_rec.advance_maximum,
	    p_usec_rec.usec_waitlist_allowed,
	    p_usec_rec.usec_max_students_per_waitlist,
	    p_usec_rec.override_enrollment_maximum,
	    p_usec_rec.max_auditors_allowed,
	    g_n_user_id,
	    sysdate,
	    g_n_user_id,
	    sysdate,
	    g_n_login_id
	   );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.record_inserted',
	     'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class);
           END IF;

         ELSE ---update
	   UPDATE igs_ps_usec_lim_wlst SET
	   enrollment_expected=p_usec_rec.enrollment_expected,
	   enrollment_minimum=p_usec_rec.enrollment_minimum ,
	   enrollment_maximum=p_usec_rec.enrollment_maximum ,
	   advance_maximum=p_usec_rec.advance_maximum,
	   waitlist_allowed=p_usec_rec.usec_waitlist_allowed ,
	   max_students_per_waitlist=p_usec_rec.usec_max_students_per_waitlist,
	   override_enrollment_max=p_usec_rec.override_enrollment_maximum,
	   max_auditors_allowed=p_usec_rec.max_auditors_allowed,
	   last_updated_by = g_n_user_id,
	   last_update_date= SYSDATE ,
	   last_update_login= g_n_login_id
	   WHERE uoo_id =l_n_uoo_id;

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.record_updated',
	     'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	     p_usec_rec.unit_class);
           END IF;

	 END IF;

	 igs_ps_validate_lgcy_pkg.post_usec_limits(p_usec_rec,p_calling_context,l_n_uoo_id,l_insert_update);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_post_usec_limits',
	   'Unit code:'||p_usec_rec.unit_cd||'  '||'Version number:'||p_usec_rec.version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_rec.teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_rec.location_cd||'  '||'Unit Class:'||
	    p_usec_rec.unit_class||'  '||'Status:'||p_usec_rec.status);
          END IF;

       END IF;

     END IF;

    END create_usec_el;


  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.start_logging_for','Unit Sections');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_usec_tbl.LAST LOOP
      IF p_usec_tbl.EXISTS(I) THEN
        p_usec_tbl(I).status := 'S';
        p_usec_tbl(I).msg_from := fnd_msg_pub.count_msg;
	l_conc_flag := FALSE;

        trim_values(p_usec_tbl(I));
        -- Create Unit Offering

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.call',
	  'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_tbl(I).teach_cal_alternate_code);
        END IF;

        create_uo ( p_usec_rec => p_usec_tbl(I) );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uo.status_after_record_creation',
	  'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Status:'||p_usec_tbl(I).status);
        END IF;


        IF p_usec_tbl(I).status = 'S' THEN
            -- Create Unit Offering Pattern

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.call',
	      'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_tbl(I).teach_cal_alternate_code);
            END IF;

            create_uop ( p_usec_tbl(I) );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uop.status_after_record_creation',
	      'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Status:'||p_usec_tbl(I).status);
           END IF;

        END IF;

        IF p_usec_tbl(I).status = 'S' THEN
          -- Create Unit Offering Option
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.call',
	    'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_tbl(I).unit_class);
          END IF;

	  create_uoo ( p_usec_tbl(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_uoo.status_after_record_creation',
	    'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_tbl(I).unit_class||'  '||'Status:'||p_usec_tbl(I).status);
          END IF;
        END IF;
        IF p_usec_tbl(I).status = 'S' THEN
          -- Create Unit Section Credit Points
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.call',
	    'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_tbl(I).unit_class);
          END IF;

          create_cp ( p_usec_tbl(I) );

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_cp.status_after_record_creation',
	    'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_tbl(I).unit_class||'  '||'Status:'||p_usec_tbl(I).status);
          END IF;

        END IF;
        IF p_usec_tbl(I).status = 'S' THEN
          -- Create Unit Section Reference
	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.call',
	    'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_tbl(I).unit_class);
          END IF;

          create_ref ( p_usec_tbl(I) );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_ref.status_after_record_creation',
	    'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	    p_usec_tbl(I).unit_class||'  '||'Status:'||p_usec_tbl(I).status);
          END IF;

        END IF;
        IF p_usec_tbl(I).status = 'S' THEN
           -- Create Unit Section Enrollment Limits
	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.call',
	     'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_tbl(I).unit_class);
           END IF;

           create_usec_el ( p_usec_tbl(I) );

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.create_usec_el.status_after_record_creation',
	     'Unit code:'||p_usec_tbl(I).unit_cd||'  '||'Version number:'||p_usec_tbl(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_usec_tbl(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_usec_tbl(I).location_cd||'  '||'Unit Class:'||
	     p_usec_tbl(I).unit_class||'  '||'Status:'||p_usec_tbl(I).status);
          END IF;

        END IF;

	-- if the unit section status changed to CANCELLED then invoke the concurrent program to transfer the data to interface
	-- the flag is set in validate_uoo(IGSPS86B.pls)
	IF l_conc_flag THEN
	  IF NOT Igs_ps_usec_schedule.prgp_upd_usec_dtls(
						     p_uoo_id=>l_n_uoo_id,
						     p_usec_status=>p_usec_tbl(I).unit_section_status,
						     p_request_id=>l_request_id,
						     p_message_name=>l_message_name) THEN

		  fnd_message.set_name ('IGS', l_message_name);
		  fnd_msg_pub.add;
		  p_usec_tbl(I).status := 'E';
	  END IF;
	END IF;

        IF  p_usec_tbl(I).status = 'S' THEN
           p_usec_tbl(I).msg_from := NULL;
           p_usec_tbl(I).msg_to := NULL;
        ELSIF  p_usec_tbl(I).status = 'A' THEN
	   p_usec_tbl(I).msg_from  := p_usec_tbl(I).msg_from + 1;
	   p_usec_tbl(I).msg_to := fnd_msg_pub.count_msg;
	ELSE
           p_c_rec_status :=  p_usec_tbl(I).status;
           p_usec_tbl(I).msg_from :=  p_usec_tbl(I).msg_from + 1;
           p_usec_tbl(I).msg_to := fnd_msg_pub.count_msg;
           IF p_c_rec_status = 'E' THEN
             RETURN;
           END IF;
        END IF;
      END IF;--exists
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_section.after_import_status',p_c_rec_status);
    END IF;

  END create_unit_section;


  PROCEDURE create_usec_grd_sch (
            p_tab_usec_gs IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
            p_c_rec_status OUT NOCOPY VARCHAR2,
	    p_calling_context  IN VARCHAR2
  ) AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  18-NOV-2002
    Purpose        :  This procedure is a sub process to insert records of Unit Section Grading Schema.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
     l_insert_update  VARCHAR2(1);
     l_n_uoo_id       igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
     l_tbl_uoo        igs_ps_create_generic_pkg.uoo_tbl_type;

    /* Private Procedures for create_usec_grd_sch */
    PROCEDURE trim_values ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type ) AS
    BEGIN
      p_usec_gs_rec.unit_cd := trim(p_usec_gs_rec.unit_cd);
      p_usec_gs_rec.version_number := trim(p_usec_gs_rec.version_number);
      p_usec_gs_rec.teach_cal_alternate_code := trim(p_usec_gs_rec.teach_cal_alternate_code);
      p_usec_gs_rec.location_cd := trim(p_usec_gs_rec.location_cd);
      p_usec_gs_rec.unit_class := trim(p_usec_gs_rec.unit_class);
      p_usec_gs_rec.grading_schema_code := trim(p_usec_gs_rec.grading_schema_code);
      p_usec_gs_rec.grd_schm_version_number := trim(p_usec_gs_rec.grd_schm_version_number);
      p_usec_gs_rec.default_flag := trim(p_usec_gs_rec.default_flag);
    END trim_values;

    -- validate parameters passed.
    PROCEDURE validate_parameters ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type ) AS
    BEGIN

      /* Check for Mandatory Parameters */
      IF p_usec_gs_rec.unit_cd IS NULL OR p_usec_gs_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.version_number IS NULL OR p_usec_gs_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.teach_cal_alternate_code IS NULL OR p_usec_gs_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.location_cd IS NULL OR p_usec_gs_rec.location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.unit_class IS NULL OR p_usec_gs_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.grading_schema_code IS NULL OR p_usec_gs_rec.grading_schema_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_GRADING_SCHM_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.grd_schm_version_number IS NULL OR p_usec_gs_rec.grd_schm_version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_GRADING_SCHM_VER_NUM', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
      IF p_usec_gs_rec.default_flag IS NULL OR p_usec_gs_rec.default_flag = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'DEFAULT_FLAG', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
    END validate_parameters;

    -- Check for Update
    FUNCTION check_insert_update ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type ) RETURN VARCHAR2 IS
       CURSOR c_usec_gs(p_grading_schema_code IN VARCHAR2,p_grd_schm_version_number NUMBER ,p_n_uoo_id NUMBER) IS
       SELECT 'X'
       FROM  igs_ps_usec_grd_schm
       WHERE grading_schema_code =p_grading_schema_code
       AND grd_schm_version_number = p_grd_schm_version_number
       AND uoo_id = p_n_uoo_id;

       c_usec_gs_rec c_usec_gs%ROWTYPE;
    BEGIN

	OPEN c_usec_gs(p_usec_gs_rec.grading_schema_code,p_usec_gs_rec.grd_schm_version_number, l_n_uoo_id);
	FETCH c_usec_gs INTO c_usec_gs_rec;
	IF c_usec_gs%NOTFOUND THEN
          CLOSE c_usec_gs;
	 RETURN 'I';
        ELSE
         CLOSE c_usec_gs;
	 RETURN 'U';
        END IF;

    END check_insert_update;

    -- Carry out derivations and validate them
    PROCEDURE validate_derivations ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type ) AS
      l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
      l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
      l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
      l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
      l_c_message  VARCHAR2(30);
    BEGIN


      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_usec_gs_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;


      -- Derive uoo_id
      l_c_message := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_usec_gs_rec.unit_cd,
                                            p_ver_num    => p_usec_gs_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_usec_gs_rec.location_cd,
                                            p_unit_class => p_usec_gs_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF ( l_c_message IS NOT NULL ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;

    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type,p_insert_update VARCHAR2 ) AS
    BEGIN
      IF (p_insert_update = 'I') THEN
	/* Unique Key Validation */
	IF igs_ps_usec_grd_schm_pkg.get_uk_for_validation ( x_grading_schema_code => p_usec_gs_rec.grading_schema_code,
							    x_grd_schm_version_number => p_usec_gs_rec.grd_schm_version_number,
							    x_uoo_id => l_n_uoo_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_GRADING_SCHM', 'LEGACY_TOKENS', FALSE);
	  p_usec_gs_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      /* Validate Check Constraints */
      BEGIN
        igs_ps_usec_grd_schm_pkg.check_constraints ( 'DEFAULT_FLAG', p_usec_gs_rec.default_flag );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'DEFAULT_FLAG', 'LEGACY_TOKENS', TRUE);
          p_usec_gs_rec.status := 'E';
      END;

      /* Validate FK Constraints */
      IF NOT igs_as_grd_schema_pkg.get_pk_for_validation ( p_usec_gs_rec.grading_schema_code, p_usec_gs_rec.grd_schm_version_number) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_GRADING_SCHM', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;

      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_usec_gs_rec.status := 'E';
      END IF;
    END validate_db_cons;


  /* Main Unit Section Grading Schema Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.start_logging_for','Unit Section Grading Schema');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_tab_usec_gs.LAST LOOP

      IF p_tab_usec_gs.EXISTS(I) THEN
        l_n_uoo_id := NULL;
        p_tab_usec_gs(I).status := 'S';
        p_tab_usec_gs(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_tab_usec_gs(I) );
        validate_parameters ( p_tab_usec_gs(I) );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.status_after_validate_parameters',
	  'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	  p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
          ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Status:'||p_tab_usec_gs(I).status);
        END IF;

	IF p_tab_usec_gs(I).status = 'S' THEN
          validate_derivations ( p_tab_usec_gs(I));

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.status_after_validate_derivations',
	    'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
            ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Status:'||p_tab_usec_gs(I).status);
          END IF;

        END IF;

	--Find out whether it is insert/update of record
        l_insert_update:='I';
        IF p_tab_usec_gs(I).status = 'S' AND p_calling_context IN ('G','S') THEN
            l_insert_update:= check_insert_update(p_tab_usec_gs(I));

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
              fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.status_after_check_insert_update',
	      'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	      ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	      p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
              ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Status:'||p_tab_usec_gs(I).status);
            END IF;

        END IF;


	-- Find out whether record can go for import in context of cancelled/aborted
	IF  p_tab_usec_gs(I).status = 'S' AND p_calling_context = 'S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,NULL) = FALSE THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
	    fnd_msg_pub.add;
	    p_tab_usec_gs(I).status := 'A';
	  END IF;

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.status_after_check_import_allowed',
	    'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
            ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Status:'||p_tab_usec_gs(I).status);
          END IF;

	END IF;

        IF l_tbl_uoo.count = 0 THEN
          l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
	ELSE
	  IF NOT igs_ps_validate_lgcy_pkg.isExists(l_n_uoo_id,l_tbl_uoo) THEN
	    l_tbl_uoo(l_tbl_uoo.count+1) :=l_n_uoo_id;
          END IF;
	END IF;

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.count_unique_uoo_ids',
	    'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
            ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Count:'||l_tbl_uoo.count);
         END IF;

	IF p_tab_usec_gs(I).status = 'S' THEN
          validate_db_cons ( p_tab_usec_gs(I),l_insert_update );

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.status_after_validate_db_cons',
	    'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
            ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Status:'||p_tab_usec_gs(I).status);
          END IF;

        END IF;



        /* Business Validations */
        /* Proceed with business validations only if the status is Success, 'S' */
        IF p_tab_usec_gs(I).status = 'S' THEN
          igs_ps_validate_lgcy_pkg.validate_usec_grd_sch ( p_tab_usec_gs(I),l_n_uoo_id );

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.status_after_Business_validation',
	    'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
            ||p_tab_usec_gs(I).grd_schm_version_number||'  '||'Status:'||p_tab_usec_gs(I).status);
          END IF;

        END IF;

        IF p_tab_usec_gs(I).status = 'S'  THEN
	  IF l_insert_update = 'I' THEN
             /* Insert Record */
             INSERT INTO igs_ps_usec_grd_schm
             (unit_section_grading_schema_id,
             uoo_id,
             grading_schema_code,
             grd_schm_version_number,
             default_flag,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login
             )
             VALUES
             (igs_ps_usec_grd_schm_s.NEXTVAL,
             l_n_uoo_id,
             p_tab_usec_gs(I).grading_schema_code,
             p_tab_usec_gs(I).grd_schm_version_number,
             p_tab_usec_gs(I).default_flag,
             g_n_user_id,
             SYSDATE,
             g_n_user_id,
             SYSDATE,
             g_n_login_id
             );

             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.record_inserted',
	       'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	       p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
               ||p_tab_usec_gs(I).grd_schm_version_number);
             END IF;


         ELSE
	      /*Update record*/
              UPDATE igs_ps_usec_grd_schm
	      SET default_flag = p_tab_usec_gs(I).default_flag,
	      last_updated_by = g_n_user_id,
	      last_update_date = SYSDATE,
              last_update_login = g_n_login_id
	      WHERE grading_schema_code = p_tab_usec_gs(I).grading_schema_code
	      AND grd_schm_version_number = p_tab_usec_gs(I).grd_schm_version_number
	      AND uoo_id = l_n_uoo_id;

	      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
               fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.record_updated',
	       'Unit code:'||p_tab_usec_gs(I).unit_cd||'  '||'Version number:'||p_tab_usec_gs(I).version_number||'  '||'teach_cal_alternate_code:'
	       ||p_tab_usec_gs(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_gs(I).location_cd||'  '||'Unit Class:'||
	       p_tab_usec_gs(I).unit_class||'  '||'Grading Schema Code:'||p_tab_usec_gs(I).grading_schema_code||' '||'Grading Schema Version Number:'
               ||p_tab_usec_gs(I).grd_schm_version_number);
             END IF;

	 END IF;--insert/update
       END IF;

       IF p_tab_usec_gs(I).status = 'S' THEN
	  p_tab_usec_gs(I).msg_from := NULL;
	  p_tab_usec_gs(I).msg_to := NULL;
       ELSIF   p_tab_usec_gs(I).status = 'A' THEN
	  p_tab_usec_gs(I).msg_from  :=  p_tab_usec_gs(I).msg_from + 1;
	  p_tab_usec_gs(I).msg_to := fnd_msg_pub.count_msg;
       ELSE
          p_c_rec_status := p_tab_usec_gs(I).status;
          p_tab_usec_gs(I).msg_from := p_tab_usec_gs(I).msg_from+1;
          p_tab_usec_gs(I).msg_to := fnd_msg_pub.count_msg;
          IF p_tab_usec_gs(I).status = 'E' THEN
            RETURN;
          END IF;
       END IF;

     END IF;--exists
   END LOOP;

	    /* Post Insert/Update Checks */
   IF NOT igs_ps_validate_lgcy_pkg.post_usec_grd_sch (p_tab_usec_gs,l_tbl_uoo) THEN
     p_c_rec_status := 'E';
   END IF;
   l_tbl_uoo.DELETE;

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
     fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_grd_sch.after_import_status',p_c_rec_status);
   END IF;


 END create_usec_grd_sch;

 PROCEDURE create_usec_occur ( p_tab_usec_occur IN OUT NOCOPY igs_ps_generic_pub.uso_tbl_type,
                                p_c_rec_status OUT NOCOPY VARCHAR2,
 			        p_calling_context  IN VARCHAR2) AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  19-NOV-2002
    Purpose        :  This procedure is a sub process to insert records of Unit Section Occurrence.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    02-AUG-2006     Bug#5356402, Using a PL/SQl table l_tbl_uso to store USO that get inserted.
    sommukhe    27-APR-2006     Bug#5122473,Modified the cursor check_ovrd to include Date override check
                                so that the Scheduling API considers Date Occurrence Override during import.
    sommukhe    27-SEP-2005     Bug #4632652.Used cursor c_build_id to derive Building id.
    smvk        25-jun-2003     Enh bug#2918094. Added column cancel_flag and its value will be 'N'
    jbegum      3-June-2003     Enh Bug#2972950
                                For PSP Scheduling Enhancements TD:
                                Modified the local procedure's validate_derivation,validate_db_cons.
  ********************************************************************************************** */

    l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
    l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
    l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
    l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
    l_n_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_n_uso_id   igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE;
    l_n_usec_occurs_id	igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE;

    l_n_building_code           igs_ps_usec_occurs_all.building_code%TYPE;
    l_n_dedicated_building_code igs_ps_usec_occurs_all.dedicated_building_code%TYPE;
    l_n_preferred_building_code igs_ps_usec_occurs_all.preferred_building_code%TYPE;

    l_n_room_code           igs_ps_usec_occurs_all.room_code%TYPE;
    l_n_dedicated_room_code igs_ps_usec_occurs_all.dedicated_room_code%TYPE;
    l_n_preferred_room_code igs_ps_usec_occurs_all.preferred_room_code%TYPE;

    l_c_schedule_status     igs_ps_usec_occurs_all.schedule_status%TYPE;
    l_notify_status         igs_ps_usec_occurs_all.notify_status%TYPE;

    l_insert_update VARCHAR2(1);
    l_n_tbl_cnt NUMBER;



    PROCEDURE trim_values ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type ) AS
    BEGIN
      p_uso_rec.unit_cd := trim(p_uso_rec.unit_cd);
      p_uso_rec.version_number := trim(p_uso_rec.version_number);
      p_uso_rec.teach_cal_alternate_code := trim(p_uso_rec.teach_cal_alternate_code);
      p_uso_rec.location_cd := trim(p_uso_rec.location_cd);
      p_uso_rec.unit_class := trim(p_uso_rec.unit_class);
      p_uso_rec.occurrence_identifier := trim(p_uso_rec.occurrence_identifier);
      p_uso_rec.to_be_announced     := trim(p_uso_rec.to_be_announced);
      p_uso_rec.monday := trim(p_uso_rec.monday);
      p_uso_rec.tuesday := trim(p_uso_rec.tuesday);
      p_uso_rec.wednesday := trim(p_uso_rec.wednesday);
      p_uso_rec.thursday := trim(p_uso_rec.thursday);
      p_uso_rec.friday := trim(p_uso_rec.friday);
      p_uso_rec.saturday := trim(p_uso_rec.saturday);
      p_uso_rec.sunday := trim(p_uso_rec.sunday);
      p_uso_rec.start_date := TRUNC(p_uso_rec.start_date);
      p_uso_rec.end_date := TRUNC(p_uso_rec.end_date);
      p_uso_rec.building_code := trim(p_uso_rec.building_code);
      p_uso_rec.room_code := trim(p_uso_rec.room_code);
      p_uso_rec.dedicated_building_code := trim(p_uso_rec.dedicated_building_code);
      p_uso_rec.dedicated_room_code := trim(p_uso_rec.dedicated_room_code);
      p_uso_rec.preferred_building_code := trim(p_uso_rec.preferred_building_code);
      p_uso_rec.preferred_room_code := trim(p_uso_rec.preferred_room_code);
      p_uso_rec.no_set_day_ind := trim(p_uso_rec.no_set_day_ind);
      p_uso_rec.preferred_region_code := trim(p_uso_rec.preferred_region_code);
      p_uso_rec.attribute_category := trim(p_uso_rec.attribute_category);
      p_uso_rec.attribute1 := trim(p_uso_rec.attribute1);
      p_uso_rec.attribute2 := trim(p_uso_rec.attribute2);
      p_uso_rec.attribute3 := trim(p_uso_rec.attribute3);
      p_uso_rec.attribute4 := trim(p_uso_rec.attribute4);
      p_uso_rec.attribute5 := trim(p_uso_rec.attribute5);
      p_uso_rec.attribute6 := trim(p_uso_rec.attribute6);
      p_uso_rec.attribute7 := trim(p_uso_rec.attribute7);
      p_uso_rec.attribute8 := trim(p_uso_rec.attribute8);
      p_uso_rec.attribute9 := trim(p_uso_rec.attribute9);
      p_uso_rec.attribute10 := trim(p_uso_rec.attribute10);
      p_uso_rec.attribute11 := trim(p_uso_rec.attribute11);
      p_uso_rec.attribute12 := trim(p_uso_rec.attribute12);
      p_uso_rec.attribute13 := trim(p_uso_rec.attribute13);
      p_uso_rec.attribute14 := trim(p_uso_rec.attribute14);
      p_uso_rec.attribute15 := trim(p_uso_rec.attribute15);
      p_uso_rec.attribute16 := trim(p_uso_rec.attribute16);
      p_uso_rec.attribute17 := trim(p_uso_rec.attribute17);
      p_uso_rec.attribute18 := trim(p_uso_rec.attribute18);
      p_uso_rec.attribute19 := trim(p_uso_rec.attribute19);
      p_uso_rec.attribute20 := trim(p_uso_rec.attribute20);

    END trim_values;

    /* Private Procedures for create_usec_occur */
    PROCEDURE validate_parameters ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type ) AS
    BEGIN

     /* Check for Mandatory Parameters */
      IF p_uso_rec.unit_cd IS NULL OR p_uso_rec.unit_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;
      IF p_uso_rec.version_number IS NULL OR p_uso_rec.version_number = FND_API.G_MISS_NUM THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VERSION', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;
      IF p_uso_rec.teach_cal_alternate_code IS NULL OR p_uso_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;
      IF p_uso_rec.location_cd IS NULL  OR p_uso_rec.location_cd = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;
      IF p_uso_rec.unit_class IS NULL OR p_uso_rec.unit_class = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;
      IF p_uso_rec.occurrence_identifier IS NULL OR p_uso_rec.occurrence_identifier = FND_API.G_MISS_CHAR THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_OCCRS_ID', 'IGS_PS_LOG_PARAMETERS', FALSE);
        p_uso_rec.status := 'E';
      END IF;

    END validate_parameters;

    PROCEDURE validate_derivations ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type ) AS

    CURSOR c_bld_id ( cp_building_cd igs_ad_building_all.building_cd%TYPE,
                      cp_location_cd igs_ad_building_all.location_cd%TYPE ) IS
    SELECT building_id
    FROM igs_ad_building_all
    WHERE
      building_cd = cp_building_cd AND
      location_cd = cp_location_cd;

    CURSOR c_build_id ( cp_building_cd igs_ad_building_all.building_cd%TYPE) IS
    SELECT building_id
    FROM igs_ad_building_all
    WHERE building_cd = cp_building_cd;

    CURSOR c_room_id ( cp_building_id igs_ad_building_all.building_id%TYPE,
                       cp_room_cd igs_ad_room_all.room_cd%TYPE ) IS
    SELECT room_id
    FROM igs_ad_room_all
    WHERE
      room_cd = cp_room_cd AND
      building_id = cp_building_id;

    l_c_message  VARCHAR2(30);

    BEGIN
      l_c_message :=NULL;

      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_uso_rec.teach_cal_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;

      l_c_message :=NULL;

      -- Derive uoo_id
      igs_ps_validate_lgcy_pkg.get_uoo_id ( p_unit_cd    => p_uso_rec.unit_cd,
                                            p_ver_num    => p_uso_rec.version_number,
                                            p_cal_type   => l_c_cal_type,
                                            p_seq_num    => l_n_seq_num,
                                            p_loc_cd     => p_uso_rec.location_cd,
                                            p_unit_class => p_uso_rec.unit_class,
                                            p_uoo_id     => l_n_uoo_id,
                                            p_message    => l_c_message );
      IF ( l_c_message IS NOT NULL ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;

      -- Derive Building Identifier and associated Room Identifier.
      IF p_uso_rec.building_code IS NOT NULL AND p_uso_rec.building_code <> FND_API.G_MISS_CHAR THEN
        OPEN c_build_id ( p_uso_rec.building_code);
        FETCH c_build_id INTO l_n_building_code;
        IF ( c_build_id%NOTFOUND ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
            p_uso_rec.status := 'E';
        END IF;
        CLOSE c_build_id;

        -- Derive Room Identifier
        IF p_uso_rec.room_code IS NOT NULL AND p_uso_rec.room_code <> FND_API.G_MISS_CHAR THEN
          OPEN c_room_id ( l_n_building_code, p_uso_rec.room_code );
          FETCH c_room_id INTO l_n_room_code;
          IF ( c_room_id%NOTFOUND ) THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
              p_uso_rec.status := 'E';
          END IF;
          CLOSE c_room_id;
        END IF;
      END IF;

      -- Derive Dedicated Building Identifier associated Room Identifier
      IF p_uso_rec.dedicated_building_code IS NOT NULL AND p_uso_rec.dedicated_building_code <> FND_API.G_MISS_CHAR THEN
        OPEN c_bld_id ( p_uso_rec.dedicated_building_code, p_uso_rec.location_cd );
        FETCH c_bld_id INTO l_n_dedicated_building_code;
        IF ( c_bld_id%NOTFOUND ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED', 'LEGACY_TOKENS') || ' ' ||
                                           igs_ps_validate_lgcy_pkg.get_lkup_meaning('BUILDING_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
          p_uso_rec.status := 'E';
        END IF;
        CLOSE c_bld_id;

        -- Derive Dedicated Room Identifier
        IF p_uso_rec.dedicated_room_code IS NOT NULL AND p_uso_rec.dedicated_room_code <> FND_API.G_MISS_CHAR THEN
          OPEN c_room_id ( l_n_dedicated_building_code, p_uso_rec.dedicated_room_code );
          FETCH c_room_id INTO l_n_dedicated_room_code;
          IF ( c_room_id%NOTFOUND ) THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED', 'LEGACY_TOKENS') || ' ' ||
                                             igs_ps_validate_lgcy_pkg.get_lkup_meaning('ROOM_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
            p_uso_rec.status := 'E';
          END IF;
          CLOSE c_room_id;
        END IF;
      END IF;

      -- Derive Preferred Building Identifier
      IF p_uso_rec.preferred_building_code IS NOT NULL AND p_uso_rec.preferred_building_code <> FND_API.G_MISS_CHAR THEN
        OPEN c_bld_id ( p_uso_rec.preferred_building_code, p_uso_rec.location_cd );
        FETCH c_bld_id INTO l_n_preferred_building_code;
        IF ( c_bld_id%NOTFOUND ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED', 'LEGACY_TOKENS') || ' ' ||
                                            igs_ps_validate_lgcy_pkg.get_lkup_meaning('BUILDING_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
          p_uso_rec.status := 'E';
        END IF;
        CLOSE c_bld_id;

        -- Derive Preferred Room Identifier
        IF p_uso_rec.preferred_room_code IS NOT NULL AND p_uso_rec.preferred_room_code <> FND_API.G_MISS_CHAR THEN
          OPEN c_room_id ( l_n_preferred_building_code, p_uso_rec.preferred_room_code );
          FETCH c_room_id INTO l_n_preferred_room_code;
          IF ( c_room_id%NOTFOUND ) THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED', 'LEGACY_TOKENS') || ' ' ||
                                             igs_ps_validate_lgcy_pkg.get_lkup_meaning('ROOM_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
            p_uso_rec.status := 'E';
          END IF;
          CLOSE c_room_id;
        END IF;
      END IF;


    END validate_derivations;

    -- Validate Database Constraints
    PROCEDURE validate_db_cons ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type,p_insert IN VARCHAR2 ) AS
    BEGIN

    /* Validate Check Constraints */

      -- Following validation added as part of bug#2972950 for the PSP Scheduling Enhancements TD
      -- If No Set Day Indicator is not NULL then it should have a value of either of 'Y' or 'N'
      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'NO_SET_DAY_IND', p_uso_rec.no_set_day_ind );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'NO_SET_DAY_IND', 'LEGACY_TOKENS', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'TO_BE_ANNOUNCED', p_uso_rec.to_be_announced );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'TO_BE_ANNOUNCED', 'LEGACY_TOKENS', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'MONDAY', p_uso_rec.monday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'MONDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'TUESDAY', p_uso_rec.tuesday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'TUESDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'WEDNESDAY', p_uso_rec.wednesday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'WEDNESDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'THURSDAY', p_uso_rec.thursday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'THURSDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'FRIDAY', p_uso_rec.friday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'FRIDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'SATURDAY', p_uso_rec.saturday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'SATURDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;

      BEGIN
        igs_ps_usec_occurs_pkg.check_constraints ( 'SUNDAY', p_uso_rec.sunday );
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N', 'SUNDAY', 'DT_OFFSET_CONSTRAINT_TYPE', TRUE);
          p_uso_rec.status := 'E';
      END;


      IF p_insert = 'I' THEN
	/* Unique Key Validation */
	IF igs_ps_usec_occurs_pkg.get_uk_for_validation ( x_uoo_id => l_n_uoo_id ,
							  x_occurrence_identifier => p_uso_rec.occurrence_identifier
							 ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'USEC_OCCRS_ID', 'IGS_PS_LOG_PARAMETERS', FALSE);
	  p_uso_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      /* Validate FK Constraints */

      -- Check for the existence of Unit Section
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation ( l_n_uoo_id ) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
        p_uso_rec.status := 'E';
      END IF;

      -- Check for the existence of Buildings, if their codes are passed
      IF l_n_building_code IS NOT NULL THEN
        IF NOT igs_ad_building_pkg.get_pk_for_validation ( l_n_building_code ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      IF  l_n_dedicated_building_code  IS NOT NULL THEN
        IF NOT igs_ad_building_pkg.get_pk_for_validation ( l_n_dedicated_building_code ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED', 'LEGACY_TOKENS') || ' ' ||
                                            igs_ps_validate_lgcy_pkg.get_lkup_meaning('BUILDING_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      IF  l_n_preferred_building_code  IS NOT NULL THEN
        IF NOT igs_ad_building_pkg.get_pk_for_validation ( l_n_preferred_building_code ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED', 'LEGACY_TOKENS') || ' ' ||
                                            igs_ps_validate_lgcy_pkg.get_lkup_meaning('BUILDING_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      -- Check for the existence of Rooms, if their codes are passed
      IF  l_n_room_code IS NOT NULL THEN
        IF NOT igs_ad_room_pkg.get_pk_for_validation ( l_n_room_code ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      IF  l_n_dedicated_room_code IS NOT NULL THEN
        IF NOT igs_ad_room_pkg.get_pk_for_validation ( l_n_dedicated_room_code ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED', 'LEGACY_TOKENS') || ' ' ||
                                            igs_ps_validate_lgcy_pkg.get_lkup_meaning('ROOM_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      IF  l_n_preferred_room_code IS NOT NULL THEN
        IF NOT igs_ad_room_pkg.get_pk_for_validation ( l_n_preferred_room_code ) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED', 'LEGACY_TOKENS') || ' ' ||
                                            igs_ps_validate_lgcy_pkg.get_lkup_meaning('ROOM_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      -- Following validation added as part of bug#2972950 for the PSP Scheduling Enhancements TD
      -- If preferred region code is not NULL check it has a valid value
      IF p_uso_rec.preferred_region_code IS NOT NULL THEN
        IF NOT igs_lookups_view_pkg.get_pk_for_validation ('IGS_OR_LOC_REGION',p_uso_rec.preferred_region_code) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','PREFERRED_REGION_CODE','LEGACY_TOKENS',FALSE);
          p_uso_rec.status := 'E';
        ELSIF NOT igs_or_loc_region_pkg.get_pk_for_validation(p_uso_rec.location_cd,p_uso_rec.preferred_region_code) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','PREFERRED_REGION_CODE','LEGACY_TOKENS',FALSE);
          p_uso_rec.status := 'E';
        END IF;
      END IF;

    END validate_db_cons;

---
    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type ) RETURN VARCHAR2 IS

      CURSOR c_occr IS
      SELECT unit_section_occurrence_id
      FROM  igs_ps_usec_occurs_all
      WHERE uoo_id = l_n_uoo_id
      AND   occurrence_identifier=p_uso_rec.occurrence_identifier;

      l_c_occr c_occr%ROWTYPE;

    BEGIN

       OPEN c_occr;
       FETCH c_occr INTO l_c_occr;
       IF c_occr%FOUND THEN
	 CLOSE c_occr;
	 l_n_uso_id := l_c_occr.unit_section_occurrence_id;
	 RETURN 'U';
       ELSE
	 CLOSE c_occr;
	 RETURN 'I';
       END IF;

    END check_insert_update;

    PROCEDURE assign_defaults ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type, p_insert IN VARCHAR2) IS
     CURSOR cur_usec_ocurs ( cp_uso_id IN NUMBER) IS
     SELECT *
     FROM   igs_ps_usec_occurs_all
     WHERE  unit_section_occurrence_id = cp_uso_id;
     l_cur_usec_ocurs cur_usec_ocurs%ROWTYPE;

      CURSOR cur_room (cp_building_id IN NUMBER, cp_room_cd IN VARCHAR2) IS
      SELECT room_id
      FROM igs_ad_room
      WHERE room_cd=cp_room_cd
      AND   building_id=cp_building_id;

    BEGIN
      IF p_insert = 'I' THEN


	-- If To Be Announced is Null then default it to 'N'
	IF ( p_uso_rec.to_be_announced IS NULL ) THEN
	  p_uso_rec.to_be_announced := 'N';
	END IF;

	-- Similarly default days to 'N', if they are NULL.
	IF ( p_uso_rec.monday IS NULL ) THEN
	  p_uso_rec.monday := 'N';
	END IF;

	IF ( p_uso_rec.tuesday IS NULL ) THEN
	  p_uso_rec.tuesday := 'N';
	END IF;

	IF ( p_uso_rec.wednesday IS NULL ) THEN
	  p_uso_rec.wednesday := 'N';
	END IF;

	IF ( p_uso_rec.thursday IS NULL ) THEN
	  p_uso_rec.thursday := 'N';
	END IF;

	IF ( p_uso_rec.friday IS NULL ) THEN
	  p_uso_rec.friday := 'N';
	END IF;

	IF ( p_uso_rec.saturday IS NULL ) THEN
	  p_uso_rec.saturday := 'N';
	END IF;

	IF ( p_uso_rec.sunday IS NULL ) THEN
	  p_uso_rec.sunday := 'N';
	END IF;

	-- Following validation added as part of bug#2972950 for the PSP Scheduling Enhancements TD
	-- If No Set Day Indicator is NULL then default it to 'N'
	IF p_uso_rec.no_set_day_ind IS NULL THEN
	   p_uso_rec.no_set_day_ind := 'N';
	END IF;

	-- Derive schedule status depending on values of building_code/room_code
	IF p_uso_rec.building_code IS NOT NULL THEN
	  l_c_schedule_status     := 'SCHEDULED';
	ELSE
	  l_c_schedule_status     := NULL;
	END IF;

      ELSE

	OPEN cur_usec_ocurs(l_n_uso_id);
	FETCH cur_usec_ocurs INTO l_cur_usec_ocurs;
	CLOSE cur_usec_ocurs;

	IF ( p_uso_rec.to_be_announced IS NULL ) THEN
	  p_uso_rec.to_be_announced := l_cur_usec_ocurs.to_be_announced;
        ELSIF p_uso_rec.to_be_announced = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.to_be_announced := 'N';
	END IF;

	-- Similarly default days to 'N', if they are NULL.
	IF ( p_uso_rec.monday IS NULL ) THEN
	  p_uso_rec.monday := l_cur_usec_ocurs.monday;
        ELSIF p_uso_rec.monday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.monday := 'N';
	END IF;

	IF ( p_uso_rec.tuesday IS NULL ) THEN
	  p_uso_rec.tuesday := l_cur_usec_ocurs.tuesday;
        ELSIF  p_uso_rec.tuesday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.tuesday := 'N';
	END IF;

	IF ( p_uso_rec.wednesday IS NULL ) THEN
	  p_uso_rec.wednesday := l_cur_usec_ocurs.wednesday;
        ELSIF  p_uso_rec.wednesday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.wednesday := 'N';
	END IF;

	IF ( p_uso_rec.thursday IS NULL ) THEN
	  p_uso_rec.thursday := l_cur_usec_ocurs.thursday;
        ELSIF  p_uso_rec.thursday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.thursday := 'N';
	END IF;

	IF ( p_uso_rec.friday IS NULL ) THEN
	  p_uso_rec.friday := l_cur_usec_ocurs.friday;
        ELSIF  p_uso_rec.friday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.friday := 'N';
	END IF;

	IF ( p_uso_rec.saturday IS NULL ) THEN
	  p_uso_rec.saturday := l_cur_usec_ocurs.saturday;
        ELSIF  p_uso_rec.saturday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.saturday := 'N';
	END IF;


	IF ( p_uso_rec.sunday IS NULL ) THEN
	  p_uso_rec.sunday := l_cur_usec_ocurs.sunday;
        ELSIF  p_uso_rec.sunday = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.sunday := 'N';
	END IF;


	IF p_uso_rec.no_set_day_ind IS NULL THEN
	   p_uso_rec.no_set_day_ind := l_cur_usec_ocurs.no_set_day_ind;
        ELSIF  p_uso_rec.no_set_day_ind = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.no_set_day_ind := 'N';
	END IF;


	IF p_uso_rec.attribute_category IS NULL THEN
	   p_uso_rec.attribute_category := l_cur_usec_ocurs.attribute_category;
        ELSIF  p_uso_rec.attribute_category = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute_category := NULL;
	END IF;


	IF p_uso_rec.attribute1 IS NULL THEN
	   p_uso_rec.attribute1 := l_cur_usec_ocurs.attribute1;
        ELSIF  p_uso_rec.attribute1 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute1 := NULL;
	END IF;


	IF p_uso_rec.attribute2 IS NULL THEN
	   p_uso_rec.attribute2 := l_cur_usec_ocurs.attribute2;
        ELSIF  p_uso_rec.attribute2 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute2 := NULL;
	END IF;


	IF p_uso_rec.attribute3 IS NULL THEN
	   p_uso_rec.attribute3 := l_cur_usec_ocurs.attribute3;
        ELSIF  p_uso_rec.attribute3 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute3 := NULL;
	END IF;

	IF p_uso_rec.attribute4 IS NULL THEN
	   p_uso_rec.attribute4 := l_cur_usec_ocurs.attribute4;
        ELSIF  p_uso_rec.attribute4 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute4 := NULL;
	END IF;

	IF p_uso_rec.attribute5 IS NULL THEN
	   p_uso_rec.attribute5 := l_cur_usec_ocurs.attribute5;
        ELSIF  p_uso_rec.attribute5 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute5 := NULL;
	END IF;


	IF p_uso_rec.attribute6 IS NULL THEN
	   p_uso_rec.attribute6 := l_cur_usec_ocurs.attribute6;
        ELSIF  p_uso_rec.attribute6 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute6 := NULL;
	END IF;


	IF p_uso_rec.attribute7 IS NULL THEN
	   p_uso_rec.attribute7 := l_cur_usec_ocurs.attribute7;
        ELSIF  p_uso_rec.attribute7 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute7 := NULL;
	END IF;


	IF p_uso_rec.attribute8 IS NULL THEN
	   p_uso_rec.attribute8 := l_cur_usec_ocurs.attribute8;
        ELSIF  p_uso_rec.attribute8 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute8 := NULL;
	END IF;


	IF p_uso_rec.attribute9 IS NULL THEN
	   p_uso_rec.attribute9 := l_cur_usec_ocurs.attribute9;
        ELSIF  p_uso_rec.attribute9 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute9 := NULL;
	END IF;


	IF p_uso_rec.attribute10 IS NULL THEN
	   p_uso_rec.attribute10 := l_cur_usec_ocurs.attribute10;
        ELSIF  p_uso_rec.attribute10 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute10 := NULL;
	END IF;


	IF p_uso_rec.attribute11 IS NULL THEN
	   p_uso_rec.attribute11 := l_cur_usec_ocurs.attribute11;
        ELSIF  p_uso_rec.attribute11 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute11 := NULL;
	END IF;


	IF p_uso_rec.attribute12 IS NULL THEN
	   p_uso_rec.attribute12 := l_cur_usec_ocurs.attribute12;
        ELSIF  p_uso_rec.attribute12 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute12 := NULL;
	END IF;


	IF p_uso_rec.attribute13 IS NULL THEN
	   p_uso_rec.attribute13 := l_cur_usec_ocurs.attribute13;
        ELSIF  p_uso_rec.attribute13 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute13 := NULL;
	END IF;


	IF p_uso_rec.attribute14 IS NULL THEN
	   p_uso_rec.attribute14 := l_cur_usec_ocurs.attribute14;
        ELSIF  p_uso_rec.attribute14 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute14 := NULL;
	END IF;

	IF p_uso_rec.attribute15 IS NULL THEN
	   p_uso_rec.attribute15 := l_cur_usec_ocurs.attribute15;
        ELSIF  p_uso_rec.attribute15 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute15 := NULL;
	END IF;


	IF p_uso_rec.attribute16 IS NULL THEN
	   p_uso_rec.attribute16 := l_cur_usec_ocurs.attribute16;
        ELSIF  p_uso_rec.attribute16 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute16 := NULL;
	END IF;

	IF p_uso_rec.attribute17 IS NULL THEN
	   p_uso_rec.attribute17 := l_cur_usec_ocurs.attribute17;
        ELSIF  p_uso_rec.attribute17 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute17 := NULL;
	END IF;

	IF p_uso_rec.attribute18 IS NULL THEN
	   p_uso_rec.attribute18 := l_cur_usec_ocurs.attribute18;
        ELSIF  p_uso_rec.attribute18 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute18 := NULL;
	END IF;

	IF p_uso_rec.attribute19 IS NULL THEN
	   p_uso_rec.attribute19 := l_cur_usec_ocurs.attribute19;
        ELSIF  p_uso_rec.attribute19 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute19 := NULL;
	END IF;


	IF p_uso_rec.attribute20 IS NULL THEN
	   p_uso_rec.attribute20 := l_cur_usec_ocurs.attribute20;
        ELSIF  p_uso_rec.attribute20 = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.attribute20 := NULL;
	END IF;


	IF p_uso_rec.start_time IS NULL THEN
	   p_uso_rec.start_time := l_cur_usec_ocurs.start_time;
        ELSIF  p_uso_rec.start_time = FND_API.G_MISS_DATE THEN
	  p_uso_rec.start_time := NULL;
	END IF;


	IF p_uso_rec.end_time IS NULL THEN
	   p_uso_rec.end_time := l_cur_usec_ocurs.end_time;
        ELSIF  p_uso_rec.end_time = FND_API.G_MISS_DATE THEN
	  p_uso_rec.end_time := NULL;
	END IF;


	IF p_uso_rec.building_code IS NULL THEN
	  l_n_building_code := l_cur_usec_ocurs.building_code;
        ELSIF  p_uso_rec.building_code = FND_API.G_MISS_CHAR THEN
	  l_n_building_code := NULL;
	END IF;

	IF p_uso_rec.room_code IS NULL THEN
	   l_n_room_code := l_cur_usec_ocurs.room_code;
        ELSIF  p_uso_rec.room_code = FND_API.G_MISS_CHAR THEN
	  l_n_room_code := NULL;
        ELSIF p_uso_rec.room_code IS NOT NULL THEN

          OPEN cur_room(l_n_building_code,p_uso_rec.room_code);
	  FETCH cur_room INTO l_n_room_code;
	  IF cur_room%NOTFOUND THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'ROOM_CODE', 'LEGACY_TOKENS', FALSE);
            p_uso_rec.status := 'E';
	  END IF;
          CLOSE cur_room;
	END IF;


	IF p_uso_rec.dedicated_building_code IS NULL THEN
	   l_n_dedicated_building_code := l_cur_usec_ocurs.dedicated_building_code;
        ELSIF  p_uso_rec.dedicated_building_code = FND_API.G_MISS_CHAR THEN
	  l_n_dedicated_building_code := NULL;
	END IF;


	IF p_uso_rec.dedicated_room_code IS NULL THEN
	   l_n_dedicated_room_code := l_cur_usec_ocurs.dedicated_room_code;
        ELSIF  p_uso_rec.dedicated_room_code = FND_API.G_MISS_CHAR THEN
	  l_n_dedicated_room_code := NULL;
        ELSIF p_uso_rec.dedicated_room_code IS NOT NULL THEN
          OPEN cur_room(l_n_dedicated_building_code,p_uso_rec.dedicated_room_code);
	  FETCH cur_room INTO l_n_dedicated_room_code;
	  IF cur_room%NOTFOUND THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED', 'LEGACY_TOKENS') || ' ' ||
                                             igs_ps_validate_lgcy_pkg.get_lkup_meaning('ROOM_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
            p_uso_rec.status := 'E';
	  END IF;
          CLOSE cur_room;
	END IF;

	IF p_uso_rec.preferred_building_code IS NULL THEN
	   l_n_preferred_building_code := l_cur_usec_ocurs.preferred_building_code;
        ELSIF  p_uso_rec.preferred_building_code = FND_API.G_MISS_CHAR THEN
	  l_n_preferred_building_code := NULL;
	END IF;


	IF p_uso_rec.preferred_room_code IS NULL THEN
	   l_n_preferred_room_code := l_cur_usec_ocurs.preferred_room_code;
        ELSIF  p_uso_rec.preferred_room_code = FND_API.G_MISS_CHAR THEN
	  l_n_preferred_room_code := NULL;
        ELSIF p_uso_rec.preferred_room_code IS NOT NULL THEN
          OPEN cur_room(l_n_preferred_building_code,p_uso_rec.preferred_room_code);
	  FETCH cur_room INTO l_n_preferred_room_code;
	  IF cur_room%NOTFOUND THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED', 'LEGACY_TOKENS') || ' ' ||
                                             igs_ps_validate_lgcy_pkg.get_lkup_meaning('ROOM_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
            p_uso_rec.status := 'E';
	  END IF;
          CLOSE cur_room;
	END IF;


	IF p_uso_rec.start_date IS NULL THEN
	   p_uso_rec.start_date := l_cur_usec_ocurs.start_date;
        ELSIF  p_uso_rec.start_date = FND_API.G_MISS_DATE THEN
	  p_uso_rec.start_date := NULL;
	END IF;


	IF p_uso_rec.end_date IS NULL THEN
	   p_uso_rec.end_date := l_cur_usec_ocurs.end_date;
        ELSIF  p_uso_rec.end_date = FND_API.G_MISS_DATE THEN
	  p_uso_rec.end_date := NULL;
	END IF;


	IF p_uso_rec.preferred_region_code IS NULL THEN
	   p_uso_rec.preferred_region_code := l_cur_usec_ocurs.preferred_region_code;
        ELSIF  p_uso_rec.preferred_region_code = FND_API.G_MISS_CHAR THEN
	  p_uso_rec.preferred_region_code := NULL;
	END IF;

        --Set the  schedule status.
	IF l_cur_usec_ocurs.schedule_status IN ('ERROR','TBA','PROCESSING') AND l_n_building_code IS NOT NULL THEN
	    l_c_schedule_status := 'SCHEDULED';
	END IF;


      END IF;

    END assign_defaults;
----


  /* Main Unit Section Occurrence Sub Process */
  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.start_logging_for','Unit Section Occurrence');
    END IF;

    p_c_rec_status := 'S';
    FOR I in 1..p_tab_usec_occur.LAST LOOP
      IF p_tab_usec_occur.EXISTS(I) THEN
        --Initialize all variables
	l_c_cal_type                :=NULL;
	l_n_seq_num                 :=NULL;
	l_d_start_dt                :=NULL;
	l_d_end_dt                  :=NULL;
	l_n_uoo_id                  :=NULL;
	l_n_uso_id                  :=NULL;
	l_n_building_code           :=NULL;
	l_n_dedicated_building_code :=NULL;
	l_n_preferred_building_code :=NULL;
	l_n_room_code               :=NULL;
	l_n_dedicated_room_code     :=NULL;
	l_n_preferred_room_code     :=NULL;
	l_c_schedule_status         :=NULL;
        l_notify_status :=NULL;


	p_tab_usec_occur(I).status := 'S';
        p_tab_usec_occur(I).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_tab_usec_occur(I) );
        validate_parameters ( p_tab_usec_occur(I) );

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_validate_parameters',
	  'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	  ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	  p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	  'Status:'||p_tab_usec_occur(I).status);
        END IF;

        --Only derivation no defaulting
	IF p_tab_usec_occur(I).status = 'S' THEN
	  validate_derivations ( p_tab_usec_occur(I));

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_validate_derivations',
	    'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	    'Status:'||p_tab_usec_occur(I).status);
          END IF;

	END IF;

	--Find out whether it is insert/update of record
	l_insert_update:='I';
	IF p_tab_usec_occur(I).status = 'S' AND p_calling_context IN ('G','S') THEN
	  l_insert_update:= check_insert_update(p_tab_usec_occur(I));

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_check_insert_update',
	    'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	    ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	    p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	    'Status:'||p_tab_usec_occur(I).status);
          END IF;

	END IF;

	-- Find out whether record can go for import in context of cancelled/aborted
        IF  p_tab_usec_occur(I).status = 'S' AND p_calling_context ='S' THEN
	  IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,l_n_uso_id) = FALSE THEN
            fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
            fnd_msg_pub.add;
            p_tab_usec_occur(I).status := 'A';
	  END IF;

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_check_import_allowed',
	     'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	     p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	     'Status:'||p_tab_usec_occur(I).status);
          END IF;

        END IF;

        --Defaulting depending upon insert or update
	IF p_tab_usec_occur(I).status = 'S' THEN
	  assign_defaults(p_tab_usec_occur(I),l_insert_update);

	  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_assign_defaults',
	     'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	     p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	     'Status:'||p_tab_usec_occur(I).status);
          END IF;

	END IF;

	IF p_tab_usec_occur(I).status = 'S' THEN
	  validate_db_cons ( p_tab_usec_occur(I),l_insert_update);

          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_validate_db_cons',
	     'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	     p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	     'Status:'||p_tab_usec_occur(I).status);
          END IF;

	END IF;

	/* Business Validations */
	/* Proceed with business validations only if the status is Success, 'S' */
	IF p_tab_usec_occur(I).status = 'S' THEN
	  igs_ps_validate_lgcy_pkg.validate_usec_occurs ( p_tab_usec_occur(I), l_n_uoo_id, l_d_start_dt, l_d_end_dt,
	                                                  l_n_building_code,l_n_room_code,
							  l_n_dedicated_building_code,l_n_dedicated_room_code,
							  l_n_preferred_building_code,l_n_preferred_room_code,l_n_uso_id,
							  l_insert_update,p_calling_context,l_notify_status,l_c_schedule_status
							  );

           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
             fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.status_after_Business_validation',
	     'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	     ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	     p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier||'  '||
	     'Status:'||p_tab_usec_occur(I).status);
           END IF;
	END IF;

	IF p_tab_usec_occur(I).status = 'S' THEN
	  IF l_insert_update = 'I' THEN
	      /* Insert Record */
	      INSERT INTO igs_ps_usec_occurs_all
	      (unit_section_occurrence_id,
	       uoo_id,
	       monday,
	       tuesday,
	       wednesday,
	       thursday,
	       friday,
	       saturday,
	       sunday,
	       start_time,
	       end_time,
	       building_code,
	       room_code,
	       schedule_status,
	       status_last_updated,
	       created_by,
	       creation_date,
	       last_updated_by,
	       last_update_date,
	       last_update_login,
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
	       dedicated_building_code,
	       dedicated_room_code,
	       preferred_building_code,
	       preferred_room_code,
	       start_date,
	       end_date,
	       to_be_announced,
	       preferred_region_code,
	       no_set_day_ind,
	       cancel_flag,
	       occurrence_identifier,
	       abort_flag
	      )
	      VALUES
	      (igs_ps_usec_occurs_s.NEXTVAL,
	       l_n_uoo_id,
	       p_tab_usec_occur(I).monday,
	       p_tab_usec_occur(I).tuesday,
	       p_tab_usec_occur(I).wednesday,
	       p_tab_usec_occur(I).thursday,
	       p_tab_usec_occur(I).friday,
	       p_tab_usec_occur(I).saturday,
	       p_tab_usec_occur(I).sunday,
	       p_tab_usec_occur(I).start_time,
	       p_tab_usec_occur(I).end_time,
	       l_n_building_code,
	       l_n_room_code,
	       l_c_schedule_status,
	       TRUNC(SYSDATE),
	       g_n_user_id,
	       SYSDATE,
	       g_n_user_id,
	       SYSDATE,
	       g_n_login_id,
	       p_tab_usec_occur(I).attribute_category,
	       p_tab_usec_occur(I).attribute1,
	       p_tab_usec_occur(I).attribute2,
	       p_tab_usec_occur(I).attribute3,
	       p_tab_usec_occur(I).attribute4,
	       p_tab_usec_occur(I).attribute5,
	       p_tab_usec_occur(I).attribute6,
	       p_tab_usec_occur(I).attribute7,
	       p_tab_usec_occur(I).attribute8,
	       p_tab_usec_occur(I).attribute9,
	       p_tab_usec_occur(I).attribute10,
	       p_tab_usec_occur(I).attribute11,
	       p_tab_usec_occur(I).attribute12,
	       p_tab_usec_occur(I).attribute13,
	       p_tab_usec_occur(I).attribute14,
	       p_tab_usec_occur(I).attribute15,
	       p_tab_usec_occur(I).attribute16,
	       p_tab_usec_occur(I).attribute17,
	       p_tab_usec_occur(I).attribute18,
	       p_tab_usec_occur(I).attribute19,
	       p_tab_usec_occur(I).attribute20,
	       l_n_dedicated_building_code,
	       l_n_dedicated_room_code,
	       l_n_preferred_building_code,
	       l_n_preferred_room_code,
	       p_tab_usec_occur(I).start_date,
	       p_tab_usec_occur(I).end_date,
	       p_tab_usec_occur(I).to_be_announced,
	       p_tab_usec_occur(I).preferred_region_code,
	       p_tab_usec_occur(I).no_set_day_ind,
	       'N',
	       p_tab_usec_occur(I).occurrence_identifier,
	       'N'
	      )RETURNING unit_section_occurrence_id INTO l_n_usec_occurs_id;


	      l_n_tbl_cnt :=l_tbl_uso.count+1;
	      l_tbl_uso(l_n_tbl_cnt):=l_n_usec_occurs_id ;


              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.record_inserted',
	        'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	        ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	        p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier);
              END IF;

          ELSE

	    DECLARE

	      CURSOR c_prd_uso(cp_n_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
	      SELECT rowid,uso.*
	      FROM   igs_ps_usec_occurs_all uso
	      WHERE  uso.unit_section_occurrence_id=cp_n_uso_id;
              rec_prd_uso c_prd_uso%ROWTYPE;

	      CURSOR check_ovrd IS
	      SELECT day_ovrd_flag, time_ovrd_flag, scheduled_bld_ovrd_flag, scheduled_room_ovrd_flag,date_ovrd_flag
	      FROM igs_ps_sch_ocr_cfig;

	      l_check_ovrd check_ovrd%ROWTYPE;
	      l_c_monday     igs_ps_usec_occurs_all.monday%TYPE;
	      l_c_tuesday    igs_ps_usec_occurs_all.tuesday%TYPE;
	      l_c_wednesday  igs_ps_usec_occurs_all.wednesday%TYPE;
	      l_c_thursday   igs_ps_usec_occurs_all.thursday%TYPE;
	      l_c_friday     igs_ps_usec_occurs_all.friday%TYPE;
	      l_c_saturday   igs_ps_usec_occurs_all.saturday%TYPE;
	      l_c_sunday     igs_ps_usec_occurs_all.sunday%TYPE;
	      l_d_uso_start_date igs_ps_usec_occurs_all.start_date%TYPE;
              l_d_uso_end_date   igs_ps_usec_occurs_all.end_date%TYPE;
	      l_start_time   igs_ps_usec_occurs_all.start_time%TYPE;
	      l_end_time     igs_ps_usec_occurs_all.end_time%TYPE;
	      l_sch_bld      igs_ps_usec_occurs_all.building_code%TYPE;
	      l_sch_room     igs_ps_usec_occurs_all.room_code%TYPE;
	    BEGIN
		OPEN  c_prd_uso (l_n_uso_id);
		FETCH c_prd_uso INTO rec_prd_uso;
		CLOSE c_prd_uso;

		OPEN check_ovrd;
		FETCH check_ovrd INTO l_check_ovrd;
		IF check_ovrd%FOUND THEN
		  --Days override
		  IF l_check_ovrd.day_ovrd_flag = 'N' AND (p_tab_usec_occur(I).monday='Y' OR
							   p_tab_usec_occur(I).tuesday='Y' OR
							   p_tab_usec_occur(I).wednesday='Y' OR
							   p_tab_usec_occur(I).thursday='Y' OR
							   p_tab_usec_occur(I).friday='Y' OR
							   p_tab_usec_occur(I).saturday='Y' OR
							   p_tab_usec_occur(I).sunday='Y'  ) THEN
		   l_c_monday := rec_prd_uso.monday;
		   l_c_tuesday := rec_prd_uso.tuesday;
		   l_c_wednesday := rec_prd_uso.wednesday;
		   l_c_thursday := rec_prd_uso.thursday;
		   l_c_friday := rec_prd_uso.friday;
		   l_c_saturday := rec_prd_uso.saturday;
		   l_c_sunday := rec_prd_uso.sunday;
		 ELSE
		   l_c_monday := p_tab_usec_occur(I).monday;
		   l_c_tuesday := p_tab_usec_occur(I).tuesday;
		   l_c_wednesday := p_tab_usec_occur(I).wednesday;
		   l_c_thursday := p_tab_usec_occur(I).thursday;
		   l_c_friday := p_tab_usec_occur(I).friday;
		   l_c_saturday := p_tab_usec_occur(I).saturday;
		   l_c_sunday := p_tab_usec_occur(I).sunday;
		 END IF;
		  --Date override
		 IF l_check_ovrd.date_ovrd_flag = 'N' AND (rec_prd_uso.start_date IS NOT NULL  OR
						      rec_prd_uso.end_date IS NOT NULL ) THEN
		  l_d_uso_start_date  := rec_prd_uso.start_date;
		  l_d_uso_end_date := rec_prd_uso.end_date;
		 ELSE
		   l_d_uso_start_date := p_tab_usec_occur(I).start_date;
		   l_d_uso_end_date := p_tab_usec_occur(I).end_date;
		 END IF;
		 --Time override
		 IF l_check_ovrd.time_ovrd_flag = 'N' AND (rec_prd_uso.start_time IS NOT NULL  OR
						      rec_prd_uso.end_time IS NOT NULL ) THEN
		   l_start_time := rec_prd_uso.start_time;
		   l_end_time := rec_prd_uso.end_time;
		 ELSE
		   l_start_time := p_tab_usec_occur(I).start_time;
		   l_end_time := p_tab_usec_occur(I).end_time;
		 END IF;
		 --Schedule Building override
		 IF l_check_ovrd.scheduled_bld_ovrd_flag = 'N' AND (rec_prd_uso.building_code IS NOT NULL) THEN
		   l_sch_bld := rec_prd_uso.building_code;
		 ELSE
		   l_sch_bld := l_n_building_code;
		 END IF;
		 --Schedule Room override
		 IF l_check_ovrd.scheduled_room_ovrd_flag = 'N' AND (rec_prd_uso.room_code IS NOT NULL ) THEN
		   l_sch_room := rec_prd_uso.room_code;
		 ELSE
		   l_sch_room := l_n_room_code;
		 END IF;

	       ELSE
		   l_c_monday := p_tab_usec_occur(I).monday;
		   l_c_tuesday := p_tab_usec_occur(I).tuesday;
		   l_c_wednesday := p_tab_usec_occur(I).wednesday;
		   l_c_thursday := p_tab_usec_occur(I).thursday;
		   l_c_friday := p_tab_usec_occur(I).friday;
		   l_c_saturday := p_tab_usec_occur(I).saturday;
		   l_c_sunday := p_tab_usec_occur(I).sunday;
		   l_start_time := p_tab_usec_occur(I).start_time;
		   l_end_time := p_tab_usec_occur(I).end_time;
                   l_d_uso_start_date :=p_tab_usec_occur(I).start_date;
                   l_d_uso_end_date := p_tab_usec_occur(I).end_date;
		   l_sch_bld := l_n_building_code;
		   l_sch_room := l_n_room_code;
	       END IF;
	       CLOSE check_ovrd;

               /*Update record*/
               UPDATE IGS_PS_USEC_OCCURS_ALL SET
               monday = l_c_monday,
               tuesday = l_c_tuesday,
               wednesday = l_c_wednesday,
               thursday =l_c_thursday,
               friday = l_c_friday,
               saturday = l_c_saturday,
               sunday = l_c_sunday,
               start_time = l_start_time,
               end_time = l_end_time,
               building_code = l_sch_bld,
               room_code = l_sch_room,
               schedule_status = NVL(l_c_schedule_status,schedule_status),
	       error_text = DECODE(l_c_schedule_status,'SCHEDULED',NULL,'CANCELLED',NULL,error_text),
	       notify_status = NVL(l_notify_status,notify_status),
               status_last_updated = TRUNC(SYSDATE),
               last_updated_by=g_n_user_id,
               last_update_date=SYSDATE,
               last_update_login=g_n_login_id,
               attribute_category=p_tab_usec_occur(I).attribute_category,
               attribute1=p_tab_usec_occur(I).attribute1,
               attribute2=p_tab_usec_occur(I).attribute2,
               attribute3=p_tab_usec_occur(I).attribute3,
               attribute4=p_tab_usec_occur(I).attribute4,
               attribute5=p_tab_usec_occur(I).attribute5,
               attribute6=p_tab_usec_occur(I).attribute6,
               attribute7=p_tab_usec_occur(I).attribute7,
               attribute8=p_tab_usec_occur(I).attribute8,
               attribute9=p_tab_usec_occur(I).attribute9,
               attribute10=p_tab_usec_occur(I).attribute10,
               attribute11=p_tab_usec_occur(I).attribute11,
               attribute12=p_tab_usec_occur(I).attribute12,
               attribute13=p_tab_usec_occur(I).attribute13,
               attribute14=p_tab_usec_occur(I).attribute14,
               attribute15=p_tab_usec_occur(I).attribute15,
               attribute16=p_tab_usec_occur(I).attribute16,
               attribute17=p_tab_usec_occur(I).attribute17,
               attribute18=p_tab_usec_occur(I).attribute18,
               attribute19=p_tab_usec_occur(I).attribute19,
               attribute20=p_tab_usec_occur(I).attribute20,
               dedicated_building_code=l_n_dedicated_building_code,
               dedicated_room_code=l_n_dedicated_room_code,
               preferred_building_code=l_n_preferred_building_code,
               preferred_room_code=l_n_preferred_room_code,
               start_date=l_d_uso_start_date,
               end_date=l_d_uso_end_date,
               to_be_announced=p_tab_usec_occur(I).to_be_announced,
               preferred_region_code=p_tab_usec_occur(I).preferred_region_code,
               no_set_day_ind=p_tab_usec_occur(I).no_set_day_ind
	       WHERE unit_section_occurrence_id = l_n_uso_id ;

	       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
                fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.record_updated',
	        'Unit code:'||p_tab_usec_occur(I).unit_cd||'  '||'Version number:'||p_tab_usec_occur(I).version_number||'  '||'teach_cal_alternate_code:'
	        ||p_tab_usec_occur(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_usec_occur(I).location_cd||'  '||'Unit Class:'||
	        p_tab_usec_occur(I).unit_class||'Occurrence Identifier:'|| p_tab_usec_occur(I).occurrence_identifier);
              END IF;

            END;
	  END IF;
	  p_tab_usec_occur(I).msg_from := NULL;
	  p_tab_usec_occur(I).msg_to := NULL;
	ELSIF p_tab_usec_occur(I).status = 'A' THEN
	  p_tab_usec_occur(I).msg_from := p_tab_usec_occur(I).msg_from+1;
	  p_tab_usec_occur(I).msg_to   := fnd_msg_pub.count_msg;
	ELSE
	  p_c_rec_status := p_tab_usec_occur(I).status;
	  p_tab_usec_occur(I).msg_from := p_tab_usec_occur(I).msg_from+1;
	  p_tab_usec_occur(I).msg_to   := fnd_msg_pub.count_msg;
	  IF p_tab_usec_occur(I).status = 'E' THEN
	    RETURN;
	  END IF;
	END IF;
      END IF;
    END LOOP;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_usec_occur.after_import_status',p_c_rec_status);
     END IF;

  END create_usec_occur;

  PROCEDURE create_unit_ref_code( p_tab_ref_cd IN OUT NOCOPY igs_ps_generic_pub.unit_ref_tbl_type,
                                  p_c_rec_status OUT NOCOPY VARCHAR2,
				  p_calling_context  IN VARCHAR2) AS

  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  18-NOV-2002
    Purpose        :  This procedure import reference codes of unit version, unit section, unit section occurrence.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sarakshi    11-Mar-2005     Bug#4212680, modified cursor c_ref_des within procedure validate_derivation.
    smvk        27-Jun-2003     Enh Bug # 2999888. Importing Unit requirements / Unit Section requirements reference codes
    jbegum      02-June-2003    Enh#2972950
                                For Legacy Enhancements TD:
                                Modified validate_usec_db_cons, changed the impact of change of
                                signature of igs_ps_usec_ref_cd_pkg.get_uk_for_validation
                                For PSP Scheduling Enhancements TD:
                                Modified the local procedure's validate_occur_deri_busi,validate_occur_db_cons.
                                For PSP Enhancements TD:
                                Modified validate_occur_db_cons,validate_derivation,validate_unit_db_cons
                                validate_usec_db_cons,validate_usec_derivations.

  ********************************************************************************************** */


    l_c_cal_type      igs_ca_inst_all.cal_type%TYPE;         -- Holds Calendar Type
    l_n_seq_num       igs_ca_inst_all.sequence_number%TYPE;  -- Holds Calendar Instance Sequence Number
    l_n_uoo_id        igs_ps_unit_ofr_opt_all.uoo_id%TYPE;   -- Holds Unit Offering Options Identifier
    l_n_usec_ref_id   igs_ps_usec_ref.unit_section_reference_id%TYPE;  -- Holds Unit Section Reference Identifier
    l_n_uso_id        igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE; -- Holds the Unit Section Occurrence Identifier

--
l_insert_update VARCHAR2(1);
--
    -- Following cursor added as part of bug#2972950 for the PSP Enhancements TD
    CURSOR c_res_flag (cp_c_ref_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE) IS
       SELECT restricted_flag
       FROM igs_ge_ref_cd_type_all
       WHERE reference_cd_type = cp_c_ref_type;

    rec_res_flag c_res_flag%ROWTYPE;

    PROCEDURE trim_values ( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS
    BEGIN
      p_ref_cd_rec.unit_cd := trim(p_ref_cd_rec.unit_cd);
      p_ref_cd_rec.version_number := trim(p_ref_cd_rec.version_number);
      p_ref_cd_rec.data_type := trim(p_ref_cd_rec.data_type);
      p_ref_cd_rec.teach_cal_alternate_code := trim(p_ref_cd_rec.teach_cal_alternate_code);
      p_ref_cd_rec.location_cd := trim(p_ref_cd_rec.location_cd);
      p_ref_cd_rec.unit_class := trim(p_ref_cd_rec.unit_class);
      p_ref_cd_rec.occurrence_identifier := trim(p_ref_cd_rec.occurrence_identifier);
      p_ref_cd_rec.reference_cd_type := trim(p_ref_cd_rec.reference_cd_type);
      p_ref_cd_rec.reference_cd := trim(p_ref_cd_rec.reference_cd);
      p_ref_cd_rec.description := trim(p_ref_cd_rec.description);
      p_ref_cd_rec.gen_ref_flag := trim(p_ref_cd_rec.gen_ref_flag);

    END trim_values ;

    -- Validate the Mandatory Parameters for creation of unit referrence code
    PROCEDURE validate_unit_parameters( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS
    BEGIN
       IF p_ref_cd_rec.unit_cd IS NULL OR p_ref_cd_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CD','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
       IF p_ref_cd_rec.version_number IS NULL OR p_ref_cd_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_VER_NUM','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
       IF p_ref_cd_rec.data_type IS NULL OR p_ref_cd_rec.data_type = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'DATA_TYPE','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
       IF p_ref_cd_rec.reference_cd_type IS NULL OR p_ref_cd_rec.reference_cd_type = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'REFERENCE_CD_TYPE','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
       IF p_ref_cd_rec.reference_cd IS NULL OR p_ref_cd_rec.reference_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'REFERENCE_CD','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
    END validate_unit_parameters;

    -- Validate the Mandatory Parameters for Unit Section / Unit Section Occurrence
    PROCEDURE validate_usec_parameters( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS
    BEGIN
       validate_unit_parameters( p_ref_cd_rec );
       IF p_ref_cd_rec.teach_cal_alternate_code IS NULL OR p_ref_cd_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
       IF p_ref_cd_rec.location_cd IS NULL OR p_ref_cd_rec.location_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
       IF p_ref_cd_rec.unit_class IS NULL OR p_ref_cd_rec.unit_class = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'UNIT_CLASS','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;

       IF p_ref_cd_rec.data_type = 'OCCURRENCE' AND
         (p_ref_cd_rec.occurrence_identifier IS NULL OR p_ref_cd_rec.occurrence_identifier = FND_API.G_MISS_CHAR) AND (p_ref_cd_rec.production_uso_id IS NULL OR p_ref_cd_rec.production_uso_id = FND_API.G_MISS_NUM) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_OCCRS_ID','IGS_PS_LOG_PARAMETERS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;

       IF p_calling_context IN ('G','S') AND p_ref_cd_rec.data_type = 'UNIT' THEN
            fnd_message.set_name ( 'IGS', 'IGS_PS_UNIT_REF_N_ALLW_GEN_SCH' );
            fnd_msg_pub.add;
            p_ref_cd_rec.status := 'E';
       END IF;


    END validate_usec_parameters;

    -- Validate the Mandatory Parameters
    PROCEDURE validate_parameters( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS
    BEGIN
       IF p_ref_cd_rec.data_type IS NULL OR p_ref_cd_rec.data_type = 'UNIT' THEN
         validate_unit_parameters(p_ref_cd_rec);
       ELSIF p_ref_cd_rec.data_type = 'SECTION'  OR p_ref_cd_rec.data_type = 'OCCURRENCE' THEN
         validate_usec_parameters(p_ref_cd_rec);
       ELSE
         igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'DATA_TYPE','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
       END IF;
    END validate_parameters;

    --Enh Bug#2972950
    --For the PSP Enhancements TD:
    --Removed the cursor c_ref_cd_id and its reference from validate_usec_derivations

    -- Derivation of values required to create Unit Section Referrence.
    PROCEDURE validate_usec_derivations( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS

      CURSOR c_usec_ref_id (cp_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
        SELECT  A.unit_section_reference_id
          FROM  igs_ps_usec_ref A
          WHERE A.uoo_id = cp_uoo_id;

      l_d_start igs_ca_inst_all.start_dt%TYPE;
      l_d_end igs_ca_inst_all.end_dt%TYPE;
      l_ret_status VARCHAR2(30);

    BEGIN

      -- Deriving the Calendar Type and Calendar Sequence Number
      igs_ge_gen_003.get_calendar_instance(p_ref_cd_rec.teach_cal_alternate_code, '''TEACHING''', l_c_cal_type,l_n_seq_num,l_d_start,l_d_end,l_ret_status);
      IF l_ret_status <> 'SINGLE' THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;

      -- Deriving the Unit Offering Option Identifier
      l_ret_status := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id(p_ref_cd_rec.unit_cd, p_ref_cd_rec.version_number , l_c_cal_type, l_n_seq_num, p_ref_cd_rec.location_cd, p_ref_cd_rec.unit_class,l_n_uoo_id,l_ret_status);
      IF l_ret_status IS NOT NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION','LEGACY_TOKENS', FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;

      -- Deriving the Unit Section Reference Identifier
      OPEN c_usec_ref_id (l_n_uoo_id);
      FETCH c_usec_ref_id INTO l_n_usec_ref_id;
      IF c_usec_ref_id%NOTFOUND THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS',
                                         igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_SECTION','LEGACY_TOKENS') || ' ' ||
                                         igs_ps_validate_lgcy_pkg.get_lkup_meaning('REFERENCE_CD','LEGACY_TOKENS'),
                                         NULL, FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;
      CLOSE c_usec_ref_id;
    END validate_usec_derivations;

    -- As the derivation of Unit Section Occurrence Identifier and the business validation
    -- for the Unit Section Occurrence References are tightly coupled, the derivation and
    -- business validation mentioned in the TD are combined.

    -- Change History
    -- Who         When            What
    -- smvk        28-Jul-2004     Bug # 3793580. Coded to call get_uso_id procedure and removed
    --                             cursors used to derive USO id.
    -- jbegum      04-June-2003    Enh#2972950
    --                             For PSP Scheduling Enhancements TD:
    --                             Modified the cursor's c_tba_count,c_tba_uso_id,c_count,c_uso_id.
    --                             Added 2 new cursor's c_nsd_count,c_nsd_uso_id.
    PROCEDURE validate_occur_deri_busi( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS

      l_d_start DATE;
      l_d_end DATE;
      l_ret_status VARCHAR2(30);
      l_c_msg VARCHAR2(30);

    BEGIN

      -- Deriving the Calendar Type and Calendar Sequence Number
      igs_ge_gen_003.get_calendar_instance(p_ref_cd_rec.teach_cal_alternate_code, '''TEACHING''', l_c_cal_type,l_n_seq_num,l_d_start,l_d_end,l_ret_status);
      IF l_ret_status <> 'SINGLE' THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;

      -- Deriving the Unit Offering Option Identifier
      l_ret_status := NULL;
      igs_ps_validate_lgcy_pkg.get_uoo_id(p_ref_cd_rec.unit_cd, p_ref_cd_rec.version_number , l_c_cal_type, l_n_seq_num, p_ref_cd_rec.location_cd, p_ref_cd_rec.unit_class,l_n_uoo_id,l_ret_status);
      IF l_ret_status IS NOT NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION','LEGACY_TOKENS', FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;



      IF p_ref_cd_rec.production_uso_id IS NULL THEN
	--  To get the unit section occurrence id.
	--  Error message is return in the out parameter l_c_msg if any.
	l_c_msg := NULL;


	igs_ps_validate_lgcy_pkg.get_uso_id( p_uoo_id                => l_n_uoo_id,
					     p_occurrence_identifier => p_ref_cd_rec.occurrence_identifier,
					     p_uso_id                => l_n_uso_id,
					     p_message               => l_c_msg
					    );

	IF l_c_msg IS NOT NULL THEN
	   fnd_message.set_name('IGS',l_c_msg);
	   fnd_msg_pub.add;
	   p_ref_cd_rec.status := 'E';
	END IF;
      ELSE
        l_n_uso_id := p_ref_cd_rec.production_uso_id;
      END IF;

    END validate_occur_deri_busi;

    -- Decides to call the derivation procedures based on the datatype
    PROCEDURE validate_derivation( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS

    -- Following cursor added as part of bug#2972950 for the PSP Enhancements TD
    CURSOR c_ref_des (cp_c_ref_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE,
                      cp_c_ref_cd   igs_ge_ref_cd.reference_cd%TYPE) IS
       SELECT rc.description
       FROM igs_ge_ref_cd_type_all rct,
            igs_ge_ref_cd  rc
       WHERE rct.reference_cd_type = cp_c_ref_type
       AND  rct.reference_cd_type = rc.reference_cd_type
       AND  rc.reference_cd = cp_c_ref_cd
       AND rct.restricted_flag = 'Y';

    rec_ref_des c_ref_des%ROWTYPE;

    BEGIN

      -- Following validation added as part of bug#2972950 for the PSP Enhancements TD
      -- Description field to be defaulted to the description of the passed reference code
      -- if 'Restricted Reference Code Values' checkbox is checked else passed values to be used if any.

      OPEN c_ref_des(p_ref_cd_rec.reference_cd_type,p_ref_cd_rec.reference_cd);
      FETCH c_ref_des INTO rec_ref_des;
      IF c_ref_des%FOUND THEN
         p_ref_cd_rec.description := rec_ref_des.description;
      END IF;
      CLOSE c_ref_des;

      IF p_ref_cd_rec.gen_ref_flag IS NULL THEN
         p_ref_cd_rec.gen_ref_flag := 'Y' ;-- Defauling to 'Y' that is generic reference codes
      ELSE
         IF p_ref_cd_rec.gen_ref_flag NOT IN ('Y','N') THEN
            fnd_message.set_name('IGS','IGS_PS_LGCY_GEN_FLAG');
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N',fnd_message.get,NULL,FALSE);
            p_ref_cd_rec.status:='E';
         END IF;
      END IF;

      IF p_ref_cd_rec.data_type = 'SECTION' THEN
        validate_usec_derivations( p_ref_cd_rec );
      ELSIF p_ref_cd_rec.data_type = 'OCCURRENCE' THEN

        validate_occur_deri_busi( p_ref_cd_rec );

      END IF;

    END validate_derivation;

    -- Validate the database constraints for the Unit Referrence code
    PROCEDURE validate_unit_db_cons(p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type) AS

    BEGIN
      -- Unique Key Validation
      IF p_ref_cd_rec.gen_ref_flag  = 'Y' THEN  -- if generic reference code
        IF igs_ps_unit_ref_cd_pkg.get_uk_for_validation(p_ref_cd_rec.unit_cd,
                                                        p_ref_cd_rec.version_number,
                                                        p_ref_cd_rec.reference_cd_type) THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', 'UNIT_REFERENCE_CD','LEGACY_TOKENS', FALSE);
          p_ref_cd_rec.status := 'W';
          RETURN;
        END IF;
      ELSE   -- else Unit requirement reference code
        IF igs_ps_unitreqref_cd_pkg.get_uk_for_validation(p_ref_cd_rec.unit_cd,
                                                          p_ref_cd_rec.version_number,
                                                          p_ref_cd_rec.reference_cd_type,
                                                          p_ref_cd_rec.reference_cd
                                                          ) THEN
          fnd_message.set_name('IGS','IGS_PS_LGCY_UNIT_REQ_REF');
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', fnd_message.get,NULL, FALSE);
          p_ref_cd_rec.status := 'W';
          RETURN;
        END IF;
      END IF;

      -- Check Constraints: Unit Code Should be in Upper Case
      BEGIN
        igs_ps_unit_ref_cd_pkg.check_constraints('UNIT_CD', p_ref_cd_rec.unit_cd);
      EXCEPTION
        WHEN OTHERS THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'UNIT_CD','LEGACY_TOKENS', TRUE);
        p_ref_cd_rec.status := 'E';
      END;

      -- Check Constraints: Reference Code Should be in Upper Case
      BEGIN
        igs_ps_unit_ref_cd_pkg.check_constraints('REFERENCE_CD', p_ref_cd_rec.reference_cd);
      EXCEPTION
        WHEN OTHERS THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'REFERENCE_CD','LEGACY_TOKENS', TRUE);
        p_ref_cd_rec.status := 'E';
      END;

      -- Check Constraints: Reference Code Type Should be in Upper Case
      BEGIN
        igs_ps_unit_ref_cd_pkg.check_constraints('REFERENCE_CD_TYPE', p_ref_cd_rec.reference_cd_type);
      EXCEPTION
        WHEN OTHERS THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE', 'REFERENCE_CD_TYPE','LEGACY_TOKENS', TRUE);
        p_ref_cd_rec.status := 'E';
      END;

      -- Following validation added as part of bug#2972950 for the PSP Enhancements TD
      OPEN c_res_flag(p_ref_cd_rec.reference_cd_type);
      FETCH c_res_flag INTO rec_res_flag;
      IF c_res_flag%FOUND THEN
         IF rec_res_flag.restricted_flag = 'Y' THEN
            -- Foreign Key Validations : Reference Code doesn't exists
            IF NOT igs_ge_ref_cd_pkg.get_uk_for_validation(p_ref_cd_rec.reference_cd_type,p_ref_cd_rec.reference_cd) THEN
               igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'REFERENCE_CD','LEGACY_TOKENS', FALSE);
               p_ref_cd_rec.status := 'E';
            END IF;
         END IF;
      ELSE
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_INVALID_REF_CD_TYPE',NULL,NULL,FALSE);
         p_ref_cd_rec.status := 'E';
      END IF;
      CLOSE c_res_flag;

      -- Foreign Key Validations : Unit Version doesn't exists
      IF NOT igs_ps_unit_ver_pkg.get_pk_for_validation(p_ref_cd_rec.unit_cd, p_ref_cd_rec.version_number) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_VERSION','LEGACY_TOKENS', FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;

    END validate_unit_db_cons;

    -- Validate the database constraints for the Unit Section Occurrence Referrence code
    PROCEDURE validate_usec_db_cons(p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type,p_insert IN VARCHAR2) AS

    BEGIN

      IF p_insert = 'I' THEN
	--Unique Key Validation
	--Enh#2972950,impact of change of signature of igs_ps_usec_ref_cd_pkg.get_uk_for_validation
	IF p_ref_cd_rec.gen_ref_flag  = 'Y' THEN  -- if generic reference code
	  IF igs_ps_usec_ref_cd_pkg.get_uk_for_validation(l_n_usec_ref_id,p_ref_cd_rec.reference_cd_type,p_ref_cd_rec.reference_cd) THEN
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS',
					     igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_SECTION','LEGACY_TOKENS') || ' ' ||
					     igs_ps_validate_lgcy_pkg.get_lkup_meaning('REFERENCE_CD','LEGACY_TOKENS'),
					     NULL, FALSE);
	    p_ref_cd_rec.status := 'W';
	    RETURN;
	  END IF;
	ELSE -- else Unit Section requirement reference code
	  IF igs_ps_us_req_ref_cd_pkg.get_uk_for_validation(l_n_usec_ref_id,p_ref_cd_rec.reference_cd_type,p_ref_cd_rec.reference_cd) THEN
	    fnd_message.set_name('IGS','IGS_PS_LGCY_USEC_REQ_REF');
	    igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS',fnd_message.get,NULL, FALSE);
	    p_ref_cd_rec.status := 'W';
	    RETURN;
	  END IF;
	END IF;
      END IF;

      -- Following validation added as part of bug#2972950 for the PSP Enhancements TD
      OPEN c_res_flag(p_ref_cd_rec.reference_cd_type);
      FETCH c_res_flag INTO rec_res_flag;
      IF c_res_flag%FOUND THEN
         IF rec_res_flag.restricted_flag = 'Y' THEN
            -- Foreign Key Validations : Reference Code doesn't exists
            IF NOT igs_ge_ref_cd_pkg.get_uk_for_validation(p_ref_cd_rec.reference_cd_type,p_ref_cd_rec.reference_cd) THEN
               igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'REFERENCE_CD','LEGACY_TOKENS', FALSE);
               p_ref_cd_rec.status := 'E';
            END IF;
         END IF;
      ELSE
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_INVALID_REF_CD_TYPE',NULL,NULL,FALSE);
         p_ref_cd_rec.status := 'E';
      END IF;
      CLOSE c_res_flag;

      -- Foreign Key Validation :  Unit Section  doesn't exists
      IF NOT igs_ps_usec_ref_pkg.get_pk_for_validation(l_n_usec_ref_id) THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS',
                                         igs_ps_validate_lgcy_pkg.get_lkup_meaning('UNIT_SECTION','LEGACY_TOKENS') || ' ' ||
                                         igs_ps_validate_lgcy_pkg.get_lkup_meaning('REFERENCE_CD','LEGACY_TOKENS'),
                                         NULL, FALSE);
        p_ref_cd_rec.status := 'E';
      END IF;

    END validate_usec_db_cons;

    -- Validate the database constraints for the Unit Section Occurrence Referrence code
    PROCEDURE validate_occur_db_cons(p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type,p_insert IN VARCHAR2) AS

    BEGIN
      IF p_insert = 'I' THEN
	-- Unique Key Validation
	IF igs_ps_usec_ocur_ref_pkg.get_uk_for_validation( p_ref_cd_rec.reference_cd_type ,
							   p_ref_cd_rec.reference_cd ,
							   l_n_uso_id ) THEN
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS',
					   igs_ps_validate_lgcy_pkg.get_lkup_meaning('USEC_OCCUR','LEGACY_TOKENS') || ' ' ||
					   igs_ps_validate_lgcy_pkg.get_lkup_meaning('REFERENCE_CD','LEGACY_TOKENS'),
					   NULL, FALSE);
	  p_ref_cd_rec.status := 'W';
	  RETURN;
	END IF;
      END IF;

      -- Following validation added as part of bug#2972950 for the PSP Enhancements TD
      OPEN c_res_flag(p_ref_cd_rec.reference_cd_type);
      FETCH c_res_flag INTO rec_res_flag;
      IF c_res_flag%FOUND THEN
         IF rec_res_flag.restricted_flag = 'Y' THEN
            -- Foreign Key Validations : Reference Code doesn't exists
            IF NOT igs_ge_ref_cd_pkg.get_uk_for_validation(p_ref_cd_rec.reference_cd_type,p_ref_cd_rec.reference_cd) THEN
               igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'REFERENCE_CD','LEGACY_TOKENS', FALSE);
               p_ref_cd_rec.status := 'E';
            END IF;
         END IF;
      ELSE
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_INVALID_REF_CD_TYPE',NULL,NULL,FALSE);
         p_ref_cd_rec.status := 'E';
      END IF;
      CLOSE c_res_flag;

      -- Foreign Key Validation : Unit Section Occurrence doesn't exists
      IF NOT igs_ps_usec_occurs_pkg.get_pk_for_validation(l_n_uso_id) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'USEC_OCCUR','LEGACY_TOKENS', FALSE);
         p_ref_cd_rec.status := 'E';
      END IF;


    END validate_occur_db_cons;


    -- Decides to call the database constraint procedures based on the datatype
    PROCEDURE validate_db_cons( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type,p_insert IN VARCHAR2) AS
    BEGIN
      IF p_ref_cd_rec.data_type = 'UNIT' THEN
        validate_unit_db_cons(p_ref_cd_rec);
      ELSIF p_ref_cd_rec.data_type = 'SECTION' THEN
        validate_usec_db_cons(p_ref_cd_rec,p_insert);
      ELSIF p_ref_cd_rec.data_type = 'OCCURRENCE' THEN
        validate_occur_db_cons(p_ref_cd_rec,p_insert);
      END IF;
    END validate_db_cons;

---
    -- Check for Update/Insert
    FUNCTION check_insert_update ( p_ref_cd_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type ) RETURN VARCHAR2 IS
      --For  IGS_PS_USEC_REF_CD record
      CURSOR c_gen IS
      SELECT rc.restricted_flag,ur.reference_code_desc
      FROM igs_ps_usec_ref_cd ur, igs_ge_ref_cd_type_all rc
      WHERE ur.unit_section_reference_id  = l_n_usec_ref_id
      AND ur.reference_code_type    = p_ref_cd_rec.reference_cd_type
      AND ur.reference_code = p_ref_cd_rec.reference_cd
      AND ur.reference_code_type=rc.reference_cd_type;


      --For  IGS_PS_US_REQ_REF_CD record
      CURSOR c_req IS
      SELECT rc.restricted_flag,urr.reference_code_desc
      FROM  igs_ps_us_req_ref_cd urr,igs_ge_ref_cd_type_all rc
      WHERE urr.unit_section_reference_id  =  l_n_usec_ref_id
      AND   urr.reference_cd_type    = p_ref_cd_rec.reference_cd_type
      AND   urr.reference_code = p_ref_cd_rec.reference_cd
      AND   urr.reference_cd_type=rc.reference_cd_type;

      --For  IGS_PS_USEC_OCUR_REF record
      CURSOR c_occr IS
      SELECT rc.restricted_flag,uo.reference_code_desc
      FROM  igs_ps_usec_ocur_ref uo,igs_ge_ref_cd_type_all rc
      WHERE uo.reference_code_type    = p_ref_cd_rec.reference_cd_type
      AND   uo.reference_code = p_ref_cd_rec.reference_cd
      AND   uo.unit_section_occurrence_id = l_n_uso_id
      AND   uo.reference_code_type=rc.reference_cd_type;

      l_c_gen c_gen%ROWTYPE;
      l_c_req c_req%ROWTYPE;
      l_c_occr c_occr%ROWTYPE;

    BEGIN
        IF p_ref_cd_rec.data_type = 'SECTION' THEN
          IF p_ref_cd_rec.gen_ref_flag = 'Y' THEN
             OPEN c_gen;
	     FETCH c_gen INTO l_c_gen;
	     IF c_gen%FOUND THEN
               CLOSE c_gen;
               IF l_c_gen.restricted_flag = 'N'  THEN
	         IF p_ref_cd_rec.description IS NULL THEN
 		   p_ref_cd_rec.description := l_c_gen.reference_code_desc;
                 ELSIF p_ref_cd_rec.description =  FND_API.G_MISS_CHAR THEN
 		   p_ref_cd_rec.description := NULL;
		 END IF;
	       END IF;
               RETURN 'U';
	     ELSE
               CLOSE c_gen;
               RETURN 'I';
	     END IF;
	  ELSE
             OPEN c_req;
	     FETCH c_req INTO l_c_req;
	     IF c_req%FOUND THEN
               CLOSE c_req;
               IF l_c_req.restricted_flag = 'N'  THEN
	         IF p_ref_cd_rec.description IS NULL THEN
 		   p_ref_cd_rec.description := l_c_req.reference_code_desc;
                 ELSIF p_ref_cd_rec.description =  FND_API.G_MISS_CHAR THEN
 		   p_ref_cd_rec.description := NULL;
		 END IF;
	       END IF;
               RETURN 'U';
	     ELSE
               CLOSE c_req;
               RETURN 'I';
	     END IF;
	  END IF;

        ELSIF p_ref_cd_rec.data_type = 'OCCURRENCE' THEN
             OPEN c_occr;
	     FETCH c_occr INTO l_c_occr;
	     IF c_occr%FOUND THEN
               CLOSE c_occr;
               IF l_c_occr.restricted_flag = 'N'  THEN
	         IF p_ref_cd_rec.description IS NULL THEN
 		   p_ref_cd_rec.description := l_c_occr.reference_code_desc;
                 ELSIF p_ref_cd_rec.description =  FND_API.G_MISS_CHAR THEN
 		   p_ref_cd_rec.description := NULL;
		 END IF;
	       END IF;
               RETURN 'U';
	     ELSE
               CLOSE c_occr;
               RETURN 'I';
	     END IF;

	ELSE
	  RETURN 'I';
	END IF;

    END check_insert_update;


----

  BEGIN

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.start_logging_for','Reference: Unit,Unit Sections,Unit section Occurrence');
    END IF;

    p_c_rec_status := 'S';

    FOR i IN 1 .. p_tab_ref_cd.LAST
    LOOP
      IF p_tab_ref_cd.EXISTS(i) THEN
        --Initialize the variable
	l_c_cal_type    :=NULL;
	l_n_seq_num     :=NULL;
	l_n_uoo_id      :=NULL;
	l_n_usec_ref_id :=NULL;
	l_n_uso_id      :=NULL;

        p_tab_ref_cd(i).status := 'S';
        p_tab_ref_cd(i).msg_from := fnd_msg_pub.count_msg;
        trim_values(p_tab_ref_cd(i));
        -- Validate the parameters values

        validate_parameters(p_tab_ref_cd(i));

	IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.status_after_validate_parameters',
	  'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
	  ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
	  ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
	  'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
	  '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
	  ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id||'  '||'Status:'||p_tab_ref_cd(i).status);
        END IF;

          -- Derive the required values
	  IF p_tab_ref_cd(i).status = 'S' THEN
	    validate_derivation(p_tab_ref_cd(i));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.status_after_validate_derivation',
	      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
	      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
	      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
	      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
	      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id||'  '||'Status:'||p_tab_ref_cd(i).status);
            END IF;

	  END IF;

	  --Find out whether it is insert/update of record
          l_insert_update:='I';
          IF p_tab_ref_cd(i).status = 'S' AND p_calling_context IN ('G','S')  THEN
            l_insert_update:= check_insert_update(p_tab_ref_cd(I));

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.status_after_check_insert_update',
	      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
	      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
	      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
	      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
	      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id||'  '||'Status:'||p_tab_ref_cd(i).status);
            END IF;

          END IF;

	-- Find out whether record can go for import in context of cancelled/aborted
        IF  p_tab_ref_cd(i).status = 'S' AND p_calling_context ='S' THEN
          IF igs_ps_validate_lgcy_pkg.check_import_allowed( l_n_uoo_id,l_n_uso_id) = FALSE THEN
            fnd_message.set_name ( 'IGS', 'IGS_PS_REC_ABORTED_CANCELLED' );
            fnd_msg_pub.add;
            p_tab_ref_cd(i).status := 'A';
	  END IF;

	   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.status_after_check_import_allowed',
	      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
	      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
	      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
	      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
	      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id||'  '||'Status:'||p_tab_ref_cd(i).status);
            END IF;

	END IF;

	  -- Check for database constraints
	  IF p_tab_ref_cd(i).status = 'S' THEN
	    validate_db_cons(p_tab_ref_cd(i),l_insert_update);

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.status_after_validate_db_cons',
	      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
	      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
	      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
	      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
	      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id||'  '||'Status:'||p_tab_ref_cd(i).status);
            END IF;

	  END IF;

	  IF p_tab_ref_cd(i).status = 'S' THEN
	    igs_ps_validate_lgcy_pkg.validate_unit_reference(p_tab_ref_cd(i),l_n_uoo_id,l_n_uso_id,p_calling_context);

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.status_after_Business_Validation',
	      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
	      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
	      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
	      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
	      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
	      ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id||'  '||'Status:'||p_tab_ref_cd(i).status);
            END IF;

	  END IF;

	  -- Insert the reference codes in appropriate table based on datatype value.
	  IF p_tab_ref_cd(i).status = 'S' THEN
	    IF p_tab_ref_cd(i).data_type = 'UNIT' THEN
	       IF p_tab_ref_cd(i).gen_ref_flag = 'Y' THEN -- if generic reference code
		  -- Creating the unit refernce code if the datatype is UNIT.
		  INSERT INTO igs_ps_unit_ref_cd (
						   UNIT_CD,
						   VERSION_NUMBER,
						   REFERENCE_CD_TYPE,
						   REFERENCE_CD,
						   DESCRIPTION,
						   CREATION_DATE,
						   CREATED_BY,
						   LAST_UPDATE_DATE,
						   LAST_UPDATED_BY,
						   LAST_UPDATE_LOGIN
						 ) VALUES (
						    p_tab_ref_cd(i).unit_cd,
						    p_tab_ref_cd(i).version_number,
						    p_tab_ref_cd(i).reference_cd_type,
						    p_tab_ref_cd(i).reference_cd,
						    p_tab_ref_cd(i).description,
						    sysdate,
						    g_n_user_id,
						    sysdate,
						    g_n_user_id,
						    g_n_login_id
						 );
                 IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_Inserted_igs_ps_unit_ref_cd',
		    'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		    ||p_tab_ref_cd(i).version_number||'  '||'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||
		    'reference_cd:'||p_tab_ref_cd(i).reference_cd||'  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag);
                 END IF;
	       ELSE  -- else unit requirements reference code
		  INSERT INTO igs_ps_unitreqref_cd (
						     unit_req_ref_cd_id,
						     unit_cd,
						     version_number,
						     reference_cd_type,
						     creation_date,
						     created_by,
						     last_update_date,
						     last_updated_by,
						     last_update_login,
						     reference_code,
						     reference_code_desc
						   ) VALUES (
						     igs_ps_unitreqref_cd_s.NEXTVAL,
						     p_tab_ref_cd(i).unit_cd,
						     p_tab_ref_cd(i).version_number,
						     p_tab_ref_cd(i).reference_cd_type,
						     SYSDATE,
						     g_n_user_id,
						     SYSDATE,
						     g_n_user_id,
						     g_n_login_id,
						     p_tab_ref_cd(i).reference_cd,
						     p_tab_ref_cd(i).description
						   );
                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		    fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_Inserted_igs_ps_unitreqref_cd',
		    'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		    ||p_tab_ref_cd(i).version_number||'  '||'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||
		    'reference_cd:'||p_tab_ref_cd(i).reference_cd||'  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag);
                  END IF;

	       END IF;

	    ELSIF p_tab_ref_cd(i).data_type = 'SECTION' THEN

	       IF p_tab_ref_cd(i).gen_ref_flag = 'Y' THEN -- if generic reference code
		  --Enh Bug#2972950
		  --For the PSP Enhancements TD:
		  --Added the column's reference_code_type,reference_code,reference_code_desc
		  --in the INSERT of table igs_ps_usec_ref_cd
		  --Also deleted column reference_code_id in the INSERT of table igs_ps_usec_ref_cd

		  -- Creating the unit section refernce code if the datatype is SECTION.
                  IF l_insert_update = 'I' THEN

		    INSERT INTO igs_ps_usec_ref_cd (
						     unit_section_reference_cd_id,
						     unit_section_reference_id,
						     creation_date,
						     created_by,
						     last_update_date,
						     last_updated_by,
						     last_update_login,
						     reference_code_type,
						     reference_code,
						     reference_code_desc
						   ) VALUES (
						     igs_ps_usec_ref_cd_s.nextval,
						     l_n_usec_ref_id,
						     sysdate,
						     g_n_user_id,
						     sysdate,
						     g_n_user_id,
						     g_n_login_id,
						     p_tab_ref_cd(i).reference_cd_type,
						     p_tab_ref_cd(i).reference_cd,
						     p_tab_ref_cd(i).description
						   );
	        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_Inserted_igs_ps_usec_ref_cd',
		  'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		  ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
		  ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
		  'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
		  '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag);
		END IF;
                  ELSE

                    UPDATE igs_ps_usec_ref_cd SET reference_code_desc=p_tab_ref_cd(i).description,last_updated_by=g_n_user_id,
                    last_update_date=SYSDATE WHERE unit_section_reference_id=l_n_usec_ref_id AND
		    reference_code_type=p_tab_ref_cd(i).reference_cd_type AND reference_code=p_tab_ref_cd(i).reference_cd;

                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_Updated_igs_ps_usec_ref_cd',
		      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
		      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
		      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
		      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag);
		    END IF;

		  END IF;
	       ELSE -- else unit section requirements reference code
	          IF l_insert_update = 'I' THEN

		    INSERT INTO igs_ps_us_req_ref_cd (
						       unit_section_req_ref_cd_id,
						       unit_section_reference_id,
						       reference_cd_type,
						       creation_date,
						       created_by,
						       last_update_date,
						       last_updated_by,
						       last_update_login,
						       reference_code,
						       reference_code_desc
						     ) VALUES (
						       igs_ps_us_req_ref_cd_s.NEXTVAL,
						       l_n_usec_ref_id,
						       p_tab_ref_cd(i).reference_cd_type,
						       SYSDATE,
						       g_n_user_id,
						       SYSDATE,
						       g_n_user_id,
						       g_n_login_id,
						       p_tab_ref_cd(i).reference_cd,
						       p_tab_ref_cd(i).description
						     );
		   IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_Inserted_igs_ps_us_req_ref_cd',
		      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
		      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
		      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
		      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag);
		    END IF;
                  ELSE

		    UPDATE igs_ps_us_req_ref_cd SET reference_code_desc=p_tab_ref_cd(i).description,last_updated_by=g_n_user_id,
                    last_update_date=SYSDATE WHERE unit_section_reference_id=l_n_usec_ref_id AND
		    reference_cd_type=p_tab_ref_cd(i).reference_cd_type AND reference_code=p_tab_ref_cd(i).reference_cd;

                    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_updated_igs_ps_us_req_ref_cd',
		      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
		      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
		      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
		      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag);
		    END IF;

		  END IF;
	       END IF;

	    ELSIF p_tab_ref_cd(i).data_type = 'OCCURRENCE' THEN

	     --Enh Bug#2972950
	     --For the PSP Enhancements TD:
	     --Added the reference_code_desc column in the INSERT of table igs_ps_usec_ocur_ref

	     --Creating the unit section occurrence refernce code if the datatype is OCCURRENCE.
	      IF l_insert_update = 'I' THEN

	        INSERT INTO igs_ps_usec_ocur_ref (
						  unit_sec_occur_reference_id,
						  unit_section_occurrence_id,
						  reference_code_type,
						  reference_code,
						  creation_date,
						  created_by,
						  last_update_date,
						  last_updated_by,
						  last_update_login,
						  reference_code_desc
						 ) VALUES (
						   igs_ps_usec_occur_ref_s.nextval,
						   l_n_uso_id,
						   p_tab_ref_cd(i).reference_cd_type,
						   p_tab_ref_cd(i).reference_cd,
						   sysdate,
						   g_n_user_id,
						   sysdate,
						   g_n_user_id,
						   g_n_login_id,
						   p_tab_ref_cd(i).description
						 );
                  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_inserted_igs_ps_usec_ocur_ref',
		      'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		      ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
		      ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
		      'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
		      '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
		      ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id);
		    END IF;
              ELSE

                UPDATE igs_ps_usec_ocur_ref SET reference_code_desc=p_tab_ref_cd(i).description,last_updated_by=g_n_user_id,
                last_update_date=SYSDATE WHERE unit_section_occurrence_id=l_n_uso_id AND
		reference_code_type=p_tab_ref_cd(i).reference_cd_type AND reference_code=p_tab_ref_cd(i).reference_cd;

                IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.Record_updated_igs_ps_usec_ocur_ref',
		  'Data Type:'||p_tab_ref_cd(i).data_type||'  '||'Unit code:'||p_tab_ref_cd(i).unit_cd||'  '||'Version number:'
		  ||p_tab_ref_cd(i).version_number||'  '||'teach_cal_alternate_code:'||p_tab_ref_cd(i).teach_cal_alternate_code
		  ||'  '||'Location_cd:'||p_tab_ref_cd(i).location_cd||'  '||'Unit Class:'||p_tab_ref_cd(i).unit_class||'  '||
		  'reference_cd_type:'||p_tab_ref_cd(i).reference_cd_type||'  '||'reference_cd:'||p_tab_ref_cd(i).reference_cd||
		  '  '||'gen_ref_flag:'||p_tab_ref_cd(i).gen_ref_flag||'  '||'occurrence_identifier'||p_tab_ref_cd(i).occurrence_identifier
		  ||'  '||'production_uso_id:'||p_tab_ref_cd(i).production_uso_id);
		END IF;
	      END IF;

	    END IF;
	    p_tab_ref_cd(i).msg_from  := NULL;
	    p_tab_ref_cd(i).msg_to    := NULL;
          ELSIF  p_tab_ref_cd(i).status = 'A' THEN
	    p_tab_ref_cd(i).msg_from  := p_tab_ref_cd(i).msg_from + 1;
	    p_tab_ref_cd(i).msg_to := fnd_msg_pub.count_msg;
	  ELSE
	    p_c_rec_status := p_tab_ref_cd(i).status;
	    p_tab_ref_cd(i).msg_from  := p_tab_ref_cd(i).msg_from + 1;
	    p_tab_ref_cd(i).msg_to := fnd_msg_pub.count_msg;
	    IF p_c_rec_status = 'E' THEN
	      RETURN;
	    END IF;
	  END IF; -- status is E
      END IF; --  end of exist(i) if
    END LOOP;

    IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_unit_ref_code.after_import_status',p_c_rec_status);
    END IF;


  END create_unit_ref_code;

 --This procedure is a sub process to create Unit Section Occurrence Instructors
 --in production table(IGS_PS_USO_INSTRCTRS)
  PROCEDURE create_uso_ins( p_tab_uso_ins IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type,
                            p_c_rec_status   OUT NOCOPY VARCHAR2 ) AS
    /***********************************************************************************************

    Created By:         smvk
    Date Created By:    20-May-2003
    Purpose:            This procedure imports unit section occurrence instructor.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    sommukhe  02-AUG-2006  Bug#5356402,Using function usoexists to probe the PL/SQL table so that the status of occurrences
                           are not changed to resheduling when imported together with instructors.
    smvk      30-Aug-2004  Bug # 3862086. Modified Return to Exit. Post insert business logic needs to be executed Always.
                           This internally clears the package level PL/SQL table v_tab_usec_tr.
    smvk      23-Sep-2003  Bug # 3121311, Removed the call to procedures uso_effective_dates and validate_instructor.
    jbegum    4-June-2003  Enh Bug#2972950
                           For PSP Scheduling Enhancements TD:
                           Modified local procedures validate_db_cons and validate_derivation.
    ***********************************************************************************************/

    l_n_ins_id            igs_ps_uso_instrctrs.instructor_id%TYPE;
    l_n_uso_id            igs_ps_uso_instrctrs.unit_section_occurrence_id%TYPE;
    l_n_uoo_id            igs_ps_unit_ofr_opt_all.uoo_id%TYPE;
    l_d_start_dt          igs_ps_usec_occurs_all.start_date%TYPE;
    l_d_end_dt            igs_ps_usec_occurs_all.end_date%TYPE;

    CURSOR c_occurs(cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
    SELECT uso.unit_section_occurrence_id
    FROM igs_ps_usec_occurs_all uso
    WHERE (uso.schedule_status IS NOT NULL AND uso.schedule_status NOT IN ('PROCESSING','USER_UPDATE'))
    AND uso.no_set_day_ind ='N'
    AND uso.unit_section_occurrence_id=cp_unit_section_occurrence_id;

    FUNCTION usoexists(p_n_uso_id igs_ps_uso_instrctrs.unit_section_occurrence_id%TYPE) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sommukhe
    Date Created By:  1-08-2006.
    Purpose        :  This utility procedure is to check if a uso exists in a pl/sql table

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/
    BEGIN
      FOR i in 1..l_tbl_uso.count LOOP
        IF p_n_uso_id = l_tbl_uso(i) THEN
          RETURN TRUE;
	END IF;
      END LOOP;
      RETURN FALSE;
    END usoexists;

    PROCEDURE trim_values ( p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
    BEGIN
      p_uso_ins_rec.instructor_person_number := TRIM(p_uso_ins_rec.instructor_person_number);
      p_uso_ins_rec.production_uso_id := TRIM(p_uso_ins_rec.production_uso_id);
      p_uso_ins_rec.unit_cd := TRIM(p_uso_ins_rec.unit_cd);
      p_uso_ins_rec.version_number := TRIM(p_uso_ins_rec.version_number);
      p_uso_ins_rec.teach_cal_alternate_code := TRIM(p_uso_ins_rec.teach_cal_alternate_code);
      p_uso_ins_rec.location_cd := TRIM(p_uso_ins_rec.location_cd);
      p_uso_ins_rec.unit_class := TRIM(p_uso_ins_rec.unit_class);
      p_uso_ins_rec.occurrence_identifier := TRIM(p_uso_ins_rec.occurrence_identifier);
      p_uso_ins_rec.confirmed_flag := TRIM(p_uso_ins_rec.confirmed_flag);
      p_uso_ins_rec.wl_percentage_allocation := TRIM(p_uso_ins_rec.wl_percentage_allocation);
      p_uso_ins_rec.instructional_load_lecture := TRIM(p_uso_ins_rec.instructional_load_lecture);
      p_uso_ins_rec.instructional_load_laboratory :=  TRIM(p_uso_ins_rec.instructional_load_laboratory);
      p_uso_ins_rec.instructional_load_other :=  TRIM(p_uso_ins_rec.instructional_load_other);
      p_uso_ins_rec.lead_instructor_flag := TRIM(p_uso_ins_rec.lead_instructor_flag);

    END trim_values;

    PROCEDURE validate_parameters(p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
    /***********************************************************************************************

    Created By:         smvk
    Date Created By:    20-May-2003
    Purpose:            This procedure validates all mandatory parameter required for the unit section occurrence
                        instructor process to proceed.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    ***********************************************************************************************/

    BEGIN
      p_uso_ins_rec.status:='S';

      -- Checking for the mandatory existence of Unit Code, verison  number, instructor person number parameter in the record.
      IF p_uso_ins_rec.instructor_person_number IS NULL OR p_uso_ins_rec.instructor_person_number = FND_API.G_MISS_CHAR THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY',fnd_message.get,NULL,FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      IF p_uso_ins_rec.unit_cd IS NULL OR p_uso_ins_rec.unit_cd = FND_API.G_MISS_CHAR THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CD','LEGACY_TOKENS',FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      IF p_uso_ins_rec.version_number IS NULL OR p_uso_ins_rec.version_number = FND_API.G_MISS_NUM THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_VER_NUM','LEGACY_TOKENS',FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      -- if the production USO id is not provided then Teching calendar alternate code, location code and
      -- unit class are required.
      IF p_uso_ins_rec.production_uso_id IS NULL OR p_uso_ins_rec.production_uso_id = FND_API.G_MISS_NUM THEN
         IF p_uso_ins_rec.teach_cal_alternate_code IS NULL OR p_uso_ins_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS',FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
         IF p_uso_ins_rec.location_cd IS NULL OR p_uso_ins_rec.location_cd = FND_API.G_MISS_CHAR THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'LOCATION_CD','LEGACY_TOKENS',FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
         IF p_uso_ins_rec.unit_class IS NULL OR p_uso_ins_rec.unit_class = FND_API.G_MISS_CHAR THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY','UNIT_CLASS','LEGACY_TOKENS',FALSE);
          p_uso_ins_rec.status := 'E';
         END IF;
      END IF;

      IF (p_uso_ins_rec.teach_cal_alternate_code IS NULL OR p_uso_ins_rec.teach_cal_alternate_code = FND_API.G_MISS_CHAR ) AND
         (p_uso_ins_rec.location_cd IS NULL OR p_uso_ins_rec.location_cd = FND_API.G_MISS_CHAR ) AND
         (p_uso_ins_rec.unit_class IS NULL OR p_uso_ins_rec.unit_class = FND_API.G_MISS_CHAR) THEN
         IF p_uso_ins_rec.production_uso_id IS NULL OR p_uso_ins_rec.production_uso_id = FND_API.G_MISS_NUM THEN
            fnd_message.set_name('IGS','IGS_PS_PRODUCTION_USO_ID');
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY',fnd_message.get,NULL,FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
      END IF;

      IF (p_uso_ins_rec.production_uso_id IS NULL OR p_uso_ins_rec.production_uso_id = FND_API.G_MISS_NUM ) AND
         (p_uso_ins_rec.occurrence_identifier IS NULL OR p_uso_ins_rec.occurrence_identifier = FND_API.G_MISS_CHAR) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MANDATORY', 'USEC_OCCRS_ID','IGS_PS_LOG_PARAMETERS', FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;


    END validate_parameters;

    PROCEDURE validate_derivation(p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
    /***********************************************************************************************

    Created By:         smvk
    Date Created By:    20-May-2003
    Purpose:            This procedure derives the values required for creation of unit section occurrence instructor in production table.

    Known limitations,enhancements,remarks:
    Change History
    Who       When         What
    smvk      28-Jul-2004  Bug # 3793580. Coded to call get_uso_id procedure and removed
                           cursors used to derive USO id.
    jbegum    5-June-2003  Bug#2972950
                           For the PSP Scheduling Enhancements TD:
                           Modified the two cursors c_tba_count,c_tba_uso_id
    ***********************************************************************************************/


      CURSOR c_uoo_id (cp_n_uso_id IN igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
        SELECT A.uoo_id
        FROM   igs_ps_usec_occurs_all A
        WHERE  A.unit_section_occurrence_id = cp_n_uso_id;

      l_c_cal_type    igs_ca_inst_all.cal_type%TYPE;
      l_n_seq_num     igs_ca_inst_all.sequence_number%TYPE;
      l_d_start       igs_ca_inst_all.start_dt%TYPE;
      l_d_end         igs_ca_inst_all.end_dt%TYPE;
      l_c_ret_status  VARCHAR2(30);
      l_c_msg         VARCHAR2(30);

    BEGIN
      -- Initialize the variable use to store the derived values.
      l_n_ins_id := NULL;
      l_n_uso_id := NULL;
      l_n_uoo_id := NULL;

      -- Derive the Instructor identifier
      igs_ps_validate_lgcy_pkg.get_party_id(p_uso_ins_rec.instructor_person_number, l_n_ins_id);
      IF l_n_ins_id IS NULL THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', fnd_message.get,NULL, FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      -- if the production unit section occurrence identifier is provided then validate it
      -- otherwise derive the production unit section occurrence identifier.
      IF p_uso_ins_rec.production_uso_id IS NOT NULL THEN
         IF igs_ps_usec_occurs_pkg.get_pk_for_validation(p_uso_ins_rec.production_uso_id) THEN
            l_n_uso_id := p_uso_ins_rec.production_uso_id;
            -- Also derive the unit section identifier uoo_id for the the unit section occurrence identifier
            OPEN  c_uoo_id(l_n_uso_id);
            FETCH c_uoo_id INTO l_n_uoo_id;
            CLOSE c_uoo_id;
         ELSE
            fnd_message.set_name('IGS','IGS_PS_PRODUCTION_USO_ID');
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', fnd_message.get,NULL, FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;
      ELSE
         -- Deriving the value of Unit section Occurrence identifier

         -- Deriving the Calendar Type and Calendar Sequence Number
         igs_ge_gen_003.get_calendar_instance(p_uso_ins_rec.teach_cal_alternate_code,'''TEACHING''',  l_c_cal_type, l_n_seq_num, l_d_start, l_d_end, l_c_ret_status);
         IF l_c_ret_status <> 'SINGLE' THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'TEACH_CAL_ALTERNATE_CD','LEGACY_TOKENS', FALSE);
             p_uso_ins_rec.status := 'E';
         END IF;
         -- Deriving the Unit Offering Option Identifier
         l_c_ret_status := NULL;
         igs_ps_validate_lgcy_pkg.get_uoo_id(p_uso_ins_rec.unit_cd, p_uso_ins_rec.version_number, l_c_cal_type, l_n_seq_num, p_uso_ins_rec.location_cd, p_uso_ins_rec.unit_class, l_n_uoo_id, l_c_ret_status);
         IF l_c_ret_status IS NOT NULL THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS','UNIT_SECTION','LEGACY_TOKENS', FALSE);
            p_uso_ins_rec.status := 'E';
         END IF;


	 --Derive the unit section occurrence id
	 l_c_msg := NULL;
	 igs_ps_validate_lgcy_pkg.get_uso_id( p_uoo_id                => l_n_uoo_id,
					      p_occurrence_identifier => p_uso_ins_rec.occurrence_identifier,
					      p_uso_id                => l_n_uso_id,
					      p_message               => l_c_msg
					    );
	 IF l_c_msg IS NOT NULL THEN
	    fnd_message.set_name('IGS',l_c_msg);
	    fnd_msg_pub.add;
	    p_uso_ins_rec.status := 'E';
	 END IF;

      END IF;
    END validate_derivation;

    PROCEDURE validate_db_cons(p_uso_ins_rec IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type) AS
	CURSOR c_unit_ver (cp_n_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
	SELECT  a.unit_cd, a.version_number
	FROM    igs_ps_unit_ofr_opt_all a, igs_ps_usec_occurs_all b
	WHERE   a.uoo_id = b.uoo_id
	AND     b.unit_section_occurrence_id = cp_n_uso_id;

	rec_unit_ver c_unit_ver%ROWTYPE;

	CURSOR c_occur_status (cp_uso_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
	SELECT 'X'
	FROM   igs_ps_usec_occurs_all
	WHERE  unit_section_occurrence_id = cp_uso_id
	AND    schedule_status = 'PROCESSING';
	l_c_var  VARCHAR2(1);

    BEGIN
      -- Check uniqueness validation
      IF igs_ps_uso_instrctrs_pkg.get_uk_for_validation(l_n_uso_id, l_n_ins_id) THEN
         p_uso_ins_rec.status :='W';
         fnd_message.set_name('IGS','IGS_PS_USO_INS');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_EXISTS', fnd_message.get, NULL, FALSE);
         RETURN;
      END IF;

      -- Check Constraints
      BEGIN
        igs_ps_unit_ver_pkg.check_constraints( 'UNIT_CD',p_uso_ins_rec.unit_cd);
      EXCEPTION
        WHEN OTHERS THEN
            igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_UPPER_CASE','UNIT_CD','LEGACY_TOKENS',TRUE);
            p_uso_ins_rec.status :='E';
      END;

      BEGIN
        igs_ps_unit_ver_pkg.check_constraints('VERSION_NUMBER',p_uso_ins_rec.version_number);
      EXCEPTION
        WHEN OTHERS THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VER_NUM_1_999',NULL,NULL,TRUE);
          p_uso_ins_rec.status :='E';
      END;

      -- Foreign Key Checking
      IF NOT igs_pe_person_pkg.get_pk_for_validation(l_n_ins_id ) THEN
         fnd_message.set_name('IGS','IGS_PS_INS_PERSON_NUMBER');
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', fnd_message.get, NULL, FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;
      IF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (l_n_uoo_id ) THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REC_NOT_EXISTS', 'UNIT_SECTION', 'LEGACY_TOKENS', FALSE);
         p_uso_ins_rec.status := 'E';
      END IF;

      IF p_uso_ins_rec.production_uso_id IS NOT NULL THEN

         -- validate the production USO ID with unit_cd, version_number
         OPEN  c_unit_ver(p_uso_ins_rec.production_uso_id);
         FETCH c_unit_ver INTO rec_unit_ver;
         IF c_unit_ver%FOUND THEN
            IF p_uso_ins_rec.unit_cd <> rec_unit_ver.unit_cd  OR
               p_uso_ins_rec.version_number <> rec_unit_ver.version_number THEN
               fnd_message.set_name('IGS','IGS_PS_LGCY_UNIT_VER_NOT_USO');
               fnd_msg_pub.add;
               p_uso_ins_rec.status :='E';
            END IF;
         ELSE
            fnd_message.set_name('IGS','IGS_PS_LGCY_UNIT_VER_NOT_USO');
            fnd_msg_pub.add;
            p_uso_ins_rec.status :='E';
         END IF;
         CLOSE c_unit_ver;

      END IF;


      --When the occurrence is Scheduling in progress then import is not allowed
      --Note this validation cannot be pushed in the post validation as that is also called from the instructor override
      OPEN c_occur_status (l_n_uso_id);
      FETCH c_occur_status INTO l_c_var;
      IF c_occur_status%FOUND THEN
	 fnd_message.set_name ( 'IGS', 'IGS_PS_SCHEDULING_IN_PROGRESS' );
	 fnd_msg_pub.add;
	 p_uso_ins_rec.status := 'E';
      END IF;
      CLOSE c_occur_status;

    END validate_db_cons;

  BEGIN

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.start_logging_for','Unit Section Occurrence Instructors');
     END IF;

     p_c_rec_status := 'S';
     FOR I in 1..p_tab_uso_ins.LAST LOOP
         IF p_tab_uso_ins.EXISTS(I) THEN
            p_tab_uso_ins(I).status := 'S';
            p_tab_uso_ins(I).msg_from := fnd_msg_pub.count_msg;
            trim_values(p_tab_uso_ins(I));
            validate_parameters(p_tab_uso_ins(I));

	    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
	      fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.status_after_validate_parameters',
	      'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
	      'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
	       ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
	       ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
	       ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	    END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
               validate_derivation(p_tab_uso_ins(I));

	       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.status_after_validate_derivation',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		   ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		   ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		   ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	       END IF;

            END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
               validate_db_cons ( p_tab_uso_ins(I) );
	        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.status_after_validate_db_cons',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		   ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		   ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		   ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	       END IF;
            END IF;
            IF p_tab_uso_ins(I).status = 'S' THEN
               INSERT INTO IGS_PS_USO_INSTRCTRS (
                                                  USO_INSTRUCTOR_ID,
                                                  UNIT_SECTION_OCCURRENCE_ID,
                                                  INSTRUCTOR_ID,
                                                  CREATED_BY ,
                                                  CREATION_DATE,
                                                  LAST_UPDATED_BY,
                                                  LAST_UPDATE_DATE ,
                                                  LAST_UPDATE_LOGIN
                                                ) VALUES (
                                                  igs_ps_uso_instrctrs_s.nextval,
                                                  l_n_uso_id,
                                                  l_n_ins_id,
                                                  g_n_user_id,
                                                  sysdate,
                                                  g_n_user_id,
                                                  sysdate,
                                                  g_n_login_id
                                                );
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.record_inserted',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		   ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		   ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		   ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id);
	       END IF;
            END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
               igs_ps_validate_lgcy_pkg.post_uso_ins(l_n_ins_id, l_n_uoo_id, p_tab_uso_ins(I),I);
               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
		  fnd_log.string( fnd_log.level_statement, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.status_after_post_uso_ins',
		  'Unit code:'||p_tab_uso_ins(I).unit_cd||'  '||'Version number:'||p_tab_uso_ins(I).version_number||'  '||
		  'teach_cal_alternate_code:'||p_tab_uso_ins(I).teach_cal_alternate_code||'  '||'Location_cd:'||p_tab_uso_ins(I).location_cd
		   ||'  '||'Unit Class:'||p_tab_uso_ins(I).unit_class||'  '||'instructor_person_number:'||p_tab_uso_ins(I).instructor_person_number
		   ||'  '||'occurrence_identifier'||p_tab_uso_ins(I).occurrence_identifier
		   ||'  '||'production_uso_id:'||p_tab_uso_ins(I).production_uso_id||'  '||'Status:'|| p_tab_uso_ins(I).status);
	       END IF;
            END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
	      --Update the schedule status of the occurrence to USER_UPDATE if inserting a record
	      --Note this validation cannot be pushed in the post validation as that is also called from the instructor override
              IF NOT usoexists(l_n_uso_id) THEN
		FOR l_occurs_rec IN c_occurs(l_n_uso_id) LOOP
		  igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
		END LOOP;
	      END IF;
            END IF;

            IF p_tab_uso_ins(I).status = 'S' THEN
               p_tab_uso_ins(I).msg_from := NULL;
               p_tab_uso_ins(I).msg_to := NULL;
            ELSE
               p_c_rec_status := p_tab_uso_ins(I).status;
               p_tab_uso_ins(I).msg_from := p_tab_uso_ins(I).msg_from+1;
               p_tab_uso_ins(I).msg_to := fnd_msg_pub.count_msg;
               IF p_tab_uso_ins(I).status = 'E' THEN
                  RETURN;
               END IF;
            END IF;

         END IF;
     END LOOP;
     IF NOT igs_ps_validate_lgcy_pkg.post_uso_ins_busi(p_tab_uso_ins) THEN
        p_c_rec_status :=  'E';
     END IF;

     IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
       fnd_log.string( fnd_log.level_procedure, 'igs.plsql.igs_ps_unit_lgcy_pkg.create_uso_ins.after_import_status',p_c_rec_status);
     END IF;

     l_tbl_uso.DELETE;

  END create_uso_ins;


END igs_ps_unit_lgcy_pkg;

/
