--------------------------------------------------------
--  DDL for Package Body FEM_REFRESH_ENG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_REFRESH_ENG_PKG" AS
-- $Header: fem_refresh_eng.plb 120.9 2007/06/26 16:54:26 rflippo ship $

/***************************************************************************
                    Copyright (c) 2003 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    fem_refresh_eng.plb

  DESCRIPTION
    See fem_refresh_eng.pls for details

  HISTORY
    Rob Flippo   02-May-2005   Created
    Rob Flippo   08-JUN-2005   Modified to continue if error encountered with
                               a load of a seeded data file
    Rob Flippo   09-JUN-2005   Modify reset_profile_options for dataset
                               profiles
    Rob Flippo   22-JUL-2005   Modify tables cursor to only retrieve tables
                               that exist in the db
    Rob Flippo   19-AUG-2005   Bug#4547880 Modify fem_rfsh_procedures cursor
                               to order by sub_phase asc - this ensures that
                               the proc to create the default cal period
                               happens first
    Rob Flippo   16-MAY-2006   Bug#5223789 Add hard-coded call
                               to delete KFF registration info for
                               composite dimensions
    Rob Flippo   14-SEP-2006   Bug#5520316 Refresh engine should continue on
                               even if get exception to KFF delete; Also
                               modified the clean_tables procedure so that
                               if get truncate_table failure, the refresh
                               continues
    Rob Flippo   22-SEP-2006   Bug#5549010 Modified load_Seed_data procedure
                               so that it only runs the TL files in the base
                               language;
    Rob Flippo   25-JAN-2007   Bug#5837043 Running the TL files only in the
                               base language is not sufficient, since non-trans
                               ldt files will not be populated in non-US
                               directories.  To solve this will run US files
                               first to ensure that the data gets loaded, and
                               then when base lang <> 'US' will re-run the files
                               in the Base language files
 **************************************************************************/

-------------------------------
-- Declare package variables --
-------------------------------
   f_set_status  BOOLEAN;

   c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
   c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
   c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
   c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
   c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
   c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

   v_log_level    NUMBER;

   gv_prg_msg      VARCHAR2(2000);
   gv_callstack    VARCHAR2(2000);


-- Private Internal Procedures
PROCEDURE Report_errors;


PROCEDURE Register_process_execution (p_object_id IN NUMBER
                                     ,p_obj_def_id IN NUMBER
                                     ,p_execution_status IN VARCHAR);



PROCEDURE Eng_Master_Prep (x_appltop OUT NOCOPY VARCHAR2
                          ,x_release OUT NOCOPY VARCHAR2
                          ,x_execution_status OUT NOCOPY VARCHAR2);

PROCEDURE Clean_tables   (x_execution_status OUT NOCOPY VARCHAR2);

PROCEDURE Refresh_fndload (errbuf OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY VARCHAR2
                          ,x_sub_request_id OUT NOCOPY NUMBER
                          ,p_appltop IN VARCHAR2
                          ,p_release IN VARCHAR2
                          ,p_ldtpath IN VARCHAR2
                          ,p_lctpath IN VARCHAR2);

PROCEDURE Refresh_procedure (x_procedure_status OUT NOCOPY VARCHAR2
                            ,p_procedure_call IN VARCHAR2);


PROCEDURE Load_seed_data (p_appltop IN VARCHAR2
                         ,p_release IN VARCHAR2
                         ,x_execution_status OUT NOCOPY VARCHAR2);

PROCEDURE Reset_profile_options (x_execution_status IN OUT NOCOPY VARCHAR2);

PROCEDURE Refresh_completion;

-----------------------------------------------------------------------------
--  Package bodies for functions/procedures
-----------------------------------------------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              Engine Master Preparation
 |
 | DESCRIPTION
 |    Validates the FEM_TOP and splits it into component pieces so the
 |    APPL_TOP portion can be re-used to identify homes of other products
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   03-MAY-05  Created
 |
 +===========================================================================*/
PROCEDURE Eng_Master_Prep (x_appltop OUT NOCOPY VARCHAR2
                          ,x_release OUT NOCOPY VARCHAR2
                          ,x_execution_status OUT NOCOPY VARCHAR2) IS

   v_concurrent_status BOOLEAN;
   v_ldtpath VARCHAR2(1000);
   v_lctpath VARCHAR2(1000);

   v_fem_start NUMBER :=0; -- point where the "fem" portion of the $FEM_TOP string begins
   v_temp_fem_start NUMBER :=0; -- temporary variable for storing the starting position
                                -- of "/fem/" in the $FEM_TOP string

   v_release_end NUMBER :=0; -- point where the release component ends in the $FEM_TOP string
   v_release_len NUMBER :=0; -- number of chars in the release component
   v_sub_request_id NUMBER;

   v_parent_request_id   NUMBER;

   -- Exceptions
   e_unable_parse_femtop EXCEPTION;
   e_fndload_error EXCEPTION;
   e_concurrent_manager EXCEPTION;


   -- output variables for the wait_for_request function
   f_req_wait    BOOLEAN; -- return of the wait_for_request function
   v_req_phase   VARCHAR2(100);
   v_req_status  VARCHAR2(100);
   v_dev_phase   VARCHAR2(100);
   v_dev_status  VARCHAR2(100);
   v_req_message VARCHAR2(100);

   v_femtop  VARCHAR2(1000);

   errbuf VARCHAR2(4000);
   retcode VARCHAR2(4000);

CURSOR c_sub_request IS
   SELECT request_id
   FROM   fnd_concurrent_requests R,
          fnd_concurrent_programs P
   WHERE  parent_request_id = v_parent_request_id
   AND    R.concurrent_program_id = P.concurrent_program_id
   AND    P.concurrent_program_name = c_FNDLOAD
   ORDER BY request_id;



