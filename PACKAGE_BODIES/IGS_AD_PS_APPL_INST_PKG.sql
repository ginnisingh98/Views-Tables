--------------------------------------------------------
--  DDL for Package Body IGS_AD_PS_APPL_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PS_APPL_INST_PKG" AS
/* $Header: IGSAI18B.pls 120.14 2006/05/30 11:00:51 pbondugu ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_ps_appl_inst_all%RowType;
  new_references igs_ad_ps_appl_inst_all%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_org_id IN NUMBER,
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_predicted_gpa IN NUMBER,
    x_academic_index IN VARCHAR2,
    x_adm_cal_type IN VARCHAR2,
    x_app_file_location IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_app_source_id IN NUMBER,
    x_crv_version_number IN NUMBER,
    x_waitlist_rank IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attent_other_inst_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_edu_goal_prior_enroll_id IN NUMBER,
    x_attendance_type IN VARCHAR2,
    x_decision_make_id IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_decision_date IN DATE,
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
    x_decision_reason_id IN NUMBER,
    x_us_version_number IN NUMBER,
    x_decision_notes IN VARCHAR2,
    x_pending_reason_id IN NUMBER,
    x_preference_number IN NUMBER,
    x_adm_doc_status IN VARCHAR2,
    x_adm_entry_qual_status IN VARCHAR2,
    x_deficiency_in_prep IN VARCHAR2,
    x_late_adm_fee_status IN VARCHAR2,
    x_spl_consider_comments IN VARCHAR2,
    x_apply_for_finaid IN VARCHAR2,
    x_finaid_apply_date IN DATE,
    x_adm_outcome_status IN VARCHAR2,
    x_adm_otcm_stat_auth_per_id IN NUMBER,
    x_adm_outcome_status_auth_dt IN DATE,
    x_adm_outcome_status_reason IN VARCHAR2,
    x_offer_dt IN DATE,
    x_offer_response_dt IN DATE,
    x_prpsd_commencement_dt IN DATE,
    x_adm_cndtnl_offer_status IN VARCHAR2,
    x_cndtnl_offer_satisfied_dt IN DATE,
    x_cndnl_ofr_must_be_stsfd_ind IN VARCHAR2,
    x_adm_offer_resp_status IN VARCHAR2,
    x_actual_response_dt IN DATE,
    x_adm_offer_dfrmnt_status IN VARCHAR2,
    x_deferred_adm_cal_type IN VARCHAR2,
    x_deferred_adm_ci_sequence_num IN NUMBER,
    x_deferred_tracking_id IN NUMBER,
    x_ass_rank IN NUMBER,
    x_secondary_ass_rank IN NUMBER,
    x_intr_accept_advice_num IN NUMBER,
    x_ass_tracking_id IN NUMBER,
    x_fee_cat IN VARCHAR2,
    x_hecs_payment_option IN VARCHAR2,
    x_expected_completion_yr IN NUMBER,
    x_expected_completion_perd IN VARCHAR2,
    x_correspondence_cat IN VARCHAR2,
    x_enrolment_cat IN VARCHAR2,
    x_funding_source IN VARCHAR2,
    x_applicant_acptnce_cndtn IN VARCHAR2,
    x_cndtnl_offer_cndtn IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_ss_application_id IN VARCHAR2,
    x_ss_pwd IN VARCHAR2  ,
    X_AUTHORIZED_DT IN DATE,
    X_AUTHORIZING_PERS_ID IN NUMBER,
    x_entry_status IN NUMBER,
    x_entry_level IN NUMBER,
    x_sch_apl_to_id IN NUMBER,
    x_idx_calc_date IN DATE,
    x_waitlist_status IN VARCHAR2,
      x_attribute21 IN VARCHAR2,
      x_attribute22 IN VARCHAR2,
      x_attribute23 IN VARCHAR2,
      x_attribute24 IN VARCHAR2,
      x_attribute25 IN VARCHAR2,
      x_attribute26 IN VARCHAR2,
      x_attribute27 IN VARCHAR2,
      x_attribute28 IN VARCHAR2,
      x_attribute29 IN VARCHAR2,
      x_attribute30 IN VARCHAR2,
      x_attribute31 IN VARCHAR2,
      x_attribute32 IN VARCHAR2,
      x_attribute33 IN VARCHAR2,
      x_attribute34 IN VARCHAR2,
      x_attribute35 IN VARCHAR2,
      x_attribute36 IN VARCHAR2,
      x_attribute37 IN VARCHAR2,
      x_attribute38 IN VARCHAR2,
      x_attribute39 IN VARCHAR2,
      x_attribute40 IN VARCHAR2,
      x_fut_acad_cal_type           IN VARCHAR2,
      x_fut_acad_ci_sequence_number IN NUMBER  ,
      x_fut_adm_cal_type            IN VARCHAR2,
      x_fut_adm_ci_sequence_number  IN NUMBER  ,
      x_prev_term_adm_appl_number  IN NUMBER  ,
      x_prev_term_sequence_number  IN NUMBER  ,
      x_fut_term_adm_appl_number    IN NUMBER  ,
      x_fut_term_sequence_number    IN NUMBER  ,
      x_def_acad_cal_type IN VARCHAR2,
      x_def_acad_ci_sequence_num  IN NUMBER  ,
      x_def_prev_term_adm_appl_num  IN NUMBER  ,
      x_def_prev_appl_sequence_num  IN NUMBER  ,
      x_def_term_adm_appl_num  IN NUMBER  ,
      x_def_appl_sequence_num  IN NUMBER  ,
      x_appl_inst_status	IN VARCHAR2,				--arvsrini igsm
      x_ais_reason		IN VARCHAR2,
      x_decline_ofr_reason	IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : nsinha
  Date Created By : Jul 30, 2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smadathi       12-feb-2002      Bug 2217104. Added new columns as mentioned against DLD
  nsinha         Jul 30, 2001     Bug enh no : 1905651 changes.
                                  Added entry_status, entry_level and sch_apl_to_id
                                  to the procedures
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PS_APPL_INST_ALL
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
      IGS_AD_GEN_001.SET_TOKEN('From Table  IGS_AD_PS_APPL_INST_ALL P_action NOT IN INSERT or VALiDATE_INSERT' );
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.predicted_gpa := x_predicted_gpa;
    new_references.academic_index := x_academic_index;
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.app_file_location := x_app_file_location;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.course_cd := x_course_cd;
    new_references.app_source_id := x_app_source_id;
    new_references.crv_version_number := x_crv_version_number;
    new_references.waitlist_rank := x_waitlist_rank;
    new_references.location_cd := x_location_cd;
    new_references.attent_other_inst_cd := x_attent_other_inst_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.edu_goal_prior_enroll_id := x_edu_goal_prior_enroll_id;
    new_references.attendance_type := x_attendance_type;
    new_references.decision_make_id := x_decision_make_id;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.decision_date := TRUNC(x_decision_date);
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
    new_references.decision_reason_id := x_decision_reason_id;
    new_references.us_version_number := x_us_version_number;
    new_references.decision_notes := x_decision_notes;
    new_references.pending_reason_id := x_pending_reason_id;
    new_references.preference_number := x_preference_number;
    new_references.adm_doc_status := x_adm_doc_status;
    new_references.adm_entry_qual_status := x_adm_entry_qual_status;
    new_references.deficiency_in_prep := x_deficiency_in_prep;
    new_references.late_adm_fee_status := x_late_adm_fee_status;
    new_references.spl_consider_comments := x_spl_consider_comments;
    new_references.apply_for_finaid := x_apply_for_finaid;
    new_references.finaid_apply_date := TRUNC(x_finaid_apply_date);
    new_references.adm_outcome_status := x_adm_outcome_status;
    new_references.adm_otcm_status_auth_person_id := x_adm_otcm_stat_auth_per_id;
    new_references.adm_outcome_status_auth_dt := TRUNC(x_adm_outcome_status_auth_dt);
    new_references.adm_outcome_status_reason := x_adm_outcome_status_reason;
    new_references.offer_dt := TRUNC(x_offer_dt);
    new_references.offer_response_dt := TRUNC(x_offer_response_dt);
    new_references.prpsd_commencement_dt := TRUNC(x_prpsd_commencement_dt);
    new_references.adm_cndtnl_offer_status := x_adm_cndtnl_offer_status;
    new_references.cndtnl_offer_satisfied_dt := TRUNC(x_cndtnl_offer_satisfied_dt);
    new_references.cndtnl_offer_must_be_stsfd_ind := x_cndnl_ofr_must_be_stsfd_ind;
    new_references.adm_offer_resp_status := x_adm_offer_resp_status;
    new_references.actual_response_dt := TRUNC(x_actual_response_dt);
    new_references.adm_offer_dfrmnt_status := x_adm_offer_dfrmnt_status;
    new_references.deferred_adm_cal_type := x_deferred_adm_cal_type;
    new_references.deferred_adm_ci_sequence_num := x_deferred_adm_ci_sequence_num;
    new_references.deferred_tracking_id := x_deferred_tracking_id;
    new_references.ass_rank := x_ass_rank;
    new_references.secondary_ass_rank := x_secondary_ass_rank;
    new_references.intrntnl_acceptance_advice_num := x_intr_accept_advice_num;
    new_references.ass_tracking_id := x_ass_tracking_id;
    new_references.fee_cat := x_fee_cat;
    new_references.hecs_payment_option := x_hecs_payment_option;
    new_references.expected_completion_yr := x_expected_completion_yr;
    new_references.expected_completion_perd := x_expected_completion_perd;
    new_references.correspondence_cat := x_correspondence_cat;
    new_references.enrolment_cat := x_enrolment_cat;
    new_references.funding_source := x_funding_source;
    new_references.applicant_acptnce_cndtn := x_applicant_acptnce_cndtn;
    new_references.cndtnl_offer_cndtn := x_cndtnl_offer_cndtn;
    new_references.ss_application_id := x_ss_application_id;
    new_references.ss_pwd := x_ss_pwd;
    new_references.authorized_dt := TRUNC(x_authorized_dt);
    new_references.authorizing_pers_id := x_authorizing_pers_id;
    new_references.entry_status := x_entry_status;
    new_references.entry_level := x_entry_level;
    new_references.sch_apl_to_id := x_sch_apl_to_id;
    new_references.idx_calc_date := TRUNC(x_idx_calc_date);
    new_references.waitlist_status := x_waitlist_status;
    new_references.attribute21 := x_attribute21;
    new_references.attribute22 := x_attribute22;
    new_references.attribute23 := x_attribute23;
    new_references.attribute24 := x_attribute24;
    new_references.attribute25 := x_attribute25;
    new_references.attribute26 := x_attribute26;
    new_references.attribute27 := x_attribute27;
    new_references.attribute28 := x_attribute28;
    new_references.attribute29 := x_attribute29;
    new_references.attribute30 := x_attribute30;
    new_references.attribute31 := x_attribute31;
    new_references.attribute32 := x_attribute32;
    new_references.attribute33 := x_attribute33;
    new_references.attribute34 := x_attribute34;
    new_references.attribute35 := x_attribute35;
    new_references.attribute36 := x_attribute36;
    new_references.attribute37 := x_attribute37;
    new_references.attribute38 := x_attribute38;
    new_references.attribute39 := x_attribute39;
    new_references.attribute40 := x_attribute40;
    new_references.future_acad_cal_type            :=  x_fut_acad_cal_type;
    new_references.future_acad_ci_sequence_number  :=  x_fut_acad_ci_sequence_number;
    new_references.future_adm_cal_type             :=  x_fut_adm_cal_type;
    new_references.future_adm_ci_sequence_number   :=  x_fut_adm_ci_sequence_number ;
    new_references.previous_term_adm_appl_number   :=  x_prev_term_adm_appl_number;
    new_references.previous_term_sequence_number   :=  x_prev_term_sequence_number;
    new_references.future_term_adm_appl_number     :=  x_fut_term_adm_appl_number;
    new_references.future_term_sequence_number     :=  x_fut_term_sequence_number;
    new_references.def_acad_cal_type := x_def_acad_cal_type;
    new_references.def_acad_ci_sequence_num     := x_def_acad_ci_sequence_num;
    new_references.def_prev_term_adm_appl_num      := x_def_prev_term_adm_appl_num;
    new_references.def_prev_appl_sequence_num      := x_def_prev_appl_sequence_num;
    new_references.def_term_adm_appl_num           := x_def_term_adm_appl_num;
    new_references.def_appl_sequence_num           := x_def_appl_sequence_num;
    new_references.appl_inst_status		   := x_appl_inst_status;			--arvsrini igsm
    new_references.ais_reason			   := x_ais_reason;
    new_references.decline_ofr_reason		   := x_decline_ofr_reason;


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
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) IS
        v_message_name                  VARCHAR2(30);
        v_return_type                   VARCHAR2(1);
        v_update_non_enrol_detail_ind   VARCHAR2(1)     ;
        v_late_ind                      VARCHAR2(1)     ;
        v_staff_member_ind              IGS_PE_PERSON.staff_member_ind%TYPE;
        v_p_inserting_ind                       VARCHAR2(1)     ;
        v_offer_ind                     VARCHAR2(1)     ;
        v_crv_version_number            IGS_PS_VER.version_number%TYPE;
        v_admission_cat                 IGS_AD_APPL.admission_cat%TYPE;
        v_s_admission_process_type      IGS_AD_APPL.s_admission_process_type%TYPE;
        v_acad_cal_type                 IGS_AD_APPL.acad_cal_type%TYPE;
        v_aa_acad_ci_sequence_number    IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_aa_adm_cal_type               IGS_AD_APPL.adm_cal_type%TYPE;
        v_aa_adm_ci_sequence_number     IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_acad_ci_sequence_number       IGS_AD_APPL.acad_ci_sequence_number%TYPE;
        v_adm_cal_type                  IGS_AD_APPL.adm_cal_type%TYPE;
        v_adm_ci_sequence_number        IGS_AD_APPL.adm_ci_sequence_number%TYPE;
        v_appl_dt                               IGS_AD_APPL.appl_dt%TYPE;
        v_adm_appl_status                     IGS_AD_APPL.adm_appl_status%TYPE;
        v_adm_fee_status                        IGS_AD_APPL.adm_fee_status%TYPE;
        v_transfer_course_cd            IGS_AD_PS_APPL.transfer_course_cd%TYPE;
        v_ca_sequence_number            IGS_RE_CANDIDATURE.sequence_number%TYPE;
        v_pref_allowed_ind                      VARCHAR2(1)     ;
        v_pref_limit                    NUMBER;
        v_cond_offer_doc_allowed_ind    VARCHAR2(1)     ;
        v_cond_offer_fee_allowed_ind    VARCHAR2(1)     ;
        v_cond_offer_ass_allowed_ind    VARCHAR2(1)     ;
        v_late_appl_allowed_ind         VARCHAR2(1)     ;
        v_late_fees_required_ind                VARCHAR2(1)     ;
        v_fees_required_ind             VARCHAR2(1)     ;
        v_override_outcome_allowed_ind  VARCHAR2(1)     ;
        v_set_outcome_allowed_ind               VARCHAR2(1)     ;
        v_mult_offer_allowed_ind                VARCHAR2(1)     ;
        v_multi_offer_limit                     NUMBER;
        v_unit_set_appl_ind             VARCHAR2(1)     ;
        v_check_person_encumb           VARCHAR2(1)     ;
        v_check_course_encumb           VARCHAR2(1)     ;
        v_deferral_allowed_ind          VARCHAR2(1)     ;
        v_pre_enrol_ind                 VARCHAR2(1)     ;
        cst_error                               CONSTANT        VARCHAR2(1):= 'E';
        cst_transfer                    CONSTANT        VARCHAR2(8) := 'TRANSFER';
        -- Variables added to handle mutation logic
        v_index                         BINARY_INTEGER;
        CURSOR c_aca (
                cp_person_id            IGS_AD_PS_APPL.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_PS_APPL.admission_appl_number%TYPE,
                cp_nominated_course_cd  IGS_AD_PS_APPL.nominated_course_cd%TYPE) IS
        SELECT  transfer_course_cd
        FROM    IGS_AD_PS_APPL
        WHERE   person_id = cp_person_id AND
                admission_appl_number = cp_admission_appl_number AND
                nominated_course_cd = cp_nominated_course_cd;
        CURSOR c_apcs (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type
                                        IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT  s_admission_step_type,
                step_type_restriction_num
        FROM    IGS_AD_PRCS_CAT_STEP
        WHERE   admission_cat = cp_admission_cat AND
                s_admission_process_type = cp_s_admission_process_type AND
                step_group_type <> 'TRACK'; --2402377
        CURSOR c_pti (
                      cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                      cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                      cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                      cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE) IS
        SELECT pti.rowid row_id
	FROM igs_pe_typ_instances_all pti,
	     igs_pe_person_types ppt
	WHERE pti.person_id = cp_person_id
	    AND pti.admission_appl_number = cp_admission_appl_number
	    AND pti.nominated_course_cd = cp_nominated_course_cd
	    AND pti.sequence_number = cp_sequence_number
	    AND ppt.person_type_code = pti.person_type_code
	    AND ppt.system_type = 'APPLICANT';

	 CURSOR c_appl_dt (p_person_id  igs_ad_appl.person_id%TYPE,
		p_admission_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
	  SELECT appl_dt  FROM  igs_ad_appl
       WHERE    person_id = p_person_id
	AND      admission_appl_number = p_admission_appl_number;

       -- Following cursors added as part of Single Response build Bug:3132406
       CURSOR get_single_response (p_admission_cat igs_ad_appl_all.admission_cat%TYPE,
                                   p_s_admission_process_type igs_ad_appl_all.s_admission_process_type%TYPE) IS
       SELECT admprd.single_response_flag
       FROM igs_ad_prd_ad_prc_ca admprd,
              igs_ad_appl_all appl,
              igs_ad_ps_appl_inst_all aplinst
       WHERE appl.person_id = new_references.person_id
              AND appl.admission_appl_number = new_references.admission_appl_number
              AND appl.person_id = aplinst.person_id
              AND appl.admission_appl_number = aplinst.admission_appl_number
              AND admprd.adm_cal_type = NVL(aplinst.adm_cal_type,appl.adm_cal_type)
              AND admprd.adm_ci_sequence_number = NVL(aplinst.adm_ci_sequence_number,appl.adm_ci_sequence_number)
              AND admprd.admission_cat = p_admission_cat
              AND admprd.s_admission_process_type = p_s_admission_process_type;

        CURSOR get_aplinst_response_accepted IS
        SELECT distinct appl.application_id, aplinst.nominated_course_cd
        FROM igs_ad_appl_all appl,
            igs_ad_ps_appl_inst aplinst,
            igs_ad_prd_ad_prc_ca admprd
        WHERE appl.person_id = aplinst.person_id
        AND appl.admission_appl_number = aplinst.admission_appl_number
        AND appl.person_id = new_references.person_id
        AND igs_ad_gen_009.admp_get_sys_aors(aplinst.adm_offer_resp_status) = 'ACCEPTED'
        AND admprd.adm_cal_type = NVL(aplinst.adm_cal_type,appl.adm_cal_type)
        AND admprd.adm_ci_sequence_number = NVL(aplinst.adm_ci_sequence_number,appl.adm_ci_sequence_number)
	AND admprd.admission_cat = appl.admission_cat
	AND admprd.s_admission_process_type = appl.s_admission_process_type
        AND admprd.single_response_flag = 'Y';

        CURSOR get_alternate_code ( p_cal_type igs_ca_inst.cal_type%TYPE,
	                            p_sequence_number igs_ca_inst.sequence_number%TYPE) IS
	SELECT alternate_code
	FROM igs_ca_inst
	WHERE cal_type = p_cal_type
	AND sequence_number = p_sequence_number;


	l_appl_dt  igs_ad_appl.appl_dt%TYPE;
	l_single_response_flag igs_ad_prd_ad_prc_ca.single_response_flag%TYPE;
	l_application_id igs_ad_appl_all.application_id%TYPE;
	l_acad_alt_code igs_ca_inst.alternate_code%TYPE;
	l_adm_alt_code igs_ca_inst.alternate_code%TYPE;
	l_nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE;

	l_s_adm_outcome_status VARCHAR2(30) ;
	cst_withdrawn		CONSTANT VARCHAR2(10) := 'WITHDRAWN';

	--- begin apadegal ADTD001 RE-OPEN Build  igs.m
	CURSOR cur_reconsider IS
        SELECT   req_for_reconsideration_ind
        FROM     IGS_AD_PS_APPL_ALL apl
	WHERE   apl.person_id = new_references.person_id
        AND     apl.admission_appl_number = new_references.admission_appl_number
        AND     apl.nominated_course_cd = new_references.nominated_course_cd ;

	l_is_inst_reconsidered VARCHAR2(1) DEFAULT NULL;

	CURSOR c_decl_ofr_rsn (cp_lookup_code igs_lookup_values.lookup_code%TYPE) IS
	       SELECT 1
                  FROM IGS_LOOKUP_VALUES lkupv
               WHERE lookup_type = 'IGS_AD_DECL_OFR_REAS'
                 AND lkupv.CLOSED_IND <> 'N'
		 AND LOOKUP_CODE = cp_lookup_code;

        --- end apadegal ADTD001 RE-OPEN Build  igs.m

  BEGIN
        v_unit_set_appl_ind             := 'N';
        v_check_person_encumb           := 'N';
        v_check_course_encumb           := 'N';
        v_deferral_allowed_ind          := 'N';
        v_pre_enrol_ind                 := 'N';
        v_cond_offer_doc_allowed_ind    := 'N';
        v_cond_offer_fee_allowed_ind    := 'N';
        v_cond_offer_ass_allowed_ind    := 'N';
        v_late_appl_allowed_ind         := 'N';
        v_late_fees_required_ind        := 'N';
        v_fees_required_ind             := 'N';
        v_override_outcome_allowed_ind  := 'N';
        v_set_outcome_allowed_ind       := 'N';
        v_mult_offer_allowed_ind        := 'N';
        v_pref_allowed_ind              := 'N';
        v_p_inserting_ind               := 'N';
        v_offer_ind                     := 'N';
        v_update_non_enrol_detail_ind   := 'N';
        v_late_ind                      := 'N';

	l_s_adm_outcome_status := igs_ad_gen_008.admp_get_saos(new_references.adm_outcome_status);
        IF NVL(p_inserting,FALSE) OR NVL(p_updating,FALSE) THEN
                OPEN c_appl_dt(p_person_id => new_references.person_id,
				p_admission_appl_number => new_references.admission_appl_number);
		FETCH c_appl_dt  INTO l_appl_dt;
		CLOSE c_appl_dt;

		IF (new_references.adm_outcome_status_auth_dt IS NOT NULL
		  AND  new_references.adm_outcome_status_auth_dt  < l_appl_dt ) THEN
		       FND_MESSAGE.SET_NAME('IGS','IGS_AD_APPL_DATE_ERROR');
		        FND_MESSAGE.SET_TOKEN ('NAME',fnd_message.get_string('IGS','IGS_AD_OS_AUTH_DT'));
		       IGS_GE_MSG_STACK.ADD;
		       APP_EXCEPTION.RAISE_EXCEPTION;
	     END IF;
	   IF ( new_references.offer_dt IS NOT NULL AND  new_references.offer_dt  < l_appl_dt ) THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_OFRDT_APPLDT');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	   END IF;
	   IF ( new_references.offer_dt IS NOT NULL AND  new_references.offer_dt  > SYSDATE ) THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_OFFER_DATE_INVALID');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	   END IF;

	    IF (new_references.idx_calc_date IS NOT NULL AND new_references.idx_calc_date  < l_appl_dt ) THEN
		FND_MESSAGE.SET_NAME('IGS','IGS_AD_APPL_DATE_ERROR');
	       FND_MESSAGE.SET_TOKEN ('NAME',fnd_message.get_string('IGS','IGS_AD_CALC_DATE'));
	       IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	    ELSIF new_references.idx_calc_date > SYSDATE THEN
               FND_MESSAGE.SET_NAME('IGS','IGS_AD_DATE_SYSDATE');
               FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CALC_DATE'));
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
	    END IF;

	    --stammine
	    IF NVL(new_references.decline_ofr_reason,'-1*$') <> NVL(old_references.decline_ofr_reason,'-1*$') THEN
	         FOR c_decl_ofr_rsn_rec IN c_decl_ofr_rsn(new_references.decline_ofr_reason)
		 LOOP
		     FND_MESSAGE.SET_NAME('IGS','IGS_AD_DCL_OFR_RS_CLD');
                     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		 END LOOP;
	     END IF;


                -- Get admission application details required for validation.
                --
                igs_ad_gen_002.admp_get_aa_dtl(
                        new_references.person_id,
                        new_references.admission_appl_number,
                        v_admission_cat,
                        v_s_admission_process_type,
                        v_acad_cal_type,
                        v_aa_acad_ci_sequence_number,
                        v_aa_adm_cal_type,
                        v_aa_adm_ci_sequence_number,
                        v_appl_dt,
                        v_adm_appl_status,
                        v_adm_fee_status);

                -- Start of Single Response validations Bug:3132406
                IF (old_references.adm_offer_resp_status <> new_references.adm_offer_resp_status AND
                  igs_ad_gen_009.admp_get_sys_aors (new_references.adm_offer_resp_status) = 'ACCEPTED') THEN
                  OPEN get_single_response (v_admission_cat,v_s_admission_process_type);
                  FETCH get_single_response INTO l_single_response_flag;
                  CLOSE get_single_response;

                  IF l_single_response_flag = 'Y' THEN
                    OPEN get_aplinst_response_accepted;
                    FETCH get_aplinst_response_accepted INTO l_application_id,l_nominated_course_cd;
                    IF get_aplinst_response_accepted%FOUND THEN
                      CLOSE get_aplinst_response_accepted;

		      OPEN get_alternate_code(v_acad_cal_type,v_aa_acad_ci_sequence_number);
                      FETCH get_alternate_code INTO l_acad_alt_code;
		      CLOSE get_alternate_code;

		      OPEN get_alternate_code(v_aa_adm_cal_type,v_aa_adm_ci_sequence_number);
                      FETCH get_alternate_code INTO l_adm_alt_code;
		      CLOSE get_alternate_code;


                      FND_MESSAGE.SET_NAME('IGS','IGS_AD_SINGLE_OFFRESP_EXISTS');
                      FND_MESSAGE.SET_TOKEN ('PROG_CODE',l_nominated_course_cd);
                      FND_MESSAGE.SET_TOKEN ('APPL_ID', TO_CHAR(l_application_id));
                      FND_MESSAGE.SET_TOKEN ('ACAD_ADM_PRD', l_acad_alt_code||'/'||l_adm_alt_code);
                      IGS_GE_MSG_STACK.ADD;
                      APP_EXCEPTION.RAISE_EXCEPTION;
                    ELSE
                      CLOSE get_aplinst_response_accepted;
                    END IF;
                  END IF;
                END IF;
		-- End of Single Response validations Bug:3132406

                --
                -- Validate step access.
                --
                IF NVL(p_inserting,FALSE) THEN
                        v_p_inserting_ind := 'Y';
                END IF;
                --
                -- Determine the admission process category steps.
                --
                FOR v_apcs_rec IN c_apcs (
                                v_admission_cat,
                                v_s_admission_process_type)
                LOOP
                        IF v_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
                                v_check_course_encumb := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'CHKPENCUMB' THEN
                                v_check_person_encumb := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'PREF-LIMIT' THEN
                                v_pref_allowed_ind := 'Y';
                                v_pref_limit := v_apcs_rec.step_type_restriction_num;
                        ELSIF v_apcs_rec.s_admission_step_type = 'DOC-COND' THEN
                                v_cond_offer_doc_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'FEE-COND' THEN
                                v_cond_offer_fee_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'ASSES-COND' THEN
                                v_cond_offer_ass_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
                                v_late_appl_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'LATE-FEE' THEN
                                v_late_fees_required_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'APP-FEE' THEN
                                v_fees_required_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'OVERRIDE-O' THEN
                                        v_override_outcome_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'SET-OTCOME' THEN
                                        v_set_outcome_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'MULTI-OFF' THEN
                                v_mult_offer_allowed_ind := 'Y';
                                v_multi_offer_limit := v_apcs_rec.step_type_restriction_num;
                        ELSIF v_apcs_rec.s_admission_step_type = 'UNIT-SET' THEN
                                v_unit_set_appl_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'DEFER' THEN
                                v_deferral_allowed_ind := 'Y';
                        ELSIF v_apcs_rec.s_admission_step_type = 'PRE-ENROL' THEN
                                        v_pre_enrol_ind := 'Y';
                        END IF;
                END LOOP;
                --
                -- Determine the Academic and Admission period for validation.
                --
                IF new_references.adm_cal_type IS NULL THEN
                        v_acad_ci_sequence_number := v_aa_acad_ci_sequence_number;
                        v_adm_cal_type := v_aa_adm_cal_type;
                        v_adm_ci_sequence_number := v_aa_adm_ci_sequence_number;
                ELSE
                        v_acad_ci_sequence_number := IGS_CA_GEN_001.CALP_GET_SUP_INST (
                                                        v_acad_cal_type,
                                                        new_references.adm_cal_type,
                                                        new_references.adm_ci_sequence_number);
                        v_adm_cal_type := new_references.adm_cal_type;
                        v_adm_ci_sequence_number := new_references.adm_ci_sequence_number;
                END IF;
                IF NVL(p_updating,FALSE) THEN

                        -- Validate update of an admission IGS_PS_COURSE application instance record.


		        --- begin apadegal ADTD001 RE-OPEN Build  igs.m
			OPEN cur_reconsider;
			FETCH cur_reconsider INTO   l_is_inst_reconsidered;
			CLOSE  cur_reconsider;
			--- end apadegal ADTD001 RE-OPEN Build  igs.m
                        --
                        IF IGS_AD_VAL_ACAI.admp_val_acai_update (
                                        v_adm_appl_status,
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        v_message_name,
                                        v_update_non_enrol_detail_ind) = FALSE THEN



				IF (IGS_AD_GEN_007.ADMP_GET_SAAS(old_references.appl_inst_status)= cst_withdrawn
						AND new_references.appl_inst_status IS NULL) THEN		-- resubmitting application instance
														-- arvsrini igsm
					NULL;
				ELSIF (NVL(l_is_inst_reconsidered,'N') = 'Y') THEN -- during RECONSIDERATION ,
				     NULL;	                 ---need  to set the outcomes to pending, let the records get updated.
				ELSE
					IF v_update_non_enrol_detail_ind = 'Y' THEN
						IF NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
								NVL(old_references.adm_ci_sequence_number, -1) <>
									NVL(new_references.adm_ci_sequence_number, -1) OR
								old_references.course_cd <>
									new_references.course_cd OR
								old_references.crv_version_number <>
									new_references.crv_version_number OR
								NVL(old_references.location_cd, '-1') <>
									NVL(new_references.location_cd, '-1') OR
								NVL(old_references.attendance_mode, '-1') <>
									NVL(new_references.attendance_mode, '-1') OR
								NVL(old_references.attendance_type, '-1') <>
									NVL(new_references.attendance_type, '-1') OR
								NVL(old_references.unit_set_cd, '-1') <>
									NVL(new_references.unit_set_cd, '-1') OR
								NVL(old_references.us_version_number, -1) <>
									NVL(new_references.us_version_number, -1) OR
								NVL(old_references.preference_number, -1) <>
									NVL(new_references.preference_number, -1) OR
								NVL(TRUNC(old_references.prpsd_commencement_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
									NVL(new_references.prpsd_commencement_dt,
										IGS_GE_DATE.IGSDATE('1900/01/01')) OR
								NVL(old_references.fee_cat, '-1') <>
									NVL(new_references.fee_cat, '-1') OR
								NVL(old_references.hecs_payment_option, '-1') <>
									NVL(new_references.hecs_payment_option, '-1') OR
								NVL(old_references.expected_completion_yr, -1) <>
									NVL(new_references.expected_completion_yr, -1) OR
								NVL(old_references.expected_completion_perd, '-1') <>
									NVL(new_references.expected_completion_perd, '-1') OR
								NVL(old_references.correspondence_cat, '-1') <>
									NVL(new_references.correspondence_cat, '-1') OR
								NVL(old_references.enrolment_cat, '-1') <>
									NVL(new_references.enrolment_cat, '-1') THEN
							FND_MESSAGE.SET_NAME('IGS',v_message_name);
							IGS_GE_MSG_STACK.ADD;
							APP_EXCEPTION.RAISE_EXCEPTION;
						END IF;
					ELSE
						IF NOT (igs_ad_gen_002.check_any_offer_inst(new_references.person_id,			--arvsrini igsm
											    new_references.admission_appl_number,	--either instance is withdrawn
											    new_references.nominated_course_cd,		--or instance is complete and is not offered/cond offered
											    new_references.sequence_number)		--or instance is complete but deffered appl is already created
							 AND old_references.def_term_adm_appl_num IS NULL 				-- hence cant be udpated
							 AND old_references.def_appl_sequence_num IS NULL
							)
								OR check_non_updateable_list() THEN -- tried to update the fields which are not supposed to be updated in proced phase
							IF IGS_AD_GEN_007.ADMP_GET_SAAS(old_references.appl_inst_status) = cst_withdrawn THEN
								FND_MESSAGE.SET_NAME('IGS','IGS_AD_APPL_INST_WITHD');
								IGS_GE_MSG_STACK.ADD;
								APP_EXCEPTION.RAISE_EXCEPTION;
							ELSE
								FND_MESSAGE.SET_NAME('IGS','IGS_AD_APPL_INST_COMPL');
								IGS_GE_MSG_STACK.ADD;
								APP_EXCEPTION.RAISE_EXCEPTION;
							END IF;
						END IF;

					END IF;
				 END IF;

                        END IF;	    -- end if of igs_admp_val_acai_update

			--
                        -- Cannot update the IGS_PS_COURSE Version.
                        --
                        IF ((old_references.course_cd <> new_references.course_cd) OR
                                        (old_references.crv_version_number <> new_references.crv_version_number)) THEN
                                FND_MESSAGE.SET_NAME('IGS','IGS_AD_UPD_PRGVER_NOTALLOW');
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                        --
                        -- Validate change of preference.
                        IF v_pref_allowed_ind = 'Y' AND
                                        NVL(old_references.preference_number, -1) <> NVL(new_references.preference_number, -1) THEN
                                IF IGS_AD_VAL_ACAI.admp_val_chg_of_pref (
                                                v_adm_cal_type,
                                                v_adm_ci_sequence_number,
                                                v_admission_cat,
                                                v_s_admission_process_type,
                                                new_references.course_cd,
                                                new_references.crv_version_number,
                                                v_acad_cal_type,
                                                new_references.location_cd,
                                                new_references.attendance_mode,
                                                new_references.attendance_type,
                                                v_message_name) = FALSE THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF; -- p_updating
                IF NVL(p_inserting,FALSE) THEN
                        -- Validate insert of a preference.
                        IF v_pref_allowed_ind = 'Y' THEN
                                IF IGS_AD_VAL_ACAI.admp_val_chg_of_pref (
                                                v_adm_cal_type,
                                                v_adm_ci_sequence_number,
                                                v_admission_cat,
                                                v_s_admission_process_type,
                                                new_references.course_cd,
                                                new_references.crv_version_number,
                                                v_acad_cal_type,
                                                new_references.location_cd,
                                                new_references.attendance_mode,
                                                new_references.attendance_type,
                                                v_message_name) = FALSE THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate the Admission Calendar.
                -- If either calendar component is set, then both must be set.
                --
                IF new_references.adm_cal_type IS NOT NULL AND
                                new_references.adm_ci_sequence_number IS NULL THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_AD_ADMCAL_SET_ADMCAL_SET');
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
                IF new_references.adm_ci_sequence_number IS NOT NULL AND
                                new_references.adm_cal_type IS NULL THEN
                        FND_MESSAGE.SET_NAME('IGS','IGS_AD_ADMCAL_SET_ADMCAL_SET');
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF;
                IF new_references.adm_cal_type IS NOT NULL AND
                                (NVL(old_references.adm_cal_type, '-1') <> new_references.adm_cal_type OR
                                 NVL(old_references.adm_ci_sequence_number, -1) <> new_references.adm_ci_sequence_number) THEN
                        IF IGS_AD_VAL_AA.admp_val_aa_adm_cal (
                                        new_references.adm_cal_type,
                                        new_references.adm_ci_sequence_number,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Determine the offer indicator.
                --
                IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') IN
                                ('OFFER', 'COND-OFFER') THEN
                        v_offer_ind := 'Y';
                END IF;
                --
                -- Validate the IGS_PS_COURSE code.
                --
                IF (NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1))THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_course (
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_appl_dt,
                                        v_late_appl_allowed_ind,
                                        v_offer_ind,
                                        v_crv_version_number,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate IGS_PS_COURSE encumbrances.
                --
                IF v_check_course_encumb = 'Y' AND
                                (NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1))THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_encmb (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_check_course_encumb,
                                        v_offer_ind,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate against current student IGS_PS_COURSE attempt.
                --
                IF NVL(old_references.course_cd, '-1') <> new_references.course_cd THEN
                        IF IGS_AD_VAL_ACAI.admp_val_aca_sca (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        v_appl_dt,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        new_references.fee_cat,
                                        new_references.correspondence_cat,
                                        new_references.enrolment_cat,
                                        v_offer_ind,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate transfer IGS_PS_COURSE code.
                --
                IF v_s_admission_process_type = cst_transfer AND
                                (NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1)) THEN
                        OPEN c_aca (
                                new_references.person_id,
                                new_references.admission_appl_number,
                                new_references.nominated_course_cd);
                        FETCH c_aca INTO v_transfer_course_cd;
                        CLOSE c_aca;
                        IF IGS_AD_VAL_ACA.admp_val_aca_trnsfr (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        v_transfer_course_cd,
                                        v_s_admission_process_type,
                                        v_check_course_encumb,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate the IGS_PS_COURSE offering pattern.
                --
                IF (NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_type, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1))THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_cop (
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_offer_ind,
                                        v_appl_dt,
                                        v_late_appl_allowed_ind,
                                        'N',    -- Deferred indicator.
                                        v_message_name,
                                        v_return_type,
                                        v_late_ind) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate the IGS_PS_COURSE offering options (IGS_AD_LOCATION, attendance mode + type).
                --
                IF new_references.location_cd IS NOT NULL OR
                                new_references.attendance_mode IS NOT NULL OR
                                new_references.attendance_type IS NOT NULL OR
                                ( NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_type, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1) )THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_opt (
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_offer_ind,
                                        v_appl_dt,
                                        v_late_appl_allowed_ind,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the IGS_PS_COURSE offering IGS_PS_UNIT set.
                --
                IF NVL(old_references.unit_set_cd, '-1') <> NVL(new_references.unit_set_cd, '-1') OR
                                NVL(old_references.us_version_number, -1) <> NVL(new_references.us_version_number, -1) OR
                                NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_type, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1)THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_us (
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        v_acad_cal_type,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        v_admission_cat,
                                        v_offer_ind,
                                        v_unit_set_appl_ind,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate IGS_PS_COURSE IGS_PS_UNIT set encumbrances.
                --
                IF v_check_course_encumb = 'Y' AND
                                NVL(old_references.unit_set_cd, '-1') <> NVL(new_references.unit_set_cd, '-1') OR
                                NVL(old_references.us_version_number, -1) <> NVL(new_references.us_version_number, -1) OR
                                (NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1))THEN
                        IF IGS_AD_VAL_ACAI.admp_val_us_encmb (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_check_course_encumb,
                                        v_offer_ind,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate the preference number.
                --
                IF NVL(old_references.preference_number, -1) <> NVL(new_references.preference_number, -1) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_pref (
                                        new_references.preference_number,
                                        v_pref_allowed_ind      ,
                                        v_pref_limit,
                                        v_s_admission_process_type,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- IGS_GE_NOTE: STATUS VALIDATIONS
                -- Only invoke status validations for the status value that is changing.
                -- Cross status validation checks are included in all status validations.
                --
                --
                -- Validate admission entry qualification status.
                --
                IF NVL(old_references.adm_entry_qual_status, '-1') <> new_references.adm_entry_qual_status THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aeqs (
                                        new_references.adm_entry_qual_status,
                                        new_references.adm_outcome_status,
                                        v_s_admission_process_type,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate admission documentation status.
                --
                IF NVL(old_references.adm_doc_status, '-1') <> new_references.adm_doc_status THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_ads (
                                        new_references.adm_doc_status,
                                        new_references.adm_outcome_status,
                                        new_references.adm_cndtnl_offer_status,
                                        v_s_admission_process_type,
                                        v_cond_offer_doc_allowed_ind,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate late admission fee status.
                --
                IF NVL(old_references.late_adm_fee_status, '-1') <> new_references.late_adm_fee_status OR
                                NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                NVL(new_references.adm_ci_sequence_number, -1) THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_lafs (
                                        new_references.late_adm_fee_status,
                                        v_late_appl_allowed_ind,
                                        v_late_fees_required_ind,
                                        v_cond_offer_fee_allowed_ind,
                                        v_appl_dt,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        v_acad_cal_type,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        new_references.adm_outcome_status,
                                        new_references.adm_cndtnl_offer_status,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate admission outcome status.
                --
                IF NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_type, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.unit_set_cd, '-1') <> NVL(new_references.unit_set_cd, '-1') OR
                                NVL(old_references.us_version_number, -1) <> NVL(new_references.us_version_number, -1) OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1) OR
                                (NVL(old_references.adm_outcome_status, '-1') <> new_references.adm_outcome_status AND
				NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), '-1') <> 'SUSPENDED' AND
				NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), '-1') <> 'WITHDRAWN') --nshee bug 2630217
				THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aos (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_appl_dt,
                                        new_references.fee_cat,
                                        new_references.correspondence_cat,
                                        new_references.enrolment_cat,
                                        new_references.adm_outcome_status,
                                        NVL(old_references.adm_outcome_status, IGS_AD_GEN_009.ADMP_GET_SYS_AOS('PENDING')),
                                        new_references.adm_doc_status,
                                        v_adm_fee_status,
                                        new_references.late_adm_fee_status,
                                        new_references.adm_cndtnl_offer_status,
                                        new_references.adm_entry_qual_status,
                                        new_references.adm_offer_resp_status,
                                        NVL(old_references.adm_offer_resp_status, IGS_AD_GEN_009.ADMP_GET_SYS_AORS('NOT-APPLIC')),
                                        new_references.adm_outcome_status_auth_dt,
                                        v_set_outcome_allowed_ind,
                                        v_cond_offer_ass_allowed_ind,
                                        v_cond_offer_fee_allowed_ind,
                                        v_cond_offer_doc_allowed_ind,
                                        v_late_appl_allowed_ind,
                                        v_fees_required_ind,
                                        v_mult_offer_allowed_ind,
                                        v_multi_offer_limit,
                                        v_pref_allowed_ind,
                                        v_unit_set_appl_ind,
                                        v_check_person_encumb,
                                        v_check_course_encumb,
                                        'TRG_BR',               -- Called From.
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                IF NVL(old_references.adm_outcome_status, '-1') <> new_references.adm_outcome_status THEN
                        -- Validate update of admission outcome status.
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_aos_update (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.adm_outcome_status,
                                        NVL(old_references.adm_outcome_status, IGS_AD_GEN_009.ADMP_GET_SYS_AOS('PENDING')),
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;


		---validate application instance status
		IF NVL(old_references.appl_inst_status, '-1') <> NVL(new_references.appl_inst_status,'-1') THEN			--arvsrini igsm

                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_ais (
					new_references.appl_inst_status,
					new_references.ais_reason ,
					new_references.adm_outcome_status,
					v_message_name)= FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;




                --
                -- Validate admission offer response status.
                --
                IF NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.adm_offer_resp_status, '-1') <> new_references.adm_offer_resp_status OR
                                NVL(TRUNC(old_references.actual_response_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                        NVL(new_references.actual_response_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aors (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.course_cd,
                                        new_references.adm_offer_resp_status,
                                        NVL(old_references.adm_offer_resp_status, IGS_AD_GEN_009.ADMP_GET_SYS_AORS('NOT-APPLIC')),
                                        new_references.adm_outcome_status,
                                        new_references.adm_offer_dfrmnt_status,
                                        NVL(old_references.adm_offer_dfrmnt_status, IGS_AD_GEN_009.ADMP_GET_SYS_AODS('NOT-APPLIC')),
                                        new_references.adm_outcome_status_auth_dt,
                                        new_references.actual_response_dt,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_deferral_allowed_ind,
                                        v_mult_offer_allowed_ind,
                                        v_multi_offer_limit,
                                        v_pre_enrol_ind,
                                        new_references.cndtnl_offer_must_be_stsfd_ind,
                                        new_references.cndtnl_offer_satisfied_dt,
                                        'TRG_BR',               -- Called From.
                                        v_message_name,
					new_references.decline_ofr_reason ,		-- IGSM
					new_references.attent_other_inst_cd		-- igsm
					) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate admission conditional offer.
                --
                IF NVL(old_references.adm_cndtnl_offer_status, '-1') <> new_references.adm_cndtnl_offer_status OR
                                NVL(old_references.adm_outcome_status, '-1') <> new_references.adm_outcome_status THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_acos (
                                        new_references.adm_cndtnl_offer_status,
                                        NVL(old_references.adm_cndtnl_offer_status, IGS_AD_GEN_009.ADMP_GET_SYS_ACOS('NOT-APPLIC')),
                                        new_references.adm_outcome_status,
                                        new_references.adm_outcome_status,
                                        new_references.late_adm_fee_status,
                                        v_adm_fee_status,
                                        v_late_appl_allowed_ind,
                                        v_fees_required_ind,
                                        v_cond_offer_ass_allowed_ind,
                                        v_cond_offer_fee_allowed_ind,
                                        v_cond_offer_doc_allowed_ind,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate admission offer deferment status.
                --
                IF NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.adm_offer_dfrmnt_status, '-1') <> new_references.adm_offer_dfrmnt_status THEN
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aods (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.course_cd,
                                        new_references.adm_offer_dfrmnt_status,
                                        NVL(old_references.adm_offer_dfrmnt_status, IGS_AD_GEN_009.ADMP_GET_SYS_AODS('NOT-APPLIC')),
                                        new_references.adm_offer_resp_status,
                                        v_deferral_allowed_ind,
                                        v_s_admission_process_type,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate offer date.
                --
                IF (NVL(TRUNC(old_references.offer_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                        NVL(new_references.offer_dt, IGS_GE_DATE.IGSDATE('1900/01/01')) OR
                                NVL(old_references.adm_outcome_status, '-1') <> new_references.adm_outcome_status OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1)) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_offer_dt (
                                        new_references.offer_dt,
                                        new_references.adm_outcome_status,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate offer response date.
                --
                IF (NVL(TRUNC(old_references.offer_response_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                        NVL(new_references.offer_response_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
                                (NVL(old_references.adm_outcome_status, '-1') <> new_references.adm_outcome_status) OR
                                (NVL(TRUNC(old_references.offer_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                        NVL(new_references.offer_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_off_resp_dt (
                                        new_references.offer_response_dt,
                                        new_references.adm_outcome_status,
                                        new_references.offer_dt,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate proposed commencement date.
                --
                IF (NVL(TRUNC(old_references.prpsd_commencement_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                        NVL(new_references.prpsd_commencement_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) THEN
                        IF IGS_RE_VAL_CA.admp_val_acai_comm (
                                        new_references.person_id,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        new_references.adm_outcome_status,
                                        new_references.prpsd_commencement_dt,
                                        NULL,   -- Minimum submission date.
                                        v_ca_sequence_number,
                                        'ACAI', -- Parent.
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate actual response date.
                --
                IF (NVL(TRUNC(old_references.actual_response_dt), IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                        NVL(new_references.actual_response_dt, IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
                                (NVL(old_references.adm_offer_resp_status, '-1') <> new_references.adm_offer_resp_status) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_act_resp_dt (
                                        new_references.actual_response_dt,
                                        new_references.adm_offer_resp_status,
                                        new_references.offer_dt,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate conditional offer satisfied date.
                --
                IF (NVL(TRUNC(old_references.cndtnl_offer_satisfied_dt),
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                                NVL(new_references.cndtnl_offer_satisfied_dt,
                                                        IGS_GE_DATE.IGSDATE('1900/01/01'))) OR
                                (NVL(old_references.adm_cndtnl_offer_status, '-1') <>
                                                new_references.adm_cndtnl_offer_status) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_stsfd_dt (
                                        new_references.cndtnl_offer_satisfied_dt,
                                        new_references.adm_cndtnl_offer_status,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate acceptance condition.
                --
                IF new_references.applicant_acptnce_cndtn IS NOT NULL AND
                                (NVL(old_references.applicant_acptnce_cndtn, '-1') <> new_references.applicant_acptnce_cndtn OR
                                NVL(old_references.adm_offer_resp_status, '-1') <>
                                                new_references.adm_offer_resp_status) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acpt_cndtn (
                                        new_references.applicant_acptnce_cndtn,
                                        new_references.adm_offer_resp_status,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate conditional offer condition.
                --
                IF new_references.cndtnl_offer_cndtn IS NOT NULL AND
                                (NVL(old_references.cndtnl_offer_cndtn, '-1') <> new_references.cndtnl_offer_cndtn OR
                                NVL(old_references.adm_cndtnl_offer_status, '-1') <>
                                                new_references.adm_cndtnl_offer_status) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_offer_cndtn (
                                        new_references.cndtnl_offer_cndtn,
                                        new_references.adm_cndtnl_offer_status,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate conditional offer must be satisfied indicator.
                --
                IF NVL(old_references.cndtnl_offer_must_be_stsfd_ind, '-') <>
                                        NVL(new_references.cndtnl_offer_must_be_stsfd_ind, '-') OR
                                NVL(old_references.adm_cndtnl_offer_status, '-1') <>
                                                new_references.adm_cndtnl_offer_status THEN
                        IF IGS_AD_VAL_ACAI.admp_val_must_stsfd (
                                        new_references.cndtnl_offer_must_be_stsfd_ind,
                                        new_references.adm_cndtnl_offer_status,
                                        new_references.adm_offer_resp_status,
                                        new_references.cndtnl_offer_satisfied_dt,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the fee category.
                --
                IF (new_references.fee_cat IS NOT NULL AND
                                (NVL(old_references.fee_cat, '-1') <> new_references.fee_cat)) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_fc (
                                        v_admission_cat,
                                        new_references.fee_cat,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the HECS payment option.
                --
                IF (new_references.hecs_payment_option IS NOT NULL AND
                                (NVL(old_references.hecs_payment_option, '-1') <> new_references.hecs_payment_option)) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_hpo (
                                        v_admission_cat,
                                        new_references.hecs_payment_option,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the correspondence category.
                --
                IF (new_references.correspondence_cat IS NOT NULL AND
                                (NVL(old_references.correspondence_cat, '-1') <> new_references.correspondence_cat)) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_cc (
                                        v_admission_cat,
                                        new_references.correspondence_cat,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the enrolment category.
                --
                IF (new_references.enrolment_cat IS NOT NULL AND
                                (NVL(old_references.enrolment_cat, '-1') <> new_references.enrolment_cat)) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_ec (
                                        v_admission_cat,
                                        new_references.enrolment_cat,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the funding source.
                --
                IF (new_references.funding_source IS NOT NULL AND
                                (NVL(old_references.funding_source, '-1') <> new_references.funding_source)) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_acai_fs (
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        new_references.funding_source,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the expected completion details.
                --
                IF (NVL(old_references.expected_completion_yr, -1) <>
                                        NVL(new_references.expected_completion_yr, -1)) OR
                                (NVL(old_references.expected_completion_perd, '-') <>
                                        NVL(new_references.expected_completion_perd, '-')) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_expctd_comp (
                                        new_references.expected_completion_yr,
                                        new_references.expected_completion_perd,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the deferment calendar.
                --
                IF ( NVL(old_references.deferred_adm_cal_type, '-1') <>
                                NVL(new_references.deferred_adm_cal_type,'-1') OR
                                NVL(old_references.deferred_adm_ci_sequence_num, -1) <>
                                NVL(new_references.deferred_adm_ci_sequence_num, -1) OR
                                NVL(old_references.adm_offer_resp_status, '-1') <> new_references.adm_offer_resp_status OR
                                NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_type, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.unit_set_cd, '-1') <> NVL(new_references.unit_set_cd, '-1') OR
                                NVL(old_references.us_version_number, -1) <> NVL(new_references.us_version_number, -1) ) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_dfrmnt_cal (
                                        new_references.deferred_adm_cal_type,
                                        new_references.deferred_adm_ci_sequence_num,
                                        new_references.def_acad_cal_type,
                                        new_references.adm_offer_resp_status,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_appl_dt,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        v_deferral_allowed_ind,
                                        v_late_appl_allowed_ind,
                                        v_message_name,
                                        v_return_type,
					new_references.def_acad_ci_sequence_num   --added the parameter as the signature of the function is changed (rghosh-bug#2765260)
					) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                --
                -- Validate the Outcome Status Authorising Date.
                --
                IF NVL(TRUNC(old_references.adm_outcome_status_auth_dt),
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                NVL(new_references.adm_outcome_status_auth_dt,
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_ovrd_dt (
                                        new_references.adm_outcome_status_auth_dt,
                                        v_override_outcome_allowed_ind,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the Outcome Status Authorising IGS_PE_PERSON ID.
                --
                IF NVL(old_references.adm_otcm_status_auth_person_id, -1) <>
                                NVL(new_references.adm_otcm_status_auth_person_id, -1) OR
                                NVL(TRUNC(old_references.adm_outcome_status_auth_dt),
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                NVL(new_references.adm_outcome_status_auth_dt,
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_ovrd_person (
                                        new_references.adm_otcm_status_auth_person_id,
                                        new_references.adm_outcome_status_auth_dt,
                                        v_override_outcome_allowed_ind,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Validate the Outcome Status Override Reason.
                --
                IF NVL(old_references.adm_outcome_status_reason, '-1') <>
                                NVL(new_references.adm_outcome_status_reason, '-1') OR
                                NVL(TRUNC(old_references.adm_outcome_status_auth_dt),
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) <>
                                NVL(new_references.adm_outcome_status_auth_dt,
                                        IGS_GE_DATE.IGSDATE('1900/01/01')) THEN
                        IF IGS_AD_VAL_ACAI.admp_val_ovrd_reason (
                                        new_references.adm_outcome_status_reason,
                                        new_references.adm_outcome_status_auth_dt,
                                        v_override_outcome_allowed_ind,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
        END IF; -- p_inserting or p_updating
        IF NVL(p_deleting,FALSE) THEN

		-- Validate delete of the admission IGS_PS_COURSE application instance record.
                IF IGS_AD_VAL_ACAI.admp_val_acai_delete (
                                old_references.person_id,
                                old_references.admission_appl_number,
                                old_references.adm_outcome_status,
                                v_message_name,
                                v_return_type) = FALSE THEN
                        IF NVL(v_return_type, '-1') = cst_error THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                --
                -- Get admission application details required for validation.
                --
                IGS_AD_GEN_002.ADMP_GET_AA_DTL(
                        old_references.person_id,
                        old_references.admission_appl_number,
                        v_admission_cat,
                        v_s_admission_process_type,
                        v_acad_cal_type,
                        v_aa_acad_ci_sequence_number,
                        v_aa_adm_cal_type,
                        v_aa_adm_ci_sequence_number,
                        v_appl_dt,
                        v_adm_appl_status,
                        v_adm_fee_status);
                --
                -- Determine the Academic and Admission period for validation.
                --
                IF new_references.adm_cal_type IS NULL THEN
                        v_acad_ci_sequence_number := v_aa_acad_ci_sequence_number;
                        v_adm_cal_type := v_aa_adm_cal_type;
                        v_adm_ci_sequence_number := v_aa_adm_ci_sequence_number;
                ELSE
                        v_acad_ci_sequence_number := IGS_CA_GEN_001.CALP_GET_SUP_INST (
                                                        v_acad_cal_type,
                                                        new_references.adm_cal_type,
                                                        new_references.adm_ci_sequence_number);
                        v_adm_cal_type := new_references.adm_cal_type;
                        v_adm_ci_sequence_number := new_references.adm_ci_sequence_number;
                END IF;
                --
                -- Determine the admission process category steps.
                --
                FOR v_apcs_rec IN c_apcs (
                                v_admission_cat,
                                v_s_admission_process_type)
                LOOP
                        IF v_apcs_rec.s_admission_step_type = 'PREF-LIMIT' THEN
                                v_pref_allowed_ind := 'Y';
                                v_pref_limit := v_apcs_rec.step_type_restriction_num;
                        END IF;
                END LOOP;
                -- Validate delete of a preference.
                IF v_pref_allowed_ind = 'Y' THEN
                        IF IGS_AD_VAL_ACAI.admp_val_chg_of_pref (
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        old_references.course_cd,
                                        old_references.crv_version_number,
                                        v_acad_cal_type,
                                        old_references.location_cd,
                                        old_references.attendance_mode,
                                        old_references.attendance_type,
                                        v_message_name) = FALSE THEN
                                FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                END IF;
                FOR c_pti_rec IN c_pti (
                                        old_references.person_id,
                                        old_references.admission_appl_number,
                                        old_references.nominated_course_cd,
                                        old_references.sequence_number)
                LOOP
                  igs_pe_typ_instances_pkg.delete_row(x_rowid => c_pti_rec.row_id);
                END LOOP;
        END IF; -- p_deleting
  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsert1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
    CURSOR c_pti (cp_person_id igs_pe_person.person_id%TYPE) IS
      SELECT pti.rowid row_id,pti.*, lv.lookup_code lv_end_method
      FROM   igs_pe_typ_instances_all pti,
             igs_pe_person_types ppt,
             igs_lookup_values lv
      WHERE  pti.person_id = cp_person_id
      AND    ppt.person_type_code = pti.person_type_code
      AND    ppt.system_type = 'PROSPECT'
      AND    pti.end_date IS NULL
      AND    lv.lookup_type = 'PERSON_TYPE_END_METHOD'
      AND    lv.lookup_code = 'CREATE_APPLICANT'
      AND    lv.closed_ind = 'N';

  BEGIN
    IF  NVL(p_inserting,FALSE) THEN
      FOR c_pti_rec IN c_pti (new_references.person_id)
      LOOP
        Igs_Pe_Typ_Instances_Pkg.Update_Row (
          X_Mode                              => 'R',
          X_RowId                             => c_pti_rec.Row_Id,
          X_Type_Instance_Id                  => c_pti_rec.Type_Instance_Id,
          X_Person_Type_Code                  => c_pti_rec.Person_Type_Code,
          X_Person_Id                         => c_pti_rec.Person_Id,
          X_Course_Cd                         => c_pti_rec.Course_Cd,
          X_CC_Version_Number                 => c_pti_rec.CC_Version_Number,
          X_Funnel_Status                     => c_pti_rec.Funnel_Status,
          X_Admission_Appl_Number             => c_pti_rec.Admission_Appl_Number,
          X_Nominated_Course_Cd               => c_pti_rec.Nominated_Course_Cd,
          X_NCC_Version_Number                => c_pti_rec.NCC_Version_Number,
          X_Sequence_Number                   => c_pti_rec.Sequence_Number,
          X_Start_Date                        => c_pti_rec.Start_Date,
          X_End_Date                          => TRUNC(SYSDATE),
          X_Create_Method                     => c_pti_rec.Create_Method,
          X_Ended_By                          => fnd_global.user_id,
          X_End_Method                        => c_pti_rec.lv_end_method,
          X_Emplmnt_Category_code             => c_pti_rec.emplmnt_category_code
        );
      END LOOP;
    END IF;
  END AfterRowInsert1;

  PROCEDURE AfterRowUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
    CURSOR c_pti (cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                  cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                  cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                  cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE) IS
      SELECT pti.rowid row_id,pti.*
      FROM   igs_pe_typ_instances_all pti,
             igs_pe_person_types ppt
      WHERE  pti.person_id = cp_person_id
      AND    pti.admission_appl_number = cp_admission_appl_number
      AND    pti.nominated_course_cd = cp_nominated_course_cd
      AND    pti.sequence_number = cp_sequence_number
      AND    ppt.person_type_code = pti.person_type_code
      AND    ppt.system_type = 'APPLICANT'
      AND    pti.end_date IS NULL;

CURSOR c_ptyp_inst (cp_person_id igs_ad_ps_appl_inst.person_id%TYPE,
                    cp_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                    cp_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
                    cp_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE,
		    cp_end_method igs_lookup_values.lookup_code%TYPE) IS
      SELECT pti.rowid row_id,pti.*
      FROM   igs_pe_typ_instances_all pti,
             igs_pe_person_types ppt
      WHERE  pti.person_id = cp_person_id
      AND    pti.admission_appl_number = cp_admission_appl_number
      AND    pti.nominated_course_cd = cp_nominated_course_cd
      AND    pti.sequence_number = cp_sequence_number
      AND    ppt.person_type_code = pti.person_type_code
      AND    ppt.system_type = 'APPLICANT'
      AND    pti.end_date IS NOT NULL
      AND    pti.End_Method = cp_end_method ;


CURSOR c_per_end_type
     IS
      SELECT lv.lookup_code
      FROM   igs_lookup_values lv
      WHERE  lv.lookup_type = 'PERSON_TYPE_END_METHOD'
      AND    lv.lookup_code = 'DELETE_APPLICATION'
      AND    lv.closed_ind = 'N';

lv_end_method  igs_lookup_values.lookup_code%TYPE;

  BEGIN

    OPEN c_per_end_type;
    FETCH c_per_end_type INTO lv_end_method;
    CLOSE c_per_end_type;

    IF NVL(p_updating,FALSE) THEN
      IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') = 'CANCELLED' THEN
        FOR c_pti_rec IN c_pti (new_references.person_id,
                                new_references.admission_appl_number,
                                new_references.nominated_course_cd,
                                new_references.sequence_number)
        LOOP
          Igs_Pe_Typ_Instances_Pkg.Update_Row (
            X_Mode                              => 'R',
            X_RowId                             => c_pti_rec.Row_Id,
            X_Type_Instance_Id                  => c_pti_rec.Type_Instance_Id,
            X_Person_Type_Code                  => c_pti_rec.Person_Type_Code,
            X_Person_Id                         => c_pti_rec.Person_Id,
            X_Course_Cd                         => c_pti_rec.Course_Cd,
            X_CC_Version_Number                 => c_pti_rec.CC_Version_Number,
            X_Funnel_Status                     => c_pti_rec.Funnel_Status,
            X_Admission_Appl_Number             => c_pti_rec.Admission_Appl_Number,
            X_Nominated_Course_Cd               => c_pti_rec.Nominated_Course_Cd,
            X_NCC_Version_Number                => c_pti_rec.NCC_Version_Number,
            X_Sequence_Number                   => c_pti_rec.Sequence_Number,
            X_Start_Date                        => c_pti_rec.Start_Date,
            X_End_Date                          => TRUNC(SYSDATE),
            X_Create_Method                     => c_pti_rec.Create_Method,
            X_Ended_By                          => fnd_global.user_id,
            X_End_Method                        => lv_end_method,
            X_Emplmnt_Category_code             => c_pti_rec.emplmnt_category_code
          );
        END LOOP;
      END IF;

--begin  apadegal adtd001 igs.m
      -- added this, to reverse the above process.
       IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(old_references.adm_outcome_status), 'NONE') = 'CANCELLED'  AND
          NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') <> 'CANCELLED'
       THEN
	  FOR c_ptyp_inst_rec IN c_ptyp_inst (  new_references.person_id,
						new_references.admission_appl_number,
						new_references.nominated_course_cd,
						new_references.sequence_number,
						lv_end_method)
        LOOP
          Igs_Pe_Typ_Instances_Pkg.Update_Row (
            X_Mode                              => 'R',
            X_RowId                             => c_ptyp_inst_rec.Row_Id,
            X_Type_Instance_Id                  => c_ptyp_inst_rec.Type_Instance_Id,
            X_Person_Type_Code                  => c_ptyp_inst_rec.Person_Type_Code,
            X_Person_Id                         => c_ptyp_inst_rec.Person_Id,
            X_Course_Cd                         => c_ptyp_inst_rec.Course_Cd,
            X_CC_Version_Number                 => c_ptyp_inst_rec.CC_Version_Number,
            X_Funnel_Status                     => c_ptyp_inst_rec.Funnel_Status,
            X_Admission_Appl_Number             => c_ptyp_inst_rec.Admission_Appl_Number,
            X_Nominated_Course_Cd               => c_ptyp_inst_rec.Nominated_Course_Cd,
            X_NCC_Version_Number                => c_ptyp_inst_rec.NCC_Version_Number,
            X_Sequence_Number                   => c_ptyp_inst_rec.Sequence_Number,
            X_Start_Date                        => c_ptyp_inst_rec.Start_Date,
            X_End_Date                          => NULL,
            X_Create_Method                     => c_ptyp_inst_rec.Create_Method,
            X_Ended_By                          => NULL,
            X_End_Method                        => NULL,
            X_Emplmnt_Category_code             => c_ptyp_inst_rec.emplmnt_category_code
          );
        END LOOP;
       END IF;
--end  apadegal adtd001 igs.m
    END IF;
  END AfterRowUpdate1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) IS
        CURSOR c_apcs (
                cp_admission_cat                IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
                cp_s_admission_process_type
                                        IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT  s_admission_step_type,
                step_type_restriction_num
        FROM    IGS_AD_PRCS_CAT_STEP
        WHERE   admission_cat = cp_admission_cat AND
                s_admission_process_type = cp_s_admission_process_type AND
                step_group_type <> 'TRACK'; --2402377
  v_row_validated  boolean := FALSE;  -- added as a part of VAW008 to handle mutation
  v_message_name                        VARCHAR2(30);
  v_cond_offer_doc_allowed_ind  VARCHAR2(1)     ;
  v_cond_offer_fee_allowed_ind  VARCHAR2(1)     ;
  v_cond_offer_ass_allowed_ind  VARCHAR2(1)     ;
  v_admission_cat                       IGS_AD_APPL.admission_cat%TYPE;
  v_s_admission_process_type    IGS_AD_APPL.s_admission_process_type%TYPE;
  v_acad_ci_sequence_number     IGS_AD_APPL.acad_ci_sequence_number%TYPE;
  v_adm_cal_type                        IGS_AD_APPL.adm_cal_type%TYPE;
  v_adm_ci_sequence_number      IGS_AD_APPL.adm_ci_sequence_number%TYPE;
  v_acad_cal_type                       IGS_AD_APPL.acad_cal_type%TYPE;
  v_aa_acad_ci_sequence_number  IGS_AD_APPL.acad_ci_sequence_number%TYPE;
  v_aa_adm_cal_type             IGS_AD_APPL.adm_cal_type%TYPE;
  v_aa_adm_ci_sequence_number   IGS_AD_APPL.adm_ci_sequence_number%TYPE;
  v_pref_allowed_ind            VARCHAR2(1)    ;
  v_pref_limit                  NUMBER;
  v_appl_dt                             IGS_AD_APPL.appl_dt%TYPE;
  v_set_outcome_allowed_ind     VARCHAR2(1)     ;
  v_late_appl_allowed_ind       VARCHAR2(1)     ;
  v_fees_required_ind           VARCHAR2(1)     ;
  v_deferral_allowed_ind        VARCHAR2(1)     ;
  v_pre_enrol_ind                       VARCHAR2(1)     ;
  v_mult_offer_allowed_ind      VARCHAR2(1)     ;
  v_multi_offer_limit           NUMBER;
  v_unit_set_appl_ind           VARCHAR2(1)     ;
  v_check_person_encumb         VARCHAR2(1)     ;
  v_adm_appl_status             IGS_AD_APPL.adm_appl_status%TYPE;
  v_check_course_encumb         VARCHAR2(1)     ;
  v_adm_fee_status              IGS_AD_APPL.adm_fee_status%TYPE;
  v_return_type                 VARCHAR2(1);
  cst_error                             CONSTANT        VARCHAR2(1):= 'E';
  v_person_id                   IGS_AD_APPL.person_id%TYPE;
  v_admission_appl_number           IGS_AD_APPL.admission_appl_number%TYPE;
  v_derived_adm_appl_status         IGS_AD_APPL.adm_appl_status%TYPE;

  -- added this cursor here to get the old outcome status from the database
  -- by rrengara on 10-apr-2002 for bug no 2298840
  CURSOR c_adm_appl_status (cp_person_id igs_ad_appl.person_id%TYPE,
                              cp_admission_appl_number igs_ad_appl.admission_appl_number%TYPE) IS
      SELECT adm_appl_status
      FROM igs_ad_appl
      WHERE person_id = cp_person_id
      AND   admission_appl_number= cp_admission_appl_number;

  BEGIN
      v_check_course_encumb         := 'N';
      v_unit_set_appl_ind           := 'N';
      v_check_person_encumb         := 'N';
      v_set_outcome_allowed_ind     := 'N';
      v_late_appl_allowed_ind       := 'N';
      v_fees_required_ind           := 'N';
      v_deferral_allowed_ind        := 'N';
      v_pre_enrol_ind               := 'N';
      v_mult_offer_allowed_ind      := 'N';
      v_pref_allowed_ind            := 'N';
      v_cond_offer_doc_allowed_ind  := 'N';
      v_cond_offer_fee_allowed_ind  := 'N';
      v_cond_offer_ass_allowed_ind  := 'N';
        IF  NVL(p_inserting,FALSE) THEN
                -- Save the rowid of the current row.
            v_row_validated := TRUE;
        END IF;
        IF NVL(p_updating,FALSE) THEN
                -- Check if after statement needs to be performed.
                IF NVL(old_references.course_cd, '-1') <> new_references.course_cd OR
                                NVL(old_references.crv_version_number, -1) <> new_references.crv_version_number OR
                                NVL(old_references.location_cd, '-1') <> NVL(new_references.location_cd, '-1') OR
                                NVL(old_references.attendance_mode, '-1') <> NVL(new_references.attendance_mode, '-1') OR
                                NVL(old_references.attendance_type, '-1') <> NVL(new_references.attendance_type, '-1') OR
                                NVL(old_references.unit_set_cd, '-1') <> NVL(new_references.unit_set_cd, '-1') OR
                                NVL(old_references.us_version_number, -1) <> NVL(new_references.us_version_number, -1) OR
                                NVL(old_references.adm_cal_type, '-1') <> NVL(new_references.adm_cal_type, '-1') OR
                                NVL(old_references.adm_ci_sequence_number, -1) <>
                                        NVL(new_references.adm_ci_sequence_number, -1) OR
                                NVL(old_references.adm_outcome_status, '-1') <> new_references.adm_outcome_status THEN
                        -- Save the rowid of the current row.
                        v_row_validated := TRUE;
                END IF;
        END IF;
      IF  v_row_validated = TRUE THEN
                IF NVL(p_inserting,FALSE) OR NVL(p_updating,FALSE) THEN
                        --
                        -- Get admission application details required for validation.
                        --
                        IGS_AD_GEN_002.ADMP_GET_AA_DTL(
                                new_references.person_id,
                                new_references.admission_appl_number,
                                v_admission_cat,
                                v_s_admission_process_type,
                                v_acad_cal_type,
                                v_aa_acad_ci_sequence_number,
                                v_aa_adm_cal_type,
                                v_aa_adm_ci_sequence_number,
                                v_appl_dt,
                                v_adm_appl_status,
                                v_adm_fee_status);
                        --
                        -- Determine the Academic and Admission period for validation.
                        --
                        IF new_references.adm_cal_type IS NULL THEN
                                v_acad_ci_sequence_number := v_aa_acad_ci_sequence_number;
                                v_adm_cal_type := v_aa_adm_cal_type;
                                v_adm_ci_sequence_number := v_aa_adm_ci_sequence_number;
                        ELSE
                                v_acad_ci_sequence_number := IGS_CA_GEN_001.CALP_GET_SUP_INST (
                                                                v_acad_cal_type,
                                                                new_references.adm_cal_type,
                                                                new_references.adm_ci_sequence_number);
                                v_adm_cal_type := new_references.adm_cal_type;
                                v_adm_ci_sequence_number := new_references.adm_ci_sequence_number;
                        END IF;
                        --
                        -- Determine the admission process category steps.
                        --
                        FOR v_apcs_rec IN c_apcs (
                                        v_admission_cat,
                                        v_s_admission_process_type)
                        LOOP
                                IF v_apcs_rec.s_admission_step_type = 'PREF-LIMIT' THEN
                                        v_pref_allowed_ind := 'Y';
                                        v_pref_limit := v_apcs_rec.step_type_restriction_num;
                                ELSIF v_apcs_rec.s_admission_step_type = 'DOC-COND' THEN
                                        v_cond_offer_doc_allowed_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'FEE-COND' THEN
                                        v_cond_offer_fee_allowed_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'ASSES-COND' THEN
                                        v_cond_offer_ass_allowed_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'SET-OTCOME' THEN
                                        v_set_outcome_allowed_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
                                        v_late_appl_allowed_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'APP-FEE' THEN
                                        v_fees_required_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'DEFER' THEN
                                        v_deferral_allowed_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'PRE-ENROL' THEN
                                        v_pre_enrol_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'MULTI-OFF' THEN
                                        v_mult_offer_allowed_ind := 'Y';
                                        v_multi_offer_limit := v_apcs_rec.step_type_restriction_num;
                                ELSIF v_apcs_rec.s_admission_step_type = 'UNIT-SET' THEN
                                        v_unit_set_appl_ind := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'CHKPENCUMB' THEN
                                        v_check_person_encumb := 'Y';
                                ELSIF v_apcs_rec.s_admission_step_type = 'CHKCENCUMB' THEN
                                        v_check_course_encumb := 'Y';
                                END IF;
                        END LOOP;
                END IF;
		-- Bug no 2462198 (D) 2566987 (P) do the validation of duplicate while doing the update also
		 -- by rrengara on 13-SEP-2002
                IF      NVL(p_inserting,FALSE) THEN
		        --Should be called only in case of an insert
                        -- Validate insert of admission course application instance.
                        IF IGS_AD_VAL_ACAI.admp_val_acai_insert (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.course_cd,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_s_admission_process_type,
                                        v_pref_limit,
                                        FALSE,  -- Validate AA Only
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                   FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                   IGS_GE_MSG_STACK.ADD;
                                   APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
                IF      NVL(p_inserting,FALSE) OR NVL(p_updating,FALSE) THEN
                        --
                        -- Validate admission outcome status.
                        --
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aos (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.course_cd,
                                        new_references.crv_version_number,
                                        new_references.location_cd,
                                        new_references.attendance_mode,
                                        new_references.attendance_type,
                                        new_references.unit_set_cd,
                                        new_references.us_version_number,
                                        v_acad_cal_type,
                                        v_acad_ci_sequence_number,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_appl_dt,
                                        new_references.fee_cat,
                                        new_references.correspondence_cat,
                                        new_references.enrolment_cat,
                                        new_references.adm_outcome_status,
                                        new_references.adm_outcome_status,              -- Old
                                        new_references.adm_doc_status,
                                        v_adm_fee_status,
                                        new_references.late_adm_fee_status,
                                        new_references.adm_cndtnl_offer_status,
                                        new_references.adm_entry_qual_status,
                                        new_references.adm_offer_resp_status,
                                        new_references.adm_offer_resp_status,   -- Old
                                        new_references.adm_outcome_status_auth_dt,
                                        v_set_outcome_allowed_ind,
                                        v_cond_offer_ass_allowed_ind,
                                        v_cond_offer_fee_allowed_ind,
                                        v_cond_offer_doc_allowed_ind,
                                        v_late_appl_allowed_ind,
                                        v_fees_required_ind,
                                        v_mult_offer_allowed_ind,
                                        v_multi_offer_limit,
                                        v_pref_allowed_ind,
                                        v_unit_set_appl_ind,
                                        v_check_person_encumb,
                                        v_check_course_encumb,
                                        'TRG_AS',               -- Called From.
                                        v_message_name) = FALSE THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                        --
                        -- Validate admission offer response status.
                        --
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aors (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.course_cd,
                                        new_references.adm_offer_resp_status,
                                        new_references.adm_offer_resp_status,   -- Old
                                        new_references.adm_outcome_status,
                                        new_references.adm_offer_dfrmnt_status,
                                        new_references.adm_offer_dfrmnt_status, -- Old
                                        new_references.adm_outcome_status_auth_dt,
                                        new_references.actual_response_dt,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_deferral_allowed_ind,
                                        v_mult_offer_allowed_ind,
                                        v_multi_offer_limit,
                                        v_pre_enrol_ind,
                                        new_references.cndtnl_offer_must_be_stsfd_ind,
                                        new_references.cndtnl_offer_satisfied_dt,
                                        'TRG_AS',               -- Called From.
                                        v_message_name,
					new_references.decline_ofr_reason ,		-- IGSM
					new_references.attent_other_inst_cd		-- igsm
					) = FALSE THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                        END IF;
                        --
                        -- Validate multiple offers across admission process categories.
                        --
                        IF IGS_AD_VAL_ACAI_STATUS.admp_val_offer_x_apc (
                                        new_references.person_id,
                                        new_references.admission_appl_number,
                                        new_references.nominated_course_cd,
                                        new_references.sequence_number,
                                        new_references.adm_outcome_status,
                                        new_references.adm_offer_resp_status,
                                        v_adm_cal_type,
                                        v_adm_ci_sequence_number,
                                        v_admission_cat,
                                        v_s_admission_process_type,
                                        v_message_name,
                                        v_return_type) = FALSE THEN
                                IF NVL(v_return_type, '-1') = cst_error THEN
                                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                                        IGS_GE_MSG_STACK.ADD;
                                        APP_EXCEPTION.RAISE_EXCEPTION;
                                END IF;
                        END IF;
                END IF;
        END IF; -- v_row_validated
  END AfterRowInsertUpdate2;

  PROCEDURE AfterRowUpdateDelete3(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) IS
        v_message_name                  VARCHAR2(30);
  v_person_id                   IGS_AD_APPL.person_id%TYPE;
  v_admission_appl_number           IGS_AD_APPL.admission_appl_number%TYPE;
  v_derived_adm_appl_status         IGS_AD_APPL.adm_appl_status%TYPE;
  v_adm_appl_status             IGS_AD_APPL.adm_appl_status%TYPE;
        CURSOR c_aa (
                cp_person_id            IGS_AD_PS_APPL.person_id%TYPE,
                cp_admission_appl_number        IGS_AD_PS_APPL.admission_appl_number%TYPE) IS
        SELECT  adm_appl_status
        FROM    IGS_AD_APPL
        WHERE   person_id = cp_person_id AND
                admission_appl_number = cp_admission_appl_number;
  BEGIN
        IF NVL(p_updating,FALSE) THEN
                -- Create admission IGS_PS_COURSE application instance history record.

                IGS_AD_GEN_011.ADMP_INS_ACAI_HIST (
                        new_references.person_id,
                        new_references.admission_appl_number,
                        new_references.nominated_course_cd,
                        new_references.sequence_number,
                        new_references.adm_cal_type,
                        old_references.adm_cal_type,
                        new_references.adm_ci_sequence_number,
                        old_references.adm_ci_sequence_number,
                        new_references.course_cd,
                        old_references.course_cd,
                        new_references.crv_version_number,
                        old_references.crv_version_number,
                        new_references.location_cd,
                        old_references.location_cd,
                        new_references.attendance_mode,
                        old_references.attendance_mode,
                        new_references.attendance_type,
                        old_references.attendance_type,
                        new_references.unit_set_cd,
                        old_references.unit_set_cd,
                        new_references.us_version_number,
                        old_references.us_version_number,
                        new_references.preference_number,
                        old_references.preference_number,
                        new_references.adm_doc_status,
                        old_references.adm_doc_status,
                        new_references.adm_entry_qual_status,
                        old_references.adm_entry_qual_status,
                        new_references.late_adm_fee_status,
                        old_references.late_adm_fee_status,
                        new_references.adm_outcome_status,
                        old_references.adm_outcome_status,
                        new_references.adm_otcm_status_auth_person_id,
                        old_references.adm_otcm_status_auth_person_id,
                        new_references.adm_outcome_status_auth_dt,
                        TRUNC(old_references.adm_outcome_status_auth_dt),
                        new_references.adm_outcome_status_reason,
                        old_references.adm_outcome_status_reason,
                        new_references.offer_dt,
                        TRUNC(old_references.offer_dt),
                        new_references.offer_response_dt,
                        TRUNC(old_references.offer_response_dt),
                        new_references.prpsd_commencement_dt,
                        TRUNC(old_references.prpsd_commencement_dt),
                        new_references.adm_cndtnl_offer_status,
                        old_references.adm_cndtnl_offer_status,
                        new_references.cndtnl_offer_satisfied_dt,
                        TRUNC(old_references.cndtnl_offer_satisfied_dt),
                        new_references.cndtnl_offer_must_be_stsfd_ind,
                        old_references.cndtnl_offer_must_be_stsfd_ind,
                        new_references.adm_offer_resp_status,
                        old_references.adm_offer_resp_status,
                        new_references.actual_response_dt,
                        TRUNC(old_references.actual_response_dt),
                        new_references.adm_offer_dfrmnt_status,
                        old_references.adm_offer_dfrmnt_status,
                        new_references.deferred_adm_cal_type,
                        old_references.deferred_adm_cal_type,
                        new_references.deferred_adm_ci_sequence_num,
                        old_references.deferred_adm_ci_sequence_num,
                        new_references.deferred_tracking_id,
                        old_references.deferred_tracking_id,
                        new_references.ass_rank,
                        old_references.ass_rank,
                        new_references.secondary_ass_rank,
                        old_references.secondary_ass_rank,
                        new_references.intrntnl_acceptance_advice_num,
                        old_references.intrntnl_acceptance_advice_num,
                        new_references.ass_tracking_id,
                        old_references.ass_tracking_id,
                        new_references.fee_cat,
                        old_references.fee_cat,
                        new_references.hecs_payment_option,
                        old_references.hecs_payment_option,
                        new_references.expected_completion_yr,
                        old_references.expected_completion_yr,
                        new_references.expected_completion_perd,
                        old_references.expected_completion_perd,
                        new_references.correspondence_cat,
                        old_references.correspondence_cat,
                        new_references.enrolment_cat,
                        old_references.enrolment_cat,
                        new_references.funding_source,
                        old_references.funding_source,
                        new_references.last_updated_by,
                        old_references.last_updated_by,
                        new_references.last_update_date,
                        old_references.last_update_date,
                        new_references.applicant_acptnce_cndtn,
                        old_references.applicant_acptnce_cndtn,
                        new_references.cndtnl_offer_cndtn,
                        old_references.cndtnl_offer_cndtn,
			new_references.appl_inst_status,						--arvsrini igsm
			old_references.appl_inst_status,
			new_references.DECISION_DATE,                                       -- begin APADEGAL adtd001 igs.m
			old_references.DECISION_DATE,
			new_references.DECISION_MAKE_ID,
			old_references.DECISION_MAKE_ID,
			new_references.DECISION_REASON_ID,
			old_references.DECISION_REASON_ID,
			new_references.PENDING_REASON_ID,
			old_references.PENDING_REASON_ID,
			new_references.WAITLIST_STATUS,
			old_references.WAITLIST_STATUS,
			new_references.WAITLIST_RANK,
			old_references.WAITLIST_RANK ,
			new_references.FUTURE_ACAD_CAL_TYPE,
			old_references.FUTURE_ACAD_CAL_TYPE,
			new_references.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
			old_references.FUTURE_ACAD_CI_SEQUENCE_NUMBER,
			new_references.FUTURE_ADM_CAL_TYPE,
			old_references.FUTURE_ADM_CAL_TYPE,
			new_references.FUTURE_ADM_CI_SEQUENCE_NUMBER,
			old_references.FUTURE_ADM_CI_SEQUENCE_NUMBER,
			new_references.DEF_ACAD_CAL_TYPE,
			old_references.DEF_ACAD_CAL_TYPE,
			new_references.def_acad_ci_sequence_num,
			old_references.DEF_ACAD_CI_SEQUENCE_NUM,
			new_references.DECLINE_OFR_REASON,
			old_references.DECLINE_OFR_REASON                             -- end APADEGAL adtd001 igs.m

			);

        END IF;
        IF NVL(p_deleting,FALSE) THEN
                -- Delete admission IGS_PS_COURSE application instance history records.
                IF IGS_AD_GEN_001.ADMP_DEL_ACAI_HIST (
                                old_references.person_id,
                                old_references.admission_appl_number,
                                old_references.nominated_course_cd,
                                old_references.sequence_number,
                                v_message_name) = FALSE THEN
                        FND_MESSAGE.SET_NAME('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        APP_EXCEPTION.RAISE_EXCEPTION;
                END IF ;
        END IF;
        OPEN c_aa (
                        old_references.person_id,
                        old_references.admission_appl_number);
        FETCH c_aa INTO v_adm_appl_status;
        CLOSE c_aa;
        v_person_id := old_references.person_id;
        v_admission_appl_number := old_references.admission_appl_number;
        -- Derive the Admission Application status.
        v_derived_adm_appl_status := IGS_AD_GEN_002.ADMP_GET_AA_AAS (
                                v_person_id,
                                v_admission_appl_number,
                                v_adm_appl_status);
        -- Update the admission application status.
        IF v_derived_adm_appl_status IS NOT NULL AND
           v_derived_adm_appl_status <> v_adm_appl_status THEN
          UPDATE  IGS_AD_APPL
          SET     adm_appl_status = v_derived_adm_appl_status
          WHERE   person_id = v_person_id AND
                  admission_appl_number = v_admission_appl_number;
       igs_ad_wf_001.APP_PRCOC_STATUS_UPD_EVENT (
	     P_PERSON_ID	        => new_references.person_id,
	     P_ADMISSION_APPL_NUMBER	=> new_references.admission_appl_number,
	     P_ADM_APPL_STATUS_NEW	=> v_derived_adm_appl_status,
             P_ADM_APPL_STATUS_OLD	=> v_adm_appl_status);
        END IF;

       -- Raise the Admission Academic Index workflow, whenever the Academic Index value of Application Instance is changed. Financial Aid Integration Build : 3202866
       IF NVL(new_references.academic_index,'*****') <> NVL(old_references.academic_index,'*****') THEN
         igs_ad_wf_001.wf_adm_academic_index(
                           new_references.person_id,
			   new_references.admission_appl_number,
			   new_references.nominated_course_cd,
			   new_references.sequence_number,
			   NVL(old_references.academic_index,'NULL'),
			   NVL(new_references.academic_index,'NULL')
                          );
       END IF;

  END AfterRowUpdateDelete3;

 PROCEDURE Check_Constraints (
     column_name IN VARCHAR2,
     column_value IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  vvutukur        19-May-2002   removed upper check constraint on fee_cat column.bug#2344826.
  arvsrini        27-Jul-2004   removed upper check constraint on adm_outcome_status_reason. bug#3787713
  ***************************************************************/
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'EXPECTED_COMPLETION_PERD' THEN
      new_references.expected_completion_perd := column_value;
     ELSIF upper(column_name) = 'EXPECTED_COMPLETION_YR' THEN
      new_references.expected_completion_yr := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'INTRNTNL_ACCEPTANCE_ADVICE_NUM' THEN
      new_references.intrntnl_acceptance_advice_num := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'SECONDARY_ASS_RANK' THEN
      new_references.secondary_ass_rank := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'ASS_RANK' THEN
      new_references.ass_rank := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'DEFERRED_ADM_CI_SEQUENCE_NUM' THEN
      new_references.deferred_adm_ci_sequence_num := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'CNDTNL_OFFER_MUST_BE_STSFD_IND' THEN
      new_references.cndtnl_offer_must_be_stsfd_ind := column_value;
     ELSIF upper(column_name) = 'PREFERENCE_NUMBER' THEN
      new_references.preference_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' THEN
      new_references.adm_ci_sequence_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'SEQUENCE_NUMBER' THEN
      new_references.sequence_number := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'ADM_CAL_TYPE' THEN
      new_references.adm_cal_type := column_value;
     ELSIF upper(column_name) = 'ADM_CNDTNL_OFFER_STATUS' THEN
      new_references.adm_cndtnl_offer_status := column_value;
     ELSIF upper(column_name) = 'ADM_DOC_STATUS' THEN
      new_references.adm_doc_status := column_value;
     ELSIF upper(column_name) = 'ADM_ENTRY_QUAL_STATUS' THEN
      new_references.adm_entry_qual_status := column_value;
     ELSIF upper(column_name) = 'ADM_OFFER_DFRMNT_STATUS' THEN
      new_references.adm_offer_dfrmnt_status := column_value;
     ELSIF upper(column_name) = 'ADM_OFFER_RESP_STATUS' THEN
      new_references.adm_offer_resp_status := column_value;
     ELSIF upper(column_name) = 'ADM_OUTCOME_STATUS' THEN
      new_references.adm_outcome_status := column_value;
     ELSIF upper(column_name) = 'ADM_OUTCOME_STATUS_REASON' THEN
      new_references.adm_outcome_status_reason := column_value;
     ELSIF upper(column_name) = 'ATTENDANCE_MODE' THEN
      new_references.attendance_mode := column_value;
     ELSIF upper(column_name) = 'ATTENDANCE_TYPE' THEN
      new_references.attendance_type := column_value;
     ELSIF upper(column_name) = 'CNDTNL_OFFER_MUST_BE_STSTD_IND' THEN
      new_references.cndtnl_offer_must_be_stsfd_ind := column_value;
     ELSIF upper(column_name) = 'CORRESPONDENCE_CAT' THEN
      new_references.correspondence_cat := column_value;
     ELSIF upper(column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
     ELSIF upper(column_name) = 'DEFERRED_ADM_CAL_TYPE' THEN
      new_references.deferred_adm_cal_type := column_value;
     ELSIF upper(column_name) = 'ENROLMENT_CAT' THEN
      new_references.enrolment_cat := column_value;
     ELSIF upper(column_name) = 'EXPECTED_COMPLETION_PERD' THEN
      new_references.expected_completion_perd := column_value;
     ELSIF upper(column_name) = 'FUNDING_SOURCE' THEN
      new_references.funding_source := column_value;
     ELSIF upper(column_name) = 'HECS_PAYMENT_OPTION' THEN
      new_references.hecs_payment_option := column_value;
     ELSIF upper(column_name) = 'LATE_ADM_FEE_STATUS' THEN
      new_references.late_adm_fee_status := column_value;
     ELSIF upper(column_name) = 'LOCATION_CD' THEN
      new_references.location_cd := column_value;
     ELSIF upper(column_name) = 'UNIT_SET_CD' THEN
      new_references.unit_set_cd := column_value;
     ELSIF upper(column_name) = 'APPL_INST_STATUS' THEN								--arvsrini igsm
      new_references.appl_inst_status := column_value;
     END IF;
     IF upper(column_name) = 'EXPECTED_COMPLETION_PERD' OR column_name IS NULL THEN
      IF (new_references.expected_completion_perd) NOT IN ('E','M','S') THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXPCT_COMP_PRD'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'EXPECTED_COMPLETION_YR' OR column_name IS NULL THEN
      IF new_references.expected_completion_yr < 0 OR new_references.expected_completion_yr > 9999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXPCT_COMP_YR'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'INTRNTNL_ACCEPTANCE_ADVICE_NUM' OR column_name IS NULL THEN
      IF new_references.intrntnl_acceptance_advice_num < 0 OR new_references.intrntnl_acceptance_advice_num > 999999999999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INTRNL_ACC_ADV_NUM'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'SECONDARY_ASS_RANK' OR column_name IS NULL THEN
      IF new_references.secondary_ass_rank < 1 OR new_references.secondary_ass_rank > 999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ASSESSMENT_RANK'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ASS_RANK' OR column_name IS NULL THEN
      IF new_references.ass_rank < 1 OR new_references.ass_rank > 999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ASSESSMENT_RANK'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'DEFERRED_ADM_CI_SEQUENCE_NUM' OR column_name IS NULL THEN
      IF new_references.deferred_adm_ci_sequence_num < 1 OR new_references.deferred_adm_ci_sequence_num > 999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEFERRED_ADM_CAL_TYPE'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'CNDTNL_OFFER_MUST_BE_STSFD_IND' OR column_name IS NULL THEN
      IF new_references.cndtnl_offer_must_be_stsfd_ind NOT IN ('Y','N')
        THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CND_OFR_STSFD_IND'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'PREFERENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.preference_number < 1 OR new_references.preference_number > 99 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PREFERANCE_NUM'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.adm_ci_sequence_number < 1 OR new_references.adm_ci_sequence_number > 999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'SEQUENCE_NUMBER' OR column_name IS NULL THEN
      IF new_references.sequence_number < 1 OR new_references.sequence_number > 999999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_CAL_TYPE' OR column_name IS NULL THEN
      IF new_references.adm_cal_type <> UPPER(new_references.adm_cal_type) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_CNDTNL_OFFER_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_cndtnl_offer_status <> UPPER(new_references.adm_cndtnl_offer_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_COND_OFR_STATUS'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_DOC_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_doc_status <> UPPER(new_references.adm_doc_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_DOC_STAT'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_ENTRY_QUAL_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_entry_qual_status <> UPPER(new_references.adm_entry_qual_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_ENTRY_QUAL_STATUS'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_OFFER_DFRMNT_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_offer_dfrmnt_status <> UPPER(new_references.adm_offer_dfrmnt_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_DFRMNT_STATUS'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_OFFER_RESP_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_offer_resp_status <> UPPER(new_references.adm_offer_resp_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_RESP_STATUS'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ADM_OUTCOME_STATUS' OR column_name IS NULL THEN
      IF new_references.adm_outcome_status <> UPPER(new_references.adm_outcome_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OUTCOME_STATUS'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'CNDTNL_OFFER_MUST_BE_STSTD_IND' OR column_name IS NULL THEN
      IF new_references.cndtnl_offer_must_be_stsfd_ind <> UPPER(new_references.cndtnl_offer_must_be_stsfd_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CND_OFR_STSFD_IND'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'CORRESPONDENCE_CAT' OR column_name IS NULL THEN
      IF new_references.correspondence_cat <> UPPER(new_references.correspondence_cat) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CRSPOND_CAT'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'COURSE_CD' OR column_name IS NULL THEN
      IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'DEFERRED_ADM_CAL_TYPE' OR column_name IS NULL THEN
      IF new_references.deferred_adm_cal_type <> UPPER(new_references.deferred_adm_cal_type) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEFERRED_ADM_CAL_TYPE'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ENROLMENT_CAT' OR column_name IS NULL THEN
      IF new_references.enrolment_cat <> UPPER(new_references.enrolment_cat) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENROLMENT_CAT'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'EXPECTED_COMPLETION_PERD' OR column_name IS NULL THEN
      IF new_references.expected_completion_perd <> UPPER(new_references.expected_completion_perd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXPCT_COMP_PRD'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'FUNDING_SOURCE' OR column_name IS NULL THEN
      IF new_references.funding_source <> UPPER(new_references.funding_source) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUNDING_SOURCE'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'HECS_PAYMENT_OPTION' OR column_name IS NULL THEN
      IF new_references.hecs_payment_option <> UPPER(new_references.hecs_payment_option) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_HECS_PAY_OPT'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'LATE_ADM_FEE_STATUS' OR column_name IS NULL THEN
      IF new_references.late_adm_fee_status <> UPPER(new_references.late_adm_fee_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_LATE_ADM_FEE_STATUS'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'NOMINATED_COURSE_CD' OR column_name IS NULL THEN
      IF new_references.nominated_course_cd <> UPPER(new_references.nominated_course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_COURSE'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'UNIT_SET_CD' OR column_name IS NULL THEN
      IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_PS_UNIT_SET'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'APPL_INST_STATUS' OR column_name IS NULL THEN				--arvsrini igsm
      IF new_references.appl_inst_status <> UPPER(new_references.appl_inst_status) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_INST_STAT'));
           IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
    /*IF upper(column_name) = 'PRPSD_COMMENCEMENT_DT' OR column_name IS NULL THEN
           IF new_references.prpsd_commencement_dt IS NOT NULL
        AND TRUNC(new_references.prpsd_commencement_dt) > TRUNC(SYSDATE)
	OR TRUNC(new_references.prpsd_commencement_dt) < TRUNC(new_references.offer_dt) THEN
           FND_MESSAGE.SET_NAME('IGS','IGS_AD_PRPSD_CMCMNT_DT_INVALID');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      END IF;*/
  END Check_Constraints;


  PROCEDURE Check_Parent_Existance IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smadathi       13-Feb-2002      Bug 2217104. Added foreign key references
                                  to IGS_CA_INST_ALL table
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
    IF (((old_references.edu_goal_prior_enroll_id = new_references.edu_goal_prior_enroll_id)) OR
        ((new_references.edu_goal_prior_enroll_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                        new_references.edu_goal_prior_enroll_id,
                        'EDU_GOALS', 'N'
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PRI_EN_EDU_GOAL'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.attent_other_inst_cd = new_references.attent_other_inst_cd)) OR
        ((new_references.attent_other_inst_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Or_Institution_Pkg.Get_PK_For_Validation (
                        new_references.attent_other_inst_cd
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_AT_OTH_INST'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.app_source_id = new_references.app_source_id)) OR
        ((new_references.app_source_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                        new_references.app_source_id,
                        'SYS_APPL_SOURCE', 'N'
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APP_SOURCE'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.decision_make_id = new_references.decision_make_id)) OR
        ((new_references.decision_make_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
                        new_references.decision_make_id
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEC_MAKE'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.decision_reason_id = new_references.decision_reason_id)) OR
        ((new_references.decision_reason_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                        new_references.decision_reason_id,
                       'DECISION_REASON', 'N'
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEC_REASON'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.pending_reason_id = new_references.pending_reason_id)) OR
        ((new_references.pending_reason_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
                        new_references.pending_reason_id,
                        'PENDING_REASON','N'
        )  THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PEND_REASON'));
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.attendance_mode
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ATTENDANCE_MODE'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_offer_dfrmnt_status = new_references.adm_offer_dfrmnt_status)) OR
        ((new_references.adm_offer_dfrmnt_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OFRDFRMT_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_offer_dfrmnt_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_DFRMNT_STATUS'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_offer_resp_status = new_references.adm_offer_resp_status)) OR
        ((new_references.adm_offer_resp_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OFR_RESP_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_offer_resp_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OFFER_RESP_STATUS'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_outcome_status = new_references.adm_outcome_status)) OR
        ((new_references.adm_outcome_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_OU_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_outcome_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_OUTCOME_STATUS'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.attendance_type
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ATTENDANCE_TYPE'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    -- Bug no 2380815 locking issue
    -- Removed GET_PK call for Correspondence categories

    IF (((old_references.deferred_adm_cal_type = new_references.deferred_adm_cal_type) AND
         (old_references.deferred_adm_ci_sequence_num = new_references.deferred_adm_ci_sequence_num)) OR
        ((new_references.deferred_adm_cal_type IS NULL) OR
         (new_references.deferred_adm_ci_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.deferred_adm_cal_type,
        new_references.deferred_adm_ci_sequence_num
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEFERRED_ADM_CAL_TYPE'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    -- Bug no 2380815 locking issue
    -- Removed GET_PK call for IGS_PS_COURSE_PKG

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.crv_version_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.enrolment_cat = new_references.enrolment_cat)) OR
        ((new_references.enrolment_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ENROLMENT_CAT_PKG.Get_PK_For_Validation (
        new_references.enrolment_cat
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENROLMENT_CAT'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_CAT_PKG.Get_PK_For_Validation (
        new_references.fee_cat
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FEE_CAT'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
        ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUNDING_SOURCE'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.hecs_payment_option = new_references.hecs_payment_option)) OR
        ((new_references.hecs_payment_option IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_HECS_PAY_OPTN_PKG.Get_PK_For_Validation (
        new_references.hecs_payment_option
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_HECS_PAY_OPT'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_EN_LOCATION'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.ass_tracking_id = new_references.ass_tracking_id)) OR
        ((new_references.ass_tracking_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_TR_ITEM_PKG.Get_PK_For_Validation (
        new_references.ass_tracking_id
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ASS_TRACKING_ID'));
                IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.deferred_tracking_id = new_references.deferred_tracking_id)) OR
        ((new_references.deferred_tracking_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_TR_ITEM_PKG.Get_PK_For_Validation (
        new_references.deferred_tracking_id
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEF_TRACKING_ID'));
                IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.us_version_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_PS_UNIT_SET'));
                  IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL) OR
         (new_references.nominated_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PS_APPL_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.nominated_course_cd
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_APPL'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_cndtnl_offer_status = new_references.adm_cndtnl_offer_status)) OR
        ((new_references.adm_cndtnl_offer_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_CNDNL_OFRSTAT_PKG.Get_PK_For_Validation (
        new_references.adm_cndtnl_offer_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_COND_OFR_STATUS'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_doc_status = new_references.adm_doc_status)) OR
        ((new_references.adm_doc_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_DOC_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_doc_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_DOC_STAT'));
                  IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.adm_entry_qual_status = new_references.adm_entry_qual_status)) OR
        ((new_references.adm_entry_qual_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_ENT_QF_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_entry_qual_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_ENTRY_QUAL_STATUS'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.late_adm_fee_status = new_references.late_adm_fee_status)) OR
        ((new_references.late_adm_fee_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_FEE_STAT_PKG.Get_PK_For_Validation (
        new_references.late_adm_fee_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_LATE_ADM_FEE_STATUS'));
                 IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.future_acad_cal_type = new_references.future_acad_cal_type) AND
         (old_references.future_acad_ci_sequence_number = new_references.future_acad_ci_sequence_number)) OR
        ((new_references.future_acad_cal_type IS NULL) OR
         (new_references.future_acad_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.future_acad_cal_type,
        new_references.future_acad_ci_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUT_ACAD_CAL'));
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.future_adm_cal_type = new_references.future_adm_cal_type) AND
         (old_references.future_adm_ci_sequence_number = new_references.future_adm_ci_sequence_number)) OR
        ((new_references.future_adm_cal_type IS NULL) OR
         (new_references.future_adm_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.future_adm_cal_type,
        new_references.future_adm_ci_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUT_ADM_CAL'));
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.def_prev_term_adm_appl_num = new_references.def_prev_term_adm_appl_num) AND
         (old_references.def_prev_appl_sequence_num = new_references.def_prev_appl_sequence_num)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.def_prev_term_adm_appl_num IS NULL) OR
         (new_references.def_prev_appl_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PS_APPL_INST_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.def_prev_term_adm_appl_num,
        new_references.nominated_course_cd,
        new_references.def_prev_appl_sequence_num
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEFER_APPL_INST'));
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.nominated_course_cd = new_references.nominated_course_cd) AND
         (old_references.def_term_adm_appl_num = new_references.def_term_adm_appl_num) AND
         (old_references.def_appl_sequence_num = new_references.def_appl_sequence_num)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.nominated_course_cd IS NULL) OR
         (new_references.def_term_adm_appl_num IS NULL) OR
         (new_references.def_appl_sequence_num IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PS_APPL_INST_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.def_term_adm_appl_num,
        new_references.nominated_course_cd,
        new_references.def_appl_sequence_num
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_DEFER_APPL_INST'));
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


    IF (((old_references.appl_inst_status = new_references.appl_inst_status)) OR			--arvsrini igsm
        ((new_references.appl_inst_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_STAT_PKG.Get_PK_For_Validation (
        new_references.appl_inst_status ,'N'
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL_INST_STAT'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;


  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  nshee           07-feb-2001     Removed the call of IGS_AD_CREDENTIALS
                                  as part of Bug#2177686. The get_fk call
                                  IGS_AD_CREDENTIALS_PKG.get_fk_igs_ad_ps_appl_inst
                                  is no longer needed since this foreign key relation
                                  doesn't hold true with IGS_PE_CREDENTIALS table
  samaresh        21-dec-2001     Bug No 2158524
                                  Removed the call to get Fk to
                                  Igs_ad_app_req, as the table is
                                  now a child of Igs_ad_appl
  rghosh          08-nov-2002     Bug No. 2619603
				  Added the calls to get fk to
				  IGS_AD_APLINS_ADMREQ
				  IGS_AD_APPL_NOTES
				  IGS_AD_APPL_PGMAPPRV
				  IGS_AD_TSTSCR_USED
				  IGS_PE_TYP_INSTANCES
  (reverse chronological order - newest change first)
  ***************************************************************/


    -- Cursor to check for HESA Installation at site

     CURSOR c_hesa(cp_tab user_objects.object_name%TYPE) IS
     SELECT 1 FROM USER_OBJECTS
     WHERE OBJECT_NAME  = cp_tab
     AND   object_type = 'PACKAGE BODY';

     l_hesa  VARCHAR2(1);


  BEGIN

    Igs_Ad_Appl_Eval_Pkg.Get_FK_Igs_Ad_Ps_Appl_Inst (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    Igs_Ad_Edugoal_Pkg.Get_FK_Igs_Ad_Ps_Appl_Inst (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    Igs_Ad_Spl_Adm_Cat_Pkg.Get_FK_Igs_Ad_Ps_Appl_Inst (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    Igs_Ad_Unit_Sets_Pkg.Get_FK_Igs_Ad_Ps_Appl_Inst (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    IGS_AD_PS_APLINSTUNT_PKG.GET_FK_IGS_AD_PS_APPL_INST (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    IGS_RE_CANDIDATURE_PKG.GET_FK_IGS_AD_PS_APPL_INST (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    IGS_EN_STDNT_PS_ATT_PKG.GET_FK_IGS_AD_PS_APPL_INST (
      old_references.person_id,
      old_references.admission_appl_number,
      old_references.nominated_course_cd,
      old_references.sequence_number
      );
    IGS_AD_APPL_ARP_PKG.GET_FK_IGS_AD_PS_APPL_INST (
     old_references.person_id,
     old_references.admission_appl_number,
     old_references.nominated_course_cd,
     old_references.sequence_number
     );
     -- added the following calls as per bug #2619603 -rghosh

   IGS_AD_APLINS_ADMREQ_PKG.GET_FK_IGS_AD_PS_APPL_INST_ALL (
     old_references.person_id,
     old_references.admission_appl_number,
     old_references.nominated_course_cd,
     old_references.sequence_number
     );
   IGS_AD_APPL_NOTES_PKG.GET_FK_IGS_AD_PS_APPL_INST (
     old_references.person_id,
     old_references.admission_appl_number,
     old_references.nominated_course_cd,
     old_references.sequence_number
     );
   IGS_AD_APPL_PGMAPPRV_PKG.GET_FK_IGS_AD_PS_APPL_INST (
     old_references.person_id,
     old_references.admission_appl_number,
     old_references.nominated_course_cd,
     old_references.sequence_number
     );
   IGS_AD_TSTSCR_USED_PKG.GET_FK_IGS_AD_PS_APPL_INST (
     old_references.person_id,
     old_references.admission_appl_number,
     old_references.nominated_course_cd,
     old_references.sequence_number
     );

   IGS_PE_TYP_INSTANCES_PKG.GET_FK_IGS_AD_PS_APPL_INST (
     old_references.person_id,
     old_references.admission_appl_number,
     old_references.nominated_course_cd,
     old_references.sequence_number
     );

   --Addition of calls for bug #2619603 ends here -rghosh

   -- Added the following check chaild existance for the HESA requirment - cdcruz

  OPEN c_hesa('IGS_HE_AD_DTL_ALL_PKG');
  FETCH c_hesa INTO l_hesa;
  IF c_hesa%FOUND THEN
    EXECUTE IMMEDIATE
   'BEGIN  igs_he_ad_dtl_all_pkg.get_fk_igs_ad_ps_appl_inst_all(:1,:2,:3,:4);  END;'
      USING
           old_references.person_id,
           old_references.admission_appl_number,
           old_references.nominated_course_cd,
           old_references.sequence_number ;
      CLOSE c_hesa;
  ELSE
    CLOSE c_hesa;
  END IF;


  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      sequence_number = x_sequence_number
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

  FUNCTION Get_PKNolock_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
      AND      sequence_number = x_sequence_number;
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
  END Get_PKNolock_For_Validation;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid1 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    pending_reason_id = x_code_id ;
    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    edu_goal_prior_enroll_id = x_code_id ;
    CURSOR cur_rowid3 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    app_source_id = x_code_id ;
    CURSOR cur_rowid5 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    decision_reason_id = x_code_id ;
    CURSOR cur_rowid6 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    entry_status = x_code_id ;
    CURSOR cur_rowid7 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    entry_level = x_code_id ;
    lv_rowid cur_rowid1%RowType;
  BEGIN
    Open cur_rowid1;
    Fetch cur_rowid1 INTO lv_rowid;
    IF (cur_rowid1%FOUND) THEN
      Close cur_rowid1;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACDC_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid1;
    Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACDC_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;
    Open cur_rowid3;
    Fetch cur_rowid3 INTO lv_rowid;
    IF (cur_rowid3%FOUND) THEN
      Close cur_rowid3;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACDC_FK3');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid3;
    Open cur_rowid5;
    Fetch cur_rowid5 INTO lv_rowid;
    IF (cur_rowid5%FOUND) THEN
      Close cur_rowid5;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACDC_FK5');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid5;
    Open cur_rowid6;
    Fetch cur_rowid6 INTO lv_rowid;
    IF (cur_rowid6%FOUND) THEN
      Close cur_rowid6;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACDC_FK6');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid6;
    Open cur_rowid7;
    Fetch cur_rowid7 INTO lv_rowid;
    IF (cur_rowid7%FOUND) THEN
      Close cur_rowid7;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACDC_FK7');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid7;
  END Get_FK_Igs_Ad_Code_Classes;

  PROCEDURE Get_FK_Igs_Or_Institution (
    x_institution_cd IN VARCHAR2
    ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    attent_other_inst_cd = x_institution_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_OI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END Get_FK_Igs_Or_Institution;

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid1 IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    person_id = x_person_id ;
    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    decision_make_id = x_person_id ;
    lv_rowid cur_rowid1%RowType;
  BEGIN
    Open cur_rowid1;
    Fetch cur_rowid1 INTO lv_rowid;
    IF (cur_rowid1%FOUND) THEN
      Close cur_rowid1;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid1;
    Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_PE_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;
  END Get_FK_Igs_Pe_Person;

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    attendance_mode = x_attendance_mode ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AM_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_MODE;


  PROCEDURE GET_FK_IGS_AD_OFRDFRMT_STAT (
    x_adm_offer_dfrmnt_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    adm_offer_dfrmnt_status = x_adm_offer_dfrmnt_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AODS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_OFRDFRMT_STAT;


  PROCEDURE GET_FK_IGS_AD_OFR_RESP_STAT (
    x_adm_offer_resp_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    adm_offer_resp_status = x_adm_offer_resp_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AORS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_OFR_RESP_STAT;


  PROCEDURE GET_FK_IGS_AD_OU_STAT (
    x_adm_outcome_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    adm_outcome_status = x_adm_outcome_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AOS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_OU_STAT;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    attendance_type = x_attendance_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ATT_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_CO_CAT (
    x_correspondence_cat IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    correspondence_cat  = x_correspondence_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_CC_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CO_CAT;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) IS
   ------------------------------------------------------------------
   --Change History:
   --Who         When            What
   --smadathi    12-Feb-2002     Bug 2217104. Changed cursor cur_rowid
   --                            to add future_adm_cal_type,future_adm_ci_sequence_number,
   --                            future_acad_cal_type,future_acad_ci_sequence_number,
   -------------------------------------------------------------------
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    (deferred_adm_cal_type = x_cal_type
      AND      deferred_adm_ci_sequence_num = x_sequence_number)
      OR       (adm_cal_type           = x_cal_type
      AND       adm_ci_sequence_number = x_sequence_number )
      OR       (future_acad_cal_type           = x_cal_type
      AND       future_acad_ci_sequence_number = x_sequence_number )
      OR       (future_adm_cal_type            = x_cal_type
      AND       future_adm_ci_sequence_number  = x_sequence_number );

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_CI_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    course_cd = x_course_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_CRS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_COURSE;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    course_cd = x_course_cd
      AND      crv_version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_CRV_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_VER;

  PROCEDURE GET_FK_IGS_EN_ENROLMENT_CAT (
    x_enrolment_cat IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    enrolment_cat = x_enrolment_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_EC_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_ENROLMENT_CAT;

  PROCEDURE GET_FK_IGS_FI_FEE_CAT (
    x_fee_cat IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_FC_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_CAT;

  PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    funding_source = x_funding_source ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_FS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FUND_SRC;

  PROCEDURE GET_FK_IGS_FI_HECS_PAY_OPTN (
    x_hecs_payment_option IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    hecs_payment_option = x_hecs_payment_option ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_HPO_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_HECS_PAY_OPTN;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_LOC_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_TR_ITEM (
    x_tracking_id IN NUMBER
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    ass_tracking_id = x_tracking_id
         OR    deferred_tracking_id = x_tracking_id ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_TRI_ASS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_TR_ITEM;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_US_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_EN_UNIT_SET;

  -- begin oxford unit set code bug 5194658
    PROCEDURE GET_FK_IGS_PS_OFR_UNIT_SET (
      x_unit_set_cd IN VARCHAR2,
      x_version_number IN NUMBER,
      x_course_cd VARCHAR2,
      x_crv_version_number NUMBER,
      x_acad_cal_type VARCHAR2
      ) IS
      CURSOR cur_rowid IS
        SELECT   ainst.rowid
        FROM     IGS_AD_PS_APPL_INST_ALL ainst, IGS_AD_APPL_ALL apl
        WHERE    ainst.person_id              = apl.person_id
        AND      ainst.admission_appl_number  = apl.admission_appl_number
        AND      ainst.unit_set_cd            = x_unit_set_cd
        AND      ainst.us_version_number      = x_version_number
        AND      ainst.course_cd              = x_course_cd
        AND      ainst.crv_version_number     = x_crv_version_number
        AND      apl.acad_cal_type            = x_acad_cal_type ;

      lv_rowid cur_rowid%RowType;
    BEGIN
      Open cur_rowid;
      Fetch cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
        Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_US_FK');
            IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
        Return;
      END IF;
      Close cur_rowid;
    END GET_FK_IGS_PS_OFR_UNIT_SET;
   -- end oxford unit set code bug 5194658



  PROCEDURE GET_FK_IGS_AD_APPL (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AA_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_APPL;

  PROCEDURE GET_FK_IGS_AD_PS_APPL (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACA_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_PS_APPL;

  PROCEDURE GET_FK_IGS_AD_CNDNL_OFRSTAT (
    x_adm_cndtnl_offer_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    adm_cndtnl_offer_status = x_adm_cndtnl_offer_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ACOS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_CNDNL_OFRSTAT;

  PROCEDURE GET_FK_IGS_AD_DOC_STAT (
    x_adm_doc_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    adm_doc_status = x_adm_doc_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ADS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_DOC_STAT;

  PROCEDURE GET_FK_IGS_AD_ENT_QF_STAT (
    x_adm_entry_qual_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    adm_entry_qual_status = x_adm_entry_qual_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AEQS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_ENT_QF_STAT;

  PROCEDURE GET_FK_IGS_AD_FEE_STAT (
    x_adm_fee_status IN VARCHAR2
    ) IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_INST_ALL
      WHERE    late_adm_fee_status = x_adm_fee_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_AFS_FK');
          IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_FEE_STAT;

  PROCEDURE GET_FK_IGS_AD_SCHL_APLY_TO (
    x_sch_apl_to_id IN NUMBER
    ) IS
  /*************************************************************
  Created By : nsinha
  Date Created By : 30-Jul-2001
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_ps_appl_inst_all
      WHERE    sch_apl_to_id = x_sch_apl_to_id;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ACAI_ASAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_SCHL_APLY_TO;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_org_id IN NUMBER,
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_predicted_gpa IN NUMBER,
    x_academic_index IN VARCHAR2,
    x_adm_cal_type IN VARCHAR2,
    x_app_file_location IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_app_source_id IN NUMBER,
    x_crv_version_number IN NUMBER,
    x_waitlist_rank IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attent_other_inst_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_edu_goal_prior_enroll_id IN NUMBER,
    x_attendance_type IN VARCHAR2,
    x_decision_make_id IN NUMBER,
    x_unit_set_cd IN VARCHAR2,
    x_decision_date IN DATE,
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
    x_decision_reason_id IN NUMBER,
    x_us_version_number IN NUMBER,
    x_decision_notes IN VARCHAR2,
    x_pending_reason_id IN NUMBER,
    x_preference_number IN NUMBER,
    x_adm_doc_status IN VARCHAR2,
    x_adm_entry_qual_status IN VARCHAR2,
    x_deficiency_in_prep IN VARCHAR2,
    x_late_adm_fee_status IN VARCHAR2,
    x_spl_consider_comments IN VARCHAR2,
    x_apply_for_finaid IN VARCHAR2,
    x_finaid_apply_date IN DATE,
    x_adm_outcome_status IN VARCHAR2,
    x_adm_otcm_stat_auth_per_id IN NUMBER,
    x_adm_outcome_status_auth_dt IN DATE,
    x_adm_outcome_status_reason IN VARCHAR2,
    x_offer_dt IN DATE,
    x_offer_response_dt IN DATE,
    x_prpsd_commencement_dt IN DATE,
    x_adm_cndtnl_offer_status IN VARCHAR2,
    x_cndtnl_offer_satisfied_dt IN DATE,
    x_cndnl_ofr_must_be_stsfd_ind IN VARCHAR2,
    x_adm_offer_resp_status IN VARCHAR2,
    x_actual_response_dt IN DATE,
    x_adm_offer_dfrmnt_status IN VARCHAR2,
    x_deferred_adm_cal_type IN VARCHAR2,
    x_deferred_adm_ci_sequence_num IN NUMBER,
    x_deferred_tracking_id IN NUMBER,
    x_ass_rank IN NUMBER,
    x_secondary_ass_rank IN NUMBER,
    x_intr_accept_advice_num IN NUMBER,
    x_ass_tracking_id IN NUMBER,
    x_fee_cat IN VARCHAR2,
    x_hecs_payment_option IN VARCHAR2,
    x_expected_completion_yr IN NUMBER,
    x_expected_completion_perd IN VARCHAR2,
    x_correspondence_cat IN VARCHAR2,
    x_enrolment_cat IN VARCHAR2,
    x_funding_source IN VARCHAR2,
    x_applicant_acptnce_cndtn IN VARCHAR2,
    x_cndtnl_offer_cndtn IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_ss_application_id IN VARCHAR2,
    x_ss_pwd IN VARCHAR2,
    X_AUTHORIZED_DT IN DATE,
    X_AUTHORIZING_PERS_ID IN NUMBER,
    x_entry_status IN NUMBER,
    x_entry_level IN NUMBER,
    x_sch_apl_to_id IN NUMBER,
    x_idx_calc_date IN DATE,
    x_waitlist_status IN VARCHAR2,
        x_attribute21 IN VARCHAR2,
    x_attribute22 IN VARCHAR2,
    x_attribute23 IN VARCHAR2,
    x_attribute24 IN VARCHAR2,
    x_attribute25 IN VARCHAR2,
    x_attribute26 IN VARCHAR2,
    x_attribute27 IN VARCHAR2,
    x_attribute28 IN VARCHAR2,
    x_attribute29 IN VARCHAR2,
    x_attribute30 IN VARCHAR2,
    x_attribute31 IN VARCHAR2,
    x_attribute32 IN VARCHAR2,
    x_attribute33 IN VARCHAR2,
    x_attribute34 IN VARCHAR2,
    x_attribute35 IN VARCHAR2,
    x_attribute36 IN VARCHAR2,
    x_attribute37 IN VARCHAR2,
    x_attribute38 IN VARCHAR2,
    x_attribute39 IN VARCHAR2,
    x_attribute40 IN VARCHAR2,
    x_fut_acad_cal_type           IN VARCHAR2,
    x_fut_acad_ci_sequence_number IN NUMBER  ,
    x_fut_adm_cal_type            IN VARCHAR2,
    x_fut_adm_ci_sequence_number  IN NUMBER  ,
    x_prev_term_adm_appl_number  IN NUMBER  ,
    x_prev_term_sequence_number  IN NUMBER  ,
    x_fut_term_adm_appl_number    IN NUMBER  ,
    x_fut_term_sequence_number    IN NUMBER  ,
      x_def_acad_cal_type IN VARCHAR2,
      x_def_acad_ci_sequence_num  IN NUMBER  ,
      x_def_prev_term_adm_appl_num  IN NUMBER  ,
      x_def_prev_appl_sequence_num  IN NUMBER  ,
      x_def_term_adm_appl_num  IN NUMBER  ,
      x_def_appl_sequence_num  IN NUMBER  ,
      x_appl_inst_status	IN VARCHAR2,						--arvsrini igsm
      x_ais_reason		IN VARCHAR2,
      x_decline_ofr_reason	IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : nsinha
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who               When            What
  (reverse chronological order - newest change first)
  nsinha         Jul 30, 2001     Bug enh no : 1905651 changes.
                                  Added entry_status, entry_level and sch_apl_to_id
                                  to the procedures
  pbondugu     02-Apr-2003	Validation is added for checking whether application date
				        is less than adm_outcome_status_auth_dt,offer_dt,idx_calc_date
  rghosh       03-apr-2003     Added the code for getting the new offer response status for an UCAS application
                                                       bug# 2860860 (UCAS Conditional Offer build)
  pbondugu     23-Apr-2003	Validation  for checking whether application date
				        is less than adm_outcome_status_auth_dt,offer_dt,idx_calc_date
					is moved to BeforeRowInsertUpdateDelete1
  akadam       06-OCT-2003      BUG: 3160184 Removed check on  adm_offer_resp_status for System status
                                     of Accepted
  ***************************************************************/


 --rghosh bug# 2860860 (UCAS Conditional Offer build)
 -- cursor to fetch the alt_appl_id and choice number for the current Admission Application
 CURSOR c_get_appl_details (cp_person_id   igs_ad_appl. person_id %TYPE,
                            cp_admission_appl_number    igs_ad_appl. admission_appl_number%TYPE) IS
 SELECT alt_appl_id, choice_number,s_admission_process_type
 FROM igs_ad_appl
 WHERE person_id = cp_person_id AND
       admission_appl_number = cp_admission_appl_number;

 c_get_appl_details_rec      c_get_appl_details%ROWTYPE;
 l_message_name VARCHAR2(30);
 l_adm_offer_resp_status igs_ad_ps_appl_inst_all.adm_offer_resp_status%TYPE;

 --- begin apadegal ADTD001 RE-OPEN Build  igs.m
CURSOR cur_reconsider IS
SELECT   req_for_reconsideration_ind
FROM     IGS_AD_PS_APPL_ALL apl
WHERE   apl.person_id = new_references.person_id
AND     apl.admission_appl_number = new_references.admission_appl_number
AND     apl.nominated_course_cd = new_references.nominated_course_cd ;

l_is_inst_reconsidered VARCHAR2(1) DEFAULT NULL;
--- end apadegal ADTD001 RE-OPEN Build  igs.m

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_person_id,
      x_admission_appl_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_predicted_gpa,
      x_academic_index,
      x_adm_cal_type,
      x_app_file_location,
      x_adm_ci_sequence_number,
      x_course_cd,
      x_app_source_id,
      x_crv_version_number,
      x_waitlist_rank,
      x_location_cd,
      x_attent_other_inst_cd,
      x_attendance_mode,
      x_edu_goal_prior_enroll_id,
      x_attendance_type,
      x_decision_make_id,
      x_unit_set_cd,
      x_decision_date,
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
      x_decision_reason_id,
      x_us_version_number,
      x_decision_notes,
      x_pending_reason_id,
      x_preference_number,
      x_adm_doc_status,
      x_adm_entry_qual_status,
      x_deficiency_in_prep,
      x_late_adm_fee_status,
      x_spl_consider_comments,
      x_apply_for_finaid,
      x_finaid_apply_date,
      x_adm_outcome_status,
      x_adm_otcm_stat_auth_per_id,
      x_adm_outcome_status_auth_dt,
      x_adm_outcome_status_reason,
      x_offer_dt,
      x_offer_response_dt,
      x_prpsd_commencement_dt,
      x_adm_cndtnl_offer_status,
      x_cndtnl_offer_satisfied_dt,
      x_cndnl_ofr_must_be_stsfd_ind,
      x_adm_offer_resp_status,
      x_actual_response_dt,
      x_adm_offer_dfrmnt_status,
      x_deferred_adm_cal_type,
      x_deferred_adm_ci_sequence_num,
      x_deferred_tracking_id,
      x_ass_rank,
      x_secondary_ass_rank,
      x_intr_accept_advice_num,
      x_ass_tracking_id,
      x_fee_cat,
      x_hecs_payment_option,
      x_expected_completion_yr,
      x_expected_completion_perd,
      x_correspondence_cat,
      x_enrolment_cat,
      x_funding_source,
      x_applicant_acptnce_cndtn,
      x_cndtnl_offer_cndtn,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_ss_application_id,
      x_ss_pwd ,
      X_AUTHORIZED_DT,
      X_AUTHORIZING_PERS_ID,
      x_entry_status,
      x_entry_level,
      x_sch_apl_to_id,
      x_idx_calc_date,
      x_waitlist_status,
      x_attribute21,
      x_attribute22,
      x_attribute23,
      x_attribute24,
      x_attribute25,
      x_attribute26,
      x_attribute27,
      x_attribute28,
      x_attribute29,
      x_attribute30,
      x_attribute31,
      x_attribute32,
      x_attribute33,
      x_attribute34,
      x_attribute35,
      x_attribute36,
      x_attribute37,
      x_attribute38,
      x_attribute39,
      x_attribute40,
      x_fut_acad_cal_type,
      x_fut_acad_ci_sequence_number,
      x_fut_adm_cal_type,
      x_fut_adm_ci_sequence_number,
      x_prev_term_adm_appl_number,
      x_prev_term_sequence_number,
      x_fut_term_adm_appl_number,
      x_fut_term_sequence_number,
      x_def_acad_cal_type,
      x_def_acad_ci_sequence_num,
      x_def_prev_term_adm_appl_num,
      x_def_prev_appl_sequence_num,
      x_def_term_adm_appl_num,
      x_def_appl_sequence_num,
      x_appl_inst_status,									--arvsrini igsm
      x_ais_reason,
      x_decline_ofr_reason
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_Pk_For_Validation(
           new_references.person_id,
           new_references.admission_appl_number,
           new_references.nominated_course_cd,
           new_references.sequence_number)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE , p_updating => FALSE, p_deleting=> FALSE);
    ELSIF (p_action = 'UPDATE') THEN

	--- begin apadegal ADTD001 RE-OPEN Build  igs.m
	OPEN cur_reconsider;
	FETCH cur_reconsider INTO   l_is_inst_reconsidered;
	CLOSE  cur_reconsider;
	--- end apadegal ADTD001 RE-OPEN Build  igs.m

      IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(old_references.adm_outcome_status), 'NONE') = 'CANCELLED'
         AND (NVL(l_is_inst_reconsidered,'N') <> 'Y')       -- APADEGAL (IGS.M) - CANCELLED instance can be updated while reconsideration.
      THEN
        Fnd_Message.Set_name('IGS','IGS_AD_NOT_UPD_CANCEL_APPLINST');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') <> 'CANCELLED' THEN

      -- rghosh bug# 2860860 (UCAS Conditional Offer build)
      -- if the application is UK one and old admission outcome status is mapped to system outcome status of COND-OFFER
      -- and the new admission outcome status is mapped to system outcome status of OFFER
      -- and the old offer response status is mapped to that UCAS decision code which is in turn mapped to system outcome status of COND-OFFER
      -- and UCAS reply code of Firm Acceptance then it returns a new offer response status that is mapped to that UCAS decision code which is in turn
      -- mapped to system outcome status of OFFER and UCAS reply code of Firm Acceptance.
        IF fnd_profile.value('OSS_COUNTRY_CODE')  = 'GB' AND
              (NVL(igs_ad_gen_008.admp_get_saos(old_references.adm_outcome_status), 'NONE') = 'COND-OFFER') AND
              (NVL(igs_ad_gen_008.admp_get_saos(new_references.adm_outcome_status), 'NONE') = 'OFFER')  THEN

                 OPEN c_get_appl_details (new_references.person_id,new_references.admission_appl_number);
                 FETCH c_get_appl_details INTO c_get_appl_details_rec;
                 CLOSE c_get_appl_details;
                 IF c_get_appl_details_rec.alt_appl_id IS NOT NULL AND
                    c_get_appl_details_rec.choice_number IS NOT NULL AND
		    c_get_appl_details_rec.s_admission_process_type <> 'RE-ADMIT' THEN
                    l_adm_offer_resp_status := igs_uc_tran_processor_pkg.get_adm_offer_resp_stat(
                                                   c_get_appl_details_rec.alt_appl_id,
                                                   c_get_appl_details_rec.choice_number,
                                                   old_references.adm_outcome_status,
		                                   new_references.adm_outcome_status,
                                                   old_references.adm_offer_resp_status,
						   l_message_name);
                    IF l_message_name IS NOT NULL THEN
                       fnd_message.set_name('IGS',l_message_name);
                       igs_ge_msg_stack.add;
                    END IF;

            	    IF l_message_name IS NULL AND
                       IGS_AD_GEN_008.ADMP_GET_SAORS(l_adm_offer_resp_status) IS NOT NULL THEN -- Bug : 3160184 Removed the check on l_adm_offer_resp_status for ACCEPTED
                        new_references.adm_offer_resp_status := l_adm_offer_resp_status;
                        IF IGS_AD_GEN_008.ADMP_GET_SAORS(new_references.adm_offer_resp_status) NOT IN ('PENDING', 'LAPSED', 'NOT-APPLIC') THEN -- added this code for Bug : 3160184
                        new_references.actual_response_dt := TRUNC(SYSDATE);
                        END IF;
                    END IF;

                 END IF;
        END IF;

        -- Call all the procedures related to Before Update.
        Check_Constraints;
        Check_Parent_Existance;
        BeforeRowInsertUpdateDelete1 (p_inserting => FALSE, p_updating => TRUE , p_deleting => FALSE);
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 (p_inserting=> FALSE, p_updating => FALSE , p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_Pk_For_Validation(
           new_references.person_id,
           new_references.admission_appl_number,
           new_references.nominated_course_cd,
           new_references.sequence_number)  THEN
        Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') <> 'CANCELLED' THEN
        Check_Constraints;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action                  IN VARCHAR2,
    x_rowid                   IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  rasahoo       01-Sep-2003     Removed the private procedure IGF_UPDATE_DATA And
                                Removed the call of IGF_UPDATE_DATA as part of the Build
                                FA 114(Obsoletion of base record history)
  smadathi      19-Feb-2002     Bug 2217104. Added code as per ADM012,ADM016,ADM038.
  sjalasut      09-oct-01       added code here to calculate the initial and
                                most recent term of admit
  sjadhav          jun 15,2001     this procedure is modified to trigger
                                   a Concurrent Request (IGFAPJ10) which
                                   will create a new record in IGF To do table
  Veereshwar.Dixit  07-AUG-2000     Added AfterRowUpdate call
  kamohan 8/2/02 Bug 2407628 Modified the logic comments whereever neccessary
  knag    23-JAN-2003 Modified population of admittance logic and code indents
  (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_get_init_recent(p_person_id IGS_PE_PERSON.PERSON_ID%TYPE) IS
      SELECT psv.init_cal_type, psv.init_sequence_number,
             psv.recent_cal_type, psv.recent_sequence_number,
             psv.catalog_cal_type, psv.catalog_sequence_number
      FROM   igs_pe_stat_details psv
      WHERE  psv.person_id = p_person_id;

    cv_get_init_recent c_get_init_recent%ROWTYPE;

    -- kamohan bug 2407628
    -- Added this cursor to check if there is an application instance already existing
    CURSOR appl_inst_exist_cur IS
      SELECT DISTINCT 1
      FROM   igs_ad_ps_appl_inst
      WHERE  row_id <> x_rowid
      AND person_id = new_references.person_id
      AND    igs_ad_gen_008.admp_get_saors (adm_offer_resp_status) IN ('ACCEPTED', 'DEFERRAL');

    l_appl_inst_exist_rec NUMBER;

    CURSOR c_adm_ca_seq_acad IS
      SELECT acad_cal_type, acad_ci_sequence_number
      FROM igs_ad_appl
      WHERE admission_appl_number =  new_references.admission_appl_number
      AND   person_id = new_references.person_id;

    cv_adm_ca_seq_acad c_adm_ca_seq_acad%ROWTYPE;

    CURSOR c_get_teach_period (p_acad_cal_type igs_ad_appl.acad_cal_type%TYPE,
                               p_acad_ci_sequence_number igs_ad_appl.acad_ci_sequence_number%TYPE) IS
      SELECT cr.sub_cal_type, cr.sub_ci_sequence_number
      FROM   igs_ca_inst_rel cr, igs_ca_type ct
      WHERE  ct.s_cal_cat ='TEACHING'
      AND    cr.sub_cal_type = ct.cal_type
      AND    cr.sup_cal_type = p_acad_cal_type
      AND    cr.sup_ci_sequence_number = p_acad_ci_sequence_number;

    cv_get_teach_period c_get_teach_period%ROWTYPE;

    CURSOR c_get_load_start_date (p_sub_cal_type igs_ca_inst.cal_type%TYPE,
	                          p_sub_ci_sequence_number igs_ca_inst.sequence_number%TYPE) IS
      SELECT TRUNC(load_start_dt) load_start_dt, load_cal_type, load_ci_sequence_number
      FROM   igs_ca_teach_to_load_v ctl
      WHERE  ctl.teach_cal_type = p_sub_cal_type
      AND    ctl.teach_ci_sequence_number = p_sub_ci_sequence_number;

    cv_get_load_start_date c_get_load_start_date%ROWTYPE;

    --begin  ravi shar changes

     CURSOR c_recon_flag (cp_person_id IN NUMBER, cp_adm_application_num  IN NUMBER,
       cp_nomintaed_course_code IN VARCHAR2) IS
       SELECT REQ_FOR_RECONSIDERATION_IND
       FROM IGS_AD_PS_APPL_ALL
       WHERE PERSON_ID = cp_person_id
       AND ADMISSION_APPL_NUMBER = cp_adm_application_num
       AND NOMINATED_COURSE_CD = cp_nomintaed_course_code;

     l_req_for_reconsideration_ind IGS_AD_PS_APPL_ALL.REQ_FOR_RECONSIDERATION_IND%TYPE;
    -- end ravi shar changes

    -- kamohan Bug 2407628
    -- Added in order to avoid the hit to the database every time the records are looped through
    l_most_recent_profile VARCHAR2(200) ;
    l_catalog_profile VARCHAR2(200) ;

    l_load_init_start_date IGS_CA_TEACH_TO_LOAD_V.LOAD_START_DT%TYPE;
    l_load_init_cal_type IGS_CA_TEACH_TO_LOAD_V.LOAD_CAL_TYPE%TYPE;
    l_load_init_ci_sequence_number IGS_CA_TEACH_TO_LOAD_V.LOAD_CI_SEQUENCE_NUMBER%TYPE;
    l_recent_start_date IGS_CA_TEACH_TO_LOAD_V.LOAD_START_DT%TYPE;
    l_recent_cal_type IGS_CA_TEACH_TO_LOAD_V.LOAD_CAL_TYPE%TYPE;
    l_recent_ci_sequence_number IGS_CA_TEACH_TO_LOAD_V.LOAD_CI_SEQUENCE_NUMBER%TYPE;

    v_party_last_update_date hz_person_profiles.last_update_date%TYPE;
    lv_perosn_profile_id hz_person_profiles.person_profile_id%TYPE;
    v_return_status VARCHAR2(5);
    v_msg_count NUMBER;
    v_msg_data VARCHAR2(2000);

  BEGIN

    l_rowid := x_rowid;
    l_most_recent_profile := FND_PROFILE.VALUE('IGS_PE_RECENT_TERM');
    l_catalog_profile := FND_PROFILE.VALUE('IGS_PE_CATALOG');
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE,p_updating => FALSE,p_deleting=> FALSE );
      AfterRowInsert1 ( p_inserting => TRUE,p_updating => FALSE,p_deleting=> FALSE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') <> 'CANCELLED' THEN
        AfterRowInsertUpdate2 ( p_inserting=> FALSE,p_updating => TRUE,p_deleting=> FALSE );
      END IF;
      AfterRowUpdateDelete3 ( p_inserting=> FALSE,p_updating => TRUE,p_deleting=> FALSE );
      AfterRowUpdate1 ( p_inserting => FALSE,p_updating => TRUE,p_deleting=> FALSE );
      --Raise the buisness event if Application competion status has changed
      IF new_references.adm_doc_status <> old_references.adm_doc_status THEN

	      igs_ad_wf_001.APPCOMP_STATUS_UPD_EVENT
	      (
--		P_ORG_ID                 =>     new_references.org_id,
		P_PERSON_ID              =>     new_references.person_id,
		P_ADMISSION_APPL_NUMBER  =>     new_references.admission_appl_number,
		P_NOMINATED_COURSE_CD    =>     new_references.nominated_course_cd,
		P_SEQUENCE_NUMBER        =>     new_references.sequence_number,
		P_ADM_DOC_STATUS_NEW     =>     new_references.adm_doc_status,
		P_ADM_DOC_STATUS_OLD     =>     old_references.adm_doc_status
	      );
     END IF;

      IF new_references.adm_entry_qual_status <> old_references.adm_entry_qual_status THEN

	      igs_ad_wf_001.ENTRY_QUAL_STATUS_UPD_EVENT
	      (
		   P_PERSON_ID			=>  new_references.person_id,
		   P_ADMISSION_APPL_NUMBER	=>  new_references.admission_appl_number,
		   P_NOMINATED_COURSE_CD	=>  new_references.nominated_course_cd,
		   P_SEQUENCE_NUMBER		=>  new_references.sequence_number,
		   P_ADM_ENTRY_QUAL_STATUS_NEW	=>  new_references.adm_entry_qual_status,
		   P_ADM_ENTRY_QUAL_STATUS_OLD	=>  old_references.adm_entry_qual_status
	      );
     END IF;

      IF new_references.late_adm_fee_status <> old_references.late_adm_fee_status THEN

	      igs_ad_wf_001.LATE_ADM_FEE_STATUS_UPD_EVENT
	      (
		   P_PERSON_ID			=>  new_references.person_id,
		   P_ADMISSION_APPL_NUMBER	=>  new_references.admission_appl_number,
		   P_NOMINATED_COURSE_CD	=>  new_references.nominated_course_cd,
		   P_SEQUENCE_NUMBER		=>  new_references.sequence_number,
		   P_LATE_ADM_FEE_STATUS_NEW    =>  new_references.late_adm_fee_status,
		   P_LATE_ADM_FEE_STATUS_OLD    =>  old_references.late_adm_fee_status
	      );
     END IF;
      IF new_references.adm_cndtnl_offer_status <> old_references.adm_cndtnl_offer_status THEN

	      igs_ad_wf_001.COND_OFFER_STATUS_UPD_EVENT
	      (
		   P_PERSON_ID			=>  new_references.person_id,
		   P_ADMISSION_APPL_NUMBER	=>  new_references.admission_appl_number,
		   P_NOMINATED_COURSE_CD	=>  new_references.nominated_course_cd,
		   P_SEQUENCE_NUMBER		=>  new_references.sequence_number,
		   P_ADM_CNDTNL_OFFER_STATUS_NEW=>  new_references.adm_cndtnl_offer_status,
		   P_ADM_CNDTNL_OFFER_STATUS_OLD=>  old_references.adm_cndtnl_offer_status
	      );
     END IF;

      IF new_references.adm_offer_dfrmnt_status <> old_references.adm_offer_dfrmnt_status THEN

	      igs_ad_wf_001.OFFER_DEFER_STATUS_UPD_EVENT
	      (
		   P_PERSON_ID			=>  new_references.person_id,
		   P_ADMISSION_APPL_NUMBER	=>  new_references.admission_appl_number,
		   P_NOMINATED_COURSE_CD	=>  new_references.nominated_course_cd,
		   P_SEQUENCE_NUMBER		=>  new_references.sequence_number,
		   P_ADM_CAL_TYPE               => new_references.adm_cal_type,    	   -- ravi shar changes
                   P_ADM_CI_SEQUENCE_NUMBER     => new_references.adm_ci_sequence_number,  -- ravi shar changes
		   P_ADM_OFFER_DFRMNT_STATUS_NEW=>  new_references.adm_offer_dfrmnt_status,
		   P_ADM_OFFER_DFRMNT_STATUS_OLD=>  old_references.adm_offer_dfrmnt_status
	      );
     END IF;

      IF new_references.waitlist_status <> old_references.waitlist_status THEN

	      igs_ad_wf_001.WAITLIST_STATUS_UPD_EVENT
	      (
		   P_PERSON_ID			=>  new_references.person_id,
		   P_ADMISSION_APPL_NUMBER	=>  new_references.admission_appl_number,
		   P_NOMINATED_COURSE_CD	=>  new_references.nominated_course_cd,
		   P_SEQUENCE_NUMBER		=>  new_references.sequence_number,
		   P_WAITLIST_STATUS_NEW	=>  new_references.waitlist_status,
		   P_WAITLIST_STATUS_OLD	=>  old_references.waitlist_status
	      );
     END IF;

     IF new_references.adm_offer_resp_status <> old_references.adm_offer_resp_status  THEN
	      igs_ad_offresp_status_wf.adm_offer_response_changed				--arvsrini igsm
	      (
		   P_PERSON_ID			=>  new_references.person_id,
		   P_ADMISSION_APPL_NUMBER	=>  new_references.admission_appl_number,
		   P_NOMINATED_COURSE_CD	=>  new_references.nominated_course_cd,
		   P_SEQUENCE_NUMBER		=>  new_references.sequence_number,
		   p_old_offresp_status 	=>  old_references.adm_offer_resp_status ,
		   p_new_offresp_status		=>  new_references.adm_offer_resp_status
	      );
     END IF;



      IF NVL(new_references.appl_inst_status,'X!@#$Y%') <> NVL(old_references.appl_inst_status,'X!@#$Y%') THEN
               igs_ad_wf_001.APP_INSTANCE_STATUS_UPD_EVENT
               (
               P_PERSON_ID                => new_references.person_id,
               P_ADMISSION_APPL_NUMBER        => new_references.admission_appl_number,
               P_NOMINATED_COURSE_CD        => new_references.nominated_course_cd,
               P_SEQUENCE_NUMBER                => new_references.sequence_number,
               P_APPL_INST_STATUS_NEW        => new_references.appl_inst_status,
               P_APPL_INST_STATUS_OLD        => old_references.appl_inst_status
               );
      END IF;

      -- begin ravi shar changes

      IF new_references.future_acad_cal_type <> old_references.future_acad_cal_type
          OR  new_references.future_adm_cal_type <> old_references.future_adm_cal_type THEN
      OPEN c_recon_flag(new_references.person_id,new_references.admission_appl_number,new_references.nominated_course_cd);
      FETCH c_recon_flag INTO l_req_for_reconsideration_ind;
      CLOSE c_recon_flag;
               igs_ad_wf_001.APP_RECON_FUT_REQ_UPD_EVENT
               (
               P_PERSON_ID                        => new_references.person_id,
               P_ADMISSION_APPL_NUMBER                => new_references.admission_appl_number,
               P_NOMINATED_COURSE_CD                => new_references.nominated_course_cd,
               P_SEQUENCE_NUMBER                        => new_references.sequence_number,
               P_ADM_OUTCOME_STATUS              => new_references.adm_outcome_status,
               P_ADM_OFFER_RESP_STATUS           => new_references.adm_offer_resp_status,
               P_FUTURE_ADM_CAL_TYPE_NEW         => new_references.future_adm_cal_type,
               P_FUTURE_ADM_CAL_TYPE_OLD         =>  old_references.future_adm_cal_type,
               P_FUTURE_ADM_CI_SEQU_NUM_NEW      => new_references.future_adm_ci_sequence_number,
               P_FUTURE_ADM_CI_SEQU_NUM_OLD      => old_references.future_adm_ci_sequence_number,
               P_FUTURE_ACAD_CAL_TYPE_NEW        =>  new_references.future_acad_cal_type,
               P_FUTURE_ACAD_CAL_TYPE_OLD        =>  old_references.future_acad_cal_type,
               P_FUTURE_ACAD_CI_SEQU_NUM_NEW     => new_references.future_acad_ci_sequence_number,
               P_FUTURE_ACAD_CI_SEQ_NUM_OLD      => old_references.future_acad_ci_sequence_number,
               P_REQ_FOR_RECONSIDERATION_IND     => l_req_for_reconsideration_ind
               );

      END IF;

      -- end ravi shar changes.



    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterRowUpdateDelete3 (  p_inserting=> FALSE,p_updating => FALSE, p_deleting => TRUE );
    END IF;

    IF NVL(IGS_AD_GEN_008.ADMP_GET_SAOS(new_references.adm_outcome_status), 'NONE') <> 'CANCELLED' AND
       p_action IN ('INSERT','UPDATE') THEN
      -- This Funtion Gets the System Value of the Offer Response Status
       -- changed for person stats bug 5054301/3958556
      IF (igs_ad_gen_008.admp_get_saors (new_references.adm_offer_resp_status) = 'ACCEPTED' AND
          igs_ad_gen_008.admp_get_saors (old_references.adm_offer_resp_status) <> 'ACCEPTED')
      THEN

	       -- Offer is Accepted
	       igs_ad_upd_initialise.update_per_stats( new_references.person_id,
                                                       new_references.admission_appl_number,
                                                       'A'
						     );

      ELSIF (igs_ad_gen_008.admp_get_saors (new_references.adm_offer_resp_status) <> 'ACCEPTED' AND
             igs_ad_gen_008.admp_get_saors (old_references.adm_offer_resp_status) = 'ACCEPTED')
      THEN
	      -- Accepted offer is reopened/ or Accepted application is reconsidered
              igs_ad_upd_initialise.update_per_stats( new_references.person_id,
						      new_references.admission_appl_number,
						      'R'
						    );

      END IF;

    END IF;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
        X_ORG_ID in NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PREDICTED_GPA IN NUMBER,
       x_ACADEMIC_INDEX IN VARCHAR2,
       x_ADM_CAL_TYPE IN VARCHAR2,
       x_APP_FILE_LOCATION IN VARCHAR2,
       x_ADM_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_APP_SOURCE_ID IN NUMBER,
       x_CRV_VERSION_NUMBER IN NUMBER,
       x_WAITLIST_RANK IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_ATTENT_OTHER_INST_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_EDU_GOAL_PRIOR_ENROLL_ID IN NUMBER,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_DECISION_MAKE_ID IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_DECISION_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_DECISION_REASON_ID IN NUMBER,
       x_US_VERSION_NUMBER IN NUMBER,
       x_DECISION_NOTES IN VARCHAR2,
       x_PENDING_REASON_ID IN NUMBER,
       x_PREFERENCE_NUMBER IN NUMBER,
       x_ADM_DOC_STATUS IN VARCHAR2,
       x_ADM_ENTRY_QUAL_STATUS IN VARCHAR2,
       x_DEFICIENCY_IN_PREP IN VARCHAR2,
       x_LATE_ADM_FEE_STATUS IN VARCHAR2,
       x_SPL_CONSIDER_COMMENTS IN VARCHAR2,
       x_APPLY_FOR_FINAID IN VARCHAR2,
       x_FINAID_APPLY_DATE IN DATE,
       x_ADM_OUTCOME_STATUS IN VARCHAR2,
       x_adm_otcm_stat_auth_per_id IN NUMBER,
       x_ADM_OUTCOME_STATUS_AUTH_DT IN DATE,
       x_ADM_OUTCOME_STATUS_REASON IN VARCHAR2,
       x_OFFER_DT IN DATE,
       x_OFFER_RESPONSE_DT IN DATE,
       x_PRPSD_COMMENCEMENT_DT IN DATE,
       x_ADM_CNDTNL_OFFER_STATUS IN VARCHAR2,
       x_CNDTNL_OFFER_SATISFIED_DT IN DATE,
       x_cndnl_ofr_must_be_stsfd_ind IN VARCHAR2,
       x_ADM_OFFER_RESP_STATUS IN VARCHAR2,
       x_ACTUAL_RESPONSE_DT IN DATE,
       x_ADM_OFFER_DFRMNT_STATUS IN VARCHAR2,
       x_DEFERRED_ADM_CAL_TYPE IN VARCHAR2,
       x_DEFERRED_ADM_CI_SEQUENCE_NUM IN NUMBER,
       x_DEFERRED_TRACKING_ID IN NUMBER,
       x_ASS_RANK IN NUMBER,
       x_SECONDARY_ASS_RANK IN NUMBER,
       x_intr_accept_advice_num IN NUMBER,
       x_ASS_TRACKING_ID IN NUMBER,
       x_FEE_CAT IN VARCHAR2,
       x_HECS_PAYMENT_OPTION IN VARCHAR2,
       x_EXPECTED_COMPLETION_YR IN NUMBER,
       x_EXPECTED_COMPLETION_PERD IN VARCHAR2,
       x_CORRESPONDENCE_CAT IN VARCHAR2,
       x_ENROLMENT_CAT IN VARCHAR2,
       x_FUNDING_SOURCE IN VARCHAR2,
       x_APPLICANT_ACPTNCE_CNDTN IN VARCHAR2,
       x_CNDTNL_OFFER_CNDTN IN VARCHAR2,
      X_MODE in VARCHAR2,
      X_SS_APPLICATION_ID IN VARCHAR2,
      X_SS_PWD IN VARCHAR2,
      X_AUTHORIZED_DT IN DATE,
      X_AUTHORIZING_PERS_ID IN NUMBER,
      x_entry_status IN NUMBER,
      x_entry_level IN NUMBER,
      x_sch_apl_to_id IN NUMBER,
      x_idx_calc_date IN DATE,
      x_waitlist_status IN VARCHAR2,
      x_ATTRIBUTE21 IN VARCHAR2 ,
       x_ATTRIBUTE22 IN VARCHAR2,
       x_ATTRIBUTE23 IN VARCHAR2,
       x_ATTRIBUTE24 IN VARCHAR2,
       x_ATTRIBUTE25 IN VARCHAR2,
       x_ATTRIBUTE26 IN VARCHAR2,
       x_ATTRIBUTE27 IN VARCHAR2,
       x_ATTRIBUTE28 IN VARCHAR2,
       x_ATTRIBUTE29 IN VARCHAR2,
       x_ATTRIBUTE30 IN VARCHAR2,
       x_ATTRIBUTE31 IN VARCHAR2,
       x_ATTRIBUTE32 IN VARCHAR2,
       x_ATTRIBUTE33 IN VARCHAR2,
       x_ATTRIBUTE34 IN VARCHAR2,
       x_ATTRIBUTE35 IN VARCHAR2,
       x_ATTRIBUTE36 IN VARCHAR2,
       x_ATTRIBUTE37 IN VARCHAR2,
       x_ATTRIBUTE38 IN VARCHAR2,
       x_ATTRIBUTE39 IN VARCHAR2,
       x_ATTRIBUTE40 IN VARCHAR2,
       x_fut_acad_cal_type           IN VARCHAR2,
       x_fut_acad_ci_sequence_number IN NUMBER  ,
       x_fut_adm_cal_type            IN VARCHAR2,
       x_fut_adm_ci_sequence_number  IN NUMBER  ,
       x_prev_term_adm_appl_number  IN NUMBER  ,
       x_prev_term_sequence_number  IN NUMBER  ,
       x_fut_term_adm_appl_number    IN NUMBER  ,
       x_fut_term_sequence_number    IN NUMBER  ,
      x_def_acad_cal_type IN VARCHAR2,
      x_def_acad_ci_sequence_num  IN NUMBER  ,
      x_def_prev_term_adm_appl_num  IN NUMBER  ,
      x_def_prev_appl_sequence_num  IN NUMBER  ,
      x_def_term_adm_appl_num  IN NUMBER  ,
      x_def_appl_sequence_num  IN NUMBER  ,
      x_appl_inst_status	IN VARCHAR2,						--arvsrini igsm
      x_ais_reason		IN VARCHAR2,
      x_decline_ofr_reason	IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor C is select ROWID from IGS_AD_PS_APPL_INST_ALL
     where  PERSON_ID= X_PERSON_ID
            and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
            and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
            and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if(X_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (X_MODE IN ('R', 'S')) then
      X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      if X_LAST_UPDATED_BY is NULL then
        X_LAST_UPDATED_BY := -1;
      end if;
      X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
      if X_LAST_UPDATE_LOGIN is NULL then
        X_LAST_UPDATE_LOGIN := -1;
      end if;
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID =  -1) then
        X_REQUEST_ID := NULL;
        X_PROGRAM_ID := NULL;
        X_PROGRAM_APPLICATION_ID := NULL;
        X_PROGRAM_UPDATE_DATE := NULL;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    else
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    end if;
   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
                x_org_id => igs_ge_gen_003.get_org_id,
               x_person_id=>X_PERSON_ID,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_predicted_gpa=>X_PREDICTED_GPA,
               x_academic_index=>X_ACADEMIC_INDEX,
               x_adm_cal_type=>X_ADM_CAL_TYPE,
               x_app_file_location=>X_APP_FILE_LOCATION,
               x_adm_ci_sequence_number=>X_ADM_CI_SEQUENCE_NUMBER,
               x_course_cd=>X_COURSE_CD,
               x_app_source_id=>X_APP_SOURCE_ID,
               x_crv_version_number=>X_CRV_VERSION_NUMBER,
               x_waitlist_rank=>X_WAITLIST_RANK,
               x_location_cd=>X_LOCATION_CD,
               x_attent_other_inst_cd=>X_ATTENT_OTHER_INST_CD,
               x_attendance_mode=>X_ATTENDANCE_MODE,
               x_edu_goal_prior_enroll_id=>X_EDU_GOAL_PRIOR_ENROLL_ID,
               x_attendance_type=>X_ATTENDANCE_TYPE,
               x_decision_make_id=>X_DECISION_MAKE_ID,
               x_unit_set_cd=>X_UNIT_SET_CD,
               x_decision_date=>X_DECISION_DATE,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_attribute2=>X_ATTRIBUTE2,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_attribute11=>X_ATTRIBUTE11,
               x_attribute12=>X_ATTRIBUTE12,
               x_attribute13=>X_ATTRIBUTE13,
               x_attribute14=>X_ATTRIBUTE14,
               x_attribute15=>X_ATTRIBUTE15,
               x_attribute16=>X_ATTRIBUTE16,
               x_attribute17=>X_ATTRIBUTE17,
               x_attribute18=>X_ATTRIBUTE18,
               x_attribute19=>X_ATTRIBUTE19,
               x_attribute20=>X_ATTRIBUTE20,
               x_decision_reason_id=>X_DECISION_REASON_ID,
               x_us_version_number=>X_US_VERSION_NUMBER,
               x_decision_notes=>X_DECISION_NOTES,
               x_pending_reason_id=>X_PENDING_REASON_ID,
               x_preference_number=>X_PREFERENCE_NUMBER,
               x_adm_doc_status=>X_ADM_DOC_STATUS,
               x_adm_entry_qual_status=>X_ADM_ENTRY_QUAL_STATUS,
               x_deficiency_in_prep=>X_DEFICIENCY_IN_PREP,
               x_late_adm_fee_status=>X_LATE_ADM_FEE_STATUS,
               x_spl_consider_comments=>X_SPL_CONSIDER_COMMENTS,
               x_apply_for_finaid=>X_APPLY_FOR_FINAID,
               x_finaid_apply_date=>X_FINAID_APPLY_DATE,
               x_adm_outcome_status=>X_ADM_OUTCOME_STATUS,
               x_adm_otcm_stat_auth_per_id=>x_adm_otcm_stat_auth_per_id,
               x_adm_outcome_status_auth_dt=>X_ADM_OUTCOME_STATUS_AUTH_DT,
               x_adm_outcome_status_reason=>X_ADM_OUTCOME_STATUS_REASON,
               x_offer_dt=>X_OFFER_DT,
               x_offer_response_dt=>X_OFFER_RESPONSE_DT,
               x_prpsd_commencement_dt=>X_PRPSD_COMMENCEMENT_DT,
               x_adm_cndtnl_offer_status=>X_ADM_CNDTNL_OFFER_STATUS,
               x_cndtnl_offer_satisfied_dt=>X_CNDTNL_OFFER_SATISFIED_DT,
               x_cndnl_ofr_must_be_stsfd_ind=>NVL(x_cndnl_ofr_must_be_stsfd_ind,'N' ),
               x_adm_offer_resp_status=>X_ADM_OFFER_RESP_STATUS,
               x_actual_response_dt=>X_ACTUAL_RESPONSE_DT,
               x_adm_offer_dfrmnt_status=>X_ADM_OFFER_DFRMNT_STATUS,
               x_deferred_adm_cal_type=>X_DEFERRED_ADM_CAL_TYPE,
               x_deferred_adm_ci_sequence_num=>X_DEFERRED_ADM_CI_SEQUENCE_NUM,
               x_deferred_tracking_id=>X_DEFERRED_TRACKING_ID,
               x_ass_rank=>X_ASS_RANK,
               x_secondary_ass_rank=>X_SECONDARY_ASS_RANK,
               x_intr_accept_advice_num=>x_intr_accept_advice_num,
               x_ass_tracking_id=>X_ASS_TRACKING_ID,
               x_fee_cat=>X_FEE_CAT,
               x_hecs_payment_option=>X_HECS_PAYMENT_OPTION,
               x_expected_completion_yr=>X_EXPECTED_COMPLETION_YR,
               x_expected_completion_perd=>X_EXPECTED_COMPLETION_PERD,
               x_correspondence_cat=>X_CORRESPONDENCE_CAT,
               x_enrolment_cat=>X_ENROLMENT_CAT,
               x_funding_source=>X_FUNDING_SOURCE,
               x_applicant_acptnce_cndtn=>X_APPLICANT_ACPTNCE_CNDTN,
               x_cndtnl_offer_cndtn=>X_CNDTNL_OFFER_CNDTN,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               X_SS_APPLICATION_ID => X_SS_APPLICATION_ID,
               X_SS_PWD => X_SS_PWD,
               X_AUTHORIZED_DT => X_AUTHORIZED_DT,
               X_AUTHORIZING_PERS_ID  => X_AUTHORIZING_PERS_ID,
               x_entry_status => x_entry_status,
               x_entry_level => x_entry_level,
               x_sch_apl_to_id => x_sch_apl_to_id,
               x_idx_calc_date => x_idx_calc_date,
               x_waitlist_status =>x_waitlist_status,
               x_attribute21=>X_ATTRIBUTE21,
               x_attribute22=>X_ATTRIBUTE22,
               x_attribute23=>X_ATTRIBUTE23,
               x_attribute24=>X_ATTRIBUTE24,
               x_attribute25=>X_ATTRIBUTE25,
               x_attribute26=>X_ATTRIBUTE26,
               x_attribute27=>X_ATTRIBUTE27,
               x_attribute28=>X_ATTRIBUTE28,
               x_attribute29=>X_ATTRIBUTE29,
               x_attribute30=>X_ATTRIBUTE30,
               x_attribute31=>X_ATTRIBUTE31,
               x_attribute32=>X_ATTRIBUTE32,
               x_attribute33=>X_ATTRIBUTE33,
               x_attribute34=>X_ATTRIBUTE34,
               x_attribute35=>X_ATTRIBUTE35,
               x_attribute36=>X_ATTRIBUTE36,
               x_attribute37=>X_ATTRIBUTE37,
               x_attribute38=>X_ATTRIBUTE38,
               x_attribute39=>X_ATTRIBUTE39,
               x_attribute40=>X_ATTRIBUTE40,
               x_fut_acad_cal_type           => x_fut_acad_cal_type,
               x_fut_acad_ci_sequence_number => x_fut_acad_ci_sequence_number ,
               x_fut_adm_cal_type            => x_fut_adm_cal_type,
               x_fut_adm_ci_sequence_number  => x_fut_adm_ci_sequence_number,
               x_prev_term_adm_appl_number  => x_prev_term_adm_appl_number,
               x_prev_term_sequence_number  => x_prev_term_sequence_number,
               x_fut_term_adm_appl_number    => x_fut_term_adm_appl_number ,
               x_fut_term_sequence_number    => x_fut_term_sequence_number,
               x_def_acad_cal_type     =>       x_def_acad_cal_type,
               x_def_acad_ci_sequence_num      =>x_def_acad_ci_sequence_num,
               x_def_prev_term_adm_appl_num      =>x_def_prev_term_adm_appl_num,
               x_def_prev_appl_sequence_num      =>x_def_prev_appl_sequence_num,
               x_def_term_adm_appl_num      =>       x_def_term_adm_appl_num,
               x_def_appl_sequence_num      =>       x_def_appl_sequence_num,
	       x_appl_inst_status	    =>  x_appl_inst_status,				--arvsrini igsm
	       x_ais_reason		    =>  x_ais_reason,
	       x_decline_ofr_reason	    =>  x_decline_ofr_reason
               );
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_AD_PS_APPL_INST_ALL (
                ORG_ID,
                PERSON_ID
                ,ADMISSION_APPL_NUMBER
                ,NOMINATED_COURSE_CD
                ,SEQUENCE_NUMBER
                ,PREDICTED_GPA
                ,ACADEMIC_INDEX
                ,ADM_CAL_TYPE
                ,APP_FILE_LOCATION
                ,ADM_CI_SEQUENCE_NUMBER
                ,COURSE_CD
                ,APP_SOURCE_ID
                ,CRV_VERSION_NUMBER
                ,WAITLIST_RANK
                ,LOCATION_CD
                ,ATTENT_OTHER_INST_CD
                ,ATTENDANCE_MODE
                ,EDU_GOAL_PRIOR_ENROLL_ID
                ,ATTENDANCE_TYPE
                ,DECISION_MAKE_ID
                ,UNIT_SET_CD
                ,DECISION_DATE
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,ATTRIBUTE16
                ,ATTRIBUTE17
                ,ATTRIBUTE18
                ,ATTRIBUTE19
                ,ATTRIBUTE20
                ,DECISION_REASON_ID
                ,US_VERSION_NUMBER
                ,DECISION_NOTES
                ,PENDING_REASON_ID
                ,PREFERENCE_NUMBER
                ,ADM_DOC_STATUS
                ,ADM_ENTRY_QUAL_STATUS
                ,DEFICIENCY_IN_PREP
                ,LATE_ADM_FEE_STATUS
                ,SPL_CONSIDER_COMMENTS
                ,APPLY_FOR_FINAID
                ,FINAID_APPLY_DATE
                ,ADM_OUTCOME_STATUS
                ,ADM_OTCM_STATUS_AUTH_PERSON_ID
                ,ADM_OUTCOME_STATUS_AUTH_DT
                ,ADM_OUTCOME_STATUS_REASON
                ,OFFER_DT
                ,OFFER_RESPONSE_DT
                ,PRPSD_COMMENCEMENT_DT
                ,ADM_CNDTNL_OFFER_STATUS
                ,CNDTNL_OFFER_SATISFIED_DT
                ,CNDTNL_OFFER_MUST_BE_STSFD_IND
                ,ADM_OFFER_RESP_STATUS
                ,ACTUAL_RESPONSE_DT
                ,ADM_OFFER_DFRMNT_STATUS
                ,DEFERRED_ADM_CAL_TYPE
                ,DEFERRED_ADM_CI_SEQUENCE_NUM
                ,DEFERRED_TRACKING_ID
                ,ASS_RANK
                ,SECONDARY_ASS_RANK
                ,INTRNTNL_ACCEPTANCE_ADVICE_NUM
                ,ASS_TRACKING_ID
                ,FEE_CAT
                ,HECS_PAYMENT_OPTION
                ,EXPECTED_COMPLETION_YR
                ,EXPECTED_COMPLETION_PERD
                ,CORRESPONDENCE_CAT
                ,ENROLMENT_CAT
                ,FUNDING_SOURCE
                ,APPLICANT_ACPTNCE_CNDTN
                ,CNDTNL_OFFER_CNDTN
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,REQUEST_ID
                ,PROGRAM_ID
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_UPDATE_DATE
                ,SS_APPLICATION_ID
                ,SS_PWD
                ,AUTHORIZED_DT
                ,AUTHORIZING_PERS_ID
                ,ENTRY_STATUS
                ,ENTRY_LEVEL
                ,SCH_APL_TO_ID
                ,IDX_CALC_DATE
                ,WAITLIST_STATUS
                ,ATTRIBUTE21
                ,ATTRIBUTE22
                ,ATTRIBUTE23
                ,ATTRIBUTE24
                ,ATTRIBUTE25
                ,ATTRIBUTE26
                ,ATTRIBUTE27
                ,ATTRIBUTE28
                ,ATTRIBUTE29
                ,ATTRIBUTE30
                ,ATTRIBUTE31
                ,ATTRIBUTE32
                ,ATTRIBUTE33
                ,ATTRIBUTE34
                ,ATTRIBUTE35
                ,ATTRIBUTE36
                ,ATTRIBUTE37
                ,ATTRIBUTE38
                ,ATTRIBUTE39
                ,ATTRIBUTE40
                ,future_acad_cal_type
                ,future_acad_ci_sequence_number
                ,future_adm_cal_type
                ,future_adm_ci_sequence_number
                ,previous_term_adm_appl_number
                ,previous_term_sequence_number
                ,future_term_adm_appl_number
                ,future_term_sequence_number
                ,def_acad_cal_type
                ,def_acad_ci_sequence_num
                ,def_prev_term_adm_appl_num
                ,def_prev_appl_sequence_num
                ,def_term_adm_appl_num
                ,def_appl_sequence_num
		,appl_inst_status							--arvsrini igsm
		,ais_reason
		,decline_ofr_reason
        ) values  (
                NEW_REFERENCES.ORG_ID
                ,NEW_REFERENCES.PERSON_ID
                ,NEW_REFERENCES.ADMISSION_APPL_NUMBER
                ,NEW_REFERENCES.NOMINATED_COURSE_CD
                ,NEW_REFERENCES.SEQUENCE_NUMBER
                ,NEW_REFERENCES.PREDICTED_GPA
                ,NEW_REFERENCES.ACADEMIC_INDEX
                ,NEW_REFERENCES.ADM_CAL_TYPE
                ,NEW_REFERENCES.APP_FILE_LOCATION
                ,NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER
                ,NEW_REFERENCES.COURSE_CD
                ,NEW_REFERENCES.APP_SOURCE_ID
                ,NEW_REFERENCES.CRV_VERSION_NUMBER
                ,NEW_REFERENCES.WAITLIST_RANK
                ,NEW_REFERENCES.LOCATION_CD
                ,NEW_REFERENCES.ATTENT_OTHER_INST_CD
                ,NEW_REFERENCES.ATTENDANCE_MODE
                ,NEW_REFERENCES.EDU_GOAL_PRIOR_ENROLL_ID
                ,NEW_REFERENCES.ATTENDANCE_TYPE
                ,NEW_REFERENCES.DECISION_MAKE_ID
                ,NEW_REFERENCES.UNIT_SET_CD
                ,NEW_REFERENCES.DECISION_DATE
                ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
                ,NEW_REFERENCES.ATTRIBUTE1
                ,NEW_REFERENCES.ATTRIBUTE2
                ,NEW_REFERENCES.ATTRIBUTE3
                ,NEW_REFERENCES.ATTRIBUTE4
                ,NEW_REFERENCES.ATTRIBUTE5
                ,NEW_REFERENCES.ATTRIBUTE6
                ,NEW_REFERENCES.ATTRIBUTE7
                ,NEW_REFERENCES.ATTRIBUTE8
                ,NEW_REFERENCES.ATTRIBUTE9
                ,NEW_REFERENCES.ATTRIBUTE10
                ,NEW_REFERENCES.ATTRIBUTE11
                ,NEW_REFERENCES.ATTRIBUTE12
                ,NEW_REFERENCES.ATTRIBUTE13
                ,NEW_REFERENCES.ATTRIBUTE14
                ,NEW_REFERENCES.ATTRIBUTE15
                ,NEW_REFERENCES.ATTRIBUTE16
                ,NEW_REFERENCES.ATTRIBUTE17
                ,NEW_REFERENCES.ATTRIBUTE18
                ,NEW_REFERENCES.ATTRIBUTE19
                ,NEW_REFERENCES.ATTRIBUTE20
                ,NEW_REFERENCES.DECISION_REASON_ID
                ,NEW_REFERENCES.US_VERSION_NUMBER
                ,NEW_REFERENCES.DECISION_NOTES
                ,NEW_REFERENCES.PENDING_REASON_ID
                ,NEW_REFERENCES.PREFERENCE_NUMBER
                ,NEW_REFERENCES.ADM_DOC_STATUS
                ,NEW_REFERENCES.ADM_ENTRY_QUAL_STATUS
                ,NEW_REFERENCES.DEFICIENCY_IN_PREP
                ,NEW_REFERENCES.LATE_ADM_FEE_STATUS
                ,NEW_REFERENCES.SPL_CONSIDER_COMMENTS
                ,NEW_REFERENCES.APPLY_FOR_FINAID
                ,NEW_REFERENCES.FINAID_APPLY_DATE
                ,NEW_REFERENCES.ADM_OUTCOME_STATUS
                ,NEW_REFERENCES.ADM_OTCM_STATUS_AUTH_PERSON_ID
                ,NEW_REFERENCES.ADM_OUTCOME_STATUS_AUTH_DT
                ,NEW_REFERENCES.ADM_OUTCOME_STATUS_REASON
                ,NEW_REFERENCES.OFFER_DT
                ,NEW_REFERENCES.OFFER_RESPONSE_DT
                ,NEW_REFERENCES.PRPSD_COMMENCEMENT_DT
                ,NEW_REFERENCES.ADM_CNDTNL_OFFER_STATUS
                ,NEW_REFERENCES.CNDTNL_OFFER_SATISFIED_DT
                ,NEW_REFERENCES.CNDTNL_OFFER_MUST_BE_STSFD_IND
                ,NEW_REFERENCES.ADM_OFFER_RESP_STATUS
                ,NEW_REFERENCES.ACTUAL_RESPONSE_DT
                ,NEW_REFERENCES.ADM_OFFER_DFRMNT_STATUS
                ,NEW_REFERENCES.DEFERRED_ADM_CAL_TYPE
                ,NEW_REFERENCES.DEFERRED_ADM_CI_SEQUENCE_NUM
                ,NEW_REFERENCES.DEFERRED_TRACKING_ID
                ,NEW_REFERENCES.ASS_RANK
                ,NEW_REFERENCES.SECONDARY_ASS_RANK
                ,NEW_REFERENCES.INTRNTNL_ACCEPTANCE_ADVICE_NUM
                ,NEW_REFERENCES.ASS_TRACKING_ID
                ,NEW_REFERENCES.FEE_CAT
                ,NEW_REFERENCES.HECS_PAYMENT_OPTION
                ,NEW_REFERENCES.EXPECTED_COMPLETION_YR
                ,NEW_REFERENCES.EXPECTED_COMPLETION_PERD
                ,NEW_REFERENCES.CORRESPONDENCE_CAT
                ,NEW_REFERENCES.ENROLMENT_CAT
                ,NEW_REFERENCES.FUNDING_SOURCE
                ,NEW_REFERENCES.APPLICANT_ACPTNCE_CNDTN
                ,NEW_REFERENCES.CNDTNL_OFFER_CNDTN
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,X_REQUEST_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_UPDATE_DATE
                ,NEW_REFERENCES.SS_APPLICATION_ID
                ,NEW_REFERENCES.SS_PWD
                ,NEW_REFERENCES.AUTHORIZED_DT
                ,NEW_REFERENCES.AUTHORIZING_PERS_ID
                ,NEW_REFERENCES.ENTRY_STATUS
                ,NEW_REFERENCES.ENTRY_LEVEL
                ,NEW_REFERENCES.SCH_APL_TO_ID
                ,NEW_REFERENCES.IDX_CALC_DATE
                ,NEW_REFERENCES.WAITLIST_STATUS
                ,NEW_REFERENCES.ATTRIBUTE21
                ,NEW_REFERENCES.ATTRIBUTE22
                ,NEW_REFERENCES.ATTRIBUTE23
                ,NEW_REFERENCES.ATTRIBUTE24
                ,NEW_REFERENCES.ATTRIBUTE25
                ,NEW_REFERENCES.ATTRIBUTE26
                ,NEW_REFERENCES.ATTRIBUTE27
                ,NEW_REFERENCES.ATTRIBUTE28
                ,NEW_REFERENCES.ATTRIBUTE29
                ,NEW_REFERENCES.ATTRIBUTE30
                ,NEW_REFERENCES.ATTRIBUTE31
                ,NEW_REFERENCES.ATTRIBUTE32
                ,NEW_REFERENCES.ATTRIBUTE33
                ,NEW_REFERENCES.ATTRIBUTE34
                ,NEW_REFERENCES.ATTRIBUTE35
                ,NEW_REFERENCES.ATTRIBUTE36
                ,NEW_REFERENCES.ATTRIBUTE37
                ,NEW_REFERENCES.ATTRIBUTE38
                ,NEW_REFERENCES.ATTRIBUTE39
                ,NEW_REFERENCES.ATTRIBUTE40
                ,new_references.future_acad_cal_type
                ,new_references.future_acad_ci_sequence_number
                ,new_references.future_adm_cal_type
                ,new_references.future_adm_ci_sequence_number
                ,new_references.previous_term_adm_appl_number
                ,new_references.previous_term_sequence_number
                ,new_references.future_term_adm_appl_number
                ,new_references.future_term_sequence_number
                ,new_references.DEF_ACAD_CAL_TYPE
                ,new_references.DEF_ACAD_CI_SEQUENCE_NUM
                ,new_references.DEF_PREV_TERM_ADM_APPL_NUM
                ,new_references.DEF_PREV_APPL_SEQUENCE_NUM
		,new_references.DEF_TERM_ADM_APPL_NUM
                ,new_references.def_appl_sequence_num
		,new_references.appl_inst_status						--arvsrini igsm
		,new_references.ais_reason
		,new_references.decline_ofr_reason
              );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML(
        p_action                  => 'INSERT',
        x_rowid                   => X_ROWID );
 EXCEPTION
  WHEN OTHERS THEN
   IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
   END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END INSERT_ROW;
 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PREDICTED_GPA IN NUMBER,
       x_ACADEMIC_INDEX IN VARCHAR2,
       x_ADM_CAL_TYPE IN VARCHAR2,
       x_APP_FILE_LOCATION IN VARCHAR2,
       x_ADM_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_APP_SOURCE_ID IN NUMBER,
       x_CRV_VERSION_NUMBER IN NUMBER,
       x_WAITLIST_RANK IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_ATTENT_OTHER_INST_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_EDU_GOAL_PRIOR_ENROLL_ID IN NUMBER,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_DECISION_MAKE_ID IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_DECISION_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_DECISION_REASON_ID IN NUMBER,
       x_US_VERSION_NUMBER IN NUMBER,
       x_DECISION_NOTES IN VARCHAR2,
       x_PENDING_REASON_ID IN NUMBER,
       x_PREFERENCE_NUMBER IN NUMBER,
       x_ADM_DOC_STATUS IN VARCHAR2,
       x_ADM_ENTRY_QUAL_STATUS IN VARCHAR2,
       x_DEFICIENCY_IN_PREP IN VARCHAR2,
       x_LATE_ADM_FEE_STATUS IN VARCHAR2,
       x_SPL_CONSIDER_COMMENTS IN VARCHAR2,
       x_APPLY_FOR_FINAID IN VARCHAR2,
       x_FINAID_APPLY_DATE IN DATE,
       x_ADM_OUTCOME_STATUS IN VARCHAR2,
       x_adm_otcm_stat_auth_per_id IN NUMBER,
       x_ADM_OUTCOME_STATUS_AUTH_DT IN DATE,
       x_ADM_OUTCOME_STATUS_REASON IN VARCHAR2,
       x_OFFER_DT IN DATE,
       x_OFFER_RESPONSE_DT IN DATE,
       x_PRPSD_COMMENCEMENT_DT IN DATE,
       x_ADM_CNDTNL_OFFER_STATUS IN VARCHAR2,
       x_CNDTNL_OFFER_SATISFIED_DT IN DATE,
       x_cndnl_ofr_must_be_stsfd_ind IN VARCHAR2,
       x_ADM_OFFER_RESP_STATUS IN VARCHAR2,
       x_ACTUAL_RESPONSE_DT IN DATE,
       x_ADM_OFFER_DFRMNT_STATUS IN VARCHAR2,
       x_DEFERRED_ADM_CAL_TYPE IN VARCHAR2,
       x_DEFERRED_ADM_CI_SEQUENCE_NUM IN NUMBER,
       x_DEFERRED_TRACKING_ID IN NUMBER,
       x_ASS_RANK IN NUMBER,
       x_SECONDARY_ASS_RANK IN NUMBER,
       x_intr_accept_advice_num IN NUMBER,
       x_ASS_TRACKING_ID IN NUMBER,
       x_FEE_CAT IN VARCHAR2,
       x_HECS_PAYMENT_OPTION IN VARCHAR2,
       x_EXPECTED_COMPLETION_YR IN NUMBER,
       x_EXPECTED_COMPLETION_PERD IN VARCHAR2,
       x_CORRESPONDENCE_CAT IN VARCHAR2,
       x_ENROLMENT_CAT IN VARCHAR2,
       x_FUNDING_SOURCE IN VARCHAR2,
       x_APPLICANT_ACPTNCE_CNDTN IN VARCHAR2,
       x_CNDTNL_OFFER_CNDTN IN VARCHAR2,
       X_SS_APPLICATION_ID IN VARCHAR2,
       X_SS_PWD IN VARCHAR2 ,
       X_AUTHORIZED_DT DATE,
       X_AUTHORIZING_PERS_ID NUMBER,
       x_entry_status IN NUMBER,
       x_entry_level IN NUMBER,
       x_sch_apl_to_id IN NUMBER,
       x_idx_calc_date IN DATE,
       x_waitlist_status IN VARCHAR2,
       x_ATTRIBUTE21 IN VARCHAR2,
       x_ATTRIBUTE22 IN VARCHAR2,
       x_ATTRIBUTE23 IN VARCHAR2,
       x_ATTRIBUTE24 IN VARCHAR2,
       x_ATTRIBUTE25 IN VARCHAR2,
       x_ATTRIBUTE26 IN VARCHAR2,
       x_ATTRIBUTE27 IN VARCHAR2,
       x_ATTRIBUTE28 IN VARCHAR2,
       x_ATTRIBUTE29 IN VARCHAR2,
       x_ATTRIBUTE30 IN VARCHAR2,
       x_ATTRIBUTE31 IN VARCHAR2,
       x_ATTRIBUTE32 IN VARCHAR2,
       x_ATTRIBUTE33 IN VARCHAR2,
       x_ATTRIBUTE34 IN VARCHAR2,
       x_ATTRIBUTE35 IN VARCHAR2,
       x_ATTRIBUTE36 IN VARCHAR2,
       x_ATTRIBUTE37 IN VARCHAR2,
       x_ATTRIBUTE38 IN VARCHAR2,
       x_ATTRIBUTE39 IN VARCHAR2,
       x_ATTRIBUTE40 IN VARCHAR2,
       x_fut_acad_cal_type           IN VARCHAR2,
       x_fut_acad_ci_sequence_number IN NUMBER  ,
       x_fut_adm_cal_type            IN VARCHAR2,
       x_fut_adm_ci_sequence_number  IN NUMBER  ,
       x_prev_term_adm_appl_number  IN NUMBER  ,
       x_prev_term_sequence_number  IN NUMBER  ,
       x_fut_term_adm_appl_number    IN NUMBER  ,
       x_fut_term_sequence_number    IN NUMBER  ,
       x_def_acad_cal_type IN VARCHAR2,
       x_def_acad_ci_sequence_num  IN NUMBER  ,
       x_def_prev_term_adm_appl_num  IN NUMBER  ,
       x_def_prev_appl_sequence_num  IN NUMBER  ,
       x_def_term_adm_appl_num  IN NUMBER  ,
       x_def_appl_sequence_num  IN NUMBER  ,
       x_appl_inst_status	IN VARCHAR2,						--arvsrini igsm
       x_ais_reason		IN VARCHAR2,
       x_decline_ofr_reason	IN VARCHAR2
 ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
   cursor c1 is select
      PERSON_ID
,     PREDICTED_GPA
,      ACADEMIC_INDEX
,      ADM_CAL_TYPE
,      APP_FILE_LOCATION
,      ADM_CI_SEQUENCE_NUMBER
,      COURSE_CD
,      APP_SOURCE_ID
,      CRV_VERSION_NUMBER
,      WAITLIST_RANK
,      LOCATION_CD
,      ATTENT_OTHER_INST_CD
,      ATTENDANCE_MODE
,      EDU_GOAL_PRIOR_ENROLL_ID
,      ATTENDANCE_TYPE
,      DECISION_MAKE_ID
,      UNIT_SET_CD
,      DECISION_DATE
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      DECISION_REASON_ID
,      US_VERSION_NUMBER
,      DECISION_NOTES
,      PENDING_REASON_ID
,      PREFERENCE_NUMBER
,      ADM_DOC_STATUS
,      ADM_ENTRY_QUAL_STATUS
,      DEFICIENCY_IN_PREP
,      LATE_ADM_FEE_STATUS
,      SPL_CONSIDER_COMMENTS
,      APPLY_FOR_FINAID
,      FINAID_APPLY_DATE
,      ADM_OUTCOME_STATUS
,      ADM_OTCM_STATUS_AUTH_PERSON_ID
,      ADM_OUTCOME_STATUS_AUTH_DT
,      ADM_OUTCOME_STATUS_REASON
,      OFFER_DT
,      OFFER_RESPONSE_DT
,      PRPSD_COMMENCEMENT_DT
,      ADM_CNDTNL_OFFER_STATUS
,      CNDTNL_OFFER_SATISFIED_DT
,      CNDTNL_OFFER_MUST_BE_STSFD_IND
,      ADM_OFFER_RESP_STATUS
,      ACTUAL_RESPONSE_DT
,      ADM_OFFER_DFRMNT_STATUS
,      DEFERRED_ADM_CAL_TYPE
,      DEFERRED_ADM_CI_SEQUENCE_NUM
,      DEFERRED_TRACKING_ID
,      ASS_RANK
,      SECONDARY_ASS_RANK
,      INTRNTNL_ACCEPTANCE_ADVICE_NUM
,      ASS_TRACKING_ID
,      FEE_CAT
,      HECS_PAYMENT_OPTION
,      EXPECTED_COMPLETION_YR
,      EXPECTED_COMPLETION_PERD
,      CORRESPONDENCE_CAT
,      ENROLMENT_CAT
,      FUNDING_SOURCE
,      APPLICANT_ACPTNCE_CNDTN
,      CNDTNL_OFFER_CNDTN
,      SS_APPLICATION_ID
,      SS_PWD
,      AUTHORIZED_DT
,      AUTHORIZING_PERS_ID
     ,ENTRY_STATUS
      ,ENTRY_LEVEL
      ,SCH_APL_TO_ID
,      IDX_CALC_DATE
,      WAITLIST_STATUS
,      ATTRIBUTE21
,      ATTRIBUTE22
,      ATTRIBUTE23
,      ATTRIBUTE24
,      ATTRIBUTE25
,      ATTRIBUTE26
,      ATTRIBUTE27
,      ATTRIBUTE28
,      ATTRIBUTE29
,      ATTRIBUTE30
,      ATTRIBUTE31
,      ATTRIBUTE32
,      ATTRIBUTE33
,      ATTRIBUTE34
,      ATTRIBUTE35
,      ATTRIBUTE36
,      ATTRIBUTE37
,      ATTRIBUTE38
,      ATTRIBUTE39
,      ATTRIBUTE40
,      future_acad_cal_type
,      future_acad_ci_sequence_number
,      future_adm_cal_type
,      future_adm_ci_sequence_number
,      previous_term_adm_appl_number
,      previous_term_sequence_number
,      future_term_adm_appl_number
,      future_term_sequence_number
,      DEF_ACAD_CAL_TYPE
,      DEF_ACAD_CI_SEQUENCE_NUM
,      DEF_PREV_TERM_ADM_APPL_NUM
,      DEF_PREV_APPL_SEQUENCE_NUM
,      DEF_TERM_ADM_APPL_NUM
,      def_appl_sequence_num
,      appl_inst_status										--arvsrini igsm
,      ais_reason
,      decline_ofr_reason

    from IGS_AD_PS_APPL_INST_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
        IGS_AD_GEN_001.SET_TOKEN('From IGS_AD_PS_APPL_INST ->Parameter : Lock_row ');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

    IF (
         ((tlinfo.predicted_gpa = x_predicted_gpa) OR ((tlinfo.predicted_gpa IS NULL) AND (X_predicted_gpa IS NULL)))
        AND ((tlinfo.academic_index = x_academic_index) OR ((tlinfo.academic_index IS NULL) AND (X_academic_index IS NULL)))
        AND ((tlinfo.adm_cal_type = x_adm_cal_type) OR ((tlinfo.adm_cal_type IS NULL) AND (X_adm_cal_type IS NULL)))
        AND ((tlinfo.app_file_location = x_app_file_location) OR ((tlinfo.app_file_location IS NULL) AND (X_app_file_location IS NULL)))
        AND ((tlinfo.adm_ci_sequence_number = x_adm_ci_sequence_number) OR ((tlinfo.adm_ci_sequence_number IS NULL) AND (X_adm_ci_sequence_number IS NULL)))
        AND ((tlinfo.app_source_id = x_app_source_id) OR ((tlinfo.app_source_id IS NULL) AND (X_app_source_id IS NULL)))
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.crv_version_number = x_crv_version_number)
        AND ((tlinfo.waitlist_rank = x_waitlist_rank) OR ((tlinfo.waitlist_rank IS NULL) AND (X_waitlist_rank IS NULL)))
        AND ((tlinfo.location_cd = x_location_cd) OR ((tlinfo.location_cd IS NULL) AND (X_location_cd IS NULL)))
        AND ((tlinfo.attent_other_inst_cd = x_attent_other_inst_cd) OR ((tlinfo.attent_other_inst_cd IS NULL) AND (X_attent_other_inst_cd IS NULL)))
        AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (X_attendance_mode IS NULL)))
        AND ((tlinfo.edu_goal_prior_enroll_id = x_edu_goal_prior_enroll_id) OR ((tlinfo.edu_goal_prior_enroll_id IS NULL) AND (X_edu_goal_prior_enroll_id IS NULL)))
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND ((tlinfo.decision_make_id = x_decision_make_id) OR ((tlinfo.decision_make_id IS NULL) AND (X_decision_make_id IS NULL)))
        AND ((tlinfo.unit_set_cd = x_unit_set_cd) OR ((tlinfo.unit_set_cd IS NULL) AND (X_unit_set_cd IS NULL)))
        AND ((TRUNC(tlinfo.decision_date) = TRUNC(x_decision_date)) OR ((tlinfo.decision_date IS NULL) AND (X_decision_date IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((tlinfo.decision_reason_id = x_decision_reason_id) OR ((tlinfo.decision_reason_id IS NULL) AND (X_decision_reason_id IS NULL)))
        AND ((tlinfo.us_version_number = x_us_version_number) OR ((tlinfo.us_version_number IS NULL) AND (X_us_version_number IS NULL)))
        AND ((tlinfo.decision_notes = x_decision_notes) OR ((tlinfo.decision_notes IS NULL) AND (X_decision_notes IS NULL)))
        AND ((tlinfo.pending_reason_id = x_pending_reason_id) OR ((tlinfo.pending_reason_id IS NULL) AND (X_pending_reason_id IS NULL)))
        AND ((tlinfo.preference_number = x_preference_number) OR ((tlinfo.preference_number IS NULL) AND (X_preference_number IS NULL)))
        AND (tlinfo.adm_doc_status = x_adm_doc_status)
        AND (tlinfo.adm_entry_qual_status = x_adm_entry_qual_status)
        AND ((tlinfo.deficiency_in_prep = x_deficiency_in_prep) OR ((tlinfo.deficiency_in_prep IS NULL) AND (X_deficiency_in_prep IS NULL)))
        AND (tlinfo.late_adm_fee_status = x_late_adm_fee_status)
        AND ((tlinfo.spl_consider_comments = x_spl_consider_comments) OR ((tlinfo.spl_consider_comments IS NULL) AND (X_spl_consider_comments IS NULL)))
        AND ((tlinfo.apply_for_finaid = x_apply_for_finaid) OR ((tlinfo.apply_for_finaid IS NULL) AND (X_apply_for_finaid IS NULL)))
        AND ((TRUNC(tlinfo.finaid_apply_date) = TRUNC(x_finaid_apply_date)) OR ((tlinfo.finaid_apply_date IS NULL) AND (X_finaid_apply_date IS NULL)))
        AND (tlinfo.adm_outcome_status = x_adm_outcome_status)
        AND ((tlinfo.adm_otcm_status_auth_person_id = x_adm_otcm_stat_auth_per_id) OR ((tlinfo.adm_otcm_status_auth_person_id IS NULL) AND (x_adm_otcm_stat_auth_per_id IS NULL)))
        AND ((TRUNC(tlinfo.adm_outcome_status_auth_dt) = TRUNC(x_adm_outcome_status_auth_dt)) OR ((tlinfo.adm_outcome_status_auth_dt IS NULL) AND (X_adm_outcome_status_auth_dt IS NULL)))
        AND ((tlinfo.adm_outcome_status_reason = x_adm_outcome_status_reason) OR ((tlinfo.adm_outcome_status_reason IS NULL) AND (X_adm_outcome_status_reason IS NULL)))
        AND ((TRUNC(tlinfo.offer_dt) = TRUNC(x_offer_dt)) OR ((tlinfo.offer_dt IS NULL) AND (X_offer_dt IS NULL)))
        AND ((TRUNC(tlinfo.offer_response_dt) = TRUNC(x_offer_response_dt)) OR ((tlinfo.offer_response_dt IS NULL) AND (X_offer_response_dt IS NULL)))
        AND ((TRUNC(tlinfo.prpsd_commencement_dt) = TRUNC(x_prpsd_commencement_dt)) OR ((tlinfo.prpsd_commencement_dt IS NULL) AND (X_prpsd_commencement_dt IS NULL)))
        AND (tlinfo.adm_cndtnl_offer_status = x_adm_cndtnl_offer_status)
        AND ((TRUNC(tlinfo.cndtnl_offer_satisfied_dt) = TRUNC(x_cndtnl_offer_satisfied_dt)) OR ((tlinfo.cndtnl_offer_satisfied_dt IS NULL) AND (X_cndtnl_offer_satisfied_dt IS NULL)))
        AND (tlinfo.cndtnl_offer_must_be_stsfd_ind = x_cndnl_ofr_must_be_stsfd_ind)
        AND (tlinfo.adm_offer_resp_status = x_adm_offer_resp_status)
        AND ((TRUNC(tlinfo.actual_response_dt) = TRUNC(x_actual_response_dt)) OR ((tlinfo.actual_response_dt IS NULL) AND (X_actual_response_dt IS NULL)))
        AND (tlinfo.adm_offer_dfrmnt_status = x_adm_offer_dfrmnt_status)
        AND ((tlinfo.deferred_adm_cal_type = x_deferred_adm_cal_type) OR ((tlinfo.deferred_adm_cal_type IS NULL) AND (X_deferred_adm_cal_type IS NULL)))
        AND ((tlinfo.deferred_adm_ci_sequence_num = x_deferred_adm_ci_sequence_num) OR ((tlinfo.deferred_adm_ci_sequence_num IS NULL) AND (X_deferred_adm_ci_sequence_num IS NULL)))
        AND ((tlinfo.deferred_tracking_id = x_deferred_tracking_id) OR ((tlinfo.deferred_tracking_id IS NULL) AND (X_deferred_tracking_id IS NULL)))
        AND ((tlinfo.ass_rank = x_ass_rank) OR ((tlinfo.ass_rank IS NULL) AND (X_ass_rank IS NULL)))
        AND ((tlinfo.secondary_ass_rank = x_secondary_ass_rank) OR ((tlinfo.secondary_ass_rank IS NULL) AND (X_secondary_ass_rank IS NULL)))
        AND ((tlinfo.intrntnl_acceptance_advice_num = x_intr_accept_advice_num) OR ((tlinfo.intrntnl_acceptance_advice_num IS NULL) AND (x_intr_accept_advice_num IS NULL)))
        AND ((tlinfo.ass_tracking_id = x_ass_tracking_id) OR ((tlinfo.ass_tracking_id IS NULL) AND (X_ass_tracking_id IS NULL)))
        AND ((tlinfo.fee_cat = x_fee_cat) OR ((tlinfo.fee_cat IS NULL) AND (X_fee_cat IS NULL)))
        AND ((tlinfo.hecs_payment_option = x_hecs_payment_option) OR ((tlinfo.hecs_payment_option IS NULL) AND (X_hecs_payment_option IS NULL)))
        AND ((tlinfo.expected_completion_yr = x_expected_completion_yr) OR ((tlinfo.expected_completion_yr IS NULL) AND (X_expected_completion_yr IS NULL)))
        AND ((tlinfo.expected_completion_perd = x_expected_completion_perd) OR ((tlinfo.expected_completion_perd IS NULL) AND (X_expected_completion_perd IS NULL)))
        AND ((tlinfo.correspondence_cat = x_correspondence_cat) OR ((tlinfo.correspondence_cat IS NULL) AND (X_correspondence_cat IS NULL)))
        AND ((tlinfo.enrolment_cat = x_enrolment_cat) OR ((tlinfo.enrolment_cat IS NULL) AND (X_enrolment_cat IS NULL)))
        AND ((tlinfo.funding_source = x_funding_source) OR ((tlinfo.funding_source IS NULL) AND (X_funding_source IS NULL)))
        AND ((tlinfo.applicant_acptnce_cndtn = x_applicant_acptnce_cndtn) OR ((tlinfo.applicant_acptnce_cndtn IS NULL) AND (X_applicant_acptnce_cndtn IS NULL)))
        AND ((tlinfo.cndtnl_offer_cndtn = x_cndtnl_offer_cndtn) OR ((tlinfo.cndtnl_offer_cndtn IS NULL) AND (X_cndtnl_offer_cndtn IS NULL)))
        AND ((tlinfo.ss_application_id = x_ss_application_id) OR ((tlinfo.ss_application_id IS NULL) AND (X_ss_application_id IS NULL)))
        AND ((tlinfo.ss_pwd = x_ss_pwd) OR ((tlinfo.ss_pwd IS NULL) AND (X_ss_pwd IS NULL)))
        AND ((tlinfo.entry_status = x_entry_status) OR ((tlinfo.entry_status IS NULL) AND (X_entry_status IS NULL)))
        AND ((tlinfo.entry_level = x_entry_level) OR ((tlinfo.entry_level IS NULL) AND (X_entry_level IS NULL)))
        AND ((tlinfo.sch_apl_to_id = x_sch_apl_to_id) OR ((tlinfo.sch_apl_to_id IS NULL) AND (X_sch_apl_to_id IS NULL)))
        AND ((TRUNC(tlinfo.authorized_dt) = TRUNC(x_authorized_dt)) OR ((tlinfo.authorized_dt IS NULL) AND (X_authorized_dt IS NULL)))
        AND ((tlinfo.authorizing_pers_id = x_authorizing_pers_id) OR ((tlinfo.authorizing_pers_id IS NULL) AND (X_authorizing_pers_id IS NULL)))
        AND ((TRUNC(tlinfo.idx_calc_date) = TRUNC(x_idx_calc_date)) OR ((tlinfo.idx_calc_date IS NULL) AND (X_idx_calc_date IS NULL)))
        AND ((tlinfo.waitlist_status = x_waitlist_status) OR ((tlinfo.waitlist_status IS NULL) AND (X_waitlist_status IS NULL)))
        AND ((tlinfo.attribute21 = x_attribute21) OR ((tlinfo.attribute21 IS NULL) AND (X_attribute21 IS NULL)))
        AND ((tlinfo.attribute22 = x_attribute22) OR ((tlinfo.attribute22 IS NULL) AND (X_attribute22 IS NULL)))
        AND ((tlinfo.attribute23 = x_attribute23) OR ((tlinfo.attribute23 IS NULL) AND (X_attribute23 IS NULL)))
        AND ((tlinfo.attribute24 = x_attribute24) OR ((tlinfo.attribute24 IS NULL) AND (X_attribute24 IS NULL)))
        AND ((tlinfo.attribute25 = x_attribute25) OR ((tlinfo.attribute25 IS NULL) AND (X_attribute25 IS NULL)))
        AND ((tlinfo.attribute26 = x_attribute26) OR ((tlinfo.attribute26 IS NULL) AND (X_attribute26 IS NULL)))
        AND ((tlinfo.attribute27 = x_attribute27) OR ((tlinfo.attribute27 IS NULL) AND (X_attribute27 IS NULL)))
        AND ((tlinfo.attribute28 = x_attribute28) OR ((tlinfo.attribute28 IS NULL) AND (X_attribute28 IS NULL)))
        AND ((tlinfo.attribute29 = x_attribute29) OR ((tlinfo.attribute29 IS NULL) AND (X_attribute29 IS NULL)))
        AND ((tlinfo.attribute30 = x_attribute30) OR ((tlinfo.attribute30 IS NULL) AND (X_attribute30 IS NULL)))
        AND ((tlinfo.attribute31 = x_attribute31) OR ((tlinfo.attribute31 IS NULL) AND (X_attribute31 IS NULL)))
        AND ((tlinfo.attribute32 = x_attribute32) OR ((tlinfo.attribute32 IS NULL) AND (X_attribute32 IS NULL)))
        AND ((tlinfo.attribute33 = x_attribute33) OR ((tlinfo.attribute33 IS NULL) AND (X_attribute33 IS NULL)))
        AND ((tlinfo.attribute34 = x_attribute34) OR ((tlinfo.attribute34 IS NULL) AND (X_attribute34 IS NULL)))
        AND ((tlinfo.attribute35 = x_attribute35) OR ((tlinfo.attribute35 IS NULL) AND (X_attribute35 IS NULL)))
        AND ((tlinfo.attribute36 = x_attribute36) OR ((tlinfo.attribute36 IS NULL) AND (X_attribute36 IS NULL)))
        AND ((tlinfo.attribute37 = x_attribute37) OR ((tlinfo.attribute37 IS NULL) AND (X_attribute37 IS NULL)))
        AND ((tlinfo.attribute38 = x_attribute38) OR ((tlinfo.attribute38 IS NULL) AND (X_attribute38 IS NULL)))
        AND ((tlinfo.attribute39 = x_attribute39) OR ((tlinfo.attribute39 IS NULL) AND (X_attribute39 IS NULL)))
        AND ((tlinfo.attribute40 = x_attribute40) OR ((tlinfo.attribute40 IS NULL) AND (X_attribute40 IS NULL)))
        AND ((tlinfo.future_acad_cal_type = x_fut_acad_cal_type) OR ((tlinfo.future_acad_cal_type IS NULL)
            AND (x_fut_acad_cal_type IS NULL)))
        AND ((tlinfo.future_acad_ci_sequence_number = x_fut_acad_ci_sequence_number) OR
            ((tlinfo.future_acad_ci_sequence_number IS NULL) AND (x_fut_acad_ci_sequence_number IS NULL)))
        AND ((tlinfo.future_adm_cal_type = x_fut_adm_cal_type) OR ((tlinfo.future_adm_cal_type IS NULL)
            AND (x_fut_adm_cal_type IS NULL)))
        AND ((tlinfo.future_adm_ci_sequence_number = x_fut_adm_ci_sequence_number) OR
            ((tlinfo.future_adm_ci_sequence_number IS NULL) AND (x_fut_adm_ci_sequence_number IS NULL)))
        AND ((tlinfo.previous_term_adm_appl_number = x_prev_term_adm_appl_number) OR
            ((tlinfo.previous_term_adm_appl_number IS NULL) AND (x_prev_term_adm_appl_number IS NULL)))
        AND ((tlinfo.previous_term_sequence_number = x_prev_term_sequence_number) OR
            ((tlinfo.previous_term_sequence_number IS NULL) AND (x_prev_term_sequence_number IS NULL)))
        AND ((tlinfo.future_term_adm_appl_number = x_fut_term_adm_appl_number) OR
            ((tlinfo.future_term_adm_appl_number IS NULL) AND (x_fut_term_adm_appl_number IS NULL)))
        AND ((tlinfo.future_term_sequence_number = x_fut_term_sequence_number) OR
            ((tlinfo.future_term_sequence_number IS NULL) AND (x_fut_term_sequence_number IS NULL)))
        AND ((tlinfo.def_acad_cal_type = x_def_acad_cal_type) OR
            ((tlinfo.def_acad_cal_type IS NULL) AND (x_def_acad_cal_type IS NULL)))
        AND ((tlinfo.def_acad_ci_sequence_num = x_def_acad_ci_sequence_num) OR
            ((tlinfo.def_acad_ci_sequence_num IS NULL) AND (x_def_acad_ci_sequence_num IS NULL)))
        AND ((tlinfo.def_prev_term_adm_appl_num = x_def_prev_term_adm_appl_num) OR
            ((tlinfo.def_prev_term_adm_appl_num IS NULL) AND (x_def_prev_term_adm_appl_num IS NULL)))
        AND ((tlinfo.def_prev_appl_sequence_num = x_def_prev_appl_sequence_num) OR
            ((tlinfo.def_prev_appl_sequence_num IS NULL) AND (x_def_prev_appl_sequence_num IS NULL)))
        AND ((tlinfo.def_term_adm_appl_num = x_def_term_adm_appl_num) OR
            ((tlinfo.def_term_adm_appl_num IS NULL) AND (x_def_term_adm_appl_num IS NULL)))
        AND ((tlinfo.def_appl_sequence_num = x_def_appl_sequence_num) OR
            ((tlinfo.def_appl_sequence_num IS NULL) AND (x_def_appl_sequence_num IS NULL)))

	AND ((tlinfo.appl_inst_status = x_appl_inst_status) OR						--arvsrini igsm
            ((tlinfo.appl_inst_status IS NULL) AND (x_appl_inst_status IS NULL)))
	AND ((tlinfo.ais_reason = x_ais_reason) OR
            ((tlinfo.ais_reason IS NULL) AND (x_ais_reason IS NULL)))
	AND ((tlinfo.decline_ofr_reason = x_decline_ofr_reason) OR
            ((tlinfo.decline_ofr_reason IS NULL) AND (x_decline_ofr_reason IS NULL)))

       ) THEN
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
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PREDICTED_GPA IN NUMBER,
       x_ACADEMIC_INDEX IN VARCHAR2,
       x_ADM_CAL_TYPE IN VARCHAR2,
       x_APP_FILE_LOCATION IN VARCHAR2,
       x_ADM_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_APP_SOURCE_ID IN NUMBER,
       x_CRV_VERSION_NUMBER IN NUMBER,
       x_WAITLIST_RANK IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_ATTENT_OTHER_INST_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_EDU_GOAL_PRIOR_ENROLL_ID IN NUMBER,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_DECISION_MAKE_ID IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_DECISION_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_DECISION_REASON_ID IN NUMBER,
       x_US_VERSION_NUMBER IN NUMBER,
       x_DECISION_NOTES IN VARCHAR2,
       x_PENDING_REASON_ID IN NUMBER,
       x_PREFERENCE_NUMBER IN NUMBER,
       x_ADM_DOC_STATUS IN VARCHAR2,
       x_ADM_ENTRY_QUAL_STATUS IN VARCHAR2,
       x_DEFICIENCY_IN_PREP IN VARCHAR2,
       x_LATE_ADM_FEE_STATUS IN VARCHAR2,
       x_SPL_CONSIDER_COMMENTS IN VARCHAR2,
       x_APPLY_FOR_FINAID IN VARCHAR2,
       x_FINAID_APPLY_DATE IN DATE,
       x_ADM_OUTCOME_STATUS IN VARCHAR2,
       x_adm_otcm_stat_auth_per_id IN NUMBER,
       x_ADM_OUTCOME_STATUS_AUTH_DT IN DATE,
       x_ADM_OUTCOME_STATUS_REASON IN VARCHAR2,
       x_OFFER_DT IN DATE,
       x_OFFER_RESPONSE_DT IN DATE,
       x_PRPSD_COMMENCEMENT_DT IN DATE,
       x_ADM_CNDTNL_OFFER_STATUS IN VARCHAR2,
       x_CNDTNL_OFFER_SATISFIED_DT IN DATE,
       x_cndnl_ofr_must_be_stsfd_ind IN VARCHAR2,
       x_ADM_OFFER_RESP_STATUS IN VARCHAR2,
       x_ACTUAL_RESPONSE_DT IN DATE,
       x_ADM_OFFER_DFRMNT_STATUS IN VARCHAR2,
       x_DEFERRED_ADM_CAL_TYPE IN VARCHAR2,
       x_DEFERRED_ADM_CI_SEQUENCE_NUM IN NUMBER,
       x_DEFERRED_TRACKING_ID IN NUMBER,
       x_ASS_RANK IN NUMBER,
       x_SECONDARY_ASS_RANK IN NUMBER,
       x_intr_accept_advice_num IN NUMBER,
       x_ASS_TRACKING_ID IN NUMBER,
       x_FEE_CAT IN VARCHAR2,
       x_HECS_PAYMENT_OPTION IN VARCHAR2,
       x_EXPECTED_COMPLETION_YR IN NUMBER,
       x_EXPECTED_COMPLETION_PERD IN VARCHAR2,
       x_CORRESPONDENCE_CAT IN VARCHAR2,
       x_ENROLMENT_CAT IN VARCHAR2,
       x_FUNDING_SOURCE IN VARCHAR2,
       x_APPLICANT_ACPTNCE_CNDTN IN VARCHAR2,
       x_CNDTNL_OFFER_CNDTN IN VARCHAR2,
       X_MODE in VARCHAR2,
       X_SS_APPLICATION_ID IN VARCHAR2,
       X_SS_PWD IN VARCHAR2       ,
       X_AUTHORIZED_DT DATE,
       X_AUTHORIZING_PERS_ID NUMBER,
       x_entry_status IN NUMBER,
       x_entry_level IN NUMBER,
       x_sch_apl_to_id IN NUMBER,
       x_idx_calc_date IN DATE,
       x_waitlist_status IN VARCHAR2,
       x_ATTRIBUTE21 IN VARCHAR2,
       x_ATTRIBUTE22 IN VARCHAR2,
       x_ATTRIBUTE23 IN VARCHAR2,
       x_ATTRIBUTE24 IN VARCHAR2,
       x_ATTRIBUTE25 IN VARCHAR2,
       x_ATTRIBUTE26 IN VARCHAR2,
       x_ATTRIBUTE27 IN VARCHAR2,
       x_ATTRIBUTE28 IN VARCHAR2,
       x_ATTRIBUTE29 IN VARCHAR2,
       x_ATTRIBUTE30 IN VARCHAR2,
       x_ATTRIBUTE31 IN VARCHAR2,
       x_ATTRIBUTE32 IN VARCHAR2,
       x_ATTRIBUTE33 IN VARCHAR2,
       x_ATTRIBUTE34 IN VARCHAR2,
       x_ATTRIBUTE35 IN VARCHAR2,
       x_ATTRIBUTE36 IN VARCHAR2,
       x_ATTRIBUTE37 IN VARCHAR2,
       x_ATTRIBUTE38 IN VARCHAR2,
       x_ATTRIBUTE39 IN VARCHAR2,
       x_ATTRIBUTE40 IN VARCHAR2,
       x_fut_acad_cal_type           IN VARCHAR2,
       x_fut_acad_ci_sequence_number IN NUMBER  ,
       x_fut_adm_cal_type            IN VARCHAR2,
       x_fut_adm_ci_sequence_number  IN NUMBER  ,
       x_prev_term_adm_appl_number  IN NUMBER  ,
       x_prev_term_sequence_number  IN NUMBER  ,
       x_fut_term_adm_appl_number    IN NUMBER  ,
       x_fut_term_sequence_number    IN NUMBER  ,
       x_def_acad_cal_type IN VARCHAR2,
       x_def_acad_ci_sequence_num  IN NUMBER  ,
       x_def_prev_term_adm_appl_num  IN NUMBER  ,
       x_def_prev_appl_sequence_num  IN NUMBER  ,
       x_def_term_adm_appl_num  IN NUMBER  ,
       x_def_appl_sequence_num  IN NUMBER  ,
       x_appl_inst_status	IN VARCHAR2,							--arvsrini igsm
       x_ais_reason		IN VARCHAR2,
       x_decline_ofr_reason	IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : nsinha
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  nsinha         Jul 30, 2001     Bug enh no : 1905651 changes.
                                  Added entry_status, entry_level and sch_apl_to_id
                                  to the procedures
  (reverse chronological order - newest change first)
  ***************************************************************/
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
    X_LAST_UPDATE_DATE := SYSDATE;
    if(X_MODE = 'I') then
      X_LAST_UPDATED_BY := 1;
      X_LAST_UPDATE_LOGIN := 0;
    elsif (X_MODE IN ('R', 'S')) then
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
               x_person_id=>X_PERSON_ID,
               x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
               x_nominated_course_cd=>X_NOMINATED_COURSE_CD,
               x_sequence_number=>X_SEQUENCE_NUMBER,
               x_predicted_gpa=>X_PREDICTED_GPA,
               x_academic_index=>X_ACADEMIC_INDEX,
               x_adm_cal_type=>X_ADM_CAL_TYPE,
               x_app_file_location=>X_APP_FILE_LOCATION,
               x_adm_ci_sequence_number=>X_ADM_CI_SEQUENCE_NUMBER,
               x_course_cd=>X_COURSE_CD,
               x_app_source_id=>X_APP_SOURCE_ID,
               x_crv_version_number=>X_CRV_VERSION_NUMBER,
               x_waitlist_rank=>X_WAITLIST_RANK,
               x_location_cd=>X_LOCATION_CD,
               x_attent_other_inst_cd=>X_ATTENT_OTHER_INST_CD,
               x_attendance_mode=>X_ATTENDANCE_MODE,
               x_edu_goal_prior_enroll_id=>X_EDU_GOAL_PRIOR_ENROLL_ID,
               x_attendance_type=>X_ATTENDANCE_TYPE,
               x_decision_make_id=>X_DECISION_MAKE_ID,
               x_unit_set_cd=>X_UNIT_SET_CD,
               x_decision_date=>X_DECISION_DATE,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_attribute2=>X_ATTRIBUTE2,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_attribute11=>X_ATTRIBUTE11,
               x_attribute12=>X_ATTRIBUTE12,
               x_attribute13=>X_ATTRIBUTE13,
               x_attribute14=>X_ATTRIBUTE14,
               x_attribute15=>X_ATTRIBUTE15,
               x_attribute16=>X_ATTRIBUTE16,
               x_attribute17=>X_ATTRIBUTE17,
               x_attribute18=>X_ATTRIBUTE18,
               x_attribute19=>X_ATTRIBUTE19,
               x_attribute20=>X_ATTRIBUTE20,
               x_decision_reason_id=>X_DECISION_REASON_ID,
               x_us_version_number=>X_US_VERSION_NUMBER,
               x_decision_notes=>X_DECISION_NOTES,
               x_pending_reason_id=>X_PENDING_REASON_ID,
               x_preference_number=>X_PREFERENCE_NUMBER,
               x_adm_doc_status=>X_ADM_DOC_STATUS,
               x_adm_entry_qual_status=>X_ADM_ENTRY_QUAL_STATUS,
               x_deficiency_in_prep=>X_DEFICIENCY_IN_PREP,
               x_late_adm_fee_status=>X_LATE_ADM_FEE_STATUS,
               x_spl_consider_comments=>X_SPL_CONSIDER_COMMENTS,
               x_apply_for_finaid=>X_APPLY_FOR_FINAID,
               x_finaid_apply_date=>X_FINAID_APPLY_DATE,
               x_adm_outcome_status=>X_ADM_OUTCOME_STATUS,
               x_adm_otcm_stat_auth_per_id=>x_adm_otcm_stat_auth_per_id,
               x_adm_outcome_status_auth_dt=>X_ADM_OUTCOME_STATUS_AUTH_DT,
               x_adm_outcome_status_reason=>X_ADM_OUTCOME_STATUS_REASON,
               x_offer_dt=>X_OFFER_DT,
               x_offer_response_dt=>X_OFFER_RESPONSE_DT,
               x_prpsd_commencement_dt=>X_PRPSD_COMMENCEMENT_DT,
               x_adm_cndtnl_offer_status=>X_ADM_CNDTNL_OFFER_STATUS,
               x_cndtnl_offer_satisfied_dt=>X_CNDTNL_OFFER_SATISFIED_DT,
               x_cndnl_ofr_must_be_stsfd_ind=>NVL(x_cndnl_ofr_must_be_stsfd_ind,'N' ),
               x_adm_offer_resp_status=>X_ADM_OFFER_RESP_STATUS,
               x_actual_response_dt=>X_ACTUAL_RESPONSE_DT,
               x_adm_offer_dfrmnt_status=>X_ADM_OFFER_DFRMNT_STATUS,
               x_deferred_adm_cal_type=>X_DEFERRED_ADM_CAL_TYPE,
               x_deferred_adm_ci_sequence_num=>X_DEFERRED_ADM_CI_SEQUENCE_NUM,
               x_deferred_tracking_id=>X_DEFERRED_TRACKING_ID,
               x_ass_rank=>X_ASS_RANK,
               x_secondary_ass_rank=>X_SECONDARY_ASS_RANK,
               x_intr_accept_advice_num=>x_intr_accept_advice_num,
               x_ass_tracking_id=>X_ASS_TRACKING_ID,
               x_fee_cat=>X_FEE_CAT,
               x_hecs_payment_option=>X_HECS_PAYMENT_OPTION,
               x_expected_completion_yr=>X_EXPECTED_COMPLETION_YR,
               x_expected_completion_perd=>X_EXPECTED_COMPLETION_PERD,
               x_correspondence_cat=>X_CORRESPONDENCE_CAT,
               x_enrolment_cat=>X_ENROLMENT_CAT,
               x_funding_source=>X_FUNDING_SOURCE,
               x_applicant_acptnce_cndtn=>X_APPLICANT_ACPTNCE_CNDTN,
               x_cndtnl_offer_cndtn=>X_CNDTNL_OFFER_CNDTN,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_ss_application_id => x_ss_application_id,
               x_ss_pwd => x_ss_pwd,
               x_authorized_dt => x_authorized_dt,
               x_authorizing_pers_id => x_authorizing_pers_id,
               x_entry_status => x_entry_status,
               x_entry_level => x_entry_level,
               x_sch_apl_to_id => x_sch_apl_to_id,
               x_idx_calc_date => x_idx_calc_date,
               x_waitlist_status => x_waitlist_status,
               x_attribute21=>X_ATTRIBUTE21,
               x_attribute22=>X_ATTRIBUTE22,
               x_attribute23=>X_ATTRIBUTE23,
               x_attribute24=>X_ATTRIBUTE24,
               x_attribute25=>X_ATTRIBUTE25,
               x_attribute26=>X_ATTRIBUTE26,
               x_attribute27=>X_ATTRIBUTE27,
               x_attribute28=>X_ATTRIBUTE28,
               x_attribute29=>X_ATTRIBUTE29,
               x_attribute30=>X_ATTRIBUTE30,
               x_attribute31=>X_ATTRIBUTE31,
               x_attribute32=>X_ATTRIBUTE32,
               x_attribute33=>X_ATTRIBUTE33,
               x_attribute34=>X_ATTRIBUTE34,
               x_attribute35=>X_ATTRIBUTE35,
               x_attribute36=>X_ATTRIBUTE36,
               x_attribute37=>X_ATTRIBUTE37,
               x_attribute38=>X_ATTRIBUTE38,
               x_attribute39=>X_ATTRIBUTE39,
               x_attribute40=>X_ATTRIBUTE40,
               x_fut_acad_cal_type           => x_fut_acad_cal_type,
               x_fut_acad_ci_sequence_number => x_fut_acad_ci_sequence_number,
               x_fut_adm_cal_type            => x_fut_adm_cal_type,
               x_fut_adm_ci_sequence_number  => x_fut_adm_ci_sequence_number,
               x_prev_term_adm_appl_number  => x_prev_term_adm_appl_number,
               x_prev_term_sequence_number  => x_prev_term_sequence_number,
               x_fut_term_adm_appl_number    => x_fut_term_adm_appl_number,
               x_fut_term_sequence_number    => x_fut_term_sequence_number,
               x_def_acad_cal_type     =>       x_def_acad_cal_type,
               x_def_acad_ci_sequence_num      =>       x_def_acad_ci_sequence_num,
               x_def_prev_term_adm_appl_num      =>       x_def_prev_term_adm_appl_num,
               x_def_prev_appl_sequence_num      =>       x_def_prev_appl_sequence_num,
               x_def_term_adm_appl_num      =>       x_def_term_adm_appl_num,
               x_def_appl_sequence_num      =>       x_def_appl_sequence_num,
	       x_appl_inst_status	    =>       x_appl_inst_status,				--arvsrini igsm
	       x_ais_reason		    =>	     x_ais_reason,
	       x_decline_ofr_reason         =>	     x_decline_ofr_reason
               );

    if (X_MODE IN ('R', 'S')) then
      X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
      if (X_REQUEST_ID = -1) then
        X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
        X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
        X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
        X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
      else
        X_PROGRAM_UPDATE_DATE := SYSDATE;
      end if;
    end if;
     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;

 update IGS_AD_PS_APPL_INST_ALL set
      PREDICTED_GPA =  NEW_REFERENCES.PREDICTED_GPA,
      ACADEMIC_INDEX =  NEW_REFERENCES.ACADEMIC_INDEX,
      ADM_CAL_TYPE =  NEW_REFERENCES.ADM_CAL_TYPE,
      APP_FILE_LOCATION =  NEW_REFERENCES.APP_FILE_LOCATION,
      ADM_CI_SEQUENCE_NUMBER =  NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
      COURSE_CD =  NEW_REFERENCES.COURSE_CD,
      APP_SOURCE_ID =  NEW_REFERENCES.APP_SOURCE_ID,
      CRV_VERSION_NUMBER =  NEW_REFERENCES.CRV_VERSION_NUMBER,
      WAITLIST_RANK =  NEW_REFERENCES.WAITLIST_RANK,
      LOCATION_CD =  NEW_REFERENCES.LOCATION_CD,
      ATTENT_OTHER_INST_CD =  NEW_REFERENCES.ATTENT_OTHER_INST_CD,
      ATTENDANCE_MODE =  NEW_REFERENCES.ATTENDANCE_MODE,
      EDU_GOAL_PRIOR_ENROLL_ID =  NEW_REFERENCES.EDU_GOAL_PRIOR_ENROLL_ID,
      ATTENDANCE_TYPE =  NEW_REFERENCES.ATTENDANCE_TYPE,
      DECISION_MAKE_ID =  NEW_REFERENCES.DECISION_MAKE_ID,
      UNIT_SET_CD =  NEW_REFERENCES.UNIT_SET_CD,
      DECISION_DATE =  NEW_REFERENCES.DECISION_DATE,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
      DECISION_REASON_ID =  NEW_REFERENCES.DECISION_REASON_ID,
      US_VERSION_NUMBER =  NEW_REFERENCES.US_VERSION_NUMBER,
      DECISION_NOTES =  NEW_REFERENCES.DECISION_NOTES,
      PENDING_REASON_ID =  NEW_REFERENCES.PENDING_REASON_ID,
      PREFERENCE_NUMBER =  NEW_REFERENCES.PREFERENCE_NUMBER,
      ADM_DOC_STATUS =  NEW_REFERENCES.ADM_DOC_STATUS,
      ADM_ENTRY_QUAL_STATUS =  NEW_REFERENCES.ADM_ENTRY_QUAL_STATUS,
      DEFICIENCY_IN_PREP =  NEW_REFERENCES.DEFICIENCY_IN_PREP,
      LATE_ADM_FEE_STATUS =  NEW_REFERENCES.LATE_ADM_FEE_STATUS,
      SPL_CONSIDER_COMMENTS =  NEW_REFERENCES.SPL_CONSIDER_COMMENTS,
      APPLY_FOR_FINAID =  NEW_REFERENCES.APPLY_FOR_FINAID,
      FINAID_APPLY_DATE =  NEW_REFERENCES.FINAID_APPLY_DATE,
      ADM_OUTCOME_STATUS =  NEW_REFERENCES.ADM_OUTCOME_STATUS,
      ADM_OTCM_STATUS_AUTH_PERSON_ID =  NEW_REFERENCES.ADM_OTCM_STATUS_AUTH_PERSON_ID,
      ADM_OUTCOME_STATUS_AUTH_DT =  NEW_REFERENCES.ADM_OUTCOME_STATUS_AUTH_DT,
      ADM_OUTCOME_STATUS_REASON =  NEW_REFERENCES.ADM_OUTCOME_STATUS_REASON,
      OFFER_DT =  NEW_REFERENCES.OFFER_DT,
      OFFER_RESPONSE_DT =  NEW_REFERENCES.OFFER_RESPONSE_DT,
      PRPSD_COMMENCEMENT_DT =  NEW_REFERENCES.PRPSD_COMMENCEMENT_DT,
      ADM_CNDTNL_OFFER_STATUS =  NEW_REFERENCES.ADM_CNDTNL_OFFER_STATUS,
      CNDTNL_OFFER_SATISFIED_DT =  NEW_REFERENCES.CNDTNL_OFFER_SATISFIED_DT,
      CNDTNL_OFFER_MUST_BE_STSFD_IND =  NEW_REFERENCES.CNDTNL_OFFER_MUST_BE_STSFD_IND,
      ADM_OFFER_RESP_STATUS =  NEW_REFERENCES.ADM_OFFER_RESP_STATUS,
      ACTUAL_RESPONSE_DT =  NEW_REFERENCES.ACTUAL_RESPONSE_DT,
      ADM_OFFER_DFRMNT_STATUS =  NEW_REFERENCES.ADM_OFFER_DFRMNT_STATUS,
      DEFERRED_ADM_CAL_TYPE =  NEW_REFERENCES.DEFERRED_ADM_CAL_TYPE,
      DEFERRED_ADM_CI_SEQUENCE_NUM =  NEW_REFERENCES.DEFERRED_ADM_CI_SEQUENCE_NUM,
      DEFERRED_TRACKING_ID =  NEW_REFERENCES.DEFERRED_TRACKING_ID,
      ASS_RANK =  NEW_REFERENCES.ASS_RANK,
      SECONDARY_ASS_RANK =  NEW_REFERENCES.SECONDARY_ASS_RANK,
      INTRNTNL_ACCEPTANCE_ADVICE_NUM =  NEW_REFERENCES.INTRNTNL_ACCEPTANCE_ADVICE_NUM,
      ASS_TRACKING_ID =  NEW_REFERENCES.ASS_TRACKING_ID,
      FEE_CAT =  NEW_REFERENCES.FEE_CAT,
      HECS_PAYMENT_OPTION =  NEW_REFERENCES.HECS_PAYMENT_OPTION,
      EXPECTED_COMPLETION_YR =  NEW_REFERENCES.EXPECTED_COMPLETION_YR,
      EXPECTED_COMPLETION_PERD =  NEW_REFERENCES.EXPECTED_COMPLETION_PERD,
      CORRESPONDENCE_CAT =  NEW_REFERENCES.CORRESPONDENCE_CAT,
      ENROLMENT_CAT =  NEW_REFERENCES.ENROLMENT_CAT,
      FUNDING_SOURCE =  NEW_REFERENCES.FUNDING_SOURCE,
      APPLICANT_ACPTNCE_CNDTN =  NEW_REFERENCES.APPLICANT_ACPTNCE_CNDTN,
      CNDTNL_OFFER_CNDTN =  NEW_REFERENCES.CNDTNL_OFFER_CNDTN,
        LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
        LAST_UPDATED_BY = X_LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        REQUEST_ID = X_REQUEST_ID,
        PROGRAM_ID = X_PROGRAM_ID,
        PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
        PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
        SS_APPLICATION_ID = NEW_REFERENCES.SS_APPLICATION_ID,
        SS_PWD = NEW_REFERENCES.SS_PWD,
        AUTHORIZED_DT = NEW_REFERENCES.AUTHORIZED_DT,
        AUTHORIZING_PERS_ID = NEW_REFERENCES.AUTHORIZING_PERS_ID,
      ENTRY_STATUS  =  NEW_REFERENCES.ENTRY_STATUS,
      ENTRY_LEVEL   =  NEW_REFERENCES.ENTRY_LEVEL,
      SCH_APL_TO_ID =  NEW_REFERENCES.SCH_APL_TO_ID,
      IDX_CALC_DATE = NEW_REFERENCES.IDX_CALC_DATE,
      WAITLIST_STATUS = NEW_REFERENCES.WAITLIST_STATUS,
            ATTRIBUTE21 =  NEW_REFERENCES.ATTRIBUTE21,
      ATTRIBUTE22 =  NEW_REFERENCES.ATTRIBUTE22,
      ATTRIBUTE23 =  NEW_REFERENCES.ATTRIBUTE23,
      ATTRIBUTE24 =  NEW_REFERENCES.ATTRIBUTE24,
      ATTRIBUTE25 =  NEW_REFERENCES.ATTRIBUTE25,
      ATTRIBUTE26 =  NEW_REFERENCES.ATTRIBUTE26,
      ATTRIBUTE27 =  NEW_REFERENCES.ATTRIBUTE27,
      ATTRIBUTE28 =  NEW_REFERENCES.ATTRIBUTE28,
      ATTRIBUTE29 =  NEW_REFERENCES.ATTRIBUTE29,
      ATTRIBUTE30 =  NEW_REFERENCES.ATTRIBUTE30,
      ATTRIBUTE31 =  NEW_REFERENCES.ATTRIBUTE31,
      ATTRIBUTE32 =  NEW_REFERENCES.ATTRIBUTE32,
      ATTRIBUTE33 =  NEW_REFERENCES.ATTRIBUTE33,
      ATTRIBUTE34 =  NEW_REFERENCES.ATTRIBUTE34,
      ATTRIBUTE35 =  NEW_REFERENCES.ATTRIBUTE35,
      ATTRIBUTE36 =  NEW_REFERENCES.ATTRIBUTE36,
      ATTRIBUTE37 =  NEW_REFERENCES.ATTRIBUTE37,
      ATTRIBUTE38 =  NEW_REFERENCES.ATTRIBUTE38,
      ATTRIBUTE39 =  NEW_REFERENCES.ATTRIBUTE39,
      ATTRIBUTE40 =  NEW_REFERENCES.ATTRIBUTE40,
      future_acad_cal_type           = new_references.future_acad_cal_type,
      future_acad_ci_sequence_number = new_references.future_acad_ci_sequence_number,
      future_adm_cal_type            = new_references.future_adm_cal_type,
      future_adm_ci_sequence_number  = new_references.future_adm_ci_sequence_number,
      previous_term_adm_appl_number  = new_references.previous_term_adm_appl_number,
      previous_term_sequence_number  = new_references.previous_term_sequence_number,
      future_term_adm_appl_number    = new_references.future_term_adm_appl_number,
      future_term_sequence_number    = new_references.future_term_sequence_number,
      def_acad_cal_type              = new_references.def_acad_cal_type,
      def_acad_ci_sequence_num       = new_references.def_acad_ci_sequence_num,
      def_prev_term_adm_appl_num     = new_references.def_prev_term_adm_appl_num,
      def_prev_appl_sequence_num     = new_references.def_prev_appl_sequence_num,
      def_term_adm_appl_num          = new_references.def_term_adm_appl_num,
      def_appl_sequence_num          = new_references.def_appl_sequence_num,
      appl_inst_status	     = new_references.appl_inst_status,						--arvsrini igsm
      ais_reason		     = new_references.ais_reason,
      decline_ofr_reason	     = new_references.decline_ofr_reason

      where ROWID = X_ROWID;


      IF (sql%notfound) THEN
             fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
             igs_ge_msg_stack.add;
             igs_sc_gen_001.unset_ctx('R');
             app_exception.raise_exception;
      END IF;
      IF (x_mode = 'S') THEN
         igs_sc_gen_001.unset_ctx('R');
      END IF;

 After_DML (
        p_action                  => 'UPDATE' ,
        x_rowid                   => X_ROWID);


EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE


      RAISE;
    END IF;
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       X_ORG_ID in NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_NOMINATED_COURSE_CD IN VARCHAR2,
       x_SEQUENCE_NUMBER IN NUMBER,
       x_PREDICTED_GPA IN NUMBER,
       x_ACADEMIC_INDEX IN VARCHAR2,
       x_ADM_CAL_TYPE IN VARCHAR2,
       x_APP_FILE_LOCATION IN VARCHAR2,
       x_ADM_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_APP_SOURCE_ID IN NUMBER,
       x_CRV_VERSION_NUMBER IN NUMBER,
       x_WAITLIST_RANK IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_ATTENT_OTHER_INST_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_EDU_GOAL_PRIOR_ENROLL_ID IN NUMBER,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_DECISION_MAKE_ID IN NUMBER,
       x_UNIT_SET_CD IN VARCHAR2,
       x_DECISION_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_DECISION_REASON_ID IN NUMBER,
       x_US_VERSION_NUMBER IN NUMBER,
       x_DECISION_NOTES IN VARCHAR2,
       x_PENDING_REASON_ID IN NUMBER,
       x_PREFERENCE_NUMBER IN NUMBER,
       x_ADM_DOC_STATUS IN VARCHAR2,
       x_ADM_ENTRY_QUAL_STATUS IN VARCHAR2,
       x_DEFICIENCY_IN_PREP IN VARCHAR2,
       X_LATE_ADM_FEE_STATUS IN VARCHAR2,
       x_SPL_CONSIDER_COMMENTS IN VARCHAR2,
       x_APPLY_FOR_FINAID IN VARCHAR2,
       x_FINAID_APPLY_DATE IN DATE,
       x_ADM_OUTCOME_STATUS IN VARCHAR2,
       x_adm_otcm_stat_auth_per_id IN NUMBER,
       x_ADM_OUTCOME_STATUS_AUTH_DT IN DATE,
       x_ADM_OUTCOME_STATUS_REASON IN VARCHAR2,
       x_OFFER_DT IN DATE,
       x_OFFER_RESPONSE_DT IN DATE,
       x_PRPSD_COMMENCEMENT_DT IN DATE,
       x_ADM_CNDTNL_OFFER_STATUS IN VARCHAR2,
       x_CNDTNL_OFFER_SATISFIED_DT IN DATE,
       x_cndnl_ofr_must_be_stsfd_ind IN VARCHAR2,
       x_ADM_OFFER_RESP_STATUS IN VARCHAR2,
       x_ACTUAL_RESPONSE_DT IN DATE,
       x_ADM_OFFER_DFRMNT_STATUS IN VARCHAR2,
       x_DEFERRED_ADM_CAL_TYPE IN VARCHAR2,
       x_DEFERRED_ADM_CI_SEQUENCE_NUM IN NUMBER,
       x_DEFERRED_TRACKING_ID IN NUMBER,
       x_ASS_RANK IN NUMBER,
       x_SECONDARY_ASS_RANK IN NUMBER,
       x_intr_accept_advice_num IN NUMBER,
       x_ASS_TRACKING_ID IN NUMBER,
       x_FEE_CAT IN VARCHAR2,
       x_HECS_PAYMENT_OPTION IN VARCHAR2,
       x_EXPECTED_COMPLETION_YR IN NUMBER,
       x_EXPECTED_COMPLETION_PERD IN VARCHAR2,
       x_CORRESPONDENCE_CAT IN VARCHAR2,
       x_ENROLMENT_CAT IN VARCHAR2,
       x_FUNDING_SOURCE IN VARCHAR2,
       x_APPLICANT_ACPTNCE_CNDTN IN VARCHAR2,
       x_CNDTNL_OFFER_CNDTN IN VARCHAR2,
       X_MODE in VARCHAR2,
       X_SS_APPLICATION_ID IN VARCHAR2,
       X_SS_PWD IN VARCHAR2  ,
       X_AUTHORIZED_DT DATE,
       X_AUTHORIZING_PERS_ID NUMBER,
       x_entry_status IN NUMBER,
       x_entry_level IN NUMBER,
       x_sch_apl_to_id IN NUMBER,
       x_idx_calc_date IN DATE,
       x_waitlist_status IN VARCHAR2,
       x_ATTRIBUTE21 IN VARCHAR2 ,
       x_ATTRIBUTE22 IN VARCHAR2,
       x_ATTRIBUTE23 IN VARCHAR2,
       x_ATTRIBUTE24 IN VARCHAR2,
       x_ATTRIBUTE25 IN VARCHAR2,
       x_ATTRIBUTE26 IN VARCHAR2,
       x_ATTRIBUTE27 IN VARCHAR2,
       x_ATTRIBUTE28 IN VARCHAR2,
       x_ATTRIBUTE29 IN VARCHAR2,
       x_ATTRIBUTE30 IN VARCHAR2,
       x_ATTRIBUTE31 IN VARCHAR2,
       x_ATTRIBUTE32 IN VARCHAR2,
       x_ATTRIBUTE33 IN VARCHAR2,
       x_ATTRIBUTE34 IN VARCHAR2,
       x_ATTRIBUTE35 IN VARCHAR2,
       x_ATTRIBUTE36 IN VARCHAR2,
       x_ATTRIBUTE37 IN VARCHAR2,
       x_ATTRIBUTE38 IN VARCHAR2,
       x_ATTRIBUTE39 IN VARCHAR2,
       x_ATTRIBUTE40 IN VARCHAR2,
       x_fut_acad_cal_type           IN VARCHAR2,
       x_fut_acad_ci_sequence_number IN NUMBER  ,
       x_fut_adm_cal_type            IN VARCHAR2,
       x_fut_adm_ci_sequence_number  IN NUMBER  ,
       x_prev_term_adm_appl_number  IN NUMBER  ,
       x_prev_term_sequence_number  IN NUMBER  ,
       x_fut_term_adm_appl_number    IN NUMBER  ,
       x_fut_term_sequence_number    IN NUMBER  ,
       x_def_acad_cal_type IN VARCHAR2,
       x_def_acad_ci_sequence_num  IN NUMBER  ,
       x_def_prev_term_adm_appl_num  IN NUMBER  ,
       x_def_prev_appl_sequence_num  IN NUMBER  ,
       x_def_term_adm_appl_num  IN NUMBER  ,
       x_def_appl_sequence_num  IN NUMBER  ,
       x_appl_inst_status	IN VARCHAR2,							--arvsrini igsm
       x_ais_reason		IN VARCHAR2,
       x_decline_ofr_reason	IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor c1 is select ROWID from IGS_AD_PS_APPL_INST_ALL
             where     PERSON_ID= X_PERSON_ID
            and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
            and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
            and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
                        X_ORG_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_PREDICTED_GPA,
       X_ACADEMIC_INDEX,
       X_ADM_CAL_TYPE,
       X_APP_FILE_LOCATION,
       X_ADM_CI_SEQUENCE_NUMBER,
       X_COURSE_CD,
       X_APP_SOURCE_ID,
       X_CRV_VERSION_NUMBER,
       X_WAITLIST_RANK,
       X_LOCATION_CD,
       X_ATTENT_OTHER_INST_CD,
       X_ATTENDANCE_MODE,
       X_EDU_GOAL_PRIOR_ENROLL_ID,
       X_ATTENDANCE_TYPE,
       X_DECISION_MAKE_ID,
       X_UNIT_SET_CD,
       X_DECISION_DATE,
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
       X_DECISION_REASON_ID,
       X_US_VERSION_NUMBER,
       X_DECISION_NOTES,
       X_PENDING_REASON_ID,
       X_PREFERENCE_NUMBER,
       X_ADM_DOC_STATUS,
       X_ADM_ENTRY_QUAL_STATUS,
       X_DEFICIENCY_IN_PREP,
       X_LATE_ADM_FEE_STATUS,
       X_SPL_CONSIDER_COMMENTS,
       X_APPLY_FOR_FINAID,
       X_FINAID_APPLY_DATE,
       X_ADM_OUTCOME_STATUS,
       x_adm_otcm_stat_auth_per_id,
       X_ADM_OUTCOME_STATUS_AUTH_DT,
       X_ADM_OUTCOME_STATUS_REASON,
       X_OFFER_DT,
       X_OFFER_RESPONSE_DT,
       X_PRPSD_COMMENCEMENT_DT,
       X_ADM_CNDTNL_OFFER_STATUS,
       X_CNDTNL_OFFER_SATISFIED_DT,
       x_cndnl_ofr_must_be_stsfd_ind,
       X_ADM_OFFER_RESP_STATUS,
       X_ACTUAL_RESPONSE_DT,
       X_ADM_OFFER_DFRMNT_STATUS,
       X_DEFERRED_ADM_CAL_TYPE,
       X_DEFERRED_ADM_CI_SEQUENCE_NUM,
       X_DEFERRED_TRACKING_ID,
       X_ASS_RANK,
       X_SECONDARY_ASS_RANK,
       x_intr_accept_advice_num,
       X_ASS_TRACKING_ID,
       X_FEE_CAT,
       X_HECS_PAYMENT_OPTION,
       X_EXPECTED_COMPLETION_YR,
       X_EXPECTED_COMPLETION_PERD,
       X_CORRESPONDENCE_CAT,
       X_ENROLMENT_CAT,
       X_FUNDING_SOURCE,
       X_APPLICANT_ACPTNCE_CNDTN,
       X_CNDTNL_OFFER_CNDTN,
      X_MODE,
      X_SS_APPLICATION_ID,
      X_SS_PWD,
      X_AUTHORIZED_DT ,
      X_AUTHORIZING_PERS_ID,
       X_ENTRY_STATUS,
       X_ENTRY_LEVEL,
       X_SCH_APL_TO_ID,
       X_IDX_CALC_DATE,
       X_WAITLIST_STATUS,
       X_ATTRIBUTE21,
       X_ATTRIBUTE22,
       X_ATTRIBUTE23,
       X_ATTRIBUTE24,
       X_ATTRIBUTE25,
       X_ATTRIBUTE26,
       X_ATTRIBUTE27,
       X_ATTRIBUTE28,
       X_ATTRIBUTE29,
       X_ATTRIBUTE30,
       X_ATTRIBUTE31,
       X_ATTRIBUTE32,
       X_ATTRIBUTE33,
       X_ATTRIBUTE34,
       X_ATTRIBUTE35,
       X_ATTRIBUTE36,
       X_ATTRIBUTE37,
       X_ATTRIBUTE38,
       X_ATTRIBUTE39,
       X_ATTRIBUTE40,
       x_fut_acad_cal_type           ,
       x_fut_acad_ci_sequence_number ,
       x_fut_adm_cal_type            ,
       x_fut_adm_ci_sequence_number  ,
       x_prev_term_adm_appl_number  ,
       x_prev_term_sequence_number  ,
       x_fut_term_adm_appl_number    ,
       x_fut_term_sequence_number    ,
      x_def_acad_cal_type ,
      x_def_acad_ci_sequence_num,
      x_def_prev_term_adm_appl_num,
      x_def_prev_appl_sequence_num,
      x_def_term_adm_appl_num,
      x_def_appl_sequence_num,
      x_appl_inst_status,										--arvsrini igsm
      x_ais_reason,
      x_decline_ofr_reason
      );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_NOMINATED_COURSE_CD,
       X_SEQUENCE_NUMBER,
       X_PREDICTED_GPA,
       X_ACADEMIC_INDEX,
       X_ADM_CAL_TYPE,
       X_APP_FILE_LOCATION,
       X_ADM_CI_SEQUENCE_NUMBER,
       X_COURSE_CD,
       X_APP_SOURCE_ID,
       X_CRV_VERSION_NUMBER,
       X_WAITLIST_RANK,
       X_LOCATION_CD,
       X_ATTENT_OTHER_INST_CD,
       X_ATTENDANCE_MODE,
       X_EDU_GOAL_PRIOR_ENROLL_ID,
       X_ATTENDANCE_TYPE,
       X_DECISION_MAKE_ID,
       X_UNIT_SET_CD,
       X_DECISION_DATE,
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
       X_DECISION_REASON_ID,
       X_US_VERSION_NUMBER,
       X_DECISION_NOTES,
       X_PENDING_REASON_ID,
       X_PREFERENCE_NUMBER,
       X_ADM_DOC_STATUS,
       X_ADM_ENTRY_QUAL_STATUS,
       X_DEFICIENCY_IN_PREP,
       X_LATE_ADM_FEE_STATUS,
       X_SPL_CONSIDER_COMMENTS,
       X_APPLY_FOR_FINAID,
       X_FINAID_APPLY_DATE,
       X_ADM_OUTCOME_STATUS,
       x_adm_otcm_stat_auth_per_id,
       X_ADM_OUTCOME_STATUS_AUTH_DT,
       X_ADM_OUTCOME_STATUS_REASON,
       X_OFFER_DT,
       X_OFFER_RESPONSE_DT,
       X_PRPSD_COMMENCEMENT_DT,
       X_ADM_CNDTNL_OFFER_STATUS,
       X_CNDTNL_OFFER_SATISFIED_DT,
       x_cndnl_ofr_must_be_stsfd_ind,
       X_ADM_OFFER_RESP_STATUS,
       X_ACTUAL_RESPONSE_DT,
       X_ADM_OFFER_DFRMNT_STATUS,
       X_DEFERRED_ADM_CAL_TYPE,
       X_DEFERRED_ADM_CI_SEQUENCE_NUM,
       X_DEFERRED_TRACKING_ID,
       X_ASS_RANK,
       X_SECONDARY_ASS_RANK,
       x_intr_accept_advice_num,
       X_ASS_TRACKING_ID,
       X_FEE_CAT,
       X_HECS_PAYMENT_OPTION,
       X_EXPECTED_COMPLETION_YR,
       X_EXPECTED_COMPLETION_PERD,
       X_CORRESPONDENCE_CAT,
       X_ENROLMENT_CAT,
       X_FUNDING_SOURCE,
       X_APPLICANT_ACPTNCE_CNDTN,
       X_CNDTNL_OFFER_CNDTN,
       X_MODE,
       x_ss_application_id,
       x_ss_pwd ,
       X_AUTHORIZED_DT ,
       X_AUTHORIZING_PERS_ID,
       X_ENTRY_STATUS,
       X_ENTRY_LEVEL,
       X_SCH_APL_TO_ID,
      X_IDX_CALC_DATE,
      X_WAITLIST_STATUS,
       X_ATTRIBUTE21,
       X_ATTRIBUTE22,
       X_ATTRIBUTE23,
       X_ATTRIBUTE24,
       X_ATTRIBUTE25,
       X_ATTRIBUTE26,
       X_ATTRIBUTE27,
       X_ATTRIBUTE28,
       X_ATTRIBUTE29,
       X_ATTRIBUTE30,
       X_ATTRIBUTE31,
       X_ATTRIBUTE32,
       X_ATTRIBUTE33,
       X_ATTRIBUTE34,
       X_ATTRIBUTE35,
       X_ATTRIBUTE36,
       X_ATTRIBUTE37,
       X_ATTRIBUTE38,
       X_ATTRIBUTE39,
       X_ATTRIBUTE40,
       x_fut_acad_cal_type           ,
       x_fut_acad_ci_sequence_number ,
       x_fut_adm_cal_type            ,
       x_fut_adm_ci_sequence_number  ,
       x_prev_term_adm_appl_number  ,
       x_prev_term_sequence_number  ,
       x_fut_term_adm_appl_number    ,
       x_fut_term_sequence_number    ,
      x_def_acad_cal_type ,
      x_def_acad_ci_sequence_num,
      x_def_prev_term_adm_appl_num,
      x_def_prev_appl_sequence_num,
      x_def_term_adm_appl_num,
      x_def_appl_sequence_num,
      x_appl_inst_status,									--arvsrini igsm
      x_ais_reason,
      x_decline_ofr_reason
       );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) IS
  /*************************************************************
  Created By :
  Date Created By :
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
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_AD_PS_APPL_INST_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

After_DML (
        p_action                  => 'DELETE',
        x_rowid                   => X_ROWID
       );
EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;

end DELETE_ROW;

PROCEDURE ucas_user_hook (p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE,
			  p_nominated_course_cd igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
			  p_sequence_number igs_ad_ps_appl_inst.sequence_number%TYPE,
			  p_adm_outcome_status igs_ad_ps_appl_inst.adm_outcome_status%TYPE,
			  p_cond_offer_status igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE,
			  p_adm_outcome_status_old igs_ad_ps_appl_inst.adm_outcome_status%TYPE,
			  p_cond_offer_status_old igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE,
			  p_person_id igs_pe_person.person_id%TYPE,
        p_condition_category IN igs_uc_offer_conds.condition_category%TYPE,
        p_condition_name IN igs_uc_offer_conds.condition_name%TYPE,
        p_uc_tran_id OUT NOCOPY NUMBER )
IS
  /*************************************************************
  Created By : Nilotpal Shee
  Date Created By : 16-Sep-2002
  Purpose : 2550009
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  nsinha          26-Nov-2002     For bug 2664410 alt_appl_id :
				  Modified the cursor c_igs_pe_ucas to check for
				  person_id_type IN ('UCASID', 'SWASID', 'NMASID', 'GTTRID') for UCAS small systems.
  knag            21-Nov-2002     fetch and pass alt_appl_id from cursor c_igs_ad_appl for bug 2664410
                                  also passing NULL for P_UCAS_ID as is made obsolete by UCAS
  ayedubat     10-NOV-2003   Changed the ucas_user_hook procedure to add a new OUT parameter to procedure call,
                             igs_uc_trx_gen_hook.create_ucas_transactions for UC208 Enhancement Bug, 3009203
    (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR c_igs_ad_appl(cp_n_person_id            igs_pe_person.person_id%TYPE,
                     cp_n_admission_appl_no    igs_ad_appl.admission_appl_number%TYPE
                    ) IS
  SELECT choice_number, alt_appl_id
  FROM   igs_ad_appl
  WHERE  person_id             = cp_n_person_id
  AND    admission_appl_number = cp_n_admission_appl_no ;
  rec_c_igs_ad_appl  c_igs_ad_appl%ROWTYPE;


  CURSOR  c_igs_pe_person(cp_n_person_id  igs_pe_person.person_id%TYPE) IS
   SELECT  party_number person_number
   FROM    hz_parties hz
   WHERE  hz.party_id   =  cp_n_person_id;
  rec_c_igs_pe_person   c_igs_pe_person%ROWTYPE;


  CURSOR c_igs_pe_ucas(cp_n_person_id igs_pe_person.person_id%TYPE) IS
  SELECT api_person_id
  FROM   igs_pe_alt_pers_id
  WHERE sysdate BETWEEN start_dt AND NVL(end_dt, sysdate)
        AND person_id_type IN ('UCASID', 'SWASID', 'NMASID', 'GTTRID')
        AND pe_person_id = cp_n_person_id ;
       rec_c_igs_pe_ucas     c_igs_pe_ucas%ROWTYPE;

BEGIN
         -- api_person_id fetched is not used but cursor is still required to
         -- determine this is an UCAS person application or not
         OPEN c_igs_pe_ucas(p_person_id);
         FETCH c_igs_pe_ucas INTO rec_c_igs_pe_ucas;
         IF c_igs_pe_ucas%FOUND THEN
           IF (NVL(p_adm_outcome_status_old, '-1') <> p_adm_outcome_status) OR
              (NVL(p_cond_offer_status_old, '-1') <> p_cond_offer_status) THEN

              OPEN c_igs_ad_appl(p_person_id,
                                 p_admission_appl_number
                                );
              FETCH c_igs_ad_appl INTO rec_c_igs_ad_appl;
              CLOSE c_igs_ad_appl;


              OPEN  c_igs_pe_person(p_person_id);
              FETCH c_igs_pe_person INTO rec_c_igs_pe_person;
              CLOSE c_igs_pe_person;

              EXECUTE IMMEDIATE
             'BEGIN  igs_uc_trx_gen_hook.create_ucas_transactions(
               P_UCAS_ID                => :1,
               P_CHOICE_NUMBER          => :2,
               P_PERSON_NUMBER          => :3,
               P_ADMISSION_APPL_NUMBER  => :4,
               P_NOMINATED_COURSE_CD    => :5,
               P_SEQUENCE_NUMBER        => :6,
               P_OUTCOME_STATUS         => :7,
               P_COND_OFFER_STATUS      => :8,
               P_ALT_APPL_ID            => :9,
               P_CONDITION_CATEGORY     => :10,
               P_CONDITION_NAME         => :11,
               P_UC_TRAN_ID             => :12);  END;'
              USING
               IGS_GE_NUMBER.TO_CANN(NULL), -- made obsolete, earlier passed rec_c_igs_pe_ucas.api_person_id,
               rec_c_igs_ad_appl.choice_number,
               rec_c_igs_pe_person.person_number,
               p_admission_appl_number,
               p_nominated_course_cd,
               p_sequence_number,
               p_adm_outcome_status,
               p_cond_offer_status,
               rec_c_igs_ad_appl.alt_appl_id,
               p_condition_category,
               p_condition_name,
               OUT p_uc_tran_id;

           END IF;
         END IF;
         CLOSE c_igs_pe_ucas;
   END ucas_user_hook;



FUNCTION check_non_updateable_list RETURN BOOLEAN IS					--arvsrini igsm

BEGIN


IF NVL(old_references.predicted_gpa,-1) <> NVL(new_references.predicted_gpa,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Academic_Index,'**##') <> NVL(new_references.Academic_Index,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Cal_Type,'**##') <> NVL(new_references.Adm_Cal_Type,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Ci_Sequence_Number,-1) <> NVL(new_references.Adm_Ci_Sequence_Number,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Course_Cd,'**##') <> NVL(new_references.Course_Cd,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.App_Source_Id,-1) <> NVL(new_references.App_Source_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Crv_Version_Number,-1) <> NVL(new_references.Crv_Version_Number,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Waitlist_Rank,'**##') <> NVL(new_references.Waitlist_Rank,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Location_Cd,'**##') <> NVL(new_references.Location_Cd,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attendance_Mode,'**##') <> NVL(new_references.Attendance_Mode,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attendance_Type,'**##') <> NVL(new_references.Attendance_Type,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Decision_Make_Id,-1) <> NVL(new_references.Decision_Make_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Unit_Set_Cd,'**##') <> NVL(new_references.Unit_Set_Cd,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(TRUNC(old_references.Decision_Date),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Decision_Date),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Decision_Reason_Id,-1) <> NVL(new_references.Decision_Reason_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Us_Version_Number,-1) <> NVL(new_references.Us_Version_Number,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Decision_Notes,'**##') <> NVL(new_references.Decision_Notes,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Pending_Reason_Id,-1) <> NVL(new_references.Pending_Reason_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Preference_Number,-1) <> NVL(new_references.Preference_Number,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Doc_Status,'**##') <> NVL(new_references.Adm_Doc_Status,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Entry_Qual_Status,'**##') <> NVL(new_references.Adm_Entry_Qual_Status,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Deficiency_In_Prep,'**##') <> NVL(new_references.Deficiency_In_Prep,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Spl_Consider_Comments,'**##') <> NVL(new_references.Spl_Consider_Comments,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Outcome_Status,'**##') <> NVL(new_references.Adm_Outcome_Status,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Otcm_Status_Auth_Person_Id,-1) <> NVL(new_references.Adm_Otcm_Status_Auth_Person_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(TRUNC(old_references.Adm_Outcome_Status_Auth_Dt),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Adm_Outcome_Status_Auth_Dt),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Outcome_Status_Reason,'**##') <> NVL(new_references.Adm_Outcome_Status_Reason,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(TRUNC(old_references.Offer_Dt),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Offer_Dt),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Adm_Cndtnl_Offer_Status,'**##') <> NVL(new_references.Adm_Cndtnl_Offer_Status,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(TRUNC(old_references.Cndtnl_Offer_Satisfied_Dt),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Cndtnl_Offer_Satisfied_Dt),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Cndtnl_Offer_Must_Be_Stsfd_Ind,'**##') <> NVL(new_references.Cndtnl_Offer_Must_Be_Stsfd_Ind,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Deferred_Tracking_Id,-1) <> NVL(new_references.Deferred_Tracking_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Ass_Rank,-1) <> NVL(new_references.Ass_Rank,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Secondary_Ass_Rank,-1) <> NVL(new_references.Secondary_Ass_Rank,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Ass_Tracking_Id,-1) <> NVL(new_references.Ass_Tracking_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Cndtnl_Offer_Cndtn,'**##') <> NVL(new_references.Cndtnl_Offer_Cndtn,'**##')THEN
      RETURN TRUE;
END IF;
/*
IF NVL(TRUNC(old_references.Creation_Date),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Creation_Date),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Created_By,-99999) <> NVL(new_references.Created_By,-99999)THEN
      RETURN TRUE;
END IF;
IF NVL(TRUNC(old_references.Last_Update_Date),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Last_Update_Date),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Last_Updated_By,-99999) <> NVL(new_references.Last_Updated_By,-99999)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Last_Update_Login,-99999) <> NVL(new_references.Last_Update_Login,-99999)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Request_Id,-1) <> NVL(new_references.Request_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Program_Id,-1) <> NVL(new_references.Program_Id,-1)THEN
      RETURN TRUE;
END IF;

IF NVL(old_references.Program_Application_Id,-1) <> NVL(new_references.Program_Application_Id,-1)THEN
      RETURN TRUE;
END IF;

IF NVL(TRUNC(old_references.Program_Update_Date),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Program_Update_Date),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
*/
IF NVL(old_references.Ss_Application_Id,-1) <> NVL(new_references.Ss_Application_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Ss_Pwd,'**##') <> NVL(new_references.Ss_Pwd,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Entry_Status,-1) <> NVL(new_references.Entry_Status,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Entry_Level,-1) <> NVL(new_references.Entry_Level,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Sch_Apl_To_Id,-1) <> NVL(new_references.Sch_Apl_To_Id,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(TRUNC(old_references.Idx_Calc_Date),IGS_GE_DATE.IGSDATE('1900/01/01')) <> NVL(TRUNC(new_references.Idx_Calc_Date),IGS_GE_DATE.IGSDATE('1900/01/01'))THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Waitlist_Status,'**##') <> NVL(new_references.Waitlist_Status,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Future_Acad_Cal_Type,'**##') <> NVL(new_references.Future_Acad_Cal_Type,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Future_Acad_Ci_Sequence_Number,-1) <> NVL(new_references.Future_Acad_Ci_Sequence_Number,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Future_Adm_Cal_Type,'**##') <> NVL(new_references.Future_Adm_Cal_Type,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Future_Adm_Ci_Sequence_Number,-1) <> NVL(new_references.Future_Adm_Ci_Sequence_Number,-1)THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute_Category,'**##') <> NVL(new_references.Attribute_Category,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute1,'**##') <> NVL(new_references.Attribute1,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute2,'**##') <> NVL(new_references.Attribute2,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute3,'**##') <> NVL(new_references.Attribute3,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute4,'**##') <> NVL(new_references.Attribute4,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute5,'**##') <> NVL(new_references.Attribute5,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute6,'**##') <> NVL(new_references.Attribute6,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute7,'**##') <> NVL(new_references.Attribute7,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute8,'**##') <> NVL(new_references.Attribute8,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute9,'**##') <> NVL(new_references.Attribute9,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute10,'**##') <> NVL(new_references.Attribute10,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute11,'**##') <> NVL(new_references.Attribute11,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute12,'**##') <> NVL(new_references.Attribute12,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute13,'**##') <> NVL(new_references.Attribute13,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute14,'**##') <> NVL(new_references.Attribute14,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute15,'**##') <> NVL(new_references.Attribute15,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute16,'**##') <> NVL(new_references.Attribute16,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute17,'**##') <> NVL(new_references.Attribute17,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute18,'**##') <> NVL(new_references.Attribute18,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute19,'**##') <> NVL(new_references.Attribute19,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute20,'**##') <> NVL(new_references.Attribute20,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute21,'**##') <> NVL(new_references.Attribute21,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute22,'**##') <> NVL(new_references.Attribute22,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute23,'**##') <> NVL(new_references.Attribute23,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute24,'**##') <> NVL(new_references.Attribute24,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute25,'**##') <> NVL(new_references.Attribute25,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute26,'**##') <> NVL(new_references.Attribute26,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute27,'**##') <> NVL(new_references.Attribute27,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute28,'**##') <> NVL(new_references.Attribute28,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute29,'**##') <> NVL(new_references.Attribute29,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute30,'**##') <> NVL(new_references.Attribute30,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute31,'**##') <> NVL(new_references.Attribute31,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute32,'**##') <> NVL(new_references.Attribute32,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute33,'**##') <> NVL(new_references.Attribute33,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute34,'**##') <> NVL(new_references.Attribute34,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute35,'**##') <> NVL(new_references.Attribute35,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute36,'**##') <> NVL(new_references.Attribute36,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute37,'**##') <> NVL(new_references.Attribute37,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute38,'**##') <> NVL(new_references.Attribute38,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute39,'**##') <> NVL(new_references.Attribute39,'**##')THEN
      RETURN TRUE;
END IF;
IF NVL(old_references.Attribute40,'**##') <> NVL(new_references.Attribute40,'**##')THEN
      RETURN TRUE;
END IF;

RETURN FALSE;

END check_non_updateable_list;


END igs_ad_ps_appl_inst_pkg;

/
