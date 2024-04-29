--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_OFF_RESP_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_OFF_RESP_DATA" AS
/* $Header: IGSADC2B.pls 120.5 2006/01/16 20:24:33 rghosh ship $ */
---------------------------------------------------------------------------------------------------------------------------------------
--  Created By : rboddu
--  Date Created On : 17-SEP-2002
--  Purpose : Bug: 2395510. This package is used to import the Offer Response data from interface tables to the Admission System tables,
--  by performing All the validations that are currently done in Offer Response form (IGSAD093). Bulk Collect is implemented to import
--  the interface records. Currently this is job is called from UCAS process. This job can also be invoked from SRS.
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
--  rghosh         02-Jan-03       removed the planned status as per bug#2722785
--  rbezawad       1-Nov-04        Modified imp_off_resp procedure to display the security error message in the log file w.r.t. Bug 3919112.
---------------------------------------------------------------------------------------------------------------------------------------

  -- Cursor to get the Application Instance record from OSS System table, corresponding to given Interface Offer Response record
  -- Cursor is put at the package level as it's being accessed by different procedures of this package.
  CURSOR  cur_ad_ps_appl_inst (  cp_person_id              igs_ad_ps_appl_inst_all.person_id%TYPE ,
                               cp_admission_appl_number  igs_ad_ps_appl_inst_all.admission_appl_number%TYPE ,
                               cp_nominated_course_cd    igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE ,
                               cp_sequence_number        igs_ad_ps_appl_inst_all.sequence_number%TYPE
                                ) IS
  SELECT aplinst.rowid, aplinst.*
  FROM  igs_ad_ps_appl_inst_all aplinst
  WHERE  person_id = cp_person_id   AND
         admission_appl_number = cp_admission_appl_number AND
         nominated_course_cd = cp_nominated_course_cd AND
         sequence_number = cp_sequence_number;

  PROCEDURE logdetail(l_id IN igs_ad_offresp_int.offresp_int_id%TYPE,
                    l_err_code IN igs_ad_offresp_err.error_code%TYPE,
                    l_err_msg  IN igs_ad_offresp_err.error_text%TYPE,
                    l_debug_msg IN VARCHAR2,
                    l_first_flag IN VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------------------------------
  --  Created By : rboddu
  --  Date Created On : 09-SEP-2002
  --  Purpose : Bug 2395510. Procedure to display the LOG data in required format.
  --  Know limitations, enhancements or remarks
  --  Change History
  --  Who             When            What
  ---------------------------------------------------------------------------------------------------------------------------------------

    l_full_string VARCHAR2(400);
    l_meaning VARCHAR2(400);
    l_bat_string VARCHAR2(100);
    l_text  VARCHAR2(400);
    CURSOR c_lkup_meaning(l_code igs_ad_offresp_err.error_code%TYPE) IS
    SELECT meaning
    FROM igs_lookups_view
    WHERE lookup_type = 'IMPORT_ERROR_CODE' AND
          lookup_code = l_code;

    CURSOR batch_details(l_batch_id igs_ad_offresp_batch.batch_id%TYPE) IS
    SELECT batch_id, batch_desc
    FROM igs_ad_offresp_batch
    WHERE batch_id = l_batch_id;
    l_batch_rec batch_details%ROWTYPE;

  BEGIN
    IF l_err_code IS NOT NULL THEN
      OPEN c_lkup_meaning(l_err_code);
      FETCH c_lkup_meaning INTO l_meaning;
      CLOSE c_lkup_meaning;
    ELSE
      l_meaning := FND_MESSAGE.GET_STRING('IGS',l_err_msg);
    END IF;

    IF l_first_flag = 'Y' THEN
      OPEN batch_details(l_id);
      FETCH batch_details INTO l_batch_rec;
      CLOSE batch_Details;

      l_full_string :='                                                                                                                                  ';
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string);

      FND_MESSAGE.SET_NAME('IGS','IGS_AD_BATCH_ID');
      l_full_string := RPAD(FND_MESSAGE.GET,10,' ')||RPAD(IGS_GE_NUMBER.TO_CANN(l_batch_rec.batch_id),15,' ')||l_batch_rec.batch_desc;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string);

      l_full_string :='----------------------------------------------------------------------------------------------------------------------------------';
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string);

      FND_MESSAGE.SET_NAME('IGS','IGS_AD_IMP_OFR_LOG_HDR');
      l_full_string := FND_MESSAGE.GET;

      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string);

      l_full_string :='----------------------------------------------------------------------------------------------------------------------------------';
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string);

    ELSIF l_err_code IS NOT NULL OR l_err_msg IS NOT NULL THEN
      l_text := RPAD(IGS_GE_NUMBER.TO_CANN(l_id),15,' ')||RPAD(NVL(l_err_code,' '),10,' ')||l_meaning;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_text);

      FND_MESSAGE.SET_NAME('IGS','IGS_AD_DEBUG_INFO');
      l_full_string := FND_MESSAGE.GET;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string||' '||l_debug_msg);
      l_full_string :='                                                                                                                                    ';
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_full_string);

    END IF;

    IF l_id IS NOT NULL AND l_err_code IS NULL AND l_err_msg IS NULL AND l_first_flag IS NULL THEN

      FND_MESSAGE.SET_NAME('IGS','IGS_AD_SUCC_IMP_OFR_RESP_REC');
      l_full_string := FND_MESSAGE.GET;

      FND_FILE.PUT_LINE(FND_FILE.LOG, RPAD(IGS_GE_NUMBER.TO_CANN(l_id),15,' ')||' '||l_full_string);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
    IF c_lkup_meaning%ISOPEN THEN
       CLOSE c_lkup_meaning;
    END IF;
    IF batch_details%ISOPEN THEN
       CLOSE batch_details;
    END IF;
     FND_FILE.PUT_LINE(FND_FILE.LOG,'logdetail: '||FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION')||'  '||SQLERRM);
  END logdetail;

  --Procedure to Update igs_ad_offresp_int with the Error status and insert the corresponding Error record into igs_ad_offresp_err.
  PROCEDURE insert_int_error( p_offresp_int_id IN igs_ad_offresp_int.offresp_int_id%TYPE,
                                 p_error_code IN igs_ad_offresp_err.error_code%TYPE,
                                 p_message_name IN VARCHAR2
                                ) IS
  ---------------------------------------------------------------------------------------------------------------------------------------
  --  Created By : rboddu
  --  Date Created On : 09-SEP-2002
  --  Purpose : Bug 2395510. Procedure to insert Error Code / Error Message text into igs_ad_offresp_err, for the failed validations.
  --  Know limitations, enhancements or remarks
  --  Change History
  --  Who             When            What
  ---------------------------------------------------------------------------------------------------------------------------------------

  l_message_text VARCHAR2(2000);
  BEGIN
    l_message_text := NULL;
    IF p_message_name IS NOT NULL THEN
      IF length(p_message_name) > 30 THEN
        l_message_text := p_message_name;
      ELSE
        FND_MESSAGE.SET_NAME('IGS',p_message_name);
        l_message_text := fnd_message.get();
      END IF;
    END IF;

    INSERT INTO igs_ad_offresp_err(
      offresp_err_id,
      offresp_int_id,
      error_code,
      error_text,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      request_id,
      program_application_id,
      program_update_date,
      program_id)
    VALUES(
      igs_ad_offresp_err_s.nextval,
      p_offresp_int_id,
      p_error_code,
      l_message_text,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      SYSDATE,
      fnd_global.user_id,
      fnd_global.conc_request_id,
      fnd_global.prog_appl_id,
      SYSDATE,
      fnd_global.conc_program_id);
  EXCEPTION
    WHEN OTHERS THEN
     FND_FILE.PUT_LINE(FND_FILE.LOG,'insert_int_error: '||FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION')||'  '||SQLERRM);
  END insert_int_error;


  PROCEDURE validate_off_resp_dtls(
      p_offresp_int_id              IN igs_ad_offresp_int.OFFRESP_INT_ID%TYPE,
      p_batch_id                    IN igs_ad_offresp_int.BATCH_ID%TYPE,
      p_person_id                   IN igs_ad_offresp_int.person_id%TYPE,
      p_admission_appl_number       IN igs_ad_offresp_int.admission_appl_number%TYPE,
      p_nominated_course_cd         IN igs_ad_offresp_int.nominated_course_cd%TYPE ,
      p_sequence_number             IN igs_ad_offresp_int.sequence_number%TYPE,
      p_adm_offer_resp_status       IN igs_ad_offresp_int.adm_offer_resp_status%TYPE ,
      p_decline_ofr_reason	    IN igs_ad_offresp_int.decline_ofr_reason%TYPE,			--arvsrini igsm
      p_actual_offer_response_dt    IN igs_ad_offresp_int.actual_offer_response_dt%TYPE,
      p_attent_other_inst_cd        IN igs_ad_offresp_int.attent_other_inst_cd%TYPE,
      p_applicant_acptnce_cndtn     IN igs_ad_offresp_int.applicant_acptnce_cndtn%TYPE,
      p_def_acad_cal_type           IN igs_ad_offresp_int.def_acad_cal_type%TYPE ,
      p_def_acad_ci_sequence_number IN igs_ad_offresp_int.def_acad_ci_sequence_number%TYPE,
      p_def_adm_cal_type            IN igs_ad_offresp_int.def_adm_cal_type%TYPE ,
      p_def_adm_ci_sequence_number  IN igs_ad_offresp_int.def_adm_ci_sequence_number%TYPE ,
      p_status                      IN igs_ad_offresp_int.status%TYPE ,
      p_prpsd_commencement_date       IN igs_ad_offresp_int.prpsd_commencement_date%TYPE,
      p_adm_offer_defr_status       OUT NOCOPY igs_ad_ps_appl_inst_all.adm_offer_dfrmnt_status%TYPE,
      p_calc_actual_ofr_resp_dt     OUT NOCOPY igs_ad_offresp_int.actual_offer_response_dt%TYPE,
      appl_rec                      IN igs_ad_appl_all%ROWTYPE,
      acaiv_rec                     IN cur_ad_ps_appl_inst%ROWTYPE,
      p_yes_no                      IN VARCHAR2,
      p_validation_success          OUT NOCOPY VARCHAR2) IS
  ---------------------------------------------------------------------------------------------------------------------------------------
  --  Created By : rboddu
  --  Date Created On : 09-SEP-2002
  --  Purpose : Bug 2395510. This procedure performs all the validations that are being done in Offer Response form (IGSAD093). Apart
  --  from these validations some additional validations are performed to check for the validity of different Offer Response details.
  --  Validations are stopped whenever basic validation a fails, like the application is not in Open processing state or Outcome Status
  --  is not valid etc.
  --  Know limitations, enhancements or remarks
  --  Change History
  --  Who             When            What
  --  rboddu          11/17/2003      Added p_prpsd_commencement_date and related validations. Bug:3181590
  ---------------------------------------------------------------------------------------------------------------------------------------

  CURSOR c_apcs (cp_admission_cat  igs_ad_prcs_cat_step.admission_cat%TYPE,
      cp_s_admission_process_type  igs_ad_prcs_cat_step.s_admission_process_type%TYPE) IS
  SELECT  s_admission_step_type,
          step_type_restriction_num
  FROM  igs_ad_prcs_cat_step
  WHERE admission_cat = cp_admission_cat AND
        s_admission_process_type = cp_s_admission_process_type AND
        step_group_type <> 'TRACK' ;

  CURSOR valid_inst_cur(l_cd igs_or_institution.institution_cd%TYPE) IS
  SELECT institution_cd
  FROM   igs_or_institution
  WHERE institution_cd = l_cd;

  CURSOR c_appl_inst_ctxt(
           cp_person_id              igs_ad_ps_appl_inst_all.person_id%TYPE ,
           cp_admission_appl_number  igs_ad_ps_appl_inst_all.admission_appl_number%TYPE ,
           cp_nominated_course_cd    igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE ,
           cp_sequence_number        igs_ad_ps_appl_inst_all.sequence_number%TYPE) IS
  SELECT ci1.start_dt acad_ci_start_dt,
    ci1.end_dt acad_ci_end_dt,
    ci2.start_dt adm_ci_start_dt,
    ci2.end_dt adm_ci_end_dt
  FROM  igs_ad_appl aav,   /* Replaced igs_ad_ps_apl_inst_cntx_v with underlying tables. Bug 3150054 */
    igs_ad_ps_appl_inst acai,
    igs_ca_inst ci1,
    igs_ca_inst ci2
  WHERE acai.person_id = cp_person_id   AND
        acai.admission_appl_number = cp_admission_appl_number AND
        acai.nominated_course_cd = cp_nominated_course_cd AND
        acai.sequence_number = cp_sequence_number AND
        aav.person_id = acai.person_id AND
        aav.admission_appl_number = acai.admission_appl_number AND
        ci1.cal_type = aav.acad_cal_type AND
        ci1.sequence_number = aav.acad_ci_sequence_number AND
        ci2.cal_type = nvl(acai.adm_cal_type,aav.adm_cal_type) AND
        ci2.sequence_number = nvl(acai.adm_ci_sequence_number,aav.adm_ci_sequence_number);


  --Cursor to select the valid Deferred Academic Calendars
  CURSOR c_valid_acad_cals(cp_acad_ci_start_dt IN igs_ca_inst.start_dt%TYPE,
                           cp_acad_ci_end_dt IN igs_ca_inst.end_dt%TYPE ) IS
  SELECT UNIQUE
    acad_ciav.alternate_code  def_acad_alternate_code
   ,acad_ciav.cal_type        def_acad_cal_type
   ,acad_ciav.sequence_number def_acad_ci_seq_number
   ,acad_ciav.start_dt        start_dt
   ,acad_ciav.end_dt          end_dt
   ,acad_ciav.description     abbreviation
   ,acad_ciav.cal_status      cal_status
   ,acad_ciav.s_cal_status    s_cal_status
  FROM
   igs_ca_inst_alt_v acad_ciav,
   igs_ca_inst_alt_v adm_ciav,
   igs_ca_inst_rel cir,
   igs_ad_prd_ad_prc_ca apapc,
   igs_ca_type ct
  WHERE
   (acad_ciav.s_cal_cat = 'ACADEMIC' AND
   acad_ciav.s_cal_status = 'ACTIVE' AND
   adm_ciav.s_cal_cat = 'ADMISSION' AND
   adm_ciav.s_cal_status = 'ACTIVE' AND
   cir.sup_cal_type = acad_ciav.cal_type AND
   cir.sup_ci_sequence_number = acad_ciav.sequence_number AND
   cir.sub_cal_type = adm_ciav.cal_type AND
   cir.sub_ci_sequence_number = adm_ciav.sequence_number AND
   apapc.adm_cal_type = cir.sub_cal_type AND
   apapc.adm_ci_sequence_number = cir.sub_ci_sequence_number AND
   ct.cal_type = acad_ciav.cal_type AND
   acad_ciav.start_dt >= cp_acad_ci_start_dt AND
   acad_ciav.end_dt >= cp_acad_ci_end_dt AND
   apapc.closed_ind = 'N')                                --added the closed indicator for bug# 2380108 (rghosh)
  ORDER BY
   acad_ciav.cal_type asc
   ,acad_ciav.start_dt desc;

  --Cursor to select the valid Deferred Admission Calendars for the given Academic Calendar
  CURSOR c_valid_adm_cals( cp_admission_cat igs_ad_appl_all.admission_cat%TYPE,
            cp_s_adm_process_type igs_ad_appl_all.s_admission_process_type%TYPE,
            cp_def_acad_cal_type igs_ad_ps_appl_inst_all.def_acad_cal_type%TYPE,
            cp_def_acad_ci_seq_num igs_ad_ps_appl_inst_all.def_acad_ci_sequence_num%TYPE,
            cp_adm_ci_end_dt  igs_ca_inst.end_dt%TYPE
            ) IS
  SELECT
  ciav1.alternate_code def_adm_alternate_code,
  ciav1.cal_type def_adm_cal_type ,
  ciav1.sequence_number def_adm_ci_seq_number ,
  ciav1.start_dt start_dt ,
  ciav1.end_dt end_dt ,
  ciav1.description abbreviation ,
  ciav1.cal_status cal_status
  FROM
   igs_ca_inst_alt_v ciav1
  WHERE
   (ciav1.s_cal_cat = 'ADMISSION' AND ciav1.s_cal_status = 'ACTIVE'
   AND ciav1.start_dt > cp_adm_ci_end_dt
   AND (ciav1.cal_type, ciav1.sequence_number) IN
         (SELECT apapc.adm_cal_type,
                 apapc.adm_ci_sequence_number
          FROM   igs_ad_prd_ad_prc_ca apapc,
                 igs_ca_inst_rel cir
          WHERE  apapc.admission_cat = cp_admission_cat AND
                 apapc.s_admission_process_type =cp_s_adm_process_type AND
                 cir.sub_cal_type = apapc.adm_cal_type AND
                 cir.sub_ci_sequence_number = apapc.adm_ci_sequence_number AND
                 cir.sup_cal_type = cp_def_acad_cal_type AND
                 cir.sup_ci_sequence_number = cp_def_acad_ci_seq_num AND
		 apapc.closed_ind= 'N') )    --added the closed indicator for bug# 2380108 (rghosh)
          ORDER BY  ciav1.cal_type ASC ,
                    ciav1.start_dt ASC;

    CURSOR get_aplinst_adm_period IS
    SELECT adm_cal_type,adm_ci_sequence_number
    FROM igs_ad_ps_appl_inst
    WHERE person_id = p_person_id
    AND admission_appl_number = p_admission_appl_number
    AND nominated_course_cd = p_nominated_course_cd
    AND sequence_number = p_sequence_number;

       -- Following cursors added as part of Single Response build Bug:3132406
       CURSOR get_single_response (p_admission_cat igs_ad_appl_all.admission_cat%TYPE,
                                   p_s_admission_process_type igs_ad_appl_all.s_admission_process_type%TYPE) IS
       SELECT admprd.single_response_flag
       FROM igs_ad_prd_ad_prc_ca admprd,
              igs_ad_appl_all appl,
              igs_ad_ps_appl_inst_all aplinst
       WHERE appl.person_id = p_person_id
              AND appl.admission_appl_number = p_admission_appl_number
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
        AND appl.person_id = p_person_id
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

    c_appl_inst_ctxt_rec c_appl_inst_ctxt%ROWTYPE;
    v_step_type          VARCHAR2(100);
    l_deferral_allowed   VARCHAR2(1);
    l_pre_enrol          VARCHAR2(1);
    l_multi_offer_allowed VARCHAR2(1);
    l_multi_offer_limit  NUMBER(10);
    v_message_name       VARCHAR2(100);
    l_valid_def_adm_cal  VARCHAR2(1);
    l_valid_def_acad_cal VARCHAR2(1);
    cst_completed        CONSTANT VARCHAR2(10) := 'COMPLETED';
    cst_withdrawn        CONSTANT VARCHAR2(10) := 'WITHDRAWN';
    cst_offer            CONSTANT VARCHAR2(10) := 'OFFER';
    cst_cond_offer       CONSTANT VARCHAR2(10) := 'COND-OFFER';
    cst_pending          CONSTANT VARCHAR2(10) := 'PENDING';
    cst_accepted         CONSTANT VARCHAR2(10) := 'ACCEPTED';
    cst_rejected         CONSTANT VARCHAR2(10) := 'REJECTED';
    cst_deferral         CONSTANT VARCHAR2(10) := 'DEFERRAL';
    cst_lapsed           CONSTANT VARCHAR2(10) := 'LAPSED';
    cst_not_applic       CONSTANT VARCHAR2(10) := 'NOT-APPLIC';

    l_applicant_acptnce_cndtn igs_ad_ps_appl_inst_all.applicant_acptnce_cndtn%TYPE;
    l_inst_cd  igs_or_institution.institution_cd%TYPE;

    v_admission_cat                 igs_ad_appl.admission_cat%TYPE;
    v_s_admission_process_type      igs_ad_appl.s_admission_process_type%TYPE;
    v_acad_cal_type                 igs_ad_appl.acad_cal_type%TYPE;
    v_acad_ci_sequence_number       igs_ad_appl.acad_ci_sequence_number%TYPE;
    v_aa_adm_cal_type               igs_ad_appl.adm_cal_type%TYPE;
    v_aa_adm_ci_sequence_number     igs_ad_appl.adm_ci_sequence_number%TYPE;
    v_acaiv_adm_cal_type            igs_ad_ps_appl_inst_all.adm_cal_type%TYPE;
    v_acaiv_adm_ci_sequence_number  igs_ad_ps_appl_inst_all.adm_ci_sequence_number%TYPE;
    v_adm_cal_type                  igs_ad_appl.adm_cal_type%TYPE;
    v_adm_ci_sequence_number        igs_ad_appl.adm_ci_sequence_number%TYPE;
    v_appl_dt                       igs_ad_appl.appl_dt%TYPE;
    v_adm_appl_status               igs_ad_appl.adm_appl_status%TYPE;
    v_adm_fee_status                igs_ad_appl.adm_fee_status%TYPE;
    l_single_response_flag          igs_ad_prd_ad_prc_ca.single_response_flag%TYPE;
    l_application_id                igs_ad_appl_all.application_id%TYPE;
    l_nominated_course_cd           igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE;
    l_acad_alt_code                 igs_ca_inst.alternate_code%TYPE;
    l_adm_alt_code                  igs_ca_inst.alternate_code%TYPE;

  BEGIN

     --Initialize the flag indicating the SUCCESS ('Y'). Gets updated to 'N' even if one validation fails
    p_validation_success := 'Y';

   --Validations on the Application Instance Outcome Status. Check if the Applicant's Outcome Status is mapped to one of the System Outcome Status of
   --'Make Offer of Admission' (OFFER) or 'Make Offer of Admission Subject to Condition' (COND-OFFER).
   IF NVL(igs_ad_gen_008.admp_get_saos(acaiv_rec.adm_outcome_status), 'NULL') NOT IN (cst_offer, cst_cond_offer) THEN
     insert_int_error(p_offresp_int_id, 'E618',NULL);
     p_validation_success := 'N';
     logdetail(p_offresp_int_id, 'E618', NULL, 'validate_off_resp_dtls: IF NVL(igs_ad_gen_008.admp_get_saos(acaiv_rec.adm_outcome_status)' ,NULL);
     RETURN;
   END IF;

   --Check if the Interface Offer Response Status is a valid Offer Response Status mapped to one of the System Offer Response Statuses.
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) IS NULL THEN
     insert_int_error(p_offresp_int_id, 'E600',NULL);
     p_validation_success := 'N';
     logdetail(p_offresp_int_id, 'E600', NULL, 'validate_off_resp_dtls: IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status)' ,NULL);
     RETURN;
   END IF;


  /********** VALIDATIONS WHICH CHECK FOR THE PROPER COMBINATION OF INTERFACE Vs SYSTEM TABLE Offer Response Status. Stop processing in case of failure *******/

   -- Check if Interface Offer Response status = Production table (IGS_AD_PS_APPL_INST_ALL) Offer Response Status.
/* Hashed this code as part of bug fix for 2631947. The corresponding MNT fix is through 2624637 */
   /*IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = igs_ad_gen_008.admp_get_saors(acaiv_rec.adm_offer_resp_status) THEN */

   IF p_adm_offer_resp_status = acaiv_rec.adm_offer_resp_status THEN
     insert_int_error(p_offresp_int_id, 'E601',NULL);
     p_validation_success := 'N';
     logdetail(p_offresp_int_id, 'E601', NULL, 'validate_off_resp_dtls: IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status)' ,NULL);
     RETURN;
   END IF;
   -- Check if the Interface Offer Response Status is allowed to update the existing offer response in production table.

   -- If Offer Response is changed to PENDING from DEFERRAL, then the Deffered Calendars should be NULL otherswise insert error record into corresponding table
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) <> cst_pending AND igs_ad_gen_008.admp_get_saors(acaiv_rec.adm_offer_resp_status) = cst_deferral THEN
     IF p_def_acad_cal_type IS NOT NULL OR p_def_acad_ci_sequence_number IS NOT NULL THEN
        insert_int_error(p_offresp_int_id, 'E612',NULL);
        p_validation_success := 'N';
        logdetail(p_offresp_int_id, 'E612', NULL, 'validate_off_resp_dtls: Check if the Interface Offer Response Status is allowed to update' ,NULL);
     RETURN;
     END IF;
     IF p_def_adm_cal_type IS NOT NULL OR p_def_adm_ci_sequence_number IS NOT NULL THEN
        insert_int_error(p_offresp_int_id, 'E611',NULL);
        p_validation_success := 'N';
        logdetail(p_offresp_int_id, 'E611', NULL, 'validate_off_resp_dtls: Check if the Interface Offer Response Status is allowed to update' ,NULL);
     RETURN;
     END IF;
     IF p_validation_success = 'N' THEN
       RETURN;
     END IF;
   END IF;