BEGIN

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.v_femtop',
      p_msg_text => v_femtop);

   v_parent_request_id   := fnd_global.conc_request_id;
   v_femtop  := FND_PROFILE.Value_Specific('FEM_FEMTOP');

   -- Parse the FEM_TOP to find the APPL_TOP and RELEASE components
   -- we will look for the last occurrence (up to a max of 10 occurrences)
   -- of '/fem/'
   FOR i IN 1 .. 10 LOOP

      v_temp_fem_start := instr(v_femtop,'/fem/',1,i);
      IF v_temp_fem_start > 0 THEN
         v_fem_start := v_temp_fem_start;
      ELSE
         EXIT;
      END IF;
   END LOOP;

   IF v_fem_start = 0 THEN
      RAISE e_unable_parse_femtop;
   END IF;

   -- Identify the $APPL_TOP as everyting preceeding the '/fem/' string
   x_appltop := substr(v_femtop,1,v_fem_start);

   -- Identify the release component of $FEM_TOP
   -- we do this by first looking for the next '/' that is after '/fem/'
   -- then we substr on v_femtop, starting at the end of '/fem',
   -- and continuing for the length of the release string
   v_release_end := instr(v_femtop,'/',v_fem_start+4,1);
   v_release_len := v_release_end - v_fem_start+4;
   x_release := substr(v_femtop,v_fem_start+4,v_release_len);
   v_lctpath := x_appltop||'fem'||x_release||c_test_lct;
   v_ldtpath := x_appltop||'fem'||x_release||c_test_ldt;

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.v_fem_start',
      p_msg_text => v_fem_start);

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.x_appltop',
      p_msg_text => x_appltop);

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.x_release',
      p_msg_text => x_release);

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.lctpath',
      p_msg_text => v_lctpath);

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.ldtpath',
      p_msg_text => v_ldtpath);

   -- Test the $FEM_TOP by running FNDLOAD for fem_dim.ldt
      Refresh_fndload (errbuf
                      ,retcode
                      ,v_sub_request_id
                      ,x_appltop
                      ,x_release
                      ,v_ldtpath
                      ,v_lctpath);



   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.v_sub_request_id',
      p_msg_text => v_sub_request_id);

   IF (v_sub_request_id = 0)
   THEN
      RAISE e_fndload_error;
   ELSE
      COMMIT;
   END IF;

   -- check status of the submitted request and exit when finished
   LOOP
      f_req_wait := FND_CONCURRENT.WAIT_FOR_REQUEST
                    (REQUEST_ID => v_sub_request_id
                    ,INTERVAL =>5
                    ,MAX_WAIT => 600
                    ,PHASE => v_req_phase
                    ,STATUS => v_req_status
                    ,DEV_PHASE => v_dev_phase
                    ,DEV_STATUS => v_dev_status
                    ,MESSAGE => v_req_message);

      CASE v_dev_phase
         WHEN 'COMPLETE' THEN EXIT;
         WHEN 'INACTIVE' THEN EXIT;
         ELSE NULL;
      END CASE;
   END LOOP;

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Engine_master_prep.v_dev_phase',
      p_msg_text => v_dev_phase);


   IF v_dev_phase NOT IN ('COMPLETE') THEN
      RAISE e_concurrent_manager;
   ELSIF v_dev_phase = 'COMPLETE' AND v_dev_status NOT IN ('NORMAL') THEN
      RAISE e_fndload_error;
   ELSIF v_dev_phase = 'COMPLETE' AND v_dev_status = 'NORMAL' THEN
      x_execution_status := 'SUCCESS';
   END IF;

EXCEPTION
   WHEN e_unable_parse_femtop THEN
      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_INVALID_FEM_TOP'
      ,P_TOKEN1 => 'PATH'
      ,P_VALUE1 => v_femtop);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Engine_master_prep',
         p_msg_text => 'Unable to find /fem/ in the FEM_FEMTOP profile option');

      x_execution_status := 'ERROR_RERUN';

   WHEN e_fndload_error THEN
      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_FNDLOAD_ERROR'
      ,P_TOKEN1 => 'LDTFILE'
      ,P_VALUE1 => v_ldtpath
      ,P_TOKEN2 => 'LCTFILE'
      ,P_VALUE2 => v_lctpath);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Engine_master_prep',
         p_msg_text => 'Unable to run the FEM_RFSH_FNDLOAD concurrent program');

      x_execution_status := 'ERROR_RERUN';

   WHEN e_concurrent_manager THEN
      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_CONCURRENT_ERROR');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Engine_master_prep',
         p_msg_text => 'Concurrent Manager is unable to process the refresh');

      x_execution_status := 'ERROR_RERUN';

END Eng_Master_Prep;

/*===========================================================================+
 | PROCEDURE
 |              Load_seed_data
 |
 | DESCRIPTION
 |    Loads all seeded data files (both ldt and sql) into the database
 |    and executes all procedures required for seeded data population.
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |   SQL files are not supported at this time, as there are no known
 |   cases (i.e. all sql files have been converted to a procedure call.
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   05-MAY-05  Created
 |    Rob Flippo   08-JUN-05  Modified to continue if error encountered with
 |                            a load of a seeded data file
 |    Rob Flippo   25-JAN-07  Bug#5837043 Running the TL files only in the
 |                            base language is not sufficient, since non-trans
 |                            ldt files will not be populated in non-US
 |                            directories.  To solve this will run US files
 |                            first to ensure that the data gets loaded, and
 |                            then when base lang <> 'US' will re-run the files
 |                            in the Base language files
 |
 +===========================================================================*/
