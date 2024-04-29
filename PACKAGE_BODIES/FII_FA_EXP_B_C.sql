--------------------------------------------------------
--  DDL for Package Body FII_FA_EXP_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_FA_EXP_B_C" AS
/*$Header: FIIFA01B.pls 120.11 2006/08/21 17:22:38 bridgway noship $*/

 G_SOLE                  boolean;
 G_PARENT                boolean;
 G_CHILD                 boolean;

 G_NUMBER_OF_PROCESS     NUMBER;
 G_WORKER_NUM            NUMBER;

 g_retcode               VARCHAR2(20) := NULL;
 g_sob_id                NUMBER       := NULL;
 g_from_date             DATE;
 g_to_date               DATE;
 g_lud_from_date         DATE         := NULL;
 g_lud_to_date           DATE         := NULL;
 g_has_lud               BOOLEAN      := FALSE;
 g_fii_schema            VARCHAR2(30);
 g_prim_currency         VARCHAR2(10);
 g_sec_currency          VARCHAR2(10);
 g_prim_rate_type        VARCHAR2(30);
 g_sec_rate_type         VARCHAR2(30);
 g_prim_rate_type_name   VARCHAR2(30);
 g_sec_rate_type_name    VARCHAR2(30);
 g_primary_mau           NUMBER;
 g_secondary_mau         NUMBER;
 g_phase                 VARCHAR2(100);
 g_resume_flag           VARCHAR2(1)  := 'N';
 g_child_process_size    NUMBER       := 1000;
 g_missing_rates         NUMBER       := 0;
 g_missing_time          NUMBER       := 0;
 g_fii_user_id           NUMBER(15);
 g_fii_login_id          NUMBER(15);
 g_truncate_stg          BOOLEAN;
 g_truncate_id           BOOLEAN;
 g_debug_flag            VARCHAR2(1)  := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
 g_program_type          VARCHAR2(1);
 g_global_start_date     DATE;

 g_non_upgraded_ledgers  BOOLEAN := FALSE;

 ONE_SECOND     CONSTANT NUMBER := 0.000011574;  -- 1 second
 INTERVAL       CONSTANT NUMBER := 4;            -- 4 days
 MAX_LOOP       CONSTANT NUMBER := 180;          -- 180 loops = 180 minutes
 LAST_PHASE     CONSTANT NUMBER := 3;

 G_NO_CHILD_PROCESS      EXCEPTION;
 G_CHILD_PROCESS_ISSUE   EXCEPTION;
 G_LOGIN_INFO_NOT_AVABLE EXCEPTION;
 G_CAT_ID_FAILED EXCEPTION;

 g_usage_code CONSTANT VARCHAR2(10) := 'DBI';

-- ---------------------------------------------------------------
-- Private procedures and Functions;
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- PROCEDURE CHECK_XLA_CONVERSION_STATUS
-- ---------------------------------------------------------------
PROCEDURE CHECK_XLA_CONVERSION_STATUS IS

    CURSOR c_non_upgraded_ledgers IS
    SELECT DISTINCT
           s.ledger_id,
           s.name
      FROM gl_period_statuses  ps,
           gl_ledgers_public_v s,
           fa_deprn_periods    dp,
           fa_book_controls    bc,
           (SELECT DISTINCT slga.ledger_id
              FROM fii_slg_assignments         slga,
                   fii_source_ledger_groups    fslg
             WHERE slga.source_ledger_group_id = fslg.source_ledger_group_id
               AND fslg.usage_code             = g_usage_code) fset
     WHERE s.ledger_id        = fset.ledger_id
       AND ps.application_id  = 101
       AND ps.set_of_books_id = fset.ledger_id
       AND ps.end_date       >= g_global_Start_Date
       AND bc.set_of_books_id  = fset.ledger_id
       AND dp.book_type_code  = bc.book_type_code
       AND dp.period_name     = ps.period_name
       AND nvl(dp.xla_conversion_status, 'UA') <> 'UA';

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: CHECK_XLA_CONVERSION_STATUS');
      FII_UTIL.put_line('');
   end if;

   FOR ledger_record in c_non_upgraded_ledgers  LOOP
      g_non_upgraded_ledgers := TRUE;

      FII_MESSAGE.write_log(
         msg_name   => 'FII_XLA_NON_UPGRADED_LEDGER',
         token_num  => 3,
         t1         => 'PRODUCT',
         v1         => 'Assets',
         t2         => 'LEDGER',
         v2         => ledger_record.name,
         t3         => 'START_DATE',
         v3         => g_global_Start_Date);
   END LOOP;


EXCEPTION
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: CHECK_XLA_CONVERSION_STATUS
Phase: '||g_phase||'
Message: '||sqlerrm);

        raise;



END CHECK_XLA_CONVERSION_STATUS;

-- ---------------------------------------------------------------
-- PROCEDURE REPORT_MISSING_RATES
-- ---------------------------------------------------------------
PROCEDURE REPORT_MISSING_RATES IS
    TYPE cursorType is  REF CURSOR;

    l_stmt   VARCHAR2(500);
    l_count  NUMBER;
    l_curr   CURSORTYPE;

/*
    cursor PrimMissingRate is
       SELECT DISTINCT
              currency_code,
              decode( prim_conversion_rate,
              -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
              least(sysdate, effective_date)) effective_date
         FROM fii_fa_exp_t
        WHERE prim_conversion_rate < 0;

    cursor SecMissingRate is
       SELECT DISTINCT
              currency_code,
              decode( sec_conversion_rate,
              -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
              least(sysdate, effective_date) ) effective_date
         FROM fii_fa_exp_t
        WHERE sec_conversion_rate < 0;
*/

BEGIN

   -- for first phase, just return
   return;

/*

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: REPORT_MISSING_RATES');
      FII_UTIL.put_line('');
   end if;

   g_phase := 'Calling BIS_COLLECTION_UTILITIES.WriteMissingRateHeader to write out report header';
   if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_phase);
      FII_UTIL.put_line('');
   end if;

   BIS_COLLECTION_UTILITIES.WriteMissingRateHeader;

   g_phase := 'Calling BIS_COLLECTION_UTILITIES.WriteMissingRate to write out report contents';
   if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_phase);
      FII_UTIL.put_line('');
   end if;

   FOR rate_record in PrimMissingRate  LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
         g_prim_rate_type_name,
         rate_record.currency_code,
         g_prim_currency,
         rate_record.effective_7);
   END LOOP;

   FOR rate_record in SecMissingRate  LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
         g_sec_rate_type_name,
         rate_record.currency_code,
         g_sec_currency,
         rate_record.effective_date);
   END LOOP;

   FND_FILE.CLOSE;
*/

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        g_retcode:=-1;
        FII_UTIL.put_line('
---------------------------------------------------
Error in Procedure: REPORT_MISSING_RATES
Phase: '||g_phase||'
Message: Should have missing rates but found none');

        raise;

   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: REPORT_MISSING_RATES
Phase: '||g_phase||'
Message: '||sqlerrm);

        raise;

END REPORT_MISSING_RATES;


-----------------------------------------------------------------------
-- PROCEDURE GET_ACCT_CLASSES
-----------------------------------------------------------------------

PROCEDURE get_acct_classes is

   l_stmt                VARCHAR2(50);

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: GET_ACCT_CLASSES');
      FII_UTIL.put_line('');
   end if;

   insert into FII_FA_ACCT_CLASS_CODE_GT
                (accounting_class_code, ledger_id)
   SELECT XACA.accounting_class_code,
          fset.ledger_id
     FROM xla_post_acct_progs_b  XPAP,
          xla_assignment_defns_b XAD,
          xla_acct_class_assgns  XACA,
          (SELECT DISTINCT slga.ledger_id
             FROM fii_slg_assignments         slga,
                  fii_source_ledger_groups    fslg
            WHERE slga.source_ledger_group_id = fslg.source_ledger_group_id
              AND fslg.usage_code             = g_usage_code) fset
    WHERE XPAP.program_owner_code    = 'S'
      AND XPAP.program_code          = 'ASSETS DBI EXPENSES'
      AND XPAP.application_id        = 450
      AND XAD.program_code           = XPAP.program_code
      AND XAD.enabled_flag           = 'Y'
      AND XAD.ledger_id              = fset.ledger_id
      AND XACA.program_code          = XAD.program_code
      AND XACA.assignment_code       = XAD.assignment_code
    UNION
   SELECT XACA.accounting_class_code,
          fset.ledger_id
     FROM xla_post_acct_progs_b  XPAP,
          xla_assignment_defns_b XAD,
          xla_acct_class_assgns  XACA,
          (SELECT DISTINCT slga.ledger_id
             FROM fii_slg_assignments         slga,
                  fii_source_ledger_groups    fslg
            WHERE slga.source_ledger_group_id = fslg.source_ledger_group_id
              AND fslg.usage_code             = g_usage_code) fset
    WHERE XPAP.program_owner_code    = 'S'
      AND XPAP.program_code          = 'ASSETS DBI EXPENSES'
      AND XPAP.application_id        = 450
      AND XAD.program_code           = XPAP.program_code
      AND XAD.enabled_flag           = 'Y'
      AND XAD.ledger_id              is null
      AND XACA.program_code          = XAD.program_code
      AND XACA.assignment_code       = XAD.assignment_code
      AND not exists
          (select 1
             from xla_assignment_defns_b XAD2
            where xad2.ledger_id = fset.ledger_id);

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' rows into FII_FA_ACCT_CLASS_CODE_GT');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
   end if;

EXCEPTION
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: GET_ACCT_CLASSES
Phase: '||g_phase||'
Message: '||sqlerrm);

        raise;


END GET_ACCT_CLASSES;

-----------------------------------------------------------------------
-- PROCEDURE INIT
-----------------------------------------------------------------------
PROCEDURE Init is

   l_stmt                VARCHAR2(50);

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: INIT');
      FII_UTIL.put_line('');
   end if;

   -- -------------------------------------------
   -- Turn on parallel insert/dml for the session
   -- Commit to terminate any open transactions
   -- This will avoid issue with not being able
   -- to run ddl within a transaction
   -- -------------------------------------------
   /*g_phase        := 'Altering session to enable parallel DML';
   commit;

   -- *** avoiding this as it's causing:
   -- ORA-12838: cannot read/modify an object after modifying it in parallel

   if (G_ = 'L') then
      l_stmt           :='ALTER SESSION ENABLE PARALLEL DML';

      execute immediate l_stmt;
   end if;

   ----------------------------------------------------------
   -- Find the schema owner of FII
   ----------------------------------------------------------
   g_phase          := 'Find FII schema';
   g_fii_schema     := FII_UTIL.get_schema_name ('FII');

/*
   --------------------------------------------------------------
   -- Find all currency related information
   --------------------------------------------------------------
   g_phase          := 'Find currency information';

   g_primary_mau    := nvl(fii_currency.get_mau_primary, 0.01 );
   g_secondary_mau  := nvl(fii_currency.get_mau_secondary, 0.01);
   g_prim_currency  := bis_common_parameters.get_currency_code;
   g_sec_currency   := bis_common_parameters.get_secondary_currency_code;
   g_prim_rate_type := bis_common_parameters.get_rate_type;
   g_sec_rate_type  := bis_common_parameters.get_secondary_rate_type;

   begin
      g_phase := 'Convert rate_type to rate_type_name';

      select user_conversion_type into g_prim_rate_type_name
        from gl_daily_conversion_types
       where conversion_type = g_prim_rate_type;

      if g_sec_rate_type is not null then
         select user_conversion_type into g_sec_rate_type_name
           from gl_daily_conversion_types
          where conversion_type = g_sec_rate_type;
      else
         g_sec_rate_type_name := null;
      end if;

   exception
      when others then
           fii_util.write_log('Failed to convert rate_type to rate_type_name' );
            raise;
   end;
*/

