--------------------------------------------------------
--  DDL for Package Body BIL_BI_OPDTL_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_OPDTL_F_PKG" AS
/*$Header: bilos1b.pls 120.11 2006/10/05 16:32:57 esapozhn noship $*/

 g_retcode              VARCHAR2(20);
 g_start_date           DATE;
 g_end_date             DATE;
 G_global_start_date    DATE;
 G_status               BOOLEAN;
 g_bil_schema           VARCHAR2(30);

 g_prim_currency        VARCHAR2(10);
 g_prim_rate_type       VARCHAR2(15);

 g_sec_currency         VARCHAR2(10);
 g_sec_rate_type        VARCHAR2(15);

 g_primary_mau          NUMBER;
 g_phase                VARCHAR2(100);
 g_refresh_flag         VARCHAR2(1);

 g_missing_time         NUMBER;
 G_request_id           NUMBER;
 G_appl_id              NUMBER;
 G_program_id           NUMBER;
 G_user_id              NUMBER;
 G_login_id             NUMBER;
 g_row_num              NUMBER;
 g_program_start        DATE;
 g_load_flag    	VARCHAR2(1);
 g_credit_type_id       VARCHAR2(10);
 g_setup_error_flag     BOOLEAN;
 g_pkg 			VARCHAR2(100);


 --the following variable is used for a work around for log file messages not showing up in main program.
 --need to be removed once this problem is fixed
 g_debug       BOOLEAN;


 G_BIS_SETUP_ERROR  EXCEPTION;
 G_SETUP_VAL_ERROR  EXCEPTION;
 INVALID_SETUP      EXCEPTION;
-- ---------------------------------------------------------------
-- Private procedures and Functions Prototypes;
-- ---------------------------------------------------------------
--  ***********************************************************************
   PROCEDURE Report_Missing_Rates;

   --PROCEDURE Alter_Table (p_table_name in varchar2);

   PROCEDURE Init(p_object_name VARCHAR2);


   PROCEDURE Summary_Err_Check(x_valid_curr OUT NOCOPY VARCHAR2,
                               x_valid_date OUT NOCOPY VARCHAR2,
                               x_valid_prod OUT NOCOPY VARCHAR2,
                               x_return_warn OUT NOCOPY VARCHAR2);


   PROCEDURE Clean_Up ;

   PROCEDURE Ins_New_Chngd_Oppty_Incr;

   PROCEDURE Ins_New_Chngd_Oppty_Init;


   PROCEDURE Insert_Into_Sumry_Incr;

   PROCEDURE Insert_Into_Sumry_Init;


   PROCEDURE Main (errbuf              IN OUT NOCOPY VARCHAR2 ,
                   retcode             IN OUT NOCOPY  VARCHAR2,
                   p_start_date        IN      VARCHAR2,
                   p_end_date          IN      VARCHAR2,
       p_truncate         IN      VARCHAR2 ,
             p_load_flag         IN     VARCHAR2
             );


   PROCEDURE Check_Profiles(ret_status OUT NOCOPY BOOLEAN);

   PROCEDURE Setup_Validation(ret_status OUT NOCOPY BOOLEAN);

   PROCEDURE Populate_Currency_Rate;


  -- FUNCTION get_last_failure_period (p_object_name in varchar2) return varchar2 ;


   FUNCTION get_first_success_period(p_object_name in varchar2) return varchar2 ;



  /* function get_last_failure_period(p_object_name in varchar2) return varchar2 is
       l_date   	date;
       l_date_disp 	varchar2(100);
       l_proc       VARCHAR2(100);
   begin
     l_proc := 'get_last_failure_period';

     SELECT MAX(period_to) INTO l_date
     FROM bis_refresh_log
     WHERE object_name = p_object_name AND
           status='FAILURE' AND
           last_update_date =(SELECT MAX(last_update_date)
                              FROM bis_refresh_log
                              WHERE object_name= p_object_name AND
                                    status='FAILURE' ) ;

     IF (l_date IS NULL) THEN
        l_date:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
     END IF;

     l_date_disp := fnd_date.date_to_displaydt (l_date);
     return l_date_disp;

   Exception
      WHEN OTHERS THEN

         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
         fnd_message.set_token('ERRNO' ,SQLCODE);
         fnd_message.set_token('REASON', SQLERRM);
         fnd_message.set_token('ROUTINE', l_proc);
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
                 p_module => g_pkg || l_proc || ' proc_error',
                 p_msg => fnd_message.get,
                 p_force_log => TRUE);
       RAISE;
   end get_last_failure_period;
*/

   function get_first_success_period(p_object_name in varchar2) return varchar2 is
      l_date   	  date;
      l_date_disp varchar2(100);
      l_proc 	  VARCHAR2(100);
   begin
      l_proc  := 'get_first_success_period';

      SELECT MIN(period_from) INTO l_date
      FROM bis_refresh_log
      WHERE object_name = p_object_name AND
            status='SUCCESS' AND
            last_update_date =(SELECT MIN(last_update_date)
                               FROM bis_refresh_log
                               WHERE object_name= p_object_name AND
                                          status='SUCCESS' ) ;

      IF (l_date IS NULL) THEN
         l_date:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
      END IF;
      l_date_disp := fnd_date.date_to_displaydt (l_date);
      return l_date_disp;

   Exception
     WHEN OTHERS THEN
     /*Generic Exception Handling block.*/
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
          p_module => g_pkg || l_proc || ' proc_error',
          p_msg => fnd_message.get,
          p_force_log => TRUE);

      RAISE;
   end get_first_success_period;

-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------
/***************************************************
Initial Load:
p_from_date : Start Date of the collection_process
--p_to_date : assumed to be the sysdate,
p_truncate : Truncate flag (Y/N)
****************************************************/

PROCEDURE  Init_load
(
  errbuf              IN OUT NOCOPY VARCHAR2 ,
  retcode             IN OUT NOCOPY  VARCHAR2,
  p_from_date         IN  VARCHAR2,
  p_truncate          IN   VARCHAR2
)
IS
  l_valid_setup BOOLEAN;
  l_proc VARCHAR2(100);
BEGIN
  g_pkg := 'bil.patch.115.sql.bil_bi_opdtl_f_pkg.';
  l_proc := 'Init_load';

  l_valid_setup := BIS_COLLECTION_UTILITIES.SETUP('BIL_BI_OPDTL_F');
  IF (not l_valid_setup) THEN
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    		p_module => g_pkg || l_proc ,
    		p_msg => 'BIS_COLLECTION_UTILITIES.SETUP failed' );
     END IF;
     retcode := g_retcode;
     return;
  END IF;
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
  END IF;
  -- in the initial load mode, default start date to global start date
  -- default end date to sysdate , this is taken care by the main program
  Main
   (
     ERRBUF,
     RETCODE,
     p_from_date,
     to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'),--'2004/02/11 23:59:59',--
     p_truncate,
     'C'
   );

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
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;
END Init_load;


/***************************************************
Incremental Load:
****************************************************/

PROCEDURE  Incr_load
(
  errbuf     IN OUT NOCOPY VARCHAR2 ,
  retcode    IN OUT NOCOPY VARCHAR2
)
IS
  l_start_date 	VARCHAR2(30);
  l_end_date   	VARCHAR2(30);
  l_proc        VARCHAR2(100);
  l_valid_setup BOOLEAN;
BEGIN
   l_proc := 'Incr_load';
   g_pkg := 'bil.patch.115.sql.bil_bi_opdtl_f_pkg.';

   l_valid_setup := BIS_COLLECTION_UTILITIES.SETUP('BIL_BI_OPDTL_F');

   IF (not l_valid_setup) THEN
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    		p_module => g_pkg || l_proc ,
    		p_msg => 'BIS_COLLECTION_UTILITIES.SETUP failed' );
      END IF;
      retcode := g_retcode;
      return;
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;
   l_start_date :=
       to_char(fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('BIL_BI_OPDTL_F'))
       ,'YYYY/MM/DD HH24:MI:SS');

     -- Find the last collection time and use it as the start date for
   -- this time period.
   l_end_date := to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS');
   Main
   (
     ERRBUF,
     RETCODE,
     l_start_date,
     l_end_date,
     'N',
     'I'
   );
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
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
    END IF;
END Incr_load;



-- Procedure
--   Main()
-- Purpose
--   This Main routine Handles all functions involved in the Opportunity summarization
--   and populating Opportunity base summary table and cleaning.
--

PROCEDURE  Main (errbuf              	IN OUT NOCOPY VARCHAR2 ,
                 retcode             	IN OUT NOCOPY VARCHAR2,
                 p_start_date        	IN            VARCHAR2,
                 p_end_date          	IN            VARCHAR2,
     		 p_truncate          	IN            VARCHAR2,
     		 p_load_flag       	IN            VARCHAR2
           ) IS

     return_status      BOOLEAN;
     l_start_date       DATE;
     l_end_date         DATE;
     l_period_start_date DATE;
     l_period_end_date  DATE;
     p_number_of_rows   NUMBER;
     p_no_worker        NUMBER;
     l_conversion_count NUMBER;
     l_retcode          VARCHAR2(3);
     l_errbuf           VARCHAR2(500);
     l_stmt             VARCHAR2(300);
     l_ids_count        NUMBER;
     l_no_days          NUMBER;
     l_max_date         DATE;
     l_count            NUMBER;
     l_max_range        NUMBER;
     l_date_format      VARCHAR2(21);
     l_int_date_format  VARCHAR2(21);
     l_int_date_format1 VARCHAR2(21);
     l_valid_curr       VARCHAR2(1);
     l_valid_date       VARCHAR2(1);
     l_valid_prod  	VARCHAR2(1);
     l_return_warn      VARCHAR2(1);
     l_return_warn_resume VARCHAR2(1);
     l_warn_parameter   VARCHAR2(1);
     l_failure_date     DATE;

     l_statement       	VARCHAR2(500);
     l_fact_count    	NUMBER;
     l_proc       	VARCHAR2(100);
     l_denlog_count   	NUMBER;
     l_resume_flag     	VARCHAR2(1);
     l_valid_setup    	BOOLEAN;

	 l_bis_status BOOLEAN;
	 l_bis_message VARCHAR2(1000);

