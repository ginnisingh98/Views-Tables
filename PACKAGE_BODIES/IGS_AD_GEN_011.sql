--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_011
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_011" AS
/* $Header: IGSAD11B.pls 120.7 2006/02/21 22:51:09 arvsrini ship $ */
/*change history
   who        when            what
   npalanis   23-OCT-2002     Bug : 2608630
                              references to igs_pe_code_classes are removed
   npalanis   23-OCT-2002     Bug : 2547368
                              Defaulting arguments in funtion and procedure definitions removed
   rbezawad   30-Oct-2004    Added logic to properly handle the security Policy errors IGS_SC_POLICY_EXCEPTION
                              and IGS_SC_POLICY_UPD_DEL_EXCEP   w.r.t. bug fix 3919112.
   sjlaport   17-Feb-2005     Removed function Admp_Ins_Eap_Eitpi for IGR migration (bug 4114493)
*/
Procedure Admp_Ins_Acai_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_new_adm_cal_type IN VARCHAR2 ,
  p_old_adm_cal_type IN VARCHAR2 ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_new_course_cd IN VARCHAR2 ,
  p_old_course_cd IN VARCHAR2 ,
  p_new_crv_version_number IN NUMBER ,
  p_old_crv_version_number IN NUMBER ,
  p_new_location_cd IN VARCHAR2 ,
  p_old_location_cd IN VARCHAR2 ,
  p_new_attendance_mode IN VARCHAR2 ,
  p_old_attendance_mode IN VARCHAR2 ,
  p_new_attendance_type IN VARCHAR2 ,
  p_old_attendance_type IN VARCHAR2 ,
  p_new_unit_set_cd IN VARCHAR2 ,
  p_old_unit_set_cd IN VARCHAR2 ,
  p_new_us_version_number IN NUMBER ,
  p_old_us_version_number IN NUMBER ,
  p_new_preference_number IN NUMBER ,
  p_old_preference_number IN NUMBER ,
  p_new_adm_doc_status IN VARCHAR2 ,
  p_old_adm_doc_status IN VARCHAR2 ,
  p_new_adm_entry_qual_status IN VARCHAR2 ,
  p_old_adm_entry_qual_status IN VARCHAR2 ,
  p_new_late_adm_fee_status IN VARCHAR2 ,
  p_old_late_adm_fee_status IN VARCHAR2 ,
  p_new_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_new_otcm_sts_auth_prsn_id IN NUMBER ,
  p_old_otcm_sts_auth_prsn_id IN NUMBER ,
  p_new_adm_otcm_status_auth_dt IN DATE ,
  p_old_adm_otcm_status_auth_dt IN DATE ,
  p_new_adm_otcm_status_reason IN VARCHAR2 ,
  p_old_adm_otcm_status_reason IN VARCHAR2 ,
  p_new_offer_dt IN DATE ,
  p_old_offer_dt IN DATE ,
  p_new_offer_response_dt IN DATE ,
  p_old_offer_response_dt IN DATE ,
  p_new_prpsd_commencement_dt IN DATE ,
  p_old_prpsd_commencement_dt IN DATE ,
  p_new_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_old_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_new_cndtnl_offer_stsfd_dt IN DATE ,
  p_old_cndtnl_offer_stsfd_dt IN DATE ,
  p_new_cndtnl_off_must_be_stsfd IN VARCHAR2 ,
  p_old_cndtnl_off_must_be_stsfd IN VARCHAR2 ,
  p_new_adm_offer_resp_status IN VARCHAR2 ,
  p_old_adm_offer_resp_status IN VARCHAR2 ,
  p_new_actual_response_dt IN DATE ,
  p_old_actual_response_dt IN DATE ,
  p_new_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_new_deferred_adm_cal_type IN VARCHAR2 ,
  p_old_deferred_adm_cal_type IN VARCHAR2 ,
  p_new_deferred_adm_ci_seq_num IN NUMBER ,
  p_old_deferred_adm_ci_seq_num IN NUMBER ,
  p_new_deferred_tracking_id IN NUMBER ,
  p_old_deferred_tracking_id IN NUMBER ,
  p_new_ass_rank IN NUMBER ,
  p_old_ass_rank IN NUMBER ,
  p_new_secondary_ass_rank IN NUMBER ,
  p_old_secondary_ass_rank IN NUMBER ,
  p_new_intrntnl_acpt_advice_num IN NUMBER ,
  p_old_intrntnl_acpt_advice_num IN NUMBER ,
  p_new_ass_tracking_id IN NUMBER ,
  p_old_ass_tracking_id IN NUMBER ,
  p_new_fee_cat IN VARCHAR2 ,
  p_old_fee_cat IN VARCHAR2 ,
  p_new_hecs_payment_option IN VARCHAR2 ,
  p_old_hecs_payment_option IN VARCHAR2 ,
  p_new_expected_completion_yr IN NUMBER ,
  p_old_expected_completion_yr IN NUMBER ,
  p_new_expected_completion_perd IN VARCHAR2 ,
  p_old_expected_completion_perd IN VARCHAR2 ,
  p_new_correspondence_cat IN VARCHAR2 ,
  p_old_correspondence_cat IN VARCHAR2 ,
  p_new_enrolment_cat IN VARCHAR2 ,
  p_old_enrolment_cat IN VARCHAR2 ,
  p_new_funding_source IN VARCHAR2 ,
  p_old_funding_source IN VARCHAR2 ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE ,
  p_new_applicant_acptnce_cndtn IN VARCHAR2 ,
  p_old_applicant_acptnce_cndtn IN VARCHAR2 ,
  p_new_cndtnl_offer_cndtn IN VARCHAR2 ,
  p_old_cndtnl_offer_cndtn IN VARCHAR2 ,
  p_new_appl_inst_status IN VARCHAR2 DEFAULT NULL,                        --arvsrini igsm
  p_old_appl_inst_status IN VARCHAR2 DEFAULT NULL,
  P_NEW_DECISION_DATE            DATE     DEFAULT NULL,        -- begin APADEGAL adtd001 igs.m
  P_OLD_DECISION_DATE            DATE     DEFAULT NULL,
  P_NEW_DECISION_MAKE_ID         NUMBER   DEFAULT NULL,
  P_OLD_DECISION_MAKE_ID         NUMBER   DEFAULT NULL,
  P_NEW_DECISION_REASON_ID       NUMBER   DEFAULT NULL,
  P_OLD_DECISION_REASON_ID       NUMBER   DEFAULT NULL,
  P_NEW_PENDING_REASON_ID        NUMBER   DEFAULT NULL,
  P_OLD_PENDING_REASON_ID        NUMBER   DEFAULT NULL,
  P_NEW_WAITLIST_STATUS          VARCHAR2 DEFAULT NULL,
  P_OLD_WAITLIST_STATUS          VARCHAR2 DEFAULT NULL,
  P_NEW_WAITLIST_RANK            VARCHAR2 DEFAULT NULL,
  P_OLD_WAITLIST_RANK            VARCHAR2 DEFAULT NULL,
  P_NEW_FUTURE_ACAD_CAL_TYPE     VARCHAR2 DEFAULT NULL,
  P_OLD_FUTURE_ACAD_CAL_TYPE     VARCHAR2 DEFAULT NULL,
  P_NEW_FUTURE_ACAD_CI_SEQ_NUM         NUMBER   DEFAULT NULL,
  P_OLD_FUTURE_ACAD_CI_SEQ_NUM         NUMBER   DEFAULT NULL,
  P_NEW_FUTURE_ADM_CAL_TYPE      VARCHAR2 DEFAULT NULL,
  P_OLD_FUTURE_ADM_CAL_TYPE      VARCHAR2 DEFAULT NULL,
  P_NEW_FUTURE_ADM_CI_SEQ_NUM         NUMBER   DEFAULT NULL,
  P_OLD_FUTURE_ADM_CI_SEQ_NUM         NUMBER   DEFAULT NULL,
  P_NEW_DEF_ACAD_CAL_TYPE        VARCHAR2 DEFAULT NULL,
  P_OLD_DEF_ACAD_CAL_TYPE        VARCHAR2 DEFAULT NULL,
  P_NEW_DEF_ACAD_CI_SEQ_NUM         NUMBER   DEFAULT NULL,
  P_OLD_DEF_ACAD_CI_SEQ_NUM         NUMBER   DEFAULT NULL,
  P_NEW_DECLINE_OFR_REASON       VARCHAR2 DEFAULT NULL,
  P_OLD_DECLINE_OFR_REASON       VARCHAR2 DEFAULT NULL    -- end APADEGAL adtd001 igs.m

 )
IS
    gv_other_detail     VARCHAR2(255);

        --Local variables to check if the Security Policy exception already set or not.  Ref: Bug 3919112
        l_sc_encoded_text   VARCHAR2(4000);
        l_sc_msg_count NUMBER;
        l_sc_msg_index NUMBER;
        l_sc_app_short_name VARCHAR2(50);
        l_sc_message_name   VARCHAR2(50);
        lv_old_update_on    DATE := p_old_update_on;


BEGIN   -- admp_ins_acai_hist
    -- Routine to create a history for the IGS_AD_PS_APPL_INST table.