EXCEPTION
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: INIT
Phase: '||g_phase||'
Message: '||sqlerrm);

        raise;

END Init;

-----------------------------------------------------------------
-- FUNCTION CHECK_IF_SLG_SET_UP_CHANGE
--
-- FA NOTE: this will hopefully become and API if still needed
-- so we're not dupicating code from FIIGL03B.pls
-----------------------------------------------------------------
FUNCTION CHECK_IF_SLG_SET_UP_CHANGE RETURN VARCHAR2 IS

   l_slg_chg VARCHAR2(10);
   l_count1  number := 0;
   l_count2  number := 0;

BEGIN

   g_phase := 'Check if Source Legder Assignments setup has changed';
   if g_debug_flag  = 'Y' then
      FII_UTIL.put_line(g_phase);
   end if;

   SELECT DECODE(item_value, 'Y', 'TRUE', 'FALSE')
     INTO l_slg_chg
     FROM fii_change_log
    WHERE log_item = 'FA_RESUMMARIZE';

   IF l_slg_chg = 'TRUE' THEN

      g_phase := 'Reach l_slg_chg = TRUE';

      begin

         SELECT 1
           INTO l_count1
           FROM fii_fa_exp_f
          WHERE ROWNUM = 1;
      exception
         when NO_DATA_FOUND then
              l_count1 := 0;
      end;

      begin
         SELECT 1
           INTO l_count2
           FROM fii_fa_exp_t
          WHERE ROWNUM = 1;
      exception
         when NO_DATA_FOUND then
              l_count2 := 0;
      end;


      IF (l_count1 = 0 AND l_count2 = 0)  then
         g_phase := 'Updating fii_change_log for log_item FA_RESUMMARIZE';
         UPDATE fii_change_log
            SET item_value        = 'N',
                last_update_date  = SYSDATE,
                last_update_login = g_fii_login_id,
                last_updated_by   = g_fii_user_id
          WHERE log_item          = 'FA_RESUMMARIZE'
            AND item_value        = 'Y';

         COMMIT;

         l_slg_chg := 'FALSE';
      END IF;

   END IF;

   RETURN l_slg_chg;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 'FALSE';
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
-----------------------------
Error occured in Funcation: CHECK_IF_SLG_SET_UP_CHANGE
Phase: '||g_phase||'
Message: ' || sqlerrm);

        raise;

END CHECK_IF_SLG_SET_UP_CHANGE;


-----------------------------------------------------------------
-- PROCEDURE REGISTER_JOBS
--
-- FA NOTE: this currently NOT used for our method of paralization
--  pending DBI/perf review, as we may change and need this,
--  so keeping it and it's original GL layout here
-----------------------------------------------------------------
PROCEDURE REGISTER_JOBS IS

   l_max_number   NUMBER;
   l_start_number NUMBER;
   l_end_number   NUMBER;
   l_count        NUMBER := 0;

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: REGISTER_JOBS');
      FII_UTIL.put_line('');
   end if;

   g_phase := 'Register jobs for workers';
   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Register jobs for workers');
   end if;

   ------------------------------------------------------------
   --  select min and max sequence IDs from your ID Temp table
   ------------------------------------------------------------
   g_phase := 'select min and max dist ids';

   SELECT NVL(max(record_id), 0), nvl(min(record_id),1)
     INTO l_max_number, l_start_number
     FROM FII_FA_NEW_EXP_HDR_IDS;

   WHILE (l_start_number <= l_max_number) LOOP
      l_end_number:= l_start_number + g_child_process_size;
      g_phase := 'Loop to insert into FII_FA_WORKER_JOBS: '
                  || l_start_number || ', ' || l_end_number;
      INSERT INTO FII_FA_WORKER_JOBS (start_range, end_range, worker_number, status)
      VALUES (l_start_number, least(l_end_number, l_max_number), 0, 'UNASSIGNED');
      l_count := l_count + 1;
      l_start_number := least(l_end_number, l_max_number) + 1;
   END LOOP;

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Inserted ' || l_count || ' jobs into FII_FA_WORKER_JOBS table');
   end if;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: REGISTER_JOBS
Phase: '||g_phase||'
Message: '||sqlerrm);
        RAISE;

END REGISTER_JOBS;

-----------------------------------------------------------------------
-- FUNCTION LAUNCH_WORKERS
--
-- FA NOTE: different from FII's utilization in that we
--  are reusing the same conc definition for parent and child
--
-----------------------------------------------------------------------
PROCEDURE LAUNCH_WORKERS(p_number_of_workers  NUMBER) IS

   l_request_id         NUMBER;

BEGIN

   FOR i IN 1..p_number_of_workers LOOP


      l_request_id := FND_REQUEST.SUBMIT_REQUEST('FII',
                                              'FII_FA_EXP_B_C',
                                              NULL,
                                              NULL,
                                              FALSE,
                                              p_number_of_workers,
                                              i,
                                              'I',
                                              1,
                                              20000000,
                                              20000000);

      if g_debug_flag = 'Y' then
         FII_util.put_line('  Worker '||i||' request id: '||l_request_id);
      end if;

      IF (l_request_id = 0) THEN
         rollback;
         g_retcode := -1;
         FII_UTIL.put_line('
---------------------------------
Error in Procedure: LAUNCH_WORKERS
Message: '||fnd_message.get);
         raise G_NO_CHILD_PROCESS;
      END IF;


   END LOOP;

   COMMIT;  -- moved from iteration level per Renu

EXCEPTION
   WHEN G_NO_CHILD_PROCESS THEN
        g_retcode := -1;
        FII_UTIL.put_line('No child process launched');
        raise;

   WHEN OTHERS THEN
        rollback;
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: LAUNCH_WORKERS
Message: '||sqlerrm);

        raise;

END LAUNCH_WORKERS;

-----------------------------------------------------------------------
-- PROCEDURE CHILD_SETUP
--
-- FA NOTE: unsure if this is needed????
-----------------------------------------------------------------------
PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS

   l_dir      VARCHAR2(400);
   l_stmt     VARCHAR2(100);

BEGIN

   g_phase := 'Calling ALTER SESSION SET global_names = false ';
   l_stmt  := 'ALTER SESSION SET global_names = false';
   EXECUTE IMMEDIATE l_stmt;

   g_fii_user_id  := FND_GLOBAL.User_Id;
   g_fii_login_id := FND_GLOBAL.Login_Id;

EXCEPTION
   WHEN OTHERS THEN
        rollback;
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: CHILD_SETUP
Phase: '||g_phase||'
Message: '||sqlerrm);

        raise;

END CHILD_SETUP;

--------------------------------------------------------------------
-- PROCEDURE SUMMARY_ERR_CHECK
--
-- FA NOTE: not used in first phase since we won't do global
--   currencies yet, but retaining for when we do currently
--   references original GL tables which would change
--------------------------------------------------------------------
PROCEDURE SUMMARY_ERR_CHECK IS

   l_conv_rate_cnt  NUMBER :=0;
   l_stg_min        DATE;
   l_stg_max        DATE;
   l_row_cnt        NUMBER;
   l_check_time_dim BOOLEAN;

BEGIN

   g_phase := 'Checking for missing rates';
   if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_phase);
   end if;


   --------------------------------------------------------
   -- FA's initial version doesn't handle global currencies
   -- skipping this
   ------------------------------------------------------

/*

   ------------------------------------------------------
   -- If there are missing exchange rates indicated in
   -- the staging table, then call report_missing_rates
   -- API to print out the missing rates report
   ------------------------------------------------------
   IF (g_program_type = 'L') THEN
      g_phase := 'For g_program_type = L ';
      SELECT MIN(trx_date), MAX(trx_date), sum(decode(sign(prim_conversion_rate), -1, 1, 0)) +
                sum(decode(sign(sec_conversion_rate), -1, 1, 0)), count(*)
        INTO l_stg_min, l_stg_max, l_conv_rate_cnt, l_row_cnt
        FROM FII_GL_REVENUE_RATES_TEMP;

   ELSE

      g_phase := 'For g_program_type <> L ';
      SELECT MIN(effective_date), MAX(effective_date), sum(decode(sign(prim_conversion_rate), -1, 1, 0)) +
                sum(decode(sign(sec_conversion_rate), -1, 1, 0)), count(*)
       INTO l_stg_min, l_stg_max, l_conv_rate_cnt, l_row_cnt
       FROM FII_GL_JE_SUMMARY_STG;

   END IF;

   IF l_row_cnt = 0 THEN
      IF g_debug_flag = 'Y' THEN
         FII_UTIL.put_line('Summary Error Check completed successfully, no data found!');
      END IF;
      RETURN;
   END IF;

   IF (l_conv_rate_cnt >0) THEN
      -------------------------------------------------
      -- Write out translated message to let user know
      -- there are missing exchange rate information
      -------------------------------------------------
      FII_MESSAGE.write_output (msg_name => 'FII_MISS_EXCH_RATE_FOUND', token_num => 0);
      FII_MESSAGE.write_log    (msg_name => 'FII_MISS_EXCH_RATE_FOUND', token_num => 0);
      FII_MESSAGE.write_log    (msg_name => 'FII_REFER_TO_OUTPUT',      token_num => 0);

      --FII_UTIL.put_line('Missing currency conversion rates found, program will exit with error status.  Please fix the missing conversion rates');

      g_retcode := -1;
      g_missing_rates := 1;
      IF g_program_type = 'L' THEN
         REPORT_MISSING_RATES_L;
      ELSE
         REPORT_MISSING_RATES;
      END IF;
      RETURN;
   END IF;

   g_phase := 'Checking for Time dimension';
   if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_phase);
   end if;

*/


   -----------------------------------------------------------
   -- If we find record in the staging table which references
   -- time records which does not exist in FII_TIME_DAY
   -- table, then we will exit the program with error status
   --
   -- moving this out from comments per Renu
   -----------------------------------------------------------

   -- FII_TIME_API.check_missing_date (l_stg_min, l_stg_max, l_check_time_dim);

   --------------------------------------
   -- If there are missing time records
   --------------------------------------
   IF (l_check_time_dim) THEN

      FII_MESSAGE.write_output (msg_name  => 'FII_TIME_DIM_STALE',  token_num => 0);
      FII_MESSAGE.write_log    (msg_name  => 'FII_TIME_DIM_STALE',  token_num => 0);
      FII_MESSAGE.write_log    (msg_name  => 'FII_REFER_TO_OUTPUT', token_num => 0);

      --FII_UTIL.put_line('Time Dimension is not fully populated.  Please populate Time dimension to cover the date range you are collecting');

      g_retcode := -1;  --we set it error out for missing time
      g_missing_time := 1;
      RETURN;
   END IF;

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Summary Error Check completed successfully, no error found!');
   end if;
   RETURN;

