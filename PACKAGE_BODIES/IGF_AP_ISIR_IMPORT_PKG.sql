--------------------------------------------------------
--  DDL for Package Body IGF_AP_ISIR_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ISIR_IMPORT_PKG" AS
/* $Header: IGFAP01B.pls 120.2 2006/02/10 02:47:08 bvisvana noship $ */

   g_ISIR_rec                igf_ap_ISIR_matched%ROWTYPE;
   g_base_rec                igf_ap_fa_base_rec%ROWTYPE;
   g_paid_efc                igf_ap_fa_base_rec.efc_f%TYPE;
   g_pell_grant_elig_flag    igf_ap_fa_base_rec_all.pell_eligible%TYPE;
   g_nslds_match_flag        igf_ap_fa_base_rec.nslds_eligible%TYPE;
   g_verification_flag       igf_ap_ISIR_matched.verification_flag%TYPE;
   g_ISIR_id                 igf_ap_ISIR_matched.ISIR_id%TYPE;
   g_base_id                 igf_ap_fa_base_rec.base_id%TYPE;
   g_fed_verif_status        igf_ap_fa_base_rec_all.fed_verif_status%TYPE;
   g_msg_body                VARCHAR2(4000) := NULL;
   g_transaction_num         CHAR(13);
   g_cnt                     NUMBER := 1;
   l_document                VARCHAR2(4000);
   l_document_type           VARCHAR2(4000);

-- added by rgangara as part of FA138 enh
   g_batch_year       igf_ap_batch_aw_map.batch_year%TYPE;
   g_match_code       igf_ap_record_match_all.match_code%TYPE;
   g_rec_status       igf_ap_isir_ints_all.record_status%TYPE;
   g_rec_type         igf_ap_isir_ints_all.processed_rec_type%TYPE;
   g_message_Class    igf_ap_isir_ints_all.data_file_name_txt%TYPE;
   g_school_code      igf_ap_isir_ints_all.first_college_cd%TYPE;
   g_del_int          VARCHAR2(1);
   g_force_add        VARCHAR2(1);
   g_create_inquiry   VARCHAR2(1);
   g_adm_source_type  VARCHAR2(30);

   g_where            VARCHAR2(32000);
   g_total_recs_fetched NUMBER;

   -- define a PL/SQL table
   TYPE T_int_si_id    IS TABLE OF igf_ap_isir_ints_all.si_id%TYPE;
   TYPE T_int_batch_yr IS TABLE OF igf_ap_isir_ints_all.batch_year_num%TYPE;
   TYPE T_int_orig_ssn IS TABLE OF igf_ap_isir_ints_all.original_ssn_txt%TYPE;
   TYPE T_int_orig_id  IS TABLE OF igf_ap_isir_ints_all.orig_name_id_txt%TYPE;

   TYPE T_int_prnt_req_id IS TABLE OF igf_ap_isir_ints_all.orig_name_id_txt%TYPE;
   TYPE T_int_sub_req_num IS TABLE OF igf_ap_isir_ints_all.orig_name_id_txt%TYPE;
   -- define global variables of corresp type and initialize
   g_si_id_tab              T_int_si_id       := T_int_si_id();
   g_batch_year_num_tab     T_int_batch_yr    := T_int_batch_yr();
   g_original_ssn_txt_tab   T_int_orig_ssn    := T_int_orig_ssn();
   g_orig_name_id_txt_tab   T_int_orig_id     := T_int_orig_id();
   g_parent_req_id_tab      T_int_prnt_req_id := T_int_prnt_req_id();
   g_sub_req_num_tab        T_int_sub_req_num := T_int_sub_req_num();


PROCEDURE log_debug_message(m VARCHAR2)
IS
-- for debug message logging
--g_debug_seq               NUMBER:=0;  --- #R1 Remove after debugging
BEGIN
--fnd_file.put_line(fnd_file.log, m);
--g_debug_seq := g_debug_seq + 1;
--INSERT INTO RAN_DEBUG values (g_debug_seq,m);
NULL;
END;

FUNCTION get_msg_class( p_isir_type IN VARCHAR2)
RETURN VARCHAR2
/*
||  Created By : rasahoo
||  Created On : 22-NOV-2004
||  Purpose : Returns the message class
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  (reverse chronological order - newest change first)
*/
IS

	CURSOR c_msg_class( p_lookup_type VARCHAR2, p_lookup_code VARCHAR2 ) IS
	SELECT LOOKUP_CODE
   FROM igf_lookups_view
	WHERE lookup_type = p_lookup_type
	AND tag = p_lookup_code
	AND enabled_flag = 'Y';

         l_msg_class c_msg_class%ROWTYPE;

         ret_val VARCHAR2(100);
   BEGIN
   ret_val := NULL;
   OPEN c_msg_class('IGF_AP_ISIR_MESSAGE_CLASS',p_isir_type);
   LOOP
	FETCH c_msg_class INTO l_msg_class;
	EXIT WHEN c_msg_class%NOTFOUND;
	IF ret_val IS NOT NULL THEN
	   ret_val := ret_val || ',';
	END IF;
	ret_val := ret_val||''''||l_msg_class.lookup_code || '''';
   END LOOP;
   CLOSE c_msg_class;
   return ret_val;
END get_msg_class;
------------------------------------------------------------------------------------
-- Function to check whether coreection is initiated from the this school or not.
------------------------------------------------------------------------------------
FUNCTION l_is_cor_from_same_school(p_ISIR_id NUMBER)
RETURN BOOLEAN
IS
/*
||  Created By : brajendr
||  Created On : 08-NOV-2000
||  Purpose : Checks whether the ISIR Correction is intiated from the same school.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  ugummall        27-OCT-2003     Bug 3102439. FA 126 - Multiple FA Offices.
||                                  removed cursor cur_fed_code and its references.
||                                  Added new cursor cur_get_base_id.
||  (reverse chronological order - newest change first)
*/

        -- Get the base_id as well as 6 school codes for p_isir_id.
        CURSOR cur_get_base_id IS
          SELECT  base_id,
                  first_college,
                  second_college,
                  third_college,
                  fourth_college,
                  fifth_college,
                  sixth_college
            FROM  igf_ap_isir_matched
           WHERE  isir_id = p_ISIR_id;
        l_get_base_id_rec   cur_get_base_id%ROWTYPE;

        x_fed_sch_cd      igs_or_org_alt_ids.org_alternate_id%TYPE;
        x_return_status   VARCHAR2(1);
        x_msg_data        VARCHAR2(30);

BEGIN

        -- FA 126.
        OPEN cur_get_base_id;
        FETCH cur_get_base_id INTO l_get_base_id_rec;
        CLOSE cur_get_base_id;

        -- Derive Federal School Code.
        igf_sl_gen.get_stu_fao_code(l_get_base_id_rec.base_id, 'FED_SCH_CD', x_fed_sch_cd, x_return_status, x_msg_data);
        IF (x_return_status = 'E') THEN
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'igf.plsql.igf_ap_isir_import_pkg.l_is_cor_from_same_school.debug','x_msg_data : ' || x_msg_data);
          END IF;
          RETURN FALSE;
        ELSE
          -- write debug message with federal school code.
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'igf.plsql.igf_ap_isir_import_pkg.l_is_cor_from_same_school.debug','x_fed_sch_cd : ' || x_fed_sch_cd);
          END IF;
          -- check wether federal school code matches with any of 6 codes
          IF ( x_fed_sch_cd = l_get_base_id_rec.first_college    OR
               x_fed_sch_cd = l_get_base_id_rec.second_college    OR
               x_fed_sch_cd = l_get_base_id_rec.third_college    OR
               x_fed_sch_cd = l_get_base_id_rec.fourth_college    OR
               x_fed_sch_cd = l_get_base_id_rec.fifth_college    OR
               x_fed_sch_cd = l_get_base_id_rec.sixth_college
             ) THEN
            RETURN TRUE;
          ELSE
            RETURN FALSE;
          END IF;
        END IF;

EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.L_IS_COR_FROM_SAME_SCHOOL');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END l_is_cor_from_same_school;


PROCEDURE main_import_process ( errbuf             OUT NOCOPY VARCHAR2,
                                retcode            OUT NOCOPY NUMBER,
                                p_org_id           IN         NUMBER,
                                p_award_year       IN         VARCHAR2,
                                p_force_add        IN         VARCHAR2,
                                p_create_inquiry   IN         VARCHAR2,
                                p_adm_source_type  IN         VARCHAR2,
                                p_match_code       IN         VARCHAR2,
                                p_rec_type         IN         VARCHAR2,
                                p_rec_status       IN         VARCHAR2,
                                p_message_class    IN         VARCHAR2,
                                p_school_type      IN         VARCHAR2,
                                p_school_code      IN         VARCHAR2,
                                p_del_int          IN         VARCHAR2,
                                p_spawn_process    IN         VARCHAR2,
                                p_upd_ant_val      IN         VARCHAR2
                             )

IS

/*
||  Created By : rgangara
||  Created On : 06-AUG-2004
||  Purpose : Main process which in turn calls the Matching process by passing either SI_ID or a PL/sQL table.
||  Known limitations, enhancements or remarks :
||  Change History :
||  (reverse chronological order - newest change first)

||  Who             When            What
||
*/

   CURSOR c_batch(cp_cal_type VARCHAR2,
                  cp_seq_number NUMBER) IS
   SELECT batch_year
   FROM   igf_ap_batch_aw_map_all
   WHERE  ci_cal_type        = cp_cal_type
   AND    ci_sequence_number = cp_seq_number;

   l_batch        c_batch%ROWTYPE;
   l_sql          VARCHAR2(32000);
   l_add_and      VARCHAR2(1);
   ln_total_rec   NUMBER  := 0;

   l_cal_type   igf_ap_fa_base_rec_all.ci_cal_type%TYPE ;
   l_seq_number igf_ap_fa_base_rec_all.ci_sequence_number%TYPE;
   l_batch_year igf_ap_batch_aw_map_all.batch_year%TYPE;

   g_parent_req_number NUMBER;
