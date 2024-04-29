--------------------------------------------------------
--  DDL for Package Body FII_GL_JE_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_JE_B_C" AS
/*$Header: FIIGL03B.pls 120.82 2007/12/18 02:45:35 wywong ship $*/

 g_retcode              VARCHAR2(20) := NULL;
 g_sob_id               NUMBER := NULL;
 g_from_date            DATE;
 g_to_date              DATE;
 g_lud_from_date        DATE := NULL;
 g_lud_to_date          DATE := NULL;
 g_has_lud              BOOLEAN := FALSE;
 g_fii_schema           VARCHAR2(30);
 g_prim_currency        VARCHAR2(10);
 g_sec_currency         VARCHAR2(10);
 g_prim_rate_type       VARCHAR2(30);
 g_sec_rate_type        VARCHAR2(30);
 g_prim_rate_type_name  VARCHAR2(30);
 g_sec_rate_type_name   VARCHAR2(30);
 g_primary_mau          NUMBER;
 g_secondary_mau        NUMBER;
 g_worker_num           NUMBER;
 g_phase                VARCHAR2(100);
 g_resume_flag          VARCHAR2(1):= 'N';
 g_child_process_size   NUMBER := 20000;
 g_missing_rates        NUMBER := 0;
 g_missing_time         NUMBER := 0;
 g_fii_user_id		    	   NUMBER(15);
 g_fii_login_id         NUMBER(15);
 g_truncate_stg         BOOLEAN;
 g_truncate_id          BOOLEAN;
 g_debug_flag           VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
 g_program_type         VARCHAR2(1);
 g_industry             VARCHAR2(1) := NVL(FND_PROFILE.value('Industry'), 'C');
 g_global_start_date    DATE := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');

 ONE_SECOND    CONSTANT NUMBER := 0.000011574;  -- 1 second
 INTERVAL      CONSTANT NUMBER := 4;            -- 4 days
 MAX_LOOP      CONSTANT NUMBER := 180;          -- 180 loops = 180 minutes
 LAST_PHASE    CONSTANT NUMBER := 3;

 G_TABLE_NOT_EXIST      EXCEPTION;
 G_NO_CHILD_PROCESS     EXCEPTION;
 G_CHILD_PROCESS_ISSUE  EXCEPTION;
 G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;
 G_CCID_FAILED          EXCEPTION;
 G_MISSING_ENCUM_MAPPING EXCEPTION;

 PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

 g_usage_code CONSTANT VARCHAR2(10) := 'DBI';

-- ---------------------------------------------------------------
-- Private procedures and Functions;
-- ---------------------------------------------------------------


-- ---------------------------------------------------------------
-- PROCEDURE REPORT_MISSING_RATES
-- ---------------------------------------------------------------
PROCEDURE REPORT_MISSING_RATES IS
    TYPE cursorType is  REF CURSOR;

    l_stmt	VARCHAR2(500);
    l_count	NUMBER;
    l_curr	CURSORTYPE;

/*
--bug 3677737: use least(sysdate, effective_date) to replace effective_date
    cursor PrimMissingRate is
       SELECT DISTINCT
       functional_currency,
       decode( prim_conversion_rate,
	 	-3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
		least(sysdate, effective_date)) effective_date
       FROM   fii_gl_je_summary_stg
       WHERE  prim_conversion_rate < 0;

--bug 3677737: use least(sysdate, effective_date) to replace effective_date
    cursor SecMissingRate is
       SELECT DISTINCT
       functional_currency,
       decode( sec_conversion_rate,
		-3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
		least(sysdate, effective_date) ) effective_date
       FROM   fii_gl_je_summary_stg
       WHERE  sec_conversion_rate < 0;
*/
    cursor PSMissingRate is
       SELECT DISTINCT
       functional_currency,
       CASE WHEN prim_conversion_rate < 0 THEN
       decode( prim_conversion_rate,
        -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
        least(sysdate, effective_date))
       ELSE NULL END prim_effective_date,
       CASE WHEN sec_conversion_rate < 0 THEN
       decode( sec_conversion_rate,
		-3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
		least(sysdate, effective_date))
       ELSE NULL END sec_effective_date
       FROM   fii_gl_je_summary_stg
       WHERE  prim_conversion_rate < 0
          OR  sec_conversion_rate < 0;

BEGIN

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

/*
    FOR rate_record in PrimMissingRate  LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
      g_prim_rate_type_name,
      rate_record.functional_currency,
      g_prim_currency,
      rate_record.effective_date);
    END LOOP;

    FOR rate_record in SecMissingRate  LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
      g_sec_rate_type_name,
      rate_record.functional_currency,
      g_sec_currency,
      rate_record.effective_date);
    END LOOP;
*/
    FOR rate_record in PSMissingRate LOOP

     IF rate_record.prim_effective_date IS NOT NULL THEN
      BIS_COLLECTION_UTILITIES.writemissingrate(
      g_prim_rate_type_name,
      rate_record.functional_currency,
      g_prim_currency,
      rate_record.prim_effective_date);
     END IF;

     IF rate_record.sec_effective_date IS NOT NULL THEN
      BIS_COLLECTION_UTILITIES.writemissingrate(
      g_sec_rate_type_name,
      rate_record.functional_currency,
      g_sec_currency,
      rate_record.sec_effective_date);
     END IF;

    END LOOP;

    FND_FILE.CLOSE;

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

-- ---------------------------------------------------------------
-- PROCEDURE REPORT_MISSING_RATES_L
-- ---------------------------------------------------------------
PROCEDURE REPORT_MISSING_RATES_L IS
    TYPE cursorType is  REF CURSOR;

    l_stmt	VARCHAR2(500);
    l_count	NUMBER;
    l_curr	CURSORTYPE;

--bug 3677737: use least(sysdate, trx_date) to replace trx_date
    cursor PrimMissingRate is
       SELECT DISTINCT
       functional_currency,
       decode( prim_conversion_rate,
		-3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
		least(sysdate, trx_date) ) trx_date
       FROM   fii_gl_revenue_rates_temp
       WHERE  prim_conversion_rate < 0;

--bug 3677737: use least(sysdate, trx_date) to replace trx_date
    cursor SecMissingRate is
       SELECT DISTINCT
       functional_currency,
       decode( sec_conversion_rate,
		-3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
		least(sysdate, trx_date) ) trx_date
       FROM   fii_gl_revenue_rates_temp
       WHERE  sec_conversion_rate < 0;