EXCEPTION
   WHEN OTHERS THEN
        g_retcode := -1;
        FII_UTIL.put_line('
---------------------------------
Error occured in Summary_err_check function
Phase: '||g_phase||'
Message: '||sqlerrm);

        Raise;

END Summary_err_check;

-----------------------------------------------------------------------
-- PROCEDURE CLEAN_UP
-----------------------------------------------------------------------
PROCEDURE Clean_Up IS

  l_ret_code varchar2(30);

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: CLEAN_UP');
   end if;

   ------------------------------------------------------
   -- Current plan is to not use a worker table
   ------------------------------------------------------
   FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_WORKER_JOBS',
                           P_RETCODE    => l_ret_code);

   IF (g_truncate_id) THEN
      FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_NEW_EXP_HDR_IDS',
                            P_RETCODE      => l_ret_code);
   END IF;

   IF (g_truncate_stg) THEN
      FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_EXP_T',
                            P_RETCODE      => l_ret_code);

   END IF;

   COMMIT;

EXCEPTION
   WHEN OTHERS Then
        g_retcode:=-1;
        FII_UTIL.put_line('
---------------------------------
Error in Procedure: Clean_Up
Message: ' || sqlerrm);

        RAISE;

END Clean_up;

------------------------------------------------------------------------
-- PROCEDURE JOURNALS_PROCESSED
--
-- NOTE: simply moves lines from the initial table used for selection
-- to the table which will permanently flag them as processed
------------------------------------------------------------------------
PROCEDURE JOURNALS_PROCESSED IS

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line ('Calling Journals_Processed Procedure');
      FII_UTIL.start_timer;
   end if;

   ---------------------------------------------------------------------
   -- Inserting processed JE Header IDs into FII_FA_EXP_HDR_IDS
   -- table.  Not all JE Header IDs in FII_FA_NEW_EXP_HDR_IDS are
   -- processed.  This is because when we select Header IDs to be
   -- processed (refer to NEW_JOURNALS function), we only filter by SOB
   -- in FII_COMPANY_SETS table, however when we extract data from OLTP
   -- tables, we actually filter data by both SOB and Company
   ---------------------------------------------------------------------

   INSERT INTO fii_fa_exp_hdr_ids (
                je_header_id,
                creation_date,
                created_by,
                last_update_date,
                last_update_login,
                last_updated_by)
    SELECT distinct
           je_header_id,
           sysdate,
           g_fii_user_id,
           sysdate,
           g_fii_login_id,
           g_fii_user_id
      FROM fii_fa_new_exp_hdr_ids;

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' rows into FII_FA_EXP_HDR_IDS');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
   end if;

Exception
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: Journal_processed
Message: '||sqlerrm);
    ROLLBACK;
    raise;
END Journals_Processed;

-----------------------------------------------------------------------
-- FUNCTION NEW_JOURNALS
--
-- FA NOTE: find new lines to processed based on a combination of
--  our GL/SLA/FA tables for tracking posted journals
-----------------------------------------------------------------------
Function  New_Journals(P_Start_Date   IN  DATE,
                       P_End_Date     IN  DATE) RETURN NUMBER IS

   l_number_of_rows     NUMBER :=0;

BEGIN

   ----------------------------------------------------------------------
   -- Insert into a table to hold GL and AE header ids which have not been
   -- processed (and would not exist in the table)
   --
   -- The Journal must be posted (and not reversed/rolled back)
   -- And Journal entry line effective date falls within user specified
   -- date range.
   --
   -- For assets, this selection breaks into 4 pieces:
   --  1) current logic using the FA_JOURNAL_ENTRIES table for audit
   --      where status would be C
   --  2) older logic where this table did not exist
   --     (this only needs to be concidered in the Initial Load
   --  3) journals already extracted to base summary but since rolled
   --     back (status = B)
   --
   -----------------------------------------------------------------------
   if g_debug_flag = 'Y' then
      FII_UTIL.put_line(' ');
      FII_UTIL.put_line('Inserting New Journal header ids');
      FII_UTIL.start_timer;
   end if;

   if (g_program_type <> 'L') then

      -- incremental mode only!
      -- fetch any journal runs which have been previously extracted to
      -- DBI but rolled back since

      -- NOTE FIX THIS - should probably put in stage then update later (update or new row?)

      insert into
        fii_fa_new_exp_hdr_ids
         (JE_HEADER_ID                    ,
          AE_HEADER_ID                    ,
          EVENT_TYPE_CODE                 ,
          EVENT_ID                        ,
          LEDGER_ID                       ,
          CREATION_DATE                   ,
          CREATED_BY                      ,
          LAST_UPDATE_DATE                ,
          LAST_UPDATED_BY                 ,
          LAST_UPDATE_LOGIN,
          RECORD_ID)
        select nid.je_header_id,
               nid.ae_header_id,
               nid.event_type_code,
               nid.event_id,
               nid.ledger_id,
               sysdate,
               1,
               sysdate,
               1,
               1,
               rownum
          from (select distinct
                       glh.JE_HEADER_ID           ,
                       xlah.ae_Header_id          ,
                       xlah.event_type_code       ,
                       xlah.event_id              ,
                       glh.ledger_id
                  from fii_gl_processed_header_ids fiiglh,
                       gl_je_headers               glh,
                       gl_import_references        gir,
                       xla_ae_lines                xlal,
                       xla_ae_headers              xlah,
                       xla_subledgers              xlasl,
                       (SELECT p.period_name,
                               s.ledger_id
                          FROM gl_periods       p,
                               gl_ledgers_public_v s
                         WHERE p.end_date       >= g_global_Start_Date
                           AND p.period_set_name = s.period_set_name) per,
                       (SELECT DISTINCT slga.ledger_id
                          FROM fii_slg_assignments         slga,
                               fii_source_ledger_groups    fslg
                         WHERE slga.source_ledger_group_id = fslg.source_ledger_group_id
                           AND fslg.usage_code             = g_usage_code) fset
                 where xlasl.application_id          = 140
                   and glh.JE_SOURCE                 = xlasl.je_source_name
                   and fiiglh.je_header_id           = glh.je_header_id
                   and gir.je_header_id              = glh.je_header_id
                   and gir.gl_sl_link_id             = xlal.gl_sl_link_id
                   and xlal.ae_header_id             = xlah.ae_header_id
                   and xlal.application_id           = 140
                   and xlah.application_id           = 140
                   and glh.period_name               = per.period_name
                   and glh.ledger_id                 = per.ledger_id
                   and glh.ledger_id                 = fset.ledger_id
                   and glh.ledger_id                 = xlah.ledger_id
                   and not exists
                       (select 1
                          from fii_fa_exp_hdr_ids faph
                         where faph.je_header_id = fiiglh.je_header_id)) nid;

      l_number_of_rows := SQL%ROWCOUNT;

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('Inserted '||l_number_of_rows||
                           ' JE header IDs into FII_FA_NEW_EXP_HDR_IDS for new entries');
         FII_UTIL.stop_timer;
         FII_UTIL.print_timer('Duration');
         FII_UTIL.put_line('');
      end if;

      commit;

   else -- initial

      -- Fetch all rows from FA_JOURNAL_ENTRIES which are not rolled back
      -- and insert into FII_FA_EXP_HDR_IDS table.

      -- R12: for efficiency, we will use group_id instead of ae_header_id
      -- for access in initial mode

      -- R12: note that there is a potential for multiple deprn events for
      -- the same entity as well as the rollback events to be picked up here
      -- we want to insure we only pick up events which have not been reversed
      -- Since this is the header level, we will do this later on

      -- BUG# 4996218
      -- remove reliance on group_id

      insert /*+ append parallel(i) */
        into fii_fa_new_exp_hdr_ids i
         (JE_HEADER_ID                    ,
          LEDGER_ID                       ,
          CREATION_DATE                   ,
          CREATED_BY                      ,
          LAST_UPDATE_DATE                ,
          LAST_UPDATED_BY                 ,
          LAST_UPDATE_LOGIN)
        select /*+ parallel(fiiglh) parallel(glh) parallel(xlash) parallel(per) parallel(fset) */
               distinct glh.JE_HEADER_ID  ,
               glh.ledger_id              ,
               sysdate,
               1,
               sysdate,
               1,
               1
         from fii_gl_processed_header_ids fiiglh,
              gl_je_headers               glh,
              xla_subledgers              xlasl,
              (SELECT p.period_name,
                      s.ledger_id
                 FROM gl_periods       p,
                      gl_ledgers_public_v s
                WHERE p.end_date       >= g_global_Start_Date
                  AND p.period_set_name = s.period_set_name) per,
              (SELECT DISTINCT slga.ledger_id
                 FROM fii_slg_assignments         slga,
                      fii_source_ledger_groups    fslg
                WHERE slga.source_ledger_group_id = fslg.source_ledger_group_id
                  AND fslg.usage_code             = g_usage_code) fset
        where xlasl.application_id = 140
          and glh.JE_SOURCE        = xlasl.je_source_name
          and fiiglh.je_header_id  = glh.je_header_id
          and glh.period_name      = per.period_name
          and glh.ledger_id        = per.ledger_id
          and glh.ledger_id        = fset.ledger_id;

      l_number_of_rows := SQL%ROWCOUNT;
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('Inserted '||l_number_of_rows||
                           ' JE header IDs into FII_FA_NEW_EXP_HDR_IDS for main processing');
         FII_UTIL.stop_timer;
         FII_UTIL.print_timer('Duration');
         FII_UTIL.put_line('');
      end if;

      commit;

   end if;

   COMMIT;
   return(l_number_of_rows);

Exception
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in New_Journals Procedure
Message: '||sqlerrm);
    RAISE;
END New_Journals;


---------------------------------------------------------------
-- PROCEDURE DELETE_FROM_BASE_SUMMARY
---------------------------------------------------------------
PROCEDURE DELETE_FROM_BASE_SUMMARY (p_start_range       IN   NUMBER,
                                    p_end_range         IN   NUMBER)    IS

   l_count number;

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line ('Calling Delete_From_Base_Summary Procedure');
      FII_UTIL.start_timer;
   end if;

   delete from fii_fa_exp_f
    where xla_event_id in
          (select ev_dep.event_id
             from fii_fa_new_exp_hdr_ids nid,
                  xla_events              ev_rb,
                  xla_events              ev_dep
            where nid.record_id           between p_start_range and p_end_range
              and nid.event_type_code     = 'ROLLBACK_DEPRECIATION'
              and ev_rb.event_id          = nid.event_id
              and ev_rb.application_id    = 140
              and ev_dep.entity_id        = ev_rb.entity_id
              and ev_dep.application_id   = 140
              and ev_rb.event_id          > ev_dep.event_id);

   l_count := SQL%ROWCOUNT;

   commit;

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Deleted '|| l_count ||
                        ' lines from FII_FA_EXP_F for rolled back entries');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
      FII_UTIL.put_line('');
   end if;


Exception
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Delete_From_Base_Summary Procedure
Message: '||sqlerrm);
    RAISE;
END Delete_From_Base_Summary;


