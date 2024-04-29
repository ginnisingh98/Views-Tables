--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_001" AS
/* $Header: IGSAD79B.pls 120.3 2006/02/21 22:50:38 arvsrini noship $ */
/* ------------------------------------------------------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose : Main Import process package.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  || npalanis        17-FEB-2002     2758854 - New interface table race is created under person statistics
  ||                                 source category
  || ssawhney        7jan            Changed IMP_ADM_DATA : Bug 2732600, HZ policy functions were giving issues.
					Hence disabled the policy function.
  || rrengara        11-Feb-2003     Changes for RCT Build 2664699
  ||                                 Removed the procedure calls for importing inquiry programs, unitsets and program unitsets
  ||                                 Added a call to import inquiry lines
  ||                                 Also removed the references of old inquiry related tables and changed to IGS_RC tables
  || pkpatel         6-NOV-2003      Bug 3130316 Added procedures print_stats and logerrormessage
  || rbezawad        27-Feb-05       Added code to procedure update_parent_record_status() to execute a Dynamic Code block
                                     when IGR functionality is enabled
  ---------------------------------------------------------------------------------------------------------------------------*/
  PROCEDURE logerrormessage(p_record IN VARCHAR2,
                            p_error IN VARCHAR2,
                            p_entity_name IN VARCHAR2 DEFAULT NULL,
                            p_match_ind IN VARCHAR2 DEFAULT NULL) AS
  /*****************************************************************
   Created By    : asbala
   Creation date : 9/23/2003
   Purpose       : This function is to print the statistics from igs_ad_imp_stats.
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_context_token_str VARCHAR2(50);
  BEGIN
    IF p_entity_name IS NULL THEN
      NULL;
    ELSE
      l_context_token_str := p_entity_name || ' - ';
    END IF;

    l_context_token_str := l_context_token_str || p_record;

    IF p_match_ind IS NULL THEN
      NULL;
    ELSE
      l_context_token_str := l_context_token_str || ' - ' || p_match_ind;
    END IF;

    -- Import Process Failed for Record: CONTEXT, Error: ERROR_CD
    FND_MESSAGE.SET_NAME('IGS', 'IGS_PE_IMP_DET_ERROR');
    FND_MESSAGE.SET_TOKEN('CONTEXT', l_context_token_str);
    FND_MESSAGE.SET_TOKEN('ERROR_CD', p_error);

    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  END logerrormessage;

  PROCEDURE print_stats(p_interface_run_id IN igs_ad_interface_all.interface_run_id%TYPE) AS
  /*****************************************************************
   Created By    : asbala
   Creation date : 9/23/2003
   Purpose       : This function is to print the statistics from igs_ad_imp_stats.
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
    CURSOR c_get_statistics (cp_lookup_type VARCHAR2,
                             cp_interface_run_id NUMBER) IS
      SELECT total_rec_num, total_warn_num, total_success_num, total_error_num, meaning,entity_name
      FROM   igs_ad_imp_stats imp, igs_lookup_values lk
      WHERE  imp.src_cat_code = lk.lookup_code
      AND    lk.lookup_type = cp_lookup_type
      AND    imp.interface_run_id = cp_interface_run_id
    ORDER BY meaning, entity_name;
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
    FND_MESSAGE.SET_NAME('IGS','IGS_PE_IMP_HEADER1');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    FND_MESSAGE.SET_NAME('IGS','IGS_PE_IMP_HEADER2');
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
/*
FND_FILE.PUT_LINE(FND_FILE.LOG,
'Category                               Entity                      Total No of         Total No of         Total No of         Total No of');
FND_FILE.PUT_LINE(FND_FILE.LOG,
'                                                                   Records Processed   Records Successful  Records with Error  Records with Warning');
*/

