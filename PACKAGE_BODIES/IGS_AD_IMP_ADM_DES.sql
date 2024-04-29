--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_ADM_DES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_ADM_DES" AS
/* $Header: IGSADB1B.pls 120.1 2006/02/01 04:21:43 pfotedar noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL Body for package: IGS_AD_IMP_ADM_DES                      |
 |                                                                       |
 | NOTES                                                                 |
 |     This is the Package body for the Package IGS_AD_IMP_ADM_DES       |
 |     which will update the outcome decision for an application         |
 |     calculated by the user in interface table                         |
 | HISTORY                                                               |
 | Who             When            What                                  |
 | rrengara       2001/08/14      Creation of this code                  |
 | cdcruz         18-feb-2002     Bug 2217104 Admit to future term Enhancement,updated tbh call for
 |                                new columns being added to IGS_AD_PS_APPL_INST
 |
 | kamohan      09-SEP-2002  Bug 2536463 Modified the package to accomodate the detailed |
 |                                           error codes for the outcome status validation failure                  |
 | nshee     29-Aug-2002  Bug 2395510 added 6 columns as part of deferments build |
 | kamohan      16-SEP-2002  Bug # 2550009 // Modified the prc_adm_outcome_status procedure
 |                                            for the UCAS transaction builder call            	        	         |
 |ayedubat        04-DEC-03      Modified the call to  the procedure,ucas_user_hook to add         |
 |                               two new IN parameters, p_condition_category and p_condition_name  |
 |                               and one OUT Patrameter,p_uc_tran_id  for bug, 3009203             |
 *=======================================================================*/


   PROCEDURE update_int_table (
      p_status               IN   igs_ad_admde_int.status%TYPE,
      p_error_msg            IN   fnd_new_messages.message_text%TYPE,  -- Replaced error_code with error_msg Bug 3297241
      p_interface_mkdes_id   IN   igs_ad_admde_int.interface_mkdes_id%TYPE,
      p_outcome_status       IN   igs_ad_admde_int.adm_outcome_status%TYPE
   )
   IS
       ------------------------------------------------------------------
  --Created by  : rrengara, Oracle India (in)
  --Date created:  14-AUG-2001
  --
  --Purpose: to update the interface table
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
   BEGIN
      UPDATE igs_ad_admde_int
         SET status = p_status,
             error_text = p_error_msg
       WHERE interface_mkdes_id = p_interface_mkdes_id;
   END update_int_table;

   PROCEDURE validate_set_decision_details (
      p_batch_id               IN       igs_ad_admde_int.batch_id%TYPE,
      p_interface_mkdes_id     IN       igs_ad_admde_int.interface_mkdes_id%TYPE,
      p_person_id              IN       igs_pe_person.person_id%TYPE,
      p_acad_cal_type           IN       igs_ad_appl.acad_cal_type%TYPE,
      p_acad_ci_sequence_number IN       igs_ad_appl.acad_ci_sequence_number%TYPE,
      p_adm_cal_type            IN       igs_ad_appl.adm_cal_type%TYPE,
      p_adm_ci_sequence_number  IN       igs_ad_appl.adm_ci_sequence_number%TYPE,
      p_admission_cat           IN       igs_ad_appl.admission_cat%TYPE,
      p_s_admission_process_type IN      igs_ad_appl.s_admission_process_type%TYPE,
      p_s_adm_outcome_status   IN        igs_ad_ou_Stat.s_adm_outcome_status%TYPE,
      p_decision_make_id       OUT NOCOPY      igs_ad_ps_appl_inst.decision_make_id%TYPE,
      p_decision_date          OUT NOCOPY      igs_ad_ps_appl_inst.decision_date%TYPE,
      p_decision_reason_id     OUT NOCOPY      igs_ad_ps_appl_inst.decision_reason_id%TYPE,
      p_pending_reason_id      OUT NOCOPY      igs_ad_ps_appl_inst.pending_reason_id%TYPE,
      p_offer_dt               OUT NOCOPY      igs_ad_ps_appl_inst.offer_dt%TYPE,
      p_offer_response_dt      OUT NOCOPY      igs_ad_ps_appl_inst.offer_response_dt%TYPE,
      p_error_msg              OUT NOCOPY      fnd_new_messages.message_name%TYPE,  -- Replaced error_code with error_msg Bug 3297241
      p_return_status          OUT NOCOPY      VARCHAR2,
      p_prpsd_commencement_date   IN  igs_ad_admde_int_all.prpsd_commencement_date%TYPE DEFAULT NULL
   )
   IS
       ------------------------------------------------------------------
  --Created by  : rrengara, Oracle India (in)
  --Date created:  14-AUG-2001
  --
  --Purpose: to validate set decision details
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --rboddu      11/17/2003      Added  p_prpsd_commencement_date and related validations. Bug 3181590
  -------------------------------------------------------------------
      CURSOR def_fields_cur
      IS
         SELECT decision_make_id, decision_date, decision_reason_id,
                pending_reason_id, offer_dt, offer_response_dt
           FROM igs_ad_batc_def_det
         WHERE
                batch_id = p_batch_id AND
                acad_cal_type = p_acad_cal_type AND
                acad_ci_sequence_number = p_acad_ci_sequence_number AND
                adm_cal_type = p_adm_cal_type AND
                adm_ci_sequence_number = p_adm_ci_sequence_number AND
                admission_cat = p_admission_cat AND
                s_admission_process_type = p_s_admission_process_type;


      CURSOR appl_des_fields_cur
      IS
         SELECT person_id, decision_make_id, decision_date, decision_reason_id,
                pending_reason_id, offer_dt, offer_response_dt, admission_appl_number
           FROM igs_ad_admde_int
          WHERE interface_mkdes_id = p_interface_mkdes_id;

      l_c_def_fields_rec        def_fields_cur%ROWTYPE;
      l_c_appl_des_fields_rec   appl_des_fields_cur%ROWTYPE;
      l_decision_maker VARCHAR2(1);

      CURSOR appl_dt_cur (
         cp_person_id               igs_pe_person.person_id%TYPE,
         cp_admission_appl_number   igs_ad_ps_appl_inst.admission_appl_number%TYPE
      )
      IS
         SELECT appl_dt
           FROM igs_ad_appl
          WHERE person_id = cp_person_id
            AND admission_appl_number = cp_admission_appl_number;

      l_appl_dt                 igs_ad_appl.appl_dt%TYPE;

  CURSOR c_code_classes (cp_class igs_ad_code_classes.class%TYPE,
                           cp_code_id igs_ad_code_classes.code_id%TYPE) IS
      SELECT   'x'
      FROM     igs_ad_code_classes
      WHERE    code_id = cp_code_id
      AND      class   = cp_class
      AND      closed_ind = 'N';

    l_decision_reason_id_found VARCHAR2(1);
    l_pending_reason_id_found VARCHAR2(1);
 CURSOR c_decision_maker (cp_decision_maker_id igs_pe_person_base_v.person_id%TYPE) IS
         SELECT 'x'
         FROM   igs_pe_typ_instances typeinst
                 WHERE  typeinst.person_id = cp_decision_maker_id
         AND    typeinst.system_type IN ('STAFF','FACULTY')
         AND    (SYSDATE between typeinst.start_date AND NVL(typeinst.end_date,SYSDATE));

 CURSOR c_dmi (cp_person_id NUMBER) IS
   SELECT 'X'
   FROM  igs_pe_person_base_v base, igs_pe_hz_parties pd
   WHERE base.person_id = cp_person_id
   AND  base.person_id = pd.party_id (+)
   AND  DECODE(base.date_of_death,NULL,NVL(pd.deceased_ind,'N'),'Y') = 'Y';

  l_deceased igs_pe_person.person_id%TYPE := NULL;

   BEGIN
      /*  Open the  details */
      OPEN def_fields_cur;
      FETCH def_fields_cur INTO l_c_def_fields_rec;
      CLOSE def_fields_cur;
      /*  Open the application specific decision reason fields */
      OPEN appl_des_fields_cur;
      FETCH appl_des_fields_cur INTO l_c_appl_des_fields_rec;
      CLOSE appl_des_fields_cur;

      OPEN appl_dt_cur (
         l_c_appl_des_fields_rec.person_id,
         l_c_appl_des_fields_rec.admission_appl_number
      );
      FETCH appl_dt_cur INTO l_appl_dt;
      CLOSE appl_dt_cur;

      /* If the application specific decision detail information is not available then assign the */
      /*  decision detail information.  */
      /*Validate and Set Decision Make ID information */
      IF l_c_appl_des_fields_rec.decision_make_id IS NOT NULL
      THEN
         p_decision_make_id := l_c_appl_des_fields_rec.decision_make_id;
      ELSE
         p_decision_make_id := l_c_def_fields_rec.decision_make_id;
      END IF;



      --Validate and Set Decision Date field --
      IF l_c_appl_des_fields_rec.decision_date IS NULL
      THEN
         p_decision_date := l_c_def_fields_rec.decision_date;


      ELSE
         p_decision_date := l_c_appl_des_fields_rec.decision_date;
      END IF;

      /* Validate And Set Decision Reason ID */
      p_decision_reason_id := NVL (
                                 l_c_appl_des_fields_rec.decision_reason_id,
                                 l_c_def_fields_rec.decision_reason_id
                              );



      /* Validate And Set Pending Reason ID */
      p_pending_reason_id := NVL (
                                l_c_appl_des_fields_rec.pending_reason_id,
                                l_c_def_fields_rec.pending_reason_id
                             );




      /* Validate And Set the offer date */
      p_offer_dt :=
           NVL (l_c_appl_des_fields_rec.offer_dt, l_c_def_fields_rec.offer_dt);



    --Bug 3181590
      IF p_s_adm_outcome_status NOT IN ('OFFER','COND-OFFER') AND
         p_prpsd_commencement_date IS NOT NULL THEN
         p_error_msg := 'IGS_AD_PRPSD_CMNCDT_NOIMPORT';  --Proposed Commencement Date cannot be imported without Offer Bug 3297241
         p_return_status := 'FALSE';
         RETURN;
      END IF;
      IF p_prpsd_commencement_date IS NOT NULL
        AND TRUNC(p_prpsd_commencement_date) > TRUNC(SYSDATE)
	OR TRUNC(p_prpsd_commencement_date) < TRUNC(l_appl_dt)
        OR TRUNC(p_prpsd_commencement_date) < TRUNC(p_offer_dt) THEN
	 p_error_msg := 'IGS_AD_PRPSD_CMCMNT_DT_INVALID'; --Proposed Commencement Date can not be greater than current date, cannot be less than Application Date and cannot be less than Offer Date
         p_return_status := 'FALSE';
         RETURN;
      END IF;
    --End Bug 3181590

      /* Set the offer response date. */
      p_offer_response_dt := NVL (
                                l_c_appl_des_fields_rec.offer_response_dt,
                                l_c_def_fields_rec.offer_response_dt
                             );

   EXCEPTION
      WHEN OTHERS
      THEN
         p_error_msg := 'IGS_AD_DECISION_DTLS_INVALID'; -- Replaced error_code with error_msg Bug 3297241
         p_return_status := 'FALSE';
   END validate_set_decision_details;

   PROCEDURE prc_adm_outcome_status (
      p_person_id               IN       igs_pe_person.person_id%TYPE,
      p_admission_appl_number   IN       igs_ad_appl.admission_appl_number%TYPE,
      p_nominated_course_cd     IN       igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
      p_sequence_number         IN       igs_ad_ps_appl_inst.sequence_number%TYPE,
      p_adm_outcome_status      IN       igs_ad_ou_stat.adm_outcome_status%TYPE,
      p_s_adm_outcome_status    IN       igs_ad_ou_stat.s_adm_outcome_status%TYPE,
      p_acad_cal_type           IN       igs_ad_appl.acad_cal_type%TYPE,
      p_acad_ci_sequence_number IN       igs_ad_appl.acad_ci_sequence_number%TYPE,
      p_adm_cal_type            IN       igs_ad_appl.adm_cal_type%TYPE,
      p_adm_ci_sequence_number  IN       igs_ad_appl.adm_ci_sequence_number%TYPE,
      p_admission_cat           IN       igs_ad_appl.admission_cat%TYPE,
      p_s_admission_process_type IN      igs_ad_appl.s_admission_process_type%TYPE,
      p_batch_id                IN       igs_ad_admde_int.batch_id%TYPE,
      p_interface_run_id        IN       igs_ad_admde_int.interface_run_id%TYPE,
      p_interface_mkdes_id      IN       igs_ad_admde_int.interface_mkdes_id%TYPE,
      p_error_message           OUT NOCOPY      fnd_new_messages.message_text%TYPE,
      p_return_status           OUT NOCOPY      VARCHAR2,
      p_ucas_transaction    IN VARCHAR2,
      p_reconsideration     IN VARCHAR2,
      p_prpsd_commencement_date   IN  igs_ad_admde_int_all.prpsd_commencement_date%TYPE
   )
   IS
  ------------------------------------------------------------------
  -- Created by  : rrengara, Oracle India (in)
  -- Date created:  14-AUG-2001
  --
  -- Purpose: to import the outcome status of the application.
  --
  --
  -- Known limitations/enhancements and/or remarks:
  --
  -- Change History:
  -- Who         When            What
  -- samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
  -- kamohan  16-SEP-2002         Bug # 2550009 Changed the procedure defnition with
  --                                              addition of p_ucas_transaction parameter
  -- rghosh     18-Jun-2003       Bug#2860852(Request for reconsideration import enhancement) added the parameter p_reconsideration
  -- rboddu     11/17/2003        Added p_prpsd_commencement_date. Bug:3181590
  -------------------------------------------------------------------


      l_decision_make_id     igs_ad_ps_appl_inst.decision_make_id%TYPE;
      l_decision_date        igs_ad_ps_appl_inst.decision_date%TYPE;
      l_decision_reason_id   igs_ad_ps_appl_inst.decision_reason_id%TYPE;
      l_pending_reason_id    igs_ad_ps_appl_inst.pending_reason_id%TYPE;
      l_offer_dt             igs_ad_ps_appl_inst.offer_dt%TYPE;
      l_offer_response_dt    igs_ad_ps_appl_inst.offer_response_dt%TYPE;
      l_adm_offer_resp_status igs_ad_ps_appl_inst.adm_offer_resp_status%TYPE;
      l_adm_cndtl_offer_status         igs_ad_ps_appl_inst.adm_cndtnl_offer_status%TYPE;
      l_sqlerrm              VARCHAR2(2000);

    CURSOR c_appl_cur IS
      SELECT a.ROWID, a.*
        FROM IGS_AD_APPL a
       WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number;
    l_c_appl_cur c_appl_cur%ROWTYPE;

    CURSOR c_aplinst_cur IS
      SELECT a.ROWID, a.*, b.req_for_reconsideration_ind
        FROM igs_ad_ps_appl_inst a, IGS_AD_PS_APPL b
       WHERE a.person_id = p_person_id
         AND a.admission_appl_number = p_admission_appl_number
         AND a.nominated_course_cd = p_nominated_course_cd
         AND a.sequence_number = p_sequence_number
	 AND a.person_id = b.person_id
  	 AND a.admission_appl_number = b.admission_appl_number
	 AND a.nominated_course_cd = b.nominated_course_cd;

      l_c_aplinst_cur               c_aplinst_cur%ROWTYPE;



      CURSOR c_apcs (
          cp_admission_cat          IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
          cp_s_admission_process_type       IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
        SELECT
	  'Y'
        FROM
	  IGS_AD_PRCS_CAT_STEP
        WHERE
	  admission_cat = cp_s_admission_process_type
	  AND s_admission_process_type = cp_s_admission_process_type
	  AND s_admission_step_type = 'PRE-ENROL'
	  AND step_group_type <> 'TRACK' ;

       -- cursor to fetch the values from the table igs_ad_ps_appl which are passed while calling
       -- igs_ad_ps_appl_pkg.update_row (rghosh -- bug#2860860)

       CURSOR c_ps_appl_cur IS
         SELECT a.*
         FROM igs_ad_ps_appl a
         WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number
         AND nominated_course_cd = p_nominated_course_cd;

    -- cursor to get the offer response status
    CURSOR c_adm_ofr_resp_stat_cur IS
         SELECT a.adm_offer_resp_status
         FROM igs_ad_ps_appl_inst a
         WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number
         AND nominated_course_cd = p_nominated_course_cd
         AND sequence_number = p_sequence_number;

        l_c_ps_appl_cur      c_ps_appl_cur%ROWTYPE;
        l_req_for_reconsideration_ind igs_ad_ps_appl.req_for_reconsideration_ind%TYPE;
        l_prpsd_commencement_dt igs_ad_ps_appl_inst.prpsd_commencement_dt%TYPE;
        l_actual_response_dt igs_ad_ps_appl_inst.actual_response_dt%TYPE;
        l_cur_msg_count NUMBER;
        l_max_msg_count NUMBER;
        l_msg_index_out NUMBER;
        l_app_name VARCHAR2(2000);

	l_pre_enroll VARCHAR2(2);
	v_message_name VARCHAR2(2000);
        v_warn_level   VARCHAR2(2000);

    -- cursor to get whether APC step of RECONSIDER is attached to the given APC (rghosh bug#2860852 - Request for Reconsideration Import)
    CURSOR c_check_reconsider (cp_admission_cat IGS_AD_PRCS_CAT_STEP.ADMISSION_CAT%TYPE,
                               cp_s_admission_process_type IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
      SELECT 'X'
      FROM IGS_AD_PRCS_CAT_STEP
      WHERE admission_cat = cp_admission_cat
      AND s_admission_process_type = cp_s_admission_process_type
      AND s_admission_step_type = 'RECONSIDER';

    l_check_reconsider VARCHAR2(1);
    l_uc_tran_id igs_uc_transactions.uc_tran_id%TYPE;
    l_error_msg FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_err_msg FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_return_status VARCHAR2(1);
    l_msg_data VARCHAR2(2000);
    l_msg_count NUMBER;

  BEGIN

  -- Check whether any application is available in OSS to update outcome status
  -- if the corresponding application is not there , then update the interface record with appropriate error code
     OPEN c_appl_cur;
     FETCH c_appl_cur INTO l_c_appl_cur;
     CLOSE c_appl_cur;

    OPEN c_aplinst_cur;
    FETCH c_aplinst_cur
      INTO l_c_aplinst_cur;
    CLOSE c_aplinst_cur;

     IF l_c_aplinst_cur.person_id IS NULL THEN
       fnd_message.set_name('IGS','IGS_AD_DECISION_DTLS_INVALID');  -- Replaced error_code with error_msg Bug 3297241
       l_err_msg :=  fnd_message.get;
       update_int_table ('3', l_err_msg, p_interface_mkdes_id, p_adm_outcome_status);
       p_error_message := l_err_msg;
       p_return_status := 'FALSE';
       RETURN;
     END IF;

      -- Resolve the Decision, Offer Values given by the user
      validate_set_decision_details (
         p_batch_id=> p_batch_id,
         p_interface_mkdes_id=> p_interface_mkdes_id,
         p_person_id => p_person_id,
         p_acad_cal_type => NVL(p_acad_cal_type,l_c_appl_cur.acad_cal_type),
         p_acad_ci_sequence_number =>  NVL(p_acad_ci_sequence_number,l_c_appl_cur.acad_ci_sequence_number),
         p_adm_cal_type => NVL(p_adm_cal_type,l_c_appl_cur.adm_cal_type),
         p_adm_ci_sequence_number  => NVL(p_adm_ci_sequence_number,l_c_appl_cur.adm_ci_sequence_number),
         p_admission_cat => NVL(p_admission_cat,l_c_appl_cur.admission_cat),
         p_s_admission_process_type =>  NVL(p_s_admission_process_type,l_c_appl_cur.s_admission_process_type),
         p_s_adm_outcome_status=> p_s_adm_outcome_status,
         p_decision_make_id=> l_decision_make_id,
         p_decision_date=> l_decision_date,
         p_decision_reason_id=> l_decision_reason_id,
         p_pending_reason_id=> l_pending_reason_id,
         p_offer_dt=> l_offer_dt,
         p_offer_response_dt=> l_offer_response_dt,
         p_error_msg=> l_error_msg,  -- Replaced error_code with error_msg Bug 3297241
         p_return_status=> l_return_status,
	       p_prpsd_commencement_date => p_prpsd_commencement_date
      );
      IF UPPER (l_return_status) = 'FALSE'
      THEN
         fnd_message.set_name('IGS',l_error_msg);  -- Replaced error_code with error_msg Bug 3297241
         l_error_msg :=  fnd_message.get;
         update_int_table ('3', l_error_msg, p_interface_mkdes_id, p_adm_outcome_status);
         p_error_message := l_error_msg;
         p_return_status := l_return_status;
         RETURN;
      END IF;



      IF p_s_adm_outcome_status IN ('OFFER', 'COND-OFFER')
      THEN
         l_pending_reason_id := NULL;
      ELSIF p_s_adm_outcome_status IN ('PENDING')
      THEN
         l_offer_dt := NULL;
         l_offer_response_dt := NULL;
         l_decision_reason_id := NULL;
         l_decision_make_id := NULL;
         l_decision_date := NULL;
      ELSE
         l_offer_dt := NULL;
         l_offer_response_dt := NULL;
         l_pending_reason_id := NULL;
      END IF;

        l_prpsd_commencement_dt := l_c_aplinst_cur.prpsd_commencement_dt;
        l_actual_response_dt := l_c_aplinst_cur.actual_response_dt;


	   l_cur_msg_count := igs_ge_msg_stack.count_msg;

        IGS_AdmApplication_PUB.Record_Outcome_AdmApplication(
	  p_api_version        =>  1.0,
	  p_init_msg_list      =>   FND_API.G_TRUE,
	  p_commit	       =>   FND_API.G_FALSE,
	  p_validation_level   =>   FND_API.G_VALID_LEVEL_FULL,


	  p_person_id          =>     l_c_aplinst_cur.person_id,
	  p_admission_appl_number =>  l_c_aplinst_cur.admission_appl_number,
	  p_nominated_program_cd   =>  l_c_aplinst_cur.nominated_course_cd,
	  p_sequence_number       =>  l_c_aplinst_cur.sequence_number,
	  p_adm_outcome_status    =>  p_adm_outcome_status,
	  p_decision_maker_id      =>  l_decision_make_id,
	  p_decision_date         =>  l_decision_date,
	  p_decision_reason_id    =>  l_decision_reason_id,
	  p_pending_reason_id     =>  l_pending_reason_id,
	  p_offer_dt              =>  l_offer_dt,
	  p_offer_response_dt     =>  l_offer_response_dt,
	  p_reconsider_flag       =>  p_reconsideration,
	  p_prpsd_commencement_date => l_prpsd_commencement_dt,
	  p_ucas_transaction       =>  p_ucas_transaction,

	  x_return_status	   =>	l_return_status,
	  x_msg_count		   =>   l_msg_count,
	  x_msg_data		   =>  l_msg_data
         );



       IF l_return_status IN ('E','U')  THEN
     	 update_int_table ('3', l_msg_data, p_interface_mkdes_id, p_adm_outcome_status);
         p_error_message := l_sqlerrm;
         p_return_status := 'FALSE';
       ELSE
       UPDATE igs_ad_admde_int_all
       SET status = '1'
       WHERE interface_mkdes_id = p_interface_mkdes_id;
       p_return_status := 'TRUE';
       END IF;


   EXCEPTION WHEN OTHERS THEN
     l_sqlerrm := SQLERRM;

     UPDATE igs_ad_admde_int SET status = '3', error_text = l_sqlerrm  WHERE interface_mkdes_id = p_interface_mkdes_id;
     p_error_message := l_sqlerrm;
     p_return_status := 'FALSE';
     RETURN;

   END prc_adm_outcome_status;

PROCEDURE import_adm_decision (
	      p_batch_id 		    IN	igs_ad_batc_def_det_all.batch_id%TYPE,
      	      p_ucas_transaction            IN    VARCHAR2,
              p_message_name                OUT NOCOPY VARCHAR2,
              p_msg_token_rec_prc_cnt       OUT NOCOPY NUMBER
        ) IS

   l_msg_token_rec_prc_cnt NUMBER := 0;
   l_processed_records     NUMBER := 0;
   l_return_status         VARCHAR2(30);

   CURSOR c_batc_def_det IS
     SELECT *
     FROM   igs_ad_batc_def_det_all    abdd
     WHERE  batch_id = p_batch_id AND
     ( (abdd.ACAD_CAL_TYPE IS NULL AND
        abdd.ACAD_CI_SEQUENCE_NUMBER IS NULL AND
        abdd.ADM_CAL_TYPE  IS NULL AND
        abdd.ADM_CI_SEQUENCE_NUMBER IS NULL AND
        abdd.ADMISSION_CAT IS NULL AND
        abdd.S_ADMISSION_PROCESS_TYPE IS NULL)
      OR
       (abdd.ACAD_CAL_TYPE IS NOT NULL AND
        abdd.ACAD_CI_SEQUENCE_NUMBER IS NOT NULL AND
        abdd.ADM_CAL_TYPE  IS NOT NULL AND
        abdd.ADM_CI_SEQUENCE_NUMBER IS NOT NULL AND
        abdd.ADMISSION_CAT IS NOT NULL AND
        abdd.S_ADMISSION_PROCESS_TYPE IS NOT NULL) ) ;

   CURSOR c_admde_int IS
     SELECT mdi.*
     FROM   igs_ad_admde_int_all mdi, igs_ad_batc_def_det_all abdd
     WHERE  mdi.batch_id = p_batch_id
     AND mdi.batch_id = abdd.batch_id
     AND    EXISTS ( SELECT  1
	     FROM igs_ad_ps_appl_inst aplinst, igs_ad_appl appl
	     WHERE aplinst.person_id = appl.person_id
	     AND  aplinst.admission_appl_number = appl.admission_appl_number
	     AND  aplinst.person_id = mdi.person_id
	     AND  aplinst.admission_appl_number = mdi.admission_appl_number
	     AND  aplinst.nominated_course_cd = mdi.nominated_course_cd
	     AND  aplinst.sequence_number = mdi.sequence_number
             AND  ( (abdd.ACAD_CAL_TYPE IS NULL
                  AND abdd.ACAD_CI_SEQUENCE_NUMBER IS NULL
                  AND abdd.ADM_CAL_TYPE  IS NULL
                  AND abdd.ADM_CI_SEQUENCE_NUMBER IS NULL
                  AND abdd.ADMISSION_CAT IS NULL
                  AND abdd.S_ADMISSION_PROCESS_TYPE IS NULL)
	     OR  appl.ACAD_CAL_TYPE = abdd.ACAD_CAL_TYPE
             AND  appl.ACAD_CI_SEQUENCE_NUMBER = abdd.ACAD_CI_SEQUENCE_NUMBER
	     AND  NVL(aplinst.ADM_CAL_TYPE, appl.ADM_CAL_TYPE) = abdd.ADM_CAL_TYPE
	     AND  NVL(aplinst.ADM_CI_SEQUENCE_NUMBER,   appl.ADM_CI_SEQUENCE_NUMBER ) = abdd.ADM_CI_SEQUENCE_NUMBER
	     AND  appl.ADMISSION_CAT = abdd.ADMISSION_CAT
	     AND  appl.S_ADMISSION_PROCESS_TYPE = abdd.S_ADMISSION_PROCESS_TYPE /*2*/) /*1*/)
     AND    status = '2';

   CURSOR c_old_adm_outcome_status (
      cp_person_id               IN       igs_pe_person.person_id%TYPE,
      cp_admission_appl_number   IN       igs_ad_appl.admission_appl_number%TYPE,
      cp_nominated_course_cd     IN       igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
      cp_sequence_number         IN       igs_ad_ps_appl_inst.sequence_number%TYPE
   ) IS
     SELECT adm_outcome_status
     FROM   igs_ad_ps_appl_inst
     WHERE  person_id = cp_person_id
     AND    admission_appl_number = cp_admission_appl_number
     AND    nominated_course_cd = cp_nominated_course_cd
     AND    sequence_number = cp_sequence_number;

   l_old_adm_outcome_status igs_ad_ps_appl_inst_all.adm_outcome_status%TYPE;
   l_error_msg fnd_new_messages.message_text%TYPE;

  BEGIN
    DECLARE
      l_gather_status VARCHAR2(5);
      l_industry      VARCHAR2(5);
      l_schema        VARCHAR2(30);
      l_gather_return BOOLEAN;
    BEGIN
      l_gather_return := fnd_installation.get_app_info('IGS', l_gather_status, l_industry, l_schema);
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_BATC_DEF_DET', cascade => TRUE);
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_ADMDE_INT', cascade => TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

   FOR c_batc_def_det_rec IN c_batc_def_det
   LOOP
      FOR c_admde_int_rec IN c_admde_int
      LOOP
        l_msg_token_rec_prc_cnt := l_msg_token_rec_prc_cnt + 1;
        l_processed_records := l_processed_records + 1;
        -- Ensured call to igs_ad_imp_adm_des.prc_adm_outcome_status
        -- do not result in code flow to EXCEPTION section in calling procedure
        -- variable l_return_status determines success or failure of the process

        OPEN c_old_adm_outcome_status (
                  c_admde_int_rec.person_id,
                  c_admde_int_rec.admission_appl_number,
                  c_admde_int_rec.nominated_course_cd,
                  c_admde_int_rec.sequence_number);
	FETCH c_old_adm_outcome_status INTO l_old_adm_outcome_status;
	CLOSE c_old_adm_outcome_status;



	igs_ad_imp_adm_des.prc_adm_outcome_status(
        	      p_person_id 			=> c_admde_int_rec.person_id,
        	      p_admission_appl_number 		=> c_admde_int_rec.admission_appl_number,
        	      p_nominated_course_cd 		=> c_admde_int_rec.nominated_course_cd,
        	      p_sequence_number 		=> c_admde_int_rec.sequence_number,
                      p_adm_outcome_status 		=> c_admde_int_rec.adm_outcome_status,
        	      p_s_adm_outcome_status		=> igs_ad_gen_008.admp_get_saos(c_admde_int_rec.adm_outcome_status),
        	      p_acad_cal_type 			=> c_batc_def_det_rec.acad_cal_type,
        	      p_acad_ci_sequence_number 	=> c_batc_def_det_rec.acad_ci_sequence_number,
        	      p_adm_cal_type 			=> c_batc_def_det_rec.adm_cal_type,
        	      p_adm_ci_sequence_number 		=> c_batc_def_det_rec.adm_ci_sequence_number,
        	      p_admission_cat 			=> c_batc_def_det_rec.admission_cat,
        	      p_s_admission_process_type 	=> c_batc_def_det_rec.s_admission_process_type,
        	      p_batch_id 			=> c_batc_def_det_rec.batch_id,
        	      p_interface_run_id 		=> c_admde_int_rec.interface_run_id,
        	      p_interface_mkdes_id 		=> c_admde_int_rec.interface_mkdes_id,
        	      p_error_message 			=> l_error_msg,  -- Replaced error_code with error_msg Bug 3297241
        	      p_return_status 			=> l_return_status,
              	      p_ucas_transaction                => p_ucas_transaction,
        	      p_reconsideration                 => c_admde_int_rec.reconsider_flag,
		      p_prpsd_commencement_date         => c_admde_int_rec.prpsd_commencement_date
        );

/*          -- Application Decision got imported successfully
          -- Raise the business event
	  -- Changes to the logic of raising the business event is done as part of Financial Aid Integration buid - 3202866
          IF l_old_adm_outcome_status <> c_admde_int_rec.adm_outcome_status
	    AND NVL(l_return_status,'TRUE') <> 'FALSE' THEN

              igs_ad_wf_001.wf_raise_event(
                          p_person_id => c_admde_int_rec.person_id,
		          p_raised_for => 'IOD',
                          p_admission_appl_number => c_admde_int_rec.admission_appl_number,
                          p_nominated_course_cd => c_admde_int_rec.nominated_course_cd,
                          p_sequence_number => c_admde_int_rec.sequence_number,
                          p_old_outcome_status => l_old_adm_outcome_status,
                          p_new_outcome_status => c_admde_int_rec.adm_outcome_status
        		 );
	  END IF;
  */
          IF l_processed_records = 100 THEN
            COMMIT;
            l_processed_records := 0;
          END IF;
    END LOOP;

    IF l_msg_token_rec_prc_cnt > 0 THEN
          p_message_name := 'IGS_AD_PROCESS_N_RECORDS';
          p_msg_token_rec_prc_cnt := l_msg_token_rec_prc_cnt;

          DELETE FROM igs_ad_admde_int_all
          WHERE  batch_id = p_batch_id
          AND    status = '1';
          COMMIT;

    END IF;
   END LOOP;
END import_adm_decision;


 PROCEDURE discard_adm_decision (
	      p_batch_id 		    IN	igs_ad_batc_def_det_all.batch_id%TYPE,
              p_message_name                OUT NOCOPY VARCHAR2,
              p_msg_token_rec_prc_cnt       OUT NOCOPY NUMBER
        ) IS

    l_msg_token_rec_prc_cnt NUMBER := 0;
    l_processed_records     NUMBER := 0;

    CURSOR c_admde_int IS
      SELECT *
      FROM   igs_ad_admde_int_all
      WHERE  batch_id = p_batch_id
      AND    status = '2';

    BEGIN
      FOR c_admde_int_rec IN c_admde_int
      LOOP
        l_msg_token_rec_prc_cnt := l_msg_token_rec_prc_cnt + 1;
        l_processed_records := l_processed_records + 1;

       	DELETE FROM igs_ad_admde_int_all
        WHERE interface_mkdes_id = c_admde_int_rec.interface_mkdes_id;

        IF l_processed_records = 100 THEN
          COMMIT;
          l_processed_records := 0;
        END IF;
      END LOOP;

      IF l_msg_token_rec_prc_cnt > 0 THEN
        p_message_name := 'IGS_AD_DELETE_N_RECORDS';
        p_msg_token_rec_prc_cnt := l_msg_token_rec_prc_cnt;
        COMMIT;
      END IF;

END discard_adm_decision;

END igs_ad_imp_adm_des;

/