BEGIN

    g_bil_schema := 'BIL';
    g_refresh_flag := 'N';
    g_load_flag := p_load_flag;

    g_missing_time:= 0;
    g_row_num    :=0;
    G_status := FALSE;
    g_setup_error_flag := FALSE;
    --G_Start_date := TO_DATE(p_start_date, l_date_format);


    errbuf := NULL;
    retcode := 0;


    return_status:= TRUE;
    l_start_date:= NULL;
    l_end_date:=NULL;
    l_period_start_date:= NULL;
    l_period_end_date:= NULL;
    p_number_of_rows:=0;
    p_no_worker:=1;
    l_conversion_count:=0;
    l_ids_count:= 0;
    l_no_days:= 0;
    l_date_format:= 'YYYY/MM/DD HH24:MI:SS';
    l_int_date_format:='DD/MM/YYYY HH24:MI:SS';
    l_int_date_format1:='MM/DD/YYYY HH24:MI:SS';
    l_proc:= 'Main';
    l_resume_flag:= 'N';

    G_Start_date := TO_DATE(p_start_date, l_date_format);

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
       bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;

    /*Check for incremental(I) or complete refresh(F).*/
    G_Refresh_Flag := p_truncate;


    /*For initial set up call INIT*/
    Init(p_object_name => 'BIL_BI_OPDTL_F');

	/*ctoba ER 4160374 - uptake of BIS API */

	 l_failure_date := fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_failure_period('BIL_BI_OPDTL_F'));




    /*Check whether the data already there in staging table can go into the  sumry table. */
    BEGIN
      IF (G_Refresh_Flag <> 'Y') THEN
         -- see if there is anything in stage to resume
         SELECT count(1)
           INTO l_count
         FROM BIL_BI_OPDTL_STG
         WHERE rownum < 2;

         IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
            bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'No. of Rows in Staging are :'||l_count);
         END IF;
         IF (l_count > 0) THEN
            Populate_Currency_Rate;
            /*Update the staging with new conversion rates.*/
            Summary_Err_Check
            (
              x_valid_curr => l_valid_curr,
              x_valid_date => l_valid_date,
              x_valid_prod => l_valid_prod,
              x_return_warn => l_return_warn_resume
            );
            IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y') AND (l_valid_prod='Y') ) THEN
               IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
                  bil_bi_util_collection_pkg.writeLog
                  (
                    p_log_level => fnd_log.LEVEL_EVENT,
                    p_module => g_pkg || l_proc ,
                    p_msg =>'Summary Error Check Successful!'
                  );
               END IF;
               SELECT count(1) INTO l_count FROM BIL_BI_OPDTL_F WHERE rownum < 2;
               IF (l_count > 0) THEN
                  Insert_Into_Sumry_Incr;
               ELSE
                  Insert_Into_Sumry_Init;
               END IF;
               l_resume_flag := 'Y';

			   /*ctoba ER  4160374 - uptake of BIS API */

			   l_bis_status   := TRUE;
               l_bis_message  := 'Successful resumed from last run.';

			   BIS_COLLECTION_UTILITIES.WRITE_BIS_REFRESH_LOG(
        	   l_bis_status,
        	   g_row_num ,
        	   l_bis_message  ,
        	   g_start_date ,
        	   l_failure_date,
        	   null,
        	   null ,
        	   null ,
        	   null ,
        	   null ,
        	   null ,
        	   null ,
        	   null ,
        	   null ,
        	   null );

			   ELSE
                 g_end_date := l_failure_date;
                 IF (l_valid_prod='N') THEN
                    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_STG');
                 END IF;
                 RAISE INVALID_SETUP;
               END IF;
               commit;
            END IF;
         END IF;
    END;
    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_STG');
    -----------------------------------------------------------------
    -- If Truncate flag is 'Y' (Complete), then this program starts from the
    -- beginning:
    --     1. Identify the lead_ids for which the process need to run.
    --     2. Submit child process insert
    --        records into temporary staging table
    -- Otherwise, it would first check if all missing rates have been
    -- fixed, and then resume the normal process which includes:
    --     3. Merging summarized records into base summary table
    ------------------------------------------------------------------
   /*This is for complete refresh and if truncate_flag is yes*/

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Default Parameter : Global Start Date ='||G_global_Start_date);
   END IF;
   IF(g_refresh_flag = 'Y') THEN
     BIS_COLLECTION_UTILITIES.deleteLogForObject ('BIL_BI_OPDTL_F');
     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_F');

     IF p_start_date IS NOT NULL THEN
        G_Start_date := TO_DATE(p_start_date, l_date_format);
        IF(G_START_DATE <= sysdate) THEN
           IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
              bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_EVENT,
                  p_module => g_pkg || l_proc ,
                  p_msg => 'User Parameter : Start Date = ' || g_start_date);
           END IF;
        ELSE

          l_warn_parameter := 'Y';
          G_Start_date := sysdate;
          fnd_message.set_name('BIL','BIL_BI_DATE_PARAM_RESET');
          fnd_message.set_token('RESET_DATE', to_char(sysdate, l_date_format));
          IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_ERROR) THEN
             bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_ERROR,
                p_module => g_pkg || l_proc ,
                p_msg => fnd_message.get );
          END IF;
        END IF;
     ELSE
       G_Start_date :=
          fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('BIL_BI_OPDTL_F'));
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg => 'Default Parameter : Start Date ='||G_Start_date);
       END IF;
     END IF;
     G_END_DATE := TO_DATE(p_end_date, l_date_format);
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
           p_log_level => fnd_log.LEVEL_EVENT,
           p_module => g_pkg || l_proc ,
           p_msg => 'User Parameter : Purge = ' || g_refresh_flag);
     END IF;
   /*If its a Incremental Load*/
   ELSIF (g_load_flag = 'I') THEN
      -- check for resume action here.
      IF l_resume_flag = 'Y' THEN
         G_Start_Date := l_failure_date;
      ELSE
         G_Start_Date := TO_DATE(p_start_date, l_date_format);
      END IF;
         G_End_Date := TO_DATE(p_end_date, l_date_format);
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => 'Assigning the start and end Dates:'||to_char(G_Start_Date,l_date_format)||
            '  --  '||to_char(G_End_Date, l_date_format));
      END IF;
      /*If the Initial Load is ran without setting the truncate flag to 'Y'*/
   ELSE
      /* if both staing and fact has zero rows, treat it as an initial load */
      SELECT COUNT(1) into l_fact_count FROM BIL_BI_OPDTL_F where rownum < 2;

      /* resume should called wrap up which should have set last_refresh_period */

      l_max_date := fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('BIL_BI_OPDTL_F'));
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => 'L_max_date from bis_refresh_log:'||l_max_date);
      END IF;

      IF (p_start_date IS NOT NULL) THEN
         G_Start_date := l_max_date;
         IF (TO_DATE(p_start_date, l_date_format)= l_max_date) THEN
            IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
               bil_bi_util_collection_pkg.writeLog(
                  p_log_level => fnd_log.LEVEL_EVENT,
                  p_module => g_pkg || l_proc ,
                  p_msg => 'User Parameter : Start Date = ' || g_start_date );
            END IF;
         ELSE
            l_warn_parameter := 'Y';
           fnd_message.set_name('BIL','BIL_BI_DATE_PARAM_RESET');
           fnd_message.set_token('RESET_DATE', to_char(l_max_date, l_date_format));
            IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_ERROR) THEN
               bil_bi_util_collection_pkg.writeLog(
                    p_log_level => fnd_log.LEVEL_ERROR,
                    p_module => g_pkg || l_proc ,
                    p_msg => fnd_message.get );
            END IF;
         END IF;
      ELSE
        G_Start_date := l_max_date;
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Default Parameter : Start Date ='||G_Start_date);
        END IF;
      END IF;
      G_END_DATE := TO_DATE(p_end_date, l_date_format);
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'User Parameter : Purge = ' || g_refresh_flag );
      END IF;
   	IF (l_fact_count = 0) THEN
            g_refresh_flag := 'Y';
    ELSE
	      g_load_flag := 'I';
    END IF;
   END IF; -- IF (g_refresh_flag = 'Y')

   -- nologging
   --Alter_table('BIL_BI_OPDTL_STG');
   IF (g_refresh_flag = 'Y') THEN
      l_stmt:='alter session set sort_area_size=100000000';
      execute immediate l_stmt;

      l_stmt:='alter session set hash_area_size=100000000';
      execute immediate l_stmt;

      Ins_New_Chngd_Oppty_Init ;

   ELSE
      Ins_New_Chngd_Oppty_Incr;
   END IF;

   -- initial mode popoulate it using denlog tmp
   -- only incremental use staging table to populate

   Populate_Currency_Rate;

   -----------------------------------------------------------------
   -- If all the child process completes successfully then Invoke
   -- Summary_err_check routine to check for any Invalid currencies
   -- and invalid date ranges in staging table (BIL_BI_OPDTL_STG).
   -----------------------------------------------------------------
   g_phase:= 'Summarization Error Check';
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
               p_log_level => fnd_log.LEVEL_EVENT,
               p_module => g_pkg || l_proc ,
               p_msg => g_phase);
   END IF;
   Summary_Err_Check(x_valid_curr => l_valid_curr,
                      x_valid_date => l_valid_date,
                      x_valid_prod => l_valid_prod,
                      x_return_warn => l_return_warn);

   IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y') AND (l_valid_prod='Y')  ) THEN
       g_phase := 'Merging records into base summary table...';
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog(
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => g_phase);
       END IF;
       bil_bi_util_collection_pkg.analyze_table('BIL_BI_OPDTL_STG',TRUE, 10, 'GLOBAL');

       IF ((g_load_flag = 'I') OR (g_refresh_flag = 'N')) THEN
         Insert_Into_Sumry_Incr;
       ELSE
         Insert_Into_Sumry_Init;
       END IF;
       COMMIT;
       -- Cleaning phase
       -- Truncate staging summary table if all the processes completed
       -- successfully. Also set the status to true for successful completion date
       G_status := TRUE;
       Clean_up;
       IF (G_refresh_flag = 'Y') THEN
         --- why 99 percent
         bil_bi_util_collection_pkg.analyze_table('BIL_BI_OPDTL_F',TRUE, 10, 'GLOBAL');
       END IF;



       IF (l_return_warn = 'Y' or l_return_warn_resume= 'Y' or l_warn_parameter = 'Y') THEN
         retcode := 1;
       ELSE
         retcode := 0;
       END IF;
       bil_bi_util_collection_pkg.writeLog(
	  p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc || ' proc_event',
          p_msg => 'Procedure Completed Successfully',
          p_force_log => TRUE
			  );
       return;
   ELSE
     IF (l_valid_prod='N') THEN
         bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_STG');
     END IF;
     RAISE INVALID_SETUP;
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

