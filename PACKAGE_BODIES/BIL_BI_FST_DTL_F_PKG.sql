--------------------------------------------------------
--  DDL for Package Body BIL_BI_FST_DTL_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_FST_DTL_F_PKG" AS
/*$Header: bilfstb.pls 120.2 2005/10/06 03:45:04 asolaiy noship $*/

     -- Global variables for WHO variables and Concurrent program

       G_request_id            NUMBER;
       G_appl_id               NUMBER;
       G_program_id            NUMBER;
       G_user_id               NUMBER;
       G_login_id              NUMBER;

       g_first_run             boolean;
       g_mode                  VARCHAR2(30);
       g_truncate_flag         boolean;
       g_debug                 boolean;
       g_conv_rate_cnt         number;
       g_degree                Number;
       g_num_row_proc          Number;
       g_fact_row_proc         Number;
       g_obj_name              VARCHAR2(30);
       g_retcode               VARCHAR2(20);
       g_cal_start_date        DATE;
       g_cal                   VARCHAR2(50);
       g_cal_per_type          VARCHAR2(50);
       g_fsct_per_type         VARCHAR2(50);
       g_asf_calendar          VARCHAR2(50);
       g_map_ent_per_type      VARCHAR2(50);
       G_Resume_Flag           VARCHAR2(1);
       g_warn_flag             VARCHAR2(1);
       g_missing_rates         NUMBER;
       g_missing_time          NUMBER;
       G_End_Date              DATE;
       G_Start_Date            DATE;
       G_Bil_Schema            VARCHAR2(30);
       G_Prim_Currency         VARCHAR2(10);
       G_Prim_Rate_Type        VARCHAR2(15);

       G_sec_Currency          VARCHAR2(10);
       G_sec_Rate_Type         VARCHAR2(15);


       G_Phase                 VARCHAR2(100);
       g_program_start_time    DATE;

       G_INIT_FAILED           EXCEPTION;
       G_SETUP_VALID_ERROR     EXCEPTION;

       g_fst_rollup            VARCHAR2(100);

       g_pkg                   VARCHAR2(100);

       g_asn_date              DATE;

-- ---------------------------------------------------------------
-- Prototypes of Private procedures and Functions;
-- ---------------------------------------------------------------
--  ***********************************************************************

-- Initialize all the globals.
PROCEDURE Init(p_obj_name in varchar2);


-- Check for errors in the data set collected in staging table. Verify currency, time , .etc
PROCEDURE Summary_Err_Check;

-- Clean up...
PROCEDURE Clean_Up(ErrorMsg in varchar2);



-- Report missing currencies in a standard format.
--we'll report the missing rates from the staging table
PROCEDURE REPORT_MISSING_RATES;


-- Summarize data for forecast time period
PROCEDURE Summarize_Frcsts_Periods;


--Populate table with distinct cuurency exchange rate, date combinations
PROCEDURE POPULATE_CURRENCY_RATE;

-- If the collected data set is a valid, then merge into the summary table.
PROCEDURE Insert_From_Stg( ERRBUF           IN OUT NOCOPY VARCHAR2
                          ,RETCODE          IN OUT NOCOPY VARCHAR2
                         );


--insert into staging.
PROCEDURE Insert_Into_Stg
(
  p_mode        IN VARCHAR2
);



-- Get the number of new forecast records since last run
FUNCTION  New_Forecasts(P_Start_Date IN DATE ,  P_End_Date IN DATE) RETURN NUMBER;

-- Adjust amounts in incremental mode to maitain correct history
PROCEDURE summary_adjust;

--the normal validate setup proc used for validating the setup
PROCEDURE validate_setup(ret_status out nocopy boolean);


PROCEDURE check_profiles(ret_status out nocopy boolean);


PROCEDURE main ( errbuf               in out nocopy varchar2
                ,retcode              in out nocopy varchar2
                ,p_start_date         in varchar2
                ,p_end_date           in varchar2
                ,p_truncate           in varchar2
               );


PROCEDURE init_load
          (
            errbuf       in out  nocopy varchar2,
            retcode      in out  nocopy varchar2,
            p_start_date in varchar2,
            p_truncate   in varchar2
          ) is

l_proc varchar2(100);

begin

/* initialization of variable */
       g_request_id := 0;
       g_appl_id := 0;
       G_program_id := 0;
       G_user_id := 0;
       G_login_id := 0;
       g_first_run :=FALSE;
       g_truncate_flag := FALSE;
       g_debug := FALSE;
       g_conv_rate_cnt := 0;
       g_degree :=1;
       g_num_row_proc :=0;
       g_fact_row_proc :=0;
       g_obj_name := 'BIL_BI_FST_DTL_F';
       g_missing_rates := 0;
       g_missing_time := 0;
       g_pkg := 'bil.patch.115.sql.BIL_BI_FST_DTL_F_PKG.';

       l_proc := 'INIT_LOAD.';
/* end initialization of variable */

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
             bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin ',
             p_msg => ' Start of Procedure '|| l_proc);
      END IF;

  IF p_truncate = 'Y' THEN
   g_mode := 'INITIAL';
  ELSE
   g_mode := '';
  END IF;
    -- in the initial load mode, default start date to global start date
    -- default end date to sysdate , this is taken care by the main program
   Main
   (
     ERRBUF,
     RETCODE,
     p_start_date,
     TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS'),
     p_truncate
   );


/* Set the return code for SUCESS/WARNING/ERROR */

    IF(retcode=0 AND g_warn_flag='Y') THEN
      retcode := 1;
    END IF;

    IF(retcode=-1 OR g_retcode=-1) THEN
      retcode := -1;
    END IF;


/*
  A generic line in the log file that requests the user to see the o/p file for
  further info.
*/
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc,
        p_msg =>
          ' If there have been errors, Please refer to the Concurrent program output file for more information '
      );
    END IF;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
             bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end ',
             p_msg => ' End of Procedure '|| l_proc);
    END IF;


END;


PROCEDURE INCR_LOAD
(
  ERRBUF               IN OUT NOCOPY VARCHAR2 ,
  RETCODE              IN OUT NOCOPY VARCHAR2
) IS


    l_start_date DATE;
    l_end_date   DATE;
    l_period_from     DATE;
    l_period_to       DATE;
    l_proc VARCHAR2(100);

BEGIN
/* initialization of variable */
       G_request_id := 0;
       G_appl_id := 0;
       G_program_id := 0;
       G_user_id := 0;
       G_login_id := 0;
       g_first_run :=FALSE;
       g_truncate_flag := FALSE;
       g_debug := FALSE;
       g_conv_rate_cnt := 0;
       g_degree :=1;
       g_num_row_proc :=0;
       g_fact_row_proc :=0;
       g_obj_name := 'BIL_BI_FST_DTL_F';
       g_missing_rates := 0;
       g_missing_time := 0;
       g_pkg := 'bil.patch.115.sql.BIL_BI_FST_DTL_F_PKG.';

    l_start_date :=NULL;
    l_end_date :=NULL;
    l_period_from :=NULL;
    l_period_to :=NULL;
    l_proc := 'INCR_LOAD.';

/* end initialization of variable */

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
             bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin ',
             p_msg => ' Start of Procedure '|| l_proc);
   END IF;



 BIS_COLLECTION_UTILITIES.get_last_refresh_dates(
            g_obj_name,
            l_start_date,
            l_end_date,
            l_period_from,
            l_period_to
            );

   g_mode := '';
   g_first_run := FALSE;
   g_truncate_flag := FALSE;

   l_end_date := SYSDATE;
   Main
   (
     ERRBUF,
     RETCODE,
     TO_CHAR(l_period_to, 'YYYY/MM/DD HH24:MI:SS'),
     TO_CHAR(l_end_date,'YYYY/MM/DD HH24:MI:SS'),
     'N'
   );

/* Set the return code for SUCESS/WARNING/ERROR */

    IF(retcode=0 AND g_warn_flag='Y') THEN
      retcode := 1;
    END IF;

    IF(retcode=-1 OR g_retcode=-1) THEN
      retcode := -1;
    END IF;


/*
  A generic line in the log file that requests the user to see the o/p file for
  further info.
*/
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc,
        p_msg =>
          ' If there have been errors, Please refer to the Concurrent program output file for more information '
      );
    END IF;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
             bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end ',
             p_msg => ' End of Procedure '|| l_proc);
  END IF;


END INCR_LOAD;



-- ********************************************************************
-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

PROCEDURE Main ( ERRBUF               IN OUT NOCOPY VARCHAR2
                ,RETCODE              IN OUT NOCOPY  VARCHAR2
                ,p_start_date         IN VARCHAR2
                ,p_end_date           IN VARCHAR2
                ,p_truncate           IN VARCHAR2
                ) IS

    l_proc VARCHAR2(100);

    l_ids_count      NUMBER;
    stg_count        NUMBER;
    l_asf_calendar   VARCHAR2(100);

    l_start_date       DATE;
    l_end_date         DATE;
    l_period_from      DATE;
    l_period_to        DATE;
    l_sysdate          DATE;

    l_setup_valid    BOOLEAN;
    l_setup_warn     BOOLEAN;

    l_stg_cnt       NUMBER;

    /* all temp variables used in resume only */

    l_temp_first_run     BOOLEAN;
    l_temp_mode          VARCHAR2(100);
    l_temp_truncate_flag BOOLEAN;
    l_temp_start_date    DATE;
    l_temp_end_date      DATE;
    l_temp_collect_mode  VARCHAR2(200);

BEGIN

/* initialization of variable */
    l_proc := 'Main.';

    l_ids_count := 0;
    stg_count := 0;

    l_start_date :=NULL;
    l_end_date :=NULL;
    l_period_from :=NULL;
    l_period_to :=NULL;
    l_sysdate :=SYSDATE;

    l_stg_cnt :=0;
