--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_004" AS
/* $Header: IGSAD82B.pls 120.4 2005/09/30 05:47:29 appldev ship $ */
/***************************Status,Discrepancy Rule, Match Indicators, Error Codes********************/
	cst_rule_val_I  CONSTANT VARCHAR2(1) := 'I';
	cst_rule_val_E CONSTANT VARCHAR2(1) := 'E';
	cst_rule_val_R CONSTANT VARCHAR2(1) := 'R';


	cst_mi_val_11 CONSTANT  VARCHAR2(2) := '11';
	cst_mi_val_12  CONSTANT VARCHAR2(2) := '12';
	cst_mi_val_13  CONSTANT VARCHAR2(2) := '13';
	cst_mi_val_14  CONSTANT VARCHAR2(2) := '14';
	cst_mi_val_15  CONSTANT VARCHAR2(2) := '15';
	cst_mi_val_16  CONSTANT VARCHAR2(2) := '16';
	cst_mi_val_17  CONSTANT VARCHAR2(2) := '17';
        cst_mi_val_18  CONSTANT VARCHAR2(2) := '18';
	cst_mi_val_19  CONSTANT VARCHAR2(2) := '19';
	cst_mi_val_20  CONSTANT VARCHAR2(2) := '20';
        cst_mi_val_21  CONSTANT VARCHAR2(2) := '21';
	cst_mi_val_22  CONSTANT VARCHAR2(2) := '22';
	cst_mi_val_23  CONSTANT VARCHAR2(2) := '23';
	cst_mi_val_24  CONSTANT VARCHAR2(2) := '24';
	cst_mi_val_25  CONSTANT VARCHAR2(2) := '25';
        cst_mi_val_27  CONSTANT VARCHAR2(2) := '27';

	cst_s_val_1  CONSTANT   VARCHAR2(1) := '1';
        cst_s_val_2  CONSTANT VARCHAR2(1) := '2';
	cst_s_val_3  CONSTANT VARCHAR2(1) := '3';
	cst_s_val_4  CONSTANT VARCHAR2(1) := '4';

       cst_ec_val_E322 CONSTANT VARCHAR2(4) := 'E322';
       cst_ec_val_E014 CONSTANT VARCHAR2(4) := 'E014';
       cst_ec_val_NULL CONSTANT VARCHAR2(4)  := NULL;

       cst_insert  CONSTANT VARCHAR2(6) :=  'INSERT';
       cst_update CONSTANT VARCHAR2(6) :=  'UPDATE';
       cst_unique_record  CONSTANT  NUMBER :=  1;

/***************************Status,Discrepancy Rule, Match Indicators, Error Codes*******************/

-- Initialize Application Status , Fee status
     l_adm_appl_status IGS_AD_APPL_STAT.adm_appl_status%TYPE ;
     l_adm_fee_status IGS_AD_FEE_STAT.adm_fee_status%TYPE ;
     l_Late_Adm_Fee_Status IGS_AD_FEE_STAT.adm_fee_status%TYPE ;
     l_cndnl_ofr_must_be_stsfd_ind   IGS_AD_PS_APPL_INST.cndtnl_offer_must_be_stsfd_ind%TYPE ;
     l_adm_pending_outcome_status	VARCHAR2(127) ;
     l_adm_cndtnl_offer_status	VARCHAR2(127) ;
     l_adm_offer_resp_status	VARCHAR2(127) ;
     l_adm_offer_dfrmnt_status	VARCHAR2(127) ;
     l_admission_application_type  IGS_AD_APPL.application_type%TYPE ;
     l_admission_cat                     IGS_AD_APPL.admission_cat%TYPE ;
     l_s_admission_process_type   IGS_AD_APPL.s_admission_process_type%TYPE ;
     l_adm_doc_status     igs_ad_ps_appl_inst.adm_doc_status%TYPE;

     l_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE ;
     l_enrolment_cat			IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE ;
     l_hecs_payment_option		IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE ;
     l_adm_entry_qual_status		VARCHAR2(127) ;
     l_correspondence_cat		IGS_CO_CAT.correspondence_cat%TYPE;
     l_funding_source	IGS_FI_FUND_SRC.funding_source%TYPE;

     l_rank_set_allowed   VARCHAR2(1);
     l_unit_set_allowed   VARCHAR2(1);
     l_fin_aid_allowed   VARCHAR2(1);
     l_fee_cat_allowed   VARCHAR2(1);
     l_enrol_cat_allowed   VARCHAR2(1);
     l_fund_src_allowed   VARCHAR2(1);
     l_adv_std_allowed   VARCHAR2(1);
     l_int_acc_adv_no_allowed   VARCHAR2(1);
     l_pref_allowed  VARCHAR2(1);
     l_comp_yr_allowed  VARCHAR2(1);
     l_edu_goal_allowed  VARCHAR2(1);

     PROCEDURE populate_apc_columns(p_admission_application_type  IGS_AD_APPL.APPLICATION_TYPE%TYPE) IS
       v_description VARCHAr2(2000);
       l_appl_type_valid  VARCHAR2(10);
        /*---------------------------------------------------------------------------------------------------------
          Check the APC allows following attribute if not and user provides values in columns error out.
               Attribute                                                       step type
            1. Program Rank Set                                          RANK-SET
            2. Unit Set                                                        UNIT-SET
            3. Financial Aid                                                  FINAID
            4. Fee Category                                                 FEE-ASSESS
            5. Enrollment Category                                       ENRCATEGRY
            6. Funding Source                                             FUNDSOURCE
            7. Advanced Standing                                        REQ-ADV
            8. International Acceptance Advice Number          CRS-INTERN
        ----------------------------------------------------------------------------------------------------------*/
     BEGIN
        l_appl_type_Valid :=  igs_ad_gen_016.get_appl_type_apc (p_admission_application_type ,
                              l_admission_cat ,
                              l_s_admission_process_type) ;
        IF l_s_admission_process_type <> 'RE-ADMIT' THEN
          l_fee_cat  :=  IGS_AD_GEN_005.admp_get_dflt_fcm(
  					l_admission_cat,
  					v_description);

          l_hecs_payment_option := IGS_AD_GEN_005.admp_get_dflt_hpo(
  					l_admission_cat,
  					v_description);

          l_enrolment_cat :=  IGS_AD_GEN_005.admp_get_dflt_ecm(
   					l_admission_cat,
  					v_description);
        END IF;

    	-----------------------------------------------------------------------------------------
	-- Get the Application Status and Entry Qualification Status for the application instance
	-----------------------------------------------------------------------------------------
	IF l_s_admission_process_type = 'NON-AWARD' THEN
            l_adm_entry_qual_status := IGS_AD_GEN_009.admp_get_sys_aeqs('NOT-APPLIC');
            l_adm_doc_status := IGS_AD_GEN_009.admp_get_sys_ads('NOT-APPLIC');
        ELSE
	  IF igs_ad_gen_016.get_apcs (p_admission_cat => l_admission_cat,
                                      p_s_admission_process_type => l_s_admission_process_type,
                                      p_s_admission_step_type    => 'DFLT_ENTRY_QUAL') = 'FALSE' THEN
            l_adm_entry_qual_status := IGS_AD_GEN_009.admp_get_sys_aeqs('PENDING');
          ELSE
            l_adm_entry_qual_status := IGS_AD_GEN_009.admp_get_sys_aeqs('QUALIFIED');
	  END IF;
	  IF igs_ad_gen_016.get_apcs (p_admission_cat => l_admission_cat,
                                      p_s_admission_process_type => l_s_admission_process_type,
                                      p_s_admission_step_type    => 'DFLT_DOC_STATUS') = 'FALSE' THEN
            l_adm_doc_status:= IGS_AD_GEN_009.admp_get_sys_ads('PENDING');
          ELSE
           l_adm_doc_status:= IGS_AD_GEN_009.admp_get_sys_ads('SATISFIED');
	  END IF;

        END IF;
        l_admission_application_type := p_admission_application_type ;

       -- Program Rank Set
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'RANK-SET') = 'FALSE' THEN
              l_rank_set_allowed := 'N';
        ELSE
              l_rank_set_allowed := 'Y';
        END IF;
        -- Unit Set
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'UNIT-SET') = 'FALSE' THEN
             l_unit_set_allowed := 'N';
        ELSE
              l_unit_set_allowed := 'Y';
         END IF;
        --Financial Aid
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'FINAID') = 'FALSE' THEN
             l_fin_aid_allowed := 'N';
        ELSE
              l_fin_aid_allowed := 'Y';
         END IF;
         --Fee Category
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'FEE-ASSESS') = 'FALSE' THEN
              l_fee_cat_allowed := 'N';
        ELSE
              l_fee_cat_allowed := 'Y';
        END IF;
         --Enrollment Category
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'ENRCATEGRY') = 'FALSE' THEN
              l_enrol_cat_allowed := 'N';
        ELSE
              l_enrol_cat_allowed := 'Y';
        END IF;
        --  Funding Source
          IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'FUNDSOURCE') = 'FALSE' THEN
              l_fund_src_allowed := 'N';
        ELSE
              l_fund_src_allowed := 'Y';
        END IF;

         --Advanced Standing
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'ADVSTAND') = 'FALSE' THEN
              l_adv_std_allowed := 'N';
        ELSE
              l_adv_std_allowed := 'Y';
        END IF;
          --International Acceptance Advice Number
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'CRS-INTERN') = 'FALSE' THEN
              l_int_acc_adv_no_allowed := 'N';
        ELSE
              l_int_acc_adv_no_allowed := 'Y';
        END IF;

          --International Acceptance Advice Number
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'PREF-LIMIT') = 'FALSE' THEN
              l_pref_allowed := 'N';
        ELSE
              l_pref_allowed := 'Y';
        END IF;

          --International Acceptance Advice Number
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'COMPLETION') = 'FALSE' THEN
              l_comp_yr_allowed := 'N';
        ELSE
              l_comp_yr_allowed := 'Y';
        END IF;

          --International Acceptance Advice Number
        IF igs_ad_gen_016.get_apcs (p_admission_cat            => l_admission_cat,
                                                       p_s_admission_process_type => l_s_admission_process_type,
                                                       p_s_admission_step_type    => 'EDU-GOALS') = 'FALSE' THEN
              l_edu_goal_allowed := 'N';
        ELSE
              l_edu_goal_allowed := 'Y';
        END IF;

    END populate_apc_columns;


 -- This procedure update in the table in different session
 -- so when we rollback the application , it wont rollback these transactions

 PROCEDURE update_appl_inst(p_appl_inst_id NUMBER, p_status VARCHAR2,
            p_error_text VARCHAR2, p_sequence_number NUMBER,p_error_code VARCHAR2,
            p_admission_appl_number NUMBER ,
            p_match_ind VARCHAR2 ) AS
 PRAGMA AUTONOMOUS_TRANSACTION;
   l_error_text  igs_ad_ps_appl_inst_int.error_text%TYPE;
 BEGIN
    UPDATE igs_ad_ps_appl_inst_int
    SET error_text = p_error_text,
        status = p_status,
	sequence_number = p_sequence_number,
	error_code = p_error_code,
        admission_appl_number = p_admission_appl_number,
        match_ind = p_match_ind
    WHERE interface_ps_appl_inst_id = p_appl_inst_id;

    COMMIT;
 END update_appl_inst;


 PROCEDURE prc_appcln(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2,
p_legacy_ind IN VARCHAR2)  AS

 l_request_id NUMBER ;
 l_admission_appl_number   IGS_AD_APPL.admission_appl_number%TYPE;

  CURSOR
    appl_cur IS
  SELECT  cst_insert dmlmode, api.rowid,  api.*
  FROM  igs_ad_apl_int api
  WHERE api.interface_run_id = p_interface_run_id
  AND  api.status = '2'
  AND (  p_rule = 'R'  AND api.match_ind IN ('16', '25')
          OR update_adm_appl_number IS NULL )
  UNION ALL
  SELECT  cst_update dmlmode, api.rowid, api.*
  FROM  igs_ad_apl_int api
  WHERE api.interface_run_id = p_interface_run_id
  AND  api.status = '2'
  AND (       p_rule = 'I'  OR (p_rule = 'R' AND api.match_ind = '21'))
  AND update_adm_appl_number IS NOT NULL ;