EXCEPTION
   WHEN G_BIS_SETUP_ERROR THEN
     g_retcode := -1;
     ROLLBACK;
     clean_up;
     retcode := g_retcode;

   WHEN G_SETUP_VAL_ERROR THEN
     g_retcode := -1;
     ROLLBACK;
     clean_up;
     retcode := g_retcode;

   WHEN INVALID_SETUP THEN
     g_retcode := -1;
     ROLLBACK;
     clean_up;
     ---?????  detail message output by the validation routines, this is for log

     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc || ' proc_error',
          p_msg => 'The Time, Currency or Product Dimensions are not properly setup',
          p_force_log => TRUE);

          retcode := g_retcode;
          -- RAISE;
   WHEN OTHERS Then
       g_retcode := -1;
       g_phase :='Other';
       ROLLBACK;
       clean_up;

       fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('ERRNO' ,SQLCODE);
       fnd_message.set_token('REASON' ,SQLERRM);
       fnd_message.set_token('ROUTINE' , l_proc);
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => fnd_message.get,
           p_force_log => TRUE);
       retcode := g_retcode;
       RAISE;
END Main;

PROCEDURE Report_Missing_Rates IS
    l_stmt  VARCHAR2(500);
    l_count  NUMBER;
    cursor MissingRate_p is
       SELECT DISTINCT
              stg.txn_currency txn_currency,
              trunc( decode(stg.prim_conversion_rate,-3,
                     to_date('01/01/1999','MM/DD/RRRR'),least(sysdate, stg.EFFECTIVE_DATE))) TXN_DATE,
              decode(sign(nvl(stg.prim_conversion_rate,-1)),-1,'P') prim_curr_type,
              decode(sign(nvl(stg.CONVERSION_RATE_S,-1)),-1,'S')    sec_curr_type
       FROM   BIL_BI_OPDTL_STG stg
       WHERE  ((stg.PRIM_CONVERSION_RATE < 0 OR stg.PRIM_CONVERSION_RATE is null )
              OR (g_sec_currency IS NOT NULL AND (stg.CONVERSION_RATE_S < 0 OR stg.CONVERSION_RATE_S is null )))
       AND effective_date<= add_months(trunc(g_program_start),24);

    l_proc VARCHAR2(100);
BEGIN
    l_proc := 'Report_Missing_Rates';
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
       bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;

       BIS_COLLECTION_UTILITIES.WriteMissingRateHeader;
       FOR rate_record in MissingRate_p
       LOOP
         IF rate_record.prim_curr_type='P' THEN
          BIS_COLLECTION_UTILITIES.writemissingrate(
            g_prim_rate_type,
            rate_record.txn_currency,
            g_prim_currency,
            rate_record.txn_date);
          END IF;

          IF rate_record.sec_curr_type='S' THEN
          BIS_COLLECTION_UTILITIES.writemissingrate(
            g_sec_rate_type,
            rate_record.txn_currency,
            g_sec_currency,
            rate_record.txn_date);
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
                 p_module => g_pkg || l_proc || ' proc_error',
                 p_msg => fnd_message.get,
                 p_force_log => TRUE);
      raise;
END Report_Missing_Rates;


--  ***********************************************************************

--  ***********************************************************************
PROCEDURE Clean_Up IS
      l_stmt        VARCHAR2(50);
      l_sysdate     DATE;
      l_proc        VARCHAR2(100);
BEGIN
    l_proc := 'Clean_Up';
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
       bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;
    IF (G_status) THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc || ' proc_event',
          p_msg => 'Program finished normally, truncating staging tables.',
          p_force_log => TRUE);

      bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_STG');
      null;
    ELSIF (g_phase = 'Other') THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc || ' proc_event',
         p_msg => 'Program finished with unhandled error, truncating staging tables.',
         p_force_log => TRUE);
         bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_STG');
    END IF;
    l_sysdate := SYSDATE;
    /*
      Added commit before wrapup and setup procedures are called
      Commented commit in write_log procedure. This is done to avoid
      hanging of incremental program when ran with multiple workers.
    */
    COMMIT;
    BIS_COLLECTION_UTILITIES.wrapup(G_status,
            g_row_num,
            null,
            G_Start_Date,
            G_end_date);

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
       bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
    END IF;

EXCEPTION
    WHEN OTHERS Then
        ROLLBACK;
        g_retcode:=-1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON' ,SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => fnd_message.get,
           p_force_log => TRUE);
        RAISE;
END Clean_up;


-- *************************************************************************
-- PROCEDURE Init
/**************************************************************************************
 *Init: This procedure is used to intialize the global variables viz- the values for
 *who columns.
 **************************************************************************************
/**************************************************************************************
 *Init: This procedure is used to intialize the global variables viz- the values for
 *who columns.
 **************************************************************************************/
PROCEDURE Init(p_object_name VARCHAR2) IS
    l_setup_status   BOOLEAN;
    l_status         VARCHAR2(30);
    l_industry       VARCHAR2(30);
    l_stmt           VARCHAR2(50);
    --l_valid_setup  BOOLEAN ;
    l_max_date       DATE ;
    l_proc           VARCHAR2(100);
BEGIN

   l_proc:= 'Init';
   /*
   Added commit before wrapup and setup procedures are called
   Commented commit in write_log procedure. This is done to avoid
   hanging of incremental program when ran with multiple workers.
   */
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;
   -- setup has to be called first for log to work
   COMMIT;
   g_program_start := sysdate;

   Setup_Validation(l_setup_status);
   IF (NOT l_setup_status) THEN
      --- ???
     g_retcode := 2;
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Setup Validition failed' );
     END IF;
     RAISE G_SETUP_VAL_ERROR;
   ELSE
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Setup Validition success' );
      END IF;

   END IF;
   g_phase := 'Find BIL schema';
   g_bil_schema := bil_bi_util_collection_pkg.get_schema_name('BIL');

   -- no user id check for now
   G_request_id := FND_GLOBAL.CONC_REQUEST_ID();
   G_appl_id    := FND_GLOBAL.PROG_APPL_ID();
   G_program_id := FND_GLOBAL.CONC_PROGRAM_ID();
   G_user_id    := FND_GLOBAL.USER_ID();
   G_login_id   := FND_GLOBAL.CONC_LOGIN_ID();
   -- Initialize Debug global variable
   g_debug := NVL(BIS_COLLECTION_UTILITIES.g_debug,FALSE);

   -- Get primary currency code and rate type
   g_prim_currency := bis_common_parameters.get_currency_code;
   g_prim_rate_type := bis_common_parameters.get_rate_type;

   -- Get secondary currency code and rate type
   g_sec_currency := bis_common_parameters.get_secondary_currency_code;
   g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc || 'Primary Currency',
             p_msg => g_prim_currency);
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc || 'Primary Rate Type',
             p_msg => g_prim_rate_type);
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc || 'Secondary Currency',
             p_msg => g_sec_currency);
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc || 'Secondary Rate Type',
             p_msg => g_sec_rate_type);
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

END Init;


PROCEDURE Summary_Err_Check(x_valid_curr OUT NOCOPY VARCHAR2,
                            x_valid_date OUT NOCOPY VARCHAR2,
                            x_valid_prod OUT NOCOPY VARCHAR2,
                            x_return_warn OUT NOCOPY VARCHAR2) IS

      l_time_cnt          NUMBER;
      l_conv_rate_cnt     NUMBER;
      l_stg_min           NUMBER;
      l_stg_max           NUMBER;
      l_stg_min_txn_dt    DATE;
      l_stg_max_txn_dt    DATE;
      l_stg_min_eff_dt    DATE;
      l_stg_max_eff_dt    DATE;
      l_stg_min_dt        DATE;
      l_stg_max_dt        DATE;
      l_day_min           NUMBER;
      l_day_max           NUMBER;
      l_has_missing_date  BOOLEAN;
      l_count             NUMBER;
      l_lead_num          NUMBER;
      l_eff_date          DATE;
      l_number_of_rows    NUMBER;
      l_int_type          VARCHAR2(100);
      l_prim_code         VARCHAR2(100);
      l_sec_code          VARCHAR2(100);
      l_warn              VARCHAR2(1);
      l_limit_date        DATE;

      cursor c_date_range(p_date date) is
             SELECT lead_number, effective_date FROM BIL_BI_OPDTL_STG
             WHERE  effective_date > p_date;

      cursor c_item_prod (p_date date) is
             SELECT lead_number  FROM BIL_BI_OPDTL_STG
             WHERE  effective_date <= p_date
             and nvl(product_category_id,-999)=-999;

      l_proc VARCHAR2(100);
