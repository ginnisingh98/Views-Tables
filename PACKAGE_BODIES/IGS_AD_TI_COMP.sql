--------------------------------------------------------
--  DDL for Package Body IGS_AD_TI_COMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TI_COMP" AS
/* $Header: IGSADA3B.pls 120.4 2006/04/25 04:17:09 rghosh ship $ */

  FUNCTION upd_trk_step_complete (
                                   p_tracking_id igs_tr_step.tracking_id%TYPE,
                                   p_tracking_step_id igs_tr_step.tracking_step_id%TYPE,
                                   p_s_tracking_step_type igs_tr_step.s_tracking_step_type%TYPE,
                                   p_recipient_id igs_tr_step.recipient_id%TYPE) RETURN BOOLEAN

  IS
      l_message_name             VARCHAR2(30);
   BEGIN
   IF igs_tr_gen_002.trkp_upd_trst(
                                   p_tracking_id,
                                   p_tracking_step_id,
                                   p_s_tracking_step_type,
                                   NULL,
                                   SYSDATE,
                                   'Y',
                                   NULL,
                                   p_recipient_id,
                                   l_message_name
                                  )
   THEN
     -- Tracking Step Update to complete Successful
     FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_STP_SUCFL');
     FND_MESSAGE.SET_TOKEN('TRID', p_tracking_id);
     FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
     RETURN TRUE ;
   ELSE
     -- Tracking Step Update to complete Failed
     FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_STP_NT_SUCFL');
     FND_MESSAGE.SET_TOKEN('TRID', p_tracking_id);
     FND_MESSAGE.SET_TOKEN('STPID', p_tracking_step_id);
     FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET() );
     FND_MESSAGE.SET_NAME('IGS', l_message_name);
     FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
     RETURN FALSE;
     END IF;
  END upd_trk_step_complete ;

  FUNCTION upd_trk_stp_cp(
                           p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE,
                           p_admission_appl_number     IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                           p_course_cd                 IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                           p_sequence_number           IN   igs_ad_ps_appl_inst.sequence_number%TYPE,
                           p_tracking_id               IN   igs_tr_step.tracking_id%TYPE,
                           p_tracking_step_id          IN   igs_tr_step.tracking_step_id%TYPE,
                           p_s_tracking_step_type      IN   igs_tr_step.s_tracking_step_type%TYPE,
                           p_recipient_id              IN   igs_tr_step.recipient_id%TYPE
                          ) RETURN BOOLEAN AS
   /*
   ||  Created By : brajendr
   ||  Created On :
   ||  Purpose :  This Function Checks for Completion of all the Tracking Steps for Each Tracking Item.
   ||  Known limitations, enhancements or remarks :
   ||  Change History :
   ||  Who             When            What
   ||  (reverse chronological order - newest change first)
   ||  hreddych   09-OCT-2002 #2602077 Added a new case for Enrollment Deposit
   ||  vdixit          07-Jan-2002     Changes pertaining to 2152871 enh.
   */


  CURSOR cur_enrolment_deposit (p_person_id igs_ad_app_req.person_id%TYPE,
         p_admission_appl_number igs_ad_app_req.admission_appl_number%TYPE) IS
          SELECT DISTINCT 1
	  FROM   igs_ad_app_req
	  WHERE  admission_appl_number = p_admission_appl_number
	  AND    person_id	= p_person_id
	  AND    applicant_fee_type IN (SELECT code_id
					FROM  igs_ad_code_classes
					WHERE class = 'SYS_FEE_TYPE'
					AND   system_status IN ('ENROLL_DEPOSIT')
					AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	  AND    applicant_fee_status IN (SELECT code_id
					  FROM igs_ad_code_classes
					  WHERE class = 'SYS_FEE_STATUS'
					  AND system_status IN ('PAID','WAIVED')
					  AND CLASS_TYPE_CODE='ADM_CODE_CLASSES');

    -- Get all the Credential details for each application of the Person.
    CURSOR cur_credentials(
                           p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE ,
			   p_tracking_id               IN   igs_tr_step.tracking_id%TYPE,
			   p_tracking_step_id          IN   igs_tr_step.tracking_step_id%TYPE
                          ) IS
          SELECT DISTINCT 1
           FROM  igs_pe_credentials pc,
                 igs_ad_cred_types act,
                 igs_tr_step ts
          WHERE  pc.person_id = p_person_id
            AND  act.credential_type_id = pc.credential_type_id
            AND  ts.step_catalog_cd = act.step_code
            AND  ts.tracking_id = p_tracking_id
            AND  ts.tracking_step_id = p_tracking_step_id;

    -- Get all the Test details for each application of the Person.
    CURSOR cur_test(
                    p_person_id     IN   igs_ad_ps_appl_inst.person_id%TYPE  ,
		    p_tracking_id IN 	igs_tr_step.tracking_id%TYPE,
		    p_tracking_step_id IN     igs_tr_step.tracking_step_id%TYPE
                   ) IS
        SELECT DISTINCT 1
	FROM  igs_ad_test_results atr,
	      igs_ad_test_type att,
	      igs_tr_step ts
	WHERE ts.tracking_id = p_tracking_id
	AND   ts.tracking_step_id = p_tracking_step_id
	AND   att.step_code =ts.step_catalog_cd
	AND   atr.admission_test_type = att.admission_test_type
	AND   atr.person_id =p_person_id ;

    -- Get all the Education details for each application of the Person.

    CURSOR cur_trans      ( p_person_id   IN   igs_ad_ps_appl_inst.person_id%TYPE ) IS
       SELECT DISTINCT institution_code,
                       degree_attempted,
       		             degree_earned
       FROM   igs_ad_acad_history_v
       WHERE  person_id = p_person_id
       AND    transcript_required = 'Y'
       AND    status = 'A' ;


     -- Get all the transacript details for each application of the Person where the status is FINAL.
     CURSOR cur_trans_final ( p_person_id   IN    igs_ad_acad_history_v.person_id%TYPE ,
                       p_institution_code IN  igs_ad_acad_history_v.institution_code%TYPE,
                       p_degree_attempted IN igs_ad_acad_history_v.degree_attempted%TYPE,
                       p_degree_earned IN igs_ad_acad_history_v.degree_earned%TYPE ) IS
       SELECT DISTINCT 1
       FROM   igs_ad_acad_history_v a
       WHERE  person_id= p_person_id
       AND    institution_code =  p_institution_code
       AND    NVL(degree_attempted,NVL(p_degree_attempted,'*')) = NVL(p_degree_attempted,'*')
       AND    NVL(degree_earned,NVL(p_degree_earned,'*')) = NVL(p_degree_earned,'*')
       AND    status = 'A'
       AND    exists (
                      SELECT 'x'
                      FROM   igs_ad_transcript c
                      WHERE  c.education_id = a.education_id
                      AND    c.transcript_status  = 'FINAL'
                      AND    c.transcript_type ='OFFICIAL');

     -- Get all the transacript details for each application of the Person where the status is PARTIAL or FINALL.
     CURSOR cur_trans_partial(p_person_id   IN    igs_ad_acad_history_v.person_id%TYPE ,
                       p_institution_code IN  igs_ad_acad_history_v.institution_code%TYPE,
                       p_degree_attempted IN igs_ad_acad_history_v.degree_attempted%TYPE,
                       p_degree_earned IN igs_ad_acad_history_v.degree_earned%TYPE ) IS
       SELECT DISTINCT 1
       FROM   igs_ad_acad_history_v a
       WHERE  person_id = p_person_id
       AND    institution_code=  p_institution_code
       AND    NVL(degree_attempted,NVL(p_degree_attempted,'*')) = NVL(p_degree_attempted,'*')
       AND    NVL(degree_earned,NVL(p_degree_earned,'*')) = NVL(p_degree_earned,'*')
       AND    status = 'A'
       AND    exists (
                      SELECT 'x'
                      FROM   igs_ad_transcript c
                      WHERE  c.education_id = a.education_id
                      AND    c.transcript_status IN ('FINAL','PARTIAL')
                      AND    c.transcript_type ='OFFICIAL');

       -- Get all the transacript details for each application of the Person where the status is FINAL and type UNOFFICIAL.
     CURSOR cur_trans_final_unofficial ( p_person_id   IN    igs_ad_acad_history_v.person_id%TYPE ,
                       p_institution_code IN  igs_ad_acad_history_v.institution_code%TYPE,
                       p_degree_attempted IN igs_ad_acad_history_v.degree_attempted%TYPE,
                       p_degree_earned IN igs_ad_acad_history_v.degree_earned%TYPE ) IS
       SELECT DISTINCT 1
       FROM   igs_ad_acad_history_v a
       WHERE  person_id = p_person_id
       AND    institution_code=  p_institution_code
       AND    NVL(degree_attempted,NVL(p_degree_attempted,'*')) = NVL(p_degree_attempted,'*')
       AND    NVL(degree_earned,NVL(p_degree_earned,'*')) = NVL(p_degree_earned,'*')
       AND    status = 'A'
       AND    exists (
                      SELECT 'x'
                      FROM   igs_ad_transcript c
                      WHERE  c.education_id = a.education_id
                      AND    c.transcript_status  = 'FINAL'
                      AND    c.transcript_type ='UNOFFICIAL');

     -- Get all the transacript details for each application of the Person where the status is PARTIAL or FINALL and type UNOFFICIAL.
     CURSOR cur_trans_partial_unofficial(p_person_id   IN    igs_ad_acad_history_v.person_id%TYPE ,
                       p_institution_code IN  igs_ad_acad_history_v.institution_code%TYPE,
                       p_degree_attempted IN igs_ad_acad_history_v.degree_attempted%TYPE,
                       p_degree_earned IN igs_ad_acad_history_v.degree_earned%TYPE ) IS
       SELECT DISTINCT 1
       FROM   igs_ad_acad_history_v a
       WHERE  person_id = p_person_id
       AND    institution_code=  p_institution_code
       AND    NVL(degree_attempted,NVL(p_degree_attempted,'*')) = NVL(p_degree_attempted,'*')
       AND    NVL(degree_earned,NVL(p_degree_earned,'*')) = NVL(p_degree_earned,'*')
       AND    status = 'A'
       AND    exists (
                      SELECT 'x'
                      FROM   igs_ad_transcript c
                      WHERE  c.education_id = a.education_id
                      AND    c.transcript_status IN ('FINAL','PARTIAL')
                      AND    c.transcript_type ='UNOFFICIAL');

    -- Get the Personal Statements for the person
    CURSOR cur_pers_statements(
                           p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE ,
                           p_admission_appl_number     IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE ,
			   p_tracking_id               IN   igs_tr_step.tracking_id%TYPE,
			   p_tracking_step_id          IN   igs_tr_step.tracking_step_id%TYPE
                          ) IS
           SELECT DISTINCT 1
            FROM  igs_ad_appl_perstat aaps,
                  igs_ad_per_stm_typ apst,
                  igs_tr_step ts
           WHERE  ts.tracking_id = p_tracking_id
             AND  ts.tracking_step_id = p_tracking_step_id
             AND  apst.step_catalog_cd =ts.step_catalog_cd
             AND  aaps.persl_stat_type =apst.persl_stat_type
             AND  aaps.person_id =p_person_id
             AND  aaps.admission_appl_number = p_admission_appl_number ;

    l_count                    NUMBER;
    l_message_name             VARCHAR2(30);
    tr_stp_fail_exp            EXCEPTION;
    tr_stp_no_records_exp      EXCEPTION;
    already_completed_exp      EXCEPTION;
    l_eid_records_not_found    BOOLEAN := TRUE;
    l_val1                     NUMBER;
    l_val2                     NUMBER;
    l_need_to_update           BOOLEAN := FALSE;


  BEGIN

    -- Create a SavePoint in order to process each Application.
    SAVEPOINT IGSADA3_SP1;

    -- Create a SavePoint in order to process each Application.
    -- Check for Completion of all the Tracking Steps if the Tracking Step Type is ENR_DEP
    IF p_s_tracking_step_type ='ENR_DEP' THEN

        -- If Enrollment Deposit records are not present in the system,
	-- then log a message and process the next Tracking Item in the Application.
	  OPEN cur_enrolment_deposit(p_person_id,p_admission_appl_number);
	  FETCH cur_enrolment_deposit INTO l_count;
	IF  cur_enrolment_deposit%NOTFOUND THEN
	    CLOSE cur_enrolment_deposit;
	    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_ENR_DPT_NT_PAID');
            FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
            RAISE tr_stp_no_records_exp;
        ELSE
	    CLOSE cur_enrolment_deposit;
             -- If Enrollment Deposit records are present, then update the status to COMPLETED
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
       END IF;  -- End of Processing all the Enrollment Deposit


    -- Check for Completion of all the Tracking Steps if the Tracking Step Type is CREDENTIAL
    ELSIF p_s_tracking_step_type ='CREDENTIAL' THEN

	OPEN cur_credentials( p_person_id,p_tracking_id,p_tracking_step_id);
	FETCH cur_credentials INTO l_count;
        -- If Credential records are not present in the system, then log a message and process the next Tracking Item in the Application.
	IF cur_credentials%NOTFOUND THEN
	  CLOSE cur_credentials;
	  FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_CRD_DTL_NT_EXISTS');
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
          RAISE tr_stp_no_records_exp;
        ELSE
	  CLOSE cur_credentials;
          -- If Credential records are present, then update the status to COMPLETED
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
        END IF;   -- End of Processing all the Credentials

    -- Check for Completion of all the Tracking Steps if the Tracking Step Type is TEST
    ELSIF p_s_tracking_step_type = 'TEST' THEN

	OPEN cur_test( p_person_id,p_tracking_id,p_tracking_step_id);
	FETCH cur_test INTO l_count;
        -- If Test records are not present in the system, then log a message and process the next Tracking Item in the Application.
	IF cur_test%NOTFOUND THEN
	  CLOSE cur_test;
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TST_DTL_NT_EXISTS');
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
          RAISE tr_stp_no_records_exp;
        ELSE
	  CLOSE cur_test;
          -- If Test records are present, then update the status to COMPLETED
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
        END IF;	  -- End of Processing all the Test

    -- Check for Completion of all the Tracking Steps if the Tracking Step Type is TRANS-PARTIAL or TRANS-FINAL
    -- ELSIF p_s_tracking_step_type IN ( 'TRANS-PARTIAL', 'TRANS-FINAL') THEN

    ELSIF p_s_tracking_step_type = 'TRANS-PARTIAL' THEN

      -- l_eid_records_not_found has FALSE when there are any educational details where transcripts
      -- are required.
       l_eid_records_not_found := TRUE ;
       l_need_to_update := FALSE;

      FOR cur_trans_rec IN cur_trans( p_person_id) LOOP

	    l_eid_records_not_found := FALSE ;
            OPEN cur_trans_partial ( p_person_id,
	                             cur_trans_rec.institution_code,
				     cur_trans_rec.degree_attempted,
				     cur_trans_rec.degree_earned ) ;
            FETCH cur_trans_partial INTO l_val1 ;
	    IF cur_trans_partial%FOUND THEN
               l_need_to_update := TRUE;
	    ELSE
               l_need_to_update := FALSE;
	       EXIT ;
	    END IF;
	    CLOSE cur_trans_partial;
      END LOOP;
        IF (l_eid_records_not_found = TRUE) THEN
          -- The tracking items are yet to be created for this application so the tracking items completion cannot take place.
          -- Message ('Tracking items do not exist for this application');
          l_need_to_update := FALSE;
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_EID_NT_FND');
          FND_MESSAGE.SET_TOKEN('TRID', p_tracking_id);
          FND_MESSAGE.SET_TOKEN('STPID', p_tracking_step_id);
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
        END IF;
        IF  l_need_to_update THEN
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
        END IF;  -- Check whether the Trackings need to get updated or not.

    ELSIF p_s_tracking_step_type = 'TRANS-FINAL' THEN

      -- l_eid_records_not_found has FALSE when there are any educational details where transcripts
      -- are required.
       l_eid_records_not_found := TRUE ;
       l_need_to_update := FALSE;

      FOR cur_trans_rec IN cur_trans( p_person_id) LOOP
	    l_eid_records_not_found := FALSE ;
            OPEN cur_trans_final ( p_person_id,
	                           cur_trans_rec.institution_code,
				   cur_trans_rec.degree_attempted,
				   cur_trans_rec.degree_earned ) ;
            FETCH cur_trans_final INTO l_val1 ;
	    IF cur_trans_final%FOUND THEN
               l_need_to_update := TRUE;
	    ELSE
               l_need_to_update := FALSE;
	       EXIT;
	    END IF;
	    CLOSE cur_trans_final;
      END LOOP;

        IF l_eid_records_not_found THEN
          -- The tracking items are yet to be created for this application so the tracking items completion cannot take place.
          -- Message ('Tracking items do not exist for this application');
          l_need_to_update := FALSE;
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_EID_NT_FND');
          FND_MESSAGE.SET_TOKEN('TRID', p_tracking_id);
          FND_MESSAGE.SET_TOKEN('STPID', p_tracking_step_id);
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
        END IF;
        IF  l_need_to_update THEN
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
        END IF;  -- Check whether the Trackings need to get updated or not.

 -- Check for Completion of all the Tracking Steps if the Tracking Step Type is TRANS-PARTIAL or TRANS-FINAL
    -- ELSIF p_s_tracking_step_type IN ( 'TRANS-PART-U', 'TRANS-FINAL-U') THEN

    ELSIF p_s_tracking_step_type = 'TRANS-PART-U' THEN

      -- l_eid_records_not_found has FALSE when there are any educational details where transcripts
      -- are required.
       l_eid_records_not_found := TRUE ;
       l_need_to_update := FALSE;

      FOR cur_trans_rec IN cur_trans( p_person_id) LOOP

	    l_eid_records_not_found := FALSE ;
            OPEN cur_trans_partial_unofficial ( p_person_id,
	                             cur_trans_rec.institution_code,
				     cur_trans_rec.degree_attempted,
				     cur_trans_rec.degree_earned ) ;
            FETCH cur_trans_partial_unofficial INTO l_val1 ;
	    IF cur_trans_partial_unofficial%FOUND THEN
               l_need_to_update := TRUE;
	    ELSE
               l_need_to_update := FALSE;
	       EXIT ;
	    END IF;
	    CLOSE cur_trans_partial_unofficial;
      END LOOP;
        IF (l_eid_records_not_found = TRUE) THEN
          -- The tracking items are yet to be created for this application so the tracking items completion cannot take place.
          -- Message ('Tracking items do not exist for this application');
          l_need_to_update := FALSE;
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_EID_NT_FND');
          FND_MESSAGE.SET_TOKEN('TRID', p_tracking_id);
          FND_MESSAGE.SET_TOKEN('STPID', p_tracking_step_id);
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
        END IF;
        IF  l_need_to_update THEN
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
        END IF;  -- Check whether the Trackings need to get updated or not.

    ELSIF p_s_tracking_step_type = 'TRANS-FINAL-U' THEN

      -- l_eid_records_not_found has FALSE when there are any educational details where transcripts
      -- are required.
       l_eid_records_not_found := TRUE ;
       l_need_to_update := FALSE;

      FOR cur_trans_rec IN cur_trans( p_person_id) LOOP
	    l_eid_records_not_found := FALSE ;
            OPEN cur_trans_final_unofficial ( p_person_id,
	                           cur_trans_rec.institution_code,
				   cur_trans_rec.degree_attempted,
				   cur_trans_rec.degree_earned ) ;
            FETCH cur_trans_final_unofficial INTO l_val1 ;
	    IF cur_trans_final_unofficial%FOUND THEN
               l_need_to_update := TRUE;
	    ELSE
               l_need_to_update := FALSE;
	       EXIT;
	    END IF;
	    CLOSE cur_trans_final_unofficial;
      END LOOP;

        IF l_eid_records_not_found THEN
          -- The tracking items are yet to be created for this application so the tracking items completion cannot take place.
          -- Message ('Tracking items do not exist for this application');
          l_need_to_update := FALSE;
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_EID_NT_FND');
          FND_MESSAGE.SET_TOKEN('TRID', p_tracking_id);
          FND_MESSAGE.SET_TOKEN('STPID', p_tracking_step_id);
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
        END IF;
        IF  l_need_to_update THEN
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
        END IF;  -- Check whether the Trackings need to get updated or not.

    ELSIF p_s_tracking_step_type = 'PERSONAL_STATEMENT' THEN

      OPEN cur_pers_statements(p_person_id, p_admission_appl_number,p_tracking_id,p_tracking_step_id );
      FETCH cur_pers_statements INTO l_count;
      IF  cur_pers_statements%FOUND THEN
          CLOSE cur_pers_statements;
            IF  NOT upd_trk_step_complete ( p_tracking_id,
                                            p_tracking_step_id,
                                            p_s_tracking_step_type,
                                            p_recipient_id
                                           )
            THEN
                RAISE tr_stp_fail_exp;
            END IF;
      ELSE
          CLOSE cur_pers_statements;
      END IF;


    END IF;

    -- Once all the Tracking Steps are completed successfull, then return the TRUE to the Calling Procedure and COMMIT the transactions.
    -- If called from Job then commit , if called from SS skip commit
    IF NVL( IGS_AD_TI_COMP.G_CALLED_FROM, 'J') = 'J' THEN
      COMMIT;
    END IF;
    RETURN TRUE;

  EXCEPTION

    -- If Records are not found, then skip to the next Tracking Item in the Application Instance.
    WHEN tr_stp_no_records_exp THEN
      ROLLBACK TO IGSADA3_SP1;
      RETURN TRUE;

    -- Rollback all the transactions, If the Exception is RAISED while Processing the Tracking Steps of Application Tracking Items.
    WHEN tr_stp_fail_exp THEN
      ROLLBACK TO IGSADA3_SP1;
      RETURN FALSE;

    WHEN others THEN
      ROLLBACK TO IGSADA3_SP1;
      RETURN FALSE;

  END upd_trk_stp_cp;


  PROCEDURE get_incp_trstp(
                           p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE,
                           p_admission_appl_number     IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                           p_course_cd                 IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                           p_sequence_number           IN   igs_ad_ps_appl_inst.sequence_number%TYPE
                          ) AS
    /*
    ||  Created By : brajendr
    ||  Created On :
    ||  Purpose :  This Procedure Checks for Completion of all the Tracking Items for each Application Instances.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    -- Get all the Tracking Items for each Application of the Person.
    CURSOR cur_tr(
                  p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE,
                  p_admission_appl_number     IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                  p_course_cd                 IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                  p_sequence_number           IN   igs_ad_ps_appl_inst.sequence_number%TYPE
                 ) IS
    SELECT aa.tracking_id
      FROM igs_ad_aplins_admreq aa,
           igs_tr_item ti,
	   igs_tr_status ts
      WHERE aa.person_id             = p_person_id
        AND aa.admission_appl_number = p_admission_appl_number
        AND aa.sequence_number       = p_sequence_number
        AND aa.course_cd             = p_course_cd
        AND aa.tracking_id           = ti.tracking_id -- changes made
        AND ti.tracking_status = ts.tracking_status
        AND ts.s_tracking_status = 'ACTIVE' ; --  the tracking status should be mapped to system tracking status of 'ACTIVE'  ( rghosh, bug#2919317)

    -- Get all the Tracking Steps of Each Tracking Item.
    CURSOR cur_tr_stp(
                      p_tracking_id  igs_ad_aplins_admreq.tracking_id%TYPE
                     ) IS
      SELECT tracking_step_id, s_tracking_step_type, recipient_id
        FROM igs_tr_step ts
          WHERE ts.tracking_id = p_tracking_id
            AND ts.step_completion_ind='N'
            AND ts.by_pass_ind = 'N'
            AND ts.completion_dt IS NULL
          ORDER BY s_tracking_step_type;

    l_records_not_found        BOOLEAN := TRUE;
    l_stp_records_not_found    BOOLEAN := TRUE;

  BEGIN

    l_records_not_found := TRUE;
    FOR cur_tr_rec IN cur_tr( p_person_id, p_admission_appl_number, p_course_cd, p_sequence_number) LOOP
      l_records_not_found := FALSE;

      -- Process all the Tracking Items for each Tracking Step.
      l_stp_records_not_found := TRUE;

      FOR cur_tr_stp_rec IN cur_tr_stp( cur_tr_rec.tracking_id) LOOP
        -- For the tracking steps which are yet to be completed, call the  generic procedure which would check the tracking steps completion
        -- for the application instance and update the tracking steps in case the pre-requisite has been found in the admission tables. For the
        -- Tracking id steps found, fetch the tracking steps which are not completed and not by passed and the completion date has not been updated.
        l_stp_records_not_found := FALSE;
        IF upd_trk_stp_cp(
                          p_person_id,
                          p_admission_appl_number,
                          p_course_cd,
                          p_sequence_number,
                          cur_tr_rec.tracking_id,
                          cur_tr_stp_rec.tracking_step_id,
                          cur_tr_stp_rec.s_tracking_step_type,
                          cur_tr_stp_rec.recipient_id
                         ) = FALSE
        THEN
          -- If any of the Tracking ID's are Invalid, then process the next Application Instance.
          RETURN;
        END IF;
      END LOOP;  -- End of Each Tracking Item Steps.
      IF l_stp_records_not_found THEN
        -- The tracking items are yet to be created for this application so the tracking items completion cannot take place.
        -- Message ('Tracking items do not exist for this application');
        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_NO_TR_STPS');
        FND_MESSAGE.SET_TOKEN('TRID', cur_tr_rec.tracking_id);
        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

      END IF;

    END LOOP;

    IF l_records_not_found THEN
      -- The tracking items are yet to be created for this application so the tracking items completion cannot take place.
      -- Message ('Tracking items do not exist for this application');
      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_NO_TR_ITM');
      FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    END IF;

  EXCEPTION
    WHEN others THEN
      ROLLBACK;
  END get_incp_trstp;


 PROCEDURE upd_trk_itm_st(
                           ERRBUF                         OUT NOCOPY  VARCHAR2,
                           RETCODE                        OUT NOCOPY  NUMBER,
                           p_person_id                    IN   igs_ad_ps_appl_inst.person_id%TYPE,
                           p_person_id_group              IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
                           p_admission_appl_number        IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE,
                           p_course_cd                    IN   igs_ad_ps_appl_inst.course_cd%TYPE,
                           p_sequence_number              IN   igs_ad_ps_appl_inst.sequence_number%TYPE,
                           p_calendar_details             IN   VARCHAR2,
                           p_admission_process_category   IN   VARCHAR2,
                           p_org_id                       IN   igs_pe_prsid_grp_mem_all.org_id%TYPE
                          ) AS
    /*
    ||  Created By :
    ||  Created On :
    ||  Purpose    : This is a main Procedure which will check whether all the Tracking Items are COMPLETE or not.
    ||               This is getting called from the forms as well as a Concurrent Job.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    ||  hreddych   09-OCT-2002 #2602077 Added a new case where person_id and admission_appl_number are passed
    ||  rghosh      21-Oct-2003        Added the REF CURSOR c_dyn_pig_check and hence the
    ||                                                   logic for supporting dynamic Person ID Group
    ||                                                    (Enh# 3194295 , ADCR043: Person ID Group)
    */

    -- Get the all the Application Instances Details of the Person with parameters as
    -- p_person_id, p_admission_appl_number, p_course_cd and p_sequence_number.


   TYPE c_dyn_pig_checkCurTyp IS REF CURSOR;
   c_dyn_pig_check c_dyn_pig_checkCurTyp;
   TYPE  c_dyn_pig_checkrecTyp IS RECORD ( person_id igs_ad_ps_appl_inst_all.person_id%TYPE,
                                                                                     admission_appl_number igs_ad_ps_appl_inst_all.admission_appl_number%TYPE,
                                                                                     nominated_course_cd igs_ad_ps_appl_inst_all.nominated_course_cd%TYPE,
                                                                                     sequence_number igs_ad_ps_appl_inst_all.sequence_number%TYPE);
   c_dyn_pig_check_rec c_dyn_pig_checkrecTyp ;

   lv_status     VARCHAR2(1) := 'S';  /*Defaulted to 'S' and the function will return 'F' in case of failure */
   lv_sql_stmt   VARCHAR(32767);



CURSOR cur_appl_details(  p_person_id	 igs_ad_ps_appl_inst.person_id%TYPE,
        p_acad_cal_type  igs_ad_appl.acad_cal_type%TYPE,
			  p_adm_cal_type  igs_ad_appl.adm_cal_type%TYPE,
			  p_acad_ci_sequence_number  igs_ad_appl.acad_ci_sequence_number%TYPE,
			  p_adm_ci_sequence_number  igs_ad_appl.adm_ci_sequence_number%TYPE,
			  p_admission_cat  igs_ad_appl.admission_cat%TYPE,
			  p_s_admission_process_type  igs_ad_appl.s_admission_process_type%TYPE ,
			  p_admission_appl_number igs_ad_ps_appl_inst.admission_appl_number%TYPE	 ,
			  p_sequence_number  igs_ad_ps_appl_inst.sequence_number%TYPE )IS

SELECT
	apai.person_id,
	apai.admission_appl_number,
	apai.nominated_course_cd,
	apai.sequence_number
FROM
	igs_ad_ps_appl_inst apai,
	igs_ad_ou_stat aos,
	igs_ad_doc_stat ads,
	igs_ad_appl aa
WHERE
	apai.person_id = nvl(p_person_id,apai.person_id) AND
	aa.acad_cal_type = nvl(p_acad_cal_type,aa.acad_cal_type) AND
	aa.acad_ci_sequence_number = nvl(p_acad_ci_sequence_number,aa.acad_ci_sequence_number) AND
	aa.adm_cal_type = nvl(p_adm_cal_type,aa.adm_cal_type) AND
	aa.adm_ci_sequence_number = nvl(p_adm_ci_sequence_number,aa.adm_ci_sequence_number) AND
	aa.admission_cat = nvl(p_admission_cat,aa.admission_cat) AND
	aa.s_admission_process_type = nvl(p_s_admission_process_type,aa.s_admission_process_type) AND
	apai.nominated_course_cd = nvl(p_course_cd,apai.nominated_course_cd) AND
	apai.admission_appl_number = nvl(p_admission_appl_number,apai.admission_appl_number) AND
	apai.sequence_number = nvl(p_sequence_number,apai.sequence_number) AND
	aos.s_adm_outcome_status = 'PENDING' AND
	apai.adm_outcome_status = aos.adm_outcome_status AND
	ads.s_adm_doc_status = 'PENDING' AND
	apai.adm_doc_status = ads.adm_doc_status AND
	aa.person_id=apai.person_id AND
	aa.admission_appl_number = apai.admission_appl_number ;

   --Check whether there is any tracking associated for the person and Application Number
   CURSOR  cur_trk_exists(
                  p_person_id                 IN   igs_ad_ps_appl_inst.person_id%TYPE,
                  p_admission_appl_number     IN   igs_ad_ps_appl_inst.admission_appl_number%TYPE  ,
                  p_course_cd                 IN   igs_ad_aplins_admreq.course_cd%TYPE  ,
                  p_sequence_number           IN   igs_ad_aplins_admreq.sequence_number%TYPE  ) IS
    SELECT  1
      FROM  igs_ad_aplins_admreq aa,
            igs_tr_item ti,
 	   igs_tr_status ts
     WHERE aa.person_id             = p_person_id
        AND aa.admission_appl_number = p_admission_appl_number
	AND aa.course_cd             = p_course_cd
	AND aa.sequence_number       = p_sequence_number
        AND aa.tracking_id           = ti.tracking_id
	AND ti.tracking_status = ts.tracking_status
        AND ts.s_tracking_status = 'ACTIVE' ;  --  the tracking status should be mapped to system tracking status of 'ACTIVE'  ( rghosh, bug#2919317)

    l_acad_cal_type                igs_ca_inst_all.cal_type%TYPE;
    l_acad_ci_sequence_number      igs_ca_inst_all.sequence_number%TYPE;
    l_adm_cal_type                 igs_ca_inst_all.cal_type%TYPE;
    l_adm_ci_sequence_number       igs_ca_inst_all.sequence_number%TYPE;
    l_admission_cat                igs_ad_appl_all.admission_cat%TYPE;
    l_s_admission_process_type     igs_ad_appl_all.s_admission_process_type%TYPE;
    l_count                        NUMBER;
    l_records_not_found            BOOLEAN := TRUE;

    lv_group_type IGS_PE_PERSID_GROUP_V.group_type%TYPE;

  BEGIN

    -- Set the Org_id for the corresponding responsibility.
    igs_ge_gen_003.set_org_id( p_org_id);
    RETCODE := 0;
    ERRBUF  := NULL;
   lv_sql_stmt   :=  igs_pe_dynamic_persid_group.get_dynamic_sql(p_person_id_group,lv_status,lv_group_type);
    -- Log the Initial parameters into the LOG file.
    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_PRMS');
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

           -- Get the Academic Calander details form the Academic Calender Parameter
        l_acad_cal_type             := RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
        l_acad_ci_sequence_number   := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));

   -- if l_acad_sequence_number is NULL (ie, calendar details are not entered) then
   -- it is assigned a value of -1, if we keep it NULL then the value cannot be used while
   -- opening the REF CURSOR c_dyn_pig_check.

        IF l_acad_ci_sequence_number IS NULL THEN
          l_acad_ci_sequence_number := -1 ;
        END IF;

        -- Get the Admission Calander details form the Admission Calender Parameter
        l_adm_cal_type              := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
        l_adm_ci_sequence_number    := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));

   -- if l_adm_sequence_number is NULL (ie, calendar details are not entered) then
   -- it is assigned a value of -1, if we keep it NULL then the value cannot be used while
   -- opening the REF CURSOR c_dyn_pig_check.

       IF l_adm_ci_sequence_number IS NULL THEN
         l_adm_ci_sequence_number := -1;
       END IF;

        -- Get the Admission Process Category details form the APC
        -- Do not change SUBSTR position for APC param in code and SEED
        -- since the same value set is used in value set IGS_SRS_AD_PERSON_ID_COMPLETE
       l_admission_cat             := RTRIM ( SUBSTR ( p_admission_process_category, 1, 10));
       l_s_admission_process_type  := RTRIM ( SUBSTR ( p_admission_process_category, 11, 30));

       IF (  p_admission_process_category  IS NULL AND
               p_calendar_details            IS NULL AND
               p_person_id                   IS NULL AND
               p_person_id_group             IS NULL ) THEN

	  --Message One of the following Parameters Person Id, Person Id Group, Calendar Details
	  --or Admission Process Category is mandatory.

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_MANDATORY_PRM');
          FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
          RETURN;


     ELSIF (p_person_id                   IS NOT NULL AND
                  p_person_id_group             IS NOT NULL ) THEN
    -- Message: Invalid parameters entered. Valid combinations for parameters
    -- to be entered is Person ID or Person Group ID or Person ID, Admission Application
    -- Number, Program Code, Sequence Number or Academic Calendar, Admission  Calendar,
    -- Admission Process Category.

      FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_INV_PRM_COMB');
      FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
      RETURN;


   ELSIF (    p_person_id                   IS NULL AND
                    p_person_id_group             IS NOT NULL ) THEN

        l_records_not_found   := TRUE;

        IF lv_status = 'S' THEN
  	  BEGIN

           IF (lv_group_type = 'STATIC') THEN
            OPEN  c_dyn_pig_check FOR
                'SELECT
	                 apai.person_id,
	                 apai.admission_appl_number,
	                 apai.nominated_course_cd,
                   apai.sequence_number
                 FROM
	                 igs_ad_ps_appl_inst apai,
	                 igs_ad_ou_stat aos,
	                 igs_ad_doc_stat ads ,
                   igs_ad_appl aa
                 WHERE
                   apai.person_id  IN ( '||lv_sql_stmt||')  AND
	                 aos.s_adm_outcome_status = ''PENDING'' AND
	                 apai.adm_outcome_status = aos.adm_outcome_status AND
	                 ads.s_adm_doc_status = ''PENDING'' AND
	                 apai.adm_doc_status = ads.adm_doc_status  AND
                   aa.person_id = apai.person_id AND
                   aa.admission_appl_number = apai.admission_appl_number AND
                   aa.acad_cal_type = nvl(:1,aa.acad_cal_type) AND
                 	aa.acad_ci_sequence_number = DECODE ( :2, -1,aa.acad_ci_sequence_number, :2 )  AND
                 	aa.adm_cal_type = nvl(:3,aa.adm_cal_type) AND
                 	aa.adm_ci_sequence_number = DECODE ( :4, -1 ,aa.adm_ci_sequence_number , :4 ) AND
                 	aa.admission_cat = nvl( :5,aa.admission_cat) AND
                 	aa.s_admission_process_type = nvl( :6, aa.s_admission_process_type)  '
		USING p_person_id_group,l_acad_cal_type, l_acad_ci_sequence_number, l_acad_ci_sequence_number, l_adm_cal_type, l_adm_ci_sequence_number, l_adm_ci_sequence_number, l_admission_cat, l_s_admission_process_type;
	    LOOP

            FETCH c_dyn_pig_check  INTO c_dyn_pig_check_rec;

            IF c_dyn_pig_check%NOTFOUND THEN
              EXIT;
            END IF;

            l_records_not_found   := FALSE;

            get_incp_trstp(c_dyn_pig_check_rec.person_id,
	                                     c_dyn_pig_check_rec.admission_appl_number,
			                                 c_dyn_pig_check_rec.nominated_course_cd,
			                                 c_dyn_pig_check_rec.sequence_number);
	           END LOOP;

           ELSIF (lv_group_type = 'DYNAMIC') THEN


            OPEN  c_dyn_pig_check FOR
                'SELECT
	                 apai.person_id,
	                 apai.admission_appl_number,
	                 apai.nominated_course_cd,
                   apai.sequence_number
                 FROM
	                 igs_ad_ps_appl_inst apai,
	                 igs_ad_ou_stat aos,
	                 igs_ad_doc_stat ads ,
                   igs_ad_appl aa
                 WHERE
                   apai.person_id  IN ( '||lv_sql_stmt||')  AND
	                 aos.s_adm_outcome_status = ''PENDING'' AND
	                 apai.adm_outcome_status = aos.adm_outcome_status AND
	                 ads.s_adm_doc_status = ''PENDING'' AND
	                 apai.adm_doc_status = ads.adm_doc_status  AND
                   aa.person_id = apai.person_id AND
                   aa.admission_appl_number = apai.admission_appl_number AND
                   aa.acad_cal_type = nvl(:1,aa.acad_cal_type) AND
                 	aa.acad_ci_sequence_number = DECODE ( :2, -1,aa.acad_ci_sequence_number, :2 )  AND
                 	aa.adm_cal_type = nvl(:3,aa.adm_cal_type) AND
                 	aa.adm_ci_sequence_number = DECODE ( :4, -1 ,aa.adm_ci_sequence_number , :4 ) AND
                 	aa.admission_cat = nvl( :5,aa.admission_cat) AND
                 	aa.s_admission_process_type = nvl( :6, aa.s_admission_process_type)  '
		USING l_acad_cal_type, l_acad_ci_sequence_number, l_acad_ci_sequence_number, l_adm_cal_type, l_adm_ci_sequence_number, l_adm_ci_sequence_number, l_admission_cat, l_s_admission_process_type;
	    LOOP

            FETCH c_dyn_pig_check  INTO c_dyn_pig_check_rec;

            IF c_dyn_pig_check%NOTFOUND THEN
              EXIT;
            END IF;

            l_records_not_found   := FALSE;

            get_incp_trstp(c_dyn_pig_check_rec.person_id,
	                                     c_dyn_pig_check_rec.admission_appl_number,
			                                 c_dyn_pig_check_rec.nominated_course_cd,
			                                 c_dyn_pig_check_rec.sequence_number);
	           END LOOP;

            END IF;
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

          EXCEPTION
            WHEN OTHERS THEN
              FND_MESSAGE.SET_NAME ('IGF','IGF_AP_INVALID_QUERY');
              FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.GET);
              FND_FILE.PUT_LINE (FND_FILE.LOG,sqlerrm);
  	      END;

	      ELSE
          FND_MESSAGE.SET_NAME ('IGS',' IGS_AZ_DYN_PERS_ID_GRP_ERR');
          FND_FILE.PUT_LINE (FND_FILE.LOG,FND_MESSAGE.GET);
        END IF;

     ELSE


        -- Based  on the parameters entered fetch the application instance from admission
        -- application instance table which have application completion status = 'PENDING' and
        -- application outcome status = 'PENDING or COND-OFFER'
        l_records_not_found := TRUE;
       -- Reverting back the values of l_acad_ci_sequence_number and l_adm_ci_sequence_number
       IF l_adm_ci_sequence_number = -1 THEN
         l_adm_ci_sequence_number :=  NULL;
       END IF;

        IF l_acad_ci_sequence_number = -1 THEN
          l_acad_ci_sequence_number := NULL;
        END IF;

        FOR cur_appl_details_rec IN cur_appl_details(  p_person_id ,  l_acad_cal_type ,
			  l_adm_cal_type  , l_acad_ci_sequence_number , l_adm_ci_sequence_number  ,
			  l_admission_cat , l_s_admission_process_type  , p_admission_appl_number ,
			  p_sequence_number )LOOP
            OPEN cur_trk_exists(cur_appl_details_rec.person_id,
	                        cur_appl_details_rec.admission_appl_number,
				cur_appl_details_rec.nominated_course_cd,
				cur_appl_details_rec.sequence_number);
            FETCH cur_trk_exists INTO l_count;
            IF cur_trk_exists%FOUND THEN
               CLOSE cur_trk_exists;
               l_records_not_found := FALSE;
		-- Make a call to the procedure : get_cpti_apcmp
	       get_incp_trstp(cur_appl_details_rec.person_id,
	                      cur_appl_details_rec.admission_appl_number,
			      cur_appl_details_rec.nominated_course_cd,
			      cur_appl_details_rec.sequence_number);


	            ELSE
               CLOSE cur_trk_exists;
           END IF;
	       END LOOP;
                       IF l_records_not_found THEN
                -- Tracking steps cannot be completed for applications not having application completion status of pending
                -- and application outcome status of pending or conditional offer
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_PEND_STAT');
                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                 -- Abort the process and raise error
                 RETURN;
              END IF;
    END IF;

    -- For all the successful transactions save the changes to the database
    -- If called from Job then commit , if called from SS skip commit
    IF NVL( IGS_AD_TI_COMP.G_CALLED_FROM, 'J') = 'J' THEN
      COMMIT;
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       FND_MESSAGE.SET_NAME ( 'IGS', 'IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN ( 'NAME', ' igs_ad_ti_comp.upd_trk_itm_st');
       errbuf := FND_MESSAGE.GET_STRING ( 'IGS', FND_MESSAGE.GET);
       -- Rollback the transaction
       ROLLBACK;
       retcode := 2;
       -- Handle the standard igs-message stack
       igs_ge_msg_stack.conc_exception_hndl;
 END upd_trk_itm_st;
END igs_ad_ti_comp;

/