/* end initialization of variable */

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
             bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin ',
             p_msg => ' Start of Procedure '|| l_proc);
      END IF;

    errbuf := NULL;
    retcode := 0;

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates(
            g_obj_name,
            l_start_date,
            l_end_date,
            l_period_from,
            l_period_to
            );

    IF (l_start_date IS NULL OR p_truncate='Y' OR p_truncate='y') THEN
        g_first_run:=TRUE;
        g_mode:= 'INITIAL';
    END IF;


    ------------------------------------------------
    -- Initialize Global Variables
    ------------------------------------------------
    g_obj_name := 'BIL_BI_FST_DTL_F';
    init(g_obj_name);

   -- only set these for main parent and for initial run
   IF(g_mode='INITIAL') THEN
     EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE=100000000';
     EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE=100000000';
   END IF;

   -- chech for mode of operation, if full refresh, truncate tables
   IF (g_mode='INITIAL') THEN
     bil_bi_util_collection_pkg.Truncate_table('BIL_BI_FST_DTL_F');
     bil_bi_util_collection_pkg.Truncate_table('BIL_BI_FST_DTL_STG');
     bil_bi_util_collection_pkg.Truncate_table('BIL_BI_PROCESSED_FST_ID');
     bil_bi_util_collection_pkg.Truncate_table('BIL_BI_NEW_FST_ID');
     BIS_COLLECTION_UTILITIES.deleteLogForObject (g_obj_name);
     g_truncate_flag := TRUE;
     COMMIT;
   END IF;


    -- Set the STart and End Dates of This Run

  IF(p_truncate = 'Y' or p_truncate= 'y') THEN
    IF p_start_date IS NULL THEN
       G_Start_Date :=    g_cal_start_date;
    ELSIF (TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS') > l_sysdate) THEN
      fnd_message.set_name('BIL','BIL_BI_DATE_PARAM_RESET');
      fnd_message.set_token('RESET_DATE',
                  TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS'));
      bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_ERROR,
          p_module => g_pkg || l_proc ,
          p_msg => fnd_message.get,
          p_force_log => TRUE
        );
        g_start_date := l_sysdate;
        g_warn_flag := 'Y';
      ELSE
        G_Start_Date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
    END IF;
  ELSE
    IF p_start_date IS NULL THEN
       G_Start_Date :=    g_cal_start_date;
    ELSE
      IF ((TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS') < l_period_to) AND p_truncate NOT IN ('y','Y')) THEN
        fnd_message.set_name('BIL','BIL_BI_INVALID_DATE_RANGE');
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_ERROR,
          p_module => g_pkg || l_proc ,
          p_msg => fnd_message.get,
          p_force_log => TRUE
        );
        g_start_date := l_period_to;
        g_warn_flag := 'Y';
      ELSIF ( TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS') > l_period_to ) THEN
        fnd_message.set_name('BIL','BIL_BI_DATE_PARAM_RESET');
        fnd_message.set_token('RESET_DATE',
                   TO_CHAR(l_period_to, 'YYYY/MM/DD HH24:MI:SS'));
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_ERROR,
          p_module => g_pkg || l_proc ,
          p_msg => FND_MESSAGE.get,
          p_force_log => TRUE
        );
        g_start_date := l_period_to;
        g_warn_flag := 'Y';
      ELSE
        G_Start_Date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
      END IF;
    END IF;
   END IF;

    G_End_Date := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');

    -------------------------------------------------
    -- Print out useful parameter information
    -------------------------------------------------

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc  || ' g_start_date ',
          p_msg => ' Start date range: ' || to_char(g_start_date, 'YYYY/MM/DD HH24:MI:SS')
        );

        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc  || ' g_end_date ',
          p_msg => ' End date range: ' || to_char(g_end_date, 'YYYY/MM/DD HH24:MI:SS')
        );

        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc  || ' p_truncate ',
          p_msg => ' Truncate: ' || p_truncate
        );

        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc  || ' g_mode ',
          p_msg => ' Mode: ' || g_mode
        );

      END IF;

     Validate_Setup(l_setup_valid);

     IF (NOT l_setup_valid) THEN
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level => fnd_log.LEVEL_EVENT,
           p_module => g_pkg || l_proc || ' proc_error ',
           p_msg => ' Initial setup validation failed',
           p_force_log => TRUE
         );
       END IF;
       RAISE G_SETUP_VALID_ERROR;
     END IF;

        SELECT
          COUNT(*)
        INTO
          l_stg_cnt
        FROM BIL_BI_NEW_FST_ID
        WHERE ROWNUM < 2;

        IF (l_stg_cnt > 0) THEN
          G_Resume_Flag := 'Y';
        END IF;

     IF (g_resume_Flag = 'Y') THEN

       g_phase := 'Resuming';

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc,
            p_msg => g_phase);
       END IF;

       /* The forecasts to resume are present in the new fst id table. Resume from there */

         /*
         -----------------------------------------------------------------------------
           Determine the previous run type:
             1.Initial with truncate = Y
             2.Initial with truncate = N
             3.Incremental

           And then put current g_* variables in temporary variables and
           set g_* with resume type and proceed to insert into the stg and pfi tables
         -----------------------------------------------------------------------------
         */

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_STATEMENT,
          p_module => g_pkg || l_proc  ,
          p_msg =>
             'g_* variables before exchange = g_end_date,g_start_date,g_mode,'||
            ' => '||g_end_date||','||g_start_date||','||','||g_mode
        );
       END IF;

         l_temp_first_run := g_first_run;
         l_temp_mode := g_mode;
         l_temp_truncate_flag := g_truncate_flag;
         l_temp_start_date := g_start_date;
         l_temp_end_date := g_end_date;


       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_STATEMENT,
          p_module => g_pkg || l_proc  ,
          p_msg =>
             'temp variables after exchange = l_temp_end_date,l_temp_start_date,l_temp_mode,'||
            l_temp_end_date||','||l_temp_start_date||','||','||l_temp_mode
        );
       END IF;


         SELECT
           MIN(submission_date) start_date,
           MAX(submission_date) end_date,
           MAX(collect_mode) collect_mode
         INTO
           g_start_date,
           g_end_date,
           l_temp_collect_mode
         FROM
           BIL_BI_NEW_FST_ID;

         IF SUBSTR(l_temp_collect_mode,1,1) = 'Y' THEN
           g_truncate_flag := TRUE;
         ELSE
           g_truncate_flag := FALSE;
         END IF;


         IF SUBSTR(l_temp_collect_mode,3,1) = 'Y' THEN
           g_first_run := TRUE;
         ELSE
           g_first_run := FALSE;
         END IF;


         IF g_truncate_flag THEN
           g_mode := 'INITIAL';
         ELSE
           g_mode := '';
         END IF;


       --------------------------------------------------------------
       -- Populate currency rates with the dates and currency codes
       -- in the new fst ids table
       --------------------------------------------------------------

       POPULATE_CURRENCY_RATE;

       --------------------------------------------------------------
       -- Check for missing currency, submission
       -- and forecast time dimensions
       --------------------------------------------------------------

       SUMMARY_ERR_CHECK;

       IF (g_missing_rates = 0 AND g_missing_time = 0) THEN

         g_phase := 'Resume: Insert into staging';

         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
            bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => g_phase);
         END IF;

       Insert_into_Stg
       (
         g_mode
       );

         g_phase := 'Resume: adjust forecast amount for staging table';

         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog
           (
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc ,
             p_msg => g_phase
           );
         END IF;


         Summary_Adjust;

         -------------------------------------------------------------
         -- Call Summarization_aggreagte forecast data along the forecast period
         -- dimension
         -------------------------------------------------------------

         g_phase := 'Resume: Aggregating summarized data';

         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
             bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => g_phase);
         END IF;

         Summarize_Frcsts_Periods;

         --------------------------------------------------------
         -- Call Merge routine to insert validated data into
         -- the base summary table
         --------------------------------------------------------
         g_phase := 'Resume:Merging records into base summary table';
         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
            bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => g_phase);
         END IF;

         Insert_From_Stg
         (
           ERRBUF  => ERRBUF
           ,RETCODE => RETCODE
         );

        --------------------------------------------------------
        -- Call routine to insert validated data into
        -- the processed id table.
        --------------------------------------------------------
         g_phase := 'RESUME: Completed insert into fact';


         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
              bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => g_phase);
         END IF;
         -- clean the table once resume is complete and commit
         bil_bi_util_collection_pkg.truncate_table('BIL_BI_FST_DTL_STG');
         bil_bi_util_collection_pkg.truncate_table('BIL_BI_NEW_FST_ID');
         COMMIT;
         -- end of new code
         G_Resume_Flag := 'N';

         /* Reassign all the g_* variables, their original values */

         g_first_run := l_temp_first_run;
         g_mode := l_temp_mode;
         g_truncate_flag := l_temp_truncate_flag;
         g_start_date := l_temp_start_date;
         g_end_date := l_temp_end_date;

         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
           bil_bi_util_collection_pkg.writeLog
           (
             p_log_level => fnd_log.LEVEL_STATEMENT,
             p_module => g_pkg || l_proc  ,
             p_msg =>
               'g_* variables after exchange = g_end_date,g_start_date,g_mode,'||
                'g_first_run => '||g_end_date||','||g_start_date||','||g_mode
           );
         END IF;


       ELSE

       /* if sumry err check returned missing date/curr*/

         retcode := - 1;
         g_phase := 'MISSING RATES FOUND WHILE RESUMING';
         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog
           (
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc ,
             p_msg => g_phase
           );
         END IF;
         commit;
         Clean_up('Missing currencies or dimension values');
         return;
       END IF;
     ELSE
      G_Resume_Flag := 'N';
     END IF;

  -----------------------------------------------------------------
  -- If resume flag is 'N', then this program starts from the
  -- beginning:
  --     1. Identify Forecasts IDs to process
  --     2. insert day-level summarized
  --        records into temporary staging table
  --        Otherwise, it would first check if all missing rates have been
  --        fixed, and then resume the normal process which includes:
  --     3. Insert higher time level summarized records into
  --        temporary staging table.
  --     4. Merging summarized records into base summary table
  --     5. Insert processed Header IDs into a processed table
  ------------------------------------------------------------------
  IF(g_resume_flag = 'N') THEN
    ---------------------------------------------------------------
    -- Call New_Forecasts routine to insert Forecasts ids into
    -- BIL_BI_FRCST_TEMP
    ----------------------------------------------------------------

      g_phase := 'Identify New Forecasts to process';
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => g_phase);
       END IF;

      --------------------------------------------------------
      -- New_Forecasts will identify the new Forecasts which
      -- need to be processed based on the user entered
      -- date range.  If there are no new journals to process
      -- the program will exit immediately with complete
      -- successful status
      --------------------------------------------------------
      /*Fetch the range of forecasts into new fst id table that needs to be processed. */
      l_ids_count := New_Forecasts (g_start_date, g_end_date);

      IF (l_ids_count = 0) THEN
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => 'No new forecasts to process, exiting.'
          );
        END IF;
        COMMIT;
          BIS_COLLECTION_UTILITIES.wrapup(TRUE, 0, NULL, g_start_date, g_end_date);
        RETURN;
      END IF;

     COMMIT;

     g_phase := 'going to populate currency rates';
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg =>g_phase
       );
     END IF;

     --------------------------------------------------------------
     -- Populate currency rates with the dates and currency codes
     -- in the new fst ids table
     --------------------------------------------------------------

     POPULATE_CURRENCY_RATE;


     g_phase := 'Doing summary error check';

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg =>g_phase
       );
     END IF;


     --------------------------------------------------------------
     -- Check for missing currency, submission
     -- and forecast time dimensions
     --------------------------------------------------------------

     SUMMARY_ERR_CHECK;


    -----------------------------------------------------------------
    -- If completed successfully then we cab proceed with inserting
    -- into the stg and processed ids table
    -----------------------------------------------------------------

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Summarization Error Check completed');
    END IF;

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'g_missing_rates= ' || g_missing_rates ||' g_missing_time= ' || g_missing_time
       );
     END IF;

     IF (g_missing_rates = 0 AND g_missing_time = 0) THEN

       Insert_into_Stg
       (
         g_mode
       );

       COMMIT;

       -----------------------------------------------------------------------------------
       -- Call summary adjust
       -- if INITIAL WITH TRUNCATE then only check for correct periods
       -- and update the forecast period column
       -- for INITIAL WITHOUT TRUNCATE AND INCR do the above as well as adjust amounts
       -----------------------------------------------------------------------------------


       g_phase := ' Calling SUMMARY ADJUST - check for periods and adjust amount(incr)';
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level => fnd_log.LEVEL_EVENT,
           p_module => g_pkg || l_proc ,
           p_msg => g_phase
        );
       END IF;

       Summary_Adjust;

       -------------------------------------------------------------
       -- Call Summarization_aggreagte forecast data along the forecast period
       -- dimension
       -------------------------------------------------------------

       g_phase := 'Aggregating summarized data';
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog(
               p_log_level => fnd_log.LEVEL_EVENT,
               p_module => g_pkg || l_proc ,
               p_msg => g_phase);
       END IF;


       Summarize_Frcsts_Periods;

      --------------------------------------------------------
       -- Call Merge routine to insert validated data into
       -- the base summary table
       --------------------------------------------------------

       g_phase := 'Merging records into base summary table';
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
               p_log_level => fnd_log.LEVEL_EVENT,
               p_module => g_pkg || l_proc ,
               p_msg => g_phase);
       END IF;

       Insert_From_Stg
       (
         ERRBUF  => ERRBUF
         ,RETCODE => RETCODE
       );


      ----------------------------------------------------------------------
      -- Call routine to insert validated data into the processed id table.
      ----------------------------------------------------------------------

       g_phase := 'truncate new fst id table after a successful colelction';
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
               p_log_level => fnd_log.LEVEL_EVENT,
               p_module => g_pkg || l_proc ,
               p_msg => g_phase);
       END IF;

       /* truncate the new fst ids table after a successful collection */
       bil_bi_util_collection_pkg.Truncate_table('BIL_BI_NEW_FST_ID');


       COMMIT;

       -- Cleaning phase
       -- Truncate staging summary table if all the processes completed
       -- successfully.
       g_phase := 'Final Cleanup';

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog(
               p_log_level => fnd_log.LEVEL_EVENT,
               p_module => g_pkg || l_proc ,
               p_msg => g_phase);
       END IF;
       Clean_up(NULL);
       IF (g_truncate_flag or g_first_run) THEN
         bil_bi_util_collection_pkg.analyze_table('BIL_BI_FST_DTL_F', TRUE, 10, 'GLOBAL');
       END IF;
       retcode := 0;
     ELSE
      -- don't move a record to base summary table in case of error but still commit
        retcode := - 1;
        g_phase:='Summarization Error Check Positive';
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => g_phase
          );
        END IF;
        Clean_up('Missing currencies or dimension values');
      END IF;
    END IF; -- IF (g_resume_flag = 'N')



    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
     bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_STATEMENT,
              p_module => g_pkg || l_proc  ,
              p_msg => 'Warn Flag := ' || retcode);
    END IF;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' end ',
              p_msg => ' End of Procedure ' || l_proc);
   END IF;


EXCEPTION

     WHEN G_SETUP_VALID_ERROR THEN
       g_retcode := -1;
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level => fnd_log.LEVEL_EVENT,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => 'The Time, Currency or Product Dimensions are not properly setup ',
           p_force_log => TRUE
         );
       END IF;
       ROLLBACK;
       retcode := g_retcode;
       Clean_up(sqlerrm);

     WHEN OTHERS Then
         g_retcode := -1;
         ROLLBACK;
         retcode := g_retcode;
         Clean_up(sqlerrm);
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
         fnd_message.set_token('ERRNO' ,SQLCODE);
         fnd_message.set_token('REASON' ,SQLERRM);
         fnd_message.set_token('ROUTINE' , l_proc);
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
            p_module => g_pkg || l_proc || 'proc_error',
            p_msg => fnd_message.get,
            p_force_log => TRUE);
        RAISE;
END Main;
/************************************************************************************************/




----------------------------------------------------------------------
-- FUNCTION NEW_JOURNALS
----------------------------------------------------------------------
FUNCTION  New_Forecasts
(
  P_Start_Date IN DATE ,
  P_End_Date IN DATE
) RETURN NUMBER IS

     l_number_of_rows     NUMBER;
     l_proc VARCHAR2(100);
     l_collect_mode VARCHAR2(100);

BEGIN

/* initialization of variable */
     l_number_of_rows :=0;
     l_proc := 'New_forecasts.';
/* end initialization of variable */

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' begin ',
              p_msg => ' Start of Procedure ' || l_proc);
   END IF;

      ----------------------------------------------------------------------
      -- Insert into a table to hold forecast ids which are never
      -- processed (Not exist processed id table.
      -----------------------------------------------------------------------
      IF g_truncate_flag THEN
        l_collect_mode := 'Y';
      ELSE
        l_collect_mode := 'N';
      END IF;

      IF g_first_run THEN
        l_collect_mode := l_collect_mode||':Y';
      ELSE
        l_collect_mode := l_collect_mode||':N';
      END IF;


   IF (g_mode='INITIAL') THEN

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_STATEMENT,
          p_module => g_pkg || l_proc,
          p_msg => 'Inserting in INITIAL mode'
        );
      END IF;



    INSERT /*+ PARALLEL(nfst) */ INTO BIL_BI_NEW_FST_ID nfst
    (
      record_id,
      forecast_id,
      currency_code,
      submission_date,
      collect_mode,
      period_name
    )
    SELECT /*+ USE_HASH(aif) PARALLEL(aif) PARALLEL(glp) */
      rownum,
      aif.forecast_id,
      aif.currency_code,
      aif.submission_date,
      l_collect_mode,
      aif.period_name
    FROM
      as_internal_forecasts aif,
      gl_periods glp
    WHERE
      aif.submission_date BETWEEN p_start_date AND p_end_date
      AND aif.status_code = 'SUBMITTED'
      AND glp.period_set_name = g_cal
      AND glp.period_name = aif.period_name
      AND glp.period_type = g_fsct_per_type;

      l_number_of_rows := SQL%ROWCOUNT;

  ELSE

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_STATEMENT,
          p_module => g_pkg || l_proc,
          p_msg => 'Inserting in Incremental mode'
        );
      END IF;


    INSERT INTO BIL_BI_NEW_FST_ID
    (
      record_id,
      forecast_id,
      currency_code,
      submission_date,
      collect_mode,
      period_name
    )
     SELECT
      ROWNUM,
      aif.forecast_id,
      aif.currency_code,
      aif.submission_date,
      l_collect_mode,
      aif.period_name
    FROM
      as_internal_forecasts aif,
      gl_periods glp
    WHERE
      NOT EXISTS (SELECT forecast_id FROM bil_bi_processed_fst_id  bpfi
                  WHERE aif.forecast_id = bpfi.forecast_id)
      AND aif.submission_date  BETWEEN P_Start_Date AND P_End_Date
      AND aif.status_code = 'SUBMITTED'
      AND glp.period_set_name = g_cal
      AND glp.period_name = aif.period_name
      AND glp.period_type = g_fsct_per_type;



   l_number_of_rows := SQL%ROWCOUNT;

  END IF;



  COMMIT;

         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
              bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_PROCEDURE,
                p_module => g_pkg || l_proc,
                p_msg => 'Inserted '||l_number_of_rows||' forecast IDs into BIL_BI_NEW_FST_ID');
         END IF;

      bil_bi_util_collection_pkg.analyze_table('BIL_BI_NEW_FST_ID', TRUE, 10, 'GLOBAL');

    return(l_number_of_rows);

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' end ',
              p_msg => ' End of Procedure ' || l_proc);
   END IF;


