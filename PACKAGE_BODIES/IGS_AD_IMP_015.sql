--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_015
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_015" AS
/* $Header: IGSAD93B.pls 120.2 2006/04/13 05:52:53 stammine ship $ */

/******************************************************************
Created By : knag
Date Created By : 05-NOV-2003
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
rbezawad   27-Feb-05     Added code to procedures prc_ad_category(), del_cmpld_ad_records() to execute a Dynamic Code block
                         when IGR functionality is enabled.   In store_ad_stats() procedure, changed Recruitment table
                         names to IGR_% naming convention.  Also deleted package variables related to inquiry.
******************************************************************/
  -- These are the package variables to hold the value of whether the particular category is included or not.
  g_application_inc               BOOLEAN := FALSE;
  g_person_qual_inc               BOOLEAN := FALSE;
  g_person_recruit_dtls_inc       BOOLEAN := FALSE;
  g_test_result_inc               BOOLEAN := FALSE;
  g_transcript_dtls_inc           BOOLEAN := FALSE;
  g_applicant_oth_inst_appl_inc   BOOLEAN := FALSE;
  g_applicant_acad_int_inc        BOOLEAN := FALSE;
  g_applicant_appl_intent_inc     BOOLEAN := FALSE;
  g_applicant_spl_int_inc         BOOLEAN := FALSE;
  g_applicant_spl_tal_inc         BOOLEAN := FALSE;
  g_applicant_per_stat_inc        BOOLEAN := FALSE;
  g_applicant_fee_dtls_inc        BOOLEAN := FALSE;
  g_applicant_notes_inc           BOOLEAN := FALSE;
  g_applicant_des_unit_sets_inc   BOOLEAN := FALSE;
  g_applicant_edu_goal_inc        BOOLEAN := FALSE;
  g_applicant_hist_inc            BOOLEAN := FALSE;

  PROCEDURE sel_ad_src_cat_imp (p_source_type_id IN NUMBER,
                             p_batch_id IN NUMBER,
                             p_enable_log IN VARCHAR2,
                             p_legacy_ind IN VARCHAR2
  ) AS
  /*************************************************************
   Created By : knag
   Date Created By :  05-NOV-2003
   Purpose : This procedure gets called at the beginning of import process.
             The package variables are initialized here as per the categories included and then used further.
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_prog_label VARCHAR2(4000);
    l_label      VARCHAR2(4000);
    l_request_id NUMBER;
    l_debug_str  VARCHAR2(4000);
  BEGIN
    l_prog_label := 'igs.plsql.igs_ad_imp_015.sel_ad_src_cat_imp';
    l_label := 'igs.plsql.igs_ad_imp_015.sel_ad_src_cat_imp.';

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_015.sel_ad_src_cat_imp.begin';
      l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID : ' || p_batch_id;

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    g_person_qual_inc             := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'PERSON_QUAL');
    IF g_person_qual_inc AND p_legacy_ind = 'N' THEN
      g_person_qual_inc := FALSE;
    END IF;
    g_person_recruit_dtls_inc     := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'PERSON_RECRUITMENT_DETAILS');

    g_test_result_inc             := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'TEST_RESULTS');
    g_transcript_dtls_inc         := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'TRANSCRIPT_DETAILS');

    g_application_inc             := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICATION');
    g_applicant_oth_inst_appl_inc := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_OTHERINSTS_APPLIED');
    g_applicant_acad_int_inc      := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_ACADEMIC_INTERESTS');
    g_applicant_appl_intent_inc   := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_INTENT');
    g_applicant_spl_int_inc       := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_SPECIAL_INTERESTS');
    g_applicant_spl_tal_inc       := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_SPECIAL_TALENTS');
    g_applicant_per_stat_inc      := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_PERSONAL_STATEMENTS');
    g_applicant_fee_dtls_inc      := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_FEE_DTLS');
    g_applicant_notes_inc         := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_NOTES');
    g_applicant_des_unit_sets_inc := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_UNITSETS_APPLIED');
    g_applicant_edu_goal_inc      := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_EDU_GOALS' );
    g_applicant_hist_inc          := igs_ad_gen_016.chk_src_cat (p_source_type_id, 'APPLICANT_HISTORY');
    IF g_applicant_hist_inc AND p_legacy_ind = 'N' THEN
      g_applicant_hist_inc := FALSE;
    END IF;

  END sel_ad_src_cat_imp;

  PROCEDURE prc_ad_category (p_source_type_id IN NUMBER,
                             p_batch_id IN NUMBER,
                             p_interface_run_id  IN NUMBER,
                             p_enable_log IN VARCHAR2,
                             p_legacy_ind IN VARCHAR2
  ) AS
  /*************************************************************
   Created By : knag
   Date Created By :  05-NOV-2003
   Purpose : This procedure will call all the procedures for admission and inquiry related categories
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   rbezawad        27-Feb-05       Added code to procedure prc_ad_category() to execute a Dynamic Code block
                                   when IGR functionality is enabled
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_prog_label VARCHAR2(4000);
    l_label      VARCHAR2(4000);
    l_request_id NUMBER;
    l_debug_str  VARCHAR2(4000);

    l_return           BOOLEAN;
    l_status           VARCHAR2(5);
    l_industry         VARCHAR2(5);
    l_schema           VARCHAR2(30);

    l_meaning          igs_lookup_values.meaning%TYPE;
    l_stmt          VARCHAR2(2000);
    l_system_source_type           igs_pe_src_types_all.system_source_type%TYPE;

    CURSOR  c_system_source_type IS
    SELECT system_source_type
    FROM   igs_pe_src_types_all
    WHERE  source_type_id = p_source_type_id
    AND    NVL(closed_ind,'N') = 'N';

  BEGIN

    -- Select categories for import
    igs_ad_imp_015.sel_ad_src_cat_imp (p_source_type_id => p_source_type_id,
                                       p_batch_id       => p_batch_id,
                                       p_enable_log     => p_enable_log,
                                       p_legacy_ind     => p_legacy_ind);

    l_prog_label := 'igs.plsql.igs_ad_imp_015.prc_ad_category';
    l_label := 'igs.plsql.igs_ad_imp_015.prc_ad_category.';

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_015.prc_ad_category.begin';
      l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID : ' || p_batch_id;

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    -- To fetch table schema name for gather statistics
    l_return := fnd_installation.get_app_info('IGS', l_status, l_industry, l_schema);

    IF g_person_qual_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'PERSON_QUAL', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_uc_qual_ints a
      SET    interface_run_id = p_interface_run_id,
             person_id = (SELECT person_id
                          FROM   igs_ad_interface
                          WHERE  interface_id = a.interface_id)
      WHERE  interface_id IN (SELECT interface_id
                              FROM   igs_ad_interface
                              WHERE  interface_run_id = p_interface_run_id
                              AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_UC_QUAL_INTS',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_028.prc_pe_qual_details (p_interface_run_id => p_interface_run_id,
                                          p_enable_log       => p_enable_log,
                                          p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_person_qual_inc

    IF g_person_recruit_dtls_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'PERSON_RECRUITMENT_DETAILS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_recruit_int a
      SET    interface_run_id = p_interface_run_id,
             person_id = (SELECT person_id
                          FROM   igs_ad_interface
                          WHERE  interface_id = a.interface_id)
      WHERE  interface_id IN (SELECT interface_id
                              FROM   igs_ad_interface
                              WHERE  interface_run_id = p_interface_run_id
                              AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_RECRUIT_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_014.prc_pe_recruitments_dtl (p_interface_run_id => p_interface_run_id,
                                              p_enable_log       => p_enable_log,
                                              p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'PERSON_RECRUITMENT_DETAILS'));

    END IF; -- g_person_recruit_dtls_inc

    --Dynamic Code block to be executed when IGR functionality is enabled.
    IF (fnd_profile.value('IGS_RECRUITING_ENABLED') IS NULL OR fnd_profile.value('IGS_RECRUITING_ENABLED') = 'N')  THEN

      IF  igs_ad_gen_016.chk_src_cat (p_source_type_id, 'INQUIRY_INSTANCE') = TRUE THEN
          --Log error "Inquiry Instance related information is not Processed as Oracle Student Recruiting functionality is not enabled for the user".
          fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET_STRING('IGS','IGS_AD_INQ_NOT_PRCSD'));
      ELSE
          OPEN c_system_source_type;
	  FETCH c_system_source_type INTO l_system_source_type;
	  CLOSE c_system_source_type;

	  IF l_system_source_type = 'PROSPECT_SS_WEB_INQUIRY' OR l_system_source_type IS NULL THEN
            --Log error "Inquiry Instance related information is not Processed as Oracle Student Recruiting functionality is not enabled for the user".
            fnd_file.put_line(fnd_file.log,FND_MESSAGE.GET_STRING('IGS','IGS_AD_INQ_NOT_PRCSD'));
	  END IF;

      END IF;
    ELSIF fnd_profile.value('IGS_RECRUITING_ENABLED') = 'Y' THEN

       BEGIN
         l_stmt :=  ' BEGIN
                        igr_imp_002.prc_ad_category(:1,:2,:3,:4);
                      END; ';
         EXECUTE IMMEDIATE l_stmt USING p_source_type_id, p_interface_run_id, p_enable_log, l_schema;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log,'Error occurred while calling IGR_IMP_002.PRC_AD_CATEGORY() : '||SQLERRM);
       END;

    END IF;

    IF g_test_result_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'TEST_RESULTS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_test_int a
      SET    interface_run_id = p_interface_run_id,
             person_id = (SELECT person_id
                          FROM   igs_ad_interface
                          WHERE  interface_id = a.interface_id)
      WHERE  interface_id IN (SELECT interface_id
                              FROM   igs_ad_interface
                              WHERE  interface_run_id = p_interface_run_id
                              AND    status IN ('1','4'));

      -- If record failed only due to child record failure
      -- then set status back to 1 and nullify error code/text
      UPDATE igs_ad_test_int
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_TEST_INT',
                                   cascade => TRUE);

      UPDATE igs_ad_test_segs_int
      SET    interface_run_id = p_interface_run_id
      WHERE  interface_test_id IN (SELECT interface_test_id
                                   FROM   igs_ad_test_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','2','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_TEST_SEGS_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_016.prc_tst_rslts (p_interface_run_id => p_interface_run_id,
                                    p_enable_log       => p_enable_log,
                                    p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'TEST_RESULTS'));

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_015.prc_ad_category.after_prc_tst_rslt';
      l_debug_str := 'Test Results Processed Succesfully';

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    END IF; -- g_test_result_inc

    IF g_transcript_dtls_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'TRANSCRIPT_DETAILS', 8405);

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_015.prc_ad_category.before_prc_transcript_dtls';
        l_debug_str := 'Befoer Processing Transcript Details';

        fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
      END IF;

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- If record failed only due to child record failure
      -- then set status back to 1 and nullify error code/text
      UPDATE igs_ad_acadhis_int_all
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_txcpt_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,education_id)
             = (SELECT person_id,NVL(education_id,update_education_id)
                FROM   igs_ad_acadhis_int_all
                WHERE  interface_acadhis_id = a.interface_acadhis_id)
      WHERE  interface_acadhis_id IN (SELECT interface_acadhis_id
                                      FROM   igs_ad_acadhis_int_all
                                      WHERE  interface_run_id = p_interface_run_id
                                      AND    status IN ('1','4'));

      -- If record failed only due to child record failure
      -- then set status back to 1 and nullify error code/text
      UPDATE igs_ad_txcpt_int
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_TXCPT_INT',
                                   cascade => TRUE);

     -- Call category entity import procedure
      igs_ad_imp_024.prc_trscrpt (p_interface_run_id => p_interface_run_id,
                                  p_enable_log       => p_enable_log,
                                  p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'TRANSCRIPT_DETAILS'));

    END IF; -- g_transcript_dtls_inc

    IF g_application_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICATION', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_apl_int a
      SET    interface_run_id = p_interface_run_id,
             person_id = (SELECT person_id
                          FROM   igs_ad_interface
                          WHERE  interface_id = a.interface_id)
      WHERE  interface_id IN (SELECT interface_id
                              FROM   igs_ad_interface
                              WHERE  interface_run_id = p_interface_run_id
                              AND    status IN ('1','4'));

      -- If record failed only due to child record failure
      -- then set status back to 1 and nullify error code/text
      UPDATE igs_ad_apl_int
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_APL_INT',
                                   cascade => TRUE);

      UPDATE igs_ad_ps_appl_inst_int a
      SET    interface_run_id = p_interface_run_id
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND update_adm_appl_number IS NULL
                                   AND    status IN ('1','2','4'));

      -- If record failed only due to child record failure
      -- then set status back to 1 and nullify error code/text
      UPDATE igs_ad_ps_appl_inst_int
      SET    error_code = NULL,
             error_text = NULL,
             status = '1'
      WHERE  interface_run_id = p_interface_run_id
      AND    error_code = 'E347'
      AND    status = '4';

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_PS_APPL_INST_INT',
                                   cascade => TRUE);

      -- ONLY required to identify presence of history records for which application/instance is being updated
      -- Populating the application history interface table with the application context value
      UPDATE igs_ad_apphist_int a
      SET    (person_id,admission_appl_number)
             = (SELECT person_id,update_adm_appl_number
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  status IN ('1','2','4')
      AND    interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','2','4'));

      -- Populating the application instance history interface table with the application instance context value
      UPDATE igs_ad_insthist_int a
      SET    (person_id,admission_appl_number,nominated_course_cd,sequence_number)
             = (SELECT person_id,admission_appl_number,nominated_course_cd,update_adm_seq_number
                FROM   igs_ad_ps_appl_inst_int
                WHERE  interface_ps_appl_inst_id = a.interface_ps_appl_inst_id)
      WHERE  status IN ('1','2','4')
      AND    interface_ps_appl_inst_id IN (SELECT interface_ps_appl_inst_id
                                           FROM   igs_ad_ps_appl_inst_int
                                           WHERE  interface_run_id = p_interface_run_id
                                           AND    status IN ('1','2','4'));

      -- Call category entity import procedure
      igs_ad_imp_004.prc_appcln (p_interface_run_id => p_interface_run_id,
                                 p_enable_log       => p_enable_log,
                                 p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'APPLICATION'),
                                 p_legacy_ind       => p_legacy_ind);

      UPDATE igs_ad_ps_appl_inst_int a
      SET    (person_id,admission_appl_number,admission_application_type)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number),admission_application_type
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  status IN ('1','4')
      AND    interface_run_id = p_interface_run_id;

    END IF; -- g_application_inc

    IF g_applicant_hist_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_HISTORY', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_apphist_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number)
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_APPHIST_INT',
                                   cascade => TRUE);

      UPDATE igs_ad_insthist_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,nominated_course_cd,sequence_number)
             = (SELECT person_id,admission_appl_number,nominated_course_cd,NVL(sequence_number,update_adm_seq_number)
                FROM   igs_ad_ps_appl_inst_int
                WHERE  interface_ps_appl_inst_id = a.interface_ps_appl_inst_id)
      WHERE  interface_ps_appl_inst_id IN (SELECT interface_ps_appl_inst_id
                                           FROM   igs_ad_ps_appl_inst_int
                                           WHERE  interface_run_id = p_interface_run_id
                                           AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_INSTHIST_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_027.prc_appl_hist (p_interface_run_id => p_interface_run_id,
                                    p_enable_log       => p_enable_log,
                                    p_rule             => 'N'); -- Update not yet supported

      igs_ad_imp_027.prc_appl_inst_hist (p_interface_run_id => p_interface_run_id,
                                         p_enable_log       => p_enable_log,
                                         p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_hist_inc

    IF g_applicant_oth_inst_appl_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_OTHERINSTS_APPLIED', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_othinst_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,admission_Application_type)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number), admission_Application_type
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_OTHINST_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_apcnt_oth_inst_apld (p_interface_run_id => p_interface_run_id,
                                              p_enable_log       => p_enable_log,
                                              p_category_meaning => l_meaning,
                                              p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_oth_inst_appl_inc

    IF g_applicant_acad_int_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_ACADEMIC_INTERESTS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_acadint_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number, admission_Application_type)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number),admission_Application_type
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_ACADINT_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_acad_int (p_interface_run_id => p_interface_run_id,
                                   p_enable_log       => p_enable_log,
                                   p_category_meaning => l_meaning,
                                   p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_acad_int_inc

    IF g_applicant_appl_intent_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_INTENT', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_appint_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,admission_Application_type)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number),admission_Application_type
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_APPINT_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_apcnt_indt (p_interface_run_id => p_interface_run_id,
                                     p_enable_log       => p_enable_log,
                                     p_category_meaning => l_meaning,
                                     p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_appl_intent_inc

    IF g_applicant_spl_int_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_SPECIAL_INTERESTS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_splint_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,admission_Application_type)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number),admission_Application_type
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_SPLINT_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_apcnt_spl_intrst (p_interface_run_id => p_interface_run_id,
                                           p_enable_log       => p_enable_log,
                                           p_category_meaning => l_meaning,
                                           p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_spl_int_inc

    IF g_applicant_spl_tal_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_SPECIAL_TALENTS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_spltal_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,admission_Application_type)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number),admission_Application_type
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_SPLTAL_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_apcnt_spl_tal (p_interface_run_id => p_interface_run_id,
                                        p_enable_log       => p_enable_log,
                                        p_category_meaning => l_meaning,
                                        p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_spl_tal_inc

    IF g_applicant_per_stat_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_PERSONAL_STATEMENTS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_perstmt_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number)
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_PERSTMT_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_pe_persstat_details (p_interface_run_id => p_interface_run_id,
                                              p_enable_log       => p_enable_log,
                                              p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_per_stat_inc

    IF g_applicant_fee_dtls_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_FEE_DTLS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_fee_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number)
             = (SELECT person_id,NVL(admission_appl_number,update_adm_appl_number)
                FROM   igs_ad_apl_int
                WHERE  interface_appl_id = a.interface_appl_id)
      WHERE  interface_appl_id IN (SELECT interface_appl_id
                                   FROM   igs_ad_apl_int
                                   WHERE  interface_run_id = p_interface_run_id
                                   AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_FEE_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_003.prc_appl_fees (p_interface_run_id => p_interface_run_id,
                                    p_enable_log       => p_enable_log,
                                    p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'APPLICANT_FEE_DTLS'));

    END IF; -- g_applicant_fee_dtls_inc

    IF g_applicant_notes_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_NOTES', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_notes_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,nominated_course_cd,sequence_number,admission_Application_type)
             = (SELECT person_id,admission_appl_number,nominated_course_cd,
                            NVL(sequence_number,update_adm_seq_number),admission_Application_type
                FROM   igs_ad_ps_appl_inst_int
                WHERE  interface_ps_appl_inst_id = a.interface_ps_appl_inst_id)
      WHERE  interface_ps_appl_inst_id IN (SELECT interface_ps_appl_inst_id
                                           FROM   igs_ad_ps_appl_inst_int
                                           WHERE  interface_run_id = p_interface_run_id
                                           AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_NOTES_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_010.admp_val_pappl_nots (p_interface_run_id => p_interface_run_id,
                                          p_enable_log       => p_enable_log,
                                          p_category_meaning => l_meaning,
                                          p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_notes_inc

    IF g_applicant_des_unit_sets_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_UNITSETS_APPLIED', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_unitsets_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,nominated_course_cd,sequence_number,admission_Application_type )
             = (SELECT person_id,admission_appl_number,nominated_course_cd,NVL(sequence_number,update_adm_seq_number),admission_Application_type
                FROM   igs_ad_ps_appl_inst_int
                WHERE  interface_ps_appl_inst_id = a.interface_ps_appl_inst_id)
      WHERE  interface_ps_appl_inst_id IN (SELECT interface_ps_appl_inst_id
                                           FROM   igs_ad_ps_appl_inst_int
                                           WHERE  interface_run_id = p_interface_run_id
                                           AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_UNITSETS_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_010.prc_apcnt_uset_apl (p_interface_run_id => p_interface_run_id,
                                         p_enable_log       => p_enable_log,
                                         p_category_meaning => l_meaning,
                                         p_rule             => igs_ad_gen_016.find_source_cat_rule (p_source_type_id, 'APPLICANT_UNITSETS_APPLIED'));

    END IF; -- g_applicant_des_unit_sets_inc

    IF g_applicant_edu_goal_inc THEN
      l_meaning := igs_ad_gen_016.get_lkup_meaning ('IMP_CATEGORIES', 'APPLICANT_EDU_GOALS', 8405);

      IF p_enable_log = 'Y' THEN
        igs_ad_imp_001.set_message (p_name        => 'IGS_PE_BEG_IMP',
                                    p_token_name  => 'TYPE_NAME',
                                    p_token_value => l_meaning);
      END IF;

      -- Populating the interface table with the interface_run_id value
      UPDATE igs_ad_edugoal_int a
      SET    interface_run_id = p_interface_run_id,
             (person_id,admission_appl_number,nominated_course_cd,sequence_number,admission_Application_type )
             = (SELECT person_id,admission_appl_number,nominated_course_cd,NVL(sequence_number,update_adm_seq_number),admission_Application_type
                FROM   igs_ad_ps_appl_inst_int
                WHERE  interface_ps_appl_inst_id = a.interface_ps_appl_inst_id)
      WHERE  interface_ps_appl_inst_id IN (SELECT interface_ps_appl_inst_id
                                           FROM   igs_ad_ps_appl_inst_int
                                           WHERE  interface_run_id = p_interface_run_id
                                           AND    status IN ('1','4'));

      -- Gather statistics of the table
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_EDUGOAL_INT',
                                   cascade => TRUE);

      -- Call category entity import procedure
      igs_ad_imp_010.prcs_applnt_edu_goal_dtls (p_interface_run_id => p_interface_run_id,
                                                p_enable_log       => p_enable_log,
                                                p_category_meaning => l_meaning,
                                                p_rule             => 'N'); -- Update not yet supported

    END IF; -- g_applicant_edu_goal_inc

      IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

        IF (l_request_id IS NULL) THEN
          l_request_id := fnd_global.conc_request_id;
        END IF;

        l_label := 'igs.plsql.igs_ad_imp_015.prc_ad_category.Leaving';
        l_debug_str := 'Leaving prc_ad_category';

        fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
      END IF;
  END prc_ad_category;

  PROCEDURE store_ad_stats (p_source_type_id IN NUMBER,
                            p_batch_id IN NUMBER,
                            p_interface_run_id  IN NUMBER
  ) AS
  /*************************************************************
   Created By : knag
   Date Created By :  05-NOV-2003
   Purpose : This procedure will call all the procedures for admission and inquiry related categories
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   rbezawad        27-Feb-05    In store_ad_stats() procedure, changed Recruitment table names to IGR_% naming convention.
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_category_entity_ad_table igs_ad_imp_001.g_category_entity_type_table;

  BEGIN

    -- Define category - entity mapping
    l_category_entity_ad_table(01).category_name := 'PERSON_QUAL';                    l_category_entity_ad_table(01).entity_name := 'IGS_UC_QUAL_INTS';
    l_category_entity_ad_table(02).category_name := 'PERSON_RECRUITMENT_DETAILS';     l_category_entity_ad_table(02).entity_name := 'IGS_AD_RECRUIT_INT';
    l_category_entity_ad_table(03).category_name := 'INQUIRY_DETAILS';                l_category_entity_ad_table(03).entity_name := 'IGR_I_APPL_INT';
    l_category_entity_ad_table(04).category_name := 'INQUIRY_ACADEMIC_INTEREST';      l_category_entity_ad_table(04).entity_name := 'IGR_I_LINES_INT';
    l_category_entity_ad_table(05).category_name := 'INQUIRY_PACKAGE_ITEMS';          l_category_entity_ad_table(05).entity_name := 'IGR_I_PKG_INT';
    l_category_entity_ad_table(06).category_name := 'INQUIRY_INFORMATION_TYPES';      l_category_entity_ad_table(06).entity_name := 'IGR_I_INFO_INT';
    l_category_entity_ad_table(07).category_name := 'INQUIRY_CHARACTERISTICS';        l_category_entity_ad_table(07).entity_name := 'IGR_I_CHAR_INT';
    l_category_entity_ad_table(08).category_name := 'TEST_RESULTS';                   l_category_entity_ad_table(08).entity_name := 'IGS_AD_TEST_INT';
    l_category_entity_ad_table(09).category_name := 'TEST_RESULTS';                   l_category_entity_ad_table(09).entity_name := 'IGS_AD_TEST_SEGS_INT';
    l_category_entity_ad_table(10).category_name := 'TRANSCRIPT_DETAILS';             l_category_entity_ad_table(10).entity_name := 'IGS_AD_TXCPT_INT';
    l_category_entity_ad_table(11).category_name := 'TRANSCRIPT_DETAILS';             l_category_entity_ad_table(11).entity_name := 'IGS_AD_TRMDT_INT';
    l_category_entity_ad_table(12).category_name := 'TRANSCRIPT_DETAILS';             l_category_entity_ad_table(12).entity_name := 'IGS_AD_TUNDT_INT';
    l_category_entity_ad_table(13).category_name := 'APPLICATION';                    l_category_entity_ad_table(13).entity_name := 'IGS_AD_APL_INT';
    l_category_entity_ad_table(14).category_name := 'APPLICATION';                    l_category_entity_ad_table(14).entity_name := 'IGS_AD_PS_APPL_INST_INT';
    l_category_entity_ad_table(15).category_name := 'APPLICANT_HISTORY';              l_category_entity_ad_table(15).entity_name := 'IGS_AD_APPHIST_INT';
    l_category_entity_ad_table(16).category_name := 'APPLICANT_HISTORY';              l_category_entity_ad_table(16).entity_name := 'IGS_AD_INSTHIST_INT';
    l_category_entity_ad_table(17).category_name := 'APPLICANT_OTHERINSTS_APPLIED';   l_category_entity_ad_table(17).entity_name := 'IGS_AD_OTHINST_INT';
    l_category_entity_ad_table(18).category_name := 'APPLICANT_ACADEMIC_INTERESTS';   l_category_entity_ad_table(18).entity_name := 'IGS_AD_ACADINT_INT';
    l_category_entity_ad_table(19).category_name := 'APPLICANT_INTENT';               l_category_entity_ad_table(19).entity_name := 'IGS_AD_APPINT_INT';
    l_category_entity_ad_table(20).category_name := 'APPLICANT_SPECIAL_INTERESTS';    l_category_entity_ad_table(20).entity_name := 'IGS_AD_SPLINT_INT';
    l_category_entity_ad_table(21).category_name := 'APPLICANT_SPECIAL_TALENTS';      l_category_entity_ad_table(21).entity_name := 'IGS_AD_SPLTAL_INT';
    l_category_entity_ad_table(22).category_name := 'APPLICANT_PERSONAL_STATEMENTS';  l_category_entity_ad_table(22).entity_name := 'IGS_AD_PERSTMT_INT';
    l_category_entity_ad_table(23).category_name := 'APPLICANT_FEE_DTLS';             l_category_entity_ad_table(23).entity_name := 'IGS_AD_FEE_INT';
    l_category_entity_ad_table(24).category_name := 'APPLICANT_NOTES';                l_category_entity_ad_table(24).entity_name := 'IGS_AD_NOTES_INT';
    l_category_entity_ad_table(25).category_name := 'APPLICANT_UNITSETS_APPLIED';     l_category_entity_ad_table(25).entity_name := 'IGS_AD_UNITSETS_INT';
    l_category_entity_ad_table(26).category_name := 'APPLICANT_EDU_GOALS';            l_category_entity_ad_table(26).entity_name := 'IGS_AD_EDUGOAL_INT';

    IF fnd_profile.value('IGS_RECRUITING_ENABLED') = 'Y' THEN
      l_category_entity_ad_table(27).category_name := 'INQUIRY_INSTANCE';               l_category_entity_ad_table(27).entity_name := 'IGR_I_APPL_INT';
      l_category_entity_ad_table(28).category_name := 'INQUIRY_INSTANCE';               l_category_entity_ad_table(28).entity_name := 'IGR_I_LINES_INT';
      l_category_entity_ad_table(29).category_name := 'INQUIRY_INSTANCE';               l_category_entity_ad_table(29).entity_name := 'IGR_I_PKG_INT';
      l_category_entity_ad_table(30).category_name := 'INQUIRY_INSTANCE';               l_category_entity_ad_table(30).entity_name := 'IGR_I_INFO_INT';
      l_category_entity_ad_table(31).category_name := 'INQUIRY_INSTANCE';               l_category_entity_ad_table(31).entity_name := 'IGR_I_CHAR_INT';
    END IF;

    igs_ad_imp_001.store_stats (p_source_type_id        => p_source_type_id,
                                p_batch_id              => p_batch_id,
                                p_interface_run_id      => p_interface_run_id,
                                p_category_entity_table => l_category_entity_ad_table);

  END store_ad_stats;

  PROCEDURE del_cmpld_ad_records (p_source_type_id IN NUMBER,
                                  p_batch_id IN NUMBER,
                                  p_interface_run_id  IN NUMBER
  ) AS
  /*************************************************************
   Created By : knag
   Date Created By :  05-NOV-2003
   Purpose : This procedure will call all the procedures for admission and inquiry related categories
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   rbezawad        27-Feb-05       Added code to procedure del_cmpld_ad_records() to execute a Dynamic Code block
                                   when IGR functionality is enabled
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_prog_label VARCHAR2(4000);
    l_label      VARCHAR2(4000);
    l_request_id NUMBER;
    l_debug_str  VARCHAR2(4000);
    l_stmt          VARCHAR2(2000);

  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_imp_015.del_cmpld_ad_records';
    l_label := 'igs.plsql.igs_ad_imp_015.del_cmpld_ad_records.';

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_015.del_cmpld_ad_records.begin';
      l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID : ' || p_batch_id;

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    IF g_applicant_hist_inc THEN
      DELETE FROM igs_ad_insthist_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_hist_inc

    IF g_applicant_notes_inc THEN
      DELETE FROM igs_ad_notes_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_notes_inc

    IF g_applicant_des_unit_sets_inc THEN
      DELETE FROM igs_ad_unitsets_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_des_unit_sets_inc

    IF g_applicant_edu_goal_inc THEN
      DELETE FROM igs_ad_edugoal_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_edu_goal_inc

    IF g_application_inc THEN
      DELETE FROM igs_ad_ps_appl_inst_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_application_inc

    IF g_applicant_hist_inc THEN
      DELETE FROM igs_ad_apphist_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_hist_inc

    IF g_applicant_oth_inst_appl_inc THEN
      DELETE FROM igs_ad_othinst_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_oth_inst_appl_inc

    IF g_applicant_acad_int_inc THEN
      DELETE FROM igs_ad_acadint_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_acad_int_inc

    IF g_applicant_appl_intent_inc THEN
      DELETE FROM igs_ad_appint_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_appl_intent_inc

    IF g_applicant_spl_int_inc THEN
      DELETE FROM igs_ad_splint_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_spl_int_inc

    IF g_applicant_spl_tal_inc THEN
      DELETE FROM igs_ad_spltal_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_spl_tal_inc

    IF g_applicant_per_stat_inc THEN
      DELETE FROM igs_ad_perstmt_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_per_stat_inc

    IF g_applicant_fee_dtls_inc THEN
      DELETE FROM igs_ad_fee_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_applicant_fee_dtls_inc

    IF g_application_inc THEN
      DELETE FROM igs_ad_apl_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_application_inc

    IF g_transcript_dtls_inc THEN
      DELETE FROM igs_ad_tundt_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;

      DELETE FROM igs_ad_trmdt_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;

      DELETE FROM igs_ad_txcpt_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_transcript_dtls_inc

    IF g_test_result_inc THEN
      DELETE FROM igs_ad_test_segs_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;

      DELETE FROM igs_ad_test_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_test_result_inc

    --Dynamic Code block to be executed when IGR functionality is enabled.
    IF fnd_profile.value('IGS_RECRUITING_ENABLED') = 'Y' THEN
       BEGIN
         l_stmt :=  ' BEGIN
                        igr_imp_002.del_cmpld_rct_records(:1,:2);
                      END; ';
         EXECUTE IMMEDIATE l_stmt USING p_source_type_id,p_interface_run_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log,'Error occurred while calling IGR_IMP_002.DEL_CMPLD_RCT_RECORDS() : '||SQLERRM);
       END;
    END IF;

    IF g_person_recruit_dtls_inc THEN
      DELETE FROM igs_ad_recruit_int
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_person_recruit_dtls_inc

    IF g_person_qual_inc THEN
      DELETE FROM igs_uc_qual_ints
      WHERE  status = '1'
      AND    interface_run_id = p_interface_run_id;
      COMMIT;
    END IF; -- g_person_qual_inc

  END del_cmpld_ad_records;

END igs_ad_imp_015;

/