DECLARE
    v_changed_flag      BOOLEAN DEFAULT FALSE;
    v_acaih_rec     IGS_AD_PS_APLINSTHST%ROWTYPE;
    lv_rowid        VARCHAR2(25);
    l_org_id        NUMBER(15);
        l_old_hist_start_dt     VARCHAR2(2);
         CURSOR c_old_hist_dt
         IS
             SELECT 'x'
             FROM IGS_AD_PS_APLINSTHST
             WHERE person_id = p_person_id
             AND   admission_appl_number = p_admission_appl_number
             AND   nominated_course_cd = p_nominated_course_cd
             AND   sequence_number = p_sequence_number
             AND   hist_start_dt = p_old_update_on;

          -- begin apadegal adtd001 igs.m
           CURSOR  cur_ad_ps_appl (  cp_person_id         igs_ad_ps_appl.person_id%type ,
                            cp_admission_appl_number   igs_ad_ps_appl.admission_appl_number%type ,
                            cp_nominated_course_cd     igs_ad_ps_appl.nominated_course_cd%type ) IS
           SELECT req_for_reconsideration_ind
           FROM   igs_ad_ps_appl
           WHERE  person_id = cp_person_id   and
                  admission_appl_number = cp_admission_appl_number and
                  nominated_course_cd = cp_nominated_course_cd;
          -- end  apadegal adtd001 igs.m

          CURSOR c_latest_hist_dt IS
            SELECT MAX(hist_start_dt) max_hist_start_dt, MAX(hist_end_dt) max_hist_end_dt
            FROM IGS_AD_PS_APLINSTHST
            WHERE person_id = p_person_id
            AND   admission_appl_number = p_admission_appl_number
            AND   nominated_course_cd = p_nominated_course_cd
            AND   sequence_number = p_sequence_number;

          l_latest_hist_dt c_latest_hist_dt%ROWTYPE;