FND_FILE.PUT_LINE(FND_FILE.LOG,
'---------------------------------------------------------------------------------------------------------------------------------------------------');
    FOR get_statistics_rec IN c_get_statistics('IMP_CATEGORIES',p_interface_run_id)
    LOOP
      FND_FILE.PUT_LINE (FND_FILE.LOG, RPAD(get_statistics_rec.meaning,39,' ') ||
                                       RPAD(get_statistics_rec.entity_name,29,' ') ||
                                       RPAD(get_statistics_rec.total_rec_num,20,' ') ||
                                       RPAD(get_statistics_rec.total_success_num,20,' ') ||
                                       RPAD(get_statistics_rec.total_error_num,20,' ') ||
                                       RPAD(get_statistics_rec.total_warn_num,20,' '));
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END print_stats;

  PROCEDURE set_message(p_name IN VARCHAR2,
                        p_token_name IN VARCHAR2 DEFAULT NULL,
                        p_token_value IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
   Created By : knag
   Date Created By :  05-NOV-2003
   Purpose : This procedure will accept message name, token name
             and vale and write message text to logfile
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN
        FND_MESSAGE.SET_NAME('IGS',p_name);
        IF p_token_name IS NOT NULL AND
           p_token_value IS NOT NULL THEN
          FND_MESSAGE.SET_TOKEN(p_token_name, p_token_value);
        END IF;
        Fnd_File.PUT_LINE(Fnd_File.LOG,FND_MESSAGE.GET);
  END set_message;

  PROCEDURE logHeader(p_proc_name VARCHAR2) AS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_proc_name);
  END;
  PROCEDURE logdetail(p_debug_msg VARCHAR2) AS
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_msg);
  END;

  PROCEDURE update_parent_record_status (p_source_type_id IN NUMBER,
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
   rbezawad        27-Feb-05       Added code to procedure update_parent_record_status() to execute a Dynamic Code block
                                   when IGR functionality is enabled
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_prog_label    VARCHAR2(4000);
    l_label         VARCHAR2(4000);
    l_request_id    NUMBER;
    l_debug_str     VARCHAR2(4000);

    l_category_list VARCHAR2(32000) ;
    l_entity_list   VARCHAR2(32000) ;
    start_pos_cat   NUMBER;
    end_pos_cat     NUMBER;
    cur_pos_cat     NUMBER;
    start_pos_tab   NUMBER;
    end_pos_tab     NUMBER;
    cur_pos_tab     NUMBER;
    l_category_name VARCHAR2(30);
    l_entity_name   VARCHAR2(30);

    TYPE c_ref_cur_typ IS REF CURSOR;
    c_ref_cur c_ref_cur_typ;

    TYPE c_ref_cur_rec_typ IS RECORD (status VARCHAR2(1), reccount NUMBER);
    c_ref_cur_rec c_ref_cur_rec_typ;

    l_success       NUMBER;
    l_error         NUMBER;
    l_warning       NUMBER;
    l_total_rec     NUMBER;
    l_stmt          VARCHAR2(2000);

  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_imp_001.update_parent_record_status';
    l_label := 'igs.plsql.igs_ad_imp_001.update_parent_record_status.';

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_001.update_parent_record_status.begin';
      l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID : ' || p_batch_id;

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    -- Based upon application instance child
    UPDATE igs_ad_ps_appl_inst_int apinst
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    (
               EXISTS (SELECT 1 FROM igs_ad_insthist_int WHERE status <> '1' AND interface_ps_appl_inst_id = apinst.interface_ps_appl_inst_id)
            OR EXISTS (SELECT 1 FROM igs_ad_notes_int WHERE status <> '1' AND interface_ps_appl_inst_id = apinst.interface_ps_appl_inst_id)
            OR EXISTS (SELECT 1 FROM igs_ad_unitsets_int WHERE status <> '1' AND interface_ps_appl_inst_id = apinst.interface_ps_appl_inst_id)
            OR EXISTS (SELECT 1 FROM igs_ad_edugoal_int WHERE status <> '1' AND interface_ps_appl_inst_id = apinst.interface_ps_appl_inst_id)
           );
    COMMIT;

    -- Based upon application child
    UPDATE igs_ad_apl_int api
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    (
                EXISTS (SELECT 1 FROM igs_ad_ps_appl_inst_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_othinst_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_acadint_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_appint_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_splint_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_spltal_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_perstmt_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_fee_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_apphist_int WHERE status <> '1' AND interface_appl_id = api.interface_appl_id)
           );
    COMMIT;

    -- Based upon transcript term child
    UPDATE igs_ad_trmdt_int trmdt
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    EXISTS (SELECT 1 FROM igs_ad_tundt_int WHERE status <> '1' AND interface_term_dtls_id = trmdt.interface_term_dtls_id);
    COMMIT;

    -- Based upon transcript child
    UPDATE igs_ad_txcpt_int txcpt
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    EXISTS (SELECT 1 FROM igs_ad_trmdt_int WHERE status <> '1' AND interface_transcript_id = txcpt.interface_transcript_id);
    COMMIT;

    -- Based upon academic history child
    UPDATE igs_ad_acadhis_int_all acadhis
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    EXISTS (SELECT 1 FROM igs_ad_txcpt_int WHERE status <> '1' AND interface_acadhis_id = acadhis.interface_acadhis_id);
    COMMIT;

    -- Based upon test result child
    UPDATE igs_ad_test_int tst
    SET    status = '4',
           error_code = 'E347',
           error_text =  igs_ad_gen_016.get_lkup_meaning ('IMPORT_ERROR_CODE', 'E347', 8405)
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    EXISTS (SELECT 1 FROM igs_ad_test_segs_int WHERE status <> '1' AND interface_test_id = tst.interface_test_id);
    COMMIT;

    --Dynamic Code block to be executed when IGR functionality is enabled.
    IF fnd_profile.value('IGS_RECRUITING_ENABLED') = 'Y' THEN
       BEGIN
         l_stmt :=  ' BEGIN
                        igr_imp_002.update_parent_record_status(:1);
                      END; ';
         EXECUTE IMMEDIATE l_stmt USING p_interface_run_id;
       EXCEPTION
         WHEN OTHERS THEN
           fnd_file.put_line(fnd_file.log,'Error occurred while calling IGR_IMP_002.UPDATE_PARENT_RECORD_STATUS() : '||SQLERRM);
       END;
    END IF;

    -- Based upon person child
    UPDATE igs_ad_interface ad
    SET    record_status = '3',
           status = '4',
           error_code = 'E347'
    WHERE  status = '1'
    AND    interface_run_id = p_interface_run_id
    AND    (
                EXISTS (SELECT 1 FROM igs_ad_apl_int WHERE status <> '1' AND interface_id = ad.interface_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_test_int WHERE status <> '1' AND interface_id = ad.interface_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_recruit_int WHERE status <> '1' AND interface_id = ad.interface_id)
            OR  EXISTS (SELECT 1 FROM igs_uc_qual_ints WHERE status <> '1' AND interface_id = ad.interface_id)
            OR  EXISTS (SELECT 1 FROM igs_ad_acadhis_int_all WHERE status <> '1' AND interface_id = ad.interface_id)
            OR  EXISTS (SELECT 1 FROM igs_pe_cred_int WHERE status <> '1' AND interface_id = ad.interface_id)
           );
    COMMIT;

    -- Based upon person
    UPDATE igs_ad_interface_ctl
    SET    status = '3'
    WHERE  interface_run_id = p_interface_run_id
    AND    EXISTS (SELECT 1
                   FROM   igs_ad_interface
                   WHERE  interface_run_id = p_interface_run_id
                   AND    (record_status <> '1' OR status <> '1'));

    IF SQL%NOTFOUND THEN
      UPDATE igs_ad_interface_ctl
      SET    status = '1'
      WHERE  interface_run_id = p_interface_run_id;
    END IF;
    COMMIT;

  END update_parent_record_status;

  PROCEDURE store_stats (p_source_type_id IN NUMBER,
                         p_batch_id IN NUMBER,
                         p_interface_run_id  IN NUMBER,
                         p_category_entity_table IN g_category_entity_type_table
  ) AS
  /*************************************************************
   Created By : knag
   Date Created By :  05-NOV-2003
   Purpose : This procedure will store process statistics of all
             entities for included categories
   Know limitations, enhancements or remarks
   Change History
   Who             When            What
   (reverse chronological order - newest change first)
  ***************************************************************/
    l_prog_label    VARCHAR2(4000);
    l_label         VARCHAR2(4000);
    l_request_id    NUMBER;
    l_debug_str     VARCHAR2(4000);

    TYPE c_ref_cur_typ IS REF CURSOR;
    c_ref_cur c_ref_cur_typ;

    TYPE c_ref_cur_rec_typ IS RECORD (status VARCHAR2(1), reccount NUMBER);
    c_ref_cur_rec c_ref_cur_rec_typ;

    l_success       NUMBER;
    l_error         NUMBER;
    l_warning       NUMBER;
    l_total_rec     NUMBER;

  BEGIN

    l_prog_label := 'igs.plsql.igs_ad_imp_001.store_stats';
    l_label := 'igs.plsql.igs_ad_imp_001.store_stats.';

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_001.store_stats.begin';
      l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID : ' || p_batch_id;

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    FOR idx IN p_category_entity_table.first..p_category_entity_table.last
    LOOP
      l_success   := 0;
      l_error     := 0;
      l_warning   := 0;
      l_total_rec := 0;
     IF  igs_ad_gen_016.chk_src_cat (p_source_type_id, p_category_entity_table(idx).category_name) THEN
        OPEN c_ref_cur FOR 'SELECT status, count(*) reccount FROM ' ||
                           p_category_entity_table(idx).entity_name ||
                           ' WHERE interface_run_id = :1 GROUP BY status'
	USING p_interface_run_id;
        LOOP
          FETCH c_ref_cur INTO c_ref_cur_rec;
          IF c_ref_cur%NOTFOUND THEN
            CLOSE c_ref_cur;
          EXIT;
          END IF;

          IF c_ref_cur_rec.status = '1' THEN
            l_success := c_ref_cur_rec.reccount;
          ELSIF c_ref_cur_rec.status = '3' THEN
            l_error := c_ref_cur_rec.reccount;
          ELSIF c_ref_cur_rec.status = '4' THEN
            l_warning := c_ref_cur_rec.reccount;
          END IF;
         END LOOP;

         IF l_success IS NULL THEN
            l_success := 0;
         END IF;
         IF l_error IS NULL THEN
           l_error := 0;
         END IF;
         IF l_warning IS NULL THEN
             l_warning := 0;
         END IF;

         l_total_rec := l_success + l_error + l_warning;
      /*********************************************************
      dbms_output.put_line ('Category - ' || p_category_entity_table(idx).category_name ||' : '||
                            'Entity - ' || p_category_entity_table(idx).entity_name ||' : '||
                            'S - '|| to_char(l_success) ||' : '||
                            'E - '|| to_char(l_error) ||' : '||
                            'W - '|| to_char(l_warning) ||' : '||
                            'T - '|| to_char(l_total_rec));
      *********************************************************/
        INSERT INTO IGS_AD_IMP_STATS (
                  INTERFACE_RUN_ID,
                  SRC_CAT_CODE,
                  ENTITY_NAME,
                  TOTAL_REC_NUM,
                  TOTAL_WARN_NUM,
                  TOTAL_SUCCESS_NUM,
                  TOTAL_ERROR_NUM,
                  CREATED_BY,
                  CREATION_DATE,
                  LAST_UPDATED_BY,
                  LAST_UPDATE_DATE,
                  LAST_UPDATE_LOGIN,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE
          ) VALUES (
                  p_interface_run_id,
                  p_category_entity_table(idx).category_name,
                  p_category_entity_table(idx).entity_name,
                  l_total_rec,
                  l_warning,
                  l_success,
                  l_error,
                  1,
                  sysdate,
                  1,
                  sysdate,
                  NULL,
                  NULL,
                  NULL,
                  NULL,
                  NULL
        );
     END IF ;
    END LOOP;

  END store_stats;

  FUNCTION import_legacy_data (
        p_batch_id         NUMBER,
        p_source_type_id   NUMBER,
        p_interface_run_id NUMBER
  ) RETURN BOOLEAN IS

    l_count1 NUMBER;
    l_count2 NUMBER;

   BEGIN

      BEGIN
      SELECT 1 INTO l_count1
      FROM   DUAL
      WHERE  EXISTS (SELECT 1
                     FROM   igs_ad_interface int,
                            igs_uc_qual_ints qint
                     WHERE  int.interface_id = qint.interface_id
                     AND    int.source_type_id = p_source_type_id
                     AND    int.batch_id = p_batch_id
                     AND    int.status IN('1','4','2')
                     AND    qint.status ='2');
      EXCEPTION
      WHEN OTHERS THEN
         l_count1 := 0;
      END;

      BEGIN
      SELECT 1 INTO l_count2
      FROM   DUAL
      WHERE  EXISTS (SELECT 1
                     FROM   igs_ad_interface int,
                            igs_ad_apl_int aplint,
                            igs_ad_apphist_int applhist
                     WHERE  int.interface_id = aplint.interface_id
                     AND    aplint.interface_appl_id = applhist.interface_appl_id
                     AND    int.source_type_id = p_source_type_id
                     AND    int.batch_id = p_batch_id
                     AND    int.status IN ( '1', '4', '2')
                     AND    aplint.status IN ('1', '4', '2')
                     AND    applhist.status = '2'
                     UNION ALL
                     SELECT 1
                     FROM   igs_ad_interface int,
                            igs_ad_apl_int aplint,
                            igs_ad_ps_appl_inst_int aplinst,
                            igs_ad_insthist_int applinsthist
                     WHERE  int.interface_id = aplint.interface_id
                     AND    aplint.interface_appl_id = aplinst.interface_appl_id
                     AND    applinsthist.interface_ps_appl_inst_id = aplinst.interface_ps_appl_inst_id
                     AND    int.source_type_id = p_source_type_id
                     AND    int.batch_id = p_batch_id
                     AND    int.status IN ( '1', '4', '2')
                     AND    aplint.status IN ('1', '4', '2')
                     AND    aplinst.status IN ('1', '4', '2')
                     AND    applinsthist.status = '2');
      EXCEPTION
      WHEN OTHERS THEN
         l_count2 := 0;
      END;

     IF l_count1 = 1 OR l_count2 = 1 THEN
        -- Failure Condition
        UPDATE igs_ad_interface_ctl
        SET status = '3'
        WHERE interface_run_id = p_interface_run_id;
        COMMIT;

        IF  l_count1 = 1 THEN
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot import Qualification Details in non-legacy mode of import');
        ELSE
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Cannot import Application History Details in non-legacy mode of import');
        END IF;

       RETURN TRUE;
     END IF;
     RETURN FALSE;

  END import_legacy_data;

  PROCEDURE imp_adm_data (
      ERRBUF OUT NOCOPY VARCHAR2,
      RETCODE OUT NOCOPY NUMBER ,
      P_BATCH_ID  IN NUMBER,
      P_SOURCE_TYPE_ID IN NUMBER,
      P_MATCH_SET_ID  IN NUMBER,
      P_LEGACY_IND        IN VARCHAR2 ,
      P_ENABLE_LOG IN VARCHAR2,
      P_ACAD_CAL_TYPE  IN VARCHAR2,
      P_ACAD_SEQUENCE_NUMBER  IN NUMBER,
      P_ADM_CAL_TYPE  IN VARCHAR2,
      P_ADM_SEQUENCE_NUMBER  IN NUMBER,
      P_ADMISSION_CAT  IN VARCHAR2,
      P_S_ADMISSION_PROCESS_TYPE  IN VARCHAR2,
      P_INTERFACE_RUN_ID  IN NUMBER,
      P_ORG_ID       IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------------
  ||  Created By : pkpatel
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || gmaheswa        17-Jan-06       4938278: disable Business Events before starting bulk import process and enable after import.
  || rrengara        20-jan-2003     Bug 2711176 , Gather statistics
  || ssawhney        7jan            Bug 2732600, HZ policy functions were giving issues. Hence disabled the policy functions.
  || pkpatel         25-DEC-2002     Bug No: 2702536
  ||                                 Removed the duplicate checking procedure IGS_AD_IMP_FIND_DUP_PERSONS to IGSAD80B.
  ||                                 Modified the signature of Igs_Ad_Imp_002.PRC_PE_DTLS
  ||                                 Modified the count of record processed to be based on RECORD_STATUS
  ||  pkpatel       17-DEC-2002      Bug No: 2695902
  ||                                 Added delete logic for Residency Details
  ||                                 Modified p_interface_run_id to l_interface_run_id so that the interface records can be updated with proper interface run id.
  ||  gmuralid      4-DEC-2002       Change by gmuralid, removed reference to table igs_ad_intl_int,
  ||                                  igs_pe_fund_dep_int.Included references to igs_pe_visa_int,
  ||                                  igs_pe_vst_hist_int,igs_pe_passport_int,igs_pe_eit_int in delete logic
  ||                                  As a part of BUG 2599109, SEVIS Build
  || npalanis      21-May-2002      Code is added to update interface_run_id in igs_ad_interface records
  ||                                 with status '1' ,'2' and  '4' .The parameter p_interface_run_id passed
  ||                                 to prc_pe_dtls is also removed as no  more updation of interface_run_id
  ||                                 is required there.
  || rrengara        4-OCT-2002      Changed the ordering of the parameters batch id and source type id for the Build bug 2604395
  ||                                 Called IGS_AD_INTERFACE_CTL tables TBH and assigned l_interface_run_id to the value from OUT NOCOPY parameter TBH
  ||
  || ssawhney        28-oct-2002     SWS104- Jan03 build residency details import added. moved acad honors to person level
  ||                                 IGS_AD_REFS_INT table obsoleted.
  || sjalsaut        Oct 31, 02	     SWSCR012 Bug 2435520 Removed College Activities references
  ||                                 and changed extracurr act to PERSON_ACTIVITIES
  ||  (reverse chronological order - newest change first)
  ||--------------------------------------------------------------------------------*/
    l_prog_label            VARCHAR2(4000);
    l_label                 VARCHAR2(4000);
    l_request_id            NUMBER;
    l_debug_str             VARCHAR2(4000);

    l_return                BOOLEAN;
    l_status                VARCHAR2(5);
    l_industry              VARCHAR2(5);
    l_schema                VARCHAR2(30);

    l_batch_desc            igs_ad_imp_batch_det.batch_desc%TYPE;
    l_source_type           igs_pe_src_types_all.system_source_type%TYPE;
    l_match_set_name        igs_pe_match_sets_all.match_set_name%TYPE;
    l_interface_run_id      igs_ad_interface_ctl.interface_run_id%TYPE;
    l_rowid                 VARCHAR2(100);
    l_cnt_dup_process_run   NUMBER;
    l_err_msg               VARCHAR2(4000);
  BEGIN
    l_prog_label := 'igs.plsql.igs_ad_imp_001.imp_adm_data';
    l_label := 'igs.plsql.igs_ad_imp_001.imp_adm_data.';

    IF fnd_log.test(fnd_log.level_procedure,l_prog_label) THEN

      IF (l_request_id IS NULL) THEN
        l_request_id := fnd_global.conc_request_id;
      END IF;

      l_label := 'igs.plsql.igs_ad_imp_001.imp_adm_data.begin';
      l_debug_str := 'Source Type Id : ' || p_source_type_id || ' Batch ID : ' || p_batch_id;

      fnd_log.string_with_context (fnd_log.level_procedure,
                                   l_label,
                                   l_debug_str,
                                   NULL,NULL,NULL,NULL,NULL,
                                   TO_CHAR(l_request_id));
    END IF;

    retcode := 0;
    igs_ge_gen_003.set_org_id(p_org_id);

    --Disable Business Event before running Bulk Process
    IGS_PE_GEN_003.TURNOFF_TCA_BE (
      P_TURNOFF  => 'Y'
    );

    igs_ge_msg_stack.initialize;

    BEGIN
      SELECT batch_desc INTO l_batch_desc
      FROM   igs_ad_imp_batch_det
      WHERE  batch_id = p_batch_id ;

      SELECT system_source_type INTO l_source_type
      FROM   igs_pe_src_types_all
      WHERE  source_type_id = p_source_type_id
      AND    NVL(closed_ind,'N') = 'N'
      AND    system_source_type IN ('APPLICATION', 'TEST_RESULTS', 'PROSPECT_LIST', 'PROSPECT_SS_WEB_INQUIRY',  'TRANSCRIPT');

      SELECT match_set_name INTO l_match_set_name
      FROM   igs_pe_match_sets_all
      WHERE  match_set_id = p_match_set_id
      AND    closed_ind = 'N';
    EXCEPTION
    WHEN OTHERS THEN
      l_batch_desc := NULL;
      l_source_type := NULL;
      l_match_set_name := NULL;
    END;

    IF l_batch_desc IS NULL OR
       l_source_type IS NULL OR
       l_match_set_name IS NULL THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, '');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch ID       :' || p_batch_id );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Source Type ID :' || p_source_type_id );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Match Set ID   :' || p_match_set_id );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Invalid Batch OR Source Type OR Match Set');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '');
      --Enable Business Event before quiting Bulk Process
      IGS_PE_GEN_003.TURNOFF_TCA_BE (
         P_TURNOFF  => 'N'
      );
      RETURN;
    ELSE
      FND_FILE.PUT_LINE(FND_FILE.LOG, '');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Batch ID       :' || p_batch_id       ||'    '|| 'Batch Description   :' || l_batch_desc );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Source Type ID :' || p_source_type_id ||'    '|| 'Source Type         :' || l_source_type );
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Match Set ID   :' || p_match_set_id   ||'    '|| 'Match Set Name      :' || l_match_set_name );
      FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    END IF;
    igs_ad_interface_ctl_pkg.insert_row (
      x_rowid                    => l_rowid,
      x_interface_run_id         => l_interface_run_id ,
      x_source_type_id           => p_source_type_id,
      x_batch_id                 => p_batch_id,
      x_match_set_id             => p_match_set_id,
      x_status                   => '2',
      x_mode                     => 'R');
    COMMIT;
    SELECT COUNT (*) INTO l_cnt_dup_process_run
    FROM   igs_ad_interface_ctl
    WHERE  batch_id = p_batch_id
    AND    source_type_id = p_source_type_id
    AND    status = '2';
    IF l_cnt_dup_process_run > 1 THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Another import process with same batch and source type is currently under execution hence aborting.');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      igs_ad_imp_001.g_interface_run_id := l_interface_run_id;
      igs_ad_imp_001.g_enable_log := p_enable_log;

      IF p_legacy_ind = 'N' THEN
        IF import_legacy_data (
            p_batch_id         => p_batch_id,
            p_source_type_id   => p_source_type_id,
            p_interface_run_id => l_interface_run_id ) THEN

	  --Enable Business Event before quiting Bulk Process
	  IGS_PE_GEN_003.TURNOFF_TCA_BE (
	    P_TURNOFF  => 'N'
          );

          RETURN;
        END IF;
      END IF;
      -- Update the interface_run_id for IGS_AD_INTERFACE records with status in 1,2,4 for Bug - 2377123
      UPDATE igs_ad_interface_all
      SET    interface_run_id = l_interface_run_id
      WHERE  batch_id = p_batch_id
      AND    source_type_id = p_source_type_id
      AND    status IN ('1','2','4');
     COMMIT;

      -- Update the interface records if the interface ids are duplicate (within the batch and across the batch)
      UPDATE igs_ad_interface_all  int1
      SET status ='3',
             error_code = 'E712'
      WHERE   EXISTS ( SELECT 1 FROM igs_ad_interface_all
                                  WHERE interface_id = int1.interface_id
                                  AND rowid <> int1.rowid )
      AND interface_run_id = l_interface_run_id;
     COMMIT;

      -- To fetch table schema name for gather statistics
      l_return := fnd_installation.get_app_info('IGS', l_status, l_industry, l_schema);

      -- Gather statistics of interface tables
      FND_STATS.GATHER_TABLE_STATS(ownname => l_schema,
                                   tabname => 'IGS_AD_INTERFACE_ALL',
                                   cascade => TRUE);

      -------------------------------------------------------
      -- disable HZ security policy before starting the import.
      -------------------------------------------------------
      HZ_COMMON_PUB.DISABLE_CONT_SOURCE_SECURITY ;
      -- Process categories for import
      igs_pe_pers_imp_001.prc_pe_category (p_batch_id         => p_batch_id,
                                           p_source_type_id   => p_source_type_id,
                                           p_match_set_id     => p_match_set_id,
                                           p_interface_run_id => l_interface_run_id);
      igs_ad_imp_015.prc_ad_category (p_source_type_id   => p_source_type_id,
                                      p_batch_id         => p_batch_id,
                                      p_interface_run_id => l_interface_run_id,
                                      p_enable_log       => p_enable_log,
                                      p_legacy_ind       => p_legacy_ind);

      -- Update category entities if child has failure (traverse parent to super parent)
      -- Update parent based on p_interface_run_id
      -- Select child based on FK link and not p_interface_run_id
      igs_ad_imp_001.update_parent_record_status (p_source_type_id   => p_source_type_id,
                                                  p_batch_id         => p_batch_id,
                                                  p_interface_run_id => l_interface_run_id);

      -- Create process statistics
      igs_ad_imp_015.store_ad_stats (p_source_type_id   => p_source_type_id,
                                     p_batch_id         => p_batch_id,
                                     p_interface_run_id => l_interface_run_id);

      -- Delete successfully imported records from the interface table with the interface_run_id value
      igs_pe_pers_imp_001.del_cmpld_pe_records(p_batch_id);

      igs_ad_imp_015.del_cmpld_ad_records (p_source_type_id   => p_source_type_id,
                                           p_batch_id         => p_batch_id,
                                           p_interface_run_id => l_interface_run_id);
      DELETE FROM igs_ad_interface_all
      WHERE  status = '1'
      AND record_status ='1'
      AND    interface_run_id = l_interface_run_id;

     UPDATE igs_ad_interface_all
     SET record_status = '3'
     WHERE  interface_run_id = l_interface_run_id
     AND status <> '1';
     COMMIT;
      -- Write process statistics to logfile
      igs_ad_imp_001.print_stats (l_interface_run_id);
      -------------------------------------------------------
      -- enable HZ security policy if abnormal termination
      -------------------------------------------------------
      HZ_COMMON_PUB.ENABLE_CONT_SOURCE_SECURITY ;
    END IF;

    --Enable Business Event before quiting Bulk Process
    IGS_PE_GEN_003.TURNOFF_TCA_BE (
         P_TURNOFF  => 'N'
    );
  EXCEPTION
    WHEN OTHERS THEN
      retcode:=2;
      l_err_msg := SQLERRM;

      logdetail('EXCEPTION FROM Import Process' || l_err_msg);
      errbuf := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      igs_ge_msg_stack.conc_exception_hndl;

      -- Failure Condition

      IF l_interface_run_id IS NOT NULL THEN
        UPDATE igs_ad_interface_ctl
        SET status = '3'
        WHERE rowid = l_rowid;
        COMMIT;
      END IF;

      --Enable Business Event before quiting Bulk Process
      IGS_PE_GEN_003.TURNOFF_TCA_BE (
         P_TURNOFF  => 'N'
      );
      -------------------------------------------------------
      -- enable HZ security policy if abnormal termination
      -------------------------------------------------------
      HZ_COMMON_PUB.ENABLE_CONT_SOURCE_SECURITY ;

  END imp_adm_data;


  FUNCTION find_source_cat_rule(
         P_Source_type_id IN NUMBER,
         p_Category IN VARCHAR2 ) RETURN VARCHAR2
  AS
  /*
  ||  Created By : nsinha
  ||  Created On : 22-JUN-2001
  ||  Purpose : This function returns the rule for a category for a source type
  ||            Find out NOCOPY from IGS_AD_SRC_CAT the rule for the p_source_type_id and
  ||            category_cd passed as the parameter.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       22-Jun-2001     For Modeling and Forecasting DLD modified the code
  ||                                  To return a value 'D' for Attribute level discrepancy rule.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR discrepancy_rule_cur IS
      SELECT *
      FROM   igs_ad_source_cat
      WHERE  source_type_id = p_source_type_id
      AND         category_name = p_category;
    discrepancy_rule_rec discrepancy_rule_cur%ROWTYPE;
    l_disp_rule igs_ad_source_cat.discrepancy_rule_cd%TYPE;

  BEGIN

    OPEN  discrepancy_rule_cur;
    FETCH discrepancy_rule_cur INTO discrepancy_rule_rec;
    CLOSE discrepancy_rule_cur;

    IF NVL(discrepancy_rule_rec.detail_Level_Ind,'N') = 'Y' THEN
      l_disp_rule := 'D'; -- Detail Level discrepancy rule is checked.
    ELSE  -- Check discrepancy rule at Table Level.
      l_disp_rule := discrepancy_rule_rec.discrepancy_rule_cd;
    END IF;

    RETURN l_disp_rule;

  END find_source_cat_rule;

END Igs_Ad_Imp_001;

/