PROCEDURE Load_seed_data (p_appltop IN VARCHAR2
                         ,p_release IN VARCHAR2
                         ,x_execution_status OUT NOCOPY VARCHAR2) IS

   v_procedure_status VARCHAR2(100);
   v_concurrent_status BOOLEAN;
   v_ldtpath VARCHAR2(1000);
   v_lctpath VARCHAR2(1000);
   v_sub_request_id NUMBER;
   v_process_name VARCHAR2(150); -- temp variable for holding the procedure
                                   -- name being processed - used by the exception
                                   -- handler

   -- language variables
   v_base_lang           FND_LANGUAGES.language_code%type;
   v_lang_start          NUMBER;
   v_subdir_length       NUMBER;
   v_subdir_lang         FND_LANGUAGES.language_code%type;
   v_subdir_lang_length  NUMBER;

   -- output variables for the wait_for_request function
   f_req_wait    BOOLEAN; -- return of the wait_for_request function
   v_req_phase   VARCHAR2(100);
   v_req_status  VARCHAR2(100);
   v_dev_phase   VARCHAR2(100);
   v_dev_status  VARCHAR2(100);
   v_req_message VARCHAR2(100);

   errbuf VARCHAR2(4000);
   retcode VARCHAR2(4000);

   -- Exceptions
   e_fndload_error      EXCEPTION;
   e_concurrent_manager EXCEPTION;
   e_procedure_error    EXCEPTION;

   -- This cursor joins to AD_FILES so that we guarantee to run only those
   -- files that have been installed and that we run for all languages
   cursor c_ldt_files IS
      SELECT R.file_name, ALDT.subdir file_directory_path, R.file_product_prefix,
             R.lctfile_name, ALCT.subdir lctfile_directory_path, R.lctfile_product_prefix,
             substr(ALDT.subdir,instr(ALDT.subdir,'/',-1,1)+1,(length(ALDT.subdir) - instr(ALDT.subdir,'/',-1,1))+1) FILE_LANG,
             DECODE(substr(ALDT.subdir,instr(ALDT.subdir,'/',-1,1)+1,(length(ALDT.subdir) - instr(ALDT.subdir,'/',-1,1))+1),'US','1',substr(ALDT.subdir,instr(ALDT.subdir,'/',-1,1)+1,(length(ALDT.subdir) - instr(ALDT.subdir,'/',-1,1))+1)) ORDER_SEQ
      FROM fem_rfsh_files R,
      (SELECT distinct filename, subdir
       FROM ad_files) ALDT,
      (SELECT distinct filename, subdir
       FROM ad_files
       WHERE substr(subdir,1,5) = 'patch') ALCT
      WHERE R.file_type = 'LDT'
      AND UPPER(R.file_name) = UPPER(ALDT.filename)
      AND UPPER(R.lctfile_name) = UPPER(ALCT.filename)
      ORDER BY R.sub_phase, ORDER_SEQ, R.file_name;

   cursor c_procs IS
      SELECT distinct R.process_name, R.procedure_call, R.sub_phase
      FROM fem_rfsh_procedures R, user_procedures U
      WHERE R.package_name = U.object_name
      AND R.procedure_name = U.procedure_name
      ORDER BY sub_phase asc;

BEGIN
   x_execution_status := 'SUCCESS';

   -- Identify the base language
   -- if there is some error with FND_LANGUAGES, we will
   -- set the base langauge = to the env language of the
   -- user running the refresh
   BEGIN

      SELECT language_code
      INTO v_base_lang
      FROM fnd_languages
      WHERE installed_flag = 'B';
   EXCEPTION
      WHEN OTHERS THEN
         SELECT userenv('LANG')
         INTO v_base_lang
         FROM dual;
   END;

   -- Load LDT Files
   FOR ldtfile IN c_ldt_files LOOP

      v_ldtpath := p_appltop||ldtfile.file_product_prefix||p_release||'/'||
                   ldtfile.file_directory_path||'/'||ldtfile.file_name;
      v_lctpath := p_appltop||ldtfile.lctfile_product_prefix||p_release||'/'||
                   ldtfile.lctfile_directory_path||'/'||ldtfile.lctfile_name;

/*******************************************************
Putting this logic to get the language in the SELECT
so we can sort by lang
      -- identify the language_code for the ldt file
      -- we will only run ldt files of the base language
      v_subdir_length := length(ldtfile.file_directory_path);
      v_lang_start    := instr(ldtfile.file_directory_path,'/',-1,1);
      v_subdir_lang_length := (v_subdir_length - v_lang_start) + 1;

      v_subdir_lang   := substr(ldtfile.file_directory_path,v_lang_start+1,v_subdir_lang_length);
*************************************************************/

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Load_seed_data.ldtpath',
         p_msg_text => v_ldtpath);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Load_seed_data.lctpath',
         p_msg_text => v_lctpath);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'ldt language',
         p_msg_text => v_subdir_lang);

      -- only load the ldt file if the language_code of the file is the same
      -- as the base language or it is a US file
      -- All US files get loaded first.  If the base language is is non-US,
      -- the base lang files will get loaded afterwards, so that the
      -- translatable strings are all in the Base language
      IF ldtfile.FILE_LANG = v_base_lang OR ldtfile.FILE_LANG = 'US' THEN

         Refresh_fndload (errbuf
                         ,retcode
                         ,v_sub_request_id
                         ,p_appltop
                         ,p_release
                         ,v_ldtpath
                         ,v_lctpath);

         IF (v_sub_request_id = 0) THEN
            RAISE e_fndload_error;
         ELSE
            COMMIT;
         END IF;

      -- check status of the submitted request and exit when finished
         LOOP
            f_req_wait := FND_CONCURRENT.WAIT_FOR_REQUEST
                          (REQUEST_ID => v_sub_request_id
                          ,INTERVAL =>5
                          ,MAX_WAIT => 600
                          ,PHASE => v_req_phase
                          ,STATUS => v_req_status
                          ,DEV_PHASE => v_dev_phase
                          ,DEV_STATUS => v_dev_status
                          ,MESSAGE => v_req_message);

            CASE v_dev_phase
               WHEN 'COMPLETE' THEN EXIT;
               WHEN 'INACTIVE' THEN EXIT;
               ELSE NULL;
            END CASE;
         END LOOP; -- wait_for_request
         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Load_seed_data.v_dev_phase',
            p_msg_text => v_dev_phase);


         IF v_dev_phase NOT IN ('COMPLETE') THEN
            RAISE e_concurrent_manager;
         ELSIF v_dev_phase = 'COMPLETE' AND v_dev_status NOT IN ('NORMAL') THEN
            FEM_ENGINES_PKG.USER_MESSAGE
            (P_APP_NAME => c_fem
            ,P_MSG_NAME => 'FEM_RFSH_FNDLOAD_ERROR'
            ,P_TOKEN1 => 'LDTFILE'
            ,P_VALUE1 => v_ldtpath
            ,P_TOKEN2 => 'LCTFILE'
            ,P_VALUE2 => v_lctpath);

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => c_log_level_1,
               p_module   => c_block||'.'||'Load_seed_data error: ldtfile = ',
               p_msg_text => v_ldtpath);

            x_execution_status := 'ERROR_RERUN';

         ELSIF v_dev_phase = 'COMPLETE' AND v_dev_status = 'NORMAL' THEN
           NULL; -- do nothing
         END IF;
      END IF;  -- v_subdir_lang = v_base_lang

   END LOOP;

   -- Run procedures
   FOR proc IN c_procs LOOP

      v_process_name := proc.process_name;
      refresh_procedure(v_procedure_status
                       ,proc.procedure_call);
      IF v_procedure_status = 'ERROR' THEN
         RAISE e_procedure_error;
      END IF;
   END LOOP;