------------------------------------------------------------
-- Begin of Local new Procedures created for FA138 build - rgangara.
------------------------------------------------------------
   PROCEDURE launch_sub_request(p_sub_req_number NUMBER,
                                p_sub_req_rec_cnt NUMBER)
   IS
     /*
     ||  Created By : rgangara
     ||  Created On : 28-JUL-2004
     ||  Purpose :    For records distribution and launching spawned/parallel processes.
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who              When              What
     ||  (reverse chronological order - newest change first)
     */
      l_request_id        NUMBER;
      l_recs_to_process   NUMBER;  -- No. of records to process

   BEGIN

      l_request_id := Fnd_Request.Submit_Request
                            ('IGF',
                             'IGFAPJ30',
                             'ISIR Internal Spawned Import Process',
                             NULL,
                             FALSE,
                             p_force_add,
                             p_create_inquiry,
                             p_adm_source_type,
                             g_batch_year,
                             p_match_code,
                             p_del_int,
                             g_parent_req_number,
                             p_sub_req_number,
                             NULL,
                             p_upd_ant_val,
                             CHR(0),
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
                            );


      IF l_request_id > 0 THEN
          -- successfully submitted then log message
          fnd_file.put_line( fnd_file.LOG ,' ');
          fnd_message.set_name('IGS','IGF_AP_SPAWN_REQ_SUBMIT');
          fnd_message.set_token('REQUEST_ID', l_request_id);
          fnd_message.set_token('SPAWN_ID', p_sub_req_number);
          fnd_message.set_token('TOTAL_RECS', p_sub_req_rec_cnt);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
      ELSE
          -- if error then log message
          fnd_message.set_name('IGS','IGF_AP_FAIL_SBMT_SPAWN_PROC');
          fnd_message.set_token('SPAWN_ID', p_sub_req_number);
          fnd_file.put_line( fnd_file.LOG ,fnd_message.get);
      END IF;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.spawn_processes.debug','Launched spawned request ' || p_sub_req_number || ' Request ID : ' || l_request_id);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_import_pkg.launch_sub_request.exception','The exception is : ' || SQLERRM );
       END IF;

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.LAUNCH_SUB_REQUEST');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       igs_ge_msg_stack.add;
       RETURN; -- continue processing for the next sub request.
   END launch_sub_request;


   PROCEDURE validate_parameters(errbuf OUT NOCOPY VARCHAR2, Retcode OUT NOCOPY NUMBER)
   IS
     /*
     ||  Created By : rgangara
     ||  Created On : 28-JUL-2004
     ||  Purpose :        Validates all the input parameters which are copied to global variables.
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who              When              What
     ||  (reverse chronological order - newest change first)
     */

      CURSOR cur_batch_aw_map(cp_batch_yr NUMBER)  IS
      SELECT 'Y'
        FROM igf_ap_batch_aw_map
       WHERE batch_year = cp_batch_yr;

      CURSOR cur_lookups(cp_lkup_type igf_lookups_view.lookup_type%TYPE,
                         cp_lkup_code igf_lookups_view.lookup_code%TYPE)  IS
      SELECT 'Y'
        FROM igf_lookups_view
       WHERE lookup_type = cp_lkup_type
         AND lookup_code = cp_lkup_code
         AND enabled_flag = 'Y';

      CURSOR cur_school_cd(cp_school_cd VARCHAR2)  IS
        SELECT
           'Y'
         FROM
          hz_parties hz,
          igs_or_org_alt_ids oli,
          igs_or_org_alt_idtyp olt
         WHERE oli.org_structure_id = hz.party_number
         AND oli.org_alternate_id_type = olt.org_alternate_id_type
         AND SYSDATE BETWEEN  oli.start_date AND nvl (end_date, SYSDATE)
         AND hz.status = 'A'
         AND olt.system_id_type  = 'FED_SCH_CD'
         AND oli.org_alternate_id = cp_school_cd ;

      CURSOR cur_match_set(cp_match_code igf_ap_record_match_all.match_code%TYPE)  IS
      SELECT 'Y'
        FROM igf_ap_record_match
       WHERE match_code = cp_match_code
         AND enabled_flag = 'Y';

      l_valid_found VARCHAR2(1);

   BEGIN
      -----------------------------------------------------------------------------
      -- PARAMETER VALIDATIONS
      -----------------------------------------------------------------------------

      -- Batch Year Validation (Mandatory parameter)
      OPEN  cur_batch_aw_map(g_batch_year) ;
      FETCH cur_batch_aw_map INTO l_valid_found ;

      IF cur_batch_aw_map%NOTFOUND THEN
         CLOSE cur_batch_aw_map ;
         fnd_message.set_name('IGF','IGF_AP_BATCH_YEAR_NOT_FOUND');
         errbuf := fnd_message.get;
         igs_ge_msg_stack.add;
         retcode := 2;
         RETURN;
      END IF ;
      CLOSE cur_batch_aw_map ;

      log_debug_message('  Record type validation... ' || g_rec_type);
      -- Record Type validation
      IF g_rec_type IS NOT NULL THEN
         l_valid_found :=  'N';
         OPEN cur_lookups ('IGF_AP_ISIR_REC_TYPE', g_rec_type);
         FETCH cur_lookups INTO l_valid_found;

         IF cur_lookups%NOTFOUND THEN
            CLOSE cur_lookups;
            fnd_message.set_name('IGF','IGF_AP_INVALID_PARAMETER');
            fnd_message.set_token('PARAM_TYPE', 'RECORD TYPE');
            errbuf := fnd_message.get;
            igs_ge_msg_stack.add;
            retcode := 2;
            RETURN;
         END IF ;
         CLOSE cur_lookups;
      END IF;


      log_debug_message('  Record status validation... ' || g_rec_status);
      -- Record Status validation
      IF g_rec_status IS NOT NULL THEN
         l_valid_found :=  'N';
         OPEN cur_lookups ('IGF_AP_ISIR_STATUS', g_rec_status);
         FETCH cur_lookups INTO l_valid_found;

         IF cur_lookups%NOTFOUND THEN
            CLOSE cur_lookups;
            fnd_message.set_name('IGF','IGF_AP_INVALID_PARAMETER');
            fnd_message.set_token('PARAM_TYPE', 'RECORD STATUS');
            errbuf := fnd_message.get;
            igs_ge_msg_stack.add;
            retcode := 2;
            RETURN;
         END IF ;
         CLOSE cur_lookups;
      END IF;

      log_debug_message('  Message class validation... ' || g_message_class);
      -- Message Class validation
      IF g_message_class IS NOT NULL THEN
         l_valid_found :=  'N';
         OPEN cur_lookups ('IGF_AP_ISIR_TYPE', g_message_class);
         FETCH cur_lookups INTO l_valid_found;

         IF cur_lookups%NOTFOUND THEN
            CLOSE cur_lookups;
            fnd_message.set_name('IGF','IGF_AP_INVALID_PARAMETER');
            fnd_message.set_token('PARAM_TYPE', 'MESSAGE CLASS');
            errbuf := fnd_message.get;
            igs_ge_msg_stack.add;
            retcode := 2;
            RETURN;
         END IF ;
         CLOSE cur_lookups;
      END IF;


      log_debug_message('  Schoold code validation... ' || g_school_code);
      -- School Code validation
      IF g_school_code IS NOT NULL THEN
         l_valid_found :=  'N';
         OPEN cur_school_cd (g_school_code);
         FETCH cur_school_cd INTO l_valid_found;

         IF cur_school_cd%NOTFOUND THEN
            CLOSE cur_school_cd;
            fnd_message.set_name('IGF','IGF_AP_INVALID_PARAMETER');
            fnd_message.set_token('PARAM_TYPE', 'SCHOOL CODE');
            errbuf := fnd_message.get;
            igs_ge_msg_stack.add;
            retcode := 2;
            RETURN;
         END IF ;
         CLOSE cur_school_cd;
      END IF;


      log_debug_message('  Match Code validation... ' || g_match_code);
      -- Match Code validation (Mandatory parameter)
      l_valid_found :=  'N';
      OPEN cur_match_set(g_match_code);
      FETCH cur_match_set INTO l_valid_found;

      IF cur_match_set%NOTFOUND THEN
         CLOSE cur_match_set;
         fnd_message.set_name('IGF','IGF_AP_INVALID_PARAMETER');
         fnd_message.set_token('PARAM_TYPE', 'MATCH SET CODE');
         errbuf := fnd_message.get;
         igs_ge_msg_stack.add;
         retcode := 2;
         RETURN;
      END IF ;
      CLOSE cur_match_set;

      log_debug_message('  All validations successful... ');

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.validate_parameters.debug', 'Successfully Completed validate_parameters procedure.');
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_import_pkg.validate_parameters.exception','The exception is : ' || SQLERRM );
       END IF;

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.VALIDATE_PARAMETERS');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.put_line(fnd_file.log, SQLERRM);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
   END validate_parameters;



   PROCEDURE build_selection_criteria
   IS
     /*
     ||  Created By : rgangara
     ||  Created On : 28-JUL-2004
     ||  Purpose :        Builds the dynamic record selection criteria based on parameters.
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who              When              What
     ||  (reverse chronological order - newest change first)
     */

   BEGIN

      log_debug_message(' Beginning Building record Selection criteria ');

      -- adding record status filtering
      IF g_rec_status IS NOT NULL THEN

         IF g_rec_status = 'N' THEN -- New
            g_where := g_where || ' AND record_status = ' || '''NEW''';

         ELSIF g_rec_status = 'R' THEN -- Review
            g_where := g_where || ' AND record_status = ' || '''REVIEW''';

         ELSIF g_rec_status = 'U' THEN -- Unmatched
            g_where := g_where || ' AND record_status = ' || '''UNMATCHED''';

         ELSIF g_rec_status = 'NR' THEN -- New and Review
            g_where := g_where || ' AND record_status IN (' || '''REVIEW''' || ',' || '''NEW''' || ')';

         ELSIF g_rec_status = 'NU' THEN -- New and Unmatched
            g_where := g_where || ' AND record_status IN (' || '''NEW''' || ',' || '''UNMATCHED''' || ')';

         ELSIF g_rec_status = 'RU' THEN -- Review and Unmatched
            g_where := g_where || ' AND record_status IN (' || '''REVIEW''' || ',' || '''UNMATCHED''' || ')';

         END IF;

      ELSE -- g_rec_status
         -- no rec status filtering given hence process all except matched records.
         g_where := g_where || ' AND record_status IN (' || '''REVIEW''' || ',' || '''UNMATCHED''' || ',' || '''NEW''' || ')';
      END IF; -- g_rec_status


      log_debug_message(' Record type filtering... ');
      -- adding Record Type filtering
      IF g_rec_type IS NOT NULL THEN

         IF g_rec_type = 'O' THEN -- Original ISIR records
            g_where := g_where || ' AND (processed_rec_type IS NULL OR processed_rec_type NOT IN (''C'',''H''))';
         ELSE
            g_where := g_where || ' AND processed_rec_type IN (''C'',''H'')';
         END IF;
      END IF;



      -- adding Message Class filtering RAMMOHAN chk whether function call is efficient or direct derivation.
      IF g_message_class IS NOT NULL THEN
--         g_where := g_where || ' AND ' ||  '''' || g_message_class || '''' || ' = DECODE(INSTR(data_file_name_txt, ''.''), 0, data_file_name_txt, SUBSTR(data_file_name_txt, 1, INSTR(data_file_name_txt, ''.'')-1))';
--         g_where := g_where || ' AND ' ||  '''' || g_message_class || '''' || ' = igf_ap_matching_process_pkg.get_msg_class_from_filename(data_file_name_txt) ';
     g_where := g_where || ' AND ' || ' igf_ap_matching_process_pkg.get_msg_class_from_filename(data_file_name_txt) IN (' || get_msg_class(g_message_class) || ')';
      END IF;


      -- adding School Code filtering
      IF g_school_code IS NOT NULL THEN
         g_where := g_where || ' AND ' || '''' || g_school_code || '''' || ' IN (first_college_cd, second_college_cd, third_college_cd, fourth_college_cd, fifth_college_cd, sixth_college_cd) ';
      END IF;