EXCEPTION

       WHEN OTHERS Then
        g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
               p_module => g_pkg || l_proc || ' proc_error ',
               p_msg => fnd_message.get,
               p_force_log => TRUE);
        RAISE;

END New_Forecasts;


/**************************************************************************************
 *Init: This procedure is used to intialize the global variables viz- the values for
 *who columns.
 **************************************************************************************/
PROCEDURE Init (p_obj_name in varchar2)  IS
   l_status        VARCHAR2(30);
   l_industry    VARCHAR2(30);
   l_proc          VARCHAR2(100);
   l_ret_status BOOLEAN;
BEGIN

/* initialization of variable */
   l_proc := 'Init.';
/* end initialization of variable */

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
            p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' begin ',
            p_msg => ' Start of Procedure ' || l_proc);
   END IF;


   IF (NOT BIS_COLLECTION_UTILITIES.setup(p_obj_name)) THEN

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog(
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc,
          p_msg => ' BIS Setup Failed');
    END IF;
    RAISE  G_INIT_FAILED;
  END IF;


    g_debug := BIS_COLLECTION_UTILITIES.g_debug;


    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc,
              p_msg => ' Calling procedure: INIT');
    END IF;


    Check_Profiles(l_ret_status);


    IF (NOT l_ret_status) THEN
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc ,
          p_msg => ' Profiles have not been setup',
          p_force_log => TRUE);
        END IF;
      RAISE G_SETUP_VALID_ERROR;
    ELSE
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc ,
          p_msg => ' Profiles setup properly',
          p_force_log => TRUE
        );
      END IF;
    END IF;

   ----------------------------------------------------------------
   -- Set program start time.  We need this variable to delete
   -- records inserted into staging table in this run.  Any records
   -- with creation date greater than program start time will be
   -- deleted in the event of error
   ----------------------------------------------------------------
   g_program_start_time := SYSDATE;

        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN

          bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Initialize global variables');
        END IF;


   g_phase := 'Find BIL schema';
   g_bil_schema := bil_bi_util_collection_pkg.get_schema_name('BIL');

     G_request_id := FND_GLOBAL.CONC_REQUEST_ID();
     G_appl_id    := FND_GLOBAL.PROG_APPL_ID();
     G_program_id := FND_GLOBAL.CONC_PROGRAM_ID();
     G_user_id    := FND_GLOBAL.USER_ID();
     G_login_id   := FND_GLOBAL.CONC_LOGIN_ID();

    G_DEGREE := NVL(bis_common_parameters.get_degree_of_parallelism,1);

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
            bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' end ',
              p_msg => ' End of Procedure ' || l_proc);
     END IF;


END Init;




/****************************************************************************************
--PROCEDURE Populate_Currency_Rate
--This procedure populates the currency rate table with distinct combinations
--of currency codes and dates
--it gets the distinct combinations from the forecast staging table
****************************************************************************************/

PROCEDURE Populate_Currency_Rate IS
  l_proc     VARCHAR2(100);

BEGIN

/* initialization of variable */
  l_proc := 'Populate_Currency_Rate.';
/* end initialization of variable */

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;


   MERGE INTO BIL_BI_CURRENCY_RATE sumry
   USING
   (
     SELECT
       currency_code,
       submission_date,
       DECODE(currency_code,g_prim_currency,1,
          fii_currency.get_global_rate_primary(currency_code,trunc(least(sysdate, submission_date)))) prate,
       DECODE(g_sec_currency,NULL,NULL,DECODE(currency_code,g_sec_currency,1,
          fii_currency.get_global_rate_secondary(currency_code,trunc(least(sysdate, submission_date))))) srate
     FROM
     (
       SELECT /*+ PARALLEL(nfi) */
         DISTINCT currency_code currency_code,
         TRUNC(submission_date) submission_date
       FROM
         bil_bi_new_fst_id nfi
     )
   ) rates
   ON
   (
     rates.currency_code = sumry.currency_code
     AND rates.submission_date = sumry.exchange_date
   )
   WHEN MATCHED THEN
     UPDATE SET
       sumry.exchange_rate = rates.prate,
       sumry.EXCHANGE_RATE_S = rates.srate
   WHEN NOT MATCHED THEN
     INSERT
     (
       sumry.currency_code,
       sumry.exchange_date,
       sumry.exchange_rate,
       sumry.exchange_rate_s
     )
     VALUES
     (
       rates.currency_code,
       rates.submission_date,
       rates.prate,
       rates.srate
     );

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Merged  '||sql%rowcount||' into bil_bi_currency_rate table');
  END IF;

  --update bil.bil_bi_currency_rate set exchange_rate = -1,exchange_rate_s = -1 where rownum < 2;

  COMMIT;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;
 EXCEPTION
   WHEN OTHERS THEN

      g_retcode := -1;
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
      fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
        p_module => g_pkg || l_proc || 'proc_error',
        p_msg => fnd_message.get,
        p_force_log => TRUE);
  RAISE;
 END   Populate_Currency_Rate;




/**************************************************************************************
 * PROCEDURE Insert_Into_Stg
 * This procedure is used to insert a range of forecasts in to the staging table.
 **************************************************************************************/

PROCEDURE Insert_Into_Stg
(
  p_mode IN VARCHAR2
) IS

  l_number_of_rows NUMBER;
  l_stime DATE;
  l_proc varchar2(100);


BEGIN

/* initialization of variable */
  l_number_of_rows :=0;
  l_stime := SYSDATE;
  l_proc := 'Insert_Into_Stg.';
/* end initialization of variable */

    ------------------------------------------------------------------
    -- Insert Forecasts in the given range from AS_INTERNAL_FORECASTS,
    -- AS_FST_SALES_CATEGORIES and AS_FORECAST_CATEGORIES.
    ------------------------------------------------------------------

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' begin ',
              p_msg => ' Start of Procedure ' || l_proc);
  END IF;

  IF (p_mode='INITIAL') THEN

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg => 'insert into staging - initial'
       );
     END IF;


    INSERT ALL
    /*+  PARALLEL(bil_bi_fst_dtl_stg) */ INTO  BIL_BI_FST_DTL_STG
    (
      Txn_Day,Txn_Week,Txn_Period,Txn_Quarter,Txn_Year
      ,forecast_period_day,forecast_period_week,forecast_period_period,forecast_period_quarter,forecast_period_year
      ,sales_group_id,salesrep_id,forecast_amt,forecast_amt_s,valid_flag,functional_currency
      ,Primary_Conversion_Rate,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt,opp_forecast_amt_s
    )
    VALUES
    (
      Txn_Day,Txn_Week,Txn_Period,Txn_Quarter,Txn_Year
      ,forecast_period_day,forecast_period_week,forecast_period_Period,forecast_period_quarter,forecast_period_year
      ,sales_group_id,salesrep_id,adjusted_amt_p,adjusted_amt_s,valid_flag,functional_currency
      ,primary_Conversion_Rate,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      adjusted_opp_forecast_amt_p,adjusted_opp_forecast_amt_s
    )
    /*+ PARALLEL(bil_bi_processed_fst_id) */ INTO  bil_bi_processed_fst_id
    (
      creation_date,created_by,last_update_date,last_updated_by,LAST_UPDATE_LOGIN,Txn_Day
      ,sales_group_id,salesrep_id,forecast_amt,forecast_amt_s,functional_currency
      ,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt,opp_forecast_amt_s
    )
    VALUES
    (
      SYSDATE,G_user_id,SYSDATE,G_user_id,g_login_id,Txn_Day
      ,sales_group_id,salesrep_id,forecast_amt_p,forecast_amt_s,functional_currency
      ,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt_p,opp_forecast_amt_s
    )
    (
    SELECT
      /*+ PARALLEL(aif) PARALLEL(bnfi) PARALLEL(asfc)
          USE_HASH(aif) USE_HASH(bnfi) USE_HASH(asfc) */
      to_char(submission_date, 'J') txn_DAY,
      to_number(NULL, 999) txn_WEEK,
      to_number(NULL, 999) txn_PERIOD,
      to_number(NULL, 999) txn_QUARTER,
      to_number(NULL, 999) txn_YEAR,
      to_number(NULL,999) forecast_period_day,
      to_number(NULL,999)forecast_period_week,
      to_number(NULL,999)forecast_period_period,
      to_number(NULL,999)forecast_period_quarter,
      to_number(NULL,999)forecast_period_year,
      sales_group_id,
      salesforce_id salesrep_id,
      forecast_amt_p,
      forecast_amt_s,
      adjusted_amt_p,
      adjusted_amt_s,
      'T' valid_flag,
      currency_code functional_currency,
      NULL primary_conversion_rate,
      product_category_id,
      credit_type_id,
      period_name,
      submission_date,
      forecast_id,
      opp_forecast_amt_p,
      opp_forecast_amt_s,
      adjusted_opp_forecast_amt_p,
      adjusted_opp_forecast_amt_s
  FROM
  (
    SELECT
      forecast_id,
      submission_date,
      sales_group_id,
      salesforce_id,
      product_category_id,
      period_name,
      currency_code,
      credit_type_id,
      forecast_amount,
      forecast_amt_p,
      forecast_amt_s,
      forecast_amt_p-NVL(lag_forecast_amt_p,0) adjusted_amt_p,
      forecast_amt_s-NVL(lag_forecast_amt_s,0) adjusted_amt_s,
      opp_forecast_amt_p,
      opp_forecast_amt_s,
      opp_forecast_amt_p-NVL(lag_opp_forecast_amt_p,0) adjusted_opp_forecast_amt_p,
      opp_forecast_amt_s-NVL(lag_opp_forecast_amt_s,0) adjusted_opp_forecast_amt_s
    FROM
    (
    SELECT
      forecast_id,
      submission_date,
      sales_group_id,
      salesforce_id,
      product_category_id,
      period_name,
      currency_code,
      credit_type_id,
      forecast_amount,
      forecast_amt_p,
      forecast_amt_s,
      opp_forecast_amt_p,
      opp_forecast_amt_s,
      LAG((forecast_amt_p)) OVER (PARTITION BY sales_group_id,salesforce_id,product_category_id
        ,period_name,credit_type_id ORDER BY submission_date ASC) lag_forecast_amt_p,
      LAG((forecast_amt_s)) OVER (PARTITION BY sales_group_id,salesforce_id,product_category_id
        ,period_name,credit_type_id ORDER BY submission_date ASC) lag_forecast_amt_s,
      LAG((opp_forecast_amt_p)) OVER (PARTITION BY sales_group_id,salesforce_id,product_category_id
        ,period_name,credit_type_id ORDER BY submission_date ASC) lag_opp_forecast_amt_p,
      LAG((opp_forecast_amt_s)) OVER (PARTITION BY sales_group_id,salesforce_id,product_category_id
        ,period_name,credit_type_id ORDER BY submission_date ASC) lag_opp_forecast_amt_s
    FROM
    (
      SELECT
        /*+
          PARALLEL(aif) PARALLEL(bnfi) PARALLEL(asfc) PARALLEL(rates)
          USE_HASH(aif) USE_HASH(bnfi) USE_HASH(asfc) USE_HASH(rates)
        */
        aif.forecast_id,
        aif.submission_date,
        aif.sales_group_id,
        aif.salesforce_id,
        asfc.product_category_id,
        aif.period_name,
        aif.currency_code,
        aif.credit_type_id,
        aif.forecast_amount,
        aif.forecast_amount*rates.exchange_rate forecast_amt_p,
        aif.forecast_amount*rates.exchange_rate_s forecast_amt_s,
        NULL opp_forecast_amt_p,
        NULL opp_forecast_amt_s
      FROM
        as_internal_forecasts aif,
        bil_bi_new_fst_id bnfi,
        as_fst_sales_categories asfc,
        bil_bi_currency_rate rates
      WHERE
        aif.forecast_id  = bnfi.forecast_id
        AND aif.status_code = 'SUBMITTED'
        AND aif.submission_date >= g_start_date
        AND aif.submission_date <= LEAST(g_end_date,(g_asn_date-(1/(24*60*60))))
        AND NVL(aif.FORECAST_AMOUNT_FLAG,'Y') = 'Y'
        AND aif.forecast_category_id = asfc.forecast_category_id
        AND NVL(asfc.end_date_active,SYSDATE) >= SYSDATE
        AND asfc.start_date_active <= SYSDATE
        AND TRUNC(aif.submission_date) = rates.exchange_date
        AND aif.currency_code = rates.currency_code
        AND product_category_id IS NOT NULL
        AND aif.forecast_category_id IN
        (
          SELECT
            afsc1.forecast_category_id
          FROM
            as_fst_sales_categories afsc1
          WHERE
            NVL(afsc1.end_date_active,SYSDATE) >= SYSDATE
            AND afsc1.start_date_active <= SYSDATE
            AND NOT(NVL(interest_type_id,-1)<0 AND product_category_id IS NULL)
          GROUP BY
            afsc1.forecast_category_id
          HAVING COUNT(1) = 1
        )
      UNION ALL
      SELECT
        /*+
          PARALLEL(aif) PARALLEL(bnfi) PARALLEL(asfc) PARALLEL(apwsl)
          USE_HASH(aif) USE_HASH(bnfi) USE_HASH(asfc) USE_HASH(apwsl)
        */
        aif.forecast_id,
        aif.submission_date,
        aif.sales_group_id,
        aif.salesforce_id,
        apwsl.product_category_id,
        aif.period_name,
        aif.currency_code,
        aif.credit_type_id,
        apwsl.forecast_amount,
        apwsl.forecast_amount*rates.exchange_rate forecast_amt_p,
        apwsl.forecast_amount*rates.exchange_rate_s forecast_amt_s,
        apwsl.opp_forecast_amount*rates.exchange_rate opp_forecast_amt_p,
        apwsl.opp_forecast_amount*rates.exchange_rate_s opp_forecast_amt_s
      FROM
        as_internal_forecasts aif,
        as_prod_worksheet_lines apwsl,
        bil_bi_new_fst_id bnfi,
        bil_bi_currency_rate rates
      WHERE
        aif.forecast_id  = bnfi.forecast_id
        AND aif.status_code = 'SUBMITTED'
        AND apwsl.status_code = 'SUBMITTED'
        AND aif.submission_date >= GREATEST(g_start_date,g_asn_date)
        AND aif.submission_date <= g_end_date
        AND nvl(aif.FORECAST_AMOUNT_FLAG,'Y') = 'Y'
        AND aif.forecast_id = apwsl.forecast_id
        AND TRUNC(aif.submission_date) = rates.exchange_date
        AND aif.currency_code = rates.currency_code
      )
    )
  )
 );

  l_number_of_rows := SQL%ROWCOUNT;

  COMMIT;


  ELSE  -- Incremental Load

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg => 'insert into staging - incremental'
       );
     END IF;

    INSERT ALL
    INTO  BIL_BI_FST_DTL_STG
    (
      Txn_Day,Txn_Week,Txn_Period,Txn_Quarter,Txn_Year
      ,forecast_period_day,forecast_period_week,forecast_period_period,forecast_period_quarter,forecast_period_year
      ,sales_group_id,salesrep_id,forecast_amt,forecast_amt_s,valid_flag,functional_currency
      ,Primary_Conversion_Rate,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt,opp_forecast_amt_s
    )
    VALUES
    (
      Txn_Day,Txn_Week,Txn_Period,Txn_Quarter,Txn_Year
      ,forecast_period_day,forecast_period_week,forecast_period_Period,forecast_period_quarter,forecast_period_year
      ,sales_group_id,salesrep_id,forecast_amt_p,forecast_amt_s,valid_flag,functional_currency
      ,primary_Conversion_Rate,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt_p,opp_forecast_amt_s
    )
    INTO  bil_bi_processed_fst_id
    (
      creation_date,created_by,last_update_date,last_updated_by,LAST_UPDATE_LOGIN,Txn_Day
      ,sales_group_id,salesrep_id,forecast_amt,forecast_amt_s,functional_currency
      ,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt,opp_forecast_amt_s
    )
    VALUES
    (
      SYSDATE,G_user_id,SYSDATE,G_user_id,g_login_id,Txn_Day
      ,sales_group_id,salesrep_id,forecast_amt_p,forecast_amt_s,functional_currency
      ,product_category_id,credit_type_id,period_name,submission_date,forecast_id,
      opp_forecast_amt_p,opp_forecast_amt_s
    )
    (
    SELECT
      to_char(submission_date, 'J') txn_DAY,
      to_number(NULL, 999) txn_WEEK,
      to_number(NULL, 999) txn_PERIOD,
      to_number(NULL, 999) txn_QUARTER,
      to_number(NULL, 999) txn_YEAR,
      to_number(NULL,999) forecast_period_day,
      to_number(NULL,999)forecast_period_week,
      to_number(NULL,999)forecast_period_period,
      to_number(NULL,999)forecast_period_quarter,
      to_number(NULL,999)forecast_period_year,
      sales_group_id,
      salesforce_id salesrep_id,
      forecast_amt_p,
      forecast_amt_s,
      'T' valid_flag,
      currency_code functional_currency,
      NULL primary_conversion_rate,
      product_category_id,
      credit_type_id,
      period_name,
      submission_date,
      forecast_id,
      opp_forecast_amt_p,
      opp_forecast_amt_s
  FROM
  (
    SELECT
      forecast_id,
      submission_date,
      sales_group_id,
      salesforce_id,
      product_category_id,
      period_name,
      currency_code,
      credit_type_id,
      forecast_amount,
      forecast_amt_p,
      forecast_amt_s,
      opp_forecast_amt_p,
      opp_forecast_amt_s
    FROM
    (
      SELECT
        aif.forecast_id,
        aif.submission_date,
        aif.sales_group_id,
        aif.salesforce_id,
        apwsl.product_category_id,
        aif.period_name,
        aif.currency_code,
        aif.credit_type_id,
        apwsl.forecast_amount,
        apwsl.forecast_amount*rates.exchange_rate forecast_amt_p,
        apwsl.forecast_amount*rates.exchange_rate_s forecast_amt_s,
        NVL(apwsl.opp_forecast_amount,0)*rates.exchange_rate opp_forecast_amt_p,
        NVL(apwsl.opp_forecast_amount,0)*rates.exchange_rate_s opp_forecast_amt_s
      FROM
        as_internal_forecasts aif,
        as_prod_worksheet_lines apwsl,
        bil_bi_new_fst_id bnfi,
        bil_bi_currency_rate rates
      WHERE
        aif.forecast_id  = bnfi.forecast_id
        AND aif.status_code = 'SUBMITTED'
        AND apwsl.status_code = 'SUBMITTED'
        AND aif.submission_date >= g_start_date
        AND aif.submission_date <= g_end_date
        AND nvl(aif.FORECAST_AMOUNT_FLAG,'Y') = 'Y'
        AND aif.forecast_id = apwsl.forecast_id
        AND TRUNC(aif.submission_date) = rates.exchange_date
        AND aif.currency_code = rates.currency_code
        AND NOT EXISTS
        (
          SELECT 1
          FROM bil_bi_processed_fst_id bpfi
          WHERE bpfi.forecast_id = aif.forecast_id
        )
      )
    )
  );

  l_number_of_rows := SQL%ROWCOUNT  ;
  COMMIT;

 END IF;

    COMMIT;


    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg => ' Rows Inserted into Staging + Processed fst id Table: '||l_number_of_rows
       );
    END IF;

     bil_bi_util_collection_pkg.analyze_table('BIL_BI_PROCESSED_FST_ID', TRUE, 10, 'GLOBAL');

     bil_bi_util_collection_pkg.analyze_table('BIL_BI_FST_DTL_STG', TRUE, 10, 'GLOBAL');


       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
            p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' end ',
            p_msg => ' End of Procedure ' || l_proc);
       END IF;