EXCEPTION
   WHEN e_concurrent_manager THEN
      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_CONCURRENT_ERROR');

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Load_seed_data',
         p_msg_text => 'Concurrent Manager is unable to process the refresh');

      x_execution_status := 'ERROR_RERUN';

   WHEN e_procedure_error THEN

      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_PROCEDURE_ERROR'
      ,P_TOKEN1 => 'PROCESS_NAME'
      ,P_VALUE1 => v_process_name);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Load_seed_data',
         p_msg_text => 'Procedure '||v_process_name||' failed');

      x_execution_status := 'ERROR_RERUN';

END Load_seed_data;


/*===========================================================================+
 | PROCEDURE
 |              Refresh_fndload
 |
 | DESCRIPTION
 |    This procedure calls the FNDLOAD concurrent program for loading
 |    ldt files
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   16-MAY-05  Created
 |
 +===========================================================================*/
PROCEDURE Refresh_fndload (errbuf OUT NOCOPY VARCHAR2
                          ,retcode OUT NOCOPY VARCHAR2
                          ,x_sub_request_id OUT NOCOPY NUMBER
                          ,p_appltop IN VARCHAR2
                          ,p_release IN VARCHAR2
                          ,p_ldtpath IN VARCHAR2
                          ,p_lctpath IN VARCHAR2) IS

   v_sub_request_id NUMBER;
   v_process_name VARCHAR2(150); -- temp variable for holding the procedure
                                   -- name being processed - used by the exception
                                   -- handler

   -- output variables for the wait_for_request function
   f_req_wait    BOOLEAN; -- return of the wait_for_request function
   v_req_phase   VARCHAR2(100);
   v_req_status  VARCHAR2(100);
   v_dev_phase   VARCHAR2(100);
   v_dev_status  VARCHAR2(100);
   v_req_message VARCHAR2(100);

   -- Exceptions
   e_fndload_error      EXCEPTION;

BEGIN

    x_sub_request_id :=  FND_REQUEST.SUBMIT_REQUEST(
                          application => 'FEM',
                          program => c_FNDLOAD,
                          sub_request => FALSE,
                          argument1 => 'UPLOAD',
                          argument2 => p_lctpath,
                          argument3 => p_ldtpath);

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_1,
      p_module   => c_block||'.'||'Load_seed_data.x_sub_request_id',
      p_msg_text => x_sub_request_id);

END Refresh_fndload;


/*===========================================================================+
 | PROCEDURE
 |              Refresh_procedure
 |
 | DESCRIPTION
 |    This procedure executes the dynamic SQL to call procedures for
 |    required for seeded data population
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   17-MAY-05  Created
 |
 +===========================================================================*/

PROCEDURE Refresh_procedure (x_procedure_status OUT NOCOPY VARCHAR2
                            ,p_procedure_call IN VARCHAR2) IS

BEGIN

   EXECUTE IMMEDIATE p_procedure_call;
   x_procedure_status := 'SUCCESS';
EXCEPTION
   WHEN others THEN x_procedure_status := 'ERROR';
END Refresh_procedure;


/*===========================================================================+
 | PROCEDURE
 |              Clean_tables
 |
 | DESCRIPTION
 |    Truncates all of the tables that can store user defined data
 |    This includes tables owned by teams other than FEM (i.e., RCM, PFT, etc)
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   06-MAY-05  Created
 |    Rob Flippo   22-JUL-05  Modify cursor so only retrieve tables that exist
 |    Rob Flippo   16-MAY-06  bug#5223789 Add call to delete KFF reg info for
 |                            composite dimensions
 |    Rob Flippo   14-SEP-06  Bug#5520316 Continue on if get KFF delete failure;
 |                            Also continue on if get truncate table failure;
+===========================================================================*/
PROCEDURE Clean_tables (x_execution_status OUT NOCOPY VARCHAR2) IS

   v_concurrent_status BOOLEAN;
   v_target_schema VARCHAR2(100);  -- temp variable used to identify schema
                                  -- the schema name where tables reside
                                  -- for a given application_id

   v_app_id        NUMBER;        -- temp variable used to identify the a
                                  -- application_id for which the tables are
                                  -- being truncated
   v_table         VARCHAR2(30);  -- temp variable to hold the table name being
                                  -- truncated
   v_fnd_status VARCHAR2(1000);  -- return variable for get_app_info function
   v_fnd_industry   VARCHAR2(1000); -- return variable for get_app_info function
   v_fnd_boolean    BOOLEAN;      -- return variable for get_app_info function
   v_sql_stmt       VARCHAR2(4000); -- dynamic sql for truncate

   -- KFF delete variables
   v_return_status varchar2(1);
   v_msg_count number;
   v_msg_data varchar2(4000);



   cursor c_apps is
      SELECT DISTINCT A1.application_short_name app_short_name
      ,A1.application_id
      FROM ( SELECT table_owner_application_id
      FROM fem_rfsh_tables
      UNION
      SELECT table_owner_application_id
      FROM fem_tables_b) R1,
      fnd_application A1
      WHERE R1.table_owner_application_id = A1.application_id;

   cursor c_tables (p_app_id IN NUMBER,p_schema IN VARCHAR2) IS
      SELECT table_name FROM
      (SELECT R.table_name
      FROM fem_rfsh_tables R
      WHERE table_owner_application_id = p_app_id
      AND EXISTS
      (SELECT table_name FROM ALL_TABLES A2
       WHERE A2.table_name = R.table_name
       AND A2.owner = p_schema)
      UNION
      SELECT T.table_name
      FROM fem_tables_b T
      WHERE T.table_owner_application_id = p_app_id
      AND T.table_name not in (select table_name
      FROM fem_rfsh_tables R)) RT
      WHERE EXISTS
      (SELECT table_name FROM ALL_TABLES A1
       WHERE A1.table_name = RT.table_name
       AND A1.owner = p_schema);

   -- Exceptions
   e_composite_delete EXCEPTION;
   e_table_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(e_table_not_exist, -0942);