-- To be used by instances where application already exists in OSS
 CURSOR
    appl_cur_upd( p_interface_appl_id   igs_ad_apl_int.interface_appl_id%TYPE) IS
  SELECT  cst_update dmlmode, api.rowid,  api.*
  FROM  igs_ad_apl_int api
  WHERE  api.interface_run_id = p_interface_run_id
  AND  interface_appl_id = p_interface_appl_id
  AND status = cst_s_val_1;

  CURSOR
   applinst_cur(
        cp_interface_appl_id igs_ad_apl_int.interface_appl_id%TYPE ) IS
  SELECT
     cst_insert dmlmode, aplinst.rowid, aplinst.*
  FROM
     igs_ad_ps_appl_inst_int  aplinst
  WHERE  aplinst.status = '2'
  AND aplinst.interface_run_id = p_interface_run_id
  AND (  p_rule = 'R'  AND aplinst.match_ind IN ('16', '25')
          OR update_adm_seq_number IS NULL )
  AND  aplinst.interface_appl_id = NVL(cp_interface_appl_id , aplinst.interface_appl_id)
  UNION ALL
  SELECT
      cst_update dmlmode, aplinst.rowid, aplinst.*
   FROM
     igs_ad_ps_appl_inst_int  aplinst
   WHERE  aplinst.status = '2'
   AND aplinst.interface_run_id = p_interface_run_id
   AND  aplinst.interface_appl_id = NVL(cp_interface_appl_id , aplinst.interface_appl_id)
   AND (       p_rule = 'I'  OR (p_rule = 'R' AND aplinst.match_ind = '21'))
   AND update_adm_seq_number IS NOT NULL ;


    CURSOR  c_dup_cur(appl_rec  appl_cur%ROWTYPE) IS
    SELECT
       appl_oss.rowid, appl_oss.*
    FROM
	IGS_AD_APPL  appl_oss
    WHERE person_id = appl_Rec.person_id
    AND  admission_Appl_number = appl_rec.update_adm_appl_number;

    CURSOR dup_applinst_cur(applinst_rec  applinst_cur%ROWTYPE,
           p_person_id   hz_parties.party_id%TYPE,
           p_admission_appl_number  IGS_AD_APPL.admission_Appl_number%TYPE
           )  IS
    SELECT
     acai.rowid,acai.*
   FROM
     igs_ad_ps_appl_inst acai
   WHERE
      person_id = p_person_id
    AND admission_appl_number = p_admission_appl_number
    AND nominated_course_cd = applinst_rec.nominated_course_cd
    AND sequence_number = applinst_rec.update_adm_seq_number;
   dup_applinst_rec dup_applinst_cur%ROWTYPE;

    dup_cur_rec   c_dup_cur%ROWTYPE;
    l_appl_type_Valid  BOOLEAN;
    l_Status_application   VARCHAR2(1);
    l_Status_instance       VARCHAR2(1);
    l_org_id  NUMBER(15) ;
    l_prog_label  VARCHAR2(100) ;
    l_label  VARCHAR2(150)  ;
    l_debug_str  VARCHAR2(150)  ;
    l_processed_records  NUMBER(5);


 FUNCTION validate_apc_steps(p_applinst_rec  applinst_cur%ROWTYPE )
                  RETURN BOOLEAN IS
     l_error_code  VARCHAR2(4);
     l_error_text   VARCHAR2(2000);
  BEGIN    -- Validates the interface columns with apc steps
      --i.e if the columns are having the valid values matchng to application type
     IF l_rank_set_allowed  =  'N'  AND p_applinst_rec.course_rank_set IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_COURSE_RANK_DTLS'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_unit_set_allowed  =  'N'  AND p_applinst_rec.unit_set_cd  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_PS_UNIT_SET'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_fin_aid_allowed  =  'N'  AND p_applinst_rec.apply_for_finaid  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FIN_AID'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_fee_cat_allowed  =  'N'  AND p_applinst_rec.fee_cat  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FEE_CAT'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_code := 'E322';
           l_error_text := FND_MESSAGE.GET;
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_enrol_cat_allowed  =  'N'  AND p_applinst_rec.enrolment_cat  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ENROLMENT_CAT'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

    IF l_fund_src_allowed  =  'N'  AND p_applinst_rec.funding_source  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FUNDING_SOURCE'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
         l_error_code := 'E322';
         l_error_text := FND_MESSAGE.GET;
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

    IF l_adv_std_allowed  =  'N'  AND p_applinst_rec.req_for_adv_standing_ind  = 'Y'  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REQ_ADV_STD_IND'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_int_acc_adv_no_allowed  =  'N'  AND p_applinst_rec.intrntnl_acceptance_advice_num  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_INTRNL_ACC_ADV_NUM'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_pref_allowed  =  'N'  AND p_applinst_rec.preference_number  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_PREFNUM_NOTBE_SPECIFY');
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_comp_yr_allowed  =  'N'  AND p_applinst_rec.expected_completion_yr  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXPCT_COMP_YR'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_comp_yr_allowed  =  'N'  AND p_applinst_rec.expected_completion_perd  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_EXPCT_COMP_PRD'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;

     IF l_edu_goal_allowed  =  'N'  AND p_applinst_rec.edu_goal_prior_enroll_id  IS NOT NULL  THEN
           FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_NOT_APC_STEP');
           FND_MESSAGE.SET_TOKEN('CATEGORY',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PRI_EN_EDU_GOAL'));
           FND_MESSAGE.SET_TOKEN ('APPLTYPE', l_admission_application_type);
           l_error_text := FND_MESSAGE.GET;
           l_error_code := 'E322';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);
            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
           RETURN FALSE;
     END IF;
     RETURN TRUE;