EXCEPTION
     WHEN OTHERS Then
        g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error ',
           p_msg => fnd_message.get,
           p_force_log => TRUE);

         raise;

END Insert_Into_Stg;



--  ***********************************************************************
PROCEDURE Clean_Up( ErrorMsg in varchar2 ) IS

     l_proc VARCHAR2(100);

BEGIN

 /* initialization of variable */
    l_proc := 'Clean_Up.';
 /* end initialization of variable */

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
         bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' begin ',
              p_msg => ' Start of Procedure ' || l_proc);
  END IF;


  IF g_phase = 'Final Cleanup' THEN

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc,
          p_msg => 'Calling wrap up');
    END IF;

    COMMIT;
    BIS_COLLECTION_UTILITIES.wrapup(TRUE,g_fact_row_proc,NULL,g_start_date,g_end_date);
  ELSE
    COMMIT;
    BIS_COLLECTION_UTILITIES.wrapup(FALSE,0,ErrorMsg,g_start_date,g_end_date);
  END IF;

  /* Always truncate staging table */
  bil_bi_util_collection_pkg.truncate_table('BIL_BI_FST_DTL_STG');

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' end ',
              p_msg => ' End of Procedure ' || l_proc);
  END IF;


  EXCEPTION

    WHEN OTHERS THEN

        ROLLBACK;

        g_retcode:=-1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
             p_module => g_pkg || l_proc || ' proc_error ',
             p_msg => fnd_message.get,
             p_force_log => TRUE);
        RAISE;

 END Clean_up;

--  **********************************************************************
PROCEDURE Summarize_Frcsts_Periods IS

      l_stmt VARCHAR2(4000);

      l_select VARCHAR2(3000);
      l_rollup VARCHAR2(100);
      l_where  VARCHAR2(200);
      l_from   VARCHAR2(100);
      l_cnt    number;
      l_proc VARCHAR2(100);


BEGIN

/* initialization of variable */
      l_cnt    := 0;
      l_proc := ' Summarize_Frcsts_Periods.';
/* end initialization of variable */

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
              bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' begin ',
            p_msg => ' Start of Procedure ' || l_proc);
  END IF;



/*
 * Here Using period start and end dates of all the start and end periods, the forecasts are updated accordingly.
 * Need to determine logic here.
 */

   -- use dynamic sql since this query is run once per collection, so
   -- should not cause too manu soft parse.


   CASE
    WHEN g_map_ent_per_type = 'FII_TIME_WEEK' THEN
      BEGIN
       NULL;
      END;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_PERIOD' THEN
     BEGIN
      l_select := '
      Txn_Day
     ,Txn_Week
     ,Txn_Period
     ,Txn_Quarter
     ,Txn_Year  ,
      to_number(NULL,999) DAY   ,
      to_number(NULL,999) week   ,
      to_number(NULL,999) Period ,
      fep.ENT_QTR_ID,
      fep.ENT_YEAR_ID,
      sales_group_id   ,
      salesrep_id  ,
      sum(forecast_amt) forecast_amt,
      sum(forecast_amt_s) forecast_amt_s,
      sum(opp_forecast_amt) opp_forecast_amt,
      sum(opp_forecast_amt_s) opp_forecast_amt_s,
      ''T''     ,
      ''NA''    ,
      1,
      PRODUCT_CATEGORY_ID,
      CREDIT_TYPE_ID';

    l_rollup := ' grouping sets (fep.ENT_Year_ID, fep.ENT_Qtr_ID)';
    l_FROM   := ' FROM  BIL_BI_FST_DTL_STG stg, FII_TIME_ENT_Period fep';
    l_WHERE  := ' WHERE stg.FORECAST_PERIOD_Period  = fep.ENT_PERIOD_ID ';
      END;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_QTR' THEN
      BEGIN

      l_select := '
      Txn_Day
     ,Txn_Week
     ,Txn_Period
     ,Txn_Quarter
     ,Txn_Year  ,
      to_number(NULL,999) DAY   ,
      to_number(NULL,999) week   ,
      to_number(NULL,999) Period ,
      to_number(NULL,999) Quarter ,
      fep.ENT_YEAR_ID,
      sales_group_id   ,
      salesrep_id  ,
      sum(forecast_amt) forecast_amt,
      sum(forecast_amt_s) forecast_amt_s,
      sum(opp_forecast_amt) opp_forecast_amt,
      sum(opp_forecast_amt_s) opp_forecast_amt_s,
      ''T''     ,
      ''NA''   ,
      1,
      PRODUCT_CATEGORY_ID,
      CREDIT_TYPE_ID';


    l_rollup := ' grouping sets (fep.ENT_Year_ID)';
    l_from   := ' FROM  BIL_BI_FST_DTL_STG stg, FII_TIME_ENT_QTR fep';
    l_where  := ' WHERE stg.FORECAST_PERIOD_Quarter  = fep.ENT_QTR_ID ';
     END;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_YEAR' THEN
      BEGIN
       NULL ;
      END;
   END CASE;


  IF g_map_ent_per_type = 'FII_TIME_ENT_PERIOD' or
   g_map_ent_per_type = 'FII_TIME_ENT_QTR'           THEN

   IF (g_mode='INITIAL') THEN
     l_stmt := ' INSERT /*+ PARALLEL(stg1) */ into  BIL_BI_FST_DTL_STG stg1 (';
   ELSE
     l_stmt := ' INSERT  into  BIL_BI_FST_DTL_STG (';
   END IF;

  l_stmt := l_stmt ||
  'Txn_Day
  ,Txn_Week
   ,Txn_Period
   ,Txn_Quarter
   ,Txn_Year
   ,FORECAST_PERIOD_DAY
   ,FORECAST_PERIOD_WEEK
   ,FORECAST_PERIOD_Period
   ,FORECAST_PERIOD_Quarter
   ,FORECAST_PERIOD_Year,
   SALES_GROUP_ID,
   SALESREP_ID,
   FORECAST_AMT,
   forecast_amt_s,
   OPP_FORECAST_AMT,
   opp_forecast_amt_s,
   VALID_FLAG,
   functional_currency,
  Primary_Conversion_Rate,
  PRODUCT_CATEGORY_ID,
  CREDIT_TYPE_ID
  )';

   IF (g_mode='INITIAL') THEN
     l_stmt := l_stmt || ' (SELECT /*+ PARALLEL(stg) PARALLEL(fep) */' ;
   ELSE
     l_stmt := l_stmt || ' (SELECT ';
   END IF;

       IF (g_fst_rollup = 'Y') THEN  -- Rollup on Forecast Period

    l_stmt := l_stmt ||
      l_select  ||
      l_from ||
      l_where || '    GROUP BY
             stg.Txn_Day,
             stg.Txn_Week,
             stg.Txn_Period,
             stg.Txn_Quarter,
             stg.Txn_Year,
             stg.sales_group_id,
             stg.SALESREP_ID,
             stg.PRODUCT_CATEGORY_ID,
             stg.CREDIT_TYPE_ID,'
     || l_rollup || ')';

     EXECUTE IMMEDIATE  l_stmt ;
     l_cnt:=SQL%ROWCOUNT;
     COMMIT;


      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
              bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_STATEMENT,
                p_module => g_pkg ,
                p_msg => ' Statemnt to execute is ' || l_stmt);
      END IF;


      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc,
          p_msg => 'Inserted ' || l_cnt || ' rows of aggregated (based on fst period) data into summary table'
        );
      END IF;
    END IF;
  END IF;