BEGIN

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
      rate_record.functional_currency,
      g_prim_currency,
      rate_record.trx_date);
    END LOOP;

    FOR rate_record in SecMissingRate  LOOP
      BIS_COLLECTION_UTILITIES.writemissingrate(
      g_sec_rate_type_name,
      rate_record.functional_currency,
      g_sec_currency,
      rate_record.trx_date);
    END LOOP;

    FND_FILE.CLOSE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    g_retcode:=-1;
    if g_debug_flag = 'Y' then
    FII_UTIL.put_line('
---------------------------------------------------
Error in Procedure: REPORT_MISSING_RATES_L
Phase: '||g_phase||'
Message: Should have missing rates but found none');
    end if;
    raise;
  WHEN OTHERS THEN
    g_retcode := -1;
    if g_debug_flag = 'Y' then
    FII_UTIL.put_line('
---------------------------------
Error in Procedure: REPORT_MISSING_RATES_L
Phase: '||g_phase||'
Message: '||sqlerrm);
    end if;
    raise;
END REPORT_MISSING_RATES_L;

-----------------------------------------------------------
-- PROCEDURE DROP_TABLE
-----------------------------------------------------------
PROCEDURE Drop_Table (p_table_name in varchar2) is
    l_stmt varchar2(400);

Begin

    l_stmt:='drop table '||g_fii_schema||'.'|| p_table_name;

   if g_debug_flag = 'Y' then
    FII_UTIL.put_line('');
    FII_UTIL.put_line(l_stmt);
   end if;

    execute immediate l_stmt;

Exception
  WHEN G_TABLE_NOT_EXIST THEN
    NULL;      -- Oracle 942, table does not exist, no actions
  WHEN OTHERS THEN
    g_retcode := -1;
    if g_debug_flag = 'Y' then
    FII_UTIL.put_line('
---------------------------------
Error in Procedure: DROP_TABLE
Message: '||sqlerrm);
    end if;
    RAISE;
End Drop_Table;

-----------------------------------------------------------------------
-- PROCEDURE TRUNCATE_TABLE
-----------------------------------------------------------------------
PROCEDURE TRUNCATE_TABLE (p_table_name in varchar2) is
    l_stmt varchar2(400);

Begin

    l_stmt:='truncate table '||g_fii_schema||'.'|| p_table_name;

   if g_debug_flag = 'Y' then
    FII_UTIL.put_line('');
    FII_UTIL.put_line(l_stmt);
   end if;

    execute immediate l_stmt;

Exception
  WHEN OTHERS THEN
    g_retcode := -1;
    if g_debug_flag = 'Y' then
    FII_UTIL.put_line('
---------------------------------
Error in Procedure: TRUNCATE_TABLE
Message: '||sqlerrm);
    end if;
    RAISE;
End truncate_Table;

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
     /*g_phase := 'Altering session to enable parallel DML';
     commit;
     l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
     execute immediate l_stmt;*/

     ----------------------------------------------------------
     -- Find the schema owner of FII
     ----------------------------------------------------------
     g_phase := 'Find FII schema';
     g_fii_schema := FII_UTIL.get_schema_name ('FII');

     --------------------------------------------------------------
     -- Find all currency related information
     --------------------------------------------------------------
     g_phase := 'Find currency information';

     g_primary_mau := nvl(fii_currency.get_mau_primary, 0.01 );
     g_secondary_mau:= nvl(fii_currency.get_mau_secondary, 0.01);
     g_prim_currency := bis_common_parameters.get_currency_code;
  	  g_sec_currency := bis_common_parameters.get_secondary_currency_code;
     g_prim_rate_type := bis_common_parameters.get_rate_type;
	    g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

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

     g_phase := 'Find User ID and User Login';

     g_fii_user_id := FND_GLOBAL.User_Id;
     g_fii_login_id := FND_GLOBAL.Login_Id;

     IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
                RAISE G_LOGIN_INFO_NOT_AVABLE;
     END IF;

      if g_debug_flag = 'Y' then
  	FII_UTIL.put_line('User ID: ' || g_fii_user_id || '  Login ID: ' || g_fii_login_id);
      end if;

EXCEPTION
  WHEN G_LOGIN_INFO_NOT_AVABLE THEN
    g_retcode := -1;
    FII_UTIL.put_line('Init: can not get User ID and Login ID, program exits');
    raise;
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
-----------------------------------------------------------------
FUNCTION CHECK_IF_SLG_SET_UP_CHANGE RETURN VARCHAR2 IS
    l_slg_chg VARCHAR2(10);
    l_count1 number :=0 ;
    l_count2 number :=0 ;

BEGIN

    g_phase := 'Check if Source Legder Assignments setup has changed';
    if g_debug_flag  = 'Y' then
      FII_UTIL.put_line(g_phase);
    end if;

    SELECT DECODE(item_value, 'Y', 'TRUE', 'FALSE')
    INTO l_slg_chg
    FROM fii_change_log
    WHERE log_item = 'GL_RESUMMARIZE';

    IF l_slg_chg = 'TRUE' THEN

       g_phase := 'Reach l_slg_chg = TRUE';

   begin
       SELECT 1
       INTO l_count1
       FROM fii_gl_je_summary_b
       WHERE ROWNUM = 1;
   exception
       when NO_DATA_FOUND then
         l_count1 := 0;
   end;

   begin
       SELECT 1
       INTO l_count2
       FROM fii_gl_je_summary_stg
       WHERE ROWNUM = 1;
   exception
       when NO_DATA_FOUND then
         l_count2 := 0;
   end;

       IF (l_count1 = 0 AND l_count2 = 0)  then
         g_phase := 'Updating fii_change_log for log_item GL_RESUMMARIZE';
                   UPDATE fii_change_log
                   SET item_value = 'N',
			   last_update_date  = SYSDATE,
			   last_update_login = g_fii_login_id,
			   last_updated_by   = g_fii_user_id
                   WHERE log_item = 'GL_RESUMMARIZE'
                     AND item_value = 'Y';

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
-- FUNCTION CHECK_IF_PRD_SET_UP_CHANGE
-----------------------------------------------------------------
FUNCTION CHECK_IF_PRD_SET_UP_CHANGE RETURN VARCHAR2 IS
    l_prd_chg VARCHAR2(10);
    l_count1 number :=0 ;
    l_count2 number :=0 ;

BEGIN
    g_phase := 'Check if Product Assignments set up has changed';
    if g_debug_flag  = 'Y' then
      FII_UTIL.put_line(g_phase);
    end if;

    SELECT DECODE(item_value, 'Y', 'TRUE', 'FALSE')
    INTO l_prd_chg
    FROM fii_change_log
    WHERE log_item = 'GL_PROD_CHANGE';

    IF l_prd_chg = 'TRUE' THEN

       g_phase := 'Reach l_prd_chg = TRUE';

   begin
       SELECT 1
       INTO l_count1
       FROM fii_gl_je_summary_b
       WHERE ROWNUM = 1;
   exception
       when NO_DATA_FOUND then
         l_count1 := 0;
   end;

   begin
       SELECT 1
       INTO l_count2
       FROM fii_gl_je_summary_stg
       WHERE ROWNUM = 1;
   exception
       when NO_DATA_FOUND then
         l_count2 := 0;
   end;

       IF (l_count1 = 0 AND l_count2 = 0)  then
         g_phase := 'Updating fii_change_log for log_item GL_PROD_CHANGE';
                   UPDATE fii_change_log
                   SET item_value = 'N',
			   last_update_date  = SYSDATE,
			   last_update_login = g_fii_login_id,
			   last_updated_by   = g_fii_user_id
                   WHERE log_item = 'GL_PROD_CHANGE'
                     AND item_value = 'Y';

                   COMMIT;

                   l_prd_chg := 'FALSE';
       END IF;

   END IF;

   RETURN l_prd_chg;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'FALSE';
  WHEN OTHERS THEN
    g_retcode := -1;
    FII_UTIL.put_line('
-----------------------------
Error occured in Funcation: CHECK_IF_PRD_SET_UP_CHANGE
Phase: '||g_phase||'
Message: ' || sqlerrm);
    raise;
END CHECK_IF_PRD_SET_UP_CHANGE;


-----------------------------------------------------------------
-- PROCEDURE REGISTER_JOBS
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
    g_phase := 'select min and max sequence IDs from the ID Temp table';
    SELECT NVL(max(record_id), 0), nvl(min(record_id),1)
    INTO   l_max_number, l_start_number
    FROM   FII_GL_NEW_JRL_HEADER_IDS;

    WHILE (l_start_number <= l_max_number) LOOP
      l_end_number:= l_start_number + g_child_process_size;
      g_phase := 'Loop to insert into FII_GL_WORKER_JOBS: '
                  || l_start_number || ', ' || l_end_number;
      INSERT INTO FII_GL_WORKER_JOBS (start_range, end_range, worker_number, status)
      VALUES (l_start_number, least(l_end_number, l_max_number), 0, 'UNASSIGNED');
      l_count := l_count + 1;
      l_start_number := least(l_end_number, l_max_number) + 1;
    END LOOP;

   if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' || l_count || ' jobs into FII_GL_WORKER_JOBS table');
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
-- FUNCTION LAUNCH_WORKER
-----------------------------------------------------------------------
FUNCTION LAUNCH_WORKER(p_worker_no  NUMBER) RETURN NUMBER IS
    l_request_id         NUMBER;

BEGIN

    l_request_id := FND_REQUEST.SUBMIT_REQUEST('FII',
                                               'FII_GL_JE_B_C_SUBWORKER',
                                               NULL,
                                               NULL,
                                               FALSE,
                                               p_worker_no);
    IF (l_request_id = 0) THEN
      rollback;
      g_retcode := -1;
      FII_UTIL.put_line('
---------------------------------
Error in Procedure: LAUNCH_WORKER
Message: '||fnd_message.get);
      raise G_NO_CHILD_PROCESS;
    END IF;
    RETURN l_request_id;

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
Error in Procedure: LAUNCH_WORKER
Message: '||sqlerrm);
    raise;
END LAUNCH_WORKER;

-----------------------------------------------------------------------
-- PROCEDURE CHILD_SETUP
-----------------------------------------------------------------------
PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS
    l_dir 	VARCHAR2(400);
    l_stmt        VARCHAR2(100);

BEGIN

    g_phase := 'Calling ALTER SESSION SET global_names = false ';
    l_stmt := ' ALTER SESSION SET global_names = false';
    EXECUTE IMMEDIATE l_stmt;

    ------------------------------------------------------
    -- Set default directory in case if the profile option
    -- BIS_DEBUG_LOG_DIRECTORY is not set up
    ------------------------------------------------------
    l_dir:=FII_UTIL.get_utl_file_dir;

    ----------------------------------------------------------------
    -- fii_util.initialize will get profile options FII_DEBUG_MODE
    -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
    -- the log files and output files are written to
    ----------------------------------------------------------------
    g_phase := 'Calling FII_UTIL.initialize ';
    FII_UTIL.initialize(p_object_name||'.log',p_object_name||'.out',l_dir, 'FII_GL_JE_B_C_Worker');

    g_fii_user_id := FND_GLOBAL.User_Id;
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
--------------------------------------------------------------------
PROCEDURE SUMMARY_ERR_CHECK (p_program_type  IN   VARCHAR2)IS
    l_conv_rate_cnt NUMBER :=0;
    l_stg_min       DATE;
    l_stg_max       DATE;
    l_row_cnt       NUMBER;
    l_check_time_dim BOOLEAN;

BEGIN

    g_phase := 'Checking for missing rates';
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_phase);
    end if;

    ------------------------------------------------------
    -- If there are missing exchange rates indicated in
    -- the staging table, then call report_missing_rates
    -- API to print out the missing rates report
    ------------------------------------------------------
    IF (p_program_type = 'L') THEN
      g_phase := 'For p_program_type = L ';
      SELECT MIN(trx_date), MAX(trx_date), sum(decode(sign(prim_conversion_rate), -1, 1, 0)) +
                   sum(decode(sign(sec_conversion_rate), -1, 1, 0)), count(*)
      INTO l_stg_min, l_stg_max, l_conv_rate_cnt, l_row_cnt
      FROM FII_GL_REVENUE_RATES_TEMP;

    ELSE

      g_phase := 'For p_program_type <> L ';
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

----FII_UTIL.put_line('Missing currency conversion rates found, program will exit with error status.  Please fix the missing conversion rates');

      g_retcode := -1;
      g_missing_rates := 1;
      IF p_program_type = 'L' THEN
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

    -----------------------------------------------------------
    -- If we find record in the staging table which references
    -- time records which does not exist in FII_TIME_DAY
    -- table, then we will exit the program with error status
    -----------------------------------------------------------

    FII_TIME_API.check_missing_date (l_stg_min, l_stg_max, l_check_time_dim);

    --------------------------------------
    -- If there are missing time records
    --------------------------------------
    IF (l_check_time_dim) THEN

      FII_MESSAGE.write_output (msg_name  => 'FII_TIME_DIM_STALE',  token_num => 0);
      FII_MESSAGE.write_log    (msg_name  => 'FII_TIME_DIM_STALE',  token_num => 0);
      FII_MESSAGE.write_log    (msg_name  => 'FII_REFER_TO_OUTPUT', token_num => 0);

----FII_UTIL.put_line('Time Dimension is not fully populated.  Please populate Time dimension to cover the date range you are collecting');

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
BEGIN

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: CLEAN_UP');
    end if;

    TRUNCATE_TABLE('FII_GL_WORKER_JOBS');

    IF (g_truncate_id) THEN
      TRUNCATE_TABLE('FII_GL_NEW_JRL_HEADER_IDS');
    END IF;

    IF (g_truncate_stg) THEN
      TRUNCATE_TABLE('FII_GL_JE_SUMMARY_STG');
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

-----------------------------------------------------------------------
-- PROCEDURE SUM_AGGREGATE_WEEK
-- Aggregate date to week level (similar to ROLL_UP)
-- Note that we need to call Summarize_aggregate first before calling this
-- since global amounts need to be updated there.
-----------------------------------------------------------------------
PROCEDURE Sum_Aggregate_Week IS
    l_number_of_rows NUMBER :=0;

BEGIN

    ---------------------------------------------------------------------
    --Insert aggregate data into FII_GL_JE_SUMMARY_STG table for week level
    ---------------------------------------------------------------------
    g_phase := 'Insert aggregate data into FII_GL_JE_SUMMARY_STG table for week level';

   if g_debug_flag = 'Y' then
    FII_UTIL.put_line('');
    FII_UTIL.put_line('Inserting weekly aggregated data into FII_GL_JE_SUMMARY_STG table');
    FII_UTIL.start_timer;
   end if;

    INSERT INTO fii_gl_je_summary_stg
             (
             week,
             cost_center_id,
             fin_category_id,
             company_id,
             prod_category_id,
             user_dim1_id,
             user_dim2_id,
			 je_source,
             je_category,
             effective_date,
             ledger_id,
             chart_of_accounts_id,
             functional_currency,
             amount_b,
             prim_amount_g,
             sec_amount_g,
			 committed_amount_b,
			 committed_amount_prim,
			 obligated_amount_b,
			 obligated_amount_prim,
			 other_amount_b,
			 other_amount_prim,
			 posted_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
             SELECT
                    fday.week_id,
                    stg.cost_center_id,
                    stg.fin_category_id,
                    stg.company_id,
                    stg.prod_category_id,
					stg.user_dim1_id,
                    stg.user_dim2_id,
                    stg.je_source,
                    stg.je_category,
                    MAX(stg.effective_date),
                    stg.ledger_id,
                    stg.chart_of_accounts_id,
                    stg.functional_currency,
                    SUM(stg.amount_b) amount_b,
                    SUM(stg.prim_amount_g) prim_amount_g,
                    SUM(stg.sec_amount_g) sec_amount_g,
                    SUM(stg.committed_amount_b) committed_amount_b,
                    SUM(stg.committed_amount_prim) committed_amount_prim,
                    SUM(stg.obligated_amount_b) obligated_amount_b,
                    SUM(stg.obligated_amount_prim) obligated_amount_prim,
				    SUM(stg.other_amount_b) other_amount_b,
                    SUM(stg.other_amount_prim) other_amount_prim,
				    stg.posted_date,
					stg.last_update_date,
                    stg.last_updated_by,
                    stg.creation_date,
                    stg.created_by,
                    stg.last_update_login
             FROM   fii_gl_je_summary_stg stg,
                    fii_time_day              fday
             WHERE  stg.day  = fday.report_date_julian
             GROUP BY
                    stg.cost_center_id,
                    stg.fin_category_id,
                    stg.company_id,
                    stg.prod_category_id,
					stg.user_dim1_id,
                    stg.user_dim2_id,
                    stg.je_source,
                    stg.je_category,
                    stg.ledger_id,
                    stg.chart_of_accounts_id,
                    stg.functional_currency,
                    stg.last_update_date,
                    stg.last_updated_by,
                    stg.creation_date,
                    stg.created_by,
                    stg.last_update_login,
                    fday.week_id,
					stg.posted_date;


  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' rows of aggregated data into FII_GL_JE_SUMMARY_STG table');
    FII_UTIL.stop_timer;
    FII_UTIL.print_timer('Duration');
   end if;

Exception
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
Error in phase ' || g_phase || ' of Sum_Aggregate_Week procedure' || '
Message: ' || sqlerrm);
    ROLLBACK;
    raise;
END Sum_Aggregate_Week;

-----------------------------------------------------------------------
-- PROCEDURE SUMMARIZE_AGGREGATE
-----------------------------------------------------------------------
PROCEDURE Summarize_aggregate IS
    l_number_of_rows NUMBER :=0;

BEGIN

    --------------------------------------------------------------------
    -- Update FII_GL_JE_SUMMARY_STG table for global amount after all error
    -- checks passed.
    --------------------------------------------------------------------
    g_phase := 'Update global amount in FII_GL_JE_SUMMARY_STG table';

   if g_debug_flag = 'Y' then
    FII_UTIL.start_timer;
    FII_UTIL.put_line('Updating global amount in FII_GL_JE_SUMMARY_STG');
   end if;

    Update FII_GL_JE_SUMMARY_STG stg
    SET stg.prim_amount_g = round((stg.amount_b * prim_conversion_rate)/g_primary_mau)*g_primary_mau,
        stg.sec_amount_g  = round((stg.amount_b * sec_conversion_rate)/g_secondary_mau)*g_secondary_mau,
		stg.committed_amount_prim = round((stg.committed_amount_b * prim_conversion_rate)/g_primary_mau)*g_primary_mau,
		stg.obligated_amount_prim = round((stg.obligated_amount_b * prim_conversion_rate)/g_primary_mau)*g_primary_mau,
		stg.other_amount_prim = round((stg.other_amount_b * prim_conversion_rate)/g_primary_mau)*g_primary_mau;

   if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' records in FII_GL_JE_SUMMARY_STG');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
   end if;

    ---------------------------------------------------------------------
    --Insert aggregate data into FII_GL_JE_SUMMARY_STG table for higher
    --time levels Period, Quarter and Year.
    ---------------------------------------------------------------------
    g_phase := 'Insert aggregate data into FII_GL_JE_SUMMARY_STG table';

   if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line('Inserting aggregated data into FII_GL_JE_SUMMARY_STG table');
     FII_UTIL.start_timer;
   end if;

--
--bug 3356106: remove rollup by week_id (it's now handled in Sum_aggregate_week)
--

    INSERT INTO fii_gl_je_summary_stg
             (year,
             quarter,
             period,
             day,
             cost_center_id,
             fin_category_id,
             company_id,
             prod_category_id,
			 user_dim1_id,
             user_dim2_id,
             je_source,
             je_category,
             effective_date,
             ledger_id,
             chart_of_accounts_id,
             functional_currency,
             amount_b,
             prim_amount_g,
             sec_amount_g,
			 committed_amount_b,
			 committed_amount_prim,
			 obligated_amount_b,
			 obligated_amount_prim,
			 other_amount_b,
			 other_amount_prim,
			 posted_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
             SELECT  fday.ent_year_id,
                    fday.ent_qtr_id,
                    fday.ent_period_id,
                    TO_NUMBER(NULL),
                    stg.cost_center_id,
                    stg.fin_category_id,
                    stg.company_id,
                    stg.prod_category_id,
					stg.user_dim1_id,
                    stg.user_dim2_id,
                    stg.je_source,
                    stg.je_category,
                    MAX(stg.effective_date),
                    stg.ledger_id,
                    stg.chart_of_accounts_id,
                    stg.functional_currency,
                    SUM(stg.amount_b) amount_b,
                    SUM(stg.prim_amount_g) prim_amount_g,
                    SUM(stg.sec_amount_g) sec_amount_g,
					SUM(committed_amount_b) committed_amount_b,
			 	    SUM(committed_amount_prim) committed_amount_prim,
			 	    SUM(obligated_amount_b) obligated_amount_b,
			 	    SUM(obligated_amount_prim) obligated_amount_prim,
			 	    SUM(other_amount_b) other_amount_b,
			 	    SUM(other_amount_prim) other_amount_prim,
					stg.posted_date,
                    stg.last_update_date,
                    stg.last_updated_by,
                    stg.creation_date,
                    stg.created_by,
                    stg.last_update_login
             FROM   fii_gl_je_summary_stg stg,
                    fii_time_day fday
             WHERE  stg.day  = fday.report_date_julian
             GROUP BY
                    stg.cost_center_id,
                    stg.fin_category_id,
                    stg.company_id,
                    stg.prod_category_id,
					stg.user_dim1_id,
                    stg.user_dim2_id,
                    stg.je_source,
                    stg.je_category,
                    stg.ledger_id,
                    stg.chart_of_accounts_id,
                    stg.functional_currency,
					stg.posted_date,
                    stg.last_update_date,
                    stg.last_updated_by,
                    stg.creation_date,
                    stg.created_by,
                    stg.last_update_login,
             ROLLUP (fday.ent_year_id,
                    fday.ent_qtr_id,
                    fday.ent_period_id);


  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT ||
                      ' rows of aggregated data into FII_GL_JE_SUMMARY_STG table');
    FII_UTIL.stop_timer;
    FII_UTIL.print_timer('Duration');
   end if;

Exception
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
Error in phase ' || g_phase || ' of Summarize_aggregate procedure' || '
Message: ' || sqlerrm);
    ROLLBACK;
    raise;
END Summarize_aggregate;

-----------------------------------------------------------------------
-- PROCEDURE MERGE
-----------------------------------------------------------------------
PROCEDURE MERGE IS

BEGIN

    ----------------------------------------------------------------------
    -- Merges newly collected/summarized records from temporary table
    -- FII_GL_JE_SUMMARY_STG into GL base summary table FII_GL_JE_SUMMARY_B.
    -- FII_GL_JE_SUMMARY_B uses the nested summary table structure.

    -- If the merging record is new in FII_GL_JE_SUMMARY_STG then the record
    -- will be inserted into  FII_GL_JE_SUMMARY_B table. A merging reord is
    -- consoidered if the combination of period, Period_type,
    -- Cost center Organization id, natural Account, Journal Entry source,
    -- Journal Entry category, Set Of Books Id, Functional Currency Code,
    -- Company and Product code feilds is not present in the
    -- FII_GL_JE_SUMMARY_B table.
    -----------------------------------------------------------------------

    g_phase := 'Merging records into FII_GL_JE_SUMMARY_B';

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Merging records into FII_GL_JE_SUMMARY_B');
      FII_UTIL.start_timer;
    end if;

    MERGE INTO fii_gl_je_summary_b bsum
                USING
                   (SELECT  NVL(day, NVL(week, NVL(period, NVL(quarter, year)))) TIME_ID,
                      DECODE(day, null,
                           DECODE(week, null,
                              DECODE(period, null,
                                 DECODE(quarter, null, 128, 64), 32), 16), 1)
                                                        PERIOD_TYPE_ID,
                      COST_CENTER_ID,
					  PROD_CATEGORY_ID,
					  USER_DIM1_ID,
                      USER_DIM2_ID,
					  FIN_CATEGORY_ID,
					  COMPANY_ID,
                      JE_SOURCE, JE_CATEGORY, LEDGER_ID,
                      CHART_OF_ACCOUNTS_ID,
					  FUNCTIONAL_CURRENCY,
                      SUM(AMOUNT_B)  AMOUNT_B,
                      SUM(PRIM_AMOUNT_G)   PRIM_AMOUNT_G,
                      SUM(SEC_AMOUNT_G) SEC_AMOUNT_G,
					  SUM(COMMITTED_AMOUNT_B) COMMITTED_AMOUNT_B,
					  SUM(COMMITTED_AMOUNT_PRIM) COMMITTED_AMOUNT_PRIM,
					  SUM(OBLIGATED_AMOUNT_B) OBLIGATED_AMOUNT_B,
					  SUM(OBLIGATED_AMOUNT_PRIM) OBLIGATED_AMOUNT_PRIM,
					  SUM(OTHER_AMOUNT_B) OTHER_AMOUNT_B,
					  SUM(OTHER_AMOUNT_PRIM) OTHER_AMOUNT_PRIM,
					  POSTED_DATE
                   FROM fii_gl_je_summary_stg
                   WHERE  year IS NOT NULL
                      OR  week IS NOT NULL
                   GROUP BY
                      NVL(day, NVL(week, NVL(period, NVL(quarter, year)))),
                      DECODE(day, null,
                           DECODE(week, null,
                              DECODE(period, null,
                                 DECODE(quarter, null, 128, 64), 32), 16), 1),
                      COST_CENTER_ID,
					  PROD_CATEGORY_ID,
					  USER_DIM1_ID,
                      USER_DIM2_ID,
					  FIN_CATEGORY_ID,
					  COMPANY_ID,
                      JE_SOURCE, JE_CATEGORY, LEDGER_ID,
                      CHART_OF_ACCOUNTS_ID,
					  FUNCTIONAL_CURRENCY,
					  POSTED_DATE) s
                   ON (bsum.time_id = s.time_id AND
                      bsum.period_type_id = s.period_type_id AND
                      bsum.cost_center_id = s.cost_center_id AND
                      bsum.fin_category_id = s.fin_category_id AND
                      bsum.je_source = s.je_source AND
                      bsum.je_category = s.je_category AND
                      bsum.ledger_id = s.ledger_id AND
                      bsum.chart_of_accounts_id = s.chart_of_accounts_id AND
                      bsum.functional_currency = s.functional_currency AND
                      bsum.company_id = s.company_id AND
                      bsum.prod_category_id = s.prod_category_id AND
                      bsum.user_dim1_id = s.user_dim1_id AND
                      bsum.user_dim2_id = s.user_dim2_id AND
					  NVL(bsum.posted_date, g_global_start_date) = NVL(s.posted_date, g_global_start_date))
                  WHEN MATCHED THEN
                     UPDATE SET bsum.amount_b = bsum.amount_b+ s.amount_b,
                                bsum.prim_amount_g = bsum.prim_amount_g + s.prim_amount_g,
                                bsum.sec_amount_g = bsum.sec_amount_g + s.sec_amount_g,
								bsum.committed_amount_b = bsum.committed_amount_b+ s.committed_amount_b,
                                bsum.committed_amount_prim = bsum.committed_amount_prim + s.committed_amount_prim,
                                bsum.obligated_amount_b = bsum.obligated_amount_b+ s.obligated_amount_b,
                                bsum.obligated_amount_prim = bsum.obligated_amount_prim + s.obligated_amount_prim,
                                bsum.other_amount_b = bsum.other_amount_b+ s.other_amount_b,
                                bsum.other_amount_prim = bsum.other_amount_prim + s.other_amount_prim,
                                bsum.last_update_date = sysdate,
                                bsum.last_update_login = g_fii_login_id,
                                bsum.last_updated_by = g_fii_user_id
                  WHEN NOT MATCHED THEN INSERT (bsum.time_id,
                                                bsum.period_type_id,
                                                bsum.company_id,
                                                bsum.cost_center_id,
                                                bsum.fin_category_id,
                                                bsum.prod_category_id,
												bsum.user_dim1_id,
                                                bsum.user_dim2_id,
                                                bsum.je_source,
                                                bsum.je_category,
                                                bsum.ledger_id,
                                                bsum.chart_of_accounts_id,
                                                bsum.functional_currency,
                                                bsum.amount_B,
                                                bsum.prim_amount_G,
                                                bsum.sec_amount_G,
												bsum.committed_amount_b,
											    bsum.committed_amount_prim,
			 									bsum.obligated_amount_b,
												bsum.obligated_amount_prim,
											    bsum.other_amount_b,
												bsum.other_amount_prim,
												bsum.posted_date,
                                                bsum.creation_date,
                                                bsum.created_by,
                                                bsum.last_update_date,
                                                bsum.last_update_login,
                                                bsum.last_updated_by)
                           values (s.time_id,
                                   s.period_type_id,
                                   s.company_id,
                                   s.cost_center_id,
                                   s.fin_category_id,
                                   s.prod_category_id,
								   s.user_dim1_id,
                                   s.user_dim2_id,
                                   s.je_source,
                                   s.je_category,
                                   s.ledger_id,
                                   s.chart_of_accounts_id,
                                   s.functional_currency,
                                   s.amount_B,
                                   s.prim_amount_G,
                                   s.sec_amount_G,
								   s.committed_amount_b,
								   s.committed_amount_prim,
								   s.obligated_amount_b,
								   s.obligated_amount_prim,
								   s.other_amount_b,
								   s.other_amount_prim,
								   s.posted_date,
                                   sysdate,
                                   g_fii_user_id,
                                   sysdate,
                                   g_fii_login_id,
                                   g_fii_user_id);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Merged ' || SQL%ROWCOUNT || ' rows of records into FII_GL_JE_SUMMARY_B');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;

Exception
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: Merge
Message: '||sqlerrm);
    ROLLBACK;
    raise;
END MERGE;

------------------------------------------------------------------------
-- PROCEDURE JOURNALS_PROCESSED
------------------------------------------------------------------------
PROCEDURE JOURNALS_PROCESSED IS

BEGIN

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line ('Calling Journals_Processed Procedure');
    FII_UTIL.start_timer;
  end if;


    ---------------------------------------------------------------------
    -- Inserting processed JE Header IDs into FII_GL_PROCESSED_HEADER_IDS
    -- table.  Not all JE Header IDs in FII_GL_NEW_JRLHEADER_IDS are
    -- processed.  This is because when we select Header IDs to be
    -- processed (refer to NEW_JOURNALS function), we only filter by SOB
    -- in FII_COMPANY_SETS table, however when we extract data from OLTP
    -- tables, we actually filter data by both SOB and Company
    ---------------------------------------------------------------------

    INSERT INTO fii_gl_processed_header_ids (
                je_header_id,
                creation_date,
   		created_by,
    		last_update_date,
    		last_update_login,
    		last_updated_by)
    SELECT je_header_id,
           sysdate,
           g_fii_user_id,
           sysdate,
           g_fii_login_id,
           g_fii_user_id
    FROM fii_gl_new_jrl_header_ids;

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' rows into FII_GL_PROCESSED_HEADER_IDS');
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
-----------------------------------------------------------------------
Function  New_Journals(P_Start_Date IN DATE ,
                       P_End_Date IN DATE) RETURN NUMBER IS
    l_number_of_rows     NUMBER :=0;

BEGIN

    ----------------------------------------------------------------------
    -- Insert into a table to hold journal header ids which are never
    -- processed (Not exist in fii_gl_processed_header_id table.
    -- Posted Journals only
    -- And Journal entry line effective date falls within user specified
    -- date range.
    -- In future the header ids will be filtered on given set of books id.
    -----------------------------------------------------------------------
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line(' ');
      FII_UTIL.put_line('Inserting New Journal header ids');
      FII_UTIL.start_timer;
    end if;

--Bug 3121847: changed the hint per performance team suggestion

    --Added filtering by JE category/source for DBI 6.0

      INSERT /*+ append */ INTO fii_gl_new_jrl_header_ids
                 (record_id,
                  je_header_id,
                  currency_code,
                  je_source,
                  je_category,
    	          encumbrance_type,
				  actual_flag,
				  posted_date)
      SELECT /*+ use_hash(per, jeh, fset,fgph) parallel(jeh) parallel(fgph) */
             rownum,
             jeh.je_header_id,
             jeh.currency_code,
             jeh.je_source,
             jeh.je_category,
             decode(g_industry, 'G', NVL(etype.encumbrance_type, 'OTHERS'),
                                'C', NULL) encumbrance_type,
			 jeh.actual_flag,
			 decode(g_industry,
					   'G', decode(jeh.actual_flag,          --for Government
								   'A', g_global_start_date,  	-- for actuals
								   per2.start_date), --jeh.posted_date),    -- for encumbrances
						null)       	-- for Commercial
      FROM (
            SELECT  p.period_name, s.ledger_id
            FROM gl_periods p, gl_ledgers_public_v s
            WHERE p.start_date <= NVL(P_End_Date, start_date)
            AND   p.end_date   >= P_Start_Date
            AND   p.period_set_name = s.period_set_name) per,
           (SELECT DISTINCT
              slga.ledger_id,
              DECODE(slga.je_rule_set_id, NULL, '-1', rule.JE_SOURCE_NAME) je_source_name,
              DECODE(slga.je_rule_set_id, NULL, '-1', rule.JE_CATEGORY_NAME) je_category_name
            FROM fii_slg_assignments      slga,
                 gl_je_inclusion_rules    rule,
                 fii_source_ledger_groups fslg
            WHERE slga.je_rule_set_id = rule.je_rule_set_id (+)
              AND slga.source_ledger_group_id = fslg.source_ledger_group_id
              AND fslg.usage_code = g_usage_code) fset,
           gl_je_headers jeh,
           fii_encum_type_mappings etype,
           fii_gl_processed_header_ids fgph,
           gl_periods per2,
           gl_ledgers_public_v s2
        WHERE jeh.ledger_id = fset.ledger_id
        AND jeh.encumbrance_type_id = etype.encumbrance_type_id (+)
        AND (jeh.je_source   = fset.je_source_name   OR fset.je_source_name   = '-1')
        -- Bug 5026804: Exclude the journal source - Closing Journal
        AND jeh.je_source <> 'Closing Journal'
        AND (jeh.je_category = fset.je_category_name OR fset.je_category_name = '-1')
        AND      jeh.currency_code <> 'STAT'
        AND      jeh.period_name = per.period_name
        AND      jeh.ledger_id = per.ledger_id
        AND      jeh.je_header_id = fgph.je_header_id(+)
        AND      fgph.je_header_id IS NULL
        AND      jeh.status = 'P'
        AND      decode (jeh.actual_flag,
                         'A',1,
                         'E',1,
                         0) = 1
        AND jeh.ledger_id = s2.ledger_id
        AND s2.period_set_name = per2.period_set_name
        AND trunc(jeh.posted_date) between per2.start_date and per2.end_date
        AND per2.period_type = s2.accounted_period_type
        AND per2.adjustment_period_flag = 'N' ;

    l_number_of_rows := SQL%ROWCOUNT;

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Inserted '||l_number_of_rows||
                        ' JE header IDs into FII_GL_NEW_JRL_HEADER_IDS');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
      FII_UTIL.put_line('');
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

-------------------------------------------------------
-- PROCEDURE SUMMARIZE_DAY
-------------------------------------------------------
PROCEDURE SUMMARIZE_DAY(p_start_range NUMBER,
                        p_end_range   NUMBER) IS
    l_number_of_rows NUMBER :=0;
    l_stmt VARCHAR2(10000);

BEGIN

    ------------------------------------------------------------------
    -- Insert summarize journal entry lines at day level whose journal
    -- Header IDs are stored in FII_GL_NEW_JRL_HEADER_IDS table into
    -- FII_GL_JE_SUMMARY_STG.
    ------------------------------------------------------------------
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Processing ID range: ' || p_start_range ||
                       ' to ' || p_end_range);
    end if;

    l_stmt:= 'INSERT INTO FII_GL_JE_SUMMARY_STG
                  (day,
                   week,
                   period,
                   quarter,
                   year,
                   company_id,
                   cost_center_id,
                   fin_category_id,
                   prod_category_id,
				   user_dim1_id,
                   user_dim2_id,
                   je_source,
                   je_category,
                   ledger_id,
                   effective_date,
                   chart_of_accounts_id,
                   functional_currency,
                   amount_b,
				   committed_amount_b,
				   obligated_amount_b,
				   other_amount_b,
                   prim_conversion_rate,
                   sec_conversion_rate,
				   posted_date,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login)
              SELECT /*+ ORDERED USE_NL(njhi line sob fin) */
                   to_number(to_char(line.effective_date,''J'')) ,
                   to_number(NULL, 999),
                   to_number(NULL, 999) ,
                   to_number(NULL, 999) ,
                   999,  -- Insert 999 for year field so this record is merged into summary
                   fin.company_id,
                   fin.cost_center_id,
                   fin.natural_account_id,
                   NVL(fin.prod_category_id, -1),
				   fin.user_dim1_id,
                   fin.user_dim2_id,
                   njhi.je_source ,
                   njhi.je_category ,
                   sob.ledger_id,
                   line.effective_date,
                   sob.chart_of_accounts_id,
                   sob.currency_code,
				   decode(njhi.actual_flag,
					  ''A'', sum(NVL(line.accounted_cr, 0) - NVL(line.accounted_dr, 0)),
					  0),
				   decode(njhi.actual_flag,
						''E'', decode(njhi.encumbrance_type,
							      ''COMMITMENT'', sum(NVL(line.accounted_cr, 0) - NVL(line.accounted_dr, 0)),
								0),
						0), -- For encumbrances: requisitions (committed_amount)
				   decode(njhi.actual_flag,
						''E'', decode(njhi.encumbrance_type,
							      ''OBLIGATION'', sum(NVL(line.accounted_cr, 0) - NVL(line.accounted_dr, 0)),
								0),
						0), -- For encumbrances: purchase orders (obligated_amount)
				   decode(njhi.actual_flag,
						''E'', decode(njhi.encumbrance_type,
                                                              ''OTHERS'', sum(NVL(line.accounted_cr, 0) - NVL(line.accounted_dr, 0)),
                                                                0),
						0), -- For encumbrances: others (other_amount)
				   fii_currency.get_global_rate_primary(sob.currency_code, least(sysdate, line.effective_date)),
                   fii_currency.get_global_rate_secondary(sob.currency_code, least(sysdate, line.effective_date)),
				   decode('''||g_industry||''',
		                  ''G'', decode(njhi.actual_flag, --for Government
					   					''A'', null,  -- for actuals
				 					    njhi.posted_date),             -- for encumbrances
						  null),         	-- for Commercial
                   sysdate, ' ||
                   g_fii_user_id || ',
                   sysdate, ' ||
                   g_fii_user_id || ',' ||
                   g_fii_login_id || '
                   FROM  fii_gl_new_jrl_header_ids njhi,
                         gl_je_lines line,
                         gl_ledgers_public_v sob,
                         fii_gl_ccid_dimensions fin,
            			 fii_slg_assignments slga,
						 fii_source_ledger_groups fslg
                   WHERE njhi.je_header_id = line.je_header_id
                   AND   line.ledger_id = sob.ledger_id
                   AND   line.code_combination_id = fin.code_combination_id
                   AND   ( fin.company_id = slga.bal_seg_value_id OR slga.bal_seg_value_id = -1 )
                   AND   fin.chart_of_accounts_id = slga.chart_of_accounts_id
                   AND   line.ledger_id = slga.ledger_id
                   AND   njhi.record_id >= '|| p_start_range || '
                   AND   njhi.record_id <= ' || p_end_range || '
			AND slga.source_ledger_group_id = fslg.source_ledger_group_id
			AND fslg.usage_code = ''' || g_usage_code || '''
                   GROUP BY line.effective_date,
                            fin.company_id,
                            fin.cost_center_id,
                            fin.natural_account_id,
                            NVL(fin.prod_category_id, -1),
							fin.user_dim1_id,
                            fin.user_dim2_id,
                            njhi.je_source,
                            njhi.je_category,
                            sob.ledger_id,
                            sob.chart_of_accounts_id,
                            sob.currency_code,
     			    njhi.encumbrance_type,
							njhi.actual_flag,
						    decode('''||g_industry||''',
				                  ''G'', decode(njhi.actual_flag, --for Government
							   					''A'', null,  -- for actuals
						 					    njhi.posted_date),             -- for encumbrances
								  null)';              -- for Commercial

   if g_debug_flag = 'Y' then
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
     FII_UTIL.put_line(l_stmt);
   end if;


   EXECUTE IMMEDIATE l_stmt;

   l_number_of_rows := SQL%ROWCOUNT;

   commit;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('');
    FII_UTIL.put_line('Inserted '||l_number_of_rows||' into table FII_GL_JE_SUMMARY_STG with day level data');
    FII_UTIL.stop_timer;
    FII_UTIL.print_timer('Duration');
  end if;

EXCEPTION
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: Summarize_day
Message: '||sqlerrm);
    raise;
END Summarize_day;

---------------------------------------------------------------
-- PROCEDURE VERIFY_CCID_UP_TO_DATE
---------------------------------------------------------------
PROCEDURE VERIFY_CCID_UP_TO_DATE IS
    l_errbuf VARCHAR2(1000);
    l_retcode VARCHAR2(100);
    l_request_id NUMBER;
    l_result BOOLEAN;
    l_phase VARCHAR2(500) := NULL;
    l_status VARCHAR2(500) := NULL;
    l_devphase VARCHAR2(500) := 'PENDING';
    l_devstatus VARCHAR2(500) := NULL;
    l_message VARCHAR2(500) := NULL;
    l_dummy BOOLEAN;
    l_submit_failed EXCEPTION;
    l_call_status   boolean;

BEGIN

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('Calling Procedure: VERIFY_CCID_UP_TO_DATE');
    FII_UTIL.put_line('');
  end if;

  IF(FII_GL_CCID_C.NEW_CCID_IN_GL) THEN
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('CCID Dimension is not up to date, calling CCID Dimension update program');
    end if;

      g_phase := 'Calling CCID Dimension update program';
      l_dummy := FND_REQUEST.SET_MODE(TRUE);
      l_request_id := FND_REQUEST.SUBMIT_REQUEST('FII', 'FII_GL_CCID_C',
                                                 NULL, NULL, FALSE, 'I');
      commit;

      IF (l_request_id = 0) THEN
	  rollback;
	  g_retcode := -1;
	  FII_UTIL.put_line('
---------------------------------
Error in Procedure: VERIFY_CCID_UP_TO_DATE
Message: '||fnd_message.get);
        raise G_NO_CHILD_PROCESS;
      END IF;

      g_phase := 'Calling FND_CONCURRENT.wait_for_request';
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
         FII_UTIL.put_line('CCID Dimension populated successfully');
       end if;
      ELSE
       if g_debug_flag = 'Y' then
         FII_UTIL.put_line('CCID Dimension populated unsuccessfully');
       end if;
        raise G_CCID_FAILED;
      END IF;

    ELSE

     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('CCID Dimension is up to date');
       FII_UTIL.put_line('');
     end if;

    END IF;

Exception
  WHEN G_NO_CHILD_PROCESS THEN
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Phase: Submitting Child process to run CCID program');
    raise;
  WHEN G_CCID_FAILED THEN
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE when running CCID program
Phase: ' || g_phase);
    raise;
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Phase: ' || g_phase || '
Message: '||sqlerrm);
    raise;
END VERIFY_CCID_UP_TO_DATE;


---------------------------------------------------------------
-- PROCEDURE POPULATE_ENCUM_MAPPING
---------------------------------------------------------------
PROCEDURE POPULATE_ENCUM_MAPPING IS
  l_count         NUMBER;

  CURSOR invalid_lookup_cur IS
    SELECT a.lookup_code,
           decode(a.lookup_type, 'FII_PSI_ENCUM_TYPES_OBLIGATION', 'Obligation',
                                 'FII_PSI_ENCUM_TYPES_COMMITMENT', 'Commitment') lookup_type
    FROM  fnd_lookup_values a
    WHERE a.lookup_type in ( 'FII_PSI_ENCUM_TYPES_OBLIGATION',
                             'FII_PSI_ENCUM_TYPES_COMMITMENT')
    AND a.view_application_id = 450
    AND a.language = userenv('LANG')
    AND upper(a.lookup_code) not in (select upper(encumbrance_type)
                                     from gl_encumbrance_types);
BEGIN

  IF g_debug_flag = 'Y' THEN
    FII_UTIL.put_line('In procedure POPULATE_ENCUM_MAPPING():');
    FII_UTIL.put_line('');
  END IF;

  ---------------------------------------------------------------------------
  -- Truncate fii_encum_type_mappings
  ---------------------------------------------------------------------------
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line(' ');
    fii_util.put_line('Truncate fii_encum_type_mappings...');
  END IF;
  TRUNCATE_TABLE('FII_ENCUM_TYPE_MAPPINGS');

  INSERT INTO fii_encum_type_mappings
    (encumbrance_type_id,
     encumbrance_type,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
     last_update_login)
  SELECT b.encumbrance_type_id,
         decode(a.lookup_type, 'FII_PSI_ENCUM_TYPES_OBLIGATION', 'OBLIGATION',
                               'FII_PSI_ENCUM_TYPES_COMMITMENT', 'COMMITMENT'),
         sysdate,
         g_fii_user_id,
         sysdate,
         g_fii_user_id,
         g_fii_login_id
  FROM  fnd_lookup_values a,
        gl_encumbrance_types b
  WHERE a.lookup_type in ( 'FII_PSI_ENCUM_TYPES_OBLIGATION',
                           'FII_PSI_ENCUM_TYPES_COMMITMENT')
  AND a.view_application_id = 450
  AND a.language = userenv('LANG')
  AND upper(a.lookup_code) = upper(b.encumbrance_type);

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_encum_type_mappings');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  END IF;

  -- Print a warning message if there is any lookup_code that does not match the
  -- encumbrance_type defined in gl_encumbrance_types
  l_count := 0;
  FOR invalid_lookup_codes in invalid_lookup_cur LOOP
    IF (l_count = 0) THEN
      fii_util.put_line(' ');
      fii_util.put_line(
        'WARNING: Invalid lookup codes found in the encumbrance type mappings. ');
      fii_util.put_line('Please make sure these lookup codes are valid GL Encumbrance Types.');
      fii_util.put_line('Lookup Type     Lookup Code ');
      fii_util.put_line('-----------     -----------');
      l_count := l_count + 1;
    END IF;

    fii_util.put_line(invalid_lookup_codes.lookup_type ||'   '||
                      invalid_lookup_codes.lookup_code);

  END LOOP;

  -- Raise an error if the mapping table is empty
  IF (SQL%ROWCOUNT = 0) THEN
    fii_util.put_line('The mapping table between GL Encumrbance Type and FII Encumbrance bucket (fii_encum_type_mappings) is empty.  Please enter the encumbrance type mappings.');
    raise G_MISSING_ENCUM_MAPPING;
  END IF;

  commit;

Exception
  WHEN G_MISSING_ENCUM_MAPPING Then
    g_retcode := -1;
    FII_UTIL.put_line('POPULATE_ENCUM_MAPPING:Encumbrance mapping is missing.');
    raise;

  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Procedure : POPULATE_ENCUM_MAPPING
Phase: ' || g_phase || '
Message: '||sqlerrm);
    raise;
END POPULATE_ENCUM_MAPPING;

------------------------------------------
-- PROCEDURE Insert_Into_Stg
------------------------------------------


PROCEDURE INSERT_INTO_STG (p_sort_area_size  IN   NUMBER,
			   p_hash_area_size  IN   NUMBER,
			   l_start_date      IN   DATE,
			   l_end_date        IN   DATE)    IS

  l_stmt   VARCHAR2(1000);

BEGIN

 g_phase := 'Calling alter session set sort_area_size';
 l_stmt := 'alter session set sort_area_size= '|| p_sort_area_size;
 execute immediate l_stmt;

 g_phase := 'Calling alter session set hash_area_size';
 l_stmt := 'alter session set hash_area_size= ' ||p_hash_area_size;
 execute immediate l_stmt;

 if g_debug_flag = 'Y' then
   fii_util.put_line(' ');
   fii_util.put_line('Loading data into staging table');
   fii_util.start_timer;
   fii_util.put_line('');
 end if;

 g_phase := 'Inserting into FII_GL_JE_SUMMARY_STG';
 INSERT /*+ append parallel(fii_gl_je_summary_stg) */ INTO FII_GL_JE_SUMMARY_STG
                  (day,
                   week,
                   period,
                   quarter,
                   year,
                   company_id,
                   cost_center_id,
                   fin_category_id,
                   prod_category_id,
				   user_dim1_id,
                   user_dim2_id,
                   je_source,
                   je_category,
                   ledger_id,
                   effective_date,
                   chart_of_accounts_id,
                   functional_currency,
                   amount_b,
                   prim_conversion_rate,
                   sec_conversion_rate,
			 	   committed_amount_b,
			 	   obligated_amount_b,
			 	   other_amount_b,
				   posted_date,
                   last_update_date,
                   last_updated_by,
                   creation_date,
                   created_by,
                   last_update_login)
 SELECT   /*+ ORDERED parallel(v1) parallel(line) use_hash(line,fset2) use_nl(fin)
           swap_join_inputs(sob)  swap_join_inputs(fset2) pq_distribute(fset2,none,broadcast) */
	to_number(to_char(line.effective_date,'J')) ,
	to_number(NULL, 999),
	to_number(NULL, 999) ,
	to_number(NULL, 999) ,
	999,  -- Insert value into YEAR field so this day level record can be inserted into summary table
	fin.company_id,
	fin.cost_center_id,
	fin.natural_account_id,
	NVL(fin.prod_category_id, -1),
	fin.user_dim1_id,
    fin.user_dim2_id,
	v1.je_source ,
	v1.je_category ,
        fset2.set_of_books_id,
	line.effective_date,
	fset2.chart_accs_id_sob,
        fset2.currency_code,
	decode(v1.actual_flag,
		'A', sum(NVL(line.accounted_cr, 0) - NVL(line.accounted_dr, 0)),
		0),
	-- fii_currency.get_global_rate_primary(sob.currency_code, line.effective_date),
	-- fii_currency.get_global_rate_secondary(sob.currency_code, line.effective_date),
	-1,
	-1,
	decode(v1.actual_flag,
		'E', decode(v1.encumbrance_type,
     		           'COMMITMENT', sum(NVL(line.accounted_cr, 0) -
                                             NVL(line.accounted_dr, 0)),
				0),
		0), -- For encumbrances: requisitions (committed_amount)
	decode(v1.actual_flag,
		'E', decode(v1.encumbrance_type,
		            'OBLIGATION', sum(NVL(line.accounted_cr, 0) -
                                              NVL(line.accounted_dr, 0)),
				0),
		0), -- For encumbrances: purchase orders (obligated_amount)
	decode(v1.actual_flag,
		'E', decode(v1.encumbrance_type,
                            'OTHERS', sum(NVL(line.accounted_cr, 0) -
                                          NVL(line.accounted_dr, 0)),
                                0),
		0), -- For encumbrances: others (other_amount)
	decode(g_industry,
		   'G', decode(v1.actual_flag,--for Government
					   'A', null,  	  -- for actuals
					   v1.posted_date),             -- for encumbrances
			null),         	-- for Commercial
	trunc(sysdate),  -- bug 4323856
        g_fii_user_id,
	trunc(sysdate),  -- bug 4323856
        g_fii_user_id,
        g_fii_login_id
-- rewrite the v1 inline view beased on perf team's suggestion bug 4214956
-- [old definition of vi inline view]
--
--  FROM  	(
--       	SELECT 	/*+ no_merge ordered parallel(jeh) parallel(per) parallel(fset) parallel(fgph) use_hash(jeh,per,fset,fgph) */
/*             	jeh.je_header_id,
             	jeh.currency_code,
             	jeh.je_source,
             	jeh.je_category,
				jeh.posted_date,		 --Added for PSI
				jeh.encumbrance_type_id, --Added for PSI
			    jeh.actual_flag,			 --Added for PSI
                org.req_encumbrance_type_id,
                org.purch_encumbrance_type_id
        FROM   	gl_je_headers jeh,
                (select distinct hdrs.ledger_id, hdrs.je_batch_id, bat.org_id
                 from gl_je_headers hdrs, gl_je_batches bat
                 where hdrs.je_batch_id = bat.je_batch_id
                ) jeb,
                financials_system_params_all org,
      	 	(
                 SELECT p.period_name, s.ledger_id
                 FROM gl_periods p, gl_ledgers_public_v s
            	 WHERE p.start_date <= l_end_date
            	 AND   p.end_date   >= l_start_date
                 AND   p.period_set_name = s.period_set_name) per,
                (SELECT DISTINCT
                   slga.ledger_id,
                   DECODE(slga.je_rule_set_id, NULL, '-1', rule.JE_SOURCE_NAME) je_source_name,
                   DECODE(slga.je_rule_set_id, NULL, '-1', rule.JE_CATEGORY_NAME) je_category_name
                 FROM  fii_slg_assignments slga,
                       gl_je_inclusion_rules rule,
                       fii_source_ledger_groups fslg
                 WHERE slga.je_rule_set_id = rule.je_rule_set_id (+)
                   AND slga.source_ledger_group_id = fslg.source_ledger_group_id
                   AND fslg.usage_code = g_usage_code) fset,
           	fii_gl_processed_header_ids fgph
        WHERE jeh.ledger_id = fset.ledger_id
        AND jeh.je_batch_id = jeb.je_batch_id
        AND jeb.org_id = org.org_id (+)
        AND jeb.ledger_id = org.set_of_books_id (+)
        AND (jeh.je_source   = fset.je_source_name   OR fset.je_source_name   = '-1')
          AND (jeh.je_category = fset.je_category_name OR fset.je_category_name = '-1')
          AND     jeh.currency_code <> 'STAT'
          AND     jeh.period_name = per.period_name
          AND     jeh.ledger_id = per.set_of_books_id
          AND     jeh.je_header_id = fgph.je_header_id(+)
          AND     fgph.je_header_id IS NULL
          AND     jeh.status = 'P'
          AND     decode (jeh.actual_flag,
						  'A', 1,
						  'E', 1,
						  0) = 1
	) v1,
*/
-- rewrite the v1 inline view beased on perf team's suggestion bug 4214956
-- [new definition of vi inline view]
--
 FROM   (
        SELECT  /*+ no_merge ordered parallel(jeh) parallel(s) parallel(p) parallel(fset) parallel(fgph)
		use_hash(jeh ,per ,fset ,fgph) swap_join_inputs(fgph) swap_join_inputs(fset) */
                jeh.je_header_id,
                jeh.currency_code,
                jeh.je_source,
                jeh.je_category,
                p2.start_date posted_date, --jeh.posted_date,         --Added for PSI
                jeh.encumbrance_type_id, --Added for PSI
                jeh.actual_flag,         --Added for PSI
                decode(g_industry, 'G', NVL(etype.encumbrance_type, 'OTHERS'),
                                   'C', NULL) encumbrance_type
        FROM    gl_ledgers_public_v s,
                gl_periods p,
                gl_periods p2,
                gl_je_headers jeh,
                fii_encum_type_mappings etype,
                (SELECT /*+ no_merge */ DISTINCT
                      slga.ledger_id,
                      DECODE(slga.je_rule_set_id, NULL, '-1', rule.JE_SOURCE_NAME) je_source_name,
                      DECODE(slga.je_rule_set_id, NULL, '-1', rule.JE_CATEGORY_NAME) je_category_name
                FROM  fii_slg_assignments slga,
                      gl_je_inclusion_rules rule,
                      fii_source_ledger_groups fslg
                WHERE slga.je_rule_set_id = rule.je_rule_set_id (+)
                AND  slga.source_ledger_group_id = fslg.source_ledger_group_id
                AND  fslg.usage_code = g_usage_code) fset,
                fii_gl_processed_header_ids fgph
        WHERE  jeh.ledger_id = fset.ledger_id
        AND    (jeh.je_source  = fset.je_source_name  OR fset.je_source_name  = '-1')
        -- Bug 5026804: Exclude the journal source - Closing Journal
        AND    jeh.je_source <> 'Closing Journal'
        AND    (jeh.je_category = fset.je_category_name OR fset.je_category_name = '-1')
        AND    jeh.currency_code <> 'STAT'
        AND    jeh.period_name = p.period_name
        AND    jeh.ledger_id = s.ledger_id
        AND    jeh.je_header_id = fgph.je_header_id(+)
        AND    fgph.je_header_id IS NULL
        AND    jeh.status = 'P'
        AND    jeh.actual_flag IN ('A','E')
        AND    jeh.encumbrance_type_id = etype.encumbrance_type_id (+)
        AND    p.start_date <= l_end_date    --:b3
        AND    p.end_date  >=  l_start_date  --:b2
        AND    p.period_set_name = s.period_set_name

        AND    p2.period_set_name = s.period_set_name
        AND    trunc(jeh.posted_date) between p2.start_date and p2.end_date
        AND    p2.period_type = s.accounted_period_type
        AND    p2.adjustment_period_flag = 'N'

      ) v1,
	gl_je_lines line,
      ( SELECT /*+ no_merge */
               SOB.ledger_id set_of_books_id,
               SLGA2.ledger_id,
               SLGA2.bal_seg_value_id,
     	       SLGA2.chart_of_accounts_id,
               SOB.currency_code,
               SOB.CHART_OF_ACCOUNTS_ID chart_accs_id_sob
        FROM   gl_ledgers_public_v SOB,
	       FII_SLG_ASSIGNMENTS SLGA2,
	       FII_SOURCE_LEDGER_GROUPS FSLG2
        WHERE SOB.LEDGER_ID =  SLGA2.LEDGER_ID
        AND SLGA2.SOURCE_LEDGER_GROUP_ID = FSLG2.SOURCE_LEDGER_GROUP_ID
        AND FSLG2.USAGE_CODE = 'DBI'
      ) fset2,
	fii_gl_ccid_dimensions fin
WHERE 	v1.je_header_id 		= line.je_header_id
AND   	line.code_combination_id 	= fin.code_combination_id
AND     line.ledger_id                  = fset2.set_of_books_id
AND     line.ledger_id                  = fset2.ledger_id
AND   	( fin.company_id 			= fset2.bal_seg_value_id
        OR fset2.bal_seg_value_id = -1 )
AND   	fin.chart_of_accounts_id 	= fset2.chart_of_accounts_id
GROUP 	BY line.effective_date,
	fin.company_id,
	fin.cost_center_id,
	fin.natural_account_id,
	NVL(fin.prod_category_id, -1),
	fin.user_dim1_id,
    fin.user_dim2_id,
	v1.je_source,
	v1.je_category,
        fset2.set_of_books_id,
	fset2.chart_accs_id_sob,
	fset2.currency_code,
	decode(g_industry,
		   'G', decode(v1.actual_flag,--for Government
					   'A', null,  	-- for actuals
					   v1.posted_date),             -- for encumbrances
			null),         	-- for Commercial
	v1.encumbrance_type,
	v1.actual_flag;

  -- Bug 4545509: Per performance team, we need to commit before we call
  -- gather stats so that stats will be gathered at 10% vs 99%.
  commit;

  --Call FND_STATS to collect statistics after populating the table
    g_phase := 'Calling FND_STATS to collect statistics for FII_GL_JE_SUMMARY_STG';
       FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_GL_JE_SUMMARY_STG');

    g_phase := 'Enabling parallel dml';
	execute immediate 'alter session enable parallel dml';

 if g_debug_flag = 'Y' then
   fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_gl_je_summary_stg');
   fii_util.stop_timer;
   fii_util.print_timer('Duration');
 end if;

EXCEPTION
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: INSERT_INTO_STG
Phase: ' || g_phase || '
Message: '||sqlerrm);
    raise;

END INSERT_INTO_STG;

-------------------------------------------
-- PROCEDURE Roll_Up
-------------------------------------------

PROCEDURE ROLL_UP (p_sort_area_size  IN  NUMBER,
                   p_hash_area_size  IN  NUMBER)    IS

  l_stmt   VARCHAR2(1000);

BEGIN

 g_phase := 'Calling alter session set sort_area_size';
 l_stmt := 'alter session set sort_area_size= ' ||p_sort_area_size;
 execute immediate l_stmt;

 g_phase := 'Calling alter session set hash_area_size';
 l_stmt := 'alter session set hash_area_size= ' ||p_hash_area_size;
 execute immediate l_stmt;

 if g_debug_flag = 'Y' then
   fii_util.put_line(' ');
   fii_util.put_line('Rolling up data in staging table');
   fii_util.start_timer;
   fii_util.put_line('');
 end if;

 g_phase := 'Inserting into fii_gl_je_summary_b';
 INSERT /*+ append parallel(fii_gl_je_summary_b) */ INTO fii_gl_je_summary_b
             (time_id,
             period_type_id,
             cost_center_id,
             fin_category_id,
             company_id,
             prod_category_id,
             user_dim1_id,
             user_dim2_id,
             je_source,
             je_category,
             -- effective_date,
             ledger_id,
             chart_of_accounts_id,
             functional_currency,
             amount_b,
             prim_amount_g,
             sec_amount_g,
			 committed_amount_b,
			 committed_amount_prim,
			 obligated_amount_b,
			 obligated_amount_prim,
		     other_amount_b,
			 other_amount_prim,
			 posted_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
             SELECT  /*+ parallel(bsum) parallel(fday) use_hash(fday,stg) */
                    fday.week_id,
                    16,
                    bsum.cost_center_id,
                    bsum.fin_category_id,
                    bsum.company_id,
                    bsum.prod_category_id,
                    bsum.user_dim1_id,
                    bsum.user_dim2_id,
                    bsum.je_source,
                    bsum.je_category,
                    -- MAX(stg.effective_date),
                    bsum.ledger_id,
                    bsum.chart_of_accounts_id,
                    bsum.functional_currency,
                    SUM(bsum.amount_b) amount_b,
                    SUM(bsum.prim_amount_g) prim_amount_g,
                    SUM(bsum.sec_amount_g) sec_amount_g,
				    SUM(bsum.committed_amount_b) committed_amount_b,
					SUM(bsum.committed_amount_prim) committed_amount_prim,
					SUM(bsum.obligated_amount_b) obligated_amount_b,
					SUM(bsum.obligated_amount_prim) obligated_amount_prim,
				    SUM(bsum.other_amount_b) other_amount_b,
					SUM(bsum.other_amount_prim) other_amount_prim,
					bsum.posted_date,
                    bsum.last_update_date,
                    bsum.last_updated_by,
                    bsum.creation_date,
                    bsum.created_by,
                    bsum.last_update_login
             FROM   fii_gl_je_summary_b bsum,
                    fii_time_day fday
             WHERE  bsum.time_id  = fday.report_date_julian
             GROUP BY
                    bsum.cost_center_id,
                    bsum.fin_category_id,
                    bsum.company_id,
                    bsum.prod_category_id,
                    bsum.user_dim1_id,
                    bsum.user_dim2_id,
                    bsum.je_source,
                    bsum.je_category,
              --      stg.effective_date,
                    bsum.ledger_id,
                    bsum.chart_of_accounts_id,
                    bsum.functional_currency,
                    bsum.last_update_date,
                    bsum.last_updated_by,
                    bsum.creation_date,
                    bsum.created_by,
                    bsum.last_update_login,
                    fday.week_id,
					bsum.posted_date ;

   if g_debug_flag = 'Y' then
     fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into FII_GL_JE_SUMMARY_B');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;

commit;

EXCEPTION
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: Roll_up
Phase: ' || g_phase || '
Message: '||sqlerrm);
    raise;

END ROLL_UP;

-------------------------------------------
-- PROCEDURE Roll_Up2
-------------------------------------------

PROCEDURE ROLL_UP2 (p_sort_area_size  IN  NUMBER,
                   p_hash_area_size  IN  NUMBER)
                   IS

 l_stmt   VARCHAR2(1000);

BEGIN

 g_phase := 'Calling alter session set sort_area_size';
 l_stmt := 'alter session set sort_area_size= ' ||p_sort_area_size;
 execute immediate l_stmt;

 g_phase := 'Calling alter session set hash_area_size';
 l_stmt := 'alter session set hash_area_size= ' ||p_hash_area_size;
 execute immediate l_stmt;

 if g_debug_flag = 'Y' then
   fii_util.put_line(' ');
   fii_util.put_line('Rolling up data in staging table');
   fii_util.start_timer;
   fii_util.put_line('');
 end if;

--Bug 3121847: removed delete in ROLL_UP2 by filtering it out during insert

 g_phase := 'Inserting into fii_gl_je_summary_b';
 INSERT /*+ append parallel(fii_gl_je_summary_b) */ INTO fii_gl_je_summary_b
            (time_id,
             period_type_id,
             cost_center_id,
             fin_category_id,
             company_id,
             prod_category_id,
             user_dim1_id,
             user_dim2_id,
             je_source,
             je_category,
             -- effective_date,
             ledger_id,
             chart_of_accounts_id,
             functional_currency,
             amount_b,
             prim_amount_g,
             sec_amount_g,
			 committed_amount_b,
			 committed_amount_prim,
			 obligated_amount_b,
			 obligated_amount_prim,
		     other_amount_b,
			 other_amount_prim,
			 posted_date,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
             last_update_login)
      Select * From (
          SELECT  /*+ parallel(bsum) parallel(fday) use_hash(fday,stg) */
              NVL(fday.ent_period_id, NVL(fday.ent_qtr_id, fday.ent_year_id))              time_id,
              DECODE(fday.ent_period_id, NULL, DECODE(fday.ent_qtr_id, NULL, 128, 64), 32) period_type_id,
                    bsum.cost_center_id,
                    bsum.fin_category_id,
                    bsum.company_id,
                    bsum.prod_category_id,
                    bsum.user_dim1_id,
                    bsum.user_dim2_id,
                    bsum.je_source,
                    bsum.je_category,
                    bsum.ledger_id,
                    bsum.chart_of_accounts_id,
                    bsum.functional_currency,
                    SUM(bsum.amount_b) amount_b,
                    SUM(bsum.prim_amount_g) prim_amount_g,
                    SUM(bsum.sec_amount_g) sec_amount_g,
					SUM(bsum.committed_amount_b) committed_amount_b,
					SUM(bsum.committed_amount_prim) committed_amount_prim,
					SUM(bsum.obligated_amount_b) obligated_amount_b,
					SUM(bsum.obligated_amount_prim) obligated_amount_prim,
				    SUM(bsum.other_amount_b) other_amount_b,
					SUM(bsum.other_amount_prim) other_amount_prim,
					bsum.posted_date,
                    bsum.last_update_date,
                    bsum.last_updated_by,
                    bsum.creation_date,
                    bsum.created_by,
                    bsum.last_update_login
             FROM   fii_gl_je_summary_b bsum,
                    fii_time_day fday
             WHERE  bsum.time_id  = fday.report_date_julian
             GROUP BY
                    bsum.cost_center_id,
                    bsum.fin_category_id,
                    bsum.company_id,
                    bsum.prod_category_id,
					bsum.user_dim1_id,
                	bsum.user_dim2_id,
                    bsum.je_source,
                    bsum.je_category,
                    bsum.ledger_id,
                    bsum.chart_of_accounts_id,
                    bsum.functional_currency,
					bsum.posted_date,
                    bsum.last_update_date,
                    bsum.last_updated_by,
                    bsum.creation_date,
                    bsum.created_by,
                    bsum.last_update_login,
             ROLLUP (fday.ent_year_id,
                    fday.ent_qtr_id,
                    fday.ent_period_id))
          where time_id is not null;

   if g_debug_flag = 'Y' then
     fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into FII_GL_JE_SUMMARY_B');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;

commit;

-------
--Removed delete: DELETE FROM FII_GL_JE_SUMMARY_B WHERE time_id IS NULL;
-------

EXCEPTION
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: Roll_up2
Phase: ' || g_phase || '
Message: '||sqlerrm);
    raise;

END ROLL_UP2;

----------------------------------------
-- PROCEDURE Insert_Into_Rates
----------------------------------------

PROCEDURE INSERT_INTO_RATES IS

 l_global_prim_curr_code  VARCHAR2(30);
 l_global_sec_curr_code   VARCHAR2(30);

BEGIN

   g_phase := 'Calling bis_common_parameters.get_currency_code';

   l_global_prim_curr_code := bis_common_parameters.get_currency_code;
   l_global_sec_curr_code  := bis_common_parameters.get_secondary_currency_code;

   if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line('Loading data into rates table');
     fii_util.start_timer;
     fii_util.put_line('');
   end if;

  g_phase := 'Inserting into fii_gl_revenue_rates_temp';
insert into fii_gl_revenue_rates_temp
(FUNCTIONAL_CURRENCY,
 TRX_DATE,
 PRIM_CONVERSION_RATE,
 SEC_CONVERSION_RATE)
select cc functional_currency,
       dt trx_date,
       decode(cc, l_global_prim_curr_code, 1, FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY (cc,least(sysdate, dt))) PRIM_CONVERSION_RATE,
       decode(cc, l_global_sec_curr_code, 1, FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(cc,least(sysdate, dt))) SEC_CONVERSION_RATE
       from (
       select /*+ no_merge parallel(FII_gl_je_summary_STG)*/ distinct
             FUNCTIONAL_CURRENCY cc,
             effective_date dt
       from FII_gl_je_summary_STG
       );


   --Call FND_STATS to collect statistics after populating the table
       g_phase := 'Calling FND_STATS to collect statistics for fii_gl_revenue_rates_temp';
       FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_GL_REVENUE_RATES_TEMP');

       g_phase := 'Enabling parallel dml';
	   execute immediate 'alter session enable parallel dml';

   if g_debug_flag = 'Y' then
     fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into fii_gl_revenue_rates_temp');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;

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

----------------------------------------
-- PROCEDURE Insert_Into_Summary
-----------------------------------------

PROCEDURE INSERT_INTO_SUMMARY IS

  l_stmt VARCHAR2(1000);

BEGIN

	if g_debug_flag = 'Y' then
	  fii_util.put_line(' ');
          fii_util.put_line('Loading data into base summary table');
          fii_util.start_timer;
          fii_util.put_line('');
        end if;

--Bug 3121847: changed the second hint per performance team suggestion

 insert /*+ append parallel(bsum) */  INTO fii_gl_je_summary_b bsum
                   (bsum.time_id,
                                                bsum.period_type_id,
                                                bsum.company_id,
                                                bsum.cost_center_id,
                                                bsum.fin_category_id,
                                                bsum.prod_category_id,
                                                bsum.user_dim1_id,
                                                bsum.user_dim2_id,
                                                bsum.je_source,
                                                bsum.je_category,
                                                bsum.ledger_id,
                                                bsum.chart_of_accounts_id,
                                                bsum.functional_currency,
                                                bsum.amount_B,
                                                bsum.prim_amount_G,
                                                bsum.sec_amount_G,
												bsum.committed_amount_b,
												bsum.committed_amount_prim,
												bsum.obligated_amount_b,
												bsum.obligated_amount_prim,
											    bsum.other_amount_b,
												bsum.other_amount_prim,
												bsum.posted_date,
                                                bsum.creation_date,
                                                bsum.created_by,
                                                bsum.last_update_date,
                                                bsum.last_update_login,
                                                bsum.last_updated_by)
                  SELECT  /*+ leading(r) use_hash(stg) parallel(stg) parallel(r) */
                                   stg.day,
                                   1,
                                   stg.company_id,
                                   stg.cost_center_id,
                                   stg.fin_category_id,
                                   stg.prod_category_id,
								   stg.user_dim1_id,
                                   stg.user_dim2_id,
                                   stg.je_source,
                                   stg.je_category,
                                   stg.ledger_id,
                                   stg.chart_of_accounts_id,
                                   stg.functional_currency,
                                   sum(stg.amount_B),
                                   sum(round((stg.amount_B * r.prim_conversion_rate)/g_primary_mau) * g_primary_mau),
                                   sum(round((stg.amount_B * r.sec_conversion_rate) /g_secondary_mau)*g_secondary_mau),
                                   sum(stg.committed_amount_B),
                                   sum(round((stg.committed_amount_B * r.prim_conversion_rate)/g_primary_mau) * g_primary_mau),
                                   sum(stg.obligated_amount_B),
                                   sum(round((stg.obligated_amount_B * r.prim_conversion_rate)/g_primary_mau) * g_primary_mau),
                                   sum(stg.other_amount_B),
                                   sum(round((stg.other_amount_B * r.prim_conversion_rate)/g_primary_mau) * g_primary_mau),
                                   stg.posted_date,
                                   stg.creation_date,
                                   stg.created_by,
                                   stg.last_update_date,
                                   stg.last_update_login,
                                   stg.last_updated_by
FROM FII_GL_JE_SUMMARY_STG stg, fii_gl_revenue_rates_temp r
where stg.year IS NOT NULL
AND   stg.effective_date = r.trx_date
AND   stg.functional_currency = r.functional_currency
GROUP BY                           stg.day,
                                   stg.cost_center_id,
                                   stg.company_id,
                                   stg.fin_category_id,
                                   stg.prod_category_id,
                                   stg.user_dim1_id,
                                   stg.user_dim2_id,
                                   stg.je_source,
                                   stg.je_category,
                                   stg.ledger_id,
                                   stg.chart_of_accounts_id,
                                   stg.functional_currency,
								   stg.posted_date,
                                   stg.creation_date,
                                   stg.created_by,
                                   stg.last_update_date,
                                   stg.last_update_login,
                                   stg.last_updated_by;
-------------------------------------------------------------
-- Year field is NULL only for those extra sum records
-- created by the rollup function
-------------------------------------------------------------

  --Fix bug 3561245
	commit;

  --Call FND_STATS to collect statistics after populating the table
    g_phase := 'Calling FND_STATS to collect statistics for FII_GL_JE_SUMMARY_B';
    FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_GL_JE_SUMMARY_B');

    g_phase := 'Enabling parallel dml';
	execute immediate 'alter session enable parallel dml';

 if g_debug_flag = 'Y' then
   fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into FII_GL_JE_SUMMARY_B');
   fii_util.stop_timer;
   fii_util.print_timer('Duration');
 end if;

  commit;

EXCEPTION
  WHEN OTHERS Then
    g_retcode := -1;
    FII_UTIL.put_line('
----------------------------
Error in Function: Insert_Into_Summary
Phase: ' || g_phase || '
Message: '||sqlerrm);
    raise;

END INSERT_INTO_SUMMARY;


-------------------------------------------
-- PROCEDURE INSERT_CARRYFWD_BASE
-------------------------------------------
PROCEDURE INSERT_CARRYFWD_BASE IS
  l_sqlstmt       VARCHAR2(5000);
BEGIN

  IF g_debug_flag = 'Y' THEN
   fii_util.put_line(' ');
   fii_util.put_line('Insert carryforward data into fii_gl_enc_carryfwd_f...');
   fii_util.start_timer;
   fii_util.put_line(' ');
  END IF;

  g_phase := 'Inserting encumbrance carry forward into fii_gl_enc_carryfwd_f';

  l_sqlstmt :=
    'INSERT /*+ append parallel(bsum) */  INTO fii_gl_enc_carryfwd_f bsum '||
     ' (bsum.time_id, bsum.period_type_id, bsum.company_id, '||
     '  bsum.cost_center_id, bsum.fin_category_id, bsum.prod_category_id, '||
     '  bsum.user_dim1_id, bsum.user_dim2_id, bsum.je_source, '||
     '  bsum.je_category, bsum.ledger_id, bsum.chart_of_accounts_id, '||
     '  bsum.functional_currency, '||
     '  bsum.committed_amount_b, bsum.committed_amount_prim, '||
     '  bsum.obligated_amount_b, bsum.obligated_amount_prim, '||
     '  bsum.other_amount_b,     bsum.other_amount_prim, '||
     '  bsum.posted_date, bsum.creation_date, bsum.created_by, '||
     '  bsum.last_update_date, bsum.last_update_login, '||
     '  bsum.last_updated_by) '||
    ' SELECT '||
      ' NVL(stg.day, NVL(stg.period, NVL(stg.quarter, stg.year))), '||
      ' DECODE(stg.day, null, '||
        ' DECODE(stg.period, null, '||
          ' DECODE(stg.quarter, null, 128, 64), 32), 1), '||
     '  stg.company_id, '||
     '  stg.cost_center_id, stg.fin_category_id, stg.prod_category_id, '||
     '  stg.user_dim1_id, stg.user_dim2_id, stg.je_source, '||
     '  stg.je_category, stg.ledger_id, stg.chart_of_accounts_id, '||
     '  stg.functional_currency, '||
     '  stg.committed_amount_B, stg.committed_amount_B, '||
     '  stg.obligated_amount_B, stg.obligated_amount_B, '||
     '  stg.other_amount_B,     stg.other_amount_B, '||
     '  stg.posted_date, stg.creation_date, stg.created_by, '||
     '  stg.last_update_date, stg.last_update_login, '||
     '  stg.last_updated_by '||
   ' FROM FII_GL_ENC_CARRYFWD_T stg '||
   ' WHERE stg.functional_currency = :global_prim_curr '||
   ' AND   stg.year IS NOT NULL ';

  -- Print out the dynamic SQL statements if running in debug mode
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

    FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_GL_JE_B_C.INSERT_CARRYFWD_BASE()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
  END IF;

  EXECUTE IMMEDIATE l_sqlstmt USING g_prim_currency;

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                      ' rows into FII_GL_ENC_CARRYFWD_F');
    fii_util.put_line('');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  END IF;

  COMMIT;

  EXCEPTION
    WHEN OTHERS Then
      g_retcode := -1;
      FII_UTIL.put_line('
  ----------------------------
  Error in Function: INSERT_CARRYFWD_BASE
  Phase: ' || g_phase || '
  Message: '||sqlerrm);
    raise;

END INSERT_CARRYFWD_BASE;

-------------------------------------------
-- PROCEDURE MERGE_CARRYFWD_BASE
-------------------------------------------
PROCEDURE MERGE_CARRYFWD_BASE IS
  l_sqlstmt       VARCHAR2(5000);
  l_stg_sql       VARCHAR2(1000);
  l_base_sql      VARCHAR2(1000);
BEGIN

  ---------------------------------------------------------------------------
  -- Delete data from fii_gl_enc_carryfwd_f if time/dimension exists in base
  -- table is no longer included in the current run.
  ---------------------------------------------------------------------------
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line(' ');
    fii_util.put_line('Delete data from fact table if time/dimension no longer exists in the currency run...');
    fii_util.start_timer;
    fii_util.put_line('');
  END IF;

  g_phase := 'Delete carryforward data from fact not included in currency run';

  l_sqlstmt :=
  ' DELETE '||
  ' FROM fii_gl_enc_carryfwd_f '||
  ' WHERE (time_id, company_id, cost_center_id, fin_category_id, '||
         ' prod_category_id, user_dim1_id, user_dim2_id, '||
         ' committed_amount_b, obligated_amount_b, other_amount_b) '||
  ' NOT IN '||
  ' (SELECT '||
     ' NVL(stg.day, NVL(stg.period, NVL(stg.quarter, stg.year))), '||
     ' company_id, cost_center_id, fin_category_id, '||
     ' prod_category_id, user_dim1_id, user_dim2_id, '||
     ' committed_amount_b, obligated_amount_b, other_amount_b '||
   ' FROM  fii_gl_enc_carryfwd_t stg '||
   ' WHERE functional_currency = :global_primary) ';

  -- Print out the dynamic SQL statements if running in debug mode
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

    FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_GL_JE_B_C.INSERT_CARRYFWD_BASE()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
  END IF;

  EXECUTE IMMEDIATE l_sqlstmt USING g_prim_currency;

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('Deleted '||SQL%ROWCOUNT||
                      ' rows from FII_GL_ENC_CARRYFWD_F');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  END IF;

  ---------------------------------------------------------------------------
  -- Insert new data from fii_gl_enc_carryfwd_t into fii_gl_enc_carryfwd_f
  ---------------------------------------------------------------------------
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line(' ');
    fii_util.put_line('Insert new data into fii_gl_enc_carryfwd_f...');
    fii_util.start_timer;
    fii_util.put_line('');
  END IF;

  g_phase := 'Insert new data into fii_gl_enc_carryfwd_f';

  -- Sql to delete data from fact table if time/dimension no longer
  -- exists in the currency run
  l_sqlstmt :=
  ' INSERT INTO fii_gl_enc_carryfwd_f '||
   ' (time_id, period_type_id, company_id, cost_center_id, '||
    ' fin_category_id, prod_category_id, user_dim1_id, '||
    ' user_dim2_id, je_source, je_category, '||
    ' ledger_id, chart_of_accounts_id, functional_currency, '||
    ' committed_amount_b, committed_amount_prim, '||
    ' obligated_amount_b, obligated_amount_prim, '||
    ' other_amount_b, other_amount_prim, posted_date, '||
    ' creation_date, created_by, last_update_date, '||
    ' last_update_login, last_updated_by) '||
  ' SELECT '||
    ' NVL(day, NVL(period, NVL(quarter, year))), '||
    ' DECODE(day, null, '||
      ' DECODE(period, null, '||
        ' DECODE(quarter, null, 128, 64), 32), 1), '||
    ' company_id, cost_center_id, fin_category_id, '||
    ' prod_category_id, user_dim1_id, user_dim2_id, '||
    ' je_source, je_category, ledger_id, '||
    ' chart_of_accounts_id, functional_currency, '||
    ' committed_amount_B, committed_amount_B, '||
    ' obligated_amount_B, obligated_amount_B, '||
    ' other_amount_B, other_amount_B, posted_date, '||
    ' creation_date, created_by, last_update_date, '||
    ' last_update_login, last_updated_by '||
  ' FROM FII_GL_ENC_CARRYFWD_T '||
  ' WHERE functional_currency = :global_primary '||
  ' AND   year IS NOT NULL '||
  ' AND   (NVL(day, NVL(period, NVL(quarter, year))), '||
         ' company_id, cost_center_id, fin_category_id, '||
         ' prod_category_id, user_dim1_id, user_dim2_id, '||
         ' committed_amount_B, obligated_amount_b, other_amount_b) '||
         ' NOT IN '||
         ' (SELECT '||
            ' time_id, company_id, cost_center_id, fin_category_id, '||
            ' prod_category_id, user_dim1_id, user_dim2_id, '||
            ' committed_amount_b, obligated_amount_b, other_amount_b '||
          ' FROM fii_gl_enc_carryfwd_f) ';

  -- Print out the dynamic SQL statements if running in debug mode
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

    FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_GL_JE_B_C.INSERT_CARRYFWD_BASE()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
  END IF;

  EXECUTE IMMEDIATE l_sqlstmt USING g_prim_currency;

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                      ' rows into FII_GL_ENC_CARRYFWD_F');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  END IF;

  EXCEPTION
    WHEN OTHERS Then
      g_retcode := -1;
      FII_UTIL.put_line('
  ----------------------------
  Error in Function: MERGE_CARRYFWD_BASE
  Phase: ' || g_phase || '
  Message: '||sqlerrm);
    raise;

END MERGE_CARRYFWD_BASE;

-------------------------------------------
-- PROCEDURE INSERT_ENC_CARRYFWD
-------------------------------------------
PROCEDURE INSERT_ENC_CARRYFWD (l_ret_code IN OUT NOCOPY VARCHAR2,
                               l_program_type      IN   VARCHAR2,
                               l_start_date        IN   DATE,
   			       l_end_date          IN   DATE) IS

  l_sqlstmt       VARCHAR2(5000);
  l_tmpstmt       VARCHAR2(5000);
  l_sob_name      VARCHAR2(30);
  l_currency_code VARCHAR2(15);
  l_print_hdr1    BOOLEAN := FALSE;
  l_obtype_id NUMBER;
  l_comtype_id NUMBER;

  -- Cursor for checking if we have encumrbance amounts not in
  -- global primary currency
  CURSOR fcurrCursor (global_prim_curr VARCHAR2) IS
    SELECT DISTINCT sob.name, t.functional_currency
    FROM   fii_gl_enc_carryfwd_t t,
           gl_ledgers_public_v sob
    WHERE  t.functional_currency NOT IN (global_prim_curr)
    AND    t.ledger_id = sob.ledger_id;

BEGIN

  ---------------------------------------------------------------------------
  -- Truncate fii_gl_enc_carrfywd_t
  ---------------------------------------------------------------------------
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line(' ');
    fii_util.put_line('Truncate fii_gl_enc_carryfwd_t...');
  END IF;
  TRUNCATE_TABLE('FII_GL_ENC_CARRYFWD_T');

  ---------------------------------------------------------------------------
  -- If initial load, truncate fii_gl_enc_carrfywd_f as well
  ---------------------------------------------------------------------------
  IF (l_program_type = 'L') THEN
    IF g_debug_flag = 'Y' THEN
      fii_util.put_line(' ');
      fii_util.put_line('Truncate fii_gl_enc_carryfwd_f...');
    END IF;
    TRUNCATE_TABLE('FII_GL_ENC_CARRYFWD_F');
  END IF;

  ---------------------------------------------------------------------------
  -- Insert encumbrance carry forward amounts into staging table
  ---------------------------------------------------------------------------
  g_phase := 'Inserting encumbrance carry forward into fii_gl_enc_carryfwd_t';
  IF g_debug_flag = 'Y' THEN
   fii_util.put_line(' ');
   fii_util.put_line('Insert carryforward data into fii_gl_enc_carryfwd_t...');
   fii_util.start_timer;
   fii_util.put_line('');
  END IF;

  -- Find out the encumbrance type ID for the seeded encumbrance types
  SELECT encumbrance_type_id
  INTO   l_obtype_id
  FROM   gl_encumbrance_types
  WHERE  encumbrance_type = 'Obligation';

  SELECT encumbrance_type_id
  INTO   l_comtype_id
  FROM   gl_encumbrance_types
  WHERE  encumbrance_type = 'Commitment';

  l_tmpstmt :=
    'INSERT /*+ append parallel(fii_gl_enc_carryfwd_t) */ '||
    '  INTO fii_gl_enc_carryfwd_t '||
    ' (day, period, quarter, year, '||
     ' company_id, cost_center_id, fin_category_id, '||
     ' prod_category_id, user_dim1_id, user_dim2_id, '||
     ' je_source, je_category, '||
     ' ledger_id, chart_of_accounts_id, '||
     ' functional_currency, '||
     ' committed_amount_b, obligated_amount_b, '||
     ' other_amount_b, posted_date, last_update_date, '||
     ' last_updated_by, creation_date, created_by, last_update_login) '||
    'SELECT day, to_number(NULL, 999), to_number(NULL, 999), 999, '||
          ' company_id, cost_center_id, natural_account_id, '||
          ' prod_category_id, user_dim1_id, user_dim2_id, '||
          ' ''Manual'', ''Carry Forward'', '||
          ' ledger_id, chart_of_accounts_id, '||
          ' currency_code, '||
          ' sum(committed_amount_b) committed_amount_b, '||
          ' sum(obligated_amount_b) obligated_amount_b, '||
          ' sum(other_amount_b) other_amount_b, year_start_date, sysdate, '||
          ' :user_id, sysdate, :user_id, :login_id '||
    ' FROM ( '||
       'SELECT /*+ parallel(per) parallel(sob) pq_distribute(sob hash,hash) '||
                 ' pq_distribute(fset hash,hash) parallel(b) '||
                 ' use_hash(fin,slga2,fslg2) parallel(fin) parallel(slga2) '||
                 ' parallel(fslg2) pq_distribute(slga2 hash,hash) '||
                 ' pq_distribute(fslg2 hash,hash) '||
                 ' pq_distribute(fin hash,hash) */ '||
             ' to_char(per.start_date, ''J'') day, '||
             ' fin.company_id, fin.cost_center_id, fin.natural_account_id, '||
             ' NVL(fin.prod_category_id, -1) prod_category_id, '||
             ' fin.user_dim1_id, fin.user_dim2_id, '||
            ' sob.ledger_id, sob.chart_of_accounts_id, '||
            ' sob.currency_code, '||
            ' decode( '||
              ' b.encumbrance_type_id, '||
              ' :comtype_id, '||
              ' NVL(b.begin_balance_cr, 0) - NVL(b.begin_balance_dr, 0), '||
              ' 0) committed_amount_b, '||
            ' decode( '||
              ' b.encumbrance_type_id, '||
              ' :obtype_id, '||
              ' NVL(b.begin_balance_cr, 0) - NVL(b.begin_balance_dr, 0), '||
              ' 0) obligated_amount_b, '||
            ' decode( '||
              ' b.encumbrance_type_id, '||
              ' :comtype_id, 0, '||
              ' :obtype_id, 0, '||
              ' NVL(b.begin_balance_cr, 0) - NVL(b.begin_balance_dr, 0)) '||
              ' other_amount_b, '||
            ' per.year_start_date '||
       'FROM   gl_balances      b, '||
             ' gl_ledgers_public_v sob, '||
             ' gl_periods       per, '||
            ' (SELECT /*+ full(slga) */ DISTINCT slga.ledger_id '||
             ' FROM  fii_slg_assignments slga, '||
                   ' fii_source_ledger_groups fslg '||
             ' WHERE slga.source_ledger_group_id =fslg.source_ledger_group_id '||
             ' AND   fslg.usage_code = ''DBI'') fset, '||
             ' fii_gl_ccid_dimensions   fin, '||
             ' fii_slg_assignments      slga2, '||
   	     ' fii_source_ledger_groups fslg2 '||
        ' WHERE sob.ledger_id = fset.ledger_id ';

  IF (l_program_type = 'L') THEN
    l_sqlstmt := l_tmpstmt ||
        ' AND   per.start_date <= :end_date '||
        ' AND   per.end_date   >= :start_date ';
  ELSE
    l_sqlstmt := l_tmpstmt ||
        ' AND   per.end_date   >= :start_date ';
  END IF;

  l_sqlstmt := l_sqlstmt ||
   ' AND   per.period_set_name = sob.period_set_name '||
   ' AND   per.period_type     = sob.accounted_period_type '||
   ' AND   per.period_num      = 1 '||
   ' AND   b.period_name       = per.period_name '||
   ' AND   b.ledger_id = sob.ledger_id '||
   ' AND   b.currency_code <> ''STAT'' '||
   ' AND   b.actual_flag = ''E'' '||
   ' AND   (b.begin_balance_dr <> 0 or b.begin_balance_cr <> 0) '||
   ' AND   fin.code_combination_id = b.code_combination_id '||
   ' AND   fslg2.usage_code = ''DBI'' '||
   ' AND   slga2.source_ledger_group_id = fslg2.source_ledger_group_id '||
   ' AND   ( fin.company_id = slga2.bal_seg_value_id '||
         ' OR slga2.bal_seg_value_id = -1 ) '||
   ' AND   fin.chart_of_accounts_id 	= slga2.chart_of_accounts_id )'||
   ' GROUP BY '||
     ' day, company_id, cost_center_id, natural_account_id, '||
     ' prod_category_id, user_dim1_id, user_dim2_id, ledger_id, '||
     ' chart_of_accounts_id, currency_code, year_start_date ';

    -- Print out the dynamic SQL statements if running in debug mode
    IF g_debug_flag = 'Y' THEN
      fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

      FII_MESSAGE.Write_Log
	(msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_GL_JE_B_C.INSERT_ENC_CARRYFWD()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
    END IF;

  IF (l_program_type = 'L') THEN
    EXECUTE IMMEDIATE l_sqlstmt
    USING g_fii_user_id, g_fii_user_id, g_fii_login_id,
          l_comtype_id, l_obtype_id, l_comtype_id, l_obtype_id,
          l_end_date,  l_start_date;
  ELSE
    EXECUTE IMMEDIATE l_sqlstmt
    USING g_fii_user_id, g_fii_user_id, g_fii_login_id,
          l_comtype_id, l_obtype_id, l_comtype_id, l_obtype_id,
          l_start_date;
  END IF;

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('Inserted '||SQL%ROWCOUNT||
                      ' rows into FII_GL_ENC_CARRYFWD_T');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  END IF;

  ---------------------------------------------------------------------------
  -- Needs to commit before reading from table after inserting in parallel
  ---------------------------------------------------------------------------
  COMMIT;

  ---------------------------------------------------------------------------
  -- Validate currencies used in encumbrance carry forward
  ---------------------------------------------------------------------------
  g_phase := 'Validate currencies used in encumbrance carry forward amounts';

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line(' ');
    fii_util.put_line('Validate currencies used in encumbrance carry forward');
    fii_util.put_line('');
  END IF;

  l_print_hdr1 := FALSE;

  FOR rec_csr IN fcurrCursor(g_prim_currency) LOOP
    l_sob_name      := rec_csr.name;
    l_currency_code := rec_csr.functional_currency;

    IF (NOT l_print_hdr1) THEN
        -- Set the return code so the program will ends with warning.
        l_ret_code := 'W';

        FII_UTIL.Write_Output ('   ');
        FII_MESSAGE.Write_Log (msg_name  => 'FII_INV_ENC_CURR_CODE',
                               token_num => 0);
        FII_MESSAGE.Write_Log (msg_name  => 'FII_REFER_TO_OUTPUT',
                               token_num => 0);
        FII_UTIL.put_line('');
        FII_MESSAGE.Write_Output (msg_name  => 'FII_INV_ENC_CURR_CODE',
                                  token_num => 0);
           l_print_hdr1 := TRUE;
      END IF;

      FII_UTIL.Write_Output (l_sob_name || ' (' || l_currency_code || ')');
  END LOOP;


  ---------------------------------------------------------------------------
  -- Rollup daily slices into monthly/quarterly/yearly slices
  -- in fii_gl_enc_carryfwd_t
  --
  -- Since we will only include records where functional_currency =
  -- global primary for this release, we will only rollup data that satisfy
  -- this criteria.
  ---------------------------------------------------------------------------
  g_phase := 'Roll up encumbrance carry forward data into month/qtr/yr slices';

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line(' ');
    fii_util.put_line(
    'Rollup encumbrance carry forward data into month/quarter/year slices...');
    fii_util.put_line('');
    fii_util.start_timer;
    fii_util.put_line('');
  END IF;

  l_sqlstmt :=
  ' INSERT /*+ append parallel(fii_gl_enc_carryfwd_t) */ '||
  ' INTO fii_gl_enc_carryfwd_t '||
     ' (period, quarter, year, '||
     '  company_id, cost_center_id, fin_category_id, '||
     '  prod_category_id, user_dim1_id, user_dim2_id, '||
     '  je_source, je_category, '||
     '  ledger_id, chart_of_accounts_id, functional_currency, '||
     '  committed_amount_b, obligated_amount_b, other_amount_b, '||
     '  posted_date, last_update_date, '||
     '  last_updated_by, creation_date, created_by, last_update_login) '||
  ' SELECT * FROM ( '||
    ' SELECT  /*+ parallel(t) parallel(fday) use_hash(fday,t) */ '||
     '  fday.ent_period_id, fday.ent_qtr_id, fday.ent_year_id, '||
     '  t.company_id, t.cost_center_id, t.fin_category_id, '||
     '  t.prod_category_id, t.user_dim1_id, t.user_dim2_id, '||
     '  t.je_source, t.je_category, '||
     '  t.ledger_id, t.chart_of_accounts_id, t.functional_currency, '||
     '  SUM(t.committed_amount_b) committed_amount_b, '||
     '  SUM(t.obligated_amount_b) obligated_amount_b, '||
     '  SUM(t.other_amount_b) other_amount_b, '||
     '  t.posted_date, t.last_update_date, '||
     '  t.last_updated_by, t.creation_date, t.created_by, '||
     '  t.last_update_login '||
    ' FROM   fii_gl_enc_carryfwd_t t, '||
          '  fii_time_day fday '||
    ' WHERE  t.day = fday.report_date_julian '||
    ' AND    t.functional_currency = :global_primary '||
    ' GROUP BY t.company_id, t.cost_center_id, t.fin_category_id, '||
          '    t.prod_category_id, t.user_dim1_id, t.user_dim2_id, '||
          '    t.je_source, t.je_category, t.ledger_id, '||
          '    t.chart_of_accounts_id, t.functional_currency, '||
          '    t.posted_date, t.last_update_date, t.last_updated_by, '||
          '    t.creation_date, t.created_by, t.last_update_login, '||
    ' ROLLUP (fday.ent_year_id, '||
          '   fday.ent_qtr_id, '||
          '   fday.ent_period_id)) '||
    ' WHERE ent_year_id IS NOT NULL ';

  -- Print out the dynamic SQL statements if running in debug mode
  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('l_sqlstmt = '|| l_sqlstmt);

    FII_MESSAGE.Write_Log
        (msg_name  	=> 'FII_ROUTINE_VAL',
         token_num 	=> 3 ,
         t1        	=> 'ROUTINE',
         v1        	=> 'FII_GL_JE_B_C.INSERT_ENC_CARRYFWD()',
         t2        	=> 'VARIABLE',
         v2        	=> 'LENGTH(l_sqlstmt)',
         t3        	=> 'VALUE',
         v3        	=> TO_CHAR(LENGTH(l_sqlstmt)));
  END IF;

  EXECUTE IMMEDIATE l_sqlstmt USING g_prim_currency;

  IF g_debug_flag = 'Y' THEN
    fii_util.put_line('Inserted '|| SQL%ROWCOUNT||
                      ' rows into FII_GL_ENC_CARRYFWD_T');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  END IF;

  ---------------------------------------------------------------------------
  -- Needs to commit before reading from table after inserting in parallel
  ---------------------------------------------------------------------------
  COMMIT;

  ---------------------------------------------------------------------------
  -- If initial load, insert carryforward data into fii_gl_enc_carryfwd_f
  -- If incremental load,
  --   1. Delete carryforward data not included this run from base
  --   2. Merge carryforward data into fii_gl_enc_carryfwd_f
  ---------------------------------------------------------------------------
  IF (l_program_type = 'L') THEN
    INSERT_CARRYFWD_BASE;
  ELSE
    MERGE_CARRYFWD_BASE;
  END IF;

  EXCEPTION
    WHEN OTHERS Then
      g_retcode := -1;
      FII_UTIL.put_line('
  ----------------------------
  Error in Function: INSERT_ENC_CARRYFWD
  Phase: ' || g_phase || '
  Message: '||sqlerrm);
    raise;

END INSERT_ENC_CARRYFWD;


-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

PROCEDURE Main (errbuf              IN OUT NOCOPY VARCHAR2,
                retcode             IN OUT NOCOPY VARCHAR2,
                p_start_date        IN      VARCHAR2,
                p_end_date          IN      VARCHAR2,
                p_number_of_process IN      NUMBER,
                p_program_type      IN      VARCHAR2,
                p_parallel_query    IN      NUMBER,
                p_sort_area_size    IN      NUMBER,
                p_hash_area_size    IN      NUMBER) IS

    return_status      BOOLEAN := TRUE;
    l_start_date       DATE := NULL;
    l_end_date         DATE :=NULL;
    l_period_start_date DATE := NULL;
    l_period_end_date  DATE := NULL;
    p_number_of_rows   NUMBER :=0;
    p_no_worker        NUMBER :=1;
    l_conversion_count NUMBER :=0;
    l_retcode          VARCHAR2(3);
    l_errbuf           VARCHAR2(500);
    l_stmt             VARCHAR2(300);
    l_dir              VARCHAR2(400);
    l_ids_count        NUMBER:= 0;
    stg_count          NUMBER:= 0;
    l_truncate_stg     BOOLEAN := FALSE;

    -- Declaring local variables to initialize the dates for the
    -- incremental mode
    l_last_start_date    DATE;
    l_last_end_date      DATE;
    l_last_period_from   DATE;
    l_last_period_to     DATE;
    l_lud_hours          NUMBER := to_number(NULL);
    l_global_start_date  DATE;

    l_global_param_list dbms_sql.varchar2_table;

    TYPE WorkerList is table of NUMBER
     index by binary_integer;
     l_worker      WorkerList;

    l_slg_chg  VARCHAR2(10);
    l_prd_chg  VARCHAR2(10);

    l_ret_val BOOLEAN;
    l_ret_code VARCHAR2(1) := 'N';  -- Default to 'N' for Normal

BEGIN
    errbuf := NULL;
    retcode := 0;

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
     FII_UTIL.initialize('FII_GL_SUM.log','FII_GL_SUM.out',l_dir, 'FII_GL_JE_B_C');
    ELSIF g_program_type = 'L'  THEN
     FII_UTIL.initialize('FII_GL_SUM.log','FII_GL_SUM.out',l_dir, 'FII_GL_JE_B_L');
    END IF;

    -----------------------------------------------------
    -- Calling BIS API to do common set ups
    -- If it returns false, then program should error out
    -----------------------------------------------------
    g_phase := 'Calling BIS API to do common set ups';
    l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
    l_global_param_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_global_param_list(3) := 'BIS_PRIMARY_RATE_TYPE';
    IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
      FII_MESSAGE.write_log(   msg_name   => 'FII_BAD_GLOBAL_PARA',
                               token_num  => 0);
      FII_MESSAGE.write_output(msg_name   => 'FII_BAD_GLOBAL_PARA',
                               token_num  => 0);

      l_ret_val := FND_CONCURRENT.Set_Completion_Status(
          status  => 'ERROR',
          message => 'One of the three global parameters: Global Start Date; Primary Currency Code; Primary Rate Type has not been set up.'
      );

      return;
    ELSIF p_program_type = 'I'  THEN
      IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_GL_JE_B_C')) THEN
        raise_application_error(-20000,errbuf);
        return;
      END IF;
    ELSIF p_program_type = 'L'  THEN
      IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_GL_JE_B_L')) THEN
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
    IF p_program_type = 'L' THEN
        IF g_debug_flag = 'Y' then
	  FII_UTIL.put_line('Running in Initial Load mode, truncate STG, summary and other processing tables.');
        END IF;
   	TRUNCATE_TABLE('FII_GL_JE_SUMMARY_STG');
   	TRUNCATE_TABLE('FII_GL_JE_SUMMARY_B');
	TRUNCATE_TABLE('FII_GL_PROCESSED_HEADER_IDS');

      COMMIT;
    END IF;

	------------------------------------------
	-- Check setups only if we are running in
	-- Incremental Mode, p_program_type = 'I'
	------------------------------------------
	IF (p_program_type = 'I') THEN
    	---------------------------------------------
    	-- Check if any set up got changed.  If yes,
    	-- then we need to truncate the summary table
    	-- and then reload (also see bug 3401590)
    	---------------------------------------------
        g_phase := 'Check setups if we are running in Incremental Mode';

        l_slg_chg := CHECK_IF_SLG_SET_UP_CHANGE;
        l_prd_chg := CHECK_IF_PRD_SET_UP_CHANGE;

    	IF (l_slg_chg = 'TRUE') THEN
      	  FII_MESSAGE.write_output (msg_name  => 'FII_TRUNC_SUMMARY', token_num => 0);
      	  FII_MESSAGE.write_log    (msg_name  => 'FII_TRUNC_SUMMARY', token_num => 0);
----FII_UTIL.put_line('Source Ledger Group setup has changed. Please run the Request Set in the Initial mode to repopulate the summaries.');
    	END IF;

    	IF (l_prd_chg = 'TRUE') THEN
      	  FII_MESSAGE.write_output (msg_name  => 'FII_TRUNC_SUMMARY_PRD', token_num => 0);
      	  FII_MESSAGE.write_log    (msg_name  => 'FII_TRUNC_SUMMARY_PRD', token_num => 0);
----FII_UTIL.put_line('Product Assignment has changed. Please run the Request Set in the Initial mode to repopulate the summaries.');
        END IF;

        -- should fail the program if either slg or prd changed
        IF l_slg_chg = 'TRUE' OR l_prd_chg = 'TRUE' THEN
	    retcode := -1;
      	    RETURN;
    	END IF;

        ELSIF (p_program_type = 'L') THEN
        ---------------------------------------------
        -- If running in Inital Load, then update
        -- change log to indicate that resummarization
        -- is not necessary since everything is
        -- going to be freshly loaded
        ---------------------------------------------
        g_phase := 'Update fii_change_log if we are running in Inital Load';

	UPDATE fii_change_log
     	SET item_value = 'N',
		    last_update_date  = SYSDATE,
		    last_update_login = g_fii_login_id,
		    last_updated_by   = g_fii_user_id
     	WHERE log_item = 'GL_RESUMMARIZE'
          AND item_value = 'Y';

	UPDATE fii_change_log
     	SET item_value = 'N',
		    last_update_date  = SYSDATE,
		    last_update_login = g_fii_login_id,
		    last_updated_by   = g_fii_user_id
     	WHERE log_item = 'GL_PROD_CHANGE'
          AND item_value = 'Y';

        COMMIT;

        END IF;

    -------------------------------------------------
    -- Print out useful date range information
    -------------------------------------------------
    g_phase := 'Get date range information';

    IF p_program_type = 'L' THEN

      -------------------------------------------------------------
      -- When running in Initial mode, the default values of the
      -- parameters are defined in the concurrent program seed data
      -------------------------------------------------------------
      l_start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
      l_end_date   := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');

    ELSE

      -----------------------------------------------------------------
      -- When running in Incremental mode, the values of the parameters
      -- are derived in the program
      -----------------------------------------------------------------
      BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_GL_JE_B_C',
                                                      l_last_start_date,
                                                      l_last_end_date,
                                                      l_last_period_from,
                                                      l_last_period_to);

      IF l_last_start_date IS NULL THEN
        l_start_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');
      ELSE
        -----------------------------------------------------------------------
        -- Bug fix 3021099: In this sql to find the earliest period we need to
        -- process for incremental, we will only look at periods that is on or
        -- after global start date.  Thus we will not be processing extra periods
        -- which does not have data for us to process.
        -----------------------------------------------------------------------
        l_global_start_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'MM/DD/YYYY');

        SELECT trunc(min(stu.start_date))
        INTO   l_start_date
        FROM   gl_period_statuses stu,
 	         fii_slg_assignments slga,
	         fii_source_ledger_groups fslg
        WHERE  slga.ledger_id = stu.set_of_books_id
        AND    stu.application_id = 101
        AND    (stu.closing_status = 'O' OR (stu.closing_status IN ('C', 'P')
        AND    stu.last_update_date > l_last_start_date))
        AND    stu.start_date >= l_global_start_date
		AND    slga.source_ledger_group_id = fslg.source_ledger_group_id
		AND    fslg.usage_code = g_usage_code;
      END IF;

      l_end_date := to_date(NULL);

    END IF;

   if g_debug_flag = 'Y' then
     FII_UTIL.put_line('User submitted start date range: ' || l_start_date);
     FII_UTIL.put_line('User submitted end date range: ' || l_end_date);
   end if;

   l_period_start_date := l_start_date;
   l_period_end_date := l_end_date;

   if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Collection Period start date: ' || l_period_start_date);
     FII_UTIL.put_line('Collection Period end date: ' || l_period_end_date);
   end if;

    ----------------------------------------------------------
    -- Determine if we need to resume.  If there are records
    -- in staging table, then that means there are records
    -- with missing exchange rate information left from the
    -- previous run.  In this case, we will not process any
    -- more new records, we will only process records already
    -- in the staging table
    ----------------------------------------------------------
   g_phase := 'Determine if we need to resume';
   if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_phase);
   end if;

    SELECT COUNT(*)
    INTO stg_count
    FROM fii_gl_je_summary_stg;

    IF (stg_count > 0) THEN
      g_resume_flag := 'Y';
    ELSE
      g_resume_flag := 'N';
    END IF;

    -----------------------------------------------------------------
    -- If resume flag is 'N', then this program starts from the
    -- beginning:
    --     1. Identify GL Header IDs to process
    --     2. Submit child process to insert day-level summarized
    --        records into temporary staging table
    -- Otherwise, it would first check if all missing rates have been
    -- fixed, and then resume the normal process which includes:
    --     3. Insert higher time level summarized records into
    --        temporary staging table.
    --     4. Merging summarized records into base summary table
    --     5. Insert processed Header IDs into a processed table
    ------------------------------------------------------------------

    IF (g_resume_flag = 'N') THEN
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
      -- FII_NEW_GL_HEADER_ID_TEMP
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
      l_ids_count := NEW_JOURNALS(l_period_start_date, l_period_end_date);

      IF (l_ids_count = 0) THEN
       if g_debug_flag = 'Y' then
        FII_UTIL.put_line('No Journal Entries to Process, exit.');
       end if;
        RETURN;
      END IF;

      ----------------------------------------------------------------
      -- After the new journals are identified, we need to call the
      -- CCID API to make sure that the CCID dimension is up to date.
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
      ----------------------------------------------------------------
      g_phase := 'Verifying if CCID Dimension is up to date';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line(g_phase);
      end if;

      VERIFY_CCID_UP_TO_DATE;

      IF (g_industry = 'G') THEN
        g_phase := 'Populate encumbrance type mapping table';
        if g_debug_flag = 'Y' then
          FII_UTIL.put_line(g_phase);
        end if;

        POPULATE_ENCUM_MAPPING;
      END IF;

      IF (p_program_type = 'L') THEN
       INSERT_INTO_STG(p_sort_area_size, p_hash_area_size,l_start_date, l_end_date);
       INSERT_INTO_RATES;


      ELSE

      ----------------------------------------------------------------
      -- Register jobs in the table FII_GL_WORKER_JOBS for launching
      -- child processes.
      ----------------------------------------------------------------
      g_phase := 'Calling Routine Register_Jobs';

      if g_debug_flag = 'Y' then
        FII_UTIL.put_line(g_phase);
      end if;

      Register_Jobs();

      COMMIT;

      ----------------------------------------------------------------
      -- Launching child processes.
      ----------------------------------------------------------------
      g_phase := 'Launching child process...';
      p_no_worker := p_number_of_process;

      -- Launch child process

       FOR i IN 1..p_no_worker
       LOOP
         -- p_no_worker is the parameter user submitted to specify how many
         -- workers they want to submit
         l_worker(i) := LAUNCH_WORKER(i);
         COMMIT;

         if g_debug_flag = 'Y' then
           FII_util.put_line('  Worker '||i||' request id: '||l_worker(i));
         end if;
       END LOOP;

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
           INTO   l_unassigned_cnt,
                  l_completed_cnt,
                  l_wip_cnt,
                  l_failed_cnt,
                  l_tot_cnt
           FROM   FII_GL_WORKER_JOBS;

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

           -- -----------------------
           -- Detect infinite loops
           -- -----------------------
           IF (l_unassigned_cnt = l_last_unassigned_cnt AND
           l_completed_cnt = l_last_completed_cnt AND
           l_wip_cnt = l_last_wip_cnt) THEN

             l_cycle := l_cycle + 1;
           ELSE
             l_cycle := 1;
           END IF;

           -- --------------------------------------
           -- MAX_LOOP is a global variable you set.
           -- It represents the number of minutes
           -- you want to wait for each worker to
           -- complete.  We can set it to 30 minutes
           -- for now
           -- --------------------------------------
           IF (l_cycle > MAX_LOOP) THEN
             g_retcode := -1;
             FII_UTIL.put_line('
---------------------------------
Error in Main Procedure:
Message: No progress have been made for '||MAX_LOOP||' minutes.
Terminating');
             RAISE G_CHILD_PROCESS_ISSUE;
           END IF;

           -- -----------------------
           -- Sleep 60 Seconds
           -- -----------------------
           dbms_lock.sleep(60);

           l_last_unassigned_cnt := l_unassigned_cnt;
           l_last_completed_cnt := l_completed_cnt;
           l_last_wip_cnt := l_wip_cnt;
         END LOOP;
       END;   -- Monitor child process Ends here.

       END IF;
    ----------------------------------------------------
    -- Else, running in resume mode
    ----------------------------------------------------
    ELSE

      g_phase := 'g_resume_flag = Y';

      -----------------------------------------------------------
      -- Setting g_truncate_stg to FALSE to make sure we don't
      -- truncate staging table when we are just fixing exchange
      -- rates in staging table
      -----------------------------------------------------------
      g_truncate_stg := FALSE;

      g_phase := 'Fixing missing rates in temporary staging table';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line(g_phase);

        FII_UTIL.start_timer;
      end if;

      Update FII_GL_JE_SUMMARY_STG stg
      SET  prim_conversion_rate =
           fii_currency.get_global_rate_primary(stg.functional_currency,least(sysdate, stg.effective_date))
      WHERE stg.prim_conversion_rate < 0;

      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' records for primary currency rates in staging table');
        FII_UTIL.stop_timer;
        FII_UTIL.print_timer('Duration');

        FII_UTIL.start_timer;
      end if;

      commit;  --use commit after print out correct SQL%ROWCOUNT

      Update FII_GL_JE_SUMMARY_STG stg
      SET  sec_conversion_rate =
           fii_currency.get_global_rate_secondary(stg.functional_currency,least(sysdate, stg.effective_date))
      WHERE stg.sec_conversion_rate < 0;

      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' records for secondary currency rates in staging table');
        FII_UTIL.stop_timer;
        FII_UTIL.print_timer('Duration');
      end if;

      commit;  --use commit after print out correct SQL%ROWCOUNT

    END IF; -- IF (g_resume_flag = 'N')


    -----------------------------------------------------------------
    -- If all the child process completes successfully then Invoke
    -- Summary_err_check routine to check for any missing rates record
    -- or missing time dimension record in the FII_GL_JE_SUMMARY_STG
    -- table.
    -----------------------------------------------------------------
    g_phase:= 'Summarization Error Check';
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_phase);
    end if;

    Summary_err_check (p_program_type);

    IF (g_missing_rates = 0 AND g_missing_time = 0) THEN

      -------------------------------------------------------------
      -- Setting g_truncate_stg to TRUE because during the subsequent
      -- processes, if failure occurs, we should truncate staging
      ---------------------------------------------------------------
      g_truncate_stg := TRUE;

      -------------------------------------------------------------
      -- Call Summarization_aggreagte routine to insert PTD,QTD and
      -- YTD into the FII_GL_JE_SUMMARY_STG table.
      -------------------------------------------------------------
      g_phase := 'Aggregating summarized data';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('');
        FII_UTIL.put_line(g_phase);
      end if;

      IF p_program_type = 'I' THEN

        Summarize_aggregate;

--Bug 3356106: should summarize week level seperately
        Sum_Aggregate_Week;  --this should be after Summarize_aggregate

      ELSIF p_program_type = 'L' THEN

        INSERT_INTO_SUMMARY;

      END IF;

      --------------------------------------------------------
      -- Call Merge routine to insert summarized data into
      -- FII_GL_JE_SUMMARY_B table.
      --------------------------------------------------------
      g_phase := 'Merging records into base summary table';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('');
        FII_UTIL.put_line(g_phase);
      end if;

      IF p_program_type = 'I' THEN
        Merge;
      ELSIF p_program_type = 'L' THEN
        ROLL_UP  (p_sort_area_size, p_hash_area_size);
        ROLL_UP2 (p_sort_area_size, p_hash_area_size);
      END IF;

      -----------------------------------------------------------------
      -- If Merge routine returns true then Insert processed rows into
      -- FII_GL_PROCESSED_HEADER_IDS table by calling the routine
      -- Jornals_processed.
      -----------------------------------------------------------------
      g_phase := 'Inserting processed JE Header IDs';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('');
        FII_UTIL.put_line(g_phase);
      end if;

      Journals_processed;

      -----------------------------------------------------------------
      -- If industry = 'Governemnt'.  We should gather the carryforward
      -- encumbrances to the new fiscal year from gl_balances
      -----------------------------------------------------------------
      IF (g_industry = 'G') THEN
        INSERT_ENC_CARRYFWD(l_ret_code, p_program_type,
                            l_start_date, l_end_date);

      END IF;

      COMMIT;

      ------------------------------------------------------------------
      -- Cleaning phase
      -- Truncate staging summary table if all the processes completed
      -- successfully.
      ------------------------------------------------------------------
      Clean_up;

      ----------------------------------------------------------------
      -- Calling BIS API to record the range we collect.  Only do this
      -- when we have a successful collection
      ----------------------------------------------------------------
      BIS_COLLECTION_UTILITIES.wrapup(p_status => TRUE,
                                      p_period_from => l_period_start_date,
                                      p_period_to => l_period_end_date);

      IF (l_ret_code = 'N') THEN
        retcode := 0;

      ELSIF (l_ret_code = 'W') THEN
        -- INSERT_ENC_CARRYFWD has a validation error.
        -- Program should completes with warnings.
        l_ret_val := FND_CONCURRENT.Set_Completion_Status
     	                (status	 => 'WARNING', message => NULL);
      END IF;

    ELSE

      retcode := g_retcode;
      errbuf  := 'There is missing rate or missing time information';

    END IF; --g_missing_rates = 0 AND g_missing_time = 0

Exception
  WHEN OTHERS Then
    g_retcode := -1;
    clean_up;
    FII_UTIL.put_line('
Error in Function: Main
Phase: '|| g_phase || '
Message: ' || sqlerrm);
    retcode := g_retcode;
END Main;

-- ************************************************************************
-- PROCEDURE WORKER
-- ************************************************************************
PROCEDURE WORKER(Errbuf      IN OUT NOCOPY VARCHAR2,
                 Retcode     IN OUT NOCOPY VARCHAR2,
                 p_worker_no IN NUMBER) IS

    -- Put any additional developer variables here

    l_unassigned_cnt       NUMBER := 0;
    l_failed_cnt           NUMBER := 0;
    l_wip_cnt      NUMBER := 0;
    l_completed_cnt        NUMBER := 0;
    l_total_cnt         NUMBER := 0;
    l_count                NUMBER :=0;
    l_start_range          NUMBER :=0;
    l_end_range            NUMBER :=0;

BEGIN

    Errbuf :=NULL;
    Retcode:=0;

    -- -----------------------------------------------
    -- Set up directory structure for child process
    -- because child process do not call setup routine
    -- from EDWCORE
    -- -----------------------------------------------
    g_phase := 'Calling child_setup';
    CHILD_SETUP('FII_GL_SUM_SUBWORKER'||p_worker_no);

    if g_debug_flag = 'Y' then
   	FII_UTIL.put_line(' ');
   	FII_UTIL.put_timestamp;
   	FII_UTIL.put_line('Worker '||p_worker_no||' Starting');
   end if;

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
      FROM   FII_GL_WORKER_JOBS;

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
        UPDATE FII_GL_WORKER_JOBS
        SET    status = 'IN PROCESS',
               worker_number = p_worker_no
        WHERE  status = 'UNASSIGNED'
        AND    rownum < 2;
        if g_debug_flag = 'Y' then
          FII_UTIL.put_line('Taking job from job queue');
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
          g_phase := 'Getting ID range from FII_GL_WORKER_JOBS table';
          if g_debug_flag = 'Y' then
            FII_UTIL.put_line(g_phase);
          end if;

          SELECT start_range,
                 end_range
          INTO l_start_range,
               l_end_range
          FROM FII_GL_WORKER_JOBS
          WHERE worker_number = p_worker_no
          AND  status = 'IN PROCESS';

          --------------------------------------------------
          --  Do summarization using the start_range
          --  and end_range call the summarization routine
          --  Passing start range and end range parameters
          --------------------------------------------------
          g_phase := 'Inserting day level summarized records';
          if g_debug_flag = 'Y' then
            FII_UTIL.put_line(g_phase);
          end if;

          Summarize_Day(l_start_range,
                        l_end_range);

          -----------------------------------------------------
          -- Do other work if necessary to finish the child
          -- process
          -- After completing the work, set the job status
          -- to complete
          -----------------------------------------------------
          g_phase:='Updating job status in FII_GL_WORKER_JOBS table';
          if g_debug_flag = 'Y' then
            FII_UTIL.put_line(g_phase);
          end if;

          UPDATE FII_GL_WORKER_JOBS
          SET    status = 'COMPLETED'
          WHERE  status = 'IN PROCESS'
          AND    worker_number = p_worker_no;

          COMMIT;

          --   Handle any exception that occured during
          --   your child process

        EXCEPTION
          WHEN OTHERS THEN
            g_retcode := -1;

            UPDATE FII_GL_WORKER_JOBS
            SET  status = 'FAILED'
            WHERE  worker_number = p_worker_no
            AND   status = 'IN PROCESS';

            COMMIT;
            Raise;
        END;

      END IF; /* IF (l_count> 0) */
    END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    retcode:= g_retcode;
    FII_UTIL.put_line('
---------------------------------
Error in Procedure: WORKER
Phase: '|| g_phase || '
Message: '||sqlerrm);
END WORKER;

END FII_GL_JE_B_C;

/
