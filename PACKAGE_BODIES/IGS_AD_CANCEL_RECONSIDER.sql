--------------------------------------------------------
--  DDL for Package Body IGS_AD_CANCEL_RECONSIDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CANCEL_RECONSIDER" AS
/* $Header: IGSADC9B.pls 120.14 2006/05/26 07:21:58 pfotedar ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL Body for package: IGS_AD_CANCEL_RECONSIDER                |
 |                                                                       |
 | NOTES : This job will close all applicatoins that are part of a person|
 |         id group, or are in a specified academic admission calendar   |
 |         and admission process category with Outcome status 'Rejected' |
 |         or 'No-Quota' and for which the reconsideration flag is set to|
 |         Yes, that the institution does not want to reconsider for the |
 |         current term or any future term. The job runs and unchecks the|
 |         Request for reconsideration flag for such application         |
 |         instances                                                     |
 | HISTORY                                                               |
 | Who             When                    What                          |
 |  rghosh      21-Oct-2003    Added the REF CURSOR c_dyn_pig_check and  |
 |                             hence the logic for supporting dynamic    |
 |                             Person ID Group                           |
 |                             (Enh# 3194295 , ADCR043: Person ID Group) |
 *=======================================================================*/

FUNCTION get_person_number ( p_person_id hz_parties.party_id%TYPE ) RETURN VARCHAR2 IS

CURSOR c_person_num IS
        SELECT party_number
        FROM   hz_parties hp
        WHERE  hp.party_id = p_person_id;

lv_person_number      hz_parties.party_number%TYPE DEFAULT NULL;
BEGIN

      OPEN c_person_num;
      FETCH c_person_num INTO lv_person_number;
      CLOSE c_person_num;

      RETURN   lv_person_number;
END   get_person_number;