BEGIN
    -- Check if any of the old IGS_AD_PS_APPL_INST values are different from
    -- the associated new IGS_AD_PS_APPL_INST values.
    IF NVL(p_new_adm_cal_type,'NULL') <> NVL(p_old_adm_cal_type,'NULL') THEN
        v_acaih_rec.adm_cal_type := p_old_adm_cal_type;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_adm_ci_sequence_number,-1) <>
            NVL(p_old_adm_ci_sequence_number, -1) THEN
        v_acaih_rec.adm_ci_sequence_number := p_old_adm_ci_sequence_number;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_course_cd <> p_old_course_cd THEN
        v_acaih_rec.course_cd := p_old_course_cd;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_crv_version_number <> p_old_crv_version_number THEN
        v_acaih_rec.crv_version_number := p_old_crv_version_number;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_location_cd,'NULL') <> NVL(p_old_location_cd,'NULL') THEN
        v_acaih_rec.location_cd := p_old_location_cd;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_attendance_mode,'NULL') <>
            NVL(p_old_attendance_mode,'NULL') THEN
        v_acaih_rec.attendance_mode := p_old_attendance_mode;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_attendance_type,'NULL') <>
            NVL(p_old_attendance_type,'NULL') THEN
        v_acaih_rec.attendance_type := p_old_attendance_type;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_unit_set_cd, 'NULL') <>  NVL(p_old_unit_set_cd, 'NULL') THEN
        v_acaih_rec.unit_set_cd := p_old_unit_set_cd;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_us_version_number, -1) <> NVL(p_old_us_version_number, -1) THEN
        v_acaih_rec.us_version_number := p_old_us_version_number;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_preference_number, -1) <> NVL(p_old_preference_number, -1) THEN
        v_acaih_rec.preference_number := p_old_preference_number;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_adm_doc_status <> p_old_adm_doc_status THEN
        v_acaih_rec.adm_doc_status := p_old_adm_doc_status;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_adm_entry_qual_status <> p_old_adm_entry_qual_status THEN
        v_acaih_rec.adm_entry_qual_status := p_old_adm_entry_qual_status;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_late_adm_fee_status <> p_old_late_adm_fee_status THEN
        v_acaih_rec.late_adm_fee_status := p_old_late_adm_fee_status;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_adm_outcome_status <> p_old_adm_outcome_status THEN
        v_acaih_rec.adm_outcome_status := p_old_adm_outcome_status;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_otcm_sts_auth_prsn_id,-1) <>
            NVL(p_old_otcm_sts_auth_prsn_id,-1) THEN
        v_acaih_rec.adm_otcm_status_auth_person_id := p_old_otcm_sts_auth_prsn_id;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_adm_otcm_status_auth_dt,SYSDATE) <>
            NVL(p_old_adm_otcm_status_auth_dt, SYSDATE) THEN
        v_acaih_rec.adm_outcome_status_auth_dt := p_old_adm_otcm_status_auth_dt;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_adm_otcm_status_reason,'NULL') <>
            NVL(p_old_adm_otcm_status_reason,'NULL') THEN
        v_acaih_rec.adm_outcome_status_reason := p_old_adm_otcm_status_reason;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_offer_dt, SYSDATE) <> NVL(p_old_offer_dt, SYSDATE) THEN
        v_acaih_rec.offer_dt := p_old_offer_dt;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_offer_response_dt,SYSDATE) <>
            NVL(p_old_offer_response_dt,SYSDATE) THEN
        v_acaih_rec.offer_response_dt := p_old_offer_response_dt;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_prpsd_commencement_dt, SYSDATE) <>
            NVL(p_old_prpsd_commencement_dt, SYSDATE) THEN
        v_acaih_rec.prpsd_commencement_dt := p_old_prpsd_commencement_dt;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_adm_cndtnl_offer_status <> p_old_adm_cndtnl_offer_status THEN
        v_acaih_rec.adm_cndtnl_offer_status := p_old_adm_cndtnl_offer_status;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_cndtnl_offer_stsfd_dt,SYSDATE) <>
             NVL(p_old_cndtnl_offer_stsfd_dt,SYSDATE) THEN
        v_acaih_rec.cndtnl_offer_satisfied_dt := p_old_cndtnl_offer_stsfd_dt;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_cndtnl_off_must_be_stsfd, 'NULL') <>
            NVL(p_old_cndtnl_off_must_be_stsfd, 'NULL') THEN
        v_acaih_rec.cndtnl_offer_must_be_stsfd_ind := p_old_cndtnl_off_must_be_stsfd;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_adm_offer_resp_status <> p_old_adm_offer_resp_status THEN
        v_acaih_rec.adm_offer_resp_status := p_old_adm_offer_resp_status;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_actual_response_dt,SYSDATE) <>
            NVL(p_old_actual_response_dt,SYSDATE) THEN
        v_acaih_rec.actual_response_dt := p_old_actual_response_dt;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_adm_offer_dfrmnt_status <> p_old_adm_offer_dfrmnt_status THEN
        v_acaih_rec.adm_offer_dfrmnt_status := p_old_adm_offer_dfrmnt_status;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_deferred_adm_cal_type,'NULL') <>
            NVL(p_old_deferred_adm_cal_type,'NULL') THEN
        v_acaih_rec.deferred_adm_cal_type := p_old_deferred_adm_cal_type;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_deferred_adm_ci_seq_num,-1) <>
            NVL(p_old_deferred_adm_ci_seq_num,-1) THEN
        v_acaih_rec.deferred_adm_ci_sequence_num := p_old_deferred_adm_ci_seq_num;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_deferred_tracking_id,-1) <>
            NVL(p_old_deferred_tracking_id,-1) THEN
        v_acaih_rec.deferred_tracking_id := p_old_deferred_tracking_id;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_ass_rank,-1) <> NVL(p_old_ass_rank,-1) THEN
        v_acaih_rec.ass_rank := p_old_ass_rank;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_secondary_ass_rank,-1) <> NVL(p_old_secondary_ass_rank,-1) THEN
        v_acaih_rec.secondary_ass_rank := p_old_secondary_ass_rank;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_intrntnl_acpt_advice_num,-1) <>
            NVL(p_old_intrntnl_acpt_advice_num,-1) THEN
        v_acaih_rec.intrntnl_acceptance_advice_num := p_old_intrntnl_acpt_advice_num;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_ass_tracking_id,-1) <> NVL(p_old_ass_tracking_id,-1) THEN
        v_acaih_rec.ass_tracking_id := p_old_ass_tracking_id;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_fee_cat,'NULL') <> NVL(p_old_fee_cat,'NULL') THEN
        v_acaih_rec.fee_cat := p_old_fee_cat;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_funding_source, 'NULL') <>
            NVL(p_old_funding_source, 'NULL') THEN
        v_acaih_rec.funding_source := p_old_funding_source;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_hecs_payment_option,'NULL') <>
            NVL(p_old_hecs_payment_option,'NULL') THEN
        v_acaih_rec.hecs_payment_option := p_old_hecs_payment_option;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_expected_completion_yr,-1) <>
            NVL(p_old_expected_completion_yr,-1) THEN
        v_acaih_rec.expected_completion_yr := p_old_expected_completion_yr;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_expected_completion_perd,'NULL') <>
            NVL(p_old_expected_completion_perd,'NULL') THEN
        v_acaih_rec.expected_completion_perd := p_old_expected_completion_perd;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_correspondence_cat,'NULL') <>
            NVL(p_old_correspondence_cat,'NULL') THEN
        v_acaih_rec.correspondence_cat := p_old_correspondence_cat;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_enrolment_cat,'NULL') <> NVL(p_old_enrolment_cat,'NULL') THEN
        v_acaih_rec.enrolment_cat := p_old_enrolment_cat;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_applicant_acptnce_cndtn,'NULL') <>
            NVL(p_old_applicant_acptnce_cndtn,'NULL') THEN
        v_acaih_rec.applicant_acptnce_cndtn := p_old_applicant_acptnce_cndtn;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_cndtnl_offer_cndtn, 'NULL') <>
            NVL(p_old_cndtnl_offer_cndtn, 'NULL') THEN
        v_acaih_rec.cndtnl_offer_cndtn := p_old_cndtnl_offer_cndtn;
        v_changed_flag := TRUE;
    END IF;

    IF NVL(p_new_appl_inst_status, 'NULL') <>                                -- IGS.M arvsrini
            NVL(p_old_appl_inst_status, 'NULL') THEN
        v_acaih_rec.appl_inst_status := p_old_appl_inst_status;
        v_changed_flag := TRUE;
    END IF;

                                                         -- begin apadegal td001 igsm
  IF NVL(p_new_decision_Make_Id, -1) <>
           NVL(p_old_decision_Make_Id, -1) THEN
       v_acaih_rec.decision_Make_Id := p_old_decision_Make_Id;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_decision_Date, IGS_GE_DATE.IGSDATE('1900/01/01')) <>
           NVL(p_old_decision_Date, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
       v_acaih_rec.decision_Date := p_old_decision_Date;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_decision_reason_id, -1) <>
           NVL(p_old_decision_reason_id, -1) THEN
       v_acaih_rec.decision_reason_id := p_old_decision_reason_id;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_pending_reason_id, -1) <>
           NVL(p_old_pending_reason_id, -1) THEN
       v_acaih_rec.pending_reason_id := p_old_pending_reason_id;
       v_changed_flag := TRUE;
  END IF;
  IF NVL(p_new_waitlist_status, 'NULL') <>
           NVL(p_old_waitlist_status, 'NULL') THEN
       v_acaih_rec.waitlist_status := p_old_waitlist_status;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_waitlist_rank, 'NULL') <>
           NVL(p_old_waitlist_rank, 'NULL') THEN
       v_acaih_rec.waitlist_rank := p_old_waitlist_rank;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_Future_Acad_Cal_Type, -1) <>
           NVL(p_old_Future_Acad_Cal_Type, -1) THEN
       v_acaih_rec.Future_Acad_Cal_Type := p_old_Future_Acad_Cal_Type;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_FUTURE_ACAD_CI_SEQ_NUM, -1) <>
           NVL(p_old_FUTURE_ACAD_CI_SEQ_NUM, -1) THEN
       v_acaih_rec.Future_Acad_Ci_Sequence_Num := p_old_FUTURE_ACAD_CI_SEQ_NUM;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_FUTURE_ADM_CAL_TYPE, -1) <>
           NVL(p_old_FUTURE_ADM_CAL_TYPE, -1) THEN
       v_acaih_rec.Future_Adm_Cal_Type := p_old_FUTURE_ADM_CAL_TYPE;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_FUTURE_ADM_CI_SEQ_NUM, -1) <>
           NVL(p_old_FUTURE_ADM_CI_SEQ_NUM, -1) THEN
       v_acaih_rec.Future_Adm_Ci_Sequence_Num := p_old_FUTURE_ADM_CI_SEQ_NUM;
       v_changed_flag := TRUE;
  END IF;

   IF NVL(p_new_def_acad_cal_type, -1) <>
           NVL(p_old_Def_acad_cal_type, -1) THEN
       v_acaih_rec.Def_acad_cal_type := p_old_Def_acad_cal_type;
       v_changed_flag := TRUE;
  END IF;

  IF NVL(p_new_DEF_ACAD_CI_SEQ_NUM, -1) <>
           NVL(p_old_DEF_ACAD_CI_SEQ_NUM, -1) THEN
       v_acaih_rec.def_Acad_Ci_Sequence_Num := p_old_DEF_ACAD_CI_SEQ_NUM;
       v_changed_flag := TRUE;
  END IF;

   IF NVL(p_new_DECLINE_OFR_REASON, 'NULL') <>
           NVL(p_old_DECLINE_OFR_REASON, 'NULL') THEN
       v_acaih_rec.DECLINE_OFR_REASON := p_old_DECLINE_OFR_REASON;
       v_changed_flag := TRUE;
  END IF;
                                                                -- end apadegal td001 igsm


    OPEN cur_ad_ps_appl (p_person_id,p_admission_appl_number,p_nominated_course_cd);
    FETCH cur_ad_ps_appl INTO v_acaih_rec.RECONSIDER_FLAG ;
    CLOSE cur_ad_ps_appl;


    IF v_changed_flag = TRUE THEN




        -- Create and IGS_AD_PS_APLINSTHST history record.
        v_acaih_rec.person_id := p_person_id;
        v_acaih_rec.admission_appl_number :=p_admission_appl_number;
        v_acaih_rec.nominated_course_cd := p_nominated_course_cd;
        v_acaih_rec.sequence_number := p_sequence_number;
        v_acaih_rec.hist_start_dt := p_old_update_on;
        v_acaih_rec.hist_end_dt := p_new_update_on;
        v_acaih_rec.hist_who := p_old_update_who;



    OPEN c_latest_hist_dt;
    FETCH c_latest_hist_dt INTO l_latest_hist_dt;
    CLOSE c_latest_hist_dt;


    IF l_latest_hist_dt.max_hist_start_dt IS NOT NULL THEN
       IF (l_latest_hist_dt.max_hist_start_dt = p_old_update_on) THEN
                  -- add one second from the hist_start_dt value
                  -- to avoid a primary key constraint from occurring
                  -- when saving the record.  Modified as part of Bug:2315674
                  v_acaih_rec.hist_start_dt := v_acaih_rec.hist_start_dt +1 / (60*24*60);
                  v_acaih_rec.hist_end_dt := v_acaih_rec.hist_end_dt +1 / (60*24*60);
       ELSIF (l_latest_hist_dt.max_hist_start_dt > p_old_update_on) THEN
                  v_acaih_rec.hist_start_dt := l_latest_hist_dt.max_hist_start_dt +1 / (60*24*60);
		  IF (l_latest_hist_dt.max_hist_end_dt >= p_new_update_on) THEN
		    v_acaih_rec.hist_end_dt := l_latest_hist_dt.max_hist_end_dt + 1 / (60*24*60);
		  END IF;
       END IF;
    END IF;



    l_org_id := igs_ge_gen_003.get_org_id;
        IGS_AD_PS_APLINSTHST_Pkg.Insert_Row (
            X_Mode                              => 'R',
            X_RowId                             => lv_rowid,
            X_Person_Id                         => v_acaih_rec.person_id,
            X_Admission_Appl_Number             => v_acaih_rec.admission_appl_number,
            X_Nominated_Course_Cd               => v_acaih_rec.nominated_course_cd,
            X_Sequence_Number                   => v_acaih_rec.sequence_number,
            X_Hist_Start_Dt                     => v_acaih_rec.hist_start_dt,
            X_Hist_End_Dt                       => v_acaih_rec.hist_end_dt,
            X_Hist_Who                          => v_acaih_rec.hist_who,
            X_Hist_Offer_Round_Number           => Null,
            X_Adm_Cal_Type                      => v_acaih_rec.adm_cal_type,
            X_Adm_Ci_Sequence_Number            => v_acaih_rec.adm_ci_sequence_number,
            X_Course_Cd                         => v_acaih_rec.course_cd,
            X_Crv_Version_Number                => v_acaih_rec.crv_version_number,
            X_Location_Cd                       => v_acaih_rec.location_cd,
            X_Attendance_Mode                   => v_acaih_rec.attendance_mode,
            X_Attendance_Type                   => v_acaih_rec.attendance_type,
            X_Unit_Set_Cd                       => v_acaih_rec.unit_set_cd,
            X_Us_Version_Number                 => v_acaih_rec.us_version_number,
            X_Preference_Number                 => v_acaih_rec.preference_number,
            X_Adm_Doc_Status                    => v_acaih_rec.adm_doc_status,
            X_Adm_Entry_Qual_Status             => v_acaih_rec.adm_entry_qual_status,
            X_Late_Adm_Fee_Status               => v_acaih_rec.late_adm_fee_status,
            X_Adm_Outcome_Status                => v_acaih_rec.adm_outcome_status,
            X_ADM_OTCM_STATUS_AUTH_PER_ID       => v_acaih_rec.adm_otcm_status_auth_person_id,
            X_Adm_Outcome_Status_Auth_Dt        => v_acaih_rec.adm_outcome_status_auth_dt,
            X_Adm_Outcome_Status_Reason         => v_acaih_rec.adm_outcome_status_reason,
            X_Offer_Dt                          => v_acaih_rec.offer_dt,
            X_Offer_Response_Dt                 => v_acaih_rec.offer_response_dt,
            X_Prpsd_Commencement_Dt             => v_acaih_rec.prpsd_commencement_dt,
            X_Adm_Cndtnl_Offer_Status           => v_acaih_rec.adm_cndtnl_offer_status,
            X_Cndtnl_Offer_Satisfied_Dt         => v_acaih_rec.cndtnl_offer_satisfied_dt,
            X_CNDTNL_OFR_MUST_BE_STSFD_IND      => v_acaih_rec.cndtnl_offer_must_be_stsfd_ind,
            X_Adm_Offer_Resp_Status             => v_acaih_rec.adm_offer_resp_status,
            X_Actual_Response_Dt                => v_acaih_rec.actual_response_dt,
            X_Adm_Offer_Dfrmnt_Status           => v_acaih_rec.adm_offer_dfrmnt_status,
            X_Deferred_Adm_Cal_Type             => v_acaih_rec.deferred_adm_cal_type,
            X_Deferred_Adm_Ci_Sequence_Num      => v_acaih_rec.deferred_adm_ci_sequence_num,
            X_Deferred_Tracking_Id              => v_acaih_rec.deferred_tracking_id,
            X_Ass_Rank                          => v_acaih_rec.ass_rank,
            X_Secondary_Ass_Rank                => v_acaih_rec.secondary_ass_rank,
            X_INTRNTNL_ACCEPT_ADVICE_NUM        => v_acaih_rec.intrntnl_acceptance_advice_num,
            X_Ass_Tracking_Id                   => v_acaih_rec.ass_tracking_id,
            X_Fee_Cat                           => v_acaih_rec.fee_cat,
            X_Hecs_Payment_Option               => v_acaih_rec.hecs_payment_option,
            X_Expected_Completion_Yr            => v_acaih_rec.expected_completion_yr,
            X_Expected_Completion_Perd          => v_acaih_rec.expected_completion_perd,
            X_Correspondence_Cat                => v_acaih_rec.correspondence_cat,
            X_Enrolment_Cat                     => v_acaih_rec.enrolment_cat,
            X_Funding_Source                    => v_acaih_rec.funding_source,
            X_Applicant_Acptnce_Cndtn           => v_acaih_rec.applicant_acptnce_cndtn,
            X_Cndtnl_Offer_Cndtn                => v_acaih_rec.cndtnl_offer_cndtn,
            X_Org_Id                                => l_org_id,
            X_Appl_inst_status                        => v_acaih_rec.appl_inst_status,                        --arvsrini igsm
            X_DECISION_DATE                     => v_acaih_rec.DECISION_DATE,            -- begin APADEGAL adtd001 igs.m
            X_DECISION_MAKE_ID                  => v_acaih_rec.DECISION_MAKE_ID,
            X_DECISION_REASON_ID                => v_acaih_rec.DECISION_REASON_ID,
            X_PENDING_REASON_ID                 => v_acaih_rec.PENDING_REASON_ID,
            X_WAITLIST_STATUS                   => v_acaih_rec.WAITLIST_STATUS,
            X_WAITLIST_RANK                     => v_acaih_rec.WAITLIST_RANK,
            X_FUTURE_ACAD_CAL_TYPE              => v_acaih_rec.FUTURE_ACAD_CAL_TYPE,
            X_FUTURE_ACAD_CI_SEQUENCE_NUM       => v_acaih_rec.FUTURE_ACAD_CI_SEQUENCE_NUM,
            X_FUTURE_ADM_CAL_TYPE               => v_acaih_rec.FUTURE_ADM_CAL_TYPE,
            X_FUTURE_ADM_CI_SEQUENCE_NUM        => v_acaih_rec.FUTURE_ADM_CI_SEQUENCE_NUM,
            X_DEF_ACAD_CAL_TYPE                 => v_acaih_rec.DEF_ACAD_CAL_TYPE,
            X_DEF_ACAD_CI_SEQUENCE_NUM          => v_acaih_rec.DEF_ACAD_CI_SEQUENCE_NUM,
            X_RECONSIDER_FLAG                   => v_acaih_rec.RECONSIDER_FLAG,
            X_DECLINE_OFR_REASON                => v_acaih_rec.DECLINE_OFR_REASON           -- end APADEGAL adtd001 igs.m

        );

    END IF;
