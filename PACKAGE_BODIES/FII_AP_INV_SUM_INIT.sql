--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_SUM_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_SUM_INIT" AS
/* $Header: FIIAP18B.pls 120.13 2006/10/10 23:32:07 vkazhipu noship $ */

g_errbuf                 VARCHAR2(2000) := NULL;
g_retcode                VARCHAR2(200)  := NULL;
g_exception_msg          VARCHAR2(4000) := NULL;
g_prim_currency          VARCHAR2(15)   := NULL;
g_sec_currency           VARCHAR2(15)   := NULL;
g_state                  VARCHAR2(200);
g_start_date             DATE;
g_end_date               DATE;
l_date_mask              VARCHAR2(240);
g_sysdate                DATE := TRUNC(SYSDATE);
g_seq_id                 NUMBER;
g_debug_flag             VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_oper_imp_prof_flag     VARCHAR2(1) := NVL(FND_PROFILE.value('FII_AP_DBI_IMP'), 'N');
g_exp_imp_prof_flag      VARCHAR2(1) := NVL(FND_PROFILE.value('FII_AP_DBI_EXP_IMP'), 'N');
g_manual_sources         VARCHAR2(2000) := FND_PROFILE.value('FII_AP_MANUAL_SOURCES');
ONE_SECOND               CONSTANT NUMBER := 0.000011574;  -- 1 second
INTERVAL_SIZE            NUMBER := 50000;
MAX_LOOP                 CONSTANT NUMBER := 60;

g_prim_rate_type         VARCHAR2(30);
g_sec_rate_type          VARCHAR2(30);
g_primary_mau            NUMBER;
g_secondary_mau          NUMBER;
g_fii_user_id            NUMBER(15);
g_fii_login_id           NUMBER(15);
g_no_worker              NUMBER;

g_fii_schema             VARCHAR2(30);
G_TABLE_NOT_EXIST        EXCEPTION;
                         PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
G_PROCEDURE_FAILURE      EXCEPTION;
G_NO_CHILD_PROCESS       EXCEPTION;
G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;
G_IMP_NOT_SET            EXCEPTION;
G_MISSING_RATES          EXCEPTION;
G_MISS_GLOBAL_PARAMS     EXCEPTION;
G_NEED_SECONDARY_INFO    EXCEPTION;
G_INVALID_MANUAL_SOURCE  EXCEPTION;

g_due_bucket1            NUMBER := 31;
g_due_bucket2            NUMBER := 30;
g_due_bucket3            NUMBER := 15;

g_past_bucket1           NUMBER := 31;
g_past_bucket2           NUMBER := 30;
g_past_bucket3           NUMBER := 15;

g_bucket_interval        NUMBER := 15;
g_no_buckets             NUMBER := 6;

g_start_range            NUMBER;
g_end_range              NUMBER;

g_timestamp1 DATE;
g_timestamp2 DATE;
g_timestamp3 DATE;
g_act_part1 NUMBER;
g_act_part2 NUMBER;

g_ap_schema VARCHAR2(30) := 'AP';
-- ------------------------------------------------------------
-- Private Functions and Procedures
-- ------------------------------------------------------------

---------------------------------------------------
-- PROCEDURE TRUNCATE_TABLE
---------------------------------------------------

PROCEDURE Truncate_table (p_table_name VARCHAR2) IS
    l_stmt VARCHAR2(100);
BEGIN
    l_stmt := 'TRUNCATE table '||g_fii_schema||'.'||p_table_name;
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('g_fii_schema '||g_fii_schema);
      FII_UTIL.put_line('');
      FII_UTIL.put_line(l_stmt);
    end if;
    EXECUTE IMMEDIATE l_stmt;

EXCEPTION
    WHEN G_TABLE_NOT_EXIST THEN
        null;      -- Oracle 942, table does not exist, no actions
    WHEN OTHERS THEN
        g_errbuf := 'Error in Procedure: TRUNCATE_TABLE  Message: '||sqlerrm;
        RAISE;
END Truncate_Table;


-------------------------------------------------------------------
-- PROCEDURE Init
-- Purpose
-- This procedure INIT initialises the global variables.
-------------------------------------------------------------------
PROCEDURE Init is

  l_status              VARCHAR2(30);
  l_industry            VARCHAR2(30);
  l_global_param_list dbms_sql.varchar2_table;


BEGIN

  g_state := 'Initializing the global variables';

  -- --------------------------------------------------------
  -- Find the schema owner
  -- --------------------------------------------------------

  IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema)) THEN
      NULL;
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('g_fii_schema is '||g_fii_schema);
      end if;
  END IF;

  -- --------------------------------------------------------
  -- Find the schema owner (AP)
  -- --------------------------------------------------------

  g_ap_schema := FII_UTIL.get_schema_name('SQLAP');
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('g_ap_schema is '||g_ap_schema);
  end if;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Initializing the Global Currency Precision');
  end if;

  g_primary_mau := nvl(fii_currency.get_mau_primary, 0.01 );
  g_secondary_mau:= nvl(fii_currency.get_mau_secondary, 0.01);

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Initializing the Global Currencies');
  end if;

  g_prim_currency := bis_common_parameters.get_currency_code;
  g_sec_currency := bis_common_parameters.get_secondary_currency_code;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Initializing Global Currency Rate Types');
  end if;

  g_prim_rate_type := bis_common_parameters.get_rate_type;
  g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

  l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
  l_global_param_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
  l_global_param_list(3) := 'BIS_PRIMARY_RATE_TYPE';
  IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
       RAISE G_MISS_GLOBAL_PARAMS;
  END IF;

  if ((g_sec_currency IS NULL and g_sec_rate_type IS NOT NULL) OR
      (g_sec_currency IS NOT NULL and g_sec_rate_type IS NULL)) THEN
         RAISE G_NEED_SECONDARY_INFO;
  END IF;

  g_fii_user_id :=  FND_GLOBAL.User_Id;
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
        g_errbuf := 'Can not get User ID and Login ID, program exit';
        RAISE;

   WHEN G_MISS_GLOBAL_PARAMS THEN
        g_retcode := -1;
        g_errbuf := fnd_message.get_string('FII', 'FII_BAD_GLOBAL_PARA');
        RAISE;

   WHEN G_NEED_SECONDARY_INFO THEN
        g_retcode := -1;
        g_errbuf := fnd_message.get_string('FII', 'FII_AP_SEC_MISS');
        RAISE;

  WHEN OTHERS THEN
       g_retcode := -1;
       g_errbuf := '
---------------------------------
Error in Procedure: INIT
Message: '||sqlerrm;
       RAISE;

END Init;


-----------------------------------------------------------
--PROCEDURE CHILD_SETUP
-----------------------------------------------------------
PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS
  l_dir         VARCHAR2(400);
  l_stmt        VARCHAR2(100);
BEGIN
  g_state := 'Inside the procedure CHILD_SETUP';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  ------------------------------------------------------
  -- Set default directory in case if the profile option
  -- BIS_DEBUG_LOG_DIRECTORY is not set up
  ------------------------------------------------------
  l_dir:='/sqlcom/log';

  ----------------------------------------------------------------
  -- fii_util.initialize will get profile options FII_DEBUG_MODE
  -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
  -- the log files and output files are written to
  ----------------------------------------------------------------
  FII_UTIL.initialize(p_object_name||'.log',p_object_name||'.out',l_dir,'FII_AP_INV_SUM_INIT_Worker');

  g_fii_user_id := FND_GLOBAL.User_Id;
  g_fii_login_id := FND_GLOBAL.Login_Id;

EXCEPTION
  WHEN OTHERS THEN
       rollback;
       g_retcode := -2;
       g_errbuf := 'Error in Procedure: CHILD_SETUP  Message: '||sqlerrm;
       RAISE g_procedure_failure;
END CHILD_SETUP;



-----------------------------------------------------------
--  PROCEDURE REGISTER_JOBS
--  This procedure REGISTER_JOBS will insert the start and end
--  numbers into the worker jobs table.
-----------------------------------------------------------
PROCEDURE REGISTER_JOBS IS

  l_max_number      NUMBER;
  l_start_number    NUMBER;
  l_end_number      NUMBER;
  l_count           NUMBER := 0;
  l_inv_count       NUMBER := 0;
  l_job_size        NUMBER := 0;


BEGIN

  g_state := 'Register jobs for workers';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Register jobs for workers');
  end if;

  SELECT max(invoice_ID), min(invoice_ID), COUNT(*)
  INTO   l_max_number, l_start_number, l_inv_count
  FROM   FII_AP_INVOICE_B;

  IF l_inv_count < (g_no_worker * 20000) THEN
     l_job_size := round(l_inv_count/g_no_worker);
  ELSE
     l_job_size := 20000;
  END IF;

  WHILE (l_start_number < (l_max_number + 1))
  LOOP

   SELECT MAX(INVOICE_ID) INTO l_end_number
    FROM (SELECT invoice_id
          FROM fii_ap_invoice_b
          WHERE invoice_id >= l_start_number
          ORDER BY invoice_id)
    WHERE rownum < l_job_size;

    INSERT INTO FII_AP_PS_WORK_JOBS
          (Start_Range,
           End_Range,
           Worker_Number,
           Status)
    VALUES
          (l_start_number,
           least(l_end_number, l_max_number),
           0,
           'UNASSIGNED');

    l_count := l_count + 1;
    l_start_number := least(l_end_number, l_max_number) + 1;
  END LOOP;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('Inserted ' || l_count || ' jobs into FII_AP_PS_WORK_JOBS table');
  end if;

EXCEPTION
  WHEN OTHERS THEN
       g_retcode := -2;
       g_errbuf := '
Error in Procedure: REGISTER_JOBS
Phase: '||g_state||'
Message: '||sqlerrm;
       RAISE g_procedure_failure;

END REGISTER_JOBS;



---------------------------------------------------
-- FUNCTION LAUNCH_WORKER
-- This function LAUNCH_WORKER will submit the subworker
-- request.
-- p_worker_no is the worker number of this particular worker
---------------------------------------------------
FUNCTION LAUNCH_WORKER(p_worker_no  NUMBER) RETURN NUMBER IS
  l_request_id         NUMBER;
BEGIN


  g_state := 'Inside Launch Worker procedure for worker ' || p_worker_no;
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  l_request_id := FND_REQUEST.SUBMIT_REQUEST
                         ('FII',
                          'FII_AP_INV_SUM_INIT_SUBWORKER',
                          NULL,
                          NULL,
                          FALSE,
                          g_start_date,
                          g_end_date,
                          p_worker_no);

  -- This is the concurrent executable of the subworker.

  IF (l_request_id = 0) THEN
      rollback;
      g_retcode := -2;
      g_errbuf := '
Error in Procedure: LAUNCH_WORKER
Message: '||fnd_message.get;
      RAISE G_NO_CHILD_PROCESS;

  END IF;

  RETURN l_request_id;

EXCEPTION
  WHEN G_NO_CHILD_PROCESS THEN
       g_retcode := -1;
       FII_UTIL.put_line('No child process launched');
       RAISE;
   WHEN OTHERS THEN
        ROLLBACK;
        g_retcode := -2;
        g_errbuf := '
Error in Procedure: LAUNCH_WORKER
Message: '||sqlerrm;
        RAISE g_procedure_failure;

END LAUNCH_WORKER;



---------------------------------------------------
-- PROCEDURE MONITOR_WORKER
-- This function MONITOR_WORKER will monitor the subworker
-- request.
---------------------------------------------------
PROCEDURE MONITOR_WORKER IS

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

  g_state := 'Inside Monitor Workers';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Register jobs for workers');
  end if;

  LOOP

    SELECT nvl(sum(decode(status,'UNASSIGNED',1,0)),0),
           nvl(sum(decode(status,'COMPLETED',1,0)),0),
           nvl(sum(decode(status,'IN PROCESS',1,0)),0),
           nvl(sum(decode(status,'FAILED',1,0)),0),
           count(*)
    INTO   l_unassigned_cnt,
           l_completed_cnt,
           l_wip_cnt,
           l_failed_cnt,
           l_tot_cnt
    FROM   FII_AP_PS_WORK_JOBS;

    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Job status - Unassigned:'||l_unassigned_cnt||
                         ' In Process:'||l_wip_cnt||
                         ' Completed:'||l_completed_cnt||
                         ' Failed:'||l_failed_cnt);
    end if;

    IF l_failed_cnt > 0 THEN
       g_retcode := -2;
       g_errbuf := '
Error in Main Procedure:
Message: At least one of the workers have errored out';
       RAISE g_procedure_failure;

    END IF;

    ----------------------------------------------
    -- IF the number of complete count equals to
    -- the total count, then that means all workers
    -- have completed.  Then we can exit the loop
    ----------------------------------------------

    IF l_tot_cnt = l_completed_cnt THEN

       if g_debug_flag = 'Y' then
          FII_UTIL.put_line('Job status - Total: '|| l_tot_cnt);
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

    ----------------------------------------
    -- MAX_LOOP is a global variable you set.
    -- It represents the number of minutes
    -- you want to wait for each worker to
    -- complete.  We can set it to 30 minutes
    -- for now
    ----------------------------------------

    IF (l_cycle > MAX_LOOP) THEN
        g_retcode := -2;
        g_errbuf := '
Error in Main Procedure:
Message: No progress have been made for '||MAX_LOOP||' minutes Terminating';

        RAISE g_procedure_failure;
    END IF;

    -------------------------
    -- Sleep 60 Seconds
    -------------------------
    dbms_lock.sleep(60);

    l_last_unassigned_cnt := l_unassigned_cnt;
    l_last_completed_cnt := l_completed_cnt;
    l_last_wip_cnt := l_wip_cnt;

  END LOOP;

  if g_debug_flag = 'Y' then
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;


EXCEPTION
   WHEN G_PROCEDURE_FAILURE THEN
        ROLLBACK;
        RAISE g_procedure_failure;
   WHEN OTHERS THEN
        ROLLBACK;
        g_retcode := -2;
        g_errbuf := '
Error in Procedure: MONITOR_WORKER
Message: '||sqlerrm;
        RAISE g_procedure_failure;

END MONITOR_WORKER;


------------------------------------------------------------------
-- Procedure insert_wh_prepay_amount
-- Purpose
-- This fuction INSERT_WH_PREPAY_AMOUNT inserts the prepayment and
-- withholding amount applicable for a payment schedule into the
-- temp table.
------------------------------------------------------------------
Procedure INSERT_WH_PREPAY_AMOUNT IS

BEGIN

  g_state := 'Inserting records into the FII_AP_WH_TAX_T table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;


  /* Selecting the prorated prepayment and withholding amount for a
     payment schedule and inserting into the temp table */


  INSERT /*+ append parallel(T) */ INTO fii_ap_wh_tax_t T
        (Invoice_ID,
         Payment_Num,
	 Creation_Date,
         Due_Date,
         Discount_Date,
         Second_Discount_Date,
         Third_Discount_Date,
         Invoice_Type,
         Entered_Date,
         WH_Tax_Amount)
  SELECT /*+ ordered use_hash(AID,AI,FC,PS) parallel(AID) parallel(AI) parallel(FC)
             parallel(PS) */
         AI.Invoice_ID,
         PS.Payment_Num,
	 TRUNC(AID.Creation_Date) Creation_Date,
         TRUNC(PS.Due_Date),
         TRUNC(PS.Discount_Date),
         TRUNC(PS.Second_Discount_Date),
         TRUNC(PS.Third_Discount_Date),
         AI.Invoice_Type,
         TRUNC(AI.Entered_Date),
         -1 * DECODE(AI.Invoice_Amount, 0, 0,
                 DECODE(FC.Minimum_Accountable_Unit, NULL,
                   ROUND(PS.Gross_Amount *
                              SUM(AID.Amount)/AI.Invoice_Amount
                           / 0.01) * 0.01,
                   ROUND(PS.Gross_Amount *
                              SUM(AID.Amount)/AI.Invoice_Amount
                           / FC.Minimum_Accountable_Unit) * FC.Minimum_Accountable_Unit))
                WH_Tax_Amount
  FROM   FII_AP_Invoice_B AI,
         AP_Invoice_Distributions_All AID,
         AP_Invoice_Lines_All AIL,
         AP_Payment_Schedules_All PS,
         FND_Currencies FC
  WHERE  AI.Invoice_ID             = AID.Invoice_ID
  AND    AID.Invoice_ID = AIL.Invoice_ID
  AND    AID.Invoice_Line_Number = AIL.Line_Number
  AND    AI.Cancel_Date IS NULL
  AND    (AID.Line_Type_Lookup_Code IN ('AWT') OR (AID.Line_Type_Lookup_Code IN ('NONREC_TAX', 'REC_TAX') AND AID.Prepay_Distribution_ID IS NOT NULL))
  AND    (AIL.Invoice_Includes_Prepay_Flag IS NULL or AIL.Invoice_Includes_Prepay_Flag = 'N')
  AND    PS.Invoice_ID             = AI.Invoice_ID
  AND    FC.Currency_Code          = AI.Payment_Currency_Code
  GROUP  BY AI.Invoice_ID,
            AI.Invoice_Amount,
            PS.Payment_Num,
            PS.Gross_Amount,
	    TRUNC(AID.Creation_Date),
            TRUNC(PS.Due_Date),
            TRUNC(PS.Discount_Date),
            TRUNC(PS.Second_Discount_Date),
            TRUNC(PS.Third_Discount_Date),
            AI.Invoice_Type,
            TRUNC(AI.Entered_Date),
            FC.Precision,
            FC.Minimum_Accountable_Unit;


  if g_debug_flag = 'Y' then
     fii_util.put_line('Inserted '||SQL%ROWCOUNT||' records into FII_AP_WH_TAX_T');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_WH_TAX_T');
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  COMMIT;



  g_state := 'Inserting records into the FII_AP_Prepay_T table';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('');
       FII_UTIL.put_line(g_state);
       fii_util.start_timer;
       fii_util.put_line('');
    end if;

  INSERT /*+ append parallel(T) */ INTO fii_ap_prepay_t T
	 (Invoice_ID,
	  Payment_Num,
	  Creation_Date,
          Due_Date,
          Discount_Date,
          Second_Discount_Date,
          Third_Discount_Date,
          Entered_Date,
	  Prepay_Amount,
	  Check_ID)
  SELECT  /*+ parallel(AID_prepay) parallel(PS_Prepay) */
          PS_Prepay.Invoice_ID Invoice_ID,
          PS_Prepay.Payment_Num Payment_Num,
          AID_Prepay.Creation_Date Creation_Date,
          PS_Prepay.Due_Date Due_Date,
          PS_Prepay.Discount_Date Discount_Date,
          PS_Prepay.Second_Discount_Date Second_Discount_Date,
          PS_Prepay.Third_Discount_Date Third_Discount_Date,
          PS_Prepay.Entered_Date Entered_Date,
          CASE
              WHEN    PS_Prepay.First_PP + 1 <= AID_Prepay.First + 1 AND AID_Prepay.First + 1 <= PS_Prepay.Last_PP
                      THEN LEAST(PS_Prepay.Last_PP, AID_Prepay.Last) - AID_Prepay.First
              WHEN    AID_Prepay.First + 1 <= PS_Prepay.First_PP + 1 AND PS_Prepay.First_PP + 1 <= AID_Prepay.Last
                      THEN LEAST(PS_Prepay.Last_PP, AID_Prepay.Last) - PS_Prepay.First_PP
          END Prepay_Amount,
	  AID_Prepay.Check_ID Check_ID
  FROM    (SELECT /*+ use_hash(AID,TEMP,AIP) parallel(AID) parallel(TEMP) parallel(AIP) */
                  AID.Invoice_ID Invoice_ID,
                  TRUNC(AID.Creation_Date) Creation_Date,
                  SUM(-1*ROUND((AID.Amount * AI.Payment_Cross_Rate)
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)) Prepymt,
                  (SUM(SUM(-1*ROUND((AID.Amount * AI.Payment_Cross_Rate)
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)))
                                                 OVER (PARTITION BY AID.Invoice_ID
                                                 ORDER BY AID.Invoice_ID, TRUNC(AID.Creation_Date)
                                                 ROWS UNBOUNDED PRECEDING))
                        - SUM(-1*ROUND((AID.Amount * AI.Payment_Cross_Rate)
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)) AS First,
                  SUM(SUM(-1*AID.Amount * AI.Payment_Cross_Rate)) OVER (PARTITION BY AID.Invoice_ID
                                                ORDER BY AID.Invoice_ID, TRUNC(AID.Creation_Date)
                                                ROWS UNBOUNDED PRECEDING) AS Last,
		  AIP.Check_ID Check_ID
          FROM    AP_Invoice_Distributions_All AID,
                  AP_Invoice_Lines_All AIL,
		  AP_Invoice_Distributions_All TEMP,
		  (SELECT /*+ parallel(AIP1) */ Invoice_ID Invoice_ID,
			  MIN(Check_ID) Check_ID
		   FROM	  AP_Invoice_Payments_All AIP1
		   GROUP BY Invoice_ID) AIP,
		  AP_Invoices_All AI,
                  FND_Currencies FC
          WHERE   AID.Invoice_ID = AI.Invoice_ID
          AND     AID.Invoice_ID = AIL.Invoice_ID
          AND     AID.Invoice_Line_Number = AIL.Line_Number
          AND     AID.Line_Type_Lookup_Code = 'PREPAY'
	  --AND 	  AID.Reversal_Flag IS NULL
	  AND NVL(AID.Reversal_Flag,'N') = 'N'
	  AND 	  (AIL.Invoice_Includes_Prepay_Flag IS NULL OR AIL.Invoice_Includes_Prepay_Flag = 'N')
          AND	  AID.Prepay_Distribution_ID = TEMP.Invoice_Distribution_ID
	  AND	  TEMP.Invoice_ID = AIP.Invoice_ID
          AND     AI.Payment_Currency_Code = FC.Currency_Code
	  GROUP BY AID.Invoice_ID, TRUNC(AID.Creation_Date), AIP.Check_ID) AID_Prepay,
          (SELECT /*+ parallel(PP) */
                  PP.Invoice_ID Invoice_ID,
                  PP.Payment_Num Payment_Num,
                  PP.Due_Date Due_Date,
                  PP.Discount_Date Discount_Date,
                  PP.Second_Discount_Date Second_Discount_Date,
                  PP.Third_Discount_Date Third_Discount_Date,
                  PP.Entered_Date Entered_Date,
                  PP.PP_Amount,
                  (SUM(PP.PP_Amount) OVER (PARTITION BY PP.Invoice_ID
                                           ORDER BY PP.Invoice_ID, PP.Payment_Num
                                           ROWS UNBOUNDED PRECEDING)) - PP.PP_Amount AS First_PP,
                  SUM(PP.PP_Amount) OVER (PARTITION BY PP.Invoice_ID
                                          ORDER BY PP.Invoice_ID, PP.Payment_Num
                                          ROWS UNBOUNDED PRECEDING) AS Last_PP
          FROM (SELECT /*+ use_hash(AI) parallel(AI) parallel(PS) parallel(PAY) parallel(TEMP) */
                       PS.Invoice_ID Invoice_ID,
                       PS.Payment_Num Payment_Num,
                       TRUNC(PS.Due_Date) Due_Date,
                       TRUNC(PS.Discount_Date) Discount_Date,
                       TRUNC(PS.Second_Discount_Date) Second_Discount_Date,
                       TRUNC(PS.Third_Discount_Date) Third_Discount_Date,
                       TRUNC(AI.Entered_Date) Entered_Date,
                       PS.Gross_Amount - PS.Amount_Remaining - NVL(PAY.Payment_Amount,0) - NVL(TEMP.WH_Tax_Amount, 0) PP_Amount
               FROM   FII_AP_INVOICE_B AI,
                      AP_PAYMENT_SCHEDULES_ALL PS,
                      (SELECT /*+ parallel(AI) parallel(AIP) parallel(PS)  */
                              AIP.Invoice_ID Invoice_ID,
                              AIP.Payment_Num Payment_Num,
                              SUM(AIP.Amount + NVL(AIP.Discount_Taken, 0)) Payment_Amount
                      FROM    AP_Invoice_Payments_All AIP,
                              FII_AP_Invoice_B AI,
                              AP_Payment_Schedules_All PS
                      WHERE  PS.Invoice_ID   = AI.Invoice_ID
                      AND    AIP.Invoice_ID  = AI.Invoice_ID
                      AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
                      AND    AI.Cancel_Date IS NULL
                      AND    AIP.Payment_Num = PS.Payment_Num
   	              GROUP BY AIP.Invoice_ID, AIP.Payment_Num) PAY,
                      (SELECT /*+ parallel(STG) */ Invoice_ID,
                              Payment_Num,
                              SUM(WH_Tax_Amount) WH_Tax_Amount
                      FROM    FII_AP_WH_TAX_T STG
                      GROUP BY Invoice_ID, Payment_Num) TEMP
              WHERE   PS.Invoice_ID = PAY.Invoice_ID (+)
              AND     PS.Payment_Num = PAY.Payment_Num (+)
              AND     PS.Invoice_ID = TEMP.Invoice_ID (+)
              AND     PS.Payment_Num = TEMP.Payment_Num (+)
              AND     AI.Invoice_ID = PS.Invoice_ID
              ORDER BY PS.Invoice_ID, PS.Payment_Num) PP
          WHERE   PP.PP_Amount > 0) PS_Prepay
  WHERE   AID_Prepay.Invoice_ID = PS_Prepay.Invoice_ID
  AND     AID_Prepay.Prepymt > 0
  AND     ((PS_Prepay.First_PP + 1 <= AID_Prepay.First + 1 AND AID_Prepay.First + 1 <= PS_Prepay.Last_PP) OR
           (AID_Prepay.First + 1 <= PS_Prepay.First_PP + 1 AND PS_Prepay.First_PP + 1 <= AID_Prepay.Last));


  if g_debug_flag = 'Y' then
     fii_util.put_line('Inserted '||SQL%ROWCOUNT||' records into FII_AP_Prepay_T');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;


  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_PREPAY_T');
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  COMMIT;


EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Insert_WH_Prepay_Amount;


------------------------------------------------------------------
-- Procedure insert_payment_check_info
-- Purpose
-- This fuction INSERT_PAYMENT_CHECK_INFO inserts the payment and
-- check information into a staging table
------------------------------------------------------------------
Procedure INSERT_PAYMENT_CHECK_INFO IS

BEGIN

  g_state := 'Inserting records into the FII_AP_PAY_CHK_STG table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;


  INSERT /*+ append parallel(S) */ INTO FII_AP_PAY_CHK_STG S
        (Invoice_ID,
         Payment_Num,
         Check_Date,
         Payment_Amount,
         Discount_Taken,
         Invoice_Type,
         Due_Date,
         Discount_Date,
         Second_Discount_Date,
         Third_Discount_Date,
         Entered_Date,
         Invp_Creation_Date)
  SELECT /*+ use_hash(PS, AIP, AI, AC) parallel(PS) parallel(AIP) parallel(AI) parallel(AC)  */
         PS.Invoice_ID Invoice_Id,
         PS.Payment_Num Payment_Num,
         TRUNC(AC.Check_Date) Check_Date,
         AIP.Amount + NVL(AIP.Discount_Taken,0) Payment_Amount,
         NVL(AIP.Discount_Taken,0) Discount_Taken,
         AI.Invoice_Type Invoice_Type,
         TRUNC(PS.Due_Date) Due_Date,
         TRUNC(PS.Discount_Date) Discount_Date,
         TRUNC(PS.Second_Discount_Date) Second_Discount_Date,
         TRUNC(PS.Third_Discount_Date) Third_Discount_Date,
         TRUNC(AI.Entered_Date) Entered_Date,
         TRUNC(AIP.Creation_Date) Invp_Creation_Date
  FROM   FII_AP_INVOICE_B AI,
         AP_Checks_All AC,
         AP_Invoice_Payments_All AIP,
         AP_Payment_Schedules_All PS
  WHERE  AI.Invoice_ID  = PS.Invoice_ID
  AND    PS.Invoice_ID  = AIP.Invoice_ID
  AND    PS.Payment_Num = AIP.Payment_Num
  AND    AC.Check_ID    = AIP.Check_ID
  AND    AC.Void_Date   IS NULL;

  if g_debug_flag = 'Y' then
     fii_util.put_line('Inserted '||SQL%ROWCOUNT||' records into FII_AP_PAY_CHK_STG');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_PAY_CHK_STG');
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Insert_Payment_Check_Info;



-----------------------------------------------------------
--  FUNCTION VERIFY_MISSING_RATES
-----------------------------------------------------------
FUNCTION Verify_Missing_Rates RETURN NUMBER IS
--  l_miss_rates_prim   NUMBER := 0;
--  l_miss_rates_sec    NUMBER := 0;
  l_miss_rates_ps     NUMBER := 0;
  l_payment_currency  VARCHAR2(2000) := NULL;
  l_trx_date          VARCHAR2(2000) := NULL;
  l_miss_rates_func   NUMBER := 0;

  --------------------------------------------------------
  -- Cursor declaration required to generate output file
  -- containing rows with MISSING CONVERSION RATES
  --------------------------------------------------------

  CURSOR prim_MissingRate IS
  SELECT DISTINCT Functional_Currency From_Currency,
         decode(prim_conversion_rate,-3,  to_date('01/01/1999','MM/DD/RRRR'),
         LEAST(TRX_DATE,sysdate)) Trx_Date
  FROM   FII_AP_PS_RATES_TEMP RATES
  WHERE  RATES.Prim_Conversion_Rate < 0 ;

  CURSOR sec_MissingRate IS
  SELECT DISTINCT FUNCTIONAL_CURRENCY From_Currency,
         decode(sec_conversion_rate,-3,  to_date('01/01/1999','MM/DD/RRRR'),
         LEAST(TRX_DATE,sysdate)) Trx_Date
  FROM   FII_AP_PS_RATES_TEMP RATES
  WHERE  RATES.Sec_Conversion_Rate < 0 ;

  CURSOR func_MissingRate IS
  SELECT DISTINCT From_Currency,
         To_Currency,
         decode(conversion_rate,-3,  to_date('01/01/1999','MM/DD/RRRR'),
         LEAST(TRX_DATE,sysdate)) Trx_Date,
         Conversion_Type
  FROM   FII_AP_FUNC_RATES_TEMP RATES
  WHERE  RATES.Conversion_Rate < 0 ;

BEGIN
  g_state := 'Checking to see which additional rates need to be defined, if any';

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;

  BEGIN
    SELECT 1
    INTO l_miss_rates_ps
    FROM FII_AP_PS_RATES_TEMP RATES
    WHERE (RATES.Prim_Conversion_Rate < 0
    OR RATES.Sec_Conversion_Rate < 0)
    AND   ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN l_miss_rates_ps := 0;
  END;

  BEGIN
    SELECT 1
    INTO   l_miss_rates_func
    FROM   FII_AP_FUNC_RATES_TEMP RATES
    WHERE  RATES.Conversion_Rate < 0
    AND    ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN l_miss_rates_func := 0;
  END;

  --------------------------------------------------------
  -- Print out translated messages to let user know there
  -- are missing exchange rate information
  --------------------------------------------------------
  IF (l_miss_rates_ps > 0 OR
      l_miss_rates_func > 0) THEN
      FII_MESSAGE.write_log(
      msg_name    => 'BIS_DBI_CURR_PARTIAL_LOAD',
      token_num   => 0);
  END IF;

  --------------------------------------------------------
  -- Print out missing rates report
  --------------------------------------------------------

   IF (l_miss_rates_ps > 0 OR
       l_miss_rates_func > 0) THEN
       BIS_COLLECTION_UTILITIES.writeMissingRateHeader;


      FOR rate_record in func_MissingRate
      LOOP
          BIS_COLLECTION_UTILITIES.writeMissingRate(
                        rate_record.conversion_type,
                        rate_record.from_currency,
                        rate_record.to_currency,
                        rate_record.trx_date);
      END LOOP;


         FOR rate_record in prim_MissingRate
         LOOP
             BIS_COLLECTION_UTILITIES.writeMissingRate(
                           g_prim_rate_type,
                           rate_record.from_currency,
                           g_prim_currency,
                           rate_record.trx_date);
         END LOOP;


         FOR rate_record in sec_MissingRate
         LOOP
             BIS_COLLECTION_UTILITIES.writeMissingRate(
                        g_sec_rate_type,
                        rate_record.from_currency,
                        g_sec_currency,
                        rate_record.trx_date);
         END LOOP;
         RETURN -1;

  ELSE
        RETURN 1;
  END IF;  /* IF (l_miss_rates_prim > 0) */

EXCEPTION
  WHEN OTHERS THEN
       g_errbuf:=sqlerrm;
       g_retcode:= -1;
       g_exception_msg  := g_retcode || ':' || g_errbuf;
       FII_UTIL.put_line('Error occured while ' || g_state);
       FII_UTIL.put_line(g_exception_msg);
       RAISE;
END Verify_Missing_Rates;


------------------------------------
---- PROCEDURE INSERT_RATES
------------------------------------

PROCEDURE Insert_Rates IS
l_host_var VARCHAR2(100);

BEGIN

  g_state := 'Loading data into rates table';

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;

  INSERT /*+ append parallel(T) */
  INTO    FII_AP_PS_RATES_TEMP T
        (Functional_Currency,
         Trx_Date,
         Prim_Conversion_Rate,
         Sec_Conversion_Rate)
  SELECT Curr_Code,
         Trx_Date,
	 DECODE(Curr_Code, g_prim_currency, 1,
                   FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY (Curr_Code, LEAST(Trx_Date,sysdate)))
	    PRIM_CONVERSION_RATE,
         DECODE(Curr_Code, g_sec_currency, 1,
                   FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(Curr_Code, LEAST(Trx_Date,sysdate)))
             SEC_CONVERSION_RATE
  FROM  (
         SELECT /*+ parallel(ASP) parallel(AI) use_hash(AI) */
                Distinct ASP.Base_Currency_code Curr_Code,
                TRUNC(AI.Invoice_Date) Trx_Date
         FROM   AP_Invoices_All AI,
                AP_System_Parameters_All ASP
         WHERE  AI.Org_ID = ASP.Org_ID
         AND    AI.Invoice_Type_Lookup_Code <> 'EXPENSE REPORT'
         AND    AI.Invoice_Amount <> 0
         AND    TRUNC(AI.Creation_Date) >= g_start_date
         AND    TRUNC(AI.Creation_Date) + 0 <= g_end_date + 0.99999);

  if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  COMMIT;

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line('Loading data into functional rates table');
     fii_util.start_timer;
     fii_util.put_line('');
  end if;


  INSERT /*+ append parallel(T)*/
  INTO   FII_AP_FUNC_RATES_TEMP T
        (From_Currency,
         To_Currency,
         Trx_Date,
         Conversion_Type,
         Conversion_Rate,
         Functional_MAU)
  SELECT From_Currency,
         To_Currency,
         Trx_Date,
         Exchange_Rate_Type,
         DECODE(Exchange_Rate_Type, 'User', Exchange_Rate, 'No Rate Type', 1,
                 DECODE(From_Currency, To_Currency, 1,
                         FII_CURRENCY.get_rate(From_Currency, To_Currency,
                                                      LEAST(Trx_Date,sysdate), Exchange_Rate_Type)))
             Conversion_Rate,
         Functional_MAU
  FROM  (
         SELECT /*+ parallel(AI) parallel(ASP) parallel(FC) use_hash(AI,ASP,FC) */
                Distinct AI.Payment_Currency_Code From_Currency,
                ASP.Base_Currency_code To_Currency,
                TRUNC(NVL(AI.Exchange_Date, AI.Invoice_Date)) Trx_Date,
                NVL(AI.Exchange_Rate_Type,'No Rate Type') Exchange_Rate_Type,
                DECODE(AI.Exchange_Rate_Type, 'User', AI.Exchange_Rate, 1)
                              Exchange_Rate,
                NVL(FC.Minimum_Accountable_Unit, 0.01) Functional_MAU
         FROM   AP_Invoices_All AI,
                AP_System_Parameters_All ASP,
                FND_Currencies FC
         WHERE  AI.Org_ID = ASP.Org_ID
         AND    AI.Invoice_Type_Lookup_Code <> 'EXPENSE REPORT'
         AND    AI.Invoice_Amount <> 0
         AND    TRUNC(AI.Creation_Date) >= g_start_date
         AND    TRUNC(AI.Creation_Date) + 0 <= g_end_date + 0.99999
         AND    ASP.Base_Currency_Code = FC.Currency_Code);


  if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  COMMIT;

  l_host_var := 'ALTER TABLE ' || g_fii_schema || '.FII_AP_PS_RATES_TEMP CACHE';
  EXECUTE IMMEDIATE l_host_var;
  l_host_var := 'ALTER TABLE ' || g_fii_schema || '.FII_AP_FUNC_RATES_TEMP CACHE';
  EXECUTE IMMEDIATE l_host_var;


EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END Insert_Rates;

------------------------------------------------------------------
-- Procedure POPULATE_HOLDS_SUM
-- Purpose
--   This POPULATE_HOLDS_SUM routine inserts records into the
--   FII AP Holds summary tables.
------------------------------------------------------------------

PROCEDURE POPULATE_HOLDS_SUM IS