BEGIN

  l_time_cnt	    :=0;
  l_conv_rate_cnt   :=0;
  l_has_missing_date:= FALSE;
  l_count  	    :=0;
  l_number_of_rows  :=0;
  l_limit_date      := add_months(trunc(g_program_start),24);
  l_proc            := 'Summary_Err_Check';


  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
  END IF;
  g_phase := 'update rates';
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => g_phase);
  END IF;
  IF g_sec_currency IS NOT NULL THEN
     IF (g_refresh_flag = 'Y') THEN
        UPDATE  /*+ PARALLEL(stg)*/ BIL_BI_OPDTL_STG stg
         SET (stg.prim_conversion_rate,stg.CONVERSION_RATE_S)
                       = (select exchange_rate, exchange_rate_s
                            from BIL_BI_CURRENCY_RATE
                           where currency_code = stg.txn_currency
                             and exchange_date = stg.effective_date)
         WHERE ((prim_conversion_rate < 0) OR  prim_conversion_rate IS NULL)
               OR ((CONVERSION_RATE_S < 0) OR  CONVERSION_RATE_S IS NULL);
     ELSE
        UPDATE  BIL_BI_OPDTL_STG stg
           SET (stg.prim_conversion_rate,stg.CONVERSION_RATE_S)
                       = (select exchange_rate, exchange_rate_s
                            from BIL_BI_CURRENCY_RATE
                           where currency_code = stg.txn_currency
                             and exchange_date = stg.effective_date)
        WHERE ((prim_conversion_rate < 0) OR  prim_conversion_rate IS NULL )
               OR ((CONVERSION_RATE_S < 0) OR  CONVERSION_RATE_S IS NULL);
     END IF;
  ELSE --g_sec_currency is null
     IF (g_refresh_flag = 'Y') THEN
        UPDATE  /*+ PARALLEL(stg)*/ BIL_BI_OPDTL_STG stg
         SET stg.prim_conversion_rate =(select exchange_rate from BIL_BI_CURRENCY_RATE
                                         where currency_code = stg.txn_currency
                                           and exchange_date = stg.effective_date)
         WHERE ((prim_conversion_rate < 0) OR  prim_conversion_rate IS NULL) ;
     ELSE
        UPDATE  BIL_BI_OPDTL_STG stg
        SET  stg.prim_conversion_rate =
                    (select exchange_rate from BIL_BI_CURRENCY_RATE
                      where currency_code = stg.txn_currency
                        and exchange_date = stg.effective_date)
        WHERE ((prim_conversion_rate < 0) OR  prim_conversion_rate IS NULL);
     END IF;
  END IF;
  -- need this commit for the rollup not to roll back all the currencys, doesn't really matter anyway
  commit;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg => 'Updated rates for '|| sql%rowcount || ' rows');
  END IF;
  -- Check missing primary currency rates
  IF (g_refresh_flag = 'Y') THEN
      SELECT /*+ PARALLEL(stg)*/ count(1)
      INTO   l_conv_rate_cnt
      FROM   BIL_BI_OPDTL_STG stg
      WHERE  ((prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
               OR (g_sec_currency IS NOT NULL AND (CONVERSION_RATE_S < 0  OR  CONVERSION_RATE_S IS NULL)))
			  AND stg.effective_date <= l_limit_date;
  ELSE
      SELECT count(1)
      INTO   l_conv_rate_cnt
      FROM   BIL_BI_OPDTL_STG stg
      WHERE ((prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
               OR (g_sec_currency  IS NOT NULL AND (CONVERSION_RATE_S < 0  OR  CONVERSION_RATE_S IS NULL)))
			AND stg.effective_date <= l_limit_date;
  END IF;

  --l_conv_rate_cnt := 0; -- only for GSIDBI testing

  IF (l_conv_rate_cnt >0) THEN
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc,
                p_msg => 'Missing currency conversion rates found, program will exit with warning status. '
								||'Please fix the missing conversion rates');
     END IF;
     g_retcode := -1;

     -- report missing primary curency conversion rates.
     Report_Missing_Rates;

     x_valid_curr := 'N';
  ELSE
     x_valid_curr := 'Y';
  END IF;

  g_phase := 'Checking for Time dimension';
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg => g_phase);
  END IF;
  /*also for effective date. need to call the time api*/

  IF (g_refresh_flag = 'Y') THEN
      SELECT  /*+ parallel(stg) */
              NVL(MIN(stg.TXN_DATE), G_Start_Date),
              NVL(Max(stg.TXN_DATE), G_End_Date),
              LEAST(NVL(MIN(stg.Effective_DATE), G_Start_Date), NVL(MIN(stg.close_date), G_Start_Date)),
              LEAST(add_months(sysdate,24), GREATEST(nvl(Max(stg.Effective_DATE),G_End_Date), nvl(Max(stg.close_DATE),G_End_Date)))
      INTO   l_stg_min_txn_dt,
             l_stg_max_txn_dt,
             l_stg_min_eff_dt,
             l_stg_max_eff_dt
      FROM   BIL_BI_OPDTL_STG stg;
  ELSE
      SELECT  NVL(MIN(stg.TXN_DATE), G_Start_Date),
              NVL(Max(stg.TXN_DATE), G_End_Date),
              LEAST(NVL(MIN(stg.Effective_DATE), G_Start_Date), NVL(MIN(stg.close_date), G_Start_Date)),
              LEAST(add_months(sysdate,24), GREATEST(nvl(Max(stg.Effective_DATE),G_End_Date), nvl(Max(stg.close_DATE),G_End_Date)))
      INTO   l_stg_min_txn_dt,
             l_stg_max_txn_dt,
             l_stg_min_eff_dt,
             l_stg_max_eff_dt
      FROM   BIL_BI_OPDTL_STG stg;

  END IF;
  IF (l_stg_min_txn_dt < l_stg_min_eff_dt) THEN
     l_stg_min_dt := l_stg_min_txn_dt;
  ELSE
     l_stg_min_dt := l_stg_min_eff_dt;
  END IF;
  IF (l_stg_max_txn_dt < l_stg_max_eff_dt) THEN
     l_stg_max_dt := l_stg_max_eff_dt;
  ELSE
     l_stg_max_dt := l_stg_max_txn_dt;
  END IF;
  --write_log(p_msg => 'Date range:'||l_stg_min_dt||'  '||l_stg_max_dt, p_log => 'N');

  FII_TIME_API.check_missing_date (l_stg_min_dt,l_stg_max_dt,l_has_missing_date);

  IF (l_has_missing_date) THEN
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                   p_module => g_pkg || l_proc ,
                      p_msg => 'Time Dimension is not fully populated.  '||
                               'Please populate Time dimension to cover the date range you are collecting');
      END IF;
      x_valid_date := 'N';
  ELSE
      x_valid_date := 'Y';
  END IF;
  --- The following check applies both initial and incremental mode

  -- check for oppty close date

  OPEN c_date_range(l_limit_date);
  LOOP
     FETCH c_date_range into
           l_lead_num, l_eff_date ;
     EXIT WHEN c_date_range%NOTFOUND ;
     l_number_of_rows :=l_number_of_rows + 1;
     IF(l_number_of_rows=1) THEN
       -- print header
       fnd_message.set_name('BIL','BIL_BI_OPTY_PER_ERR_HDR');
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                          p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);
     END IF;
     -- print detail
     fnd_message.set_name('BIL','BIL_BI_OPTY_PER_ERR_DTL');
     fnd_message.set_token('OPPNUM', l_lead_num);
     fnd_message.set_token('CLOSEDATE', to_char(l_eff_date));
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                            p_msg => fnd_message.get,
                            p_force_log => TRUE);

  END LOOP;
  CLOSE c_date_range;
  IF ( l_number_of_rows  > 0) THEN
     l_warn := 'Y';
  ELSE
     l_warn := 'N';
  END IF;

  -- check for bad item/product
  l_number_of_rows := 0;
  OPEN c_item_prod(l_limit_date);
  LOOP
     FETCH c_item_prod into
           l_lead_num;
     EXIT WHEN c_item_prod%NOTFOUND ;
     l_number_of_rows :=l_number_of_rows + 1;

     IF(l_number_of_rows=1) THEN
       -- print header
       fnd_message.set_name('BIL','BIL_BI_ITEM_PROD_ERR_HDR');
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          --p_msg => 'The following opportunities have null product and product category, they are not collected',
                            p_msg => fnd_message.get,
                            p_force_log => TRUE);
     END IF;

     -- print detail

     fnd_message.set_name('BIL','BIL_BI_ITEM_PROD_ERR_DTL');
     fnd_message.set_token('OPPNUM', l_lead_num);
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                            p_msg => fnd_message.get,
                            p_force_log => TRUE);


  END LOOP;
  CLOSE c_item_prod;

  --Delete BIL_BI_OPDTL_F  ???? too much cost here

  --Delete BIL_BI_OPDTL_STG  WHERE

  --(item_id = -1 and nvl(product_category_id,-1)=-1) or valid_flag = 'F';

  /*
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Deleted'|| sql%rowcount || ' rows due to bad item/prod or close date');
      END IF;
  */
  IF ( l_number_of_rows  > 0) THEN
     x_valid_prod := 'N';
  ELSE
     x_valid_prod := 'Y';
  END IF;

  x_return_warn := l_warn;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
  END IF;
EXCEPTION
      WHEN OTHERS THEN
        g_retcode:=-1;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON' ,SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
            p_module => g_pkg || l_proc || ' proc_error',
            p_msg => fnd_message.get,
            p_force_log => TRUE);
        Raise;
END Summary_Err_Check;



--  ***********************************************************************
--  Procedure
--     Ins_New_Chngd_Oppty_Incr
--  Purpose
--    Insert new/changed rows into staging table



