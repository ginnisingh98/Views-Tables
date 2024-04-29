--------------------------------------------------------
--  DDL for Package Body IGS_AD_ADM_REQ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ADM_REQ" AS
/* $Header: IGSADA2B.pls 120.10 2006/07/31 10:16:11 apadegal ship $ */

  --
  -- Forward declarations
  --
  TYPE TRK_TYPE IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

  FUNCTION crt_adm_trk_itm(
    p_person_id IN NUMBER,
    p_admission_appl_number IN NUMBER,
    p_program_code IN VARCHAR2,
    p_sequence_number IN NUMBER,
    p_requirements_type IN VARCHAR2,
    p_originator_person IN NUMBER,
    p_tracking_status IN VARCHAR2,
    p_message_name OUT NOCOPY VARCHAR2
   ) RETURN BOOLEAN;

  FUNCTION admp_get_trk_types(
    p_admission_cat IN VARCHAR2,
    p_admission_process_type IN VARCHAR2,
    p_adm_rule_type IN VARCHAR2,
    p_person_id IN NUMBER,
    p_admission_appl_number IN NUMBER,
    p_adm_sequence_number IN NUMBER,
    p_nominated_prg_cd IN VARCHAR2,
    p_nominated_prg_version IN NUMBER
   ) RETURN TRK_TYPE;

  PROCEDURE log_detail(p_log_text IN VARCHAR2) AS
  BEGIN
    FND_FILE.PUT_LINE( FND_FILE.LOG, p_log_text);
  --  DBMS_OUTPUT.PUT_LINE(p_log_text);
  END log_detail;

  PROCEDURE ini_adm_trk_itm(
        errbuf OUT NOCOPY VARCHAR2,
        retcode OUT NOCOPY NUMBER ,
        p_person_id IN NUMBER,
        p_calendar_details IN VARCHAR2,
        p_admission_process_category IN VARCHAR2,
        p_admission_appl_number IN NUMBER,
        p_program_code IN VARCHAR2,
        p_sequence_number IN NUMBER,
        p_person_id_group IN VARCHAR2,
        p_requirements_type IN VARCHAR2,
        p_originator_person IN NUMBER,
        p_org_id IN NUMBER
        ) AS

        l_tracking_id igs_tr_item.tracking_id%TYPE;
        l_aplins_admreq_id igs_ad_aplins_admreq.aplins_admreq_id%TYPE;
        l_message_name VARCHAR2(30);
        l_found BOOLEAN;
        l_acad_cal_type igs_ca_inst.cal_type%TYPE;
        l_acad_sequence_number igs_ca_inst.sequence_number%TYPE;
        l_adm_cal_type igs_ca_inst.cal_type%TYPE;
        l_adm_sequence_number igs_ca_inst.sequence_number%TYPE;
        l_admission_cat igs_ad_cat.admission_cat%TYPE;
        l_s_adm_process_typ igs_ad_prd_ad_prc_ca.s_admission_process_type%TYPE;
        --
        -- Get eligible application instances for ADM_PROCESSING
        --
        CURSOR assn_adm_pro_cur IS
        SELECT  DISTINCT
                apai.person_id,
                apai.admission_appl_number,
                apai.nominated_course_cd,
                apai.sequence_number
        FROM
                igs_ad_ps_appl_inst apai,
                igs_ad_ou_stat aos,
                igs_ad_doc_stat ads,
                igs_ad_appl aa,
                igs_ad_appl_stat aps
        WHERE
        -- known person
                apai.person_id = nvl(p_person_id,apai.person_id) AND
        -- known person id group
                (p_person_id_group IS NOT NULL AND
                 apai.person_id IN (SELECT person_id
                                    FROM igs_pe_prsid_grp_mem pgm
                                    WHERE pgm.group_id = NVL(p_person_id_group,pgm.group_id) AND
                                    NVL(TRUNC(pgm.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) AND
                                    NVL(TRUNC(pgm.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE))
                 or
                (p_person_id_group is null)) AND
        -- known academic/admission calendar period
                aa.acad_cal_type = nvl(l_acad_cal_type,aa.acad_cal_type) AND
                aa.acad_ci_sequence_number = nvl(l_acad_sequence_number,aa.acad_ci_sequence_number) AND
                aa.adm_cal_type = nvl(l_adm_cal_type,aa.adm_cal_type) AND
                aa.adm_ci_sequence_number = nvl(l_adm_sequence_number,aa.adm_ci_sequence_number) AND
        -- known admission process category
                aa.admission_cat = nvl(l_admission_cat,aa.admission_cat) AND
                aa.s_admission_process_type = nvl(l_s_adm_process_typ,aa.s_admission_process_type) AND
        -- known application instance
                apai.nominated_course_cd = nvl(p_program_code,apai.nominated_course_cd) AND
                apai.admission_appl_number = nvl(p_admission_appl_number,apai.admission_appl_number) AND
                apai.sequence_number = nvl(p_sequence_number,apai.sequence_number) AND
        -- regular joins
                aos.s_adm_outcome_status = 'PENDING' AND
                apai.adm_outcome_status = aos.adm_outcome_status AND
                ads.s_adm_doc_status = 'PENDING' AND
                apai.adm_doc_status = ads.adm_doc_status AND
                aa.person_id=apai.person_id AND
                aa.admission_appl_number = apai.admission_appl_number AND
                NVL(apai.appl_inst_status,aps.adm_appl_status) = aps.adm_appl_status AND
                aps.s_adm_appl_status <> 'WITHDRAWN' AND			-- igsm arvsrini instance withdrawn
                aps.closed_ind = 'N';
        --
        -- Get eligible application instances for POST_ADMISSION
        --
        CURSOR assn_post_adm_cur IS
        SELECT  DISTINCT
                apai.person_id,
                apai.admission_appl_number,
                apai.nominated_course_cd,
                apai.sequence_number
        FROM
                igs_ad_ps_appl_inst apai,
                igs_ad_ou_stat aos,
                igs_ad_doc_stat ads,
                igs_ad_appl aa,
                igs_ad_appl_stat aps
        WHERE
        -- known person
                apai.person_id = nvl(p_person_id,apai.person_id) AND
        -- known person id group
                (p_person_id_group IS NOT NULL AND
                 apai.person_id IN (SELECT person_id
                                    FROM igs_pe_prsid_grp_mem pgm
                                    WHERE pgm.group_id = NVL(p_person_id_group,pgm.group_id) AND
                                   NVL(TRUNC(pgm.start_date),TRUNC(SYSDATE)) <= TRUNC(SYSDATE) AND
                                     NVL(TRUNC(pgm.end_date),TRUNC(SYSDATE)) >= TRUNC(SYSDATE))
                 or
                (p_person_id_group is null)) AND
        -- known academic/admission calendar period
                aa.acad_cal_type = nvl(l_acad_cal_type,aa.acad_cal_type) AND
                aa.acad_ci_sequence_number = nvl(l_acad_sequence_number,aa.acad_ci_sequence_number) AND
                aa.adm_cal_type = nvl(l_adm_cal_type,aa.adm_cal_type) AND
                aa.adm_ci_sequence_number = nvl(l_adm_sequence_number,aa.adm_ci_sequence_number) AND
        -- known admission process category
                aa.admission_cat = nvl(l_admission_cat,aa.admission_cat) AND
                aa.s_admission_process_type = nvl(l_s_adm_process_typ,aa.s_admission_process_type) AND
        -- known application instance
                apai.nominated_course_cd = nvl(p_program_code,apai.nominated_course_cd) AND
                apai.admission_appl_number = nvl(p_admission_appl_number,apai.admission_appl_number) AND
                apai.sequence_number = nvl(p_sequence_number,apai.sequence_number) AND
        -- regular joins
                aos.s_adm_outcome_status IN ( 'OFFER', 'PENDING', 'COND-OFFER') AND
                apai.adm_outcome_status = aos.adm_outcome_status AND
                ads.s_adm_doc_status IN ( 'INCOMPLETE', 'NOT-APPLIC', 'PENDING', 'SATISFIED') AND
                apai.adm_doc_status = ads.adm_doc_status AND
                aa.person_id=apai.person_id AND
                aa.admission_appl_number = apai.admission_appl_number AND
                NVL(apai.appl_inst_status,aps.adm_appl_status) = aps.adm_appl_status AND
                aps.s_adm_appl_status <> 'WITHDRAWN' AND			-- igsm arvsrini instance withdrawn
                aps.closed_ind = 'N'
		AND igs_ad_gen_002.check_adm_appl_inst_stat(apai.person_id,apai.admission_appl_number,apai.nominated_course_cd,
		     apai.sequence_number,'Y')='Y';

        CURSOR get_dflt_active_track_stat_cur IS
          SELECT tracking_status
          FROM   igs_tr_status
          WHERE  s_tracking_status = 'ACTIVE'
          AND    NVL(default_ind,'N') = 'Y'
          AND    closed_ind = 'N';

        get_dflt_active_track_stat_rec get_dflt_active_track_stat_cur%ROWTYPE;

	CURSOR get_meaning_req_type_cur IS
          SELECT meaning
          FROM   igs_lookup_values
          WHERE  lookup_type = 'TRACKING_TYPE'
          AND    lookup_code = p_requirements_type;

        get_meaning_req_type_rec get_meaning_req_type_cur%ROWTYPE;

  CURSOR c_get_person_number (cp_person_id hz_parties.party_id%TYPE) IS
         SELECT party_number person_number
         FROM   hz_parties
         WHERE  party_id = cp_person_id;

  l_get_person_number hz_parties.party_number%TYPE;


  BEGIN
        -- Initialize message stack
        igs_ge_msg_stack.initialize;
        --
        -- To populate org_id
        igs_ge_gen_003.set_org_id(p_org_id);
        --
        retcode := 0;
        errbuf  := NULL;

        OPEN get_dflt_active_track_stat_cur;
        FETCH get_dflt_active_track_stat_cur INTO get_dflt_active_track_stat_rec;
        CLOSE get_dflt_active_track_stat_cur;

        OPEN get_meaning_req_type_cur;
        FETCH get_meaning_req_type_cur INTO get_meaning_req_type_rec;
        CLOSE get_meaning_req_type_cur;

        IF get_dflt_active_track_stat_rec.tracking_status IS NULL THEN
          log_detail('This process requires a user defined tracking status with default indicator set');
          log_detail('and not marked as closed to be mapped to the system tracking status of ACTIVE');
          log_detail('Please re run the process with the above setup');

        ELSE

          -- Log the Initial parameters into the LOG file.
          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_TR_PRMS');
          log_detail(FND_MESSAGE.GET());

          OPEN c_get_person_number(p_person_id);
          FETCH c_get_person_number INTO l_get_person_number;
          CLOSE c_get_person_number;

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_PNUM');
          FND_MESSAGE.SET_TOKEN('PNUM', l_get_person_number);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_PID_GRP');
          FND_MESSAGE.SET_TOKEN('PGPID', p_person_id_group);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_ADM_APLNO');
          FND_MESSAGE.SET_TOKEN('APLNO', p_admission_appl_number);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CRCD');
          FND_MESSAGE.SET_TOKEN('CRCD', p_program_code);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_APP_SEQNO');
          FND_MESSAGE.SET_TOKEN('SEQNO', p_sequence_number);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CL_DTLS');
          FND_MESSAGE.SET_TOKEN('CLDTLS', p_calendar_details);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_APC');
          FND_MESSAGE.SET_TOKEN('APC', p_admission_process_category);
          log_detail(FND_MESSAGE.GET());

          OPEN c_get_person_number(p_originator_person);
          FETCH c_get_person_number INTO l_get_person_number;
          CLOSE c_get_person_number;

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_OPNUM');
          FND_MESSAGE.SET_TOKEN('OPNUM', l_get_person_number);
          log_detail(FND_MESSAGE.GET());

          FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_REQ_TYPE');
          FND_MESSAGE.SET_TOKEN('RTYP', get_meaning_req_type_rec.meaning);
          log_detail(FND_MESSAGE.GET());

          IF p_person_id                  IS NULL AND
             p_person_id_group            IS NULL AND
             p_calendar_details           IS NULL AND
             p_admission_process_category IS NULL THEN
            --Message One of the following Parameters Person Id, Person Id Group, Calendar Details
            --or Admission Process Category is mandatory.
            FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_MANDATORY_PRM');
            log_detail(FND_MESSAGE.GET());
          ELSE
            SAVEPOINT ini_adm_trk_prcs;
            --
            -- Split the calendar details and the admission process category into seperate variables
            --
            l_acad_cal_type        := RTRIM ( SUBSTR ( p_calendar_details, 1, 10));
            l_acad_sequence_number := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 14, 6));
            l_adm_cal_type         := RTRIM ( SUBSTR ( p_calendar_details, 23, 10));
            l_adm_sequence_number  := IGS_GE_NUMBER.TO_NUM ( SUBSTR ( p_calendar_details, 37, 6));

            -- Do not change SUBSTR position for APC param in code and SEED
            -- since the same value set is used in value set IGS_SRS_AD_PERSON_ID_COMPLETE
            l_admission_cat        := RTRIM ( SUBSTR ( p_admission_process_category, 1, 10));
            l_s_adm_process_typ    := RTRIM ( SUBSTR ( p_admission_process_category, 11, 30));

            -- Flag to indicate whether any admission application instance records could be fetched
            -- based on the parameters passed to the procedure
            l_found := FALSE;

            IF p_requirements_type = 'ADM_PROCESSING' THEN
              FOR assn_adm_pro_rec IN assn_adm_pro_cur LOOP
                --
                -- Set the found flag to TRUE
                --
                l_found := TRUE;
                --
                -- For Each Record Selected Do The Following
                --

                OPEN c_get_person_number(IGS_GE_NUMBER.TO_CANN (assn_adm_pro_rec.person_id));
                FETCH c_get_person_number INTO l_get_person_number;
                CLOSE c_get_person_number;

                log_detail( FND_GLOBAL.NEWLINE );
                log_detail( ' Application Instance Information ' );
                log_detail( ' Person Number :: ' || RPAD(l_get_person_number,30) ||
                            ' Admission Application Number :: ' || IGS_GE_NUMBER.TO_CANN (assn_adm_pro_rec.admission_appl_number ) );
                log_detail( ' Program Code  :: ' || RPAD(assn_adm_pro_rec.nominated_course_cd,30) ||
                            ' Sequence Number              :: ' || IGS_GE_NUMBER.TO_CANN ( assn_adm_pro_rec.sequence_number ) );
                IF NOT crt_adm_trk_itm(
                        p_person_id => assn_adm_pro_rec.person_id,
                        p_admission_appl_number => assn_adm_pro_rec.admission_appl_number,
                        p_program_code => assn_adm_pro_rec.nominated_course_cd,
                        p_sequence_number => assn_adm_pro_rec.sequence_number,
                        p_requirements_type => p_requirements_type,
                        p_originator_person => p_originator_person,
                        p_tracking_status => get_dflt_active_track_stat_rec.tracking_status,
                        p_message_name => l_message_name
                       ) THEN
                  IF l_message_name IS NOT NULL THEN
                    log_detail(FND_MESSAGE.GET_STRING('IGS', l_message_name));
                  END IF;
                END IF;
              END LOOP;
            ELSIF p_requirements_type = 'POST_ADMISSION' THEN
              FOR assn_post_adm_rec IN assn_post_adm_cur LOOP
                --
                -- Set the found flag to TRUE
                --
                l_found := TRUE;
                --
                -- For Each Record Selected Do The Following
                --

                OPEN c_get_person_number(IGS_GE_NUMBER.TO_CANN (assn_post_adm_rec.person_id));
                FETCH c_get_person_number INTO l_get_person_number;
                CLOSE c_get_person_number;


                log_detail( FND_GLOBAL.NEWLINE );
                log_detail( ' Application Instance Information ' );
                log_detail( ' Person Number :: ' || RPAD(l_get_person_number,30) ||
                            ' Admission Application Number :: ' || IGS_GE_NUMBER.TO_CANN (assn_post_adm_rec.admission_appl_number ) );
                log_detail( ' Program Code :: ' || RPAD(assn_post_adm_rec.nominated_course_cd,30) ||
                            ' Sequence Number              :: ' || IGS_GE_NUMBER.TO_CANN ( assn_post_adm_rec.sequence_number ) );
                IF NOT crt_adm_trk_itm(
                        p_person_id => assn_post_adm_rec.person_id,
                        p_admission_appl_number => assn_post_adm_rec.admission_appl_number,
                        p_program_code => assn_post_adm_rec.nominated_course_cd,
                        p_sequence_number => assn_post_adm_rec.sequence_number,
                        p_requirements_type => p_requirements_type,
                        p_originator_person => p_originator_person,
                        p_tracking_status => get_dflt_active_track_stat_rec.tracking_status,
                        p_message_name => l_message_name
                       ) THEN
                  IF l_message_name IS NOT NULL THEN
                    log_detail(FND_MESSAGE.GET_STRING('IGS', l_message_name));
                  END IF;
                END IF;
              END LOOP;
            END IF;
            --
            -- If no rows selected then abort the process with the message
            -- Requirements cannot be assigned for selected applications
            --
	    IF l_found THEN
	     igs_ad_wf_001.ASSIGN_REQUIRMENT_DONE_EVENT
             (
		p_person_id                     => p_person_id,
		p_admission_appl_number         => p_admission_appl_number,
		p_nominated_course_cd           => p_program_code,
		p_sequence_number               => p_sequence_number
	      );
	    END IF;

            IF NOT l_found THEN
              IF p_requirements_type = 'ADM_PROCESSING' THEN
                log_detail( FND_GLOBAL.NEWLINE );
                log_detail('Requirements cannot be assigned as applications do not exist for parameters');
                log_detail('entered or applications do not have application processing status of Received');
                log_detail('or application completion status of Pending');
                log_detail('or application outcome status of Pending');
              ELSIF p_requirements_type = 'POST_ADMISSION' THEN
                log_detail( FND_GLOBAL.NEWLINE );
                log_detail('Requirements cannot be assigned as applications do not exist for parameters');
                log_detail('entered or applications do not have application processing status of');
                log_detail('Received/Completed or application completion status of');
                log_detail('Not Applicable/Pending/Incomplete/Satisfied or application outcome status of');
                log_detail('Pending/Conditional Offer/Offer');
              END IF;
            END IF;
          END IF;
        END IF;
  EXCEPTION
        WHEN OTHERS THEN
          log_detail( FND_GLOBAL.NEWLINE );
          FND_MESSAGE.SET_NAME ( 'IGS', 'IGS_GE_UNHANDLED_EXP');
          FND_MESSAGE.SET_TOKEN ( 'NAME', ' igs_ad_adm_req.ini_adm_trk_itm');
          errbuf := FND_MESSAGE.GET_STRING ( 'IGS', FND_MESSAGE.GET);
          -- Rollback the transaction
          ROLLBACK TO ini_adm_trk_prcs;
          retcode := 2;
          -- Handle the standard igs-message stack
          igs_ge_msg_stack.conc_exception_hndl;
  END ini_adm_trk_itm;
  --
  -- End of Procedure ins_adm_trk_itm
  --
  --
  -- Start of Function crt_adm_trk_itm
  --
  FUNCTION crt_adm_trk_itm(
        p_person_id IN NUMBER,
        p_admission_appl_number IN NUMBER,
        p_program_code IN VARCHAR2,
        p_sequence_number IN NUMBER,
        p_requirements_type IN VARCHAR2,
        p_originator_person IN NUMBER,
        p_tracking_status IN VARCHAR2,
        p_message_name OUT NOCOPY VARCHAR2
        ) RETURN BOOLEAN AS

        l_message_name VARCHAR2(30);
        l_target_days igs_tr_type.target_days%TYPE;
        l_originator_person_id hz_parties.party_id%type;

        CURSOR trk_comp_dt_cur IS
        SELECT
                NVL(TRUNC(IGS_CA_GEN_001.calp_set_alias_value(
                      cdi.absolute_val,
                      IGS_CA_GEN_002.cals_clc_dt_from_dai(
                            cdi.ci_sequence_number, cdi.CAL_TYPE, cdi.DT_ALIAS, cdi.sequence_number)
                    )), TRUNC(sysdate-1)) alias_val
        FROM
                igs_ad_ps_appl_inst apai,
                igs_ad_cal_conf acc,
                igs_ca_da_inst cdi
        WHERE
                -- Application Instance
                apai.person_id = p_person_id AND
                apai.admission_appl_number = p_admission_appl_number AND
                apai.nominated_course_cd = p_program_code AND
                apai.sequence_number = p_sequence_number AND
                -- Calendar Instance
                cdi.ci_sequence_number = apai.adm_ci_sequence_number AND
                cdi.cal_type = apai.adm_cal_type AND
                -- Date Alias
                ((cdi.dt_alias = acc.adm_prc_trk_dt_alias AND
                  p_requirements_type = 'ADM_PROCESSING') OR
                 (cdi.dt_alias = acc.post_adm_trk_dt_alias AND
                  p_requirements_type = 'POST_ADMISSION'));

        trk_comp_dt trk_comp_dt_cur%ROWTYPE;

        CURSOR check_existence_cur IS
        SELECT
                ar.rowid, ar.tracking_id, itt.tracking_type
        FROM
                igs_ad_aplins_admreq ar,
                igs_tr_item itt,
                igs_tr_type tt
        WHERE
                ar.person_id = p_person_id  AND
                ar.admission_appl_number = p_admission_appl_number AND
                ar.course_cd = p_program_code AND
                ar.sequence_number = p_sequence_number AND
                itt.tracking_id = ar.tracking_id AND
                itt.tracking_type = tt.tracking_type AND
                tt.s_tracking_type = p_requirements_type AND
                NOT EXISTS
                        (SELECT 'x'
                         FROM   igs_tr_step its
                         WHERE  its.tracking_id = ar.tracking_id AND
                                (its.step_completion_ind = 'Y' OR
                                 its.by_pass_ind = 'Y')                -- bug 2776548
                        )
        FOR UPDATE OF itt.tracking_id NOWAIT;

        CURSOR process_rules_cur IS
        SELECT
                aa.admission_cat,
                aa.s_admission_process_type,
                apai.crv_version_number
        FROM
                igs_ad_ps_appl_inst apai,
                igs_ad_appl aa
        WHERE
                apai.person_id = aa.person_id AND
                apai.admission_appl_number = aa.admission_appl_number AND
                apai.person_id = p_person_id AND
                apai.admission_appl_number = p_admission_appl_number AND
                apai.nominated_course_cd = p_program_code AND
                apai.sequence_number = p_sequence_number;

        process_rules_rec process_rules_cur%ROWTYPE;

        CURSOR process_apc_cur IS
          SELECT ty.tracking_type
          FROM   igs_tr_type ty
          WHERE  ty.s_tracking_type = p_requirements_type
          AND    ty.closed_ind = 'N'
	  AND    EXISTS ( SELECT 'X'
                          FROM igs_ad_appl aa,
                               igs_ad_ps_appl_inst apai,
                               igs_ad_prcs_cat_step apcs
                          WHERE apai.person_id = p_person_id
                          AND   apai.admission_appl_number = p_admission_appl_number
                          AND   apai.sequence_number = p_sequence_number
                          AND   apai.nominated_course_cd = p_program_code
                          AND   aa.person_id = apai.person_id
                          AND   aa.admission_appl_number = apai.admission_appl_number
                          AND   aa.admission_cat = apcs.admission_cat
                          AND   aa.s_admission_process_type = apcs.s_admission_process_type
                          AND   apcs.s_admission_step_type = ty.tracking_type
                          AND   apcs.step_group_type = 'TRACK' );


        process_apc_rec process_apc_cur%ROWTYPE;

        CURSOR check_duplicate_cur (cp_tracking_type igs_tr_type.tracking_type%TYPE) IS
        SELECT ar.tracking_id
        FROM   igs_ad_aplins_admreq ar
        WHERE  ar.person_id = p_person_id
        AND    ar.admission_appl_number = p_admission_appl_number
        AND    ar.course_cd = p_program_code
        AND    ar.sequence_number = p_sequence_number
	      AND    EXISTS ( SELECT 'X'
                        FROM igs_tr_item itt,
	                           igs_tr_type tt
	                      WHERE itt.tracking_id = ar.tracking_id
                        AND itt.tracking_type = tt.tracking_type
		                    AND tt.s_tracking_type = p_requirements_type
		                    AND tt.tracking_type = cp_tracking_type);


        check_duplicate_cur_rec check_duplicate_cur%ROWTYPE;

        l_trk_types TRK_TYPE;
        l_trk_types_final TRK_TYPE;
        l_trk_types_rpt BOOLEAN;
        l_trk_ind BOOLEAN;
        --
        -- Start of Local Function crt_adm_trkitm
        --
         PROCEDURE crt_adm_trkitm(
                p_person_id             IN      NUMBER,
                p_admission_appl_number IN      NUMBER,
                p_program_code          IN      VARCHAR2,
                p_sequence_number       IN      NUMBER,
                p_tracking_type         IN      VARCHAR2,
                p_target_days           IN      NUMBER,
                p_completion_due_dt     IN      DATE
                ) AS

                l_message_name VARCHAR2(30);
                l_tracking_id igs_ad_aplins_admreq.tracking_id%TYPE;
                l_aplins_admreq_id igs_ad_aplins_admreq.aplins_admreq_id%TYPE;
                l_rowid VARCHAR2(25);
		l_override_offset_clc_ind VARCHAR2(2);
           BEGIN
                /*
                Call the tracking item api to create the tracking item for application instance in the loop
                */
		IF p_completion_due_dt IS NULL THEN
		l_override_offset_clc_ind :='N';
		ELSE
		l_override_offset_clc_ind :='Y';
		END IF;
                igs_tr_gen_002.trkp_ins_trk_item(
                        p_tracking_status => p_tracking_status,
                        p_tracking_type => p_tracking_type,
                        p_source_person_id => p_person_id,
                        p_start_dt => SYSDATE,
                        p_target_days => p_target_days,
                        p_sequence_ind => NULL,
                        p_business_days_ind => NULL,
                        p_originator_person_id => l_originator_person_id,
                        p_s_created_ind => NULL,
                        p_completion_due_dt => p_completion_due_dt,
                        p_override_offset_clc_ind => l_override_offset_clc_ind,
                        p_publish_ind => NULL,
                        p_tracking_id => l_tracking_id,
                        p_message_name => l_message_name
                        );
                IF l_tracking_id IS NOT NULL THEN
                  BEGIN
                        igs_ad_aplins_admreq_pkg.insert_row(
                                x_rowid                 => l_rowid,
                                x_aplins_admreq_id      => l_aplins_admreq_id,
                                x_person_id             => p_person_id,
                                x_admission_appl_number => p_admission_appl_number,
                                x_course_cd             => p_program_code,
                                x_sequence_number       => p_sequence_number,
                                x_tracking_id           => l_tracking_id,
                                x_mode                  => 'R'
                                );
                        IF l_aplins_admreq_id IS NOT NULL THEN
                                --
                                -- Process completed successfully tracking items
                                -- created for the Application Instances entered
                                --
                                log_detail(FND_MESSAGE.GET_STRING ( 'IGS', 'IGS_AD_PROC_ASSIGN_REQ_COMP'));
                                log_detail('Tracking ID :: ' || IGS_GE_NUMBER.TO_CANN ( l_tracking_id) ||' for tracking type :: ' || p_tracking_type);

                        ELSE
                                log_detail('Failed to create the tracking item link to admission application instance');
                                log_detail('for the tracking item :: ' || IGS_GE_NUMBER.TO_CANN (l_tracking_id) ||', please create it manually');
                        END IF;
                  EXCEPTION
                    WHEN OTHERS THEN
                      log_detail('Failed to create the tracking item link to admission application instance');
                      log_detail('for the tracking item :: ' || IGS_GE_NUMBER.TO_CANN (l_tracking_id) ||', please create it manually');
                  END;
                ELSE
		              log_detail('Failed to create the tracking item for the admission application instance');
		              log_detail('For the tracking type :: ' || p_tracking_type);
                  p_message_name := l_message_name;
             	    IF l_message_name IS NOT NULL THEN
            		    log_detail(FND_MESSAGE.GET_STRING('IGS', l_message_name));
           		    END IF;
                END IF;
	         EXCEPTION
	           WHEN OTHERS THEN
	           log_detail('Failed to create the tracking item for the admission application instance');
	           log_detail('For the tracking type :: ' || p_tracking_type);
	           IF l_message_name IS NOT NULL THEN
	             log_detail(FND_MESSAGE.GET_STRING('IGS', l_message_name));
	           END IF;
           END crt_adm_trkitm;
        --
        -- End Of Local Function crt_adm_trkitm
        --
  BEGIN

        l_trk_ind := FALSE;

        /*
        Issue a savepoint for the tracking items-applications related processing
        */
        SAVEPOINT sp_trkitm_aplproc;

        -- Set the originator person ID
        IF p_originator_person IS NULL THEN
          l_originator_person_id := p_person_id;
        ELSE
          l_originator_person_id := p_originator_person;
        END IF;
        --
        -- Tracking Completion Date validation
        -- 5.9.7.1 ( This refers to the section in the DLD)
        --
        IF p_requirements_type = 'POST_ADMISSION' THEN
                OPEN trk_comp_dt_cur;
                FETCH trk_comp_dt_cur INTO trk_comp_dt;
                IF NVL(trk_comp_dt.alias_val,SYSDATE) < SYSDATE  THEN
                        p_message_name := 'IGS_AD_TRAC_COMP_DATE_PASS';
                        CLOSE trk_comp_dt_cur;
                        RETURN FALSE;
                END IF;
                CLOSE trk_comp_dt_cur;
        --
        -- 5.9.7.2
        --
        ELSIF p_requirements_type = 'ADM_PROCESSING' THEN
                OPEN trk_comp_dt_cur;
                FETCH trk_comp_dt_cur INTO trk_comp_dt;
                IF NVL(trk_comp_dt.alias_val,SYSDATE) < SYSDATE  THEN
                        p_message_name := 'IGS_AD_TRAC_COMP_DATE_PASS';
                        CLOSE trk_comp_dt_cur;
                        RETURN FALSE;
                END IF;
                CLOSE trk_comp_dt_cur;
        END IF;

        IF trk_comp_dt.alias_val IS NULL THEN
	l_target_days := NULL;
	ELSE
        l_target_days := trk_comp_dt.alias_val - TRUNC(SYSDATE);

        IF l_target_days > 9999 THEN
          log_detail('Target days for a tracking item cannot be more than 9999 days');
          RETURN FALSE;
        END IF;
	END IF;


        /*
        5.9.7.3
        Check if records already exist in the linking table for the application instance
        and the tracking items
        */
        FOR check_existence_rec IN check_existence_cur LOOP
            igs_ad_aplins_admreq_pkg.delete_row ( check_existence_rec.rowid);
            IF igs_tr_gen_002.trkp_del_tri ( check_existence_rec.tracking_id, l_message_name) THEN
              log_detail(FND_MESSAGE.GET_STRING( 'IGS', 'IGS_AD_TRAC_NOT_REQ_DELETED'));
              log_detail('Tracking ID :: ' || IGS_GE_NUMBER.TO_CANN( check_existence_rec.tracking_id) ||
                         ' of tracking type :: ' || check_existence_rec.tracking_type);
            ELSE
              log_detail(FND_MESSAGE.GET_STRING( 'IGS', l_message_name));
              log_detail('Tracking ID :: ' || IGS_GE_NUMBER.TO_CANN( check_existence_rec.tracking_id) ||
                         ' of tracking type :: ' || check_existence_rec.tracking_type);
              ROLLBACK TO sp_trkitm_aplproc;
              RETURN FALSE;
            END IF;
        END LOOP;

        --
        -- 5.9.7.15
        -- Get the admission category, system  admission process type, program version
        -- number  for the application instance in loop and input these values to the function
        -- (admp_get_trkp_types) getting created in the  DLD DLD_adsr_rules_changes
        --
        l_trk_ind := FALSE;

        OPEN process_rules_cur;
        FETCH process_rules_cur INTO process_rules_rec;
        IF process_rules_cur%NOTFOUND THEN
          CLOSE process_rules_cur;
        ELSE
          --
          -- Modified as a part DLD_adsr_rules_changes DLD enhancement
          -- call the admp_get_trk_types API which will return the PL/SQL table
          -- populated with the tracking types attached to the APC through rules
          --
          l_trk_types := admp_get_trk_types(
                                p_admission_cat                 => process_rules_rec.admission_cat,
                                p_admission_process_type        => process_rules_rec.s_admission_process_type,
                                p_adm_rule_type                 => p_requirements_type,
                                p_person_id                     => p_person_id,
                                p_admission_appl_number         => p_admission_appl_number,
                                p_adm_sequence_number           => p_sequence_number,
                                p_nominated_prg_cd              => p_program_code,
                                p_nominated_prg_version         => process_rules_rec.crv_version_number
                                );
          CLOSE process_rules_cur;

          If l_trk_types.count > 0 THEN
            l_trk_ind := TRUE;
          END IF;
        END IF;

        /*
        5.9.7.7
        Process the Tracking steps that are defined in the APC
        */
        OPEN process_apc_cur;
        FETCH process_apc_cur INTO process_apc_rec;
        IF process_apc_cur%FOUND THEN
          l_trk_ind := TRUE;
          LOOP
            l_trk_types(NVL(l_trk_types.count,0)+1) := process_apc_rec.tracking_type;

            FETCH process_apc_cur INTO process_apc_rec;
            IF process_apc_cur%NOTFOUND THEN
              EXIT;
            END IF;
          END LOOP;
        END IF;
        CLOSE process_apc_cur;

        IF NOT l_trk_ind THEN
          log_detail(FND_MESSAGE.GET_STRING ( 'IGS', 'IGS_AD_TRAC_NOT_ASSIGN'));
          ROLLBACK TO sp_trkitm_aplproc;
          RETURN FALSE;
        ELSE

          FOR i in 1 .. l_trk_types.count LOOP
            l_trk_types_rpt := FALSE;
            FOR j in i+1 .. l_trk_types.count LOOP
              IF l_trk_types(i) = l_trk_types(j) THEN
                l_trk_types_rpt := TRUE;
                EXIT;
              END IF;
            END LOOP;
            IF NOT l_trk_types_rpt THEN
              l_trk_types_final(NVL(l_trk_types_final.count,0)+1) := l_trk_types(i);
            END IF;
          END LOOP;

          FOR k in 1 .. l_trk_types_final.count LOOP
            OPEN check_duplicate_cur(l_trk_types_final(k));
            FETCH check_duplicate_cur INTO check_duplicate_cur_rec;
            IF check_duplicate_cur%NOTFOUND THEN
              CLOSE check_duplicate_cur;
              crt_adm_trkitm(
                    p_person_id             => p_person_id,
                    p_admission_appl_number => p_admission_appl_number,
                    p_program_code          => p_program_code,
                    p_sequence_number       => p_sequence_number,
                    p_tracking_type         => l_trk_types_final(k),
                    p_target_days           => l_target_days,
                    p_completion_due_dt     => trk_comp_dt.alias_val
                   );
            ELSE
              CLOSE check_duplicate_cur;
              log_detail('Tracking item :: '|| IGS_GE_NUMBER.TO_CANN(check_duplicate_cur_rec.tracking_id) ||
                         ' for tracking type :: ' || l_trk_types_final(k) ||
                         ' already exist with closed or bypassed steps, hence not recreating');
            END IF;
          END LOOP;

          RETURN TRUE;
        END IF;

        EXCEPTION
          WHEN OTHERS THEN
            ROLLBACK TO sp_trkitm_aplproc;
            p_message_name := 'IGS_AD_PROC_ASSIGN_REQ_FAILED';
            RETURN FALSE;
        END crt_adm_trk_itm;

     /* This function will evaluate the Admission Process Category Rules for the APC attached to the application instance
        and return the list of tracking type(s) to be attached to the application instance in a PLSQL Table.
        The function(s)/procedure(s) which will attach the tracking type(s) to the application instance should call this
        function to get the list of the tracking type(s) to be attached to the application Instance.
      */

    FUNCTION admp_get_trk_types(
                   p_admission_cat IN VARCHAR2,
                   p_admission_process_type IN VARCHAR2,
                   p_adm_rule_type IN VARCHAR2,
                   p_person_id IN NUMBER,
                   p_admission_appl_number IN NUMBER,
                   p_adm_sequence_number IN NUMBER,
                   p_nominated_prg_cd IN VARCHAR2,
                   p_nominated_prg_version IN NUMBER
        ) RETURN TRK_TYPE AS

       CURSOR  c_igs_pe_person_addr IS
         SELECT row_id
         FROM   igs_pe_person_addr
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_pe_mil_services IS
         SELECT row_id
         FROM   igs_pe_mil_services
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_pe_pers_disablty_v IS
         SELECT rowid row_id
         FROM   igs_pe_pers_disablty
         WHERE  person_id = p_person_id;

      CURSOR  c_igs_pe_citizenship_status IS
         SELECT rowid row_id
	 FROM IGS_PE_EIT
         WHERE INFORMATION_TYPE     = 'PE_STAT_RES_STATUS'
         AND person_id = p_person_id
	 AND SYSDATE BETWEEN START_DATE AND NVL(END_DATE, SYSDATE);



       CURSOR  c_igs_pe_citizenship_v IS
         SELECT row_id
         FROM   igs_pe_citizenship_v
         WHERE  party_id = p_person_id;

       CURSOR  c_igs_pe_res_dtls IS
         SELECT row_id
         FROM   igs_pe_res_dtls
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_pe_teach_periods_v IS
         SELECT rowid row_id
         FROM   igs_pe_teach_periods
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_tst_rslt_dtls_v IS
         SELECT iatrdv.rowid row_id
         FROM   igs_ad_tst_rslt_dtls iatrdv
         WHERE   EXISTS (SELECT 'X'
	                 FROM igs_ad_test_results iatr
                         WHERE iatr.person_id = p_person_id
                         AND   iatrdv.test_results_id = iatr.test_results_id );

       CURSOR  c_igs_ad_acad_history_v IS
         SELECT row_id
         FROM   igs_ad_acad_history_v
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_extracurr_act_v IS
         SELECT rowid
	 FROM HZ_PERSON_INTEREST PI
	 WHERE party_ID = p_person_id;

       CURSOR  c_igs_ad_test_results_v IS
         SELECT rowid row_id
          FROM   igs_ad_test_results
          WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_app_intent_v IS
         SELECT rowid row_id
         FROM   igs_ad_app_intent
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_acad_interest_v IS
         SELECT rowid row_id
         FROM   igs_ad_acad_interest
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_spl_interests_v IS
         SELECT rowid row_id
         FROM   igs_ad_spl_interests
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_spl_talents_v IS
         SELECT rowid row_id
         FROM   igs_ad_spl_talents
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_unit_sets_v IS
         SELECT rowid row_id
         FROM   igs_ad_unit_sets
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_ad_other_inst_v IS
         SELECT rowid row_id
         FROM   igs_ad_other_inst
         WHERE  person_id = p_person_id;

       CURSOR  c_igs_pe_athletic_prg_v IS       -- bug 2794983
         SELECT rowid row_id
         FROM   igs_pe_athletic_prg
         WHERE  person_id = p_person_id;