END;
EXCEPTION
    WHEN APP_EXCEPTION.APPLICATION_EXCEPTION THEN
         IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'igs.plsql.igs_ad_gen_011.admp_ins_acai_hist.APP_EXP','Application Exception raised with code '||SQLCODE||' and error '||SQLERRM);
         END IF;
    WHEN OTHERS THEN

            --Loop through all messages in stack to check if there is Security Policy exception already set or not.    Ref: Bug 3919112
            l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
            WHILE l_sc_msg_count <> 0 loop
              igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
              fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
	     IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                --Raise the exception to Higher Level with out setting any Unhandled exception.
                App_Exception.Raise_Exception;
              END IF;
              l_sc_msg_count := l_sc_msg_count - 1;
            END LOOP;
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_011.admp_ins_acai_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_ins_acai_hist;

Procedure Admp_Ins_Aca_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_new_transfer_course_cd IN VARCHAR2 ,
  p_old_transfer_course_cd IN VARCHAR2 ,
  p_new_basis_for_admission_type IN VARCHAR2 ,
  p_old_basis_for_admission_type IN VARCHAR2 ,
  p_new_admission_cd IN VARCHAR2 ,
  p_old_admission_cd IN VARCHAR2 ,
  p_new_course_rank_set IN VARCHAR2 ,
  p_old_course_rank_set IN VARCHAR2 ,
  p_new_course_rank_schedule IN VARCHAR2 ,
  p_old_course_rank_schedule IN VARCHAR2 ,
  p_new_req_for_reconsider_ind IN VARCHAR2 ,
  p_old_req_for_reconsider_ind IN VARCHAR2 ,
  p_new_req_for_adv_standing_ind IN VARCHAR2 ,
  p_old_req_for_adv_standing_ind IN VARCHAR2 ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE )
IS
    gv_other_detail     VARCHAR2(255);

        --Local variables to check if the Security Policy exception already set or not.  Ref: Bug 3919112
        l_sc_encoded_text   VARCHAR2(4000);
        l_sc_msg_count NUMBER;
        l_sc_msg_index NUMBER;
        l_sc_app_short_name VARCHAR2(50);
        l_sc_message_name   VARCHAR2(50);

BEGIN   -- admp_ins_aca_hist
    -- Routine to create a history for the IGS_AD_PS_APPL table.
DECLARE
    v_changed_flag      BOOLEAN DEFAULT FALSE;
    v_acah_rec      IGS_AD_PS_APPL_HIST%ROWTYPE;
    lv_rowid        VARCHAR2(25);
    l_org_id        NUMBER(15);
BEGIN
    -- Check if any of the old IGS_AD_PS_APPL values are different from the
    -- associated new IGS_AD_PS_APPL values.
    IF NVL(p_new_transfer_course_cd, 'NULL') <>
            NVL(p_old_transfer_course_cd, 'NULL') THEN
        v_acah_rec.transfer_course_cd := p_old_transfer_course_cd;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_basis_for_admission_type, 'NULL') <>
            NVL(p_old_basis_for_admission_type, 'NULL') THEN
        v_acah_rec.basis_for_admission_type := p_old_basis_for_admission_type;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_admission_cd, 'NULL') <> NVL(p_old_admission_cd, 'NULL') THEN
        v_acah_rec.admission_cd := p_old_admission_cd;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_course_rank_set, 'NULL') <>
            NVL(p_old_course_rank_set, 'NULL') THEN
        v_acah_rec.course_rank_set := p_old_course_rank_set;
        v_changed_flag := TRUE;
    END IF;
    IF NVL(p_new_course_rank_schedule, 'NULL') <>
            NVL(p_old_course_rank_schedule, 'NULL') THEN
        v_acah_rec.course_rank_schedule := p_old_course_rank_schedule;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_req_for_reconsider_ind <> p_old_req_for_reconsider_ind THEN
        v_acah_rec.req_for_reconsideration_ind := p_old_req_for_reconsider_ind;
        v_changed_flag := TRUE;
    END IF;
    IF p_new_req_for_adv_standing_ind <> p_old_req_for_adv_standing_ind THEN
        v_acah_rec.req_for_adv_standing_ind := p_old_req_for_adv_standing_ind;
        v_changed_flag := TRUE;
    END IF;
    IF v_changed_flag = TRUE THEN
        v_acah_rec.person_id := p_person_id;
        v_acah_rec.admission_appl_number := p_admission_appl_number;
        v_acah_rec.nominated_course_cd := p_nominated_course_cd;
        v_acah_rec.hist_start_dt := p_old_update_on;
        v_acah_rec.hist_end_dt := p_new_update_on;
        v_acah_rec.hist_who := p_old_update_who;
        -- Ceate an IGS_AD_PS_APPL_HIST history record.
    l_org_id := igs_ge_gen_003.get_org_id;
        IGS_AD_PS_APPL_Hist_Pkg.Insert_Row (
            X_Mode                              => 'R',
            X_RowId                             => lv_rowid,
            X_Hist_Who                          => v_acah_rec.hist_who,
            X_Transfer_Course_Cd                => v_acah_rec.transfer_course_cd,
            X_Basis_For_Admission_Type          => v_acah_rec.basis_for_admission_type,
            X_Admission_Cd                      => v_acah_rec.admission_cd,
            X_Course_Rank_Set                   => v_acah_rec.course_rank_set,
            X_Course_Rank_Schedule              => v_acah_rec.course_rank_schedule,
            X_Req_For_Reconsideration_Ind       => v_acah_rec.req_for_reconsideration_ind,
            X_Req_For_Adv_Standing_Ind          => v_acah_rec.req_for_adv_standing_ind,
            X_Person_Id                         => v_acah_rec.person_id,
            X_Admission_Appl_Number             => v_acah_rec.admission_appl_number,
            X_Nominated_Course_Cd               => v_acah_rec.nominated_course_cd,
            X_Hist_Start_Dt                     => v_acah_rec.hist_start_dt,
            X_Hist_End_Dt                       => v_acah_rec.hist_end_dt,
            X_Org_Id                => l_org_id
        );

    END IF;