-- rolllup along time dimension
    IF (g_mode='INITIAL') THEN
      INSERT /*+ PARALLEL(stg1) */ INTO   BIL_BI_FST_DTL_STG stg1(
          Txn_DAY
         ,Txn_Week
         ,Txn_Period
         ,Txn_Quarter
         ,Txn_Year
         ,FORECAST_PERIOD_DAY
         ,FORECAST_PERIOD_WEEK
         ,FORECAST_PERIOD_Period
         ,FORECAST_PERIOD_Quarter
         ,FORECAST_PERIOD_Year
         , SALES_GROUP_ID
         , SALESREP_ID
         ,FORECAST_AMT
         ,forecast_amt_s
         ,OPP_FORECAST_AMT
         ,opp_forecast_amt_s
         ,VALID_FLAG
         ,functional_currency
         ,Primary_Conversion_Rate
         ,PRODUCT_CATEGORY_ID
         ,CREDIT_TYPE_ID    )
      SELECT /*+ PARALLEL(stg) PARALLEL(fday) */
         to_number(NULL,999),
          fday.week_id,
          fday.ent_period_id,
          fday.ENT_QTR_ID,
          fday.ENT_YEAR_ID,
          FORECAST_PERIOD_DAY
         ,FORECAST_PERIOD_WEEK
         ,FORECAST_PERIOD_Period
         ,FORECAST_PERIOD_Quarter
         ,FORECAST_PERIOD_Year  ,
          sales_group_id   ,
          salesrep_id  ,
          sum(forecast_amt),
          sum(forecast_amt_s),
          sum(opp_forecast_amt),
          sum(opp_forecast_amt_s),
          'T'    ,
          'NA'    ,
          1,
          PRODUCT_CATEGORY_ID,
          CREDIT_TYPE_ID
      FROM    BIL_BI_FST_DTL_STG stg,
              FII_TIME_Day fday
      WHERE stg.txn_day  = fday.report_date_julian
      GROUP BY
         stg.FORECAST_PERIOD_DAY
        ,stg.FORECAST_PERIOD_WEEK
        ,stg.FORECAST_PERIOD_Period
        ,stg.FORECAST_PERIOD_Quarter
        ,stg.FORECAST_PERIOD_Year,
         stg.sales_group_id,
         stg.SALESREP_ID,
         stg.PRODUCT_CATEGORY_ID,
         stg.CREDIT_TYPE_ID,
     grouping sets((fday.ENT_Year_ID,
            fday.ENT_Qtr_ID,fday.ent_period_id,fday.week_id),(fday.ENT_Year_ID,
            fday.ENT_Qtr_ID,fday.ent_period_id), (fday.ENT_Year_ID,
            fday.ENT_Qtr_ID), fday.ENT_Year_ID);
      l_cnt:=SQL%ROWCOUNT;
       ELSE

             IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
               bil_bi_util_collection_pkg.writeLog
               (
                 p_log_level => fnd_log.LEVEL_EVENT,
                 p_module => g_pkg || l_proc,
                 p_msg => 'in incremental rollup on txn time.'
               );
            END IF;

      INSERT  into   BIL_BI_FST_DTL_STG (
         Txn_DAY
         ,Txn_Week
         ,Txn_Period
         ,Txn_Quarter
         ,Txn_Year
         ,FORECAST_PERIOD_DAY
         ,FORECAST_PERIOD_WEEK
         ,FORECAST_PERIOD_Period
         ,FORECAST_PERIOD_Quarter
         ,FORECAST_PERIOD_Year
        , SALES_GROUP_ID
        , SALESREP_ID
        ,FORECAST_AMT
        ,forecast_amt_s
        ,OPP_FORECAST_AMT
        ,opp_forecast_amt_s
        ,VALID_FLAG
        ,functional_currency
        ,Primary_Conversion_Rate
        ,PRODUCT_CATEGORY_ID
        ,CREDIT_TYPE_ID    )
      SELECT
         to_number(NULL,999),
          fday.week_id,
          fday.ent_period_id,
          fday.ENT_QTR_ID,
          fday.ENT_YEAR_ID,
          FORECAST_PERIOD_DAY
         ,FORECAST_PERIOD_WEEK
         ,FORECAST_PERIOD_Period
         ,FORECAST_PERIOD_Quarter
         ,FORECAST_PERIOD_Year  ,
          sales_group_id   ,
          salesrep_id  ,
          sum(forecast_amt),
          sum(forecast_amt_s),
          sum(opp_forecast_amt),
          sum(opp_forecast_amt_s),
          'T'    ,
          'NA'    ,
          1,
          PRODUCT_CATEGORY_ID,
          CREDIT_TYPE_ID
      FROM  BIL_BI_FST_DTL_STG stg,
        FII_TIME_Day fday
      WHERE stg.txn_day  = fday.report_date_julian
        GROUP BY
           stg.FORECAST_PERIOD_DAY
         ,stg.FORECAST_PERIOD_WEEK
         ,stg.FORECAST_PERIOD_Period
         ,stg.FORECAST_PERIOD_Quarter
         ,stg.FORECAST_PERIOD_Year,
           stg.sales_group_id,
           stg.SALESREP_ID,
           stg.PRODUCT_CATEGORY_ID,
           stg.CREDIT_TYPE_ID,
        grouping sets((fday.ENT_Year_ID,
            fday.ENT_Qtr_ID,fday.ent_period_id,fday.week_id),(fday.ENT_Year_ID,
            fday.ENT_Qtr_ID,fday.ent_period_id), (fday.ENT_Year_ID,
            fday.ENT_Qtr_ID), fday.ENT_Year_ID);

       l_cnt:=SQL%ROWCOUNT;
     END IF;

    COMMIT;


    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
              bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc,
                p_msg => 'Inserted ' || l_cnt || ' rows of aggregated (based on time) data into summary table');
    END IF;


    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' end ',
              p_msg => ' End of Procedure ' || l_proc);
    END IF;


EXCEPTION
     WHEN OTHERS Then
        g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
         p_module => g_pkg || l_proc || ' proc_error ',
         p_msg => fnd_message.get,
         p_force_log => TRUE);
         raise;

END Summarize_Frcsts_Periods;
-- **********************************************************************

PROCEDURE Insert_From_Stg( ERRBUF           IN OUT NOCOPY VARCHAR2
                          ,RETCODE          IN OUT NOCOPY VARCHAR2
                         )
IS
  l_number_of_rows number;
  l_sysdate DATE;
  l_proc VARCHAR2(100);

BEGIN

/* initialization of variable */
  l_sysdate := SYSDATE;
  l_proc := 'Insert_From_Stg.';
/* end initialization of variable */

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' begin ',
              p_msg => ' Start of Procedure ' || l_proc);
    END IF;


    ----------------------------------------------------------------------
    -- Merges  will not be required since a new recoreded is created each tim
  -- a time is made  to a forecast.
    -----------------------------------------------------------------------

  IF (g_mode='INITIAL' and g_first_run) THEN

 INSERT /*+ PARALLEL(fact) */ into BIL_BI_FST_DTL_F fact
  (TXN_TIME_ID,
  TXN_PERIOD_TYPE_ID,
  FORECAST_TIME_ID,
  FORECAST_PERIOD_TYPE_ID,
  SALES_GROUP_ID,
  PRODUCT_CATEGORY_ID,
  CREDIT_TYPE_ID,
  CREATION_DATE,
  CREATED_BY,
  LAST_UPDATE_DATE,
  LAST_UPDATED_BY,
  LAST_UPDATE_LOGIN,
  SALESREP_ID,
  FORECAST_AMT,
  forecast_amt_s,
  opp_forecast_amt,
  opp_forecast_amt_s,
  REQUEST_ID,
  PROGRAM_APPLICATION_ID,
  PROGRAM_ID,
  PROGRAM_UPDATE_DATE,
  SECURITY_GROUP_ID)
  (select
  STAGE.TXN_TIME_ID  ,
  STAGE.TXN_PERIOD_TYPE_ID  ,
  STAGE.FORECAST_TIME_ID    ,
  STAGE.FORECAST_PERIOD_TYPE_ID,
  STAGE.SALES_GROUP_ID,
  STAGE.PRODUCT_CATEGORY_ID,
  STAGE.CREDIT_TYPE_ID,
  sysdate,
  g_user_id ,
  sysdate,
  g_user_id ,
  g_login_id ,
  STAGE.SALESREP_ID,
  STAGE.AMOUNT,
  STAGE.SEC_AMOUNT,
  stage.opp_amount,
  stage.sec_opp_amount,
  G_request_id,
  G_appl_id,
  G_program_id,
  sysdate,
  NULL  FROM (select /*+ PARALLEL (stg) */
  SUM(forecast_amt) AMOUNT,
  SUM(forecast_amt_s) SEC_AMOUNT,
  SUM(opp_forecast_amt) opp_amount,
  SUM(opp_forecast_amt_s) sec_opp_amount,
        (CASE WHEN txn_day IS NOT NULL THEN txn_day
              WHEN Txn_Week IS NOT NULL THEN Txn_Week
              WHEN Txn_Period IS NOT NULL THEN Txn_Period
              WHEN Txn_Quarter IS NOT NULL THEN Txn_Quarter
              WHEN Txn_Year IS NOT NULL THEN Txn_Year END) TXN_TIME_ID,
        (CASE WHEN txn_day IS NOT NULL THEN 1
              WHEN Txn_Week IS NOT NULL THEN 16
              WHEN Txn_Period IS NOT NULL THEN 32
              WHEN Txn_Quarter IS NOT NULL THEN 64
              WHEN Txn_Year IS NOT NULL THEN 128 END) TXN_PERIOD_TYPE_ID,
        (CASE WHEN forecast_period_week IS NOT NULL THEN forecast_period_week
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN FORECAST_PERIOD_Period
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN FORECAST_PERIOD_Quarter
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN FORECAST_PERIOD_Year END) FORECAST_TIME_ID,
        (CASE WHEN forecast_period_week IS NOT NULL THEN 16
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN 32
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN 64
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN 128 END) FORECAST_PERIOD_TYPE_ID,
            SALES_GROUP_ID,
            SALESREP_ID,
            PRODUCT_CATEGORY_ID,
            CREDIT_TYPE_ID
             FROM BIL_BI_FST_DTL_STG stg
            GROUP BY
        (CASE WHEN txn_day IS NOT NULL THEN txn_day
              WHEN Txn_Week IS NOT NULL THEN Txn_Week
              WHEN Txn_Period IS NOT NULL THEN Txn_Period
              WHEN Txn_Quarter IS NOT NULL THEN Txn_Quarter
              WHEN Txn_Year IS NOT NULL THEN Txn_Year END),
        (CASE WHEN txn_day IS NOT NULL THEN 1
              WHEN Txn_Week IS NOT NULL THEN 16
              WHEN Txn_Period IS NOT NULL THEN 32
              WHEN Txn_Quarter IS NOT NULL THEN 64
              WHEN Txn_Year IS NOT NULL THEN 128 END),
        (CASE WHEN forecast_period_week IS NOT NULL THEN forecast_period_week
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN FORECAST_PERIOD_Period
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN FORECAST_PERIOD_Quarter
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN FORECAST_PERIOD_Year END),
        (CASE WHEN forecast_period_week IS NOT NULL THEN 16
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN 32
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN 64
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN 128 END),
            SALES_GROUP_ID,
            SALESREP_ID,
            PRODUCT_CATEGORY_ID,
            CREDIT_TYPE_ID) STAGE);

    l_number_of_rows := SQL%ROWCOUNT;
  ELSE
  -- added the index hint per jais suggestions
     MERGE /*+ index(bsum) */ INTO BIL_BI_FST_DTL_F bsum
            USING (select
        SUM(forecast_amt) AMOUNT,
        SUM(forecast_amt_s) SEC_AMOUNT,
        SUM(opp_forecast_amt) opp_amount,
        SUM(opp_forecast_amt_s) sec_opp_amount,
        (CASE WHEN txn_day IS NOT NULL THEN txn_day
              WHEN Txn_Week IS NOT NULL THEN Txn_Week
              WHEN Txn_Period IS NOT NULL THEN Txn_Period
              WHEN Txn_Quarter IS NOT NULL THEN Txn_Quarter
              WHEN Txn_Year IS NOT NULL THEN Txn_Year END) TXN_TIME_ID,
        (CASE WHEN txn_day IS NOT NULL THEN 1
              WHEN Txn_Week IS NOT NULL THEN 16
              WHEN Txn_Period IS NOT NULL THEN 32
              WHEN Txn_Quarter IS NOT NULL THEN 64
              WHEN Txn_Year IS NOT NULL THEN 128 END) TXN_PERIOD_TYPE_ID,
        (CASE WHEN forecast_period_week IS NOT NULL THEN forecast_period_week
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN FORECAST_PERIOD_Period
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN FORECAST_PERIOD_Quarter
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN FORECAST_PERIOD_Year END) FORECAST_TIME_ID,
        (CASE WHEN forecast_period_week IS NOT NULL THEN 16
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN 32
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN 64
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN 128 END) FORECAST_PERIOD_TYPE_ID,
            SALES_GROUP_ID,
            SALESREP_ID,
            PRODUCT_CATEGORY_ID,
            CREDIT_TYPE_ID
             FROM BIL_BI_FST_DTL_STG stg
             GROUP BY
        (CASE WHEN txn_day IS NOT NULL THEN txn_day
              WHEN Txn_Week IS NOT NULL THEN Txn_Week
              WHEN Txn_Period IS NOT NULL THEN Txn_Period
              WHEN Txn_Quarter IS NOT NULL THEN Txn_Quarter
              WHEN Txn_Year IS NOT NULL THEN Txn_Year END),
        (CASE WHEN txn_day IS NOT NULL THEN 1
              WHEN Txn_Week IS NOT NULL THEN 16
              WHEN Txn_Period IS NOT NULL THEN 32
              WHEN Txn_Quarter IS NOT NULL THEN 64
              WHEN Txn_Year IS NOT NULL THEN 128 END),
        (CASE WHEN forecast_period_week IS NOT NULL THEN forecast_period_week
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN FORECAST_PERIOD_Period
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN FORECAST_PERIOD_Quarter
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN FORECAST_PERIOD_Year END),
        (CASE WHEN forecast_period_week IS NOT NULL THEN 16
              WHEN FORECAST_PERIOD_Period IS NOT NULL THEN 32
              WHEN FORECAST_PERIOD_Quarter IS NOT NULL THEN 64
              WHEN FORECAST_PERIOD_Year IS NOT NULL THEN 128 END),
            SALES_GROUP_ID,
            SALESREP_ID,
            PRODUCT_CATEGORY_ID,
            CREDIT_TYPE_ID) STAGE
                  ON (bsum.txn_time_id = stage.txn_time_id  AND
                      bsum.txn_period_type_id = stage.txn_period_type_id AND
                      bsum.forecast_time_id = stage.forecast_time_id AND
                      bsum.forecast_period_type_id = stage.forecast_period_type_id AND
                      bsum.SALES_GROUP_ID = stage.SALES_GROUP_ID AND
                      nvl(bsum.SALESREP_ID, -999) = nvl(stage.SALESREP_ID, -999) AND
                      bsum.PRODUCT_CATEGORY_ID = stage.PRODUCT_CATEGORY_ID AND
                      bsum.CREDIT_TYPE_ID = stage.CREDIT_TYPE_ID
                      )
                  WHEN MATCHED THEN UPDATE SET bsum.forecast_amt = (bsum.forecast_amt+ stage.amount)
                                      ,bsum.forecast_amt_s = (bsum.forecast_amt_s+ stage.sec_amount)
                                      ,bsum.opp_forecast_amt = (bsum.opp_forecast_amt+ stage.opp_amount)
                                      ,bsum.opp_forecast_amt_s = (bsum.opp_forecast_amt_s+ stage.sec_opp_amount)
                                      ,bsum.LAST_UPDATED_BY  = g_user_id
                                      ,bsum.LAST_UPDATE_DATE = l_sysdate
                                      ,bsum.LAST_UPDATE_LOGIN= G_Login_Id

                  WHEN NOT MATCHED THEN INSERT
  (TXN_TIME_ID  ,
  TXN_PERIOD_TYPE_ID  ,
  FORECAST_TIME_ID    ,
  FORECAST_PERIOD_TYPE_ID    ,
  SALES_GROUP_ID       ,
  SALESREP_ID     ,
  FORECAST_AMT  ,
  forecast_amt_s  ,
  OPP_FORECAST_AMT  ,
  opp_forecast_amt_s  ,
  PRODUCT_CATEGORY_ID,
  CREDIT_TYPE_ID,
  CREATION_DATE  ,
  CREATED_BY    ,
  LAST_UPDATE_DATE   ,
  LAST_UPDATE_LOGIN   ,
  LAST_UPDATED_BY,
  REQUEST_ID,
  PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE
  )