BEGIN
   x_execution_status := 'SUCCESS';

   -- remove KFF composite dimension registration
   BEGIN
      fem_setup_pkg.delete_flexfield
            (p_api_version  => 1.0,p_init_msg_list   => NULL
            ,p_commit => FND_API.G_TRUE
            ,p_encoded   => NULL
            ,x_return_status=>v_return_status
            ,x_msg_count=>v_msg_count
            ,x_msg_data=>v_msg_data
            ,p_dimension_varchar_label => 'ACTIVITY');
      IF v_return_status NOT IN ('S') then
         raise e_composite_delete;
      END IF;
      fem_setup_pkg.delete_flexfield
           (p_api_version  => 1.0,p_init_msg_list   => NULL
           ,p_commit => FND_API.G_TRUE
           ,p_encoded   => NULL
           ,x_return_status=>v_return_status
           ,x_msg_count=>v_msg_count
           ,x_msg_data=>v_msg_data
           ,p_dimension_varchar_label => 'COST_OBJECT');
      IF v_return_status NOT IN ('S') then
         raise e_composite_delete;
      END IF;
   EXCEPTION
      WHEN e_composite_delete THEN
         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => 'FEM_RFSH_COMPOSITE_DELETE');

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Clean_tables',
            p_msg_text => 'Failed to delete composite dimension registration');

         x_execution_status := 'ERROR_RERUN';

   END;


   FOR app IN c_apps LOOP

      v_app_id := app.application_id;
      v_fnd_boolean := fnd_installation.get_app_info(
         APPLICATION_SHORT_NAME => app.app_short_name
        ,STATUS => v_fnd_status
        ,INDUSTRY => v_fnd_industry
        ,ORACLE_SCHEMA => v_target_schema);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Clean_tables.v_target_schema',
         p_msg_text => v_target_schema);

      FOR tab IN c_tables (v_app_id, v_target_schema) LOOP

         v_table := tab.table_name;
         v_sql_stmt := 'TRUNCATE TABLE '||v_target_schema||'.'||v_table;

         BEGIN
            EXECUTE IMMEDIATE v_sql_stmt;

         EXCEPTION
            WHEN e_table_not_exist THEN
               FEM_ENGINES_PKG.USER_MESSAGE
               (P_APP_NAME => c_fem
               ,P_MSG_NAME => 'FEM_RFSH_TRUNCATE_ERROR'
               ,P_TOKEN1 => 'TABLE'
               ,P_VALUE1 => v_table);

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => c_log_level_1,
               p_module   => c_block||'.'||'Clean_tables',
               p_msg_text => 'Failed to truncate table '||v_table);

            x_execution_status := 'ERROR_RERUN';

         END;
      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Clean_tables.table_name',
         p_msg_text => v_table);

      END LOOP;
   END LOOP;

END Clean_tables;

/*===========================================================================+
 | PROCEDURE
 |              Reset_profile_options
 |
 | DESCRIPTION
 |    Resets all of the FEM profile options for all users
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   09-MAY-05  Created
 |    Rob Flippo   12-JUL-06  Bug#5237422 No longer set Ledger profile
 |                            or Default Actuals Dataset since there is no
 |                            Default dataset
 |
 |
 +===========================================================================*/
PROCEDURE Reset_profile_options (x_execution_status IN OUT NOCOPY VARCHAR2) IS

   v_concurrent_status BOOLEAN;
   v_app_id        NUMBER;        -- temp variable used to identify the a
                                  -- application_id for which the tables are
                                  -- being truncated
   v_ledger_id     NUMBER;
   v_dataset_cd    NUMBER;
   v_process_name  VARCHAR2(150);  -- the process name that seeds the Default Ledger
                                   -- used for error logging only
   v_ldtfile       VARCHAR2(150);  -- ldtfile that seeds the Default dataset
                                   -- used for error logging only
   v_lctfile       VARCHAR2(150);  -- lctfile that seeds the Default dataset
                                   -- used for error logging only
   v_boolean       BOOLEAN;   -- Return value from FND API to reset profile option


   cursor c_appl is
      SELECT application_id
      FROM fem_applications;

   cursor c_user IS
      SELECT user_id
      FROM fnd_user;

   -- Exceptions
   e_no_default_ledger EXCEPTION;
   e_no_default_dataset EXCEPTION;

BEGIN