END;
EXCEPTION
    WHEN OTHERS THEN
            --Loop through all messages in stack to check if there is Security Policy exception already set or not.    Ref: Bug 3919112
            l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
            WHILE l_sc_msg_count <> 0 loop
              igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
              fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
              IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                --Raise the exception to Higher Level with out setting any Unhandled exception.
                App_Exception.Raise_Exception;
              END IF;
              l_sc_msg_count := l_sc_msg_count - 1;
            END LOOP;

        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_011.admp_ins_aca_hist');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_ins_aca_hist;
  --
  --
  --
  Function Admp_Ins_Adm_Letter (
    p_acad_cal_type                  IN     VARCHAR2,
    p_acad_ci_sequence_number        IN     NUMBER,
    p_adm_cal_type                   IN     VARCHAR2,
    p_adm_ci_sequence_number         IN     NUMBER,
    p_admission_cat                  IN     VARCHAR2,
    p_s_admission_process_type       IN     VARCHAR2,
    p_correspondence_type            IN     VARCHAR2,
    p_person_id                      IN     NUMBER,
    p_admission_appl_number          IN     NUMBER,
    p_adm_outcome_status             IN     VARCHAR2,
    p_message_name                   OUT NOCOPY    VARCHAR2,
    p_reference_number               OUT NOCOPY    NUMBER,
    p_pgmofstudy                     IN     VARCHAR2,
    p_response_stat                  IN     VARCHAR2,
    p_resd_class                     IN     VARCHAR2,
    p_resd_stat                      IN     VARCHAR2,
    p_persid_grp                     IN     NUMBER,
    p_org_unit                       IN     VARCHAR2,
    p_sortby                         IN     VARCHAR2
  ) RETURN BOOLEAN IS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Kalyan.Dande    07-May-2001     Made modifications according to the DLD (Communicate Offer to Student).
  ||  (reverse chronological order - newest change first)
  */
    --
    -- Local Variables
    --
    gv_other_detail         VARCHAR2(255);
    gv_first_cori           BOOLEAN DEFAULT TRUE;
    gv_reference_number     NUMBER DEFAULT NULL;
    CURSOR c_igsco_itm_rf_num_s IS
      SELECT igs_co_itm_rf_num_s.NEXTVAL
      FROM   dual;
    CURSOR c_igs_co_ou_co_ref_seq_num_s IS
      SELECT igs_co_ou_co_ref_seq_num_s.NEXTVAL
      FROM   dual;
    FUNCTION Admpl_Process_Person (
      p_person_id                IN  igs_ad_appl_ltr.person_id%TYPE,
      p_admission_appl_number    IN  igs_ad_appl.admission_appl_number%TYPE,
      p_correspondence_type      IN  igs_ad_appl_ltr.correspondence_type%TYPE,
      p_aal_sequence_number      IN  igs_ad_appl_ltr.sequence_number%TYPE,
      p_admission_cat            IN  igs_ad_appl.admission_cat%TYPE,
      p_s_admission_process_type IN  igs_ad_appl.s_admission_process_type%TYPE,
      p_message_name             OUT NOCOPY VARCHAR2
    ) RETURN BOOLEAN IS
      --
      -- Local Variables for admpl_process_person.
      --
      gv_other_detail    VARCHAR2(255);
      e_resource_busy    EXCEPTION;
      l_org_id           NUMBER(15);
      PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
    BEGIN
      DECLARE
        v_letter_reference_number    igs_co_s_ltr.letter_reference_number%TYPE;
        v_spl_sequence_number        igs_co_s_per_lt_parm.spl_sequence_number%TYPE;
        v_create_dt                  DATE;
        v_issue_dt                   DATE;
        v_comments                   VARCHAR2(2000);
        v_message_name               VARCHAR2(30);
        v_sl_record_found            BOOLEAN DEFAULT FALSE;
        lv_rowid                     VARCHAR2(25);
        x_rowid                      VARCHAR2(25);
        v_igs_co_itm_rf_num_s        NUMBER;
        v_igs_co_ou_co_ref_seq_num_s igs_co_ou_co_ref.sequence_number%TYPE;
        CURSOR c_apcl_slet (
                 cp_admission_cat igs_ad_appl.admission_cat%TYPE,
                 cp_s_admission_process_type igs_ad_appl.s_admission_process_type%TYPE,
                 cp_correspondence_type igs_ad_appl_ltr.correspondence_type%TYPE
               ) IS
          SELECT   apcl.letter_reference_number
          FROM     igs_ad_prcs_cat_ltr apcl,
                   igs_co_s_ltr slet
          WHERE    apcl.admission_cat = cp_admission_cat
          AND      apcl.s_admission_process_type = cp_s_admission_process_type
          AND      apcl.correspondence_type = cp_correspondence_type
          AND      apcl.correspondence_type = slet.correspondence_type
          AND      apcl.letter_reference_number = slet.letter_reference_number
          AND      slet.closed_ind = 'N';
        CURSOR c_sl (
                 cp_correspondence_type igs_ad_appl_ltr.correspondence_type%TYPE
               ) IS
          SELECT   sl.letter_reference_number
          FROM     igs_co_s_ltr sl
          WHERE    sl.correspondence_type = cp_correspondence_type
          AND      sl.closed_ind = 'N'
          ORDER BY sl.letter_reference_number;
        CURSOR c_cit (
                 cp_correspondence_type igs_co_itm.correspondence_type%TYPE,
                 cp_create_dt igs_co_itm.create_dt%TYPE
               ) IS
          SELECT   cit.reference_number
          FROM     igs_co_itm cit
          WHERE    cit.correspondence_type = cp_correspondence_type
          AND      cit.create_dt = cp_create_dt;
        CURSOR  c_aal (
                  cp_person_id igs_ad_appl_ltr.person_id%TYPE,
                  cp_admission_appl_number igs_ad_appl.admission_appl_number%TYPE,
                  cp_correspondence_type igs_ad_appl_ltr.correspondence_type%TYPE,
                  cp_aal_sequence_number igs_ad_appl_ltr.sequence_number%TYPE
                ) IS
          SELECT   'x'
          FROM     igs_ad_appl_ltr aal
          WHERE    aal.person_id = cp_person_id
          AND      aal.admission_appl_number = cp_admission_appl_number
          AND      aal.correspondence_type = cp_correspondence_type
          AND      aal.sequence_number = cp_aal_sequence_number
          FOR UPDATE OF aal.letter_reference_number, aal.spl_sequence_number NOWAIT;
      BEGIN
        --
        --  Process the Person passed as parameter.
        --
        v_message_name := NULL;
        l_org_id := igs_ge_gen_003.get_org_id;
        --
        --  Find the letter by looking at IGS_AD_PRCS_CAT_LTR.
        --
        OPEN c_apcl_slet (
               p_admission_cat,
               p_s_admission_process_type,
               p_correspondence_type
             );
        FETCH c_apcl_slet INTO v_letter_reference_number;
        IF (c_apcl_slet%NOTFOUND) THEN
          CLOSE c_apcl_slet;
          p_message_name := 'IGS_AD_LETTER_NOT_PRODUCED';
          RETURN FALSE;
        ELSE
          CLOSE c_apcl_slet;
        END IF;
        --
        --  Insert Person letter.
        --
        IF (igs_co_gen_002.corp_ins_spl_detail (
              p_person_id,
              p_correspondence_type,
              v_letter_reference_number,
              p_admission_appl_number || '|' || p_aal_sequence_number,
              v_spl_sequence_number,
              v_message_name
            ) = FALSE) THEN
          p_message_name := v_message_name;
          RETURN FALSE;
        END IF;
        --
        -- Get values we need to create correspondence item.
        --
        IF (gv_first_cori = TRUE) THEN
          v_create_dt := SYSDATE;  -- Note: Using the time component
          --
          --  Join all the parameters into one long string for the comments field
          --
          v_comments := 'Admission Calendar-'
                        || p_adm_cal_type || ' '
                        || IGS_GE_NUMBER.TO_CANN (p_adm_ci_sequence_number)
                        || ', Academic Calendar-'
                        || p_acad_cal_type || ' '
                        || IGS_GE_NUMBER.TO_CANN (p_acad_ci_sequence_number)
                        || ', Admission Category-'
                        || p_admission_cat
                        || ', System Admission Process Type-'
                        || p_s_admission_process_type
                        || ', Correspondence Type-'
                        || p_correspondence_type
                        || ', Person ID-'
                        || IGS_GE_NUMBER.TO_CANN (p_person_id)
                        || ', Admission Application Number-'
                        || IGS_GE_NUMBER.TO_CANN (p_admission_appl_number)
                        || ', Admission Outcome Status-'
                        || p_adm_outcome_status
                        || ', Program of Study-'
                        || p_pgmofstudy
                        || ', Response Status-'
                        || p_response_stat
                        || ', Residency Class-'
                        || p_resd_class
                        || ', Residency Status-'
                        || p_resd_stat
                        || ', Person ID Group-'
                        || IGS_GE_NUMBER.TO_CANN (p_persid_grp)
                        || ', Organization Unit-'
                        || p_org_unit
                        || ', Sort By-'
                        || p_sortby;
          OPEN c_igsco_itm_rf_num_s;
          FETCH c_igsco_itm_rf_num_s INTO v_igs_co_itm_rf_num_s;
          IF c_igsco_itm_rf_num_s%NOTFOUND THEN
            RAISE NO_DATA_FOUND;
          END IF;
          CLOSE c_igsco_itm_rf_num_s;
          --
          --  Insert a record in Correspondence Item table.
          --
          DECLARE
            lv_rowid VARCHAR2(25);
          BEGIN
            igs_co_itm_pkg.insert_row (
              x_rowid                    => lv_rowid,
              x_org_id                   => fnd_profile.value ('ORG_ID'),
              x_correspondence_type      => p_correspondence_type,
              x_reference_number         => v_igs_co_itm_rf_num_s,
              x_create_dt                => v_create_dt,
              x_originator_person_id     => NULL,
              x_request_num              => NULL,
              x_s_job_name               => NULL,
              x_request_job_id           => NULL,
              x_output_num               => NULL,
              x_request_job_run_id       => NULL,
              x_cal_type                 => NULL,
              x_ci_sequence_number       => NULL,
              x_course_cd                => NULL,
              x_cv_version_number        => NULL,
              x_unit_cd                  => NULL,
              x_uv_version_number        => NULL,
              x_comments                 => UPPER (v_comments),
              x_job_request_id           => NULL,
              x_mode                     => 'R'
            );

          END;
          gv_first_cori := FALSE;
          --
          --  Now get the reference number of the correspondence item we just created.
          --
          OPEN c_cit (
                 p_correspondence_type,
                 v_create_dt
               );
          FETCH c_cit INTO gv_reference_number;
          IF (c_cit%NOTFOUND) THEN
            CLOSE c_cit;
            p_message_name := 'IGS_AD_CORITEM_NOTBE_FOUND';
            RETURN FALSE;
          END IF;
          CLOSE c_cit;
          --
          --  Set outgoing parameter
          --
          p_reference_number := gv_reference_number;
        END IF;
        --
        --  Insert outgoing correspondence
        --  We want to wait until the time has changed to the next second
        --
        v_issue_dt := SYSDATE;
        WHILE (v_issue_dt = SYSDATE) LOOP
          NULL;
        END LOOP;
        v_issue_dt := SYSDATE;    -- IGS_GE_NOTE. Using the time component
        --
        --  Insert a record in Outgoing Correspondence table.
        --
        DECLARE
          lv_rowid   VARCHAR2(25);
        BEGIN
          igs_co_ou_co_pkg.insert_row (
            x_rowid                          => lv_rowid,
            x_person_id                      => p_person_id,
            x_correspondence_type            => p_correspondence_type,
            x_reference_number               => gv_reference_number,
            x_issue_dt                       => v_issue_dt,
            x_dt_sent                        => NULL,
            x_unknown_return_dt              => NULL,
            x_addr_type                      => NULL,
            x_tracking_id                    => NULL,
            x_comments                       => NULL,
            x_letter_reference_number        => v_letter_reference_number,
            x_org_id                         => l_org_id,
            x_spl_sequence_number            => v_spl_sequence_number,
            x_mode                           => 'R'
          );
        END;
        OPEN c_igs_co_ou_co_ref_seq_num_s;
        FETCH c_igs_co_ou_co_ref_seq_num_s INTO v_igs_co_ou_co_ref_seq_num_s;
        IF (c_igs_co_ou_co_ref_seq_num_s%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_igs_co_ou_co_ref_seq_num_s;
        --
        --  Insert a record in Outgoing Correspondence Reference table.
        --
        DECLARE
          lv_rowid VARCHAR2(25);
        BEGIN
          igs_co_ou_co_ref_pkg.insert_row (
            x_rowid                          => lv_rowid,
            x_person_id                      => p_person_id,
            x_org_id                         => l_org_id,
            x_correspondence_type            => p_correspondence_type,
            x_reference_number               => gv_reference_number,
            x_issue_dt                       => v_issue_dt,
            x_sequence_number                => v_igs_co_ou_co_ref_seq_num_s,
            x_cal_type                       => NULL,
            x_ci_sequence_number             => NULL,
            x_course_cd                      => NULL,
            x_cv_version_number              => NULL,
            x_unit_cd                        => NULL,
            x_uv_version_number              => NULL,
            x_s_other_reference_type         => 'SPL_SEQNUM',
            x_other_reference                => v_spl_sequence_number,
            x_mode                           => 'R'
          );
        END;
        --
        --  Update Admission Application Letter details.
        --
        FOR v_aal_rec IN c_aal (
                           p_person_id,
                           p_admission_appl_number,
                           p_correspondence_type,
                           p_aal_sequence_number
                         )
        LOOP
          UPDATE igs_ad_appl_ltr
          SET    letter_reference_number = v_letter_reference_number,
                 spl_sequence_number = v_spl_sequence_number
          WHERE CURRENT OF c_aal;
        END LOOP;
        RETURN TRUE;
      END;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        CLOSE c_igsco_itm_rf_num_s;
        CLOSE c_igs_co_ou_co_ref_seq_num_s;
      WHEN E_RESOURCE_BUSY THEN
        p_message_name := 'IGS_AD_LETTER_NOTUPD_LOCKING';
        RETURN FALSE;
      WHEN OTHERS THEN
        fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token ('NAME', 'IGS_AD_GEN_011.ADMPL_PROCESS_PERSON');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
    END Admpl_Process_Person;
    --
    --
    --
  BEGIN   -- Begin of Admp_Ins_Adm_Letter Function.
    --
    -- This module creates letter and correspondence item details for either
    -- a single student or a batch of students.
    --
    DECLARE
      v_message_name       VARCHAR2(30);
      v_false              BOOLEAN DEFAULT FALSE;
      v_success_count      NUMBER(5);
      CURSOR  c_aa_aal (
                cp_person_id              igs_ad_appl_ltr.person_id%TYPE,
                cp_admission_appl_number  igs_ad_appl_ltr.admission_appl_number%TYPE,
                cp_correspondence_type    igs_ad_appl_ltr.correspondence_type%TYPE
              ) IS
        SELECT    aa.admission_cat,
                  aa.s_admission_process_type,
                  aal.sequence_number,
                  aal.spl_sequence_number
        FROM      igs_ad_appl aa,
                  igs_ad_appl_ltr aal
        WHERE     aa.person_id = cp_person_id
        AND       aa.admission_appl_number = cp_admission_appl_number
        AND       aal.person_id = aa.person_id
        AND       aal.admission_appl_number = aa.admission_appl_number
        AND       aal.correspondence_type = cp_correspondence_type
        AND       aal.composed_ind = 'Y';
      /*
      **  Cursor was changed for enhancement# 1818444.
      */
      CURSOR  c_aa_aal_acaiv (
                cp_acad_cal_type            igs_ad_appl.acad_cal_type%TYPE,
                cp_acad_ci_sequence_number  igs_ad_appl.acad_ci_sequence_number%TYPE,
                cp_adm_cal_type             igs_ad_appl.adm_cal_type%TYPE,
                cp_adm_ci_sequence_number   igs_ad_appl.adm_ci_sequence_number%TYPE,
                cp_admission_cat            igs_ad_appl.admission_cat%TYPE,
                cp_s_admission_process_type igs_ad_appl.s_admission_process_type%TYPE,
                cp_correspondence_type      igs_ad_appl_ltr.correspondence_type%TYPE,
                cp_adm_outcome_status       igs_ad_ou_stat.adm_outcome_status%TYPE,
                cp_pgm_of_study             igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                cp_response_status      igs_ad_ofr_resp_stat.adm_offer_resp_status%TYPE,
                cp_residency_class          igs_pe_res_dtls_v.residency_class%TYPE,
                cp_residency_stat           igs_pe_res_dtls_v.residency_status%TYPE,
                cp_org_unit_code            igs_ps_ver.responsible_org_unit_cd%TYPE
              ) IS
        SELECT    DISTINCT
                  aa.person_id person_id,
                  aa.admission_appl_number admission_appl_number,
                  aal.correspondence_type correspondence_type,
                  aal.sequence_number sequence_number,
                  aa.admission_cat admission_cat,
                  aa.s_admission_process_type s_admission_process_type,
                  padv.city city,
                  padv.county county,
                  padv.country country,
                  padv.postal_code postal_code
        FROM      igs_ad_appl aa,
                  igs_ad_appl_ltr aal,
                  igs_ad_ps_appl_inst acaiv, --Bug 3150054 Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst
                  igs_ps_ver pv,
                  igs_pe_addr_v padv,
                  igs_pe_res_dtls_v prdv
        WHERE     aa.acad_cal_type LIKE cp_acad_cal_type
        AND       aa.acad_ci_sequence_number LIKE cp_acad_ci_sequence_number
        AND       NVL(acaiv.adm_cal_type, aa.adm_cal_type) LIKE cp_adm_cal_type
        AND       NVL(acaiv.adm_ci_sequence_number, aa.adm_ci_sequence_number) LIKE cp_adm_ci_sequence_number
        AND       aa.admission_cat LIKE cp_admission_cat
        AND       aa.s_admission_process_type LIKE cp_s_admission_process_type
        AND       aa.person_id = aal.person_id
        AND       aa.admission_appl_number = aal.admission_appl_number
        AND       aal.correspondence_type = cp_correspondence_type
        AND       aal.composed_ind = 'Y'
        AND       acaiv.person_id = aa.person_id
        AND       acaiv.admission_appl_number = aa.admission_appl_number
        AND       pv.course_cd = acaiv.nominated_course_cd
        AND   pv.version_number = acaiv.crv_version_number
        AND       pv.responsible_org_unit_cd LIKE NVL (cp_org_unit_code, '%')
        AND       acaiv.adm_outcome_status LIKE cp_adm_outcome_status
        AND       acaiv.nominated_course_cd LIKE cp_pgm_of_study
        AND       acaiv.adm_offer_resp_status LIKE  cp_response_status
        AND       aa.person_id = prdv.person_id(+)
        AND       aa.person_id = padv.person_id (+)
        AND       prdv.residency_class (+) LIKE cp_residency_class
        AND       prdv.residency_status (+) LIKE cp_residency_stat
        AND       NVL (acaiv.offer_dt, SYSDATE) <= SYSDATE;
      /*
      **  Reference Cursor was added for enhancement# 1818444.
      */
      TYPE c_aal_ref_cursor IS REF CURSOR;
      c_aal_refcur c_aal_ref_cursor;
      v_aa_aal_acaiv_rec c_aa_aal_acaiv%ROWTYPE;
      /*
      **  Cursor was added for enhancement# 1818444.
      */
      CURSOR  c_aa_aal_persid (
                cp_correspondence_type      igs_ad_appl_ltr.correspondence_type%TYPE,
                cp_person_id                igs_ad_appl_ltr.person_id%TYPE
              ) IS
        SELECT    DISTINCT
                  aa.admission_appl_number,
                  aa.admission_cat,
                  aa.s_admission_process_type,
                  aal.sequence_number,
                  aal.spl_sequence_number
        FROM      igs_ad_appl aa,
                  igs_ad_appl_ltr aal,
                  igs_pe_addr_v padv
        WHERE     aa.person_id = aal.person_id
        AND       aa.person_id = padv.person_id (+)
        AND       aal.person_id = cp_person_id
        AND       aal.correspondence_type = cp_correspondence_type;
      /*
      **  Reference Cursor was added for enhancement# 1818444.
      */
      TYPE ref_cursor_aa_aal_persid IS REF CURSOR;
      ref_cur_aa_aal_persid ref_cursor_aa_aal_persid;
      v_aa_aal_persid_rec c_aa_aal_persid%ROWTYPE;
    BEGIN
      --
      -- Explicitly use large rollback section as we will not commit until the very end.
      --
      COMMIT;
      SAVEPOINT sp_before;
      p_message_name := null;
      v_success_count := 0;
      gv_first_cori := TRUE;
      gv_reference_number := NULL;
      IF (p_person_id IS NOT NULL AND
          p_admission_appl_number IS NOT NULL AND
          p_correspondence_type IS NOT NULL) THEN
        FOR v_aa_aal_rec IN c_aa_aal (
                              p_person_id,
                              p_admission_appl_number,
                              p_correspondence_type
                            )
        LOOP
          IF (igs_ad_gen_002.admp_get_aal_sent_dt (
                p_person_id,
                p_admission_appl_number,
                p_correspondence_type,
                v_aa_aal_rec.sequence_number
              ) IS NULL) THEN
            IF (admpl_process_person (
                  p_person_id,
                  p_admission_appl_number,
                  p_correspondence_type,
                  v_aa_aal_rec.sequence_number,
                  v_aa_aal_rec.admission_cat,
                  v_aa_aal_rec.s_admission_process_type,
                  v_message_name
                ) = FALSE) THEN
              v_false := TRUE;
              p_message_name := v_message_name;
              EXIT;
            END IF;
          END IF;
        END LOOP;
        IF (v_false = TRUE) THEN
          ROLLBACK TO sp_before;
          RETURN FALSE;
        END IF;
      /*
      **  Start of code for enhancement# 1818444.
      */
      ELSIF (p_persid_grp IS NOT NULL) THEN
        DECLARE
          --
          --  Cursor to select all the Person IDs that are part of the Person ID Group.
          --
          CURSOR cur_person_ids (
                   cp_person_id_group IN igs_pe_persid_group_all.group_id%TYPE
                 ) IS
            SELECT   person_id
            FROM     igs_pe_prsid_grp_mem_v
            WHERE    group_id = cp_person_id_group AND
                                NVL(TRUNC(start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) AND
                                NVL(TRUNC(end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE);
        BEGIN
          FOR lcur_person_ids IN cur_person_ids (
                                   p_persid_grp
                                 )
          LOOP
            OPEN ref_cur_aa_aal_persid FOR '
            SELECT    DISTINCT
                      aa.admission_appl_number admission_appl_number,
                      aa.admission_cat admission_cat,
                      aa.s_admission_process_type s_admission_process_type,
                      aal.sequence_number sequence_number,
                      aal.spl_sequence_number spl_sequence_number, padv.' || p_sortby ||
          ' FROM      igs_ad_appl aa,
                      igs_ad_appl_ltr aal,
                      igs_pe_addr_v padv
            WHERE     aa.person_id = aal.person_id
            AND       aa.person_id = padv.person_id (+)
            AND       aal.person_id = :1
            AND       aal.correspondence_type = :2
            ORDER BY  padv.' || p_sortby
	    USING lcur_person_ids.person_id, p_correspondence_type ;

            LOOP
              FETCH ref_cur_aa_aal_persid INTO v_aa_aal_persid_rec;
              EXIT WHEN ref_cur_aa_aal_persid%NOTFOUND;
              IF (igs_ad_gen_002.admp_get_aal_sent_dt (
                    lcur_person_ids.person_id,
                    v_aa_aal_persid_rec.admission_appl_number,
                    p_correspondence_type,
                    v_aa_aal_persid_rec.sequence_number
                  ) IS NULL) THEN
                IF (admpl_process_person (
                      lcur_person_ids.person_id,
                      v_aa_aal_persid_rec.admission_appl_number,
                      p_correspondence_type,
                      v_aa_aal_persid_rec.sequence_number,
                      v_aa_aal_persid_rec.admission_cat,
                      v_aa_aal_persid_rec.s_admission_process_type,
                      v_message_name
                    ) = FALSE) THEN
                  v_false := TRUE;
                  p_message_name := v_message_name;
                  EXIT;
                END IF;
              END IF;
            END LOOP;
            CLOSE ref_cur_aa_aal_persid;
          END LOOP;
        END;
      /*
      **  End of code for enhancement# 1818444.
      */
      ELSIF (p_person_id IS NULL AND p_persid_grp IS NULL) THEN -- Changed for enhancement# 1818444.
      /*
      **  Start of code change for enhancement# 1818444.
      */
        OPEN c_aal_refcur FOR '
        SELECT    DISTINCT
                  aa.person_id person_id,
                  aa.admission_appl_number admission_appl_number,
                  aal.correspondence_type correspondence_type,
                  aal.sequence_number sequence_number,
                  aa.admission_cat admission_cat,
                  aa.s_admission_process_type s_admission_process_type,
                  padv.city city,
                  padv.county county,
                  padv.country country,
                  padv.postal_code postal_code
        FROM      igs_ad_appl aa,
                  igs_ad_appl_ltr aal,
                  igs_ad_ps_appl_inst acaiv,  --Bug 3150054 Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst
                  igs_ps_ver pv,
                  igs_pe_addr_v padv,
                  igs_pe_res_dtls_v prdv
        WHERE     aa.acad_cal_type LIKE :1
        AND       aa.acad_ci_sequence_number LIKE :2
        AND       NVL(acaiv.adm_cal_type, aa.adm_cal_type) LIKE :3
        AND       NVL(acaiv.adm_ci_sequence_number,aa.adm_ci_sequence_number) LIKE :4
        AND       aa.admission_cat LIKE :5
        AND       aa.s_admission_process_type LIKE :6
        AND       aa.person_id = aal.person_id
        AND       aa.admission_appl_number = aal.admission_appl_number
        AND       aal.correspondence_type = :7
        AND       aal.composed_ind = ''Y''
        AND       acaiv.person_id = aa.person_id
        AND       acaiv.admission_appl_number = aa.admission_appl_number
        AND       pv.course_cd = acaiv.nominated_course_cd
        AND   pv.version_number = acaiv.crv_version_number
        AND       pv.responsible_org_unit_cd LIKE :8
        AND       acaiv.adm_outcome_status LIKE :9
        AND       acaiv.nominated_course_cd LIKE :10
        AND       acaiv.adm_offer_resp_status LIKE :11
        AND       aa.person_id = prdv.person_id(+)
        AND       aa.person_id = padv.person_id (+)
        AND       prdv.residency_class (+) LIKE :12
        AND       prdv.residency_status (+) LIKE :13
        AND       NVL (acaiv.offer_dt, SYSDATE) <= SYSDATE
        ORDER BY  padv.' || p_sortby
	USING	NVL (p_acad_cal_type, '%'), NVL (IGS_GE_NUMBER.TO_CANN (p_acad_ci_sequence_number), '%'), NVL (p_adm_cal_type, '%'),
		NVL (IGS_GE_NUMBER.TO_CANN (p_adm_ci_sequence_number), '%'), p_admission_cat, p_s_admission_process_type, p_correspondence_type,
		NVL (p_org_unit, '%'), p_adm_outcome_status, p_pgmofstudy, p_response_stat, p_resd_stat, p_resd_class
	;
        LOOP
          FETCH c_aal_refcur INTO v_aa_aal_acaiv_rec;
          EXIT WHEN c_aal_refcur%NOTFOUND;
          IF (igs_ad_gen_002.admp_get_aal_sent_dt (
                v_aa_aal_acaiv_rec.person_id,
                v_aa_aal_acaiv_rec.admission_appl_number,
                p_correspondence_type,
                v_aa_aal_acaiv_rec.sequence_number
              ) IS NULL) THEN
            IF (admpl_process_person (
                  v_aa_aal_acaiv_rec.person_id,
                  v_aa_aal_acaiv_rec.admission_appl_number,
                  v_aa_aal_acaiv_rec.correspondence_type,
                  v_aa_aal_acaiv_rec.sequence_number,
                  v_aa_aal_acaiv_rec.admission_cat,
                  v_aa_aal_acaiv_rec.s_admission_process_type,
                  v_message_name
                ) = FALSE) THEN
              fnd_message.set_name ('IGS', 'IGS_AD_LETTER_NOTUPD_LOCKING');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
            ELSE
              v_success_count := v_success_count + 1;
            END IF;
          END IF;
        END LOOP;
        CLOSE c_aal_refcur;
      /*
      **  End of code change for enhancement# 1818444.
      */
      END IF;
      COMMIT;
      RETURN TRUE;
    END;
  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      ROLLBACK TO sp_before;
      fnd_message.set_token ('NAME', 'IGS_AD_GEN_011.ADMPL_INS_ADM_LETTER');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
  END Admp_Ins_Adm_Letter;
  --
  PROCEDURE Adms_Ins_Adm_Letter (
    errbuf                        OUT NOCOPY    VARCHAR2,
    retcode                       OUT NOCOPY    NUMBER,
    p_acad_perd                   IN     VARCHAR2,
    p_adm_perd                    IN     VARCHAR2,
    p_adm_cat                     IN     VARCHAR2,
    p_s_adm_prcss_type            IN     VARCHAR2,
    p_correspondence_type         IN     VARCHAR2,
    p_adm_outcome_stat            IN     VARCHAR2,
    p_org_id                      IN     NUMBER,
    p_pgmofstudy                  IN     VARCHAR2,
    p_response_stat               IN     VARCHAR2,
    p_resd_class                  IN     VARCHAR2,
    p_resd_stat                   IN     VARCHAR2,
    p_persid_grp                  IN     NUMBER,
    p_org_unit                    IN     VARCHAR2,
    p_sortby                      IN     VARCHAR2
  ) IS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Kalyan.Dande    07-May-2001     Made modifications according to the DLD (Communicate Offer to Student).
  ||  (reverse chronological order - newest change first)
  */
    p_admission_cat              igs_ad_cat.admission_cat%TYPE;
    p_s_admission_process_type   igs_lookups_view.lookup_code%TYPE;
    p_adm_outcome_status         igs_ad_ou_stat.adm_outcome_status%TYPE;
    p_acad_cal_type              igs_ca_inst.cal_type%TYPE;
    p_acad_ci_sequence_number    igs_ca_inst.sequence_number%TYPE;
    p_adm_cal_type               igs_ca_inst.cal_type%TYPE;
    p_adm_ci_sequence_number     igs_ca_inst.sequence_number%TYPE;
    /*
    **  Start of code for enhancement# 1818444.
    */
    p_program_of_study           igs_ad_ps_appl_inst.nominated_course_cd%TYPE;
    p_response_status            igs_ad_ofr_resp_stat.adm_offer_resp_status%TYPE;
    p_residency_class            igs_pe_res_dtls_v.residency_class%TYPE;
    p_residency_status           igs_pe_res_dtls_v.residency_status%TYPE;
    p_person_id_group            igs_pe_persid_group_all.group_id%TYPE;
    p_organization_unit          igs_ps_ver.responsible_org_unit_cd%TYPE;
    p_sort_by                    fnd_lookups.lookup_code%TYPE;
    /*
    **  End of code for enhancement# 1818444.
    */
    invalid_parameter            EXCEPTION;
    p_message_name               VARCHAR2(30);
    p_reference_number           NUMBER;
  BEGIN
    p_person_id_group := p_persid_grp;
    --
    --  Set Organization context for populating Multi-Org tables.
    --
    igs_ge_gen_003.set_org_id (IGS_GE_NUMBER.TO_CANN (p_org_id));
    retcode := 0;
    --
    --  Handle NULL parameter values.
    --
    p_admission_cat := NVL (p_adm_cat, '%');
    p_s_admission_process_type := NVL (p_s_adm_prcss_type, '%');
    p_adm_outcome_status := NVL (p_adm_outcome_stat, '%');
    /*
    **  Start of code for enhancement# 1818444.
    */
    p_program_of_study := NVL (p_pgmofstudy, '%');
    p_response_status := NVL (p_response_stat, '%');
    p_residency_class := NVL (p_resd_class, '%');
    p_residency_status := NVL (p_resd_stat, '%');
    p_sort_by := NVL (p_sortby, 'POSTAL_CODE');
    --
    --  Check the combination of the parameters and raise error if the wrong combination is passed.
    --  The proper combination is as follows:
    --  a) Correspondence Type, Person ID Group, Sort By
    --  b) Correspondence Type, Admission Calendar, Academic Calendar, Admission Category,
    --     System Admission Process Type, Admission Application Number, Admission Outcome Status,
    --     Program of Study, Response Status, Residency Class, Residency Status, Organization Unit, Sort By
    --
    IF ((p_persid_grp IS NOT NULL) AND ((p_acad_perd IS NOT NULL) OR
                                        (p_adm_perd IS NOT NULL) OR
                                        (p_adm_cat IS NOT NULL) OR
                                        (p_s_adm_prcss_type IS NOT NULL) OR
                                        (p_adm_outcome_stat IS NOT NULL) OR
                                        (p_pgmofstudy IS NOT NULL) OR
                                        (p_response_stat IS NOT NULL) OR
                                        (p_resd_class IS NOT NULL) OR
                                        (p_resd_stat IS NOT NULL) OR
                                        (p_org_unit IS NOT NULL))) THEN
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_INVALID_COMBI_OF_PARAMS');
      RAISE invalid_parameter;
    END IF;
    --
    --  Raise an error if the no parameter other than Correspondence Type is passed.
    --
    IF ((p_persid_grp IS NULL) AND
        (p_acad_perd IS NULL) AND
        (p_adm_perd IS NULL) AND
        (p_adm_cat IS NULL) AND
        (p_s_adm_prcss_type IS NULL) AND
        (p_adm_outcome_stat IS NULL) AND
        (p_pgmofstudy IS NULL) AND
        (p_response_stat IS NULL) AND
        (p_resd_class IS NULL) AND
        (p_resd_stat IS NULL) AND
        (p_org_unit IS NULL)) THEN
      errbuf := fnd_message.get_string ('IGS', 'IGS_GE_INVALID_COMBI_OF_PARAMS');
      RAISE invalid_parameter;
    END IF;
    --
    --  Added the IF condition in enhancement# 1818444 to take care of parameters.
    --
    IF ((p_acad_perd IS NOT NULL) AND (p_adm_perd IS NOT NULL)) THEN
      --
      --  Extract Academic Calendar
      --
      p_acad_cal_type := RTRIM (SUBSTR (p_acad_perd, 101, 10));
      p_acad_ci_sequence_number := IGS_GE_NUMBER.TO_NUM (RTRIM (SUBSTR (p_acad_perd, 112, 6)));
      --
      --  Extract Admission Calendar
      --
      p_adm_cal_type := RTRIM (SUBSTR (p_adm_perd, 101, 10));
      p_adm_ci_sequence_number := IGS_GE_NUMBER.TO_NUM (RTRIM (SUBSTR (p_adm_perd, 112, 6)));
      --
      --  Validate if the Academic and Admission Calendar are within Calendar Instance.
      --
      IF (igs_en_gen_014.enrs_get_within_ci (
            p_acad_cal_type,
            p_acad_ci_sequence_number,
            p_adm_cal_type,
            p_adm_ci_sequence_number,
            'N'
          ) = 'N')  THEN
        errbuf := fnd_message.get_string ('IGS', 'IGS_GE_VAL_DOES_NOT_XS');
        RAISE invalid_parameter;
      END IF;
    END IF;
    /*
    **  End of code for enhancement# 1818444.
    */
    --
    --  Call Admp_Ins_Adm_Letter.
    --  Parameters were added during enhancement# 1818444.
    --
    IF (admp_ins_adm_letter (
          p_acad_cal_type,
          p_acad_ci_sequence_number,
          p_adm_cal_type,
          p_adm_ci_sequence_number,
          p_admission_cat,
          p_s_admission_process_type,
          p_correspondence_type,
          NULL,
          NULL,
          p_adm_outcome_status,
          p_message_name,
          p_reference_number,
          p_program_of_study,
          p_response_status,
          p_residency_class,
          p_residency_status,
          p_person_id_group,
          p_organization_unit,
          p_sort_by
        ) = TRUE) THEN
      retcode := 0;
    ELSE
      retcode := 2;
      errbuf := fnd_message.get_string ('IGS', p_message_name);
    END IF;
EXCEPTION
  WHEN INVALID_PARAMETER  THEN
    retcode := 2;
  WHEN OTHERS THEN
    errbuf := fnd_message.get_string ('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
    retcode := 2;
    igs_ge_msg_stack.conc_exception_hndl;
END Adms_Ins_Adm_Letter;

--removed the function Admp_Ins_Eap_Cepi (bug 2664699) rghosh

--removed the function Admp_Ins_Eap_Eapc(bug 2664699) rghosh

--removed the Function Admp_Ins_Eap_Eltpi (bug 2664699) rghosh

--removed the function Admp_Ins_Eap_Eitpi for IGR migration (bug 4114493) sjlaport

Function Admp_Ins_Phrase_Splp(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_aal_sequence_number IN NUMBER ,
  p_letter_parameter_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_spl_sequence_number IN NUMBER ,
  p_letter_repeating_group_cd IN VARCHAR2 ,
  p_splrg_sequence_number IN NUMBER,
  p_letter_order_number IN NUMBER  )
RETURN BOOLEAN IS
    gv_other_detail         VARCHAR2(255);
BEGIN   -- admp_ins_phrase_splp
    -- This module calculates the value for an admissions phrase IGS_CO_LTR_PARAM
    -- and inserts a record into the IGS_CO_S_PER_LT_PARM table
DECLARE
    v_stored        BOOLEAN DEFAULT FALSE;
    v_value         VARCHAR2(2000);
    v_sequence_number   IGS_CO_S_PER_LT_PARM.sequence_number%TYPE;

    CURSOR c_aalp (
        cp_person_id            IGS_AD_APPL_LTR_PHR.person_id%TYPE,
        cp_adm_appl_number      IGS_AD_APPL_LTR_PHR.admission_appl_number%TYPE,
        cp_correspondence_type      IGS_AD_APPL_LTR_PHR.correspondence_type%TYPE,
        cp_aal_sequence_number      IGS_AD_APPL_LTR_PHR.aal_sequence_number%TYPE,
        cp_letter_parameter_type    IGS_AD_APPL_LTR_PHR.letter_parameter_type%TYPE) IS
        SELECT  aalp.phrase_cd,
            aalp.phrase_text
        FROM    IGS_AD_APPL_LTR_PHR     aalp
        WHERE   aalp.person_id          = cp_person_id AND
            aalp.admission_appl_number  = cp_adm_appl_number AND
            aalp.correspondence_type    = cp_correspondence_type AND
            aalp.aal_sequence_number    = cp_aal_sequence_number AND
            aalp.letter_parameter_type  = cp_letter_parameter_type
        ORDER BY aalp.phrase_order_number,
             aalp.sequence_number;
    CURSOR  c_ltp (
            cp_phrase_cd            IGS_CO_LTR_PHR.phrase_cd%TYPE) IS
        SELECT  ltp.phrase_text
        FROM    IGS_CO_LTR_PHR          ltp
        WHERE   ltp.phrase_cd           = cp_phrase_cd;
    CURSOR c_get_nxt_seq IS
            SELECT IGS_CO_S_PER_LT_PARM_SEQ_NUM_S.NEXTVAL
            FROM DUAL;

    lv_rowid            VARCHAR2(25);

BEGIN
    -- Initialise variables
      v_stored := FALSE;
    FOR v_aalp_rec IN c_aalp(
                p_person_id,
                p_admission_appl_number,
                p_correspondence_type,
                p_aal_sequence_number,
                p_letter_parameter_type) LOOP
        IF(v_aalp_rec.phrase_text IS NOT NULL) THEN
            v_value := v_aalp_rec.phrase_text;
        ELSE
            OPEN    c_ltp(
                    v_aalp_rec.phrase_cd);
            FETCH   c_ltp INTO v_value;
            IF(c_ltp%NOTFOUND) THEN
                v_value := NULL;
            END IF;
            CLOSE c_ltp;
        END IF;
        IF(v_value IS NOT NULL) THEN
            -- Get IGS_CO_S_PER_LT_PARM_SEQ_NUM_S.NEXTVAL
            OPEN c_get_nxt_seq;
            FETCH c_get_nxt_seq INTO v_sequence_number;
            CLOSE c_get_nxt_seq;
            IGS_CO_S_PER_LT_Parm_Pkg.Insert_Row (
                X_Mode                              => 'R',
                X_RowId                             => lv_rowid,
                X_Person_Id                         => p_person_id,
                        X_Correspondence_Type               => p_correspondence_type,
                X_Letter_Reference_Number           => p_letter_reference_number,
                X_Spl_Sequence_Number               => p_spl_sequence_number,
                X_Letter_Parameter_Type             => p_letter_parameter_type,
                X_Sequence_Number                   => v_sequence_number,
                X_Parameter_Value                   => v_value,
                X_Letter_Repeating_Group_Cd         => p_letter_repeating_group_cd,
                X_Splrg_Sequence_Number             => p_splrg_sequence_number,
                        x_letter_order_number               => p_letter_order_number,
                        X_ORG_ID => FND_PROFILE.value('ORG_ID')
                            );

            v_stored := TRUE;
        END IF;
    END LOOP;
    RETURN v_stored;
END;
EXCEPTION
    WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
        Fnd_Message.Set_Token('NAME','IGS_AD_GEN_011.admp_ins_phrase_splp');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END admp_ins_phrase_splp;

END igs_ad_gen_011;

/