PROCEDURE cancel_reconsider_appl (
        Errbuf OUT NOCOPY VARCHAR2,
        Retcode OUT NOCOPY NUMBER,
        P_person_id_group IN NUMBER,
        P_calendar_details IN VARCHAR2,
        P_application_type IN VARCHAR2,
        p_recon_no_future IN VARCHAR2,
        p_recon_future IN VARCHAR2,
        p_pend_future IN VARCHAR2) IS


     TYPE c_dyn_pig_checkCurTyp IS REF CURSOR;
     c_dyn_pig_check c_dyn_pig_checkCurTyp;

     TYPE  c_dyn_pig_checkrecTyp IS RECORD (  row_id igs_ad_ps_appl.row_id%TYPE,
                                              person_id igs_ad_ps_appl.person_id%TYPE,
                                              admission_appl_number igs_ad_ps_appl.admission_appl_number%TYPE,
                                              nominated_course_cd igs_ad_ps_appl.nominated_course_cd%TYPE,
                                              transfer_course_cd igs_ad_ps_appl.transfer_course_cd%TYPE,
                                              basis_for_admission_type igs_ad_ps_appl.basis_for_admission_type%TYPE,
                                              admission_cd igs_ad_ps_appl.admission_cd%TYPE,
                                              course_rank_set igs_ad_ps_appl.course_rank_set%TYPE,
                                              course_rank_schedule igs_ad_ps_appl.course_rank_schedule%TYPE,
                                              req_for_adv_standing_ind igs_ad_ps_appl.req_for_adv_standing_ind%TYPE );
     c_dyn_pig_check_rec c_dyn_pig_checkrecTyp ;

     TYPE c_dyn_pig_check_table IS TABLE OF c_dyn_pig_check_rec%TYPE INDEX BY BINARY_INTEGER;

     c_dyn_pig_check_table_rec c_dyn_pig_check_table;
     l_dyn_pig_check_table_count NUMBER;

     TYPE c_pend_futCurTyp IS REF CURSOR;
     c_pend_fut c_pend_futCurTyp;

     TYPE c_pend_futrecTyp IS RECORD (rowid                          igs_ad_ps_appl_inst.ROW_ID%TYPE,
                                      person_id                      igs_ad_ps_appl_inst_all.person_id%TYPE,
                                      admission_appl_number          igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                                      nominated_course_cd            igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                      sequence_number                igs_ad_ps_appl_inst_all.sequence_number%TYPE,
                                      predicted_gpa                  igs_ad_ps_appl_inst_all.predicted_gpa%TYPE,
                                      academic_index                 igs_ad_ps_appl_inst_all.academic_index%TYPE,
                                      adm_cal_type                   igs_ad_ps_appl_inst_all.adm_cal_type%TYPE,
                                      app_file_location              igs_ad_ps_appl_inst_all.app_file_location%TYPE,
                                      adm_ci_sequence_number         igs_ad_ps_appl_inst_all.adm_ci_sequence_number%TYPE,
                                      course_cd                      igs_ad_ps_appl_inst_all.course_cd%TYPE,
                                      app_source_id                  igs_ad_ps_appl_inst_all.app_source_id%TYPE,
                                      crv_version_number             igs_ad_ps_appl_inst_all.crv_version_number%TYPE,
                                      waitlist_rank                  igs_ad_ps_appl_inst_all.waitlist_rank%TYPE,
                                      location_cd                    igs_ad_ps_appl_inst_all.location_cd%TYPE,
                                      attent_other_inst_cd           igs_ad_ps_appl_inst_all.attent_other_inst_cd%TYPE,
                                      attendance_mode                igs_ad_ps_appl_inst_all.attendance_mode%TYPE,
                                      edu_goal_prior_enroll_id       igs_ad_ps_appl_inst_all.edu_goal_prior_enroll_id%TYPE,
                                      attendance_type                igs_ad_ps_appl_inst_all.attendance_type%TYPE,
                                      decision_make_id               igs_ad_ps_appl_inst_all.decision_make_id%TYPE,
                                      unit_set_cd                    igs_ad_ps_appl_inst_all.unit_set_cd%TYPE,
                                      decision_date                  igs_ad_ps_appl_inst_all.decision_date%TYPE,
                                      attribute_category             igs_ad_ps_appl_inst_all.attribute_category%TYPE,
                                      attribute1                     igs_ad_ps_appl_inst_all.attribute1%TYPE,
                                      attribute2                     igs_ad_ps_appl_inst_all.attribute2%TYPE,
                                      attribute3                     igs_ad_ps_appl_inst_all.attribute3%TYPE,
                                      attribute4                     igs_ad_ps_appl_inst_all.attribute4%TYPE,
                                      attribute5                     igs_ad_ps_appl_inst_all.attribute5%TYPE,
                                      attribute6                     igs_ad_ps_appl_inst_all.attribute6%TYPE,
                                      attribute7                     igs_ad_ps_appl_inst_all.attribute7%TYPE,
                                      attribute8                     igs_ad_ps_appl_inst_all.attribute8%TYPE,
                                      attribute9                     igs_ad_ps_appl_inst_all.attribute9%TYPE,
                                      attribute10                    igs_ad_ps_appl_inst_all.attribute10%TYPE,
                                      attribute11                    igs_ad_ps_appl_inst_all.attribute11%TYPE,
                                      attribute12                    igs_ad_ps_appl_inst_all.attribute12%TYPE,
                                      attribute13                    igs_ad_ps_appl_inst_all.attribute13%TYPE,
                                      attribute14                    igs_ad_ps_appl_inst_all.attribute14%TYPE,
                                      attribute15                    igs_ad_ps_appl_inst_all.attribute15%TYPE,
                                      attribute16                    igs_ad_ps_appl_inst_all.attribute16%TYPE,
                                      attribute17                    igs_ad_ps_appl_inst_all.attribute17%TYPE,
                                      attribute18                    igs_ad_ps_appl_inst_all.attribute18%TYPE,
                                      attribute19                    igs_ad_ps_appl_inst_all.attribute19%TYPE,
                                      attribute20                    igs_ad_ps_appl_inst_all.attribute20%TYPE,
                                      decision_reason_id             igs_ad_ps_appl_inst_all.decision_reason_id%TYPE,
                                      us_version_number              igs_ad_ps_appl_inst_all.us_version_number%TYPE,
                                      decision_notes                 igs_ad_ps_appl_inst_all.decision_notes%TYPE,
                                      pending_reason_id              igs_ad_ps_appl_inst_all.pending_reason_id%TYPE,
                                      preference_number              igs_ad_ps_appl_inst_all.preference_number%TYPE,
                                      adm_doc_status                 igs_ad_ps_appl_inst_all.adm_doc_status%TYPE,
                                      adm_entry_qual_status          igs_ad_ps_appl_inst_all.adm_entry_qual_status%TYPE,
                                      deficiency_in_prep             igs_ad_ps_appl_inst_all.deficiency_in_prep%TYPE,
                                      late_adm_fee_status            igs_ad_ps_appl_inst_all.late_adm_fee_status%TYPE,
                                      spl_consider_comments          igs_ad_ps_appl_inst_all.spl_consider_comments%TYPE,
                                      apply_for_finaid               igs_ad_ps_appl_inst_all.apply_for_finaid%TYPE,
                                      finaid_apply_date              igs_ad_ps_appl_inst_all.finaid_apply_date%TYPE,
                                      adm_outcome_status             igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE,
                                      adm_otcm_status_auth_person_id igs_ad_ps_appl_inst_all.ADM_OTCM_STATUS_AUTH_PERSON_ID%TYPE,
                                      adm_outcome_status_auth_dt     igs_ad_ps_appl_inst_all.adm_outcome_status_auth_dt%TYPE,
                                      adm_outcome_status_reason      igs_ad_ps_appl_inst_all.adm_outcome_status_reason%TYPE,
                                      offer_dt                       igs_ad_ps_appl_inst_all.offer_dt%TYPE,
                                      offer_response_dt              igs_ad_ps_appl_inst_all.offer_response_dt%TYPE,
                                      prpsd_commencement_dt          igs_ad_ps_appl_inst_all.prpsd_commencement_dt%TYPE,
                                      adm_cndtnl_offer_status        igs_ad_ps_appl_inst_all.adm_cndtnl_offer_status%TYPE,
                                      cndtnl_offer_satisfied_dt      igs_ad_ps_appl_inst_all.cndtnl_offer_satisfied_dt%TYPE,
                                      cndtnl_offer_must_be_stsfd_ind igs_ad_ps_appl_inst_all.CNDTNL_OFFER_MUST_BE_STSFD_IND%TYPE,
                                      adm_offer_resp_status          igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE,
                                      actual_response_dt             igs_ad_ps_appl_inst_all.actual_response_dt%TYPE,
                                      adm_offer_dfrmnt_status        igs_ad_ps_appl_inst_all.adm_offer_dfrmnt_status%TYPE,
                                      deferred_adm_cal_type          igs_ad_ps_appl_inst_all.deferred_adm_cal_type%TYPE,
                                      deferred_adm_ci_sequence_num   igs_ad_ps_appl_inst_all.deferred_adm_ci_sequence_num%TYPE,
                                      deferred_tracking_id           igs_ad_ps_appl_inst_all.deferred_tracking_id%TYPE,
                                      ass_rank                       igs_ad_ps_appl_inst_all.ass_rank%TYPE,
                                      secondary_ass_rank             igs_ad_ps_appl_inst_all.secondary_ass_rank%TYPE,
                                      intrntnl_acceptance_advice_num igs_ad_ps_appl_inst_all.intrntnl_acceptance_advice_num%TYPE,
                                      ass_tracking_id                igs_ad_ps_appl_inst_all.ass_tracking_id%TYPE,
                                      fee_cat                        igs_ad_ps_appl_inst_all.fee_cat%TYPE,
                                      hecs_payment_option            igs_ad_ps_appl_inst_all.hecs_payment_option%TYPE,
                                      expected_completion_yr         igs_ad_ps_appl_inst_all.expected_completion_yr%TYPE,
                                      expected_completion_perd       igs_ad_ps_appl_inst_all.expected_completion_perd%TYPE,
                                      correspondence_cat             igs_ad_ps_appl_inst_all.correspondence_cat%TYPE,
                                      enrolment_cat                  igs_ad_ps_appl_inst_all.enrolment_cat%TYPE,
                                      funding_source                 igs_ad_ps_appl_inst_all.funding_source%TYPE,
                                      applicant_acptnce_cndtn        igs_ad_ps_appl_inst_all.applicant_acptnce_cndtn%TYPE,
                                      cndtnl_offer_cndtn             igs_ad_ps_appl_inst_all.cndtnl_offer_cndtn%TYPE,
                                      ss_application_id              igs_ad_ps_appl_inst_all.ss_application_id%TYPE,
                                      ss_pwd                         igs_ad_ps_appl_inst_all.ss_pwd%TYPE,
                                      authorized_dt                  igs_ad_ps_appl_inst_all.authorized_dt%TYPE,
                                      authorizing_pers_id            igs_ad_ps_appl_inst_all.authorizing_pers_id%TYPE,
                                      entry_status                   igs_ad_ps_appl_inst_all.entry_status%TYPE,
                                      entry_level                    igs_ad_ps_appl_inst_all.entry_level%TYPE,
                                      sch_apl_to_id                  igs_ad_ps_appl_inst_all.sch_apl_to_id%TYPE,
                                      idx_calc_date                  igs_ad_ps_appl_inst_all.idx_calc_date%TYPE,
                                      waitlist_status                igs_ad_ps_appl_inst_all.waitlist_status%TYPE,
                                      attribute21                    igs_ad_ps_appl_inst_all.attribute21%TYPE,
                                      attribute22                    igs_ad_ps_appl_inst_all.attribute22%TYPE,
                                      attribute23                    igs_ad_ps_appl_inst_all.attribute23%TYPE,
                                      attribute24                    igs_ad_ps_appl_inst_all.attribute24%TYPE,
                                      attribute25                    igs_ad_ps_appl_inst_all.attribute25%TYPE,
                                      attribute26                    igs_ad_ps_appl_inst_all.attribute26%TYPE,
                                      attribute27                    igs_ad_ps_appl_inst_all.attribute27%TYPE,
                                      attribute28                    igs_ad_ps_appl_inst_all.attribute28%TYPE,
                                      attribute29                    igs_ad_ps_appl_inst_all.attribute29%TYPE,
                                      attribute30                    igs_ad_ps_appl_inst_all.attribute30%TYPE,
                                      attribute31                    igs_ad_ps_appl_inst_all.attribute31%TYPE,
                                      attribute32                    igs_ad_ps_appl_inst_all.attribute32%TYPE,
                                      attribute33                    igs_ad_ps_appl_inst_all.attribute33%TYPE,
                                      attribute34                    igs_ad_ps_appl_inst_all.attribute34%TYPE,
                                      attribute35                    igs_ad_ps_appl_inst_all.attribute35%TYPE,
                                      attribute36                    igs_ad_ps_appl_inst_all.attribute36%TYPE,
                                      attribute37                    igs_ad_ps_appl_inst_all.attribute37%TYPE,
                                      attribute38                    igs_ad_ps_appl_inst_all.attribute38%TYPE,
                                      attribute39                    igs_ad_ps_appl_inst_all.attribute39%TYPE,
                                      attribute40                    igs_ad_ps_appl_inst_all.attribute40%TYPE,
                                      future_acad_cal_type           igs_ad_ps_appl_inst_all.future_acad_cal_type%TYPE,
                                      future_acad_ci_sequence_number igs_ad_ps_appl_inst_all.future_acad_ci_sequence_number%TYPE,
                                      future_adm_cal_type            igs_ad_ps_appl_inst_all.future_adm_cal_type%TYPE,
                                      future_adm_ci_sequence_number  igs_ad_ps_appl_inst_all.future_adm_ci_sequence_number%TYPE,
                                      previous_term_adm_appl_number  igs_ad_ps_appl_inst_all.PREVIOUS_TERM_ADM_APPL_NUMBER%TYPE,
                                      previous_term_sequence_number  igs_ad_ps_appl_inst_all.PREVIOUS_TERM_SEQUENCE_NUMBER%TYPE,
                                      future_term_adm_appl_number    igs_ad_ps_appl_inst_all.future_term_adm_appl_number%TYPE,
                                      future_term_sequence_number    igs_ad_ps_appl_inst_all.future_term_sequence_number%TYPE,
                                      def_acad_cal_type              igs_ad_ps_appl_inst_all.def_acad_cal_type%TYPE,
                                      def_acad_ci_sequence_num       igs_ad_ps_appl_inst_all.def_acad_ci_sequence_num%TYPE,
                                      def_prev_term_adm_appl_num     igs_ad_ps_appl_inst_all.def_prev_term_adm_appl_num%TYPE,
                                      def_prev_appl_sequence_num     igs_ad_ps_appl_inst_all.def_prev_appl_sequence_num%TYPE,
                                      def_term_adm_appl_num          igs_ad_ps_appl_inst_all.def_term_adm_appl_num%TYPE,
                                      def_appl_sequence_num          igs_ad_ps_appl_inst_all.def_appl_sequence_num%TYPE,
                                      appl_inst_status               igs_ad_ps_appl_inst_all.appl_inst_status%TYPE,
                                      ais_reason                     igs_ad_ps_appl_inst_all.ais_reason%TYPE,
                                      decline_ofr_reason             igs_ad_ps_appl_inst_all.decline_ofr_reason%TYPE);

     c_pend_fut_rec c_pend_futrecTyp;

     TYPE c_pend_fut_table IS TABLE OF c_pend_fut_rec%TYPE INDEX BY BINARY_INTEGER;
     c_pend_fut_table_rec c_pend_fut_table;

     l_pend_fut_table_count NUMBER;

     lv_status     VARCHAR2(1) ;  /*Defaulted to 'S' and the function will return 'F' in case of failure */
     lv_sql_stmt   VARCHAR(32767) ;



        CURSOR c_get_ad_ps_appl (cp_acad_cal_type Igs_ad_appl.acad_cal_type%TYPE,
                                 cp_acad_sequence_number Igs_ad_appl.acad_ci_sequence_number%TYPE,
                                 cp_adm_cal_type Igs_ad_appl.adm_cal_type%TYPE,
                                 cp_adm_sequence_number Igs_ad_appl.adm_ci_sequence_number%TYPE,
                                 cp_admission_cat Igs_ad_appl.admission_cat%TYPE,
                                 cp_s_adm_process_typ Igs_ad_appl.s_admission_process_type%TYPE) IS
             SELECT distinct psapl.*
             FROM igs_ad_ps_appl_inst apai,
                  igs_ad_ps_appl psapl,
                  igs_ad_ou_stat aos,
                  igs_ad_appl aa,
                  igs_ad_appl_stat aps
             WHERE (( Aa.acad_cal_type = cp_acad_cal_type AND cp_acad_cal_type IS NOT NULL) OR ( cp_acad_cal_type IS NULL))AND
                   (( Aa.acad_ci_sequence_number = cp_acad_sequence_number AND cp_acad_sequence_number IS NOT NULL)OR (cp_acad_sequence_number IS NULL) ) AND
                   (( Aa.adm_cal_type = cp_adm_cal_type AND cp_adm_cal_type IS NOT NULL) OR (cp_adm_cal_type IS NULL) ) AND
                   (( Aa.adm_ci_sequence_number = cp_adm_sequence_number AND cp_adm_sequence_number IS NOT NULL) OR (cp_adm_sequence_number IS NULL) ) AND
                   (( Aa.admission_cat = cp_admission_cat AND cp_admission_cat IS NOT NULL) OR (cp_admission_cat IS NULL)) AND
                   (( Aa.s_admission_process_type = cp_s_adm_process_typ AND cp_s_adm_process_typ IS NOT NULL) OR (cp_s_adm_process_typ IS NULL) ) AND
                   Apai.adm_outcome_status = aos.adm_outcome_status AND
                   Aos.s_adm_outcome_status = 'PENDING'  AND
                   NVL(apai.appl_inst_status,'RECEIVED') NOT IN (SELECT adm_appl_status FROM igs_ad_appl_stat WHERE S_ADM_APPL_STATUS = 'WITHDRAWN') AND
                   Psapl.req_for_reconsideration_ind = 'Y' AND
                   Apai.person_id = psapl.person_id AND
                   Apai.admission_appl_number = psapl.admission_appl_number AND
                   Apai.nominated_course_cd = psapl.nominated_course_cd AND
                   Aa.person_id=apai.person_id AND
                   Aa.admission_appl_number = apai.admission_appl_number AND
                   Aa.adm_appl_status = aps.adm_appl_status AND
                   (((p_recon_no_future = 'Y') AND (apai.future_acad_cal_type IS NULL AND apai.future_acad_ci_sequence_number IS NULL
                   AND apai.future_adm_cal_type IS NULL AND apai.future_adm_ci_sequence_number IS NULL))
                   OR ((p_recon_future = 'Y') AND (apai.future_acad_cal_type IS NOT NULL AND apai.future_acad_ci_sequence_number IS NOT NULL
                   AND apai.future_adm_cal_type IS NOT NULL AND apai.future_adm_ci_sequence_number IS NOT NULL)));

        l_get_ad_ps_appl_rec c_get_ad_ps_appl%ROWTYPE;

        CURSOR c_get_fut_appl_inst(cp_acad_cal_type Igs_ad_appl.acad_cal_type%TYPE,
                                   cp_acad_sequence_number Igs_ad_appl.acad_ci_sequence_number%TYPE,
                                   cp_adm_cal_type Igs_ad_appl.adm_cal_type%TYPE,
                                   cp_adm_sequence_number Igs_ad_appl.adm_ci_sequence_number%TYPE,
                                   cp_admission_cat Igs_ad_appl.admission_cat%TYPE,
                                   cp_s_adm_process_typ Igs_ad_appl.s_admission_process_type%TYPE)IS
          SELECT apai.rowid, apai.*
          FROM   Igs_ad_ps_appl_inst apai,
                 Igs_ad_ps_appl psapl,
                 Igs_ad_ou_stat aos,
                 Igs_ad_appl_all Aa
          WHERE  (( Aa.acad_cal_type = cp_acad_cal_type AND cp_acad_cal_type IS NOT NULL) OR ( cp_acad_cal_type IS NULL))AND
                 (( Aa.acad_ci_sequence_number = cp_acad_sequence_number AND cp_acad_sequence_number IS NOT NULL)OR (cp_acad_sequence_number IS NULL) ) AND
                 (( Aa.adm_cal_type = cp_adm_cal_type AND cp_adm_cal_type IS NOT NULL) OR (cp_adm_cal_type IS NULL) ) AND
                 (( Aa.adm_ci_sequence_number = cp_adm_sequence_number AND cp_adm_sequence_number IS NOT NULL) OR (cp_adm_sequence_number IS NULL) ) AND
                 (( Aa.admission_cat = cp_admission_cat AND cp_admission_cat IS NOT NULL) OR (cp_admission_cat IS NULL)) AND
                 (( Aa.s_admission_process_type = cp_s_adm_process_typ AND cp_s_adm_process_typ IS NOT NULL) OR (cp_s_adm_process_typ IS NULL) ) AND
                 Apai.adm_outcome_status = aos.adm_outcome_status AND
                 Aos.s_adm_outcome_status =  'PENDING'  AND
                 NVL(apai.appl_inst_status,'RECEIVED') NOT IN (SELECT adm_appl_status FROM igs_ad_appl_stat WHERE S_ADM_APPL_STATUS = 'WITHDRAWN') AND
                 Psapl.req_for_reconsideration_ind <> 'Y' AND
                 Apai.person_id = psapl.person_id AND
                 Apai.admission_appl_number = psapl.admission_appl_number AND
                 Apai.nominated_course_cd = psapl.nominated_course_cd AND
                 apai.person_id = aa.person_id AND
                 apai.admission_appl_number = aa.admission_appl_number AND
                 Apai.future_acad_cal_type  IS NOT NULL AND
                 Apai.future_acad_ci_sequence_number IS NOT NULL AND
                 Apai.future_adm_cal_type IS NOT NULL AND
                 Apai.future_adm_ci_sequence_number IS NOT NULL;

        l_get_fut_appl_inst c_get_fut_appl_inst%ROWTYPE;

        CURSOR c_get_alternate_code (cp_cal_type igs_ca_inst_all.cal_type%TYPE,
                                     cp_sequence_number igs_ca_inst_all.sequence_number%TYPE) IS
            SELECT alternate_code
            FROM igs_ca_inst_all
            WHERE cal_type = cp_cal_type
            AND sequence_number = cp_sequence_number;

        l_acad_alternate_code igs_ca_inst_all.alternate_code%TYPE;
        l_adm_alternate_code igs_ca_inst_all.alternate_code%TYPE;

        CURSOR c_get_adm_process_type (cp_s_admission_process_type igs_lookup_values.lookup_code%TYPE) IS
            SELECT meaning
            FROM igs_lookup_values
            WHERE lookup_type = 'ADMISSION_PROCESS_TYPE'
            AND   lookup_code = cp_s_admission_process_type;

        l_get_adm_process_type igs_ad_prcs_cat_v.meaning%TYPE;

        CURSOR c_get_application_id (cp_person_id igs_ad_appl_all.person_id%TYPE,
                                     cp_admission_appl_number igs_ad_appl_all.admission_appl_number%TYPE) IS
            SELECT application_id
            FROM igs_ad_appl_all
            WHERE person_id = cp_person_id
            AND admission_appl_number = cp_admission_appl_number;

        CURSOR c_get_inst_dtls(cp_person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                               cp_admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                               cp_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE) IS
          SELECT apai.rowid,apai.*
          FROM igs_ad_ps_appl_inst_all apai
          WHERE apai.person_id = cp_person_id
          AND   apai.admission_appl_number = cp_admission_appl_number
          AND   apai.nominated_course_cd = cp_nominated_course_cd
          AND   NVL(apai.appl_inst_status,'RECEIVED') NOT IN (SELECT adm_appl_status FROM igs_ad_appl_stat WHERE S_ADM_APPL_STATUS = 'WITHDRAWN');

        l_get_inst_dtls_rec c_get_inst_dtls%ROWTYPE;

        l_get_application_id igs_ad_appl_all.application_id%TYPE;

        CURSOR c_get_aplinsthist_dtls(cp_person_id igs_ad_ps_aplinsthst_all.person_id%TYPE,
                                      cp_admission_appl_number igs_ad_ps_aplinsthst_all.admission_appl_number%TYPE,
                                      cp_nominated_course_cd igs_ad_ps_aplinsthst_all.nominated_course_cd%TYPE,
                                      cp_sequence_number igs_ad_ps_aplinsthst_all.sequence_number%TYPE) IS
          SELECT hist.*
          FROM   igs_ad_ps_aplinsthst_all hist
          WHERE  person_id = cp_person_id
          AND    admission_appl_number = cp_admission_appl_number
          AND    nominated_course_cd = cp_nominated_course_cd
          AND    sequence_number = cp_sequence_number;

        l_get_aplinsthist_dtls_rec c_get_aplinsthist_dtls%ROWTYPE;

        CURSOR c_get_hist_dt (cp_person_id igs_ad_ps_aplinsthst_all.person_id%TYPE,
                              cp_admission_appl_number igs_ad_ps_aplinsthst_all.admission_appl_number%TYPE,
                              cp_nominated_course_cd igs_ad_ps_aplinsthst_all.nominated_course_cd%TYPE,
                              cp_sequence_number igs_ad_ps_aplinsthst_all.sequence_number%TYPE) IS
          SELECT MAX(hist_start_dt) latest_record
          FROM   igs_ad_ps_aplinsthst_all
          WHERE  person_id = cp_person_id
          AND    admission_appl_number = cp_admission_appl_number
          AND    nominated_course_cd = cp_nominated_course_cd
          AND    sequence_number = cp_sequence_number
          AND    NVL(reconsider_flag,'N') = 'N';

        l_get_hist_dt DATE;

        CURSOR c_get_pending_hist (cp_person_id igs_ad_ps_aplinsthst_all.person_id%TYPE,
                                   cp_admission_appl_number igs_ad_ps_aplinsthst_all.admission_appl_number%TYPE,
                                   cp_nominated_course_cd igs_ad_ps_aplinsthst_all.nominated_course_cd%TYPE,
                                   cp_sequence_number igs_ad_ps_aplinsthst_all.sequence_number%TYPE,
                                   cp_hist_start_dt igs_ad_ps_aplinsthst_all.hist_start_dt%TYPE) IS
          SELECT hist.*
          FROM   igs_ad_ps_aplinsthst_all hist
          WHERE  person_id = cp_person_id
          AND    admission_appl_number = cp_admission_appl_number
          AND    nominated_course_cd = cp_nominated_course_cd
          AND    sequence_number = cp_sequence_number
          AND    hist_start_dt > cp_hist_start_dt
          AND    NVL(adm_outcome_status,'PENDING') <> 'PENDING';

        l_get_pending_hist_rec c_get_pending_hist%ROWTYPE;

        CURSOR c_admission_type (cp_admission_type IGS_AD_SS_APPL_TYP.ADMISSION_APPLICATION_TYPE%TYPE) IS
          SELECT admission_cat, s_admission_process_type
          FROM igs_ad_ss_appl_typ
          WHERE admission_application_type = cp_admission_type;

        l_admission_type c_admission_type%ROWTYPE;

        CURSOR c_apcs(cp_admission_cat IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE, cp_s_admission_process_type IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
          SELECT 'Y'
          FROM IGS_AD_PRCS_CAT_STEP
          WHERE admission_cat = cp_admission_cat
          AND s_admission_process_type = cp_s_admission_process_type
          AND s_admission_step_type = 'PRE-ENROL'
          AND step_group_type <> 'TRACK';

        l_apcs VARCHAR2(1);

        CURSOR c_adm_cat(cp_person_id igs_ad_ps_aplinsthst_all.person_id%TYPE,
                         cp_admission_appl_number igs_ad_ps_aplinsthst_all.admission_appl_number%TYPE) IS
          SELECT admission_cat,s_admission_process_type
          FROM igs_ad_appl_all
          WHERE person_id = cp_person_id
          AND   admission_appl_number = cp_admission_appl_number;

        l_adm_cat c_adm_cat%ROWTYPE;

        l_acad_cal_type        Igs_ad_appl.acad_cal_type%TYPE ;
        l_acad_sequence_number Igs_ad_appl.acad_ci_sequence_number%TYPE ;
        l_adm_cal_type         Igs_ad_appl.adm_cal_type%TYPE ;
        l_adm_sequence_number  Igs_ad_appl.adm_ci_sequence_number%TYPE ;
        l_admission_cat        Igs_ad_appl.admission_cat%TYPE ;
        l_s_adm_process_typ    Igs_ad_appl.s_admission_process_type%TYPE;
        l_processing_ind       VARCHAR2(1);

        -- this indicator will keep a track whether the cancel reconsideration job failed for any of the application programs.
        l_record_errored       VARCHAR2(1)  ;

        l_recon_future VARCHAR2(1);
        l_recon_no_future VARCHAR2(1);

        l_record_failed VARCHAR2(1);
        lv_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

        l_sql_stmt1 VARCHAR2(32676) := 'SELECT distinct psapl.row_id,psapl.person_id, psapl.admission_appl_number,psapl.nominated_course_cd,
                   psapl.transfer_course_cd,psapl.basis_for_admission_type,psapl.admission_cd,
                   psapl.course_rank_set,psapl.course_rank_schedule, psapl.req_for_adv_standing_ind
            FROM
                Igs_ad_ps_appl_inst apai,
                igs_ad_ps_appl psapl,
                Igs_ad_ou_stat aos,
                Igs_ad_appl aa,
                Igs_ad_appl_stat aps
            WHERE
                Apai.person_id IN ';

        l_sql_stmt2 VARCHAR2(4000) := '  AND
                Aa.acad_cal_type = NVL ( :1 , aa.acad_cal_type) AND
                Aa.acad_ci_sequence_number = DECODE ( :2, -1,aa.acad_ci_sequence_number, :2 )  AND
                Aa.adm_cal_type = NVL ( :3 , aa.adm_cal_type) AND
                Aa.adm_ci_sequence_number = DECODE  ( :4, -1,aa.adm_ci_sequence_number, :4 )  AND
                Aa.admission_cat = NVL ( :5, aa.admission_cat) AND
                Aa.s_admission_process_type = NVL ( :6 , aa.s_admission_process_type) AND
                Apai.adm_outcome_status = aos.adm_outcome_status AND
                Aos.s_adm_outcome_status = ''PENDING''  AND
                NVL(apai.appl_inst_status,''RECEIVED'') NOT IN (SELECT adm_appl_status FROM igs_ad_appl_stat WHERE S_ADM_APPL_STATUS = ''WITHDRAWN'') AND
                Psapl.req_for_reconsideration_ind = ''Y'' AND
                Apai.person_id = psapl.person_id AND
                Apai.admission_appl_number = psapl.admission_appl_number AND
                Apai.nominated_course_cd = psapl.nominated_course_cd AND
                Aa.person_id=apai.person_id AND
                Aa.admission_appl_number = apai.admission_appl_number AND
                Aa.adm_appl_status = aps.adm_appl_status AND
                (((:7 = ''Y'') AND
                (apai.future_acad_cal_type IS NULL AND apai.future_acad_ci_sequence_number IS NULL AND
                   apai.future_adm_cal_type IS NULL AND apai.future_adm_ci_sequence_number IS NULL))
                OR ((:8 = ''Y'')  AND
                   (apai.future_acad_cal_type IS NOT NULL AND apai.future_acad_ci_sequence_number IS NOT NULL AND
                   apai.future_adm_cal_type IS NOT NULL AND apai.future_adm_ci_sequence_number IS NOT NULL)))';

         l_sql_stmt3 VARCHAR2(32676) :=
                  'SELECT
                    apai.row_id,
                    apai.person_id,
                    apai.admission_appl_number,
                    apai.nominated_course_cd,
                    apai.sequence_number,
                    apai.predicted_gpa,
                    apai.academic_index,
                    apai.adm_cal_type,
                    apai.app_file_location,
                    apai.adm_ci_sequence_number,
                    apai.course_cd,
                    apai.app_source_id,
                    apai.crv_version_number,
                    apai.waitlist_rank,
                    apai.location_cd,
                    apai.attent_other_inst_cd,
                    apai.attendance_mode,
                    apai.edu_goal_prior_enroll_id,
                    apai.attendance_type,
                    apai.decision_make_id,
                    apai.unit_set_cd,
                    apai.decision_date,
                    apai.attribute_category,
                    apai.attribute1,
                    apai.attribute2,
                    apai.attribute3,
                    apai.attribute4,
                    apai.attribute5,
                    apai.attribute6,
                    apai.attribute7,
                    apai.attribute8,
                    apai.attribute9,
                    apai.attribute10,
                    apai.attribute11,
                    apai.attribute12,
                    apai.attribute13,
                    apai.attribute14,
                    apai.attribute15,
                    apai.attribute16,
                    apai.attribute17,
                    apai.attribute18,
                    apai.attribute19,
                    apai.attribute20,
                    apai.decision_reason_id,
                    apai.us_version_number,
                    apai.decision_notes,
                    apai.pending_reason_id,
                    apai.preference_number,
                    apai.adm_doc_status,
                    apai.adm_entry_qual_status,
                    apai.deficiency_in_prep,
                    apai.late_adm_fee_status,
                    apai.spl_consider_comments,
                    apai.apply_for_finaid,
                    apai.finaid_apply_date,
                    apai.adm_outcome_status,
                    apai.adm_otcm_status_auth_person_id,
                    apai.adm_outcome_status_auth_dt,
                    apai.adm_outcome_status_reason,
                    apai.offer_dt,
                    apai.offer_response_dt,
                    apai.prpsd_commencement_dt,
                    apai.adm_cndtnl_offer_status,
                    apai.cndtnl_offer_satisfied_dt,
                    apai.cndtnl_offer_must_be_stsfd_ind,
                    apai.adm_offer_resp_status,
                    apai.actual_response_dt,
                    apai.adm_offer_dfrmnt_status,
                    apai.deferred_adm_cal_type,
                    apai.deferred_adm_ci_sequence_num,
                    apai.deferred_tracking_id,
                    apai.ass_rank,
                    apai.secondary_ass_rank,
                    apai.intrntnl_acceptance_advice_num,
                    apai.ass_tracking_id,
                    apai.fee_cat,
                    apai.hecs_payment_option,
                    apai.expected_completion_yr,
                    apai.expected_completion_perd,
                    apai.correspondence_cat,
                    apai.enrolment_cat,
                    apai.funding_source,
                    apai.applicant_acptnce_cndtn,
                    apai.cndtnl_offer_cndtn,
                    apai.ss_application_id,
                    apai.ss_pwd,
                    apai.authorized_dt,
                    apai.authorizing_pers_id,
                    apai.entry_status,
                    apai.entry_level,
                    apai.sch_apl_to_id,
                    apai.idx_calc_date,
                    apai.waitlist_status,
                    apai.attribute21,
                    apai.attribute22,
                    apai.attribute23,
                    apai.attribute24,
                    apai.attribute25,
                    apai.attribute26,
                    apai.attribute27,
                    apai.attribute28,
                    apai.attribute29,
                    apai.attribute30,
                    apai.attribute31,
                    apai.attribute32,
                    apai.attribute33,
                    apai.attribute34,
                    apai.attribute35,
                    apai.attribute36,
                    apai.attribute37,
                    apai.attribute38,
                    apai.attribute39,
                    apai.attribute40,
                    apai.future_acad_cal_type,
                    apai.future_acad_ci_sequence_number,
                    apai.future_adm_cal_type,
                    apai.future_adm_ci_sequence_number,
                    apai.previous_term_adm_appl_number,
                    apai.previous_term_sequence_number,
                    apai.future_term_adm_appl_number,
                    apai.future_term_sequence_number,
                    apai.def_acad_cal_type,
                    apai.def_acad_ci_sequence_num,
                    apai.def_prev_term_adm_appl_num,
                    apai.def_prev_appl_sequence_num,
                    apai.def_term_adm_appl_num,
                    apai.def_appl_sequence_num,
                    apai.appl_inst_status,
                    apai.ais_reason,
                    apai.decline_ofr_reason
             FROM   Igs_ad_ps_appl_inst apai,
                    Igs_ad_ps_appl psapl,
                    Igs_ad_ou_stat aos,
                    Igs_ad_appl_all Aa
             WHERE  Apai.person_id IN ';

           l_sql_stmt4 VARCHAR2(4000) ;


 BEGIN

   -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
   igs_ge_gen_003.set_org_id(null);

   retcode := 0;
   errbuf := NULL;
   lv_status := 'S';
   lv_sql_stmt :=  igs_pe_dynamic_persid_group.get_dynamic_sql (p_person_id_group,lv_status,lv_group_type);
   l_acad_cal_type := RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
   l_acad_sequence_number := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));
   l_adm_cal_type := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
   l_adm_sequence_number := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));
   l_record_errored := 'N';
   igs_ge_msg_stack.initialize;

   -- If the person id group as well as the session details are not entered then
   -- it should give an error, since for job atleast one of the person id group or the session details are mandatory

     OPEN c_get_alternate_code(l_acad_cal_type,l_acad_sequence_number);
     FETCH c_get_alternate_code INTO l_acad_alternate_code;
     CLOSE c_get_alternate_code;

     OPEN c_get_alternate_code(l_adm_cal_type,l_adm_sequence_number);
     FETCH c_get_alternate_code INTO l_adm_alternate_code;
     CLOSE c_get_alternate_code;

     OPEN c_get_adm_process_type(l_s_adm_process_typ);
     FETCH c_get_adm_process_type INTO l_get_adm_process_type;
     CLOSE c_get_adm_process_type;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Person ID Group               :' || p_person_id_group);

     IF (l_acad_alternate_code IS NOT NULL AND l_adm_alternate_code IS NOT NULL) THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Calendar Details              :' || l_acad_alternate_code || '/' || l_adm_alternate_code);
     ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Calendar Details              :' );
     END IF;

     IF l_get_adm_process_type IS NOT NULL THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Application Type          :' || p_application_type);
     ELSE
       FND_FILE.PUT_LINE(FND_FILE.LOG,'Application Type          :' );
     END IF;

     FND_FILE.PUT_LINE(FND_FILE.LOG,'' );
     FND_FILE.PUT_LINE(FND_FILE.LOG,'Application Program Information :' );

     OPEN c_admission_type(p_application_type);
     FETCH c_admission_type INTO l_admission_type;
     CLOSE c_admission_type;

     l_admission_cat := l_admission_type.admission_cat;
     l_s_adm_process_typ := l_admission_type.s_admission_process_type;

     -- This indicator will keep a track whether any of the applicaton programs are processed.
     l_processing_ind := 'N';
      IF (P_person_id_group IS NULL) THEN


        IF p_recon_future = 'Y' OR p_recon_no_future = 'Y' THEN



             OPEN c_get_ad_ps_appl (l_acad_cal_type,
                                    l_acad_sequence_number,
                                    l_adm_cal_type,
                                    l_adm_sequence_number,
                                    l_admission_cat,
                                    l_s_adm_process_typ);

            LOOP


              FETCH c_get_ad_ps_appl INTO l_get_ad_ps_appl_rec;
              EXIT WHEN c_get_ad_ps_appl%NOTFOUND;

              l_processing_ind := 'Y';

              OPEN c_get_application_id(l_get_ad_ps_appl_rec.person_id,l_get_ad_ps_appl_rec.admission_appl_number);
              FETCH c_get_application_id INTO l_get_application_id;
              CLOSE c_get_application_id;

              SAVEPOINT c_create_prog;

              DECLARE

                l_max_msg_count NUMBER;
                l_msg_data VARCHAR2(2000);
                l_msg_index_out NUMBER;
                l_app_name VARCHAR2(2000);
                v_message_name VARCHAR2(2000);

              BEGIN

                igs_ad_ps_appl_pkg.update_row (
                    x_rowid =>  l_get_ad_ps_appl_rec.row_id,
                    x_person_id =>  l_get_ad_ps_appl_rec.person_id,
                    x_admission_appl_number =>  l_get_ad_ps_appl_rec.admission_appl_number,
                    x_nominated_course_cd =>  l_get_ad_ps_appl_rec.nominated_course_cd,
                    x_transfer_course_cd =>  l_get_ad_ps_appl_rec.transfer_course_cd,
                    x_basis_for_admission_type =>  l_get_ad_ps_appl_rec.basis_for_admission_type,
                    x_admission_cd =>  l_get_ad_ps_appl_rec.admission_cd,
                    x_course_rank_set =>  l_get_ad_ps_appl_rec.course_rank_set,
                    x_course_rank_schedule =>  l_get_ad_ps_appl_rec.course_rank_schedule,
                    x_req_for_reconsideration_ind =>  'N',
                    x_req_for_adv_standing_ind =>  l_get_ad_ps_appl_rec.req_for_adv_standing_ind ,
                    x_mode =>  'R' ) ;

                FOR l_get_inst_dtls_rec IN c_get_inst_dtls(l_get_ad_ps_appl_rec.person_id,
                                                           l_get_ad_ps_appl_rec.admission_appl_number,
                                                           l_get_ad_ps_appl_rec.nominated_course_cd) LOOP

                FND_FILE.PUT_LINE(FND_FILE.LOG,' Person Number: ' || RPAD(get_person_number(l_get_ad_ps_appl_rec.person_id),15,' ') || ' Application ID: ' ||
                                  RPAD(l_get_application_id,15,' ') || ' Program: ' || RPAD(l_get_ad_ps_appl_rec.nominated_course_cd,6,' ')
                                  || 'Sequence Number: ' || RPAD(l_get_inst_dtls_rec.sequence_number,6,' '));

                l_record_failed := 'N';

                    OPEN c_get_hist_dt(l_get_inst_dtls_rec.person_id,
                                       l_get_inst_dtls_rec.admission_appl_number,
                                       l_get_inst_dtls_rec.nominated_course_cd,
                                       l_get_inst_dtls_rec.sequence_number);
                    FETCH c_get_hist_dt INTO l_get_hist_dt;
                    CLOSE c_get_hist_dt;

                    OPEN c_get_pending_hist(l_get_inst_dtls_rec.person_id,
                                            l_get_inst_dtls_rec.admission_appl_number,
                                            l_get_inst_dtls_rec.nominated_course_cd,
                                            l_get_inst_dtls_rec.sequence_number,
                                            l_get_hist_dt);
                    FETCH c_get_pending_hist INTO l_get_pending_hist_rec;

                    IF c_get_pending_hist%FOUND THEN

                      igs_ad_cancel_reconsider.g_cancel_recons_on := 'Y';

                      igs_ad_ps_appl_inst_pkg.update_row (
                                   X_ROWID                                => l_get_inst_dtls_rec.ROWID,
                                   x_PERSON_ID                            => l_get_inst_dtls_rec.PERSON_ID,
                                   x_ADMISSION_APPL_NUMBER                => l_get_inst_dtls_rec.ADMISSION_APPL_NUMBER,
                                   x_NOMINATED_COURSE_CD                  => l_get_inst_dtls_rec.NOMINATED_COURSE_CD,
                                   x_SEQUENCE_NUMBER                      => l_get_inst_dtls_rec.SEQUENCE_NUMBER,
                                   x_PREDICTED_GPA                        => l_get_inst_dtls_rec.PREDICTED_GPA,
                                   x_ACADEMIC_INDEX                       => l_get_inst_dtls_rec.ACADEMIC_INDEX,
                                   x_ADM_CAL_TYPE                         => l_get_inst_dtls_rec.ADM_CAL_TYPE,
                                   x_APP_FILE_LOCATION                    => l_get_inst_dtls_rec.APP_FILE_LOCATION,
                                   x_ADM_CI_SEQUENCE_NUMBER               => l_get_inst_dtls_rec.ADM_CI_SEQUENCE_NUMBER,
                                   x_COURSE_CD                            => l_get_inst_dtls_rec.COURSE_CD,
                                   x_APP_SOURCE_ID                        => l_get_inst_dtls_rec.APP_SOURCE_ID,
                                   x_CRV_VERSION_NUMBER                   => l_get_inst_dtls_rec.CRV_VERSION_NUMBER,
                                   x_WAITLIST_RANK                        => l_get_pending_hist_rec.WAITLIST_RANK,
                                   x_LOCATION_CD                          => l_get_inst_dtls_rec.LOCATION_CD,
                                   x_ATTENT_OTHER_INST_CD                 => l_get_inst_dtls_rec.ATTENT_OTHER_INST_CD,
                                   x_ATTENDANCE_MODE                      => l_get_inst_dtls_rec.ATTENDANCE_MODE,
                                   x_EDU_GOAL_PRIOR_ENROLL_ID             => l_get_inst_dtls_rec.EDU_GOAL_PRIOR_ENROLL_ID,
                                   x_ATTENDANCE_TYPE                      => l_get_inst_dtls_rec.ATTENDANCE_TYPE,
                                   x_DECISION_MAKE_ID                     => l_get_pending_hist_rec.DECISION_MAKE_ID,
                                   x_UNIT_SET_CD                          => l_get_inst_dtls_rec.UNIT_SET_CD,
                                   x_DECISION_DATE                        => l_get_pending_hist_rec.DECISION_DATE,
                                   x_ATTRIBUTE_CATEGORY                   => l_get_inst_dtls_rec.ATTRIBUTE_CATEGORY,
                                   x_ATTRIBUTE1                           => l_get_inst_dtls_rec.ATTRIBUTE1,
                                   x_ATTRIBUTE2                           => l_get_inst_dtls_rec.ATTRIBUTE2,
                                   x_ATTRIBUTE3                           => l_get_inst_dtls_rec.ATTRIBUTE3,
                                   x_ATTRIBUTE4                           => l_get_inst_dtls_rec.ATTRIBUTE4,
                                   x_ATTRIBUTE5                           => l_get_inst_dtls_rec.ATTRIBUTE5,
                                   x_ATTRIBUTE6                           => l_get_inst_dtls_rec.ATTRIBUTE6,
                                   x_ATTRIBUTE7                           => l_get_inst_dtls_rec.ATTRIBUTE7,
                                   x_ATTRIBUTE8                           => l_get_inst_dtls_rec.ATTRIBUTE8,
                                   x_ATTRIBUTE9                           => l_get_inst_dtls_rec.ATTRIBUTE9,
                                   x_ATTRIBUTE10                          => l_get_inst_dtls_rec.ATTRIBUTE10,
                                   x_ATTRIBUTE11                          => l_get_inst_dtls_rec.ATTRIBUTE11,
                                   x_ATTRIBUTE12                          => l_get_inst_dtls_rec.ATTRIBUTE12,
                                   x_ATTRIBUTE13                          => l_get_inst_dtls_rec.ATTRIBUTE13,
                                   x_ATTRIBUTE14                          => l_get_inst_dtls_rec.ATTRIBUTE14,
                                   x_ATTRIBUTE15                          => l_get_inst_dtls_rec.ATTRIBUTE15,
                                   x_ATTRIBUTE16                          => l_get_inst_dtls_rec.ATTRIBUTE16,
                                   x_ATTRIBUTE17                          => l_get_inst_dtls_rec.ATTRIBUTE17,
                                   x_ATTRIBUTE18                          => l_get_inst_dtls_rec.ATTRIBUTE18,
                                   x_ATTRIBUTE19                          => l_get_inst_dtls_rec.ATTRIBUTE19,
                                   x_ATTRIBUTE20                          => l_get_inst_dtls_rec.ATTRIBUTE20,
                                   x_DECISION_REASON_ID                   => l_get_pending_hist_rec.DECISION_REASON_ID,
                                   x_US_VERSION_NUMBER                    => l_get_inst_dtls_rec.US_VERSION_NUMBER,
                                   x_DECISION_NOTES                       => l_get_inst_dtls_rec.DECISION_NOTES,
                                   x_PENDING_REASON_ID                    => l_get_pending_hist_rec.PENDING_REASON_ID,
                                   x_PREFERENCE_NUMBER                    => l_get_inst_dtls_rec.PREFERENCE_NUMBER,
                                   x_ADM_DOC_STATUS                       => l_get_inst_dtls_rec.ADM_DOC_STATUS,
                                   x_ADM_ENTRY_QUAL_STATUS                => l_get_inst_dtls_rec.ADM_ENTRY_QUAL_STATUS,
                                   x_DEFICIENCY_IN_PREP                   => l_get_inst_dtls_rec.DEFICIENCY_IN_PREP,
                                   x_LATE_ADM_FEE_STATUS                  => l_get_inst_dtls_rec.LATE_ADM_FEE_STATUS,
                                   x_SPL_CONSIDER_COMMENTS                => l_get_inst_dtls_rec.SPL_CONSIDER_COMMENTS,
                                   x_APPLY_FOR_FINAID                     => l_get_inst_dtls_rec.APPLY_FOR_FINAID,
                                   x_FINAID_APPLY_DATE                    => l_get_inst_dtls_rec.FINAID_APPLY_DATE,
                                   x_ADM_OUTCOME_STATUS                   => l_get_pending_hist_rec.ADM_OUTCOME_STATUS,
                                   x_adm_otcm_stat_auth_per_id            => l_get_inst_dtls_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                   x_ADM_OUTCOME_STATUS_AUTH_DT           => l_get_inst_dtls_rec.ADM_OUTCOME_STATUS_AUTH_DT,
                                   x_ADM_OUTCOME_STATUS_REASON            => l_get_inst_dtls_rec.ADM_OUTCOME_STATUS_REASON,
                                   x_OFFER_DT                             => l_get_pending_hist_rec.OFFER_DT,
                                   x_OFFER_RESPONSE_DT                    => l_get_pending_hist_rec.OFFER_RESPONSE_DT,
                                   x_PRPSD_COMMENCEMENT_DT                => l_get_pending_hist_rec.PRPSD_COMMENCEMENT_DT,
                                   x_ADM_CNDTNL_OFFER_STATUS              => NVL(l_get_pending_hist_rec.ADM_CNDTNL_OFFER_STATUS,IGS_AD_GEN_009.ADMP_GET_SYS_ACOS('NOT-APPLIC')),
                                   x_CNDTNL_OFFER_SATISFIED_DT            => l_get_pending_hist_rec.CNDTNL_OFFER_SATISFIED_DT,
                                   x_cndnl_ofr_must_be_stsfd_ind          => l_get_pending_hist_rec.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                   x_ADM_OFFER_RESP_STATUS                => NVL(l_get_pending_hist_rec.ADM_OFFER_RESP_STATUS,IGS_AD_GEN_009.ADMP_GET_SYS_AORS('NOT-APPLIC')),
                                   x_ACTUAL_RESPONSE_DT                   => l_get_pending_hist_rec.ACTUAL_RESPONSE_DT,
                                   x_ADM_OFFER_DFRMNT_STATUS              => NVL(l_get_pending_hist_rec.ADM_OFFER_DFRMNT_STATUS,IGS_AD_GEN_009.ADMP_GET_SYS_AODS('NOT-APPLIC')),
                                   x_DEFERRED_ADM_CAL_TYPE                => l_get_pending_hist_rec.DEFERRED_ADM_CAL_TYPE,
                                   x_DEFERRED_ADM_CI_SEQUENCE_NUM         => l_get_pending_hist_rec.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                   x_DEFERRED_TRACKING_ID                 => l_get_inst_dtls_rec.DEFERRED_TRACKING_ID,
                                   x_ASS_RANK                             => l_get_inst_dtls_rec.ASS_RANK,
                                   x_SECONDARY_ASS_RANK                   => l_get_inst_dtls_rec.SECONDARY_ASS_RANK,
                                   x_intr_accept_advice_num               => l_get_inst_dtls_rec.intrntnl_acceptance_advice_num,
                                   x_ASS_TRACKING_ID                      => l_get_inst_dtls_rec.ASS_TRACKING_ID,
                                   x_FEE_CAT                              => l_get_inst_dtls_rec.FEE_CAT,
                                   x_HECS_PAYMENT_OPTION                  => l_get_inst_dtls_rec.HECS_PAYMENT_OPTION,
                                   x_EXPECTED_COMPLETION_YR               => l_get_inst_dtls_rec.EXPECTED_COMPLETION_YR,
                                   x_EXPECTED_COMPLETION_PERD             => l_get_inst_dtls_rec.EXPECTED_COMPLETION_PERD,
                                   x_CORRESPONDENCE_CAT                   => l_get_inst_dtls_rec.CORRESPONDENCE_CAT,
                                   x_ENROLMENT_CAT                        => l_get_inst_dtls_rec.ENROLMENT_CAT,
                                   x_FUNDING_SOURCE                       => l_get_inst_dtls_rec.FUNDING_SOURCE,
                                   x_APPLICANT_ACPTNCE_CNDTN              => l_get_pending_hist_rec.APPLICANT_ACPTNCE_CNDTN,
                                   x_CNDTNL_OFFER_CNDTN                   => l_get_pending_hist_rec.CNDTNL_OFFER_CNDTN,
                                   X_MODE                                 => 'S',
                                   X_SS_APPLICATION_ID                    => l_get_inst_dtls_rec.SS_APPLICATION_ID,
                                   X_SS_PWD                               => l_get_inst_dtls_rec.SS_PWD,
                                   X_AUTHORIZED_DT                        => l_get_inst_dtls_rec.AUTHORIZED_DT,
                                   X_AUTHORIZING_PERS_ID                  => l_get_inst_dtls_rec.AUTHORIZING_PERS_ID,
                                   x_entry_status                         => l_get_inst_dtls_rec.entry_status,
                                   x_entry_level                          => l_get_inst_dtls_rec.entry_level,
                                   x_sch_apl_to_id                        => l_get_inst_dtls_rec.sch_apl_to_id,
                                   x_idx_calc_date                        => l_get_inst_dtls_rec.idx_calc_date,
                                   x_waitlist_status                      => l_get_pending_hist_rec.waitlist_status,
                                   x_ATTRIBUTE21                          => l_get_inst_dtls_rec.ATTRIBUTE21,
                                   x_ATTRIBUTE22                          => l_get_inst_dtls_rec.ATTRIBUTE22,
                                   x_ATTRIBUTE23                          => l_get_inst_dtls_rec.ATTRIBUTE23,
                                   x_ATTRIBUTE24                          => l_get_inst_dtls_rec.ATTRIBUTE24,
                                   x_ATTRIBUTE25                          => l_get_inst_dtls_rec.ATTRIBUTE25,
                                   x_ATTRIBUTE26                          => l_get_inst_dtls_rec.ATTRIBUTE26,
                                   x_ATTRIBUTE27                          => l_get_inst_dtls_rec.ATTRIBUTE27,
                                   x_ATTRIBUTE28                          => l_get_inst_dtls_rec.ATTRIBUTE28,
                                   x_ATTRIBUTE29                          => l_get_inst_dtls_rec.ATTRIBUTE29,
                                   x_ATTRIBUTE30                          => l_get_inst_dtls_rec.ATTRIBUTE30,
                                   x_ATTRIBUTE31                          => l_get_inst_dtls_rec.ATTRIBUTE31,
                                   x_ATTRIBUTE32                          => l_get_inst_dtls_rec.ATTRIBUTE32,
                                   x_ATTRIBUTE33                          => l_get_inst_dtls_rec.ATTRIBUTE33,
                                   x_ATTRIBUTE34                          => l_get_inst_dtls_rec.ATTRIBUTE34,
                                   x_ATTRIBUTE35                          => l_get_inst_dtls_rec.ATTRIBUTE35,
                                   x_ATTRIBUTE36                          => l_get_inst_dtls_rec.ATTRIBUTE36,
                                   x_ATTRIBUTE37                          => l_get_inst_dtls_rec.ATTRIBUTE37,
                                   x_ATTRIBUTE38                          => l_get_inst_dtls_rec.ATTRIBUTE38,
                                   x_ATTRIBUTE39                          => l_get_inst_dtls_rec.ATTRIBUTE39,
                                   x_ATTRIBUTE40                          => l_get_inst_dtls_rec.ATTRIBUTE40,
                                   x_fut_acad_cal_type                    => l_get_pending_hist_rec.future_acad_cal_type,
                                   x_fut_acad_ci_sequence_number          => l_get_pending_hist_rec.future_acad_ci_sequence_num,
                                   x_fut_adm_cal_type                     => l_get_pending_hist_rec.future_adm_cal_type,
                                   x_fut_adm_ci_sequence_number           => l_get_pending_hist_rec.future_adm_ci_sequence_num,
                                   x_prev_term_adm_appl_number            => l_get_inst_dtls_rec.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                   x_prev_term_sequence_number            => l_get_inst_dtls_rec.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                   x_fut_term_adm_appl_number             => l_get_inst_dtls_rec.future_term_adm_appl_number,
                                   x_fut_term_sequence_number             => l_get_inst_dtls_rec.future_term_sequence_number,
                                   x_def_acad_cal_type                    => l_get_pending_hist_rec.def_acad_cal_type,
                                   x_def_acad_ci_sequence_num             => l_get_pending_hist_rec.def_acad_ci_sequence_num,
                                   x_def_prev_term_adm_appl_num           => l_get_inst_dtls_rec.def_prev_term_adm_appl_num,
                                   x_def_prev_appl_sequence_num           => l_get_inst_dtls_rec.def_prev_appl_sequence_num,
                                   x_def_term_adm_appl_num                => l_get_inst_dtls_rec.def_term_adm_appl_num,
                                   x_def_appl_sequence_num                => l_get_inst_dtls_rec.def_appl_sequence_num,
                                   x_appl_inst_status                     => l_get_inst_dtls_rec.appl_inst_status,
                                   x_ais_reason                           => l_get_inst_dtls_rec.ais_reason,
                                   x_decline_ofr_reason                   => l_get_pending_hist_rec.decline_ofr_reason);

                              igs_ad_cancel_reconsider.g_cancel_recons_on := 'N';

                              igs_ad_wf_001.wf_raise_event ( p_person_id             => l_get_inst_dtls_rec.Person_Id,
                                       p_raised_for            => 'AOD',
                                       p_admission_appl_number => l_get_inst_dtls_rec.Admission_Appl_Number,
                                       p_nominated_course_cd   => l_get_inst_dtls_rec.Nominated_Course_cd,
                                       p_sequence_number       => l_get_inst_dtls_rec.Sequence_Number,
                                       p_old_outcome_status    => l_get_inst_dtls_rec.adm_outcome_status,
                                       p_new_outcome_status    => l_get_pending_hist_rec.ADM_OUTCOME_STATUS
                                     );

                             OPEN c_adm_cat(l_get_inst_dtls_rec.person_id,l_get_inst_dtls_rec.admission_appl_number);
                             FETCH c_adm_cat INTO l_adm_cat;
                             CLOSE c_adm_cat;


                             OPEN c_apcs(l_adm_cat.admission_cat, l_adm_cat.s_admission_process_type);
                             FETCH c_apcs INTO l_apcs;
                             CLOSE c_apcs;

                             IF NVL(igs_ad_gen_008.admp_get_saors(l_get_pending_hist_rec.ADM_OFFER_RESP_STATUS),'NULL') = 'ACCEPTED' THEN
                                IF igs_ad_upd_initialise.perform_pre_enrol(l_get_inst_dtls_rec.Person_Id,
                                                       l_get_inst_dtls_rec.Admission_Appl_Number,
                                                       l_get_inst_dtls_rec.Nominated_Course_cd,
                                                       l_get_inst_dtls_rec.Sequence_Number,
                                                       'Y', -- Confirm course indicator.
                                                       'Y', -- Perform eligibility check indicator.
                                                       v_message_name) = FALSE THEN
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cancel Reconsideration Failed: ' || v_message_name);
                                  l_record_failed := 'Y';
                                  ROLLBACK TO c_create_prog;
                                END IF;
                              ELSIF (igs_ad_gen_008.admp_get_saos(l_get_pending_hist_rec.ADM_OUTCOME_STATUS)) IN ('COND-OFFER', 'OFFER')  AND l_apcs = 'Y' THEN
                                 IF igs_ad_upd_initialise.perform_pre_enrol(l_get_inst_dtls_rec.Person_Id,
                                                        l_get_inst_dtls_rec.Admission_Appl_Number,
                                                        l_get_inst_dtls_rec.Nominated_Course_cd,
                                                        l_get_inst_dtls_rec.Sequence_Number,
                                                        'N', -- Confirm course indicator.
                                                        'N', -- Perform eligibility check indicator.
                                                        v_message_name) = FALSE THEN
                                  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cancel Reconsideration Failed: ' || v_message_name);
                                  l_record_failed := 'Y';
                                  ROLLBACK TO c_create_prog;
                                 END IF;
                               END IF;

                    END IF;
                CLOSE c_get_pending_hist;

                END LOOP;

                IF l_record_failed = 'N' THEN

                  igs_ad_gen_002.ins_dummy_pend_hist_rec ( l_get_ad_ps_appl_rec.person_id,
                                                         l_get_ad_ps_appl_rec.admission_appl_number,
                                                         l_get_ad_ps_appl_rec.nominated_course_cd
                                                       );

                  FND_FILE.PUT_LINE(FND_FILE.LOG,' Cancelled Reconsideration Request.' );

                END IF;

              EXCEPTION
                WHEN OTHERS THEN

                  IF NVL(igs_ad_cancel_reconsider.g_cancel_recons_on,'N') = 'Y' THEN
                    igs_ad_cancel_reconsider.g_cancel_recons_on := 'N';
                  END IF;

                  IF c_get_pending_hist%ISOPEN THEN
                          CLOSE c_get_pending_hist;
                    END IF;

                  ROLLBACK TO c_create_prog;

                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                  l_record_errored := 'Y';

              END;

            END LOOP;
            CLOSE c_get_ad_ps_appl;
         END IF;

         IF p_pend_future = 'Y' THEN

           FOR l_get_fut_appl_inst IN c_get_fut_appl_inst (l_acad_cal_type,
                                                           l_acad_sequence_number,
                                                           l_adm_cal_type,
                                                           l_adm_sequence_number,
                                                           l_admission_cat,
                                                           l_s_adm_process_typ) LOOP

              SAVEPOINT c_update_inst;
              l_processing_ind := 'Y';

              DECLARE

                l_max_msg_count NUMBER;
                l_msg_data VARCHAR2(2000);
                l_msg_index_out NUMBER;
                l_app_name VARCHAR2(2000);
                v_message_name VARCHAR2(2000);

              BEGIN

              /* Begin Apadegal - 4747281 */
              OPEN c_get_application_id(l_get_fut_appl_inst.PERSON_ID,l_get_fut_appl_inst.ADMISSION_APPL_NUMBER);
              FETCH c_get_application_id INTO l_get_application_id;
              CLOSE c_get_application_id;

               FND_FILE.PUT_LINE(FND_FILE.LOG,' Person Number: ' || RPAD(get_person_number(l_get_fut_appl_inst.PERSON_ID),15,' ') || ' Application ID: ' ||
                                  RPAD(l_get_application_id,15,' ') || ' Program: ' || RPAD(l_get_fut_appl_inst.NOMINATED_COURSE_CD,6,' ')
                                  || 'Sequence Number: ' || RPAD(l_get_fut_appl_inst.SEQUENCE_NUMBER,6,' '));
                  l_get_application_id := NULL;
                /* End Apadegal - 4747281 */

                igs_ad_ps_appl_inst_pkg.update_row (
                                   X_ROWID                                => l_get_fut_appl_inst.ROWID,
                                   x_PERSON_ID                            => l_get_fut_appl_inst.PERSON_ID,
                                   x_ADMISSION_APPL_NUMBER                => l_get_fut_appl_inst.ADMISSION_APPL_NUMBER,
                                   x_NOMINATED_COURSE_CD                  => l_get_fut_appl_inst.NOMINATED_COURSE_CD,
                                   x_SEQUENCE_NUMBER                      => l_get_fut_appl_inst.SEQUENCE_NUMBER,
                                   x_PREDICTED_GPA                        => l_get_fut_appl_inst.PREDICTED_GPA,
                                   x_ACADEMIC_INDEX                       => l_get_fut_appl_inst.ACADEMIC_INDEX,
                                   x_ADM_CAL_TYPE                         => l_get_fut_appl_inst.ADM_CAL_TYPE,
                                   x_APP_FILE_LOCATION                    => l_get_fut_appl_inst.APP_FILE_LOCATION,
                                   x_ADM_CI_SEQUENCE_NUMBER               => l_get_fut_appl_inst.ADM_CI_SEQUENCE_NUMBER,
                                   x_COURSE_CD                            => l_get_fut_appl_inst.COURSE_CD,
                                   x_APP_SOURCE_ID                        => l_get_fut_appl_inst.APP_SOURCE_ID,
                                   x_CRV_VERSION_NUMBER                   => l_get_fut_appl_inst.CRV_VERSION_NUMBER,
                                   x_WAITLIST_RANK                        => l_get_fut_appl_inst.WAITLIST_RANK,
                                   x_LOCATION_CD                          => l_get_fut_appl_inst.LOCATION_CD,
                                   x_ATTENT_OTHER_INST_CD                 => l_get_fut_appl_inst.ATTENT_OTHER_INST_CD,
                                   x_ATTENDANCE_MODE                      => l_get_fut_appl_inst.ATTENDANCE_MODE,
                                   x_EDU_GOAL_PRIOR_ENROLL_ID             => l_get_fut_appl_inst.EDU_GOAL_PRIOR_ENROLL_ID,
                                   x_ATTENDANCE_TYPE                      => l_get_fut_appl_inst.ATTENDANCE_TYPE,
                                   x_DECISION_MAKE_ID                     => l_get_fut_appl_inst.DECISION_MAKE_ID,
                                   x_UNIT_SET_CD                          => l_get_fut_appl_inst.UNIT_SET_CD,
                                   x_DECISION_DATE                        => l_get_fut_appl_inst.DECISION_DATE,
                                   x_ATTRIBUTE_CATEGORY                   => l_get_fut_appl_inst.ATTRIBUTE_CATEGORY,
                                   x_ATTRIBUTE1                           => l_get_fut_appl_inst.ATTRIBUTE1,
                                   x_ATTRIBUTE2                           => l_get_fut_appl_inst.ATTRIBUTE2,
                                   x_ATTRIBUTE3                           => l_get_fut_appl_inst.ATTRIBUTE3,
                                   x_ATTRIBUTE4                           => l_get_fut_appl_inst.ATTRIBUTE4,
                                   x_ATTRIBUTE5                           => l_get_fut_appl_inst.ATTRIBUTE5,
                                   x_ATTRIBUTE6                           => l_get_fut_appl_inst.ATTRIBUTE6,
                                   x_ATTRIBUTE7                           => l_get_fut_appl_inst.ATTRIBUTE7,
                                   x_ATTRIBUTE8                           => l_get_fut_appl_inst.ATTRIBUTE8,
                                   x_ATTRIBUTE9                           => l_get_fut_appl_inst.ATTRIBUTE9,
                                   x_ATTRIBUTE10                          => l_get_fut_appl_inst.ATTRIBUTE10,
                                   x_ATTRIBUTE11                          => l_get_fut_appl_inst.ATTRIBUTE11,
                                   x_ATTRIBUTE12                          => l_get_fut_appl_inst.ATTRIBUTE12,
                                   x_ATTRIBUTE13                          => l_get_fut_appl_inst.ATTRIBUTE13,
                                   x_ATTRIBUTE14                          => l_get_fut_appl_inst.ATTRIBUTE14,
                                   x_ATTRIBUTE15                          => l_get_fut_appl_inst.ATTRIBUTE15,
                                   x_ATTRIBUTE16                          => l_get_fut_appl_inst.ATTRIBUTE16,
                                   x_ATTRIBUTE17                          => l_get_fut_appl_inst.ATTRIBUTE17,
                                   x_ATTRIBUTE18                          => l_get_fut_appl_inst.ATTRIBUTE18,
                                   x_ATTRIBUTE19                          => l_get_fut_appl_inst.ATTRIBUTE19,
                                   x_ATTRIBUTE20                          => l_get_fut_appl_inst.ATTRIBUTE20,
                                   x_DECISION_REASON_ID                   => l_get_fut_appl_inst.DECISION_REASON_ID,
                                   x_US_VERSION_NUMBER                    => l_get_fut_appl_inst.US_VERSION_NUMBER,
                                   x_DECISION_NOTES                       => l_get_fut_appl_inst.DECISION_NOTES,
                                   x_PENDING_REASON_ID                    => l_get_fut_appl_inst.PENDING_REASON_ID,
                                   x_PREFERENCE_NUMBER                    => l_get_fut_appl_inst.PREFERENCE_NUMBER,
                                   x_ADM_DOC_STATUS                       => l_get_fut_appl_inst.ADM_DOC_STATUS,
                                   x_ADM_ENTRY_QUAL_STATUS                => l_get_fut_appl_inst.ADM_ENTRY_QUAL_STATUS,
                                   x_DEFICIENCY_IN_PREP                   => l_get_fut_appl_inst.DEFICIENCY_IN_PREP,
                                   x_LATE_ADM_FEE_STATUS                  => l_get_fut_appl_inst.LATE_ADM_FEE_STATUS,
                                   x_SPL_CONSIDER_COMMENTS                => l_get_fut_appl_inst.SPL_CONSIDER_COMMENTS,
                                   x_APPLY_FOR_FINAID                     => l_get_fut_appl_inst.APPLY_FOR_FINAID,
                                   x_FINAID_APPLY_DATE                    => l_get_fut_appl_inst.FINAID_APPLY_DATE,
                                   x_ADM_OUTCOME_STATUS                   => l_get_fut_appl_inst.ADM_OUTCOME_STATUS,
                                   x_adm_otcm_stat_auth_per_id            => l_get_fut_appl_inst.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                   x_ADM_OUTCOME_STATUS_AUTH_DT           => l_get_fut_appl_inst.ADM_OUTCOME_STATUS_AUTH_DT,
                                   x_ADM_OUTCOME_STATUS_REASON            => l_get_fut_appl_inst.ADM_OUTCOME_STATUS_REASON,
                                   x_OFFER_DT                             => l_get_fut_appl_inst.OFFER_DT,
                                   x_OFFER_RESPONSE_DT                    => l_get_fut_appl_inst.OFFER_RESPONSE_DT,
                                   x_PRPSD_COMMENCEMENT_DT                => l_get_fut_appl_inst.PRPSD_COMMENCEMENT_DT,
                                   x_ADM_CNDTNL_OFFER_STATUS              => l_get_fut_appl_inst.ADM_CNDTNL_OFFER_STATUS,
                                   x_CNDTNL_OFFER_SATISFIED_DT            => l_get_fut_appl_inst.CNDTNL_OFFER_SATISFIED_DT,
                                   x_cndnl_ofr_must_be_stsfd_ind          => l_get_fut_appl_inst.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                   x_ADM_OFFER_RESP_STATUS                => l_get_fut_appl_inst.ADM_OFFER_RESP_STATUS,
                                   x_ACTUAL_RESPONSE_DT                   => l_get_fut_appl_inst.ACTUAL_RESPONSE_DT,
                                   x_ADM_OFFER_DFRMNT_STATUS              => l_get_fut_appl_inst.ADM_OFFER_DFRMNT_STATUS,
                                   x_DEFERRED_ADM_CAL_TYPE                => l_get_fut_appl_inst.DEFERRED_ADM_CAL_TYPE,
                                   x_DEFERRED_ADM_CI_SEQUENCE_NUM         => l_get_fut_appl_inst.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                   x_DEFERRED_TRACKING_ID                 => l_get_fut_appl_inst.DEFERRED_TRACKING_ID,
                                   x_ASS_RANK                             => l_get_fut_appl_inst.ASS_RANK,
                                   x_SECONDARY_ASS_RANK                   => l_get_fut_appl_inst.SECONDARY_ASS_RANK,
                                   x_intr_accept_advice_num               => l_get_fut_appl_inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                   x_ASS_TRACKING_ID                      => l_get_fut_appl_inst.ASS_TRACKING_ID,
                                   x_FEE_CAT                              => l_get_fut_appl_inst.FEE_CAT,
                                   x_HECS_PAYMENT_OPTION                  => l_get_fut_appl_inst.HECS_PAYMENT_OPTION,
                                   x_EXPECTED_COMPLETION_YR               => l_get_fut_appl_inst.EXPECTED_COMPLETION_YR,
                                   x_EXPECTED_COMPLETION_PERD             => l_get_fut_appl_inst.EXPECTED_COMPLETION_PERD,
                                   x_CORRESPONDENCE_CAT                   => l_get_fut_appl_inst.CORRESPONDENCE_CAT,
                                   x_ENROLMENT_CAT                        => l_get_fut_appl_inst.ENROLMENT_CAT,
                                   x_FUNDING_SOURCE                       => l_get_fut_appl_inst.FUNDING_SOURCE,
                                   x_APPLICANT_ACPTNCE_CNDTN              => l_get_fut_appl_inst.APPLICANT_ACPTNCE_CNDTN,
                                   x_CNDTNL_OFFER_CNDTN                   => l_get_fut_appl_inst.CNDTNL_OFFER_CNDTN,
                                   X_MODE                                 => 'S',
                                   X_SS_APPLICATION_ID                    => l_get_fut_appl_inst.SS_APPLICATION_ID,
                                   X_SS_PWD                               => l_get_fut_appl_inst.SS_PWD,
                                   X_AUTHORIZED_DT                        => l_get_fut_appl_inst.AUTHORIZED_DT,
                                   X_AUTHORIZING_PERS_ID                  => l_get_fut_appl_inst.AUTHORIZING_PERS_ID,
                                   x_entry_status                         => l_get_fut_appl_inst.entry_status,
                                   x_entry_level                          => l_get_fut_appl_inst.entry_level,
                                   x_sch_apl_to_id                        => l_get_fut_appl_inst.sch_apl_to_id,
                                   x_idx_calc_date                        => l_get_fut_appl_inst.idx_calc_date,
                                   x_waitlist_status                      => l_get_fut_appl_inst.waitlist_status,
                                   x_ATTRIBUTE21                          => l_get_fut_appl_inst.ATTRIBUTE21,
                                   x_ATTRIBUTE22                          => l_get_fut_appl_inst.ATTRIBUTE22,
                                   x_ATTRIBUTE23                          => l_get_fut_appl_inst.ATTRIBUTE23,
                                   x_ATTRIBUTE24                          => l_get_fut_appl_inst.ATTRIBUTE24,
                                   x_ATTRIBUTE25                          => l_get_fut_appl_inst.ATTRIBUTE25,
                                   x_ATTRIBUTE26                          => l_get_fut_appl_inst.ATTRIBUTE26,
                                   x_ATTRIBUTE27                          => l_get_fut_appl_inst.ATTRIBUTE27,
                                   x_ATTRIBUTE28                          => l_get_fut_appl_inst.ATTRIBUTE28,
                                   x_ATTRIBUTE29                          => l_get_fut_appl_inst.ATTRIBUTE29,
                                   x_ATTRIBUTE30                          => l_get_fut_appl_inst.ATTRIBUTE30,
                                   x_ATTRIBUTE31                          => l_get_fut_appl_inst.ATTRIBUTE31,
                                   x_ATTRIBUTE32                          => l_get_fut_appl_inst.ATTRIBUTE32,
                                   x_ATTRIBUTE33                          => l_get_fut_appl_inst.ATTRIBUTE33,
                                   x_ATTRIBUTE34                          => l_get_fut_appl_inst.ATTRIBUTE34,
                                   x_ATTRIBUTE35                          => l_get_fut_appl_inst.ATTRIBUTE35,
                                   x_ATTRIBUTE36                          => l_get_fut_appl_inst.ATTRIBUTE36,
                                   x_ATTRIBUTE37                          => l_get_fut_appl_inst.ATTRIBUTE37,
                                   x_ATTRIBUTE38                          => l_get_fut_appl_inst.ATTRIBUTE38,
                                   x_ATTRIBUTE39                          => l_get_fut_appl_inst.ATTRIBUTE39,
                                   x_ATTRIBUTE40                          => l_get_fut_appl_inst.ATTRIBUTE40,
                                   x_fut_acad_cal_type                    => NULL,
                                   x_fut_acad_ci_sequence_number          => NULL,
                                   x_fut_adm_cal_type                     => NULL,
                                   x_fut_adm_ci_sequence_number           => NULL,
                                   x_prev_term_adm_appl_number            => l_get_fut_appl_inst.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                   x_prev_term_sequence_number            => l_get_fut_appl_inst.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                   x_fut_term_adm_appl_number             => l_get_fut_appl_inst.FUTURE_TERM_ADM_APPL_NUMBER,
                                   x_fut_term_sequence_number             => l_get_fut_appl_inst.FUTURE_TERM_SEQUENCE_NUMBER,
                                   x_def_acad_cal_type                    => l_get_fut_appl_inst.def_acad_cal_type,
                                   x_def_acad_ci_sequence_num             => l_get_fut_appl_inst.def_acad_ci_sequence_num,
                                   x_def_prev_term_adm_appl_num           => l_get_fut_appl_inst.def_prev_term_adm_appl_num,
                                   x_def_prev_appl_sequence_num           => l_get_fut_appl_inst.def_prev_appl_sequence_num,
                                   x_def_term_adm_appl_num                => l_get_fut_appl_inst.def_term_adm_appl_num,
                                   x_def_appl_sequence_num                => l_get_fut_appl_inst.def_appl_sequence_num,
                                   x_appl_inst_status                     => l_get_fut_appl_inst.appl_inst_status,
                                   x_ais_reason                           => l_get_fut_appl_inst.ais_reason,
                                   x_decline_ofr_reason                   => l_get_fut_appl_inst.decline_ofr_reason);

                                   FND_FILE.PUT_LINE(FND_FILE.LOG,' Cancelled Reconsideration Request.' );

               EXCEPTION
                 WHEN OTHERS THEN

                 ROLLBACK TO c_update_inst;

                 FND_FILE.PUT_LINE(FND_FILE.LOG,'Cancel Reconsideration Failed: ' || FND_MESSAGE.GET);

                 l_record_errored := 'Y';

              END;

           END LOOP;

         END IF;

     ELSIF (P_person_id_group IS NOT NULL) THEN


        -- if l_acad_sequence_number is NULL (ie, calendar details are not entered) then
        -- it is assigned a value of -1, if we keep it NULL then the value cannot be used while
        -- opening the REF CURSOR c_dyn_pig_check.

        IF l_acad_sequence_number IS NULL THEN
          l_acad_sequence_number := -1 ;
        END IF;

       -- if l_adm_sequence_number is NULL (ie, calendar details are not entered) then
       -- it is assigned a value of -1, if we keep it NULL then the value cannot be used while
       -- opening the REF CURSOR c_dyn_pig_check.

       IF l_adm_sequence_number IS NULL THEN
          l_adm_sequence_number := -1;
       END IF;

       IF p_recon_future = 'Y' OR p_recon_no_future = 'Y' THEN

          IF p_recon_future IS NULL THEN
            l_recon_future := 'N';
          ELSE
            l_recon_future := p_recon_future;
          END IF;

          IF p_recon_no_future IS NULL THEN
            l_recon_no_future := 'N';
          ELSE
            l_recon_no_future := p_recon_no_future;
          END IF;

          l_sql_stmt1 := l_sql_stmt1 || '(' || lv_sql_stmt || ')' || l_sql_stmt2;
          -- opening the REF CURSOR c_dyn_pig_check that will pick up application instance details based on the
          -- value of the parameters entered.
          IF lv_group_type = 'STATIC' THEN

            OPEN c_dyn_pig_check  FOR l_sql_stmt1 USING p_person_id_group, l_acad_cal_type, l_acad_sequence_number,l_acad_sequence_number,
            l_adm_cal_type, l_adm_sequence_number,l_adm_sequence_number, l_admission_cat, l_s_adm_process_typ, l_recon_no_future, l_recon_future;

            FETCH c_dyn_pig_check BULK COLLECT INTO c_dyn_pig_check_table_rec;
            CLOSE c_dyn_pig_check;

          ELSIF lv_group_type = 'DYNAMIC' THEN

            OPEN c_dyn_pig_check  FOR l_sql_stmt1 USING l_acad_cal_type, l_acad_sequence_number,l_acad_sequence_number,
            l_adm_cal_type, l_adm_sequence_number,l_adm_sequence_number, l_admission_cat, l_s_adm_process_typ, l_recon_no_future, l_recon_future;

            FETCH c_dyn_pig_check BULK COLLECT INTO c_dyn_pig_check_table_rec;
            CLOSE c_dyn_pig_check;

          END IF;


          IF c_dyn_pig_check_table_rec.COUNT >0 THEN
            FOR l_dyn_pig_check_table_count IN c_dyn_pig_check_table_rec.FIRST..c_dyn_pig_check_table_rec.LAST LOOP

              c_dyn_pig_check_rec := c_dyn_pig_check_table_rec(l_dyn_pig_check_table_count);


              l_processing_ind := 'Y';

              OPEN c_get_application_id(c_dyn_pig_check_rec.person_id,c_dyn_pig_check_rec.admission_appl_number);
              FETCH c_get_application_id INTO l_get_application_id;
              CLOSE c_get_application_id;

              SAVEPOINT c_create_prog;

              DECLARE

                l_max_msg_count NUMBER;
                l_msg_data VARCHAR2(2000);
                l_msg_index_out NUMBER;
                l_app_name VARCHAR2(2000);
                v_message_name VARCHAR2(2000);

              BEGIN
                igs_ad_ps_appl_pkg.update_row (
                    x_rowid =>  c_dyn_pig_check_rec.row_id,
                    x_person_id =>  c_dyn_pig_check_rec.person_id,
                    x_admission_appl_number =>  c_dyn_pig_check_rec.admission_appl_number,
                    x_nominated_course_cd =>  c_dyn_pig_check_rec.nominated_course_cd,
                    x_transfer_course_cd =>  c_dyn_pig_check_rec.transfer_course_cd,
                    x_basis_for_admission_type =>  c_dyn_pig_check_rec.basis_for_admission_type,
                    x_admission_cd =>  c_dyn_pig_check_rec.admission_cd,
                    x_course_rank_set =>  c_dyn_pig_check_rec.course_rank_set,
                    x_course_rank_schedule =>  c_dyn_pig_check_rec.course_rank_schedule,
                    x_req_for_reconsideration_ind =>  'N',
                    x_req_for_adv_standing_ind =>  c_dyn_pig_check_rec.req_for_adv_standing_ind ,
                    x_mode =>  'R' ) ;

                   FOR l_get_inst_dtls_rec IN c_get_inst_dtls(c_dyn_pig_check_rec.person_id,
                                                              c_dyn_pig_check_rec.admission_appl_number,
                                                              c_dyn_pig_check_rec.nominated_course_cd) LOOP

                       FND_FILE.PUT_LINE(FND_FILE.LOG,' Person Number: ' ||  RPAD( get_person_number(l_get_ad_ps_appl_rec.person_id),15,' ') || ' Application ID: ' ||
                                         RPAD(l_get_application_id,15,' ') || ' Program: ' || RPAD(l_get_ad_ps_appl_rec.nominated_course_cd,6,' ')
                                         || 'Sequence Number: ' || RPAD(l_get_inst_dtls_rec.sequence_number,6,' '));

                       l_record_failed := 'N';

                       OPEN c_get_hist_dt(l_get_inst_dtls_rec.person_id,
                                          l_get_inst_dtls_rec.admission_appl_number,
                                          l_get_inst_dtls_rec.nominated_course_cd,
                                          l_get_inst_dtls_rec.sequence_number);
                       FETCH c_get_hist_dt INTO l_get_hist_dt;
                       CLOSE c_get_hist_dt;

                       OPEN c_get_pending_hist(l_get_inst_dtls_rec.person_id,
                                               l_get_inst_dtls_rec.admission_appl_number,
                                               l_get_inst_dtls_rec.nominated_course_cd,
                                               l_get_inst_dtls_rec.sequence_number,
                                               l_get_hist_dt);
                       FETCH c_get_pending_hist INTO l_get_pending_hist_rec;

                       IF c_get_pending_hist%FOUND THEN

                         igs_ad_cancel_reconsider.g_cancel_recons_on := 'Y';

                         igs_ad_ps_appl_inst_pkg.update_row (
                                      X_ROWID                                => l_get_inst_dtls_rec.ROWID,
                                      x_PERSON_ID                            => l_get_inst_dtls_rec.PERSON_ID,
                                      x_ADMISSION_APPL_NUMBER                => l_get_inst_dtls_rec.ADMISSION_APPL_NUMBER,
                                      x_NOMINATED_COURSE_CD                  => l_get_inst_dtls_rec.NOMINATED_COURSE_CD,
                                      x_SEQUENCE_NUMBER                      => l_get_inst_dtls_rec.SEQUENCE_NUMBER,
                                      x_PREDICTED_GPA                        => l_get_inst_dtls_rec.PREDICTED_GPA,
                                      x_ACADEMIC_INDEX                       => l_get_inst_dtls_rec.ACADEMIC_INDEX,
                                      x_ADM_CAL_TYPE                         => l_get_inst_dtls_rec.ADM_CAL_TYPE,
                                      x_APP_FILE_LOCATION                    => l_get_inst_dtls_rec.APP_FILE_LOCATION,
                                      x_ADM_CI_SEQUENCE_NUMBER               => l_get_inst_dtls_rec.ADM_CI_SEQUENCE_NUMBER,
                                      x_COURSE_CD                            => l_get_inst_dtls_rec.COURSE_CD,
                                      x_APP_SOURCE_ID                        => l_get_inst_dtls_rec.APP_SOURCE_ID,
                                      x_CRV_VERSION_NUMBER                   => l_get_inst_dtls_rec.CRV_VERSION_NUMBER,
                                      x_WAITLIST_RANK                        => l_get_pending_hist_rec.WAITLIST_RANK,
                                      x_LOCATION_CD                          => l_get_inst_dtls_rec.LOCATION_CD,
                                      x_ATTENT_OTHER_INST_CD                 => l_get_inst_dtls_rec.ATTENT_OTHER_INST_CD,
                                      x_ATTENDANCE_MODE                      => l_get_inst_dtls_rec.ATTENDANCE_MODE,
                                      x_EDU_GOAL_PRIOR_ENROLL_ID             => l_get_inst_dtls_rec.EDU_GOAL_PRIOR_ENROLL_ID,
                                      x_ATTENDANCE_TYPE                      => l_get_inst_dtls_rec.ATTENDANCE_TYPE,
                                      x_DECISION_MAKE_ID                     => l_get_pending_hist_rec.DECISION_MAKE_ID,
                                      x_UNIT_SET_CD                          => l_get_inst_dtls_rec.UNIT_SET_CD,
                                      x_DECISION_DATE                        => l_get_pending_hist_rec.DECISION_DATE,
                                      x_ATTRIBUTE_CATEGORY                   => l_get_inst_dtls_rec.ATTRIBUTE_CATEGORY,
                                      x_ATTRIBUTE1                           => l_get_inst_dtls_rec.ATTRIBUTE1,
                                      x_ATTRIBUTE2                           => l_get_inst_dtls_rec.ATTRIBUTE2,
                                      x_ATTRIBUTE3                           => l_get_inst_dtls_rec.ATTRIBUTE3,
                                      x_ATTRIBUTE4                           => l_get_inst_dtls_rec.ATTRIBUTE4,
                                      x_ATTRIBUTE5                           => l_get_inst_dtls_rec.ATTRIBUTE5,
                                      x_ATTRIBUTE6                           => l_get_inst_dtls_rec.ATTRIBUTE6,
                                      x_ATTRIBUTE7                           => l_get_inst_dtls_rec.ATTRIBUTE7,
                                      x_ATTRIBUTE8                           => l_get_inst_dtls_rec.ATTRIBUTE8,
                                      x_ATTRIBUTE9                           => l_get_inst_dtls_rec.ATTRIBUTE9,
                                      x_ATTRIBUTE10                          => l_get_inst_dtls_rec.ATTRIBUTE10,
                                      x_ATTRIBUTE11                          => l_get_inst_dtls_rec.ATTRIBUTE11,
                                      x_ATTRIBUTE12                          => l_get_inst_dtls_rec.ATTRIBUTE12,
                                      x_ATTRIBUTE13                          => l_get_inst_dtls_rec.ATTRIBUTE13,
                                      x_ATTRIBUTE14                          => l_get_inst_dtls_rec.ATTRIBUTE14,
                                      x_ATTRIBUTE15                          => l_get_inst_dtls_rec.ATTRIBUTE15,
                                      x_ATTRIBUTE16                          => l_get_inst_dtls_rec.ATTRIBUTE16,
                                      x_ATTRIBUTE17                          => l_get_inst_dtls_rec.ATTRIBUTE17,
                                      x_ATTRIBUTE18                          => l_get_inst_dtls_rec.ATTRIBUTE18,
                                      x_ATTRIBUTE19                          => l_get_inst_dtls_rec.ATTRIBUTE19,
                                      x_ATTRIBUTE20                          => l_get_inst_dtls_rec.ATTRIBUTE20,
                                      x_DECISION_REASON_ID                   => l_get_pending_hist_rec.DECISION_REASON_ID,
                                      x_US_VERSION_NUMBER                    => l_get_inst_dtls_rec.US_VERSION_NUMBER,
                                      x_DECISION_NOTES                       => l_get_inst_dtls_rec.DECISION_NOTES,
                                      x_PENDING_REASON_ID                    => l_get_pending_hist_rec.PENDING_REASON_ID,
                                      x_PREFERENCE_NUMBER                    => l_get_inst_dtls_rec.PREFERENCE_NUMBER,
                                      x_ADM_DOC_STATUS                       => l_get_inst_dtls_rec.ADM_DOC_STATUS,
                                      x_ADM_ENTRY_QUAL_STATUS                => l_get_inst_dtls_rec.ADM_ENTRY_QUAL_STATUS,
                                      x_DEFICIENCY_IN_PREP                   => l_get_inst_dtls_rec.DEFICIENCY_IN_PREP,
                                      x_LATE_ADM_FEE_STATUS                  => l_get_inst_dtls_rec.LATE_ADM_FEE_STATUS,
                                      x_SPL_CONSIDER_COMMENTS                => l_get_inst_dtls_rec.SPL_CONSIDER_COMMENTS,
                                      x_APPLY_FOR_FINAID                     => l_get_inst_dtls_rec.APPLY_FOR_FINAID,
                                      x_FINAID_APPLY_DATE                    => l_get_inst_dtls_rec.FINAID_APPLY_DATE,
                                      x_ADM_OUTCOME_STATUS                   => l_get_pending_hist_rec.ADM_OUTCOME_STATUS,
                                      x_adm_otcm_stat_auth_per_id            => l_get_inst_dtls_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                      x_ADM_OUTCOME_STATUS_AUTH_DT           => l_get_inst_dtls_rec.ADM_OUTCOME_STATUS_AUTH_DT,
                                      x_ADM_OUTCOME_STATUS_REASON            => l_get_inst_dtls_rec.ADM_OUTCOME_STATUS_REASON,
                                      x_OFFER_DT                             => l_get_pending_hist_rec.OFFER_DT,
                                      x_OFFER_RESPONSE_DT                    => l_get_pending_hist_rec.OFFER_RESPONSE_DT,
                                      x_PRPSD_COMMENCEMENT_DT                => l_get_pending_hist_rec.PRPSD_COMMENCEMENT_DT,
                                      x_ADM_CNDTNL_OFFER_STATUS              => NVL(l_get_pending_hist_rec.ADM_CNDTNL_OFFER_STATUS,IGS_AD_GEN_009.ADMP_GET_SYS_ACOS('NOT-APPLIC')),
                                      x_CNDTNL_OFFER_SATISFIED_DT            => l_get_pending_hist_rec.CNDTNL_OFFER_SATISFIED_DT,
                                      x_cndnl_ofr_must_be_stsfd_ind          => l_get_pending_hist_rec.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                      x_ADM_OFFER_RESP_STATUS                => NVL(l_get_pending_hist_rec.ADM_OFFER_RESP_STATUS,IGS_AD_GEN_009.ADMP_GET_SYS_AORS('NOT-APPLIC')),
                                      x_ACTUAL_RESPONSE_DT                   => l_get_pending_hist_rec.ACTUAL_RESPONSE_DT,
                                      x_ADM_OFFER_DFRMNT_STATUS              => NVL(l_get_pending_hist_rec.ADM_OFFER_DFRMNT_STATUS,IGS_AD_GEN_009.ADMP_GET_SYS_AODS('NOT-APPLIC')),
                                      x_DEFERRED_ADM_CAL_TYPE                => l_get_pending_hist_rec.DEFERRED_ADM_CAL_TYPE,
                                      x_DEFERRED_ADM_CI_SEQUENCE_NUM         => l_get_pending_hist_rec.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                      x_DEFERRED_TRACKING_ID                 => l_get_inst_dtls_rec.DEFERRED_TRACKING_ID,
                                      x_ASS_RANK                             => l_get_inst_dtls_rec.ASS_RANK,
                                      x_SECONDARY_ASS_RANK                   => l_get_inst_dtls_rec.SECONDARY_ASS_RANK,
                                      x_intr_accept_advice_num               => l_get_inst_dtls_rec.intrntnl_acceptance_advice_num,
                                      x_ASS_TRACKING_ID                      => l_get_inst_dtls_rec.ASS_TRACKING_ID,
                                      x_FEE_CAT                              => l_get_inst_dtls_rec.FEE_CAT,
                                      x_HECS_PAYMENT_OPTION                  => l_get_inst_dtls_rec.HECS_PAYMENT_OPTION,
                                      x_EXPECTED_COMPLETION_YR               => l_get_inst_dtls_rec.EXPECTED_COMPLETION_YR,
                                      x_EXPECTED_COMPLETION_PERD             => l_get_inst_dtls_rec.EXPECTED_COMPLETION_PERD,
                                      x_CORRESPONDENCE_CAT                   => l_get_inst_dtls_rec.CORRESPONDENCE_CAT,
                                      x_ENROLMENT_CAT                        => l_get_inst_dtls_rec.ENROLMENT_CAT,
                                      x_FUNDING_SOURCE                       => l_get_inst_dtls_rec.FUNDING_SOURCE,
                                      x_APPLICANT_ACPTNCE_CNDTN              => l_get_pending_hist_rec.APPLICANT_ACPTNCE_CNDTN,
                                      x_CNDTNL_OFFER_CNDTN                   => l_get_pending_hist_rec.CNDTNL_OFFER_CNDTN,
                                      X_MODE                                 => 'S',
                                      X_SS_APPLICATION_ID                    => l_get_inst_dtls_rec.SS_APPLICATION_ID,
                                      X_SS_PWD                               => l_get_inst_dtls_rec.SS_PWD,
                                      X_AUTHORIZED_DT                        => l_get_inst_dtls_rec.AUTHORIZED_DT,
                                      X_AUTHORIZING_PERS_ID                  => l_get_inst_dtls_rec.AUTHORIZING_PERS_ID,
                                      x_entry_status                         => l_get_inst_dtls_rec.entry_status,
                                      x_entry_level                          => l_get_inst_dtls_rec.entry_level,
                                      x_sch_apl_to_id                        => l_get_inst_dtls_rec.sch_apl_to_id,
                                      x_idx_calc_date                        => l_get_inst_dtls_rec.idx_calc_date,
                                      x_waitlist_status                      => l_get_pending_hist_rec.waitlist_status,
                                      x_ATTRIBUTE21                          => l_get_inst_dtls_rec.ATTRIBUTE21,
                                      x_ATTRIBUTE22                          => l_get_inst_dtls_rec.ATTRIBUTE22,
                                      x_ATTRIBUTE23                          => l_get_inst_dtls_rec.ATTRIBUTE23,
                                      x_ATTRIBUTE24                          => l_get_inst_dtls_rec.ATTRIBUTE24,
                                      x_ATTRIBUTE25                          => l_get_inst_dtls_rec.ATTRIBUTE25,
                                      x_ATTRIBUTE26                          => l_get_inst_dtls_rec.ATTRIBUTE26,
                                      x_ATTRIBUTE27                          => l_get_inst_dtls_rec.ATTRIBUTE27,
                                      x_ATTRIBUTE28                          => l_get_inst_dtls_rec.ATTRIBUTE28,
                                      x_ATTRIBUTE29                          => l_get_inst_dtls_rec.ATTRIBUTE29,
                                      x_ATTRIBUTE30                          => l_get_inst_dtls_rec.ATTRIBUTE30,
                                      x_ATTRIBUTE31                          => l_get_inst_dtls_rec.ATTRIBUTE31,
                                      x_ATTRIBUTE32                          => l_get_inst_dtls_rec.ATTRIBUTE32,
                                      x_ATTRIBUTE33                          => l_get_inst_dtls_rec.ATTRIBUTE33,
                                      x_ATTRIBUTE34                          => l_get_inst_dtls_rec.ATTRIBUTE34,
                                      x_ATTRIBUTE35                          => l_get_inst_dtls_rec.ATTRIBUTE35,
                                      x_ATTRIBUTE36                          => l_get_inst_dtls_rec.ATTRIBUTE36,
                                      x_ATTRIBUTE37                          => l_get_inst_dtls_rec.ATTRIBUTE37,
                                      x_ATTRIBUTE38                          => l_get_inst_dtls_rec.ATTRIBUTE38,
                                      x_ATTRIBUTE39                          => l_get_inst_dtls_rec.ATTRIBUTE39,
                                      x_ATTRIBUTE40                          => l_get_inst_dtls_rec.ATTRIBUTE40,
                                      x_fut_acad_cal_type                    => l_get_pending_hist_rec.future_acad_cal_type,
                                      x_fut_acad_ci_sequence_number          => l_get_pending_hist_rec.future_acad_ci_sequence_num,
                                      x_fut_adm_cal_type                     => l_get_pending_hist_rec.future_adm_cal_type,
                                      x_fut_adm_ci_sequence_number           => l_get_pending_hist_rec.future_adm_ci_sequence_num,
                                      x_prev_term_adm_appl_number            => l_get_inst_dtls_rec.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                      x_prev_term_sequence_number            => l_get_inst_dtls_rec.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                      x_fut_term_adm_appl_number             => l_get_inst_dtls_rec.future_term_adm_appl_number,
                                      x_fut_term_sequence_number             => l_get_inst_dtls_rec.future_term_sequence_number,
                                      x_def_acad_cal_type                    => l_get_pending_hist_rec.def_acad_cal_type,
                                      x_def_acad_ci_sequence_num             => l_get_pending_hist_rec.def_acad_ci_sequence_num,
                                      x_def_prev_term_adm_appl_num           => l_get_inst_dtls_rec.def_prev_term_adm_appl_num,
                                      x_def_prev_appl_sequence_num           => l_get_inst_dtls_rec.def_prev_appl_sequence_num,
                                      x_def_term_adm_appl_num                => l_get_inst_dtls_rec.def_term_adm_appl_num,
                                      x_def_appl_sequence_num                => l_get_inst_dtls_rec.def_appl_sequence_num,
                                      x_appl_inst_status                     => l_get_inst_dtls_rec.appl_inst_status,
                                      x_ais_reason                           => l_get_inst_dtls_rec.ais_reason,
                                      x_decline_ofr_reason                   => l_get_pending_hist_rec.decline_ofr_reason);

                                igs_ad_cancel_reconsider.g_cancel_recons_on := 'N';

                                igs_ad_wf_001.wf_raise_event ( p_person_id             => l_get_inst_dtls_rec.Person_Id,
                                          p_raised_for            => 'AOD',
                                          p_admission_appl_number => l_get_inst_dtls_rec.Admission_Appl_Number,
                                          p_nominated_course_cd   => l_get_inst_dtls_rec.Nominated_Course_cd,
                                          p_sequence_number       => l_get_inst_dtls_rec.Sequence_Number,
                                          p_old_outcome_status    => l_get_inst_dtls_rec.adm_outcome_status,
                                          p_new_outcome_status    => l_get_pending_hist_rec.adm_outcome_status
                                        );

                                OPEN c_adm_cat(l_get_inst_dtls_rec.person_id,l_get_inst_dtls_rec.admission_appl_number);
                                FETCH c_adm_cat INTO l_adm_cat;
                                CLOSE c_adm_cat;


                                OPEN c_apcs(l_adm_cat.admission_cat, l_adm_cat.s_admission_process_type);
                                FETCH c_apcs INTO l_apcs;
                                CLOSE c_apcs;

                                IF NVL(igs_ad_gen_008.admp_get_saors(l_get_pending_hist_rec.ADM_OFFER_RESP_STATUS),'NULL') = 'ACCEPTED' THEN
                                   IF igs_ad_upd_initialise.perform_pre_enrol(l_get_inst_dtls_rec.Person_Id,
                                                          l_get_inst_dtls_rec.Admission_Appl_Number,
                                                          l_get_inst_dtls_rec.Nominated_Course_cd,
                                                          l_get_inst_dtls_rec.Sequence_Number,
                                                          'Y', -- Confirm course indicator.
                                                          'Y', -- Perform eligibility check indicator.
                                                          v_message_name) = FALSE THEN
                                     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cancel Reconsideration Failed: ' || v_message_name);
                                     l_record_failed := 'Y';
                                     ROLLBACK TO c_create_prog;
                                   END IF;
                                 END IF;


                                IF (igs_ad_gen_008.admp_get_saos(l_get_pending_hist_rec.ADM_OUTCOME_STATUS)) IN ('COND-OFFER', 'OFFER') AND l_apcs = 'Y' THEN
                                    IF igs_ad_upd_initialise.perform_pre_enrol(l_get_inst_dtls_rec.Person_Id,
                                                           l_get_inst_dtls_rec.Admission_Appl_Number,
                                                           l_get_inst_dtls_rec.Nominated_Course_cd,
                                                           l_get_inst_dtls_rec.Sequence_Number,
                                                           'N', -- Confirm course indicator.
                                                           'N', -- Perform eligibility check indicator.
                                                           v_message_name) = FALSE THEN
                                     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cancel Reconsideration Failed: ' || v_message_name);
                                     l_record_failed := 'Y';
                                     ROLLBACK TO c_create_prog;
                                    END IF;
                                  END IF;

                       END IF;
                       CLOSE c_get_pending_hist;

                   END LOOP;
                   IF l_record_failed = 'N' THEN
                     igs_ad_gen_002.ins_dummy_pend_hist_rec ( c_dyn_pig_check_rec.person_id,
                                                            c_dyn_pig_check_rec.admission_appl_number,
                                                            c_dyn_pig_check_rec.nominated_course_cd
                                                          );
                     FND_FILE.PUT_LINE(FND_FILE.LOG,' Cancelled Reconsideration Request.' );
                   END IF;

              EXCEPTION
                WHEN OTHERS THEN

                          IF NVL(igs_ad_cancel_reconsider.g_cancel_recons_on,'N') = 'Y' THEN
                     igs_ad_cancel_reconsider.g_cancel_recons_on := 'N';
                   END IF;

                  IF c_get_pending_hist%ISOPEN THEN
                      CLOSE c_get_pending_hist;
                    END IF;
                  ROLLBACK TO c_create_prog;

                  FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                  l_record_errored := 'Y';

              END;
            END LOOP;

           END IF;

         END IF;

         IF p_pend_future = 'Y' THEN

             l_sql_stmt4 :=  'AND
                    Aa.acad_cal_type = NVL ( :1 , aa.acad_cal_type) AND
                    Aa.acad_ci_sequence_number = DECODE ( :2, -1,aa.acad_ci_sequence_number, :2 )  AND
                    Aa.adm_cal_type = NVL (:3 , aa.adm_cal_type) AND
                    Aa.adm_ci_sequence_number = DECODE  ( :4, -1,aa.adm_ci_sequence_number, :4 )  AND
                    Aa.admission_cat = NVL ( :5 , aa.admission_cat) AND
                    Aa.s_admission_process_type = NVL ( :6 , aa.s_admission_process_type) AND
                    Apai.adm_outcome_status = aos.adm_outcome_status AND
                    Aos.s_adm_outcome_status = ''PENDING''  AND
                    NVL(apai.appl_inst_status,''RECEIVED'') NOT IN (SELECT adm_appl_status FROM igs_ad_appl_stat WHERE S_ADM_APPL_STATUS = ''WITHDRAWN'') AND
                    Psapl.req_for_reconsideration_ind <> ''Y'' AND
                    Apai.person_id = psapl.person_id AND
                    Apai.admission_appl_number = psapl.admission_appl_number AND
                    Apai.nominated_course_cd = psapl.nominated_course_cd AND
                    apai.person_id = aa.person_id AND
                    apai.admission_appl_number = aa.admission_appl_number AND
                    Apai.future_acad_cal_type  IS NOT NULL AND
                    Apai.future_acad_ci_sequence_number IS NOT NULL AND
                    Apai.future_adm_cal_type IS NOT NULL AND
                    Apai.future_adm_ci_sequence_number IS NOT NULL';

             l_sql_stmt3 := l_sql_stmt3 || '(' || lv_sql_stmt || ')' || l_sql_stmt4;

               IF lv_group_type = 'STATIC' THEN

		 OPEN c_pend_fut  FOR l_sql_stmt3 USING p_person_id_group, l_acad_cal_type, l_acad_sequence_number,l_acad_sequence_number, l_adm_cal_type, l_adm_sequence_number,l_adm_sequence_number, l_admission_cat, l_s_adm_process_typ;


                 FETCH c_pend_fut BULK COLLECT INTO c_pend_fut_table_rec;
                 CLOSE c_pend_fut;

               ELSIF lv_group_type = 'DYNAMIC' THEN

                 OPEN c_pend_fut  FOR l_sql_stmt3 USING l_acad_cal_type, l_acad_sequence_number,l_acad_sequence_number, l_adm_cal_type, l_adm_sequence_number,l_adm_sequence_number, l_admission_cat, l_s_adm_process_typ;


                 FETCH c_pend_fut BULK COLLECT INTO c_pend_fut_table_rec;
                 CLOSE c_pend_fut;

               END IF;

              IF c_pend_fut_table_rec.COUNT>0 THEN
                FOR l_pend_fut_table_count IN c_pend_fut_table_rec.FIRST..c_pend_fut_table_rec.LAST LOOP

                  c_pend_fut_rec := c_pend_fut_table_rec(l_pend_fut_table_count);

                  l_processing_ind := 'Y';

		  SAVEPOINT c_update_inst;

                  DECLARE

                    l_max_msg_count NUMBER;
                    l_msg_data VARCHAR2(2000);
                    l_msg_index_out NUMBER;
                    l_app_name VARCHAR2(2000);
                    v_message_name VARCHAR2(2000);


                  BEGIN
                  /* Begin Apadegal - 4747281 */
                  OPEN c_get_application_id(c_pend_fut_rec.PERSON_ID,c_pend_fut_rec.ADMISSION_APPL_NUMBER);
                  FETCH c_get_application_id INTO l_get_application_id;
                  CLOSE c_get_application_id;

                   FND_FILE.PUT_LINE(FND_FILE.LOG,' Person Number: ' || RPAD(get_person_number(c_pend_fut_rec.PERSON_ID),15,' ') || ' Application ID: ' ||
                                      RPAD(l_get_application_id,15,' ') || ' Program: ' || RPAD(c_pend_fut_rec.NOMINATED_COURSE_CD,6,' ')
                                      || 'Sequence Number: ' || RPAD(c_pend_fut_rec.SEQUENCE_NUMBER,6,' '));
                      l_get_application_id := NULL;
                        /* End Apadegal - 4747281 */
                    igs_ad_ps_appl_inst_pkg.update_row (
                                       X_ROWID                                => c_pend_fut_rec.ROWID,
                                       x_PERSON_ID                            => c_pend_fut_rec.PERSON_ID,
                                       x_ADMISSION_APPL_NUMBER                => c_pend_fut_rec.ADMISSION_APPL_NUMBER,
                                       x_NOMINATED_COURSE_CD                  => c_pend_fut_rec.NOMINATED_COURSE_CD,
                                       x_SEQUENCE_NUMBER                      => c_pend_fut_rec.SEQUENCE_NUMBER,
                                       x_PREDICTED_GPA                        => c_pend_fut_rec.PREDICTED_GPA,
                                       x_ACADEMIC_INDEX                       => c_pend_fut_rec.ACADEMIC_INDEX,
                                       x_ADM_CAL_TYPE                         => c_pend_fut_rec.ADM_CAL_TYPE,
                                       x_APP_FILE_LOCATION                    => c_pend_fut_rec.APP_FILE_LOCATION,
                                       x_ADM_CI_SEQUENCE_NUMBER               => c_pend_fut_rec.ADM_CI_SEQUENCE_NUMBER,
                                       x_COURSE_CD                            => c_pend_fut_rec.COURSE_CD,
                                       x_APP_SOURCE_ID                        => c_pend_fut_rec.APP_SOURCE_ID,
                                       x_CRV_VERSION_NUMBER                   => c_pend_fut_rec.CRV_VERSION_NUMBER,
                                       x_WAITLIST_RANK                        => c_pend_fut_rec.WAITLIST_RANK,
                                       x_LOCATION_CD                          => c_pend_fut_rec.LOCATION_CD,
                                       x_ATTENT_OTHER_INST_CD                 => c_pend_fut_rec.ATTENT_OTHER_INST_CD,
                                       x_ATTENDANCE_MODE                      => c_pend_fut_rec.ATTENDANCE_MODE,
                                       x_EDU_GOAL_PRIOR_ENROLL_ID             => c_pend_fut_rec.EDU_GOAL_PRIOR_ENROLL_ID,
                                       x_ATTENDANCE_TYPE                      => c_pend_fut_rec.ATTENDANCE_TYPE,
                                       x_DECISION_MAKE_ID                     => c_pend_fut_rec.DECISION_MAKE_ID,
                                       x_UNIT_SET_CD                          => c_pend_fut_rec.UNIT_SET_CD,
                                       x_DECISION_DATE                        => c_pend_fut_rec.DECISION_DATE,
                                       x_ATTRIBUTE_CATEGORY                   => c_pend_fut_rec.ATTRIBUTE_CATEGORY,
                                       x_ATTRIBUTE1                           => c_pend_fut_rec.ATTRIBUTE1,
                                       x_ATTRIBUTE2                           => c_pend_fut_rec.ATTRIBUTE2,
                                       x_ATTRIBUTE3                           => c_pend_fut_rec.ATTRIBUTE3,
                                       x_ATTRIBUTE4                           => c_pend_fut_rec.ATTRIBUTE4,
                                       x_ATTRIBUTE5                           => c_pend_fut_rec.ATTRIBUTE5,
                                       x_ATTRIBUTE6                           => c_pend_fut_rec.ATTRIBUTE6,
                                       x_ATTRIBUTE7                           => c_pend_fut_rec.ATTRIBUTE7,
                                       x_ATTRIBUTE8                           => c_pend_fut_rec.ATTRIBUTE8,
                                       x_ATTRIBUTE9                           => c_pend_fut_rec.ATTRIBUTE9,
                                       x_ATTRIBUTE10                          => c_pend_fut_rec.ATTRIBUTE10,
                                       x_ATTRIBUTE11                          => c_pend_fut_rec.ATTRIBUTE11,
                                       x_ATTRIBUTE12                          => c_pend_fut_rec.ATTRIBUTE12,
                                       x_ATTRIBUTE13                          => c_pend_fut_rec.ATTRIBUTE13,
                                       x_ATTRIBUTE14                          => c_pend_fut_rec.ATTRIBUTE14,
                                       x_ATTRIBUTE15                          => c_pend_fut_rec.ATTRIBUTE15,
                                       x_ATTRIBUTE16                          => c_pend_fut_rec.ATTRIBUTE16,
                                       x_ATTRIBUTE17                          => c_pend_fut_rec.ATTRIBUTE17,
                                       x_ATTRIBUTE18                          => c_pend_fut_rec.ATTRIBUTE18,
                                       x_ATTRIBUTE19                          => c_pend_fut_rec.ATTRIBUTE19,
                                       x_ATTRIBUTE20                          => c_pend_fut_rec.ATTRIBUTE20,
                                       x_DECISION_REASON_ID                   => c_pend_fut_rec.DECISION_REASON_ID,
                                       x_US_VERSION_NUMBER                    => c_pend_fut_rec.US_VERSION_NUMBER,
                                       x_DECISION_NOTES                       => c_pend_fut_rec.DECISION_NOTES,
                                       x_PENDING_REASON_ID                    => c_pend_fut_rec.PENDING_REASON_ID,
                                       x_PREFERENCE_NUMBER                    => c_pend_fut_rec.PREFERENCE_NUMBER,
                                       x_ADM_DOC_STATUS                       => c_pend_fut_rec.ADM_DOC_STATUS,
                                       x_ADM_ENTRY_QUAL_STATUS                => c_pend_fut_rec.ADM_ENTRY_QUAL_STATUS,
                                       x_DEFICIENCY_IN_PREP                   => c_pend_fut_rec.DEFICIENCY_IN_PREP,
                                       x_LATE_ADM_FEE_STATUS                  => c_pend_fut_rec.LATE_ADM_FEE_STATUS,
                                       x_SPL_CONSIDER_COMMENTS                => c_pend_fut_rec.SPL_CONSIDER_COMMENTS,
                                       x_APPLY_FOR_FINAID                     => c_pend_fut_rec.APPLY_FOR_FINAID,
                                       x_FINAID_APPLY_DATE                    => c_pend_fut_rec.FINAID_APPLY_DATE,
                                       x_ADM_OUTCOME_STATUS                   => c_pend_fut_rec.ADM_OUTCOME_STATUS,
                                       x_adm_otcm_stat_auth_per_id            => c_pend_fut_rec.ADM_OTCM_STATUS_AUTH_PERSON_ID,
                                       x_ADM_OUTCOME_STATUS_AUTH_DT           => c_pend_fut_rec.ADM_OUTCOME_STATUS_AUTH_DT,
                                       x_ADM_OUTCOME_STATUS_REASON            => c_pend_fut_rec.ADM_OUTCOME_STATUS_REASON,
                                       x_OFFER_DT                             => c_pend_fut_rec.OFFER_DT,
                                       x_OFFER_RESPONSE_DT                    => c_pend_fut_rec.OFFER_RESPONSE_DT,
                                       x_PRPSD_COMMENCEMENT_DT                => c_pend_fut_rec.PRPSD_COMMENCEMENT_DT,
                                       x_ADM_CNDTNL_OFFER_STATUS              => c_pend_fut_rec.ADM_CNDTNL_OFFER_STATUS,
                                       x_CNDTNL_OFFER_SATISFIED_DT            => c_pend_fut_rec.CNDTNL_OFFER_SATISFIED_DT,
                                       x_cndnl_ofr_must_be_stsfd_ind          => c_pend_fut_rec.CNDTNL_OFFER_MUST_BE_STSFD_IND,
                                       x_ADM_OFFER_RESP_STATUS                => c_pend_fut_rec.ADM_OFFER_RESP_STATUS,
                                       x_ACTUAL_RESPONSE_DT                   => c_pend_fut_rec.ACTUAL_RESPONSE_DT,
                                       x_ADM_OFFER_DFRMNT_STATUS              => c_pend_fut_rec.ADM_OFFER_DFRMNT_STATUS,
                                       x_DEFERRED_ADM_CAL_TYPE                => c_pend_fut_rec.DEFERRED_ADM_CAL_TYPE,
                                       x_DEFERRED_ADM_CI_SEQUENCE_NUM         => c_pend_fut_rec.DEFERRED_ADM_CI_SEQUENCE_NUM,
                                       x_DEFERRED_TRACKING_ID                 => c_pend_fut_rec.DEFERRED_TRACKING_ID,
                                       x_ASS_RANK                             => c_pend_fut_rec.ASS_RANK,
                                       x_SECONDARY_ASS_RANK                   => c_pend_fut_rec.SECONDARY_ASS_RANK,
                                       x_intr_accept_advice_num               => c_pend_fut_rec.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
                                       x_ASS_TRACKING_ID                      => c_pend_fut_rec.ASS_TRACKING_ID,
                                       x_FEE_CAT                              => c_pend_fut_rec.FEE_CAT,
                                       x_HECS_PAYMENT_OPTION                  => c_pend_fut_rec.HECS_PAYMENT_OPTION,
                                       x_EXPECTED_COMPLETION_YR               => c_pend_fut_rec.EXPECTED_COMPLETION_YR,
                                       x_EXPECTED_COMPLETION_PERD             => c_pend_fut_rec.EXPECTED_COMPLETION_PERD,
                                       x_CORRESPONDENCE_CAT                   => c_pend_fut_rec.CORRESPONDENCE_CAT,
                                       x_ENROLMENT_CAT                        => c_pend_fut_rec.ENROLMENT_CAT,
                                       x_FUNDING_SOURCE                       => c_pend_fut_rec.FUNDING_SOURCE,
                                       x_APPLICANT_ACPTNCE_CNDTN              => c_pend_fut_rec.APPLICANT_ACPTNCE_CNDTN,
                                       x_CNDTNL_OFFER_CNDTN                   => c_pend_fut_rec.CNDTNL_OFFER_CNDTN,
                                       X_MODE                                 => 'S',
                                       X_SS_APPLICATION_ID                    => c_pend_fut_rec.SS_APPLICATION_ID,
                                       X_SS_PWD                               => c_pend_fut_rec.SS_PWD,
                                       X_AUTHORIZED_DT                        => c_pend_fut_rec.AUTHORIZED_DT,
                                       X_AUTHORIZING_PERS_ID                  => c_pend_fut_rec.AUTHORIZING_PERS_ID,
                                       x_entry_status                         => c_pend_fut_rec.entry_status,
                                       x_entry_level                          => c_pend_fut_rec.entry_level,
                                       x_sch_apl_to_id                        => c_pend_fut_rec.sch_apl_to_id,
                                       x_idx_calc_date                        => c_pend_fut_rec.idx_calc_date,
                                       x_waitlist_status                      => c_pend_fut_rec.waitlist_status,
                                       x_ATTRIBUTE21                          => c_pend_fut_rec.ATTRIBUTE21,
                                       x_ATTRIBUTE22                          => c_pend_fut_rec.ATTRIBUTE22,
                                       x_ATTRIBUTE23                          => c_pend_fut_rec.ATTRIBUTE23,
                                       x_ATTRIBUTE24                          => c_pend_fut_rec.ATTRIBUTE24,
                                       x_ATTRIBUTE25                          => c_pend_fut_rec.ATTRIBUTE25,
                                       x_ATTRIBUTE26                          => c_pend_fut_rec.ATTRIBUTE26,
                                       x_ATTRIBUTE27                          => c_pend_fut_rec.ATTRIBUTE27,
                                       x_ATTRIBUTE28                          => c_pend_fut_rec.ATTRIBUTE28,
                                       x_ATTRIBUTE29                          => c_pend_fut_rec.ATTRIBUTE29,
                                       x_ATTRIBUTE30                          => c_pend_fut_rec.ATTRIBUTE30,
                                       x_ATTRIBUTE31                          => c_pend_fut_rec.ATTRIBUTE31,
                                       x_ATTRIBUTE32                          => c_pend_fut_rec.ATTRIBUTE32,
                                       x_ATTRIBUTE33                          => c_pend_fut_rec.ATTRIBUTE33,
                                       x_ATTRIBUTE34                          => c_pend_fut_rec.ATTRIBUTE34,
                                       x_ATTRIBUTE35                          => c_pend_fut_rec.ATTRIBUTE35,
                                       x_ATTRIBUTE36                          => c_pend_fut_rec.ATTRIBUTE36,
                                       x_ATTRIBUTE37                          => c_pend_fut_rec.ATTRIBUTE37,
                                       x_ATTRIBUTE38                          => c_pend_fut_rec.ATTRIBUTE38,
                                       x_ATTRIBUTE39                          => c_pend_fut_rec.ATTRIBUTE39,
                                       x_ATTRIBUTE40                          => c_pend_fut_rec.ATTRIBUTE40,
                                       x_fut_acad_cal_type                    => NULL,
                                       x_fut_acad_ci_sequence_number          => NULL,
                                       x_fut_adm_cal_type                     => NULL,
                                       x_fut_adm_ci_sequence_number           => NULL,
                                       x_prev_term_adm_appl_number            => c_pend_fut_rec.PREVIOUS_TERM_ADM_APPL_NUMBER,
                                       x_prev_term_sequence_number            => c_pend_fut_rec.PREVIOUS_TERM_SEQUENCE_NUMBER,
                                       x_fut_term_adm_appl_number             => c_pend_fut_rec.FUTURE_TERM_ADM_APPL_NUMBER,
                                       x_fut_term_sequence_number             => c_pend_fut_rec.FUTURE_TERM_SEQUENCE_NUMBER,
                                       x_def_acad_cal_type                    => c_pend_fut_rec.def_acad_cal_type,
                                       x_def_acad_ci_sequence_num             => c_pend_fut_rec.def_acad_ci_sequence_num,
                                       x_def_prev_term_adm_appl_num           => c_pend_fut_rec.def_prev_term_adm_appl_num,
                                       x_def_prev_appl_sequence_num           => c_pend_fut_rec.def_prev_appl_sequence_num,
                                       x_def_term_adm_appl_num                => c_pend_fut_rec.def_term_adm_appl_num,
                                       x_def_appl_sequence_num                => c_pend_fut_rec.def_appl_sequence_num,
                                       x_appl_inst_status                     => c_pend_fut_rec.appl_inst_status,
                                       x_ais_reason                           => c_pend_fut_rec.ais_reason,
                                       x_decline_ofr_reason                   => c_pend_fut_rec.decline_ofr_reason);
                                         FND_FILE.PUT_LINE(FND_FILE.LOG,' Cancelled Reconsideration Request.' ); -- 4747281
                  EXCEPTION

                    WHEN OTHERS THEN

                    ROLLBACK TO c_update_inst;

                    FND_FILE.PUT_LINE(FND_FILE.LOG,'Cancel Reconsideration Failed: ' || FND_MESSAGE.GET);

                    l_record_errored := 'Y';

                  END;

                END LOOP;
              END IF;
         END IF;


        END IF;
       -- if none of the application programs are processed then give the appropiate log message
       IF l_processing_ind = 'N' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,' No Application Instance Matching The Given Criteria Is Found.' );
       -- if the cancel reconsideration job fails for any of the application programs then give the appropiate log message.
       ELSIF l_record_errored = 'Y' THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG,' For Some Application Instance Cancel Reconsideration Job Failed.' );
       END IF;

EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
    retcode:=2;
    errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    igs_ge_msg_stack.conc_exception_hndl;
END cancel_reconsider_appl;

END igs_ad_cancel_reconsider;

/