/****************************************************
Bug#5237422 comment out
   BEGIN
      SELECT ledger_id
      INTO v_ledger_id
      FROM fem_ledgers_b
      WHERE ledger_display_code = 'DEFAULT_LEDGER';
   EXCEPTION
      WHEN no_data_found THEN RAISE e_no_default_ledger;
   END;

   BEGIN
      SELECT dataset_code
      INTO v_dataset_cd
      FROM fem_datasets_b
      WHERE dataset_display_code = 'Default';
   EXCEPTION
      WHEN no_data_found THEN RAISE e_no_default_dataset;
   END;
******************************************************/


   /*Setting Site level for all profiles */
   v_boolean := FND_PROFILE.save('FEM_LEDGER', v_ledger_id, 'SITE');
   v_boolean := FND_PROFILE.save('FEM_SIGNAGE_METHOD', NULL, 'SITE');
   v_boolean := FND_PROFILE.save('FEM_PERIOD', NULL, 'SITE');
   v_boolean := FND_PROFILE.save('FEM_SEC_FOLDER', NULL, 'SITE');
   v_boolean := FND_PROFILE.save('FEM_IO_DATA_DEFINITION', NULL, 'SITE');
   v_boolean := FND_PROFILE.save('FEM_DEFAULT_ACTUALS_DATASET', v_dataset_cd, 'SITE');
   v_boolean := FND_PROFILE.save('FEM_DATASET', v_dataset_cd, 'SITE');

   /* Setting Appl level for all profiles */
   FOR appl IN c_appl LOOP
   v_boolean := FND_PROFILE.save('FEM_LEDGER', NULL, 'APPL',appl.application_id);
   v_boolean := FND_PROFILE.save('FEM_SIGNAGE_METHOD', NULL, 'APPL', appl.application_id);
   v_boolean := FND_PROFILE.save('FEM_PERIOD', NULL, 'APPL', appl.application_id);
   v_boolean := FND_PROFILE.save('FEM_SEC_FOLDER', NULL, 'APPL', appl.application_id);
   v_boolean := FND_PROFILE.save('FEM_IO_DATA_DEFINITION', NULL, 'APPL', appl.application_id);
   v_boolean := FND_PROFILE.save('FEM_DEFAULT_ACTUALS_DATASET', v_dataset_cd, 'APPL', appl.application_id);
   v_boolean := FND_PROFILE.save('FEM_DATASET', v_dataset_cd, 'APPL', appl.application_id);
   END LOOP;

   /* Setting User level for all profiles */
   FOR userid IN c_user LOOP
   v_boolean := FND_PROFILE.save('FEM_LEDGER', NULL, 'USER',userid.user_id);
   v_boolean := FND_PROFILE.save('FEM_SIGNAGE_METHOD', NULL, 'USER', userid.user_id);
   v_boolean := FND_PROFILE.save('FEM_PERIOD', NULL, 'USER', userid.user_id);
   v_boolean := FND_PROFILE.save('FEM_SEC_FOLDER', NULL, 'USER', userid.user_id);
   v_boolean := FND_PROFILE.save('FEM_IO_DATA_DEFINITION', NULL, 'USER', userid.user_id);
   v_boolean := FND_PROFILE.save('FEM_DEFAULT_ACTUALS_DATASET', v_dataset_cd, 'USER', userid.user_id);
   v_boolean := FND_PROFILE.save('FEM_DATASET', v_dataset_cd, 'USER', userid.user_id);
   END LOOP;

   COMMIT;

EXCEPTION
   WHEN e_no_default_ledger THEN
      v_process_name := 'Create Seeded Ledgers';

      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_PROCEDURE_ERROR'
      ,P_TOKEN1 => 'PROCESS_NAME'
      ,P_VALUE1 => v_process_name);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Reset_profile_options',
         p_msg_text => 'Default Ledger does not exist');

      x_execution_status := 'ERROR_RERUN';

   WHEN e_no_default_dataset THEN
      v_ldtfile := 'fem_dataset.ldt';
      v_lctfile := 'fem_dataset.lct';

      FEM_ENGINES_PKG.USER_MESSAGE
      (P_APP_NAME => c_fem
      ,P_MSG_NAME => 'FEM_RFSH_FNDLOAD_ERROR'
      ,P_TOKEN1 => 'LDTFILE'
      ,P_VALUE1 => v_ldtfile
      ,P_TOKEN2 => 'LCTFILE'
      ,P_VALUE2 => v_lctfile);

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_1,
         p_module   => c_block||'.'||'Reset_profile_options',
         p_msg_text => 'Default Dataset does not exist');

      x_execution_status := 'ERROR_RERUN';

END Reset_profile_options;



/*===========================================================================+
 | PROCEDURE
 |              Report_Errors
 |
 | DESCRIPTION
 |    Retrieves messages from the stack and reports them to the appropriate
 |    log
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   02-MAY-05  Created
 |
 +===========================================================================*/
PROCEDURE Report_errors IS

   v_msg_count NUMBER;  -- this is the return count from FND of # messages
   v_msg_data VARCHAR2(1000); -- this is the message value when only 1 msg
                              -- from FND
   v_message          VARCHAR2(4000);
   v_msg_index_out    NUMBER;
   v_block  CONSTANT  VARCHAR2(80) :=
      'fem.plsql.fem_refresh_eng_pkg.report_errors';


BEGIN
   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_2,
      p_module   => c_block||'.'||'Report_errors',
      p_msg_text => 'BEGIN');

   -- Count the number of messages on the stack
   FND_MSG_PUB.count_and_get(p_encoded => c_false
                            ,p_count => v_msg_count
                            ,p_data => v_msg_data);


   IF (v_msg_count = 1) THEN
      FND_MESSAGE.Set_Encoded(v_msg_data);
      v_message := FND_MESSAGE.Get;

      FEM_ENGINES_PKG.User_Message(
        p_msg_text => v_message);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_2,
        p_module => v_block||'.msg_data',
        p_msg_text => v_message);

   ELSIF (v_msg_count > 1) THEN
      FOR i IN 1..v_msg_count LOOP
         FND_MSG_PUB.Get(
         p_msg_index => i,
         p_encoded => c_false,
         p_data => v_message,
         p_msg_index_out => v_msg_index_out);

         FEM_ENGINES_PKG.User_Message(
           p_msg_text => v_message);

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_2,
           p_module => v_block||'.msg_data',
           p_msg_text => v_message);

      END LOOP;
   END IF;

   FND_MSG_PUB.Initialize;

   FEM_ENGINES_PKG.Tech_Message
     (p_severity => c_log_level_2,
      p_module   => c_block||'.'||'Report_errors',
      p_msg_text => 'END');


END Report_errors;