---------------------------------------------------------------
-- PROCEDURE VERIFY_CAT_ID_UP_TO_DATE
---------------------------------------------------------------
PROCEDURE VERIFY_CAT_ID_UP_TO_DATE IS

   l_errbuf        VARCHAR2(1000);
   l_retcode       VARCHAR2(100);
   l_request_id    NUMBER;
   l_result        BOOLEAN;
   l_phase         VARCHAR2(500) := NULL;
   l_status        VARCHAR2(500) := NULL;
   l_devphase      VARCHAR2(500) := 'PENDING';
   l_devstatus     VARCHAR2(500) := NULL;
   l_message       VARCHAR2(500) := NULL;
   l_dummy         BOOLEAN;
   l_call_status   boolean;

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling Procedure: VERIFY_CAT_ID_UP_TO_DATE');
      FII_UTIL.put_line('');
   end if;

   IF(FII_FA_CAT_C.NEW_CAT_IN_FA) THEN

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('CAT_ID Dimension is not up to date, calling CAT_ID Dimension update program');
      end if;

      g_phase      := 'Calling CAT_ID Dimension update program';
      l_dummy      := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := FND_REQUEST.SUBMIT_REQUEST('FII', 'FII_FA_CAT_ID_C',
                                                 NULL, NULL, FALSE, 'I');
      commit;

      IF (l_request_id = 0) THEN
         rollback;
         g_retcode := -1;
         FII_UTIL.put_line('
---------------------------------
Error in Procedure: VERIFY_CAT_ID_UP_TO_DATE
Message: '||fnd_message.get);
        raise G_NO_CHILD_PROCESS;
      END IF;

      g_phase  := 'Calling FND_CONCURRENT.wait_for_request';
      l_result := FND_CONCURRENT.wait_for_request(request_id => l_request_id,
                                                  interval   => 30,
                                                  max_wait   => 3600,
                                                  phase      => l_phase,
                                                  status     => l_status,
                                                  dev_phase  => l_devphase,
                                                  dev_status => l_devstatus,
                                                  message    => l_message);

      g_phase := 'Finished calling FND_CONCURRENT.wait_for_request -> ' || l_devphase || ', ' || l_devstatus;

      IF (NVL(l_devphase='COMPLETE' AND l_devstatus='NORMAL', FALSE)) THEN
         if g_debug_flag = 'Y' then
            FII_UTIL.put_line('CAT_ID Dimension populated successfully');
         end if;
      ELSE
         if g_debug_flag = 'Y' then
            FII_UTIL.put_line('CAT_ID Dimension populated unsuccessfully');
         end if;
         raise G_CAT_ID_FAILED;
      END IF;

   ELSE

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('CAT_ID Dimension is up to date');
         FII_UTIL.put_line('');
      end if;

   END IF;

EXCEPTION
   WHEN G_CAT_ID_FAILED THEN
        g_retcode := -1;
        FII_UTIL.put_line('
----------------------------
Error in Procedure : VERIFY_CAT_ID_UP_TO_DATE when running CAT_ID program
Phase: ' || g_phase);
    raise;

   WHEN OTHERS Then
        g_retcode := -1;
        FII_UTIL.put_line('
----------------------------
Error in Procedure : VERIFY_CAT_ID_UP_TO_DATE
Phase: ' || g_phase || '
Message: '||sqlerrm);

        raise;

END VERIFY_CAT_ID_UP_TO_DATE;




----------------------------------------
-- PROCEDURE Insert_Into_Rates
--
-- FA NOTE: not used in first phase - still refresnces orignal gl tables
----------------------------------------

PROCEDURE INSERT_INTO_RATES IS

   l_global_prim_curr_code  VARCHAR2(30);
   l_global_sec_curr_code   VARCHAR2(30);

BEGIN

   -----------------------
   -- for now, no rates
   -----------------------
   return;

/*
   g_phase := 'Calling bis_common_parameters.get_currency_code';

   l_global_prim_curr_code := bis_common_parameters.get_currency_code;
   l_global_sec_curr_code  := bis_common_parameters.get_secondary_currency_code;

   if g_debug_flag = 'Y' then
      fii_util.put_line(' ');
      fii_util.put_line('Loading data into rates table');
      fii_util.start_timer;
      fii_util.put_line('');
   end if;

   g_phase := 'Inserting into fii_fa_exp_rates_temp';

   insert into fii_fa_exp_rates_temp
          (FUNCTIONAL_CURRENCY,
           TRX_DATE,
           PRIM_CONVERSION_RATE,
           SEC_CONVERSION_RATE)
   select cc functional_currency,
          dt trx_date,
          decode(cc, l_global_prim_curr_code, 1, FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY (cc,least(sysdate, dt))) PRIM_CONVERSION_RATE,
          decode(cc, l_global_sec_curr_code, 1, FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(cc,least(sysdate, dt))) SEC_CONVERSION_RATE
     from (
           select  distinct
                  FUNCTIONAL_CURRENCY cc,
                  account_date dt
            from fii_fa_exp_t
          );


   --Call FND_STATS to collect statistics after populating the table
   g_phase := 'Calling FND_STATS to collect statistics for fii_gl_revenue_rates_temp';
   FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_GL_REVENUE_RATES_TEMP');

   if g_debug_flag = 'Y' then
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_gl_revenue_rates_temp');
      fii_util.stop_timer;
      fii_util.print_timer('Duration');
   end if;

*/

/* + no_merge parallel(fii_fa_exp_t)*/

EXCEPTION
   WHEN OTHERS Then
        g_retcode := -1;
        FII_UTIL.put_line('
----------------------------
Error in Function: Insert_Into_Rates
Phase: ' || g_phase || '
Message: '||sqlerrm);

        raise;

END INSERT_INTO_RATES;


------------------------------------------
-- PROCEDURE Insert_Into_Summary
--
-- NOTE: picks up all lines at detail level and puts them
--       directly into fact table for incremental mode
--
-- this may need to change later - we'll see
------------------------------------------

PROCEDURE INSERT_INTO_SUMMARY (p_start_range       IN   NUMBER,
                               p_end_range         IN   NUMBER)    IS

   l_stmt   VARCHAR2(1000);

BEGIN

   g_phase := 'Inserting into fii_fa_exp_f-periodic deprn';

   if g_debug_flag = 'Y' then
      fii_util.put_line('g_number_of_process: ' || to_char(g_number_of_process));
      fii_util.put_line('g_worker_num: ' || to_char(g_worker_num));

      fii_util.put_line(' ');
      fii_util.put_line(g_phase);
      fii_util.start_timer;
      fii_util.put_line('');
   end if;

   insert into fii_fa_exp_f
      (LEDGER_ID                   ,
       ACCOUNT_DATE                ,
       CURRENCY_CODE               ,
       CHART_OF_ACCOUNTS_ID        ,
       COMPANY_ID                  ,
       COST_CENTER_ID              ,
       NATURAL_ACCOUNT_ID          ,
       user_dim1_id                ,
       user_dim2_id                ,
       ASSET_CAT_FLEX_STRUCTURE_ID ,
       asset_CAT_ID                ,
       asset_cat_MAJOR_ID          ,
       asset_cat_MAJOR_VALUE       ,
       asset_cat_MINOR_ID          ,
       asset_cat_MINOR_VALUE       ,
       BOOK_TYPE_CODE              ,
       ASSET_ID                    ,
       ASSET_NUMBER                ,
       DISTRIBUTION_ID             ,
       DISTRIBUTION_CCID           ,
       EXPENSE_CCID                ,
       SOURCE_CODE                 ,
       DEPRN_TYPE                  ,
       AMOUNT_T                    ,
       AMOUNT_B                    ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN           ,
       XLA_EVENT_ID                ,
       XLA_AE_HEADER_ID
      )
   select bc.set_of_books_id,
          dp.calendar_period_close_date,
          sob.currency_code,
          bc.accounting_flex_structure,
          ccid.company_id,
          ccid.cost_center_id,
          ccid.natural_account_id,
          ccid.user_dim1_id,
          ccid.user_dim2_id,
          cat.flex_structure_id,
          cat.category_id,
          cat.major_id,
          cat.major_value,
          cat.minor_id,
          cat.minor_value,
          bc.book_type_code,
          dh.ASSET_ID,
          ad.asset_number,
          dh.DISTRIBUTION_ID,
          dh.CODE_COMBINATION_ID,
          lines.code_combination_id,
          'DEPRN',
          links.source_distribution_type,      --decode to this possibly?    was EXPENSE
          nvl(lines.accounted_dr, 0) - nvl(lines.accounted_cr, 0),
          nvl(lines.accounted_dr, 0) - nvl(lines.accounted_cr, 0),
          sysdate,
          g_fii_user_id,
          sysdate,
          g_fii_user_id,
          g_fii_login_id,
          nid.event_id,
          nid.ae_header_id
     from fii_fa_new_exp_hdr_ids  nid,
          xla_ae_lines            lines,
          fii_fa_acct_class_code_gt acls,
          fii_gl_ccid_dimensions  ccid,
          gl_ledgers_public_v     sob,
          gl_import_references    gir,
          xla_distribution_links  links,
          fa_deprn_detail         dd,
          fa_distribution_history dh,
          fa_additions_b          ad,
          fa_asset_history        ah,
          fii_fa_cat_dimensions   cat,
          fa_deprn_periods        dp,
          fa_book_controls        bc
    where nid.record_id               between p_start_range and p_end_range
      and nid.event_type_code               = 'DEPRECIATION'
      and lines.ae_header_id                = nid.ae_header_id
      and lines.application_id              = 140
      and acls.accounting_class_code        = lines.accounting_class_code
      and acls.ledger_id                    = nid.ledger_id
      and gir.je_header_id                  = nid.je_header_id
      and gir.gl_sl_link_id                 = lines.gl_sl_link_id
      and sob.ledger_id                     = nid.ledger_id
      and ccid.code_combination_id          = lines.code_combination_id
      and links.ae_header_id                = lines.ae_header_id
      and links.ae_line_num                 = lines.ae_line_num
      and links.application_id              = 140
      and dd.asset_id                       = links.Source_distribution_id_num_1
      and dd.distribution_id                = links.Source_distribution_id_num_5
      and dd.deprn_run_id                   = links.Source_distribution_id_num_3
      and dd.book_type_code                 = links.Source_distribution_id_char_4
      and dd.period_counter                 = links.Source_distribution_id_num_2
      and dd.distribution_id                = dh.distribution_id
      and ad.asset_id                       = dh.asset_id
      and ah.asset_id                       = dh.asset_id
      and ah.date_effective                <= dh.date_effective
      and nvl(ah.date_ineffective, sysdate + 1) > nvl(dh.date_ineffective, sysdate)
      and ah.transaction_header_id_in      <= dh.transaction_header_id_in
      and nvl(ah.transaction_header_id_out,
          nvl(dh.transaction_header_id_out + 1, 1)) >
          nvl(dh.transaction_header_id_out, 0)
      and cat.category_id                   = ah.category_id
      and dp.book_type_code                 = dd.book_type_code
      and dp.period_counter                 = dd.period_counter
      and bc.book_type_code                 = dp.book_type_code
      and bc.set_of_books_id                = sob.ledger_id;

   if g_debug_flag = 'Y' then
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_fa_exp_f');
      fii_util.stop_timer;
      fii_util.print_timer('Duration');
   end if;

   commit;

   g_phase := 'Inserting into fii_fa_exp_f-catchup deprn';

   if g_debug_flag = 'Y' then
      fii_util.put_line(' ');
      fii_util.put_line(g_phase);
      fii_util.start_timer;
      fii_util.put_line('');
   end if;

   insert into fii_fa_exp_f
      (LEDGER_ID                   ,
       ACCOUNT_DATE                ,
       CURRENCY_CODE               ,
       CHART_OF_ACCOUNTS_ID        ,
       COMPANY_ID                  ,
       COST_CENTER_ID              ,
       NATURAL_ACCOUNT_ID          ,
       user_dim1_id                ,
       user_dim2_id                ,
       ASSET_CAT_FLEX_STRUCTURE_ID ,
       asset_CAT_ID                ,
       asset_cat_MAJOR_ID          ,
       asset_cat_MAJOR_VALUE       ,
       asset_cat_MINOR_ID          ,
       asset_cat_MINOR_VALUE       ,
       BOOK_TYPE_CODE              ,
       ASSET_ID                    ,
       ASSET_NUMBER                ,
       DISTRIBUTION_ID             ,
       DISTRIBUTION_CCID           ,
       EXPENSE_CCID                ,
       SOURCE_CODE                 ,
       DEPRN_TYPE                  ,
       AMOUNT_T                    ,
       AMOUNT_B                    ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN           ,
       XLA_EVENT_ID                ,
       XLA_AE_HEADER_ID
      )
   select bc.set_of_books_id,
          dp.calendar_period_close_date,
          sob.currency_code,
          bc.accounting_flex_structure,
          ccid.company_id,
          ccid.cost_center_id,
          ccid.natural_account_id,
          ccid.user_dim1_id,
          ccid.user_dim2_id,
          cat.flex_structure_id,
          cat.category_id,
          cat.major_id,
          cat.major_value,
          cat.minor_id,
          cat.minor_value,
          bc.book_type_code,
          dh.ASSET_ID,
          ad.asset_number,
          dh.DISTRIBUTION_ID,
          dh.CODE_COMBINATION_ID,
          lines.code_combination_id,
          'TRX',
          adj.adjustment_type,
          sum(nvl(lines.accounted_dr, 0)) - sum(nvl(lines.accounted_cr, 0)),
          sum(nvl(lines.accounted_dr, 0)) - sum(nvl(lines.accounted_cr, 0)),
          sysdate,
          g_fii_user_id,
          sysdate,
          g_fii_user_id,
          g_fii_login_id,
          nid.event_id,
          nid.ae_header_id
     from fii_fa_new_exp_hdr_ids   nid,
          xla_ae_lines             lines,
          fii_fa_acct_class_code_gt acls,
          fii_gl_ccid_dimensions   ccid,
          gl_ledgers_public_v      sob,
          gl_import_references     gir,
          xla_distribution_links   links,
          fa_adjustments           adj,
          fa_distribution_history  dh,
          fa_additions_b           ad,
          fa_asset_history         ah,
          fii_fa_cat_dimensions    cat,
          fa_deprn_periods         dp,
          fa_book_controls         bc
    where nid.record_id               between p_start_range and p_end_range
      and nid.event_type_code          not in ('DEPRECIATION', 'ROLLBACK_DEPRECIATION')
      and lines.ae_header_id                = nid.ae_header_id
      and lines.application_id              = 140
      and acls.accounting_class_code        = lines.accounting_class_code
      and acls.ledger_id                    = nid.ledger_id
      and gir.je_header_id                  = nid.je_header_id
      and gir.gl_sl_link_id                 = lines.gl_sl_link_id
      and ccid.code_combination_id          = lines.code_combination_id
      and sob.ledger_id                     = nid.ledger_id
      and links.ae_header_id                = lines.ae_header_id
      and links.ae_line_num                 = lines.ae_line_num
      and links.application_id              = 140
      and links.source_distribution_type    = 'TRX'
      and adj.transaction_header_id         = links.Source_distribution_id_num_1
      and adj.adjustment_line_id            = links.Source_distribution_id_num_2
      and dh.asset_id                       = ah.asset_id
      and ah.date_effective                <= dh.date_effective
      and nvl(ah.date_ineffective, sysdate + 1) > nvl(dh.date_ineffective, sysdate)
      and ah.transaction_header_id_in      <= dh.transaction_header_id_in
      and nvl(ah.transaction_header_id_out,
          nvl(dh.transaction_header_id_out + 1, 1)) >
          nvl(dh.transaction_header_id_out, 0)
      and dh.asset_id                       = ad.asset_id
      and ah.category_id                    = cat.category_id
      and dh.asset_id                       = adj.asset_id
      and dp.book_type_code                 = adj.book_type_code
      and dp.period_counter                 = adj.period_counter_created
      and dh.distribution_id                = adj.distribution_id
      and nvl(adj.track_member_flag,'N')    = 'N'
      and adj.adjustment_type              in ('EXPENSE', 'BONUS EXPENSE')
      and bc.book_type_code                 = dp.book_type_code
      and bc.set_of_books_id                = sob.ledger_id
 group by bc.set_of_books_id,
          dp.calendar_period_close_date,
          NULL,
          sob.currency_code,
          bc.accounting_flex_structure,
          ccid.company_id,
          ccid.cost_center_id,
          ccid.natural_account_id,
          ccid.user_dim1_id,
          ccid.user_dim2_id,
          cat.flex_structure_id,
          cat.category_id,
          cat.major_id,
          cat.major_value,
          cat.minor_id,
          cat.minor_value,
          bc.book_type_code,
          dh.ASSET_ID,
          ad.asset_number,
          dh.DISTRIBUTION_ID,
          dh.CODE_COMBINATION_ID,
          lines.code_combination_id,
          'TRX',
          adj.adjustment_type,
          sysdate,
          g_fii_user_id,
          g_fii_login_id,
          nid.event_id,
          nid.ae_header_id;



   if g_debug_flag = 'Y' then
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_fa_exp_f');
      fii_util.stop_timer;
      fii_util.print_timer('Duration');
   end if;

   commit;

   --Call FND_STATS to collect statistics after populating the table
/*
   g_phase := 'Calling FND_STATS to collect statistics for fii_fa_exp_f';
   FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'fii_fa_exp_f');
*/
   commit;

EXCEPTION
   WHEN OTHERS Then
        g_retcode := -1;
        FII_UTIL.put_line('
----------------------------
Error in Function: INSERT_INTO_SUMMARY
Phase: ' || g_phase || '
Message: '||sqlerrm);

        raise;

END INSERT_INTO_SUMMARY;



----------------------------------------
-- PROCEDURE Insert_Into_Summary_Par
--
-- NOTE: moves staging info into base summary
--       for Initial Mode
-----------------------------------------

PROCEDURE INSERT_INTO_SUMMARY_PAR IS

   l_stmt VARCHAR2(1000);

BEGIN

   -- R12: determine accounting classes
   GET_ACCT_CLASSES;

   if g_debug_flag = 'Y' then
      fii_util.put_line(' ');
      fii_util.put_line('Loading data into base summary table - catchup');
      fii_util.start_timer;
      fii_util.put_line('');
   end if;

/*+ append parallel(bsum) */

   insert
     into fii_fa_exp_f bsum
      (LEDGER_ID                   ,
       ACCOUNT_DATE                ,
       CURRENCY_CODE               ,
       CHART_OF_ACCOUNTS_ID        ,
       COMPANY_ID                  ,
       COST_CENTER_ID              ,
       NATURAL_ACCOUNT_ID          ,
       user_dim1_id                ,
       user_dim2_id                ,
       ASSET_CAT_FLEX_STRUCTURE_ID ,
       asset_CAT_ID                ,
       asset_cat_MAJOR_ID          ,
       asset_cat_MAJOR_VALUE       ,
       asset_cat_MINOR_ID          ,
       asset_cat_MINOR_VALUE       ,
       BOOK_TYPE_CODE              ,
       ASSET_ID                    ,
       ASSET_NUMBER                ,
       DISTRIBUTION_ID             ,
       DISTRIBUTION_CCID           ,
       EXPENSE_CCID                ,
       SOURCE_CODE                 ,
       DEPRN_TYPE                  ,
       AMOUNT_T                    ,
       AMOUNT_B                    ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN           ,
       XLA_EVENT_ID                ,
       XLA_AE_HEADER_ID
      )
   select bc.set_of_books_id,
          dp.calendar_period_close_date,
          sob.currency_code,
          bc.accounting_flex_structure,
          ccid.company_id,
          ccid.cost_center_id,
          ccid.natural_account_id,
          ccid.user_dim1_id,
          ccid.user_dim2_id,
          cat.flex_structure_id,
          cat.category_id,
          cat.major_id,
          cat.major_value,
          cat.minor_id,
          cat.minor_value,
          bc.book_type_code,
          dh.ASSET_ID,
          ad.asset_number,
          dh.DISTRIBUTION_ID,
          dh.CODE_COMBINATION_ID,
          lines.code_combination_id,
          'TRX',
          adj.adjustment_type,
          sum(nvl(lines.accounted_dr, 0)) - sum(nvl(lines.accounted_cr, 0)),
          sum(nvl(lines.accounted_dr, 0)) - sum(nvl(lines.accounted_cr, 0)),
          sysdate,
          g_fii_user_id,
          sysdate,
          g_fii_user_id,
          g_fii_login_id,
          headers.event_id,
          headers.ae_header_id
     from fii_fa_new_exp_hdr_ids   nid,
          gl_import_references     gir,
          fii_fa_acct_class_code_gt acls,
          xla_ae_lines             lines,
          xla_ae_headers           headers,
          fii_gl_ccid_dimensions   ccid,
          gl_ledgers_public_v      sob,
          xla_distribution_links   links,
          fa_adjustments           adj,
          fa_distribution_history  dh,
          fa_additions_b           ad,
          fa_asset_history         ah,
          fii_fa_cat_dimensions    cat,
          fa_deprn_periods         dp,
          fa_book_controls         bc
    where gir.je_header_id                  = nid.je_header_id
      and acls.ledger_id                    = nid.ledger_id
      and lines.application_id              = 140
      and lines.gl_sl_link_id               = gir.gl_sl_link_id
      and lines.accounting_class_code       = acls.accounting_class_code
      and headers.application_id            = 140
      and headers.ae_header_id              = lines.ae_header_id
      and headers.ledger_id                  = nid.ledger_id
      and headers.event_type_code       not in ('DEPRECIATION', 'ROLLBACK_DEPRECIATION', 'DEFERRED_DEPRECIATION')
      and sob.ledger_id                      = nid.ledger_id
      and ccid.code_combination_id           = lines.code_combination_id
      and links.application_id               = 140
      and links.source_distribution_type     = 'TRX'
      and links.ae_header_id                 = lines.ae_header_id
      and links.ae_line_num                  = lines.ae_line_num
      and adj.transaction_header_id          = links.Source_distribution_id_num_1
      and adj.adjustment_line_id             = links.Source_distribution_id_num_2
      and dh.asset_id                       = ah.asset_id
      and ah.date_effective                <= dh.date_effective
      and nvl(ah.date_ineffective, sysdate + 1) > nvl(dh.date_ineffective, sysdate)
      and ah.transaction_header_id_in      <= dh.transaction_header_id_in
      and nvl(ah.transaction_header_id_out,
          nvl(dh.transaction_header_id_out + 1, 1)) >
          nvl(dh.transaction_header_id_out, 0)
      and dh.asset_id                       = ad.asset_id
      and ah.category_id                    = cat.category_id
      and dh.asset_id                       = adj.asset_id
      and dp.book_type_code                 = adj.book_type_code
      and dp.period_counter                 = adj.period_counter_created
      and dh.distribution_id                = adj.distribution_id
      and nvl(adj.track_member_flag,'N')    = 'N'
      and adj.adjustment_type              in ('EXPENSE', 'BONUS EXPENSE')
      and dp.book_type_code                 = bc.book_type_code
      and bc.set_of_books_id                = sob.ledger_id
 group by bc.set_of_books_id,
          dp.calendar_period_close_date,
          NULL,
          sob.currency_code,
          bc.accounting_flex_structure,
          ccid.company_id,
          ccid.cost_center_id,
          ccid.natural_account_id,
          ccid.user_dim1_id,
          ccid.user_dim2_id,
          cat.flex_structure_id,
          cat.category_id,
          cat.major_id,
          cat.major_value,
          cat.minor_id,
          cat.minor_value,
          bc.book_type_code,
          dh.ASSET_ID,
          ad.asset_number,
          dh.DISTRIBUTION_ID,
          dh.CODE_COMBINATION_ID,
          lines.code_combination_id,
          'TRX',
          adj.adjustment_type,
          sysdate,
          g_fii_user_id,
          g_fii_login_id,
          headers.event_id,
          headers.ae_header_id;

   if g_debug_flag = 'Y' then
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_fa_exp_f');
      fii_util.stop_timer;
      fii_util.print_timer('Duration');
   end if;

   commit;


   -- R12: adding seperate insert for DD based amounts
   if g_debug_flag = 'Y' then
      fii_util.put_line(' ');
      fii_util.put_line('Loading data into base summary table - periodic deprn');
      fii_util.start_timer;
      fii_util.put_line('');
   end if;

   insert
     into fii_fa_exp_f bsum
      (LEDGER_ID                   ,
       ACCOUNT_DATE                ,
       CURRENCY_CODE               ,
       CHART_OF_ACCOUNTS_ID        ,
       COMPANY_ID                  ,
       COST_CENTER_ID              ,
       NATURAL_ACCOUNT_ID          ,
       user_dim1_id                ,
       user_dim2_id                ,
       ASSET_CAT_FLEX_STRUCTURE_ID ,
       asset_CAT_ID                ,
       asset_cat_MAJOR_ID          ,
       asset_cat_MAJOR_VALUE       ,
       asset_cat_MINOR_ID          ,
       asset_cat_MINOR_VALUE       ,
       BOOK_TYPE_CODE              ,
       ASSET_ID                    ,
       ASSET_NUMBER                ,
       DISTRIBUTION_ID             ,
       DISTRIBUTION_CCID           ,
       EXPENSE_CCID                ,
       SOURCE_CODE                 ,
       DEPRN_TYPE                  ,
       AMOUNT_T                    ,
       AMOUNT_B                    ,
       CREATION_DATE               ,
       CREATED_BY                  ,
       LAST_UPDATE_DATE            ,
       LAST_UPDATED_BY             ,
       LAST_UPDATE_LOGIN           ,
       XLA_EVENT_ID                ,
       XLA_AE_HEADER_ID
      )
   select bc.set_of_books_id,
          dp.calendar_period_close_date,
          sob.currency_code,
          bc.accounting_flex_structure,
          ccid.company_id,
          ccid.cost_center_id,
          ccid.natural_account_id,
          ccid.user_dim1_id,
          ccid.user_dim2_id,
          cat.flex_structure_id,
          cat.category_id,
          cat.major_id,
          cat.major_value,
          cat.minor_id,
          cat.minor_value,
          bc.book_type_code,
          dh.ASSET_ID,
          ad.asset_number,
          dh.DISTRIBUTION_ID,
          dh.CODE_COMBINATION_ID,
          lines.code_combination_id,
          'DEPRN',
          links.source_distribution_type,      --decode to this possibly?    was EXPENSE
          nvl(lines.accounted_dr, 0) - nvl(lines.accounted_cr, 0),
          nvl(lines.accounted_dr, 0) - nvl(lines.accounted_cr, 0),
          sysdate,
          g_fii_user_id,
          sysdate,
          g_fii_user_id,
          g_fii_login_id,
          headers.event_id,
          headers.ae_header_id
     from fii_fa_new_exp_hdr_ids  nid,
          gl_import_references    gir,
          fii_fa_acct_class_code_gt acls,
          xla_ae_lines            lines,
          xla_ae_headers          headers,
          fii_gl_ccid_dimensions  ccid,
          gl_ledgers_public_v     sob,
          xla_distribution_links  links,
          fa_deprn_detail         dd,
          fa_distribution_history dh,
          fa_additions_b          ad,
          fa_asset_history        ah,
          fii_fa_cat_dimensions   cat,
          fa_deprn_periods        dp,
          fa_book_controls        bc
    where gir.je_header_id                  = nid.je_header_id
      and acls.ledger_id                    = nid.ledger_id
      and lines.application_id              = 140
      and lines.gl_sl_link_id               = gir.gl_sl_link_id
      and lines.accounting_class_code       = acls.accounting_class_code
      and headers.application_id            = 140
      and headers.ae_header_id              = lines.ae_header_id
      and headers.event_type_code           = 'DEPRECIATION'
      and ccid.code_combination_id          = lines.code_combination_id
      and sob.ledger_id                     = nid.ledger_id
      and links.application_id              = 140
      and links.ae_header_id                = lines.ae_header_id
      and links.ae_line_num                 = lines.ae_line_num
      and dd.asset_id                       = links.Source_distribution_id_num_1
      and dd.distribution_id                = links.Source_distribution_id_num_5
      and dd.deprn_run_id                   = links.Source_distribution_id_num_3
      and dd.book_type_code                 = links.Source_distribution_id_char_4
      and dd.period_counter                 = links.Source_distribution_id_num_2
      and dd.distribution_id                = dh.distribution_id
      and ad.asset_id                       = dh.asset_id
      and ah.asset_id                       = dh.asset_id
      and ah.date_effective                <= dh.date_effective
      and nvl(ah.date_ineffective, sysdate + 1) > nvl(dh.date_ineffective, sysdate)
      and ah.transaction_header_id_in      <= dh.transaction_header_id_in
      and nvl(ah.transaction_header_id_out,
          nvl(dh.transaction_header_id_out + 1, 1)) >
          nvl(dh.transaction_header_id_out, 0)
      and cat.category_id                   = ah.category_id
      and dp.book_type_code                 = dd.book_type_code
      and dp.period_counter                 = dd.period_counter
      and bc.book_type_code                 = dp.book_type_code
      and bc.set_of_books_id                = sob.ledger_id
      and headers.ae_header_id not in
          (select /*+ hash_aj parallel(headers2, ev_rb, ev_dep) */
                  headers2.ae_header_id
             from xla_ae_headers          headers2,
                  xla_events              ev_rb,
                  xla_events              ev_dep
            where headers2.application_id  = 140
              and headers2.event_type_code = 'DEPRECIATION'
              and ev_dep.event_id          = headers2.event_id
              and ev_dep.application_id    = 140
              and ev_rb.entity_id          = ev_dep.entity_id
              and ev_rb.application_id     = 140
              and ev_rb.event_id           > ev_dep.event_id);

   if g_debug_flag = 'Y' then
      fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_fa_exp_f');
      fii_util.stop_timer;
      fii_util.print_timer('Duration');
   end if;

   commit;


   --per DBI, no need to Call FND_STATS to collect statistics after populating the table


EXCEPTION
   WHEN OTHERS Then
        g_retcode := -1;
        FII_UTIL.put_line('
----------------------------
Error in Function: Insert_Into_Summary_Par
Phase: ' || g_phase || '
Message: '||sqlerrm);

        raise;

END INSERT_INTO_SUMMARY_PAR;



-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

PROCEDURE Main (errbuf              IN OUT NOCOPY VARCHAR2,
                retcode             IN OUT NOCOPY VARCHAR2,
                p_number_of_process IN      NUMBER,
                p_worker_num        IN      NUMBER,
                p_program_type      IN      VARCHAR2,
                p_parallel_query    IN      NUMBER,
                p_sort_area_size    IN      NUMBER,
                p_hash_area_size    IN      NUMBER) IS

   return_status        BOOLEAN := TRUE;
   p_number_of_rows     NUMBER  := 0;
   p_no_worker          NUMBER  := 1;
   l_conversion_count   NUMBER  := 0;
   l_retcode            VARCHAR2(3);
   l_errbuf             VARCHAR2(500);
   l_stmt               VARCHAR2(300);
   l_dir                VARCHAR2(100);
   l_ids_count          NUMBER  := 0;
   stg_count            NUMBER  := 0;
   l_truncate_stg       BOOLEAN := FALSE;

   -- used fort paralization - new method
   l_unassigned_cnt       NUMBER := 0;
   l_failed_cnt           NUMBER := 0;
   l_wip_cnt              NUMBER := 0;
   l_completed_cnt        NUMBER := 0;
   l_total_cnt            NUMBER := 0;
   l_count                NUMBER := 0;
   l_start_range          NUMBER := 0;
   l_end_range            NUMBER := 0;

   l_global_start_date  DATE;
   l_global_param_list dbms_sql.varchar2_table;
   L_PERIOD_START_DATE  date;
   L_PERIOD_END_DATE    date;

   TYPE WorkerList is table of NUMBER
        index by binary_integer;
   l_worker             WorkerList;

   l_slg_chg            VARCHAR2(10);
   l_prd_chg            VARCHAR2(10);

   l_ret_val            BOOLEAN;
   l_ret_code           VARCHAR2(30);

BEGIN

   errbuf  := NULL;
   retcode := 0;

   g_fii_user_id  := FND_GLOBAL.User_Id;
   g_fii_login_id := FND_GLOBAL.Login_Id;

   IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
      RAISE G_LOGIN_INFO_NOT_AVABLE;
   END IF;

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('User ID: ' || g_fii_user_id || '  Login ID: ' || g_fii_login_id);
   end if;

   g_program_type := p_program_type;
   -----------------------------------------------
   -- Do the necessary setups for logging and
   -- output
   -----------------------------------------------
   l_dir := FII_UTIL.get_utl_file_dir;

   ------------------------------------------------
   -- Initialize API will fetch the FII_DEBUG_MODE
   -- profile option and intialize g_debug variable
   -- accordingly.  It will also read in profile
   -- option BIS_DEBUG_LOG_DIRECTORY to find out
   -- the log directory
   ------------------------------------------------
   g_phase := 'Calling FII_UTIL.initialize';
   IF g_program_type = 'I'  THEN
      FII_UTIL.initialize('FII_FA_EXP_SUM.log','FII_FA_EXP_SUM.out',l_dir, 'FII_FA_EXP_B_C');
   ELSIF g_program_type = 'L'  THEN
      FII_UTIL.initialize('FII_FA_EXP_SUM.log','FII_FA_EXP_SUM.out',l_dir, 'FII_FA_EXP_F_L');
   END IF;


   ------------------------------------------------
   -- For initial mode, always 1 process...
   -- For incremental mode:
   --  Determine whether this is parent / child,etc
   ------------------------------------------------
   if (g_program_type = 'I') then

      g_number_of_process := nvl(p_number_of_process, 1);
      g_worker_num        := nvl(p_worker_num, 1);

      if (nvl(p_number_of_process, 1) = 1) then

         G_sole   := TRUE;
         G_child  := FALSE;

      elsif (nvl(p_number_of_process, 1) > 1 and
             p_worker_num is null) then

         G_parent := TRUE;
         G_child  := FALSE;

      else

         G_child  := TRUE;
         G_sole   := FALSE;
         G_parent := FALSE;

      end if;

   else

         G_child  := FALSE;
         G_sole   := TRUE;
         G_parent := FALSE;

   end if;


   -----------------------------------------------------
   -- only process the main checks, etc if this is sole
   -- or parent request
   -----------------------------------------------------
   if (G_sole or G_parent) then

      -----------------------------------------------------
      -- Calling BIS API to do common set ups
      -- If it returns false, then program should error out
      -----------------------------------------------------
      g_phase                := 'Calling BIS API to do common set ups';
      l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
      l_global_param_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
      l_global_param_list(3) := 'BIS_PRIMARY_RATE_TYPE';

      IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
         FII_MESSAGE.write_log   (msg_name   => 'FII_BAD_GLOBAL_PARA',
                                  token_num  => 0);
         FII_MESSAGE.write_output(msg_name   => 'FII_BAD_GLOBAL_PARA',
                                  token_num  => 0);

         l_ret_val := FND_CONCURRENT.Set_Completion_Status(
             status  => 'ERROR',
             message => 'One of the three global parameters: Global Start Date; Primary Currency Code; Primary Rate Type has not been set up.'
         );

         return;
      ELSIF g_program_type = 'I'  THEN
         IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_FA_EXP_B_C')) THEN
            raise_application_error(-20000,errbuf);
            return;
         END IF;
      ELSIF g_program_type = 'L'  THEN
         IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_FA_EXP_F_L')) THEN
            raise_application_error(-20000,errbuf);
            return;
         END IF;
      END IF;

      ------------------------------------------------
      -- Initialize other setups
      ------------------------------------------------
      g_phase := 'Calling INIT';
      INIT();

      ------------------------------------------------
      -- If running in Initial Load mode, truncate
      -- everything before starts.
      ------------------------------------------------
      IF g_program_type = 'L' THEN

         IF g_debug_flag = 'Y' then
            FII_UTIL.put_line('Running in Initial Load mode, truncate STG, summary and other processing tables.');
         END IF;

         FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_EXP_T',
                                 P_RETCODE    => l_ret_code);

         FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_EXP_F',
                                 P_RETCODE    => l_ret_code);

         FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_EXP_HDR_IDS',
                                 P_RETCODE    => l_ret_code);

         FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_NEW_EXP_HDR_IDS',
                                 P_RETCODE    => l_ret_code);


         COMMIT;
      END IF;

      ------------------------------------------
      -- Check setups only if we are running in
      -- Incremental Mode, g_program_type = 'I'
      ------------------------------------------
      IF (g_program_type = 'I') THEN
         ---------------------------------------------
         -- Check if any set up got changed.  If yes,
         -- then we need to truncate the summary table
         -- and then reload (also see bug 3401590)
         --
         -- FA doesn't need a check PRD change,
         -- just the SLG check
         ---------------------------------------------
         g_phase := 'Check setups if we are running in Incremental Mode';

         l_slg_chg := CHECK_IF_SLG_SET_UP_CHANGE;
         -- l_prd_chg := CHECK_IF_PRD_SET_UP_CHANGE;

         -- should fail the program if either slg or prd changed
         IF (l_slg_chg = 'TRUE') THEN
            FII_MESSAGE.write_output (msg_name  => 'FII_TRUNC_SUMMARY', token_num => 0);
            FII_MESSAGE.write_log    (msg_name  => 'FII_TRUNC_SUMMARY', token_num => 0);
            --FII_UTIL.put_line('Source Ledger Group setup has changed. Please run the Request Set in the Initial mode to repopulate the summaries.');
            retcode := -1;
            RETURN;
         END IF;

      ELSIF (g_program_type = 'L') THEN
         ---------------------------------------------
         -- If running in Inital Load, then update
         -- change log to indicate that resummarization
         -- is not necessary since everything is
         -- going to be freshly loaded
         --
         -- FA will only be using the resummarize log
         -- item, not product change since we can handle
         -- new books, etc
         ---------------------------------------------
         g_phase := 'Update fii_change_log if we are running in Inital Load';

         UPDATE fii_change_log
            SET item_value = 'N',
                last_update_date  = SYSDATE,
                last_update_login = g_fii_login_id,
                last_updated_by   = g_fii_user_id
          WHERE log_item = 'FA_RESUMMARIZE'
            AND item_value = 'Y';

         COMMIT;

      END IF;

      -------------------------------------------------
      -- Print out useful date range information
      -- FA will not use start and end date ranges
      -- as we only need the global start date
      -------------------------------------------------
      g_phase := 'Get date range information';

      l_global_start_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');
      g_global_start_date := l_global_start_date;

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('BIS Global Start Date: ' || l_global_start_date);
      end if;

      ----------------------------------------------------------
      -- FA DOES NOT need to Determine if we need to resume.
      ----------------------------------------------------------

      g_phase := 'g_resume_flag = N';

      ----------------------------------------------------------
      -- This variable indicates that if exception occur, do
      -- we need to truncate the staging table.
      -- We are about to submit the child process which will
      -- insert records into staging table.  If any exception
      -- occured during the child process run, the staging table
      -- should be truncated.  After all child process are done
      -- inserting records into staging table, this flag will
      -- be set to FALSE.
      ----------------------------------------------------------
      g_truncate_stg := TRUE;

      ----------------------------------------------------------
      -- This variable indicates that if exception occur, do
      -- we need to truncate the temporary ID table.
      -- We need to truncate this table if the program starts
      -- fresh at the beginning.
      -- We will reset this variable to FALSE after we have
      -- populate it.  We will not truncate it until next time
      -- when the program starts fresh (non-resume).  We want
      -- to preserve this table for debugging purpose.
      ----------------------------------------------------------
      g_truncate_id := TRUE;

      --------------------------------------------------------------
      -- Calling CLEAN_UP procedure to clean up all processing
      -- tables
      --------------------------------------------------------------
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('');
         FII_UTIL.put_line('Cleaning up processing tables before actual processing start');
         FII_UTIL.put_line('------------------------------------------------------------');
      end if;

      -- hold off *** testing parallel ****
      CLEAN_UP;

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('------------------------------------------------------------');
         FII_UTIL.put_line('');
      end if;

      ---------------------------------------------------------
      -- After we do initial clean up, we will set this flag to
      -- FALSE to preserve the temporary Revenue ID table for
      -- debugging purpose
      ---------------------------------------------------------
      g_truncate_id := FALSE;

      ---------------------------------------------------------------
      -- Call New_Journals routine to insert Journal header ids into
      -- FII_FA_NEW_EXP_HDR_IDS
      ----------------------------------------------------------------
      g_phase := 'Identify New Journal Headers to process';
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

      --------------------------------------------------------
      -- NEW_JOURNALS will identify the new journals which
      -- need to be processed based on the user entered
      -- date range.  If there are no new journals to process
      -- the program will exit immediately with complete
      -- successful status
      --------------------------------------------------------
      l_ids_count := NEW_JOURNALS(l_period_start_date,
                                  l_period_end_date);

      IF (l_ids_count = 0) THEN
         -- purge the new ids table for deleted lines
         FII_UTIL.TRUNCATE_TABLE(p_table_name => 'FII_FA_NEW_EXP_HDR_IDS',
                                 P_RETCODE    => l_ret_code);

         if g_debug_flag = 'Y' then
            FII_UTIL.put_line('No Journal Entries to Process, exit.');
         end if;
         RETURN;
      END IF;

      ----------------------------------------------------------------
      -- After the new journals are identified, we need to call the
      -- CAT ID API to make sure that the CAT dimension is up to date.
      --
      -- OPEN Issue - do we need this for GL CCID????
      -- The reason we call this API after we have identified the
      -- new journals instead of calling this API at the beginning of
      -- the programs is because that it is possible that after we
      -- called the API, new CCIDs are created by new journals, and
      -- then we will pull this new journal in the New_Journals API
      -- and subsequently treat this new journal as processed even
      -- though it is not processed because its corresponding CCID
      -- is missing in the CCID dimension.
      -- If CCID dimension is not up to date, VERIFY_CCID_UP_TO_DATE
      -- will also call the CCID Dimension load program to update
      -- CCID dimension.
      --
      ----------------------------------------------------------------
      g_phase := 'Verifying if CCID Dimension is up to date';
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

      VERIFY_CAT_ID_UP_TO_DATE;

      g_phase := 'Verifying if all FA periods have been upgraded for XLA';
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

      CHECK_XLA_CONVERSION_STATUS;

       ----------------------------------------------------------------
      -- Register jobs in the table FII_FA_WORKER_JOBS for launching
      -- child processes - needed for both parallel and sole for incremental
      ----------------------------------------------------------------

      if (p_program_type = 'I') then
         g_phase := 'Calling Routine Register_Jobs for incremental mode';

         if g_debug_flag = 'Y' then
            FII_UTIL.put_line(g_phase);
         end if;

         Register_Jobs();

         COMMIT;
      end if;

      ----------------------------------------------------------------
      -- Launching child processes if this is parent not sole
      ----------------------------------------------------------------
      if (G_parent) then

         g_phase := 'In G_Parent Logic...';

         if g_debug_flag = 'Y' then
            FII_UTIL.put_line(g_phase);
         end if;

         ----------------------------------------------------------------
         -- Launching child processes.
         ----------------------------------------------------------------
         g_phase     := 'Launching child process...';
         p_no_worker := p_number_of_process;

         -- Launch child process
         LAUNCH_WORKERS(p_number_of_process);

         -- Monitor Child process after launching them

         DECLARE

            l_unassigned_cnt       NUMBER := 0;
            l_completed_cnt        NUMBER := 0;
            l_wip_cnt              NUMBER := 0;
            l_failed_cnt           NUMBER := 0;
            l_tot_cnt              NUMBER := 0;
            l_last_unassigned_cnt  NUMBER := 0;
            l_last_completed_cnt   NUMBER := 0;
            l_last_wip_cnt         NUMBER := 0;
            l_cycle                NUMBER := 0;

         BEGIN
            g_phase := 'Waiting for child process to complete';
            LOOP
               SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
                      NVL(sum(decode(status,'COMPLETED',1,0)),0),
                      NVL(sum(decode(status,'IN PROCESS',1,0)),0),
                      NVL(sum(decode(status,'FAILED',1,0)),0),
                      count(*)
                 INTO l_unassigned_cnt,
                      l_completed_cnt,
                      l_wip_cnt,
                      l_failed_cnt,
                      l_tot_cnt
                 FROM FII_FA_WORKER_JOBS;

               if g_debug_flag = 'Y' then
                  FII_UTIL.put_line('Job status - Unassigned:'||l_unassigned_cnt||
                                    ' In Process:'||l_wip_cnt||
                                    ' Completed:'||l_completed_cnt||
                                    ' Failed:'||l_failed_cnt);
               end if;

               IF (l_failed_cnt > 0) THEN
                  g_retcode := -1;
                  FII_UTIL.put_line('
---------------------------------
Error in Main Procedure:
Message: At least one of the workers have errored out');
                  RAISE G_CHILD_PROCESS_ISSUE;
               END IF;

               -- --------------------------------------------
               -- IF the number of complete count equals to
               -- the total count, then that means all workers
               -- have completed.  Then we can exit the loop
               -- --------------------------------------------
               IF (l_tot_cnt = l_completed_cnt) THEN
                  if g_debug_flag = 'Y' then
                     FII_UTIL.put_line ('All jobs have completed');
                  end if;
                  EXIT;
               END IF;

               -------------------------
               -- Detect infinite loops
               -------------------------
               IF (l_unassigned_cnt = l_last_unassigned_cnt AND
                   l_completed_cnt = l_last_completed_cnt AND
                   l_wip_cnt = l_last_wip_cnt) THEN
                  l_cycle := l_cycle + 1;
               ELSE
                  l_cycle := 1;
               END IF;

               -----------------------------------------
               -- MAX_LOOP is a global variable you set.
               -- It represents the number of minutes
               -- you want to wait for each worker to
               -- complete.  We can set it to 30 minutes
               -- for now
               -----------------------------------------
               IF (l_cycle > MAX_LOOP) THEN
                  g_retcode := -1;
                  FII_UTIL.put_line('
---------------------------------
Error in Main Procedure:
Message: No progress have been made for '||MAX_LOOP||' minutes.
Terminating');
                  RAISE G_CHILD_PROCESS_ISSUE;
               END IF;

               -------------------------
               -- Sleep 60 Seconds
               -------------------------
               dbms_lock.sleep(60);

               l_last_unassigned_cnt := l_unassigned_cnt;
               l_last_completed_cnt  := l_completed_cnt;
               l_last_wip_cnt        := l_wip_cnt;
            END LOOP;
         END;   -- Monitor child process BLOCK Ends here.

      END IF;  -- end if parent

   END IF; -- end parent / sole


   -----------------------------------------------------------------
   -- assign work to the child workers or to the worker if not
   -- submitted in parallel
   -----------------------------------------------------------------
   IF (p_program_type = 'I' and
       (G_sole or G_child)) THEN

      g_phase := 'In G_Sole / G_Child Logic...';

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

      l_stmt := ' ALTER SESSION SET global_names = false';
      EXECUTE IMMEDIATE l_stmt;

      FII_UTIL.initialize;

      -- R12: determine accounting classes
      GET_ACCT_CLASSES;

      -- ------------------------------------------
      -- Loop thru job list
      -- -----------------------------------------
      g_phase := 'Loop thru job list';
      LOOP
         SELECT NVL(sum(decode(status,'UNASSIGNED', 1, 0)),0),
                NVL(sum(decode(status,'FAILED', 1, 0)),0),
                NVL(sum(decode(status,'IN PROCESS', 1, 0)),0),
                NVL(sum(decode(status,'COMPLETED',1 , 0)),0),
                count(*)
         INTO   l_unassigned_cnt,
                l_failed_cnt,
                l_wip_cnt,
                l_completed_cnt,
                l_total_cnt
         FROM   FII_FA_WORKER_JOBS;

         if g_debug_flag = 'Y' then
            FII_UTIL.put_line('Job status - Unassigned: '||l_unassigned_cnt||
                              ' In Process: '||l_wip_cnt||
                              ' Completed: '||l_completed_cnt||
                              ' Failed: '||l_failed_cnt||
                              ' Total: '|| l_total_cnt);
         end if;

         IF (l_failed_cnt > 0) THEN
            if g_debug_flag = 'Y' then
               FII_UTIL.put_line('');
               FII_UTIL.put_line('Another worker have errored out.  Stop processing.');
            end if;
            EXIT;
         ELSIF (l_unassigned_cnt = 0) THEN
            if g_debug_flag = 'Y' then
               FII_UTIL.put_line('');
               FII_UTIL.put_line('No more jobs left.  Terminating.');
            end if;
            EXIT;
         ELSIF (l_completed_cnt = l_total_cnt) THEN
            if g_debug_flag = 'Y' then
               FII_UTIL.put_line('');
               FII_UTIL.put_line('All jobs completed, no more job.  Terminating');
            end if;
            EXIT;
         ELSIF (l_unassigned_cnt > 0) THEN
            UPDATE FII_FA_WORKER_JOBS
            SET    status = 'IN PROCESS',
                   worker_number = g_worker_num
            WHERE  status = 'UNASSIGNED'
            AND    rownum < 2;
            if g_debug_flag = 'Y' then
               FII_UTIL.put_line('Taking job from job queue');
               FII_UTIL.put_line('count: ' || sql%rowcount);
            end if;
            l_count := sql%rowcount;
            COMMIT;
         END IF;

         -- -----------------------------------
         -- There could be rare situations where
         -- between Section 30 and Section 50
         -- the unassigned job gets taken by
         -- another worker.  So, if unassigned
         -- job no longer exist.  Do nothing.
         -- -----------------------------------
         IF (l_count > 0) THEN
            DECLARE
            BEGIN
               g_phase := 'Getting ID range from FII_FA_WORKER_JOBS table';

               if g_debug_flag = 'Y' then
                  FII_UTIL.put_line(g_phase);
               end if;

               SELECT start_range,
                      end_range
               INTO l_start_range,
                    l_end_range
               FROM FII_FA_WORKER_JOBS
               WHERE worker_number = g_worker_num
               AND  status = 'IN PROCESS';

               --------------------------------------------------
               --  Do summarization using the start_range
               --  and end_range call the summarization routine
               --  Passing start range and end range parameters
               --------------------------------------------------
               g_phase := 'Inserting into summary table';
               if g_debug_flag = 'Y' then
                  FII_UTIL.put_line(g_phase);
               end if;

               INSERT_INTO_SUMMARY(l_start_range,
                                   l_end_range);

               --------------------------------------------------
               --  Delete any rolled back entries
               --------------------------------------------------

               DELETE_FROM_BASE_SUMMARY(l_start_range,
                                        l_end_range);

               -----------------------------------------------------
               -- Do other work if necessary to finish the child
               -- process
               -- After completing the work, set the job status
               -- to complete
               -----------------------------------------------------
               g_phase:='Updating job status in FII_FA_WORKER_JOBS table';
               if g_debug_flag = 'Y' then
                  FII_UTIL.put_line(g_phase);
               end if;

               UPDATE FII_FA_WORKER_JOBS
               SET    status = 'COMPLETED'
               WHERE  status = 'IN PROCESS'
               AND    worker_number = g_worker_num;

               COMMIT;

               --   Handle any exception that occured during
               --   your child process

            EXCEPTION
               WHEN OTHERS THEN
                    g_retcode := -1;

                    UPDATE FII_FA_WORKER_JOBS
                    SET  status = 'FAILED'
                    WHERE  worker_number = g_worker_num
                    AND   status = 'IN PROCESS';

                    COMMIT;
                    Raise;
            END;

         END IF; /* IF (l_count> 0) */

      END LOOP;

      -- FA is not using this for now, commenting out per Renu
      -- INSERT_INTO_RATES;

   ELSIF (p_program_type = 'L') THEN
      --------------------------------------------------
      -- this is a sole request in initial mode
      --  Do summarization using the start_range
      --  and end_range call the summarization routine
      --  Passing start range and end range parameters
      --------------------------------------------------
      g_phase := 'Inserting into staging table';
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

   END IF;  -- child or sole


   IF g_parent or G_sole THEN

      g_phase := 'In G_Parent / G_Sole...';

      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

      -----------------------------------------------------------------
      -- If all the child process completes successfully then Invoke
      -- Summary_err_check routine to check for any missing rates record
      -- or missing time dimension record in the fii_fa_exp_t
      -- table.
      -----------------------------------------------------------------
      g_phase:= 'Summarization Error Check';
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line(g_phase);
      end if;

      Summary_err_check;

      IF (g_missing_rates = 0 AND g_missing_time = 0) THEN

         -------------------------------------------------------------
         -- Setting g_truncate_stg to TRUE because during the subsequent
         -- processes, if failure occurs, we should truncate staging
         ---------------------------------------------------------------
         g_truncate_stg := TRUE;

         -------------------------------------------------------------
         -- Call Summarization_aggreagte routine to insert from
         -- the staging table to the base summary
         --
         -- NOTE: only doing this for initial as incremental for
         --       now will go directly into the summary table
         -------------------------------------------------------------
         g_phase := 'Aggregating summarized data';
         if g_debug_flag = 'Y' then
            FII_UTIL.put_line('');
            FII_UTIL.put_line(g_phase);
         end if;

         if (g_program_type = 'L') then
            INSERT_INTO_SUMMARY_PAR;
         end if;

         -----------------------------------------------------------------
         -- If Merge routine returns true then Insert processed rows into
         -- FII_FA_PROCESSED_HDR_IDS table by calling the routine
         -- Jornals_processed.
         -----------------------------------------------------------------
         g_phase := 'Inserting processed JE Header IDs';
         if g_debug_flag = 'Y' then
            FII_UTIL.put_line('');
            FII_UTIL.put_line(g_phase);
         end if;

         Journals_processed;

         COMMIT;

         ------------------------------------------------------------------
         -- Cleaning phase
         -- Truncate staging summary table if all the processes completed
         -- successfully.
         ------------------------------------------------------------------
         -- ****  hold off for testing ****
         Clean_up;

         ----------------------------------------------------------------
         -- Calling BIS API to record the range we collect.  Only do this
         -- when we have a successful collection
         ----------------------------------------------------------------
         BIS_COLLECTION_UTILITIES.wrapup(p_status      => TRUE,
                                         p_period_from => l_period_start_date,
                                         p_period_to   => l_period_end_date);

         -- end in warning if any non-sla-upgraded data exists
         if (g_non_upgraded_ledgers) then
           retcode := 1;
         else
           retcode := 0;
         end if;

      ELSE

         retcode := g_retcode;
         errbuf  := 'There is missing rate or missing time information';

      END IF; --g_missing_rates = 0 AND g_missing_time = 0

   END IF;  -- parent or sole

Exception
   WHEN G_LOGIN_INFO_NOT_AVABLE THEN
        g_retcode := -1;
        FII_UTIL.put_line('Init: can not get User ID and Login ID, program exits');
        retcode := g_retcode;


  WHEN OTHERS Then
    g_retcode := -1;
    -- ****
    --
    -- temporarily removing this in order to test child perf
    -- via scripts
    clean_up;
    FII_UTIL.put_line('
Error in Function: Main
Phase: '|| g_phase || '
Message: ' || sqlerrm);
    retcode := g_retcode;

END Main;


END FII_FA_EXP_B_C;

/