values(
  STAGE.TXN_TIME_ID  ,
  STAGE.TXN_PERIOD_TYPE_ID  ,
  STAGE.FORECAST_TIME_ID    ,
  STAGE.FORECAST_PERIOD_TYPE_ID,
  STAGE.SALES_GROUP_ID,
  STAGE.SALESREP_ID,
  stage.amount,
  stage.sec_amount,
  stage.opp_amount,
  stage.sec_opp_amount,
  STAGE.PRODUCT_CATEGORY_ID,
  STAGE.CREDIT_TYPE_ID,
  sysdate,
  g_user_id,
  sysdate,
  g_user_id ,
  g_login_id ,
  G_request_id,
  G_appl_id,
  G_program_id,
  sysdate);

 l_number_of_rows := SQL%ROWCOUNT;
END IF;

commit;

 g_fact_row_proc := l_number_of_rows;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc,
            p_msg => 'Merged ' || l_number_of_rows || ' rows of records into fact table');
    END IF;


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' end ',
            p_msg => ' End of Procedure ' || l_proc);
END IF;

  COMMIT;

    EXCEPTION

       WHEN OTHERS Then
         g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
      p_module => g_pkg || l_proc || ' proc_error ',
      p_msg => fnd_message.get,
      p_force_log => TRUE);

         raise;

END Insert_From_Stg;




--------------------------------------------------------------------
-- PROCEDURE SUMMARY_ADJUST is
--------------------------------------------------------------------
PROCEDURE Summary_Adjust IS

 l_period_name   VARCHAR2(15) ;
 l_number_of_rows number;
 l_proc VARCHAR2(100);

  cursor c5 is select distinct stg.period_name
    FROM
       BIL_BI_FST_DTL_STG stg
      WHERE valid_flag = 'F';

BEGIN

/* initialization of variable */
 l_number_of_rows :=0;
 l_proc := 'Summary_Adjust.';
/* end initialization of variable */

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' begin ',
            p_msg => ' Start of Procedure ' || l_proc);
END IF;


   CASE
    WHEN g_map_ent_per_type = 'FII_TIME_WEEK' THEN
      BEGIN

      update  BIL_BI_FST_DTL_STG stg set valid_flag = 'F' WHERE
       not exists
          (select '1' FROM
         gl_periods glp,
         FII_TIME_WEEK fep
         WHERE
         fep.start_date  = glp.start_date   and
         fep.end_date    = glp.end_date   and
         glp.period_set_name = g_cal   and
         glp.period_name = stg.period_name  and
         glp.period_type = g_fsct_per_type );

     END;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_PERIOD' THEN
      BEGIN

      update  BIL_BI_FST_DTL_STG stg set valid_flag = 'F' WHERE
       not exists
          (select '1' FROM
         gl_periods glp,
         FII_TIME_ENT_PERIOD fep
         WHERE
         fep.start_date  = glp.start_date   and
         fep.end_date    = glp.end_date   and
         glp.period_set_name = g_cal   and
         glp.period_name = stg.period_name  and
         glp.period_type = g_fsct_per_type );
       END;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_QTR' THEN
      BEGIN

      update  BIL_BI_FST_DTL_STG stg set valid_flag = 'F' WHERE
       not exists
          (select '1' FROM
         gl_periods glp,
         FII_TIME_ENT_QTR fep
         WHERE
         fep.start_date  = glp.start_date   and
         fep.end_date    = glp.end_date   and
         glp.period_set_name = g_cal   and
         glp.period_name = stg.period_name  and
         glp.period_type = g_fsct_per_type );
       END;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_YEAR' THEN
      BEGIN


      update  BIL_BI_FST_DTL_STG stg set valid_flag = 'F' WHERE
       not exists
          (select '1' FROM
         gl_periods glp,
         FII_TIME_ENT_YEAR fep
         WHERE
         fep.start_date  = glp.start_date   and
         fep.end_date    = glp.end_date   and
         glp.period_set_name = g_cal   and
         glp.period_name = stg.period_name  and
         glp.period_type = g_fsct_per_type );
       END;

    END CASE;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc,
            p_msg => 'updated status bits of ' || sql%rowcount ||' rows,
                          they will be deleted due to invalid mapping forecast period');
    END IF;

-- wzhu added fix for bug 3792767
    commit;

-- delete the records before the amt are adjusted