PROCEDURE Ins_New_Chngd_Oppty_Incr IS

  l_count      NUMBER;
  l_proc       VARCHAR2(100);
  l_limit_date  DATE ;
  l_cnt        NUMBER;
  l_start_date date;
  l_int_date_format  VARCHAR2(21);
BEGIN

 l_count   	   := 0;
 l_int_date_format :='DD/MM/YYYY HH24:MI:SS';
 l_proc            := 'Ins_New_Chngd_Oppty_Inc';
 l_limit_date := add_months(trunc(g_program_start),24);

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;

 l_start_date := fnd_date.displaydt_to_date(get_first_success_period('BIL_BI_OPDTL_F'));

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Close date collected is greater or equal to :'
								|| TO_CHAR(l_start_date,'DD-MON-YYYY HH24:MI:SS') );
 END IF;

 INSERT INTO  BIL_BI_OPDTL_STG stg (
      txn_date
     ,effective_date
     ,lead_id
     ,lead_line_id
     ,sales_credit_id
     ,sales_group_id
     ,salesrep_id
     ,txn_currency
     ,sales_credit_amount
     --,primary_conversion_rate
     ,win_probability
     ,opp_open_status_flag
     ,win_loss_indicator
     ,forecast_rollup_flag
     --,valid_flag
     ,opty_creation_date
     ,opty_ld_conversion_date
     ,product_category_id
     ,item_id
     ,item_organization_id
     ,competitor_id
     ,lead_number
     ,hdr_source_promotion_id
     --,line_source_promotion_id, not required?
     ,customer_id
     ,opty_global_amt
     ,owner_sales_group_id
     ,owner_salesrep_id
     ,sales_stage_id
     ,status
     ,close_date
     ,opty_rank
     ) SELECT  /*+ full(denorm) */
      denorm.opportunity_last_update_date
     ,CASE WHEN (denorm.win_loss_indicator||denorm.opp_open_status_flag='WN' OR
                 denorm.forecast_rollup_flag||denorm.opp_open_status_flag='YY')
           THEN NVL(TRUNC(denorm.forecast_date),TRUNC(denorm.decision_date))
           ELSE
	       TRUNC(denorm.decision_date)
      END
     ,denorm.lead_id
     ,denorm.lead_line_id
     ,denorm.sales_credit_id
     ,denorm.sales_group_id
     ,denorm.salesforce_id
     ,denorm.currency_code
     ,denorm.sales_credit_amount
     -- currency table
     ,denorm.win_probability
     ,denorm.opp_open_status_flag
     ,denorm.win_loss_indicator
     ,denorm.forecast_rollup_flag
     --,valid_flag
     ,LEAST(TRUNC(denorm.opportunity_creation_date), TRUNC(denorm.decision_date))
     ,CASE     WHEN (TRUNC(denorm.decision_date)< TRUNC(MIN(aslo1.creation_date))
                     AND TRUNC(denorm.opportunity_creation_date) <=  TRUNC(denorm.decision_date) )
               THEN TRUNC(denorm.opportunity_creation_date)
               WHEN (TRUNC(denorm.decision_date)< TRUNC(MIN(aslo1.creation_date))
                     AND TRUNC(denorm.opportunity_creation_date) >  TRUNC(denorm.decision_date) )
               THEN TRUNC(denorm.decision_date)
               ELSE TRUNC(MIN(aslo1.creation_date)) END
     ,denorm.product_category_id
     ,nvl(denorm.item_id,-1)
     ,decode(denorm.item_id, null, -99, nvl(denorm.organization_id, -99))
     ,nvl(denorm.close_competitor_id,-1)
     ,denorm.lead_number
     --, line not required?
     ,nvl(denorm.source_promotion_id,-1)
     ,nvl(denorm.customer_id,-1)
     ,denorm.total_amount
     ,denorm.owner_sales_group_id
     ,denorm.owner_salesforce_id
     ,denorm.sales_stage_id
     ,denorm.status_code
     ,TRUNC(denorm.decision_date)
     ,RANK() OVER(PARTITION BY lead_id ORDER BY lead_id, TRUNC(denorm.decision_date),
                        CASE WHEN (denorm.win_loss_indicator||denorm.opp_open_status_flag='WN' OR
		                   denorm.forecast_rollup_flag||denorm.opp_open_status_flag='YY')
                             THEN NVL(TRUNC(denorm.forecast_date),TRUNC(denorm.decision_date))
	                     ELSE
	                          TRUNC(denorm.decision_date)
                        END) opty_rank
     FROM as_sales_credits_denorm denorm,
     as_sales_lead_opportunity aslo1
     WHERE denorm.lead_id = aslo1.opportunity_id (+)
     AND denorm.sales_group_id IS NOT NULL
     AND denorm.sales_credit_amount IS NOT NULL
     AND denorm.credit_type_id = g_credit_type_id


--both decision_date and forecast_date (if present) need to be between
--g_start_date and l_limit_date
     AND (denorm.decision_date >= l_start_date
        OR denorm.forecast_date >= l_start_date
        OR denorm.opportunity_last_update_date >= G_Start_DATE)
     AND denorm.decision_date >= g_start_date
     AND denorm.decision_date <= l_limit_date
     AND (denorm.forecast_date is null
        OR (denorm.forecast_date >= g_start_date
            AND denorm.forecast_date <= l_limit_date))

     AND
     (-- sc level change
        exists ( select 1 from as_sales_credits credit
      	where credit.last_update_date>= G_Start_DATE
      	and denorm.lead_id = credit.lead_id)
      OR denorm.opportunity_last_update_date >= G_Start_DATE
      OR -- link to lead works => lead to opportunity
        exists (SELECT 1 from as_sales_lead_opportunity aslo2
        where denorm.lead_id = aslo2.opportunity_id
        and aslo2.creation_date >= G_START_DATE)
      )
     GROUP BY
      denorm.opportunity_last_update_date
     ,TRUNC(denorm.decision_date)
     ,denorm.lead_id
     ,denorm.lead_line_id
     ,denorm.sales_credit_id
     ,denorm.sales_group_id
     ,denorm.salesforce_id
     ,denorm.currency_code
     ,denorm.sales_credit_amount
     --, currrency table
     ,denorm.win_probability
     ,denorm.opp_open_status_flag
     ,denorm.win_loss_indicator
     ,denorm.forecast_rollup_flag
     --,valid_flag
     ,TRUNC(denorm.opportunity_creation_date)
     ,denorm.product_category_id
     ,nvl(denorm.item_id,-1)
     ,decode(denorm.item_id, null, -99, nvl(denorm.organization_id, -99))
     ,nvl(denorm.close_competitor_id,-1)
     ,denorm.lead_number
     --, line not required?
     ,denorm.source_promotion_id
     ,nvl(denorm.customer_id,-1)
     ,denorm.total_amount
     ,denorm.owner_sales_group_id
     ,denorm.owner_salesforce_id
     ,denorm.sales_stage_id
     ,denorm.status_code
     ,TRUNC(denorm.forecast_date);

   l_cnt:=sql%rowcount;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog(
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc ,
          p_msg => 'Start and End Dates for which Ids are collected:'||
                   TO_CHAR(G_Start_Date,'DD-MON-YYYY HH24:MI:SS') ||
                   ' and G_end_date:'|| TO_CHAR(G_end_date,'DD-MON-YYYY HH24:MI:SS'));
  END IF;
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog(
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg => 'Rows Inserted into staging table are: '||l_cnt);
  END IF;

/*delete from bil.bil_bi_opdtl_f a where exists
(select lead_id from as_leads_all b where
  a.opty_id=b.lead_id and b.last_update_date >=G_Start_Date
  and b.lead_id not in (select distinct lead_id from as_sales_credits));

   l_cnt:=sql%rowcount;

dbms_output.put_line('deleted these many rows in ins_new_chgd_opty_incr procedure from fact :'||l_cnt);*/

  COMMIT;
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
  END IF;

Exception
   When Others Then
     /*Generic Exception Handling block.*/
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('ERRNO' ,SQLCODE);
        fnd_message.set_token('REASON' ,SQLERRM);
        fnd_message.set_token('ROUTINE' , l_proc);
        bil_bi_util_collection_pkg.writeLog(
		p_log_level => fnd_log.LEVEL_UNEXPECTED,
                p_module => g_pkg || l_proc || ' proc_error',
                p_msg => fnd_message.get,
                p_force_log => TRUE);
        raise;
END Ins_New_Chngd_Oppty_Incr;

PROCEDURE Ins_New_Chngd_Oppty_Init  IS

    l_count       NUMBER;
    l_statement   VARCHAR2(500);
    l_proc        VARCHAR2(100);
    l_limit_date  DATE ;