--    fnd_file.put_line(fnd_file.LOG, ' Dynamic Where Clause : ' || g_where);
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.build_selection_criteria.debug', 'Successfully Completed build_selection_criteria procedure.');
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_import_pkg.build_selection_criteria.exception','The exception is : ' || SQLERRM );
       END IF;

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.BUILD_SELECTION_CRITERIA');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       fnd_file.put_line(fnd_file.log, SQLERRM);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
   END build_selection_criteria;


   PROCEDURE query_isir_records
   IS
     /*
     ||  Created By : rgangara
     ||  Created On : 28-JUL-2004
     ||  Purpose :        fetches records from the ISIR interface table for processing.
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who              When              What
     ||  (reverse chronological order - newest change first)
     */

     -- define a REF Cursor for fetching data using the query created
     TYPE isir_int_ref_cur IS REF CURSOR;
     isir_int_cur isir_int_ref_cur;

     i NUMBER := 1;

   BEGIN

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.query_isir_records.debug', 'Beginning procedure query_isir_records');
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.query_isir_records.debug', 'Querying SQL Query : ' || g_where);
      END IF;

      i := 1;
      -- Execute the query and get the records into temp table.
      OPEN isir_int_cur FOR g_where;

      -- create one row in table type variables
      g_si_id_tab.extend;
      g_batch_year_num_tab.extend;
      g_original_ssn_txt_tab.extend;
      g_orig_name_id_txt_tab.extend;


      FETCH isir_int_cur INTO g_si_id_tab(i), g_batch_year_num_tab(i), g_original_ssn_txt_tab(i), g_orig_name_id_txt_tab(i);

      -- BULK COLLECT option is not supported hence used loop. Once supported the loop can be removed and the above fetch modified
      -- to populate directly to variables without subscripts.
      WHILE isir_int_cur%FOUND LOOP
         -- extend the tables
         g_si_id_tab.extend;
         g_batch_year_num_tab.extend;
         g_original_ssn_txt_tab.extend;
         g_orig_name_id_txt_tab.extend;
         i := i + 1;
         FETCH isir_int_cur INTO g_si_id_tab(i), g_batch_year_num_tab(i), g_original_ssn_txt_tab(i), g_orig_name_id_txt_tab(i);
      END LOOP;
      CLOSE isir_int_cur ;
      i := i - 1;  -- since the counter would be incremented by 1 extra iteration.

      -- get the count of No. of ISIR records for processing.
      g_total_recs_fetched := g_si_id_tab.COUNT;
      log_debug_message('Populated temporary PL/SQL table. Records :  ' || g_total_recs_fetched || '. Time : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.query_isir_records.debug', 'No. of records fetched for processing : ' || g_total_recs_fetched);
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_import_pkg.query_isir_records.exception','The exception is : ' || SQLERRM );
         END IF;
         log_debug_message('EXCEPTION : ' || SQLERRM);

         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.QUERY_ISIR_RECORDS');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         fnd_file.put_line(fnd_file.log, SQLERRM);
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
   END query_isir_records;


   PROCEDURE spawn_processes(p_spawn_process NUMBER)
   IS
     /*
     ||  Created By : rgangara
     ||  Created On : 28-JUL-2004
     ||  Purpose :    For records distribution and launching spawned/parallel processes.
     ||  Known limitations, enhancements or remarks :
     ||  Change History :
     ||  Who              When              What
     ||  (reverse chronological order - newest change first)
     */

    l_recs_per_process     NUMBER;  -- No. of records to process per Spawned process
    l_remaining_recs       NUMBER;  -- No. of records remaining to be processed
    l_from_rec             NUMBER;  -- Holds the starting record position for the current sub request.
    l_to_rec               NUMBER;  -- Holds the last record position for the current sub request.
    l_current_sub_req_recs NUMBER;  -- Holds the total No. of records to be processed for the current sub request.

   BEGIN

      log_debug_message(' Beginning process spawning....');
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.spawn_processes.debug', 'No. of processes to spawn : ' || p_spawn_process);
      END IF;

      -- get the No. of records per process
      l_recs_per_process := CEIL(g_total_recs_fetched/p_spawn_process);

      l_remaining_recs := g_total_recs_fetched;
      l_from_rec := 1; -- initialize the rec pointer
      l_to_rec   := 0;

      -- loop thru as many times as the No. of spawns needed
      FOR i IN 1..p_spawn_process LOOP

         l_current_sub_req_recs := 0; -- initialize for each sub request

         -- identify the Total No. of recs to process for the current sub request
         IF l_remaining_recs < l_recs_per_process THEN
            l_current_sub_req_recs := l_remaining_recs; -- if remaining recs for processing is less, process only remaining recs
         ELSE
            l_current_sub_req_recs := l_recs_per_process; -- Process recs as derived by the recs per process
         END IF;

         -- derive the last record to be processed for the current sub request.
         l_to_rec := l_from_rec + l_current_sub_req_recs - 1;

         ----------------------------------------------------------------------------
         -- At this point No. of Recs to process for the current sub request have been determined.
         -- Now check if the next record after the last record to process (for this subrequest) is for the same person.
         -- If so they have to be included in the current sub request since as per the policy
         -- ISIRs for the same person should be processed by the same sub request.
         ----------------------------------------------------------------------------

         IF g_si_id_tab.EXISTS(l_to_rec + 1) THEN -- check whether it is the last record.

               -- i.e. check whether the immeidate next record belongs to the same person.
               -- If so till they are same, add them to the current sub request.
               WHILE g_original_ssn_txt_tab(l_to_rec + 1) = g_original_ssn_txt_tab(l_to_rec) AND
                     g_orig_name_id_txt_tab(l_to_rec + 1) = g_orig_name_id_txt_tab(l_to_rec) AND
                     g_batch_year_num_tab(l_to_rec + 1)   = g_batch_year_num_tab(l_to_rec)
               LOOP

                  -- update tracking variables.
                  l_to_rec               := l_to_rec + 1;
                  l_current_sub_req_recs := l_current_sub_req_recs + 1;

                  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.spawn_processes.debug', 'Adding SI_ID ' || g_si_id_tab(l_to_rec) || ' to Sub Request No. ' ||  i);
                  END IF;
                  log_debug_message(' Next record belongs to same person!!!!. Including in the current sub reqeust itself. SI_ID ' ||  g_si_id_tab(l_to_rec));
               END LOOP;
         END IF; -- g_proc_recs_tab

         log_debug_message('TOTAL RECORDS for Sub Request No. ' ||  i ||  '  is ' || l_current_sub_req_recs);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.spawn_processes.debug', 'Total records for Sub Request No. ' ||  i ||  '  is ' || l_current_sub_req_recs);
         END IF;

         ----------------------------------------------------------------------------
         -- At this point Final Recs to be processed for the current sub request have been included.
         ----------------------------------------------------------------------------
         -- Now update the interface table for the identified recs with the sub request no.
         FORALL k IN l_from_rec..l_to_rec -- No. of recs to process from the current rec pointer.
            UPDATE igf_ap_isir_ints
            SET    parent_req_id = g_parent_req_number,
                   sub_req_num   = i
            WHERE  si_id         = g_si_id_tab(k);


         COMMIT; -- commit the parent request id and sub request number updates to Interface table.

         -- increment counters to process from the next rec for the next sub request.
         l_remaining_recs := l_remaining_recs - l_current_sub_req_recs; -- No. of recs still to be processed
         l_from_rec       := l_to_rec + 1; -- increment the from rec pointer to point to the next record

         -- Launch Sub request
         launch_sub_request(p_sub_req_number => i, p_sub_req_rec_cnt => l_current_sub_req_recs);


         IF l_remaining_recs <= 0 THEN
            -- No. more recs exists for processing. Hence exit the loop. No need to fire remaining spawn processes
            EXIT;
         END IF;

      END LOOP; -- i

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.spawn_processes.debug', 'Completed updating Spawning Processes details.... ');
      END IF;
      log_debug_message(' Spawning Process completed successfully. Exitting.....at.. ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

   EXCEPTION
      WHEN OTHERS THEN
       IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_ap_isir_import_pkg.spawn_processes.exception','The exception is : ' || SQLERRM );
       END IF;
       log_debug_message(' EXCEPTION in spawn_processes : ' || SQLERRM);

       fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
       fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.SPAWN_PROCESSES');
       fnd_file.put_line(fnd_file.log,fnd_message.get);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
   END spawn_processes;


------------------------------------------------------------
-- End of Local new Procedures created for FA138 build - rgangara.
------------------------------------------------------------

BEGIN

   igf_aw_gen.set_org_id(p_org_id);

   log_debug_message(' Beginning Main process at ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

   -- print input parameters
   fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------------------------------');
   fnd_message.set_name('IGF', 'IGF_AP_AWD_YR');
   fnd_message.set_token('AWD_YEAR', p_award_year);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_CREATE_PRSN_NO_MATCH');
   fnd_message.set_token('CREATE_PRSN', p_force_add);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_CREATE_ADM_INQ');
   fnd_message.set_token('CREATE_INQ', p_create_inquiry);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_ADM_INQ_MTHD');
   fnd_message.set_token('INQ_METHOD', p_adm_source_type);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_MATCH_CODE');
   fnd_message.set_token('MATCH_CODE', p_match_code);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_REC_TYPE');
   fnd_message.set_token('REC_TYPE', p_rec_type);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_REC_STAT');
   fnd_message.set_token('REC_STATUS', p_rec_status);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_MSG_CLASS');
   fnd_message.set_token('MSG_CLASS', p_message_class);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_SCHOOL_CD');
   fnd_message.set_token('SCHOOL_CD', p_school_code);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_SPAWN_REQ');
   fnd_message.set_token('SPAWN_CNT', p_spawn_process);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_DEL_INT_RECORD');
   fnd_message.set_token('DEL_FLAG', p_del_int);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_message.set_name('IGF', 'IGF_AP_UPD_ANT_DATA');
   fnd_message.set_token('UPD_ANT', p_upd_ant_val);
   fnd_file.put_line(fnd_file.log, fnd_message.get);

   fnd_file.put_line(fnd_file.log, '-----------------------------------------------------------------------------------------');

   errbuf             := NULL;
   retcode            := 0;
   l_cal_type         := LTRIM(RTRIM(SUBSTR(p_award_year,1,10)));
   l_seq_number       := TO_NUMBER(SUBSTR(p_award_year,11));

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.main_import_process.debug','Beginning Main process. Before gathering Statistics: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
   END IF;

   -- gather Statistics RAMMOHAN commented for testing
   log_debug_message(' Starting to gather statistics. ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
   fnd_stats.gather_table_stats(ownname        => 'IGF', tabname => 'IGF_AP_ISIR_INTS_ALL'    , cascade => TRUE);
   fnd_stats.gather_table_stats(ownname        => 'IGF', tabname => 'IGF_AP_ISIR_MATCHED_ALL' , cascade => TRUE);
   log_debug_message(' End of Statistics gathering. ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.main_import_process.debug','After gathering Statistics: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
   END IF;


   -- Copying the parameter values to the gobal variable.
   g_where             := NULL;
   g_force_add         := NVL(p_force_add, 'N');
   g_create_inquiry    := NVL(p_create_inquiry,'N');
   g_adm_source_type   := p_adm_source_type;
   g_match_code        := p_match_code;
   g_rec_status        := p_rec_status     ;
   g_rec_type          := p_rec_type       ;
   g_message_class     := p_message_class  ;
   g_school_code       := p_school_code    ;
   g_del_int           := NVL(p_del_int, 'N');
   g_parent_req_number := fnd_global.conc_request_id;  -- get the current request id as this would be the parent request id for the sub requests.

   OPEN c_batch(l_cal_type,l_seq_number) ;
   FETCH c_batch INTO l_batch;
   CLOSE c_batch;

   IF l_batch.batch_year IS NULL THEN
        fnd_message.set_name('IGF','IGF_AP_BATCH_YEAR_NOT_FOUND');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        RETCODE := 2;
        RETURN;
   END IF;
   g_batch_year := l_batch.batch_year;


   -- Initialize the variable with Basic SQL statement to which the dynamic where clause can be appended later.
   l_sql := 'SELECT si_id, batch_year_num, original_ssn_txt, orig_name_id_txt  FROM igf_ap_isir_ints WHERE batch_year_num = ' || g_batch_year  ;

   IF LTRIM(RTRIM(p_create_inquiry)) = 'Y' AND LTRIM(RTRIM(p_adm_source_type)) IS NULL THEN
       fnd_message.set_name('IGF', 'IGF_AP_SOURCE_TYPE_REQ');
       errbuf := fnd_message.get;
       fnd_file.put_line(fnd_file.log,errbuf);
       retcode := 2;
       RETURN;
   END IF;

   -- call procedure to validate parameters
   validate_parameters(retcode => retcode,  errbuf => errbuf);

   IF retcode <> 0 THEN -- i.e. some parameter validation failed.
      RETURN;
   END IF;

   -- call procedure to build ISIR record selection criteria based on given parameters
   build_selection_criteria;

   -- build the complete SQL statement
   g_where := l_sql || g_where || ' ORDER BY original_ssn_txt, orig_name_id_txt, batch_year_num ' ;

   log_debug_message(' FINAL QUERY : ' || g_where );
   -- call procedure to get interface records for processing
   query_isir_records;

   -- Check whether any records found for processing for the query
   IF g_total_recs_fetched = 0 THEN
      fnd_message.set_name ('IGF','IGF_AP_MATCHING_REC_NT_FND');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.log, errbuf);
      retcode := 1;
      RETURN;
   END IF;

   -- spawn processes only if the No. of recs to process is > No. of processes
   IF NVL(p_spawn_process,1) > 1 AND g_total_recs_fetched > NVL(p_spawn_process,1) THEN
      -- records distribution and launching spawned/parallel processes
      spawn_processes(NVL(p_spawn_process,1));

   ELSE
      log_debug_message('Processing as a Single Request.');
      -- Single request hence update the identified recs with the sub request no.
      FORALL k IN 1..g_total_recs_fetched
         UPDATE igf_ap_isir_ints
         SET    parent_req_id = g_parent_req_number,
                sub_req_num   = 1
         WHERE  si_id         = g_si_id_tab(k);


      COMMIT; -- commit the parent request id and sub request number updates to Interface table.

      log_debug_message('Launching Sub Request as a Single Request.');
      -- Launch Sub request
      launch_sub_request(p_sub_req_number => 1, p_sub_req_rec_cnt => g_total_recs_fetched);
   END IF;

   log_debug_message('Successfully completed the Request at : ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS')) ;
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_isir_import_pkg.main_import_process.debug','Successfully Completed the process at: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS'));
   END IF;

EXCEPTION
        WHEN others THEN
        ROLLBACK;
        retcode := 2;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.MAIN_IMPORT_PROCESS');
        fnd_file.put_line(fnd_file.log,SQLERRM);
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;
END main_import_process;


PROCEDURE update_matched_ISIR (p_ISIR_id             igf_ap_ISIR_matched_all.ISIR_id%TYPE,
                               p_system_record_type  igf_ap_ISIR_matched_all.system_record_type%TYPE,
                               p_payment_ISIR        igf_ap_ISIR_matched_all.payment_ISIR%TYPE,
                               p_active_ISIR         igf_ap_ISIR_matched_all.active_ISIR%TYPE)
IS
/*
||  Created By : brajendr
||  Created On : 08-NOV-2000
||  Purpose : Process which inserts comment codes of the student.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  smvk            11-Feb-2003     Bug # 2758812. Added the procedure call igf_gr_gen.update_current_ssn.
||  masehgal        15-Feb-2002     # 2216956     FACR007
||                                  Added Verif_track_flag
||  (reverse chronological order - newest change first)
*/

CURSOR cur_upd_ISIR IS
SELECT ism.*
FROM   igf_ap_ISIR_matched ism
WHERE  ism.ISIR_id = p_ISIR_id;


cur_ISIR_rec     cur_upd_ISIR%ROWTYPE;
p_c_message      VARCHAR2(30);
l_msg_class      igf_ap_isir_matched.message_class_txt%TYPE;

BEGIN
  IF p_system_record_type = 'ORIGINAL' THEN
     FOR cur_ISIR_rec IN cur_upd_ISIR LOOP

        -- get message class from data file name
        l_msg_class := igf_ap_matching_process_pkg.get_msg_class_from_filename(cur_ISIR_rec.data_file_name_txt);

        igf_ap_ISIR_matched_pkg.update_row (x_Mode                              => 'R',
                                            x_rowid                             => cur_ISIR_rec.row_id,
                                            x_ISIR_id                           => cur_ISIR_rec.ISIR_id,
                                            x_base_id                           => cur_ISIR_rec.base_id,
                                            x_batch_year                        => cur_ISIR_rec.batch_year,
                                            x_transaction_num                   => cur_ISIR_rec.transaction_num,
                                            x_current_ssn                       => cur_ISIR_rec.current_ssn,
                                            x_ssn_name_change                   => cur_ISIR_rec.ssn_name_change,
                                            x_original_ssn                      => cur_ISIR_rec.original_ssn,
                                            x_orig_name_id                      => cur_ISIR_rec.orig_name_id,
                                            x_last_name                         => cur_ISIR_rec.last_name,
                                            x_first_name                        => cur_ISIR_rec.first_name,
                                            x_middle_initial                    => cur_ISIR_rec.middle_initial,
                                            x_perm_mail_add                     => cur_ISIR_rec.perm_mail_add,
                                            x_perm_city                         => cur_ISIR_rec.perm_city,
                                            x_perm_state                        => cur_ISIR_rec.perm_state,
                                            x_perm_zip_code                     => cur_ISIR_rec.perm_zip_code,
                                            x_date_of_birth                     => cur_ISIR_rec.date_of_birth,
                                            x_phone_number                      => cur_ISIR_rec.phone_number,
                                            x_driver_license_number             => cur_ISIR_rec.driver_license_number,
                                            x_driver_license_state              => cur_ISIR_rec.driver_license_state,
                                            x_citizenship_status                => cur_ISIR_rec.citizenship_status,
                                            x_alien_reg_number                  => cur_ISIR_rec.alien_reg_number,
                                            x_s_marital_status                  => cur_ISIR_rec.s_marital_status,
                                            x_s_marital_status_date             => cur_ISIR_rec.s_marital_status_date,
                                            x_summ_enrl_status                  => cur_ISIR_rec.summ_enrl_status,
                                            x_fall_enrl_status                  => cur_ISIR_rec.fall_enrl_status,
                                            x_winter_enrl_status                => cur_ISIR_rec.winter_enrl_status,
                                            x_spring_enrl_status                => cur_ISIR_rec.spring_enrl_status,
                                            x_summ2_enrl_status                 => cur_ISIR_rec.summ2_enrl_status,
                                            x_fathers_highest_edu_level         => cur_ISIR_rec.fathers_highest_edu_level,
                                            x_mothers_highest_edu_level         => cur_ISIR_rec.mothers_highest_edu_level,
                                            x_s_state_legal_residence           => cur_ISIR_rec.s_state_legal_residence,
                                            x_legal_residence_before_date       => cur_ISIR_rec.legal_residence_before_date,
                                            x_s_legal_resd_date                 => cur_ISIR_rec.s_legal_resd_date,
                                            x_ss_r_u_male                       => cur_ISIR_rec.ss_r_u_male,
                                            x_selective_service_reg             => cur_ISIR_rec.selective_service_reg,
                                            x_degree_certification              => cur_ISIR_rec.degree_certification,
                                            x_grade_level_in_college            => cur_ISIR_rec.grade_level_in_college,
                                            x_high_school_diploma_ged           => cur_ISIR_rec.high_school_diploma_ged,
                                            x_first_bachelor_deg_by_date        => cur_ISIR_rec.first_bachelor_deg_by_date,
                                            x_interest_in_loan                  => cur_ISIR_rec.interest_in_loan,
                                            x_interest_in_stud_employment       => cur_ISIR_rec.interest_in_stud_employment,
                                            x_drug_offence_conviction           => cur_ISIR_rec.drug_offence_conviction,
                                            x_s_tax_return_status               => cur_ISIR_rec.s_tax_return_status,
                                            x_s_type_tax_return                 => cur_ISIR_rec.s_type_tax_return,
                                            x_s_elig_1040ez                     => cur_ISIR_rec.s_elig_1040ez,
                                            x_s_adjusted_gross_income           => cur_ISIR_rec.s_adjusted_gross_income,
                                            x_s_fed_taxes_paid                  => cur_ISIR_rec.s_fed_taxes_paid,
                                            x_s_exemptions                      => cur_ISIR_rec.s_exemptions,
                                            x_s_income_from_work                => cur_ISIR_rec.s_income_from_work,
                                            x_spouse_income_from_work           => cur_ISIR_rec.spouse_income_from_work,
                                            x_s_toa_amt_from_wsa                => cur_ISIR_rec.s_toa_amt_from_wsa,
                                            x_s_toa_amt_from_wsb                => cur_ISIR_rec.s_toa_amt_from_wsb,
                                            x_s_toa_amt_from_wsc                => cur_ISIR_rec.s_toa_amt_from_wsc,
                                            x_s_investment_networth             => cur_ISIR_rec.s_investment_networth,
                                            x_s_busi_farm_networth              => cur_ISIR_rec.s_busi_farm_networth,
                                            x_s_cash_savings                    => cur_ISIR_rec.s_cash_savings,
                                            x_va_months                         => cur_ISIR_rec.va_months,
                                            x_va_amount                         => cur_ISIR_rec.va_amount,
                                            x_stud_dob_before_date              => cur_ISIR_rec.stud_dob_before_date,
                                            x_deg_beyond_bachelor               => cur_ISIR_rec.deg_beyond_bachelor,
                                            x_s_married                         => cur_ISIR_rec.s_married,
                                            x_s_have_children                   => cur_ISIR_rec.s_have_children,
                                            x_legal_dependents                  => cur_ISIR_rec.legal_dependents,
                                            x_orphan_ward_of_court              => cur_ISIR_rec.orphan_ward_of_court,
                                            x_s_veteran                         => cur_ISIR_rec.s_veteran,
                                            x_p_marital_status                  => cur_ISIR_rec.p_marital_status,
                                            x_father_ssn                        => cur_ISIR_rec.father_ssn,
                                            x_f_last_name                       => cur_ISIR_rec.f_last_name,
                                            x_mother_ssn                        => cur_ISIR_rec.mother_ssn,
                                            x_m_last_name                       => cur_ISIR_rec.m_last_name,
                                            x_p_num_family_member               => cur_ISIR_rec.p_num_family_member,
                                            x_p_num_in_college                  => cur_ISIR_rec.p_num_in_college,
                                            x_p_state_legal_residence           => cur_ISIR_rec.p_state_legal_residence,
                                            x_p_state_legal_res_before_dt       => cur_ISIR_rec.p_state_legal_res_before_dt,
                                            x_p_legal_res_date                  => cur_ISIR_rec.p_legal_res_date,
                                            x_age_older_parent                  => cur_ISIR_rec.age_older_parent,
                                            x_p_tax_return_status               => cur_ISIR_rec.p_tax_return_status,
                                            x_p_type_tax_return                 => cur_ISIR_rec.p_type_tax_return,
                                            x_p_elig_1040aez                    => cur_ISIR_rec.p_elig_1040aez,
                                            x_p_adjusted_gross_income           => cur_ISIR_rec.p_adjusted_gross_income,
                                            x_p_taxes_paid                      => cur_ISIR_rec.p_taxes_paid,
                                            x_p_exemptions                      => cur_ISIR_rec.p_exemptions,
                                            x_f_income_work                     => cur_ISIR_rec.f_income_work,
                                            x_m_income_work                     => cur_ISIR_rec.m_income_work,
                                            x_p_income_wsa                      => cur_ISIR_rec.p_income_wsa,
                                            x_p_income_wsb                      => cur_ISIR_rec.p_income_wsb,
                                            x_p_income_wsc                      => cur_ISIR_rec.p_income_wsc,
                                            x_p_investment_networth             => cur_ISIR_rec.p_investment_networth,
                                            x_p_business_networth               => cur_ISIR_rec.p_business_networth,
                                            x_p_cash_saving                     => cur_ISIR_rec.p_cash_saving,
                                            x_s_num_family_members              => cur_ISIR_rec.s_num_family_members,
                                            x_s_num_in_college                  => cur_ISIR_rec.s_num_in_college,
                                            x_first_college                     => cur_ISIR_rec.first_college,
                                            x_first_house_plan                  => cur_ISIR_rec.first_house_plan,
                                            x_second_college                    => cur_ISIR_rec.second_college,
                                            x_second_house_plan                 => cur_ISIR_rec.second_house_plan,
                                            x_third_college                     => cur_ISIR_rec.third_college,
                                            x_third_house_plan                  => cur_ISIR_rec.third_house_plan,
                                            x_fourth_college                    => cur_ISIR_rec.fourth_college,
                                            x_fourth_house_plan                 => cur_ISIR_rec.fourth_house_plan,
                                            x_fifth_college                     => cur_ISIR_rec.fifth_college,
                                            x_fifth_house_plan                  => cur_ISIR_rec.fifth_house_plan,
                                            x_sixth_college                     => cur_ISIR_rec.sixth_college,
                                            x_sixth_house_plan                  => cur_ISIR_rec.sixth_house_plan,
                                            x_date_app_completed                => cur_ISIR_rec.date_app_completed,
                                            x_signed_by                         => cur_ISIR_rec.signed_by,
                                            x_preparer_ssn                      => cur_ISIR_rec.preparer_ssn,
                                            x_preparer_emp_id_number            => cur_ISIR_rec.preparer_emp_id_number,
                                            x_preparer_sign                     => cur_ISIR_rec.preparer_sign,
                                            x_transaction_receipt_date          => cur_ISIR_rec.transaction_receipt_date,
                                            x_dependency_override_ind           => cur_ISIR_rec.dependency_override_ind,
                                            x_faa_fedral_schl_code              => cur_ISIR_rec.faa_fedral_schl_code,
                                            x_faa_adjustment                    => cur_ISIR_rec.faa_adjustment,
                                            x_input_record_type                 => cur_ISIR_rec.input_record_type,
                                            x_serial_number                     => cur_ISIR_rec.serial_number,
                                            x_batch_number                      => cur_ISIR_rec.batch_number,
                                            x_early_analysis_flag               => cur_ISIR_rec.early_analysis_flag,
                                            x_app_entry_source_code             => cur_ISIR_rec.app_entry_source_code,
                                            x_eti_destination_code              => cur_ISIR_rec.eti_destination_code,
                                            x_reject_override_b                 => cur_ISIR_rec.reject_override_b,
                                            x_reject_override_n                 => cur_ISIR_rec.reject_override_n,
                                            x_reject_override_w                 => cur_ISIR_rec.reject_override_w,
                                            x_assum_override_1                  => cur_ISIR_rec.assum_override_1,
                                            x_assum_override_2                  => cur_ISIR_rec.assum_override_2,
                                            x_assum_override_3                  => cur_ISIR_rec.assum_override_3,
                                            x_assum_override_4                  => cur_ISIR_rec.assum_override_4,
                                            x_assum_override_5                  => cur_ISIR_rec.assum_override_5,
                                            x_assum_override_6                  => cur_ISIR_rec.assum_override_6,
                                            x_dependency_status                 => cur_ISIR_rec.dependency_status,
                                            x_s_email_address                   => cur_ISIR_rec.s_email_address,
                                            x_nslds_reason_code                 => cur_ISIR_rec.nslds_reason_code,
                                            x_app_receipt_date                  => cur_ISIR_rec.app_receipt_date,
                                            x_processed_rec_type                => cur_ISIR_rec.processed_rec_type,
                                            x_hist_correction_for_tran_id       => cur_ISIR_rec.hist_correction_for_tran_id,
                                            x_system_generated_indicator        => cur_ISIR_rec.system_generated_indicator,
                                            x_dup_request_indicator             => cur_ISIR_rec.dup_request_indicator,
                                            x_source_of_correction              => cur_ISIR_rec.source_of_correction,
                                            x_p_cal_tax_status                  => cur_ISIR_rec.p_cal_tax_status,
                                            x_s_cal_tax_status                  => cur_ISIR_rec.s_cal_tax_status,
                                            x_graduate_flag                     => cur_ISIR_rec.graduate_flag,
                                            x_auto_zero_efc                     => cur_ISIR_rec.auto_zero_efc,
                                            x_efc_change_flag                   => cur_ISIR_rec.efc_change_flag,
                                            x_sarc_flag                         => cur_ISIR_rec.sarc_flag,
                                            x_simplified_need_test              => cur_ISIR_rec.simplified_need_test,
                                            x_reject_reason_codes               => cur_ISIR_rec.reject_reason_codes,
                                            x_select_service_match_flag         => cur_ISIR_rec.select_service_match_flag,
                                            x_select_service_reg_flag           => cur_ISIR_rec.select_service_reg_flag,
                                            x_ins_match_flag                    => cur_ISIR_rec.ins_match_flag,
                                            x_ins_verification_number           => NULL,
                                            x_sec_ins_match_flag                => cur_ISIR_rec.sec_ins_match_flag,
                                            x_sec_ins_ver_number                => cur_ISIR_rec.sec_ins_ver_number,
                                            x_ssn_match_flag                    => cur_ISIR_rec.ssn_match_flag,
                                            x_ssa_citizenship_flag              => cur_ISIR_rec.ssa_citizenship_flag,
                                            x_ssn_date_of_death                 => cur_ISIR_rec.ssn_date_of_death,
                                            x_nslds_match_flag                  => cur_ISIR_rec.nslds_match_flag,
                                            x_va_match_flag                     => cur_ISIR_rec.va_match_flag,
                                            x_prisoner_match                    => cur_ISIR_rec.prisoner_match,
                                            x_verification_flag                 => cur_ISIR_rec.verification_flag,
                                            x_subsequent_app_flag               => cur_ISIR_rec.subsequent_app_flag,
                                            x_app_source_site_code              => cur_ISIR_rec.app_source_site_code,
                                            x_tran_source_site_code             => cur_ISIR_rec.tran_source_site_code,
                                            x_drn                               => cur_ISIR_rec.drn,
                                            x_tran_process_date                 => cur_ISIR_rec.tran_process_date,
                                            x_computer_batch_number             => cur_ISIR_rec.computer_batch_number,
                                            x_correction_flags                  => cur_ISIR_rec.correction_flags,
                                            x_highlight_flags                   => cur_ISIR_rec.highlight_flags,
                                            x_paid_efc                          => NULL,
                                            x_primary_efc                       => cur_ISIR_rec.primary_efc,
                                            x_secondary_efc                     => cur_ISIR_rec.secondary_efc,
                                            x_fed_pell_grant_efc_type           => NULL,
                                            x_primary_efc_type                  => cur_ISIR_rec.primary_efc_type,
                                            x_sec_efc_type                      => cur_ISIR_rec.sec_efc_type,
                                            x_primary_alternate_month_1         => cur_ISIR_rec.primary_alternate_month_1,
                                            x_primary_alternate_month_2         => cur_ISIR_rec.primary_alternate_month_2,
                                            x_primary_alternate_month_3         => cur_ISIR_rec.primary_alternate_month_3,
                                            x_primary_alternate_month_4         => cur_ISIR_rec.primary_alternate_month_4,
                                            x_primary_alternate_month_5         => cur_ISIR_rec.primary_alternate_month_5,
                                            x_primary_alternate_month_6         => cur_ISIR_rec.primary_alternate_month_6,
                                            x_primary_alternate_month_7         => cur_ISIR_rec.primary_alternate_month_7,
                                            x_primary_alternate_month_8         => cur_ISIR_rec.primary_alternate_month_8,
                                            x_primary_alternate_month_10        => cur_ISIR_rec.primary_alternate_month_10,
                                            x_primary_alternate_month_11        => cur_ISIR_rec.primary_alternate_month_11,
                                            x_primary_alternate_month_12        => cur_ISIR_rec.primary_alternate_month_12,
                                            x_sec_alternate_month_1             => cur_ISIR_rec.sec_alternate_month_1,
                                            x_sec_alternate_month_2             => cur_ISIR_rec.sec_alternate_month_2,
                                            x_sec_alternate_month_3             => cur_ISIR_rec.sec_alternate_month_3,
                                            x_sec_alternate_month_4             => cur_ISIR_rec.sec_alternate_month_4,
                                            x_sec_alternate_month_5             => cur_ISIR_rec.sec_alternate_month_5,
                                            x_sec_alternate_month_6             => cur_ISIR_rec.sec_alternate_month_6,
                                            x_sec_alternate_month_7             => cur_ISIR_rec.sec_alternate_month_7,
                                            x_sec_alternate_month_8             => cur_ISIR_rec.sec_alternate_month_8,
                                            x_sec_alternate_month_10            => cur_ISIR_rec.sec_alternate_month_10,
                                            x_sec_alternate_month_11            => cur_ISIR_rec.sec_alternate_month_11,
                                            x_sec_alternate_month_12            => cur_ISIR_rec.sec_alternate_month_12,
                                            x_total_income                      => cur_ISIR_rec.total_income,
                                            x_allow_total_income                => cur_ISIR_rec.allow_total_income,
                                            x_state_tax_allow                   => cur_ISIR_rec.state_tax_allow,
                                            x_employment_allow                  => cur_ISIR_rec.employment_allow,
                                            x_income_protection_allow           => cur_ISIR_rec.income_protection_allow,
                                            x_available_income                  => cur_ISIR_rec.available_income,
                                            x_contribution_from_ai              => cur_ISIR_rec.contribution_from_ai,
                                            x_discretionary_networth            => cur_ISIR_rec.discretionary_networth,
                                            x_efc_networth                      => cur_ISIR_rec.efc_networth,
                                            x_asset_protect_allow               => cur_ISIR_rec.asset_protect_allow,
                                            x_parents_cont_from_assets          => cur_ISIR_rec.parents_cont_from_assets,
                                            x_adjusted_available_income         => cur_ISIR_rec.adjusted_available_income,
                                            x_total_student_contribution        => cur_ISIR_rec.total_student_contribution,
                                            x_total_parent_contribution         => cur_ISIR_rec.total_parent_contribution,
                                            x_parents_contribution              => cur_ISIR_rec.parents_contribution,
                                            x_student_total_income              => cur_ISIR_rec.student_total_income,
                                            x_sati                              => cur_ISIR_rec.sati,
                                            x_sic                               => cur_ISIR_rec.sic,
                                            x_sdnw                              => cur_ISIR_rec.sdnw,
                                            x_sca                               => cur_ISIR_rec.sca,
                                            x_fti                               => cur_ISIR_rec.fti,
                                            x_secti                             => cur_ISIR_rec.secti,
                                            x_secati                            => cur_ISIR_rec.secati,
                                            x_secstx                            => cur_ISIR_rec.secstx,
                                            x_secea                             => cur_ISIR_rec.secea,
                                            x_secipa                            => cur_ISIR_rec.secipa,
                                            x_secai                             => cur_ISIR_rec.secai,
                                            x_seccai                            => cur_ISIR_rec.seccai,
                                            x_secdnw                            => cur_ISIR_rec.secdnw,
                                            x_secnw                             => cur_ISIR_rec.secnw,
                                            x_secapa                            => cur_ISIR_rec.secapa,
                                            x_secpca                            => cur_ISIR_rec.secpca,
                                            x_secaai                            => cur_ISIR_rec.secaai,
                                            x_sectsc                            => cur_ISIR_rec.sectsc,
                                            x_sectpc                            => cur_ISIR_rec.sectpc,
                                            x_secpc                             => cur_ISIR_rec.secpc,
                                            x_secsti                            => cur_ISIR_rec.secsti,
                                            x_secsic                            => cur_ISIR_rec.secsic,
                                            x_secsati                           => cur_ISIR_rec.secsati,
                                            x_secsdnw                           => cur_ISIR_rec.secsdnw,
                                            x_secsca                            => cur_ISIR_rec.secsca,
                                            x_secfti                            => cur_ISIR_rec.secfti,
                                            x_a_citizenship                     => cur_ISIR_rec.a_citizenship,
                                            x_a_student_marital_status          => cur_ISIR_rec.a_student_marital_status,
                                            x_a_student_agi                     => cur_ISIR_rec.a_student_agi,
                                            x_a_s_us_tax_paid                   => cur_ISIR_rec.a_s_us_tax_paid,
                                            x_a_s_income_work                   => cur_ISIR_rec.a_s_income_work,
                                            x_a_spouse_income_work              => cur_ISIR_rec.a_spouse_income_work,
                                            x_a_s_total_wsc                     => cur_ISIR_rec.a_s_total_wsc,
                                            x_a_date_of_birth                   => cur_ISIR_rec.a_date_of_birth,
                                            x_a_student_married                 => cur_ISIR_rec.a_student_married,
                                            x_a_have_children                   => cur_ISIR_rec.a_have_children,
                                            x_a_s_have_dependents               => cur_ISIR_rec.a_s_have_dependents,
                                            x_a_va_status                       => cur_ISIR_rec.a_va_status,
                                            x_a_s_num_in_family                 => cur_ISIR_rec.a_s_num_in_family,
                                            x_a_s_num_in_college                => cur_ISIR_rec.a_s_num_in_college,
                                            x_a_p_marital_status                => cur_ISIR_rec.a_p_marital_status,
                                            x_a_father_ssn                      => cur_ISIR_rec.a_father_ssn,
                                            x_a_mother_ssn                      => cur_ISIR_rec.a_mother_ssn,
                                            x_a_parents_num_family              => cur_ISIR_rec.a_parents_num_family,
                                            x_a_parents_num_college             => cur_ISIR_rec.a_parents_num_college,
                                            x_a_parents_agi                     => cur_ISIR_rec.a_parents_agi,
                                            x_a_p_us_tax_paid                   => cur_ISIR_rec.a_p_us_tax_paid,
                                            x_a_f_work_income                   => cur_ISIR_rec.a_f_work_income,
                                            x_a_m_work_income                   => cur_ISIR_rec.a_m_work_income,
                                            x_a_p_total_wsc                     => cur_ISIR_rec.a_p_total_wsc,
                                            x_comment_codes                     => cur_ISIR_rec.comment_codes,
                                            x_sar_ack_comm_code                 => cur_ISIR_rec.sar_ack_comm_code,
                                            x_pell_grant_elig_flag              => cur_ISIR_rec.pell_grant_elig_flag,
                                            x_reprocess_reason_code             => cur_ISIR_rec.reprocess_reason_code,
                                            x_duplicate_date                    => cur_ISIR_rec.duplicate_date,
                                            x_ISIR_transaction_type             => cur_ISIR_rec.ISIR_transaction_type,
                                            x_fedral_schl_code_indicator        => cur_ISIR_rec.fedral_schl_code_indicator,
                                            x_multi_school_code_flags           => cur_ISIR_rec.multi_school_code_flags,
                                            x_dup_ssn_indicator                 => cur_ISIR_rec.dup_ssn_indicator,
                                            x_payment_ISIR                      => p_payment_ISIR,
                                            x_receipt_status                    => 'PROCESSED',
                                            x_system_record_type                => p_system_record_type,
                                            x_ISIR_receipt_completed            => 'Y' ,
                                            x_verif_track_flag                  => cur_ISIR_rec.verif_track_flag,
                                            x_active_ISIR                       => NVL(p_active_ISIR,cur_ISIR_rec.active_ISIR),
                                            x_fafsa_data_verify_flags           => cur_ISIR_rec.fafsa_data_verify_flags,
                                            x_reject_override_a                 => cur_ISIR_rec.reject_override_a,
                                            x_reject_override_c                 => cur_ISIR_rec.reject_override_c,
                                            x_parent_marital_status_date        => cur_ISIR_rec.parent_marital_status_date,
                                            x_legacy_record_flag                => NULL,
                                            x_father_first_name_initial         => cur_ISIR_rec.father_first_name_initial_txt,
                                            x_father_step_father_birth_dt       => cur_ISIR_rec.father_step_father_birth_date,
                                            x_mother_first_name_initial         => cur_ISIR_rec.mother_first_name_initial_txt,
                                            x_mother_step_mother_birth_dt       => cur_ISIR_rec.mother_step_mother_birth_date,
                                            x_parents_email_address_txt         => cur_ISIR_rec.parents_email_address_txt,
                                            x_address_change_type               => cur_ISIR_rec.address_change_type,
                                            x_cps_pushed_isir_flag              => cur_ISIR_rec.cps_pushed_isir_flag,
                                            x_electronic_transaction_type       => cur_ISIR_rec.electronic_transaction_type,
                                            x_sar_c_change_type                 => cur_ISIR_rec.sar_c_change_type,
                                            x_father_ssn_match_type             => cur_ISIR_rec.father_ssn_match_type,
                                            x_mother_ssn_match_type             => cur_ISIR_rec.mother_ssn_match_type,
                                            x_reject_override_g_flag            => cur_ISIR_rec.reject_override_g_flag,
                                            x_dhs_verification_num_txt          => cur_ISIR_rec.dhs_verification_num_txt,
                                            x_data_file_name_txt                => cur_ISIR_rec.data_file_name_txt,
                                            x_message_class_txt                 => l_msg_class,
                                            x_reject_override_3_flag            => cur_ISIR_rec.reject_override_3_flag,
                                            x_reject_override_12_flag           => cur_ISIR_rec.reject_override_12_flag,
                                            x_reject_override_j_flag            => cur_ISIR_rec.reject_override_j_flag,
                                            x_reject_override_k_flag            => cur_ISIR_rec.reject_override_k_flag,
                                            x_rejected_status_change_flag       => cur_ISIR_rec.rejected_status_change_flag,
                                            x_verification_selection_flag       => cur_ISIR_rec.verification_selection_flag
                                           );

         igf_gr_gen.update_current_ssn(cur_ISIR_rec.base_id,cur_ISIR_rec.current_ssn,p_c_message);

         IF p_c_message = 'IGF_GR_UPDT_SSN_FAIL' THEN
            fnd_message.set_name ('IGF',p_c_message);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
         END IF;
     END LOOP;
  END IF;

EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.UPDATE_MATCHED_ISIR');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END update_matched_ISIR;

PROCEDURE update_fabase (p_base_id                igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_ISIR_corr_status       igf_ap_fa_base_rec_all.ISIR_corr_status%TYPE,
                         p_ISIR_corr_status_date  igf_ap_fa_base_rec_all.ISIR_corr_status_date%TYPE)
IS
/*
||  Created By : brajendr
||  Created On : 08-NOV-2000
||  Purpose : Process which inserts comment codes of the student.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  masehgal        11-Nov-2002     FA 101 - SAP Obsoletion
||                                  removed packaging hold
||  masehgal        25-Sep-2002     FA 104 - To Do Enhancements
||                                  Added manual_disb_hold in update of Fa Base Rec
||  (reverse chronological order - newest change first)
*/

CURSOR cur_upd_base (p_base_id igf_ap_fa_base_rec_all.base_id%TYPE) IS
SELECT  fab.*
FROM    igf_ap_fa_base_rec fab
WHERE   fab.base_id = p_base_id;

cur_fbr_rec              cur_upd_base%ROWTYPE;
l_fed_verif_stat         igf_ap_fa_base_rec.fed_verif_status%TYPE;
l_fed_verif_date         igf_ap_fa_base_rec.fed_verif_status_date%TYPE := TRUNC(SYSDATE);

BEGIN

   FOR cur_fbr_rec IN cur_upd_base (p_base_id) LOOP

      IF g_fed_verif_status = 'REPROCESSED'  THEN

          cur_fbr_rec.fed_verif_status := g_fed_verif_status ;
          g_fed_verif_status           := NULL;

      ELSIF cur_fbr_rec.fed_verif_status IN ('CORRSENT','NOTVERIFIED', 'NOTSELECTED')
            OR cur_fbr_rec.fed_verif_status IS NULL THEN

            IF LTRIM(RTRIM(g_verification_flag)) = 'Y' THEN
                cur_fbr_rec.fed_verif_status := 'SELECTED';
            ELSE
                cur_fbr_rec.fed_verif_status := 'NOTSELECTED';
            END IF;

      END IF;

      igf_ap_fa_base_rec_pkg.update_row (x_Mode                              => 'R',
                                         x_rowid                             => cur_fbr_rec.row_id,
                                         x_base_id                           => cur_fbr_rec.base_id,
                                         x_ci_cal_type                       => cur_fbr_rec.ci_cal_type,
                                         x_person_id                         => cur_fbr_rec.person_id,
                                         x_ci_sequence_number                => cur_fbr_rec.ci_sequence_number,
                                         x_org_id                            => cur_fbr_rec.org_id,
                                         x_coa_pending                       => cur_fbr_rec.coa_pending,
                                         x_verification_process_run          => cur_fbr_rec.verification_process_run,
                                         x_inst_verif_status_date            => cur_fbr_rec.inst_verif_status_date,
                                         x_manual_verif_flag                 => cur_fbr_rec.manual_verif_flag,
                                         x_fed_verif_status                  => cur_fbr_rec.fed_verif_status,
                                         x_fed_verif_status_date             => l_fed_verif_date,
                                         x_inst_verif_status                 => cur_fbr_rec.inst_verif_status,
                                         x_nslds_eligible                    => g_nslds_match_flag,
                                         x_ede_correction_batch_id           => cur_fbr_rec.ede_correction_batch_id,
                                         x_fa_process_status_date            => TRUNC(SYSDATE),
                                         x_ISIR_corr_status                  => p_ISIR_corr_status,
                                         x_ISIR_corr_status_date             => p_ISIR_corr_status_date,
                                         x_ISIR_status                       => 'Received-Valid',
                                         x_ISIR_status_date                  => TRUNC(SYSDATE),
                                         x_coa_code_f                        => cur_fbr_rec.coa_code_f,
                                         x_coa_code_i                        => cur_fbr_rec.coa_code_i,
                                         x_coa_f                             => cur_fbr_rec.coa_f,
                                         x_coa_i                             => cur_fbr_rec.coa_i,
                                         x_disbursement_hold                 => cur_fbr_rec.disbursement_hold,
                                         x_fa_process_status                 => cur_fbr_rec.fa_process_status,
                                         x_notification_status               => cur_fbr_rec.notification_status,
                                         x_notification_status_date          => cur_fbr_rec.notification_status_date,
                                         x_packaging_status                  => cur_fbr_rec.packaging_status,
                                         x_packaging_status_date             => cur_fbr_rec.packaging_status_date,
                                         x_total_package_accepted            => cur_fbr_rec.total_package_accepted,
                                         x_total_package_offered             => cur_fbr_rec.total_package_offered,
                                         x_admstruct_id                      => cur_fbr_rec.admstruct_id,
                                         x_admsegment_1                      => cur_fbr_rec.admsegment_1,
                                         x_admsegment_2                      => cur_fbr_rec.admsegment_2,
                                         x_admsegment_3                      => cur_fbr_rec.admsegment_3,
                                         x_admsegment_4                      => cur_fbr_rec.admsegment_4,
                                         x_admsegment_5                      => cur_fbr_rec.admsegment_5,
                                         x_admsegment_6                      => cur_fbr_rec.admsegment_6,
                                         x_admsegment_7                      => cur_fbr_rec.admsegment_7,
                                         x_admsegment_8                      => cur_fbr_rec.admsegment_8,
                                         x_admsegment_9                      => cur_fbr_rec.admsegment_9,
                                         x_admsegment_10                     => cur_fbr_rec.admsegment_10,
                                         x_admsegment_11                     => cur_fbr_rec.admsegment_11,
                                         x_admsegment_12                     => cur_fbr_rec.admsegment_12,
                                         x_admsegment_13                     => cur_fbr_rec.admsegment_13,
                                         x_admsegment_14                     => cur_fbr_rec.admsegment_14,
                                         x_admsegment_15                     => cur_fbr_rec.admsegment_15,
                                         x_admsegment_16                     => cur_fbr_rec.admsegment_16,
                                         x_admsegment_17                     => cur_fbr_rec.admsegment_17,
                                         x_admsegment_18                     => cur_fbr_rec.admsegment_18,
                                         x_admsegment_19                     => cur_fbr_rec.admsegment_19,
                                         x_admsegment_20                     => cur_fbr_rec.admsegment_20,
                                         x_packstruct_id                     => cur_fbr_rec.packstruct_id,
                                         x_packsegment_1                     => cur_fbr_rec.packsegment_1,
                                         x_packsegment_2                     => cur_fbr_rec.packsegment_2,
                                         x_packsegment_3                     => cur_fbr_rec.packsegment_3,
                                         x_packsegment_4                     => cur_fbr_rec.packsegment_4,
                                         x_packsegment_5                     => cur_fbr_rec.packsegment_5,
                                         x_packsegment_6                     => cur_fbr_rec.packsegment_6,
                                         x_packsegment_7                     => cur_fbr_rec.packsegment_7,
                                         x_packsegment_8                     => cur_fbr_rec.packsegment_8,
                                         x_packsegment_9                     => cur_fbr_rec.packsegment_9,
                                         x_packsegment_10                    => cur_fbr_rec.packsegment_10,
                                         x_packsegment_11                    => cur_fbr_rec.packsegment_11,
                                         x_packsegment_12                    => cur_fbr_rec.packsegment_12,
                                         x_packsegment_13                    => cur_fbr_rec.packsegment_13,
                                         x_packsegment_14                    => cur_fbr_rec.packsegment_14,
                                         x_packsegment_15                    => cur_fbr_rec.packsegment_15,
                                         x_packsegment_16                    => cur_fbr_rec.packsegment_16,
                                         x_packsegment_17                    => cur_fbr_rec.packsegment_17,
                                         x_packsegment_18                    => cur_fbr_rec.packsegment_18,
                                         x_packsegment_19                    => cur_fbr_rec.packsegment_19,
                                         x_packsegment_20                    => cur_fbr_rec.packsegment_20,
                                         x_miscstruct_id                     => cur_fbr_rec.miscstruct_id,
                                         x_miscsegment_1                     => cur_fbr_rec.miscsegment_1,
                                         x_miscsegment_2                     => cur_fbr_rec.miscsegment_2,
                                         x_miscsegment_3                     => cur_fbr_rec.miscsegment_3,
                                         x_miscsegment_4                     => cur_fbr_rec.miscsegment_4,
                                         x_miscsegment_5                     => cur_fbr_rec.miscsegment_5,
                                         x_miscsegment_6                     => cur_fbr_rec.miscsegment_6,
                                         x_miscsegment_7                     => cur_fbr_rec.miscsegment_7,
                                         x_miscsegment_8                     => cur_fbr_rec.miscsegment_8,
                                         x_miscsegment_9                     => cur_fbr_rec.miscsegment_9,
                                         x_miscsegment_10                    => cur_fbr_rec.miscsegment_10,
                                         x_miscsegment_11                    => cur_fbr_rec.miscsegment_11,
                                         x_miscsegment_12                    => cur_fbr_rec.miscsegment_12,
                                         x_miscsegment_13                    => cur_fbr_rec.miscsegment_13,
                                         x_miscsegment_14                    => cur_fbr_rec.miscsegment_14,
                                         x_miscsegment_15                    => cur_fbr_rec.miscsegment_15,
                                         x_miscsegment_16                    => cur_fbr_rec.miscsegment_16,
                                         x_miscsegment_17                    => cur_fbr_rec.miscsegment_17,
                                         x_miscsegment_18                    => cur_fbr_rec.miscsegment_18,
                                         x_miscsegment_19                    => cur_fbr_rec.miscsegment_19,
                                         x_miscsegment_20                    => cur_fbr_rec.miscsegment_20,
                                         x_prof_judgement_flg                => cur_fbr_rec.prof_judgement_flg,
                                         x_nslds_data_override_flg           => cur_fbr_rec.nslds_data_override_flg,
                                         x_target_group                      => cur_fbr_rec.target_group,
                                         x_coa_fixed                         => cur_fbr_rec.coa_fixed,
                                         x_profile_status                    => cur_fbr_rec.profile_status,
                                         x_profile_status_date               => cur_fbr_rec.profile_status_date,
                                         x_profile_fc                        => cur_fbr_rec.profile_fc,
                                         x_coa_pell                          => cur_fbr_rec.coa_pell,
                                         x_manual_disb_hold                  => cur_fbr_rec.manual_disb_hold,
                                         x_pell_alt_expense                  => cur_fbr_rec.pell_alt_expense,
                                         x_assoc_org_num                     => cur_fbr_rec.assoc_org_num,
                                         x_award_fmly_contribution_type      => cur_fbr_rec.award_fmly_contribution_type,
                                         x_packaging_hold                    => cur_fbr_rec.packaging_hold,
                                         x_isir_locked_by                    => cur_fbr_rec.isir_locked_by,
                                         x_adnl_unsub_loan_elig_flag         => cur_fbr_rec.adnl_unsub_loan_elig_flag,
                                         x_lock_awd_flag                     => cur_fbr_rec.lock_awd_flag,
                                 				 x_lock_coa_flag                     => cur_fbr_rec.lock_coa_flag

                                         );
    END LOOP;
EXCEPTION

      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.UPDATE_FABASE');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

END update_fabase;

PROCEDURE update_ISIR_corr (p_ISIRc_id            igf_ap_ISIR_corr_all.ISIRc_id%TYPE,
                            p_correction_status   igf_ap_ISIR_corr_all.correction_status%TYPE )
IS
     /*
        ||  Created By : skoppula
        ||  Created On : 03-JUL-2001
        ||  Purpose : Procedure updates the correction status of the ISIR corrections
        ||  Known limitations, enhancements or remarks :
        ||  Change History :
        ||  Who             When            What
        ||  (reverse chronological order - newest change first)
        */

          l_correction_status   igf_ap_ISIR_corr.correction_status%TYPE;
          CURSOR cur_corr IS
          SELECT *
          FROM   igf_ap_ISIR_corr
          WHERE  ISIRc_id = p_ISIRc_id;

          cur_ISIR_corr     cur_corr%ROWTYPE;

BEGIN

     FOR cur_ISIR_corr IN cur_corr LOOP

         igf_ap_ISIR_corr_pkg.update_row (
                       x_rowid                                 =>        cur_ISIR_corr.row_id,
                       x_ISIRc_id                              =>        cur_ISIR_corr.ISIRc_id,
                       x_ISIR_id                               =>        cur_ISIR_corr.ISIR_id,
                       x_ci_sequence_number                    =>        cur_ISIR_corr.ci_sequence_number,
                       x_ci_cal_type                           =>        cur_ISIR_corr.ci_cal_type,
                       x_sar_field_number                      =>        cur_ISIR_corr.sar_field_number,
                       x_original_value                        =>        cur_ISIR_corr.original_value,
                       x_batch_id                              =>        cur_ISIR_corr.batch_id,
                       x_corrected_value                       =>        cur_ISIR_corr.corrected_value,
                       x_correction_status                     =>        NVL(p_correction_status,cur_ISIR_corr.correction_status),
                       x_mode                                  =>        'R');
     END LOOP;

EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.UPDATE_ISIR_CORR');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END update_ISIR_corr;

PROCEDURE validate_corrections (p_base_id  igf_ap_fa_base_rec_all.base_id%TYPE,
                                p_ISIR_id  igf_ap_ISIR_matched.ISIR_id%TYPE)
IS

CURSOR cur_ISIR (p_base_id  igf_ap_fa_base_rec_all.base_id%TYPE) IS
SELECT ISIR_id
FROM   igf_ap_ISIR_matched
WHERE  base_id = p_base_id;

CURSOR cur_isir_corr (cp_base_id   igf_ap_fa_base_rec.base_id%TYPE ,
                      l_isir_id    igf_ap_isir_matched.isir_id%TYPE,
                      cp_corr_stat VARCHAR2,
                      cp_lkup_type VARCHAR2 )  IS
   SELECT corr.ISIR_id,
          corr.ISIRc_id,
          corr.sar_field_number,
          sar.sar_field_name  column_name,
          corr.corrected_value,
          corr.correction_status ,
          lkup.meaning  meaning
     FROM igf_ap_batch_aw_map     map,
          igf_ap_fa_base_rec_all  fabase,
          igf_ap_ISIR_corr        corr,
          Igf_fc_sar_cd_mst       sar ,
          igf_lookups_view        lkup
    WHERE fabase.base_id         =  cp_base_id
      AND map.ci_cal_type        =  fabase.ci_cal_type
      AND map.ci_sequence_number =  fabase.ci_sequence_number
      AND sar.sys_award_year     =  map.sys_award_year
      AND corr.isir_id           =  l_isir_id
      AND corr.correction_status <> cp_corr_stat
      AND sar.sar_field_number   =  corr.sar_field_number
      AND lkup.lookup_type       =  cp_lkup_type
      AND lkup.lookup_code       =  sar.sar_field_name ;

l_correction_value   VARCHAR2(255);
l_new_value          VARCHAR2(255);
lv_cur               PLS_INTEGER ;
lv_retval            igf_ap_ISIR_corr.original_value%TYPE;
lv_stmt              VARCHAR2(2000);
lv_rows              integer;
lv_column_name       VARCHAR2(30);
lv_column_meaning    igf_lookups_view.meaning%TYPE ;
ln_count_corr        NUMBER := 99999;
l_corr_stat          VARCHAR2(30) ;
ln_isir_id           igf_ap_isir_matched.isir_id%TYPE;
l_lkup_type          VARCHAR2(60);

BEGIN

 FOR rec_ISIR IN cur_ISIR (p_base_id) LOOP

    ln_count_corr := 0;
         l_corr_stat := 'ACKNOWLEDGED' ;
         l_lkup_type := 'IGF_AP_SAR_FIELD_MAP' ;
         FOR rec_ISIR_corr IN cur_ISIR_corr ( p_base_id, rec_ISIR.ISIR_id, l_corr_stat, l_lkup_type) LOOP

          -- The Correction Value that will be sent to CPS.
            l_correction_value := rec_ISIR_corr.corrected_value;
            -- The Values received from CPS for that Column
            lv_column_name    := rec_ISIR_corr.column_name;
            lv_column_meaning := rec_ISIR_corr.meaning;
            ln_isir_id        := TO_CHAR (p_isir_id) ;

            lv_cur := DBMS_SQL.OPEN_CURSOR;
            lv_stmt := 'SELECT '||lv_column_name ||' FROM igf_ap_ISIR_matched where ISIR_id = :l_isir_id ' ;
            DBMS_SQL.PARSE(lv_cur,lv_stmt,6);
            DBMS_SQL.BIND_VARIABLE(lv_cur, 'l_isir_id', ln_isir_id);

            DBMS_SQL.DEFINE_COLUMN(lv_cur,1,lv_retval,30);
            lv_rows := DBMS_SQL.EXECUTE_AND_FETCH(lv_cur);
            DBMS_SQL.COLUMN_VALUE(lv_cur,1,lv_retval);
            DBMS_SQL.CLOSE_CURSOR(lv_cur);

            --
            -- Compare the values and if the value send for correction is same as the value present in the ISIR then
            -- Mark the record as ACKNOWLEDGED.
            --
           IF LTRIM(RTRIM(UPPER(NVL(lv_retval,'##')))) = LTRIM(RTRIM(UPPER(NVL(l_correction_value,'##')))) THEN
                 IF  NOT igf_ap_ISIR_corr_pkg.get_uk_for_validation (  x_ISIR_id            => rec_ISIR_corr.ISIR_id,
                                                                       x_sar_field_number   => rec_ISIR_corr.sar_field_number,
                                                                       x_correction_status  => 'ACKNOWLEDGED') THEN
                           update_ISIR_corr (rec_ISIR_corr.ISIRc_id, 'ACKNOWLEDGED');
                           fnd_message.set_name('IGF','IGF_AP_ISIR_CORR_ACK');
                           fnd_message.set_token('FIELD', lv_column_meaning);
                           fnd_file.put_line(fnd_file.log,fnd_message.get);
                 END IF;

            ELSE
                 IF  NOT igf_ap_ISIR_corr_pkg.get_uk_for_validation (  x_ISIR_id            => rec_ISIR_corr.ISIR_id,
                                                                       x_sar_field_number   => rec_ISIR_corr.sar_field_number,
                                                                       x_correction_status  => 'READY') THEN
                   update_ISIR_corr (rec_ISIR_corr.ISIRc_id, 'READY');
                   ln_count_corr := ln_count_corr + 1;
                   fnd_message.set_name('IGF','IGF_AP_ISIR_CORR_READY');
                   fnd_message.set_token('FIELD', lv_column_meaning);
                   fnd_file.put_line(fnd_file.log,fnd_message.get);
                 END IF;
            END IF;
         END LOOP;

         --
         -- If all the ISIR corrections values match with the value in Current ISIR then update the Verification Status to REPROCESSED.
         --
         IF ln_count_corr = 0 THEN
           g_fed_verif_status := 'REPROCESSED';
           update_fabase(g_base_rec.base_id,g_base_rec.ISIR_corr_status,g_base_rec.ISIR_corr_status_date);
           update_matched_ISIR(g_ISIR_rec.ISIR_id,'ORIGINAL','Y','Y');
           -- set payment ISIR as active ISIR.
         END IF;
 END LOOP;

EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.VALIDATE_CORRECTIONS');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END validate_corrections;

PROCEDURE prepare_message
IS
/*
 ||  Created By : skoppula
 ||  Created On : 04-JUL-2001
 ||  Purpose : To create the Correction ISIR
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  masehgal        19-Mar-2002     # 2167635   Added column ow_id
 ||  (reverse chronological order - newest change first)
 */
     l_given_names       CHAR(301);
     l_person_number     CHAR(30);
     l_rowid             VARCHAR2(30);
     l_ow_id             NUMBER;
     CURSOR cur_get_name
     IS
     SELECT given_names,
            person_number
     FROM   igf_ap_fa_con_v
     WHERE  base_id = g_base_id;

BEGIN

       OPEN cur_get_name;
       FETCH cur_get_name INTO l_given_names,l_person_number;
       igf_ap_outcorr_wf_pkg.insert_row (
                  x_rowid               => l_rowid,
                  x_person_number       => l_person_number,
                  x_given_names         => l_given_names,
                  x_transaction_number  => g_transaction_num,
                  x_item_key            => 'NEW',
                  x_ow_id               => l_ow_id,
                  x_mode                => 'R');

      CLOSE cur_get_name;

EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.PREPARE_MESSAGE');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END prepare_message;


PROCEDURE create_message( document_id   IN             VARCHAR2,
                          display_type  IN             VARCHAR2,
                          document      IN OUT  NOCOPY VARCHAR2,
                          document_type IN OUT  NOCOPY VARCHAR2)
IS
/*
 ||  Created By : skoppula
 ||  Created On : 04-JUL-2001
 ||  Purpose : To create the Correction ISIR
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  masehgal        19-Mar-2002     # 2167635   Added column ow_id
 ||  (reverse chronological order - newest change first)
 */
     l_item_type         VARCHAR2(200);
     l_item_key          VARCHAR2(300);
     l_interim_str       VARCHAR2(500);
     l_cnt               NUMBER ;
     l_ow_id             igf_ap_outcorr_wf.ow_id%type;
     l_given_names       igf_ap_outcorr_wf.given_names%TYPE;

     CURSOR  cur_get_name
     IS
     SELECT  given_names,
             person_number
     FROM    igf_ap_fa_con_v
     WHERE   base_id = g_base_id;

     CURSOR cur_upd_key
     IS
     SELECT  wf.*,
             wf.rowid row_id
     FROM    igf_ap_outcorr_wf wf
     WHERE   item_key = 'NEW';

     CURSOR cur_get_data
     IS
     SELECT  *
     FROM    igf_ap_outcorr_wf
     WHERE   item_key = l_item_key;

    l_msg_body   cur_get_data%ROWTYPE;
    l_upd_key    cur_upd_key%ROWTYPE;

BEGIN

    l_item_key := LTRIM(RTRIM(SUBSTR(document_id,INSTR(document_id,':',1) +1)));

    OPEN cur_upd_key;

    LOOP
      FETCH cur_upd_key INTO l_upd_key;
      EXIT WHEN cur_upd_key%NOTFOUND;
               IGF_AP_OUTCORR_WF_PKG.update_row(
                  x_rowid                             =>    l_upd_key.row_id,
                  x_person_number                     =>    l_upd_key.person_number,
                  x_given_names                       =>    l_upd_key.given_names,
                  x_transaction_number                =>    l_upd_key.transaction_number,
                  x_item_key                          =>    l_item_key,
                  x_ow_id                             =>    l_upd_key.ow_id,
                  x_mode                              =>    'R'
                    );

    END LOOP;
    CLOSE cur_upd_key;
    OPEN cur_get_data;
    FETCH cur_get_data INTO l_msg_body;

    IF cur_get_data%NOTFOUND THEN
         l_cnt := 0;
         CLOSE cur_get_data;
    ELSE
           l_cnt := 1;
           CLOSE cur_get_data;
    END IF;

    IF l_cnt = 0 THEN

         fnd_message.set_name ( 'IGF','IGF_AP_NO_DATA_FOUND');
         document := fnd_message.get;
    ELSE

       OPEN cur_get_data;
       LOOP
            FETCH cur_get_data INTO l_msg_body;
            EXIT WHEN cur_get_data%NOTFOUND;
              l_given_names := SUBSTR(l_msg_body.given_names,1,LENGTH(LTRIM(RTRIM(l_msg_body.given_names))));
              document := document||l_msg_body.person_number||fnd_global.tab||
                          l_given_names||fnd_global.tab||l_msg_body.transaction_number;
              document := document||fnd_global.newline;
       END LOOP;
       CLOSE cur_get_data;

    END IF;
    --delete from igf_ap_outcorr_wf;

    IF display_type   = 'text/plain' THEN
       document_type := 'text/plain';
       RETURN;
    ELSE
       document_type := 'text/plain';
       RETURN;
    END IF;

EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.CREATE_MESSAGE');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END create_message;


PROCEDURE outside_corrections(itemtype   IN         VARCHAR2,
                               itemkey   IN         VARCHAR2,
                               actid     IN         NUMBER,
                               funcmode  IN         VARCHAR2,
                               resultout OUT NOCOPY VARCHAR2)
IS
/*
 ||  Created By : skoppula
 ||  Created On : 20-FEB-2001
 ||  Purpose:Checks whether Fabase record exists
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  (reverse chronological order - newest change first)
 */

  document        VARCHAR2(1000);
  document_type   VARCHAR2(1000);
  l_user          VARCHAR2(80);

BEGIN
  IF funcmode='RUN' THEN
        l_user := fnd_global.user_name;
        l_user := LTRIM(RTRIM(l_user));

        wf_engine.setitemattrtext(itemtype,
                                  itemkey,
                                  'VUSER',
                                  l_user);

        wf_engine.setitemattrtext(itemtype,
                                  itemkey,
                                  'VMSGBODY',
                                  g_msg_body);

        wf_engine.setitemattrtext(itemtype,
                                  itemkey,
                                  'MSGDOC','PLSQL:IGF_AP_ISIR_IMPORT_PKG.CREATE_MESSAGE/'||itemtype||':'||itemkey);
        resultout  := 'COMPLETE';
  END IF;

EXCEPTION
    WHEN OTHERS THEN
       wf_core.context('IGF_AP_NOTIFY_CHANGE_WF','FABASE_EXISTS',itemtype,itemkey,TO_CHAR(actid),funcmode);
END  outside_corrections;

PROCEDURE send_message
IS
/*
 ||  Created By : skoppula
 ||  Created On : 04-JUL-2001
 ||  Purpose : To create the Correction ISIR
 ||  Known limitations, enhancements or remarks :
 ||  Change History :
 ||  Who             When            What
 ||  (reverse chronological order - newest change first)
 */
     CURSOR cur_get_seq
     IS
     SELECT
     igf_ap_corr_wf_s.NEXTVAL
     FROM DUAL;

     l_item_key       NUMBER;

BEGIN
     OPEN  cur_get_seq;
     FETCH cur_get_seq INTO l_item_key;
     CLOSE cur_get_seq;
     wf_engine.createprocess('OUTCORR',l_item_key,'NOTIFY');
     wf_engine.startprocess('OUTCORR',l_item_key);
EXCEPTION
      WHEN others THEN
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_AP_ISIR_IMPORT_PKG.SEND_MESSAGE');
      fnd_file.put_line(fnd_file.log,SQLERRM);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
END send_message;

END IGF_AP_ISIR_IMPORT_PKG;

/