--ssawhney SWS104, ad_acad changed to pe_acad
       CURSOR  c_igs_pe_acad_honors_v IS
         SELECT rowid row_id
         FROM   igs_pe_acad_honors
         WHERE  person_id = p_person_id;

       CURSOR c_rule IS
         SELECT  rul_sequence_number
         FROM    igs_ad_apctr_ru
         WHERE   admission_cat = p_admission_cat
         AND     s_admission_process_type = p_admission_process_type
         AND     s_rule_call_cd = p_adm_rule_type;


       l_address_rule_num VARCHAR2(500)  := '30171, 30172, 30173, 30174, 30175,30176,30177,30178, 30179'; --address
       l_military_rule_num VARCHAR2(500)  := '30181, 30182, 30183, 30184'; -- Military
       l_pers_disability_rule_num VARCHAR2(500)  := '30185'; -- Pers Disability
       l_citizen_status_rule_num VARCHAR2(500)  :=  '30186'; -- Citizenship status (Bug Person Stats )
       l_citizenship_rule_num VARCHAR2(500)  := '30187'; -- Citizenship
       l_pe_results_rule_num VARCHAR2(500)  := '30188, 30189'; -- Pe Results
       l_pe_teaching_num VARCHAR2(500)  := '30190,30191'; -- Pe Teaching Periods
       l_ad_test_rslt_dtls_rule_num VARCHAR2(500)  := '30246, 30247, 30248, 30249, 30250, 30251, 30252, 30253, 30254'; -- AD Test Results Details
       l_acad_hist_rule_num VARCHAR2(500)  := '30192, 30193, 30194, 30195, 30196, 30197, 30198, 30199, 30200, 30201, 30202, 30203, 30204, 30205, 30206, 30207, 53211'; -- Acad Hist
       l_extra_cur_rule_num VARCHAR2(500)  := '30208, 30209, 30210, 30211, 30212, 30213, 30230, 30231, 30232, 30233'; -- Extra Curicular activities
       l_ad_test_rslt_rule_num VARCHAR2(500)  := '30236, 30237, 30238, 30239, 30240, 30241, 30242, 30243, 30244, 30245'; -- AD Test Results
       l_app_intent_rule_num VARCHAR2(500)  := '30275'; 	   -- App Intent
       l_acad_interest_rule_num VARCHAR2(500)  := '30276'; -- Ad Acad Interest
       l_spl_interest_rule_num VARCHAR2(500)  := '30277'; -- Spl Interest
       l_spl_talent_rule_num VARCHAR2(500)  := '30278'; -- Spl Talent
       l_unit_sets_rule_num VARCHAR2(500)  := '30279, 30280';  -- UnitSets
       l_other_inst_rule_num VARCHAR2(500)  := '30281'; -- Other Institutions
       l_athl_prog_rule_num VARCHAR2(500)  := '30282, 30283'; -- Athletic PRG
       l_pe_acad_hnrs_rule_num VARCHAR2(500)  := '30286, 30287';  -- Pe Acad Honors

       l_address_rule_exists  boolean := false;
       l_military_rule_exists  boolean := false;
       l_pers_disability_rule_exists  boolean := false;
       l_citizen_status_rule_exists  boolean := false;
       l_citizenship_rule_exists  boolean := false;
       l_pe_results_rule_exists  boolean := false;
       l_pe_teaching_exists  boolean := false;
       l_ad_tst_rslt_dtl_rule_exists  boolean := false;
       l_acad_hist_rule_exists  boolean := false;
       l_extra_cur_rule_exists  boolean := false;
       l_ad_test_rslt_rule_exists  boolean := false;
       l_app_intent_rule_exists  boolean := false;
       l_acad_interest_rule_exists  boolean := false;
       l_spl_interest_rule_exists  boolean := false;
       l_spl_talent_rule_exists  boolean := false;
       l_unit_sets_rule_exists  boolean := false;
       l_other_inst_rule_exists  boolean := false;
       l_athl_prog_rule_exists  boolean := false;
       l_pe_acad_hnrs_rule_exists  boolean := false;





 /*    CURSOR c_rule_items(p_rul_seq_num NUMBER) IS
       SELECT p_rul_seq_num, item.NAMED_RULE,  'Y'
       FROM  IGS_RU_ITEM item
       WHERE item.RUL_SEQUENCE_NUMBER =  p_rul_seq_num
       AND  item.NAMED_RULE in(30171, 30172, 30173, 30174, 30175,30176,30177,30178, 30174, -- Adreess
                               30181,30182,30183,30184, -- Military Services
                               30185, --  Person Disability
                               30186, -- Citizenship status (Bug Person Stats )
			       30187, -- Citizenship
			       30188, 30189, -- Pe Results
                               30190, -- Pe Teaching Periods
			       30246,30247,30248,30249,30250,30251,30252,30253,30254, -- AD Test Results Details
			       30192,30193,30194,30195,30196,30197,30198,30199,30200,30201,30202,30203,30204,30205,30206,30207,53211 -- Acad Hist
			       30208,30209,30210,30211,30212,30213,30230,30231,30232,30233 -- Extra Curicular activities
			       30236,30237,30238,30239,30240,30241,30242,30243,30244,30245,30248,30249,30250,30251,30252,30253,30254, -- AD Test Results
			       30275 , 	   -- App Intent
			       30276, -- Ad Acad Interest
			       30277, -- Spl Interest
			       30278, -- Spl Talent
			       30279,30280,  -- UnitSets
			       30281, -- Other Institutions
			       30282,30283, -- Athletic PRG
                               30286,30287  -- Pe Acad Honors
 			       );	     */





       lv_trk_types  TRK_TYPE;
       lv_tmp_trk    TRK_TYPE;
       lv_emp_trk    TRK_TYPE;

       lv_rowid_per_addr    igs_pe_person_addr.row_id%TYPE;
       lv_rowid_mil_serv    igs_pe_mil_services.row_id%TYPE;
       lv_rowid_pers_dis    igs_pe_pers_disablty_v.row_id%TYPE;