BEGIN
 l_proc   := 'Ins_New_Chngd_Oppty_Init';
 l_count  := 0;
 l_limit_date := add_months(trunc(g_program_start),24);

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;


 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
    bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Start and End Dates for which Ids are collected:'||
                          TO_CHAR(G_Start_Date,'DD-MON-YYYY HH24:MI:SS') ||
                          ' and G_end_date:'|| TO_CHAR(G_end_date,'DD-MON-YYYY HH24:MI:SS'));
 END IF;
 INSERT /*+ APPEND  PARALLEL(stg)*/ INTO  BIL_BI_OPDTL_STG stg (
      txn_date
     ,effective_date
     ,lead_id
     ,lead_line_id
     ,sales_credit_id
     ,sales_group_id
     ,salesrep_id
     ,txn_currency
     ,sales_credit_amount
     --,primary_conversion_rate
     ,win_probability
     ,opp_open_status_flag
     ,win_loss_indicator
     ,forecast_rollup_flag
     --,valid_flag
     ,opty_creation_date
     ,opty_ld_conversion_date
     ,product_category_id
     ,item_id
     ,item_organization_id
     ,competitor_id
     ,lead_number
     ,hdr_source_promotion_id
     --,line_source_promotion_id, not required?
     ,customer_id
     ,opty_global_amt
     ,owner_sales_group_id
     ,owner_salesrep_id
     ,sales_stage_id
     ,status
     ,close_date
     ,opty_rank
     ) SELECT  /*+ PARALLEL(denorm) PARALLEL(aslo1) PARALLEL(codes) */
      denorm.opportunity_last_update_date
     ,CASE WHEN (denorm.win_loss_indicator||denorm.opp_open_status_flag='WN' OR
                 denorm.forecast_rollup_flag||denorm.opp_open_status_flag='YY')
           THEN NVL(TRUNC(denorm.forecast_date),TRUNC(denorm.decision_date))
           ELSE
	       TRUNC(denorm.decision_date)
      END
     ,denorm.lead_id
     ,denorm.lead_line_id
     ,denorm.sales_credit_id
     ,denorm.sales_group_id
     ,denorm.salesforce_id
     ,denorm.currency_code
     ,denorm.sales_credit_amount
     -- currency table
     ,denorm.win_probability
     ,denorm.opp_open_status_flag
     ,denorm.win_loss_indicator
     ,denorm.forecast_rollup_flag
     --,valid_flag
     ,LEAST(TRUNC(denorm.opportunity_creation_date), TRUNC(denorm.decision_date))
     ,CASE     WHEN (TRUNC(denorm.decision_date)< TRUNC(MIN(aslo1.creation_date))
                     AND TRUNC(denorm.opportunity_creation_date) <=  TRUNC(denorm.decision_date) )
               THEN TRUNC(denorm.opportunity_creation_date)
               WHEN (TRUNC(denorm.decision_date)< TRUNC(MIN(aslo1.creation_date))
                     AND TRUNC(denorm.opportunity_creation_date) >  TRUNC(denorm.decision_date) )
               THEN TRUNC(denorm.decision_date)
               ELSE TRUNC(MIN(aslo1.creation_date)) END
     ,denorm.product_category_id
     ,nvl(denorm.item_id,-1)
     ,decode(denorm.item_id, null, -99, nvl(denorm.organization_id, -99))
     ,nvl(denorm.close_competitor_id,-1)
     ,denorm.lead_number
     --, line not required?
     ,nvl(denorm.source_promotion_id,-1)
     ,nvl(denorm.customer_id,-1)
     ,denorm.total_amount
     ,denorm.owner_sales_group_id
     ,denorm.owner_salesforce_id
     ,denorm.sales_stage_id
     ,denorm.status_code
     ,TRUNC(denorm.decision_date)
     ,RANK() OVER(PARTITION BY lead_id ORDER BY lead_id, TRUNC(denorm.decision_date),
                        CASE WHEN (denorm.win_loss_indicator||denorm.opp_open_status_flag='WN' OR
		                   denorm.forecast_rollup_flag||denorm.opp_open_status_flag='YY')
                             THEN NVL(TRUNC(denorm.forecast_date),TRUNC(denorm.decision_date))
	                     ELSE
	                          TRUNC(denorm.decision_date)
                        END) opty_rank
     FROM as_sales_credits_denorm denorm,
          as_sales_lead_opportunity aslo1
     WHERE
     denorm.lead_id = aslo1.opportunity_id (+)
     --AND denorm.source_promotion_id = codes.source_code_id (+)


--check that both decision_date and forecast_date (if present)
--are after g_start_date and before l_limit_date
     AND denorm.decision_date >= g_start_date
     AND denorm.decision_date <= l_limit_date
     AND (denorm.forecast_date is null OR (denorm.forecast_date >= g_start_date AND denorm.forecast_date <= l_limit_date))

     AND denorm.sales_group_id IS NOT NULL
     AND denorm.sales_credit_amount  IS NOT NULL
     AND denorm.credit_type_id = g_credit_type_id
     GROUP BY
      denorm.opportunity_last_update_date
     ,TRUNC(denorm.decision_date)
     ,denorm.lead_id
     ,denorm.lead_line_id
     ,denorm.sales_credit_id
     ,denorm.sales_group_id
     ,denorm.salesforce_id
     ,denorm.currency_code
     ,denorm.sales_credit_amount
     --, currrency table
     ,denorm.win_probability
     ,denorm.opp_open_status_flag
     ,denorm.win_loss_indicator
     ,denorm.forecast_rollup_flag
     --,valid_flag
     ,TRUNC(denorm.opportunity_creation_date)
     ,denorm.product_category_id
      ,nvl(denorm.item_id,-1)
     ,decode(denorm.item_id, null, -99, nvl(denorm.organization_id, -99))
     ,nvl(denorm.close_competitor_id,-1)
     ,denorm.lead_number
     --, line not required?
     ,nvl(denorm.source_promotion_id,-1)
     ,nvl(denorm.customer_id,-1)
     ,denorm.total_amount
     ,denorm.owner_sales_group_id
     ,denorm.owner_salesforce_id
     ,denorm.sales_stage_id
     ,denorm.status_code
     ,TRUNC(denorm.forecast_date);

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    p_module => g_pkg || l_proc ,
    p_msg => 'Rows Inserted into staging table are: '||sql%rowcount);
  END IF;

  COMMIT;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;


Exception
   When Others Then
     /*Generic Exception Handling block.*/
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
      fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(
           p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => fnd_message.get,
           p_force_log => TRUE);
      raise;

END Ins_New_Chngd_Oppty_Init;


--  ***********************************************************************
--  Procedure
--     Insert_Into_Sumry_Incr
--  Purpose
--    Insert new/changed rows into Summary table from Staging table.
--    Created
--       spraturi         16-Jul-2002

Procedure Insert_Into_Sumry_Incr
IS
  l_sysdate     DATE ;
  l_count       number ;
  l_proc        VARCHAR2(100);
BEGIN
  l_sysdate    := sysdate;
  l_count      := 0;
  l_proc       := 'Insert_Into_Sumry_Incr';

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;


--   DELETE /*+ index_ffs(f,BIL_BI_OPDTL_F_U1) */ FROM BIL_BI_OPDTL_F f
  -- WHERE EXISTS(
    --            SELECT /*+ index_ffs(stg,BIL_BI_OPDTL_STG_U1) */ 1
      --            FROM BIL_BI_OPDTL_STG stg
        --         WHERE f.opty_id = stg.lead_id
          --  );

   DELETE FROM BIL_BI_OPDTL_F f
   WHERE NOT EXISTS
     ( SELECT 1 FROM AS_SALES_CREDITS sc WHERE f.sales_credit_id = sc.sales_credit_id );


   l_count:=sql%rowcount;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Deleted  '|| l_count ||' from BIL_BI_OPDTL_F');
   END IF;

   MERGE INTO BIL_BI_OPDTL_F fact
   USING
     (SELECT
       lead_id
       ,to_number(to_char(txn_date, 'J')) txn_time_id
       ,to_number(to_char(effective_date, 'J')) opty_close_time_id
       ,to_number(to_char(opty_ld_conversion_date, 'J')) opty_ld_conversion_time_id
       ,to_number(to_char(opty_creation_date, 'J')) opty_creation_time_id
       ,SUM(decode(sales_credit_amount*prim_conversion_rate, 0, null, sales_credit_amount*prim_conversion_rate)) sales_credit_amt
       ,SUM(decode(sales_credit_amount*CONVERSION_RATE_S, 0, null, sales_credit_amount*CONVERSION_RATE_S)) sales_credit_amt_s
       ,product_category_id
       ,item_id
       ,item_organization_id
       ,competitor_id
       ,hdr_source_promotion_id
       ,customer_id
       ,opty_global_amt * prim_conversion_rate opty_amt
       ,opty_global_amt * CONVERSION_RATE_S opty_amt_s
       ,owner_sales_group_id
       ,owner_salesrep_id
       ,lead_number
       ,sales_stage_id
       ,status
       ,sales_group_id
       ,salesrep_id
       ,win_probability
       ,opp_open_status_flag
       ,win_loss_indicator
       ,forecast_rollup_flag
       ,g_user_id created_by
       ,sysdate creation_date
       ,g_user_id last_updated_by
       ,sysdate last_update_date
       ,G_Login_Id last_update_login
       ,G_request_id request_id
       ,G_appl_id program_application_id
       ,G_program_id program_id
       ,sysdate program_update_date
       ,lead_line_id
       ,sales_credit_id
       ,to_number(to_char(close_date, 'J')) opty_effective_time_id
       ,opty_rank
     FROM BIL_BI_OPDTL_STG stg
     WHERE (nvl(product_category_id,-999)<> -999)
     GROUP BY
         lead_id
         ,lead_line_id
         ,sales_credit_id
         ,to_number(to_char(txn_date, 'J'))
         ,to_number(to_char(effective_date, 'J'))
         ,to_number(to_char(opty_ld_conversion_date, 'J'))
         ,to_number(to_char(opty_creation_date, 'J'))
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_global_amt * prim_conversion_rate
         ,opty_global_amt * CONVERSION_RATE_S
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,opp_open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ,to_number(to_char(close_date, 'J'))
         ,opty_rank) stage
   ON (stage.sales_credit_id = fact.sales_credit_id)
   WHEN MATCHED THEN
   UPDATE SET
     fact.txn_time_id = stage.txn_time_id
     ,fact.opty_close_time_id = stage.opty_close_time_id
     ,fact.opty_ld_conversion_time_id = stage.opty_ld_conversion_time_id
     ,fact.opty_creation_time_id = stage.opty_creation_time_id
     ,fact.sales_credit_amt = stage.sales_credit_amt
     ,fact.sales_credit_amt_s = stage.sales_credit_amt_s
     ,fact.product_category_id = stage.product_category_id
     ,fact.item_id = stage.item_id
     ,fact.item_organization_id = stage.item_organization_id
     ,fact.competitor_id = stage.competitor_id
     ,fact.hdr_source_promotion_id = stage.hdr_source_promotion_id
     ,fact.customer_id = stage.customer_id
     ,fact.opty_amt = stage.opty_amt
     ,fact.opty_amt_s = stage.opty_amt_s
     ,fact.owner_sales_group_id = stage.owner_sales_group_id
     ,fact.owner_salesrep_id = stage.owner_salesrep_id
     ,fact.lead_number = stage.lead_number
     ,fact.sales_stage_id = stage.sales_stage_id
     ,fact.status = stage.status
     ,fact.sales_group_id = stage.sales_group_id
     ,fact.salesrep_id = stage.salesrep_id
     ,fact.win_probability = stage.win_probability
     ,fact.open_status_flag = stage.opp_open_status_flag
     ,fact.win_loss_indicator = stage.win_loss_indicator
     ,fact.forecast_rollup_flag = stage.forecast_rollup_flag
     ,fact.last_updated_by = stage.last_updated_by
     ,fact.last_update_date = stage.last_update_date
     ,fact.last_update_login = stage.last_update_login
     ,fact.request_id = stage.request_id
     ,fact.program_application_id = stage.program_application_id
     ,fact.program_id = stage.program_id
     ,fact.program_update_date = stage.program_update_date
     ,fact.lead_line_id = stage.lead_line_id
     ,fact.opty_effective_time_id = stage.opty_effective_time_id
     ,fact.opty_rank = stage.opty_rank
   WHERE
       (fact.opty_close_time_id <> stage.opty_close_time_id) OR
       (fact.opty_ld_conversion_time_id <> stage.opty_ld_conversion_time_id) OR
       (fact.opty_creation_time_id <> stage.opty_creation_time_id) OR
       (fact.sales_credit_amt <> stage.sales_credit_amt) OR
       (fact.sales_credit_amt_s <> stage.sales_credit_amt_s) OR
       (fact.product_category_id <> stage.product_category_id) OR
       (fact.item_id <> stage.item_id) OR
       (fact.item_organization_id <> stage.item_organization_id) OR
       (fact.competitor_id <> stage.competitor_id) OR
       (fact.hdr_source_promotion_id <> stage.hdr_source_promotion_id) OR
       (fact.customer_id <> stage.customer_id) OR
       (fact.opty_amt <> stage.opty_amt) OR
       (fact.opty_amt_s <> stage.opty_amt_s) OR
       (fact.owner_sales_group_id <> stage.owner_sales_group_id) OR
       (fact.owner_salesrep_id <> stage.owner_salesrep_id) OR
       (fact.lead_number <> stage.lead_number) OR
       (fact.sales_stage_id <> stage.sales_stage_id) OR
       (fact.status <> stage.status) OR
       (fact.sales_group_id <> stage.sales_group_id) OR
       (fact.salesrep_id <> stage.salesrep_id) OR
       (fact.win_probability <> stage.win_probability) OR
       (fact.open_status_flag <> stage.opp_open_status_flag) OR
       (fact.win_loss_indicator <> stage.win_loss_indicator) OR
       (fact.forecast_rollup_flag <> stage.forecast_rollup_flag) OR
       (fact.lead_line_id <> stage.lead_line_id) OR
       (fact.opty_effective_time_id <> stage.opty_effective_time_id) OR
       (fact.opty_rank <> stage.opty_rank)