BEGIN

  g_state := 'Deleting records from FII_AP_INV_HOLDS_B that are already existing';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  /* For Initial Load we will truncate the data in the holds summary table
     and re-populate this table */
  TRUNCATE_TABLE('MLOG$_FII_AP_INV_HOLDS_B');
  TRUNCATE_TABLE('FII_AP_INV_HOLDS_B');


  g_state := 'Populating FII_AP_INV_HOLDS_B FROM AP_HOLDS_ALL table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT /*+ append parallel(S) */ INTO FII_AP_INV_HOLDS_B S
        (Time_ID,
         Period_Type_ID,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Hold_Date,
         Hold_Code,
         Held_By,
         Hold_Category,
         Release_Date,
         Released_By,
         Created_By,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ ordered parallel(AH) parallel(AI) use_hash(AI,AH) */
         TO_NUMBER(TO_CHAR(AH.Hold_Date,'J')),
         1,
         AH.Org_ID,
         AI.Supplier_ID,
         AH.Invoice_ID,
         TRUNC(AH.Hold_Date),
         AH.Hold_Lookup_Code,
         AH.Held_By,
        (CASE
            WHEN Hold_Lookup_Code IN ('DIST ACCT INVALID', 'ERV ACCT INVALID')
                 THEN 'ACCOUNT'
            WHEN Hold_Lookup_Code IN ('CANT FUNDS CHECK', 'INSUFFICIENT FUNDS')
                 THEN 'FUNDS'
            WHEN Hold_Lookup_Code IN ('AMOUNT', 'AWT ERROR', 'VENDOR',
                                      'NATURAL ACCOUNT TAX', 'PREPAID AMOUNT')
                 THEN 'INVOICE'
            WHEN Hold_Lookup_Code IN ('CANT CLOSE PO', 'CANT TRY PO CLOSE',
                                      'FINAL MATCHING', 'PO REQUIRED', 'MAX QTY ORD',
                                      'MAX QTY REC', 'MAX RATE AMOUNT', 'MAX SHIP AMOUNT',
                                      'MAX TOTAL AMOUNT', 'PRICE', 'QTY ORD', 'QTY REC',
                                      'QUANTITY', 'REC EXCEPTION', 'TAX DIFFERENCE')
                 THEN 'PO MATCHING'
            WHEN Hold_Lookup_Code IN ('DIST VARIANCE', 'TAX VARIANCE', 'TAX AMOUNT RANGE', 'LINE VARIANCE')
                 THEN 'VARIANCE'
            WHEN Hold_Lookup_Code IN ('NO RATE', 'VENDOR')
                 THEN 'MISCELLANEOUS'
         ELSE 'USER DEFINED'
         END) AS Hold_Category,
         DECODE(AH.Release_Lookup_Code, Null, Null,
                         AH.Last_Update_Date),
         DECODE(AH.Release_Lookup_Code, Null, Null,
                         AH.Last_Updated_By),
         g_fii_user_id Created_By,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   AP_Holds_All AH,
         FII_AP_Invoice_B AI
  WHERE  AH.Invoice_ID = AI.Invoice_ID
  AND    AI.Cancel_Date IS NULL
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    TRUNC(AH.Hold_Date) >= g_start_date
  AND    TRUNC(AH.Hold_Date) + 0 <= g_end_date + 0.99999;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted '|| SQL%ROWCOUNT ||' records into FII_AP_INV_HOLDS_B');
     FII_UTIL.put_line('');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;

  COMMIT;


EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END;


------------------------------------------------------------------
-- Procedure POPULATE_INV_BASE_SUM
-- Purpose
--   This POPULATE_INV_BASE_SUM routine inserts records into the
--   FII AP Invoice Base summary table.
------------------------------------------------------------------

PROCEDURE POPULATE_INV_BASE_SUM IS

  l_stmt  VARCHAR2(20000);

BEGIN

  g_state := 'Deleting records from FII_AP_INVOICE_B that are already existing';
  /* For Initial Load we will truncate the data in the invoice base summary table
     and re-populate this table */
  TRUNCATE_TABLE('MLOG$_FII_AP_INVOICE_B');
  TRUNCATE_TABLE('FII_AP_INVOICE_B');

  g_state := 'Populating FII_AP_INVOICE_B FROM AP_INVOICES_ALL table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* Enhancement 4227813: Manual invoice sources are defined by the profile option
     'FII: Manual Invoice Sources'.  Do dummy select in order to verify that the
     format of the profile option is valid.  Correct format is: 'Source1',..,'SourceN'*/
     g_manual_sources := upper(g_manual_sources);
     IF g_manual_sources IS NULL THEN g_manual_sources := ''''''; END IF;
     BEGIN
     execute immediate('SELECT 1 FROM (SELECT '' '' SOURCE FROM DUAL)
                        WHERE SOURCE IN (' || g_manual_sources || ')');
     EXCEPTION
        WHEN OTHERS THEN
        RAISE g_invalid_manual_source;
     END;


  /* Insert statement to insert the invoice records into the base summary
     table. We will insert the maximum due_date, maximum discount offered
     and the first hold date in this table. */


  INSERT /*+ append parallel(S) */ INTO FII_AP_INVOICE_B S
           (Org_ID,
            Supplier_ID,
            Invoice_ID,
            Invoice_Type,
            Invoice_Number,
            Invoice_Date,
            Invoice_Amount,
            Invoice_Currency_Code,
            Base_Currency_Code,
            Exchange_Date,
            Exchange_Rate,
            Exchange_Rate_Type,
            Entered_Date,
            Created_By,
            Payment_Currency_Code,
            Payment_Status_Flag,
            Payment_Cross_Rate,
            Fully_Paid_Date,
            Terms_ID,
            Source,
            E_Invoices_Flag,
            Cancel_Flag,
            Cancel_Date,
            Dist_Count,
            Base_Amount,
            Prim_Amount,
            Sec_Amount,
            Discount_Offered,
            Discount_Offered_B,
            Prim_Discount_Offered,
            Sec_Discount_Offered,
            Fully_Paid_Amount,
            Fully_Paid_Amount_B,
            Prim_Fully_Paid_Amount,
            Sec_Fully_Paid_Amount,
            Due_Date,
            Creation_Date,
            Last_Updated_By,
            Last_Update_Date,
            Last_Update_Login)
     SELECT /*+ leading(IB) parallel(IB) use_hash(PS,RATES,FRATES,AIP)
                 parallel(RATES) parallel(FRATES) */
            IB.Org_ID,
            IB.Supplier_ID,
            IB.Invoice_ID,
            IB.Invoice_Type,
            IB.Invoice_Number,
            IB.Invoice_Date,
            IB.Invoice_Amount,
            IB.Invoice_Currency_Code,
            IB.Base_Currency_Code,
            IB.Exchange_Date,
            IB.Exchange_Rate,
            IB.Exchange_Rate_Type,
            IB.Entered_Date,
            IB.Created_By,
            IB.Payment_Currency_Code,
            IB.Payment_Status_Flag,
            IB.Payment_Cross_Rate,
            DECODE(IB.Payment_Status_Flag, 'Y',
                   DECODE(AIP.Fully_Paid_Date, NULL, IB.Fully_Paid_Date,
                          DECODE(IB.Fully_Paid_Date, NULL, AIP.Fully_Paid_Date,
                                 GREATEST(AIP.Fully_Paid_Date, IB.Fully_Paid_Date))), NULL) Fully_Paid_Date,
            IB.Terms_ID,
            IB.Source,
            IB.E_Invoices_Flag,
            IB.Cancel_Flag,
            IB.Cancel_Date,
            IB.Dist_Count,
            ROUND((IB.Invoice_Amount * FRATES.Conversion_Rate)
                   /  Functional_MAU ) *  Functional_MAU  Base_Amount,
            ROUND(DECODE(IB.Invoice_Currency_Code, g_prim_currency, IB.Invoice_Amount,
                 ((IB.Invoice_Amount * FRATES.Conversion_Rate) * RATES.Prim_Conversion_Rate))
                   / g_primary_mau) * g_primary_mau Prim_Amount,
            ROUND(DECODE(IB.Invoice_Currency_Code, g_sec_currency, IB.Invoice_Amount,
                 ((IB.Invoice_Amount * FRATES.Conversion_Rate) * RATES.Sec_Conversion_Rate))
                   / g_secondary_mau) * g_secondary_mau Sec_Amount,
            PS.Discount_Amount_Available Discount_Offered,
            ROUND((PS.Discount_Amount_Available * FRATES.Conversion_Rate)
                  /  Functional_MAU ) * Functional_MAU  Discount_Offered_B,
            ROUND(DECODE(IB.Invoice_Currency_Code, g_prim_currency, PS.Discount_Amount_Available,
                 ((PS.Discount_Amount_Available * FRATES.Conversion_Rate)
                  * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Offered,
            ROUND(DECODE(IB.Invoice_Currency_Code, g_sec_currency, PS.Discount_Amount_Available,
                 ((PS.Discount_Amount_Available * FRATES.Conversion_Rate)
                  * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Offered,
            DECODE(IB.Payment_Status_Flag, 'Y',
                   NVL(AIP.Fully_Paid_Amount_IP,0) + NVL(IB.Fully_Paid_Amount_PP,0), NULL) Fully_Paid_Amount,
            ROUND((DECODE(IB.Payment_Status_Flag, 'Y',
                   NVL(AIP.Fully_Paid_Amount_IP,0) + NVL(IB.Fully_Paid_Amount_PP,0), NULL) * FRATES.Conversion_Rate)
                  / Functional_MAU) * Functional_MAU Fully_Paid_Amount_B,
            ROUND(DECODE(IB.Invoice_Currency_Code, g_prim_currency,
                         DECODE(IB.Payment_Status_Flag, 'Y',
                         NVL(AIP.Fully_Paid_Amount_IP,0) + NVL(IB.Fully_Paid_Amount_PP,0), NULL),
                       ((DECODE(IB.Payment_Status_Flag, 'Y',
                         NVL(AIP.Fully_Paid_Amount_IP,0) + NVL(IB.Fully_Paid_Amount_PP,0), NULL) * FRATES.Conversion_Rate)
                        * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Fully_Paid_Amount,
            ROUND(DECODE(IB.Invoice_Currency_Code, g_sec_currency,
                         DECODE(IB.Payment_Status_Flag, 'Y',
                         NVL(AIP.Fully_Paid_Amount_IP,0) + NVL(IB.Fully_Paid_Amount_PP,0), NULL),
                       ((DECODE(IB.Payment_Status_Flag, 'Y',
                         NVL(AIP.Fully_Paid_Amount_IP,0) + NVL(IB.Fully_Paid_Amount_PP,0), NULL) * FRATES.Conversion_Rate)
                        * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Fully_Paid_Amount,
            PS.Due_Date,
            IB.Creation_Date,
            IB.Last_Updated_By,
            IB.Last_Update_Date,
            IB.Last_Update_Login
     FROM
           (SELECT /*+ no_merge ordered use_hash(AI,AID) parallel(IB) parallel(AI) parallel(AID) */
                   AI.Org_ID,
                   AI.Vendor_ID Supplier_id,
                   AI.Invoice_ID,
                   AI.Invoice_Type_Lookup_Code Invoice_type,
                   AI.Invoice_Num Invoice_Number,
                   TRUNC(AI.Invoice_Date) Invoice_Date,
                   AI.Invoice_Amount,
                   AI.Invoice_Currency_Code,
                   ASP.Base_Currency_Code,
                   TRUNC(NVL(AI.Exchange_Date, AI.Invoice_Date)) Exchange_Date,
                   AI.Exchange_Rate,
                   NVL(AI.Exchange_Rate_Type, 'No Rate Type') Exchange_Rate_Type,
                   TRUNC(AI.Creation_Date) Entered_Date ,
                   AI.Created_By ,
                   AI.Payment_Currency_Code,
                   AI.Payment_Status_Flag,
                   AI.Payment_Cross_Rate,
                   Decode(AI.Payment_Status_Flag, 'Y',
                               TRUNC(MAX(CASE WHEN AID.Line_Type_Lookup_Code = 'PREPAY'
                                              --AND  AID.Reversal_Flag IS NULL
                                              AND NVL(AID.Reversal_Flag,'N') = 'N'
                                              AND  (AIL.Invoice_Includes_Prepay_Flag IS NULL OR AIL.Invoice_Includes_Prepay_Flag = 'N')
                                              THEN AID.Creation_Date
                                              ELSE NULL END)), NULL) Fully_Paid_Date,
                   Decode(AI.Payment_Status_Flag, 'Y',
                               SUM(CASE WHEN AID.Line_Type_Lookup_Code = 'PREPAY'
                                              --AND  AID.Reversal_Flag IS NULL
                                              AND NVL(AID.Reversal_Flag,'N') = 'N'
                                              AND  (AIL.Invoice_Includes_Prepay_Flag IS NULL OR AIL.Invoice_Includes_Prepay_Flag = 'N')
                                              THEN -1 * AID.Amount
                                              ELSE 0 END), 0) Fully_Paid_Amount_PP,
                   AI.Terms_ID,
                   AI.Source,
                   CASE WHEN g_manual_sources like '%''' || to_char(upper(AI.Source)) || '''%'
                        --upper(AI.Source) IN (g_manual_sources)
                        THEN 'N' ELSE 'Y' END E_Invoices_Flag,
                   Decode(AI.Cancelled_Date,Null,'N','Y') Cancel_Flag,
                   AI.Cancelled_Date Cancel_Date,
                   Count(Distinct AID.Invoice_Distribution_ID) Dist_Count,
                   sysdate Creation_Date,
                   g_fii_user_id Last_Updated_By,
                   sysdate Last_Update_Date,
                   g_fii_login_id Last_Update_Login
           FROM    AP_System_Parameters_All ASP,
                   AP_Invoices_All AI,
                   AP_Invoice_Distributions_All AID,
                   AP_Invoice_Lines_All AIL
           WHERE   AI.Invoice_ID = AIL.Invoice_ID (+)
           AND     AIL.Invoice_ID = AID.Invoice_ID (+)
           AND     AIL.Line_Number = AID.Invoice_Line_Number (+)
           AND     AI.Org_ID = ASP.Org_ID
           AND     AI.Invoice_Type_Lookup_Code NOT IN ('EXPENSE REPORT')
           AND     AI.Invoice_Amount <> 0
           AND     TRUNC(AI.Creation_Date) >= g_start_date
           AND     TRUNC(AI.Creation_Date) + 0 <= g_end_date + 0.99999
           GROUP BY AI.Org_ID,
                    AI.Vendor_ID,
                    AI.Invoice_ID,
                    AI.Invoice_Type_Lookup_Code,
                    AI.Invoice_Num,
                    AI.Invoice_Date,
                    AI.Invoice_Amount,
                    ASP.Base_Currency_Code,
                    AI.Base_Amount,
                    AI.Invoice_Currency_Code,
                    AI.Payment_Currency_Code,
                    AI.Exchange_Date,
                    AI.Exchange_Rate,
                    AI.Exchange_Rate_Type,
                    AI.Creation_Date,
                    AI.Created_By,
                    AI.Payment_Status_Flag,
                    AI.Payment_Cross_Rate,
                    AI.Terms_ID,
                    AI.Source,
                    AI.Cancelled_Date) IB,
           (SELECT /*+ no_merge parallel(PS) */
                   PS.Invoice_ID,
                   SUM(NVL(PS.Discount_Amount_Available,0)) Discount_Amount_Available,
                   TRUNC(MIN(PS.Due_Date)) Due_Date
            FROM   AP_Payment_Schedules_all PS
            GROUP  BY PS.Invoice_ID ) PS,
           (SELECT /*+ no_merge parallel(AIP) */
                   AIP.Invoice_id Invoice_ID,
                   TRUNC(MAX(AIP.Creation_Date)) Fully_Paid_Date,
                   SUM(AIP.Amount + NVL(AIP.Discount_Taken,0)) Fully_Paid_Amount_IP
            FROM   AP_Invoice_Payments_All AIP
            GROUP  BY AIP.Invoice_ID ) AIP,
            FII_AP_PS_Rates_Temp RATES,
            FII_AP_Func_Rates_Temp FRATES
     WHERE  IB.Invoice_ID = PS.Invoice_ID
     AND    IB.Invoice_ID = AIP.Invoice_ID (+)
     AND    IB.Invoice_Date = RATES.Trx_Date
     AND    IB.Base_Currency_Code = RATES.Functional_Currency
     AND    IB.Payment_Currency_Code = FRATES.From_Currency
     AND    IB.Exchange_Date = FRATES.Trx_Date
     AND    IB.Exchange_Rate_Type = FRATES.Conversion_Type
     AND    DECODE(IB.Exchange_Rate_Type,'User', IB.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
     AND    IB.Base_Currency_Code = FRATES.To_Currency;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' records into FII_AP_INVOICE_B');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  COMMIT;

  FND_STATS.GATHER_TABLE_STATS(g_fii_schema,'FII_AP_INVOICE_B');
  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';


EXCEPTION
   WHEN g_invalid_manual_source THEN
      g_retcode := -1;
      g_errbuf := fnd_message.get_string('FII', 'FII_AP_INVALID_MANUAL_SOURCE');
      RAISE;
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END;



------------------------------------------------------------------
-- Procedure POPULATE_PS_PAYMENT_ACTION
-- Purpose
--   This POPULATE_PS_PAYMENT_ACTION routine inserts records into the
--   FII AP Payment Schedule summary table all the payment and
--   prepayment actions.
------------------------------------------------------------------

PROCEDURE POPULATE_PS_PAYMENT_ACTION IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PS_PAYMENT_ACTION';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Populating Payment Creation records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* Insert statement to insert all the payment information into the summary
     table including the payments made for a prepayment invoice.
     We will record the creation date as the action date and not the check date
     for a payment. If we record the check date as the action date then the
     action date for a voided payment would be the same as the payment creation
     and the report would show wrong results for past periods.  */


  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Check_ID,
         Check_Date,
         Payment_Method,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Inv_Pymt_Flag,
         Unique_ID)
 SELECT /*+ MERGE(PSUM) use_nl(frates,rates) */
	 TO_NUMBER(TO_CHAR(Action_Date,'J')) Time_ID,
         1 Period_Type_ID,
         Action_Date,
         Action,
         g_seq_id Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Invoice_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         ROUND((Amount_Remaining * Conversion_Rate) / Functional_MAU) * Functional_MAU Amount_Remaining_B,
         ROUND((Past_Due_Amount * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Amount_B,
         ROUND((Discount_Available * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Available_B,
         ROUND((Discount_Taken * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Taken_B,
         ROUND((Discount_Lost * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Lost_B,
         ROUND((Payment_Amount * Conversion_Rate) / Functional_MAU) * Functional_MAU Payment_Amount_B,
         ROUND((On_Time_Payment_Amt * Conversion_Rate) / Functional_MAU) * Functional_MAU On_Time_Payment_Amt_B,
         ROUND((Late_Payment_Amt * Conversion_Rate) / Functional_MAU) * Functional_MAU Last_Payment_Amt_B,
         ROUND((Due_Bucket1 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket1_B,
         ROUND((Due_Bucket2 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket2_B,
         ROUND((Due_Bucket3 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket3_B,
         ROUND((Past_Due_Bucket1 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket1_B,
         ROUND((Past_Due_Bucket2 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket2_B,
         ROUND((Past_Due_Bucket3 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket3_B,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Amount_Remaining,
                          ((Amount_Remaining * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Amount_Remaining,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Amount,
                          ((Past_Due_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Discount_Available,
                          ((Discount_Available * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Available,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Discount_Taken,
                          ((Discount_Taken * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Taken,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Discount_Lost,
                          ((Discount_Lost * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Lost,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Payment_Amount,
                          ((Payment_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Payment_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, On_Time_Payment_Amt,
                          ((On_Time_Payment_Amt * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_On_Time_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Late_Payment_Amt,
                          ((Late_Payment_Amt * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Late_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Due_Bucket1,
                          ((Due_Bucket1 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Due_Bucket2,
                          ((Due_Bucket2 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Due_Bucket3,
                          ((Due_Bucket3 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket3,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket1,
                          ((Past_Due_Bucket1 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket2,
                          ((Past_Due_Bucket2 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket3,
                          ((Past_Due_Bucket3 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket3,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Amount_Remaining,
                          ((Amount_Remaining * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Amount_Remaining,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Amount,
                          ((Past_Due_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Discount_Available,
                          ((Discount_Available * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Available,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Discount_Taken,
                          ((Discount_Taken * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Taken,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Discount_Lost,
                          ((Discount_Lost * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Lost,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Payment_Amount,
                          ((Payment_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Payment_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, On_Time_Payment_Amt,
                          ((On_Time_Payment_Amt * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_On_Time_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Late_Payment_Amt,
                          ((Late_Payment_Amt * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Late_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Due_Bucket1,
                          ((Due_Bucket1 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Due_Bucket2,
                          ((Due_Bucket2 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Due_Bucket3,
                          ((Due_Bucket3 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket3,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket1,
                          ((Past_Due_Bucket1 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket2,
                          ((Past_Due_Bucket2 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket3,
                          ((Past_Due_Bucket3 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket3,
         Check_ID,
         Check_Date,
         Payment_Method,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login,
         'Y' Inv_Pymt_Flag,
         Invoice_Payment_ID Unique_ID
  FROM
        (SELECT /*+ leading(aip) merge(aip) use_nl(ai) use_nl(PS) use_nl(AIP) use_nl(apc) */
                TRUNC(AIP.Creation_Date) Action_Date,
		DECODE(AI.Invoice_Type, 'PREPAYMENT', 'PREPAYMENT', 'PAYMENT') Action,
                AI.Org_ID Org_ID,
                AI.Supplier_ID Supplier_ID,
                AI.Invoice_ID Invoice_ID,
                AI.Invoice_Currency_Code Invoice_Currency_Code,
                AI.Base_Currency_Code Base_Currency_Code,
                AI.Invoice_Date Invoice_Date,
                AI.Payment_Currency_Code Payment_Currency_Code,
                AI.Exchange_Rate Exchange_Rate,
                AI.Exchange_Date Exchange_Date,
                AI.Exchange_Rate_Type Exchange_Rate_Type,
                PS.Payment_Num Payment_Num,
                TRUNC(PS.Due_Date) Due_Date,
                AIP.Created_By Created_By,
                -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0)) Amount_Remaining,
                DECODE(AI.Invoice_Type, 'PREPAYMENT', 0,
                   DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1,
                         -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0)), 0)) Past_Due_Amount,
                -1 * NVL(AIP.Discount_Taken,0) Discount_Available,
                NVL(AIP.Discount_Taken,0) Discount_Taken,
                0 Discount_Lost,
                AIP.Amount Payment_Amount,
                DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1, 0,
                                     AIP.Amount) On_Time_Payment_Amt,
                DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1,
                                     AIP.Amount, 0) Late_Payment_Amt,
                DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1,
                             (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)), 0) No_Days_Late,
               CASE
                  WHEN (AI.Invoice_Type <> 'PREPAYMENT')
                   AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) >=  g_due_bucket1
                        THEN  -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0))
                  ELSE  0
                END Due_Bucket1,
                CASE
                  WHEN (AI.Invoice_Type <> 'PREPAYMENT')
                   AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) <= g_due_bucket2
                   AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) >  g_due_bucket3
                        THEN  -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0))
                  ELSE  0
                END Due_Bucket2,
                CASE
                  WHEN (AI.Invoice_Type <> 'PREPAYMENT')
                   AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) <= g_due_bucket3
                   AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) >= 0
                        THEN  -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0))
                  ELSE  0
                END Due_Bucket3,
                CASE
                  WHEN (AI.Invoice_Type <> 'PREPAYMENT')
                   AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
                        THEN  -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0))
                  ELSE  0
                END Past_Due_Bucket1,
                CASE
                  WHEN (AI.Invoice_Type <> 'PREPAYMENT')
                   AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
                   AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) >  g_past_bucket3
                        THEN  -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0))
                  ELSE  0
                END Past_Due_Bucket2,
                CASE
                  WHEN (AI.Invoice_Type <> 'PREPAYMENT')
                   AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
                   AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) >  0
                        THEN  -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0))
                  ELSE  0
                END Past_Due_Bucket3,
                AIP.Check_ID Check_ID,
                AC.Check_Date,
                DECODE(IBY_SYS_PROF_B.Processing_Type,NULL,DECODE(AC.Payment_Method_Lookup_Code, 'EFT', 'E', 'WIRE', 'E', 'M')
               ,DECODE(IBY_SYS_PROF_B.Processing_Type, 'ELECTRONIC', 'E', 'M')) PAYMENT_METHOD,
                AIP.Invoice_Payment_ID
         FROM   FII_AP_Invoice_B AI,
		AP_Payment_Schedules_All PS,
               (SELECT /*+ leading(aip_pp) use_nl(aip_pp,pp) */ AIP_PP.Invoice_ID,
                       AIP_PP.Payment_Num,
                       AIP_PP.Creation_Date,
                       AIP_PP.Created_By,
                       AIP_PP.Amount,
                       AIP_PP.Discount_Taken,
                       AIP_PP.Check_ID,
                       AIP_PP.WH_Tax_Amount + NVL(SUM(CASE WHEN PP.Creation_Date IS NOT NULL
                                                           AND  PP.Creation_Date <= AIP_PP.Creation_Date
                                                           THEN PP.Prepay_Amount ELSE 0 END),0)  Prepay_WH_Tax_Amount,
                       AIP_PP.Invoice_Payment_ID
                FROM
                      (SELECT /*+ use_nl(aip_wh,temp) */ AIP_WH.Invoice_ID,
                              AIP_WH.Payment_Num,
                              AIP_WH.Creation_Date,
                              AIP_WH.Created_By,
                              AIP_WH.Amount,
                              AIP_WH.Discount_Taken,
                              AIP_WH.Check_ID,
                              NVL(SUM(CASE WHEN TEMP.Creation_Date IS NOT NULL
                                           AND  TEMP.Creation_Date <= TRUNC(AIP_WH.Creation_Date)
                                           THEN TEMP.WH_Tax_Amount ELSE 0 END),0) WH_Tax_Amount,
                              AIP_WH.Invoice_Payment_ID
                       FROM AP_Invoice_Payments_All AIP_WH,
                            FII_AP_WH_Tax_T TEMP
                       WHERE AIP_WH.Invoice_ID BETWEEN g_start_range and g_end_range
                       AND   AIP_WH.Invoice_ID = TEMP.Invoice_ID (+)
                       AND   AIP_WH.Payment_Num = TEMP.Payment_Num (+)
                       GROUP BY AIP_WH.Invoice_ID,
                                AIP_WH.Payment_Num,
                                AIP_WH.Creation_Date,
                                AIP_WH.Created_By,
                                AIP_WH.Amount,
                                AIP_WH.Discount_Taken,
                                AIP_WH.Check_ID,
                                AIP_WH.Invoice_Payment_ID) AIP_PP,
                       FII_AP_Prepay_T PP
                WHERE AIP_PP.Invoice_ID = PP.Invoice_ID (+)
                AND   AIP_PP.Payment_Num = PP.Payment_Num (+)
                GROUP BY AIP_PP.Invoice_ID,
                         AIP_PP.Payment_Num,
                         AIP_PP.Creation_Date,
                         AIP_PP.Created_By,
                         AIP_PP.Amount,
                         AIP_PP.Discount_Taken,
                         AIP_PP.Check_ID,
                         AIP_PP.WH_Tax_Amount,
                         AIP_PP.Invoice_Payment_ID) AIP,
                FII_AP_PAY_CHK_STG APC,
 								AP_Checks_All AC,
                IBY_SYS_PMT_PROFILES_B IBY_SYS_PROF_B,--IBY CHANGE
                IBY_ACCT_PMT_PROFILES_B IBY_ACCT_PROF_B--IBY CHANGE
         WHERE  AI.Invoice_ID = PS.Invoice_ID
         AND    AI.Cancel_Date IS NULL
         AND    AIP.Invoice_ID  = PS.Invoice_ID
         AND    AIP.Payment_Num = PS.Payment_Num
         AND    AIP.Check_ID    = AC.Check_ID
         AND    APC.Invoice_ID  = PS.Invoice_ID
         AND    APC.Payment_Num = PS.Payment_Num
         AND    AC.Payment_Profile_ID = IBY_ACCT_PROF_B.Payment_Profile_ID(+)--IBY CHANGE
         AND    IBY_ACCT_PROF_B.system_profile_code = IBY_SYS_PROF_B.system_profile_code(+)--IBY CHANGE
         AND    APC.Invp_Creation_Date <= TRUNC(AIP.Creation_Date)
         AND    AC.Void_Date   IS NULL
         HAVING SUM(APC.Payment_Amount) + AIP.Prepay_WH_Tax_Amount <> PS.Gross_Amount
         GROUP  BY AI.Org_ID, AI.Supplier_ID,
                   AI.Invoice_ID,
                   AI.Invoice_Currency_Code,
                   AI.Base_Currency_Code,
                   AI.Invoice_Date,
                   AI.Invoice_Type,
                   AI.Payment_Currency_Code,
                   AI.Exchange_Rate,
                   AI.Exchange_Date,
                   AI.Exchange_Rate_Type,
                   PS.Payment_Num,
                   PS.Due_Date,
                   AIP.Amount,
                   AIP.Created_By,
                   AIP.Check_ID,
                   AC.Check_Date,
                   IBY_SYS_PROF_B.Processing_Type,
                   AC.Payment_Method_Lookup_Code,
                  -- AC.PAYMENT_PROFILE_ID,
                   AIP.Creation_Date,
                   NVL(AIP.Discount_Taken,0),
                   PS.Gross_Amount,
                   AIP.Prepay_WH_Tax_Amount,
                   AIP.Invoice_Payment_ID) PSUM,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES
  WHERE  FRATES.To_Currency   = PSUM.Base_Currency_Code
  AND    FRATES.From_Currency = PSUM.Payment_Currency_Code
  AND    FRATES.Trx_Date      = PSUM.Exchange_Date
  AND    DECODE(PSUM.Exchange_Rate_Type,'User', PSUM.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = PSUM.Exchange_Rate_Type
  AND    RATES.Functional_Currency = PSUM.Base_Currency_Code
  AND    RATES.Trx_Date            = PSUM.Invoice_Date;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Payment records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;




  g_state := 'Populating Payment Creation records into temp table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* We will first insert the last payment of a payment schedule into a temp table
     because we want to adjust the discount available and discount lost for the last
     payment as the discounts can be taken after the discount dates and also more
     discounts can be taken. This adjustment will ensure that the sum of the
     discount available will be zero and the discount lost amount will be
     discount available - taken.

     Since we cannot insert and select from the same table at the same time we will
     select from the pay sched sum table and insert into the temp table  */

  INSERT INTO FII_AP_PAY_SCHED_TEMP
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Fully_Paid_Date,
         Check_ID,
         Check_Date,
         Payment_Method,
         Inv_Pymt_Flag,
         Unique_ID)
  SELECT /*+ ordered use_nl(PS) index(ai, FII_AP_INVOICE_B_U1 )
             use_nl(ai)  use_nl(apc)*/
         TO_NUMBER(TO_CHAR(AIP.Creation_Date,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(AIP.Creation_Date) Action_Date,
         DECODE(AI.Invoice_Type, 'PREPAYMENT', 'PREPAYMENT', 'PAYMENT') Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         AIP.Created_By Created_By,
         -1 * (AIP.Amount + NVL(AIP.Discount_Taken,0)) Amount_Remaining,
         DECODE(AI.Invoice_Type, 'PREPAYMENT', 0,
            DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1,
                  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0))),
                    0)) Past_Due_Amount,
         -1 * NVL(DISC.Discount_Available,0) Discount_Available,
         NVL(AIP.Discount_Taken,0) Discount_Taken,
         GREATEST(NVL(PS.Discount_Amount_Available,0),
                  NVL(PS.Second_Disc_Amt_Available,0),
                  NVL(PS.Third_Disc_Amt_Available,0))
            - NVL(DISC.Discount_Taken,0) - NVL(DISC.Discount_Lost,0)
            - NVL(AIP.Discount_Taken,0) Discount_Lost,
         AIP.Amount Payment_Amount,
         DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1, 0, AIP.Amount) On_Time_Payment_Amt,
         DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1, AIP.Amount, 0) Late_Payment_Amt,
         DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)), -1,
                      (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)), 0) No_Days_Late,
         CASE
           WHEN (AI.Invoice_Type <> 'PREPAYMENT')
            AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) >= g_due_bucket1
                 THEN  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0)))
           ELSE  0
         END Due_Bucket1,
         CASE
           WHEN (AI.Invoice_Type <> 'PREPAYMENT')
            AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) <= g_due_bucket2
            AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) >  g_due_bucket3
                 THEN  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0)))
           ELSE  0
         END Due_Bucket2,
         CASE
           WHEN (AI.Invoice_Type <> 'PREPAYMENT')
            AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) <= g_due_bucket3
            AND (TRUNC(PS.Due_Date) - TRUNC(AIP.Creation_Date)) >= 0
                 THEN  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0)))
           ELSE  0
         END Due_Bucket3,
         CASE
           WHEN (AI.Invoice_Type <> 'PREPAYMENT')
            AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) > = g_past_bucket1
                 THEN  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0)))
           ELSE  0
         END Past_Due_Bucket1,
         CASE
           WHEN (AI.Invoice_Type <> 'PREPAYMENT')
            AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
            AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) >  g_past_bucket3
                 THEN  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0)))
           ELSE  0
         END Past_Due_Bucket2,
         CASE
           WHEN (AI.Invoice_Type <> 'PREPAYMENT')
            AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
            AND (TRUNC(AIP.Creation_Date) - TRUNC(PS.Due_Date)) >  0
                 THEN  -1 * ((AIP.Amount + NVL(AIP.Discount_Taken,0)))
           ELSE  0
         END Past_Due_Bucket3,
         TRUNC(AIP.Creation_Date) Fully_Paid_Date,
         AIP.Check_ID Check_ID,
         AC.Check_Date,
       DECODE(IBY_SYS_PROF_B.Processing_Type,NULL,DECODE(AC.Payment_Method_Lookup_Code, 'EFT', 'E', 'WIRE', 'E', 'M')
      ,DECODE(IBY_SYS_PROF_B.Processing_Type, 'ELECTRONIC', 'E', 'M')) PAYMENT_METHOD,
           'Y' Inv_Pymt_Flag,
         AIP.Invoice_Payment_ID Unique_ID
  FROM
        (SELECT /*+ use_nl(PSUM) */
                PS.Invoice_ID Invoice_ID,
                PS.Payment_Num Payment_Num,
                SUM(Discount_Available) Discount_Available,
                SUM(Discount_Lost) Discount_Lost,
                SUM(Discount_Taken) Discount_Taken
         FROM   FII_AP_Pay_Sched_B PSUM,
                AP_Payment_Schedules_All PS
         WHERE  PS.Invoice_ID BETWEEN g_start_range and g_end_range
         AND    PS.Invoice_ID           = PSUM.Invoice_ID (+)
         AND    PS.Payment_Num          = PSUM.Payment_Num (+)
         AND    PSUM.Period_Type_ID (+) = 1
         GROUP  BY PS.Invoice_ID,
                   PS.Payment_Num) DISC,
        AP_Payment_Schedules_All PS,
        FII_AP_Invoice_B AI,
        (SELECT /*+  merge(aip_pp) use_nl(aip_pp, pp) */
                AIP_PP.Invoice_ID,
                AIP_PP.Payment_Num,
                AIP_PP.Creation_Date,
                AIP_PP.Created_By,
                AIP_PP.Amount,
                AIP_PP.Discount_Taken,
                AIP_PP.Check_ID,
                AIP_PP.WH_Tax_Amount + NVL(SUM(CASE WHEN PP.Creation_Date IS NOT NULL
                                                    AND  PP.Creation_Date <= AIP_PP.Creation_Date
                                                    THEN PP.Prepay_Amount ELSE 0 END),0) Prepay_WH_Tax_Amount,
                AIP_PP.Invoice_Payment_ID
         FROM
               (SELECT /*+ use_nl(aip_wh,temp)  */ AIP_WH.Invoice_ID,
                       AIP_WH.Payment_Num,
                       AIP_WH.Creation_Date,
                       AIP_WH.Created_By,
                       AIP_WH.Amount,
                       AIP_WH.Discount_Taken,
                       AIP_WH.Check_ID,
                       NVL(SUM(CASE WHEN TEMP.Creation_Date IS NOT NULL
                                    AND  TEMP.Creation_Date <= TRUNC(AIP_WH.Creation_Date)
                                    THEN TEMP.WH_Tax_Amount ELSE 0 END),0) WH_Tax_Amount,
                       AIP_WH.Invoice_Payment_ID
                FROM AP_Invoice_Payments_All AIP_WH,
                     FII_AP_WH_Tax_T TEMP
                WHERE AIP_WH.Invoice_ID BETWEEN g_start_range and g_end_range
                AND   AIP_WH.Invoice_ID = TEMP.Invoice_ID (+)
                AND   AIP_WH.Payment_Num = TEMP.Payment_Num (+)
                GROUP BY AIP_WH.Invoice_ID,
                         AIP_WH.Payment_Num,
                         AIP_WH.Creation_Date,
                         AIP_WH.Created_By,
                         AIP_WH.Amount,
                         AIP_WH.Discount_Taken,
                         AIP_WH.Check_ID,
                         AIP_WH.Invoice_Payment_ID) AIP_PP,
                FII_AP_Prepay_T PP
         WHERE AIP_PP.Invoice_ID = PP.Invoice_ID (+)
         AND   AIP_PP.Payment_Num = PP.Payment_Num (+)
         GROUP BY AIP_PP.Invoice_ID,
                  AIP_PP.Payment_Num,
                  AIP_PP.Creation_Date,
                  AIP_PP.Created_By,
                  AIP_PP.Amount,
                  AIP_PP.Discount_Taken,
                  AIP_PP.Check_ID,
                  AIP_PP.WH_Tax_Amount,
                  AIP_PP.Invoice_Payment_ID) AIP,
         FII_AP_PAY_CHK_STG APC,
 	 AP_Checks_All AC,
          -- IBY_Payment_Profiles IBYPM
                IBY_SYS_PMT_PROFILES_B IBY_SYS_PROF_B,--IBY CHANGE
                IBY_ACCT_PMT_PROFILES_B IBY_ACCT_PROF_B--IBY CHANGE
  WHERE  AI.Invoice_ID = PS.Invoice_ID
  AND    AI.Cancel_Date IS NULL
  AND    AIP.Invoice_ID  = PS.Invoice_ID
  AND    AIP.Payment_Num = PS.Payment_Num
  AND    AIP.Check_ID    = AC.Check_ID
  AND    PS.Invoice_ID   = DISC.Invoice_ID
  AND    PS.Payment_Num  = DISC.Payment_Num
  AND    APC.Invoice_ID  = PS.Invoice_ID
  AND    APC.Payment_Num = PS.Payment_Num
  AND    AC.Payment_Profile_ID = IBY_ACCT_PROF_B.Payment_Profile_ID(+)--IBY CHANGE
  AND    IBY_ACCT_PROF_B.system_profile_code = IBY_SYS_PROF_B.system_profile_code(+)--IBY CHANGE
  AND    APC.Invp_Creation_Date <= TRUNC(AIP.Creation_Date)
  AND    AC.Void_Date   IS NULL
  HAVING SUM(APC.Payment_Amount) + AIP.Prepay_WH_Tax_Amount = PS.Gross_Amount
  GROUP  BY AI.Org_ID, AI.Supplier_ID,
            AI.Invoice_ID,
            AI.Base_Currency_Code,
            AI.Invoice_Date,
            AI.Invoice_Type,
            PS.Payment_Num,
            PS.Due_Date,
            AIP.Amount,
            AIP.Created_By,
            AIP.Check_ID,
            AC.Check_Date,
            IBY_SYS_PROF_B.Processing_Type,
            AC.Payment_Method_Lookup_Code,
           -- AC.PAYMENT_PROFILE_ID,
            AIP.Creation_Date,
            NVL(AIP.Discount_Taken,0),
            NVL(DISC.Discount_Available,0),
            NVL(DISC.Discount_Taken,0),
            NVL(DISC.Discount_Lost,0),
            NVL(PS.Discount_Amount_Available,0),
            NVL(PS.Second_Disc_Amt_Available,0),
            NVL(PS.Third_Disc_Amt_Available,0),
            PS.Gross_Amount,
            AIP.Prepay_WH_Tax_Amount,
            AIP.Invoice_Payment_ID;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Last Payment records into FII_AP_PAY_SCHED_TEMP ');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;




  g_state := 'Populating Last Payment Creation records from temp table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Fully_Paid_Date,
         Check_ID,
         Check_Date,
         Payment_Method,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Inv_Pymt_Flag,
         Unique_ID)
  SELECT /*+ ordered use_nl(RATES,FRATES) */
         TEMP.Time_ID,
         TEMP.Period_Type_ID,
         TEMP.Action_Date,
         TEMP.Action,
         TEMP.Update_Sequence,
         TEMP.Org_ID,
         TEMP.Supplier_ID,
         TEMP.Invoice_ID,
         TEMP.Base_Currency_Code,
         TEMP.Trx_Date,
         TEMP.Payment_Num,
         TEMP.Due_Date,
         TEMP.Created_By,
         TEMP.Amount_Remaining,
         TEMP.Past_Due_Amount,
         TEMP.Discount_Available,
         TEMP.Discount_Taken,
         TEMP.Discount_Lost,
         TEMP.Payment_Amount,
         TEMP.On_Time_Payment_Amt,
         TEMP.Late_Payment_Amt,
         TEMP.No_Days_Late,
         TEMP.Due_Bucket1,
         TEMP.Due_Bucket2,
         TEMP.Due_Bucket3,
         TEMP.Past_Due_Bucket1,
         TEMP.Past_Due_Bucket2,
         TEMP.Past_Due_Bucket3,
         ROUND((Amount_Remaining * Conversion_Rate) / Functional_MAU) * Functional_MAU Amount_Remaining_B,
         ROUND((Past_Due_Amount * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Amount_B,
         ROUND((Discount_Available * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Available_B,
         ROUND((Discount_Taken * Conversion_Rate) / Functional_MAU) * Functional_MAU,
         ROUND((Discount_Lost * Conversion_Rate) / Functional_MAU) * Functional_MAU,
         ROUND((Payment_Amount * Conversion_Rate) / Functional_MAU) * Functional_MAU,
         ROUND((On_Time_Payment_Amt * Conversion_Rate) / Functional_MAU) * Functional_MAU,
         ROUND((Late_Payment_Amt * Conversion_Rate) / Functional_MAU) * Functional_MAU,
         ROUND((Due_Bucket1 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket1_B,
         ROUND((Due_Bucket2 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket2_B,
         ROUND((Due_Bucket3 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket3_B,
         ROUND((Past_Due_Bucket1 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket1_B,
         ROUND((Past_Due_Bucket2 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket2_B,
         ROUND((Past_Due_Bucket3 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket3_B,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Amount_Remaining,
                          ((Amount_Remaining * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Amount_Remaining,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Past_Due_Amount,
                          ((Past_Due_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Discount_Available,
                          ((Discount_Available * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Available,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Discount_Taken,
                          ((Discount_Taken * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Discount_Lost,
                          ((Discount_Lost * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Lost,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Payment_Amount,
                          ((Payment_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Payment_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, On_Time_Payment_Amt,
                          ((On_Time_Payment_Amt * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_On_Time_Payment_Amt,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Late_Payment_Amt,
                          ((Late_Payment_Amt * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Late_Payment_Amt,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Due_Bucket1,
                          ((Due_Bucket1 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Due_Bucket2,
                          ((Due_Bucket2 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Due_Bucket3,
                          ((Due_Bucket3 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket3,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket1,
                          ((Past_Due_Bucket1 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket2,
                          ((Past_Due_Bucket2 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket3,
                          ((Past_Due_Bucket3 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket3,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Amount_Remaining,
                          ((Amount_Remaining * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Amount_Remaining,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Past_Due_Amount,
                          ((Past_Due_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Discount_Available,
                          ((Discount_Available * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Available,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Discount_Taken,
                          ((Discount_Taken * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Discount_Lost,
                          ((Discount_Lost * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Lost,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Payment_Amount,
                          ((Payment_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Payment_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, On_Time_Payment_Amt,
                          ((On_Time_Payment_Amt * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_On_Time_Payment_Amt,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Late_Payment_Amt,
                          ((Late_Payment_Amt * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Late_Payment_Amt,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Due_Bucket1,
                          ((Due_Bucket1 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Due_Bucket2,
                          ((Due_Bucket2 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Due_Bucket3,
                          ((Due_Bucket3 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket3,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket1,
                          ((Past_Due_Bucket1 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket2,
                          ((Past_Due_Bucket2 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket3,
                          ((Past_Due_Bucket3 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket3,
         TEMP.Fully_Paid_Date,
         TEMP.Check_ID,
         TEMP.Check_Date,
         TEMP.Payment_Method,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login,
         TEMP.Inv_Pymt_Flag,
         TEMP.Unique_ID
  FROM   FII_AP_Invoice_B AI,
         FII_AP_Pay_Sched_Temp TEMP,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES
  WHERE  TEMP.Invoice_ID      = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    FRATES.To_Currency   = TEMP.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = TEMP.Base_Currency_Code
  AND    RATES.Trx_Date            = TEMP.Trx_Date;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Payment records into FII_AP_PAY_SCHED_B from Temp table');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Populating Withholding Action records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* Insert statement to insert prepayment information into the summary tables.
     Discount information is not recorded as the discounts taken and lost are
     available in the payments to the prepayment invoice.

     For prepayments we will always assume that the payment is made on time and
     will populate the On_Time_Payment_Amt column with the payment amount */



  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+  ordered use_nl(ps) use_nl(rates,frates) */
         TO_NUMBER(TO_CHAR(AID.Creation_Date,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(AID.Creation_Date) Action_Date,
         DECODE(AID.Line_Type_Lookup_Code, 'AWT', 'WITHHOLDING', 'TAX') Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Invoice_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01) Amount_Remaining,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)), -1,
                ROUND(SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))
		/NVL(FC.Minimum_Accountable_Unit, 0.01))
		* NVL(FC.Minimum_Accountable_Unit, 0.01), 0) Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         0 Payment_Amount,
	 0 On_Time_Payment_Amount,
	 0 Late_Payment_Amt,
         DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)), -1,
		(TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)), 0) No_Days_Late,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= g_due_bucket1
	     THEN ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0,PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Due_Bucket1,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) > g_due_bucket3
	     THEN ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0,PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Due_Bucket2,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= 0
	     THEN ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0,PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Due_Bucket3,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0,PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket1,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0,PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket2,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN ROUND((SUM(DECODE(AI.Invoice_Amount, 0, 0,PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)))
                                   / NVL(FC.Minimum_Accountable_Unit, 0.01))
                            * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket3,
         ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01) Amount_Remaining_B,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)), -1,
	         ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01), 0)  Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
	 0 Payment_Amount_B,
	 0 On_Time_Payment_Amt_B,
	 0 Late_Payment_Amt_B,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= g_due_bucket1
	     THEN ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Due_Bucket1_B,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) > g_due_bucket3
	     THEN ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Due_Bucket2_B,
          CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= 0
	     THEN ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Due_Bucket3_B,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Past_Due_Bucket1_B,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket2_B,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN ROUND(((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                           / NVL(FC.Minimum_Accountable_Unit, 0.01))
                      * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket3_B,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                  SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
               (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Amount_Remaining,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)), -1,
         	ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                      SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                    ((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)) * Conversion_Rate)
                	* RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau, 0) Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
	 0 Prim_Payment_Amount,
	 0 Prim_On_Time_Payment_Amt,
	 0 Prim_Late_Payment_Amt,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= g_due_bucket1
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END  Prim_Due_Bucket1,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) > g_due_bucket3
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Due_Bucket2,
          CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= 0
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Due_Bucket3,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Past_Due_Bucket1,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Past_Due_Bucket2,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Past_Due_Bucket3,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
               SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
            (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Amount_Remaining,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)), -1,
         	ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                      SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                    ((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)) * Conversion_Rate)
                	* RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau, 0) Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
	 0 Sec_Payment_Amount,
	 0 Sec_On_Time_Payment_Amt,
	 0 Sec_Late_Payment_Amt,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= g_due_bucket1
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END  Sec_Due_Bucket1,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) > g_due_bucket3
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Due_Bucket2,
          CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(AID.Creation_Date)) >= 0
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Due_Bucket3,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Past_Due_Bucket1,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Past_Due_Bucket2,
         CASE
	     WHEN (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(AID.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount)),
                     (((SUM(DECODE(AI.Invoice_Amount, 0, 0, PS.Gross_Amount * AID.Amount / AI.Invoice_Amount))) * Conversion_Rate)
                * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   FII_AP_Invoice_B AI,
         AP_Invoice_Distributions_All AID,
         AP_Invoice_Lines_All AIL,
	 AP_Payment_Schedules_All PS,
         FII_AP_PS_Rates_Temp RATES,
         FII_AP_Func_Rates_Temp FRATES,
         FND_Currencies FC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND 	 AID.Invoice_ID = AI.Invoice_ID
  AND    AID.Invoice_ID = AIL.Invoice_ID
  AND    AID.Invoice_Line_Number = AIL.Line_Number
  AND    (AID.Line_Type_Lookup_Code IN ('AWT') OR (AID.Line_Type_Lookup_Code IN ('NONREC_TAX', 'REC_TAX') AND AID.Prepay_Distribution_ID IS NOT NULL))
  AND    (AIL.Invoice_Includes_Prepay_Flag IS NULL OR AIL.Invoice_Includes_Prepay_Flag = 'N')
  --AND    AID.Reversal_Flag IS NULL
  AND NVL(AID.Reversal_Flag,'N') = 'N'
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Payment_Currency_Code = FC.Currency_Code
  GROUP BY	TO_NUMBER(TO_CHAR(AID.Creation_Date,'J')),
		TRUNC(AID.Creation_Date),
		AID.Line_Type_Lookup_Code,
                AI.Invoice_Currency_Code,
        	AI.Base_Currency_Code,
        	AI.Invoice_Date,
		AI.Org_ID,
		AI.Supplier_ID,
		AI.Invoice_ID,
		PS.Payment_Num,
		TRUNC(PS.Due_Date),
		PS.Created_By,
		AI.Invoice_Currency_Code,
		AI.Payment_Currency_Code,
		AI.Payment_Cross_Rate,
		NVL(FC.Minimum_Accountable_Unit, 0.01),
		AI.Invoice_Type,
        	RATES.Prim_Conversion_Rate,
        	RATES.Sec_Conversion_Rate,
        	Conversion_Rate;



  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Withholding records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Populating Prepayment Action records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
	 Fully_Paid_Date,
	 Check_ID,
	 Check_Date,
	 Payment_Method,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Inv_Pymt_Flag,
         Unique_ID)
  SELECT /*+ use_nl(PS) use_nl(TEMP) */
	 TO_NUMBER(TO_CHAR(TEMP.Creation_Date,'J')) Time_ID,
	 1 Period_Type_ID,
	 TEMP.Creation_Date Action_Date,
	 'PAYMENT' Action,
	 g_seq_id Update_Sequence,
	 AI.Org_ID Org_ID,
	 AI.Supplier_ID Supplier_ID,
	 AI.Invoice_ID Invoice_ID,
	 AI.Base_Currency_Code Base_Currency_Code,
	 AI.Invoice_Date Invoice_Date,
	 PS.Payment_Num Payment_Num,
	 TRUNC(PS.Due_Date) Due_Date,
	 PS.Created_By Created_By,
	 -1 * ROUND(TEMP.Prepay_Amount
              / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01) Amount_Remaining,
	 -1 * DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
	        ROUND(TEMP.Prepay_Amount
		    /NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01), 0) Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         ROUND(TEMP.Prepay_Amount
              / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01) Payment_Amount,
       	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1, 0,
		  ROUND(TEMP.Prepay_Amount
                       / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)) On_Time_Payment_Amt,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
	          ROUND(TEMP.Prepay_Amount
		       / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01), 0) Late_Payment_Amt,
         DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
		(TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)), 0) No_Days_Late,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= g_due_bucket1
	     THEN -1 * ROUND(TEMP.Prepay_Amount
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Due_Bucket1,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) > g_due_bucket3
	     THEN -1 * ROUND(TEMP.Prepay_Amount
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Due_Bucket2,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= 0
	     THEN -1 * ROUND(TEMP.Prepay_Amount
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Due_Bucket3,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN -1 * ROUND(TEMP.Prepay_Amount
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket1,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN -1 * ROUND(TEMP.Prepay_Amount
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket2,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN -1 * ROUND(TEMP.Prepay_Amount
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket3,
         -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                   / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01) Amount_Remaining_B,
	 -1 * DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
		   ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                        / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01), 0) Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
         ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                     / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01) Payment_Amount_B,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1, 0,
         	ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                     / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)) On_Time_Payment_Amt_B,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
                ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                     / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01), 0) Late_Payment_Amt_B,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= g_due_bucket1
	     THEN -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Due_Bucket1_B,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) > g_due_bucket3
	     THEN -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Due_Bucket2_B,
          CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= 0
	     THEN -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Due_Bucket3_B,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END  Past_Due_Bucket1_B,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket2_B,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN -1 * ROUND((TEMP.Prepay_Amount * Conversion_Rate)
                            / NVL(FC.Minimum_Accountable_Unit, 0.01)) * NVL(FC.Minimum_Accountable_Unit, 0.01)
	     ELSE 0
	 END Past_Due_Bucket3_B,
         -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                         ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                   / g_primary_mau) * g_primary_mau Prim_Amount_Remaining,
	 -1 * DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
         	ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                           ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                     / g_primary_mau) * g_primary_mau, 0) Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                    ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
              / g_primary_mau) * g_primary_mau Prim_Payment_Amount,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1, 0,
         		(ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                    ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                              / g_primary_mau) * g_primary_mau)) Prim_On_Time_Payment_Amt,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
         	ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                           ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                     / g_primary_mau) * g_primary_mau, 0) Prim_Late_Payment_Amt,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= g_due_bucket1
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                            / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END  Prim_Due_Bucket1,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) > g_due_bucket3
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                            / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Due_Bucket2,
          CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= 0
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                            / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Due_Bucket3,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                            / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Past_Due_Bucket1,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                            / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Past_Due_Bucket2,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                            / g_primary_mau) * g_primary_mau
	     ELSE 0
	 END Prim_Past_Due_Bucket3,
         -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                         ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                   / g_secondary_mau) * g_secondary_mau Sec_Amount_Remaining,
  	 -1 * DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
		ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                           ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                     / g_secondary_mau) * g_secondary_mau, 0) Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                    ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
              / g_secondary_mau) * g_secondary_mau Sec_Payment_Amount,
         DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1, 0,
              		(ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                    ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                              / g_secondary_mau)) * g_secondary_mau) Sec_On_Time_Payment_Amt,
	 DECODE(SIGN(TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)), -1,
         	ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                           ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                     / g_secondary_mau) * g_secondary_mau, 0) Sec_Late_Payment_Amt,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= g_due_bucket1
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                            / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END  Sec_Due_Bucket1,
         CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket2
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) > g_due_bucket3
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                            / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Due_Bucket2,
          CASE
	     WHEN (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) <= g_due_bucket3
	     AND (TRUNC(PS.Due_Date) - TRUNC(TEMP.Creation_Date)) >= 0
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                            / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Due_Bucket3,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) >= g_past_bucket1
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                            / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Past_Due_Bucket1,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket2
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > g_past_bucket3
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                            / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Past_Due_Bucket2,
         CASE
	     WHEN (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) <= g_past_bucket3
	     AND (TRUNC(TEMP.Creation_Date) - TRUNC(PS.Due_Date)) > 0
	     THEN -1 * ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency, TEMP.Prepay_Amount,
                                  ((TEMP.Prepay_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                            / g_secondary_mau) * g_secondary_mau
	     ELSE 0
	 END Sec_Past_Due_Bucket3,
	 CASE
		WHEN TEMP.PP_WH_Tax_Pay_Amount = PS.Gross_Amount
		THEN TEMP.Creation_Date ELSE NULL
	 END Fully_Paid_Date,
	 AC.Check_ID Check_ID,
	 AC.Check_Date Check_Date,
   DECODE(IBY_SYS_PROF_B.Processing_Type,NULL,DECODE(AC.Payment_Method_Lookup_Code, 'EFT', 'E', 'WIRE', 'E', 'M')
   ,DECODE(IBY_SYS_PROF_B.Processing_Type, 'ELECTRONIC', 'E', 'M')) PAYMENT_METHOD,
	 sysdate Creation_Date,
	 g_fii_user_id Last_Updated_By,
	 sysdate Last_Update_Date,
	 g_fii_login_id Last_Update_Login,
         'N' Inv_Pymt_Flag,
         AC.Check_ID Unique_ID
  FROM   FII_AP_INVOICE_B AI,
	 AP_Payment_Schedules_All PS,
        (SELECT /*+ use_nl(aps3,pp) */APS3.Invoice_ID,
                APS3.Payment_Num,
                APS3.Creation_Date,
                APS3.Prepay_Amount,
                APS3.Check_ID,
                APS3.WH_Tax_Pay_Amount + NVL(SUM(CASE WHEN PP.Creation_Date IS NOT NULL
                                                      AND  PP.Creation_Date <= APS3.Creation_Date
                                                      THEN PP.Prepay_Amount ELSE 0 END),0) PP_WH_Tax_Pay_Amount
         FROM
               (SELECT /*+ use_nl(aps2,awts) */APS2.Invoice_ID,
                       APS2.Payment_Num,
                       APS2.Creation_Date,
                       APS2.Prepay_Amount,
                       APS2.Check_ID,
                       APS2.Pay_Amount + NVL(SUM(CASE WHEN AWTS.Creation_Date IS NOT NULL
                                                      AND  AWTS.Creation_Date <= APS2.Creation_Date
                                                      THEN AWTS.WH_Tax_Amount ELSE 0 END),0) WH_Tax_Pay_Amount
                FROM
                      (SELECT /*+ use_nl(aps1, apc) */APS1.Invoice_ID,
                              APS1.Payment_Num,
                              APS1.Creation_Date,
	                      APS1.Prepay_Amount,
	                      APS1.Check_ID,
                              NVL(SUM(CASE WHEN APC.Invp_Creation_Date IS NOT NULL
                                           AND  APC.Invp_Creation_Date <= APS1.Creation_Date
                                           THEN APC.Payment_Amount ELSE 0 END),0) Pay_Amount
                       FROM FII_AP_Prepay_T APS1,
                            FII_AP_Pay_Chk_Stg APC
                       WHERE APS1.Invoice_ID BETWEEN g_start_range and g_end_range
                       AND   APS1.Invoice_ID = APC.Invoice_ID (+)
                       AND   APS1.Payment_Num = APC.Payment_Num (+)
                       Group By APS1.Invoice_ID,
                                APS1.Payment_Num,
                                APS1.Creation_Date,
                                APS1.Prepay_Amount,
                                APS1.Check_ID) APS2,
                       FII_AP_WH_Tax_T AWTS
                WHERE APS2.Invoice_ID = AWTS.Invoice_ID (+)
                AND   APS2.Payment_Num = AWTS.Payment_Num (+)
                Group By APS2.Invoice_ID,
                         APS2.Payment_Num,
                         APS2.Creation_Date,
                         APS2.Prepay_Amount,
                         APS2.Check_ID,
                         APS2.Pay_Amount) APS3,
                FII_AP_Prepay_T PP
         WHERE APS3.Invoice_ID = PP.Invoice_ID (+)
         AND   APS3.Payment_Num = PP.Payment_Num (+)
         Group By APS3.Invoice_ID,
                  APS3.Payment_Num,
                  APS3.Creation_Date,
                  APS3.Prepay_Amount,
                  APS3.Check_ID,
                  APS3.WH_Tax_Pay_Amount) TEMP,
	 FII_AP_PS_Rates_Temp RATES,
	 FII_AP_Func_Rates_Temp FRATES,
	 AP_Checks_All AC,
          -- IBY_Payment_Profiles IBYPM--IBY CHANGE
                IBY_SYS_PMT_PROFILES_B IBY_SYS_PROF_B,--IBY CHANGE
                IBY_ACCT_PMT_PROFILES_B IBY_ACCT_PROF_B,--IBY CHANGE
	 FND_Currencies FC
  WHERE  AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_ID = TEMP.Invoice_ID
  AND	 TEMP.Invoice_ID = PS.Invoice_ID
  AND	 TEMP.Payment_Num = PS.Payment_Num
  AND	 TEMP.Check_ID = AC.Check_ID
  AND   AC.Payment_Profile_ID = IBY_ACCT_PROF_B.Payment_Profile_ID(+)--IBY CHANGE
  AND    IBY_ACCT_PROF_B.system_profile_code = IBY_SYS_PROF_B.system_profile_code(+)--IBY CHANGE
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND    AI.Payment_Currency_Code = FC.Currency_Code;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Prepayment records into FII_AP_PAY_SCHED_B ');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;




EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END;


------------------------------------------------------------------
-- Procedure POPULATE_PS_DISCOUNT_ACTION
-- Purpose
--   This POPULATE_PS_DISCOUNT_ACTION routine inserts records into the
--   FII AP Payment Schedule summary table all the discount actions.
------------------------------------------------------------------

PROCEDURE POPULATE_PS_DISCOUNT_ACTION IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PS_DISC_ACTION';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Inserting the Payment Schedules Discount Action';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* For Discount and Due actions we will select the payment schedules whose
     discount or due date falls between the given from date and the least of
     to date or yesterday's date. This way we will not create wrong discount
     lost and past due amounts for due action */

  /* Inserting the Discount Date passed records into the summary table.
     We will insert only those payment schedules which have not been paid
     fully before the first discount date. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Unique_ID)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) index(FRATES) use_nl(ps)  */
         TO_NUMBER(TO_CHAR(PS.Discount_Date + 1,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(PS.Discount_Date) + 1 Action_Date,
         'DISCOUNT' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         -1 * (NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
            -  NVL(PS.Second_Disc_Amt_Available,0)) Discount_Available,
         0 Discount_Taken,
         NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
            - NVL(PS.Second_Disc_Amt_Available,0) Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         0 Due_Bucket2,
         0 Due_Bucket3,
         0 Past_Due_Bucket1,
         0 Past_Due_Bucket2,
         0 Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         ROUND((-1 * (NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)) * Conversion_Rate)
                   / Functional_MAU) * Functional_MAU Discount_Available_B,
         0 Discount_Taken_B,
         ROUND(((NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         0 Due_Bucket2_B,
         0 Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         0 Past_Due_Bucket2_B,
         0 Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                       -1 * (NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)),
                     ((-1 * (NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Available,
         0 Prim_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                        -  NVL(PS.Second_Disc_Amt_Available,0),
                     (((NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         0 Prim_Due_Bucket2,
         0 Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         0 Prim_Past_Due_Bucket2,
         0 Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                       -1 * (NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)),
                     ((-1 * (NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Available,
         0 Sec_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                       NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0),
                    (((NVL(PS.Discount_Amount_Available,0) - NVL(APC.Discount_Taken ,0)
                       -  NVL(PS.Second_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         0 Sec_Due_Bucket2,
         0 Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         0 Sec_Past_Due_Bucket2,
         0 Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login,
         1 Unique_ID
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
	 AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND    TRUNC(TEM.Discount_Date) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < TRUNC(TEM.Discount_Date) + 1
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Discount_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TRUNC(PREP.Discount_Date) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < TRUNC(PREP.Discount_Date) + 1
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Discount_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Discount_Taken, 0)) Discount_Taken,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND    TRUNC(PC.Discount_Date) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < TRUNC(PC.Discount_Date) + 1
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Discount_Date) APC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User',FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND    TRUNC(PS.Discount_Date) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Discount records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Inserting the Payment Schedules Second Discount Records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* Inserting the Discount Date passed records into the summary table.
     We will insert only those payment schedules which have not be paid
     fully before the second discount date. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Unique_ID)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) index(FRATES) use_nl(ps)  */
         TO_NUMBER(TO_CHAR(PS.Second_Discount_Date + 1,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(PS.Second_Discount_Date) + 1 Action_Date,
         'DISCOUNT' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         -1 * (NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
            -  NVL(PS.Third_Disc_Amt_Available,0)) Discount_Available,
         0 Discount_Taken,
         NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
            - NVL(PS.Third_Disc_Amt_Available,0) Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         0 Due_Bucket2,
         0 Due_Bucket3,
         0 Past_Due_Bucket1,
         0 Past_Due_Bucket2,
         0 Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         ROUND((-1 * (NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)) * Conversion_Rate)
                   / Functional_MAU) * Functional_MAU Discount_Available_B,
         0 Discount_Taken_B,
         ROUND(((NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)) * Conversion_Rate)
                   / Functional_MAU) * Functional_MAU Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         0 Due_Bucket2_B,
         0 Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         0 Past_Due_Bucket2_B,
         0 Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        -1 * (NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)),
                      ((-1 * (NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Available,
         0 Prim_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                        NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0),
                     (((NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         0 Prim_Due_Bucket2,
         0 Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         0 Prim_Past_Due_Bucket2,
         0 Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        -1 * (NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)),
                      ((-1 * (NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Available,
         0 Sec_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                        NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0),
                     (((NVL(PS.Second_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)
                        -  NVL(PS.Third_Disc_Amt_Available,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         0 Sec_Due_Bucket2,
         0 Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         0 Sec_Past_Due_Bucket2,
         0 Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login,
         2 Unique_ID
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
	 AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND    TEM.Second_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < TEM.Second_Discount_Date + 1
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Second_Discount_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PREP.Second_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < PREP.Second_Discount_Date + 1
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Second_Discount_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Discount_Taken, 0)) Discount_Taken,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND    PC.Second_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < PC.Second_Discount_Date + 1
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Second_Discount_Date) APC,
        (SELECT PC.Invoice_ID Invoice_ID,
                PC.Payment_Num Payment_Num,
                NVL(SUM(NVL(PC.Discount_Taken,0)),0) Discount_Taken
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_ID BETWEEN g_start_range and g_end_range
         AND    PC.Second_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date BETWEEN PC.Discount_Date + 1 AND PC.Second_Discount_Date
         GROUP  BY  PC.Invoice_ID,
                    PC.Payment_Num) DISC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND    TRUNC(PS.Second_Discount_Date) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    PS.Invoice_ID  = DISC.Invoice_ID(+)
  AND    PS.Payment_Num = DISC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Discount records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Inserting the Payment Schedules Third Discount Records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* Inserting the Discount Date passed records into the summary table.
     We will insert only those payment schedules which have not be paid
     fully before the third discount date. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login,
         Unique_ID)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) index(FRATES) use_nl(ps)  */
         TO_NUMBER(TO_CHAR(PS.Third_Discount_Date + 1,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(PS.Third_Discount_Date) + 1 Action_Date,
         'DISCOUNT' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         -1 * (NVL(PS.Third_Disc_Amt_Available,0)
                     - NVL(DISC.Discount_Taken,0)) Discount_Available,
         0 Discount_Taken,
         NVL(PS.Third_Disc_Amt_Available,0)
                     - NVL(DISC.Discount_Taken,0) Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         0 Due_Bucket2,
         0 Due_Bucket3,
         0 Past_Due_Bucket1,
         0 Past_Due_Bucket2,
         0 Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         ROUND((-1 * (NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Discount_Available_B,
         0 Discount_Taken_B,
         ROUND(((NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         0 Due_Bucket2_B,
         0 Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         0 Past_Due_Bucket2_B,
         0 Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
             -1 * (NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)),
           ((-1 * (NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Available,
         0 Prim_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
             NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0),
          (((NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         0 Prim_Due_Bucket2,
         0 Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         0 Prim_Past_Due_Bucket2,
         0 Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
             -1 * (NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)),
           ((-1 * (NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Available,
         0 Sec_Discount_Taken,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
             NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0),
          (((NVL(PS.Third_Disc_Amt_Available,0) - NVL(DISC.Discount_Taken,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         0 Sec_Due_Bucket2,
         0 Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         0 Sec_Past_Due_Bucket2,
         0 Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login,
         3 Unique_ID
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
         AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND    TEM.Third_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < TEM.Third_Discount_Date + 1
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Third_Discount_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PREP.Third_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < PREP.Third_Discount_Date + 1
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Third_Discount_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Discount_Taken, 0)) Discount_Taken,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND    PC.Third_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < PC.Third_Discount_Date + 1
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Third_Discount_Date) APC,
        (SELECT PC.Invoice_ID Invoice_ID,
                PC.Payment_Num Payment_Num,
                NVL(SUM(NVL(PC.Discount_Taken,0)),0) Discount_Taken
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_ID BETWEEN g_start_range and g_end_range
         AND    PC.Third_Discount_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date BETWEEN PC.Second_Discount_Date + 1
                                      AND     PC.Third_Discount_Date
         GROUP  BY  PC.Invoice_ID,
                    PC.Payment_Num) DISC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND    TRUNC(PS.Third_Discount_Date) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    PS.Invoice_ID  = DISC.Invoice_ID(+)
  AND    PS.Payment_Num = DISC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Discount records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END;



------------------------------------------------------------------
-- Procedure POPULATE_PS_DUE_ACTION
-- Purpose
--   This POPULATE_PS_DUE_ACTION routine inserts records into the
--   FII AP Payment Schedule summary table all the due actions.
------------------------------------------------------------------

PROCEDURE POPULATE_PS_DUE_ACTION IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PS_DUE_ACTION';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Inserting the Payment Schedules Due Action';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* Inserting the Due Date passed records into the summary table.
     We will insert only those payment schedules which have not been paid
     fully before the due date. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) use_nl(ps)  */
         TO_NUMBER(TO_CHAR(PS.Due_Date + 1,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(PS.Due_Date) + 1 Action_Date,
         'DUE' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                         - NVL(TEMP.WH_Tax_Amount,0)
                         - NVL(PP.Prepay_Amount,0) Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         0 Due_Bucket2,
         -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                               - NVL(TEMP.WH_Tax_Amount,0)
                               - NVL(PP.Prepay_Amount,0)) Due_Bucket3,
         0 Past_Due_Bucket1,
         0 Past_Due_Bucket2,
         PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                         - NVL(TEMP.WH_Tax_Amount,0)
                         - NVL(PP.Prepay_Amount,0) Past_Due_Bucket3,
         0 Amount_Remaining_B,
         ROUND(((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                 - NVL(TEMP.WH_Tax_Amount,0)
                                 - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         0 Due_Bucket2_B,
         ROUND((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                      - NVL(TEMP.WH_Tax_Amount,0)
                                      - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU  Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         0 Past_Due_Bucket2_B,
         ROUND(((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                 - NVL(TEMP.WH_Tax_Amount,0)
                                 - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency,
                 (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         0 Prim_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency,
                (-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0))),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau  Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         0 Prim_Past_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency,
                 (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency,
                 (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         0 Sec_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency,
                (-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0))),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         0 Sec_Past_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency,
                 (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
         AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID Invoice_ID,
                TEM.Payment_Num Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_TAX_T TEM
         WHERE  TEM.Invoice_ID BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND    TEM.Due_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date, g_sysdate)
         AND    TEM.Due_Date >= TEM.Entered_Date
         AND    TRUNC(TEM.Creation_Date) < TRUNC(TEM.Due_Date) + 1
         GROUP BY TEM.Invoice_ID,
                  TEM.Payment_Num,
                  TEM.Due_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID Invoice_ID,
                PREP.Payment_Num Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_ID BETWEEN g_start_range and g_end_range
         AND    PREP.Due_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date, g_sysdate)
         AND    PREP.Due_Date >= PREP.Entered_Date
         AND    TRUNC(PREP.Creation_Date) < TRUNC(PREP.Due_Date) + 1
         GROUP BY PREP.Invoice_ID,
                  PREP.Payment_Num,
                  PREP.Due_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND    PC.Due_Date + 1 BETWEEN g_start_date AND LEAST(g_end_date, g_sysdate)
         AND    PC.Due_Date >= PC.Entered_Date
         AND    PC.Invp_Creation_Date < PC.due_date + 1
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Due_Date) APC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND    TRUNC(PS.Due_Date) + 1 BETWEEN g_start_date
                            AND     LEAST(g_end_date,g_sysdate)
  AND    TRUNC(PS.Due_Date) >= AI.Entered_Date
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Due records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END;


------------------------------------------------------------------
-- Procedure POPULATE_PS_BUCKET_ACTION
-- Purpose
--   This POPULATE_PS_BUCKET_ACTION routine inserts records into the
--   FII AP Payment Schedule summary table all the due bucket actions.
------------------------------------------------------------------

PROCEDURE POPULATE_PS_BUCKET_ACTION IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PS_BUCKET_ACTION';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Inserting the Payment Schedules Due Bucket2 Action';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* Inserting the Due Bucket records into the summary table.
     We will insert only those payment schedules which have not been paid
     fully before the due bucket2. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) use_nl(ps)  */
         TO_NUMBER(TO_CHAR((PS.Due_Date - g_due_bucket2),'J')) Time_ID,
         1 Period_Type_ID,
         (TRUNC(PS.Due_Date) - g_due_bucket2) Action_Date,
         'DUE BUCKET' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                               - NVL(TEMP.WH_Tax_Amount,0)
                               - NVL(PP.Prepay_Amount,0)) Due_Bucket1,
         PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                         - NVL(TEMP.WH_Tax_Amount,0)
                         - NVL(PP.Prepay_Amount,0) Due_Bucket2,
         0 Due_Bucket3,
         0 Past_Due_Bucket1,
         0 Past_Due_Bucket2,
         0 Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         ROUND((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                      - NVL(TEMP.WH_Tax_Amount,0)
                                      - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU  Due_Bucket1_B,
         ROUND(((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                 - NVL(TEMP.WH_Tax_Amount,0)
                                 - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Due_Bucket2_B,
         0 Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         0 Past_Due_Bucket2_B,
         0 Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau  Prim_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Due_Bucket2,
         0 Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         0 Prim_Past_Due_Bucket2,
         0 Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket2,
         0 Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         0 Sec_Past_Due_Bucket2,
         0 Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
         AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND   (TEM.Due_Date - g_due_bucket2) BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < (TEM.Due_Date - g_due_bucket2)
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Due_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND   (PREP.Due_Date - g_due_bucket2) BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < (PREP.Due_Date - g_due_bucket2)
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Due_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND   (PC.Due_Date - g_due_bucket2) BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < (PC.Due_Date - g_due_bucket2)
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Due_Date) APC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND   (TRUNC(PS.Due_Date) - AI.Entered_Date) > g_due_bucket2
  AND   (TRUNC(PS.Due_Date) - g_due_bucket2) BETWEEN g_start_date
                                                 AND     LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Due Bucket2 records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  commit;

  g_state := 'Inserting the Payment Schedules Due Bucket3 Action';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* Inserting the Due Bucket records into the summary table.
     We will insert only those payment schedules which have not been paid
     fully before the due bucket3. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) use_nl(ps)  */
         TO_NUMBER(TO_CHAR((PS.Due_Date - g_due_bucket3),'J')) Time_ID,
         1 Period_Type_ID,
         (TRUNC(PS.Due_Date) - g_due_bucket3) Action_Date,
         'DUE BUCKET',
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                               - NVL(TEMP.WH_Tax_Amount,0)
                               - NVL(PP.Prepay_Amount,0)) Due_Bucket2,
         PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                         - NVL(TEMP.WH_Tax_Amount,0)
                         - NVL(PP.Prepay_Amount,0) Due_Bucket3,
         0 Past_Due_Bucket1,
         0 Past_Due_Bucket2,
         0 Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         ROUND((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                      - NVL(TEMP.WH_Tax_Amount,0)
                                      - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU  Due_Bucket2_B,
         ROUND(((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                 - NVL(TEMP.WH_Tax_Amount,0)
                                 - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         0 Past_Due_Bucket2_B,
         0 Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau  Prim_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         0 Prim_Past_Due_Bucket2,
         0 Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         0 Sec_Past_Due_Bucket2,
         0 Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
         AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND   (TEM.Due_Date - g_due_bucket3) BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < (TEM.Due_Date - g_due_bucket3)
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Due_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND   (PREP.Due_Date - g_due_bucket3) BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < (PREP.Due_Date - g_due_bucket3)
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Due_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND   (PC.Due_Date - g_due_bucket3) BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < (PC.Due_Date - g_due_bucket3)
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Due_Date) APC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND   (TRUNC(PS.Due_Date) - AI.Entered_Date) > g_due_bucket3
  AND   (TRUNC(PS.Due_Date) - g_due_bucket3) BETWEEN g_start_date
                                                 AND     LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Due Bucket3 records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END;


------------------------------------------------------------------
-- Procedure POPULATE_PS_PAST_BUCKET_ACTION
-- Purpose
--   This POPULATE_PS_PAST_BUCKET_ACTION routine inserts records into the
--   FII AP Payment Schedule summary table all the due bucket actions.
------------------------------------------------------------------

PROCEDURE POPULATE_PS_PAST_BUCKET_ACTION IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PS_PAST_BUCKET_ACTION';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Inserting the Payment Schedules Past Due Bucket2 Action';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* Inserting the Past Due Bucket records into the summary table.
     We will insert only those payment schedules which have not been paid
     fully before the past due bucket2. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) use_nl(ps)  */
         TO_NUMBER(TO_CHAR(PS.Due_Date + g_past_bucket3 + 1,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(PS.Due_Date) + g_past_bucket3 + 1 Action_Date,
         'PAST BUCKET' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         0 Due_Bucket2,
         0 Due_Bucket3,
         0 Past_Due_Bucket1,
         PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                         - NVL(TEMP.WH_Tax_Amount,0)
                         - NVL(PP.Prepay_Amount,0)  Past_Due_Bucket2,
         -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                               - NVL(TEMP.WH_Tax_Amount,0)
                               - NVL(PP.Prepay_Amount,0)) Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         0 Due_Bucket2_B,
         0 Due_Bucket3_B,
         0 Past_Due_Bucket1_B,
         ROUND(((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                 - NVL(TEMP.WH_Tax_Amount,0)
                                 - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Past_Due_Bucket2_B,
         ROUND((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                      - NVL(TEMP.WH_Tax_Amount,0)
                                      - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         0 Prim_Due_Bucket2,
         0 Prim_Due_Bucket3,
         0 Prim_Past_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         0 Sec_Due_Bucket2,
         0 Sec_Due_Bucket3,
         0 Sec_Past_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket2,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
         AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND   (TEM.Due_Date + g_past_bucket3) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < (TEM.Due_Date + g_past_bucket3) + 1
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Due_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND   (PREP.Due_Date + g_past_bucket3) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < (PREP.Due_Date + g_past_bucket3) + 1
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Due_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND   (PC.Due_Date + g_past_bucket3) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < (PC.Due_Date + g_past_bucket3) + 1
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Due_Date) APC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND   (TRUNC(PS.Due_Date) + g_past_bucket3 + 1) > AI.Entered_Date
  AND   (TRUNC(PS.Due_Date) + g_past_bucket3) + 1 BETWEEN g_start_date
                                                  AND     LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID  = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID  = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID  = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Past Due Bucket2 records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;

  commit;

  g_state := 'Inserting the Payment Schedules Past Due Bucket1 Action';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  /* Inserting the Past Due Bucket records into the summary table.
     We will insert only those payment schedules which have not been paid
     fully before the past due bucket2. This check is done by comparing
     the gross amount with the payment, prepayment and withheld amount */

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ leading(ai) index(AI,FII_AP_INVOICE_B_U1) use_nl(ps)  */
         TO_NUMBER(TO_CHAR(PS.Due_Date + g_past_bucket2 + 1,'J')) Time_ID,
         1 Period_Type_ID,
         TRUNC(PS.Due_Date) + g_past_bucket2 + 1 Action_Date,
         'PAST BUCKET' Action,
         g_seq_id Update_Sequence,
         AI.Org_ID Org_ID,
         AI.Supplier_ID Supplier_ID,
         AI.Invoice_ID Invoice_ID,
         AI.Base_Currency_Code Base_Currency_Code,
         AI.Invoice_Date Trx_Date,
         PS.Payment_Num Payment_Num,
         TRUNC(PS.Due_Date) Due_Date,
         PS.Created_By Created_By,
         0 Amount_Remaining,
         0 Past_Due_Amount,
         0 Discount_Available,
         0 Discount_Taken,
         0 Discount_Lost,
         0 Payment_Amount,
         0 On_Time_Payment_Amt,
         0 Late_Payment_Amt,
         0 No_Days_Late,
         0 Due_Bucket1,
         0 Due_Bucket2,
         0 Due_Bucket3,
         PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                         - NVL(TEMP.WH_Tax_Amount,0)
                         - NVL(PP.Prepay_Amount,0) Past_Due_Bucket1,
         -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                               - NVL(TEMP.WH_Tax_Amount,0)
                               - NVL(PP.Prepay_Amount,0)) Past_Due_Bucket2,
         0 Past_Due_Bucket3,
         0 Amount_Remaining_B,
         0 Past_Due_Amount_B,
         0 Discount_Available_B,
         0 Discount_Taken_B,
         0 Discount_Lost_B,
         0 Payment_Amount_B,
         0 On_Time_Payment_Amt_B,
         0 Late_Payment_Amt_B,
         0 Due_Bucket1_B,
         0 Due_Bucket2_B,
         0 Due_Bucket3_B,
         ROUND(((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                 - NVL(TEMP.WH_Tax_Amount,0)
                                 - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Past_Due_Bucket1_B,
         ROUND((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                      - NVL(TEMP.WH_Tax_Amount,0)
                                      - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
                       / Functional_MAU) * Functional_MAU Past_Due_Bucket2_B,
         0 Past_Due_Bucket3_B,
         0 Prim_Amount_Remaining,
         0 Prim_Past_Due_Amount,
         0 Prim_Discount_Available,
         0 Prim_Discount_Taken,
         0 Prim_Discount_Lost,
         0 Prim_Payment_Amount,
         0 Prim_On_Time_Payment_Amt,
         0 Prim_Late_Payment_Amt,
         0 Prim_Due_Bucket1,
         0 Prim_Due_Bucket2,
         0 Prim_Due_Bucket3,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_prim_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Prim_Conversion_Rate)) / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket2,
         0 Prim_Past_Due_Bucket3,
         0 Sec_Amount_Remaining,
         0 Sec_Past_Due_Amount,
         0 Sec_Discount_Available,
         0 Sec_Discount_Taken,
         0 Sec_Discount_Lost,
         0 Sec_Payment_Amount,
         0 Sec_On_Time_Payment_Amt,
         0 Sec_Late_Payment_Amt,
         0 Sec_Due_Bucket1,
         0 Sec_Due_Bucket2,
         0 Sec_Due_Bucket3,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                  PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0),
               (((PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                  - NVL(TEMP.WH_Tax_Amount,0)
                                  - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket1,
         ROUND(DECODE(AI.Invoice_Currency_Code, g_sec_currency,
                 -1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)),
               ((-1 * (PS.Gross_Amount - NVL(APC.Payment_Amount,0)
                                       - NVL(TEMP.WH_Tax_Amount,0)
                                       - NVL(PP.Prepay_Amount,0)) * Conversion_Rate)
             * RATES.Sec_Conversion_Rate)) / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket2,
         0 Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM   FII_AP_Invoice_B AI,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES,
         AP_Payment_Schedules_All PS,
        (SELECT /*+ index(TEM,FII_AP_WH_TAX_T_N1) */ TEM.Invoice_ID,
                TEM.Payment_Num,
                SUM(NVL(TEM.WH_Tax_Amount, 0)) WH_Tax_Amount
         FROM   FII_AP_WH_Tax_T TEM
         WHERE  TEM.Invoice_id BETWEEN g_start_range and g_end_range
         AND    TEM.Invoice_Type <> 'PREPAYMENT'
         AND   (TEM.Due_Date + g_past_bucket2) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    TEM.Creation_Date < (TEM.Due_Date + g_past_bucket2) + 1
         GROUP  BY TEM.Invoice_ID,
                   TEM.Payment_Num,
                   TEM.Due_Date) TEMP,
        (SELECT /*+ index(prep,FII_AP_PREPAY_T_N1) */ PREP.Invoice_ID,
                PREP.Payment_Num,
                SUM(NVL(PREP.Prepay_Amount, 0)) Prepay_Amount
         FROM   FII_AP_Prepay_T PREP
         WHERE  PREP.Invoice_id BETWEEN g_start_range and g_end_range
         AND   (PREP.Due_Date + g_past_bucket2) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PREP.Creation_Date < (PREP.Due_Date + g_past_bucket2) + 1
         GROUP  BY PREP.Invoice_ID,
                   PREP.Payment_Num,
                   PREP.Due_Date) PP,
        (SELECT /*+ index(PC,FII_AP_PAY_CHK_STG_N1) */ PC.Invoice_ID,
                PC.Payment_Num,
                SUM(NVL(PC.Payment_Amount, 0)) Payment_Amount
         FROM   FII_AP_PAY_CHK_STG PC
         WHERE  PC.Invoice_id BETWEEN g_start_range and g_end_range
         AND    PC.Invoice_Type <> 'PREPAYMENT'
         AND   (PC.Due_Date + g_past_bucket2) + 1 BETWEEN g_start_date AND LEAST(g_end_date,g_sysdate)
         AND    PC.Invp_Creation_Date < (PC.Due_Date + g_past_bucket2) + 1
         GROUP  BY PC.Invoice_ID,
                   PC.Payment_Num,
                   PC.Due_Date) APC
  WHERE  PS.Invoice_ID = AI.Invoice_ID
  AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AI.Cancel_Date IS NULL
  AND    FRATES.To_Currency   = AI.Base_Currency_Code
  AND    FRATES.From_Currency = AI.Payment_Currency_Code
  AND    FRATES.Trx_Date      = AI.Exchange_Date
  AND    DECODE(AI.Exchange_Rate_Type,'User', AI.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = AI.Exchange_Rate_Type
  AND    RATES.Functional_Currency = AI.Base_Currency_Code
  AND    RATES.Trx_Date            = AI.Invoice_Date
  AND   (TRUNC(PS.Due_Date) + g_past_bucket2 + 1) > AI.Entered_Date
  AND   (TRUNC(PS.Due_Date) + g_past_bucket2) + 1 BETWEEN g_start_date
                                             AND     LEAST(g_end_date,g_sysdate)
  AND    PS.Invoice_ID = TEMP.Invoice_ID(+)
  AND    PS.Payment_Num = TEMP.Payment_Num(+)
  AND    PS.Invoice_ID = PP.Invoice_ID(+)
  AND    PS.Payment_Num = PP.Payment_Num(+)
  AND    PS.Invoice_ID = APC.Invoice_ID(+)
  AND    PS.Payment_Num = APC.Payment_Num(+)
  AND    ABS(NVL(APC.Payment_Amount,0) + NVL(TEMP.WH_Tax_Amount,0)
                                       + NVL(PP.Prepay_Amount,0)) < ABS(PS.Gross_Amount);


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Past Due Bucket1 records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  commit;


EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END;


------------------------------------------------------------------
-- Procedure POPULATE_PAY_SCHED_SUM
-- Purpose
--   This POPULATE_PAY_SCHED_SUM routine inserts records into the
--   FII AP Invoice Base summary table.
------------------------------------------------------------------

PROCEDURE POPULATE_PAY_SCHED_SUM(
                                 P_Start_Range     IN   NUMBER,
                                 P_End_Range       IN   NUMBER) IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PAY_SCHED_SUM';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_start_range := p_start_range;
  g_end_range   := p_end_range;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('g_start_date is '|| g_start_date);
    FII_UTIL.put_line('g_end_date is '|| g_end_date);
    FII_UTIL.put_line('g_start_range is '|| g_start_range);
    FII_UTIL.put_line('g_end_range is '|| g_end_range);
  end if;

  SELECT fii_ap_pay_sched_b_s.nextval
  INTO   g_seq_id
  FROM   dual;

  g_state := 'Populating FII_AP_PAY_SCHED_B FROM AP_PAYMENT_SCHEDULES_ALL table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Populating Payment Schedules Creation records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.put_timestamp('Start Timestamp');
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT INTO FII_AP_PAY_SCHED_B b
        (Time_ID,
         Period_Type_ID,
         Action_Date,
         Action,
         Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Trx_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         Amount_Remaining_B,
         Past_Due_Amount_B,
         Discount_Available_B,
         Discount_Taken_B,
         Discount_Lost_B,
         Payment_Amount_B,
         On_Time_Payment_Amt_B,
         Late_Payment_Amt_B,
         Due_Bucket1_B,
         Due_Bucket2_B,
         Due_Bucket3_B,
         Past_Due_Bucket1_B,
         Past_Due_Bucket2_B,
         Past_Due_Bucket3_B,
         Prim_Amount_Remaining,
         Prim_Past_Due_Amount,
         Prim_Discount_Available,
         Prim_Discount_Taken,
         Prim_Discount_Lost,
         Prim_Payment_Amount,
         Prim_On_time_Payment_Amt,
         Prim_Late_Payment_Amt,
         Prim_Due_Bucket1,
         Prim_Due_Bucket2,
         Prim_Due_Bucket3,
         Prim_Past_Due_Bucket1,
         Prim_Past_Due_Bucket2,
         Prim_Past_Due_Bucket3,
         Sec_Amount_Remaining,
         Sec_Past_Due_Amount,
         Sec_Discount_Available,
         Sec_Discount_Taken,
         Sec_Discount_Lost,
         Sec_Payment_Amount,
         Sec_On_time_Payment_Amt,
         Sec_Late_Payment_Amt,
         Sec_Due_Bucket1,
         Sec_Due_Bucket2,
         Sec_Due_Bucket3,
         Sec_Past_Due_Bucket1,
         Sec_Past_Due_Bucket2,
         Sec_Past_Due_Bucket3,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT /*+ no_merge ordered index(PS,FII_AP_INVOICE_B_U1) index(RATES) use_nl(AI) */
         TO_NUMBER(TO_CHAR(Action_Date,'J')) Time_ID,
         1 Period_Type_ID,
         Action_Date,
         'CREATION' Action,
         g_seq_id Update_Sequence,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Base_Currency_Code,
         Invoice_Date,
         Payment_Num,
         Due_Date,
         Created_By,
         Amount_Remaining,
         Past_Due_Amount,
         Discount_Available,
         Discount_Taken,
         Discount_Lost,
         Payment_Amount,
         On_Time_Payment_Amt,
         Late_Payment_Amt,
         No_Days_Late,
         Due_Bucket1,
         Due_Bucket2,
         Due_Bucket3,
         Past_Due_Bucket1,
         Past_Due_Bucket2,
         Past_Due_Bucket3,
         ROUND((Amount_Remaining * Conversion_Rate) / Functional_MAU) * Functional_MAU Amount_Remaining_B,
         ROUND((Past_Due_Amount * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Amount_B,
         ROUND((Discount_Available * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Available_B,
         ROUND((Discount_Taken * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Taken_B,
         ROUND((Discount_Lost * Conversion_Rate) / Functional_MAU) * Functional_MAU Discount_Lost_B,
         ROUND((Payment_Amount * Conversion_Rate) / Functional_MAU) * Functional_MAU Payment_Amount_B,
         ROUND((On_Time_Payment_Amt * Conversion_Rate) / Functional_MAU) * Functional_MAU On_Time_Payment_Amt_B,
         ROUND((Late_Payment_Amt * Conversion_Rate) / Functional_MAU) * Functional_MAU Late_Payment_Amt_B,
         ROUND((Due_Bucket1 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket1_B,
         ROUND((Due_Bucket2 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket2_B,
         ROUND((Due_Bucket3 * Conversion_Rate) / Functional_MAU) * Functional_MAU Due_Bucket3_B,
         ROUND((Past_Due_Bucket1 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket1_B,
         ROUND((Past_Due_Bucket2 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket2_B,
         ROUND((Past_Due_Bucket3 * Conversion_Rate) / Functional_MAU) * Functional_MAU Past_Due_Bucket3_B,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Amount_Remaining,
                          ((Amount_Remaining * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Amount_Remaining,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Amount,
                          ((Past_Due_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Discount_Available,
                          ((Discount_Available * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Available,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Discount_Taken,
                          ((Discount_Taken * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Taken,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Discount_Lost,
                          ((Discount_Lost * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Discount_Lost,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Payment_Amount,
                          ((Payment_Amount * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Payment_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, On_Time_Payment_Amt,
                          ((On_Time_Payment_Amt * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_On_Time_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Late_Payment_Amt,
                          ((Late_Payment_Amt * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Late_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Due_Bucket1,
                          ((Due_Bucket1 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Due_Bucket2,
                          ((Due_Bucket2 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Due_Bucket3,
                          ((Due_Bucket3 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Due_Bucket3,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket1,
                          ((Past_Due_Bucket1 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket2,
                          ((Past_Due_Bucket2 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_prim_currency, Past_Due_Bucket3,
                          ((Past_Due_Bucket3 * Conversion_Rate) * RATES.Prim_Conversion_Rate))
                          / g_primary_mau) * g_primary_mau Prim_Past_Due_Bucket3,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Amount_Remaining,
                          ((Amount_Remaining * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Amount_Remaining,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Amount,
                          ((Past_Due_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Discount_Available,
                          ((Discount_Available * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Available,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Discount_Taken,
                          ((Discount_Taken * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Taken,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Discount_Lost,
                          ((Discount_Lost * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Discount_Lost,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Payment_Amount,
                          ((Payment_Amount * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Payment_Amount,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, On_Time_Payment_Amt,
                          ((On_Time_Payment_Amt * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_On_Time_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Late_Payment_Amt,
                          ((Late_Payment_Amt * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Late_Payment_Amt,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Due_Bucket1,
                          ((Due_Bucket1 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Due_Bucket2,
                          ((Due_Bucket2 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Due_Bucket3,
                          ((Due_Bucket3 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Due_Bucket3,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket1,
                          ((Past_Due_Bucket1 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket1,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket2,
                          ((Past_Due_Bucket2 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket2,
         ROUND(DECODE(Invoice_Currency_Code, g_sec_currency, Past_Due_Bucket3,
                          ((Past_Due_Bucket3 * Conversion_Rate) * RATES.Sec_Conversion_Rate))
                          / g_secondary_mau) * g_secondary_mau Sec_Past_Due_Bucket3,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM
        (SELECT AI.Entered_Date Action_Date,
                AI.Org_Id Org_ID,
                AI.Supplier_ID Supplier_ID,
                AI.Invoice_Id Invoice_ID,
                AI.Base_Currency_Code Base_Currency_Code,
                AI.Invoice_Date Invoice_Date,
                AI.Invoice_Currency_Code Invoice_Currency_Code,
                AI.Payment_Currency_Code Payment_Currency_Code,
                AI.Exchange_Rate Exchange_Rate,
                AI.Exchange_Date Exchange_Date,
                AI.Exchange_Rate_Type Exchange_Rate_Type,
                PS.Payment_Num Payment_Num,
                TRUNC(PS.Due_Date) Due_Date,
                PS.Created_By Created_By,
                PS.Gross_Amount Amount_Remaining,
                DECODE(SIGN(TRUNC(PS.Due_Date) - AI.Entered_Date), -1,
                           PS.Gross_Amount, 0) Past_Due_Amount,
                NVL(PS.Discount_Amount_Available,0) Discount_Available,
                0 Discount_Taken,
                0 Discount_Lost,
                0 Payment_Amount,
                0 On_Time_Payment_Amt,
                0 Late_Payment_Amt,
                0 No_Days_Late,
                CASE
                  WHEN (TRUNC(PS.Due_Date) - AI.Entered_Date) >= g_due_bucket1
                        THEN PS.Gross_Amount
                  ELSE  0
                END Due_Bucket1,
                CASE
                  WHEN (TRUNC(PS.Due_Date) - AI.Entered_Date) <= g_due_bucket2
                   AND (TRUNC(PS.Due_Date) - AI.Entered_Date) >  g_due_bucket3
                        THEN PS.Gross_Amount
                  ELSE  0
                END Due_Bucket2,
                CASE
                  WHEN (TRUNC(PS.Due_Date) - AI.Entered_Date) <= g_due_bucket3
                   AND (TRUNC(PS.Due_Date) - AI.Entered_Date) >=  0
                        THEN PS.Gross_Amount
                  ELSE  0
                END Due_Bucket3,
                CASE
                  WHEN (AI.Entered_Date - TRUNC(PS.Due_Date)) >= g_past_bucket1
                        THEN PS.Gross_Amount
                  ELSE  0
                END Past_Due_Bucket1,
                CASE
                  WHEN (AI.Entered_Date - TRUNC(PS.Due_Date)) <= g_past_bucket2
                   AND (AI.Entered_Date - TRUNC(PS.Due_Date)) >  g_past_bucket3
                        THEN PS.Gross_Amount
                  ELSE  0
                END Past_Due_Bucket2,
                CASE
                  WHEN (AI.Entered_Date - TRUNC(PS.Due_Date)) <= g_past_bucket3
                   AND (AI.Entered_Date - TRUNC(PS.Due_Date)) > 0
                        THEN PS.Gross_Amount
                  ELSE  0
                END Past_Due_Bucket3
         FROM   AP_Payment_Schedules_All PS,
                FII_AP_Invoice_B AI
         WHERE  PS.Invoice_ID = AI.Invoice_ID
         AND    AI.Invoice_ID BETWEEN g_start_range and g_end_range
         AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
         AND    AI.Cancel_Date IS NULL) PSUM,
         FII_AP_PS_Rates_Temp   RATES,
         FII_AP_Func_Rates_Temp FRATES
  WHERE  FRATES.To_Currency   = PSUM.Base_Currency_Code
  AND    FRATES.From_Currency = PSUM.Payment_Currency_Code
  AND    FRATES.Trx_Date      = PSUM.Exchange_Date
  AND    DECODE(PSUM.Exchange_Rate_Type,'User', PSUM.Exchange_Rate,1) =
                 DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND    FRATES.Conversion_Type    = PSUM.Exchange_Rate_Type
  AND    RATES.Functional_Currency = PSUM.Base_Currency_Code
  AND    RATES.Trx_Date            = PSUM.Invoice_Date;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' ||SQL%ROWCOUNT|| ' Creation records into FII_AP_PAY_SCHED_B');
     FII_UTIL.put_timestamp('End Timestamp');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  COMMIT;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Calling procedure POPULATE_PS_DISC_ACTION');
     FII_UTIL.put_line('');
  end if;

  POPULATE_PS_DISCOUNT_ACTION;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Calling procedure POPULATE_PS_PAYMENT_ACTION');
     FII_UTIL.put_line('');
  end if;

  POPULATE_PS_PAYMENT_ACTION;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Calling procedure POPULATE_PS_DUE_ACTION');
     FII_UTIL.put_line('');
  end if;

  POPULATE_PS_DUE_ACTION;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Calling procedure POPULATE_PS_BUCKET_ACTION');
     FII_UTIL.put_line('');
  end if;

  POPULATE_PS_BUCKET_ACTION;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Calling procedure POPULATE_PS_PAST_BUCKET_ACTION');
     FII_UTIL.put_line('');
  end if;

  POPULATE_PS_PAST_BUCKET_ACTION;

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END;


------------------------------------------------------------------
-- Procedure POPULATE_PS_BUCKET_COUNT
-- Purpose
--   This POPULATE_PS_BUCKET_COUNT routine inserts records into the
--   FII AP Bucket Count table.
--
--   This procedure is divided into four steps.
--
--
--
------------------------------------------------------------------

PROCEDURE POPULATE_PS_BUCKET_COUNT IS

BEGIN

  g_state := 'Inside the procedure POPULATE_PS_BUCKET_COUNT';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

/* **************************************************************************
Steps to populate FII_AP_AGING_BKTS_B and FII_AP_DUE_COUNTS_B:

1.  To determine the action_date that a payment schedule enters
    and exits a bucket, if it enters a bucket at all, we need to know
    the creation date, due date,and fully paid date of each payment
    schedule.  The subquery Bucket_Calcs stores this information.

2.  Each payment schedule can have at most 12 action dates.  Date 1 is
    when a payment schedule enters bucket 1, date 2 is when a payment
    schedule exits bucket 1, date 3 is when a payment schedule enters
    bucket 2, etc.  The subquery TMP stores the marker 1-12.

3.  We join Bucket_Calcs and TMP to calculate up to 12 action dates.
    Depending on certain conditions, the entry date of a bucket will
    be either the creation date, the date a payment schedule moves
    buckets, or null.  The exit date of a bucket will be either the
    fully paid date, the date a payment schedule moves buckets, or
    null.  We also have a variable for each bucket.  For entry into a
    bucket we store a +1, for exit from a bucket we store a -1.  We do
    not keep rows with a null date.  This subquery is essentially
    FII_AP_AGING_BKTS_B at the payment schedule level.

4.  To populate FII_AP_AGING_BKTS_B at the invoice level, group by
    invoice_id and action_date (SDate).  Then for each date in order
    from earliest to latest date, keep a cumulative sum for each
    bucket.  For example, let's say an invoice has two payment
    schedules.  The first goes into bucket 1 on 01-01-2004, the second
    goes into bucket 1 on 01-01-2004, the first exits bucket 1 on
    01-15-2004, the second exits bucket 1 on 01-31-2004:

    SDate            SUM(B1)   SB1
    01-01-2004        2         2
    01-15-2004       -1         1
    01-31-2004       -1         0

    To populate FII_AP_DUE_COUNTS_B, group by invoice_id and
    action_date and keep a cumulative sum for all due buckets and all
    past due buckets.

5.  The most outer subquery looks at the cumulative sum of the
    previous subquery to determine when an invoice, not a payment
    schedule, enters and exits a bucket.  If the cumulative sum is
    increased from 0, then the invoice enters the bucket on that
    date.  If the cumulative sum is decreased to 0, then the invoice
    exits the bucket on that date.  In our example:

    SDate            Due_Bucket1_Cnt
    01-01-2004            1
    01-15-2004            0
    01-31-2004           -1

6.  Populate FII_AP_AGING_BKTS_B with those records with non-zero Due
    Bucket or Past Due Bucket Counts.  Populate FII_AP_DUE_COUNTS_B
    with those records with non-zero Due or Past Due Counts.
************************************************************************** */

  g_state := 'Deleting records from FII_AP_INV_BUCKETS that are already existing';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;


  /* For Initial Load we will truncate the data in the count table
     and re-populate this table */
  TRUNCATE_TABLE('MLOG$_FII_AP_AGING_BKTS_B');
  TRUNCATE_TABLE('MLOG$_FII_AP_DUE_COUNTS_B');

  TRUNCATE_TABLE('FII_AP_AGING_BKTS_B');
  TRUNCATE_TABLE('FII_AP_DUE_COUNTS_B');

  g_state := 'Populating FII_AP_AGING_BKTS_B and FII_AP_DUE_COUNTS_B table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;


  INSERT /*+ append parallel(fii_ap_aging_bkts_b) parallel(fii_ap_due_counts_b) */ ALL
  WHEN (   Due_Bucket1_Cnt <> 0
        OR Due_Bucket2_Cnt <> 0
        OR Due_Bucket3_Cnt <> 0
        OR Past_Due_Bucket1_Cnt <> 0
        OR Past_Due_Bucket2_Cnt <> 0
        OR Past_Due_Bucket3_Cnt <> 0)
  THEN INTO FII_AP_AGING_BKTS_B(
	Time_ID,
	Period_Type_ID,
	Org_ID,
	Supplier_ID,
	Invoice_ID,
	Action_Date,
	Due_Bucket1_Cnt,
	Due_Bucket2_Cnt,
	due_bucket3_Cnt,
	Past_Due_Bucket3_Cnt,
	Past_Due_Bucket2_Cnt,
	Past_Due_Bucket1_Cnt,
	Created_By,
	Creation_Date,
	Last_Updated_By,
	Last_Update_Date,
	Last_Update_Login)
  VALUES (
	TO_NUMBER(TO_CHAR(Action_Date, 'J')),
	1,
	Org_ID,
	Supplier_ID,
	Invoice_ID,
	Action_Date,
	Due_Bucket1_Cnt,
	Due_Bucket2_Cnt,
	Due_Bucket3_Cnt,
	Past_Due_Bucket3_Cnt,
	Past_Due_Bucket2_Cnt,
	Past_Due_Bucket1_Cnt,
	g_fii_user_id,
	sysdate,
	g_fii_user_id,
	sysdate,
	g_fii_login_id)
  WHEN (   Due_Cnt <> 0
        OR Past_Due_Cnt <> 0)
  THEN INTO FII_AP_DUE_COUNTS_B (
	Time_ID,
	Period_Type_ID,
	Org_ID,
	Supplier_ID,
	Invoice_ID,
	Action_Date,
	Due_Cnt,
	Past_Due_Cnt,
	Created_By,
	Creation_Date,
	Last_Updated_By,
	Last_Update_Date,
	Last_Update_Login)
  VALUES (
	TO_NUMBER(TO_CHAR(Action_Date, 'J')),
	1,
	Org_ID,
	Supplier_ID,
	Invoice_ID,
	Action_Date,
	Due_Cnt,
	Past_Due_Cnt,
	g_fii_user_id,
	sysdate,
	g_fii_user_id,
	sysdate,
	g_fii_login_id)
  SELECT Org_ID,
         Supplier_ID,
         Invoice_ID,
         SDate Action_Date,
         CASE WHEN SB1 > 0
              AND NVL(lag(SB1) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) = 0
              THEN 1
              WHEN SB1 = 0
              AND NVL(lag(SB1) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) > 0 then -1
              ELSE 0
         END Due_Bucket1_Cnt,
         CASE WHEN SB2 > 0
              AND NVL(lag(SB2) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) = 0
              THEN 1
              WHEN SB2 = 0
              AND NVL(lag(SB2) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Due_Bucket2_Cnt,
         CASE WHEN SB3 > 0
              AND NVL(lag(SB3) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) = 0
              THEN 1
              WHEN SB3 = 0
              AND NVL(lag(SB3) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Due_Bucket3_Cnt,
         CASE WHEN SB4 > 0
              AND NVL(lag(SB4) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) = 0
              THEN 1
              WHEN SB4 = 0
              AND NVL(lag(SB4) OVER(PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                    ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Past_Due_Bucket3_Cnt,
         CASE WHEN SB5 > 0
              AND NVL(lag(SB5) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) = 0
              THEN 1
              WHEN SB5 = 0
              AND NVL(lag(SB5) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Past_Due_Bucket2_Cnt,
         CASE WHEN SB6 > 0
              AND NVL(lag(SB6) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) = 0
              THEN 1
              WHEN SB6 = 0
              AND NVL(lag(SB6) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                     ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Past_Due_Bucket1_Cnt,
         CASE WHEN D > 0
              AND NVL(lag(D) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                   ORDER BY SDate), 0) = 0
              THEN 1
              WHEN D = 0
              AND NVL(lag(D) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                   ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Due_Cnt,
         CASE WHEN PD > 0
              AND nvl(lag(PD) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                    ORDER BY SDate), 0) = 0
              THEN 1
              WHEN PD = 0
              AND NVL(lag(PD) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                    ORDER BY SDate), 0) > 0
              THEN -1
              ELSE 0
         END Past_Due_Cnt
  FROM (SELECT Org_ID,
               Supplier_ID,
               Invoice_ID,
               SDate,
               SUM(SUM(B1)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                  ORDER BY SDate
                                  ROWS UNBOUNDED PRECEDING) SB1,
               SUM(SUM(B2)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                  ORDER BY SDate
                                  ROWS UNBOUNDED PRECEDING) SB2,
               SUM(SUM(B3)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                  ORDER BY SDate
                                  ROWS UNBOUNDED PRECEDING) SB3,
               SUM(SUM(B4)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                  ORDER BY SDate
                                  ROWS UNBOUNDED PRECEDING) SB4,
               SUM(SUM(B5)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                  ORDER BY SDate
                                  ROWS UNBOUNDED PRECEDING) SB5,
               SUM(SUM(B6)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                  ORDER BY SDate
                                  ROWS UNBOUNDED PRECEDING) SB6,
               SUM(SUM(B1+B2+B3)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                        ORDER BY SDate
                                        ROWS UNBOUNDED PRECEDING) D,
               SUM(SUM(B4+B5+B6)) OVER (PARTITION BY Org_ID, Supplier_ID, Invoice_ID
                                        ORDER BY SDate
                                        ROWS UNBOUNDED PRECEDING) PD
        FROM (
              SELECT Org_ID,
                     Supplier_ID,
                     Invoice_ID,
                     Payment_Num,
                     CASE TMP.Marker
                          WHEN 1 THEN CASE WHEN Creation_Date < Due_Date-g_due_bucket2 THEN Creation_Date END
                          WHEN 2 THEN CASE WHEN Creation_Date < Due_Date-g_due_bucket2
                                           AND nvl(Fully_Paid_Date, Due_Date-g_due_bucket2) <= trunc(sysdate)
                                           THEN least(nvl(Fully_Paid_Date, Due_Date-g_due_bucket2), Due_Date-g_due_bucket2) END
                          WHEN 3 THEN CASE WHEN Creation_Date < Due_Date-g_due_bucket3
                                           AND nvl(Fully_Paid_Date, Due_Date-g_due_bucket2) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date-g_due_bucket3) >= Due_Date-g_due_bucket2
                                           THEN greatest(Creation_Date, Due_Date-g_due_bucket2) END
                          WHEN 4 THEN CASE WHEN Creation_Date < Due_Date-g_due_bucket3
                                           AND nvl(Fully_Paid_Date, Due_Date-g_due_bucket3) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date-g_due_bucket3) >= Due_Date-g_due_bucket2
                                           THEN least(nvl(Fully_Paid_Date, Due_Date-g_due_bucket3), Due_Date-g_due_bucket3) END
                          WHEN 5 THEN CASE WHEN Creation_Date < Due_Date+1
                                           AND nvl(Fully_Paid_Date, Due_Date-g_due_bucket3) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date) >= Due_Date-g_due_bucket3
                                           THEN greatest(Creation_Date, Due_Date-g_due_bucket3) END
                          WHEN 6 THEN CASE WHEN Creation_Date < Due_Date+1
                                           AND nvl(Fully_Paid_Date, Due_Date+1) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date) >= Due_Date-g_due_bucket3
                                           THEN least(nvl(Fully_Paid_Date, Due_Date+1), Due_Date+1) END
                          WHEN 7 THEN CASE WHEN Creation_Date <= Due_Date+g_past_bucket3
                                           AND nvl(Fully_Paid_Date, Due_Date+1) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket3) >= Due_Date+1
                                           THEN greatest(Creation_Date, Due_Date+1) END
                          WHEN 8 THEN CASE WHEN Creation_Date <= Due_Date+g_past_bucket3
                                           AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket3+1) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket3) >= Due_Date+1
                                           THEN least(nvl(Fully_Paid_Date, Due_Date+g_past_bucket3+1), Due_Date+g_past_bucket3+1) END
                          WHEN 9 THEN CASE WHEN Creation_Date <= Due_Date+g_past_bucket2
                                           AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket3+1) <= trunc(sysdate)
                                           AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket2) >= Due_Date+g_past_bucket3+1
                                           THEN greatest(Creation_Date, Due_Date+g_past_bucket3+1) END
                          WHEN 10 THEN CASE WHEN Creation_Date <= Due_Date+g_past_bucket2
                                            AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket1) <= trunc(sysdate)
                                            AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket2) >= Due_Date+g_past_bucket3+1
                                            THEN least(nvl(Fully_Paid_Date, Due_Date+g_past_bucket1), Due_Date+g_past_bucket1) END
                          WHEN 11 THEN CASE WHEN nvl(Fully_Paid_Date, Due_Date+g_past_bucket1) >= Due_Date+g_past_bucket1
                                            AND nvl(Fully_Paid_Date, Due_Date+g_past_bucket1) <= trunc(sysdate)
                                            THEN greatest(Creation_Date, Due_Date+g_past_bucket1) END
                          WHEN 12 THEN CASE WHEN nvl(Fully_Paid_Date, Due_Date+g_past_bucket1) >= Due_Date+g_past_bucket1
                                            THEN Fully_Paid_Date END
	             END SDate,
	             decode(TMP.Marker, 1, 1, 2, -1, 0) b1,
	             decode(TMP.Marker, 3, 1, 4, -1, 0) b2,
                     decode(TMP.Marker, 5, 1, 6, -1, 0) b3,
                     decode(TMP.Marker, 7, 1, 8, -1, 0) b4,
                     decode(TMP.Marker, 9, 1, 10, -1, 0) b5,
                     decode(TMP.Marker, 11, 1, 12, -1, 0) b6
              FROM (SELECT /*+ parallel(ps) parallel(ai) */
	                   AI.Org_ID,
                           AI.Supplier_ID,
                           PS.Invoice_ID,
                           PS.Payment_Num,
                           AI.Entered_Date Creation_Date,
                           trunc(PS.Due_Date) Due_Date,
                           CASE WHEN nvl(PAY.Payment_Amount, 0) + nvl(TEMP.WH_Tax_Amount, 0)
                                     + nvl(PP.Prepay_Amount, 0) = PS.Gross_Amount
                                THEN CASE WHEN PAY.Payment_Date is not null
                                          AND PP.Payment_Date is not null
                                          THEN greatest(PAY.Payment_Date, PP.Payment_Date)
                                          ELSE nvl(PAY.Payment_Date, PP.Payment_Date) END
	                        ELSE null END Fully_Paid_Date
                    FROM AP_Payment_Schedules_All PS,
	                 FII_AP_INVOICE_B AI,
	                (SELECT /*+ parallel(aip) */ AIP.Invoice_ID,
                                AIP.Payment_Num,
                                sum(AIP.Amount + nvl(AIP.Discount_Taken, 0)) Payment_Amount,
                                trunc(max(AIP.Creation_Date)) Payment_Date
                         FROM AP_Invoice_Payments_ALL AIP
               	         GROUP BY AIP.Invoice_id, AIP.Payment_Num) PAY,
                        (SELECT /*+ parallel(t) */ Invoice_ID,
                                Payment_Num,
                                sum(WH_Tax_Amount) WH_Tax_Amount
                         FROM FII_AP_WH_Tax_T t
                         GROUP BY Invoice_ID, Payment_Num) TEMP,
                        (SELECT /*+ parallel(p) */ Invoice_ID,
                                Payment_Num,
                                sum(Prepay_Amount) Prepay_Amount,
                                trunc(max(Creation_Date)) Payment_Date
                         FROM FII_AP_Prepay_T p
                         GROUP BY Invoice_ID, Payment_Num) PP
                    WHERE AI.Invoice_ID = PS.Invoice_ID
                    AND AI.Invoice_Type NOT IN ('PREPAYMENT')
                    AND AI.Cancel_Date IS NULL
                    AND PS.Invoice_ID = PAY.Invoice_ID (+)
                    AND PS.Payment_num = PAY.Payment_Num (+)
                    AND PS.Invoice_ID = TEMP.Invoice_ID (+)
                    AND PS.Payment_Num = TEMP.Payment_Num (+)
                    AND PS.Invoice_ID = PP.Invoice_ID (+)
                    AND PS.Payment_Num = PP.Payment_Num (+)) Bucket_Calcs,
                   (SELECT 1 marker FROM DUAL UNION ALL
                    SELECT 2 marker FROM DUAL UNION ALL
                    SELECT 3 marker FROM DUAL UNION ALL
                    SELECT 4 marker FROM DUAL UNION ALL
                    SELECT 5 marker FROM DUAL UNION ALL
                    SELECT 6 marker FROM DUAL UNION ALL
                    SELECT 7 marker FROM DUAL UNION ALL
                    SELECT 8 marker FROM DUAL UNION ALL
                    SELECT 9 marker FROM DUAL UNION ALL
                    SELECT 10 marker FROM DUAL UNION ALL
                    SELECT 11 marker FROM DUAL UNION ALL
                    SELECT 12 marker FROM DUAL) TMP)
        WHERE SDate IS NOT NULL
        GROUP BY Org_ID, Supplier_ID, Invoice_ID, SDate)

COMMIT;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted '|| SQL%ROWCOUNT ||' records into FII_AP_AGING_BKTS_B and  FII_AP_DUE_COUNTS_B');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

--  g_state := 'Truncating temp tables used to populate FII_AP_AGING_BKTS_B and FII_AP_DUE_COUNTS_B';
--  TRUNCATE_TABLE('FII_AP_BUCKET_CALCS');
--  TRUNCATE_TABLE('FII_AP_PS_BUCKETS');
--  TRUNCATE_TABLE('FII_AP_INDEX_TEMP');

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_PS_BUCKET_COUNT;



------------------------------------------------------------------
-- Procedure POPULATE_HOLD_HISTORY
-- Purpose
--   This POPULATE_HOLD_HISTORY routine inserts records into the
--   FII Hold History summary table.
------------------------------------------------------------------

PROCEDURE POPULATE_HOLD_HISTORY IS

BEGIN

  g_state := 'Inside the procedure POPULATE_HOLD_HISTORY';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Deleting records from FII_AP_HOLD_HIST_B that are already existing';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;


  /* For Initial Load we will truncate the data in the hold history table
     and re-populate this table */
  TRUNCATE_TABLE('MLOG$_FII_AP_HOLD_HIST_B');
  TRUNCATE_TABLE('FII_AP_HOLD_HIST_B');


  g_state := 'Populating FII_AP_HOLD_HIST_B FROM AP_HOLDS_ALL table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Populating Hold and Release Records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* Only insert a 'H' record for the first hold in a series of overlapping
     holds.  The first part of the union does this by checking if this hold is
     the first ever for the invoice or if all holds made before this hold have
     been released before the hold was made.

     Only insert a 'R' record for the last release in a series of overlapping
     holds, if all holds have been released.  The second part of the union does
     this by checking if this hold is the very last to be released or if all holds
     released after it were held after this hold was released.
  */

  INSERT /*+ append parallel(HH) */ INTO FII_AP_HOLD_HIST_B HH
         (TIME_ID,
          PERIOD_TYPE_ID,
          ORG_ID,
          SUPPLIER_ID,
          INVOICE_ID,
          SEQ_ID,
          ACTION,
          ACTION_DATE,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN)
  SELECT TO_NUMBER(TO_CHAR(H_R_DATE,'J')),
         1,
         ORG_ID,
         SUPPLIER_ID,
         INVOICE_ID,
         DECODE(REC_TYPE, 'H', FII_AP_HOLD_HIST_B_S.NEXTVAL, NULL),
         REC_TYPE,
         H_R_DATE,
         g_fii_user_id CREATED_BY,
         sysdate CREATION_DATE,
         g_fii_user_id LAST_UPDATED_BY,
         sysdate LAST_UPDATE_DATE,
         g_fii_login_id LAST_UPDATE_LOGIN
  FROM
    (SELECT /*+ use_hash(AI,AH) parallel(AI) parallel(AH) */
        DISTINCT AI.ORG_ID,
        AI.SUPPLIER_ID,
        AI.INVOICE_ID,
        AH.REC_TYPE,
        TRUNC(AH.H_R_DATE) H_R_DATE
     FROM FII_AP_INVOICE_B AI,
         (SELECT /*+ no_merge */
                 Invoice_ID,
                 TRUNC(Hold_Date) H_R_DATE,
                 'H' Rec_Type
          FROM (SELECT  /*+ parallel(h) */
                        Invoice_ID,
                        Hold_Date,
                        MAX(Release_Date) OVER (PARTITION BY Invoice_ID
                                                ORDER BY Hold_Date ASC
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) Max_Previous
                FROM (SELECT  /*+ parallel(h) no_merge full(h) */
                              Invoice_ID,
                              Hold_Date,
                              DECODE(Release_Lookup_Code, NULL, g_sysdate, last_update_date) Release_Date
                      FROM    AP_Holds_All h
                      WHERE Hold_Date >= g_start_date
                      AND   Hold_Date+0 <= g_end_date  --workaround for pq-between bug
                      ) h
               )
          WHERE (Max_Previous IS NULL OR TRUNC(Hold_Date) > TRUNC(Max_Previous))
          UNION ALL
          SELECT Invoice_ID,
                 TRUNC(Release_Date) H_R_DATE,
                 'R' Rec_Type
          FROM (SELECT /*+ parallel(h) */
                       Invoice_ID,
                       Release_Date,
                       Release_Lookup_Code,
                       MIN(Hold_Date) OVER (PARTITION BY Invoice_ID
                                            ORDER BY Release_Date ASC
                                            ROWS BETWEEN 1 FOLLOWING AND UNBOUNDED FOLLOWING) Min_After
                FROM (SELECT /*+ parallel(h) no_merge full(h) */
                             Invoice_ID,
                             Hold_Date,
                             DECODE(Release_Lookup_Code, NULL, g_sysdate, Last_Update_Date) Release_Date,
                             Release_Lookup_Code
                      FROM   AP_Holds_All h
                      WHERE  Hold_Date >= g_start_date
                      AND    Hold_Date+0 <= g_end_date  -- workaround for pq-between bug
                      ) h
               )
          WHERE (Min_After IS NULL OR TRUNC(Min_After) > TRUNC(Release_Date))
          AND   Release_Lookup_Code IS NOT NULL) AH --Filter release records for unreleased holds
     WHERE AI.Invoice_ID = AH.Invoice_ID
     AND AI.Cancel_Date IS NULL
     AND AI.Invoice_Type NOT IN ('PREPAYMENT'));


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted '|| SQL%ROWCOUNT ||' Hold and Release records into FII_AP_HOLD_HIST_B');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

  COMMIT;

  g_state := 'Updating Seq_ID for the Release Records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  UPDATE FII_AP_Hold_Hist_B HH
  SET    Seq_ID = (SELECT HH1.Seq_ID
                   FROM   FII_AP_Hold_Hist_B HH1
                   WHERE  HH1.Action = 'H'
                   AND    HH1.Invoice_ID = HH.Invoice_ID
                   AND    HH1.Action_Date IN
                         (SELECT MIN(TRUNC(AH1.Hold_Date))
                          FROM   AP_Holds_ALL AH1, AP_Holds_ALL AH2
                          WHERE  AH1.Invoice_ID = HH.Invoice_ID
                          AND    AH2.Invoice_ID = HH.Invoice_ID
                          AND    TRUNC(AH2.Last_Update_Date) = HH.Action_Date
                          AND    AH2.Release_Lookup_Code IS NOT NULL
                          AND    TRUNC(AH1.Last_Update_Date) >= TRUNC(AH2.Hold_Date)
                          AND    AH1.Release_Lookup_Code IS NOT NULL
                          AND    TRUNC(AH1.Last_Update_Date)
                                     <= TRUNC(AH2.Last_Update_Date)))
  WHERE  HH.Action = 'R'
  AND    HH.Seq_ID IS NULL;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Updated '|| SQL%ROWCOUNT ||' Release records in the FII_AP_HOLD_HIST_B');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;

/* We currently do not use hold_count in any mv or detail report,
   so it is safe to remove this update.

  g_state := 'Updating the Hold Count on the Hold and Release records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  UPDATE FII_AP_Hold_Hist_B HH
  SET Hold_Count = (SELECT DECODE(HH.Action,'H', COUNT(*), -1 * COUNT(*))
                    FROM   AP_Holds_ALL AH
                    WHERE  AH.Invoice_ID = HH.Invoice_ID
                    AND   (EXISTS (SELECT 'Hold Exists'
                                   FROM   FII_AP_Hold_Hist_B HH1
                                   WHERE  HH1.Invoice_ID = AH.Invoice_ID
                                   AND    HH1.Seq_ID = HH.Seq_ID
                                   AND    TRUNC(AH.Hold_Date) >= DECODE(HH.Action,'H',
                                                 HH.Action_Date, HH1.Action_Date)
                                   AND    AH.Release_Lookup_Code IS NOT NULL
                                   AND    TRUNC(AH.Last_Update_Date) <=
                                              DECODE(HH.Action,'H',HH1.Action_Date,
                                                                   HH.Action_Date)
                                   AND    HH1.Rowid <> HH.Rowid)
                    OR     NOT EXISTS (SELECT 'Release Exists'
                                       FROM   FII_AP_Hold_Hist_B HH2
                                       WHERE  HH2.Invoice_ID = AH.Invoice_ID
                                       AND    HH.Seq_ID = HH2.Seq_ID
                                       AND    HH2.Rowid <> HH.Rowid)))
  WHERE HH.Hold_Count IS NULL;


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Updated '|| SQL%ROWCOUNT ||' Hold Counts in the FII_AP_HOLD_HIST_B');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.put_line('');
  end if;
*/

EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END POPULATE_HOLD_HISTORY;



-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

--------------------------------------------------
-- PROCEDURE WORKER
--   This Worker routine Handles all functions involved in the
--   Payment Schedule Summarization and populating FII_AP_PAY_SCHED_B
--   summary table.

---------------------------------------------------
PROCEDURE WORKER(Errbuf       IN OUT NOCOPY VARCHAR2,
                 Retcode      IN OUT NOCOPY VARCHAR2,
                 p_from_date  IN     VARCHAR2,
                 p_to_date    IN     VARCHAR2,
                 p_worker_no  IN     NUMBER
                ) IS

  l_unassigned_cnt       NUMBER := 0;
  l_failed_cnt           NUMBER := 0;
  l_curr_unasgn_cnt      NUMBER := 0;
  l_curr_comp_cnt        NUMBER := 0;
  l_curr_tot_cnt         NUMBER := 0;
  l_count                NUMBER;
  l_start_range          NUMBER;
  l_end_range            NUMBER;

BEGIN
  g_state := 'Inside the procedure WORKER';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  Errbuf := NULL;
  Retcode:= 0;

  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE=UNLIMITED';
  EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
  EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE = 100000000';
  EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE = 100000000';

  -- -----------------------------------------------
  -- Set up directory structure for child process
  -- because child process do not call setup routine
  -- from EDWCORE
  -- -----------------------------------------------
  CHILD_SETUP('FII_AP_INV_SUM_INIT_SUBWORKER'||p_worker_no);

  g_start_date := p_from_date;



  g_end_date   := p_to_date;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(' ');
     FII_UTIL.put_timestamp;
     FII_UTIL.put_line('Worker '||p_worker_no||' Starting');
  end if;

  -- ------------------------------------------
  -- Initalization
  -- ------------------------------------------
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(' ');
     FII_UTIL.put_line('Initialization');
  end if;

  INIT;

  -- ------------------------------------------
  -- Loop thru job list
  -- -----------------------------------------
  g_state := 'Looping through job list';
  LOOP
    SELECT nvl(sum(decode(status,'UNASSIGNED',1,0)),0),
           nvl(sum(decode(status,'FAILED',1,0)),0),
           nvl(sum(decode(status,'UNASSIGNED',1, 0)),0),
           nvl(sum(decode(status,'COMPLETED', 1, 0)),0),
           count(*)
    INTO   l_unassigned_cnt,
           l_failed_cnt,
           l_curr_unasgn_cnt,
           l_curr_comp_cnt,
           l_curr_tot_cnt
    FROM   FII_AP_PS_WORK_JOBS;
    SELECT COUNT(1)
    INTO   l_unassigned_cnt
    FROM   FII_AP_PS_WORK_JOBS
    WHERE  status = 'UNASSIGNED'
    AND    rownum = 1;
    SELECT COUNT(1)
    INTO   l_failed_cnt
    FROM   FII_AP_PS_WORK_JOBS
    WHERE  status = 'FAILED'
    AND    rownum = 1;
    IF l_failed_cnt > 0 THEN
       if g_debug_flag = 'Y' then
          FII_UTIL.put_line('');
          FII_UTIL.put_line('Another worker have errored out.  Stop processing.');
       end if;
       EXIT;
    ELSIF l_unassigned_cnt = 0 THEN
          if g_debug_flag = 'Y' then
             FII_UTIL.put_line('');
             FII_UTIL.put_line('No more jobs left.  Terminating.');
          end if;
          EXIT;
    ELSIF l_unassigned_cnt > 0 THEN
          UPDATE FII_AP_PS_WORK_JOBS
          SET    status = 'IN PROCESS',
                 worker_number = p_worker_no
          WHERE  status = 'UNASSIGNED'
          AND    rownum < 2;
          l_count := sql%rowcount;
    END IF;
    COMMIT;

    -- -----------------------------------
    -- There could be rare situations where
    -- between Section 30 and Section 50
    -- the unassigned job gets taken by
    -- another worker.  So, if unassigned
    -- job no longer exist.  Do nothing.
      -- -----------------------------------
    IF l_count > 0 THEN
       BEGIN
         SELECT start_range,
                end_range
         INTO   l_start_range,
                l_end_range
         FROM   FII_AP_PS_WORK_JOBS jobs
         WHERE  jobs.worker_number = p_worker_no
         AND    jobs.status = 'IN PROCESS';

         ---------------------------------------------------------
         --Do summarization using the start_range and end_range
         ---------------------------------------------------------
         if g_debug_flag = 'Y' then
            FII_UTIL.start_timer;
         end if;
         POPULATE_PAY_SCHED_SUM(l_start_range,  l_end_range);
         if g_debug_flag = 'Y' then
            FII_UTIL.stop_timer;
            FII_UTIL.print_timer('Duration');
         end if;
         UPDATE FII_AP_PS_WORK_JOBS jobs
         SET    jobs.status = 'COMPLETED'
         WHERE  jobs.status = 'IN PROCESS'
         AND    jobs.worker_number = p_worker_no;
         COMMIT;

       EXCEPTION
         WHEN OTHERS THEN
              g_retcode := -1;

              UPDATE FII_AP_PS_WORK_JOBS
              SET  status = 'FAILED'
              WHERE  worker_number = p_worker_no
              AND   status = 'IN PROCESS';

              COMMIT;
              Raise;
       END;
    END IF; /* IF (l_count > 0) */
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
       Retcode:= -1;
       Errbuf := '
Error in Procedure: WORKER
Message: '||sqlerrm;
       FII_UTIL.put_line(Errbuf);

        -------------------------------------------
        -------------------------------------------
        -- Update the WORKER_JOBS table to indicate
        -- this job has failed
        -------------------------------------------
        UPDATE FII_AP_PS_WORK_JOBS
        SET  status = 'FAILED'
        WHERE  worker_number = p_worker_no
        AND   status = 'IN PROCESS';

        COMMIT;

END WORKER;


-----------------------------------------------------------
-- Procedure
--   Collect()
-- Purpose
--   This Collect routine Handles all functions involved in the AP summarization
--   and populating FII AP summary tables .

-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2,
                  p_from_date     IN      VARCHAR2,
                  p_to_date       IN      VARCHAR2,
                  p_no_worker     IN      NUMBER
                  ) IS
  l_dir                VARCHAR2(400);
  TYPE WorkerList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  l_worker             WorkerList;

  l_start_date DATE;
  l_start_date_temp DATE;

  l_end_date DATE;
  l_period_from DATE;
  l_period_to DATE;
BEGIN
  g_state := 'Inside the procedure COLLECT';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  Retcode := 0;

  ------------------------------------------------------
  -- Set default directory in case if the profile option
  -- BIS_DEBUG_LOG_DIRECTORY is not set up
  ------------------------------------------------------
  l_dir:=FII_UTIL.get_utl_file_dir;
  -- l_dir := '/sqlcom/log';
  ----------------------------------------------------------------
  -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
  -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
  -- the log files and output files are written to
  ----------------------------------------------------------------
  FII_UTIL.initialize('FII_AP_INV_SUM_INIT.log','FII_AP_INV_SUM_INIT.out',l_dir, 'FII_AP_INV_SUM_INIT');

  -------------------------------------------------------------
  -- Check if FII: DBI Payables Operations Implementation profile
  -- is turned on.  If yes, continue, otherwise, error out.  User
  -- need to turn on this profile option before running this program
  ---------------------------------------------------------------
  IF g_oper_imp_prof_flag = 'N' THEN
      g_state := 'Checking Implementation profile option';
      FII_MESSAGE.write_log(
      msg_name    => 'FII_AP_DBI_OPER_IMP',
      token_num   => 0);
      g_retcode := -2;
		g_errbuf := 'FII: DBI Payables Operations Implementation profile option is not turned on';
      RAISE G_IMP_NOT_SET;
  END IF;

  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
  EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE=UNLIMITED';
  EXECUTE IMMEDIATE 'ALTER SESSION SET events ''10046 trace name context forever, level 8''';
  EXECUTE IMMEDIATE 'ALTER SESSION SET HASH_AREA_SIZE = 100000000';
  EXECUTE IMMEDIATE 'ALTER SESSION SET SORT_AREA_SIZE = 100000000';

  g_start_date := trunc(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'));
  g_end_date   := trunc(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS')) + 1 - ONE_SECOND;
  g_no_worker := p_no_worker;

  g_state := 'Calling BIS_COLLECTION_UTILITIES.setup';
  IF(NOT BIS_COLLECTION_UTILITIES.setup('FII_AP_INV_SUM_INIT')) THEN
        raise_application_error(-20000, errbuf);
        return;
  END IF;

  IF g_exp_imp_prof_flag = 'Y' THEN
  ------------------------------------------------------------
  --Get timestamps used to maintain ap_dbi_log.
  --g_timestamp1 - current timestamp.
  --g_timestamp2 - last Payables Operation/Expenses load.
  --g_timestamp3 - last Payables Expenses load.
  -------------------------------------------------------------
    g_state := 'Defining timestamps to maintain ap_dbi_log.';
    IF g_debug_flag = 'Y' then
      FII_UTIL.put_line('');
      FII_UTIL.put_line(g_state);
      fii_util.put_line('');
    END IF;

    g_timestamp1 := BIS_COLLECTION_UTILITIES.G_Start_Date;

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_DISTRIBUTIONS_B_L',
                                                    l_start_date, l_end_date,
                                                    l_period_from, l_period_to);

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_DISTRIBUTIONS_B_I',
                                                    l_start_date_temp, l_end_date,
                                                    l_period_from, l_period_to);

    l_start_date := GREATEST(NVL(l_start_date, BIS_COMMON_PARAMETERS.Get_Global_Start_Date),
                             NVL(l_start_date_temp, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));
    g_timestamp3 := l_start_date;

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_SUM_INIT',
                                                    l_start_date_temp, l_end_date,
                                                    l_period_from, l_period_to);

    l_start_date := GREATEST(l_start_date,
                             NVL(l_start_date_temp, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_SUM_INC',
                                                    l_start_date_temp, l_end_date,
                                                    l_period_from, l_period_to);

    l_start_date := GREATEST(l_start_date,
                             NVL(l_start_date_temp, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));

    g_timestamp2 := l_start_date;

    g_act_part1 := MOD(TO_NUMBER(TO_CHAR(TRUNC(g_timestamp1), 'J')), 32);
    g_act_part2 := MOD(TO_NUMBER(TO_CHAR(TRUNC(g_timestamp1+1), 'J')), 32);

  ELSE --Payables Expenses is not implemented, so it is safe to truncate log table.
    g_state := 'Truncating AP_DBI_LOG.';
    EXECUTE IMMEDIATE('TRUNCATE TABLE ' || g_ap_schema || '.AP_DBI_LOG');
  END IF;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('Current Load Timestamp is: ' || to_char(g_timestamp1, 'YYYY/MM/DD HH24:MI:SS'));
   FII_UTIL.put_line('Previous Payables Load Timestamp is: ' || to_char(g_timestamp2, 'YYYY/MM/DD HH24:MI:SS'));
   FII_UTIL.put_line('Previous Payables Expenses Load Timestamp is: ' || to_char(g_timestamp3, 'YYYY/MM/DD HH24:MI:SS'));
  end if;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Init procedure to initialize the global variables');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  INIT;

  g_state := 'Truncating temp tables used to populate base tables';
  TRUNCATE_TABLE('FII_AP_PS_RATES_TEMP');
  TRUNCATE_TABLE('FII_AP_FUNC_RATES_TEMP');
  TRUNCATE_TABLE('FII_AP_PS_WORK_JOBS');
  TRUNCATE_TABLE('FII_AP_PAY_SCHED_TEMP');
  TRUNCATE_TABLE('FII_AP_WH_TAX_T');
  TRUNCATE_TABLE('FII_AP_PREPAY_T');
  TRUNCATE_TABLE('FII_AP_PAY_CHK_STG');

  COMMIT;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Insert_Rates procedure to insert the missing rate info');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  INSERT_RATES;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Verify_Missing_Rates procedure');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;


  IF (VERIFY_MISSING_RATES = -1) THEN
      g_retcode := -1;
      g_errbuf := fnd_message.get_string('FII', 'FII_MISS_EXCH_RATE_FOUND');
      RAISE G_MISSING_RATES;


  -----------------------------------------------------------------------
  -- If there are no missing exchange rate records, then we will insert
  -- records into the summary tables
  -----------------------------------------------------------------------
  ELSE

    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_INV_BASE_SUM');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_INV_BASE_SUM;
    g_retcode := 0;

    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_HOLDS_SUM');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_HOLDS_SUM;
    g_retcode := 0;


    /* Populating the prepayment and withholding amounts into the temp table */
    INSERT_WH_PREPAY_AMOUNT;

    /* Populating the payment and discount information into the temp table */
    INSERT_PAYMENT_CHECK_INFO;

    --------------------------------------------
    -- Register  jobs
    --------------------------------------------
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(' ');
       FII_UTIL.put_line('Populating Jobs Table');
       FII_UTIL.put_timestamp;
    end if;

    REGISTER_JOBS;
    COMMIT;

    g_state := 'Deleting records from FII_AP_PAY_SCHED_B that are already existing';
    /* For Initial Load we will truncate the data in the pay sched summary table
       and re-populate this table */
    TRUNCATE_TABLE('MLOG$_FII_AP_PAY_SCHED_B');
    TRUNCATE_TABLE('FII_AP_PAY_SCHED_B');

    FND_PROFILE.PUT('CONC_SINGLE_THREAD','N');

    --------------------------------------------------------
    -- Launch worker
    --------------------------------------------------------
    g_state := 'Launching Workers';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Launching Workers');
    end if;

   /* p_no_worker is the parameter user submitted to specify how many
      workers they want to submit */

    FOR i IN 1..p_no_worker
    LOOP
      l_worker(i) := LAUNCH_WORKER(i);
      if g_debug_flag = 'Y' then
         FII_UTIL.put_line('Worker '||i||' request id: '||l_worker(i));
      end if;
    END LOOP;

    COMMIT;

    MONITOR_WORKER;

    -------------------------------------------------------------------
    -- Analyze Payment schedule table after all workers have completed
    -- updating the AP_PAYMENT_SCHEDULES_ALL table
    -------------------------------------------------------------------
    FND_STATS.GATHER_TABLE_STATS(g_ap_schema,'AP_PAYMENT_SCHEDULES_ALL');
    EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

    FND_PROFILE.PUT('CONC_SINGLE_THREAD','Y');

    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_PS_BUCKET_COUNT');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_PS_BUCKET_COUNT;
    g_retcode := 0;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_HOLD_HISTORY');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_HOLD_HISTORY;
    g_retcode := 0;


    IF g_exp_imp_prof_flag = 'Y' THEN
      FOR i IN 0..31 LOOP --i represents the partition of ap_dbi_log.

        IF g_timestamp3 + 30 >= g_timestamp1 THEN --Copy records into Expense log table.
          INSERT INTO FII_AP_DBI_LOG_EXP_T(
                 Table_Name,
                 Operation_Flag,
                 Key_Value1_ID,
                 Key_Value2_ID,
                 Created_By,
                 Last_Updated_By,
                 Last_Update_Login,
                 Creation_Date,
                 Last_Update_Date)
          SELECT Table_Name,
                 Operation_Flag,
                 Key_Value1,
                 Key_Value2,
                 Created_By,
                 Last_Updated_By,
                 Last_Update_Login,
                 Creation_Date,
                 Last_Update_Date
          FROM AP_DBI_LOG
          WHERE Partition_ID = i
          AND Creation_Date >= g_timestamp2
          AND Creation_Date < g_timestamp1;
        END IF;

        IF NOT (i = g_act_part1 OR i = g_act_part2) THEN --This is a non-active partition.
          EXECUTE IMMEDIATE 'ALTER TABLE ' || g_ap_schema || '.AP_DBI_LOG TRUNCATE PARTITION P' || to_char(i);
        END IF;

      END LOOP;

    END IF;

    TRUNCATE_TABLE('FII_AP_DBI_LOG_PS_T');


    g_state := 'Truncating temp tables after used to populate base tables';
    TRUNCATE_TABLE('FII_AP_PAY_SCHED_TEMP');
    TRUNCATE_TABLE('FII_AP_WH_TAX_T');
    TRUNCATE_TABLE('FII_AP_PREPAY_T');
    TRUNCATE_TABLE('FII_AP_PS_WORK_JOBS');
    TRUNCATE_TABLE('FII_AP_PAY_CHK_STG');

  END IF;


  COMMIT;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('return code is ' || retcode);
  end if;
  Retcode := g_retcode;

  g_state := 'Calling BIS_COLLECTION_UTILITIES.wrapup';
  BIS_COLLECTION_UTILITIES.wrapup(
      p_status => TRUE,
      p_period_from => g_start_date,
      p_period_to => g_end_date);

  BIS_COLLECTION_UTILITIES.deleteLogForObject('FII_AP_INV_SUM_INC');


EXCEPTION
  WHEN OTHERS THEN
    g_retcode:= -1;
    retcode:=g_retcode;
    g_exception_msg  := g_retcode || ':' || g_errbuf;
    FII_UTIL.put_line('Error occured while ' || g_state);
    FII_UTIL.put_line(g_exception_msg);

END;

END FII_AP_INV_SUM_INIT;


/