--       lv_rowid_pe_stat     igs_pe_stat_v.row_id%TYPE;
       lv_rowid_pe_citizen_status  igs_pe_eit_restatus_v.row_id%TYPE;
       lv_rowid_pe_ctz      igs_pe_citizenship_v.row_id%TYPE;
       lv_rowid_pe_res      igs_pe_res_dtls.row_id%TYPE;
       lv_rowid_pe_teach    igs_pe_teach_periods_v.row_id%TYPE;
       lv_rowid_tst_rslt    igs_ad_tst_rslt_dtls_v.row_id%TYPE;
       lv_rowid_acad_hist   igs_ad_acad_history_v.row_id%TYPE;
       lv_rowid_extr_act    igs_ad_extracurr_act_v.row_id%TYPE;
       lv_rowid_test_rslt   igs_ad_test_results_v.row_id%TYPE;
       lv_rowid_app_int     igs_ad_app_intent_v.row_id%TYPE;
       lv_rowid_acad_int    igs_ad_acad_interest_v.row_id%TYPE;
       lv_rowid_spl_int     igs_ad_spl_interests_v.row_id%TYPE;
       lv_rowid_spl_tal     IGS_AD_SPL_TALENTS_V.row_id%TYPE;
       lv_rowid_unit_set    IGS_AD_UNIT_SETS_V.row_id%TYPE;
       lv_rowid_oth_inst    IGS_AD_OTHER_INST_V.row_id%TYPE;
       lv_rowid_ath         IGS_PE_ATHLETIC_PRG_V.row_id%TYPE;       -- bug 2794983
       lv_rowid_acad_hon    igs_pe_acad_honors_v.row_id%TYPE;


       TYPE rowid_type IS TABLE OF igs_pe_person_addr.row_id%TYPE  INDEX BY BINARY_INTEGER;


       rowid_per_addr_table  rowid_type;
       rowid_mil_serv_table  rowid_type;
       rowid_pers_dis_table  rowid_type;