END validate_apc_steps;
---------------------------------------------------------------------------------------------------------

   PROCEDURE create_application_details ( p_appl_rec appl_cur%ROWTYPE,
           p_admission_appl_number  OUT NOCOPY IGS_AD_APPL.admission_Appl_number%TYPE,
           p_status OUT NOCOPY VARCHAR2) IS
   /*-----------------------------------------------------------------------------------------
   Created By: pbondugu
   Date Created : 24-Nov-2003
   Purpose: Import PRocess enhancements
   Known limitations,enhancements,remarks:
   Change History
   Who        When          What
   -----------------------------------------------------------------------------------------*/
    CURSOR c_aa IS
    SELECT	 NVL(MAX(admission_appl_number),0) + 1
    FROM  	 IGS_AD_APPL
    WHERE 	 person_id = p_appl_rec.person_id;

   l_rowid VARCHAR2(25);
   l_status VARCHAR2(1);
   l_adm_appl_number  IGS_AD_APPL.admission_appl_number%TYPE;
   l_msg_at_index   NUMBER ;
   l_return_status   VARCHAR2(1);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

   l_error_code VARCHAR2(10);
   l_error_text  VARCHAR2(2000);
    BEGIN
    OPEN c_aa;
    FETCH c_aa INTO l_adm_appl_number;
    CLOSE c_aa;
      BEGIN
        p_status := 'S';
        SAVEPOINT before_insert_appl;
            l_msg_at_index := igs_ge_msg_stack.count_msg;
         IGS_AD_APPL_PKG.insert_row (
  	  X_Mode                              => 'R',
  	  X_RowId                             => l_rowid,
  	  X_Person_Id                         => p_appl_rec.Person_Id,
  	  X_Admission_Appl_Number             => l_adm_appl_number,
  	  X_Appl_Dt                           => p_appl_rec.Appl_Dt,
  	  X_Acad_Cal_Type                     => p_appl_rec.Acad_Cal_Type,
  	  X_Acad_Ci_Sequence_Number           => p_appl_rec.Acad_Ci_Sequence_Number,
  	  X_Adm_Cal_Type                      => p_appl_rec.Adm_Cal_Type,
  	  X_Adm_Ci_Sequence_Number            => p_appl_rec.Adm_Ci_Sequence_Number,
  	  X_Admission_Cat                     => l_admission_cat,
  	  X_S_Admission_Process_Type          => l_s_admission_process_type,
  	  X_Adm_Appl_Status                   => l_adm_appl_status,
  	  X_Adm_Fee_Status                    => l_adm_fee_status,
  	  X_Tac_Appl_Ind                      => p_appl_rec.Tac_Appl_Ind,
  	  X_Org_Id			                => l_org_id,
          X_Spcl_Grp_1                        => p_appl_rec.spcl_grp_1,
          X_Spcl_Grp_2                        => p_appl_rec.spcl_grp_2,
          X_Common_App                        => p_appl_rec.common_app,
          X_application_type                  => l_admission_application_type,
	  X_choice_number                     => p_appl_rec.choice_number,
          X_routeb_pref                       => p_appl_rec.routeb_pref,
	  X_alt_appl_id                       => p_appl_rec.alt_appl_id,
	  X_appl_fee_amt		      => NVL(p_appl_rec.appl_fee_amt,0)
        );
       p_admission_appl_number := l_adm_appl_number;
      EXCEPTION
         WHEN OTHERS THEN
         ROLLBACK TO before_insert_appl;
            igs_ad_gen_016.extract_msg_from_stack (
                       p_msg_at_index                => l_msg_at_index,
                       p_return_status               => l_return_status,
                       p_msg_count                   => l_msg_count,
                       p_msg_data                    => l_msg_data,
                       p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                l_error_text := l_msg_data;
                l_error_code := 'E322';
                p_status := 'E';
                IF p_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(p_appl_rec.interface_appl_id,l_msg_data,'IGS_AD_APL_INT');
                END IF;
            ELSE
                l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                l_error_code := 'E518';
                p_status := 'U';
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                    l_label :='igs.plsql.igs_ad_imp_004.create_application_details.exception '|| l_msg_data;
  		    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		    fnd_message.set_token('INTERFACE_ID',p_appl_rec.interface_appl_id);
		    fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                          fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;
           UPDATE IGS_AD_APL_INT
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text,
            match_ind = DECODE (
                                       p_appl_rec.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
            WHERE interface_appl_id = p_appl_rec.interface_appl_id;
      END;

    END create_application_details;


   PROCEDURE update_application_details ( p_appl_rec appl_cur%ROWTYPE, dup_cur_rec c_dup_cur%ROWTYPE
                                                 ) IS
   /*-----------------------------------------------------------------------------------------
   Created By: pbondugu
   Date Created : 24-Nov-2003
   Purpose: Import PRocess enhancements
   Known limitations,enhancements,remarks:
   Change History
   Who        When          What
   -----------------------------------------------------------------------------------------*/
   l_rowid VARCHAR2(25);
   l_adm_appl_number  IGS_AD_APPL.admission_appl_number%TYPE;
   l_msg_at_index   NUMBER ;
   l_return_status   VARCHAR2(1);
   l_msg_count      NUMBER ;
   l_msg_data       VARCHAR2(2000);
   l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;

   l_error_code VARCHAR2(10);
   l_error_text  VARCHAR2(2000);
BEGIN
      BEGIN
            l_msg_at_index := igs_ge_msg_stack.count_msg;
       SAVEPOINT    before_update_appl;
        IGS_AD_APPL_PKG.update_row (
  	  X_Mode                                 => 'R',
  	  X_RowId                                => dup_cur_rec.rowid,
  	  X_Person_Id                           => p_appl_rec.Person_Id,
          X_admission_appl_Number      => p_appl_rec.update_adm_appl_number,
          X_appl_dt                               => NVL( p_appl_rec.Appl_Dt,dup_cur_rec.Appl_Dt ),
  	  X_Acad_Cal_Type                   => NVL(p_appl_rec.Acad_Cal_Type,  dup_cur_rec.Acad_Cal_Type),
  	  X_Acad_Ci_Sequence_Number => NVL(p_appl_rec.Acad_Ci_Sequence_Number,  dup_cur_rec.Acad_Ci_Sequence_Number),
  	  X_Adm_Cal_Type                    => NVL(p_appl_rec.Adm_Cal_Type,   dup_cur_rec.Adm_Cal_Type),
  	  X_Adm_Ci_Sequence_Number  => NVL(p_appl_rec.Adm_Ci_Sequence_Number,  dup_cur_rec.Adm_Ci_Sequence_Number),
  	  X_Admission_Cat                     => dup_cur_rec.Admission_Cat ,
  	  X_S_Admission_Process_Type  => dup_cur_rec.s_admission_process_type,
  	  X_Adm_Appl_Status                 =>  dup_cur_rec.Adm_Appl_Status,
  	  X_Adm_Fee_Status                  =>  dup_cur_rec.adm_fee_status,
  	  X_Tac_Appl_Ind                       =>  p_appl_rec.Tac_Appl_Ind,
          X_Spcl_Grp_1                          => NVL(p_appl_rec.spcl_grp_1,   dup_cur_rec.spcl_grp_1),
          X_Spcl_Grp_2                          => NVL(p_appl_rec.spcl_grp_2,   dup_cur_rec.spcl_grp_2),
          X_Common_App                       => NVL(p_appl_rec.common_app,   dup_cur_rec.common_app),
          X_application_type                    => NVL(p_appl_rec.admission_application_type, dup_cur_rec.application_type),
	  X_choice_number                     => NVL(p_appl_rec.choice_number,  dup_cur_rec.choice_number),
          X_routeb_pref                          => NVL(p_appl_rec.routeb_pref,  dup_cur_rec.routeb_pref),
	  X_alt_appl_id                           => NVL(p_appl_rec.alt_appl_id,  dup_cur_rec.alt_appl_id),
	  x_appl_fee_amt                        => NVL(p_appl_rec.appl_fee_amt,  dup_cur_rec.appl_fee_amt)
        );
                UPDATE
       	              igs_ad_apl_int
                 SET
 	             status = cst_s_val_1,
                     admission_Appl_number = p_appl_rec.update_adm_appl_number,
                     acad_ci_sequence_number = NVL(p_appl_rec.Acad_Ci_Sequence_Number,  dup_cur_rec.Acad_Ci_Sequence_Number),
                     acad_cal_type                   =   NVL(p_appl_rec.Acad_Cal_Type,  dup_cur_rec.Acad_Cal_Type),
                     adm_cal_type                   =  NVL(p_appl_rec.Adm_Cal_Type,   dup_cur_rec.Adm_Cal_Type),
                     Adm_Ci_Sequence_Number =  NVL(p_appl_rec.Adm_Ci_Sequence_Number,  dup_cur_rec.Adm_Ci_Sequence_Number),
                     match_ind =   DECODE (
                                         p_appl_rec.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)
	         WHERE
                    interface_appl_id = p_appl_rec.interface_appl_id;
      EXCEPTION
         WHEN OTHERS THEN
          ROLLBACK TO before_update_appl;
            igs_ad_gen_016.extract_msg_from_stack (
                       p_msg_at_index                => l_msg_at_index,
                       p_return_status               => l_return_status,
                       p_msg_count                   => l_msg_count,
                       p_msg_data                    => l_msg_data,
                       p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                l_error_text := l_msg_data;
                l_error_code := 'E014';

                IF p_enable_log = 'Y' THEN
                    igs_ad_imp_001.logerrormessage(p_appl_rec.interface_appl_id,l_msg_data,'IGS_AD_APL_INT');
                END IF;
            ELSE
                l_error_text := igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                l_error_code := 'E518';
                IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
                    l_label :='igs.plsql.igs_ad_imp_004.update_application_details.exception '|| l_msg_data;
  		    fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
		    fnd_message.set_token('INTERFACE_ID',p_appl_rec.interface_appl_id);
		    fnd_message.set_token('ERROR_CD','E322');

		          l_debug_str :=  fnd_message.get;

                          fnd_log.string_with_context( fnd_log.level_exception,
								  l_label,
								  l_debug_str, NULL,
								  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                      END IF;

               END IF;
           UPDATE IGS_AD_APL_INT
            SET status = cst_s_val_3,
            error_code = l_error_code,
            error_text = l_error_text,
            match_ind =   DECODE (
                                         p_appl_rec.match_ind,
                                              NULL, cst_mi_val_11,
                                       match_ind)

            WHERE interface_appl_id = p_appl_rec.interface_appl_id;
      END;

    END update_application_details;
--Declaration of create_single_appl_instance
    PROCEDURE create_single_appl_instance(p_applinst_rec applinst_cur%ROWTYPE,
      p_person_id  hz_parties.party_id%TYPE,
      p_admission_Appl_number IGS_AD_APPL.admission_appl_number%TYPE,
      p_appl_rec  appl_cur%ROWTYPE,
      p_Status  OUT NOCOPY VARCHAR2) ;

    PROCEDURE create_application_instance(p_interface_appl_id  IGS_AD_APL_INT.interface_appl_id%TYPE,
      p_person_id  hz_parties.party_id%TYPE,
      p_admission_Appl_number IGS_AD_APPL.admission_appl_number%TYPE,
      p_appl_rec  appl_cur%ROWTYPE,
      p_Status_instance  OUT NOCOPY VARCHAR2) IS
   --------------------------------------------------------------------------
   --  Created By : pbondugu
   --  Date Created On : 2003/11/22
   --  Purpose:
   --  Know limitations, enhancements or remarks
   --  Change History
   --  Who             When            What
   --  (reverse chronological order - newest change first)
  --------------------------------------------------------------------------
      l_success_records  NUMBER ;
      l_Status VARCHAR2(4);
    BEGIN
   --Loop for all application instance interface records
   --    craete the instance.
   --     if success l_success_record := l_success_record +1 ;
   --     if fails p_Status_instance := 'W'
   -- END LOOP
   -- After the loop if l_Sucess_record =0 then p_Status_instance := 'E'  means all instances failed
   l_success_records := 0;
   l_Status :=  '1';
        FOR applinst_rec  IN applinst_cur(p_interface_appl_id) LOOP
            create_single_appl_instance(applinst_rec,  p_person_id, p_admission_Appl_number,p_appl_rec, l_status);
            IF l_status = '3' THEN
               p_Status_instance  := 'W';
            ELSE
               l_success_records := l_success_records +1 ;
            END IF;
        END LOOP;
        IF p_Status_instance <> 'W' THEN
           p_Status_instance := 'S';
        END IF;
        IF l_success_records = 0  THEN
           p_Status_instance := 'E';
        END IF;

   END create_application_instance;


    PROCEDURE create_single_appl_instance(p_applinst_rec applinst_cur%ROWTYPE,
      p_person_id  hz_parties.party_id%TYPE,
      p_admission_Appl_number IGS_AD_APPL.admission_appl_number%TYPE,
      p_appl_rec  appl_cur%ROWTYPE,
      p_Status  OUT NOCOPY VARCHAR2) IS
    --------------------------------------------------------------------------
    --  Created By : pbondugu
    --  Date Created On : 2003/11/22
    --  Purpose:
    --  Know limitations, enhancements or remarks
    --  Change History
    --  Who             When            What
    --  akadam          5/02/2004       Added the raise event as part of Bug 3391593
    --  (reverse chronological order - newest change first)
    --------------------------------------------------------------------------
       l_error_text1   VARCHAR2(2000);
       l_error_code1  NUMBER;
        CURSOR c_prg_exists(cp_person_id            IGS_AD_PS_APPL.person_id%TYPE,
                            cp_appl_no              IGS_AD_PS_APPL.admission_appl_number%TYPE,
			    cp_nominated_course_cd  IGS_AD_PS_APPL.nominated_course_cd%TYPE)
	IS
	SELECT tab.*  --multiorg table , so rowid need not be selected explicitly
	FROM   IGS_AD_PS_APPL tab
	WHERE  person_id = cp_person_id AND
	       admission_appl_number = cp_appl_no AND
	       nominated_course_cd = cp_nominated_course_cd;
        c_prg_exists_rec c_prg_exists%ROWTYPE;

       CURSOR  c_session_info(cp_person_id            IGS_AD_PS_APPL.person_id%TYPE,
                            cp_appl_no              IGS_AD_PS_APPL.admission_appl_number%TYPE) IS
        SELECT adm_cal_type, adm_ci_sequence_number, acad_cal_type , s_admission_process_type
        FROM igs_Ad_appl_all
        WHERE person_id = cp_person_id
        AND admission_Appl_number = cp_appl_no;

       CURSOR c_nxt_acai_seq_num IS
  		SELECT	NVL(MAX(sequence_number), 0) + 1
  		FROM	IGS_AD_PS_APPL_INST
  		WHERE
  	          person_id		= p_person_id 	AND
  		  admission_appl_number	= p_admission_appl_number AND
  		  nominated_course_cd	= p_applinst_rec.nominated_course_cd;

        l_name igs_ad_code_classes.name%TYPE;
        v_app_source igs_ad_code_classes.system_status%TYPE;
        lv_rowid  VARCHAR2(20);
       v_description VARCHAR2(2000);
       l_error_code VARCHAR2(4);
       l_error_text VARCHAR2(2000);
       l_app_source_id   igs_ad_ps_appl_inst_all.app_source_id%TYPE;
       l_msg_at_index   NUMBER ;
       l_return_status   VARCHAR2(1);
       l_msg_count      NUMBER ;
       l_msg_data       VARCHAR2(2000);
       l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
        l_completion_dt DATE;
        l_course_start_dt               DATE;
        l_expected_completion_yr        IGS_AD_PS_APPL_INST.expected_completion_yr%TYPE;
        l_expected_completion_perd      IGS_AD_PS_APPL_INST.expected_completion_perd%TYPE;

       l_finaid_apply_date igs_ad_ps_appl_inst.finaid_apply_date%TYPE;
        l_acai_sequence_number   igs_ad_ps_appl_inst_all.sequence_number%TYPE;
        PROCEDURE update_person_type(p_sequence_number          IN igs_pe_typ_instances_all.sequence_number%TYPE
                                     ,p_nominated_course_cd     IN igs_pe_typ_instances_all.nominated_course_cd%TYPE
        			     ,p_person_id               IN igs_pe_typ_instances_all.person_id%TYPE
        			     ,p_adm_appl_number         IN igs_pe_typ_instances_all.admission_appl_number%TYPE ) AS

            l_rowid                         VARCHAR2(25);
            l_org_id                        NUMBER(15);
            l_type_instance_id              NUMBER;
            l_person_type_code              IGS_PE_PERSON_TYPES.person_type_code%TYPE;
            CURSOR
              c_person_type_code(l_system_type IGS_PE_PERSON_TYPES.system_type%TYPE) IS
            SELECT
              person_type_code
            FROM
              igs_pe_person_types
            WHERE
              system_type=l_system_type;
          BEGIN --Begin Local Loop 1
            l_org_id := igs_ge_gen_003.get_org_id;

            OPEN c_person_type_code('APPLICANT');
            FETCH c_person_type_code INTO l_person_type_code;
            CLOSE c_person_type_code;

            IGS_PE_TYP_INSTANCES_PKG.insert_row(
        	x_rowid=>l_rowid,
        	x_org_id=>l_org_id,
        	x_person_id=>p_person_id,
        	x_course_cd=>NULL,
        	x_type_instance_id=>l_type_instance_id,
        	x_person_type_code=>l_person_type_code,
        	x_cc_version_number=>NULL,
        	x_funnel_status =>NULL,
        	x_admission_appl_number=> p_admission_Appl_number,
        	x_nominated_course_cd=> p_nominated_course_cd,--c_admappl_pgm_rec.nominated_course_cd,
        	x_ncc_version_number=>NULL,
        	x_sequence_number =>p_sequence_number,
        	x_start_date=>SYSDATE,
        	x_end_date=>NULL,
        	x_create_method =>'CREATE_APPL_INSTANCE',
        	x_ended_by => NULL,
        	x_end_method =>NULL,
        	x_mode=>'R',
                x_emplmnt_category_code =>null);
          END update_person_type;
    BEGIN
            ------------------------------------------------------------------------------
            --create_single_appl_instance
            -------------------------------------------------------------------------------
      IF NOT validate_apc_steps(p_applinst_rec) THEN
         p_status := '3';
         RETURN;
      END IF;
      OPEN c_prg_exists(p_person_id,p_admission_Appl_number,p_applinst_rec.nominated_course_cd);
      FETCH c_prg_exists INTO c_prg_exists_rec;
      --create/update  program
         l_msg_at_index := igs_ge_msg_stack.count_msg;
      SAVEPOINT before_insert_ps_appl;
      IF  c_prg_exists%NOTFOUND THEN
        IGS_AD_PS_APPL_PKG.Insert_Row (
          X_Mode                              => 'R',
          X_RowId                             => lv_rowid,
          X_Person_Id                         => p_person_id,
          X_Admission_Appl_Number             => p_admission_Appl_number,
          X_Nominated_Course_Cd               => p_applinst_rec.nominated_course_cd,
          X_Transfer_Course_Cd                => p_applinst_rec.transfer_course_cd,
          X_Basis_For_Admission_Type          => p_applinst_rec.basis_for_admission_type,
          X_Admission_Cd                      => NULL,
          X_Course_Rank_Set                   => NULL,
          X_Course_Rank_Schedule              => NULL,
          X_Req_For_Reconsideration_Ind       => 'N',
          X_Req_For_Adv_Standing_Ind          =>  p_applinst_rec.req_for_adv_standing_ind,
          X_Org_Id		            => l_org_id
        );

      ELSE
        IGS_AD_PS_APPL_PKG.update_Row (
          X_RowId                             => c_prg_exists_rec.row_id,
          X_Person_Id                         => NVL(p_person_id,c_prg_exists_rec.person_id),
          X_Admission_Appl_Number             => NVL(p_admission_Appl_number,c_prg_exists_rec.admission_appl_number),
          X_Nominated_Course_Cd               => NVL(p_applinst_rec.nominated_course_cd,c_prg_exists_rec.nominated_course_cd),
          X_Transfer_Course_Cd                => NVL(p_applinst_rec.transfer_course_cd,c_prg_exists_rec.transfer_course_cd),
          X_Basis_For_Admission_Type          => NVL(p_applinst_rec.basis_for_admission_type,c_prg_exists_rec.basis_for_admission_type),
          X_Admission_Cd                      => c_prg_exists_rec.admission_cd,
          X_Course_Rank_Set                   => c_prg_exists_rec.Course_Rank_Set,
          X_Course_Rank_Schedule              => c_prg_exists_rec.Course_Rank_Schedule,
          X_Req_For_Reconsideration_Ind       => c_prg_exists_rec.req_for_reconsideration_ind,
          X_Req_For_Adv_Standing_Ind          => NVL(p_applinst_rec.req_for_adv_standing_ind,c_prg_exists_rec.req_for_adv_standing_ind),
          X_Mode                              => 'R'
         );
      END IF;
      CLOSE c_prg_exists;
   ---------------------------------------------
   -- To validate descriptive flexfield columns.
   ---------------------------------------------
      IF NOT IGS_AD_IMP_018.validate_desc_flex_40_cols(
         p_attribute_category	=> p_applinst_rec.attribute_category,
         p_attribute1		=> p_applinst_rec.attribute1,
         p_attribute2		=> p_applinst_rec.attribute2,
         p_attribute3		=> p_applinst_rec.attribute3,
         p_attribute4		=> p_applinst_rec.attribute4,
         p_attribute5		=> p_applinst_rec.attribute5,
         p_attribute6		=> p_applinst_rec.attribute6,
         p_attribute7		=> p_applinst_rec.attribute7,
         p_attribute8		=> p_applinst_rec.attribute8,
         p_attribute9		=> p_applinst_rec.attribute9,
         p_attribute10		=> p_applinst_rec.attribute10,
         p_attribute11		=> p_applinst_rec.attribute11,
         p_attribute12		=> p_applinst_rec.attribute12,
         p_attribute13		=> p_applinst_rec.attribute13,
         p_attribute14		=> p_applinst_rec.attribute14,
         p_attribute15		=> p_applinst_rec.attribute15,
         p_attribute16		=> p_applinst_rec.attribute16,
         p_attribute17		=> p_applinst_rec.attribute17,
         p_attribute18		=> p_applinst_rec.attribute18,
         p_attribute19		=> p_applinst_rec.attribute19,
         p_attribute20		=> p_applinst_rec.attribute20,
         p_attribute21		=> p_applinst_rec.attribute21,
         p_attribute22		=> p_applinst_rec.attribute22,
         p_attribute23		=> p_applinst_rec.attribute23,
         p_attribute24		=> p_applinst_rec.attribute24,
         p_attribute25		=> p_applinst_rec.attribute25,
         p_attribute26		=> p_applinst_rec.attribute26,
         p_attribute27		=> p_applinst_rec.attribute27,
         p_attribute28		=> p_applinst_rec.attribute28,
         p_attribute29		=> p_applinst_rec.attribute29,
         p_attribute30		=> p_applinst_rec.attribute30,
         p_attribute31		=> p_applinst_rec.attribute31,
         p_attribute32		=> p_applinst_rec.attribute32,
         p_attribute33		=> p_applinst_rec.attribute33,
         p_attribute34		=> p_applinst_rec.attribute34,
         p_attribute35		=> p_applinst_rec.attribute35,
         p_attribute36		=> p_applinst_rec.attribute36,
         p_attribute37		=> p_applinst_rec.attribute37,
         p_attribute38		=> p_applinst_rec.attribute38,
         p_attribute39		=> p_applinst_rec.attribute39,
         p_attribute40		=> p_applinst_rec.attribute40,
         p_desc_flex_name	=> 'IGS_AD_APPL_INST_FLEX'
        ) THEN
           FND_MESSAGE.set_name('IGS','IGS_AD_INVALID_DESC_FLEX');
           l_error_text := FND_MESSAGE.get;
           p_status := '3';
           update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id,  p_status => '3',
             p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => 'E322');

           IF p_enable_log = 'Y' THEN
             igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
           END IF;
           RETURN;
      END IF;

     	--------------------------------
  	-- Set Funding Source
  	--------------------------------
        l_funding_source  :=  IGS_AD_GEN_005.admp_get_dflt_fs(
  					p_applinst_rec.nominated_course_cd,
                                        p_applinst_rec.crv_version_number,
  					v_description);
    IF p_applinst_rec.expected_completion_yr IS NULL AND p_applinst_rec.expected_completion_perd IS NULL THEN
        FOR c_session_info_rec IN c_session_info(p_person_id,p_admission_Appl_number) LOOP
           IF c_session_info_rec.s_admission_process_type NOT IN ('RE-ADMIT', 'TRANSFER')  THEN
	      -- Derive the Program Start date by calling the function ADMP_GET_CRV_STRT_DT

            l_course_start_dt := IGS_AD_GEN_005.ADMP_GET_CRV_STRT_DT (
                                                   c_session_info_rec.adm_cal_type,
                                                  c_session_info_rec.adm_ci_sequence_number);

              --Call the procedure ADMP_GET_CRV_COMP_DT with the additional parameters attenance_mode and location_cd. Bug: 2647482
              igs_ad_gen_004.admp_get_crv_comp_dt (
                                p_applinst_rec.nominated_course_cd,
                                p_applinst_rec.crv_version_number,
                                c_session_info_rec.acad_cal_type,
                                p_applinst_rec.attendance_type,
                                l_course_start_dt,
                                l_expected_completion_yr,
                                l_expected_completion_perd,
                                l_completion_dt,
                                p_applinst_rec.attendance_mode,
                                p_applinst_rec.location_cd);
           END IF;
        END LOOP;
    END IF;
	IF NVL(p_applinst_rec.apply_for_finaid,'N') = 'N' THEN
             l_finaid_apply_date := NULL;
	ELSE
             l_finaid_apply_date := p_applinst_rec.finaid_apply_date;
	END IF;

	---------------------------------------------------
  	-- Get the next sequence number for the application
  	---------------------------------------------------
  	OPEN c_nxt_acai_seq_num;
  	FETCH c_nxt_acai_seq_num INTO l_acai_sequence_number;
  	CLOSE c_nxt_acai_seq_num;
        lv_rowid := NULL;
        IGS_AD_PS_APPL_INST_PKG.Insert_Row (
          X_ROWID  =>   lv_rowid,
          X_PERSON_ID  => p_Person_Id,
          X_ADMISSION_APPL_NUMBER  => p_Admission_Appl_Number,
          X_NOMINATED_COURSE_CD => p_applinst_rec.nominated_course_cd,
          X_SEQUENCE_NUMBER  => l_acai_sequence_number,
          X_PREDICTED_GPA  => NULL,
          X_ACADEMIC_INDEX  => NULL,
          X_ADM_CAL_TYPE   => p_appl_rec.adm_cal_type,
          X_APP_FILE_LOCATION  => NULL,
          X_ADM_CI_SEQUENCE_NUMBER  => p_appl_rec.adm_ci_sequence_number,
          X_COURSE_CD   => p_applinst_rec.nominated_course_cd,
          X_APP_SOURCE_ID => p_applinst_rec.app_source_id,
          X_CRV_VERSION_NUMBER   => p_applinst_rec.Crv_Version_Number,
          X_WAITLIST_RANK => NULL,
          X_LOCATION_CD     => p_applinst_rec.Location_Cd,
          X_ATTENT_OTHER_INST_CD => NULL,
          X_ATTENDANCE_MODE   => p_applinst_rec.Attendance_Mode,
          X_EDU_GOAL_PRIOR_ENROLL_ID => p_applinst_rec.edu_goal_prior_enroll_id,
          X_ATTENDANCE_TYPE     => p_applinst_rec.Attendance_Type,
          X_DECISION_MAKE_ID => NULL,
          X_UNIT_SET_CD  => p_applinst_rec.Unit_Set_Cd,
          X_DECISION_DATE => NULL,
          X_ATTRIBUTE_CATEGORY => p_applinst_rec.attribute_category ,
          X_ATTRIBUTE1=> p_applinst_rec.ATTRIBUTE1,
          X_ATTRIBUTE2=> p_applinst_rec.ATTRIBUTE2,
          X_ATTRIBUTE3=> p_applinst_rec.ATTRIBUTE3,
          X_ATTRIBUTE4=>p_applinst_rec.ATTRIBUTE4,
          X_ATTRIBUTE5=>p_applinst_rec.ATTRIBUTE5,
          X_ATTRIBUTE6=>p_applinst_rec.ATTRIBUTE6,
          X_ATTRIBUTE7=>p_applinst_rec.ATTRIBUTE7,
          X_ATTRIBUTE8=>p_applinst_rec.ATTRIBUTE8,
          X_ATTRIBUTE9=>p_applinst_rec.ATTRIBUTE9,
          X_ATTRIBUTE10=>p_applinst_rec.ATTRIBUTE10,
          X_ATTRIBUTE11=>p_applinst_rec.ATTRIBUTE11,
          X_ATTRIBUTE12=>p_applinst_rec.ATTRIBUTE12,
          X_ATTRIBUTE13=>p_applinst_rec.ATTRIBUTE13,
          X_ATTRIBUTE14=>p_applinst_rec.ATTRIBUTE14,
          X_ATTRIBUTE15=>p_applinst_rec.ATTRIBUTE15,
          X_ATTRIBUTE16=>p_applinst_rec.ATTRIBUTE16,
          X_ATTRIBUTE17=>p_applinst_rec.ATTRIBUTE17,
          X_ATTRIBUTE18=>p_applinst_rec.ATTRIBUTE18,
          X_ATTRIBUTE19=>p_applinst_rec.ATTRIBUTE19,
          X_ATTRIBUTE20=>p_applinst_rec.ATTRIBUTE20,
          X_WAITLIST_STATUS => NULL,
          X_ATTRIBUTE21=>p_applinst_rec.ATTRIBUTE21,
          X_ATTRIBUTE22=>p_applinst_rec.ATTRIBUTE22,
          X_ATTRIBUTE23=>p_applinst_rec.ATTRIBUTE23,
          X_ATTRIBUTE24=>p_applinst_rec.ATTRIBUTE24,
          X_ATTRIBUTE25=>p_applinst_rec.ATTRIBUTE25,
          X_ATTRIBUTE26=>p_applinst_rec.ATTRIBUTE26,
          X_ATTRIBUTE27=>p_applinst_rec.ATTRIBUTE27,
          X_ATTRIBUTE28=>p_applinst_rec.ATTRIBUTE28,
          X_ATTRIBUTE29=>p_applinst_rec.ATTRIBUTE29,
          X_ATTRIBUTE30=>p_applinst_rec.ATTRIBUTE30,
          X_ATTRIBUTE31=>p_applinst_rec.ATTRIBUTE31,
          X_ATTRIBUTE32=>p_applinst_rec.ATTRIBUTE32,
          X_ATTRIBUTE33=>p_applinst_rec.ATTRIBUTE33,
          X_ATTRIBUTE34=>p_applinst_rec.ATTRIBUTE34,
          X_ATTRIBUTE35=>p_applinst_rec.ATTRIBUTE35,
          X_ATTRIBUTE36=>p_applinst_rec.ATTRIBUTE36,
          X_ATTRIBUTE37=>p_applinst_rec.ATTRIBUTE37,
          X_ATTRIBUTE38=>p_applinst_rec.ATTRIBUTE38,
          X_ATTRIBUTE39=>p_applinst_rec.ATTRIBUTE39,
          X_ATTRIBUTE40=>p_applinst_rec.ATTRIBUTE40,
          X_SS_APPLICATION_ID=> NULL,
          X_SS_PWD=> NULL,
          X_DECISION_REASON_ID=> NULL,
          X_US_VERSION_NUMBER => p_applinst_rec.Us_Version_Number,
          X_DECISION_NOTES=> NULL,
          X_PENDING_REASON_ID=> NULL,
          X_PREFERENCE_NUMBER  => p_applinst_rec.Preference_Number,
          X_ADM_DOC_STATUS=>   l_Adm_Doc_Status,
          X_ADM_ENTRY_QUAL_STATUS=> l_Adm_Entry_Qual_Status,
          X_DEFICIENCY_IN_PREP=> NULL,
          X_LATE_ADM_FEE_STATUS => l_Late_Adm_Fee_Status,
          X_SPL_CONSIDER_COMMENTS=> NULL,
          X_APPLY_FOR_FINAID => p_applinst_rec.apply_for_finaid,
          X_FINAID_APPLY_DATE=> l_finaid_apply_date,
          X_ADM_OUTCOME_STATUS => l_adm_pending_outcome_status,
          X_ADM_OTCM_STAT_AUTH_PER_ID => NULL,
          X_ADM_OUTCOME_STATUS_AUTH_DT => NULL,
          X_ADM_OUTCOME_STATUS_REASON  => NULL,
          X_OFFER_DT => NULL,
          X_OFFER_RESPONSE_DT  => NULL,
          X_PRPSD_COMMENCEMENT_DT => NULL,
          X_ADM_CNDTNL_OFFER_STATUS => l_adm_cndtnl_offer_status,
          X_CNDTNL_OFFER_SATISFIED_DT => NULL,
          X_CNDNL_OFR_MUST_BE_STSFD_IND  => 'N',
          X_ADM_OFFER_RESP_STATUS => l_adm_offer_resp_status,
          X_ACTUAL_RESPONSE_DT  => NULL,
          X_ADM_OFFER_DFRMNT_STATUS  => l_adm_offer_dfrmnt_status,
          X_DEFERRED_ADM_CAL_TYPE => NULL,
          X_DEFERRED_ADM_CI_SEQUENCE_NUM => NULL,
          X_DEFERRED_TRACKING_ID   => NULL,
          X_ASS_RANK    => p_applinst_rec.ass_rank,
          X_SECONDARY_ASS_RANK  => p_applinst_rec.secondary_ass_rank,
          X_INTR_ACCEPT_ADVICE_NUM   => p_applinst_rec.intrntnl_acceptance_advice_num,
          X_ASS_TRACKING_ID => p_applinst_rec.ass_tracking_id,
          X_FEE_CAT=> NVL(p_applinst_rec.Fee_Cat,l_fee_cat),
          X_HECS_PAYMENT_OPTION => NVL(p_applinst_rec.Hecs_Payment_Option, l_Hecs_Payment_Option),
          X_EXPECTED_COMPLETION_YR => NVL(p_applinst_rec.expected_completion_yr, l_expected_completion_yr),
          X_EXPECTED_COMPLETION_PERD => NVL(p_applinst_rec.expected_completion_perd, l_expected_completion_perd),
          X_CORRESPONDENCE_CAT => NULL,
          X_ENROLMENT_CAT  => NVL(p_applinst_rec.Enrolment_Cat,l_Enrolment_Cat),
          X_FUNDING_SOURCE => NVL(p_applinst_rec.funding_source,l_funding_source),
          X_APPLICANT_ACPTNCE_CNDTN => NULL,
          X_CNDTNL_OFFER_CNDTN => NULL,
          X_AUTHORIZED_DT => NULL,
          X_AUTHORIZING_PERS_ID => NULL,
          X_IDX_CALC_DATE => NULL,
          X_MODE =>'R',
          X_FUT_ACAD_CAL_TYPE                          => NULL , -- Bug # 2217104
          X_FUT_ACAD_CI_SEQUENCE_NUMBER                => NULL ,-- Bug # 2217104
          X_FUT_ADM_CAL_TYPE                           => NULL , -- Bug # 2217104
          X_FUT_ADM_CI_SEQUENCE_NUMBER                 => NULL , -- Bug # 2217104
          X_PREV_TERM_ADM_APPL_NUMBER                 => NULL , -- Bug # 2217104
          X_PREV_TERM_SEQUENCE_NUMBER                 => NULL , -- Bug # 2217104
          X_FUT_TERM_ADM_APPL_NUMBER                   => NULL , -- Bug # 2217104
          X_FUT_TERM_SEQUENCE_NUMBER                   => NULL , -- Bug # 2217104
          X_DEF_ACAD_CAL_TYPE                             => NULL, -- Bug  2395510
          X_DEF_ACAD_CI_SEQUENCE_NUM          => NULL,-- Bug  2395510
          X_DEF_PREV_TERM_ADM_APPL_NUM  => NULL,-- Bug  2395510
          X_DEF_PREV_APPL_SEQUENCE_NUM    => NULL,-- Bug  2395510
          X_DEF_TERM_ADM_APPL_NUM               => NULL,-- Bug  2395510
          X_DEF_APPL_SEQUENCE_NUM                 => NULL,-- Bug  2395510
          X_Org_Id => l_org_id,
          X_ENTRY_STATUS => p_applinst_rec.entry_status,
          X_ENTRY_LEVEL => p_applinst_rec.entry_level,
          X_SCH_APL_TO_ID => p_applinst_rec.sch_apl_to_id);

        update_person_type(p_sequence_number=> l_acai_sequence_number
                                             ,p_nominated_course_cd => p_applinst_rec.nominated_course_cd
			                     ,p_person_id   => p_person_id
			                     ,p_adm_appl_number => p_admission_Appl_number);
         update_appl_inst(p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id, p_status => '1',
                  p_error_text => NULL, p_sequence_number => l_acai_sequence_number, p_error_code => NULL,
                  p_admission_appl_number => p_admission_Appl_number,
                  p_match_ind => NVL(p_applinst_rec.match_ind , cst_mi_val_11) );

        p_Status := '1';

    /* Added the raise event as part of Bug 3391593 */
    IF l_acai_sequence_number IS NOT NULL THEN
--	Call The assign requirment procedure and admission tracking completion Procedure *** Autoadmit
-- This single process will call both the procedure
    l_error_code1 := NULL;
    IGS_AD_GEN_014.auto_assign_requirement(
			p_person_id		    => p_Person_Id,
                        p_admission_appl_number     => p_Admission_Appl_Number,
                        p_course_cd                 => p_applinst_rec.nominated_course_cd,
                        p_sequence_number           => l_acai_sequence_number,
			p_called_from         => 'IM',
			p_error_text          => l_error_text1,
			p_error_code          => l_error_code1
    );
    IF l_error_code1 IS NOT NULL THEN
                    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_ASSIGNREQ_ERRM');
		    FND_MESSAGE.SET_TOKEN ('PERSON_ID', p_person_id);
		    FND_MESSAGE.SET_TOKEN ('ADM_APPL_NUM', p_admission_Appl_number);
		    FND_MESSAGE.SET_TOKEN ('NOMINATED_COURSE_CODE', p_applinst_rec.nominated_course_cd);
		    FND_MESSAGE.SET_TOKEN ('SEQUENCE_NUMBER', l_acai_sequence_number);
		    FND_MESSAGE.SET_TOKEN ('ERROR_MESSAGE', l_error_text1);
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    END IF;

--Assign Qualification Types to application instance being submitted  **** Auto admit
   IGS_AD_GEN_014.assign_qual_type(p_person_id         => p_Person_Id,
                                 p_admission_appl_number     => p_Admission_Appl_Number,
                                 p_course_cd => p_applinst_rec.nominated_course_cd,
                                 p_sequence_number     => l_acai_sequence_number
   );
	  -- Application Instance has been successfully created and the business event needs to be raised
         igs_ad_wf_001.wf_raise_event(p_person_id => p_person_id,
                                      p_raised_for => 'IAC'
	    			 );
    END IF;

    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO before_insert_ps_appl;
        p_status := '3';
         igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_at_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => l_msg_count,
                   p_msg_data                    => l_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
        IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
            l_error_text := l_msg_data;
            l_error_code := 'E322';

            IF p_enable_log = 'Y' THEN
                igs_ad_imp_001.logerrormessage(p_applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
            END IF;
        ELSE
             l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
             l_error_code := 'E518';
             IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	        l_label :='igs.plsql.igs_ad_imp_004.create_single_appl_instance.exception ';
                l_debug_str  := 'Failed Creating Application instance'||l_msg_data;
   	        fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
       	        fnd_message.set_token('INTERFACE_ID',p_applinst_rec.interface_ps_appl_inst_id);
 	        fnd_message.set_token('ERROR_CD','E322');

	        l_debug_str :=  fnd_message.get;

                   fnd_log.string_with_context( fnd_log.level_exception,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
               END IF;

        END IF;
      update_appl_inst(p_admission_appl_number => NULL, p_match_ind => NULL, p_appl_inst_id => p_applinst_rec.interface_ps_appl_inst_id, p_status => '3',
        p_error_text => l_error_text, p_sequence_number => NULL, p_error_code => l_error_code);

    END create_single_appl_instance;

    PROCEDURE Process_application_instance(p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE
         ) IS

         l_Status VARCHAR2(1);

       l_msg_at_index   NUMBER ;
       l_return_status   VARCHAR2(1);
       l_msg_count      NUMBER ;
       l_msg_data       VARCHAR2(2000);
       l_hash_msg_name_text_type_tab   igs_ad_gen_016.g_msg_name_text_type_table;
       l_error_code VARCHAR2(4);
       l_error_text VARCHAR2(2000);
       l_finaid_apply_date igs_ad_ps_appl_inst.finaid_apply_date%TYPE;

    BEGIN
        --For all application instance interface record
        --   IF update_seq_num is NOT NULL
        --           update the instance
        --   ELSE create_application_instance
             --If given invalid update transcript ID then error out.
         UPDATE igs_ad_ps_appl_inst_int  aplinst
           SET
              status = '3'
              ,  error_code =  'E706'
              ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E706', 8405)
           WHERE  interface_run_id = p_interface_run_id
           AND status ='2'
           AND update_adm_seq_number IS NOT NULL
           AND NOT EXISTS ( SELECT 1 FROM igs_ad_ps_appl_inst
                                        WHERE person_id = aplinst.person_id
                                        AND  admission_Appl_number = aplinst.admission_Appl_number
                                        AND nominated_course_cd  = aplinst.nominated_course_cd
                                        AND  sequence_number = aplinst.update_adm_seq_number
                                        ) ;
         COMMIT;
            --	1. Set STATUS to 3 for interface records with RULE = E or I and MATCH IND is not null and not '15'
          IF p_rule IN ('E', 'I')  THEN
              UPDATE igs_ad_ps_appl_inst_int
              SET
                  status = '3'
                  , error_code = 'E700'
                  ,error_Text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
               WHERE  interface_run_id = p_interface_run_id
               AND status = '2'
               AND NVL (match_ind, '15') <> '15';
          END IF;
          COMMIT;

            --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
          IF p_rule = 'R'  THEN
               UPDATE igs_ad_ps_appl_inst_int
               SET
                 status = '1',  error_code = NULL
               WHERE  interface_run_id = p_interface_run_id
               AND status = '2'
               AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
          END IF;

          IF p_rule = 'E' THEN
             UPDATE igs_ad_ps_appl_inst_int
              SET
                 status = '1'
                , match_ind = '19'
                , SEQUENCE_NUMBER = update_adm_seq_number
              WHERE  interface_run_id = p_interface_run_id
              AND status = '2'
              AND update_adm_seq_number  IS NOT NULL ;
              COMMIT;
          END IF;
        l_admission_application_type  := NULL;
        FOR applinst_rec IN applinst_cur(NULL) LOOP
              IF applinst_rec.dmlmode =  cst_insert  THEN
                FOR p_appl_rec IN appl_cur_upd(applinst_rec.interface_appl_id) LOOP
                     IF l_admission_application_type IS NULL
                         OR p_appl_rec.admission_application_type <> l_admission_application_type THEN
                           populate_apc_columns(p_appl_rec.admission_application_type);
                     END IF;
                    create_single_appl_instance(applinst_rec, applinst_rec.person_id, applinst_rec.admission_Appl_number, p_appl_rec, l_status);
                END LOOP;
              ELSIF applinst_rec.dmlmode =  cst_update THEN
                 BEGIN
                  FOR p_appl_rec IN appl_cur_upd(applinst_rec.interface_appl_id) LOOP
                    IF l_admission_application_type IS NULL
                         OR p_appl_rec.admission_application_type <> l_admission_application_type THEN
                           populate_apc_columns(p_appl_rec.admission_application_type);
                    END IF;
                    IF  validate_apc_steps(applinst_rec) THEN
                       OPEN dup_applinst_cur(applinst_rec, applinst_rec.person_id, applinst_rec.admission_appl_number);
                       FETCH dup_applinst_cur INTO dup_applinst_rec;
                       CLOSE dup_applinst_cur;

                      IF NVL(applinst_rec.apply_for_finaid,'N') = 'N' THEN
      	                   l_finaid_apply_date := NULL;
	              ELSE
 	                   l_finaid_apply_date := applinst_rec.finaid_apply_date;
	              END IF;

                      l_msg_at_index := igs_ge_msg_stack.count_msg;
                      SAVEPOINT before_update_appl_inst;
                      igs_ad_ps_appl_inst_pkg.update_row(
  		        x_rowid => dup_applinst_rec.rowid,
          	        x_person_id =>dup_applinst_rec.person_id,
	                x_admission_appl_number => dup_applinst_rec.admission_appl_number,
                        x_nominated_course_cd=> dup_applinst_rec.nominated_course_cd,
                        x_sequence_number=> dup_applinst_rec.sequence_number,
                       x_predicted_gpa=> dup_applinst_rec.predicted_gpa,
                       x_academic_index=>dup_applinst_rec.academic_index,
	               x_adm_cal_type => dup_applinst_rec.adm_cal_type,
	               x_app_file_location =>dup_applinst_rec.app_file_location,
		       x_adm_ci_sequence_number=>dup_applinst_rec.adm_ci_sequence_number,
   	               x_course_cd=>dup_applinst_rec.course_cd,
	               x_app_source_id=> NVL(applinst_rec.app_source_id,dup_applinst_rec.app_source_id),
	               x_crv_version_number=>NVL(applinst_rec.crv_version_number, dup_applinst_rec.crv_version_number),
	               x_waitlist_rank=>dup_applinst_rec.waitlist_rank,
		       x_waitlist_status=>dup_applinst_rec.waitlist_status,
	               x_location_cd=> NVL(applinst_rec.location_cd,dup_applinst_rec.location_cd),
	               x_attent_other_inst_cd=>dup_applinst_rec.attent_other_inst_cd,
		       x_attendance_mode=>NVL(applinst_rec.attendance_mode,dup_applinst_rec.attendance_mode),
		       x_edu_goal_prior_enroll_id=> NVL(applinst_rec.edu_goal_prior_enroll_id,dup_applinst_rec.edu_goal_prior_enroll_id),
 	               x_attendance_type=>NVL(applinst_rec.attendance_type,dup_applinst_rec.attendance_type),
	               x_decision_make_id=>dup_applinst_rec.decision_make_id,
		       x_unit_set_cd=>NVL(applinst_rec.unit_set_cd,dup_applinst_rec.unit_set_cd),
	               x_decision_date=>dup_applinst_rec.decision_date,
		       x_attribute_category=>NVL(applinst_rec.attribute_category,dup_applinst_rec.attribute_category),
	               x_attribute1=>NVL(applinst_rec.attribute1,dup_applinst_rec.attribute1),
	               x_attribute2=>NVL(applinst_rec.attribute2,dup_applinst_rec.attribute2),
	               x_attribute3=>NVL(applinst_rec.attribute3,dup_applinst_rec.attribute3),
	               x_attribute4=>NVL(applinst_rec.attribute4,dup_applinst_rec.attribute4),
	               x_attribute5=>NVL(applinst_rec.attribute5,dup_applinst_rec.attribute5),
	               x_attribute6=>NVL(applinst_rec.attribute6,dup_applinst_rec.attribute6),
	               x_attribute7=>NVL(applinst_rec.attribute7,dup_applinst_rec.attribute7),
	               x_attribute8=>NVL(applinst_rec.attribute8,dup_applinst_rec.attribute8),
	               x_attribute9=>NVL(applinst_rec.attribute9,dup_applinst_rec.attribute9),
	               x_attribute10=>NVL(applinst_rec.attribute10,dup_applinst_rec.attribute10),
	               x_attribute11=>NVL(applinst_rec.attribute11,dup_applinst_rec.attribute11),
	               x_attribute12=>NVL(applinst_rec.attribute12,dup_applinst_rec.attribute12),
	               x_attribute13=>NVL(applinst_rec.attribute13,dup_applinst_rec.attribute13),
	               x_attribute14=>NVL(applinst_rec.attribute14,dup_applinst_rec.attribute14),
	               x_attribute15=>NVL(applinst_rec.attribute15,dup_applinst_rec.attribute15),
	               x_attribute16=>NVL(applinst_rec.attribute16,dup_applinst_rec.attribute16),
	               x_attribute17=>NVL(applinst_rec.attribute17,dup_applinst_rec.attribute17),
	               x_attribute18=>NVL(applinst_rec.attribute18,dup_applinst_rec.attribute18),
	               x_attribute19=>NVL(applinst_rec.attribute19,dup_applinst_rec.attribute19),
	               x_attribute20=>NVL(applinst_rec.attribute20,dup_applinst_rec.attribute20),
	               x_decision_reason_id=>dup_applinst_rec.decision_reason_id,
	               x_us_version_number=>NVL(applinst_rec.us_version_number,dup_applinst_rec.us_version_number),
	               x_decision_notes=>dup_applinst_rec.decision_notes,
	               x_pending_reason_id=>dup_applinst_rec.pending_reason_id,
	               x_preference_number=>NVL(applinst_rec.preference_number,dup_applinst_rec.preference_number),
	               x_adm_doc_status=>dup_applinst_rec.adm_doc_status,
	               x_adm_entry_qual_status=>dup_applinst_rec.adm_entry_qual_status,
	               x_deficiency_in_prep=>dup_applinst_rec.deficiency_in_prep,
	               x_late_adm_fee_status=>dup_applinst_rec.late_adm_fee_status,
	               x_spl_consider_comments=>dup_applinst_rec.spl_consider_comments,
	               x_apply_for_finaid=> NVL(applinst_rec.apply_for_finaid,dup_applinst_rec.apply_for_finaid),
	               x_finaid_apply_date=> l_finaid_apply_date,
	               x_adm_outcome_status=>dup_applinst_rec.adm_outcome_status,
  	               x_adm_otcm_stat_auth_per_id=>dup_applinst_rec.adm_otcm_status_auth_person_id,
	               x_adm_outcome_status_auth_dt=>dup_applinst_rec.adm_outcome_status_auth_dt,
	               x_adm_outcome_status_reason=> dup_applinst_rec.adm_outcome_status_reason,
	               x_offer_dt=>dup_applinst_rec.offer_dt,
	               x_offer_response_dt=>dup_applinst_rec.offer_response_dt,
	               x_prpsd_commencement_dt=>dup_applinst_rec.prpsd_commencement_dt,
	               x_adm_cndtnl_offer_status=>dup_applinst_rec.adm_cndtnl_offer_status,
	               x_cndtnl_offer_satisfied_dt=> dup_applinst_rec.cndtnl_offer_satisfied_dt,
     	               x_cndnl_ofr_must_be_stsfd_ind=>dup_applinst_rec.cndtnl_offer_must_be_stsfd_ind,
	               x_adm_offer_resp_status=> dup_applinst_rec.adm_offer_resp_status,
	               x_actual_response_dt=> dup_applinst_rec.actual_response_dt,
	               x_adm_offer_dfrmnt_status=> dup_applinst_rec.adm_offer_dfrmnt_status,
	               x_deferred_adm_cal_type=> dup_applinst_rec.deferred_adm_cal_type,
	               x_deferred_adm_ci_sequence_num=> dup_applinst_rec.deferred_adm_ci_sequence_num,
	               x_deferred_tracking_id=>  dup_applinst_rec.deferred_tracking_id,
	               x_ass_rank=> NVL(applinst_rec.ass_rank,dup_applinst_rec.ass_rank),
	               x_secondary_ass_rank=>NVL(applinst_rec.secondary_ass_rank,dup_applinst_rec.secondary_ass_rank),
	               x_intr_accept_advice_num=>NVL(applinst_rec.intrntnl_acceptance_advice_num,dup_applinst_rec.intrntnl_acceptance_advice_num),
	               x_ass_tracking_id=> NVL(applinst_rec.ass_tracking_id,dup_applinst_rec.ass_tracking_id),
	               x_fee_cat=>NVL(applinst_rec.fee_cat,dup_applinst_rec.fee_cat),
	               x_hecs_payment_option=>NVL(applinst_rec.hecs_payment_option, dup_applinst_rec.hecs_payment_option),
	               x_expected_completion_yr=>NVL(applinst_rec.expected_completion_yr, dup_applinst_rec.expected_completion_yr),
	               x_expected_completion_perd=>NVL(applinst_rec.expected_completion_perd, dup_applinst_rec.expected_completion_perd),
	               x_correspondence_cat=> dup_applinst_rec.correspondence_cat,
	               x_enrolment_cat=>NVL(applinst_rec.enrolment_cat,dup_applinst_rec.enrolment_cat),
	               x_funding_source=> NVL(applinst_rec.funding_source, dup_applinst_rec.funding_source),
	               x_applicant_acptnce_cndtn=> dup_applinst_rec.applicant_acptnce_cndtn,
	               x_cndtnl_offer_cndtn=> dup_applinst_rec.cndtnl_offer_cndtn,
	               x_ss_application_id=>dup_applinst_rec.ss_application_id,
	               x_ss_pwd=>dup_applinst_rec.ss_pwd,    --Bug Enh No : 1891835 Added two columns
	               x_authorized_dt => dup_applinst_rec.authorized_dt,
	               --Bug Enh No : 1891835 Added two columns
   	               x_authorizing_pers_id => dup_applinst_rec.authorizing_pers_id,
	               -- Enh Bug#1964478 added three parameters
                       x_entry_status => NVL(applinst_rec.entry_status, dup_applinst_rec.entry_status),
                       x_entry_level  => NVL(applinst_rec.entry_level, dup_applinst_rec.entry_level),
                       x_sch_apl_to_id=> NVL(applinst_rec.sch_apl_to_id, dup_applinst_rec.sch_apl_to_id),
  	               x_idx_calc_date => dup_applinst_rec.idx_calc_date,
	               x_fut_acad_cal_type                          => dup_applinst_rec.future_acad_cal_type, -- bug # 2217104
                       x_fut_acad_ci_sequence_number                => dup_applinst_rec.future_acad_ci_sequence_number,-- bug # 2217104
                       x_fut_adm_cal_type                           => dup_applinst_rec.future_adm_cal_type, -- bug # 2217104
                       x_fut_adm_ci_sequence_number                 => dup_applinst_rec.future_adm_ci_sequence_number, -- bug # 2217104
                       x_prev_term_adm_appl_number                 => dup_applinst_rec.previous_term_adm_appl_number, -- bug # 2217104
                       x_prev_term_sequence_number                 => dup_applinst_rec.previous_term_sequence_number, -- bug # 2217104
                       x_fut_term_adm_appl_number                   => dup_applinst_rec.future_term_adm_appl_number, -- bug # 2217104
                       x_fut_term_sequence_number                   => dup_applinst_rec.future_term_sequence_number, -- bug # 2217104
		       x_def_acad_cal_type                                        => dup_applinst_rec.def_acad_cal_type, --bug 2395510
		       x_def_acad_ci_sequence_num                   => dup_applinst_rec.def_acad_ci_sequence_num, --bug 2395510
		       x_def_prev_term_adm_appl_num           => dup_applinst_rec.def_prev_term_adm_appl_num,--bug 2395510
		       x_def_prev_appl_sequence_num              => dup_applinst_rec.def_prev_appl_sequence_num,--bug 2395510
		       x_def_term_adm_appl_num                        => dup_applinst_rec.def_term_adm_appl_num,--bug 2395510
		       x_def_appl_sequence_num                           => dup_applinst_rec.def_appl_sequence_num,--bug 2395510
	               x_mode=>'R',
		       x_appl_inst_status	=>dup_applinst_rec.appl_inst_status,
		       x_ais_reason		=>dup_applinst_rec.ais_reason
		       );

                        UPDATE igs_ad_ps_appl_inst_int
                        SET
                        status = '1',
                        sequence_number = dup_applinst_rec.sequence_number
                        WHERE interface_ps_appl_inst_id =  applinst_rec.interface_ps_appl_inst_id;
                    END IF; --Validate_Apc_steps

                  END LOOP;
            EXCEPTION
                    WHEN OTHERS THEN
                    ROLLBACK TO before_update_appl_inst;
                       igs_ad_gen_016.extract_msg_from_stack (
                              p_msg_at_index                => l_msg_at_index,
                              p_return_status               => l_return_status,
                              p_msg_count                   => l_msg_count,
                              p_msg_data                    => l_msg_data,
                              p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
                      IF l_hash_msg_name_text_type_tab(l_msg_count-1).name <>  'ORA'  THEN
                           l_error_text := l_msg_data;
                           l_error_code := NULL;

                           IF p_enable_log = 'Y' THEN
                              igs_ad_imp_001.logerrormessage(applinst_rec.interface_ps_appl_inst_id,l_error_text,'IGS_AD_APPL_INST_INT');
                           END IF;
                      ELSE
                         l_error_text :=  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E518', 8405);
                         l_error_code := 'E518';
                         IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN
              	              l_label :='igs.plsql.igs_ad_imp_004.Process_application_instance.exception '||l_msg_data;

           	              fnd_message.set_name('IGS','IGS_PE_IMP_ERROR');
       	                      fnd_message.set_token('INTERFACE_ID',applinst_rec.interface_ps_appl_inst_id);
  	                      fnd_message.set_token('ERROR_CD','E322');

	                      l_debug_str :=  fnd_message.get;

                              fnd_log.string_with_context( fnd_log.level_exception,
					  l_label,
					  l_debug_str, NULL,
					  NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
                         END IF;
                       END IF;
                       UPDATE igs_ad_ps_appl_inst_int
                       SET
                                   status = '3',
                                   error_code = l_error_code,
                                   error_text = l_error_text
                       WHERE interface_ps_appl_inst_id =  applinst_rec.interface_ps_appl_inst_id;

                      END;
              END IF;
        END LOOP;

         IF p_rule = 'R'  THEN
                UPDATE igs_ad_ps_appl_inst_int   applinst
                SET
                   status = '1'
                  , match_ind = '23'
                  , sequence_number = applinst.update_adm_seq_number
                WHERE  EXISTS ( SELECT  'X'
                FROM igs_ad_ps_appl_inst ai
                WHERE   ai.person_id = applinst.person_id AND
	                ai.nominated_course_cd = applinst.nominated_course_cd AND
			ai.admission_appl_number  = applinst.admission_Appl_number  AND
			ai.sequence_number = applinst.update_adm_seq_number AND
			NVL(ai.crv_version_number,-99)=
			NVL(NVL(applinst.crv_version_number, ai.crv_version_number),-99) AND
			NVL(ai.location_cd,'*') =
			NVL(NVL(applinst.location_cd, ai.location_cd),'*') AND
			NVL(ai.attendance_mode,'*')=
			NVL(NVL(applinst.attendance_mode, ai.attendance_mode), '*') AND
			NVL(ai.edu_goal_prior_enroll_id,-99)  =
			NVL(NVL(applinst.edu_goal_prior_enroll_id, ai.edu_goal_prior_enroll_id), -99) AND
			NVL(ai.app_source_id,-99) =
			NVL(NVL(applinst.app_source_id, ai.app_source_id), -99) AND
			NVL(ai.attendance_type,'*') =
			NVL(NVL(applinst.attendance_type, ai.attendance_type), '*') AND
			NVL(ai.unit_set_cd, '*') =
			NVL(NVL(applinst.unit_set_cd, ai.unit_set_cd ), '*') AND
			NVL(ai.us_version_number,-99)=
			NVL(NVL(applinst.us_version_number, ai.us_version_number), -99) AND
			NVL(ai.preference_number,-99)=
			NVL(NVL(applinst.preference_number, ai.preference_number), -99) AND
			NVL(ai.apply_for_finaid,'*') =
			NVL(NVL(applinst.apply_for_finaid, ai.apply_for_finaid), '*') AND
			NVL(ai.finaid_apply_date,sysdate) =
			NVL(NVL(applinst.finaid_apply_date, ai.finaid_apply_date), sysdate) AND
			NVL(ai.attribute_category,'*')=
			NVL(NVL(applinst.attribute_category, ai.attribute_category), '*') AND
			NVL(ai.attribute1,'*') = NVL(NVL(applinst.attribute1, ai.attribute1), '*') AND
			NVL(ai.attribute2,'*') = NVL(NVL(applinst.attribute2, ai.attribute2), '*') AND
			NVL(ai.attribute3,'*') = NVL(NVL(applinst.attribute3, ai.attribute3), '*') AND
			NVL(ai.attribute4,'*') = NVL(NVL(applinst.attribute4, ai.attribute4), '*') AND
			NVL(ai.attribute5,'*') = NVL(NVL(applinst.attribute5, ai.attribute5), '*') AND
			NVL(ai.attribute6,'*') = NVL(NVL(applinst.attribute6, ai.attribute6), '*') AND
			NVL(ai.attribute7,'*') = NVL(NVL(applinst.attribute7, ai.attribute7), '*') AND
			NVL(ai.attribute8,'*') = NVL(NVL(applinst.attribute8, ai.attribute8), '*') AND
			NVL(ai.attribute9,'*') = NVL(NVL(applinst.attribute9, ai.attribute9), '*')   AND
			NVL(ai.attribute10,'*') = NVL(NVL(applinst.attribute10, ai.attribute10), '*') AND
			NVL(ai.attribute11,'*') = NVL(NVL(applinst.attribute11, ai.attribute11), '*') AND
			NVL(ai.attribute12,'*') = NVL(NVL(applinst.attribute12, ai.attribute12), '*') AND
			NVL(ai.attribute13,'*') = NVL(NVL(applinst.attribute13, ai.attribute13), '*') AND
			NVL(ai.attribute14,'*') = NVL(NVL(applinst.attribute14, ai.attribute14), '*') AND
			NVL(ai.attribute15,'*') = NVL(NVL(applinst.attribute15, ai.attribute15), '*') AND
			NVL(ai.attribute16,'*') = NVL(NVL(applinst.attribute16, ai.attribute16), '*') AND
			NVL(ai.attribute17,'*') = NVL(NVL(applinst.attribute17, ai.attribute17), '*') AND
			NVL(ai.attribute18,'*') = NVL(NVL(applinst.attribute18, ai.attribute18), '*') AND
			NVL(ai.attribute19,'*') = NVL(NVL(applinst.attribute19, ai.attribute19), '*') AND
			NVL(ai.attribute20,'*') = NVL(NVL(applinst.attribute20, ai.attribute20), '*')
                  );
         END IF;


         IF p_rule = 'R'  THEN
                UPDATE igs_ad_ps_appl_inst_int
                SET
                status = '3'
                , match_ind = '20'
               WHERE  interface_run_id = p_interface_run_id
               AND status = '2'
                AND update_adm_seq_number IS NOT NULL;
         END IF;

         IF p_rule = 'R'  THEN
           UPDATE igs_ad_ps_appl_inst_int
           SET
             status = '3'
            , error_code = 'E700'
            ,  error_text = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
               WHERE  interface_run_id = p_interface_run_id
               AND status = '2'
               AND match_ind IS NOT NULL;
           END IF;
      COMMIT;
    END Process_application_instance;




BEGIN
-------------------------------------------------------------------------------
---------------------  Main procedure prc_appcln--------------------------
--------------------------------------------------------------------------------
---------------------  Initialization of Package Variables--------------------------
     l_adm_appl_status := Igs_Ad_Gen_008.ADMP_GET_SYS_AAS('RECEIVED');
     l_adm_fee_status := Igs_Ad_Gen_009.ADMP_GET_SYS_AFS('NOT-APPLIC');
     l_Late_Adm_Fee_Status := Igs_Ad_Gen_009.ADMP_GET_SYS_AFS('NOT-APPLIC');
     l_cndnl_ofr_must_be_stsfd_ind := 'N';
     l_adm_pending_outcome_status := IGS_AD_GEN_009.admp_get_sys_aos('PENDING');
     l_adm_cndtnl_offer_status	:= IGS_AD_GEN_009.admp_get_sys_acos('NOT-APPLIC');
     l_adm_offer_resp_status	:= IGS_AD_GEN_009.admp_get_sys_aors('NOT-APPLIC');
     l_adm_offer_dfrmnt_status	:= IGS_AD_GEN_009.admp_get_sys_aods('NOT-APPLIC');
     l_admission_application_type  := NULL;
     l_admission_cat     := NULL;
     l_s_admission_process_type   := NULL;

     l_fee_cat := NULL ;
     l_enrolment_cat   := NULL;
     l_hecs_payment_option := NULL;
     l_adm_entry_qual_status := NULL;
     l_request_id := fnd_global.conc_request_id; -- This is Local Variable
    l_prog_label  := 'igs.plsql.igs_ad_imp_004.prc_appcln';
    l_label  := 'igs.plsql.igs_ad_imp_004.prc_appcln.';
    l_debug_str  := 'igs.plsql.igs_ad_imp_004.prc_appcln.';
    l_org_id  := igs_ge_gen_003.get_org_id;
--------------------------------------------------------------------------------

    l_prog_label := 'igs.plsql.igs_ad_imp_004.prc_appcln.';
     IF fnd_log.test(fnd_log.level_exception,l_prog_label) THEN

	l_label :='igs.plsql.igs_ad_imp_004.prc_appcln.begin';
	l_debug_str := 'Process Application begin';

        fnd_log.string_with_context( fnd_log.level_procedure,
	   l_label,
	   l_debug_str, NULL,
	   NULL,NULL,NULL,NULL,TO_CHAR(l_request_id));
     END IF;

     UPDATE igs_ad_apl_int api
     SET
       status = '3',
       error_code =  'E523',
       error_text = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E523', 8405)
     WHERE  interface_run_id = p_interface_run_id
     AND update_adm_appl_number IS NOT NULL
     AND NOT EXISTS ( SELECT 1 FROM IGS_AD_APPL appl_oss
                                     WHERE  person_id  =  api.person_id
                                     AND admission_Appl_number =
                                        NVL(api.update_adm_appl_number, appl_oss.admission_Appl_number)
                                   ) ;
     COMMIT;
       --	1. Set STATUS to 3 for interface records with RULE = E or I and MATCH IND is not null and not '15'
     IF p_rule IN ('E', 'I')  THEN
        UPDATE igs_ad_apl_int
          SET
          status = '3'
          , error_code = 'E700'
          ,error_text = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E700', 8405)
          WHERE interface_run_id = p_interface_run_id
          AND status = '2'
         AND NVL (match_ind, '15') <> '15';
     END IF;
     COMMIT;

     --	2. Set STATUS to 1 for interface records with RULE = R and MATCH IND = 17,18,19,22,23,24,27
     IF p_rule = 'R'  THEN
        UPDATE igs_ad_apl_int
        SET
        status = '1'
        ,error_code = NULL
        ,error_text = NULL
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IN ('17', '18', '19', '22', '23', '24', '27');
     END IF;
     COMMIT;

    -- 5. Set STATUS to 1 and MATCH IND to 19 for interface records with RULE = E matching OSS record(s)
  IF  p_rule = 'E' THEN
      UPDATE igs_ad_apl_int   api
      SET
         status = '1'
        , match_ind = '19'
        , admission_appl_number = update_adm_appl_number
      WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND update_adm_appl_number IS NOT NULL;
  END IF;
COMMIT;
--  Error out applications that need to be updated but they have legacy data
  IF p_legacy_ind = 'Y' THEN
    UPDATE igs_ad_apl_int api
    SET
         status     = '3'
         ,error_code = 'E677'
         ,error_text  = igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E677', 8405)
    WHERE interface_run_id = p_interface_run_id
     AND status = '2'
      AND update_adm_appl_number IS NOT NULL
      AND ( EXISTS (SELECT 1  FROM igs_ad_apphist_int WHERE  person_id = api.person_id
                                                                                  AND admission_appl_number = api.update_adm_appl_number )
               OR  EXISTS (SELECT 1  FROM igs_ad_insthist_int WHERE person_id = api.person_id
                                                                                 AND admission_appl_number = api.update_adm_appl_number )
              );
  END IF;
  COMMIT;

    UPDATE igs_ad_apl_int api
    SET
         status     = '3'
         ,error_code = 'E176'
         ,error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E176', 8405)
    WHERE interface_run_id = p_interface_run_id
     AND status = '2'
     AND NOT EXISTS( SELECT '1'
                                FROM   igs_ad_ss_appl_typ
                                WHERE admission_application_type =  api.admission_application_type);

      COMMIT;

/**********************************************************************************
Create / Update the OSS record after validating successfully the interface record
Create
    If RULE I (match indicator will be 15 or NULL by now no need to check) and matching system record not found OR
    RULE = R and MATCH IND = 16, 25
Update
    If RULE = I (match indicator will be 15 or NULL by now no need to check) OR
    RULE = R and MATCH IND = 21

Selecting together the interface records for INSERT / UPDATE with DMLMODE identifying the DML operation.
This is done to have one code section for record validation, exception handling and interface table update.
This avoids call to separate PLSQL blocks, tuning performance on stack maintenance during the process.

**********************************************************************************/
FOR appl_rec IN appl_cur
LOOP
    IF l_admission_application_type IS NULL
          OR appl_rec.admission_application_type <> l_admission_application_type THEN
        populate_apc_columns(appl_rec.admission_application_type);
    END IF;
    IF appl_rec.dmlmode =  cst_insert  THEN
        SAVEPOINT before_create_application;
           create_application_details(appl_rec, l_admission_appl_number, l_status_application);
           IF l_status_application =  'S' THEN
              create_application_instance(appl_rec.interface_appl_id, appl_rec.person_id,
                                       l_admission_appl_number, appl_rec, l_Status_instance);
              IF l_Status_instance = 'E'  THEN
                 ROLLBACK to before_create_application;
                 UPDATE
       	              igs_ad_apl_int
                 SET
 	             status = '3',
                     error_code = 'E347'
                    ,error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
	         WHERE
                    interface_appl_id = appl_rec.interface_appl_id;
              ELSIF  l_Status_instance = 'W' THEN
                 UPDATE
       	              igs_ad_apl_int
                 SET
 	             status = '4',
                     error_code = 'E347'
                    ,error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
	         WHERE
                    interface_appl_id = appl_rec.interface_appl_id;
              ELSE
                UPDATE
       	              igs_ad_apl_int
                 SET
 	             status = cst_s_val_1,
                     admission_Appl_number = l_admission_appl_number
	         WHERE
                    interface_appl_id = appl_rec.interface_appl_id;
              END IF;
           END IF;


    ELSIF  appl_rec.dmlmode = cst_update THEN
        OPEN c_dup_cur(appl_rec);
        FETCH c_dup_cur INTO dup_cur_rec;
        CLOSE c_dup_cur;
        update_application_details(appl_rec, dup_cur_rec);
    END IF;
      l_processed_records := l_processed_records + 1;
       IF l_processed_records = 50 THEN
          COMMIT;
          l_processed_records := 0;
       END IF;

 END LOOP;
       IF l_processed_records < 100 AND l_processed_records > 0  THEN
         COMMIT;
       END IF;
 /*Set STATUS to 1 and MATCH IND to 23 for interface records with RULE = R matching OSS record(s) in
   ALL updateable column values, if column nullification is not allowed then the 2 DECODE should be replaced by a single NVL*/
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_apl_int  api
       SET
         status = '1'
         , match_ind = '23'
         , admission_appl_number = api.update_adm_appl_number
       WHERE interface_run_id = p_interface_run_id
       AND status = '2'
       AND NVL (match_ind, '15') = '15'
       AND EXISTS ( SELECT 1 FROM IGS_AD_APPL  appl_oss
                            WHERE person_id = api.person_id
                      AND admission_appl_number = api.update_adm_appl_number
                      AND TRUNC(appl_dt) = TRUNC(api.appl_dt)
                      AND tac_appl_ind = api.tac_appl_ind
                      AND  NVL(spcl_grp_1, -1)  = NVL( NVL(api.spcl_grp_1, appl_oss.spcl_grp_1), -1)
                      AND  NVL(spcl_grp_2,-1)  = NVL( NVL(api.spcl_grp_2, appl_oss.spcl_grp_2), -1)
                      AND  NVL(common_app, '*') = NVL( NVL(api.common_app,appl_oss.common_app),'*')
                      AND  NVL(choice_number, -1) = NVL( NVL(api.choice_number, appl_oss.choice_number), -1)
                      AND  NVL(routeb_pref , '*') = NVL( NVL(api.routeb_pref,appl_oss.routeb_pref), '*')
                      AND  NVL(alt_appl_id , '*') = NVL( NVL(api.alt_appl_id, appl_oss.alt_appl_id) , '*')
                      AND  NVL(adm_cal_type,'*') =  NVL(NVL(api.adm_cal_type, appl_oss.adm_cal_type),'*')
                      AND  NVL(acad_cal_type, '*') =  NVL(NVL(api.acad_cal_type, appl_oss.acad_cal_type),'*')
                      AND  NVL(api.acad_ci_sequence_number,-99) = NVL(NVL(api.acad_ci_sequence_number, appl_oss.acad_ci_sequence_number),-99)
                      AND  NVL(api.adm_ci_sequence_number,-99) =  NVL(NVL(api.adm_ci_sequence_number, appl_oss.adm_ci_sequence_number), -99)
                          );
     END IF;
     COMMIT;

      UPDATE igs_ad_ps_appl_inst_int a
      SET    (person_id, admission_appl_number,interface_run_id ) =
                 ( SELECT person_id,  admission_appl_number ,interface_run_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_appl_id = a.interface_appl_id
                                   AND    status IN ('1','4') )
      WHERE  status =  '2'
      AND    interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND update_adm_appl_number IS NOT NULL
                                   AND    status IN ('1','4'));

       COMMIT;
            -- All the application creations and updations are completed.
            -- Only the updated applications' isntances needs to be processed.
           Process_application_instance(p_interface_run_id);
 --Set STATUS to 3 and MATCH IND = 20 for interface records with RULE = R and
 --MATCH IND <> 21, 25, ones failed above discrepancy check
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_apl_int  api
        SET
        status = '3'
        , match_ind = '20'
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND update_adm_appl_number IS NOT NULL;

     END IF;
     COMMIT;


  --Set STATUS to 3 for interface records with RULE = R and invalid MATCH IND
     IF p_rule = 'R'  THEN
       UPDATE igs_ad_apl_int  api
        SET
        status = '3'
        , error_code = 'E700'
        WHERE interface_run_id = p_interface_run_id
        AND status = '2'
        AND match_ind IS NOT NULL;
     END IF;
     COMMIT;

END  prc_appcln;

END igs_ad_imp_004;

/