DELETE WHERE (to_date(stage.opty_close_time_id,'J')<g_global_start_date and to_date(stage.opty_effective_time_id,'J')<g_global_start_date)
  WHEN NOT MATCHED THEN
     INSERT (opty_id,txn_time_id,opty_close_time_id,opty_ld_conversion_time_id,opty_creation_time_id
             ,sales_credit_amt,sales_credit_amt_s,product_category_id,item_id,item_organization_id
             ,competitor_id,hdr_source_promotion_id,customer_id,opty_amt,opty_amt_s,owner_sales_group_id
             ,owner_salesrep_id,lead_number,sales_stage_id,status,sales_group_id,salesrep_id,win_probability
             ,open_status_flag,win_loss_indicator,forecast_rollup_flag,created_by,creation_date,last_updated_by
             ,last_update_date,last_update_login,request_id,program_application_id,program_id,program_update_date
             ,lead_line_id,sales_credit_id,opty_effective_time_id,opty_rank)
     VALUES (stage.lead_id,
             stage.txn_time_id,stage.opty_close_time_id,stage.opty_ld_conversion_time_id,stage.opty_creation_time_id
             ,stage.sales_credit_amt,stage.sales_credit_amt_s
             ,stage.product_category_id,stage.item_id,stage.item_organization_id
             ,stage.competitor_id,stage.hdr_source_promotion_id,stage.customer_id
             ,stage.opty_amt,stage.opty_amt_s
             ,stage.owner_sales_group_id,stage.owner_salesrep_id
             ,stage.lead_number,stage.sales_stage_id,stage.status
             ,stage.sales_group_id,stage.salesrep_id
             ,stage.win_probability,stage.opp_open_status_flag,stage.win_loss_indicator,stage.forecast_rollup_flag
             ,stage.created_by,stage.creation_date,stage.last_updated_by,stage.last_update_date
             ,stage.last_update_login,stage.request_id,stage.program_application_id
             ,stage.program_id,stage.program_update_date
             ,stage.lead_line_id,stage.sales_credit_id,stage.opty_effective_time_id,stage.opty_rank);

/*
   INSERT INTO  BIL_BI_OPDTL_F sumry (
          opty_id
         ,txn_time_id
         ,opty_close_time_id
         ,opty_ld_conversion_time_id
         ,opty_creation_time_id
         ,sales_credit_amt
         ,sales_credit_amt_s
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_amt
         ,opty_amt_s
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date
         ,lead_line_id
         ,sales_credit_id
   ) SELECT
          lead_id
         ,to_number(to_char(txn_date, 'J'))
         ,to_number(to_char(effective_date, 'J'))
         ,to_number(to_char(opty_ld_conversion_date, 'J'))
         ,to_number(to_char(opty_creation_date, 'J'))
         ,SUM(decode(sales_credit_amount*prim_conversion_rate, 0, null, sales_credit_amount*prim_conversion_rate))
         ,SUM(decode(sales_credit_amount*CONVERSION_RATE_S, 0, null, sales_credit_amount*CONVERSION_RATE_S))
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_global_amt * prim_conversion_rate
         ,opty_global_amt * CONVERSION_RATE_S
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,opp_open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ,g_user_id
         ,sysdate
         ,g_user_id
         ,sysdate
         ,G_Login_Id
         ,G_request_id
         ,G_appl_id
         ,G_program_id
         ,sysdate
         ,lead_line_id
         ,sales_credit_id
     FROM BIL_BI_OPDTL_STG stg
     WHERE (nvl(product_category_id,-999)<> -999)
       AND effective_date <= l_limit_date
     GROUP BY
          lead_id
         ,lead_line_id
         ,sales_credit_id
         ,to_number(to_char(txn_date, 'J'))
         ,to_number(to_char(effective_date, 'J'))
         ,to_number(to_char(opty_ld_conversion_date, 'J'))
         ,to_number(to_char(opty_creation_date, 'J'))
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_global_amt * prim_conversion_rate
         ,opty_global_amt * CONVERSION_RATE_S
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,opp_open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ;
*/
   g_row_num := sql%rowcount;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Inserted  '|| g_row_num ||' into BIL_BI_OPDTL_F table from BIL_BI_OPDTL_STG');
   END IF;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;
Exception
 When Others Then
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
    fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
        p_module => g_pkg || l_proc || ' proc_error',
        p_msg => fnd_message.get,
        p_force_log => TRUE);
    RAISE;
END Insert_Into_Sumry_Incr;

Procedure Insert_Into_Sumry_Init
IS
  l_sysdate    DATE ;
  l_count      number ;
  l_proc       VARCHAR2(100);
Begin
   l_sysdate    :=sysdate;
   l_count      :=0;
   l_proc       := 'Insert_Into_Sumry_Init';

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;

   INSERT /*+ APPEND  PARALLEL(sumry)*/ INTO BIL_BI_OPDTL_F  sumry
   (
         opty_id
         ,txn_time_id
         ,opty_close_time_id
         ,opty_ld_conversion_time_id
         ,opty_creation_time_id
         ,sales_credit_amt
         ,sales_credit_amt_s
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_amt
         ,opty_amt_s
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,request_id
         ,program_application_id
         ,program_id
         ,program_update_date
         ,lead_line_id
         ,sales_credit_id
         ,opty_effective_time_id
         ,opty_rank
    )
    SELECT /*+ PARALLEL(stg)*/
         lead_id
         ,to_number(to_char(txn_date, 'J'))
         ,to_number(to_char(effective_date, 'J'))
         ,to_number(to_char(opty_ld_conversion_date, 'J'))
         ,to_number(to_char(opty_creation_date, 'J'))
         ,SUM(decode(sales_credit_amount* prim_conversion_rate, 0, null, sales_credit_amount* prim_conversion_rate))
         ,SUM(decode(sales_credit_amount* CONVERSION_RATE_S, 0, null, sales_credit_amount* CONVERSION_RATE_S))
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_global_amt * prim_conversion_rate
         ,opty_global_amt * CONVERSION_RATE_S
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,opp_open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ,g_user_id
         ,sysdate
         ,g_user_id
         ,sysdate
         ,G_Login_Id
         ,G_request_id
         ,G_appl_id
         ,G_program_id
         ,sysdate
         ,lead_line_id
         ,sales_credit_id
         ,to_number(to_char(close_date, 'J'))
         ,opty_rank
    FROM BIL_BI_OPDTL_STG stg
    WHERE ( nvl(product_category_id,-999)<> -999)
    GROUP BY
         lead_id
         ,lead_line_id
         ,sales_credit_id
         ,to_number(to_char(txn_date, 'J'))
         ,to_number(to_char(effective_date, 'J'))
         ,to_number(to_char(opty_ld_conversion_date, 'J'))
         ,to_number(to_char(opty_creation_date, 'J'))
         ,product_category_id
         ,item_id
         ,item_organization_id
         ,competitor_id
         ,hdr_source_promotion_id
         ,customer_id
         ,opty_global_amt * prim_conversion_rate
         ,opty_global_amt * CONVERSION_RATE_S
         ,owner_sales_group_id
         ,owner_salesrep_id
         ,lead_number
         ,sales_stage_id
         ,status
         ,sales_group_id
         ,salesrep_id
         ,win_probability
         ,opp_open_status_flag
         ,win_loss_indicator
         ,forecast_rollup_flag
         ,to_number(to_char(close_date, 'J'))
         ,opty_rank;

    g_row_num := sql%rowcount;

    COMMIT;
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Inserted  '||g_row_num||' into BIL_BI_OPDTL_F table from BIL_BI_OPDTL_STG');
    END IF;
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
       bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end ',
             p_msg => 'End of Procedure '|| l_proc);
    END IF;