--       rowid_pe_stat_table   rowid_type;
       rowid_pe_ctzen_stat_table rowid_type;
       rowid_pe_ctz_table    rowid_type;
       rowid_pe_res_table    rowid_type;
       rowid_pe_teach_table  rowid_type;
       rowid_tst_rslt_dtl_table  rowid_type;
       rowid_acad_hist_table rowid_type;
       rowid_extr_act_table  rowid_type;
       rowid_test_rslt_table rowid_type;
       rowid_app_int_table   rowid_type;
       rowid_acad_int_table  rowid_type;
       rowid_spl_int_table   rowid_type;
       rowid_spl_tal_table   rowid_type;
       rowid_unit_set_table  rowid_type;
       rowid_oth_inst_table  rowid_type;
       rowid_ath_table       rowid_type;
       rowid_acad_hon_table  rowid_type;



       lv_message    VARCHAR2(2000);
       lv_result     VARCHAR2(2000);

    -- CONSTANTS
       cst_start     CONSTANT VARCHAR2(1) := 'S';
       cst_processed CONSTANT VARCHAR2(1) := 'P';

       lv_per_addr_index     VARCHAR2(1);
       lv_mil_serv_index     VARCHAR2(1);
       lv_pers_dis_index     VARCHAR2(1);
--       lv_pe_stat_index      VARCHAR2(1);
       lv_pe_citz_stat_index      VARCHAR2(1);
       lv_pe_ctz_index       VARCHAR2(1);
       lv_pe_res_index       VARCHAR2(1);
       lv_pe_teach_index     VARCHAR2(1);
       lv_tst_rslt_dtls_index     VARCHAR2(1);
       lv_acad_hist_index    VARCHAR2(1);
       lv_extr_act_index     VARCHAR2(1);
       lv_test_rslt_index    VARCHAR2(1);
       lv_app_int_index      VARCHAR2(1);
       lv_acad_int_index     VARCHAR2(1);
       lv_spl_int_index      VARCHAR2(1);
       lv_spl_tal_index      VARCHAR2(1);
       lv_unit_set_index     VARCHAR2(1);
       lv_oth_inst_index     VARCHAR2(1);
       lv_ath_index          VARCHAR2(1);
       lv_acad_hon_index     VARCHAR2(1);



       -- FLAG to check if the PL/SQL table already has this value
       lv_exist     VARCHAR2(1);

       -- Variable to store the tracking type temporarily to check with the PL/SQL table
       -- and to populate it if the table does not hold this value
       lv_store    VARCHAR2(500);

       --Variable to know whether the else PL/SQL table is populated
       lv_tmp_pop  VARCHAR2(1);

       --Variable to know whether the IF Condition is satisfied
       lv_if_sat  VARCHAR2(1);

       lv_rul_sequence_number igs_ad_apctr_ru.rul_sequence_number%TYPE;


       FUNCTION is_rul_item_exists ( p_rul_seq_num NUMBER, p_rul_item_seq_num_set VARCHAR2) RETURN BOOLEAN IS

        TYPE rul_items_cur_type IS REF CURSOR;
        c_rule_items   rul_items_cur_type;
	l_exists NUMBER := 0;

        CURSOR c_rule IS
	SELECT RULE_NUMBER FROM IGS_RU_ITEM item
	WHERE item.RUL_SEQUENCE_NUMBER = p_rul_seq_num
	AND rule_number is NOT NULL
	ORDER BY item desc;
	l_nest_rule_exists BOOLEAN;

       BEGIN
              OPEN c_rule_items  FOR
	      ' SELECT 1 FROM  IGS_RU_ITEM item ' ||
              ' WHERE item.RUL_SEQUENCE_NUMBER =  :1 ' ||
              ' AND  item.NAMED_RULE in (' || p_rul_item_seq_num_set || ') '
	      USING p_rul_seq_num ;

	      FETCH c_rule_items INTO l_exists;
	      CLOSE c_rule_items;
              IF (l_exists = 1) then
	        return TRUE;
	      ELSE
                FOR c_rule_rec IN c_rule LOOP
		  l_nest_rule_exists := is_rul_item_exists(c_rule_rec.rule_number, p_rul_item_seq_num_set);
		  IF l_nest_rule_exists THEN
		    RETURN TRUE;
		  END IF;
		END LOOP;
  	        RETURN FALSE;
              END IF;
       EXCEPTION
       WHEN OTHERS THEN
         -- DBMS_OUTPUT.PUT_LINE('EXception ' || SQLERRM);
          return FALSE;
       END;

    BEGIN

       lv_if_sat := 'N';

       /* The PL/SQL table for the IF condition is emptied */
       lv_trk_types := lv_emp_trk;


       /* Open all the loops so that the rule gets processed for every record of each person */
       OPEN c_rule;
       LOOP
         FETCH  c_rule INTO lv_rul_sequence_number;
         EXIT WHEN c_rule%NOTFOUND;

         /* The PL/SQL table for the ELSE condition is emptied */
         lv_tmp_trk   := lv_emp_trk;

         lv_tmp_pop := 'N';

         lv_if_sat := 'N';


       l_address_rule_exists            := is_rul_item_exists(lv_rul_sequence_number,l_address_rule_num);
       l_military_rule_exists           := is_rul_item_exists(lv_rul_sequence_number,l_military_rule_num);
       l_pers_disability_rule_exists    := is_rul_item_exists(lv_rul_sequence_number,l_pers_disability_rule_num);
       l_citizen_status_rule_exists     := is_rul_item_exists(lv_rul_sequence_number,l_citizen_status_rule_num);
       l_citizenship_rule_exists        := is_rul_item_exists(lv_rul_sequence_number,l_citizenship_rule_num);
       l_pe_results_rule_exists         := is_rul_item_exists(lv_rul_sequence_number,l_pe_results_rule_num);
       l_pe_teaching_exists             := is_rul_item_exists(lv_rul_sequence_number,l_pe_teaching_num);
       l_ad_tst_rslt_dtl_rule_exists    := is_rul_item_exists(lv_rul_sequence_number,l_ad_test_rslt_dtls_rule_num);
       l_acad_hist_rule_exists          := is_rul_item_exists(lv_rul_sequence_number,l_acad_hist_rule_num);
       l_extra_cur_rule_exists          := is_rul_item_exists(lv_rul_sequence_number,l_extra_cur_rule_num);
       l_ad_test_rslt_rule_exists       := is_rul_item_exists(lv_rul_sequence_number,l_ad_test_rslt_rule_num);
       l_app_intent_rule_exists         := is_rul_item_exists(lv_rul_sequence_number,l_app_intent_rule_num);
       l_acad_interest_rule_exists      := is_rul_item_exists(lv_rul_sequence_number,l_acad_interest_rule_num);
       l_spl_interest_rule_exists       := is_rul_item_exists(lv_rul_sequence_number,l_spl_interest_rule_num);
       l_spl_talent_rule_exists         := is_rul_item_exists(lv_rul_sequence_number,l_spl_talent_rule_num);
       l_unit_sets_rule_exists          := is_rul_item_exists(lv_rul_sequence_number,l_unit_sets_rule_num);
       l_other_inst_rule_exists         := is_rul_item_exists(lv_rul_sequence_number,l_other_inst_rule_num);
       l_athl_prog_rule_exists          := is_rul_item_exists(lv_rul_sequence_number,l_athl_prog_rule_num);
       l_pe_acad_hnrs_rule_exists       := is_rul_item_exists(lv_rul_sequence_number,l_pe_acad_hnrs_rule_num);




     IF rowid_per_addr_table.count = 0  AND   l_address_rule_exists THEN

       OPEN  c_igs_pe_person_addr;
       FETCH c_igs_pe_person_addr	BULK COLLECT INTO rowid_per_addr_table  ;
       IF c_igs_pe_person_addr%ISOPEN THEN
           CLOSE c_igs_pe_person_addr;
       END IF;
     END IF;

      IF rowid_mil_serv_table.count = 0 AND  l_military_rule_exists THEN
        OPEN  c_igs_pe_mil_services;
        FETCH c_igs_pe_mil_services BULK COLLECT INTO rowid_mil_serv_table  ;
        IF c_igs_pe_mil_services%ISOPEN THEN
           CLOSE c_igs_pe_mil_services;
        END IF;
      END IF;


      IF rowid_pers_dis_table.count = 0 AND l_pers_disability_rule_exists THEN
        OPEN  c_igs_pe_pers_disablty_v;
        FETCH c_igs_pe_pers_disablty_v BULK COLLECT INTO rowid_pers_dis_table  ;
        IF c_igs_pe_pers_disablty_v%ISOPEN THEN
           CLOSE c_igs_pe_pers_disablty_v;
        END IF;
      END IF;


      IF rowid_pe_ctzen_stat_table.count = 0 AND l_citizen_status_rule_exists THEN
        OPEN  c_igs_pe_citizenship_status;
        FETCH c_igs_pe_citizenship_status BULK COLLECT INTO rowid_pe_ctzen_stat_table   ;
        IF c_igs_pe_citizenship_status%ISOPEN THEN
           CLOSE c_igs_pe_citizenship_status;
        END IF;
      END IF;

      IF rowid_pe_ctz_table.count = 0 AND l_citizenship_rule_exists THEN
        OPEN  c_igs_pe_citizenship_v;
        FETCH c_igs_pe_citizenship_v BULK COLLECT INTO rowid_pe_ctz_table    ;
        IF c_igs_pe_citizenship_v%ISOPEN THEN
           CLOSE c_igs_pe_citizenship_v;
        END IF;
      END IF;

      IF rowid_pe_res_table.count = 0 AND l_pe_results_rule_exists THEN
        OPEN  c_igs_pe_res_dtls;
        FETCH c_igs_pe_res_dtls BULK COLLECT INTO rowid_pe_res_table    ;
        IF c_igs_pe_res_dtls%ISOPEN THEN
           CLOSE c_igs_pe_res_dtls;
        END IF;
      END IF;

      IF rowid_pe_teach_table.count = 0 AND l_pe_teaching_exists THEN
        OPEN  c_igs_pe_teach_periods_v;
        FETCH c_igs_pe_teach_periods_v BULK COLLECT INTO rowid_pe_teach_table  ;
        IF c_igs_pe_teach_periods_v%ISOPEN THEN
           CLOSE c_igs_pe_teach_periods_v;
        END IF;
      END IF;

      IF rowid_tst_rslt_dtl_table.count = 0 AND l_ad_tst_rslt_dtl_rule_exists THEN
        OPEN  c_igs_ad_tst_rslt_dtls_v;
        FETCH c_igs_ad_tst_rslt_dtls_v BULK COLLECT INTO rowid_tst_rslt_dtl_table  ;
        IF c_igs_ad_tst_rslt_dtls_v%ISOPEN THEN
           CLOSE c_igs_ad_tst_rslt_dtls_v;
        END IF;
      END IF;

      IF rowid_acad_hist_table.count = 0 AND l_acad_hist_rule_exists THEN
        OPEN  c_igs_ad_acad_history_v;
        FETCH c_igs_ad_acad_history_v BULK COLLECT INTO rowid_acad_hist_table ;
        IF c_igs_ad_acad_history_v%ISOPEN THEN
           CLOSE c_igs_ad_acad_history_v;
        END IF;
      END IF;

      IF rowid_extr_act_table.count = 0 AND l_extra_cur_rule_exists THEN
        OPEN  c_igs_ad_extracurr_act_v;
        FETCH c_igs_ad_extracurr_act_v BULK COLLECT INTO rowid_extr_act_table  ;
        IF c_igs_ad_extracurr_act_v%ISOPEN THEN
           CLOSE c_igs_ad_extracurr_act_v;
        END IF;
      END IF;

      IF rowid_test_rslt_table.count = 0 AND l_ad_test_rslt_rule_exists THEN
        OPEN  c_igs_ad_test_results_v;
        FETCH c_igs_ad_test_results_v BULK COLLECT INTO rowid_test_rslt_table ;
        IF c_igs_ad_test_results_v%ISOPEN THEN
           CLOSE c_igs_ad_test_results_v;
        END IF;
      END IF;

      IF rowid_app_int_table.count = 0 AND l_app_intent_rule_exists THEN
        OPEN  c_igs_ad_app_intent_v;
        FETCH c_igs_ad_app_intent_v BULK COLLECT INTO rowid_app_int_table   ;
        IF c_igs_ad_app_intent_v%ISOPEN THEN
           CLOSE c_igs_ad_app_intent_v;
        END IF;
      END IF;

      IF rowid_acad_int_table.count = 0 AND l_acad_interest_rule_exists THEN
        OPEN  c_igs_ad_acad_interest_v;
        FETCH c_igs_ad_acad_interest_v BULK COLLECT INTO rowid_acad_int_table  ;
        IF c_igs_ad_acad_interest_v%ISOPEN THEN
           CLOSE c_igs_ad_acad_interest_v;
        END IF;
      END IF;

      IF rowid_spl_int_table.count = 0 AND l_spl_interest_rule_exists THEN
        OPEN  c_igs_ad_spl_interests_v;
        FETCH c_igs_ad_spl_interests_v BULK COLLECT INTO rowid_spl_int_table   ;
        IF c_igs_ad_spl_interests_v%ISOPEN THEN
           CLOSE c_igs_ad_spl_interests_v;
        END IF;
      END IF;

      IF rowid_spl_tal_table.count = 0 AND l_spl_talent_rule_exists THEN
        OPEN  c_igs_ad_spl_talents_v;
        FETCH c_igs_ad_spl_talents_v BULK COLLECT INTO rowid_spl_tal_table   ;
        IF c_igs_ad_spl_talents_v%ISOPEN THEN
           CLOSE c_igs_ad_spl_talents_v;
        END IF;
      END IF;

      IF rowid_unit_set_table.count = 0 AND l_unit_sets_rule_exists THEN
        OPEN  c_igs_ad_unit_sets_v;
        FETCH c_igs_ad_unit_sets_v BULK COLLECT INTO rowid_unit_set_table  ;
        IF c_igs_ad_unit_sets_v%ISOPEN THEN
           CLOSE c_igs_ad_unit_sets_v;
        END IF;
      END IF;

      IF rowid_oth_inst_table.count = 0 AND l_other_inst_rule_exists THEN
        OPEN  c_igs_ad_other_inst_v;
        FETCH c_igs_ad_other_inst_v BULK COLLECT INTO rowid_oth_inst_table  ;
        IF c_igs_ad_other_inst_v%ISOPEN THEN
           CLOSE c_igs_ad_other_inst_v;
        END IF;
      END IF;

      IF rowid_ath_table.count = 0 AND l_athl_prog_rule_exists THEN
        OPEN  c_igs_pe_athletic_prg_v;
        FETCH c_igs_pe_athletic_prg_v BULK COLLECT INTO rowid_ath_table       ;
        IF c_igs_pe_athletic_prg_v%ISOPEN THEN
           CLOSE c_igs_pe_athletic_prg_v;
        END IF;
      END IF;

      IF rowid_acad_hon_table.count = 0 AND l_pe_acad_hnrs_rule_exists THEN
        OPEN  c_igs_pe_acad_honors_v;
        FETCH c_igs_pe_acad_honors_v BULK COLLECT INTO rowid_acad_hon_table  ;
        IF c_igs_pe_acad_honors_v%ISOPEN THEN
           CLOSE c_igs_pe_acad_honors_v;
        END IF;
      END IF;


         lv_per_addr_index := rowid_per_addr_table.FIRST;

         LOOP

           IF lv_per_addr_index IS NOT NULL THEN
              lv_rowid_per_addr := rowid_per_addr_table(lv_per_addr_index);
           END IF;
            lv_mil_serv_index    		     := rowid_mil_serv_table.FIRST;

           LOOP

             IF lv_mil_serv_index IS NOT NULL THEN
                lv_rowid_mil_serv := rowid_mil_serv_table(lv_mil_serv_index);
             END IF;
             lv_pers_dis_index     	   := rowid_pers_dis_table.FIRST;

             LOOP

              IF lv_pers_dis_index IS NOT NULL THEN
                 lv_rowid_pers_dis := rowid_pers_dis_table(lv_pers_dis_index);
              END IF;
               lv_pe_citz_stat_index     	   := rowid_pe_ctzen_stat_table.FIRST;

               LOOP

                 IF lv_pe_citz_stat_index IS NOT NULL THEN
                   lv_rowid_pe_citizen_status := rowid_pe_ctzen_stat_table(lv_pe_citz_stat_index);
                 END IF;
                 lv_pe_ctz_index      	   := rowid_pe_ctz_table.FIRST;

                 LOOP

                   IF lv_pe_ctz_index IS NOT NULL THEN
                     lv_rowid_pe_ctz := rowid_pe_ctz_table(lv_pe_ctz_index);
                   END IF;
                   lv_pe_res_index      	   := rowid_pe_res_table.FIRST;

                   LOOP

                     IF lv_pe_res_index IS NOT NULL THEN
                       lv_rowid_pe_res := rowid_pe_res_table(lv_pe_res_index);
                     END IF;
                     lv_pe_teach_index    	   := rowid_pe_teach_table.FIRST;

                     LOOP

                       IF lv_pe_teach_index IS NOT NULL THEN
                         lv_rowid_pe_teach := rowid_pe_teach_table(lv_pe_teach_index);
                       END IF;

                       lv_tst_rslt_dtls_index	   := rowid_tst_rslt_dtl_table.FIRST;

                       LOOP

                         IF lv_tst_rslt_dtls_index IS NOT NULL THEN
                           lv_rowid_tst_rslt := rowid_tst_rslt_dtl_table(lv_tst_rslt_dtls_index);
                         END IF;
                         lv_acad_hist_index   	   := rowid_acad_hist_table.FIRST;

                         LOOP

                            IF lv_acad_hist_index IS NOT NULL THEN
                              lv_rowid_acad_hist := rowid_acad_hist_table(lv_acad_hist_index);
                            END IF;
                            lv_extr_act_index    	   := rowid_extr_act_table.FIRST;

                           LOOP

                              IF lv_extr_act_index IS NOT NULL THEN
                                lv_rowid_extr_act := rowid_extr_act_table(lv_extr_act_index);
                               END IF;
                             lv_test_rslt_index   	   := rowid_test_rslt_table.FIRST;

                             LOOP

                                IF lv_test_rslt_index IS NOT NULL THEN
                                  lv_rowid_test_rslt := rowid_test_rslt_table(lv_test_rslt_index);
                                END IF;
                               lv_app_int_index     	   := rowid_app_int_table.FIRST;

                               LOOP

                                  IF lv_app_int_index IS NOT NULL THEN
                                    lv_rowid_app_int := rowid_app_int_table(lv_app_int_index);
                                  END IF;
                                 lv_acad_int_index    	   := rowid_acad_int_table.FIRST;

                                 LOOP


                                    IF lv_acad_int_index IS NOT NULL THEN
                                      lv_rowid_acad_int := rowid_acad_int_table(lv_acad_int_index);
                                    END IF;
                                   lv_spl_int_index     	   := rowid_spl_int_table.FIRST;

                                   LOOP

                                      IF lv_spl_int_index IS NOT NULL THEN
                                        lv_rowid_spl_int := rowid_spl_int_table(lv_spl_int_index);
                                      END IF;
                                     lv_spl_tal_index     	   := rowid_spl_tal_table.FIRST;

                                     LOOP

                                        IF lv_spl_tal_index IS NOT NULL THEN
                                          lv_rowid_spl_tal := rowid_spl_tal_table(lv_spl_tal_index);
                                        END IF;
                                       lv_unit_set_index    	   := rowid_unit_set_table.FIRST;

                                       LOOP

                                          IF lv_unit_set_index IS NOT NULL THEN
                                            lv_rowid_unit_set := rowid_unit_set_table(lv_unit_set_index);
                                          END IF;
                                         lv_oth_inst_index    	   := rowid_oth_inst_table.FIRST;

                                         LOOP

                                            IF lv_oth_inst_index IS NOT NULL THEN
                                              lv_rowid_oth_inst := rowid_oth_inst_table(lv_oth_inst_index);
                                            END IF;
                                           lv_ath_index         	   := rowid_ath_table.FIRST;

                                           LOOP

                                             IF lv_ath_index IS NOT NULL THEN
                                               lv_rowid_ath := rowid_ath_table(lv_ath_index);
                                             END IF;
                                             lv_acad_hon_index    	   := rowid_acad_hon_table.FIRST;

                                             LOOP

                                               IF lv_acad_hon_index IS NOT NULL THEN
                                                 lv_rowid_acad_hon := rowid_acad_hon_table(lv_acad_hon_index);
                                               END IF;

                                               lv_result:= NULL;
                                               BEGIN
                                                 lv_result := igs_ru_gen_001.rulp_val_senna
                                                                 (
                                                                  P_RULE_CALL_NAME  => 'AD-TRK-SET',
                                                                  P_PERSON_ID       => p_person_id,
                                                                  P_MESSAGE         => lv_message,
                                                                  P_RULE_NUMBER     => lv_rul_sequence_number,
                                                                  P_PARAM_1         => p_admission_appl_number,
                                                                  P_PARAM_2         => p_nominated_prg_cd,
                                                                  P_PARAM_3         => p_adm_sequence_number,
                                                                  P_PARAM_10        => ''''||lv_rowid_per_addr||'''',
                                                                  P_PARAM_11        => ''''||lv_rowid_mil_serv||'''',
                                                                  P_PARAM_12        => ''''||lv_rowid_pers_dis||'''',
                                                                  P_PARAM_13        => ''''||lv_rowid_pe_citizen_status||'''',
                                                                  P_PARAM_14        => ''''||lv_rowid_pe_ctz||'''',
                                                                  P_PARAM_15        => ''''||lv_rowid_pe_res||'''',
                                                                  P_PARAM_16        => ''''||lv_rowid_pe_teach||'''',
                                                                  P_PARAM_17        => ''''||lv_rowid_tst_rslt||'''',
                                                                  P_PARAM_18        => ''''||lv_rowid_acad_hist||'''',
                                                                  P_PARAM_19        => ''''||lv_rowid_extr_act||'''',
                                                                  P_PARAM_21        => ''''||lv_rowid_test_rslt||'''',
                                                                  P_PARAM_22        => ''''||lv_rowid_app_int||'''',
                                                                  P_PARAM_23        => ''''||lv_rowid_acad_int||'''',
                                                                  P_PARAM_24        => ''''||lv_rowid_spl_int||'''',
                                                                  P_PARAM_25        => ''''||lv_rowid_spl_tal||'''',
                                                                  P_PARAM_26        => ''''||lv_rowid_unit_set||'''',
                                                                  P_PARAM_27        => ''''||lv_rowid_oth_inst||'''',
                                                                  P_PARAM_28        => ''''||lv_rowid_ath||'''',
                                                                  P_PARAM_29        => ''''||lv_rowid_acad_hon||''''
                                                                  );
                                               EXCEPTION
                                                 WHEN OTHERS THEN
						   NULL;
						   /*
						   No need to display in log, since has nothing to do with user defined rule
						   but parsing and evaluation of the same through code and system defined rule
						   If it fails here need to debug igs_ru_gen_001.rulp_val_senna

                                                   fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
                                                   fnd_message.set_token('NAME','IGS_AD_ADM_REQ.admp_get_trk_types - SQL Error is :'||SQLERRM);
                                                   log_detail(FND_MESSAGE.GET);
						   */
                                               END;

                                               IF lv_result IS NOT NULL THEN
                                                 lv_result := ltrim(rtrim(lv_result));
                                                 lv_result := substr(lv_result,(instr(lv_result,'{')+1),(instr(lv_result,'}')-2))||',';
                                               END IF;

                                               WHILE lv_result IS NOT NULL
                                               LOOP
                                                 lv_store  := substr(lv_result,1,(instr(lv_result,',') - 1));
                                                 lv_exist  := 'N';
                                                 lv_result := substr(lv_result,(instr(lv_result,',')+2));

                                                 /* This PL/SQL table is to populate the tracking types which are not a part of the ELSE condition*/
                                                 IF NVL(igs_ru_gen_001.p_evaluated_part,'*') <> 'ELSE' THEN
                                                   /* If the IF condition is satisfied then do not process the rule further.Hence this Flag is activated
                                                      and do not populated the same tracking types again.*/
                                                   lv_if_sat := 'Y';
                                                   IF NVL(lv_trk_types.count,0) <> 0 THEN
                                                     FOR i in 1..lv_trk_types.count
                                                     LOOP
                                                       IF lv_trk_types(i) = lv_store THEN
                                                         lv_exist := 'Y';
                                                         EXIT WHEN NVL(lv_exist,'N') = 'Y';
                                                       END IF;
                                                     END LOOP;
                                                   END IF;

                                                   IF lv_exist = 'N' THEN
                                                     lv_trk_types(NVL(lv_trk_types.last,0)+1) := lv_store;
                                                   END IF;

                                                 ELSE
                                                   /* This PL/SQL table is to populate the tracking types which are a part of the ELSE condition*/
                                                   IF NVL(lv_tmp_pop,'N') <> 'Y' THEN
                                                     IF NVL(lv_tmp_trk.count,0) <> 0 THEN
                                                       FOR i in 1..lv_tmp_trk.count
                                                       LOOP
                                                         IF lv_tmp_trk(i) = lv_store THEN
                                                           lv_exist := 'Y';
                                                           EXIT WHEN NVL(lv_exist,'N') = 'Y';
                                                         END IF;
                                                       END LOOP;
                                                     END IF;

                                                     IF lv_exist = 'N' THEN
                                                       lv_tmp_trk(NVL(lv_tmp_trk.last,0)+1) := lv_store;
                                                     END IF;

                                                   END IF;
                                                 END IF;
                                               END LOOP;

                                               /* To activate the flag to indicate that the else PL/SQL table has been populated */
                                               IF NVL(lv_tmp_trk.count,0) <> 0 AND NVL(lv_tmp_pop,'N')<> 'Y' THEN
                                                 lv_tmp_pop := 'Y';
                                               END IF;
                                               IF lv_acad_hon_index IS NOT NULL THEN
                                                lv_acad_hon_index := rowid_acad_hon_table.NEXT(lv_acad_hon_index);
                                               END IF;
                                               EXIT WHEN (lv_acad_hon_index IS NULL  OR   NOT l_pe_acad_hnrs_rule_exists OR lv_if_sat = 'Y' );

                                             END LOOP;

                                             IF lv_ath_index IS NOT NULL THEN
                                               lv_ath_index := rowid_ath_table.NEXT(lv_ath_index);
                                             END IF;
                                             EXIT WHEN (lv_ath_index IS NULL  OR   NOT l_athl_prog_rule_exists OR lv_if_sat = 'Y' );

                                           END LOOP;

                                           IF lv_oth_inst_index IS NOT NULL THEN
                                             lv_oth_inst_index := rowid_oth_inst_table.NEXT(lv_oth_inst_index);
                                           END IF;
                                           EXIT WHEN (lv_oth_inst_index IS NULL  OR   NOT l_other_inst_rule_exists OR lv_if_sat = 'Y' );

                                         END LOOP;

                                         IF lv_unit_set_index IS NOT NULL THEN
                                           lv_unit_set_index := rowid_unit_set_table.NEXT(lv_unit_set_index);
                                         END IF;
                                         EXIT WHEN (lv_unit_set_index IS NULL  OR   NOT l_unit_sets_rule_exists OR lv_if_sat = 'Y' );

                                       END LOOP;

                                       IF lv_spl_tal_index IS NOT NULL THEN
                                         lv_spl_tal_index := rowid_spl_tal_table.NEXT(lv_spl_tal_index);
                                       END IF;
                                       EXIT WHEN (lv_spl_tal_index IS NULL  OR   NOT l_spl_talent_rule_exists OR lv_if_sat = 'Y' );

                                     END LOOP;

                                     IF lv_spl_int_index IS NOT NULL THEN
                                       lv_spl_int_index := rowid_spl_int_table.NEXT(lv_spl_int_index);
                                     END IF;
                                     EXIT WHEN (lv_spl_int_index IS NULL  OR   NOT l_spl_interest_rule_exists OR lv_if_sat = 'Y' );

                                   END LOOP;

                                   IF lv_acad_int_index IS NOT NULL THEN
                                     lv_acad_int_index := rowid_acad_int_table.NEXT(lv_acad_int_index);
                                   END IF;
                                   EXIT WHEN (lv_acad_int_index IS NULL  OR   NOT l_acad_interest_rule_exists OR lv_if_sat = 'Y' );

                                 END LOOP;

                                 IF lv_app_int_index IS NOT NULL THEN
                                    lv_app_int_index := rowid_app_int_table.NEXT(lv_app_int_index);
                                 END IF;
                                 EXIT WHEN (lv_app_int_index IS NULL  OR   NOT l_app_intent_rule_exists OR lv_if_sat = 'Y' );
                               END LOOP;

                               IF lv_test_rslt_index IS NOT NULL THEN
                                 lv_test_rslt_index := rowid_test_rslt_table.NEXT(lv_test_rslt_index);
                               END IF;
                               EXIT WHEN (lv_test_rslt_index IS NULL  OR   NOT l_ad_test_rslt_rule_exists OR lv_if_sat = 'Y' );
                             END LOOP;

                             IF lv_extr_act_index IS NOT NULL THEN
                               lv_extr_act_index := rowid_extr_act_table.NEXT(lv_extr_act_index);
                             END IF;
                             EXIT WHEN (lv_extr_act_index IS NULL  OR   NOT l_extra_cur_rule_exists OR lv_if_sat = 'Y' );
                           END LOOP;

                           IF lv_acad_hist_index IS NOT NULL THEN
                             lv_acad_hist_index := rowid_acad_hist_table.NEXT(lv_acad_hist_index);
                           END IF;
                           EXIT WHEN (lv_acad_hist_index IS NULL  OR   NOT l_acad_hist_rule_exists OR lv_if_sat = 'Y' );
                         END LOOP;

                         IF lv_tst_rslt_dtls_index IS NOT NULL THEN
                           lv_tst_rslt_dtls_index := rowid_tst_rslt_dtl_table.NEXT(lv_tst_rslt_dtls_index);
                         END IF;
                         EXIT WHEN (lv_tst_rslt_dtls_index IS NULL  OR   NOT l_ad_tst_rslt_dtl_rule_exists OR lv_if_sat = 'Y' );
                       END LOOP;

                       IF lv_pe_teach_index IS NOT NULL THEN
                         lv_pe_teach_index := rowid_pe_teach_table.NEXT(lv_pe_teach_index);
                       END IF;
                       EXIT WHEN (lv_pe_teach_index IS NULL  OR   NOT l_pe_teaching_exists OR lv_if_sat = 'Y' );
                     END LOOP;

                     IF lv_pe_res_index IS NOT NULL THEN
                       lv_pe_res_index := rowid_pe_res_table.NEXT(lv_pe_res_index);
                     END IF;
                     EXIT WHEN (lv_pe_res_index IS NULL  OR   NOT l_pe_results_rule_exists OR lv_if_sat = 'Y' );
                   END LOOP;

                   IF lv_pe_ctz_index IS NOT NULL THEN
                     lv_pe_ctz_index := rowid_pe_ctz_table.NEXT(lv_pe_ctz_index);
                   END IF;
                   EXIT WHEN (lv_pe_ctz_index IS NULL  OR   NOT l_citizenship_rule_exists OR lv_if_sat = 'Y' );
                 END LOOP;

                 IF lv_pe_citz_stat_index IS NOT NULL THEN
                   lv_pe_citz_stat_index := rowid_pe_ctzen_stat_table.NEXT(lv_pe_citz_stat_index);
                 END IF;
                 EXIT WHEN (lv_pe_citz_stat_index IS NULL  OR   NOT l_citizen_status_rule_exists OR lv_if_sat = 'Y' );
               END LOOP;

               IF lv_pers_dis_index IS NOT NULL THEN
                 lv_pers_dis_index := rowid_pers_dis_table.NEXT(lv_pers_dis_index);
               END IF;
               EXIT WHEN (lv_pers_dis_index IS NULL  OR   NOT l_pers_disability_rule_exists OR lv_if_sat = 'Y' );
             END LOOP;

             IF lv_mil_serv_index IS NOT NULL THEN
                 lv_mil_serv_index := rowid_mil_serv_table.NEXT(lv_mil_serv_index);
             END IF;
             EXIT WHEN (lv_mil_serv_index IS NULL  OR   NOT l_military_rule_exists OR lv_if_sat = 'Y' );
           END LOOP;

           IF lv_per_addr_index IS NOT NULL THEN
               lv_per_addr_index := rowid_per_addr_table.NEXT(lv_per_addr_index);
           END IF;
           EXIT WHEN (lv_per_addr_index IS NULL  OR   NOT l_address_rule_exists OR lv_if_sat = 'Y' );
         END LOOP;

         /* Assign the tracking types returned from the else clause to
            the return value if the PL/SQL table is not returning anything */

         IF NVL(lv_if_sat,'N') = 'N' AND NVL(lv_tmp_pop,'N') = 'Y' THEN
           -- Tracking types from previous rules IF set exist
           IF NVL(lv_trk_types.count,0) <> 0 THEN
             FOR k in lv_tmp_trk.first..lv_tmp_trk.last
             LOOP
               lv_exist := 'N';
               FOR l in lv_trk_types.first..lv_trk_types.last
               LOOP
                 IF lv_trk_types(l) = lv_tmp_trk(k) THEN
                   lv_exist := 'Y';
                   EXIT WHEN lv_exist = 'Y';
                 END IF;
               END LOOP;
               IF NVL(lv_exist,'N') = 'N' THEN
                 lv_trk_types(NVL(lv_trk_types.last,0) + 1)  := lv_tmp_trk(k);
               END IF;
             END LOOP;

           -- Tracking types from previous rules IF set do not exist
           ELSE
             FOR k in lv_tmp_trk.first..lv_tmp_trk.last
             LOOP
               lv_trk_types(NVL(lv_trk_types.count,0)) := lv_tmp_trk(k);
             END LOOP;
           END IF;
         END IF;

       END LOOP;
       CLOSE c_rule;

       RETURN lv_trk_types;
     EXCEPTION
       WHEN OTHERS THEN
              IF c_rule%ISOPEN THEN
                  CLOSE c_rule;
              END IF;
	      RETURN lv_emp_trk;
     END admp_get_trk_types;



END igs_ad_adm_req;

/