/*****   END OF VALIDATIONS CHECKING FOR THE PROPER COMBINATION OF OFFER RESPONSE STATUS (Interface Table Vs System Table)   ************/

    --Copy the interface Actual Response Date to the OUT NOCOPY Variable p_calc_actual_ofr_resp_dt and populate this variable accordingly after necessary validations
    p_calc_actual_ofr_resp_dt := p_actual_offer_response_dt;

    -- Check if Interface Offer Response Status is Other than 'PENDING', 'LAPSED', 'NOT-APPLIC'.
    IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) NOT IN (cst_pending, cst_lapsed, cst_not_applic) THEN
      IF p_calc_actual_ofr_resp_dt IS NULL THEN
         p_calc_actual_ofr_resp_dt := SYSDATE;
      ELSE
        IF TRUNC(p_calc_actual_ofr_resp_dt) > TRUNC(SYSDATE) THEN
           insert_int_error(p_offresp_int_id, 'E607',NULL);
           p_validation_success := 'N';
           logdetail(p_offresp_int_id, 'E607', NULL, 'validate_off_resp_dtls: IF TRUNC(p_calc_actual_ofr_resp_dt) > TRUNC(SYSDATE) THEN' ,NULL);
           RETURN;
        END IF;
      END IF;
    END IF;

	--arvsrini igsm
   IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) IN ('REJECTED','NOT-COMING') AND p_decline_ofr_reason IS NULL THEN
	insert_int_error(p_offresp_int_id, 'E592',NULL);
	p_validation_success := 'N';
	logdetail(p_offresp_int_id, 'E592', NULL, 'validate_off_resp_dtls: Check if the Interface Offer Response Status is allowed to update' ,NULL);

	RETURN;
   END IF;

	--arvsrini igsm
   IF p_decline_ofr_reason = 'OTHER-INST' AND p_attent_other_inst_cd IS NULL THEN
	insert_int_error(p_offresp_int_id, 'E593',NULL);
	p_validation_success := 'N';
	logdetail(p_offresp_int_id, 'E593', NULL, 'validate_off_resp_dtls: Check if the Interface Offer Response Status is allowed to update' ,NULL);
	RETURN;
   END IF;




    -- Validate admission offer response status
    FOR c_apcs_rec IN c_apcs(appl_rec.admission_cat,appl_rec.s_admission_process_type) LOOP
      IF c_apcs_rec.s_admission_step_type = 'DEFER' THEN
        l_deferral_allowed := 'Y';
      END IF;
      IF c_apcs_rec.s_admission_step_type = 'PRE-ENROL' THEN
        v_step_type := 'IGSAD' || SUBSTR (ltrim(rtrim(c_apcs_rec.s_admission_step_type)),1,3);
        IF fnd_function.test(v_step_type) THEN
          l_pre_enrol := 'Y';
        END IF;
      END IF;
      IF c_apcs_rec.s_admission_step_type = 'MULTI-OFF' THEN
        l_multi_offer_allowed := 'Y';
        l_multi_offer_limit := c_apcs_rec.step_type_restriction_num;
      END IF;

    END LOOP;
    IF igs_ad_val_acai_status.admp_val_aors_item(
              p_person_id,
              p_admission_appl_number,
              p_nominated_course_cd,
              p_sequence_number,
              acaiv_rec.course_cd,
              p_adm_offer_resp_status,
              p_calc_actual_ofr_resp_dt,
              appl_rec.s_admission_process_type,
              NVL(l_deferral_allowed,'N'),
              NVL(l_pre_enrol, 'N'),
              v_message_name,
	      p_decline_ofr_reason,		--arvsrini igsm
	      p_attent_other_inst_cd
	) = FALSE THEN
      insert_int_error(p_offresp_int_id, NULL,v_message_name);
      p_validation_success := 'N';
      logdetail(p_offresp_int_id, NULL, v_message_name, 'validate_off_resp_dtls: IF igs_ad_val_acai_status.admp_val_aors_item' ,NULL);
      RETURN;
    END IF;


     -- Validations on the Offer Deferment Status
     -- Though Offer Deferment Status is not directly imported from Offer Response Interface table, it should be populated
     -- with either of the values 'PENDING' or 'NOT-APPLIC' depending on the value of Offer Response Status.
     -- Default the Offer Deferment Status, depending on the value of Offer Response Status, and validate the same.
     -- IF Offer Response Status is 'DEFERRAL', then default the Offer Deferment Status to 'PENDING'.
     -- ELSE Offer Response Status is not equal to 'DEFERRAL', then Default the Offer Deferment Status to 'NOT-APPLIC'.

     IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_deferral AND
       NVL(igs_ad_gen_008.admp_get_saods(acaiv_rec.adm_offer_dfrmnt_status), cst_not_applic) = cst_not_applic THEN
       IF igs_ad_gen_009.admp_get_sys_aods(cst_pending) IS NULL THEN
         insert_int_error(p_offresp_int_id, 'E625',NULL);
         p_validation_success := 'N';
         logdetail(p_offresp_int_id, 'E625', NULL, 'IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status)' ,NULL);
         RETURN;
       ELSE
          p_adm_offer_defr_status := igs_ad_gen_009.admp_get_sys_aods(cst_pending);
          -- ADMISSION COURSE APPLICATION INSTANCE: Admission Offer Deferment Status.
          IF  p_adm_offer_defr_status <> acaiv_rec.adm_offer_dfrmnt_status THEN
            -- Validate.
            IF igs_ad_val_acai_status.admp_val_acai_aods (
                  p_person_id,
                  p_admission_appl_number,
                  p_nominated_course_cd,
                  p_sequence_number,
                  acaiv_rec.course_cd,
                  p_adm_offer_defr_status,
                  acaiv_rec.adm_offer_dfrmnt_status,
                  p_adm_offer_resp_status,
                  NVL(l_deferral_allowed,'N'),
                  appl_rec.s_admission_process_type,
                  v_message_name) = FALSE THEN
                insert_int_error(p_offresp_int_id, NULL,v_message_name);
                p_validation_success := 'N';
                logdetail(p_offresp_int_id, NULL, v_message_name, 'validate_off_resp_dtls: IF igs_ad_val_acai_status.admp_val_acai_aods' ,NULL);
                RETURN;
            ELSE
               --Beginning of the deferred calendar validations here
               OPEN c_appl_inst_ctxt(
                    p_person_id ,
                    p_admission_appl_number,
                    p_nominated_course_cd,
                    p_sequence_number
                    );
               FETCH c_appl_inst_ctxt INTO c_appl_inst_ctxt_rec;
               CLOSE c_appl_inst_ctxt;

              --Begin of checking the Def Acad cals for NULL values
              IF p_def_acad_cal_type IS NULL OR p_def_acad_ci_sequence_number IS NULL THEN
                 insert_int_error(p_offresp_int_id,'E614', NULL);
                 p_validation_success := 'N';
                 logdetail(p_offresp_int_id,'E614', NULL, 'validate_off_resp_dtls: IF p_def_acad_cal_type IS NULL OR p_def_acad_ci_sequence_number' ,NULL);
                 RETURN;
              ELSE
                 l_valid_def_acad_cal := 'N';
                 FOR valid_acad_cal_rec IN c_valid_acad_cals(c_appl_inst_ctxt_rec.acad_ci_start_dt,
                                        c_appl_inst_ctxt_rec.acad_ci_end_dt) LOOP
                    IF p_def_acad_cal_type = valid_acad_cal_rec.def_acad_cal_type AND
                       p_def_acad_ci_sequence_number = valid_acad_cal_rec.def_acad_ci_seq_number THEN

                      l_valid_def_acad_cal := 'Y';
                      EXIT;
                    END IF;
                 END LOOP;

                 IF l_valid_def_acad_cal = 'N' THEN
                   insert_int_error(p_offresp_int_id, 'E612', NULL);
                   p_validation_success := 'N';
                   logdetail(p_offresp_int_id,'E612', NULL, 'validate_off_resp_dtls: IF l_valid_def_acad_cal = ' ,NULL);
                   RETURN;
                 --validate the Deferred Academic Calendar.
                 ELSE
                   --Beginning of IF for adm cals
                   IF p_def_adm_cal_type IS NULL OR p_def_adm_ci_sequence_number IS NULL THEN
                     insert_int_error(p_offresp_int_id,'E615', NULL);
                     logdetail(p_offresp_int_id,'E615', NULL, 'IF p_def_adm_cal_type IS NULL OR' ,NULL);
                     p_validation_success := 'N';
                     RETURN;
                   ELSE
                     --validate the Deferred Admission Calendar.
                     l_valid_def_adm_cal := 'N';
                     FOR valid_adm_cal_rec IN c_valid_adm_cals(
                                            appl_rec.admission_cat,
                                            appl_rec.s_admission_process_type,
                                            p_def_acad_cal_type,
                                            p_def_acad_ci_sequence_number,
                                            c_appl_inst_ctxt_rec.adm_ci_end_dt) LOOP
                       IF  p_def_adm_cal_type = valid_adm_cal_rec.def_adm_cal_type AND
                           p_def_adm_ci_sequence_number = valid_adm_cal_rec.def_adm_ci_seq_number THEN
                         l_valid_def_adm_cal := 'Y';
                         EXIT;
                       END IF;
                     END LOOP;

                     IF l_valid_def_adm_cal = 'N' THEN
                        insert_int_error(p_offresp_int_id, 'E611', NULL);
                        p_validation_success := 'N';
                        RETURN;
                     END IF;

                   END IF; --End of IF for adm cals
                 END IF; --l_valid_def_acad_cal <> 'N'
              END IF; --END of checking the Def Acad cals for NULL values
            END IF; --End of igs_ad_val_acai_status.admp_val_acai_aods
          END IF; ---End of the deferred calendar validations here
       END IF;
     ELSE -- Of DEFERRAL check
       IF igs_ad_gen_009.admp_get_sys_aods(cst_not_applic) IS NULL THEN
         insert_int_error(p_offresp_int_id, 'E602',NULL);
         p_validation_success := 'N';
         logdetail(p_offresp_int_id,'E602', NULL, 'validate_off_resp_dtls: IF igs_ad_gen_009.admp_get_sys_aods' ,NULL);
         RETURN;
       ELSE
         p_adm_offer_defr_status := igs_ad_gen_009.admp_get_sys_aods(cst_not_applic);
       END IF;
     END IF; -- Of DEFERRAL check

     -- Validate all the Offer Response details here
     IF igs_ad_val_acai_status.admp_val_acai_aors(
           p_person_id,
           p_admission_appl_number,
           p_nominated_course_cd,
           p_sequence_number,
           acaiv_rec.course_cd,
           p_adm_offer_resp_status,
           acaiv_rec.adm_offer_resp_status,
           acaiv_rec.adm_outcome_status,
           p_adm_offer_defr_status,
           acaiv_rec.adm_offer_dfrmnt_status,
           acaiv_rec.adm_outcome_status_auth_dt,
           p_calc_actual_ofr_resp_dt,
           appl_rec.adm_cal_type,
           appl_rec.adm_ci_sequence_number,
           appl_rec.admission_cat,
           appl_rec.s_admission_process_type,
           NVL(l_deferral_allowed,'N'),
           NVL(l_multi_offer_allowed,'N'),
           l_multi_offer_limit,
           NVL(l_pre_enrol, 'N'),
           acaiv_rec.cndtnl_offer_must_be_stsfd_ind,
           acaiv_rec.cndtnl_offer_satisfied_dt,
           'FORM',
           v_message_name,
	   p_decline_ofr_reason,			--arvsrini igsm
	   p_attent_other_inst_cd
	  ) = FALSE THEN
           insert_int_error(p_offresp_int_id, NULL,v_message_name);
           p_validation_success := 'N';
           logdetail(p_offresp_int_id, NULL, v_message_name, 'validate_off_resp_dtls: IGS_AD_VAL_ACAI_STATUS.admp_val_acai_aors' ,NULL);
           RETURN;
     END IF;


    --Validations on the Actual Response Date
    IF p_calc_actual_ofr_resp_dt IS NULL and acaiv_rec.actual_response_dt IS NOT NULL OR
       p_calc_actual_ofr_resp_dt IS NOT NULL AND acaiv_rec.actual_response_dt IS NULL OR
       (TRUNC(p_calc_actual_ofr_resp_dt) IS NOT NULL AND TRUNC(acaiv_rec.actual_response_dt) IS NOT NULL
           AND  TRUNC(p_calc_actual_ofr_resp_dt) <> TRUNC(acaiv_rec.actual_response_dt)
       ) OR
       p_adm_offer_resp_status <> acaiv_rec.adm_offer_resp_status THEN
       -- Validate.
      IF igs_ad_val_acai.admp_val_act_resp_dt (
         p_calc_actual_ofr_resp_dt,
         p_adm_offer_resp_status,
         acaiv_rec.offer_dt,
         v_message_name) = FALSE THEN
         insert_int_error(p_offresp_int_id, NULL,v_message_name);
         p_validation_success := 'N';
         logdetail(p_offresp_int_id, NULL, v_message_name, 'validate_off_resp_dtls: IF IGS_AD_VAL_ACAI.admp_val_act_resp_dt' ,NULL);
         RETURN;
      END IF;
    END IF;


    -- if the offer response date is elapsed then continue with other validations if p_yes_no is 'Y'. Otherwise insert error record into Interface tables.
    IF p_calc_actual_ofr_resp_dt > acaiv_rec.offer_response_dt AND TRUNC(acaiv_rec.offer_response_dt) < TRUNC(SYSDATE) AND
      igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_accepted THEN
      IF p_yes_no = '2' THEN
        insert_int_error(p_offresp_int_id, NULL,'IGS_AD_RESP_DT_PASSED');
        p_validation_success := 'N';
        logdetail(p_offresp_int_id, NULL, 'IGS_AD_RESP_DT_PASSED', 'validate_off_resp_dtls: IF p_calc_actual_ofr_resp_dt > acaiv_rec.offer_response_dt' ,NULL);
        RETURN;
      END IF;
    END IF;


    --Single Response build Bug:3132406
    IF igs_ad_gen_008.admp_get_saors(p_adm_offer_resp_status) = cst_accepted THEN

      -- Get the Application level details which are required for Single Response validation. Bug:3132406
      igs_ad_gen_002.admp_get_aa_dtl(
         p_person_id,
         p_admission_appl_number,
         v_admission_cat,
         v_s_admission_process_type,
         v_acad_cal_type,
         v_acad_ci_sequence_number,
         v_aa_adm_cal_type,
         v_aa_adm_ci_sequence_number,
         v_appl_dt,
         v_adm_appl_status,
         v_adm_fee_status);

      OPEN get_single_response (v_admission_cat,v_s_admission_process_type);
      FETCH get_single_response INTO l_single_response_flag;
      CLOSE get_single_response;

      OPEN get_aplinst_adm_period;
      FETCH get_aplinst_adm_period
      INTO v_acaiv_adm_cal_type,v_acaiv_adm_ci_sequence_number;
      CLOSE get_aplinst_adm_period;

      IF l_single_response_flag = 'Y' THEN
         OPEN get_aplinst_response_accepted;
         FETCH get_aplinst_response_accepted INTO l_application_id,l_nominated_course_cd;
         IF get_aplinst_response_accepted%FOUND THEN
           CLOSE get_aplinst_response_accepted;

	   OPEN get_alternate_code(v_acad_cal_type,v_acad_ci_sequence_number);
           FETCH get_alternate_code INTO l_acad_alt_code;
	   CLOSE get_alternate_code;

	   OPEN get_alternate_code(NVL(v_acaiv_adm_cal_type,v_aa_adm_cal_type),
	        NVL(v_acaiv_adm_ci_sequence_number,v_aa_adm_ci_sequence_number));
           FETCH get_alternate_code INTO l_adm_alt_code;
	   CLOSE get_alternate_code;

           FND_MESSAGE.SET_NAME('IGS','IGS_AD_SINGLE_OFFRESP_EXISTS');
           FND_MESSAGE.SET_TOKEN ('PROG_CODE',l_nominated_course_cd);
           FND_MESSAGE.SET_TOKEN ('APPL_ID', TO_CHAR(l_application_id));
           FND_MESSAGE.SET_TOKEN ('ACAD_ADM_PRD', l_acad_alt_code||'/'||l_adm_alt_code);

           insert_int_error(p_offresp_int_id, 'E693',fnd_message.get());
           p_validation_success := 'N';
           logdetail(p_offresp_int_id, 'E693',NULL, 'validate Single Response' ,NULL);
           RETURN;
         ELSE
           CLOSE get_aplinst_response_accepted;
         END IF;
      END IF;
    END IF;

    --Bug 3181590
    IF TRUNC(p_prpsd_commencement_date) > TRUNC(SYSDATE) OR TRUNC(p_prpsd_commencement_date) < TRUNC(v_appl_dt)
      OR TRUNC(p_prpsd_commencement_date) < TRUNC(acaiv_rec.offer_dt) THEN
        insert_int_error(p_offresp_int_id, NULL,'IGS_AD_PRPSD_CMCMNT_DT_INVALID');
        p_validation_success := 'N';
        logdetail(p_offresp_int_id, NULL, 'IGS_AD_PRPSD_CMCMNT_DT_INVALID', 'validate_off_resp_dtls: IF TRUNC(p_prpsd_commencement_date) > TRUNC(SYSDATE) ' ,NULL);
        RETURN;
    END IF;

    -- Validations on the Application Acceptance Condition
    IF p_applicant_acptnce_cndtn IS NOT NULL THEN
      IF  p_applicant_acptnce_cndtn <> acaiv_rec.applicant_acptnce_cndtn OR
          p_adm_offer_resp_status <> acaiv_rec.adm_offer_resp_status THEN
          -- Validate the acceptance condition
        IF igs_ad_val_acai.admp_val_acpt_cndtn (
                                p_applicant_acptnce_cndtn,
                                p_adm_offer_resp_status,
                                v_message_name) = FALSE THEN
          insert_int_error(p_offresp_int_id, NULL,v_message_name);
          p_validation_success := 'N';
          logdetail(p_offresp_int_id, NULL, v_message_name, 'validate_off_resp_dtls: IF IGS_AD_VAL_ACAI.admp_val_acpt_cndtn' ,NULL);
          RETURN;
        END IF; -- End of igs_ad_val_acai.admp_val_acpt_cndtn
      END IF;
    END IF;