-- Check to see if all gl periods exists in enterprise calendar


      OPEN c5;
       LOOP
           FETCH c5 into
                 l_period_name ;
           EXIT WHEN c5%NOTFOUND ;
           l_number_of_rows :=l_number_of_rows + 1;


        IF(l_number_of_rows=1) THEN
          fnd_message.set_name('BIL','BIL_BI_FST_PERIOD_MAP_ERROR');
         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_ERROR) THEN
           bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc,
              p_msg =>fnd_message.get);
         END IF;

        END IF;

        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc,
              p_msg =>l_period_name);
        END IF;

       END LOOP;
       CLOSE c5;

  IF(l_number_of_rows > 0) THEN

  DELETE FROM bil_bi_processed_fst_id WHERE forecast_id IN
    (SELECT forecast_id FROM BIL_BI_FST_DTL_STG
    WHERE valid_flag = 'F');

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_STATEMENT,
            p_module => g_pkg || l_proc,
            p_msg =>'deleted '||SQL%ROWCOUNT||' rows FROM bil_bi_processed_fst_id table due to valid_flag');
   END IF;


  DELETE  FROM  BIL_BI_FST_DTL_STG stg WHERE valid_flag = 'F';

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_STATEMENT,
            p_module => g_pkg || l_proc,
            p_msg =>'deleted '||SQL%ROWCOUNT||' rows from BIL_BI_FST_DTL_STG table due to valid_flag');
   END IF;


  END IF;

  commit;


  /* summary adjustments takes place here */


   IF (g_conv_rate_cnt = 0) THEN
     CASE WHEN g_map_ent_per_type = 'FII_TIME_WEEK' THEN

       CASE WHEN g_mode='INITIAL' OR g_first_run THEN

         UPDATE /*+ parallel(stg) */ BIL_BI_FST_DTL_STG stg
         SET stg.FORECAST_PERIOD_Week
         = (select fep.week_id FROM FII_TIME_WEEK fep ,  gl_periods glp
         WHERE
           fep.start_date = glp.start_date   and
           fep.end_date = glp.end_date   and
           glp.period_set_name = g_cal   and
           glp.period_name = stg.period_name  and
           glp.period_type = g_fsct_per_type
         );

       ELSE

        UPDATE BIL_BI_FST_DTL_STG stg
         SET stg.FORECAST_PERIOD_Week
        = (select fep.week_id FROM FII_TIME_WEEK fep ,  gl_periods glp
        WHERE
         fep.start_date = glp.start_date   and
         fep.end_date = glp.end_date   and
         glp.period_set_name = g_cal   and
         glp.period_name = stg.period_name  and
         glp.period_type = g_fsct_per_type
         ),
        (stg.forecast_amt_1,stg.forecast_amt_s_1,stg.opp_forecast_amt_1,stg.opp_forecast_amt_s_1) =
          (
            SELECT
              (stg.forecast_amt-pfi.forecast_amt),(stg.forecast_amt_s - pfi.forecast_amt_s),
              (stg.opp_forecast_amt-pfi.opp_forecast_amt),(stg.opp_forecast_amt_s - pfi.opp_forecast_amt_s)
            FROM
              bil_bi_processed_fst_id pfi
            WHERE
              pfi.product_category_id=stg.product_category_id
              AND pfi.sales_group_id=stg.sales_group_id
              AND NVL(pfi.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
              AND pfi.period_name=stg.period_name
              AND pfi.credit_type_id=stg.credit_type_id
              AND rownum < 2
              AND pfi.submission_date=
                (
                  SELECT MAX(submission_date) FROM bil_bi_processed_fst_id pfi1
                  WHERE
                    pfi1.product_category_id=stg.product_category_id
                    AND pfi1.sales_group_id=stg.sales_group_id
                    AND NVL(pfi1.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
                    AND pfi1.period_name=stg.period_name
                    AND pfi1.credit_type_id=stg.credit_type_id
                    AND pfi1.submission_date < stg.submission_date
                )
           );

       END CASE;


    WHEN g_map_ent_per_type = 'FII_TIME_ENT_PERIOD' THEN

      CASE WHEN g_mode='INITIAL' OR g_first_run  THEN

      UPDATE /*+ parallel(stg) */ BIL_BI_FST_DTL_STG stg set stg.FORECAST_PERIOD_PERIOD
      = (SELECT fep.ent_period_id FROM FII_TIME_ENT_PERIOD fep,gl_periods glp
      WHERE
       fep.start_date = glp.start_date and
       fep.end_date = glp.end_date and
       glp.period_set_name = g_cal and
       glp.period_name = stg.period_name and
       glp.period_type = g_fsct_per_type
       );

      ELSE

      UPDATE BIL_BI_FST_DTL_STG stg set stg.FORECAST_PERIOD_PERIOD
      = (select fep.ent_period_id FROM FII_TIME_ENT_PERIOD fep ,  gl_periods glp
      WHERE
       fep.start_date = glp.start_date   and
       fep.end_date = glp.end_date   and
       glp.period_set_name = g_cal   and
       glp.period_name = stg.period_name  and
       glp.period_type = g_fsct_per_type
       ),
        (stg.forecast_amt_1,stg.forecast_amt_s_1,stg.opp_forecast_amt_1,stg.opp_forecast_amt_s_1) =
          (
            SELECT
              (stg.forecast_amt-pfi.forecast_amt),(stg.forecast_amt_s - pfi.forecast_amt_s),
              (stg.opp_forecast_amt-pfi.opp_forecast_amt),(stg.opp_forecast_amt_s - pfi.opp_forecast_amt_s)
            FROM
              bil_bi_processed_fst_id pfi
            WHERE
              pfi.product_category_id=stg.product_category_id
              AND pfi.sales_group_id=stg.sales_group_id
              AND NVL(pfi.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
              AND pfi.period_name=stg.period_name
              AND pfi.credit_type_id=stg.credit_type_id
              AND rownum < 2
              AND pfi.submission_date=
                (
                  SELECT MAX(submission_date) FROM bil_bi_processed_fst_id pfi1
                  WHERE
                    pfi1.product_category_id=stg.product_category_id
                    AND pfi1.sales_group_id=stg.sales_group_id
                    AND NVL(pfi1.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
                    AND pfi1.period_name=stg.period_name
                    AND pfi1.credit_type_id=stg.credit_type_id
                    AND pfi1.submission_date < stg.submission_date
                )
           );

      END CASE;

    WHEN g_map_ent_per_type = 'FII_TIME_ENT_QTR' THEN

      CASE WHEN g_mode='INITIAL' OR g_first_run  THEN

      UPDATE /*+ parallel(stg) */ BIL_BI_FST_DTL_STG stg set stg.FORECAST_PERIOD_QUARTER
      = (SELECT fep.ent_qtr_id FROM FII_TIME_ENT_QTR fep,gl_periods glp
      WHERE
        fep.start_date = glp.start_date   and
        fep.end_date = glp.end_date   and
        glp.period_set_name = g_cal   and
        glp.period_name = stg.period_name  and
        glp.period_type = g_fsct_per_type
      );

    ELSE

      UPDATE BIL_BI_FST_DTL_STG stg set stg.FORECAST_PERIOD_QUARTER
      = (select fep.ent_qtr_id FROM FII_TIME_ENT_QTR fep ,  gl_periods glp
      WHERE
        fep.start_date = glp.start_date   and
        fep.end_date = glp.end_date   and
        glp.period_set_name = g_cal   and
        glp.period_name = stg.period_name  and
        glp.period_type = g_fsct_per_type
      ),
        (stg.forecast_amt_1,stg.forecast_amt_s_1,stg.opp_forecast_amt_1,stg.opp_forecast_amt_s_1) =
          (
            SELECT
              (stg.forecast_amt-pfi.forecast_amt),(stg.forecast_amt_s - pfi.forecast_amt_s),
              (stg.opp_forecast_amt-pfi.opp_forecast_amt),(stg.opp_forecast_amt_s - pfi.opp_forecast_amt_s)
            FROM
              bil_bi_processed_fst_id pfi
            WHERE
              pfi.product_category_id=stg.product_category_id
              AND pfi.sales_group_id=stg.sales_group_id
              AND NVL(pfi.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
              AND pfi.period_name=stg.period_name
              AND pfi.credit_type_id=stg.credit_type_id
              AND rownum < 2
              AND pfi.submission_date=
                (
                  SELECT MAX(submission_date) FROM bil_bi_processed_fst_id pfi1
                  WHERE
                    pfi1.product_category_id=stg.product_category_id
                    AND pfi1.sales_group_id=stg.sales_group_id
                    AND NVL(pfi1.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
                    AND pfi1.period_name=stg.period_name
                    AND pfi1.credit_type_id=stg.credit_type_id
                    AND pfi1.submission_date < stg.submission_date
                )
           );

    END CASE;

   WHEN g_map_ent_per_type = 'FII_TIME_ENT_YEAR' THEN

      CASE WHEN g_mode='INITIAL' OR g_first_run THEN

      UPDATE BIL_BI_FST_DTL_STG stg set stg.FORECAST_PERIOD_YEAR
      = (SELECT fep.ent_year_id FROM FII_TIME_ENT_YEAR fep,gl_periods glp
      WHERE
        fep.start_date = glp.start_date   and
        fep.end_date = glp.end_date   and
        glp.period_set_name = g_cal   and
        glp.period_name = stg.period_name  and
        glp.period_type = g_fsct_per_type
       );

     ELSE

      UPDATE BIL_BI_FST_DTL_STG stg set stg.FORECAST_PERIOD_YEAR
      = (select fep.ent_year_id FROM FII_TIME_ENT_YEAR fep ,  gl_periods glp
      WHERE
        fep.start_date = glp.start_date   and
        fep.end_date = glp.end_date   and
        glp.period_set_name = g_cal   and
        glp.period_name = stg.period_name  and
        glp.period_type = g_fsct_per_type
       ),
        (stg.forecast_amt_1,stg.forecast_amt_s_1,stg.opp_forecast_amt_1,stg.opp_forecast_amt_s_1) =
          (
            SELECT
              (stg.forecast_amt-pfi.forecast_amt),(stg.forecast_amt_s - pfi.forecast_amt_s),
              (stg.opp_forecast_amt-pfi.opp_forecast_amt),(stg.opp_forecast_amt_s - pfi.opp_forecast_amt_s)
            FROM
              bil_bi_processed_fst_id pfi
            WHERE
              pfi.product_category_id=stg.product_category_id
              AND pfi.sales_group_id=stg.sales_group_id
              AND NVL(pfi.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
              AND pfi.period_name=stg.period_name
              AND pfi.credit_type_id=stg.credit_type_id
              AND rownum < 2
              AND pfi.submission_date=
                (
                  SELECT MAX(submission_date) FROM bil_bi_processed_fst_id pfi1
                  WHERE
                    pfi1.product_category_id=stg.product_category_id
                    AND pfi1.sales_group_id=stg.sales_group_id
                    AND NVL(pfi1.salesrep_id,-999) = NVL(stg.salesrep_id,-999)
                    AND pfi1.period_name=stg.period_name
                    AND pfi1.credit_type_id=stg.credit_type_id
                    AND pfi1.submission_date < stg.submission_date
                )
           );
    END CASE;
  END CASE;
  END IF;

  /* end of summary adjustments */


  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
    bil_bi_util_collection_pkg.writeLog
    (
      p_log_level => fnd_log.LEVEL_EVENT,
      p_module => g_pkg || l_proc,
      p_msg => 'smmary adjusted forecast time of ' || sql%rowcount ||' rows'
    );
  END IF;

  commit;

--update forecast_amt and forecast_amt_s columns to have the correct values

  UPDATE
   bil_bi_fst_dtl_stg
  SET
    forecast_amt = forecast_amt_1,forecast_amt_s=forecast_amt_s_1,
    opp_forecast_amt=opp_forecast_amt_1,opp_forecast_amt_s=opp_forecast_amt_s_1
  WHERE forecast_amt_1 IS NOT NULL;

            IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
              bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc,
                p_msg => 'secondary currency update done for' || sql%rowcount ||' rows');
            END IF;



       COMMIT;


     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module => g_pkg || l_proc || ' end ',
              p_msg => ' End of Procedure ' || l_proc);
     END IF;


    EXCEPTION

       WHEN OTHERS Then
        g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error ',
           p_msg => fnd_message.get,
           p_force_log => TRUE);

         raise;
END summary_adjust;
--------------------------------------------------------------------
-- PROCEDURE SUMMARY_ERR_CHECK
--------------------------------------------------------------------
PROCEDURE SUMMARY_ERR_CHECK IS

      l_time_cnt       NUMBER;
      l_stg_min        DATE;
      l_stg_max        DATE;
      l_day_min        DATE;
      l_day_max        DATE;
      l_miss_date      BOOLEAN;
      l_period_name    VARCHAR2(15) ;
      l_number_of_rows NUMBER;
      l_proc           VARCHAR2(100);

BEGIN

/* initialization of variable */
  l_time_cnt :=0;
  l_miss_date := FALSE;
  l_number_of_rows :=0;
  l_proc := 'SUMMARY_ERR_CHECK.';
/* end initialization of variable */

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
            p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' begin ',
            p_msg => ' Start of Procedure ' || l_proc);
  END IF;

      ------------------------------------------------------
      -- If there are missing exchange rates indicated in
      -- the staging table, then call report_missing_rates
      -- API to print out the missing rates report
      ------------------------------------------------------


   IF (g_truncate_flag OR g_first_run) THEN

      SELECT /*+ PARALLEL(rates) */ COUNT(1)
      INTO   g_conv_rate_cnt
      FROM   bil_bi_currency_rate rates
      WHERE  ((exchange_rate < 0 OR exchange_rate is NULL)
              OR (g_sec_currency IS NOT NULL AND (exchange_rate_s < 0 OR exchange_rate_s is NULL)))
      AND exchange_date IN (SELECT DISTINCT TRUNC(submission_date) FROM bil_bi_new_fst_id)
      AND rownum < 2;
   ELSE
      SELECT COUNT(1)
      INTO   g_conv_rate_cnt
      FROM   bil_bi_currency_rate
      WHERE  ((exchange_rate < 0 OR exchange_rate is NULL)
             OR (g_sec_currency IS NOT NULL AND (exchange_rate_s < 0 OR exchange_rate_s is NULL)))
      AND exchange_date IN (SELECT DISTINCT TRUNC(submission_date) FROM bil_bi_new_fst_id)
      AND rownum < 2;
   END IF;

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc,
          p_msg => 'err check: value in variable g_conv_rate_cnt is '||g_conv_rate_cnt);
      END IF;

    IF (g_conv_rate_cnt >0) THEN  -- Missing Rates Starts Here
         -------------------------------------------------
         -- Write out translated message to let user know
         -- there are missing exchange rate information
         -------------------------------------------------
      FII_MESSAGE.write_log(msg_name => 'BIS_DBI_CURR_PARTIAL_LOAD',token_num => 0);

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc,
          p_msg => 'Missing currency conversion rates found, '
           ||'program will exit with warning status.  '
           ||'Please fix the missing conversion rates');
      END IF;
        g_retcode := -1;
        g_missing_rates := 1;
        REPORT_MISSING_RATES;
    ELSE
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc,
            p_msg => 'No Missing rates found!'
          );
        END IF;

    END IF;  -- Missing Rates Ends Here


      -----------------------------------------------------------
      -- If we find record in the aif table which references
      -- time records which does not exist in FII_TIME_DAY
      -- table, then we will exit the program with warning
      -- status
      -----------------------------------------------------------
     -- Check for Missing Time Dimension for Submission Date Time ID

     SELECT  MIN(nfi.submission_date),
             MAX(nfi.submission_date)
      INTO   l_stg_min,
             l_stg_max
      FROM   bil_bi_new_fst_id nfi;

   IF (l_stg_min IS NOT NULL  AND l_stg_max IS NOT NULL) THEN
     FII_TIME_API.check_missing_date
     (
       l_stg_min,
       l_stg_max,
       l_miss_date
     );
   END IF;


   IF (l_miss_date) THEN
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg => 'Time dimension is not fully populated.'
       );
     END IF;
     g_retcode := -1;
     g_missing_time := 1;
   ELSE
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg => 'Time dimension is fully populated for transaction time id'
       );
     END IF;
   END IF;

   -- Check for Missing Time Dimension for Forecast Time ID

  SELECT
    MIN(glp.start_date),
    MAX(glp.end_date)
  INTO
    l_day_min,
    l_day_max
  FROM
    bil_bi_new_fst_id nfi,
    gl_periods glp
  WHERE
    glp.period_set_name = g_cal
    AND  glp.period_name = nfi.period_name
    AND  glp.period_type = g_fsct_per_type;

  IF(l_day_min IS NULL OR l_day_max IS NULL) THEN
     RETURN ;
  ELSE
     BEGIN
       FII_TIME_API.check_missing_date (l_day_min,l_day_max, l_miss_date);

        IF (l_miss_date) THEN
         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
                bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_EVENT,
                  p_module => g_pkg || l_proc,
                p_msg => 'Time dimension is not fully populated.');
            END IF;
            g_retcode := -1;
            g_missing_time := 1;
        ELSE
           IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
                bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc,
                p_msg => 'Time dimension is  fully populated for forecast time id');
           END IF;
        END IF;

     END;
   END IF;

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
                bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc,
              p_msg => 'Summary error check completed!');
 END IF;

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' end ',
            p_msg => ' End of Procedure ' || l_proc);
 END IF;

EXCEPTION
      WHEN OTHERS THEN
        g_retcode:=-1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_UNEXPECTED,
          p_module => g_pkg || l_proc || ' proc_error ',
          p_msg => fnd_message.get
        );
        Raise;

END Summary_err_check;

-- ---------------------------------------------------------------
-- PROCEDURE REPORT_MISSING_RATES
-- ---------------------------------------------------------------
PROCEDURE REPORT_MISSING_RATES IS
       TYPE cursorType is  REF CURSOR;
       l_curr  CURSORTYPE;
       l_proc VARCHAR2(100);

     CURSOR MissingRate_p IS
       SELECT
         rate.currency_code,
         TRUNC(DECODE(rate.exchange_rate,-3,
         TO_DATE('01/01/1999','MM/DD/RRRR'), LEAST(SYSDATE,report_date))) report_date,
         decode(sign(nvl(rate.exchange_rate,-1)),-1,'P') prim_curr_type,
         decode(sign(nvl(rate.exchange_rate_s,-1)),-1,'S') sec_curr_type
        FROM
          bil_bi_currency_rate rate,
          fii_time_day fday
        WHERE
          rate.exchange_date IN (SELECT DISTINCT TRUNC(submission_date) FROM bil_bi_new_fst_id)
          AND rate.exchange_date = fday.report_date
          AND ((exchange_rate < 0 OR exchange_rate IS NULL)
               OR (g_sec_currency IS NOT NULL AND (exchange_rate_s < 0 OR exchange_rate_s IS NULL)));

BEGIN

/* initialization of variable */
  l_proc := 'REPORT_MISSING_RATES.';
/* end initialization of variable */

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' begin ',
            p_msg => ' Start of Procedure ' || l_proc||' For missing conversion ');
END IF;

       -------------------------------------------------
   -- Write out translated message to let user know
         -- there are missing exchange rate information
         -------------------------------------------------
  FII_MESSAGE.write_log(msg_name => 'BIS_DBI_CURR_PARTIAL_LOAD',token_num  => 0);

  BIS_COLLECTION_UTILITIES.WriteMissingRateHeader;

  FOR rate_record in MissingRate_p  LOOP

    IF (rate_record.prim_curr_type = 'P') THEN
          BIS_COLLECTION_UTILITIES.writemissingrate(
          g_prim_rate_type,
          rate_record.currency_code,
          g_prim_currency,
          rate_record.report_date);
    END IF;

    IF (rate_record.sec_curr_type='S') THEN
          BIS_COLLECTION_UTILITIES.writemissingrate(
          g_sec_rate_type,
          rate_record.currency_code,
          g_sec_currency,
          rate_record.report_date);
    END IF;

  END LOOP;


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' end ',
            p_msg => ' End of Procedure ' || l_proc);
END IF;

EXCEPTION

 WHEN OTHERS THEN
        g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
      p_module => g_pkg || l_proc || ' proc_error ',
      p_msg => fnd_message.get,
      p_force_log => TRUE);
  RAISE;

END REPORT_MISSING_RATES;




PROCEDURE Validate_Setup (ret_status OUT NOCOPY BOOLEAN) IS

l_ret_status        BOOLEAN;
l_conv_rate_count   NUMBER;
l_min_date          DATE;
l_max_date          DATE;
l_gl_min_date       DATE;
l_gl_max_date       DATE;
l_miss_date         BOOLEAN;
l_proc              VARCHAR2(100);
l_fst_id            NUMBER;
l_fst_name          VARCHAR2(100);
l_number_of_rows    NUMBER;
l_cnt               NUMBER;
l_per_name          VARCHAR2(100);
l_stg_cnt           NUMBER;


