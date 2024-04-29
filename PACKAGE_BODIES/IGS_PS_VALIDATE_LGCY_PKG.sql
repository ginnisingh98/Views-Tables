--------------------------------------------------------
--  DDL for Package Body IGS_PS_VALIDATE_LGCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VALIDATE_LGCY_PKG" AS
/* $Header: IGSPS86B.pls 120.17 2006/04/10 05:26:28 sommukhe ship $ */

  /***********************************************************************************************
    Created By     :  Sanjeeb Rakshit, Shirish Tatiko, Saravana Kumar
    Date Created By:  11-NOV-2002
    Purpose        :  This package has validation functions which will be called from sub processes,
                      in IGS_PS_UNIG_LGCY_PKG package.
                      This Package also provides few generic utility function like set_msg, get_lkup_meaning.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk         28-Jul-2004    Bug # 3793580. Created utility procedure get_uso_id.
    sarakshi     12-Apr-2004    bug#3555871, Removed the function get_call_number
    smvk        25-Nov-2003     Bug # 2833971. Modified validate_usec_el procedure.
    smvk         10-Oct-2003    Bug # 3052445. Added utility function is_waitlist_allowed and modified validate_waitlist_allowed function.
    smvk         23-Sep-2003    Bug # 3121311, Removed the utility procedures uso_effective_dates, validate_staff_person and validate_instructor.
    SMVK         27-Jun-2003    Bug # 2999888. Created procedure validate_unit_reference.
    jbegum      02-June-2003    Bug # 2972950.
                                For Legacy Enhancements TD:
                                Modified the code to use messages rather than lookup codes mentioned in TD, due to
                                Non Backward compatible changes in igslkups.ldt.
                                Created procedure validate_usec_el and uso_effective_dates. Functions post_uso_ins_busi
                                and validate_instructor. Defined usec_tr_rectype record struture, usec_tr_tbltype table structure and
                                v_tab_usec_tr global parameter. Created new procedure validate_enr_lmts. The changes are as mentioned in TD.
                                Modified validate_staff_person, get_call_number()
                                As a part of Binding issues, modified unit_version procedure and validate_org_unit_cd function.
                                For the PSP Scheduling Enhancements TD:
                                Modified the procedure validate_usec_occurs.
                                For the PSP Enhancements TD:
                                Modified the procedure validate_uoo.
    sarakshi  04-Mar-2003      Bug#2768783,modified get_call_number and validate_uoo procedures
    smvk      12-Dec-2002      Passing the value TRUE to the newly added parameter p_b_lgcy_validator to the
                               functions call igs_ps_val_tr.crsp_val_tr_perc,igs_ps_val_ud.crsp_val_ud_perc.
                               As a part of the Bug # 2696207.
    smvk       26-Dec-2002     Added a generic procedure (get_party_id) and a function (validate_staff_person)
                               As a part of Bug # 2721495
  ********************************************************************************************** */

  g_n_user_id igs_ps_unit_ver_all.created_by%TYPE := NVL(fnd_global.user_id,-1);
  g_n_login_id igs_ps_unit_ver_all.last_update_login%TYPE := NVL(fnd_global.login_id,-1);

  -- for doing certain validation at unit section level while importing unit section occurrence of instructors
  TYPE usec_tr_rectype IS RECORD( uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                  instr_index NUMBER);
  TYPE usec_tr_tbltype IS TABLE OF usec_tr_rectype index by binary_integer;
  v_tab_usec_tr usec_tr_tbltype;


  PROCEDURE upd_usec_occurs_schd_status ( p_uoo_id IN NUMBER, schd_stat IN VARCHAR2 ) AS

    --Bug # 2831065. Update the USO which are not in schedule status processing and input schedule status schd_stat.
    CURSOR c_usec_occurs ( p_uoo_id IN NUMBER, cp_c_schd_stat IN  igs_ps_usec_occurs.schedule_status%TYPE) IS
      SELECT ROWID, puo.*
      FROM   igs_ps_usec_occurs puo
      WHERE  uoo_id = p_uoo_id
        AND  (schedule_status IS NULL OR schedule_status <> cp_c_schd_stat)
        AND  NO_SET_DAY_IND ='N'
      FOR UPDATE NOWAIT;

    l_c_cancel igs_ps_usec_occurs_all.cancel_flag%TYPE;
    l_c_schedule_status igs_ps_usec_occurs_all.schedule_status%TYPE;

  BEGIN

    FOR c_usec_occurs_rec IN c_usec_occurs(p_uoo_id, schd_stat) LOOP

      IF schd_stat ='USER_CANCEL' THEN
         IF c_usec_occurs_rec.schedule_status = 'PROCESSING'  THEN
            l_c_schedule_status := 'PROCESSING';
         ELSE
            l_c_schedule_status := schd_stat;
         END IF;
         l_c_cancel := 'Y';
      ELSE
         l_c_schedule_status := schd_stat;
         l_c_cancel := 'N';
      END IF;

      IF schd_stat ='USER_CANCEL' OR (schd_stat ='USER_UPDATE' AND (c_usec_occurs_rec.schedule_status IS NOT NULL AND c_usec_occurs_rec.schedule_status <> 'PROCESSING')) THEN

          igs_ps_usec_occurs_pkg.update_row (
           x_rowid                             => c_usec_occurs_rec.ROWID,
           x_unit_section_occurrence_id        => c_usec_occurs_rec.unit_section_occurrence_id,
           x_uoo_id                            => c_usec_occurs_rec.uoo_id,
           x_monday                            => c_usec_occurs_rec.monday,
           x_tuesday                           => c_usec_occurs_rec.tuesday,
           x_wednesday                         => c_usec_occurs_rec.wednesday,
           x_thursday                          => c_usec_occurs_rec.thursday,
           x_friday                            => c_usec_occurs_rec.friday,
           x_saturday                          => c_usec_occurs_rec.saturday,
           x_sunday                            => c_usec_occurs_rec.sunday,
           x_start_time                        => c_usec_occurs_rec.start_time,
           x_end_time                          => c_usec_occurs_rec.end_time,
           x_building_code                     => c_usec_occurs_rec.building_code,
           x_room_code                         => c_usec_occurs_rec.room_code,
           x_schedule_status                   => l_c_schedule_status,
           x_status_last_updated               => c_usec_occurs_rec.status_last_updated,
           x_instructor_id                     => c_usec_occurs_rec.instructor_id,
           X_attribute_category                => c_usec_occurs_rec.attribute_category,
           X_attribute1                        => c_usec_occurs_rec.attribute1,
           X_attribute2                        => c_usec_occurs_rec.attribute2,
           X_attribute3                        => c_usec_occurs_rec.attribute3,
           X_attribute4                        => c_usec_occurs_rec.attribute4,
           X_attribute5                        => c_usec_occurs_rec.attribute5,
           X_attribute6                        => c_usec_occurs_rec.attribute6,
           X_attribute7                        => c_usec_occurs_rec.attribute7,
           X_attribute8                        => c_usec_occurs_rec.attribute8,
           X_attribute9                        => c_usec_occurs_rec.attribute9,
           X_attribute10                       => c_usec_occurs_rec.attribute10,
           X_attribute11                       => c_usec_occurs_rec.attribute11,
           X_attribute12                       => c_usec_occurs_rec.attribute12,
           X_attribute13                       => c_usec_occurs_rec.attribute13,
           X_attribute14                       => c_usec_occurs_rec.attribute14,
           X_attribute15                       => c_usec_occurs_rec.attribute15,
           X_attribute16                       => c_usec_occurs_rec.attribute16,
           X_attribute17                       => c_usec_occurs_rec.attribute17,
           X_attribute18                       => c_usec_occurs_rec.attribute18,
           X_attribute19                       => c_usec_occurs_rec.attribute19,
           X_attribute20                       => c_usec_occurs_rec.attribute20,
           x_error_text                        => c_usec_occurs_rec.error_text,
           x_mode                              => 'R',
           X_start_date                        => c_usec_occurs_rec.start_date,
           X_end_date                          => c_usec_occurs_rec.end_date,
           X_to_be_announced                   => c_usec_occurs_rec.to_be_announced,
           x_dedicated_building_code           => c_usec_occurs_rec.dedicated_building_code,
           x_dedicated_room_code               => c_usec_occurs_rec.dedicated_room_code,
           x_preferred_building_code           => c_usec_occurs_rec.preferred_building_code,
           x_preferred_room_code               => c_usec_occurs_rec.preferred_room_code,
           x_inst_notify_ind                   => c_usec_occurs_rec.inst_notify_ind,
           x_notify_status                     => c_usec_occurs_rec.notify_status,
           x_preferred_region_code             => c_usec_occurs_rec.preferred_region_code,
           x_no_set_day_ind                    => c_usec_occurs_rec.no_set_day_ind,
           x_cancel_flag                       => l_c_cancel,
 	   x_occurrence_identifier             => c_usec_occurs_rec.occurrence_identifier,
	   x_abort_flag                        => c_usec_occurs_rec.abort_flag
         );
       END IF;
    END LOOP;

 END upd_usec_occurs_schd_status;

  PROCEDURE validate_enr_lmts( p_n_ern_min igs_ps_unit_ver_all.enrollment_minimum%TYPE,
                               p_n_enr_max igs_ps_unit_ver_all.enrollment_maximum%TYPE,
                               p_n_ovr_max igs_ps_unit_ver_all.override_enrollment_max%TYPE,
                               p_n_adv_max igs_ps_unit_ver_all.advance_maximum%TYPE,
                               p_c_rec_status IN OUT NOCOPY VARCHAR2) ;

  PROCEDURE unit_version(p_unit_ver_rec    IN OUT NOCOPY  igs_ps_generic_pub.unit_ver_rec_type,
                         p_coord_person_id IN             igs_ps_unit_ver_all.coord_person_id%TYPE) AS
  /***********************************************************************************************

  Created By:         sarakshi
  Date Created By:    13-Nov-2002
  Purpose:            This procedure validates legacy data.

  Known limitations,enhancements,remarks:

  Change History

  Who       When          What
  sommukhe  10-Mar-2006   Bug#5140666,changed the sizse of l_func_name from 10 to 50.
  sommukhe  16-FEB-2006   Bug#5040156,Description: Change call from GET_WHERE_CLAUSE to GET_WHERE_CLAUSE_API1 as a part of Literal fix
  sarakshi  04-May-2004   Enh#3568858, added validation related to columns ovrd_wkld_val_flag, workload_val_code
  sarakshi  10-Nov-2003   Enh#3116171, added business logic related to the newly introduced field BILLING_CREDIT_POINTS
  sarakshi  22-Aug-2003   Enh#3045069, added validations related to repeatable indicator.
  sarakshi  04-Jul-2003   Enh#3036221,removed the validation for repeatable checkbox
  jbegum    02-June-2003  Bug # 2972950.
                          For the Legacy Enhancements TD:
                          Add the call to validate_enr_lmts procedure as mentioned in TD.
                          As a part of Binding issues, using bind variable in the ref cursor.
  smvk      27-feb-2003  Bug #2770598. Added the validation "re-enrollment for credit('Repeatable_Ind') is not allowed
                         then the max_repeats_for_credit maximum repeats credit points and max_repeats_for_funding should be null.
  smvk      26-Dec-2002  Bug # 2721495. Using the function to validate_staff_person instead of igs_en_gen_003.get_staff_ind.
  ***********************************************************************************************/
  CURSOR c_subtitle(cp_unit_cd        igs_ps_unit_subtitle.unit_cd%TYPE,
                      cp_version_number igs_ps_unit_subtitle.version_number%TYPE) IS
  SELECT 'X'
  FROM   igs_ps_unit_subtitle
  WHERE  closed_ind='N'
  AND    approved_ind='Y'
  AND    unit_cd=cp_unit_cd
  AND    version_number=cp_version_number;
  l_c_var           VARCHAR2(1);
  l_c_message_name  fnd_new_messages.message_name%TYPE;
  l_func_name VARCHAR2(50) := 'UNIT_VERSION_LGCY';

  TYPE c_ref_cur IS REF CURSOR;
  c_org_cur         c_ref_cur;
  l_c_where_clause  VARCHAR2(3000);
  l_c_cur_stat      VARCHAR2(3100);
  l_c_rec_found       VARCHAR2(1);
  BEGIN
    --Validate the start_dt,end_dt and expiry_dt fields,using the generic function
    IF (NOT igs_ps_val_us.crsp_val_ver_dt(p_unit_ver_rec.start_dt,
                                          p_unit_ver_rec.end_dt,
                                          p_unit_ver_rec.expiry_dt,
                                          l_c_message_name,
                                          TRUE)) THEN
      p_unit_ver_rec.status:='E';
    END IF;

    --Validate end date cannot be set for non inactive status
    IF (NOT igs_ps_val_uv.crsp_val_uv_end_sts(p_unit_ver_rec.end_dt,
                                              p_unit_ver_rec.unit_status,
                                              l_c_message_name)) THEN
      igs_ps_validate_lgcy_pkg.set_msg(l_c_message_name,NULL,NULL,FALSE);
      p_unit_ver_rec.status:='E';
    END IF;

    --Removed the validation to check unit coordinator is a staff person.As a part of bug # 3121311

    --Validate if unit version has the assessable indicator checked then it must have supplementary exam checked
    IF (NOT igs_ps_val_uv.crsp_val_uv_sup_exam(p_unit_ver_rec.supp_exam_permitted_ind,
                                               p_unit_ver_rec.assessable_ind,
                                               l_c_message_name)) THEN

      igs_ps_validate_lgcy_pkg.set_msg(l_c_message_name,NULL,NULL,FALSE);
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate atleast one unit enrollment method type between interactive Voice response and
    --self service should be selected
    IF p_unit_ver_rec.ivr_enrol_ind = 'N' and p_unit_ver_rec.ss_enrol_ind = 'N' THEN
      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_ONE_UNIT_ENR_MTHD',NULL,NULL,FALSE);
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate only one version of unit can exist with active status and expiry date not set
    IF (NOT igs_ps_val_uv.crsp_val_uv_exp_sts(p_unit_ver_rec.unit_cd,
                                         p_unit_ver_rec.version_number,
                                         p_unit_ver_rec.expiry_dt,
                                         p_unit_ver_rec.unit_status,
                                         l_c_message_name)) THEN

      igs_ps_validate_lgcy_pkg.set_msg(l_c_message_name,NULL,NULL,FALSE);
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate status with respect to superior and subordinate units
    IF (NOT igs_ps_val_uv.crsp_val_uv_unit_sts(p_unit_ver_rec.unit_cd,
                                               p_unit_ver_rec.version_number,
                                               p_unit_ver_rec.unit_status,
                                               NULL,
                                               l_c_message_name,
                                               TRUE)) THEN
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate if auditable checkbox is checked then only audit_permission_ind and max_auditors_allowed can have values
    IF p_unit_ver_rec.auditable_ind = 'N' THEN
      IF p_unit_ver_rec.audit_permission_ind = 'Y' THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_AUDIT_PERMISSION_EXIST',NULL,NULL,FALSE);
        p_unit_ver_rec.status :='E';
      END IF;
      IF p_unit_ver_rec.max_auditors_allowed IS NOT NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_MAX_AUDIT_ALWD_EXIST',NULL,NULL,FALSE);
        p_unit_ver_rec.status :='E';
      END IF;
    END IF;

    --Validate if credit point indicator is checked and points max,points min,points increment are null
    IF p_unit_ver_rec.points_override_ind = 'Y' AND (p_unit_ver_rec.points_increment IS NULL OR
                                                     p_unit_ver_rec.points_max IS NULL OR
                                                     p_unit_ver_rec.points_min IS NULL) THEN

      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_CPS_NULL',NULL,NULL,FALSE);
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate the credit points related validations using generic function
    IF (NOT igs_ps_val_uv.crsp_val_uv_pnt_ovrd(p_unit_ver_rec.points_override_ind,
                                               p_unit_ver_rec.points_increment,
                                               p_unit_ver_rec.points_min,
                                               p_unit_ver_rec.points_max,
                                               p_unit_ver_rec.enrolled_credit_points,
                                               p_unit_ver_rec.achievable_credit_points,
                                               l_c_message_name,
                                               TRUE)) THEN
      p_unit_ver_rec.status :='E';
    END IF;


    --Validate if override credit points indicator has been unchecked and points max,points min,
    --points increment are not null
    IF p_unit_ver_rec.points_override_ind = 'N' AND (p_unit_ver_rec.points_increment IS NOT NULL OR
                                                     p_unit_ver_rec.points_max IS NOT NULL OR
                                                     p_unit_ver_rec.points_min IS NOT NULL) THEN
      igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_CPS_NOT_NULL',NULL,NULL,FALSE);
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate if approved subtitles exists for a unit version, if then only approved subtitles can only be
    --used.If approved subtitles does not exits then free format subtitles can be used
    OPEN c_subtitle(p_unit_ver_rec.unit_cd,p_unit_ver_rec.version_number);
    FETCH c_subtitle INTO l_c_var;
    IF c_subtitle%FOUND THEN
      IF p_unit_ver_rec.subtitle_approved_ind = 'N' AND p_unit_ver_rec.subtitle IS NOT NULL THEN
        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_INVALID_SUBTITLE',NULL,NULL,FALSE);
        p_unit_ver_rec.status :='E';
      END IF;
    END IF;
    CLOSE c_subtitle;


    --Billing credit Points can be provided only when auditable_ind is set to Y
    IF p_unit_ver_rec.auditable_ind = 'N' AND p_unit_ver_rec.billing_credit_points IS NOT NULL THEN
       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_BILL_CRD_PTS_ERROR',NULL,NULL,FALSE);
       p_unit_ver_rec.status :='E';
    END IF;

   --Added this validation as a part of bug#4199404
   IF p_unit_ver_rec.approval_date IS NOT NULL AND p_unit_ver_rec.approval_date > p_unit_ver_rec.start_dt THEN
       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_VALID_APPRDATE',NULL,NULL,FALSE);
       p_unit_ver_rec.status :='E';
   END IF;

    --validation releted to repeatable indicator columm
    IF p_unit_ver_rec.repeatable_ind = 'X' THEN
       IF p_unit_ver_rec.max_repeats_for_credit IS NOT NULL OR p_unit_ver_rec.max_repeats_for_funding IS NOT NULL OR
          p_unit_ver_rec.max_repeat_credit_points IS NOT NULL OR p_unit_ver_rec.same_teach_period_repeats IS NOT NULL OR
          p_unit_ver_rec.same_teach_period_repeats_cp IS NOT NULL THEN

          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_RPT_X',NULL,NULL,FALSE);
          p_unit_ver_rec.status :='E';
       END IF;
       IF p_unit_ver_rec.same_teaching_period = 'Y' THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_RPT_X_SAME_TCH_PRD',NULL,NULL,FALSE);
          p_unit_ver_rec.status :='E';
       END IF;

    ELSIF p_unit_ver_rec.repeatable_ind = 'N' THEN
       IF p_unit_ver_rec.max_repeat_credit_points IS NOT NULL OR p_unit_ver_rec.same_teach_period_repeats IS NOT NULL OR
          p_unit_ver_rec.same_teach_period_repeats_cp IS NOT NULL THEN

          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_RPT_N',NULL,NULL,FALSE);
          p_unit_ver_rec.status :='E';
       END IF;

       IF p_unit_ver_rec.same_teaching_period = 'Y' THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_RPT_N_SAME_TCH_PRD',NULL,NULL,FALSE);
          p_unit_ver_rec.status :='E';
       END IF;

       IF p_unit_ver_rec.max_repeats_for_funding IS NULL AND p_unit_ver_rec.max_repeats_for_credit IS NOT NULL THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_CREDIT_FUNDING',NULL,NULL,FALSE);
          p_unit_ver_rec.status :='E';
       END IF;

       IF p_unit_ver_rec.max_repeats_for_funding > p_unit_ver_rec.max_repeats_for_credit THEN
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MAX_FUN_LE_MA',NULL,NULL,FALSE);
          p_unit_ver_rec.status :='E';
       END IF;
    ELSE
      IF p_unit_ver_rec.max_repeats_for_funding IS NOT NULL THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_RPT_Y',NULL,NULL,FALSE);
         p_unit_ver_rec.status :='E';
      END IF;

      IF p_unit_ver_rec.max_repeats_for_credit = 0 AND p_unit_ver_rec.max_repeat_credit_points IS NOT NULL  THEN
         igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MAX_REP_CRD_PTS',NULL,NULL,FALSE);
         p_unit_ver_rec.status :='E';
      END IF;

      IF  p_unit_ver_rec.same_teaching_period = 'Y' THEN
         IF p_unit_ver_rec.same_teach_period_repeats > p_unit_ver_rec.max_repeats_for_credit  THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_TPA_LE_MA',NULL,NULL,FALSE);
           p_unit_ver_rec.status :='E';
         END IF;

        IF p_unit_ver_rec.max_repeats_for_credit IS NOT NULL AND p_unit_ver_rec.same_teach_period_repeats IS NULL  THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MAX_ALWD_SAME_TCH',NULL,NULL,FALSE);
           p_unit_ver_rec.status :='E';
        END IF;

        IF p_unit_ver_rec.same_teach_period_repeats = 0 AND p_unit_ver_rec.same_teach_period_repeats_cp IS NOT NULL THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_TCH_PRD_RPT_CP',NULL,NULL,FALSE);
           p_unit_ver_rec.status :='E';
        END IF;

        IF  p_unit_ver_rec.same_teach_period_repeats_cp > p_unit_ver_rec.max_repeat_credit_points THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MAX_TCH_PRD_RPT_CP',NULL,NULL,FALSE);
           p_unit_ver_rec.status :='E';
        END IF;

        IF p_unit_ver_rec.max_repeat_credit_points IS NOT NULL AND p_unit_ver_rec.same_teach_period_repeats_cp IS NULL THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_MX_CRD_SAME_TCH_CR',NULL,NULL,FALSE);
           p_unit_ver_rec.status :='E';
        END IF;

      ELSE

        IF p_unit_ver_rec.same_teach_period_repeats IS NOT NULL OR p_unit_ver_rec.same_teach_period_repeats_cp IS NOT NULL THEN
           igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_TCH_PRD_RPS_N_NULL',NULL,NULL,FALSE);
           p_unit_ver_rec.status :='E';
        END IF;

      END IF;

    END IF;


    --Workload Validation cannot be provided only when Override validation set to N
    --Workload Validation to be provided  when Override validation set to Y
    IF (p_unit_ver_rec.ovrd_wkld_val_flag = 'N' AND p_unit_ver_rec.workload_val_code IS NOT NULL) OR
       (p_unit_ver_rec.ovrd_wkld_val_flag = 'Y' AND p_unit_ver_rec.workload_val_code IS NULL)  THEN

        igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_WKLD_VALIDATION',NULL,NULL,FALSE);
        p_unit_ver_rec.status :='E';
    END IF;

    --Validate the DFF's
    IF NOT igs_ad_imp_018.validate_desc_flex(p_unit_ver_rec.attribute_category,
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
                                             'IGS_PS_UNIT_VER_FLEX') THEN

      igs_ps_validate_lgcy_pkg.set_msg('IGS_AD_INVALID_DESC_FLEX',NULL,NULL,FALSE);
      p_unit_ver_rec.status :='E';
    END IF;

    --Validate Org unit filter integration
    --Bug #2972950. As a part of Binding issues, using bind variable in the ref cursor.Original sql bind fix bug is 2941266
    igs_or_gen_012_pkg.get_where_clause_api1('UNIT_VERSION_LGCY',l_c_where_clause);
    IF l_c_where_clause IS NOT NULL THEN
      l_c_cur_stat  :='SELECT '||''''||'X'||''''||' FROM IGS_OR_INST_ORG_BASE_V WHERE party_number = :p_c_org_unit_cd AND '|| l_c_where_clause;
      OPEN c_org_cur FOR l_c_cur_stat USING p_unit_ver_rec.owner_org_unit_cd,l_func_name ;
    ELSE
      l_c_cur_stat  :='SELECT '||''''||'X'||''''||' FROM IGS_OR_INST_ORG_BASE_V WHERE party_number= :p_c_org_unit_cd ';
      OPEN c_org_cur FOR l_c_cur_stat USING p_unit_ver_rec.owner_org_unit_cd ;
    END IF;
    FETCH c_org_cur INTO l_c_rec_found;
    IF c_org_cur%NOTFOUND THEN
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV','OWNER_ORG_UNIT_CD','LEGACY_TOKENS',FALSE);
      p_unit_ver_rec.status :='E';
    END IF;
    CLOSE c_org_cur;

    validate_enr_lmts (p_unit_ver_rec.enrollment_minimum, p_unit_ver_rec.enrollment_maximum, p_unit_ver_rec.override_enrollment_max, p_unit_ver_rec.advance_maximum, p_unit_ver_rec.status);

  END unit_version;

  FUNCTION post_teach_resp ( p_tab_teach_resp IN OUT NOCOPY igs_ps_generic_pub.unit_tr_tbl_type
                           ) RETURN BOOLEAN  AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  11-NOV-2002
    Purpose        :  This procedure will do validations after inserting records of Teaching
                      Responsibility.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk      12-Dec-2002      Added a boolean parameter to the function call igs_ps_val_tr.crsp_val_tr_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */
  l_c_message VARCHAR2(30);
  l_n_count_msg NUMBER(6);

  BEGIN
    -- Check if total percentage for a given unit_cd and version_number is 100. If not, change the status of records accordingly.
    IF NOT igs_ps_val_tr.crsp_val_tr_perc ( p_tab_teach_resp(p_tab_teach_resp.FIRST).unit_cd, p_tab_teach_resp(p_tab_teach_resp.FIRST).version_number, l_c_message ,TRUE) THEN
      fnd_message.set_name ( 'IGS', l_c_message );
      fnd_msg_pub.add;

      l_n_count_msg := fnd_msg_pub.count_msg;
      FOR I in 1..p_tab_teach_resp.LAST LOOP
        IF p_tab_teach_resp.EXISTS(I) THEN
          IF p_tab_teach_resp(I).status = 'S' THEN
            p_tab_teach_resp(I).status   := 'E';
            /* Add Reference to the last added message i.e., l_c_message. */
            p_tab_teach_resp(I).msg_from := l_n_count_msg;
            p_tab_teach_resp(I).msg_to   := l_n_count_msg;
          END IF;
        END IF;
      END LOOP;
      RETURN FALSE;
    END IF;

    RETURN TRUE;

  END post_teach_resp;

  FUNCTION post_unit_discip ( p_tab_unit_dscp IN OUT NOCOPY igs_ps_generic_pub.unit_dscp_tbl_type
                            ) RETURN BOOLEAN AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  15-NOV-2002
    Purpose        :  This procedure will do validations after inserting records of Unit Discipline.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk      12-Dec-2002      Added a boolean parameter to the function call igs_ps_val_ud.crsp_val_ud_perc.
                               As a part of the Bug # 2696207
  ********************************************************************************************** */
  l_c_message VARCHAR2(30);
  l_n_count_msg NUMBER(6);

  BEGIN
    -- Check if total percentage for a given unit_cd and version_number is 100. If not, change the status of records accordingly.
    IF NOT igs_ps_val_ud.crsp_val_ud_perc ( p_tab_unit_dscp(p_tab_unit_dscp.FIRST).unit_cd, p_tab_unit_dscp(p_tab_unit_dscp.FIRST).version_number, l_c_message ,TRUE) THEN
      fnd_message.set_name ( 'IGS', l_c_message );
      fnd_msg_pub.add;

      l_n_count_msg := fnd_msg_pub.count_msg;
      FOR I in 1..p_tab_unit_dscp.LAST LOOP
        IF p_tab_unit_dscp.EXISTS(I) THEN
          IF p_tab_unit_dscp(I).status = 'S' THEN
            p_tab_unit_dscp(I).status   := 'E';
            /* Add Reference to the last added message i.e., l_c_message. */
            p_tab_unit_dscp(I).msg_from := l_n_count_msg;
            p_tab_unit_dscp(I).msg_to   := l_n_count_msg;
          END IF;
        END IF;
      END LOOP;
      RETURN FALSE;
    END IF;

    RETURN TRUE;

  END post_unit_discip;