-- Validations on Other Institution Code. It should be a valid institution_cd From IGS_OR_INSTITUTION table.

    IF p_attent_other_inst_cd IS NOT NULL THEN
      OPEN valid_inst_cur(p_attent_other_inst_cd);
      FETCH valid_inst_cur INTO l_inst_cd;
      IF valid_inst_cur%NOTFOUND THEN
        insert_int_error(p_offresp_int_id,'E608',NULL);
        p_validation_success := 'N';
        logdetail(p_offresp_int_id,'E608', NULL, 'validate_off_resp_dtls: IF valid_inst_cur%NOTFOUND THEN ' ,NULL);
        RETURN;
      END IF;
      CLOSE valid_inst_cur;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF c_apcs%ISOPEN THEN
        CLOSE c_apcs;
      END IF;
      IF valid_inst_cur%ISOPEN THEN
        CLOSE valid_inst_cur;
      END IF;
      IF c_appl_inst_ctxt%ISOPEN THEN
        CLOSE c_appl_inst_ctxt;
      END IF;
      IF c_valid_acad_cals%ISOPEN THEN
        CLOSE c_valid_acad_cals;
      END IF;
      IF c_valid_adm_cals%ISOPEN THEN
        CLOSE c_valid_adm_cals;
      END IF;
     p_validation_success := 'N';
     logdetail(p_offresp_int_id,'E621', NULL, 'validate_off_resp_dtls: EXCEPTION WHEN OTHERS ' ,NULL);
     FND_FILE.PUT_LINE(FND_FILE.LOG,'validate_off_resp_dtls: '||FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION')||'  '||SQLERRM);
  END validate_off_resp_dtls;

  PROCEDURE imp_off_resp( errbuf              OUT NOCOPY   VARCHAR2,
                          retcode             OUT NOCOPY   NUMBER,
                          p_batch_id          IN    igs_ad_offresp_batch.batch_id%TYPE,
                          p_yes_no            IN    VARCHAR2)
  AS
  ---------------------------------------------------------------------------------------------------------------------------------------
  --  Created By : rboddu
  --  Date Created On : 09-SEP-2002
  --  Purpose : Bug 2395510. Main procedure of this package.
  --     Process flow
  --       1. Import all the Pending Interface Offer Response records into PL/SQL tables using BULK COLLECT.
  --       2. Perform all the validations on each Interface record by calling local procedure validate_off_resp_dtls.
  --       3. If any of the validations fail then insert Error record into the interface error table IGS_AD_OFFRESP_ERR.
  --       3. If validations Successful then Update the OSS table IGS_AD_PS_APPL_INST_ALL with Interface Offer Response details.
  --       4. If the Offer Response status of Application Instance is updated to 'ACCEPTED' then perform the Pre enrollment by calling
  --          the corresponding job.
  --       5. If the record is succesfully imported then Delete the interface record from IGS_AD_OFFRESP_INT.
  --       6. If All the interface records for the given batch_id are succesfully imported then delete the Batch record from IGS_AD_OFFRESP_BATCH.
  --       7. Once all the pending records are processed then invoke the Import Offer Response Error Rerport (IGSADS21).
  --  Know limitations, enhancements or remarks
  --  Change History
  --  Who             When            What
  --  knag            28-Oct-2002     Called func igs_ad_gen_003.get_core_or_optional_unit for bug  2647482
  --  rboddu          11/17/2003      Added p_prpsd_commencement_date declartions and import of it.
  ---------------------------------------------------------------------------------------------------------------------------------------

  /* Variable Declaration for BULK COLLECT feature (PL/SQL tables which hold the data for each column of interface table)*/
    TYPE offresp_int_idType              IS TABLE OF igs_ad_offresp_int.offresp_int_id%TYPE;
    TYPE batch_idType                    IS TABLE OF igs_ad_offresp_int.batch_id%TYPE;
    TYPE person_idType                   IS TABLE OF igs_ad_offresp_int.person_id%TYPE;
    TYPE admission_appl_numberType       IS TABLE OF igs_ad_offresp_int.admission_appl_number%TYPE;
    TYPE nominated_course_cdType         IS TABLE OF igs_ad_offresp_int.nominated_course_cd%TYPE;
    TYPE sequence_numberType             IS TABLE OF igs_ad_offresp_int.sequence_number%TYPE;
    TYPE adm_offer_resp_statusType       IS TABLE OF igs_ad_offresp_int.adm_offer_resp_status%TYPE;
    TYPE decline_ofr_reasonType	         IS TABLE OF igs_ad_offresp_int.decline_ofr_reason%TYPE;
    TYPE actual_offer_response_dtType    IS TABLE OF igs_ad_offresp_int.actual_offer_response_dt%TYPE;
    TYPE attent_other_inst_cdType        IS TABLE OF igs_ad_offresp_int.attent_other_inst_cd%TYPE;
    TYPE applicant_acptnce_cndtnType     IS TABLE OF igs_ad_offresp_int.applicant_acptnce_cndtn%TYPE;
    TYPE def_acad_cal_typeType           IS TABLE OF igs_ad_offresp_int.def_acad_cal_type%TYPE;
    TYPE def_acad_ci_seq_numType         IS TABLE OF igs_ad_offresp_int.def_acad_ci_sequence_number%TYPE;
    TYPE def_adm_cal_typeType            IS TABLE OF igs_ad_offresp_int.def_adm_cal_type%TYPE;
    TYPE def_adm_ci_sequence_numberType  IS TABLE OF igs_ad_offresp_int.def_adm_ci_sequence_number%TYPE;
    TYPE statusType                      IS TABLE OF igs_ad_offresp_int.status%TYPE;
    TYPE prpsd_commencement_dateType       IS TABLE OF igs_ad_offresp_int.prpsd_commencement_date%TYPE;

    t_offresp_int_id              offresp_int_idType;
    t_batch_id                    batch_idType;
    t_person_id                   person_idType;
    t_admission_appl_number       admission_appl_numberType;
    t_nominated_course_cd         nominated_course_cdType;
    t_sequence_number             sequence_numberType;
    t_adm_offer_resp_status       adm_offer_resp_statusType;
    t_decline_ofr_reason	  decline_ofr_reasonType;			--arvsrini igsm
    t_actual_offer_response_dt    actual_offer_response_dtType;
    t_attent_other_inst_cd        attent_other_inst_cdType ;
    t_applicant_acptnce_cndtn     applicant_acptnce_cndtnType;
    t_def_acad_cal_type           def_acad_cal_typeType;
    t_def_acad_ci_sequence_number def_acad_ci_seq_numType;
    t_def_adm_cal_type            def_adm_cal_typeType;
    t_def_adm_ci_sequence_number  def_adm_ci_sequence_numberType;
    t_status                      statusType;
    t_prpsd_commencement_date       prpsd_commencement_dateType;


    CURSOR int_off_resp_cur IS
    SELECT
    ofresp.offresp_int_id,
    ofresp.batch_id,
    ofresp.person_id,
    ofresp.admission_appl_number,
    ofresp.nominated_course_cd,
    ofresp.sequence_number,
    ofresp.adm_offer_resp_status,
    ofresp.decline_ofr_reason,							--arvsrini igsm
    ofresp.actual_offer_response_dt,
    ofresp.attent_other_inst_cd,
    ofresp.applicant_acptnce_cndtn,
    ofresp.def_acad_cal_type,
    ofresp.def_acad_ci_sequence_number,
    ofresp.def_adm_cal_type,
    ofresp.def_adm_ci_sequence_number,
    ofresp.status,
    ofresp.prpsd_commencement_date
    FROM
    igs_ad_offresp_int ofresp
    WHERE
    ofresp.batch_id = p_batch_id AND
    ofresp.status = '2';

    -- Cursor to get the Record status, which indicates whether the Record is succesfully Imported or not.
    CURSOR int_record_status(p_offresp_id igs_ad_offresp_int.offresp_int_id%TYPE) IS
    SELECT ofresp.status
    FROM
        igs_ad_offresp_int ofresp
    WHERE
        ofresp.offresp_int_id = p_offresp_id;

    CURSOR c_adm_appl_dtl (cp_person_id              igs_ad_appl_all.person_id%TYPE ,
                     cp_admission_appl_number  igs_ad_appl_all.admission_appl_number%TYPE) IS
    SELECT appl.*
    FROM igs_ad_appl_all appl
    WHERE person_id = cp_person_id AND
          admission_appl_number = cp_admission_appl_number;

    --Cursor to check if there is any Pending or Error interface Offer Response record is present in IGS_AD_OFFRESP_INT;
    CURSOR c_processed_recs(p_batch_id igs_ad_offresp_batch.batch_id%TYPE) IS
    SELECT offresp_int_id
    FROM igs_ad_offresp_int
    WHERE batch_id = p_batch_id AND
          status IN ('2','3');

    CURSOR get_conc_desctiption(l_name fnd_concurrent_programs_vl.concurrent_program_name%TYPE) IS
    SELECT description
    FROM fnd_concurrent_programs_vl
    WHERE concurrent_program_name = l_name;

    l_completed_flag VARCHAR2(1) ;
    v_message_name   VARCHAR2(30) ;
    v_warn_level     VARCHAR2(10);
    l_request_id     NUMBER;
    l_tot_rec_processed PLS_INTEGER;

    l_processed_Rec_Stat igs_ad_offresp_int.status%TYPE;
    l_adm_offer_defr_status igs_ad_ps_appl_inst_all.adm_offer_dfrmnt_status%TYPE;
    l_validation_success VARCHAR2(1);
    l_acaiv_rec cur_ad_ps_appl_inst%ROWTYPE;
    l_appl_rec  igs_ad_appl_all%ROWTYPE;
    l_calc_actual_ofr_resp_dt igs_ad_offresp_int.actual_offer_response_dt%TYPE;
    l_offresp_id igs_ad_offresp_int.offresp_int_id%TYPE;
    l_conc_description fnd_concurrent_programs_vl.description%TYPE;
    l_space_string VARCHAR2(300);


    l_gather_status       VARCHAR2(5);
    l_industry     VARCHAR2(5);
    l_schema       VARCHAR2(30);
    l_gather_return       BOOLEAN;
    l_owner        VARCHAR2(30);

    l_pre_enrol_success VARCHAR2(1);

    --Local variables to check if the Security Policy exception already set or not.  Ref: Bug 3919112
    l_sc_encoded_text   VARCHAR2(4000);
    l_sc_msg_count NUMBER;
    l_sc_msg_index NUMBER;
    l_sc_app_short_name VARCHAR2(50);
    l_sc_message_name   VARCHAR2(50);

    x_dummy   VARCHAR2(2000);
    lv_un_conf_prg_atmpt  BOOLEAN DEFAULT TRUE;


    BEGIN --of procedure imp_off_resp

	-- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
        igs_ge_gen_003.set_org_id(null);

	retcode:=0;
        l_completed_flag :='N';

     -- Gather statistics for interface table
     -- by rrengara on 20-jan-2003 bug 2711176

      BEGIN
        l_gather_return := fnd_installation.get_app_info('IGS', l_gather_status, l_industry, l_schema);
        FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_OFFRESP_BATCH', cascade => TRUE);
	FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_OFFRESP_INT', cascade => TRUE);
	FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_OFFRESP_ERR', cascade => TRUE);
      EXCEPTION WHEN OTHERS THEN
        NULL;
      END;


      -- Delete all the records from the error table for the currently processed Batch ID
      DELETE igs_ad_offresp_err WHERE offresp_int_id IN (SELECT offresp_int_id FROM igs_ad_offresp_int WHERE batch_id = p_batch_id);

      --Fetch All the Pending (Status = '2) Offer Response Interface records from IGS_AD_OFFRESP_INT (for the given batch id.)
      OPEN int_off_resp_cur;
      FETCH int_off_resp_cur BULK COLLECT INTO
        t_offresp_int_id,
        t_batch_id,
        t_person_id,
        t_admission_appl_number,
        t_nominated_course_cd,
        t_sequence_number,
        t_adm_offer_resp_status,
	t_decline_ofr_reason,
        t_actual_offer_response_dt,
        t_attent_other_inst_cd,
        t_applicant_acptnce_cndtn,
        t_def_acad_cal_type,
        t_def_acad_ci_sequence_number,
        t_def_adm_cal_type,
        t_def_adm_ci_sequence_number,
        t_status,
	t_prpsd_commencement_date;

      --This piece of code ensures that Processing is not done when there are no Pending Interface records found for given batch_id.
      IF NOT (t_offresp_int_id.COUNT >0)  THEN
        logdetail(p_batch_id, NULL, NULL, NULL,'Y');
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_NO_PEND_INT_REC');
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
        CLOSE int_off_resp_cur;
        RETURN;
      END IF;

      CLOSE int_off_resp_cur;

      l_tot_rec_processed := 0;  --Variable which stores the number of successfully imported records in the current run

      --Put the log header here by calling the logdetail procedure with relavant parameter values.
      logdetail(p_batch_id, NULL, NULL, NULL,'Y');

      FOR t_idx IN t_offresp_int_id.first..t_offresp_int_id.last LOOP

         OPEN c_adm_appl_dtl( t_person_id(t_idx),
                              t_admission_appl_number(t_idx));
         FETCH c_adm_appl_dtl INTO l_appl_rec;
         CLOSE c_adm_appl_dtl;

         OPEN cur_ad_ps_appl_inst(
               t_person_id(t_idx),
               t_admission_appl_number(t_idx),
               t_nominated_course_cd(t_idx),
               t_sequence_number(t_idx));
         FETCH cur_ad_ps_appl_inst INTO l_acaiv_rec;
         IF cur_ad_ps_appl_inst%FOUND THEN
              -- Validate each interface record here by calling the procedure Validate_offer_response_Details.
             validate_off_resp_dtls(
             t_offresp_int_id (t_idx),
             t_batch_id (t_idx),
             t_person_id (t_idx),
             t_admission_appl_number (t_idx),
             t_nominated_course_cd (t_idx),
             t_sequence_number (t_idx),
             t_adm_offer_resp_status (t_idx),
	     t_decline_ofr_reason (t_idx),
             t_actual_offer_response_dt (t_idx),
             t_attent_other_inst_cd (t_idx),
             t_applicant_acptnce_cndtn (t_idx),
             t_def_acad_cal_type (t_idx),
             t_def_acad_ci_sequence_number (t_idx),
             t_def_adm_cal_type (t_idx),
             t_def_adm_ci_sequence_number (t_idx),
             t_status (t_idx),
	     t_prpsd_commencement_date (t_idx),
             l_adm_offer_defr_status, --OUT var
             l_calc_actual_ofr_resp_dt,
             l_appl_rec,
             l_acaiv_rec,
             p_yes_no,
             l_validation_success); --OUT var

             SAVEPOINT current_rec_savepoint;

           -- If the record has passed all the validations then import the record into Production table by calling The necessary TBH Update_row call.
              l_completed_flag := 'N'; --Flag to ensure proper Updation and Pre Enrolment (If Offer Resp Stat is 'ACCEPTED)





	      lv_un_conf_prg_atmpt := TRUE;
             IF l_validation_success = 'N' THEN
               UPDATE igs_ad_offresp_int SET status = '3' WHERE offresp_int_id = t_offresp_int_id(t_idx);
             ELSE



	       -- begin apadegal adtd001 igs.m
	       BEGIN

			 IF NVL(IGS_AD_GEN_008.ADMP_GET_SAORS(l_acaiv_rec.adm_offer_resp_status), 'NULL') = 'ACCEPTED'
			    AND    NVL(IGS_AD_GEN_008.ADMP_GET_SAORS(t_adm_offer_resp_status(t_idx)), 'NULL') <> 'ACCEPTED'
			 THEN
				  -- UNCONFIRM the Student PROGRAM ATTEMPTS.   (api would be provided by enrolments team)
				IF NOT IGS_EN_VAL_SCA.handle_rederive_prog_att (p_person_id 		     =>  l_acaiv_rec.PERSON_ID ,
										  p_admission_appl_number    =>  l_acaiv_rec.ADMISSION_APPL_NUMBER ,
										  p_nominated_course_cd      =>  l_acaiv_rec.NOMINATED_COURSE_CD ,
										  p_sequence_number 	     =>  l_acaiv_rec.SEQUENCE_NUMBER ,
										  p_message 		     =>	 x_dummy
										 )
				 THEN

					lv_un_conf_prg_atmpt := FALSE;
					App_Exception.Raise_Exception;

				 END IF;
			  END IF;

	       EXCEPTION --Update operation failed
                   WHEN OTHERS THEN
                     ROLLBACK TO current_rec_savepoint;
                     l_completed_flag := 'N';
                     UPDATE igs_ad_offresp_int SET status = '3' WHERE offresp_int_id = t_offresp_int_id(t_idx);

		     x_dummy := FND_MESSAGE.GET;
                     insert_int_error(t_offresp_int_id (t_idx),NULL,x_dummy);

                     logdetail(t_offresp_int_id(t_idx), NULL, x_dummy,'imp_off_resp: IF IGS_EN_VAL_SCA.handle_rederive_prog_att: '||x_dummy,NULL);
	       END ;
   	   -- end apadegal adtd001 igs.m

               BEGIN

		   IF lv_un_conf_prg_atmpt    --- if unconfirming SPA is successful
		   THEN

				   igs_ad_ps_appl_inst_pkg.update_row (
				   x_mode                              => 'R',
				   x_rowid                             => l_acaiv_rec.rowid,
				   x_person_id                         => l_acaiv_rec.person_id,
				   x_admission_appl_number             => l_acaiv_rec.admission_appl_number,
				   x_nominated_course_cd               => l_acaiv_rec.nominated_course_cd,
				   x_sequence_number                   => l_acaiv_rec.sequence_number,
				   x_predicted_gpa                     => l_acaiv_rec.predicted_gpa,
				   x_academic_index                    => l_acaiv_rec.academic_index,
				   x_adm_cal_type                      => l_acaiv_rec.adm_cal_type,
				   x_app_file_location                 => l_acaiv_rec.app_file_location,
				   x_adm_ci_sequence_number            => l_acaiv_rec.adm_ci_sequence_number,
				   x_course_cd                         => l_acaiv_rec.course_cd,
				   x_app_source_id                     => l_acaiv_rec.app_source_id,
				   x_crv_version_number                => l_acaiv_rec.crv_version_number,
				   x_waitlist_rank                     => l_acaiv_rec.waitlist_rank,
				   x_location_cd                       => l_acaiv_rec.location_cd,
				   x_attent_other_inst_cd              => t_attent_other_inst_cd (t_idx), --From Interface
				   x_attendance_mode                   => l_acaiv_rec.attendance_mode,
				   x_edu_goal_prior_enroll_id          => l_acaiv_rec.edu_goal_prior_enroll_id,
				   x_attendance_type                   => l_acaiv_rec.attendance_type,
				   x_decision_make_id                  => l_acaiv_rec.decision_make_id,
				   x_unit_set_cd                       => l_acaiv_rec.unit_set_cd,
				   x_decision_date                     => l_acaiv_rec.decision_date,
				   x_attribute_category                => l_acaiv_rec.attribute_category,
				   x_attribute1                        => l_acaiv_rec.attribute1,
				   x_attribute2                        => l_acaiv_rec.attribute2,
				   x_attribute3                        => l_acaiv_rec.attribute3,
				   x_attribute4                        => l_acaiv_rec.attribute4,
				   x_attribute5                        => l_acaiv_rec.attribute5,
				   x_attribute6                        => l_acaiv_rec.attribute6,
				   x_attribute7                        => l_acaiv_rec.attribute7,
				   x_attribute8                        => l_acaiv_rec.attribute8,
				   x_attribute9                        => l_acaiv_rec.attribute9,
				   x_attribute10                       => l_acaiv_rec.attribute10,
				   x_attribute11                       => l_acaiv_rec.attribute11,
				   x_attribute12                       => l_acaiv_rec.attribute12,
				   x_attribute13                       => l_acaiv_rec.attribute13,
				   x_attribute14                       => l_acaiv_rec.attribute14,
				   x_attribute15                       => l_acaiv_rec.attribute15,
				   x_attribute16                       => l_acaiv_rec.attribute16,
				   x_attribute17                       => l_acaiv_rec.attribute17,
				   x_attribute18                       => l_acaiv_rec.attribute18,
				   x_attribute19                       => l_acaiv_rec.attribute19,
				   x_attribute20                       => l_acaiv_rec.attribute20,
				   x_decision_reason_id                => l_acaiv_rec.decision_reason_id,
				   x_us_version_number                 => l_acaiv_rec.us_version_number,
				   x_decision_notes                    => l_acaiv_rec.decision_notes,
				   x_pending_reason_id                 => l_acaiv_rec.pending_reason_id,
				   x_preference_number                 => l_acaiv_rec.preference_number,
				   x_adm_doc_status                    => l_acaiv_rec.adm_doc_status,
				   x_adm_entry_qual_status             => l_acaiv_rec.adm_entry_qual_status,
				   x_deficiency_in_prep                => l_acaiv_rec.deficiency_in_prep,
				   x_late_adm_fee_status               => l_acaiv_rec.late_adm_fee_status,
				   x_spl_consider_comments             => l_acaiv_rec.spl_consider_comments,
				   x_apply_for_finaid                  => l_acaiv_rec.apply_for_finaid,
				   x_finaid_apply_date                 => l_acaiv_rec.finaid_apply_date,
				   x_adm_outcome_status                => l_acaiv_rec.adm_outcome_status,
				   x_adm_otcm_stat_auth_per_id         => l_acaiv_rec.adm_otcm_status_auth_person_id,
				   x_adm_outcome_status_auth_dt        => l_acaiv_rec.adm_outcome_status_auth_dt,
				   x_adm_outcome_status_reason         => l_acaiv_rec.adm_outcome_status_reason,
				   x_offer_dt                          => l_acaiv_rec.offer_dt,
				   x_offer_response_dt                 => l_acaiv_rec.offer_response_dt,
				   x_prpsd_commencement_dt             => NVL(t_prpsd_commencement_date (t_idx),l_acaiv_rec.prpsd_commencement_dt),
				   x_adm_cndtnl_offer_status           => l_acaiv_rec.adm_cndtnl_offer_status,
				   x_cndtnl_offer_satisfied_dt         => l_acaiv_rec.cndtnl_offer_satisfied_dt,
				   x_cndnl_ofr_must_be_stsfd_ind       => l_acaiv_rec.cndtnl_offer_must_be_stsfd_ind,
				   x_adm_offer_resp_status             => t_adm_offer_resp_status(t_idx), --From Interface
				   x_actual_response_dt                => TRUNC(l_calc_actual_ofr_resp_dt),  --From Interface (Populated with SYSDATE if NULL in the Validate_off_resp_Dtls procedure)
				   x_adm_offer_dfrmnt_status           => l_adm_offer_defr_status,  --Derived From Interface record
				   x_deferred_adm_cal_type             => t_def_adm_cal_type(t_idx),  --From Interface
				   x_deferred_adm_ci_sequence_num      => t_def_adm_ci_sequence_number(t_idx),  --From Interface
				   x_deferred_tracking_id              => NULL,
				   x_ass_rank                          => l_acaiv_rec.ass_rank,
				   x_secondary_ass_rank                => l_acaiv_rec.secondary_ass_rank,
				   x_intr_accept_advice_num            => l_acaiv_rec.intrntnl_acceptance_advice_num,
				   x_ass_tracking_id                   => l_acaiv_rec.ass_tracking_id,
				   x_fee_cat                           => l_acaiv_rec.fee_cat,
				   x_hecs_payment_option               => l_acaiv_rec.hecs_payment_option,
				   x_expected_completion_yr            => l_acaiv_rec.expected_completion_yr,
				   x_expected_completion_perd          => l_acaiv_rec.expected_completion_perd,
				   x_correspondence_cat                => l_acaiv_rec.correspondence_cat,
				   x_enrolment_cat                     => l_acaiv_rec.enrolment_cat,
				   x_funding_source                    => l_acaiv_rec.funding_source,
				   x_applicant_acptnce_cndtn           => t_applicant_acptnce_cndtn(t_idx),  --From Interface
				   x_cndtnl_offer_cndtn                => l_acaiv_rec.cndtnl_offer_cndtn,
				   x_ss_application_id                 => NULL,
				   x_ss_pwd                            => NULL   ,
				   x_authorized_dt                     => l_acaiv_rec.authorized_dt, --From Interface
				   x_authorizing_pers_id               => l_acaiv_rec.authorizing_pers_id,
				   x_entry_status                      => l_acaiv_rec.entry_status,
				   x_entry_level                       => l_acaiv_rec.entry_level,
				   x_sch_apl_to_id                     => l_acaiv_rec.sch_apl_to_id,
				   x_idx_calc_date                     => l_acaiv_rec.idx_calc_date,
				   x_waitlist_status                   => l_acaiv_rec.waitlist_status,
				   x_attribute21                       => l_acaiv_rec.attribute21,
				   x_attribute22                       => l_acaiv_rec.attribute22,
				   x_attribute23                       => l_acaiv_rec.attribute23,
				   x_attribute24                       => l_acaiv_rec.attribute24,
				   x_attribute25                       => l_acaiv_rec.attribute25,
				   x_attribute26                       => l_acaiv_rec.attribute26,
				   x_attribute27                       => l_acaiv_rec.attribute27,
				   x_attribute28                       => l_acaiv_rec.attribute28,
				   x_attribute29                       => l_acaiv_rec.attribute29,
				   x_attribute30                       => l_acaiv_rec.attribute30,
				   x_attribute31                       => l_acaiv_rec.attribute31,
				   x_attribute32                       => l_acaiv_rec.attribute32,
				   x_attribute33                       => l_acaiv_rec.attribute33,
				   x_attribute34                       => l_acaiv_rec.attribute34,
				   x_attribute35                       => l_acaiv_rec.attribute35,
				   x_attribute36                       => l_acaiv_rec.attribute36,
				   x_attribute37                       => l_acaiv_rec.attribute37,
				   x_attribute38                       => l_acaiv_rec.attribute38,
				   x_attribute39                       => l_acaiv_rec.attribute39,
				   x_attribute40                       => l_acaiv_rec.attribute40,
				   x_fut_acad_cal_type                 => l_acaiv_rec.future_acad_cal_type,
				   x_fut_acad_ci_sequence_number       => l_acaiv_rec.future_acad_ci_sequence_number,
				   x_fut_adm_cal_type                  => l_acaiv_rec.future_adm_cal_type,
				   x_fut_adm_ci_sequence_number        => l_acaiv_rec.future_adm_ci_sequence_number,
				   x_prev_term_adm_appl_number         => l_acaiv_rec.previous_term_adm_appl_number,
				   x_prev_term_sequence_number         => l_acaiv_rec.previous_term_sequence_number,
				   x_fut_term_adm_appl_number          => l_acaiv_rec.future_term_adm_appl_number,
				   x_fut_term_sequence_number          => l_acaiv_rec.future_term_sequence_number,
				   x_def_acad_cal_type                 => t_def_acad_cal_type(t_idx), --From Interface
				   x_def_acad_ci_sequence_num          => t_def_acad_ci_sequence_number(t_idx), --From Interface
				   x_def_prev_term_adm_appl_num        => NULL,
				   x_def_prev_appl_sequence_num        => NULL,
				   x_def_term_adm_appl_num             => NULL,
				   x_def_appl_sequence_num             => NULL,
				   x_decline_ofr_reason		       => t_decline_ofr_reason(t_idx)			--arvsrini igsm
				   );

				   l_completed_flag := 'Y';
		        END IF;
                 EXCEPTION --Update operation failed
                   WHEN OTHERS THEN
                     ROLLBACK TO current_rec_savepoint;
                     l_completed_flag := 'N';
                     UPDATE igs_ad_offresp_int SET status = '3' WHERE offresp_int_id = t_offresp_int_id(t_idx);
                     insert_int_error(t_offresp_int_id (t_idx),'E621',NULL);

                     logdetail(t_offresp_int_id(t_idx), 'E621', NULL,'imp_off_resp: igs_ad_ps_appl_inst_pkg.update_row',NULL);

                     --Loop through all messages in stack to check if there is Security Policy exception already set or not.    Ref: Bug 3919112
                     l_sc_msg_count := IGS_GE_MSG_STACK.COUNT_MSG;
                     WHILE l_sc_msg_count <> 0 loop
                       igs_ge_msg_stack.get(l_sc_msg_count, 'T', l_sc_encoded_text, l_sc_msg_index);
                       fnd_message.parse_encoded(l_sc_encoded_text, l_sc_app_short_name, l_sc_message_name);
                       IF l_sc_message_name = 'IGS_SC_POLICY_EXCEPTION' OR l_sc_message_name = 'IGS_SC_POLICY_UPD_DEL_EXCEP' THEN
                         --print the the security exception in log file.
                         fnd_message.set_encoded(l_sc_encoded_text);
                         FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                         EXIT;
                       END IF;
                       l_sc_msg_count := l_sc_msg_count - 1;
                     END LOOP;

                END; --of igs_ad_ps_appl_inst_pkg.update_row
             END IF;

           --	  Else    Insert proper Error message into the Error Interface table.
           --     Update the Current Interface Offer Response record with Status '3'.

             IF l_completed_flag = 'Y' THEN
               IF igs_ad_gen_008.admp_get_saors(t_adm_offer_resp_status(t_idx)) = 'ACCEPTED' THEN
              	   -- Now the Record is updated successfully then call the Pre Enrollment Job with Confirm_ind and Eligibility_Ind parameters as 'Y', 'Y' respectively.
                 IF igs_ad_upd_initialise.perform_pre_enrol(
                      l_acaiv_rec.person_id,
                      l_acaiv_rec.admission_appl_number,
                      l_acaiv_rec.nominated_course_cd,
                      l_acaiv_rec.sequence_number,
                      'Y',                     -- Confirm course indicator.
                      'Y',                     -- Perform eligibility check indicator.
                      v_message_name) = FALSE THEN
                   ROLLBACK TO current_rec_savepoint;
                   -- Update the Status of interface record and insert the error Code / Message text into Error table igs_ad_offresp_int.
                   l_completed_flag := 'N';
                   l_pre_enrol_success := 'N';
                   insert_int_error(t_offresp_int_id (t_idx),NULL,v_message_name);
                   logdetail(t_offresp_int_id(t_idx), NULL, v_message_name,'imp_off_resp: IF igs_ad_upd_initialise.perform_pre_enrol',NULL);
                   UPDATE igs_ad_offresp_int SET status = '3' WHERE offresp_int_id = t_offresp_int_id(t_idx);
                 END IF; -- Of call to Pre Enrollment job
               END IF;


                  -- Pre enrollment job is successful so put the Successful record information in the Concurrent LOG.
                IF NVL(l_pre_enrol_success,'Y') = 'Y' THEN
                  logdetail(t_offresp_int_id(t_idx), NULL, NULL,NULL,NULL);
                  -- Delete the succesfully imported Interface record from the corresponding interface table.
                  DELETE igs_ad_offresp_int WHERE offresp_int_id = t_offresp_int_id (t_idx);
                END IF;

             END IF;  --End of l_completed_flag = 'Y'


         ELSE --Application instance is not found in the OSS System table.
           insert_int_error(t_offresp_int_id (t_idx),'E605',NULL);
           UPDATE igs_ad_offresp_int SET status = '3' WHERE offresp_int_id = t_offresp_int_id(t_idx);
           logdetail(t_offresp_int_id (t_idx), 'E605', NULL, 'imp_off_resp: IF acaiv_rec.person_id' ,NULL);
         END IF;
         CLOSE cur_ad_ps_appl_inst;

         l_tot_rec_processed := l_tot_rec_processed+1;
         -- For every 200 records processed, issue a COMMIT here.
         IF l_tot_rec_processed > 200 THEN
           COMMIT;
           l_tot_rec_processed := 0;
         END IF;

      END LOOP; -- All the Pending records are processed.

      -- Check if all the interface records have successfully been imported. In this case delete the batch record from interface batch table.
      OPEN c_processed_recs(p_batch_id);
      FETCH c_processed_recs INTO l_offresp_id;
      IF c_processed_recs%NOTFOUND THEN
        DELETE igs_ad_offresp_batch where batch_id = p_batch_id;
      END IF;
      CLOSE c_processed_recs;

      IF l_tot_rec_processed > 0 THEN -- Commit the records not yet committed above
        COMMIT;
      END IF;

      --Invoke the Import Offer Response Error Report by submit the Concurrent Request.
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                        APPLICATION                => 'IGS',
                        PROGRAM                    => 'IGSADS21',
                        DESCRIPTION                => 'Import Offer Response Error Report',
                        START_TIME                 => NULL,
                        SUB_REQUEST                => FALSE,
                        ARGUMENT1                  => p_batch_id ,
                        ARGUMENT2                  => CHR(0),
                        ARGUMENT3                  => NULL,
                        ARGUMENT4                  => NULL,
                        ARGUMENT5     	           => NULL,
                        ARGUMENT6                  => NULL,
                        ARGUMENT7  	               => NULL,
                        ARGUMENT8		               => NULL,
                        ARGUMENT9   	             => NULL,
                        ARGUMENT10           	     => NULL,
                        ARGUMENT11   	             => NULL,
                        ARGUMENT12   	             => NULL,
                        ARGUMENT13                 => NULL,
                        ARGUMENT14                 => NULL,
                        ARGUMENT15                 => NULL,
                        ARGUMENT16                 => NULL,
                        ARGUMENT17                 => NULL,
                        ARGUMENT18                 => NULL,
                        ARGUMENT19                 => NULL,
                        ARGUMENT20                 => NULL,
                        ARGUMENT21                 => NULL,
                        ARGUMENT22                 => NULL,
                        ARGUMENT23                 => NULL,
                        ARGUMENT24                 => NULL,
                        ARGUMENT25                 => NULL,
                        ARGUMENT26                 => NULL,
                        ARGUMENT27                 => NULL,
                        ARGUMENT28                 => NULL,
                        ARGUMENT29                 => NULL,
                        ARGUMENT30                 => NULL,
                        ARGUMENT31                 => NULL,
                        ARGUMENT32                 => NULL,
                        ARGUMENT33                 => NULL,
                        ARGUMENT34                 => NULL,
                        ARGUMENT35                 => NULL,
                        ARGUMENT36                 => NULL,
                        ARGUMENT37                 => NULL,
                        ARGUMENT38                 => NULL,
                        ARGUMENT39                 => NULL,
                        ARGUMENT40                 => NULL,
                        ARGUMENT41                 => NULL,
                        ARGUMENT42                 => NULL,
                        ARGUMENT43                 => NULL,
                        ARGUMENT44                 => NULL,
                        ARGUMENT45                 => NULL,
                        ARGUMENT46                 => NULL,
                        ARGUMENT47                 => NULL,
                        ARGUMENT48                 => NULL,
                        ARGUMENT49                 => NULL,
                        ARGUMENT50                 => NULL,
                        ARGUMENT51                 => NULL,
                        ARGUMENT52                 => NULL,
                        ARGUMENT53                 => NULL,
                        ARGUMENT54                 => NULL,
                        ARGUMENT55                 => NULL,
                        ARGUMENT56                 => NULL,
                        ARGUMENT57                 => NULL,
                        ARGUMENT58                 => NULL,
                        ARGUMENT59                 => NULL,
                        ARGUMENT60                 => NULL,
                        ARGUMENT61                 => NULL,
                        ARGUMENT62                 => NULL,
                        ARGUMENT63                 => NULL,
                        ARGUMENT64                 => NULL,
                        ARGUMENT65                 => NULL,
                        ARGUMENT66                 => NULL,
                        ARGUMENT67                 => NULL,
                        ARGUMENT68                 => NULL,
                        ARGUMENT69                 => NULL,
                        ARGUMENT70                 => NULL,
                        ARGUMENT71                 => NULL,
                        ARGUMENT72                 => NULL,
                        ARGUMENT73                 => NULL,
                        ARGUMENT74                 => NULL,
                        ARGUMENT75                 => NULL,
                        ARGUMENT76                 => NULL,
                        ARGUMENT77                 => NULL,
                        ARGUMENT78                 => NULL,
                        ARGUMENT79                 => NULL,
                        ARGUMENT80                 => NULL,
                        ARGUMENT81                 => NULL,
                        ARGUMENT82                 => NULL,
                        ARGUMENT83                 => NULL,
                        ARGUMENT84                 => NULL,
                        ARGUMENT85                 => NULL,
                        ARGUMENT86                 => NULL,
                        ARGUMENT87                 => NULL,
                        ARGUMENT88                 => NULL,
                        ARGUMENT89                 => NULL,
                        ARGUMENT90                 => NULL,
                        ARGUMENT91                 => NULL,
                        ARGUMENT92                 => NULL,
                        ARGUMENT93                 => NULL,
                        ARGUMENT94                 => NULL,
                        ARGUMENT95                 => NULL,
                        ARGUMENT96                 => NULL,
                        ARGUMENT97                 => NULL,
                        ARGUMENT98                 => NULL,
                        ARGUMENT99                 => NULL,
                        ARGUMENT100                => NULL
                      );

      --  Job is invoked, so Display the Cocnurrent Job request Request ID details in the LOG file of the Import of Offer Response job.
      OPEN get_conc_desctiption('IGSADS21');
      FETCH get_conc_desctiption INTO l_conc_Description;
      CLOSE get_conc_desctiption;

      l_space_string :='                                                                                                                                  ';
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_space_string);

      FND_MESSAGE.SET_NAME('FND','CONC-SUBMITTED REQUEST');
      FND_MESSAGE.SET_TOKEN('REQUEST_ID',IGS_GE_NUMBER.TO_CANN(l_request_id), FALSE);
      FND_FILE.PUT_LINE(FND_FILE.LOG,l_conc_Description||' '||FND_MESSAGE.GET);

  EXCEPTION --raised in the Concurrent job - Import Offer Response error report
  WHEN OTHERS THEN
      IF int_off_resp_cur%ISOPEN THEN
        CLOSE int_off_resp_cur;
      END IF;
      IF int_record_status%ISOPEN THEN
        CLOSE int_record_status;
      END IF;
      IF c_adm_appl_dtl%ISOPEN THEN
        CLOSE c_adm_appl_dtl;
      END IF;
      IF c_processed_recs%ISOPEN THEN
        CLOSE c_processed_recs;
      END IF;
      IF get_conc_desctiption%ISOPEN THEN
        CLOSE get_conc_desctiption;
      END IF;
      retcode:=2;
      errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION')||'  '||SQLERRM;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'igs_ad_imp_off_resp_data.imp_off_resp: '||errbuf);
      Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;

  END imp_off_resp; -- End of the main procedure

END igs_ad_imp_off_resp_data; --End of Package

/
