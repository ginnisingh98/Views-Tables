--------------------------------------------------------
--  DDL for Package Body IGS_AD_AC_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_AC_COMP" AS
/* $Header: IGSADA8B.pls 120.3 2006/08/07 14:23:33 apadegal ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGS_AD_AC_COMP                          |
 |                                                                       |
 | NOTES                                                                 |
 |     To Update Admission Completion Status as Satisfied                |
 |                                                                       |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | brajendr        9-Aug-2001      Incorporaetd the review comments      |
 | brajendr        3-Aug-2001      Creation of the Initial Code          |
 | cdcruz          18-feb-2002     bug 2217104 Admit to future term Enhancement,updated tbh call for
 |                                 new columns being added to IGS_AD_PS_APPL_INST
 | hreddych        4-apr-2002      bug 2273789 The function get_cmp_apltritm was returning TRUE
 |                                 if one of the tracking status was complete which was modified to
 |                                 to return TRUE if all are complete
 | nshee     29-Aug-2002  Bug 2395510 added 6 columns as part of deferments build
 |hreddych         8-jan-2002      #2740404 Added the logmessages for giving details
 |                                 of the application Instance.
 |hreddych         25-jun-2003     # 2989257 Altered the cursors cur_tr,cur_tr_itm
 |                                 of the Function get_cmp_apltritm
 |  rghosh      21-Oct-2003        Added the REF CURSOR c_dyn_pig_check and hence the
 |                                                   logic for supporting dynamic Person ID Group
 |                                                   (Enh# 3194295 , ADCR043: Person ID Group)
 |rbezawad     1-Nov-04            Modified get_cpti_apcmp procedure to display the security error
 |                                   message in the log file w.r.t. Bug 3919112.
 |apadegal     7-Aug-06            5450345 - Removed the commit statement, as it un-necessarily commits the transaction.
*=======================================================================*/

  -- Declare all Global variables and global constants


  FUNCTION get_cmp_apltritm(
                            p_person_id                IN   igs_ad_ps_appl_inst.person_id%TYPE,
                            p_admission_appl_number    IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                            p_course_cd                IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                            p_sequence_number          IN   igs_ad_ps_appl_inst.sequence_number%TYPE
                           ) RETURN BOOLEAN AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose :    This Procedure will return TRUE if all the Tracking Items in the given Application Instance are Complete.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  -- Get all the tracking step details from for each application of the PERSON.
  CURSOR cur_tr(
                p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE,
                p_admission_appl_number     IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                p_course_cd                 IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                p_sequence_number           IN   igs_ad_ps_appl_inst.sequence_number%TYPE
               ) IS
    SELECT ti.tracking_id
      FROM igs_ad_aplins_admreq aa,
           igs_tr_item ti,
            igs_tr_type tt
      WHERE aa.person_id             = p_person_id
        AND aa.admission_appl_number = p_admission_appl_number
        AND aa.sequence_number       = p_sequence_number
        AND aa.course_cd             = p_course_cd
        AND aa.tracking_id           = ti.tracking_id
        AND ti.tracking_type         = tt.tracking_type
        AND tt.s_tracking_type       = 'ADM_PROCESSING';

  -- Get the list of tracking steps for which the tracking status is 'COMPLETE'
  CURSOR cur_tr_itm(
                    p_tracking_id  igs_ad_aplins_admreq.tracking_id%TYPE
                   ) IS
    SELECT 'x'
      FROM igs_tr_item iti,
           igs_tr_status its,
           igs_tr_type itt
      WHERE iti.tracking_id          = p_tracking_id
        AND itt.tracking_type        = iti.tracking_type
        AND itt.s_tracking_type      = 'ADM_PROCESSING'
        AND its.tracking_status      = iti.tracking_status
        AND its.s_tracking_status    = 'COMPLETE';

    l_tr_itms_not_found      BOOLEAN := TRUE;
    cur_tr_itm_rec cur_tr_itm%ROWTYPE;

  BEGIN
    -- Get all the tracking step details from for each application of the PERSON.
    FOR cur_tr_rec IN cur_tr( p_person_id, p_admission_appl_number, p_course_cd, p_sequence_number) LOOP
      OPEN cur_tr_itm( cur_tr_rec.tracking_id);
      FETCH cur_tr_itm INTO cur_tr_itm_rec;
      IF cur_tr_itm%NOTFOUND THEN
          CLOSE cur_tr_itm;
	  RETURN FALSE;
      END IF;
      CLOSE cur_tr_itm;
    END LOOP;
    RETURN TRUE;

  END get_cmp_apltritm;


  PROCEDURE get_cpti_apcmp(
                           p_person_id                IN   igs_ad_ps_appl_inst.person_id%TYPE,
                           p_admission_appl_number    IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                           p_course_cd                IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                           p_sequence_number          IN   igs_ad_ps_appl_inst.sequence_number%TYPE
                          ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose :    This procedure will update given Application Instance to the COMPLETE all the Tracking Items under this are COMPLTE
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
    ||  (reverse chronological order - newest change first)
    */

    -- Get the details of
    CURSOR cur_adm_doc_status IS
      SELECT adm_doc_status
        FROM igs_ad_doc_stat
        WHERE s_adm_doc_status = 'SATISFIED'
          AND closed_ind = 'N'
          AND system_default_ind= 'Y';

    -- Get the details of
    CURSOR cur_apcmp(
                     p_person_id                IN   igs_ad_ps_appl_inst.person_id%TYPE,
                     p_admission_appl_number    IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                     p_course_cd                IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                     p_sequence_number          IN   igs_ad_ps_appl_inst.sequence_number%TYPE
                    ) IS
      SELECT *
        FROM igs_ad_ps_appl_inst  ain
        WHERE ain.person_id               = p_person_id
          AND ain.admission_appl_number   = p_admission_appl_number
          AND ain.course_cd               = p_course_cd
          AND ain.sequence_number         = p_sequence_number;

    --Local variables to check if the Security Policy exception already set or not.  Ref: Bug 3919112
    l_sc_encoded_text   VARCHAR2(4000);
    l_sc_msg_count NUMBER;
    l_sc_msg_index NUMBER;
    l_sc_app_short_name VARCHAR2(50);
    l_sc_message_name   VARCHAR2(50);

  BEGIN

    -- Create a SavePoint in order to process each Application.
    SAVEPOINT IGSADA8_SP1;

    IF get_cmp_apltritm(
                        p_person_id,
                        p_admission_appl_number,
                        p_course_cd,
                        p_sequence_number
                       ) = FALSE
    THEN

      -- p_message_name = 'Application completion status cannot be updated to satisfied since the tracking item/s are not yet complete'
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Person Id    :'||p_person_id||'   Admission Application Number  :'||p_admission_appl_number);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Course Code  :' ||p_course_cd ||'   Sequence Number    :'||p_sequence_number);
      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_ITM_NT_CMPLT');
      FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

      RETURN;

    ELSE
      -- Since all the tracking items for the application instance have been completed and
      -- hence the application completion status can be updated  to 'SATISFIED'
      FOR cur_adm_doc_status_rec IN cur_adm_doc_status LOOP

        -- Update the tracking item status.
        FOR cur_apcmp_rec IN cur_apcmp( p_person_id, p_admission_appl_number, p_course_cd, p_sequence_number) LOOP
          igs_ad_ps_appl_inst_pkg.update_row(
                                         --  cur_adm_doc_status_rec.adm_doc_status
                                             x_rowid                        => cur_apcmp_rec.row_id,
                                             x_person_id                    => cur_apcmp_rec.person_id,
                                             x_admission_appl_number        => cur_apcmp_rec.admission_appl_number,
                                             x_nominated_course_cd          => cur_apcmp_rec.nominated_course_cd,
                                             x_sequence_number              => cur_apcmp_rec.sequence_number,
                                             x_predicted_gpa                => cur_apcmp_rec.predicted_gpa,
                                             x_academic_index               => cur_apcmp_rec.academic_index,
                                             x_adm_cal_type                 => cur_apcmp_rec.adm_cal_type,
                                             x_app_file_location            => cur_apcmp_rec.app_file_location,
                                             x_adm_ci_sequence_number       => cur_apcmp_rec.adm_ci_sequence_number,
                                             x_course_cd                    => cur_apcmp_rec.course_cd,
                                             x_app_source_id                => cur_apcmp_rec.app_source_id,
                                             x_crv_version_number           => cur_apcmp_rec.crv_version_number,
                                             x_waitlist_rank                => cur_apcmp_rec.waitlist_rank,
                                             x_waitlist_status              => cur_apcmp_rec.waitlist_status,
                                             x_location_cd                  => cur_apcmp_rec.location_cd,
                                             x_attent_other_inst_cd         => cur_apcmp_rec.attent_other_inst_cd,
                                             x_attendance_mode              => cur_apcmp_rec.attendance_mode,
                                             x_edu_goal_prior_enroll_id     => cur_apcmp_rec.edu_goal_prior_enroll_id,
                                             x_attendance_type              => cur_apcmp_rec.attendance_type,
                                             x_decision_make_id             => cur_apcmp_rec.decision_make_id,
                                             x_unit_set_cd                  => cur_apcmp_rec.unit_set_cd,
                                             x_decision_date                => cur_apcmp_rec.decision_date,
                                             x_attribute_category           => cur_apcmp_rec.attribute_category,
                                             x_attribute1                   => cur_apcmp_rec.attribute1,
                                             x_attribute2                   => cur_apcmp_rec.attribute2,
                                             x_attribute3                   => cur_apcmp_rec.attribute3,
                                             x_attribute4                   => cur_apcmp_rec.attribute4,
                                             x_attribute5                   => cur_apcmp_rec.attribute5,
                                             x_attribute6                   => cur_apcmp_rec.attribute6,
                                             x_attribute7                   => cur_apcmp_rec.attribute7,
                                             x_attribute8                   => cur_apcmp_rec.attribute8,
                                             x_attribute9                   => cur_apcmp_rec.attribute9,
                                             x_attribute10                  => cur_apcmp_rec.attribute10,
                                             x_attribute11                  => cur_apcmp_rec.attribute11,
                                             x_attribute12                  => cur_apcmp_rec.attribute12,
                                             x_attribute13                  => cur_apcmp_rec.attribute13,
                                             x_attribute14                  => cur_apcmp_rec.attribute14,
                                             x_attribute15                  => cur_apcmp_rec.attribute15,
                                             x_attribute16                  => cur_apcmp_rec.attribute16,
                                             x_attribute17                  => cur_apcmp_rec.attribute17,
                                             x_attribute18                  => cur_apcmp_rec.attribute18,
                                             x_attribute19                  => cur_apcmp_rec.attribute19,
                                             x_attribute20                  => cur_apcmp_rec.attribute20,
                                             x_decision_reason_id           => cur_apcmp_rec.decision_reason_id,
                                             x_us_version_number            => cur_apcmp_rec.us_version_number,
                                             x_decision_notes               => cur_apcmp_rec.decision_notes,
                                             x_pending_reason_id            => cur_apcmp_rec.pending_reason_id,
                                             x_preference_number            => cur_apcmp_rec.preference_number,
                                             x_adm_doc_status               => cur_adm_doc_status_rec.adm_doc_status,
                                             x_adm_entry_qual_status        => cur_apcmp_rec.adm_entry_qual_status,
                                             x_deficiency_in_prep           => cur_apcmp_rec.deficiency_in_prep,
                                             x_late_adm_fee_status          => cur_apcmp_rec.late_adm_fee_status,
                                             x_spl_consider_comments        => cur_apcmp_rec.spl_consider_comments,
                                             x_apply_for_finaid             => cur_apcmp_rec.apply_for_finaid,
                                             x_finaid_apply_date            => cur_apcmp_rec.finaid_apply_date,
                                             x_adm_outcome_status           => cur_apcmp_rec.adm_outcome_status,
                                             x_adm_otcm_stat_auth_per_id    => cur_apcmp_rec.adm_otcm_status_auth_person_id,
                                             x_adm_outcome_status_auth_dt   => cur_apcmp_rec.adm_outcome_status_auth_dt,
                                             x_adm_outcome_status_reason    => cur_apcmp_rec.adm_outcome_status_reason,
                                             x_offer_dt                     => cur_apcmp_rec.offer_dt,
                                             x_offer_response_dt            => cur_apcmp_rec.offer_response_dt,
                                             x_prpsd_commencement_dt        => cur_apcmp_rec.prpsd_commencement_dt,
                                             x_adm_cndtnl_offer_status      => cur_apcmp_rec.adm_cndtnl_offer_status,
                                             x_cndtnl_offer_satisfied_dt    => cur_apcmp_rec.cndtnl_offer_satisfied_dt,
                                             x_cndnl_ofr_must_be_stsfd_ind  => cur_apcmp_rec.cndtnl_offer_must_be_stsfd_ind,
                                             x_adm_offer_resp_status        => cur_apcmp_rec.adm_offer_resp_status,
                                             x_actual_response_dt           => cur_apcmp_rec.actual_response_dt,
                                             x_adm_offer_dfrmnt_status      => cur_apcmp_rec.adm_offer_dfrmnt_status,
                                             x_deferred_adm_cal_type        => cur_apcmp_rec.deferred_adm_cal_type,
                                             x_deferred_adm_ci_sequence_num => cur_apcmp_rec.deferred_adm_ci_sequence_num,
                                             x_deferred_tracking_id         => cur_apcmp_rec.deferred_tracking_id,
                                             x_ass_rank                     => cur_apcmp_rec.ass_rank,
                                             x_secondary_ass_rank           => cur_apcmp_rec.secondary_ass_rank,
                                             x_intr_accept_advice_num       => cur_apcmp_rec.intrntnl_acceptance_advice_num,
                                             x_ass_tracking_id              => cur_apcmp_rec.ass_tracking_id,
                                             x_fee_cat                      => cur_apcmp_rec.fee_cat,
                                             x_hecs_payment_option          => cur_apcmp_rec.hecs_payment_option,
                                             x_expected_completion_yr       => cur_apcmp_rec.expected_completion_yr,
                                             x_expected_completion_perd     => cur_apcmp_rec.expected_completion_perd,
                                             x_correspondence_cat           => cur_apcmp_rec.correspondence_cat,
                                             x_enrolment_cat                => cur_apcmp_rec.enrolment_cat,
                                             x_funding_source               => cur_apcmp_rec.funding_source,
                                             x_applicant_acptnce_cndtn      => cur_apcmp_rec.applicant_acptnce_cndtn,
                                             x_cndtnl_offer_cndtn           => cur_apcmp_rec.cndtnl_offer_cndtn,
                                             x_ss_application_id            => cur_apcmp_rec.ss_application_id,
                                             x_ss_pwd                       => cur_apcmp_rec.ss_pwd,
                                             x_authorized_dt                => cur_apcmp_rec.authorized_dt,
                                             x_authorizing_pers_id          => cur_apcmp_rec.authorizing_pers_id,
                                             x_entry_status                 => cur_apcmp_rec.entry_status,
                                             x_entry_level                  => cur_apcmp_rec.entry_level,
                                             x_sch_apl_to_id                => cur_apcmp_rec.sch_apl_to_id               ,
                                             x_idx_calc_date                => cur_apcmp_rec.idx_calc_date               ,
                                             X_FUT_ACAD_CAL_TYPE                          => cur_apcmp_rec.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                                             X_FUT_ACAD_CI_SEQUENCE_NUMBER                => cur_apcmp_rec.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                                             X_FUT_ADM_CAL_TYPE                           => cur_apcmp_rec.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                                             X_FUT_ADM_CI_SEQUENCE_NUMBER                 => cur_apcmp_rec.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_PREV_TERM_ADM_APPL_NUMBER                 => cur_apcmp_rec.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                                             X_PREV_TERM_SEQUENCE_NUMBER                 => cur_apcmp_rec.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                                             X_FUT_TERM_ADM_APPL_NUMBER                   => cur_apcmp_rec.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                                             X_FUT_TERM_SEQUENCE_NUMBER                   => cur_apcmp_rec.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
				             X_DEF_ACAD_CAL_TYPE                                        => cur_apcmp_rec.DEF_ACAD_CAL_TYPE, --Bug 2395510
					     X_DEF_ACAD_CI_SEQUENCE_NUM                   => cur_apcmp_rec.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
					     X_DEF_PREV_TERM_ADM_APPL_NUM           => cur_apcmp_rec.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
					     X_DEF_PREV_APPL_SEQUENCE_NUM              => cur_apcmp_rec.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
			                     X_DEF_TERM_ADM_APPL_NUM                        => cur_apcmp_rec.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
			                     X_DEF_APPL_SEQUENCE_NUM                           => cur_apcmp_rec.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
					     x_attribute21=> cur_apcmp_rec.attribute21,
					x_attribute22=> cur_apcmp_rec.attribute22,
					x_attribute23=> cur_apcmp_rec.attribute23,
					x_attribute24=> cur_apcmp_rec.attribute24,
					x_attribute25=> cur_apcmp_rec.attribute25,
					x_attribute26=> cur_apcmp_rec.attribute26,
					x_attribute27=> cur_apcmp_rec.attribute27,
					x_attribute28=> cur_apcmp_rec.attribute28,
					x_attribute29=> cur_apcmp_rec.attribute29,
					x_attribute30=> cur_apcmp_rec.attribute30,
					x_attribute31=> cur_apcmp_rec.attribute31,
					x_attribute32=> cur_apcmp_rec.attribute32,
					x_attribute33=> cur_apcmp_rec.attribute33,
					x_attribute34=> cur_apcmp_rec.attribute34,
					x_attribute35=> cur_apcmp_rec.attribute35,
					x_attribute36=> cur_apcmp_rec.attribute36,
					x_attribute37=> cur_apcmp_rec.attribute37,
					x_attribute38=> cur_apcmp_rec.attribute38,
					x_attribute39=> cur_apcmp_rec.attribute39,
					x_attribute40=> cur_apcmp_rec.attribute40,
					x_appl_inst_status=> cur_apcmp_rec.appl_inst_status,
					x_ais_reason=> cur_apcmp_rec.ais_reason,
					x_decline_ofr_reason=> cur_apcmp_rec.decline_ofr_reason
					);
        END LOOP;
      END LOOP;

      -- p_message_name =  'Application completion status for the application updated to SATISFIED';
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Person Id    :'||p_person_id||'   Admission Application Number  :'||p_admission_appl_number);
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Course Code  :' ||p_course_cd ||'   Sequence Number    :'||p_sequence_number);
      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_CMPLT_STAT_UPD');
      FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    END IF;

  EXCEPTION

    WHEN others THEN
        ROLLBACK TO IGSADA8_SP1;
        --Loop through the messages in stack to check if there is Security Policy exception already set or not.    Ref: Bug 3919112
        l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
        WHILE l_sc_msg_count <> 0 LOOP
          igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
          fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
          IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
            --print the the security exception in log file and return.
            fnd_file.put_line( fnd_file.log, 'Error occured while processing the Application instance with Person Id: '||p_person_id||', Admission Application Number: '||p_admission_appl_number||
	                                     ', Course Code: ' ||p_course_cd ||' and Sequence Number: '||p_sequence_number);
            fnd_message.set_encoded(l_sc_encoded_text);
            fnd_file.put_line( fnd_file.log, fnd_message.get());
            fnd_file.put_line( fnd_file.log, ' ');
            RETURN;
          END IF;
          l_sc_msg_count := l_sc_msg_count - 1;
        END LOOP;
  END get_cpti_apcmp;


  PROCEDURE upd_apl_cmp_st(
                           ERRBUF                         OUT NOCOPY VARCHAR2,
                           RETCODE                        OUT NOCOPY NUMBER,
                           p_person_id                    IN   igs_ad_ps_appl_inst.person_id%TYPE,
                           p_person_id_group              IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
                           p_admission_appl_number        IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                           p_course_cd                    IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                           p_sequence_number              IN   igs_ad_ps_appl_inst.sequence_number%TYPE,
                           p_calendar_details             IN   VARCHAR2,
                           p_admission_process_category   IN   VARCHAR2,
                           p_org_id                       IN   igs_fi_posting_int_all.org_id%TYPE
                          ) AS
    /*
    ||  Created By :
    ||  Created On :
    ||  Purpose :     This is a main Procedure which will Update the given Application to COMPLETE, if all the Tracking items are COMPLETE.
    ||                This is getting called as a concurrent Job.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  rghosh      21-Oct-2003        Added the REF CURSOR c_dyn_pig_check and hence the
    ||                                                  logic for supporting dynamic Person ID Group
    ||                                                   (Enh# 3194295 , ADCR043: Person ID Group)
    */


   TYPE c_dyn_pig_checkCurTyp IS REF CURSOR;
   c_dyn_pig_check c_dyn_pig_checkCurTyp;
   TYPE  c_dyn_pig_checkrecTyp IS RECORD ( person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                                                                     admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                                                                                     course_cd igs_ad_ps_appl_inst_all.course_cd%TYPE,
                                                                                     sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE);
   c_dyn_pig_check_rec c_dyn_pig_checkrecTyp ;


   lv_status     VARCHAR2(1);
   lv_sql_stmt   VARCHAR(32767);
   lv_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

    -- Get the details of
    CURSOR cur_appl_case1(
                          p_person_id               igs_ad_ps_appl_inst.person_id%TYPE,
                          p_admission_appl_number   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                          p_course_cd               igs_ad_ps_appl_inst.course_cd%TYPE,
                          p_sequence_number         igs_ad_ps_appl_inst.sequence_number%TYPE
                         ) IS
      SELECT person_id, admission_appl_number, course_cd, sequence_number
      FROM igs_ad_ps_appl_inst apai,
           igs_ad_ou_stat aos,
           igs_ad_doc_stat ads
      WHERE apai.person_id = p_person_id
        AND apai.admission_appl_number = p_admission_appl_number
        AND apai.course_cd = p_course_cd
        AND apai.sequence_number = p_sequence_number
        AND aos.s_adm_outcome_status IN ('PENDING','COND-OFFER')
        AND aos.closed_ind = 'N'
        AND apai.adm_outcome_status = aos.adm_outcome_status
        AND ads.s_adm_doc_status = 'PENDING'
        AND ads.closed_ind = 'N'
        AND apai.adm_doc_status  = ads.adm_doc_status;


    -- Get the details of
    CURSOR cur_appl_case2(
                          p_person_id  igs_ad_ps_appl_inst.person_id%TYPE
                         ) IS
      SELECT apai.person_id, apai.admission_appl_number, apai.course_cd, apai.sequence_number
      FROM igs_ad_ps_appl_inst apai,
           igs_ad_ou_stat aos,
           igs_ad_doc_stat ads
      WHERE apai.person_id = p_person_id
        AND aos.s_adm_outcome_status IN ('PENDING','COND-OFFER')
        AND aos.closed_ind = 'N'
        AND apai.adm_outcome_status = aos.adm_outcome_status
        AND ads.s_adm_doc_status = 'PENDING'
        AND ads.closed_ind  = 'N'
        AND apai.adm_doc_status  = ads.adm_doc_status;


    -- Get the details of
    CURSOR cur_appl_case4(
                          p_admission_cat                igs_ad_appl_all.admission_cat%TYPE,
                          p_s_admission_process_type     igs_ad_appl_all.s_admission_process_type%TYPE,
                          p_acad_cal_type                igs_ad_appl_all.acad_cal_type%TYPE,
                          p_acad_ci_sequence_number      igs_ad_appl_all.acad_ci_sequence_number%TYPE,
                          p_adm_cal_type                 igs_ad_appl_all.adm_cal_type%TYPE,
                          p_adm_ci_sequence_number       igs_ad_appl_all.adm_ci_sequence_number%TYPE
                         ) IS
      SELECT  apai.person_id, apai.admission_appl_number, apai. course_cd, apai.sequence_number
        FROM igs_ad_ps_appl_inst apai,
             igs_ad_appl aa,
             igs_ad_ou_stat aos,
             igs_ad_doc_stat ads
        WHERE apai.person_id = aa.person_id
          AND apai.admission_appl_number = aa.admission_appl_number
          AND aa.acad_cal_type = p_acad_cal_type
          AND aa.acad_ci_sequence_number = p_acad_ci_sequence_number
          AND aa.adm_cal_type = p_adm_cal_type
          AND aa.adm_ci_sequence_number = p_adm_ci_sequence_number
          AND aa.admission_cat = p_admission_cat
          AND aa.s_admission_process_type = p_s_admission_process_type
          AND aos.s_adm_outcome_status IN ('PENDING','COND-OFFER')
          AND aos.closed_ind = 'N'
          AND apai.adm_outcome_status = aos.adm_outcome_status
          AND ads.s_adm_doc_status = 'PENDING'
          AND ads.closed_ind = 'N'
          AND apai.adm_doc_status  = ads.adm_doc_status;


    l_acad_cal_type              igs_ca_inst_all.cal_type%TYPE;
    l_acad_ci_sequence_number    igs_ca_inst_all.sequence_number%TYPE;
    l_adm_cal_type               igs_ca_inst_all.cal_type%TYPE;
    l_adm_ci_sequence_number     igs_ca_inst_all.sequence_number%TYPE;
    l_admission_cat              igs_ad_appl_all.admission_cat%TYPE;
    l_s_admission_process_type   igs_ad_appl_all.s_admission_process_type%TYPE;
    l_records_not_found          BOOLEAN := TRUE;

  BEGIN

    -- Set the Org_id for the corresponding responsibility.
    igs_ge_gen_003.set_org_id( p_org_id);
    RETCODE := 0;
    ERRBUF  := NULL;
    lv_status  := 'S'; /*Defaulted to 'S' and the function will return 'F' in case of failure */
    lv_sql_stmt   :=  igs_pe_dynamic_persid_group.get_dynamic_sql(p_person_id_group,lv_status,lv_group_type);
    -- Log the Initial parameters into the LOG file.
    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_COM_PRMS');
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_PID');
    FND_MESSAGE.SET_TOKEN('PID', p_person_id);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_PID_GRP');
    FND_MESSAGE.SET_TOKEN('PGPID', p_person_id_group);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_ADM_APLNO');
    FND_MESSAGE.SET_TOKEN('APLNO', p_admission_appl_number);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CRCD');
    FND_MESSAGE.SET_TOKEN('CRCD', p_course_cd);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_APP_SEQNO');
    FND_MESSAGE.SET_TOKEN('SEQNO', p_sequence_number);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CL_DTLS');
    FND_MESSAGE.SET_TOKEN('CLDTLS', p_calendar_details);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_APC');
    FND_MESSAGE.SET_TOKEN('APC', p_admission_process_category);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    -- CASE 1 :
    -- If the parameters p_person_id, p_admission_appl_number, p_course_cd and p_sequence_number are entered
    IF p_person_id                  IS NOT NULL AND
       p_admission_appl_number      IS NOT NULL AND
       p_course_cd                  IS NOT NULL AND
       p_sequence_number            IS NOT NULL AND
       p_person_id_group            IS NULL AND
       p_admission_process_category IS NULL AND
       p_calendar_details           IS NULL
      THEN

      -- Based on the parameters entered fetch the application instance from admission
      -- application instance table which have application completion status = 'PENDING'
      -- and application outcome status = 'PENDING, COND-OFFER'.
      l_records_not_found   := TRUE;
      FOR cur_appl_case1_rec IN cur_appl_case1( p_person_id, p_admission_appl_number, p_course_cd, p_sequence_number) LOOP
        l_records_not_found   := FALSE;

        -- Make a call to the procedure : get_incp_trstp
        get_cpti_apcmp(
                      cur_appl_case1_rec.person_id,
                      cur_appl_case1_rec.admission_appl_number,
                      cur_appl_case1_rec.course_cd,
                      cur_appl_case1_rec.sequence_number
                     );
      END LOOP;

      -- If the Applicaiton records are not found then log a message
      IF l_records_not_found THEN
        -- Tracking steps cannot be completed for applications not having application completion status of pending
        -- and application outcome status of pending or conditional offer
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_PEND_STAT');
        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

        -- Abort the process and raise error
        RETURN;

      END IF;

    -- CASE 2 :
    -- In case only Person ID has been entered and all the other parameters are null
    ELSIF p_person_id                   IS NOT NULL AND
          p_admission_appl_number       IS NULL AND
          p_course_cd                   IS NULL AND
          p_sequence_number             IS NULL AND
          p_admission_process_category  IS NULL AND
          p_calendar_details            IS NULL AND
          p_person_id_group             IS NULL
      THEN
      -- Based  on the parameters entered fetch the application instance from admission
      -- application instance table which have application completion status = 'PENDING' and
      -- application outcome status = 'PENDING or 'COND-OFFER'
      l_records_not_found   := TRUE;
      FOR cur_appl_case2_rec IN cur_appl_case2( p_person_id) LOOP
        l_records_not_found   := FALSE;

        -- Make a call to the procedure : get_incp_trstp
        get_cpti_apcmp(
                      cur_appl_case2_rec.person_id,
                      cur_appl_case2_rec.admission_appl_number,
                      cur_appl_case2_rec.course_cd,
                      cur_appl_case2_rec.sequence_number
                     );
      END LOOP;

      -- If the Applicaiton records are not found then log a message
      IF l_records_not_found THEN
        -- Tracking steps cannot be completed for applications not having application completion status of pending
        -- and application outcome status of pending or conditional offer
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_PEND_STAT');
        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

        -- Abort the process and raise error
        RETURN;

      END IF;

    -- CASE 3 :
    -- In case the person group id has been entered and all other parameters are null
    ELSIF p_person_id_group            IS NOT NULL AND
          p_person_id                   IS NULL AND
          p_admission_appl_number       IS NULL AND
          p_course_cd                   IS NULL AND
          p_sequence_number             IS NULL AND
          p_admission_process_category  IS NULL AND
          p_calendar_details            IS NULL
    THEN

      -- Based  on the parameters entered fetch the application instance from admission
      -- application instance table which have application completion status = 'PENDING' and
      -- application outcome status = 'PENDING or COND-OFFER'

        l_records_not_found   := TRUE;

        IF lv_status = 'S' THEN
  	      BEGIN

              IF lv_group_type = 'STATIC' THEN

                       OPEN  c_dyn_pig_check FOR
                         'SELECT  apai.person_id, apai.admission_appl_number, apai.course_cd, apai.sequence_number
                          FROM igs_ad_ps_appl_inst apai,
                                       igs_ad_ou_stat aos,
                                       igs_ad_doc_stat ads
                          WHERE apai.person_id  IN ( '||lv_sql_stmt||')
                          AND aos.s_adm_outcome_status IN (''PENDING'',''COND-OFFER'')
                          AND aos.closed_ind = ''N''
                          AND apai.adm_outcome_status = aos.adm_outcome_status
                          AND ads.s_adm_doc_status = ''PENDING''
                          AND ads.closed_ind  = ''N''
                          AND apai.adm_doc_status  = ads.adm_doc_status '
			  USING p_person_id_group; LOOP

                     FETCH c_dyn_pig_check  INTO c_dyn_pig_check_rec;

                       IF c_dyn_pig_check%NOTFOUND THEN
                         EXIT;
                       END IF;

                       l_records_not_found   := FALSE;

                       -- Make a call to the procedure : get_incp_trstp
                       get_cpti_apcmp(
                               c_dyn_pig_check_rec.person_id,
                               c_dyn_pig_check_rec.admission_appl_number,
                               c_dyn_pig_check_rec.course_cd,
                               c_dyn_pig_check_rec.sequence_number
                              );
                       END LOOP;

              ELSIF lv_group_type = 'DYNAMIC' THEN

                       OPEN  c_dyn_pig_check FOR
                         'SELECT  apai.person_id, apai.admission_appl_number, apai.course_cd, apai.sequence_number
                          FROM igs_ad_ps_appl_inst apai,
                                       igs_ad_ou_stat aos,
                                       igs_ad_doc_stat ads
                          WHERE apai.person_id  IN ( '||lv_sql_stmt||')
                          AND aos.s_adm_outcome_status IN (''PENDING'',''COND-OFFER'')
                          AND aos.closed_ind = ''N''
                          AND apai.adm_outcome_status = aos.adm_outcome_status
                          AND ads.s_adm_doc_status = ''PENDING''
                          AND ads.closed_ind  = ''N''
                          AND apai.adm_doc_status  = ads.adm_doc_status'; LOOP

                     FETCH c_dyn_pig_check  INTO c_dyn_pig_check_rec;

                       IF c_dyn_pig_check%NOTFOUND THEN
                         EXIT;
                       END IF;

                       l_records_not_found   := FALSE;

                       -- Make a call to the procedure : get_incp_trstp
                       get_cpti_apcmp(
                               c_dyn_pig_check_rec.person_id,
                               c_dyn_pig_check_rec.admission_appl_number,
                               c_dyn_pig_check_rec.course_cd,
                               c_dyn_pig_check_rec.sequence_number
                              );
                       END LOOP;

              CLOSE c_dyn_pig_check;

              -- If the Applicaiton records are not found then log a message
              IF l_records_not_found THEN
                -- Tracking steps cannot be completed for applications not having application completion status of pending
                -- and application outcome status of pending or conditional offer
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_PEND_STAT');
                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                 -- Abort the process and raise error
                 RETURN;
              END IF;

            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME ('IGF','IGF_AP_INVALID_QUERY');
              FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.GET);
              FND_FILE.PUT_LINE (FND_FILE.LOG,lv_sql_stmt);
  	      END;

	      ELSE
          FND_MESSAGE.SET_NAME ('IGS',' IGS_AZ_DYN_PERS_ID_GRP_ERR');
          FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.GET);
        END IF;

    -- CASE 4 :
    -- In case the academic calendar, admission process category and admission calendar are
    -- entered and other parameters are null
    ELSIF p_admission_process_category  IS NOT NULL AND
          p_calendar_details            IS NOT NULL AND
          p_person_id                   IS NULL AND
          p_person_id_group             IS NULL AND
          p_admission_appl_number       IS NULL AND
          p_course_cd                   IS NULL AND
          p_sequence_number             IS NULL
      THEN

      -- Get the Academic Calander details form the Academic Calender Parameter
      l_acad_cal_type             := RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
      l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

      -- Get the Admission Calander details form the Admission Calender Parameter
      l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
      l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));

      -- Get the Admission Process Category details form the APC
      l_admission_cat             := RTRIM ( SUBSTR ( p_admission_process_category, 1, 10));
      l_s_admission_process_type  := TRIM ( SUBSTR ( p_admission_process_category, 11));

      -- Based  on the parameters entered fetch the application instance from admission
      -- application instance table which have application completion status = 'PENDING' and
      -- application outcome status = 'PENDING or COND-OFFER'
      l_records_not_found := TRUE;
      FOR cur_appl_case4_rec IN cur_appl_case4( l_admission_cat, l_s_admission_process_type, l_acad_cal_type, l_acad_ci_sequence_number, l_adm_cal_type, l_adm_ci_sequence_number ) LOOP
        l_records_not_found := FALSE;

        -- Make a call to the procedure : get_incp_trstp
        get_cpti_apcmp(
                      cur_appl_case4_rec.person_id,
                      cur_appl_case4_rec.admission_appl_number,
                      cur_appl_case4_rec.course_cd,
                      cur_appl_case4_rec.sequence_number
                     );
      END LOOP;

      -- If the Applicaiton records are not found then log a message
      IF l_records_not_found THEN
        -- Tracking steps cannot be completed for applications not having application completion status of pending
        -- and application outcome status of pending or conditional offer
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_PEND_STAT');
        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

        -- Abort the process and raise error
        RETURN;

      END IF;

    -- CASE 5 :
    -- All the parameters are NULL, raise an error and abort the process
    ELSIF p_admission_process_category  IS NULL AND
          p_calendar_details            IS NULL AND
          p_person_id                   IS NULL AND
          p_person_id_group             IS NULL AND
          p_admission_appl_number       IS NULL AND
          p_course_cd                   IS NULL AND
          p_sequence_number             IS NULL
      THEN

        -- Message ( 'All the parameters are null. The process cannot be run')
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_ALL_PRM_NULL');
        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
        RETURN;

    -- CASE 6 :
    -- In case if the parameters are not in proper combination.
    -- OR some improper combination
    ELSE
      -- 'Invalid parameters entered. Valid combinations for parameters to be entered is Person ID OR Person Group ID OR Person ID,
      -- Admission Application Number, Program Code, Sequence Number OR Academic Calendar, Admission Calendar, Admission Process Category'
      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_INV_PRM_COMB');
      FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
      RETURN;

    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK;
       RETCODE := 2;
       ERRBUF  := fnd_message.get_string( 'IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

  END upd_apl_cmp_st;

END igs_ad_ac_comp;

/