CURSOR fst_prod_csr IS
    SELECT
      afsc1.forecast_category_id,
      afsc_tl.forecast_category_name
    FROM
      as_fst_sales_categories afsc1,
      as_forecast_categories_tl  afsc_tl
    WHERE
      afsc1.forecast_category_id =  afsc_tl.forecast_category_id
      AND afsc_tl.LANGUAGE = userenv('LANG')
      AND NVL(afsc1.end_date_active,SYSDATE) >= SYSDATE
      AND afsc1.start_date_active <= SYSDATE
      AND NOT(NVL(interest_type_id,-1)<0 AND product_category_id IS NULL)
    GROUP BY afsc1.forecast_category_id,
      afsc_tl.forecast_category_name
    HAVING COUNT(1) > 1;

CURSOR asf_bil_per_csr IS
   SELECT
     DISTINCT glp2.period_name
   FROM
     gl_periods glp1,
     gl_periods glp2
   WHERE glp1.period_set_name = g_cal
     AND glp2.period_set_name = g_asf_calendar
     AND glp2.period_name = glp1.period_name
     AND (glp1.start_date <> glp2.start_date OR glp1.end_date <> glp2.end_date);

BEGIN

/* initialization of variable */
l_ret_status := TRUE;
l_conv_rate_count := 0;
l_miss_date := FALSE;
l_proc := 'Validate_Setup.';
l_number_of_rows := 0;
l_cnt := 0;
l_stg_cnt := 0;
/* end initialization of variable */

/*
  Check to see if there are product category id as NULL!
  In such a case, error out.
  this is fix for bug - 3560477
*/

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' Start ',
            p_msg => ' Start of Procedure ' || l_proc);
 END IF;

    l_cnt := 0;  -- reset the counter


    SELECT
      COUNT(1)
    INTO l_cnt
    FROM
      as_fst_sales_categories afsc1
    WHERE
      NVL(afsc1.end_date_active,SYSDATE) >= SYSDATE
      AND afsc1.start_date_active <= SYSDATE
      AND afsc1.product_category_id IS NULL
      AND NVL(afsc1.interest_type_id,-1) > 0;


   IF(l_cnt>0) THEN  -- Product categories are NULL in as_fst_sales_categories table

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc,
         p_msg => 'There are product categories in as_fst_sales_categories with value NULL'
       );
     END IF;


     fnd_message.set_name('BIL','BIL_BI_FST_PROD_CAT_NUL_ERR');
     bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_ERROR,
       p_module => g_pkg || l_proc || 'proc_error',
       p_msg => fnd_message.get
     );

     FOR ro IN
     (
        SELECT
          afsc1.forecast_category_id,
          afsc_tl.forecast_category_name
        FROM
          as_fst_sales_categories afsc1,
          as_forecast_categories_tl  afsc_tl
        WHERE
          afsc1.forecast_category_id =  afsc_tl.forecast_category_id
          AND afsc_tl.LANGUAGE = userenv('LANG')
          and NVL(afsc1.end_date_active,SYSDATE) >= SYSDATE
          and afsc1.start_date_active <= SYSDATE
          and afsc1.product_category_id IS NULL
          AND NVL(afsc1.interest_type_id,-1) > 0
        GROUP BY
         afsc1.forecast_category_id,
         afsc_tl.forecast_category_name
     )
     LOOP


   fnd_message.set_name('BIL','BIL_BI_FST_CAT_MAP_ERR_DTL');
   fnd_message.set_token('FORECAST_CATEGORY_ID', ro.forecast_category_id);
   fnd_message.set_token('FORECAST_CATEGORY_NAME', ro.forecast_category_name);
   bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
             p_msg => fnd_message.get,
             p_force_log => TRUE);


     END LOOP;

     l_ret_status:=FALSE;
   END IF;

-- end of product categry id IS NULL check

-- Check for OSO and BIL Calendar Mismatch

  OPEN asf_bil_per_csr;
  LOOP
  FETCH asf_bil_per_csr
    INTO l_per_name;
  EXIT WHEN asf_bil_per_csr%NOTFOUND ;
    l_number_of_rows :=l_number_of_rows + 1;

    IF(l_number_of_rows=1) THEN  -- OS vs BIS Calendar Period Mismatch
     -- print header
      fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
            bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
             p_module => g_pkg || l_proc || 'proc_error',
             p_msg => fnd_message.get,
             p_force_log => TRUE);
      fnd_message.set_name('BIL','BIL_BI_PER_MISMATCH_HDR');
             bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
             p_module => g_pkg || l_proc || 'proc_error',
             p_msg => fnd_message.get,
             p_force_log => TRUE);
      l_ret_status:=FALSE;

    END IF;
      -- print detail
    fnd_message.set_name('BIL','BIL_BI_PER_MISMATCH_DTL');
    fnd_message.set_token('OFFENDING_PERIOD_NAME', l_per_name);
    bil_bi_util_collection_pkg.writeLog
    (
      p_log_level => fnd_log.LEVEL_ERROR,
      p_module => g_pkg || l_proc || 'proc_error',
      p_msg => fnd_message.get,
      p_force_log => TRUE
    );
  END LOOP;
  CLOSE asf_bil_per_csr;

    -- Check Forecast and Product Category 1-to-1 Mapping
    -- If there are 1:M FC:PC mappings then warn that such data will not be collected.
    l_number_of_rows := 0;  -- reset the counter


    IF (g_mode = 'INITIAL') THEN -- the 1:M check should be perfomed only for initial load
      OPEN fst_prod_csr;
      LOOP
      FETCH fst_prod_csr
      INTO l_fst_id,
           l_fst_name;
      EXIT WHEN fst_prod_csr%NOTFOUND ;
        l_number_of_rows :=l_number_of_rows + 1;
        IF(l_number_of_rows=1) THEN  -- Forecast to Product Category Mapping Not 1-to-1
          -- print header
          fnd_message.set_name('BIL','BIL_BI_FST_CAT_MAP_ERR_HDR');
          fnd_message.set_token('ASN_IMPLEM_DATE', g_asn_date);
          bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
            p_module => g_pkg || l_proc || 'proc_error',
            p_msg => fnd_message.get,
            p_force_log => TRUE);
          g_warn_flag := 'Y';
        END IF;
        -- print detail
        fnd_message.set_name('BIL','BIL_BI_FST_CAT_MAP_ERR_DTL');
        fnd_message.set_token('FORECAST_CATEGORY_ID', l_fst_id);
        fnd_message.set_token('FORECAST_CATEGORY_NAME', l_fst_name);
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_ERROR,
          p_module => g_pkg || l_proc || 'proc_error',
          p_msg => fnd_message.get,
          p_force_log => TRUE
        );
      END LOOP;
      CLOSE fst_prod_csr;
    END IF;

  ret_status := l_ret_status;

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
        bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || ' end ',
            p_msg => ' End of Procedure ' || l_proc);
 END IF;


EXCEPTION

 WHEN OTHERS THEN
  g_retcode := -1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON', SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
      p_module => g_pkg || l_proc || ' proc_error ',
      p_msg => fnd_message.get,
      p_force_log => TRUE);
  RAISE;


END Validate_Setup;


PROCEDURE Check_Profiles(ret_status OUT NOCOPY BOOLEAN) IS
    l_list           DBMS_SQL.VARCHAR2_TABLE;
    l_val            DBMS_SQL.VARCHAR2_TABLE;
    l_ret_status     BOOLEAN;
    l_proc           VARCHAR2(100);

 BEGIN

 /* initialization of variable */
    l_ret_status := FALSE;
    l_proc := 'Check_Profiles.';
 /* end initialization of variable */

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;


     -- List of Profile for setup check
     l_list(1) := 'BIS_GLOBAL_START_DATE';
     l_list(2) := 'BIS_ENTERPRISE_CALENDAR';
     l_list(3) := 'BIS_PERIOD_TYPE';
     l_list(4) := 'BIL_BI_BASE_FST_PERIOD_TYPE';
     l_list(5) := 'BIL_BI_MAP_ENT_FST_PERIOD_TYPE';
     l_list(6) := 'BIL_BI_FST_ROLLUP';


     l_list(7) := 'ASN_FRCST_FORECAST_CALENDAR';

     l_list(8) := 'BIS_PRIMARY_CURRENCY_CODE';
     l_list(9) := 'BIS_PRIMARY_RATE_TYPE';

    -- Check if Profiles are setup
    IF (NOT bis_common_parameters.check_global_parameters(l_list)) THEN  -- Check Parameters
        bis_common_parameters.get_global_parameters(l_list, l_val);
         l_ret_status := FALSE;

        fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');

         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
            p_module => g_pkg || l_proc || 'proc_error',
            p_msg => fnd_message.get,
            p_force_log => TRUE);
      FOR v_counter IN 1..9 LOOP
        IF (l_val(v_counter) IS  NULL) THEN
          fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
          fnd_message.set_token('PROFILE_USER_NAME' ,
          bil_bi_util_collection_pkg.get_user_profile_name(l_list(v_counter)));
          fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(v_counter));

          bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE);
      END IF;
     END LOOP;
    ELSE

       bis_common_parameters.get_global_parameters(l_list, l_val);
       l_ret_status := TRUE;
    END IF; -- Check Parameters Ends Here


------------------------------
--Secondary currency chek
------------------------------

     l_list(10) := 'BIS_SECONDARY_CURRENCY_CODE';
     l_list(11) := 'BIS_SECONDARY_RATE_TYPE';
     l_list(12) := 'BIL_BI_ASN_IMPLEMENTED';

-- reget all values with the 2 new profiles!!
     bis_common_parameters.get_global_parameters(l_list, l_val);

-- Assign the primary currency code and rate type to the corresponding gloabal variables
     g_prim_currency := l_val(8);
     g_prim_rate_type := l_val(9);

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_STATEMENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'prim curr : prim rate type = '||g_prim_currency||' : '||g_prim_rate_type
       );
     END IF;

-- sec curr not set up at all
     IF (l_val(10) IS NULL) THEN
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (p_log_level => fnd_log.LEVEL_STATEMENT,p_module => g_pkg || l_proc ,
           p_msg => ' Secondary curency not set up '
         );
       END IF;
     END IF;

-- sec curr set up but rate type not set up : ERROR
     IF (l_val(10) IS NOT NULL AND l_val(11) IS NULL ) THEN
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (p_log_level => fnd_log.LEVEL_STATEMENT,p_module => g_pkg || l_proc ,
           p_msg => ' Secondary curency set up but rate type not set up: ERROR '
         );
       END IF;
       IF(l_ret_status = FALSE) THEN-- already a profile error reported.. so dont print header etc
         fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
         fnd_message.set_token('PROFILE_USER_NAME' ,
         bil_bi_util_collection_pkg.get_user_profile_name(l_list(11)));
         fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(11));
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
       ELSE -- print error msg with header also
         l_ret_status := FALSE;
         fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
         fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
         fnd_message.set_token('PROFILE_USER_NAME' ,
         bil_bi_util_collection_pkg.get_user_profile_name(l_list(11)));
         fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(11));
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
       END IF;
     END IF;

-- sec curr and rate type properly set up
     IF (l_val(10) IS NOT NULL AND l_val(11) IS NOT NULL ) THEN

       g_sec_currency := bis_common_parameters.get_secondary_currency_code;
       g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
           p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
           p_msg => 'sec curr : rate type = '||g_sec_currency||' : '||g_sec_rate_type
         );
       END IF;

     END IF;

     IF (l_val(12) IS NULL OR l_val(12)='N' OR l_val(12)='NO' OR l_val(12)='Y' OR l_val(12)='YES') THEN
       --ASN implementaion date has not been setup
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
           p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
           p_msg => 'Oracle Sales Implementation date is needed for data collection purpose.'||
                    ' Please specify a date and try again.'
          );
       END IF;

       IF(l_ret_status = FALSE) THEN-- already a profile error reported.. so dont print header etc
         fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
         fnd_message.set_token('PROFILE_USER_NAME' ,
         bil_bi_util_collection_pkg.get_user_profile_name(l_list(12)));
         fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(12));
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
       ELSE -- print error msg with header also
         l_ret_status := FALSE;
         fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
         fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
         fnd_message.set_token('PROFILE_USER_NAME' ,
         bil_bi_util_collection_pkg.get_user_profile_name(l_list(12)));
         fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(12));
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
       END IF;

     ELSE

       -- There is a valid ASN date
       g_asn_date := TO_DATE(l_val(12),'MM/DD/YYYY');
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
           p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
           p_msg => 'ASN implemented. Date = '||g_asn_date
          );
       END IF;

       -- New logic
       -- Make sure that the ASN implementation is <= sysdate
       -- This check to be enforced only for INITIAL collection

       IF ((g_mode = 'INITIAL') AND (g_asn_date > trunc(sysdate))) THEN

         -- Set the status to error
         l_ret_status := FALSE;

         -- Log a message in the CP log file and the CP ouput file
         fnd_message.set_name('BIL','BIL_BI_FUTURE_ASN_DATE');
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE); -- for fnd_message.get
       END IF;

     END IF;


    ret_status := l_ret_status;

    g_cal_start_date   := TO_DATE(l_val(1), 'MM/DD/YYYY');
    g_cal              := l_val(2);
    g_cal_per_type     := l_val(3);
    g_asf_calendar     := l_val(7);
    g_fsct_per_type    := l_val(4);
    g_map_ent_per_type := l_val(5);
    g_fst_rollup       := l_val(6);

     FOR i IN 1..11 LOOP
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
               p_log_level => fnd_log.LEVEL_EVENT,
               p_module => g_pkg || l_proc || ' prof',
               p_msg => 'Profile Name: '||l_list(i)||'<-> Value: '||l_val(i));
       END IF;
     END LOOP;

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
     END IF;


 EXCEPTION
  WHEN OTHERS THEN

    g_retcode := -1;
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
    fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
        p_module => g_pkg || l_proc || 'proc_error',
        p_msg => fnd_message.get,
        p_force_log => TRUE);

    RAISE;

END Check_Profiles;


END BIL_BI_FST_DTL_F_PKG;

/