Exception
    When Others Then
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
      fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => fnd_message.get,
           p_force_log => TRUE);

      RAISE;
END Insert_Into_Sumry_Init;

PROCEDURE Check_Profiles(ret_status OUT NOCOPY BOOLEAN) IS
   l_list          	dbms_sql.varchar2_table;
   l_val           	dbms_sql.varchar2_table;
   l_global_start_date 	VARCHAR2(30);
   l_int_date_format1  	VARCHAR2(21);
   l_proc       	VARCHAR2(100);

   BEGIN

   l_int_date_format1  	:='MM/DD/YYYY HH24:MI:SS';
   l_proc       	:= 'Check_Profiles';

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;

     l_list(1) := 'BIS_GLOBAL_START_DATE';
     --  l_list(2) := 'BIL_BI_ASN_IMPLEMENTED';

       IF ( bis_common_parameters.check_global_parameters(l_list)) THEN
          bis_common_parameters.get_global_parameters(l_list, l_val);


          l_global_start_date := l_val(1);
         g_global_start_date := TO_DATE(l_global_start_date, l_int_date_format1);
           --g_credit_type_id    := l_val(2);

             g_credit_type_id:=fnd_profile.value('ASN_FRCST_CREDIT_TYPE_ID');

             IF(g_credit_type_id is null) THEN

               IF (g_setup_error_flag = FALSE) THEN

                  g_setup_error_flag := TRUE;

                  fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');

                  bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                                                      p_module => g_pkg || l_proc || ' proc_error',
                                                      p_msg => fnd_message.get,
                                                      p_force_log => TRUE);


               END IF;




        fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
        fnd_message.set_token('PROFILE_USER_NAME' ,bil_bi_util_collection_pkg.get_user_profile_name('ASN_FRCST_CREDIT_TYPE_ID'));
        fnd_message.set_token('PROFILE_INTERNAL_NAME' ,'ASN_FRCST_CREDIT_TYPE_ID');


        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                     p_module => g_pkg || l_proc || ' proc_error',
                   p_msg => fnd_message.get,
                   p_force_log => TRUE);

             END IF;
     ELSE

               bis_common_parameters.get_global_parameters(l_list, l_val);

          --output_message('Not all the profiles have been setup');

     -- print the header
     IF (g_setup_error_flag = FALSE) THEN

        g_setup_error_flag := TRUE;

        fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');

        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);


     END IF;

     FOR v_counter IN 1..2 LOOP
        IF (l_val(v_counter) IS  NULL) THEN

        fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
        fnd_message.set_token('PROFILE_USER_NAME' ,bil_bi_util_collection_pkg.get_user_profile_name(l_list(v_counter)));
        fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(v_counter));


        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);

        END IF;
     END LOOP;


     ret_status := FALSE;
      END IF;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;
 EXCEPTION
WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;
END Check_Profiles;

PROCEDURE Setup_Validation(ret_status OUT NOCOPY BOOLEAN) IS
   l_status           BOOLEAN;
   l_opty_cnt         NUMBER;
   l_number_of_rows   NUMBER;
   l_proc             VARCHAR2(100);

BEGIN
  l_status     := FALSE;
  l_number_of_rows :=0;
  l_proc := 'Setup_Validation';
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
  END IF;
  -- check profiles
  Check_Profiles(l_status);
  ret_status := l_status;
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
      fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
            p_module => g_pkg || l_proc || ' proc_error',
            p_msg => fnd_message.get,
            p_force_log => TRUE);
      ret_status := false;
      RAISE;
END Setup_Validation;


--  **********************************************************************
--  PROCEDURE Populate_Currency_Rate_Stg
--
--  Purpose:
--  To populate the currency table using the records that in the staing table
--      this is to be used in the non-validation phase
--  **********************************************************************

PROCEDURE Populate_Currency_Rate IS
  l_proc     VARCHAR2(100);
BEGIN
   l_proc    := 'Populate_Currency_Rate_Stg';
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;
   IF g_sec_currency is not null THEN
      IF (g_refresh_flag = 'Y') THEN
            MERGE INTO BIL_BI_CURRENCY_RATE sumry
            USING ( SELECT
                        txn_currency,
                        effective_date,
                        decode(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                                    trunc(least(sysdate,effective_date)))) rate,
                        decode(txn_currency,g_sec_currency,1,fii_currency.get_global_rate_secondary(txn_currency,
                                                                    trunc(least(sysdate,effective_date)))) rate_s
                    FROM (SELECT /*+ parallel(stg) */  DISTINCT
                                 txn_currency ,
                                 effective_date
                          FROM BIL_BI_OPDTL_STG stg
                         )
                  ) rates
                  ON
                  (   rates.txn_currency = sumry.currency_code
                     AND rates.effective_date = sumry.exchange_date
                  )
            WHEN MATCHED THEN
                 UPDATE SET sumry.exchange_rate   = rates.rate,
                            sumry.exchange_rate_s = rates.rate_s
            WHEN NOT MATCHED THEN
                 INSERT (sumry.currency_code,
                         sumry.exchange_date,
                         sumry.exchange_rate,
                         sumry.exchange_rate_s)
                 VALUES (
                        rates.txn_currency,
                        rates.effective_date,
                        rates.rate,
                        rates.rate_s);
         ELSE
            MERGE INTO BIL_BI_CURRENCY_RATE sumry
            USING ( SELECT
                        txn_currency,
                        effective_date,
                        decode(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                             trunc(least(sysdate,effective_date)))) rate,
                        decode(txn_currency,g_sec_currency,1,fii_currency.get_global_rate_secondary(txn_currency,
                                                             trunc(least(sysdate,effective_date)))) rate_s
                    FROM (SELECT DISTINCT txn_currency,
                                          effective_date
                          FROM BIL_BI_OPDTL_STG stg
                         )
                  ) rates
                  ON
                  (   rates.txn_currency = sumry.currency_code
                  AND rates.effective_date = sumry.exchange_date
                 )
            WHEN MATCHED THEN
                 UPDATE SET sumry.exchange_rate = rates.rate,
                            sumry.exchange_rate_s = rates.rate_s
            WHEN NOT MATCHED THEN
                 INSERT (sumry.currency_code,
                         sumry.exchange_date,
                         sumry.exchange_rate,
                         sumry.exchange_rate_s)
                 VALUES (
                         rates.txn_currency,
                         rates.effective_date,
                         rates.rate,
                         rates.rate_s
                        );

         END IF;
   ELSE --if g_sec_currency is null
         IF (g_refresh_flag = 'Y') THEN
            MERGE INTO BIL_BI_CURRENCY_RATE sumry
            USING ( SELECT
                        txn_currency,
                        effective_date,
                        decode(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                                    trunc(least(sysdate,effective_date)))) rate
                    FROM (SELECT /*+ parallel(stg) */  DISTINCT
                                 txn_currency ,
                                 effective_date
                          FROM BIL_BI_OPDTL_STG stg
                         )
                  ) rates
                  ON
                  (   rates.txn_currency = sumry.currency_code
                     AND rates.effective_date = sumry.exchange_date
                  )
            WHEN MATCHED THEN
                 UPDATE SET sumry.exchange_rate   = rates.rate
            WHEN NOT MATCHED THEN
                 INSERT (sumry.currency_code,
                         sumry.exchange_date,
                         sumry.exchange_rate)
                 VALUES (
                        rates.txn_currency,
                        rates.effective_date,
                        rates.rate);
         ELSE
            MERGE INTO BIL_BI_CURRENCY_RATE sumry
            USING ( SELECT
                        txn_currency,
                        effective_date,
                        decode(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                             trunc(least(sysdate,effective_date)))) rate
                    FROM (SELECT DISTINCT txn_currency,
                                          effective_date
                          FROM BIL_BI_OPDTL_STG stg
                         )
                  ) rates
                  ON
                  (   rates.txn_currency = sumry.currency_code
                  AND rates.effective_date = sumry.exchange_date
                 )
            WHEN MATCHED THEN
                 UPDATE SET sumry.exchange_rate = rates.rate
            WHEN NOT MATCHED THEN
                 INSERT (sumry.currency_code,
                         sumry.exchange_date,
                         sumry.exchange_rate)
                 VALUES (
                         rates.txn_currency,
                         rates.effective_date,
                         rates.rate);

         END IF;
   END IF;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
                p_module => g_pkg || l_proc ,
                p_msg => 'Inserted  '||sql%rowcount||' into BIL_BI_CURRENCY_RATE table');
   END IF;
   commit;
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
      bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
      fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module => g_pkg || l_proc || ' proc_error',
           p_msg => fnd_message.get,
           p_force_log => TRUE);

      RAISE;
END   Populate_Currency_Rate;

END BIL_BI_OPDTL_F_PKG;

/