PROCEDURE validate_unit_grd_sch ( p_unit_gs_rec IN OUT NOCOPY igs_ps_generic_pub.unit_gs_rec_type )
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  15-NOV-2002
    Purpose        :  This procedure will do validations before inserting records of Unit Grading Schema.
                      This is called from sub process of legacy import data, which inserts Unit GS records.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  BEGIN
  -- Check if grading schema type is 'UNIT' for a given grading schema.
    IF NOT validate_gs_type ( p_unit_gs_rec.grading_schema_code, p_unit_gs_rec.grd_schm_version_number ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_LGCY_INCORRECT_GS_TYPE' );
      fnd_msg_pub.add;
      p_unit_gs_rec.status := 'E';
      RETURN;
    END IF;
  END validate_unit_grd_sch;

  FUNCTION post_unit_grd_sch ( p_tab_grd_sch IN OUT NOCOPY igs_ps_generic_pub.unit_gs_tbl_type ) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  18-NOV-2002
    Purpose        :  This function will do validations after inserting records of Unit Grading Schema.
                      This will returns TRUE if all the validations pass and returns FALSE, if fails.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_unit_gs_count (
            cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
            cp_ver_num igs_ps_unit_ver_all.version_number%TYPE
  ) IS
  SELECT COUNT(*) cnt
  FROM igs_ps_unit_grd_schm
  WHERE
    unit_code = cp_unit_cd AND
    unit_version_number = cp_ver_num AND
    default_flag = 'Y';
  rec_unit_gs_count c_unit_gs_count%ROWTYPE;
  l_n_count_msg NUMBER(6);

  BEGIN

  -- Check if atleast and atmost one default flag is set to 'Y' for a given unit code and version number.
    OPEN c_unit_gs_count (
            cp_unit_cd => p_tab_grd_sch(p_tab_grd_sch.FIRST).unit_cd,
            cp_ver_num => p_tab_grd_sch(p_tab_grd_sch.FIRST).version_number
    );
    FETCH c_unit_gs_count INTO rec_unit_gs_count;
    IF rec_unit_gs_count.cnt = 1 THEN
      CLOSE c_unit_gs_count;
      RETURN TRUE;
    ELSE
      fnd_message.set_name ( 'IGS', 'IGS_PS_ONE_UGSC_DFLT_MARK' );
      fnd_msg_pub.add;

      l_n_count_msg := fnd_msg_pub.count_msg;
      FOR I in 1..p_tab_grd_sch.LAST LOOP
        IF p_tab_grd_sch.EXISTS(I) THEN
          IF p_tab_grd_sch(I).status = 'S' THEN
            p_tab_grd_sch(I).status := 'E';
            p_tab_grd_sch(I).msg_from := l_n_count_msg;
            p_tab_grd_sch(I).msg_to := l_n_count_msg;
          END IF;
        END IF;
      END LOOP;
      CLOSE c_unit_gs_count;
      RETURN FALSE;
    END IF;

  END post_unit_grd_sch;


  -- Validate Unit Offer Option Records before inserting them
  PROCEDURE validate_uoo ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                           p_c_cal_type IN igs_ca_type.cal_type%TYPE,
                           p_n_seq_num IN igs_ca_inst_all.sequence_number%TYPE,
                           p_n_sup_uoo_id IN OUT NOCOPY igs_ps_unit_ofr_opt_all.sup_uoo_id%TYPE,
			   p_insert_update VARCHAR2,
			   p_conc_flag OUT NOCOPY BOOLEAN)
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  22-NOV-2002
    Purpose        :  This does legacy validations before inserting Unit Offering Option Records.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe  12-JAN-2006       Bug#4926548, in the cursor user_check changed the table fnd_user_resp_groups to fnd_user_resp_groups_direct
                                modified the cursors c_anon_grd_method and c_cal_rel also introduced new cursors c_min_load_start_dt and cur_teach_load.
    sarakshi  13-Apr-2004       Bug#3555871,added validation of teach calender association with load calender.Also removed the call of get_call_number .
    sarakshi  21-oct-2003       Bug#3052452,used igs_ps_gen_003.enrollment_for_uoo_check in place of using a local cursor
    smvk      24-Sep-2003       Bug # 3121311. Removed the validation to check unit contact person is of person type staff member.
                                Removed the variable l_n_unit_contact_id and calls to get_party_id and validate_staff_person.
    sarakshi  11-Sep-2003       Enh#3052452,Added validation related to passed sup_uoo_id
    sarakshi  22-Aug-2003       Bug#304509, added validation, Not Multiple Unit Section Flag should not be N if it N at Unit level
    sarakshi  04-Mar-2003       Bug#2768783, addded call number validation for profile option NONE also
    smvk      26-Dec-2002       Bug # 2721495. Using the newly created function and procedure get_party_id, validate_staff_person.
  ********************************************************************************************** */
    l_n_call_number igs_ps_unit_ofr_opt_all.call_number%TYPE;
    -- Removed l_n_unit_contact_id as a part of bug # 3121311
    l_c_message VARCHAR2(30);

    CURSOR c_location_type ( cp_location_cd igs_ad_location_all.location_cd%TYPE ) IS
    SELECT 'x'
    FROM   igs_ad_location_all a,
	   igs_ad_location_type_all b
    WHERE  a.location_type = b.location_type
    AND    b.s_location_type = 'CAMPUS'
    AND    a.location_cd = cp_location_cd;
    rec_location_type c_location_type%ROWTYPE;

    CURSOR c_anon_unit_grading ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
				 cp_version_number igs_ps_unit_ver_all.version_number%TYPE ) IS
    SELECT 1
    FROM   igs_ps_unit_ver
    WHERE  unit_cd = cp_unit_cd
    AND    version_number = cp_version_number
    AND    anon_unit_grading_ind = 'Y' ;
    rec_anon_unit_grading c_anon_unit_grading%ROWTYPE;

    CURSOR c_anon_grd_method ( cp_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE,
			       cp_ci_seq_num igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
			       cp_load_start_dt igs_ca_inst_all.start_dt%TYPE) IS
    SELECT 1
    FROM   igs_ca_teach_to_load_v a,
	   igs_as_anon_method b
    WHERE  a.teach_cal_type = cp_cal_type
    AND    a.teach_ci_sequence_number = cp_ci_seq_num
    AND    a.load_start_dt = cp_load_start_dt
    AND    a.load_cal_type = b.load_cal_type;
    rec_anon_grd_method c_anon_grd_method%ROWTYPE;

    CURSOR c_min_load_start_dt ( cp_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE,
			       cp_ci_seq_num igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE ) IS
    SELECT MIN(c.load_start_dt)
    FROM   igs_ca_teach_to_load_v c
    WHERE  c.teach_cal_type = cp_cal_type
    AND    c.teach_ci_sequence_number = cp_ci_seq_num ;

    l_load_start_dt igs_ca_inst_all.start_dt%TYPE;

    CURSOR c_anon_assess_grading ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
				   cp_version_number igs_ps_unit_ver_all.version_number%TYPE ) IS
    SELECT 1
    FROM   igs_ps_unit_ver
    WHERE  unit_cd = cp_unit_cd
    AND    version_number = cp_version_number
    AND    anon_assess_grading_ind = 'Y';
    rec_anon_assess_grading c_anon_assess_grading%ROWTYPE;

    --Enh bug#2972950
    --For PSP Enhancements the following cursor was added
    CURSOR c_cal_status  ( cp_c_cal_type igs_ca_inst_all.cal_type%TYPE,
			   cp_n_ci_seq_num igs_ca_inst_all.sequence_number%TYPE ) IS
    SELECT B.s_cal_status
    FROM igs_ca_inst_all A,igs_ca_stat B
    WHERE A.cal_type = cp_c_cal_type
    AND   A.sequence_number = cp_n_ci_seq_num
    AND   A.cal_status = B.cal_status;

    rec_cal_status c_cal_status%ROWTYPE;

    CURSOR c_muiltiple_section_flag ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
				      cp_version_number igs_ps_unit_ver_all.version_number%TYPE )IS
    SELECT same_teaching_period
    FROM   igs_ps_unit_ver_all
    WHERE  unit_cd = cp_unit_cd
    AND    version_number = cp_version_number;

    l_same_teaching_period  igs_ps_unit_ver_all.same_teaching_period%TYPE;

    CURSOR c_crosslist ( cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
    SELECT 'X'
    FROM  igs_ps_usec_x_grpmem
    WHERE uoo_id = cp_uoo_id;


    CURSOR c_usec_status ( cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			   cp_usec_status igs_ps_unit_ofr_opt_all.unit_section_status%TYPE) IS
    SELECT 'X'
    FROM  igs_ps_unit_ofr_opt_all
    WHERE uoo_id = cp_uoo_id
    AND   unit_section_status = cp_usec_status;

    CURSOR c_relation (cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
		       cp_relation_type igs_ps_unit_ofr_opt_all.relation_type%TYPE) IS
    SELECT 'X'
    FROM  igs_ps_unit_ofr_opt_all
    WHERE uoo_id = cp_uoo_id
    AND   relation_type = cp_relation_type;

    CURSOR c_cal_seq_no(cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE)  IS
    SELECT uoo.cal_type,uoo.ci_sequence_number
    FROM   igs_ps_unit_ofr_opt_all uoo
    WHERE  uoo.uoo_id = cp_uoo_id;


    TYPE teach_cal_rec IS RECORD(
				 cal_type igs_ca_inst_all.cal_type%TYPE,
				 sequence_number igs_ca_inst_all.sequence_number%TYPE
				 );
    TYPE teachCalendar IS TABLE OF teach_cal_rec INDEX BY BINARY_INTEGER;
    teachCalendar_tbl teachCalendar;
    l_n_counter NUMBER(10);
    l_c_proceed BOOLEAN ;


    CURSOR cur_teach_load IS
    SELECT load_cal_type,load_ci_sequence_number
    FROM   igs_ca_teach_to_load_v
    WHERE  teach_cal_type=p_c_cal_type
    AND    teach_ci_sequence_number=p_n_seq_num;

    CURSOR c_cal_rel(cp_cal_teach_type           igs_ca_load_to_teach_v.teach_cal_type%TYPE,
		     cp_teach_ci_sequence_number igs_ca_load_to_teach_v.teach_ci_sequence_number%TYPE)  IS
    SELECT load_cal_type,load_ci_sequence_number
    FROM   igs_ca_load_to_teach_v
    WHERE  teach_cal_type = cp_cal_teach_type
    AND    teach_ci_sequence_number = cp_teach_ci_sequence_number;

    CURSOR c_teach_to_load ( cp_cal_type igs_ca_type.cal_type%TYPE,
			     cp_seq_num igs_ca_inst_all.sequence_number%TYPE ) IS
    SELECT load_cal_type lcal_type, load_ci_sequence_number lseq_num
    FROM igs_ca_teach_to_load_v
    WHERE
      teach_cal_type = cp_cal_type AND
      teach_ci_sequence_number = cp_seq_num;
    rec_teach_to_load c_teach_to_load%ROWTYPE;

    CURSOR c_usec IS
    SELECT a.*, a.rowid
    FROM  igs_ps_unit_ofr_opt_all a
    WHERE unit_cd = p_usec_rec.unit_cd
    AND version_number =  p_usec_rec.version_number
    AND ci_sequence_number =p_n_seq_num
    AND unit_class = p_usec_rec.unit_class
    AND location_cd = p_usec_rec.location_cd
    AND cal_type = p_c_cal_type ;

    c_usec_rec c_usec%ROWTYPE;

    CURSOR c_uso(cp_n_uoo_id igs_ps_usec_occurs_all.uoo_id%TYPE) IS
    SELECT uso.rowid, uso.*
    FROM   igs_ps_usec_occurs_all uso
    WHERE  uso.uoo_id = cp_n_uoo_id
    AND    building_code IS NOT NULL;

    CURSOR cur_unit_audit(cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
    SELECT 'X'
    FROM IGS_EN_SU_ATTEMPT
    WHERE uoo_id = cp_uoo_id
    AND no_assessment_ind='Y';
    rec_unit_audit cur_unit_audit%ROWTYPE;


    CURSOR user_check(cp_user_id IN fnd_user_resp_groups.user_id%TYPE) IS
    SELECT 'X'
    FROM fnd_user_resp_groups_direct a,fnd_responsibility_vl b, fnd_user c
    WHERE a.user_id= cp_user_id
    AND   a.user_id = c.user_id
    AND   TRUNC(SYSDATE) BETWEEN TRUNC(c.start_date) AND TRUNC(NVL(c.end_date,SYSDATE))
    AND   a.responsibility_id= b.responsibility_id
    AND   b.responsibility_key    ='IGS_SUPER_USER'
    AND   TRUNC(SYSDATE) BETWEEN TRUNC(a.start_date) AND TRUNC(NVL(a.end_date,SYSDATE));


    l_v_flag  igs_ps_unit_ver.same_teaching_period%TYPE;
    l_c_perference_name igs_pe_person.preferred_name%TYPE;
    v_message_name VARCHAR2(30);
    v_request_id NUMBER;


    l_c_cal_seq_no  c_cal_seq_no%ROWTYPE;
    l_n_sup_uoo_id  igs_ps_unit_ofr_opt_all.sup_uoo_id%TYPE;
    l_c_valid_fail  BOOLEAN := FALSE;
    l_c_var         VARCHAR2(1);

      FUNCTION testCalendar(cp_cal_type igs_ca_inst_all.cal_type%TYPE,
                          cp_sequence_number igs_ca_inst_all.sequence_number%TYPE)  RETURN BOOLEAN AS
    BEGIN
      IF teachCalendar_tbl.EXISTS(1) THEN
        FOR i IN 1..teachCalendar_tbl.last LOOP
	     IF cp_cal_type=teachCalendar_tbl(i).cal_type AND
		cp_sequence_number=teachCalendar_tbl(i).sequence_number THEN
		RETURN TRUE;
	     END IF;
	END LOOP;
      END IF;
      RETURN FALSE;
    END testCalendar;

  BEGIN

    -- validation to check whehter the unit contact person should be of type staff is removed as a part of Bug # 3121311

    l_n_counter :=1;
    FOR cur_teach_load_rec IN cur_teach_load LOOP
      teachCalendar_tbl(l_n_counter).cal_type :=cur_teach_load_rec.load_cal_type;
      teachCalendar_tbl(l_n_counter).sequence_number :=cur_teach_load_rec.load_ci_sequence_number;
      l_n_counter:=l_n_counter+1;
    END LOOP;

    --Fetch the minimum load start date
    OPEN c_min_load_start_dt ( p_c_cal_type, p_n_seq_num );
    FETCH c_min_load_start_dt INTO l_load_start_dt;
    CLOSE c_min_load_start_dt;

    -- Check if the passed location type is of type 'CAMPUS'
    OPEN c_location_type ( p_usec_rec.location_cd );
    FETCH c_location_type INTO rec_location_type;
    IF ( c_location_type%NOTFOUND ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_UVN_NOTE_FK_C' );
      fnd_msg_pub.add;
      p_usec_rec.status := 'E';
    END IF;
    CLOSE c_location_type;

    -- at least one unit enrollment method type between Voice Response and Self Service should be selected
    IF ( p_usec_rec.IVRS_AVAILABLE_IND = 'N' AND p_usec_rec.ss_enrol_ind ='N' ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ONE_UNIT_ENR_MTHD' );
      fnd_msg_pub.add;
      p_usec_rec.status := 'E';
    END IF;

    -- Check whether the teach calender is associated with a load calender.
    OPEN c_teach_to_load ( p_c_cal_type, p_n_seq_num );
    FETCH c_teach_to_load INTO rec_teach_to_load;
    IF c_teach_to_load%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_PS_TECH_NO_LOAD_CAL_EXST' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
    END IF;
    CLOSE c_teach_to_load;

    IF p_insert_update = 'I' THEN---this validation needs to be done only while insert operation
      -- Validate Call Number
      IF (fnd_profile.value('IGS_PS_CALL_NUMBER') = 'AUTO' AND p_usec_rec.call_number IS NOT NULL) THEN

	-- Profile is AUTO and values is passed to call_number so raise error
	igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'CALL_NUMBER', 'LEGACY_TOKENS', FALSE);
	p_usec_rec.status := 'E';
      ELSIF ( fnd_profile.value('IGS_PS_CALL_NUMBER') = 'USER_DEFINED' ) THEN

	IF p_usec_rec.call_number IS NOT NULL THEN
	  IF NOT igs_ps_unit_ofr_opt_pkg.check_call_number ( p_teach_cal_type     => p_c_cal_type,
							     p_teach_sequence_num => p_n_seq_num,
							     p_call_number        => p_usec_rec.call_number,
							     p_rowid              => null ) THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_DUPLICATE_CALL_NUMBER' );
	    fnd_msg_pub.add;
	    p_usec_rec.status := 'E';
	  END IF;
	END IF;
      END IF;
    END IF;

    IF ( fnd_profile.value('IGS_PS_CALL_NUMBER') = 'NONE' ) THEN

	IF p_usec_rec.call_number IS NOT NULL THEN
	  -- Profile is NONE and values is passed to call_number so raise error
	  igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'CALL_NUMBER', 'LEGACY_TOKENS', FALSE);
	  p_usec_rec.status := 'E';
	END IF;

    END IF;


    -- If anonymous grading is set to Yes check whether it is enabled at unit level
    -- and check if anonymous grading method is done
    IF ( p_usec_rec.anon_unit_grading_ind = 'Y' ) THEN
      OPEN c_anon_unit_grading ( p_usec_rec.unit_cd, p_usec_rec.version_number );
      FETCH c_anon_unit_grading INTO rec_anon_unit_grading;
      IF ( c_anon_unit_grading%NOTFOUND ) THEN
        fnd_message.set_name ( 'IGS', 'IGS_AS_ANON_UNT_GRD_DISABLE' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;
      CLOSE c_anon_unit_grading;

      -- check whether configuration of anonymous grading method is done or not.
      OPEN c_anon_grd_method ( p_c_cal_type, p_n_seq_num,l_load_start_dt );
      FETCH c_anon_grd_method INTO rec_anon_grd_method;
      IF c_anon_grd_method%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_AS_CON_UN_GRD_DISABLE' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;
      CLOSE c_anon_grd_method;
    END IF;

    -- If anonymous assessment grading is set to Yes then check whether it is enabled at unit level
    IF ( p_usec_rec.anon_assess_grading_ind = 'Y' ) THEN
      OPEN c_anon_assess_grading ( p_usec_rec.unit_cd, p_usec_rec.version_number );
      FETCH c_anon_assess_grading INTO rec_anon_assess_grading;
      IF ( c_anon_assess_grading%NOTFOUND ) THEN
        fnd_message.set_name ( 'IGS', 'IGS_AS_ANON_ASES_GRD_DISABLE' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;
      CLOSE c_anon_assess_grading;

      -- check whether configuration of anonymous grading method is done or not.
      OPEN c_anon_grd_method ( p_c_cal_type, p_n_seq_num,l_load_start_dt );
      FETCH c_anon_grd_method INTO rec_anon_grd_method;
      IF c_anon_grd_method%NOTFOUND THEN
        fnd_message.set_name ( 'IGS', 'IGS_AS_CON_ASS_GRD_DISABLE' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;
      CLOSE c_anon_grd_method;

    END IF;

    --Enh Bug#2972950
    --The following validation added for PSP Enhancements TD

    OPEN c_cal_status ( p_c_cal_type, p_n_seq_num );
    FETCH c_cal_status INTO rec_cal_status;
    CLOSE c_cal_status;

    --Unit section status should be 'Not Offered' if the corresponding teaching calendar is inactive
    IF rec_cal_status.s_cal_status = 'INACTIVE' THEN
       IF p_usec_rec.unit_section_status <> 'NOT_OFFERED' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_NOT_OFR_INACT_CAL' );
          fnd_msg_pub.add;
          p_usec_rec.status := 'E';
       END IF;
    --Unit section status cannot be 'Not Offered' if the corresponding teaching calendar is not inactive
    ELSE
       IF p_usec_rec.unit_section_status = 'NOT_OFFERED' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_INACT_CAL_NOT_OFR' );
          fnd_msg_pub.add;
          p_usec_rec.status := 'E';
       END IF;
    END IF;

    --Not Multiple Unit Section Flag should not be N if it N at Unit level
    IF p_usec_rec.not_multiple_section_flag = 'N' THEN
       OPEN c_muiltiple_section_flag( p_usec_rec.unit_cd, p_usec_rec.version_number );
       FETCH c_muiltiple_section_flag INTO l_same_teaching_period;
       CLOSE c_muiltiple_section_flag;
       IF l_same_teaching_period = 'N' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_LGCY_US_MULTIPLE_FLAG' );
          fnd_msg_pub.add;
          p_usec_rec.status := 'E';
       END IF;
    END IF;

    --The validation related to the unit section start and end date is added for the bug#4210597
    --Non standard unit section must have unit section start date
    IF p_usec_rec.non_std_usec_ind = 'Y' AND p_usec_rec.unit_section_start_date IS NULL THEN
       fnd_message.set_name ( 'IGS', 'IGS_EN_OFFSET_DT_NULL' );
       fnd_msg_pub.add;
       p_usec_rec.status := 'E';
    END IF;


    --Following validation needs to be performed if the sup_uoo_id is provided
    IF p_n_sup_uoo_id IS NOT NULL THEN

      l_n_sup_uoo_id:=p_n_sup_uoo_id;

      --Check if the superior unit section belong to a crosslisted group
      OPEN c_crosslist(l_n_sup_uoo_id);
      FETCH c_crosslist INTO l_c_var;
      IF c_crosslist%FOUND THEN
        l_c_valid_fail :=TRUE;
      END IF;
      CLOSE c_crosslist;

      --Check if the superior unit section status is NOT_OFFERED
      OPEN c_usec_status(l_n_sup_uoo_id,'NOT_OFFERED');
      FETCH c_usec_status INTO l_c_var;
      IF c_usec_status%FOUND THEN
        l_c_valid_fail :=TRUE;
      END IF;
      CLOSE c_usec_status;

      --Check if the current unit section status is NOT_OFFERED
      IF p_usec_rec.unit_section_status = 'NOT_OFFERED'  THEN
        l_c_valid_fail :=TRUE;
      END IF;

      IF l_c_valid_fail THEN
        p_n_sup_uoo_id:= NULL;
        fnd_message.set_name ( 'IGS', 'IGS_PS_US_NOT_OFF_CRS_LISTED' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;


      --Check if the superior unit section is already in a relationship
      OPEN c_relation(l_n_sup_uoo_id,'SUBORDINATE');
      FETCH c_relation INTO l_c_var;
      IF c_relation%FOUND THEN
        p_n_sup_uoo_id:= NULL;
        fnd_message.set_name ( 'IGS', 'IGS_PS_US_UPLOADED_NORMAL_REL' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;
      CLOSE c_relation;

      --The unit section must belong to the same load calander as the superior unit section section

      --Fetch the calendar instance for the input uoo_id
      OPEN  c_cal_seq_no(l_n_sup_uoo_id);
      FETCH c_cal_seq_no INTO l_c_cal_seq_no;
      CLOSE c_cal_seq_no ;

      IF teachCalendar_tbl.EXISTS(1) THEN
	l_c_proceed:= TRUE;
	FOR c_cal_rel_rec IN c_cal_rel(l_c_cal_seq_no.cal_type,l_c_cal_seq_no.ci_sequence_number) LOOP
	  IF testCalendar(c_cal_rel_rec.load_cal_type ,c_cal_rel_rec.load_ci_sequence_number ) THEN
	    l_c_proceed:=FALSE;
	    EXIT;
	  END IF;
	END LOOP;
	IF l_c_proceed THEN
	  p_n_sup_uoo_id:= NULL;
	  fnd_message.set_name ( 'IGS', 'IGS_PS_SUP_TERM_STUD_ENROLL' );
	  fnd_msg_pub.add;
	  p_usec_rec.status := 'E';
	END IF;
	teachCalendar_tbl.DELETE;
      ELSE
         p_n_sup_uoo_id:= NULL;
	 fnd_message.set_name ( 'IGS', 'IGS_PS_SUP_TERM_STUD_ENROLL' );
	 fnd_msg_pub.add;
	 p_usec_rec.status := 'E';
      END IF;

      --Check if superior unit section exists in any enrollment activity
      IF igs_ps_gen_003.enrollment_for_uoo_check(l_n_sup_uoo_id) THEN
        p_n_sup_uoo_id:= NULL;
        fnd_message.set_name ( 'IGS', 'IGS_PS_SUP_TERM_STUD_ENROLL' );
        fnd_msg_pub.add;
        p_usec_rec.status := 'E';
      END IF;

    END IF;

    --starts of validations for update
    IF p_insert_update = 'U' THEN
      OPEN c_usec;
      FETCH c_usec INTO c_usec_rec;
      CLOSE c_usec;


      IF ( fnd_profile.value('IGS_PS_CALL_NUMBER') = 'USER_DEFINED' ) THEN
	IF p_usec_rec.call_number IS NOT NULL THEN
	  IF NOT igs_ps_unit_ofr_opt_pkg.check_call_number ( p_teach_cal_type     => p_c_cal_type,
							     p_teach_sequence_num => p_n_seq_num,
							     p_call_number        => p_usec_rec.call_number,
							     p_rowid              => c_usec_rec.rowid ) THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_DUPLICATE_CALL_NUMBER' );
	    fnd_msg_pub.add;
	    p_usec_rec.status := 'E';
	  END IF;
	END IF;
      END IF;


      --Unit Section status cant be passed as Not Offered.
      IF p_usec_rec.unit_section_status = 'NOT_OFFERED' THEN
	 fnd_message.set_name('IGS','IGS_PS_CNT_UPD_NOT_OFFERED');
	 fnd_msg_pub.add;
	 p_usec_rec.status := 'E';
      END IF;


      OPEN c_muiltiple_section_flag(p_usec_rec.unit_cd,p_usec_rec.version_number);
      FETCH c_muiltiple_section_flag INTO l_v_flag;
      CLOSE c_muiltiple_section_flag;

      --Enable the checkbox 'Exclude from Multiple Unit Secion', if 'Multiple Unit Section Allowed' checkbox
      --in Unit Repeat/Reenroll Condition form is checked.
      IF NVL(l_v_flag,'N') = 'N' THEN
	--update of the field NOT_MULTIPLE_SECTION_FLAG is not allowed
	IF p_usec_rec.not_multiple_section_flag <> c_usec_rec.not_multiple_section_flag THEN
	   fnd_message.set_name('IGS','IGS_PS_LGCY_US_MULTIPLE_FLAG');
	   fnd_msg_pub.add;
	   p_usec_rec.status := 'E';
	END IF;
      END IF;

      --Not Offered unit section should not be allowed to be updated
      IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(c_usec_rec.uoo_id) THEN
	fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
	fnd_msg_pub.add;
	p_usec_rec.status := 'E';
      END IF;

      --If that unit has been used in auditing then do not allow unchecking of auditable_ind
      IF p_usec_rec.auditable_ind='N' THEN
	OPEN cur_unit_audit(c_usec_rec.uoo_id);
	FETCH cur_unit_audit INTO rec_unit_audit;
	IF(cur_unit_audit%FOUND) THEN
	  fnd_message.set_name('IGS', 'IGS_PS_AUD_NO_CHK_USEC');
	  fnd_msg_pub.add;
	  p_usec_rec.status := 'E';
	END IF;
	CLOSE cur_unit_audit;

	IF p_usec_rec.audit_permission_ind ='Y'  THEN
	  fnd_message.set_name('IGS', 'IGS_PS_AUDIT_PERMISSION_EXIST');
	  fnd_msg_pub.add;
	  p_usec_rec.status := 'E';
	ELSE
	  --update of the field AUDIT_PERMISSION_IND is not allowed
	  IF p_usec_rec.audit_permission_ind <>c_usec_rec.audit_permission_ind THEN
	    fnd_message.set_name('IGS', 'IGS_PS_AUDIT_PERMISSION_EXIST');
	    fnd_msg_pub.add;
	    p_usec_rec.status := 'E';
	  END IF;
	END IF;

      END IF;

      IF igs_ps_usec_schedule.prgp_get_schd_status( c_usec_rec.uoo_id,NULL,v_message_name ) = TRUE THEN
	  IF v_message_name IS NULL THEN
	    v_message_name := 'IGS_PS_SCST_PROC';
	  END IF;
	  fnd_message.set_name( 'IGS', v_message_name);
	  fnd_msg_pub.add;
	  p_usec_rec.status := 'E';
      ELSIF c_usec_rec.location_cd <> p_usec_rec.location_cd THEN
	 IF igs_ps_usec_schedule.prgp_upd_usec_dtls( c_usec_rec.uoo_id,p_usec_rec.location_cd,Null,Null,Null,Null,
						     v_request_id,
						     v_message_name
						   ) = FALSE THEN

	    fnd_message.set_name( 'IGS', v_message_name);
	    fnd_msg_pub.add;
	    p_usec_rec.status := 'E';
	  END IF;
      END IF;

      --Validate unit section status transition
      IF  p_usec_rec.unit_section_status <> c_usec_rec.unit_section_status  THEN
	BEGIN
          igs_ps_unit_ofr_opt_pkg.check_status_transition( p_n_uoo_id        => c_usec_rec.uoo_id,
                                                           p_c_old_usec_sts  => c_usec_rec.unit_section_status,
                                                           p_c_new_usec_sts  => p_usec_rec.unit_section_status);
        EXCEPTION WHEN OTHERS THEN
	   p_usec_rec.status := 'E';
	END;

      END IF;


      --clearing Building code and room code when status is cancelled
      IF p_usec_rec.unit_section_status <> c_usec_rec.unit_section_status THEN
	IF p_usec_rec.unit_section_status = 'CANCELLED' THEN
	  IF (NVL(fnd_profile.value('IGS_PS_SCH_SOFT_NOT_INSTLD'),'N')) = 'N' THEN
	    IF p_usec_rec.status <> 'E' THEN
	      FOR rec_uso IN c_uso(c_usec_rec.uoo_id)   LOOP
		igs_ps_usec_occurs_pkg.update_row (
		       X_Mode                              => 'R',
		       X_RowId                             => rec_uso.rowid ,
		       X_unit_section_occurrence_id        => rec_uso.unit_section_occurrence_id,
		       X_uoo_id                            => rec_uso.uoo_id,
		       X_monday                            => rec_uso.monday,
		       X_tuesday                           => rec_uso.tuesday,
		       X_wednesday                         => rec_uso.wednesday,
		       X_thursday                          => rec_uso.thursday,
		       X_friday                            => rec_uso.friday,
		       X_saturday                          => rec_uso.saturday,
		       X_sunday                            => rec_uso.sunday,
		       X_start_time                        => rec_uso.start_time,
		       X_end_time                          => rec_uso.end_time,
		       X_building_code                     => NULL,  -- Clearing the building code
		       X_room_code                         => NULL,  -- Clearing the room code
		       X_schedule_status                   => rec_uso.schedule_status,
		       X_status_last_updated               => SYSDATE,
		       X_instructor_id                     => rec_uso.instructor_id,
		       X_attribute_category                => rec_uso.attribute_category,
		       X_attribute1                        => rec_uso.attribute1,
		       X_attribute2                        => rec_uso.attribute2,
		       X_attribute3                        => rec_uso.attribute3,
		       X_attribute4                        => rec_uso.attribute4,
		       X_attribute5                        => rec_uso.attribute5,
		       X_attribute6                        => rec_uso.attribute6,
		       X_attribute7                        => rec_uso.attribute7,
		       X_attribute8                        => rec_uso.attribute8,
		       X_attribute9                        => rec_uso.attribute9,
		       X_attribute10                       => rec_uso.attribute10,
		       X_attribute11                       => rec_uso.attribute11,
		       X_attribute12                       => rec_uso.attribute12,
		       X_attribute13                       => rec_uso.attribute13,
		       X_attribute14                       => rec_uso.attribute14,
		       X_attribute15                       => rec_uso.attribute15,
		       X_attribute16                       => rec_uso.attribute16,
		       X_attribute17                       => rec_uso.attribute17,
		       X_attribute18                       => rec_uso.attribute18,
		       X_attribute19                       => rec_uso.attribute19,
		       X_attribute20                       => rec_uso.attribute20,
		       X_error_text                        => rec_uso.error_text ,
		       X_start_date                        => rec_uso.start_date,
		       X_end_date                          => rec_uso.end_date,
		       X_to_be_announced                   => rec_uso.to_be_announced,
		       X_inst_notify_ind                   => rec_uso.inst_notify_ind,
		       X_notify_status                     => rec_uso.notify_status,
		       X_preferred_region_code             => rec_uso.preferred_region_code,
		       X_no_set_day_ind                    => rec_uso.no_set_day_ind,
		       X_preferred_building_code           => rec_uso.preferred_building_code,
		       X_preferred_room_code               => rec_uso.preferred_room_code,
		       X_dedicated_building_code           => rec_uso.dedicated_building_code,
		       X_dedicated_room_code               => rec_uso.dedicated_room_code,
		       x_cancel_flag                       => rec_uso.cancel_flag,
		       x_occurrence_identifier             => rec_uso.occurrence_identifier,
		       x_abort_flag                        => rec_uso.abort_flag
		    );

	      END LOOP;
            END IF;
	  ELSE
            OPEN user_check(g_n_user_id);
	    FETCH user_check INTO l_c_var;
	    IF user_check%FOUND THEN
	      p_conc_flag:= TRUE;
            ELSE
	      --Update the occurrence status
	      upd_usec_occurs_schd_status(c_usec_rec.uoo_id,'USER_CANCEL');
            END IF;
	    CLOSE user_check;

	  END IF; -- end if of checking whether scheduling software is installed or not profile checking.
	END IF;
      END IF;

    END IF;--End of  validations for update

  END validate_uoo;



  -- Validate Unit Section Credit Points Records before inserting them
  PROCEDURE validate_cps ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                           p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			   p_insert_update VARCHAR2) AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  23-NOV-2002
    Purpose        :  This procedure will validate records before inserting Unit Section Credit Points

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    29-AUG-2005     Bug # 4089179.Included the check for insert condition while recalculating Re-calculating the values in Worload lecture,
                                Laboratory and Other in Teaching Responsibilities
    smvk        17-Jun-2004     Bug # 3697443.Added variable increment into the validation for displaying the message IGS_PS_LGCY_CPS_NULL.
    sarakshi    10-Nov-2003     Enh#3116171, added business logic related to the newly introduced field BILLING_CREDIT_POINTS
    sarakshi    28-Jun-2003     Enh#2930935,modified cursor c_credits such that it no longer selects
                                enrolled and achievable credit points
  ********************************************************************************************** */
    CURSOR c_credit (cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
		     cp_ver_num igs_ps_unit_ver_all.version_number%TYPE) IS
    SELECT points_override_ind
    FROM   igs_ps_unit_ver_all
    WHERE  unit_cd = cp_unit_cd
    AND    version_number = cp_ver_num;

    CURSOR c_teach_resp(p_uoo_id NUMBER) IS
    SELECT rowid,iputr.*
    FROM   igs_ps_usec_tch_resp iputr
    WHERE  iputr.uoo_id = p_uoo_id
    AND    iputr.percentage_allocation IS NOT NULL
    AND    iputr.instructional_load_lab IS NULL
    AND    iputr.instructional_load_lecture IS NULL
    AND    iputr.instructional_load IS NULL;


    CURSOR c_usec_cp(cp_n_uoo_id NUMBER) IS
    SELECT *
    FROM igs_ps_usec_cps
    WHERE uoo_id = cp_n_uoo_id;

    c_usec_cp_rec c_usec_cp%ROWTYPE;
    l_new_lab  igs_ps_usec_tch_resp_v.instructional_load_lab%TYPE;
    l_new_lecture igs_ps_usec_tch_resp_v.instructional_load_lecture%TYPE;
    l_new_other igs_ps_usec_tch_resp_v.instructional_load%TYPE;

    l_c_override_ind igs_ps_unit_ver_all.points_override_ind%TYPE;
    l_c_message VARCHAR2(30);

  BEGIN
    OPEN c_credit ( p_usec_rec.unit_cd, p_usec_rec.version_number );
    FETCH c_credit INTO l_c_override_ind ;
    CLOSE c_credit;

    IF l_c_override_ind = 'Y' AND ( p_usec_rec.variable_increment IS NULL OR
                                      p_usec_rec.maximum_credit_points IS NULL OR
                                      p_usec_rec.minimum_credit_points IS NULL ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_LGCY_CPS_NULL' );
      fnd_msg_pub.add;
      p_usec_rec.status := 'E';
    END IF;

    --Billing credit Points can be provided only when auditable_ind is set to Y
    IF p_usec_rec.auditable_ind = 'N' AND p_usec_rec.billing_credit_points IS NOT NULL THEN
       igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_BILL_CRD_PTS_ERROR',NULL,NULL,FALSE);
       p_usec_rec.status :='E';
    END IF;

    IF NOT igs_ps_val_uv.crsp_val_uv_pnt_ovrd ( l_c_override_ind,
                                                p_usec_rec.variable_increment,
                                                p_usec_rec.minimum_credit_points,
                                                p_usec_rec.maximum_credit_points,
                                                p_usec_rec.enrolled_credit_points,
                                                p_usec_rec.achievable_credit_points,
                                                l_c_message,TRUE ) THEN
        p_usec_rec.status := 'E';
    END IF;

    OPEN c_usec_cp(p_n_uoo_id);
    FETCH c_usec_cp INTO c_usec_cp_rec;
    CLOSE c_usec_cp;
    IF (p_insert_update = 'U' AND
      ( NVL(p_usec_rec.work_load_other,-1) <> NVL(c_usec_cp_rec.work_load_other,-1) OR
       NVL(p_usec_rec.work_load_cp_lecture ,-1) <> NVL(c_usec_cp_rec.work_load_cp_lecture ,-1) OR
       NVL(p_usec_rec.work_load_cp_lab,-1) <> NVL(c_usec_cp_rec.work_load_cp_lab,-1))) OR p_insert_update = 'I' THEN
         -- Re-calculating the values in Worload lecture,Laboratory and Other in Teaching Responsibilities as these points are modified at Unit Section level

          FOR c_teach_resp_rec in c_teach_resp(p_n_uoo_id)
          LOOP
               --igs_ps_fac_credt_wrkload.calculate_teach_work_load(c_teach_resp_rec.uoo_id,c_teach_resp_rec.percentage_allocation,l_new_lab,l_new_lecture,l_new_other);
	       l_new_lecture:=((c_teach_resp_rec.percentage_allocation/100)* p_usec_rec.work_load_cp_lecture);
	       l_new_lab:=((c_teach_resp_rec.percentage_allocation/100)* p_usec_rec.work_load_cp_lab);
	       l_new_other:=((c_teach_resp_rec.percentage_allocation/100)* p_usec_rec.work_load_other);

	       igs_ps_usec_tch_resp_pkg.update_row (
                                                  x_mode                       => 'R',
                                                  x_rowid                      => c_teach_resp_rec.rowid,
                                                  x_unit_section_teach_resp_id => c_teach_resp_rec.unit_section_teach_resp_id,
                                                  x_instructor_id              => c_teach_resp_rec.instructor_id,
                                                  x_confirmed_flag             => c_teach_resp_rec.confirmed_flag ,
                                                  x_percentage_allocation      => c_teach_resp_rec.percentage_allocation,
                                                  x_instructional_load         => l_new_other ,
                                                  x_lead_instructor_flag       => c_teach_resp_rec.lead_instructor_flag,
                                                  x_uoo_id                     => c_teach_resp_rec.uoo_id,
                                                  x_instructional_load_lab     => l_new_lab,
                                                  x_instructional_load_lecture => l_new_lecture
                                                 );
          END LOOP;
    END IF;

  END validate_cps;

  -- Validate Unit Section Referece Records before inserting them
  PROCEDURE validate_ref ( p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                           p_n_subtitle_id OUT NOCOPY igs_ps_unit_subtitle.subtitle_id%TYPE,
			   p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			   p_insert_update VARCHAR2)
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  23-NOV-2002
    Purpose        :  This does legacy validations before inserting Unit Section Reference Records.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_subtitle ( cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
                        cp_ver_num igs_ps_unit_ver_all.version_number%TYPE) IS
    SELECT 1
    FROM   igs_ps_unit_subtitle
    WHERE  closed_ind = 'N'
    AND    approved_ind = 'Y'
    AND    unit_cd = cp_unit_cd
    AND    version_number = cp_ver_num;
    rec_subtitle c_subtitle%ROWTYPE;

    CURSOR c_subtitle_id  (
            cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
            cp_ver_num igs_ps_unit_ver_all.version_number%TYPE,
            cp_subtitle igs_ps_unit_subtitle.subtitle%TYPE,
            cp_approved_ind igs_ps_unit_subtitle.approved_ind%TYPE) IS
    SELECT subtitle_id
    FROM   igs_ps_unit_subtitle
    WHERE  closed_ind = 'N'
    AND    approved_ind = cp_approved_ind
    AND    unit_cd = cp_unit_cd
    AND    version_number = cp_ver_num
    AND    subtitle = cp_subtitle ;
    rec_subtitle_id c_subtitle_id%ROWTYPE;

    CURSOR c_unit_ver(cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
                    cp_ver_num igs_ps_unit_ver_all.version_number%TYPE) IS
    SELECT uv.title_override_ind,
           uv.subtitle_modifiable_flag
    FROM   igs_ps_unit_ver uv
    WHERE  uv.unit_cd = cp_unit_cd
    AND    uv.version_number = cp_ver_num;
    r_unit_ver c_unit_ver%ROWTYPE;

    CURSOR c_usec_ref(p_n_uoo_id NUMBER) IS
    SELECT *
    FROM igs_ps_usec_ref
    WHERE uoo_id = p_n_uoo_id;

    c_usec_ref_rec c_usec_ref%ROWTYPE;

    CURSOR c_subtitle_closed  (
          cp_unit_cd igs_ps_unit_ver_all.unit_cd%TYPE,
          cp_ver_num igs_ps_unit_ver_all.version_number%TYPE,
          cp_subtitle igs_ps_unit_subtitle.subtitle%TYPE ) IS
    SELECT 'X'
    FROM   igs_ps_unit_subtitle
    WHERE  closed_ind = 'Y'
    AND    unit_cd = cp_unit_cd
    AND    version_number = cp_ver_num
    AND    subtitle = cp_subtitle ;
    l_c_var VARCHAR2(1);

  BEGIN

    IF p_usec_rec.reference_subtitle IS NOT NULL THEN

      OPEN c_subtitle ( p_usec_rec.unit_cd, p_usec_rec.version_number );
      FETCH c_subtitle INTO rec_subtitle ;
      IF c_subtitle%FOUND THEN
	OPEN c_subtitle_id ( p_usec_rec.unit_cd, p_usec_rec.version_number, p_usec_rec.reference_subtitle, 'Y' );
	FETCH c_subtitle_id INTO rec_subtitle_id;
	IF c_subtitle_id%FOUND THEN
	  p_n_subtitle_id := rec_subtitle_id.subtitle_id;
	ELSE
	  fnd_message.set_name ( 'IGS', 'IGS_PS_INVALID_SUBTITLE' );
	  fnd_msg_pub.add;
	  p_usec_rec.status := 'E';
	  p_n_subtitle_id := NULL;
	END IF;
	CLOSE c_subtitle_id;
      ELSE
	-- Check if any Un-Approved subtitles exist with given subtitle
	OPEN c_subtitle_id ( p_usec_rec.unit_cd, p_usec_rec.version_number, p_usec_rec.reference_subtitle, 'N' );
	FETCH c_subtitle_id INTO rec_subtitle_id;

	IF c_subtitle_id%FOUND THEN
	  p_n_subtitle_id := rec_subtitle_id.subtitle_id;
	ELSE
	  --Added this condition as a part of bug#3748341
	  --If the passed subtitle is a closed one then it is an error condition , if it does not exists then insert it
	  OPEN c_subtitle_closed(p_usec_rec.unit_cd, p_usec_rec.version_number, p_usec_rec.reference_subtitle);
	  FETCH c_subtitle_closed INTO l_c_var;
	  IF c_subtitle_closed%NOTFOUND THEN
	    -- Subtitle is not null and there is no approved or un-approved subtitle exist
	    -- then insert the passed subtitle into table
	    INSERT INTO igs_ps_unit_subtitle
	    (subtitle_id,
	     unit_cd,
	     version_number,
	     subtitle,
	     approved_ind,
	     closed_ind,
	     created_by,
	     creation_date,
	     last_updated_by,
	     last_update_date,
	     last_update_login
	    )
	    VALUES
	    (igs_ps_unit_subtitle_s.NEXTVAL,
	     p_usec_rec.unit_cd,
	     p_usec_rec.version_number,
	     p_usec_rec.reference_subtitle,
	     'N',
	     'N',
	     g_n_user_id,
	     SYSDATE,
	     g_n_user_id,
	     SYSDATE,
	     g_n_login_id
	    )RETURNING subtitle_id INTO p_n_subtitle_id;
	  ELSE
	    fnd_message.set_name ( 'IGS', 'IGS_PS_INVALID_SUBTITLE' );
	    fnd_msg_pub.add;
	    p_usec_rec.status := 'E';
	    p_n_subtitle_id := NULL;
	  END IF;
	  CLOSE c_subtitle_closed;
	END IF;
	CLOSE c_subtitle_id;
      END IF;
      CLOSE c_subtitle;
    END IF;

    -- Validate DFF columns
    IF NOT igs_ad_imp_018.validate_desc_flex ( p_usec_rec.reference_attribute_category,
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
                                               p_usec_rec.reference_attribute18,
                                               p_usec_rec.reference_attribute20,
                                               'IGS_PS_USEC_REF_FLEX' ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_AD_INVALID_DESC_FLEX' );
      fnd_msg_pub.add;
      p_usec_rec.status := 'E';
    END IF;

    IF p_insert_update ='U' THEN

      OPEN c_unit_ver(p_usec_rec.unit_cd,p_usec_rec.version_number);
      FETCH c_unit_ver INTO r_unit_ver;
      CLOSE c_unit_ver;

      OPEN c_usec_ref(p_n_uoo_id);
      FETCH c_usec_ref INTO c_usec_ref_rec;
      CLOSE c_usec_ref;

      -- IF override Title is checked at Unit Level then only  update is allowed.
      IF r_unit_ver.title_override_ind = 'N' THEN
	--cannot  update TITLE log error message
	IF p_usec_rec.reference_title <> c_usec_ref_rec.title THEN
	  fnd_message.set_name( 'IGS', 'IGS_PS_CNT_UPD_TITLE');
	  p_usec_rec.status := 'E';
	  fnd_msg_pub.add;
	END IF;

      END IF;

      -- IF subtitle modifiable is checked at Unit Level then only update is allowed .
      IF r_unit_ver.subtitle_modifiable_flag = 'N' THEN
	  --cannot  update SUBTITLE log error message
	IF p_usec_rec.reference_subtitle <> c_usec_ref_rec.subtitle THEN
	  fnd_message.set_name( 'IGS', 'IGS_PS_CNT_UPD_SUBTITLE');
	  p_usec_rec.status := 'E';
	  fnd_msg_pub.add;
	END IF;
      END IF;
    END IF;
  END validate_ref;

  PROCEDURE validate_usec_grd_sch ( p_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type,
                                    p_n_uoo_id    IN NUMBER)
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  15-NOV-2002
    Purpose        :  This procedure will do validations before inserting records of Unit Section Grading Schema.
                      This is called from sub process of legacy import data, which inserts Unit Section GS records.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  l_c_message  VARCHAR2(30);

  BEGIN
    -- Check if grading schema type is 'UNIT' for a given grading schema.
    IF NOT validate_gs_type ( p_usec_gs_rec.grading_schema_code, p_usec_gs_rec.grd_schm_version_number ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_LGCY_INCORRECT_GS_TYPE' );
      fnd_msg_pub.add;
      p_usec_gs_rec.status := 'E';
    END IF;

    -- Check if unit status is inactive.
    IF NOT igs_ps_val_unit.crsp_val_iud_uv_dtl(p_usec_gs_rec.unit_cd,p_usec_gs_rec.version_number,l_c_message) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
      fnd_msg_pub.add;
      p_usec_gs_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_usec_gs_rec.status := 'E';
    END IF;

  END validate_usec_grd_sch;

  FUNCTION post_usec_grd_sch ( p_tab_usec_gs IN OUT NOCOPY igs_ps_generic_pub.usec_gs_tbl_type,
                               p_tab_uoo     IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  Sommukhe
    Date Created By:
    Purpose        :  This function will do validations after inserting records of Unit Section Grading Schema.
                      This will returns TRUE if all the validations pass and returns FALSE, if fails.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_usec_gs_count ( cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE ) IS
  SELECT COUNT(*) cnt
  FROM   igs_ps_usec_grd_schm
  WHERE  uoo_id = cp_uoo_id
  AND    default_flag = 'Y';
  rec_usec_gs_count c_usec_gs_count%ROWTYPE;

  CURSOR c_uoo_id (cp_usec_gs_rec IN OUT NOCOPY igs_ps_generic_pub.usec_gs_rec_type) IS
  SELECT uoo_id
  FROM   igs_ps_unit_ofr_opt_all a,igs_ca_inst_all b
  WHERE  a.unit_cd = cp_usec_gs_rec.unit_cd
  AND a.version_number = cp_usec_gs_rec.version_number
  AND a.cal_type = b.cal_type
  AND a.ci_sequence_number = b.sequence_number
  AND b.alternate_code=cp_usec_gs_rec.teach_cal_alternate_code
  AND a.location_cd =cp_usec_gs_rec.location_cd
  AND a.unit_class = cp_usec_gs_rec.unit_class;
  c_uoo_id_rec c_uoo_id%ROWTYPE;

  l_n_count_msg NUMBER(6);
  l_b_status    BOOLEAN;

  BEGIN
    l_b_status:= TRUE;
    -- Check if atleast and atmost one default flag is set to 'Y' for a given unit code and version number.
    FOR i IN 1 ..p_tab_uoo.LAST LOOP

    OPEN c_usec_gs_count (p_tab_uoo(i));
    FETCH c_usec_gs_count INTO rec_usec_gs_count;
    IF rec_usec_gs_count.cnt <> 1 THEN
      l_b_status:= FALSE;
      fnd_message.set_name ( 'IGS', 'IGS_PS_GRD_SCHM_CHCK' );
      fnd_msg_pub.add;
      l_n_count_msg := fnd_msg_pub.count_msg;
      FOR j in 1..p_tab_usec_gs.LAST LOOP
         OPEN c_uoo_id (p_tab_usec_gs(j));
	 FETCH c_uoo_id INTO c_uoo_id_rec;
         CLOSE c_uoo_id;
	IF p_tab_usec_gs.EXISTS(j) THEN
          IF p_tab_usec_gs(j).status = 'S' AND p_tab_uoo(i)= c_uoo_id_rec.uoo_id THEN
            p_tab_usec_gs(j).status := 'E';
            p_tab_usec_gs(j).msg_from := l_n_count_msg;
            p_tab_usec_gs(j).msg_to := l_n_count_msg;
          END IF;
        END IF;
      END LOOP;
    END IF;
    CLOSE c_usec_gs_count;
  END LOOP;

  RETURN   l_b_status;

  END post_usec_grd_sch;

  PROCEDURE validate_usec_occurs ( p_uso_rec IN OUT NOCOPY igs_ps_generic_pub.uso_rec_type,
                                   p_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                   p_d_start_date IN igs_ca_inst_all.start_dt%TYPE,
                                   p_d_end_date IN igs_ca_inst_all.end_dt%TYPE,
				   p_n_building_code IN NUMBER,
				   p_n_room_code IN NUMBER,
				   p_n_dedicated_building_code IN NUMBER,
				   p_n_dedicated_room_code IN NUMBER,
				   p_n_preferred_building_code IN NUMBER,
				   p_n_preferred_room_code IN NUMBER,
				   p_n_uso_id IN NUMBER,
				   p_insert IN VARCHAR2,
				   p_calling_context IN VARCHAR2,
				   p_notify_status OUT NOCOPY VARCHAR2,
				   p_schedule_status IN OUT NOCOPY VARCHAR2
				   ) AS

  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  20-NOV-2002
    Purpose        :  This procedure will do validations before inserting record of Unit Section Occurrence.
                      This is called from sub process of legacy import data, which inserts USO records.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    jbegum      3-June-2003     Enh Bug#2972950
                                For the PSP Scheduling Enhancements TD:
                                Added validations given in TD.
  ********************************************************************************************** */

  CURSOR c_usec_dates ( cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE ) IS
  SELECT unit_section_start_date start_date,
         unit_section_end_date end_date
  FROM igs_ps_unit_ofr_opt_all
  WHERE
    uoo_id = cp_uoo_id ;
  rec_usec_dates c_usec_dates%ROWTYPE;
  l_message_name fnd_new_messages.message_name%TYPE;
--
CURSOR c_room_id(cp_bld_id IN NUMBER, cp_rom_id IN NUMBER) IS
SELECT 'X'
FROM igs_ad_room
WHERE  building_id=cp_bld_id
AND room_id=cp_rom_id;
l_c_var VARCHAR2(1);



CURSOR c_ins(cp_uso_id IN NUMBER) IS
SELECT instructor_id  FROM igs_ps_uso_instrctrs
WHERE unit_section_occurrence_id = cp_uso_id;

CURSOR cur_occur(cp_uso_id IN NUMBER) IS
SELECT *
FROM igs_ps_usec_occurs_all
WHERE unit_section_occurrence_id = cp_uso_id;
l_cur_occur cur_occur%ROWTYPE;

    CURSOR c_shadow_num(l_unit_sec_occurrence_id IGS_PS_USEC_OCCURS.unit_section_occurrence_id%TYPE) IS
	SELECT count(*)
	FROM IGS_PS_SH_USEC_OCCURS
	WHERE unit_section_occurrence_id= l_unit_sec_occurrence_id;
    l_shadow_num number;
    l_new_monday IGS_PS_USEC_OCCURS_V.monday%TYPE := '1';
    l_new_tuesday IGS_PS_USEC_OCCURS_V.tuesday%TYPE := '1';
    l_new_wednesday IGS_PS_USEC_OCCURS_V.wednesday%TYPE := '1';
    l_new_thursday IGS_PS_USEC_OCCURS_V.thursday%TYPE:= '1';
    l_new_friday IGS_PS_USEC_OCCURS_V.friday%TYPE := '1';
    l_new_saturday IGS_PS_USEC_OCCURS_V.saturday%TYPE := '1';
    l_new_sunday IGS_PS_USEC_OCCURS_V.sunday%TYPE := '1';
    l_new_start_time VARCHAR2(50):='1' ;
    l_new_end_time VARCHAR2(50) :='1';
    l_new_building_code VARCHAR2(10):='1';
    l_new_room_code VARCHAR2(10):='1';

    l_old_monday IGS_PS_USEC_OCCURS_V.monday%TYPE := '1';
    l_old_tuesday IGS_PS_USEC_OCCURS_V.tuesday%TYPE := '1';
    l_old_wednesday IGS_PS_USEC_OCCURS_V.wednesday%TYPE := '1';
    l_old_thursday IGS_PS_USEC_OCCURS_V.thursday%TYPE := '1';
    l_old_friday IGS_PS_USEC_OCCURS_V.friday%TYPE := '1';
    l_old_saturday IGS_PS_USEC_OCCURS_V.saturday%TYPE := '1';
    l_old_sunday IGS_PS_USEC_OCCURS_V.sunday%TYPE := '1';
    l_old_start_time VARCHAR2(50):='1' ;
    l_old_end_time VARCHAR2(50) :='1';
    l_old_building_code VARCHAR2(10):='1';
    l_old_room_code VARCHAR2(10):='1';

    i binary_integer:=1;ctr number;
   l_new_instructor_id IGS_PS_SH_USEC_OCCURS.instructor_id%TYPE := NULL;
   l_old_instructor_id IGS_PS_SH_USEC_OCCURS.instructor_id%TYPE := NULL;
   l_new_usecsh_id IGS_PS_SH_USEC_OCCURS.usecsh_id%TYPE;
   l_new_unit_section_occur_id IGS_PS_USEC_OCCURS.unit_section_occurrence_id%TYPE;

    CURSOR c_shadow_rec(l_unit_sec_occurrence_id IGS_PS_USEC_OCCURS.unit_section_occurrence_id%TYPE) IS
	SELECT monday,tuesday, wednesday, thursday, friday, saturday,
		sunday, start_time, end_time, building_code, room_code, instructor_id
	FROM IGS_PS_SH_USEC_OCCURS
	WHERE unit_section_occurrence_id= l_unit_sec_occurrence_id;

    l_shd_monday IGS_PS_USEC_OCCURS_V.monday%TYPE:= '1';
    l_shd_tuesday IGS_PS_USEC_OCCURS_V.tuesday%TYPE:= '1';
    l_shd_wednesday IGS_PS_USEC_OCCURS_V.wednesday%TYPE:= '1';
    l_shd_thursday IGS_PS_USEC_OCCURS_V.thursday%TYPE:= '1';
    l_shd_friday IGS_PS_USEC_OCCURS_V.friday%TYPE:= '1';
    l_shd_saturday IGS_PS_USEC_OCCURS_V.saturday%TYPE:= '1';
    l_shd_sunday IGS_PS_USEC_OCCURS_V.sunday%TYPE:= '1';
    l_shd_start_time VARCHAR2(50):='1';
    l_shd_end_time VARCHAR2(50):='1';
    l_shd_building_code VARCHAR2(10):='1';
    l_shd_room_code VARCHAR2(10):='1';
    l_shd_instructor_id IGS_PS_SH_USEC_OCCURS_V.instructor_id%TYPE:= '1';
    lv_usec_occur_id IGS_PS_USEC_OCCURS.unit_section_occurrence_id%TYPE:= 1;
    CURSOR c_insv_unit_sec_occur_id(l_unit_occur_id IGS_PS_USEC_OCCURS.unit_section_occurrence_id%TYPE) IS
      SELECT instructor_id from IGS_PS_SH_USEC_OCCURS
      WHERE unit_section_occurrence_id =l_unit_occur_id;
    l_insv_instructor_id IGS_PS_SH_USEC_OCCURS.instructor_id%TYPE;

CURSOR cur_sch_int(cp_uso_id IN NUMBER) IS
SELECT uso.transaction_type,uso.schedule_status,uso.int_occurs_id,uso.int_usec_id,uso.tba_status, usec.int_pat_id
FROM igs_ps_sch_int_all uso, igs_ps_sch_usec_int_all usec
WHERE uso.unit_section_occurrence_id=cp_uso_id
AND   uso.int_usec_id = usec.int_usec_id
AND   uso.transaction_type IN ('REQUEST','UPDATE' ,'CANCEL')
AND   uso.abort_flag='N';
l_cur_sch_int cur_sch_int%ROWTYPE;

CURSOR cur_int_usec(cp_uoo_id IN NUMBER) IS
SELECT *
FROM  igs_ps_sch_usec_int_all
WHERE uoo_Id=cp_uoo_id
AND  abort_flag='N';
l_cur_int_usec  cur_int_usec%ROWTYPE;

l_transaction_type  igs_ps_sch_int_all.transaction_type%TYPE;

--
  BEGIN


    -- If one building code and room code is passed then other one should be passed.
    -- Otherwise, error out with proper message.

    IF p_n_room_code IS NOT NULL AND p_n_building_code IS NULL THEN
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', 'BUILDING_CODE', 'LEGACY_TOKENS', FALSE);
      p_uso_rec.status := 'E';
    END IF;


    IF p_n_dedicated_room_code IS NOT NULL AND p_n_dedicated_building_code IS NULL THEN
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('DEDICATED', 'LEGACY_TOKENS') || ' ' ||
                                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('BUILDING_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
      p_uso_rec.status := 'E';
    END IF;


    IF p_n_preferred_room_code IS NOT NULL AND p_n_preferred_building_code IS NULL THEN
      igs_ps_validate_lgcy_pkg.set_msg('IGS_EN_INV', igs_ps_validate_lgcy_pkg.get_lkup_meaning('PREFERRED', 'LEGACY_TOKENS') || ' ' ||
                                        igs_ps_validate_lgcy_pkg.get_lkup_meaning('BUILDING_CODE', 'LEGACY_TOKENS'), NULL, FALSE);
      p_uso_rec.status := 'E';
    END IF;


    -- Validate Start Date and End Date.
    OPEN c_usec_dates ( p_n_uoo_id );
    FETCH c_usec_dates INTO rec_usec_dates;

    -- Unit Section Occurrence (USO) start date should be greater than or equal to Unit Section (US) start date
    IF ( p_uso_rec.start_date IS NOT NULL ) THEN
      -- Check if it is less than start_date
      IF ( rec_usec_dates.start_date IS NOT NULL ) THEN
        IF ( p_uso_rec.start_date < rec_usec_dates.start_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_STDT_GE_US_STDT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      ELSE
        IF ( p_uso_rec.start_date < p_d_start_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_STDT_GE_TP_STDT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      -- Check if it is greater than end date
      IF ( rec_usec_dates.end_date IS NOT NULL ) THEN
        IF ( p_uso_rec.start_date > rec_usec_dates.end_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_ST_DT_UOO_END_DT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      ELSE
        IF ( p_uso_rec.start_date > p_d_end_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_ST_DT_TP_END_DT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      END IF;

    END IF;

    -- USO start date should be less than or equal to USO end date
    IF ( p_uso_rec.start_date > p_uso_rec.end_date ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PE_EDT_LT_SDT' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    IF ( p_uso_rec.end_date IS NOT NULL ) THEN
      -- Check it against start_date
      IF ( rec_usec_dates.start_date IS NOT NULL ) THEN
        IF ( p_uso_rec.end_date < rec_usec_dates.start_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_END_DT_UOO_ST_DT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      ELSE
        IF ( p_uso_rec.end_date < p_d_start_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_END_DT_TP_ST_DT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      END IF;

      -- Check it against end_date
      IF ( rec_usec_dates.start_date IS NOT NULL ) THEN
        IF ( p_uso_rec.end_date > rec_usec_dates.end_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_ENDT_LE_US_ENDT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      ELSE
        IF ( p_uso_rec.end_date > p_d_end_date ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_USO_ENDT_LE_TP_ENDT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
        END IF;
      END IF;

    END IF;
    CLOSE c_usec_dates;


    -- Validated start time and end time. USO start time should be less than USO end time.
    -- Compare only time part of date
    IF ( to_char(p_uso_rec.start_time,'HH24MI') > to_char(p_uso_rec.end_time,'HH24MI') ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_GE_ST_TIME_LT_END_TIME' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    -- If to_be_announced is 'N' then atleast one of the day must be checked.
    IF (p_uso_rec.to_be_announced = 'N' AND p_uso_rec.no_set_day_ind = 'N' AND
        p_uso_rec.monday    ='N' AND
        p_uso_rec.tuesday   ='N' AND
        p_uso_rec.wednesday ='N' AND
        p_uso_rec.thursday  ='N' AND
        p_uso_rec.friday    ='N' AND
        p_uso_rec.saturday  ='N' AND
        p_uso_rec.sunday    ='N' ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ATLEAST_ONE_DAY_CHECK' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    -- IF to_be_announced is 'Y' then no day should have 'Y'
    IF (p_uso_rec.to_be_announced = 'Y' AND
        ( p_uso_rec.monday    ='Y' OR
          p_uso_rec.tuesday   ='Y' OR
          p_uso_rec.wednesday ='Y' OR
          p_uso_rec.thursday  ='Y' OR
          p_uso_rec.friday    ='Y' OR
          p_uso_rec.saturday  ='Y' OR
          p_uso_rec.sunday    ='Y' OR
          p_uso_rec.start_time  IS NOT NULL OR
          p_uso_rec.end_time  IS NOT NULL)
        ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_LGCY_TBA_WITH_DAYS' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    --Start date and end date should be provided for normal unit section occurrences
    IF ( p_uso_rec.monday  ='Y' OR
          p_uso_rec.tuesday   ='Y' OR
          p_uso_rec.wednesday ='Y' OR
          p_uso_rec.thursday  ='Y' OR
          p_uso_rec.friday    ='Y' OR
          p_uso_rec.saturday  ='Y' OR
          p_uso_rec.sunday    ='Y' ) AND
          (p_uso_rec.start_date  IS  NULL OR  p_uso_rec.end_date  IS  NULL) AND
           p_uso_rec.no_set_day_ind='N'
         THEN
      fnd_message.set_name ( 'IGS', 'IGS_AS_BOTH_STDT_ENDDT_ENERED' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    -- Cannot enter Preferred Building/Room if Dedicated Building/Room is entered.
    IF ( p_n_dedicated_building_code IS NOT NULL AND
         ( p_n_preferred_room_code IS NOT NULL OR
           p_n_preferred_building_code IS NOT NULL )
       ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_ENTER_PREF_DEDICATED' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    -- Can enter either Other Building Options (Preferred or Dedicated Building/Room) or Scheduled Building
    IF ( p_n_building_code IS NOT NULL AND
         ( p_n_dedicated_building_code IS NOT NULL OR
           p_n_preferred_building_code IS NOT NULL OR
           p_n_dedicated_room_code IS NOT NULL OR
           p_n_preferred_room_code IS NOT NULL
         )
       ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_SCHD_OR_OTHER' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    -- Validate DFF columns
    IF NOT igs_ad_imp_018.validate_desc_flex ( p_uso_rec.attribute_category,
                                               p_uso_rec.attribute1,
                                               p_uso_rec.attribute2,
                                               p_uso_rec.attribute3,
                                               p_uso_rec.attribute4,
                                               p_uso_rec.attribute5,
                                               p_uso_rec.attribute6,
                                               p_uso_rec.attribute7,
                                               p_uso_rec.attribute8,
                                               p_uso_rec.attribute9,
                                               p_uso_rec.attribute10,
                                               p_uso_rec.attribute11,
                                               p_uso_rec.attribute12,
                                               p_uso_rec.attribute13,
                                               p_uso_rec.attribute14,
                                               p_uso_rec.attribute15,
                                               p_uso_rec.attribute16,
                                               p_uso_rec.attribute17,
                                               p_uso_rec.attribute18,
                                               p_uso_rec.attribute18,
                                               p_uso_rec.attribute20,
                                               'IGS_PS_UNITSEC_OCCUR' ) THEN
      fnd_message.set_name ( 'IGS', 'IGS_AD_INVALID_DESC_FLEX' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;


    -- Following validation added as part of enh bug#2972950 for the PSP Scheduling Enhancements
    --  Unit Section Occurrence should not have both the No Set Day Indicator and To Be Announced Indicator
    -- set to 'Y'.

    IF p_uso_rec.no_set_day_ind = 'Y' AND
       p_uso_rec.to_be_announced = 'Y' THEN

         fnd_message.set_name ( 'IGS', 'IGS_PS_NSD_OR_TBA' );
         fnd_msg_pub.add;
         p_uso_rec.status := 'E';

    END IF;

    -- Following validation added as part of enh bug#2972950 for the PSP Scheduling Enhancements
    --  User can enter either preferred region code or other scheduling options
    -- (ie. preferred or dedicated or scheduled building/room)

    IF p_uso_rec.preferred_region_code IS NOT NULL THEN
       IF p_n_building_code IS NOT NULL OR
          p_n_room_code IS NOT NULL OR
          p_n_dedicated_building_code IS NOT NULL OR
          p_n_dedicated_room_code IS NOT NULL OR
          p_n_preferred_building_code IS NOT NULL OR
          p_n_preferred_room_code IS NOT NULL THEN

            fnd_message.set_name ( 'IGS', 'IGS_PS_PRF_REG_BLD_ROM_EXIST' );
            fnd_msg_pub.add;
            p_uso_rec.status := 'E';

       END IF;
    END IF;

----

    --Check if the unit is INACTIVE, then do not allow to insert/update
    IF igs_ps_val_unit.crsp_val_iud_uv_dtl(p_uso_rec.unit_cd, p_uso_rec.version_number,l_message_name)=FALSE THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_NOCHG_UNITVER_DETAILS' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
    END IF;

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_uso_rec.status := 'E';
    END IF;

    -- Room should belong to a valid building
    IF p_n_building_code IS NOT NULL AND p_n_room_code IS NOT NULL THEN
	OPEN c_room_id ( p_n_building_code, p_n_room_code );
	FETCH c_room_id INTO l_c_var;
	IF ( c_room_id%NOTFOUND ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_ROOM_INV_FOR_BLD' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
	END IF;
	CLOSE c_room_id;
    END IF;

    -- Dedicated Room should belong to a valid building
    IF p_n_dedicated_building_code IS NOT NULL AND p_n_dedicated_room_code IS NOT NULL THEN
	OPEN c_room_id ( p_n_dedicated_building_code, p_n_dedicated_room_code );
	FETCH c_room_id INTO l_c_var;
	IF ( c_room_id%NOTFOUND ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_D_ROOM_INV_FOR_BLD' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
	END IF;
	CLOSE c_room_id;
    END IF;

    -- Preferred Room should belong to a valid building
    IF p_n_preferred_building_code IS NOT NULL AND p_n_preferred_room_code IS NOT NULL THEN
	OPEN c_room_id ( p_n_preferred_building_code, p_n_preferred_room_code );
	FETCH c_room_id INTO l_c_var;
	IF ( c_room_id%NOTFOUND ) THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_P_ROOM_INV_FOR_BLD' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
	END IF;
	CLOSE c_room_id;
    END IF;

    --If time is provided then days are mandatory
    IF p_uso_rec.start_time IS NOT NULL OR  p_uso_rec.end_time IS NOT NULL THEN
      IF p_uso_rec.monday = 'N' AND p_uso_rec.tuesday = 'N' AND p_uso_rec.wednesday = 'N' AND
	 p_uso_rec.thursday = 'N' AND p_uso_rec.friday = 'N' AND p_uso_rec.saturday = 'N' AND
	 p_uso_rec.sunday = 'N' THEN

          fnd_message.set_name ( 'IGS', 'IGS_PS_DAYS_REQD_TIME_THERE' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
      END IF;
    END IF;

    IF p_insert = 'U' THEN

     OPEN cur_occur(p_n_uso_id);
     FETCH cur_occur INTO l_cur_occur;
     CLOSE cur_occur;

     --If schedule status is SCHEDULED and TBA is Y then it is error condition
     IF p_uso_rec.to_be_announced = 'Y' AND l_cur_occur.schedule_status='SCHEDULED' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_SCHD_CANT_CHANGE_TBA' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
     END IF;

     --If schedule status is SCHEDULED and No_set_day is Y then it is error condition
     IF p_uso_rec.no_set_day_ind = 'Y' AND l_cur_occur.schedule_status='SCHEDULED' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_CANT_NSD_USO' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
     END IF;


     --Cannot import scheduling information for already scheduled occurrence
     IF (p_n_building_code IS NOT NULL AND p_n_building_code <> l_cur_occur.building_code OR
         p_n_room_code IS NOT NULL AND p_n_room_code <> l_cur_occur.room_code ) AND l_cur_occur.schedule_status='SCHEDULED' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_SCH_INFO_NOT_IMPORT' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
     END IF;

     --Cannot update occurrence for in progress occurrence when the calling context is not 'S'-scheduling
     IF  l_cur_occur.schedule_status='PROCESSING' AND p_calling_context <> 'S' THEN
          fnd_message.set_name ( 'IGS', 'IGS_PS_UPD_IN_PRG_OCR' );
          fnd_msg_pub.add;
          p_uso_rec.status := 'E';
     END IF;

      --If TBA is N then need to check if there is any instructors for the occurrences having time conflict, if yes then warning
      IF p_uso_rec.to_be_announced = 'N' THEN
        FOR c_ins_rec IN c_ins(p_n_uso_id) LOOP
           IF igs_ps_rlovr_fac_tsk.crsp_instrct_time_conflct (
	            p_person_id=>c_ins_rec.instructor_id,
		    p_unit_section_occurrence_id=>p_n_uso_id,
		    p_monday=>p_uso_rec.monday,
		    p_tuesday=>p_uso_rec.tuesday,
		    p_wednesday=>p_uso_rec.wednesday,
		    p_thursday=>p_uso_rec.thursday,
		    p_friday=>p_uso_rec.friday,
		    p_saturday=>p_uso_rec.saturday,
		    p_sunday=>p_uso_rec.sunday,
		    p_start_time=>p_uso_rec.start_time,
		    p_end_time=>p_uso_rec.end_time,
		    p_start_date=>p_uso_rec.start_date,
		    p_end_date=>p_uso_rec.end_date,
		    p_calling_module=>'FORM',
		    p_message_name => l_message_name)= FALSE THEN

		fnd_message.set_name ( 'IGS', l_message_name );
		fnd_msg_pub.add;
		p_uso_rec.status := 'W';
                EXIT;
           END IF;
	END LOOP;
      END IF;


     IF   p_calling_context = 'S' THEN

       OPEN cur_sch_int(p_n_uso_id);
       FETCH cur_sch_int INTO l_cur_sch_int;
       IF cur_sch_int%FOUND THEN

         -- TBA occurrences when imported should have building/days/dates

         IF (p_uso_rec.monday='N' AND  p_uso_rec.tuesday='N' AND
	   p_uso_rec.wednesday='N' AND  p_uso_rec.thursday='N' AND
	   p_uso_rec.friday='N' AND  p_uso_rec.saturday='N' AND
	   p_uso_rec.sunday='N') OR  p_uso_rec.start_date IS NULL OR p_uso_rec.end_date IS NULL OR
	   p_n_building_code IS NULL THEN

	   IF l_cur_sch_int.tba_status='Y' THEN
	     fnd_message.set_name ( 'IGS', 'IGS_PS_USO_TBA_STATUS' );
	     fnd_msg_pub.add;
 	     p_uso_rec.status := 'E';
           ELSIF l_cur_sch_int.transaction_type IN ('REQUEST','UPDATE') THEN
	     --For normal occurrences shoud have
             fnd_message.set_name ( 'IGS', 'IGS_PS_VALUES_NULL' );
             fnd_msg_pub.add;
 	     p_uso_rec.status := 'E';
           END IF;
	 END IF;

	 IF l_cur_sch_int.transaction_type = 'CANCEL' THEN
           p_schedule_status := 'CANCELLED' ;
	 END IF;

         --if the record exists in the interface table and TRANSACTION_TYPE as either 'REQUEST' / 'UPDATE' then BUILDING_CODE is must
	 IF l_cur_sch_int.transaction_type IN ('REQUEST','UPDATE')  AND p_n_building_code IS NULL THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_SCH_BLDIS_MUST' );
	    fnd_msg_pub.add;
	    p_uso_rec.status := 'E';
         END IF;
         --if the record exists in the interface table and TRANSACTION_TYPE = 'CANCEL' then BUILDING_CODE must be NULL
	 IF l_cur_sch_int.transaction_type IN ('CANCEL')  AND p_n_building_code IS NOT NULL THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_SCH_BLDIS_NOT' );
	    fnd_msg_pub.add;
	    p_uso_rec.status := 'E';
         END IF;

         --Update the interface record transaction type and schedule status
	 IF p_uso_rec.status = 'S' THEN
            UPDATE igs_ps_sch_int_all set transaction_type='COMPLETE',schedule_status=NVL(p_schedule_status,schedule_status),import_done_flag='Y' WHERE int_occurs_id = l_cur_sch_int.int_occurs_id;
            UPDATE igs_ps_sch_usec_int_all set import_done_flag='Y' WHERE int_usec_id = l_cur_sch_int.int_usec_id;
            UPDATE igs_ps_sch_pat_int set import_done_flag='Y' WHERE int_pat_id = l_cur_sch_int.int_pat_id;
	 END IF;

       END IF;
       CLOSE cur_sch_int;

     ELSE
       --If the caling context is L/G then set the schedule_satus to USER_UPDATE if any of the column value is getting modified
       IF (l_cur_occur.monday <> p_uso_rec.monday OR
	  l_cur_occur.tuesday <> p_uso_rec.tuesday OR
	  l_cur_occur.wednesday <> p_uso_rec.wednesday OR
	  l_cur_occur.thursday <> p_uso_rec.thursday OR
	  l_cur_occur.friday <> p_uso_rec.friday OR
	  l_cur_occur.saturday <> p_uso_rec.saturday OR
	  l_cur_occur.sunday <> p_uso_rec.sunday OR
	  NVL(l_cur_occur.building_code,-999) <> NVL(p_n_building_code,-999) OR
	  NVL(l_cur_occur.room_code,-999) <> NVL(p_n_room_code,-999) OR
	  NVL(l_cur_occur.start_date,TRUNC(SYSDATE)) <> NVL(p_uso_rec.start_date,TRUNC(SYSDATE)) OR
	  NVL(l_cur_occur.end_date,TRUNC(SYSDATE)) <> NVL(p_uso_rec.end_date,TRUNC(SYSDATE)) OR
	  NVL(l_cur_occur.start_time,TRUNC(SYSDATE)) <> NVL(p_uso_rec.start_time,TRUNC(SYSDATE)) OR
	  NVL(l_cur_occur.end_time,TRUNC(SYSDATE)) <> NVL(p_uso_rec.end_time,TRUNC(SYSDATE))) AND
	  p_uso_rec.no_set_day_ind = 'N' AND
	  p_uso_rec.to_be_announced = 'N' AND
	  l_cur_occur.schedule_status IS NOT NULL THEN

          p_schedule_status := 'USER_UPDATE';
       END IF;

     END IF;


     --If any of the days/time/scheduled building/schedule room is changed the set the notify_status to 'TRIGGER' and
     --insert/updatet the shadow table

     IF l_cur_occur.monday <> p_uso_rec.monday OR
	l_cur_occur.tuesday <> p_uso_rec.tuesday OR
	l_cur_occur.wednesday <> p_uso_rec.wednesday OR
	l_cur_occur.thursday <> p_uso_rec.thursday OR
	l_cur_occur.friday <> p_uso_rec.friday OR
	l_cur_occur.saturday <> p_uso_rec.saturday OR
	l_cur_occur.sunday <> p_uso_rec.sunday OR
	NVL(l_cur_occur.building_code,-999) <> NVL(p_n_building_code,-999) OR
	NVL(l_cur_occur.room_code,-999) <> NVL(p_n_room_code,-999) OR
	NVL(l_cur_occur.start_time,TRUNC(SYSDATE)) <> NVL(p_uso_rec.start_time,TRUNC(SYSDATE)) OR
	NVL(l_cur_occur.end_time,TRUNC(SYSDATE)) <> NVL(p_uso_rec.end_time,TRUNC(SYSDATE)) THEN

	p_notify_status:='TRIGGER';

	OPEN c_shadow_num(p_n_uso_id);
        FETCH c_shadow_num INTO l_shadow_num;
        IF c_shadow_num%NOTFOUND THEN
  	  l_shadow_num :=0;
        END IF;
        CLOSE c_shadow_num;

	l_old_monday := l_cur_occur.monday;
	l_old_tuesday := l_cur_occur.tuesday;
	l_old_wednesday := l_cur_occur.wednesday;
	l_old_thursday := l_cur_occur.thursday;
	l_old_friday := l_cur_occur.friday;
	l_old_saturday := l_cur_occur.saturday;
	l_old_sunday := l_cur_occur.sunday;
	l_old_start_time := l_cur_occur.start_time;
	l_old_end_time := l_cur_occur.end_time;
	l_old_building_code := l_cur_occur.building_code;
	l_old_room_code := l_cur_occur.room_code;


        IF l_shadow_num <1 THEN

	  IF NVL(l_old_monday,'X') <> NVL(p_uso_rec.monday,'X') THEN
	    l_new_monday:= l_old_monday;
	  ELSE
	    l_new_monday:=NULL;
	  END IF;
	  IF NVL(l_old_tuesday,'X') <> NVL(p_uso_rec.tuesday,'X') THEN
	    l_new_tuesday:= l_old_tuesday;
	  ELSE
	    l_new_tuesday:=NULL;
	  END IF;
	  IF NVL(l_old_wednesday,'X') <> NVL(p_uso_rec.wednesday,'X') THEN
	    l_new_wednesday:= l_old_wednesday;
	  ELSE
	    l_new_wednesday:=NULL;
	  END IF;
	  IF NVL(l_old_thursday,'X') <> NVL(p_uso_rec.thursday,'X') THEN
	    l_new_thursday:= l_old_thursday;
	  ELSE
	    l_new_thursday:=NULL;
	  END IF;
	  IF NVL(l_old_friday,'X') <> NVL(p_uso_rec.friday,'X') THEN
	    l_new_friday:= l_old_friday;
	  ELSE
	    l_new_friday := NULL;
	  END IF;
	  IF NVL(l_old_saturday,'X') <> NVL(p_uso_rec.saturday,'X') THEN
	    l_new_saturday:= l_old_saturday;
	  ELSE
	    l_new_saturday := NULL;
	  END IF;
	  IF NVL(l_old_sunday,'X') <> NVL(p_uso_rec.sunday,'X') THEN
	    l_new_sunday:= l_old_sunday;
	  ELSE
	    l_new_sunday := NULL;
	  END IF;
	  IF NVL(l_old_start_time,'X') <> NVL(TO_CHAR(p_uso_rec.Start_Time,'DD-MON-YYYY HH24:MI:SS'),'X') THEN
	    l_new_start_time:= l_old_start_time;
	  ELSE
	    l_new_start_time := NULL;
	  END IF;
	  IF NVL(l_old_end_time,'X') <> NVL(TO_CHAR(p_uso_rec.End_Time,'DD-MON-YYYY HH24:MI:SS'),'X')  THEN
	    l_new_end_time:= l_old_end_time;
	  ELSE
	    l_new_end_time := NULL;
	  END IF;
	  IF NVL(l_old_building_code,'X') <> NVL(p_uso_rec.building_code,'X') THEN
	    l_new_building_code:= l_old_building_code;
	  ELSE
	    l_new_building_code := NULL;
	  END IF;
	  IF NVL(l_old_room_code,'X') <> NVL(p_uso_rec.room_code,'X') THEN
	    l_new_room_code:= l_old_room_code;
	  ELSE
	    l_new_room_code := NULL;
	  END IF;

	  l_new_instructor_id := NULL;


	  SELECT  IGS_PS_SH_USEC_OCCURS_S.NEXTVAL INTO l_new_usecsh_id FROM dual;
	  l_new_unit_section_occur_id :=p_n_uso_id;
	  INSERT INTO IGS_PS_SH_USEC_OCCURS(USECSH_ID,
		  UNIT_SECTION_OCCURRENCE_ID,
		  MONDAY,
		  TUESDAY,
		  WEDNESDAY,
		  THURSDAY,
		  FRIDAY,
		  SATURDAY,
		  SUNDAY,
		  ROOM_CODE,
		  BUILDING_CODE,
		  START_TIME,
		  END_TIME,
		  INSTRUCTOR_ID,
		  CREATED_BY,
		  CREATION_DATE,
		  LAST_UPDATED_BY,
		  LAST_UPDATE_DATE,
		  LAST_UPDATE_LOGIN  )
	  VALUES (
		  l_new_USECSH_ID,
		  l_new_unit_section_occur_id,
		  l_new_MONDAY,
		  l_new_TUESDAY,
		  l_new_WEDNESDAY,
		  l_new_THURSDAY,
		  l_new_FRIDAY,
		  l_new_SATURDAY,
		  l_new_SUNDAY,
		  to_number(l_new_ROOM_CODE),
		  to_number(l_new_BUILDING_CODE),
		  fnd_date.canonical_to_date(fnd_date.string_to_canonical(l_new_START_TIME,'DD-MON-YYYY HH24:MI:SS')),
		  fnd_date.canonical_to_date(fnd_date.string_to_canonical(l_new_END_TIME,'DD-MON-YYYY HH24:MI:SS')),
		  l_new_INSTRUCTOR_ID,
		  g_n_user_id,
		  SYSDATE,
		  g_n_user_id,
		  SYSDATE,
		  g_n_login_id);

	ELSE

	  OPEN c_shadow_rec(p_n_uso_id);
	  FETCH c_shadow_rec INTO l_shd_monday, l_shd_tuesday, l_shd_wednesday, l_shd_thursday, l_shd_friday,
			       l_shd_saturday,l_shd_sunday, l_shd_start_time, l_shd_end_time,
			       l_shd_building_code, l_shd_room_code, l_shd_instructor_id;
	  IF c_shadow_rec%NOTFOUND THEN
	    l_shd_monday := NULL;
	    l_shd_tuesday := NULL;
	    l_shd_wednesday := NULL;
	    l_shd_thursday := NULL;
	    l_shd_friday := NULL;
	    l_shd_saturday := NULL;
	    l_shd_sunday := NULL;
	    l_shd_start_time := NULL;
	    l_shd_end_time := NULL;
	    l_shd_building_code := NULL;
	    l_shd_room_code := NULL;
	    l_shd_instructor_id := NULL;
	  END IF;

	  IF NVL(l_old_monday,'X') <> NVL(p_uso_rec.monday,'X') AND l_shd_monday IS NULL THEN
	    l_new_monday := l_old_monday;
	  ELSIF NVL(l_old_monday,'X') <> NVL(p_uso_rec.monday,'X') AND l_shd_monday IS NOT NULL THEN
	    l_new_monday := l_shd_monday;
	  ELSIF NVL(l_old_monday,'X') = NVL(p_uso_rec.monday,'X') THEN
	    l_new_monday := l_shd_monday;
	  END IF;

	  IF NVL(l_old_tuesday,'X') <> NVL(p_uso_rec.tuesday,'X') AND l_shd_tuesday IS NULL THEN
	    l_new_tuesday := l_old_tuesday;
	  ELSIF NVL(l_old_tuesday,'X') <> NVL(p_uso_rec.tuesday,'X') AND l_shd_tuesday IS NOT NULL THEN
	    l_new_tuesday := l_shd_tuesday;
	  ELSIF NVL(l_old_tuesday,'X') = NVL(p_uso_rec.tuesday,'X') THEN
	    l_new_tuesday := l_shd_tuesday;
	  END IF;

	  IF NVL(l_old_wednesday,'X') <> NVL(p_uso_rec.wednesday,'X') AND l_shd_wednesday IS NULL THEN
	    l_new_wednesday := l_old_wednesday;
	  ELSIF NVL(l_old_wednesday,'X') <> NVL(p_uso_rec.wednesday,'X') AND l_shd_wednesday IS NOT NULL THEN
	    l_new_wednesday := l_shd_wednesday;
	  ELSIF NVL(l_old_wednesday,'X') = NVL(p_uso_rec.wednesday,'X') THEN
	    l_new_wednesday := l_shd_wednesday;
	  END IF;

	  IF NVL(l_old_thursday,'X') <> NVL(p_uso_rec.thursday,'X') AND l_shd_thursday IS NULL THEN
	    l_new_thursday := l_old_thursday;
	  ELSIF NVL(l_old_thursday,'X') <> NVL(p_uso_rec.thursday,'X') AND l_shd_thursday IS NOT NULL THEN
	    l_new_thursday := l_shd_thursday;
	  ELSIF NVL(l_old_thursday,'X') = NVL(p_uso_rec.thursday,'X') THEN
	    l_new_thursday := l_shd_thursday;
	  END IF;

	  IF NVL(l_old_friday,'X') <> NVL(p_uso_rec.friday,'X') AND l_shd_friday IS NULL THEN
	    l_new_friday := l_old_friday;
	  ELSIF NVL(l_old_friday,'X') <> NVL(p_uso_rec.friday,'X') AND l_shd_friday IS NOT NULL THEN
	    l_new_friday := l_shd_friday;
	  ELSIF NVL(l_old_friday,'X') = NVL(p_uso_rec.friday,'X') THEN
	    l_new_friday := l_shd_friday;
	  END IF;

	  IF NVL(l_old_saturday,'X') <> NVL(p_uso_rec.saturday,'X') AND l_shd_saturday IS NULL THEN
	    l_new_saturday := l_old_saturday;
	  ELSIF NVL(l_old_saturday,'X') <> NVL(p_uso_rec.saturday,'X') AND l_shd_saturday IS NOT NULL THEN
	    l_new_saturday := l_shd_saturday;
	  ELSIF NVL(l_old_saturday,'X') = NVL(p_uso_rec.saturday,'X') THEN
	    l_new_saturday := l_shd_saturday;
	  END IF;

	  IF NVL(l_old_sunday,'X') <> NVL(p_uso_rec.sunday,'X') AND l_shd_sunday IS NULL THEN
	    l_new_sunday := l_old_sunday;
	  ELSIF NVL(l_old_sunday,'X') <> NVL(p_uso_rec.sunday,'X') AND l_shd_sunday IS NOT NULL THEN
	    l_new_sunday := l_shd_sunday;
	  ELSIF NVL(l_old_sunday,'X') = NVL(p_uso_rec.sunday,'X') THEN
	    l_new_sunday := l_shd_sunday;
	  END IF;

	  IF NVL(l_old_start_time,'X') <> NVL(TO_CHAR(p_uso_rec.Start_Time,'DD-MON-YYYY HH24:MI:SS'),'X') AND l_shd_start_time IS NULL THEN
	    l_new_start_time := l_old_start_time;
	  ELSIF NVL(l_old_start_time,'X') <> NVL(TO_CHAR(p_uso_rec.Start_Time,'DD-MON-YYYY HH24:MI:SS'),'X') AND l_shd_start_time IS NOT NULL THEN
	    l_new_start_time := l_shd_start_time;
	  ELSIF NVL(l_old_start_time,'X') = NVL(TO_CHAR(p_uso_rec.Start_Time,'DD-MON-YYYY HH24:MI:SS'),'X') THEN
	    l_new_start_time := l_shd_start_time;
	  END IF;

	  IF NVL(l_old_end_time,'X') <> NVL(TO_CHAR(p_uso_rec.end_Time,'DD-MON-YYYY HH24:MI:SS'),'X') AND l_shd_end_time IS NULL THEN
	    l_new_end_time := l_old_end_time;
	  ELSIF NVL(l_old_end_time,'X') <> NVL(TO_CHAR(p_uso_rec.end_Time,'DD-MON-YYYY HH24:MI:SS'),'X') AND l_shd_end_time IS NOT NULL THEN
	    l_new_end_time := l_shd_end_time;
	  ELSIF NVL(l_old_end_time,'X') = NVL(TO_CHAR(p_uso_rec.end_Time,'DD-MON-YYYY HH24:MI:SS'),'X') THEN
	    l_new_end_time := l_shd_end_time;
	  END IF;

	  IF NVL(l_old_building_code,'X') <> NVL(p_uso_rec.building_code,'X') AND l_shd_building_code IS NULL THEN
	    l_new_building_code := l_old_building_code;
	  ELSIF NVL(l_old_building_code,'X') <> NVL(p_uso_rec.building_code,'X') AND l_shd_building_code IS NOT NULL THEN
	    l_new_building_code := l_shd_building_code;
	  ELSIF NVL(l_old_building_code,'X') = NVL(p_uso_rec.building_code,'X') THEN
	    l_new_building_code := l_shd_building_code;
	  END IF;

	  IF NVL(l_old_room_code,'X') <> NVL(p_uso_rec.room_code,'X') AND l_shd_room_code IS NULL THEN
	    l_new_room_code := l_old_room_code;
	  ELSIF NVL(l_old_room_code,'X') <> NVL(p_uso_rec.room_code,'X') AND l_shd_room_code IS NOT NULL THEN
	    l_new_room_code := l_shd_room_code;
	  ELSIF NVL(l_old_room_code,'X') = NVL(p_uso_rec.room_code,'X') THEN
	    l_new_room_code := l_shd_room_code;
	  END IF;

	  OPEN c_insv_unit_sec_occur_id(p_n_uso_id);
	  FETCH c_insv_unit_sec_occur_id INTO  l_insv_instructor_id;
	  IF c_insv_unit_sec_occur_id%NOTFOUND THEN
	    NULL;
	  END IF;

	  l_new_instructor_id := l_insv_instructor_id;

	  IF  NVL(l_shd_monday,'X') <>  NVL(l_new_monday,'X') OR
	      NVL(l_shd_tuesday,'X') <> NVL(l_new_tuesday,'X') OR
	      NVL(l_shd_wednesday,'X') <> NVL(l_new_wednesday,'X') OR
	      NVL(l_shd_thursday,'X')  <> NVL(l_new_thursday,'X') OR
	      NVL(l_shd_friday,'X')  <> NVL(l_new_friday,'X') OR
	      NVL(l_shd_saturday,'X')  <> NVL(l_new_saturday,'X') OR
	      NVL(l_shd_sunday ,'X') <> NVL(l_new_sunday,'X') OR
	      NVL(l_shd_start_time ,'X')<> NVL(l_new_start_time,'X') OR
	      NVL(l_shd_end_time,'X')<> NVL(l_new_end_time,'X') OR
	      NVL(l_shd_building_code ,'X')<> NVL(l_new_building_code,'X') OR
	      NVL(l_shd_room_code,'X')  <> NVL(l_new_room_code,'X') OR
	      NVL(l_shd_instructor_id ,'X')<> NVL(l_new_instructor_id,'X') THEN


	    UPDATE IGS_PS_SH_USEC_OCCURS SET
		 monday           = l_new_monday,
		 tuesday          = l_new_tuesday,
		 wednesday        = l_new_wednesday,
		 thursday         = l_new_thursday,
		 friday           = l_new_friday,
		 saturday         = l_new_saturday,
		 sunday           = l_new_sunday,
		 start_time       = fnd_date.canonical_to_date(fnd_date.string_to_canonical(l_new_START_TIME,'DD-MON-YYYY HH24:MI:SS')),
		 end_time         = fnd_date.canonical_to_date(fnd_date.string_to_canonical(l_new_END_TIME,'DD-MON-YYYY HH24:MI:SS')),
		 room_code        = to_number(l_new_room_code),
		 building_code    = to_number(l_new_building_code),
		 instructor_id    = l_new_instructor_id,
		 last_updated_by  = g_n_user_id,
		 last_update_date = SYSDATE
	    WHERE  unit_section_occurrence_id = p_n_uso_id;

	  END IF;
	  CLOSE c_shadow_rec;
        END IF;
      END IF;

    ELSE --insert
      IF   p_calling_context = 'S' THEN

	OPEN cur_int_usec(p_n_uoo_id);
	FETCH cur_int_usec INTO l_cur_int_usec;
	IF cur_int_usec%FOUND THEN
          UPDATE igs_ps_sch_usec_int_all set import_done_flag='Y' WHERE int_usec_id = l_cur_int_usec.int_usec_id;
          UPDATE igs_ps_sch_pat_int set import_done_flag='Y' WHERE int_pat_id = l_cur_int_usec.int_pat_id;
        END IF;
        CLOSE cur_int_usec;

      END IF;

    END IF; --insert/update

--

  END validate_usec_occurs;

  PROCEDURE set_msg(p_c_msg_name IN VARCHAR2,
                    p_c_token IN VARCHAR2,
                    p_c_lkup_type IN VARCHAR2,
                    p_b_delete_flag IN BOOLEAN
                    )AS
  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  18-NOV-2002
    Purpose        :  This procedure sets the particular message in the  message stack.
                      Based upon the input arguments this procedure does the following functions
                      -- if the p_c_msg_name is null then returns immediately
                      -- if p_c_token and p_c_lkup_type
                      -- if the p_b_delete_flag is true then it deletes last message in the message stack.
                      -- if the
                      -- if p_c_token and p_c_lkup_type are not null then
                      it returns null for invalid lookup_code or/and lookup_type.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

  l_n_count NUMBER;
  l_c_meaning igs_lookups_view.meaning%TYPE;

  BEGIN
  l_c_meaning := null;
    -- If the message name is null, then return false
    IF p_c_msg_name IS NULL THEN
      RETURN;
    END IF;

    IF p_c_lkup_type IS NOT NULL THEN
      IF p_c_token IS NULL  THEN
        RETURN;
      ELSE
        l_c_meaning := get_lkup_meaning(p_c_token,p_c_lkup_type);
      END IF;
    END IF;

    IF p_b_delete_flag THEN
      l_n_count:= FND_MSG_PUB.COUNT_MSG;
      -- Delete the message 'IGS_GE_INVALID_VALUE'
      IF l_n_count > 0 THEN
        FND_MSG_PUB.DELETE_MSG(l_n_count);
      END IF;
    END IF;

    FND_MESSAGE.SET_NAME('IGS',p_c_msg_name);
      IF p_c_token IS NOT NULL THEN
        IF l_c_meaning IS NOT NULL THEN
          FND_MESSAGE.SET_TOKEN('PARAM',l_c_meaning);
        ELSE
          FND_MESSAGE.SET_TOKEN('PARAM',p_c_token);
        END IF;
      END IF;
    FND_MSG_PUB.ADD;

  END set_msg;

  FUNCTION get_lkup_meaning(p_c_lkup_cd IN VARCHAR2,
                            p_c_lkup_type IN VARCHAR2
                           ) RETURN VARCHAR2 AS
  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  18-NOV-2002
    Purpose        :  This function returns the meaning for the given lookup_code and lookup_type.
                      it returns null for invalid lookup_code or/and lookup_type.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    CURSOR c_meaning (cp_c_lkup_cd IN igs_lookups_view.lookup_code%TYPE,
                      cp_c_lkup_type IN igs_lookups_view.lookup_type%TYPE) IS
      SELECT  A.meaning
        FROM  igs_lookups_view A
        WHERE A.lookup_code  = cp_c_lkup_cd
        AND   A.lookup_type  = cp_c_lkup_type
        AND   A.enabled_flag = 'Y'
        AND   TRUNC(SYSDATE) BETWEEN NVL(A.start_date_active,TRUNC(SYSDATE))
        AND   NVL(A.end_date_active,TRUNC(SYSDATE)) ;

    l_c_meaning igs_lookups_view.meaning%TYPE;

  BEGIN
    OPEN c_meaning(p_c_lkup_cd,p_c_lkup_type);
    FETCH c_meaning INTO l_c_meaning;
    CLOSE c_meaning;
    return l_c_meaning;
  END get_lkup_meaning;

  PROCEDURE get_uoo_id( p_unit_cd IN VARCHAR2,
                        p_ver_num IN NUMBER,
                        p_cal_type IN VARCHAR2,
                        p_seq_num IN NUMBER,
                        p_loc_cd IN VARCHAR2,
                        p_unit_class IN VARCHAR2,
                        p_uoo_id OUT NOCOPY NUMBER,
                        p_message OUT NOCOPY VARCHAR2
                      )AS
    CURSOR c_uoo_id (cp_unit_cd IN igs_ps_unit_ofr_opt_all.unit_cd%TYPE,
                     cp_ver_num IN igs_ps_unit_ofr_opt_all.version_number%TYPE,
                     cp_cal_type IN igs_ps_unit_ofr_opt_all.cal_type%TYPE,
                     cp_seq_num IN igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
                     cp_loc_cd IN igs_ps_unit_ofr_opt_all.location_cd%TYPE,
                     cp_unit_class IN igs_ps_unit_ofr_opt_all.unit_class%TYPE ) IS
      SELECT   uoo_id
        FROM   igs_ps_unit_ofr_opt_all
        WHERE  UNIT_CD = cp_unit_cd
           AND version_number = cp_ver_num
           AND cal_type = cp_cal_type
           AND ci_sequence_number = cp_seq_num
           AND location_cd = cp_loc_cd
           AND unit_class = cp_unit_class;

  BEGIN
    OPEN c_uoo_id( p_unit_cd, p_ver_num, p_cal_type, p_seq_num, p_loc_cd, p_unit_class);
    FETCH c_uoo_id INTO p_uoo_id;
    IF c_uoo_id%NOTFOUND THEN
      p_message := 'IGS_PS_LGCY_REC_NOT_EXISTS';
    END IF;
    CLOSE c_uoo_id;
  END get_uoo_id;

  FUNCTION validate_waitlist_allowed ( p_c_cal_type IN igs_ca_type.cal_type%TYPE,
                                       p_n_seq_num  IN igs_ca_inst_all.sequence_number%TYPE ) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  21-NOV-2002
    Purpose        :  This function will check whether waitlisting is allowed for the given teaching calendar.
                      Returns TRUE if allowed and FALSE if not.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk       10-Oct-2003      Bug # 3052445. Modified the procedure.
  ********************************************************************************************** */
  CURSOR c_waitlist_allowed ( cp_c_cal_type igs_ca_type.cal_type%TYPE,
                              cp_n_seq_num  igs_ca_inst_all.sequence_number%TYPE ) IS
  SELECT inst.waitlist_alwd
  FROM igs_en_inst_wlst_opt inst,
       igs_ca_load_to_teach_v lot
  WHERE
    inst.cal_type = lot.load_cal_type AND
    lot.teach_cal_type = cp_c_cal_type AND
    lot.teach_ci_sequence_number = cp_n_seq_num;

  rec_waitlist_allowed c_waitlist_allowed%ROWTYPE;
  l_b_wlst_allowed  BOOLEAN := FALSE;

  BEGIN
  IF is_waitlist_allowed THEN
     l_b_wlst_allowed := TRUE;
     FOR rec_waitlist_allowed IN c_waitlist_allowed(p_c_cal_type, p_n_seq_num)
     LOOP
       IF rec_waitlist_allowed.waitlist_alwd = 'Y' THEN
          l_b_wlst_allowed := TRUE;
          EXIT;
       ELSE
          l_b_wlst_allowed := FALSE;
       END IF;
    END LOOP;
  END IF;
  RETURN l_b_wlst_allowed;

  END validate_waitlist_allowed;

  FUNCTION validate_gs_type ( p_c_gs_cd IN VARCHAR2, p_n_gs_ver IN NUMBER, p_c_gs_type IN VARCHAR2) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  18-NOV-2002
    Purpose        :  This function is to check whether the grading schema code and version number are of
                      particular grading schema type.
                      This function will returns TRUE if the passed grading schema is of 'UNIT' type and
                      returns FALSE, if not.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_gs_exists ( cp_gs_cd igs_ps_unit_grd_schm.grading_schema_code%TYPE,
                         cp_gs_ver igs_ps_unit_grd_schm.grd_schm_version_number%TYPE,
                         cp_gs_type igs_as_grd_schema.grading_schema_type%TYPE ) IS
  SELECT 1
  FROM igs_as_grd_schema
  WHERE
    grading_schema_cd = cp_gs_cd AND
    version_number = cp_gs_ver AND
    grading_schema_type = cp_gs_type ;
  rec_gs_exists c_gs_exists%ROWTYPE;

  BEGIN
    OPEN c_gs_exists ( p_c_gs_cd, p_n_gs_ver, p_c_gs_type );
    FETCH c_gs_exists INTO rec_gs_exists;
    IF ( c_gs_exists%FOUND ) THEN
      CLOSE c_gs_exists;
      RETURN TRUE;
    ELSE
      CLOSE c_gs_exists;
      RETURN FALSE;
    END IF;
  END validate_gs_type;

  FUNCTION validate_cal_cat ( p_c_cal_type IN igs_ca_inst_all.cal_type%TYPE,
                              p_c_cal_cat  IN igs_ca_type.s_cal_cat%TYPE) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  21-NOV-2002
    Purpose        :  This function will returns true if the passed calendar type's category is matches
                      with passed category and false, otherwise.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR c_cal ( cp_cal_type igs_ca_inst_all.cal_type%TYPE,
                 cp_cal_cat  igs_ca_type.s_cal_cat%TYPE ) IS
  SELECT 1
  FROM igs_ca_type
  WHERE
    s_cal_cat = cp_cal_cat AND
    cal_type  = cp_cal_type;
  rec_cal c_cal%ROWTYPE;

  BEGIN

    OPEN c_cal ( p_c_cal_type, p_c_cal_cat );
    FETCH c_cal INTO rec_cal;
    IF ( c_cal%NOTFOUND ) THEN
      CLOSE c_cal;
      RETURN FALSE;
    ELSE
      CLOSE c_cal;
      RETURN TRUE;
    END IF;

  END validate_cal_cat;

  -- Validate Orgaization Unit Code
  FUNCTION validate_org_unit_cd ( p_c_org_unit_cd IN igs_ps_unit_ver_all.owner_org_unit_cd%TYPE,
                                  p_c_object_name IN VARCHAR2 ) RETURN BOOLEAN
  AS
  /***********************************************************************************************
    Created By     :  shtatiko
    Date Created By:  22-NOV-2002
    Purpose        :  This function validates the Organization Unit Code and returns TRUE if Org
                      Unit Code is valid and retuns false, if not.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    15-FEB-2006        Bug#5040156, Changed call from GET_WHERE_CLAUSE to GET_WHERE_CLAUSE_FORM1 as a part of Literal fix
    jbegum      02-June-2003       Bug #2972950.
                                   For the Legacy Enhancements TD:
                                   As a part of Binding issues, using bind variable in the ref cursor.
  ********************************************************************************************** */
  TYPE c_ref_cur IS REF CURSOR;
  c_org_cur c_ref_cur;
  l_c_cur_stat VARCHAR2(2000);
  l_c_where_clause VARCHAR2(1000);
  l_n_rec_found NUMBER(1);

  BEGIN

    igs_or_gen_012_pkg.get_where_clause_api1( p_c_object_name, l_c_where_clause );
    IF l_c_where_clause IS NULL THEN
      l_c_cur_stat := 'SELECT 1 FROM igs_or_inst_org_base_v WHERE party_number = :p_c_org_unit_cd ';
      OPEN c_org_cur FOR l_c_cur_stat USING p_c_org_unit_cd;
    ELSE
      l_c_cur_stat := 'SELECT 1 FROM igs_or_inst_org_base_v WHERE party_number = :p_c_org_unit_cd  AND ' || l_c_where_clause;
      OPEN c_org_cur FOR l_c_cur_stat USING p_c_org_unit_cd,p_c_object_name;
   END IF;
    FETCH c_org_cur INTO l_n_rec_found;
    IF ( c_org_cur%FOUND ) THEN
      CLOSE c_org_cur;
      RETURN TRUE;
    ELSE
      CLOSE c_org_cur;
      RETURN FALSE;
    END IF;

  END validate_org_unit_cd;

  PROCEDURE get_party_id(p_c_person_number IN hz_parties.party_number%TYPE,
                         p_n_person_id OUT NOCOPY hz_parties.party_id%TYPE) AS
  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  26-DEC-2002
    Purpose        :  Gets the party identifier for the given party number for Active and Inactive records.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
    CURSOR c_party_id (cp_c_party_number IN hz_parties.party_number%type) IS
      SELECT hz.party_id
      FROM hz_parties hz
       WHERE hz.party_number = cp_c_party_number
       AND   hz.status in ('A','I');

  BEGIN
    OPEN c_party_id (p_c_person_number);
    FETCH c_party_id INTO p_n_person_id;
    CLOSE c_party_id;
  END get_party_id;

  -- Removed the function validate_staff_person

  PROCEDURE validate_enr_lmts( p_n_ern_min igs_ps_unit_ver_all.enrollment_minimum%TYPE,
                               p_n_enr_max igs_ps_unit_ver_all.enrollment_maximum%TYPE,
                               p_n_ovr_max igs_ps_unit_ver_all.override_enrollment_max%TYPE,
                               p_n_adv_max igs_ps_unit_ver_all.advance_maximum%TYPE,
                               p_c_rec_status IN OUT NOCOPY VARCHAR2) IS
  /***********************************************************************************************
    Created By     :  jbegum
    Date Created By:  02-June-2003
    Purpose        :  Bug # 2972950.
                      For the Legacy Enhancements TD:
                      This procedure does the business validation related to enrollment limits.
                      This procedure will be called from business validation part of importing unit and unit section.
                      As mentioned in TD.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  BEGIN

     IF p_n_ern_min > p_n_enr_max THEN
        p_c_rec_status := 'E';
        fnd_message.set_name('IGS','IGS_PS_ENROLL_MIN_GREATER');
        fnd_msg_pub.add;
     END IF;

     IF p_n_enr_max > p_n_ovr_max THEN
        p_c_rec_status := 'E';
        fnd_message.set_name('IGS','IGS_PS_OVERIDE_MIN_MAX_CP');
        fnd_msg_pub.add;
     END IF;

     IF p_n_adv_max > p_n_enr_max THEN
        p_c_rec_status := 'E';
        fnd_message.set_name('IGS','IGS_PS_ADV_MAX_LESS_ENR_MAX');
        fnd_msg_pub.add;
     END IF;

  END validate_enr_lmts;

  PROCEDURE validate_usec_el(p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                             p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
			     p_insert_update VARCHAR2) AS

  /***********************************************************************************************
    Created By     :  jbegum
    Date Created By:  02-June-2003
    Purpose        :  Bug # 2972950.
                      For the Legacy Enhancements TD:
                      This procedure does the business validation related to enrollment limits of unit section
                      As mentioned in TD.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    23-NOV-2005     BUG#4675113,include cursor c_usec_st, so that unit section is not updated to open on updating  Enrollment Maximum
                                when unit is planned.
    sarakshi    12-Jul-2004     Bug#3729462, Added the predicate DELETE_FLAG in the cursor c_waitlist_allowed.
    smvk        25-Nov-2003     Bug # 2833971. Removed the validation associated with displaying error
                                messages IGS_PS_WLST_MAX_LESS_THAN_ACT and IGS_PS_ENR_MAX_LESS_THAN_ACT.
  ********************************************************************************************** */

     CURSOR c_act (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT NVL(enrollment_actual, 0) enrollment_actual,
            NVL(auditable_ind,'N') auditable_ind,
	    waitlist_actual
     FROM   igs_ps_unit_ofr_opt_all a
     WHERE  uoo_id = cp_n_uoo_id;

     CURSOR c_waitlist_allowed (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT waitlist_allowed
     FROM   igs_ps_unit_ofr_pat_all a,
            igs_ps_unit_ofr_opt_all b
     WHERE  b.uoo_id = cp_n_uoo_id
     AND    a.unit_cd = b.unit_cd
     AND    a.version_number = b.version_number
     AND    a.cal_type = b.cal_type
     AND    a.ci_sequence_number = b.ci_sequence_number
     AND    a.delete_flag='N';

     CURSOR c_usec_lim(cp_n_uoo_id NUMBER) IS
     SELECT *
     FROM igs_ps_usec_lim_wlst
     WHERE uoo_id = cp_n_uoo_id;

     c_usec_lim_rec c_usec_lim%ROWTYPE;
     rec_act  c_act%ROWTYPE;
     CURSOR cur_is_audited(cp_uoo_id igs_en_su_attempt.uoo_id%TYPE) IS
     SELECT count(*)
     FROM  igs_en_su_attempt
     WHERE uoo_id  =  cp_uoo_id
     AND   no_assessment_ind = 'Y';

     CURSOR cur_db_value(cp_uoo_id igs_ps_usec_lim_wlst.uoo_id%TYPE) IS
     SELECT max_auditors_allowed
     FROM   igs_ps_usec_lim_wlst
     WHERE  uoo_id = cp_uoo_id;

     CURSOR c_usec_wlst_pri(cp_n_uoo_id NUMBER) IS
     SELECT 'X' FROM  igs_ps_usec_wlst_pri
     WHERE uoo_id = cp_n_uoo_id;

     c_usec_wlst_pri_rec c_usec_wlst_pri%ROWTYPE;

     CURSOR c_usec_st(cp_unit_cd        igs_ps_unit_ver_all.unit_cd%TYPE,
                    cp_version_number igs_ps_unit_ver_all.version_number%TYPE) IS
     SELECT b.s_unit_status unit_status
     FROM igs_ps_unit_ver_all a,igs_ps_unit_stat b
     WHERE a.UNIT_STATUS=b.UNIT_STATUS
     AND   a.unit_cd=cp_unit_cd
     AND   a.version_number=cp_version_number;
     c_usec_st_rec c_usec_st%ROWTYPE;

     l_max_auditors_allowed  igs_ps_usec_lim_wlst.max_auditors_allowed%TYPE;
     l_ctx_value igs_ps_usec_lim_wlst.max_auditors_allowed%TYPE := p_usec_rec.max_auditors_allowed;
     l_count  NUMBER;
     l_c_waitlist_allowed  igs_ps_unit_ofr_pat_all.waitlist_allowed%TYPE;
     l_message_name VARCHAR2(30);

     l_n_enr_max IGS_PS_USEC_LIM_WLST.ENROLLMENT_MAXIMUM%TYPE;
     l_n_wlst_max IGS_PS_USEC_LIM_WLST.MAX_STUDENTS_PER_WAITLIST%TYPE;
     l_c_wlst_allowed IGS_PS_USEC_LIM_WLST.WAITLIST_ALLOWED%TYPE;
     l_n_enr_act IGS_PS_UNIT_OFR_OPT_ALL.ENROLLMENT_ACTUAL%TYPE;
     l_n_wlst_act  IGS_PS_UNIT_OFR_OPT_ALL.WAITLIST_ACTUAL%TYPE;
     l_c_usec_status IGS_PS_UNIT_OFR_OPT_ALL.UNIT_SECTION_STATUS%TYPE := NULL;
     l_request_id   NUMBER;

  BEGIN

     OPEN c_act(p_n_uoo_id);
     FETCH c_act INTO rec_act;
     CLOSE c_act;
     IF p_usec_rec.usec_waitlist_allowed = 'Y' THEN
        OPEN  c_waitlist_allowed (p_n_uoo_id);
        FETCH c_waitlist_allowed INTO l_c_waitlist_allowed;
        CLOSE c_waitlist_allowed;
        IF l_c_waitlist_allowed = 'N' THEN
           p_usec_rec.status := 'E';
           fnd_message.set_name ('IGS', 'IGS_PS_WLST_ALWD_NO_ORG');
           fnd_msg_pub.add;
        END IF;
     ELSE
        p_usec_rec.usec_max_students_per_waitlist := 0;
     END IF;

     IF NVL(p_usec_rec.override_enrollment_maximum,999999) < rec_act.enrollment_actual THEN
        p_usec_rec.status := 'E';
        fnd_message.set_name ('IGS', 'IGS_PS_OVRENR_MAX_LESS_ACTMAX');
        fnd_msg_pub.add;
     END IF;

     IF rec_act.auditable_ind = 'N' and p_usec_rec.max_auditors_allowed IS NOT NULL THEN
        p_usec_rec.status := 'E';
        fnd_message.set_name ('IGS', 'IGS_PS_MAX_AUD_MUST_BE_NULL');
        fnd_msg_pub.add;
     END IF;

     IF p_usec_rec.enrollment_maximum IS NULL AND
        p_usec_rec.override_enrollment_maximum IS NOT NULL THEN
        p_usec_rec.status := 'E';
        fnd_message.set_name ('IGS', 'IGS_PS_ENR_NULL_OVR_NOT');
        fnd_msg_pub.add;
     END IF;

     validate_enr_lmts (p_usec_rec.enrollment_minimum, p_usec_rec.enrollment_maximum, p_usec_rec.override_enrollment_maximum, p_usec_rec.advance_maximum, p_usec_rec.status);

    IF p_insert_update = 'U' THEN

      OPEN c_usec_lim(p_n_uoo_id);
      FETCH c_usec_lim INTO c_usec_lim_rec;
      CLOSE c_usec_lim;

      --Before updating check the scheduling status is processing or not
      IF IGS_PS_USEC_SCHEDULE.PRGP_GET_SCHD_STATUS( p_n_uoo_id,
						    NULL,
						    l_message_name ) = TRUE THEN
	IF l_message_name IS NULL THEN
	   l_message_name := 'IGS_PS_SCST_PROC';
	END IF;
	fnd_message.set_name( 'IGS', l_message_name);
	p_usec_rec.status := 'E';
	fnd_msg_pub.add;
      END IF;

      OPEN cur_db_value(p_n_uoo_id);
      FETCH cur_db_value INTO l_max_auditors_allowed;
      CLOSE cur_db_value;
      --If user tries to clear/lower Maximum Auditors Allowed field,than which is saved in database...
      IF ( (l_ctx_value IS NULL AND l_max_auditors_allowed IS NOT NULL) OR
	   (l_max_auditors_allowed > l_ctx_value)
	 ) THEN
	--check the count that have been used for auditing...
	OPEN cur_is_audited(p_n_uoo_id);
	FETCH cur_is_audited INTO l_count;
	--if used....
	IF l_count > 0 THEN
	  --if the count is more than context value...
	  IF (l_ctx_value IS NULL OR (l_ctx_value < NVL(l_count,0))) THEN
	    --display error message to the user saying that this field cannot be lowered/cleared since the
	    --unit has been used for auditing.
	    fnd_message.set_name('IGS','IGS_PS_LOW_NO_MAX_AUD_USEC');
	    p_usec_rec.status := 'E';
	    fnd_msg_pub.add;
	  END IF;
	END IF;
	CLOSE cur_is_audited;
      END IF;

      -- Cannot unckeck waitlist allowed as there are students in the actual waitlist
      IF NVL(p_usec_rec.usec_waitlist_allowed,'N') = 'N' AND NVL(rec_act.WAITLIST_ACTUAL,0) > 0 THEN
	 fnd_message.set_name('IGS','IGS_PS_ACT_WLST_GRT_ZERO');
	 p_usec_rec.status := 'E';
	 fnd_msg_pub.add;
      END IF;

      OPEN c_usec_st(p_usec_rec.unit_cd,p_usec_rec.version_number);
      FETCH c_usec_st INTO c_usec_st_rec;
      CLOSE c_usec_st;
      IF  p_usec_rec.enrollment_maximum <> c_usec_lim_rec.enrollment_maximum  AND c_usec_st_rec.unit_status <> 'PLANNED' THEN
        l_n_enr_max      := NVL( p_usec_rec.enrollment_maximum,'999999');
        l_c_wlst_allowed := NVL(c_usec_lim_rec.waitlist_allowed,'N');
        l_n_enr_act      := rec_act.ENROLLMENT_ACTUAL;
        l_n_wlst_max     := NVL(c_usec_lim_rec.MAX_STUDENTS_PER_WAITLIST,'999999');
        l_n_wlst_act     := NVL(rec_act.WAITLIST_ACTUAL,0);

	IF l_c_wlst_allowed = 'N' THEN
	   IF l_n_enr_act >= l_n_enr_max THEN
	      l_c_usec_status := 'CLOSED';
	   ELSIF l_n_enr_act < l_n_enr_max THEN
	      l_c_usec_status := 'OPEN';
	   END IF;
	ELSE
	   IF l_n_enr_act >= l_n_enr_max AND l_n_wlst_act >= l_n_wlst_max THEN
	     l_c_usec_status := 'CLOSED';
	   ELSIF l_n_enr_act < l_n_enr_max  AND l_n_wlst_act >0 THEN
	     l_c_usec_status := 'HOLD';
	   ELSIF l_n_enr_act >= l_n_enr_max AND l_n_wlst_act < l_n_wlst_max THEN
	     l_c_usec_status := 'FULLWAITOK';
	   ELSIF l_n_enr_act < l_n_enr_max  AND l_n_wlst_act = 0 THEN
	     l_c_usec_status := 'OPEN';
	   END IF;
	END IF;
	IF l_c_usec_status IS NOT NULL THEN
	   UPDATE igs_ps_unit_ofr_opt_all
	   SET unit_section_status = l_c_usec_status
	   WHERE uoo_id = p_n_uoo_id;
	END IF;
      END IF;

	--If Priority exists then do not allow to uncheck the waitlist allowed
	IF p_usec_rec.usec_waitlist_allowed = 'N' THEN

	  OPEN c_usec_wlst_pri(p_n_uoo_id);
	  FETCH c_usec_wlst_pri INTO c_usec_wlst_pri_rec;
	  IF c_usec_wlst_pri%FOUND THEN
	    fnd_message.set_name('IGS','IGS_PS_PRIORITY_EXISTS');
	    p_usec_rec.status := 'E';
	    fnd_msg_pub.add;
	  END IF;
	END IF;

       IF p_usec_rec.usec_waitlist_allowed = 'N' THEN
	 IF p_usec_rec.usec_max_students_per_waitlist IS NULL THEN
	   p_usec_rec.usec_max_students_per_waitlist:= 0;
	 ELSIF  p_usec_rec.usec_max_students_per_waitlist > 0 THEN
	   fnd_message.set_name('IGS','IGS_PS_MAX_STD_CNT_GT_0');
	   p_usec_rec.status := 'E';
	   fnd_msg_pub.add;
	 END IF;
       END IF;

       IF (
            NVL(p_usec_rec.enrollment_maximum,-999) <>  NVL(c_usec_lim_rec.enrollment_maximum,-999) OR
            NVL(p_usec_rec.enrollment_expected,-999) <> NVL(c_usec_lim_rec.enrollment_expected,-999) OR
            NVL(p_usec_rec.override_enrollment_maximum,-999) <> NVL(c_usec_lim_rec.override_enrollment_max,-999)
          ) THEN
        IF igs_ps_usec_schedule.prgp_upd_usec_dtls(
                                                   p_uoo_id=>p_n_uoo_id,
                                                   p_max_enrollments =>NVL(p_usec_rec.enrollment_maximum,-999) ,
                                                   p_override_enrollment_max => NVL(p_usec_rec.override_enrollment_maximum,-999),
                                                   p_enrollment_expected => NVL(p_usec_rec.enrollment_expected,-999),
                                                   p_request_id =>l_request_id,
                                                   p_message_name=>l_message_name
                                                  ) = FALSE THEN


          p_usec_rec.status := 'E';
          fnd_message.set_name ('IGS', 'l_message_name');
          fnd_msg_pub.add;
        END IF;
      END IF;

    END IF;


  END validate_usec_el;

 PROCEDURE post_usec_limits(p_usec_rec IN OUT NOCOPY igs_ps_generic_pub.usec_rec_type,
                            p_calling_context IN VARCHAR2,
                            p_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
		            p_insert_update VARCHAR2) AS

     CURSOR cur_unit_limit(cp_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT enrollment_maximum,enrollment_expected,override_enrollment_max
     FROM   igs_ps_unit_ver_all uv,
           igs_ps_unit_ofr_opt_all uoo
     WHERE  uv.unit_cd=uoo.unit_cd
     AND    uv.version_number=uoo.version_number
     AND    uoo.uoo_id=cp_uoo_id;
     l_c_unit cur_unit_limit%ROWTYPE;
     l_request_id NUMBER;
     l_message_name VARCHAR2(30);

  BEGIN

    IF p_calling_context <> 'S' THEN

      IF p_insert_update = 'I' THEN
	OPEN cur_unit_limit(p_n_uoo_id);
	FETCH cur_unit_limit INTO l_c_unit;
	CLOSE cur_unit_limit;

	IF   (
	 NVL(p_usec_rec.enrollment_maximum,-999) <>  NVL(l_c_unit.enrollment_maximum,-999) OR
	 NVL(p_usec_rec.enrollment_expected,-999) <> NVL(l_c_unit.enrollment_expected,-999) OR
	 NVL(p_usec_rec.override_enrollment_maximum,-999) <> NVL(l_c_unit.override_enrollment_max,-999)
	) THEN

	  IF igs_ps_usec_schedule.prgp_upd_usec_dtls(
						     p_uoo_id=>p_n_uoo_id,
						     p_max_enrollments =>NVL(l_c_unit.enrollment_maximum,-999) ,
						     p_override_enrollment_max => NVL(l_c_unit.override_enrollment_max,-999),
						     p_enrollment_expected => NVL(l_c_unit.enrollment_expected,-999),
						     p_request_id =>l_request_id,
						     p_message_name=>l_message_name
						    ) = FALSE THEN


	    p_usec_rec.status := 'E';
	    fnd_message.set_name ('IGS', 'l_message_name');
	    fnd_msg_pub.add;
	  END IF;
	END IF;

      END IF;

    END IF;

  END post_usec_limits;

  PROCEDURE post_uso_ins (p_n_ins_id IN igs_ps_uso_instrctrs.instructor_id%TYPE,
                          p_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                          p_uso_ins_rec  IN OUT NOCOPY igs_ps_generic_pub.uso_ins_rec_type,
                          p_n_index IN NUMBER) AS
  /***********************************************************************************************
    Created By     :  jbegum
    Date Created By:  02-June-2003
    Purpose        :  Bug # 2972950.
                      For the Legacy Enhancements TD:
                      This procedure does the post validation for unit section occurrence of instructors.
                      if the instructor getting imported is not a part of Unit Section Teaching Responsibility then
                      the instructor would be added in Unit Section Teaching Responsibility .As mentioned in TD.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    smvk        04-May-2004     Bug # 3568858.  Faculty Teaching Responsibility build. Removed the code which were deriving
                                % allocation based on workload values, % allocation and workload value match and workload validations.
    smvk        19-Jun-2003     Bug # 2833853. HR integration Build. when instructors are imported, if the confirmed flag
                                is set to 'Y' then their corresponding workloads are calculated and checked against the expected workload.
                                Erroring out if the calculated workload exceeds the expected workload / calendar category is not at all set up /
                                work load is not set up for employment category of instrutor getting imported.
  ********************************************************************************************** */

     CURSOR c_check_instrctr_exists(cp_n_instructor_id IGS_PS_USEC_TCH_RESP.INSTRUCTOR_ID%TYPE,
                                    cp_n_uoo_id IGS_PS_UNIT_OFR_OPT.UOO_ID%TYPE) IS
       SELECT COUNT(*)
       FROM   igs_ps_usec_tch_resp
       WHERE  instructor_id = cp_n_instructor_id
       AND    uoo_id = cp_n_uoo_id
       AND    ROWNUM = 1;

     CURSOR c_lead_cnd (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%type) IS
       SELECT COUNT(*)
       FROM   IGS_PS_USEC_TCH_RESP
       WHERE  lead_instructor_flag='Y'
       AND    uoo_id = cp_n_uoo_id
       AND    ROWNUM = 1;

     CURSOR c_cal_inst (cp_n_uoo_id IN NUMBER) IS
       SELECT A.cal_type,
              A.ci_sequence_number,
              A.unit_section_status
       FROM   IGS_PS_UNIT_OFR_OPT_ALL A
       WHERE  A.uoo_id  =  cp_n_uoo_id;

     CURSOR c_cal_setup IS
       SELECT 'x'
       FROM   IGS_PS_EXP_WL
       WHERE  ROWNUM=1;

     rec_cal_inst c_cal_inst%ROWTYPE;

     l_n_t_lecture        igs_ps_usec_tch_resp.instructional_load_lecture%TYPE :=0;
     l_n_t_lab            igs_ps_usec_tch_resp.instructional_load_lab%TYPE :=0;
     l_n_t_other          igs_ps_usec_tch_resp.instructional_load%TYPE :=0;
     l_n_total_wl         NUMBER(10,2);
     l_n_exp_wl           NUMBER(6,2);
     l_n_tot_fac_wl       NUMBER(10,2);
     l_c_cal              VARCHAR2(1);
     l_n_no_of_instructor NUMBER;
     l_n_count            NUMBER;

  BEGIN

    --Check if the unit section is NOT_OFFERED
    IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
      fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
      fnd_msg_pub.add;
      p_uso_ins_rec.status := 'E';
    END IF;


    OPEN c_check_instrctr_exists(p_n_ins_id, p_n_uoo_id);
    FETCH c_check_instrctr_exists INTO l_n_no_of_instructor;
    CLOSE c_check_instrctr_exists;

    IF l_n_no_of_instructor > 0 THEN
       RETURN;
    ELSE
       -- Derivation of values
       IF p_uso_ins_rec.confirmed_flag IS NULL THEN
          p_uso_ins_rec.confirmed_flag := 'Y';
       END IF;

       IF p_uso_ins_rec.lead_instructor_flag IS NULL THEN
          p_uso_ins_rec.lead_instructor_flag := 'N';
       END IF;

       -- Check constraints
       BEGIN
          igs_ps_usec_tch_resp_pkg.check_constraints('LEAD_INSTRUCTOR_FLAG', p_uso_ins_rec.lead_instructor_flag);
       EXCEPTION
          WHEN OTHERS THEN
             fnd_message.set_name('IGS','IGS_PS_LEAD_INSTRUCTOR_FLAG');
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N',fnd_message.get, NULL,TRUE);
             p_uso_ins_rec.status :='E';
       END;
       BEGIN
          igs_ps_usec_tch_resp_pkg.check_constraints('CONFIRMED_FLAG', p_uso_ins_rec.confirmed_flag);
       EXCEPTION
          WHEN OTHERS THEN
             fnd_message.set_name('IGS','IGS_PS_CONFIRMED_FLAG');
             igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_Y_OR_N',fnd_message.get, NULL,TRUE);
             p_uso_ins_rec.status :='E';
       END;

       -- Validation : Either percentage allocation or workload value should be provided. Both cannot be null
       -- Presently coded the mandatory validation for confirmed records.
       IF p_uso_ins_rec.confirmed_flag = 'Y' AND
          p_uso_ins_rec.wl_percentage_allocation IS NULL AND
          p_uso_ins_rec.instructional_load_lecture IS NULL AND
          p_uso_ins_rec.instructional_load_laboratory IS NULL AND
          p_uso_ins_rec.instructional_load_other IS NULL THEN
            fnd_message.set_name('IGS','IGS_PS_PERCENT_WKLD_MANDATORY');
            fnd_msg_pub.add;
            p_uso_ins_rec.status := 'E';
       END IF;

       IF p_uso_ins_rec.wl_percentage_allocation IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('PERCENTAGE_ALLOCATION', p_uso_ins_rec.wl_percentage_allocation);
          EXCEPTION
             WHEN OTHERS THEN
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','PERCENTAGE','LEGACY_TOKENS',TRUE);
                p_uso_ins_rec.status :='E';
          END;
          --Format mask validation
	  IF p_uso_ins_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_uso_ins_rec.wl_percentage_allocation,3,2) THEN
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_PTS_RANGE_0_999','PERCENTAGE','LEGACY_TOKENS',FALSE);
		p_uso_ins_rec.status :='E';
	    END IF;
	  END IF;

       END IF;

       IF p_uso_ins_rec.instructional_load_lecture IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('INSTRUCTIONAL_LOAD_LECTURE', p_uso_ins_rec.instructional_load_lecture);
          EXCEPTION
             WHEN OTHERS THEN
               fnd_message.set_name('IGS','IGS_PS_INS_LOAD_LECTURE');
               igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get, NULL,TRUE);
               p_uso_ins_rec.status :='E';
          END;

          --Format mask validation
	  IF p_uso_ins_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_uso_ins_rec.instructional_load_lecture,4,2) THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_LECTURE');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get, NULL,FALSE);
		p_uso_ins_rec.status :='E';
	    END IF;
	  END IF;

       END IF;

       IF p_uso_ins_rec.instructional_load_laboratory IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('INSTRUCTIONAL_LOAD_LAB', p_uso_ins_rec.instructional_load_laboratory);
          EXCEPTION
             WHEN OTHERS THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_LAB');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get,NULL,TRUE);
                p_uso_ins_rec.status :='E';
          END;

	  --Format mask validation
	  IF p_uso_ins_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_uso_ins_rec.instructional_load_laboratory,4,2) THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_LAB');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get,NULL,FALSE);
		p_uso_ins_rec.status :='E';
	    END IF;
	  END IF;

       END IF;

       IF p_uso_ins_rec.instructional_load_other IS NOT NULL THEN
          BEGIN
             igs_ps_usec_tch_resp_pkg.check_constraints('INSTRUCTIONAL_LOAD', p_uso_ins_rec.instructional_load_other);
          EXCEPTION
             WHEN OTHERS THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_OTHER');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get,NULL,TRUE);
                p_uso_ins_rec.status :='E';
          END;

	  --Format mask validation
	  IF p_uso_ins_rec.status <> 'E' THEN
	    IF NOT igs_ps_validate_lgcy_pkg.boundary_check_number(p_uso_ins_rec.instructional_load_other,4,2) THEN
                fnd_message.set_name('IGS','IGS_PS_INS_LOAD_OTHER');
                igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_VAL_0_9999D99',fnd_message.get,NULL,FALSE);
		p_uso_ins_rec.status :='E';
	    END IF;
	  END IF;

       END IF;

       IF p_uso_ins_rec.lead_instructor_flag = 'Y' THEN
          OPEN c_lead_cnd(p_n_uoo_id);
          FETCH c_lead_cnd INTO l_n_count;
          CLOSE c_lead_cnd;
          IF l_n_count <> 0 THEN
             fnd_message.set_name('IGS','IGS_PS_LEAD_INSTRUCTOR_ONE');
             fnd_msg_pub.add;
             p_uso_ins_rec.status := 'E';
          END IF;
       END IF;

       -- if workload percentage is provided need to dervie the lecture /lab / other workloads.
       IF p_uso_ins_rec.wl_percentage_allocation IS NOT NULL AND
          p_uso_ins_rec.instructional_load_lecture IS NULL AND
          p_uso_ins_rec.instructional_load_laboratory IS NULL AND
          p_uso_ins_rec.instructional_load_other IS NULL THEN
          igs_ps_fac_credt_wrkload.calculate_teach_work_load(p_n_uoo_id, p_uso_ins_rec.wl_percentage_allocation, l_n_t_lab , l_n_t_lecture, l_n_t_other);
             p_uso_ins_rec.instructional_load_lecture := l_n_t_lecture;
             p_uso_ins_rec.instructional_load_laboratory := l_n_t_lab;
             p_uso_ins_rec.instructional_load_other := l_n_t_other;
       END IF;


       --Instructor should be staff or faculty
       IF validate_staff_faculty (p_person_id => p_n_ins_id) = FALSE THEN
             p_uso_ins_rec.status :='E';
             fnd_message.set_name('IGS','IGS_PS_INST_NOT_FACULTY_STAFF');
             fnd_msg_pub.add;
       END IF;

       IF p_uso_ins_rec.confirmed_flag = 'Y' THEN
          OPEN c_cal_setup;
          FETCH c_cal_setup INTO l_c_cal;
          CLOSE c_cal_setup;
          IF l_c_cal IS NULL THEN
             p_uso_ins_rec.status :='E';
             fnd_message.set_name('IGS','IGS_PS_NO_CAL_CAT_SETUP');
             fnd_msg_pub.add;
          ELSIF l_c_cal = 'x' THEN
             l_n_total_wl := NVL(p_uso_ins_rec.instructional_load_lecture,0) +
                             NVL(p_uso_ins_rec.instructional_load_laboratory,0) +
                             NVL(p_uso_ins_rec.instructional_load_other,0);

             OPEN c_cal_inst(p_n_uoo_id);
             FETCH c_cal_inst INTO rec_cal_inst;
             IF c_cal_inst%FOUND THEN
                IF rec_cal_inst.unit_section_status NOT IN ('CANCELLED','NOT_OFFERED') THEN
                   IF igs_ps_gen_001.teach_fac_wl (rec_cal_inst.cal_type,
                                                   rec_cal_inst.ci_sequence_number,
                                                   p_n_ins_id,
                                                   l_n_total_wl,
                                                   l_n_tot_fac_wl,
                                                   l_n_exp_wl
                                                   ) THEN
                      p_uso_ins_rec.status :='E';
                      fnd_message.set_name('IGS','IGS_PS_FAC_EXCEED_EXP_WL');
                      fnd_msg_pub.add;
                   END IF;
                   IF l_n_exp_wl IS NULL OR l_n_exp_wl = 0 THEN
                      p_uso_ins_rec.status :='E';
                      fnd_message.set_name('IGS','IGS_PS_NO_SETUP_FAC_EXCEED');
                      fnd_msg_pub.add;
                   END IF;
                END IF;
             END IF;
             CLOSE c_cal_inst;
          END IF;
       END IF;
       IF p_uso_ins_rec.status = 'S' THEN
          INSERT INTO IGS_PS_USEC_TCH_RESP(
                                             UNIT_SECTION_TEACH_RESP_ID,
                                             UOO_ID,
                                             INSTRUCTOR_ID,
                                             CONFIRMED_FLAG,
                                             PERCENTAGE_ALLOCATION,
                                             INSTRUCTIONAL_LOAD_LECTURE,
                                             INSTRUCTIONAL_LOAD_LAB,
                                             INSTRUCTIONAL_LOAD,
                                             LEAD_INSTRUCTOR_FLAG,
                                             CREATED_BY,
                                             CREATION_DATE,
                                             LAST_UPDATED_BY,
                                             LAST_UPDATE_DATE,
                                             LAST_UPDATE_LOGIN
                                           ) VALUES (
                                             IGS_PS_USEC_TCH_RESP_S.nextval,
                                             p_n_uoo_id,
                                             p_n_ins_id,
                                             p_uso_ins_rec.confirmed_flag,
                                             p_uso_ins_rec.wl_percentage_allocation,
                                             p_uso_ins_rec.instructional_load_lecture,
                                             p_uso_ins_rec.instructional_load_laboratory,
                                             p_uso_ins_rec.instructional_load_other,
                                             p_uso_ins_rec.lead_instructor_flag,
                                             g_n_user_id,
                                             SYSDATE,
                                             g_n_user_id,
                                             SYSDATE,
                                             g_n_login_id
                                           );
          v_tab_usec_tr(v_tab_usec_tr.count +1).uoo_id := p_n_uoo_id;
          v_tab_usec_tr(v_tab_usec_tr.count).instr_index := p_n_index;
       END IF;
    END IF;
  END post_uso_ins;

 FUNCTION post_uso_ins_busi (p_tab_uso_ins IN OUT NOCOPY igs_ps_generic_pub.uso_ins_tbl_type) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  jbegum
    Date Created By:  02-June-2003
    Purpose        :  Bug # 2972950.
                      For the Legacy Enhancements TD:
                      This function does the post business validation for unit section occurrence instructor process.
                      This validations make sure that the unit section teaching responisibilities record getting created as a part of
                      import unit section occurrence instrcutors process are valid. Changes are as mentioned in TD.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sarakshi    14-May-2004     Bug#3629483 , changed the message IGS_PS_TCHRESP_NOTTOTAL_100 to IGS_PS_US_TCHRESP_NOTTOTAL_100.Also added null to token for the message IGS_PS_WKLOAD_VALIDATION
    smvk        04-May-2004     Bug # 3568858.  Faculty Teaching Responsibility build. Workload validation based on profile
                                "IGS: Unit Section Teaching Responsibility Validation".
  ********************************************************************************************** */

   l_tab_uoo igs_ps_create_generic_pkg.uoo_tbl_type;

   CURSOR c_count_lead (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT count(*)
     FROM   IGS_PS_USEC_TCH_RESP
     WHERE  uoo_id = cp_n_uoo_id
      AND   lead_instructor_flag = 'Y';

   CURSOR c_count_percent(cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT SUM(PERCENTAGE_ALLOCATION)
     FROM   IGS_PS_USEC_TCH_RESP
     WHERE  confirmed_flag = 'Y'
     AND    uoo_id = cp_n_uoo_id;

   CURSOR c_unit_dtls (cp_n_uoo_id igs_ps_unit_ofr_opt_all.uoo_id%TYPE) IS
     SELECT unit_cd,
            version_number
     FROM   igs_ps_unit_ofr_opt_all
     WHERE  uoo_id = cp_n_uoo_id
     AND    ROWNUM < 2;

   CURSOR c_null IS
   SELECT message_text
   FROM   fnd_new_messages
   WHERE  message_name = 'IGS_PS_NULL'
   AND    application_id = 8405
   AND    LANGUAGE_CODE = USERENV('LANG');

   l_c_null  fnd_new_messages.message_text%TYPE;

   l_n_count NUMBER;
   l_n_from NUMBER;
   l_n_to NUMBER;
   l_b_validation BOOLEAN;
   l_b_status BOOLEAN;
   l_b_wl_validation BOOLEAN;
   l_n_tot_lec NUMBER;
   l_n_tot_lab NUMBER;
   l_n_tot_oth NUMBER;
   rec_unit_dtls c_unit_dtls%ROWTYPE;
   l_c_validation_type igs_ps_unit_ver_all.workload_val_code%TYPE;

 BEGIN
   l_b_validation := TRUE;
   l_b_status :=TRUE;
   l_b_wl_validation := TRUE;

   IF v_tab_usec_tr.EXISTS(1) THEN
      l_tab_uoo(1) := v_tab_usec_tr(1).uoo_id;

     FOR I in 2.. v_tab_usec_tr.COUNT LOOP
         IF NOT isExists(v_tab_usec_tr(I).uoo_id,l_tab_uoo) THEN
           l_tab_uoo(l_tab_uoo.count+1) := v_tab_usec_tr(I).uoo_id;
         END IF;
     END LOOP;

     -- Get the parent unit version.
     OPEN c_unit_dtls (l_tab_uoo(1));
     FETCH c_unit_dtls INTO rec_unit_dtls;
     CLOSE c_unit_dtls;

     -- Get the workload validation type
     l_c_validation_type := igs_ps_fac_credt_wrkload.get_validation_type (rec_unit_dtls.unit_cd, rec_unit_dtls.version_number);

     FOR I in 1.. l_tab_uoo.count LOOP
        l_n_from := fnd_msg_pub.count_msg;
        l_b_validation := TRUE;
        l_b_wl_validation := TRUE;
        OPEN c_count_lead(l_tab_uoo(I));
        FETCH c_count_lead INTO l_n_count;
        CLOSE c_count_lead;
        IF l_n_count < 1 THEN
             fnd_message.set_name('IGS','IGS_PS_ATLST_ONE_LD_INSTRCTR');
             fnd_msg_pub.add;
             l_b_validation :=FALSE;
        ELSIF l_n_count > 1 THEN
             fnd_message.set_name ('IGS','IGS_PS_LEAD_INSTRUCTOR_ONE');
             fnd_msg_pub.add;
             l_b_validation :=FALSE;
        END IF;

        IF l_c_validation_type <> 'NONE' THEN
           OPEN c_count_percent(l_tab_uoo(I));
           FETCH c_count_percent INTO l_n_count;
           CLOSE c_count_percent;

           IF l_n_count <> 100 THEN
              fnd_message.set_name('IGS', 'IGS_PS_US_TCHRESP_NOTTOTAL_100');
              fnd_msg_pub.add;
              l_b_wl_validation :=FALSE;  -- modified as a part of Bug # 3568858.
           END IF;

           IF NOT igs_ps_fac_credt_wrkload.validate_workload(l_tab_uoo(I),l_n_tot_lec,l_n_tot_lab,l_n_tot_oth) THEN
              fnd_message.set_name('IGS','IGS_PS_WKLOAD_VALIDATION');
	      OPEN c_null;
	      FETCH c_null INTO l_c_null;
	      CLOSE c_null;

              IF l_n_tot_lec = -999 THEN
                fnd_message.set_token('WKLOAD_LECTURE',l_c_null);
              ELSE
                fnd_message.set_token('WKLOAD_LECTURE',l_n_tot_lec);
              END IF;

              IF l_n_tot_lab = -999 THEN
                fnd_message.set_token('WKLOAD_LAB',l_c_null);
              ELSE
                fnd_message.set_token('WKLOAD_LAB',l_n_tot_lab);
              END IF;

              IF l_n_tot_oth = -999 THEN
                fnd_message.set_token('WKLOAD_OTHER',l_c_null);
              ELSE
                fnd_message.set_token('WKLOAD_OTHER',l_n_tot_oth);
              END IF;

	      fnd_msg_pub.add;
              l_b_wl_validation :=FALSE;  -- modified as a part of Bug # 3568858.
           END IF;
        END IF;

        IF NOT (l_b_validation AND l_b_wl_validation) THEN
           l_n_to := fnd_msg_pub.count_msg;
           FOR j in 1.. v_tab_usec_tr.COUNT LOOP
               IF l_tab_uoo(I) = v_tab_usec_tr(j).uoo_id AND p_tab_uso_ins(v_tab_usec_tr(j).instr_index).status = 'S' THEN
                  -- Setting the status of the record properly
                  -- Set the status of records as error and return status (l_b_status) as error when
                  -- 1) if the lead instructor validation is fails
                  -- 2) if the percentage allocation or workload validation fails, when the workload validation type is 'DENY'.
                  -- Set the status of record as warning
                  -- 1) if the percentage allocation or workload validation fails, when the workload validation type is 'WARN'.
                  IF NOT l_b_validation THEN
                     -- Failure of lead instructor validation.
                     p_tab_uso_ins(v_tab_usec_tr(j).instr_index).status := 'E';
                     l_b_status :=FALSE;
                  ELSE
                      -- when workload validation type is not equal to NONE
                      IF l_c_validation_type = 'WARN' THEN
                         -- setting the status as warning for the record and not setting the value for l_b_status.
                         p_tab_uso_ins(v_tab_usec_tr(j).instr_index).status := 'W';
                      ELSE  -- workload workload validation type is DENY
                         -- setting the status of the record and l_b_status as error.
                         p_tab_uso_ins(v_tab_usec_tr(j).instr_index).status := 'E';
                         l_b_status :=FALSE;
                      END IF;
                   END IF;

                   p_tab_uso_ins(v_tab_usec_tr(j).instr_index).msg_from := l_n_from +1;
                   p_tab_uso_ins(v_tab_usec_tr(j).instr_index).msg_to := l_n_to;
               END IF;
           END LOOP;
        END IF;
     END LOOP;
     v_tab_usec_tr.delete;
     return l_b_status;
   ELSE
      RETURN TRUE;
   END IF;
 END post_uso_ins_busi;

 PROCEDURE validate_unit_reference(p_unit_ref_rec IN OUT NOCOPY igs_ps_generic_pub.unit_ref_rec_type,
                                   p_n_uoo_id     IN NUMBER,
				   p_n_uso_id     IN NUMBER,
				   p_calling_context IN VARCHAR2) IS
    CURSOR c_ref_flag (cp_c_ref_cd_type  igs_ge_ref_cd_type.reference_cd_type%TYPE) IS
       SELECT  unit_flag,
               unit_section_flag,
               unit_section_occurrence_flag
       FROM igs_ge_ref_cd_type
       WHERE reference_cd_type = cp_c_ref_cd_type;

    rec_ref_flag c_ref_flag%ROWTYPE;

    CURSOR c_occurs(cp_unit_section_occurrence_id igs_ps_usec_occurs_all.unit_section_occurrence_id%TYPE) IS
    SELECT uso.unit_section_occurrence_id
    FROM igs_ps_usec_occurs_all uso
    WHERE (uso.schedule_status IS NOT NULL AND uso.schedule_status NOT IN ('PROCESSING','USER_UPDATE'))
    AND uso.no_set_day_ind ='N'
    AND uso.unit_section_occurrence_id=cp_unit_section_occurrence_id;

    CURSOR c_ref_code (cp_uso_id igs_ps_uso_facility.unit_section_occurrence_id%TYPE) IS
    SELECT 'X'
    FROM   igs_ps_usec_occurs_all
    WHERE  unit_section_occurrence_id = cp_uso_id
    AND    schedule_status = 'PROCESSING';

    l_c_var   VARCHAR2(1);
 BEGIN

    OPEN c_ref_flag(p_unit_ref_rec.reference_cd_type);
    FETCH c_ref_flag INTO rec_ref_flag;
    CLOSE c_ref_flag;

    IF p_unit_ref_rec.data_type = 'UNIT' THEN  -- check whether the reference code type is allowable at unit level

       IF rec_ref_flag.unit_flag IS NULL OR rec_ref_flag.unit_flag = 'N' THEN
          fnd_message.set_name('IGS','IGS_PS_LGCY_UNIT_REF_LVL');
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REF_NA', fnd_message.get, NULL, FALSE);
          p_unit_ref_rec.status := 'E';
       END IF;

    ELSIF p_unit_ref_rec.data_type = 'SECTION' THEN  -- check whether the reference code type is allowable at unit section level

       IF rec_ref_flag.unit_section_flag IS NULL OR rec_ref_flag.unit_section_flag = 'N' THEN
          fnd_message.set_name('IGS','IGS_PS_LGCY_USEC_REF_LVL');
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REF_NA', fnd_message.get, NULL, FALSE);
          p_unit_ref_rec.status := 'E';
       END IF;

    ELSIF p_unit_ref_rec.data_type = 'OCCURRENCE' THEN  -- check whether the reference code type is allowable at unit sectin occurrence level

       IF rec_ref_flag.unit_section_occurrence_flag IS NULL OR rec_ref_flag.unit_section_occurrence_flag = 'N' THEN
          fnd_message.set_name('IGS','IGS_PS_LGCY_OCCUR_REF_LVL');
          igs_ps_validate_lgcy_pkg.set_msg('IGS_PS_LGCY_REF_NA', fnd_message.get, NULL, FALSE);
          p_unit_ref_rec.status := 'E';
       END IF;

       IF p_calling_context <> 'S' THEN
	 OPEN c_ref_code (p_n_uso_id);
	 FETCH c_ref_code INTO l_c_var;
	 IF c_ref_code%FOUND THEN
	    fnd_message.set_name ( 'IGS', 'IGS_PS_SCHEDULING_IN_PROGRESS' );
	    fnd_msg_pub.add;
	    p_unit_ref_rec.status := 'E';
	 END IF;
	 CLOSE c_ref_code;


	 IF p_unit_ref_rec.status = 'S' THEN
	   --Update the schedule status of the occurrence to USER_UPDATE if inserting/updating a record
	   FOR l_occurs_rec IN c_occurs(p_n_uso_id) LOOP
	     igs_ps_usec_schedule.update_occurrence_status(l_occurs_rec.unit_section_occurrence_id,'USER_UPDATE','N');
	   END LOOP;
	 END IF;
       END IF;

    END IF;

    IF p_unit_ref_rec.data_type IN ('SECTION','OCCURRENCE') THEN
      --Check if the unit section is NOT_OFFERED
      IF NOT igs_ps_validate_lgcy_pkg.check_not_offered_usec_status(p_n_uoo_id) THEN
	fnd_message.set_name ( 'IGS', 'IGS_PS_IMP_NOT_ALD_NOT_OFFERED' );
	fnd_msg_pub.add;
	p_unit_ref_rec.status := 'E';
      END IF;

    END IF;

 END validate_unit_reference;

  -- This Function will returns true if waitlist is allowed otherwise false.
  FUNCTION is_waitlist_allowed RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  10-Oct-2003.
    Purpose        :  This procedure returns true if waitlist is allowed at institutional level
                      otherwise false.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

    CURSOR c_wlst_allowed IS
      SELECT waitlist_allowed_flag
      FROM   igs_en_inst_wl_stps;
    l_c_allowed igs_en_inst_wl_stps.waitlist_allowed_flag%TYPE;

  BEGIN
    OPEN c_wlst_allowed;
    FETCH c_wlst_allowed INTO l_c_allowed;
    CLOSE c_wlst_allowed;
    IF l_c_allowed = 'Y' THEN
      RETURN TRUE;
    END IF;
    RETURN FALSE;
  END;

  PROCEDURE get_uso_id( p_uoo_id                IN NUMBER,
                        p_occurrence_identifier IN VARCHAR2,
                        p_uso_id                OUT NOCOPY NUMBER,
                        p_message               OUT NOCOPY VARCHAR2
                       ) AS
  /***********************************************************************************************
    Created By     :  smvk
    Date Created By:  28-Jul-2004.
    Purpose        :  This utility procedure is use to identify the unit section occurrence with the given
                      information.
                      Returns Unit section occurrence identifier in out parameter p_uso_id.
                      Returns error message in the out parameter p_message, if it could not resolve the
                      unit section occurrence uniquely with the provided information.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */
  CURSOR occur IS
  SELECT unit_section_occurrence_id
  FROM  igs_ps_usec_occurs_all
  WHERE uoo_id= p_uoo_id
  AND occurrence_identifier=p_occurrence_identifier;

  BEGIN

    IF p_uoo_id IS NOT NULL AND p_occurrence_identifier IS NOT NULL THEN
       OPEN occur;
       FETCH occur INTO p_uso_id;
       CLOSE occur;
    END IF;
    IF p_uso_id IS NULL THEN
      P_message:= 'IGS_PS_LGCY_USO_CANT_RESOLVE';
    END IF;

  END get_uso_id;


-- to validate whether the person is a staff/faculty member
FUNCTION validate_staff_faculty (p_person_id IN NUMBER ) RETURN BOOLEAN IS
  /***********************************************************************************************
    Created By     :  sarakshi
    Date Created By:  20-Jun-2005.
    Purpose        :  This utility procedure is to validate whether a person is a staff/faculty.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/

 CURSOR C IS
    SELECT 'X'
    FROM  IGS_PE_PERSON_TYPES PT,IGS_PE_TYP_INSTANCES_ALL PTI,HZ_PARTIES HZ
                     WHERE HZ.PARTY_ID = PTI.PERSON_ID
		     AND HZ.PARTY_ID = p_person_id
                     AND PTI.PERSON_TYPE_CODE = PT.PERSON_TYPE_CODE
                     AND PT.SYSTEM_TYPE IN ('STAFF','FACULTY')
                     AND TRUNC(SYSDATE) BETWEEN TRUNC(PTI.START_DATE) AND TRUNC(NVL(PTI.END_DATE,SYSDATE))
                     AND HZ.STATUS = 'A'
    UNION
                     SELECT  'X'
                     FROM PER_PERSON_TYPE_USAGES_F USG,PER_PEOPLE_F PEO,IGS_PE_PER_TYPE_MAP MAP,HZ_PARTIES HZ
                     WHERE HZ.PARTY_ID = peo.party_id
                     AND USG.PERSON_ID = PEO.PERSON_ID
		     AND HZ.PARTY_ID = p_person_id
                     AND USG.PERSON_TYPE_ID = MAP.PER_PERSON_TYPE_ID AND TRUNC(SYSDATE) BETWEEN
                     TRUNC(PEO.EFFECTIVE_START_DATE) AND TRUNC(PEO.EFFECTIVE_END_DATE)
                     AND TRUNC(SYSDATE) BETWEEN TRUNC(USG.EFFECTIVE_START_DATE) AND TRUNC(USG.EFFECTIVE_END_DATE)
                     AND HZ.STATUS = 'A' ;

 l_c_var VARCHAR2(1);

BEGIN
         OPEN c;
         FETCH c INTO l_c_var;
         IF c%FOUND THEN
           RETURN TRUE;
         ELSE
           RETURN FALSE;
         END IF;
         CLOSE C;
END validate_staff_faculty;


FUNCTION isexists(p_n_uoo_id IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                  p_tab_uoo  IN igs_ps_create_generic_pkg.uoo_tbl_type) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sarakshi
    Date Created By:  20-Jun-2005.
    Purpose        :  This utility procedure is to check if a uoo_id exists in a pl/sql table

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/
BEGIN
  FOR i in 1..p_tab_uoo.count LOOP
     IF p_n_uoo_id = p_tab_uoo(i) THEN
	RETURN TRUE;
     END IF;
  END LOOP;
  RETURN FALSE;
END isexists;

FUNCTION  check_import_allowed( p_unit_cd IN VARCHAR2,p_version_number IN NUMBER,p_alternate_code IN VARCHAR2,p_location_cd IN VARCHAR2, p_unit_class IN VARCHAR2,p_uso_id IN NUMBER) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sarakshi
    Date Created By:  20-Jun-2005.
    Purpose        :  This utility procedure is to check whether import is allowed in context to scheduling (overlodad function)

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    15-NOV-2005     Bug# 4721543, Included the the check for cancelled status of unit section.
  ***********************************************************************************************/

	l_c_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE;
        l_n_seq_num  igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE;
        l_d_start_dt igs_ca_inst_all.start_dt%TYPE;
        l_d_end_dt   igs_ca_inst_all.end_dt%TYPE;
        l_c_message  VARCHAR2(30);
	l_n_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE;

        CURSOR c_uso_chk(p_n_uso_id NUMBER) IS
        SELECT   schedule_status,abort_flag
        FROM   igs_ps_usec_occurs_all
        WHERE  unit_section_occurrence_id = p_n_uso_id;


        c_uso_chk_rec  c_uso_chk%ROWTYPE;

        CURSOR c_usec_chk(cp_cal_type IN VARCHAR2,
	                  cp_seq_num  IN NUMBER) IS
        SELECT  abort_flag,unit_section_status
        FROM   igs_ps_unit_ofr_opt_all
        WHERE unit_cd = p_unit_cd
        AND version_number =  p_version_number
        AND cal_type = cp_cal_type
	AND ci_sequence_number =cp_seq_num
        AND location_cd = p_location_cd
        AND unit_class = p_unit_class;

        c_usec_chk_rec c_usec_chk%ROWTYPE;

        CURSOR c_pattern_chk(cp_cal_type igs_ps_unit_ofr_opt_all.cal_type%TYPE,
	                         cp_seq_num igs_ps_unit_ofr_opt_all.ci_sequence_number%TYPE,
				 cp_version_number igs_ps_unit_ver_all.version_number%type,
				 cp_unit_cd igs_ps_unit_ver_all.unit_cd%type
				 ) IS
        SELECT 'X'
        FROM   igs_ps_unit_ofr_pat_all
	WHERE   cal_type= cp_cal_type
	AND     ci_sequence_number=cp_seq_num
	AND     unit_cd = cp_unit_cd
	AND     version_number=cp_version_number
	AND     abort_flag = 'Y';

         c_pattern_chk_rec c_pattern_chk%ROWTYPE;
    BEGIN

      -- Derive Calander Type and Sequence Number
      igs_ge_gen_003.get_calendar_instance ( p_alternate_cd       => p_alternate_code,
                                             p_cal_type           => l_c_cal_type,
                                             p_ci_sequence_number => l_n_seq_num,
                                             p_start_dt           => l_d_start_dt,
                                             p_end_dt             => l_d_end_dt,
                                             p_return_status      => l_c_message );
      IF ( l_c_message <> 'SINGLE' ) THEN
         RETURN TRUE;
      END IF;



     --check if the corresponding occurrence record exists in production table with status as CANCELLED or the record is aborted.

     IF p_uso_id IS NOT NULL THEN

        OPEN c_uso_chk(p_uso_id);
        FETCH c_uso_chk INTO c_uso_chk_rec;
        IF c_uso_chk%FOUND  THEN
          IF (c_uso_chk_rec.schedule_status='CANCELLED' OR c_uso_chk_rec.abort_flag='Y' )  THEN
            CLOSE c_uso_chk;
	    RETURN FALSE;
          ELSE
            CLOSE c_uso_chk;
    	    RETURN TRUE;
          END IF;
	END IF;
        CLOSE c_uso_chk;
     END IF;


     --check if the corresponding unit section record exists in production table which is aborted.
     OPEN c_usec_chk(l_c_cal_type,l_n_seq_num);
     FETCH c_usec_chk INTO c_usec_chk_rec;
     IF c_usec_chk%FOUND  THEN
    	  IF (c_usec_chk_rec.abort_flag='Y' OR c_usec_chk_rec.unit_section_status='CANCELLED' ) THEN
           CLOSE c_usec_chk;
	   RETURN FALSE;
          ELSE
           CLOSE c_usec_chk;
    	   RETURN TRUE;
          END IF;
     END IF;
     CLOSE c_usec_chk;

     --check if the corresponding pattern record exists in production  table which is aborted.
     OPEN c_pattern_chk(l_c_cal_type,l_n_seq_num,p_version_number,p_unit_cd);
     FETCH c_pattern_chk INTO c_pattern_chk_rec;
     IF c_pattern_chk%FOUND THEN
       CLOSE c_pattern_chk;
       RETURN FALSE;
     END IF;
     CLOSE c_pattern_chk;

     RETURN TRUE;

   END check_import_allowed;

  FUNCTION  check_import_allowed( p_uoo_id IN NUMBER,p_uso_id IN NUMBER) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sarakshi
    Date Created By:  20-Jun-2005.
    Purpose        :  This utility procedure is to check whether import is allowed in context to scheduling (overlodad function)

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
    sommukhe    15-NOV-2005     Bug# 4721543, Included the the check for cancelled status of unit section.
  ***********************************************************************************************/
        CURSOR c_uso_chk(cp_n_uso_id IN NUMBER) IS
        SELECT   schedule_status,abort_flag
        FROM   igs_ps_usec_occurs_all
        WHERE  unit_section_occurrence_id = cp_n_uso_id;
        c_uso_chk_rec  c_uso_chk%ROWTYPE;

        CURSOR c_usec_chk(cp_n_uoo_id IN NUMBER) IS
        SELECT  abort_flag,unit_section_status
        FROM   igs_ps_unit_ofr_opt_all
        WHERE  uoo_id = cp_n_uoo_id;
        c_usec_chk_rec c_usec_chk%ROWTYPE;

        CURSOR c_pattern_chk(cp_n_uoo_id IN NUMBER) IS
        SELECT 'X'
        FROM   igs_ps_unit_ofr_pat_all pt, igs_ps_unit_ofr_opt_all uoo
	WHERE  uoo.uoo_id=  cp_n_uoo_id
	AND    uoo.unit_cd=pt.unit_cd
	AND    uoo.version_number=pt.version_number
	AND    uoo.cal_type= pt.cal_type
	AND    uoo.ci_sequence_number=pt.ci_sequence_number
	AND    pt.abort_flag = 'Y';

       c_pattern_chk_rec c_pattern_chk%ROWTYPE;
    BEGIN

     --check if the corresponding occurrence record exists in production table with status as CANCELLED or the record is aborted.
     IF p_uso_id IS NOT NULL THEN

        OPEN c_uso_chk(p_uso_id);
        FETCH c_uso_chk INTO c_uso_chk_rec;
        IF c_uso_chk%FOUND  THEN
          IF (c_uso_chk_rec.schedule_status='CANCELLED' OR c_uso_chk_rec.abort_flag='Y' )  THEN
            CLOSE c_uso_chk;
	    RETURN FALSE;
          ELSE
            CLOSE c_uso_chk;
    	    RETURN TRUE;
          END IF;
	END IF;
        CLOSE c_uso_chk;
     END IF;


     --check if the corresponding unit section record exists in production table which is aborted.
     OPEN c_usec_chk(p_uoo_id);
     FETCH c_usec_chk INTO c_usec_chk_rec;
     IF c_usec_chk%FOUND  THEN
    	  IF (c_usec_chk_rec.abort_flag='Y' OR c_usec_chk_rec.unit_section_status='CANCELLED' ) THEN
           CLOSE c_usec_chk;
	   RETURN FALSE;
          ELSE
           CLOSE c_usec_chk;
    	   RETURN TRUE;
          END IF;
     END IF;
     CLOSE c_usec_chk;

     --check if the corresponding pattern record exists in production  table which is aborted.
     OPEN c_pattern_chk(p_uoo_id);
     FETCH c_pattern_chk INTO c_pattern_chk_rec;
     IF c_pattern_chk%FOUND THEN
       CLOSE c_pattern_chk;
       RETURN FALSE;
     END IF;
     CLOSE c_pattern_chk;

     RETURN TRUE;

   END check_import_allowed;


   FUNCTION check_not_offered_usec_status(p_uoo_id IN NUMBER ) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sarakshi
    Date Created By:  20-Jun-2005.
    Purpose        :  This utility procedure is to check whether the unit section status is NOT_OFFERED

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/
    CURSOR c_usec_chk(cp_n_uoo_id IN NUMBER) IS
    SELECT  'X'
    FROM   igs_ps_unit_ofr_opt_all
    WHERE  uoo_id = cp_n_uoo_id
    AND    unit_section_status='NOT_OFFERED';
    l_c_var VARCHAR2(1);
  BEGIN
    OPEN c_usec_chk(p_uoo_id);
    FETCH c_usec_chk INTO l_c_var;
    IF c_usec_chk%FOUND THEN
      CLOSE c_usec_chk;
      RETURN FALSE;
    ELSE
      CLOSE c_usec_chk;
      RETURN TRUE;
    END IF;

  END check_not_offered_usec_status;

  FUNCTION boundary_check_number( p_n_value IN NUMBER,p_n_int_part IN NUMBER,p_n_dec_part IN NUMBER) RETURN BOOLEAN AS
  /***********************************************************************************************
    Created By     :  sarakshi
    Date Created By:  11-Jul-2005.
    Purpose        :  This utility procedure is to check whether a number is falling in a specifuc format mask

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ***********************************************************************************************/
    n2 NUMBER;
    a VARCHAR2(100);
    b VARCHAR2(100);
    c VARCHAR2(100);
  BEGIN
    a:= TO_CHAR(p_n_value);
    n2:= instr(a,'.');
    IF n2 > 0 THEN
      b:= substr(a,1,n2);
      c:= substr(a,n2);

      IF NVL(length(b),0) > (p_n_int_part+1)  OR  NVL(length(c),0) > (p_n_dec_part+1) THEN
        RETURN FALSE;
      END IF;

    END IF;

    RETURN TRUE;

  END boundary_check_number;

END igs_ps_validate_lgcy_pkg;

/