/*===========================================================================+
 | PROCEDURE
 |              Refresh_completion
 |
 | DESCRIPTION
 |    This procedure reports a completion message for each application
 |    that is refreshed successfully.  An App is identified as having been
 |    refreshed as long as it had one table in fem_rfsh_tables that was
 |    actually truncated.
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   19-MAY-05  Created
 |
 +===========================================================================*/

PROCEDURE Refresh_completion IS

   cursor c1 IS
      SELECT A.application_id, V.application_short_name, V.application_name
      FROM fem_applications A, fnd_application_vl V
      WHERE A.application_id = V.application_id;

   v_app_name VARCHAR2(240);
   v_app_id  NUMBER;
   v_fnd_boolean BOOLEAN;
   v_fnd_status VARCHAR2(1000);
   v_fnd_industry   VARCHAR2(1000); -- return variable for get_app_info function
   v_target_schema VARCHAR2(100);
   v_table_count NUMBER;

BEGIN

   FOR app IN c1 LOOP

      v_app_id := app.application_id;
      v_fnd_boolean := fnd_installation.get_app_info(
         APPLICATION_SHORT_NAME => app.application_short_name
        ,STATUS => v_fnd_status
        ,INDUSTRY => v_fnd_industry
        ,ORACLE_SCHEMA => v_target_schema);

      SELECT count(*)
      INTO v_table_count
      FROM fem_rfsh_tables R, all_tables A
      WHERE R.table_name = A.table_name
      AND R.table_owner_application_id = v_app_id
      AND A.owner = v_target_schema;

      IF v_table_count >0 THEN

         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => 'FEM_RFSH_COMPLETION'
         ,P_TOKEN1 => 'APP'
         ,P_VALUE1 => app.application_name);
      END IF;

  END LOOP;

END Refresh_completion;



/*===========================================================================+
 | PROCEDURE
 |              Register_process_execution
 |
 | DESCRIPTION
 |    Registers the concurrent request in FEM_PL_REQUESTS, registers
 |    the object execution in FEM_PL_OBJECT_EXECUTIION, obtaining an
 |    FEM "execution lock, and performs other FEM process initialization
 |    steps.
 | SCOPE - PRIVATE
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |
 |              OUT:
 |       x_completion_code returns 0 for success, 2 for failure.
 |
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 |
 | MODIFICATION HISTORY
 |    Rob Flippo   02-MAY-05  Created
 |
 +===========================================================================*/

PROCEDURE Register_process_execution (p_object_id IN NUMBER
                                     ,p_obj_def_id IN NUMBER
                                     ,p_execution_status IN VARCHAR)
IS

      v_API_return_status  VARCHAR2(30);
      v_exec_state       VARCHAR2(30); -- NORMAL, RESTART, RERUN
      v_num_msg          NUMBER;
      v_stmt_type        fem_pl_tables.statement_type%TYPE;
      i                  PLS_INTEGER;
      v_msg_count        NUMBER;
      v_msg_data         VARCHAR2(4000);
      v_previous_request_id NUMBER;

      v_request_id  NUMBER;
      v_apps_user_id     NUMBER;
      v_login_id    NUMBER;
      v_pgm_id      NUMBER;
      v_pgm_app_id  NUMBER;
      v_concurrent_status BOOLEAN;

      Exec_Lock_Exists   EXCEPTION;
      e_pl_register_req_failed  EXCEPTION;
      e_exec_lock_failed  EXCEPTION;
      e_post_process EXCEPTION;


   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_2,
         p_module   => c_block||'.'||'Register_process_execution',
         p_msg_text => 'BEGIN');

      v_request_id  := fnd_global.conc_request_id;
      v_apps_user_id := FND_GLOBAL.User_Id;
      v_login_id     := FND_GLOBAL.Login_Id;
      v_pgm_id       := FND_GLOBAL.Conc_Program_Id;
      v_pgm_app_id   := FND_GLOBAL.Prog_Appl_ID;
   -- Call the FEM_PL_PKG.Register_Request API procedure to register
   -- the concurrent request in FEM_PL_REQUESTS.

      FEM_PL_PKG.Register_Request
        (P_API_VERSION            => c_api_version,
         P_COMMIT                 => c_false,
         P_REQUEST_ID             => v_request_id,
         P_USER_ID                => v_apps_user_id,
         P_LAST_UPDATE_LOGIN      => v_login_id,
         P_PROGRAM_ID             => v_pgm_id,
         P_PROGRAM_LOGIN_ID       => v_login_id,
         P_PROGRAM_APPLICATION_ID => v_pgm_app_id,
         X_MSG_COUNT              => v_msg_count,
         X_MSG_DATA               => v_msg_data,
         X_RETURN_STATUS          => v_API_return_status);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Register_request.v_api_return_status',
            p_msg_text => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
         RAISE e_pl_register_req_failed;
      END IF;
   -- Check for process locks and process overlaps and register
   -- the execution in FEM_PL_OBJECT_EXECUTIONS, obtaining an execution lock.

      FEM_PL_PKG.Register_Object_Execution
        (P_API_VERSION               => c_api_version,
         P_COMMIT                    => c_false,
         P_REQUEST_ID                => v_request_id,
         P_OBJECT_ID                 => p_object_id,
         P_EXEC_OBJECT_DEFINITION_ID => p_obj_def_id,
         P_USER_ID                   => v_apps_user_id,
         P_LAST_UPDATE_LOGIN         => v_login_id,
         X_EXEC_STATE                => v_exec_state,
         X_PREV_REQUEST_ID           => v_previous_request_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
      -- Lock exists or API call failed
         RAISE e_exec_lock_failed;
      END IF;

      FEM_PL_PKG.Register_Object_Def
        (P_API_VERSION               => c_api_version,
         P_COMMIT                    => c_false,
         P_REQUEST_ID                => v_request_id,
         P_OBJECT_ID                 => p_object_id,
         P_OBJECT_DEFINITION_ID      => p_obj_def_id,
         P_USER_ID                   => v_apps_user_id,
         P_LAST_UPDATE_LOGIN         => v_login_id,
         X_MSG_COUNT                 => v_msg_count,
         X_MSG_DATA                  => v_msg_data,
         X_RETURN_STATUS             => v_API_return_status);

      IF v_API_return_status NOT IN  ('S') THEN
      -- Lock exists or API call failed
         RAISE e_exec_lock_failed;
      END IF;


   ------------------------------------
   -- Update Object Execution Status --
   ------------------------------------
   FEM_PL_PKG.Update_Obj_Exec_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => v_request_id,
     P_OBJECT_ID                 => p_object_id,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => v_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

   ---------------------------
   -- Update Request Status --
   ---------------------------
   FEM_PL_PKG.Update_Request_Status(
     P_API_VERSION               => c_api_version,
     P_COMMIT                    => c_true,
     P_REQUEST_ID                => v_request_id,
     P_EXEC_STATUS_CODE          => p_execution_status,
     P_USER_ID                   => v_apps_user_id,
     P_LAST_UPDATE_LOGIN         => null,
     X_MSG_COUNT                 => v_msg_count,
     X_MSG_DATA                  => v_msg_data,
     X_RETURN_STATUS             => v_API_return_status);

   IF v_API_return_status NOT IN ('S') THEN
      RAISE e_post_process;
   END IF;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => c_log_level_2,
         p_module   => c_block||'.'||'Register_process_execution',
         p_msg_text => 'END');

      COMMIT;

   EXCEPTION
      WHEN e_pl_register_req_failed THEN
         -- display user message
         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => G_PL_REG_REQUEST_ERR);

      WHEN e_exec_lock_failed THEN
         FEM_ENGINES_PKG.USER_MESSAGE
         (P_APP_NAME => c_fem
         ,P_MSG_NAME => G_PL_OBJ_EXEC_LOCK_ERR);

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => c_log_level_1,
            p_module   => c_block||'.'||'Register_process_execution',
            p_msg_text => 'raising Exec_Lock_failed');

         FEM_PL_PKG.Unregister_Request(
            P_API_VERSION               => c_api_version,
            P_COMMIT                    => c_true,
            P_REQUEST_ID                => v_request_id,
            X_MSG_COUNT                 => v_msg_count,
            X_MSG_DATA                  => v_msg_data,
            X_RETURN_STATUS             => v_API_return_status);
      -- Technical messages have already been logged by the API;

   WHEN e_post_process THEN
      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module => c_block||'.'||'Register_process_execution',
        p_msg_text => 'Post Process failed');

      FEM_ENGINES_PKG.USER_MESSAGE
       (P_APP_NAME => c_fem
       ,P_MSG_NAME => G_EXT_LDR_POST_PROC_ERR);

   END Register_Process_Execution;



/*===========================================================================+
 | PROCEDURE
 |                 Main
 |
 | DESCRIPTION
 |
 |
 |
 | SCOPE - PUBLIC
 |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |              OUT:
 |
 |              IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |    This procedure is called by Concurrent Manager when the loader is launched
 |    It performs the following:
 |       1)  Validates $FEM_TOP and the input parameters passed by CM
 |       2)  Truncates the tables
 |       3)  Reloads the ldt files and the runs any procedures for seeded data
 |       4)  Resets profile options
 |       5)  Reports any error messages from the stack
 |       6)  Registers the process execution
 | HISTORY
 |    08-JUN-05 Rob Flippo   Modified to continue if error encountered during
 |                           load_seed_data
 |    14-SEP-06 Rob Flippo   Bug#5520316 Modified so that clean_tables, load_seed_data
 |                           and reset_profile_options all will get executed
 |                           even if error encountered in any of those 3
 |                           procs
 ===========================================================================*/
PROCEDURE Main (
   errbuf                       OUT NOCOPY     VARCHAR2
  ,retcode                      OUT NOCOPY     VARCHAR2
)

IS

   v_concurrent_status BOOLEAN;
   v_execution_status VARCHAR2(30);

   v_appltop VARCHAR2(1000);
   v_release VARCHAR2(100);
   -- Nested Procedure declarations

---------------------------------------------------------------------------
--  Main body of the "Main" procedure
---------------------------------------------------------------------------
BEGIN
   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1
    ,p_module => c_block||'.'||c_proc_name||'.Main'
    ,p_msg_text => 'begin');

   -- initialize the message stack
   FND_MSG_PUB.Initialize;

   v_execution_status := 'SUCCESS';
   gv_request_id := fnd_global.conc_request_id;

   Eng_master_prep (v_appltop, v_release, v_execution_status);

   IF v_execution_status = 'SUCCESS' THEN
      Clean_tables(v_execution_status);
      Load_seed_data (v_appltop
                     ,v_release
                     ,v_execution_status);
      Reset_profile_options(v_execution_status);
   END IF;

   IF v_execution_status = 'ERROR_RERUN' THEN
      Report_errors;
   END IF;

   Register_process_execution (c_object_id
                              ,c_object_definition_id
                              ,v_execution_status);

IF v_execution_status = 'ERROR_RERUN' THEN
  retcode := 2;
  FEM_ENGINES_PKG.USER_MESSAGE
  (P_APP_NAME => c_fem
  ,P_MSG_NAME => 'FEM_EXEC_RERUN');
ELSE
   Refresh_completion;
END IF;


EXCEPTION

   WHEN OTHERS THEN
      retcode := 2;
      gv_prg_msg := sqlerrm;
      gv_callstack := dbms_utility.format_call_stack;

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
       ,p_msg_text => gv_prg_msg);

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_6
       ,p_module => c_block||'.'||c_proc_name||'.Unexpected Exception'
       ,p_msg_text => gv_callstack);

      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_name => 'FEM_UNEXPECTED_ERROR'
       ,P_TOKEN1 => 'ERR_MSG'
       ,P_VALUE1 => gv_prg_msg);
/*
      FEM_ENGINES_PKG.USER_MESSAGE
       (p_app_name => c_fem
       ,p_msg_text => gv_prg_msg); */


END Main;

/***************************************************************************/

END FEM_REFRESH_ENG_PKG;

/
