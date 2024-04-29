--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_SUM_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_SUM_INC" AS
/* $Header: FIIAP19B.pls 120.14 2006/10/10 23:32:45 vkazhipu noship $ */

g_errbuf                 VARCHAR2(2000) := NULL;
g_retcode                VARCHAR2(200)  := NULL;
g_exception_msg          VARCHAR2(4000) := NULL;
g_prim_currency          VARCHAR2(15)   := NULL;
g_sec_currency           VARCHAR2(15)   := NULL;
g_state                  VARCHAR2(200);
g_start_date             DATE;
g_sysdate                DATE := TRUNC(SYSDATE);
g_seq_id                 NUMBER;
g_debug_flag             VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
g_oper_imp_prof_flag     VARCHAR2(1) := NVL(FND_PROFILE.value('FII_AP_DBI_IMP'), 'N');
g_exp_imp_prof_flag      VARCHAR2(1) := NVL(FND_PROFILE.value('FII_AP_DBI_EXP_IMP'), 'N');
g_manual_sources         VARCHAR2(2000) := FND_PROFILE.value('FII_AP_MANUAL_SOURCES');
g_last_start_date        DATE;

g_prim_rate_type         VARCHAR2(30);
g_sec_rate_type          VARCHAR2(30);
g_primary_mau            NUMBER;
g_secondary_mau          NUMBER;
g_fii_user_id            NUMBER(15);
g_fii_login_id           NUMBER(15);

g_fii_schema             VARCHAR2(30);
G_TABLE_NOT_EXIST        EXCEPTION;
                         PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;
G_IMP_NOT_SET            EXCEPTION;
G_MISSING_RATES          EXCEPTION;
G_MISS_GLOBAL_PARAMS     EXCEPTION;
G_NEED_SECONDARY_INFO    EXCEPTION;
G_INVALID_MANUAL_SOURCE  EXCEPTION;
G_RUN_INIT               EXCEPTION;

g_due_bucket1            NUMBER := 31;
g_due_bucket2            NUMBER := 30;
g_due_bucket3            NUMBER := 15;

g_past_bucket1           NUMBER := 31;
g_past_bucket2           NUMBER := 30;
g_past_bucket3           NUMBER := 15;

g_bucket_interval        NUMBER := 15;
g_no_buckets             NUMBER := 6;


g_timestamp1 DATE;
g_timestamp2 DATE;
g_timestamp3 DATE;
g_timestamp4 DATE;

g_act_part1 NUMBER;
g_act_part2 NUMBER;
g_old_act_part1 NUMBER;
g_old_act_part2 NUMBER;

g_ap_schema VARCHAR2(30) := 'AP';
--Define Record Types to Populate Memory Structures.

--Inv_Type is used to populate the Invoices Memory Structure, FII_AP_Inv_MS.
TYPE Inv_Rec IS RECORD(
  Org_ID                   NUMBER(15,0),
  Supplier_ID              NUMBER(15,0),
  Invoice_ID               NUMBER(15,0),
  Invoice_Type             VARCHAR2(25),
  Invoice_Number           VARCHAR2(50),
  Invoice_Date             DATE,
  Invoice_Amount           NUMBER,
  Invoice_Currency_Code    VARCHAR2(25),
  Base_Currency_Code       VARCHAR2(25),
  Exchange_Date            DATE,
  Exchange_Rate            NUMBER,
  Exchange_Rate_Type       VARCHAR2(30),
  Entered_Date             DATE,
  Created_By               NUMBER(15,0),
  Payment_Currency_Code    VARCHAR2(25),
  Payment_Status_Flag      VARCHAR2(1),
  Payment_Cross_Rate       NUMBER,
  Terms_ID                 NUMBER(15,0),
  Source                   VARCHAR2(25),
  E_Invoices_Flag          VARCHAR2(1),
  Cancel_Flag              VARCHAR2(1),
  Cancel_Date              DATE,
  Dist_Count               NUMBER(15,0),
  Minimum_Accountable_Unit NUMBER,
  Functional_MAU           NUMBER,
  To_Func_Rate             NUMBER,
  To_Prim_Rate             NUMBER,
  To_Sec_Rate              NUMBER,
  Invoice_B_Flag           VARCHAR2(1),
  Pay_Sched_B_Flag         VARCHAR2(1));
TYPE Inv_Type IS TABLE OF Inv_Rec
  INDEX BY BINARY_INTEGER;

--Pay_Sched_Type is used to populate the Payment Schedule Memory Structure, FII_AP_Pay_Sched_MS.
TYPE Pay_Sched_Rec IS RECORD(
  Invoice_ID                NUMBER(15,0),
  Payment_Num               NUMBER(15,0),
  Due_Date                  DATE,
  Discount_Date             DATE,
  Gross_Amount              NUMBER,
  Second_Discount_Date      DATE,
  Third_Discount_Date       DATE,
  Discount_Amount_Available NUMBER,
  Second_Disc_Amt_Available NUMBER,
  Third_Disc_Amt_Available  NUMBER,
  Created_By                NUMBER(15,0),
  Fully_Paid_Date           DATE);
TYPE Pay_Sched_Type IS TABLE OF Pay_Sched_Rec
  INDEX BY BINARY_INTEGER;

--Inv_Pay_Type is used to populate the Invoice Payment Memory Structure, FII_AP_Inv_Pay_MS.
TYPE Inv_Pay_Rec IS RECORD(
  Amount                     NUMBER,
  Check_ID                   NUMBER(15,0),
  Invoice_ID                 NUMBER(15,0),
  Invoice_Payment_ID         NUMBER(15,0),
  Payment_Num                NUMBER(15,0),
  Created_By                 NUMBER(15,0),
  Creation_Date              DATE,
  Discount_Taken             NUMBER,
  Check_Date                 DATE,
  Processing_Type            VARCHAR2(30));
TYPE Inv_Pay_Type IS TABLE OF Inv_Pay_Rec
  INDEX BY BINARY_INTEGER;

--WH_Tax_Type is used to populate the Withholding/Tax Memory Structure, FII_AP_WH_Tax_MS.
TYPE WH_Tax_Rec IS RECORD(
  Invoice_ID              NUMBER(15,0),
  Line_Type_Lookup_Code   VARCHAR2(25),
  Amount                  NUMBER,
  Creation_Date           DATE,
  Invoice_Distribution_ID NUMBER(15,0));
TYPE WH_Tax_Type IS TABLE OF WH_Tax_Rec
  INDEX BY BINARY_INTEGER;

--Prepay_Applied_Type is used to populate the Prepayments Applied Memory Structure, FII_AP_Prepay_Applied_MS.
TYPE Prepay_Applied_Rec IS RECORD(
  Invoice_ID                 NUMBER(15,0),
  Amount                     NUMBER,
  Creation_Date              DATE,
  Check_ID                   NUMBER(15,0),
  Check_Date                 DATE,
  Processing_Type            VARCHAR2(30),
  Unallocated_Amount         NUMBER);
TYPE Prepay_Applied_Type IS TABLE OF Prepay_Applied_Rec
  INDEX BY BINARY_INTEGER;

--Pay_Sched_Temp_Type is used to populate the memory structure FII_AP_Pay_Sched_Temp_MS.
TYPE Pay_Sched_Temp_Rec IS RECORD(
  Action      VARCHAR2(30),
  Action_Date DATE,
  Number1     NUMBER,
  Number2     NUMBER,
  Number3     NUMBER(15,0),
  Number4     NUMBER(15,0),
  Number5     NUMBER,
  Date1       DATE,
  String1     VARCHAR2(25));
TYPE Pay_Sched_Temp_Type IS TABLE OF Pay_Sched_Temp_Rec
  INDEX BY VARCHAR2(50);

--PS_Aging_Type is used to populate the memory structure FII_AP_PS_Aging_MS.
TYPE PS_Aging_Rec IS RECORD(
  Action_Date      DATE,
  Due_Bucket1      NUMBER(15,0),
  Due_Bucket2      NUMBER(15,0),
  Due_Bucket3      NUMBER(15,0),
  Past_Due_Bucket3 NUMBER(15,0),
  Past_Due_Bucket2 NUMBER(15,0),
  Past_Due_Bucket1 NUMBER(15,0));
TYPE PS_Aging_Type IS TABLE OF PS_Aging_Rec
  INDEX BY VARCHAR2(50);

--Pay_Sched_B_Type is used to populate the memory structure FII_AP_Pay_Sched_B_MS
TYPE Pay_Sched_B_Type IS TABLE OF FII_AP_PAY_SCHED_B%ROWTYPE
  INDEX BY BINARY_INTEGER;

--Invoice_B_Type is used to populate the memory structure FII_AP_Invoice_B_MS
TYPE Invoice_B_Type IS TABLE OF FII_AP_INVOICE_B%ROWTYPE
  INDEX BY BINARY_INTEGER;

--Aging_Bkts_B_Type is used to populate the memory structure FII_AP_Aging_Bkts_B_MS
TYPE Aging_Bkts_B_Type IS TABLE OF FII_AP_AGING_BKTS_B%ROWTYPE
  INDEX BY BINARY_INTEGER;

--Due_Counts_B_Type is used to populate the memory structure FII_AP_Due_Counts_B_MS
TYPE Due_Counts_B_Type IS TABLE OF FII_AP_DUE_COUNTS_B%ROWTYPE
  INDEX BY BINARY_INTEGER;

--Used to hold deleted records from FII_AP_Pay_Sched_B.
TYPE Pay_Sched_D_Rec IS RECORD(
  Invoice_ID    NUMBER(15,0),
  Payment_Num   NUMBER(15,0),
  Action_Date   DATE,
  Action        VARCHAR2(30),
  Inv_Pymt_Flag VARCHAR2(1),
  Unique_ID     NUMBER);
TYPE Pay_Sched_D_Type IS TABLE OF Pay_Sched_D_Rec
  INDEX BY BINARY_INTEGER;

--Used to hold deleted records from FII_AP_Invoice_B.
TYPE Invoice_D_Rec IS RECORD(
  Invoice_ID Number(15,0));
TYPE Invoice_D_Type IS TABLE OF Invoice_D_Rec
  INDEX BY BINARY_INTEGER;


FII_AP_Pay_Sched_B_MS      Pay_Sched_B_Type;
g_pay_sched_b_marker       BINARY_INTEGER;
FII_AP_Pay_Sched_UI_MS      Pay_Sched_B_Type; --Stores records that have been updated or inserted.
FII_AP_Pay_Sched_D_MS      Pay_Sched_D_Type; --Stores records that have been deleted.
FII_AP_Invoice_B_MS        Invoice_B_Type;
g_invoice_b_marker         BINARY_INTEGER;
FII_AP_Invoice_UI_MS        Invoice_B_Type; --Stores records that have been updated or inserted.
FII_AP_Invoice_D_MS        Invoice_D_Type; --Stores records that have been deleted.
FII_AP_Inv_MS              Inv_Type;
FII_AP_Pay_Sched_MS        Pay_Sched_Type;
FII_AP_Inv_Pay_MS          Inv_Pay_Type;
FII_AP_WH_Tax_MS           WH_Tax_Type;
FII_AP_Prepay_Applied_MS   Prepay_Applied_Type;
FII_AP_Aging_Bkts_B_MS     Aging_Bkts_B_Type;
FII_AP_Due_Counts_B_MS     Due_Counts_B_Type;
l_pay_sched_marker         BINARY_INTEGER;
l_inv_pay_marker           BINARY_INTEGER;
l_wh_tax_marker            BINARY_INTEGER;
l_ps_wh_tax_marker         BINARY_INTEGER; --Used to store the first WH/Tax for a payment schedule.
l_prepay_applied_marker    BINARY_INTEGER;


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
--  FUNCTION VERIFY_MISSING_RATES
-----------------------------------------------------------
FUNCTION Verify_Missing_Rates RETURN NUMBER IS
  l_miss_rates_prim   NUMBER := 0;
  l_miss_rates_sec    NUMBER := 0;
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
         least(TRX_DATE,sysdate)) Trx_Date
  FROM   FII_AP_PS_RATES_TEMP RATES
  WHERE  RATES.Sec_Conversion_Rate < 0 ;

  CURSOR func_MissingRate IS
  SELECT DISTINCT From_Currency,
         To_Currency,
         decode(conversion_rate,-3,  to_date('01/01/1999','MM/DD/RRRR'),
         least(TRX_DATE,sysdate)) Trx_Date,
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

  SELECT COUNT(*)
  INTO   l_miss_rates_prim
  FROM   FII_AP_PS_RATES_TEMP RATES
  WHERE  RATES.Prim_Conversion_Rate < 0;

  SELECT COUNT(*)
  INTO   l_miss_rates_sec
  FROM   FII_AP_PS_RATES_TEMP RATES
  WHERE  RATES.Sec_Conversion_Rate < 0;

  SELECT COUNT(*)
  INTO   l_miss_rates_func
  FROM   FII_AP_FUNC_RATES_TEMP RATES
  WHERE  RATES.Conversion_Rate < 0;

  --------------------------------------------------------
  -- Print out translated messages to let user know there
  -- are missing exchange rate information
  --------------------------------------------------------
  IF (l_miss_rates_prim > 0 OR
      l_miss_rates_sec  > 0 OR
      l_miss_rates_func > 0) THEN
      FII_MESSAGE.write_log(
      msg_name    => 'BIS_DBI_CURR_PARTIAL_LOAD',
      token_num   => 0);
  END IF;

  --------------------------------------------------------
  -- Print out missing rates report
  --------------------------------------------------------

  IF (l_miss_rates_prim > 0 OR
      l_miss_rates_sec  > 0 OR
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

BEGIN


  INSERT INTO FII_AP_RATES_GT(
       Trx_Currency,
       Func_Currency,
       Exchange_Date,
       Exchange_Rate_Type,
       Exchange_Rate,
       Functional_MAU,
       Invoice_Date)
  SELECT AI.Payment_Currency_Code Trx_Currency,
       ASP.Base_Currency_Code Func_Currency,
       TRUNC(NVL(AI.Exchange_Date, AI.Invoice_Date)) Exchange_Date,
       NVL(AI.Exchange_Rate_Type,'No Rate Type') Exchange_Rate_Type,
       AI.Exchange_Rate Exchange_Rate,
       NVL(FC.Minimum_Accountable_Unit, 0.01) Functional_MAU,
       TRUNC(AI.Invoice_Date) Invoice_Date
  FROM FII_AP_Invoice_IDS ID,
     AP_Invoices_All AI,
     AP_System_Parameters_All ASP,
     FND_Currencies FC
  WHERE ID.Invoice_ID = AI.Invoice_ID
  AND   ID.Get_Rate_Flag = 'Y'
  AND   AI.Org_ID = ASP.Org_ID
  AND   AI.Set_Of_Books_ID = ASP.Set_Of_Books_ID
  AND   AI.Invoice_Type_Lookup_Code <> 'EXPENSE REPORT'
  AND   (AI.Invoice_Amount <> 0 OR (AI.Invoice_Amount = 0 AND AI.Cancelled_Date IS NOT NULL))
  AND   TRUNC(AI.Creation_Date) >= g_start_date
  AND    ASP.Base_Currency_Code = FC.Currency_Code;



  g_state := 'Loading data into rates table';

  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(g_state);
     fii_util.start_timer;
     fii_util.put_line('');
  end if;

  INSERT INTO FII_AP_PS_RATES_TEMP
        (Functional_Currency,
         Trx_Date,
         Prim_Conversion_Rate,
         Sec_Conversion_Rate)
  SELECT Functional_Currency,
         Trx_Date,
         DECODE(Functional_Currency, g_prim_currency, 1,
                FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY(Functional_Currency,
                                                     least(Trx_Date,sysdate))) PRIM_CONVERSION_RATE,
         DECODE(Functional_Currency, g_sec_currency, 1,
                FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(Functional_Currency,
                                                      least(Trx_Date,sysdate))) SEC_CONVERSION_RATE
  FROM  (SELECT /*+ no_merge */ DISTINCT
                Func_Currency Functional_Currency,
                Invoice_Date Trx_Date
         FROM FII_AP_RATES_GT);

  if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;


  if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line('Loading data into functional rates table');
     fii_util.start_timer;
     fii_util.put_line('');
  end if;


  INSERT INTO FII_AP_FUNC_RATES_TEMP
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
                                                least(Trx_Date,sysdate), Exchange_Rate_Type)))
             Conversion_Rate,
         Functional_MAU
  FROM  (SELECT /*+ no_merge */ DISTINCT
              Trx_Currency From_Currency,
              Func_Currency To_Currency,
              Exchange_Date Trx_Date,
              Exchange_Rate_Type,
              DECODE(Exchange_Rate_Type, 'User', Exchange_Rate, null) Exchange_Rate,
              Functional_MAU
         FROM FII_AP_RATES_GT);


  if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
  end if;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_PS_RATES_TEMP');

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_FUNC_RATES_TEMP');


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
-- Procedure DELETE_SUMMARY
-- Purpose
--   This DELETE_SUMMARY routine deletes the records from the
--   summary tables the invoices that have been deleted.
------------------------------------------------------------------

PROCEDURE DELETE_SUMMARY IS

BEGIN

  g_state := 'Inside the procedure DELETE_SUMMARY';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Deleting records from the FII_AP_AGING_BKTS_B table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  DELETE FROM FII_AP_AGING_BKTS_B
  WHERE  Invoice_ID IN (SELECT Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T
                        WHERE  Table_Name = 'AP_INVOICES'
                        AND    Operation_Flag = 'D');

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted '|| SQL%ROWCOUNT ||' records from the FII_AP_AGING_BKTS_B');
     FII_UTIL.put_line('');
  end if;


  g_state := 'Deleting records from the FII_AP_DUE_COUNTS_B table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  DELETE FROM FII_AP_DUE_COUNTS_B
  WHERE  Invoice_ID IN (SELECT Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T
                        WHERE  Table_Name = 'AP_INVOICES'
                        AND    Operation_Flag = 'D');

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted '|| SQL%ROWCOUNT ||' records from the FII_AP_DUE_COUNTS_B');
     FII_UTIL.put_line('');
  end if;


  g_state := 'Deleting records from the FII_AP_INV_HOLDS_B table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  DELETE FROM FII_AP_INV_HOLDS_B
  WHERE  Invoice_ID IN (SELECT Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T
                        WHERE  Table_Name = 'AP_INVOICES'
                        AND    Operation_Flag = 'D');

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted '|| SQL%ROWCOUNT ||' records from the FII_AP_INV_HOLDS_B');
     FII_UTIL.put_line('');
  end if;


  g_state := 'Deleting records from the FII_AP_HOLD_HIST_B table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  DELETE FROM FII_AP_HOLD_HIST_B
  WHERE  Invoice_ID IN (SELECT Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T
                        WHERE  Table_Name = 'AP_INVOICES'
                        AND    Operation_Flag = 'D');

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Deleted '|| SQL%ROWCOUNT ||' records from the FII_AP_HOLD_HIST_B');
     FII_UTIL.put_line('');
  end if;


EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;

END DELETE_SUMMARY;


------------------------------------------------------------------
-- Procedure POPULATE_HOLDS_SUM
-- Purpose
--   This POPULATE_HOLDS_SUM routine inserts records into the
--   FII AP Holds summary tables.
------------------------------------------------------------------

PROCEDURE POPULATE_HOLDS_SUM IS

BEGIN

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inside the procedure POPULATE_HOLDS_SUM');
  end if;

  g_state := 'Deleting holds from FII_AP_INV_HOLDS_B';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  DELETE FROM FII_AP_INV_HOLDS_B
  WHERE  Invoice_ID IN (SELECT /*+ cardinality(T,100) */ Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T T
                        WHERE  Table_Name = 'AP_HOLDS');

  DELETE /*+ index(B) push_subq */ FROM FII_AP_INV_HOLDS_B B
  WHERE  Invoice_ID IN (SELECT /*+ cardinality(Log,1) */ Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T Log, FII_AP_Invoice_B AI
                        WHERE  Log.Key_Value1_Num = AI.Invoice_ID
                        AND    AI.Cancel_Date IS NOT NULL
                        AND    Log.Table_Name = 'AP_INVOICES');

  g_state := 'Populating FII_AP_INV_HOLDS_B FROM AP_HOLDS_ALL table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  INSERT INTO FII_AP_INV_HOLDS_B
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
  SELECT /*+ ordered use_nl(AH,AI) */ TO_NUMBER(TO_CHAR(AH.Hold_Date,'J')),
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
                                      'NATURAL ACCOUNT TAX')
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
  FROM  (SELECT /*+ no_merge */ distinct Key_Value1_Num
         FROM   FII_AP_DBI_LOG_T
         WHERE  Table_Name = 'AP_HOLDS'
         AND    Operation_Flag IN ('I','U')) T,
         AP_Holds_All AH,
         FII_AP_Invoice_B AI
  WHERE  AH.Invoice_ID = AI.Invoice_ID
  AND    AI.Cancel_Date IS NULL
  AND    AI.Invoice_Type NOT IN ('PREPAYMENT')
  AND    AH.Invoice_ID = T.Key_Value1_Num;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT || ' records into FII_AP_INV_HOLDS_B');
     FII_UTIL.put_line('');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;

  UPDATE FII_AP_INV_HOLDS_B HSUM
  SET    Supplier_ID     =  (SELECT AI.Supplier_ID
                             FROM   FII_AP_Invoice_B AI
                             WHERE  AI.Invoice_ID = HSUM.Invoice_ID)
  WHERE  HSUM.Invoice_ID IN (SELECT Key_Value1_Num
                             FROM   FII_AP_DBI_LOG_T
                             WHERE  Table_Name = 'AP_INVOICES'
                             AND    Operation_Flag = 'U');



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


  /* Deleting the records from the Hold History table. This will ensure
     that the records will not be duplicated in the History table */

  DELETE FROM FII_AP_Hold_Hist_B
  WHERE  Invoice_ID IN (SELECT LOG.Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T LOG
                        WHERE  Table_Name = 'AP_HOLDS');

  DELETE /*+ index(B) push_subq */ FROM FII_AP_Hold_Hist_B
  WHERE  Invoice_ID IN (SELECT /*+ cardinality(LOG,1) */ Key_Value1_Num
                        FROM   FII_AP_DBI_LOG_T LOG, FII_AP_Invoice_B AI
                        WHERE  LOG.Key_Value1_Num = AI.Invoice_ID
                        AND    AI.Cancel_Date IS NOT NULL
                        AND    LOG.Table_Name = 'AP_INVOICES');



  g_state := 'Populating FII_AP_HOLD_HIST_B FROM AP_HOLDS_ALL table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  g_state := 'Populating Hold records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  /* If in the AP_HOLDS_ALL table there are overlapping holds then we
     will only select the first hold and insert into the hold history table.
     The subquery in the select statement checks if any overlapping holds exist
     with hold date between the first hold and release dates */

  /* Made changes for bug # 3212761  changed query for inserting Rec_type 'R' and 'H'*/

 INSERT INTO FII_AP_Hold_Hist_B HH
        (Time_ID,
         Period_Type_ID,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         Seq_ID,
         Action,
         Action_Date,
         Created_By,
         Creation_Date,
         Last_Updated_By,
         Last_Update_Date,
         Last_Update_Login)
  SELECT TO_NUMBER(TO_CHAR(H_R_Date,'J')),
         1,
         Org_ID,
         Supplier_ID,
         Invoice_ID,
         DECODE(Rec_Type, 'H', FII_AP_HOLD_HIST_B_S.NEXTVAL, NULL),
         rec_type,
         H_R_Date,
         g_fii_user_id Created_By,
         sysdate Creation_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Last_Update_Date,
         g_fii_login_id Last_Update_Login
  FROM
  (SELECT /*+ NO_EXPAND ordered use_nl(AH,AI) */ DISTINCT AI.Org_ID,
          AI.Supplier_ID,
          AI.Invoice_ID,
          TRUNC(DECODE(RT.Rec_Type, 'H', AH.Hold_Date, AH.Last_Update_Date)) H_R_Date,
          RT.Rec_Type
   FROM  (SELECT /*+ no_merge index(lt) */ distinct Key_Value1_Num
		   FROM   FII_AP_DBI_LOG_T lt
		   WHERE  Table_Name = 'AP_HOLDS'
		   AND    Operation_Flag IN ('I','U')) LOG,
          AP_HOLDS_ALL AH,
          FII_AP_INVOICE_B AI,
         (SELECT 'H' Rec_Type FROM DUAL WHERE dummy IS NOT NULL
          UNION ALL select 'R' Rec_Type FROM DUAL WHERE dummy IS NOT NULL) RT
   WHERE AH.Invoice_ID = LOG.Key_Value1_Num
   AND   AI.Invoice_ID = AH.Invoice_ID
   AND   AI.Cancel_Date IS NULL
   AND   AI.Invoice_Type NOT IN ('PREPAYMENT')
   AND ((RT.Rec_Type = 'H'
         AND ah.hold_date IN (SELECT min(ah1.hold_date)
                              FROM ap_holds_all ah1
                              WHERE ah1.invoice_id = ah.invoice_id
                              AND trunc(ah1.hold_date) <= decode(ah.release_lookup_code, NULL, sysdate, ah.last_update_date)
                              AND trunc(ah.hold_date) <= decode(ah1.release_lookup_code, NULL, sysdate, ah1.last_update_date)))
         OR
        (RT.Rec_Type = 'R'
         AND AH.Release_Lookup_Code IS NOT NULL
         AND AH.Last_Update_Date IN (SELECT max(ah1.last_update_date)
	                             FROM AP_HOLDS_ALL AH1
                                     WHERE AH.invoice_id=AH1.invoice_id
                                     AND trunc(ah1.hold_date)<=trunc(ah.last_update_date)
                                     AND trunc(ah.hold_date)<=decode(AH1.release_lookup_code,NULL,g_sysdate, trunc(AH1.last_update_date)))
         AND    NOT EXISTS (SELECT 'Unrelease holds'
                            FROM AP_HOLDS_ALL AH2
                            WHERE AH2.invoice_id=AH.invoice_id
                            AND trunc(AH2.hold_date)<=trunc(AH.last_update_date)
                            AND ah2.release_lookup_code IS NULL))));


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Inserted '|| SQL%ROWCOUNT ||' Hold and Release records into FII_AP_HOLD_HIST_B');
     FII_UTIL.put_line('');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;

  g_state := 'Updating the Seq_ID on the Release records';
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
                   AND    HH1.Period_Type_ID = 1
                   AND    HH1.Action_Date IN
                         (SELECT MIN(TRUNC(AH1.Hold_Date))
                          FROM   AP_Holds_ALL AH1, AP_Holds_ALL AH2
                          WHERE  AH1.Invoice_ID = HH1.Invoice_ID
                          AND    AH2.Invoice_ID = HH1.Invoice_ID
                          AND    TRUNC(AH2.Last_Update_Date) = HH.Action_Date
                          AND    AH2.Release_Lookup_Code IS NOT NULL
                          AND    TRUNC(AH1.Last_Update_Date) >= TRUNC(AH2.Hold_Date)
                          AND    AH1.Release_Lookup_Code IS NOT NULL
                          AND    TRUNC(AH1.Last_Update_Date)
                                     <= TRUNC(AH2.Last_Update_Date)))
  WHERE  HH.Action = 'R'
  AND    HH.Period_Type_ID = 1
  AND    HH.Seq_ID IS NULL;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Updated '|| SQL%ROWCOUNT ||' Release records in the FII_AP_HOLD_HIST_B');
     FII_UTIL.put_line('');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;


  g_state := 'Updating the Hold Count on the Hold and Release records';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;
/*
  UPDATE FII_AP_Hold_Hist_B HH
  SET Hold_Count = (SELECT DECODE(HH.Action,'H', COUNT(*), -1 * COUNT(*))
                    FROM   AP_Holds_ALL AH
                    WHERE  AH.Invoice_ID = HH.Invoice_ID
                    AND   (EXISTS (SELECT 'Hold Exists'
                                   FROM   FII_AP_Hold_Hist_B HH1
                                   WHERE  HH1.Invoice_ID = AH.Invoice_ID
                                   AND    HH1.Seq_ID = HH.Seq_ID
                                   AND    HH1.Period_Type_ID = 1
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
                                       AND    HH.Period_Type_ID = 1
                                       AND    HH2.Rowid <> HH.Rowid)))
  WHERE HH.Hold_Count IS NULL
  AND   HH.Period_Type_ID = 1;

*/
  UPDATE FII_AP_Hold_Hist_B HH
  SET    Supplier_ID     =  (SELECT AI.Vendor_ID
                             FROM   AP_Invoices_ALL AI
                             WHERE  AI.Invoice_ID = HH.Invoice_ID)
  WHERE  HH.Invoice_ID IN   (SELECT Key_Value1_Num
                             FROM   FII_AP_DBI_LOG_T
                             WHERE  Table_Name = 'AP_INVOICES'
                             AND    Operation_Flag = 'U');


  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Updated '|| SQL%ROWCOUNT ||' Hold Counts in the FII_AP_HOLD_HIST_B');
     FII_UTIL.put_line('');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
  end if;

/*
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('Calling procedure ROLLUP_HOLD_HISTORY');
     FII_UTIL.put_line('');
  end if;

  ROLLUP_HOLD_HISTORY;
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


------------------------------------------------------------------
-- Procedure INSERT_DELETED_REC
-- Purpose
--   This INSERT_DELETED_REC routine inserts records into
--   FII_AP_Pay_Sched_D_MS or FII_AP_Invoice_D_MS if
--   it has been deleted since the previous load.
------------------------------------------------------------------
PROCEDURE INSERT_DELETED_REC(Invoice_ID NUMBER, Payment_Num NUMBER) IS
  Deleted_Pay_Sched Pay_Sched_D_Rec;
  Deleted_Invoice   Invoice_D_Rec;
BEGIN
  g_state := 'Inside INSERT_DELETED_REC Procedure.';

  IF Invoice_ID IS NOT NULL AND Payment_Num IS NOT NULL THEN --Check if FII_AP_Pay_Sched_B_MS has any deletions.

    WHILE g_pay_sched_b_marker IS NOT NULL
    AND (FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Invoice_ID < Invoice_ID
    OR  (FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Invoice_ID = Invoice_ID
    AND  FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Num < Payment_Num)) LOOP
      Deleted_Pay_Sched.Invoice_ID := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Invoice_ID;
      Deleted_Pay_Sched.Payment_Num := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Num;
      Deleted_Pay_Sched.Action_Date := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Action_Date;
      Deleted_Pay_Sched.Action := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Action;
      Deleted_Pay_Sched.Inv_Pymt_Flag := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Inv_Pymt_Flag;
      Deleted_Pay_Sched.Unique_ID := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Unique_ID;
      FII_AP_Pay_Sched_D_MS(FII_AP_Pay_Sched_D_MS.Count+1) := Deleted_Pay_Sched;
      g_pay_sched_b_marker := FII_AP_Pay_Sched_B_MS.Next(g_pay_sched_b_marker);
    END LOOP;

  ELSIF Invoice_ID IS NOT NULL AND Payment_Num IS NULL THEN --Check if FII_AP_Invoice_B_MS has any deletions.

    WHILE g_invoice_b_marker IS NOT NULL
    AND FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_ID < Invoice_ID LOOP
     Deleted_Invoice.Invoice_ID := FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_ID;
      FII_AP_Invoice_D_MS(FII_AP_Invoice_D_MS.Count+1) := Deleted_Invoice;
      g_invoice_b_marker := FII_AP_Invoice_B_MS.Next(g_invoice_b_marker);
    END LOOP;

  ELSIF Invoice_ID IS NULL AND Payment_Num IS NULL THEN

    WHILE g_pay_sched_b_marker IS NOT NULL LOOP
      Deleted_Pay_Sched.Invoice_ID := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Invoice_ID;
      Deleted_Pay_Sched.Payment_Num := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Num;
      Deleted_Pay_Sched.Action_Date := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Action_Date;
      Deleted_Pay_Sched.Action := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Action;
      Deleted_Pay_Sched.Inv_Pymt_Flag := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Inv_Pymt_Flag;
      Deleted_Pay_Sched.Unique_ID := FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Unique_ID;
      FII_AP_Pay_Sched_D_MS(FII_AP_Pay_Sched_D_MS.Count+1) := Deleted_Pay_Sched;
      g_pay_sched_b_marker := FII_AP_Pay_Sched_B_MS.Next(g_pay_sched_b_marker);
    END LOOP;

    WHILE g_invoice_b_marker IS NOT NULL LOOP
      Deleted_Invoice.Invoice_ID := FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_ID;
      FII_AP_Invoice_D_MS(FII_AP_Invoice_D_MS.Count+1) := Deleted_Invoice;
      g_invoice_b_marker := FII_AP_Invoice_B_MS.Next(g_invoice_b_marker);
    END LOOP;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Insert_Deleted_Rec.');
  RAISE;
END Insert_Deleted_Rec;

------------------------------------------------------------------
-- Procedure INSERT_PAY_SCHED_B_REC
-- Purpose
--   This INSERT_PAY_SCHED_B_REC routine inserts records into
--   FII_AP_Pay_Sched_UI_MS and/or
--   FII_AP_Pay_Sched_D_MS by comparing the record passed as a
--   parameter with the current record in FII_AP_Pay_Sched_B_MS
--   (existing data).
------------------------------------------------------------------
PROCEDURE INSERT_PAY_SCHED_B_REC(Pay_Sched_Rec FII_AP_PAY_SCHED_B%ROWTYPE, Update_Only_Flag VARCHAR2) IS

BEGIN
  g_state := 'Inside INSERT_PAY_SCHED_B_REC Procedure.';

  IF Update_Only_Flag = 'Y' THEN
    FII_AP_Pay_Sched_UI_MS(FII_AP_Pay_Sched_UI_MS.Count+1) := Pay_Sched_Rec;
  ELSE


  IF Pay_Sched_Rec.Action = 'CREATION' THEN --This is the start of a new payment schedule, so clean up FII_AP_Pay_Sched_B_MS until this payment schedule or beyond.
    INSERT_DELETED_REC(Pay_Sched_Rec.Invoice_ID, Pay_Sched_Rec.Payment_Num);
  END IF;
  --Check if Pay_Sched_Rec exists from previous load.
  IF g_pay_sched_b_marker IS NOT NULL
  AND FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Invoice_ID = Pay_Sched_Rec.Invoice_ID
  AND FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Num = Pay_Sched_Rec.Payment_Num
  AND FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Action_Date = Pay_Sched_Rec.Action_Date
  AND FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Action = Pay_Sched_Rec.Action
  AND NVL(FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Inv_Pymt_Flag, ' ') = NVL(Pay_Sched_Rec.Inv_Pymt_Flag, ' ')
  AND NVL(FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Unique_ID, -99) = NVL(Pay_Sched_Rec.Unique_ID, -99) THEN
    --Check if Pay_Sched_Rec has been updated.
    IF FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Org_ID <> Pay_Sched_Rec.Org_ID
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Supplier_ID <> Pay_Sched_Rec.Supplier_ID
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Base_Currency_Code <> Pay_Sched_Rec.Base_Currency_Code
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Trx_Date <> Pay_Sched_Rec.Trx_Date
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Date <> Pay_Sched_Rec.Due_Date
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Amount_Remaining <> Pay_Sched_Rec.Amount_Remaining
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Amount <> Pay_Sched_Rec.Past_Due_Amount
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Discount_Available <> Pay_Sched_Rec.Discount_Available
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Discount_Taken <> Pay_Sched_Rec.Discount_Taken
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Discount_Lost <> Pay_Sched_Rec.Discount_Lost
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Amount <> Pay_Sched_Rec.Payment_Amount
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).On_Time_Payment_Amt <> Pay_Sched_Rec.On_Time_Payment_Amt
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Late_Payment_Amt <> Pay_Sched_Rec.Late_Payment_Amt
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).No_Days_Late <> Pay_Sched_Rec.No_Days_Late
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Bucket1 <> Pay_Sched_Rec.Due_Bucket1
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Bucket2 <> Pay_Sched_Rec.Due_Bucket2
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Bucket3 <> Pay_Sched_Rec.Due_Bucket3
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Bucket1 <> Pay_Sched_Rec.Past_Due_Bucket1
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Bucket2 <> Pay_Sched_Rec.Past_Due_Bucket2
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Bucket3 <> Pay_Sched_Rec.Past_Due_Bucket3
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Amount_Remaining_B <> Pay_Sched_Rec.Amount_Remaining_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Amount_B <> Pay_Sched_Rec.Past_Due_Amount_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Discount_Available_B <> Pay_Sched_Rec.Discount_Available_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Discount_Taken_B <> Pay_Sched_Rec.Discount_Taken_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Discount_Lost_B <> Pay_Sched_Rec.Discount_Lost_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Amount_B <> Pay_Sched_Rec.Payment_Amount_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).On_Time_Payment_Amt_B <> Pay_Sched_Rec.On_Time_Payment_Amt_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Late_Payment_Amt_B <> Pay_Sched_Rec.Late_Payment_Amt_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Bucket1_B <> Pay_Sched_Rec.Due_Bucket1_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Bucket2_B <> Pay_Sched_Rec.Due_Bucket2_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Due_Bucket3_B <> Pay_Sched_Rec.Due_Bucket3_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Bucket1_B <> Pay_Sched_Rec.Past_Due_Bucket1_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Bucket2_B <> Pay_Sched_Rec.Past_Due_Bucket2_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Past_Due_Bucket3_B <> Pay_Sched_Rec.Past_Due_Bucket3_B
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Amount_Remaining <> Pay_Sched_Rec.Prim_Amount_Remaining
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Past_Due_Amount <> Pay_Sched_Rec.Prim_Past_Due_Amount
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Discount_Available <> Pay_Sched_Rec.Prim_Discount_Available
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Discount_Taken <> Pay_Sched_Rec.Prim_Discount_Taken
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Discount_Lost <> Pay_Sched_Rec.Prim_Discount_Lost
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Payment_Amount <> Pay_Sched_Rec.Prim_Payment_Amount
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_On_Time_Payment_Amt <> Pay_Sched_Rec.Prim_On_Time_Payment_Amt
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Late_Payment_Amt <> Pay_Sched_Rec.Prim_Late_Payment_Amt
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Due_Bucket1 <> Pay_Sched_Rec.Prim_Due_Bucket1
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Due_Bucket2 <> Pay_Sched_Rec.Prim_Due_Bucket2
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Due_Bucket3 <> Pay_Sched_Rec.Prim_Due_Bucket3
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Past_Due_Bucket1 <> Pay_Sched_Rec.Prim_Past_Due_Bucket1
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Past_Due_Bucket2 <> Pay_Sched_Rec.Prim_Past_Due_Bucket2
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Prim_Past_Due_Bucket3 <> Pay_Sched_Rec.Prim_Past_Due_Bucket3
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Amount_Remaining <> Pay_Sched_Rec.Sec_Amount_Remaining
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Past_Due_Amount <> Pay_Sched_Rec.Sec_Past_Due_Amount
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Discount_Available <> Pay_Sched_Rec.Sec_Discount_Available
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Discount_Taken <> Pay_Sched_Rec.Sec_Discount_Taken
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Discount_Lost <> Pay_Sched_Rec.Sec_Discount_Lost
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Payment_Amount <> Pay_Sched_Rec.Sec_Payment_Amount
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_On_Time_Payment_Amt <> Pay_Sched_Rec.Sec_On_Time_Payment_Amt
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Late_Payment_Amt <> Pay_Sched_Rec.Sec_Late_Payment_Amt
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Due_Bucket1 <> Pay_Sched_Rec.Sec_Due_Bucket1
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Due_Bucket2 <> Pay_Sched_Rec.Sec_Due_Bucket2
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Due_Bucket3 <> Pay_Sched_Rec.Sec_Due_Bucket3
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Past_Due_Bucket1 <> Pay_Sched_Rec.Sec_Past_Due_Bucket1
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Past_Due_Bucket2 <> Pay_Sched_Rec.Sec_Past_Due_Bucket2
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Sec_Past_Due_Bucket3 <> Pay_Sched_Rec.Sec_Past_Due_Bucket3
    OR NVL(FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Check_ID, -99) <> NVL(Pay_Sched_Rec.Check_ID, -99)
    OR NVL(FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Payment_Method, ' ') <> NVL(Pay_Sched_Rec.Payment_Method, ' ')
    OR FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Created_By <> Pay_Sched_Rec.Created_By
    OR NVL(FII_AP_Pay_Sched_B_MS(g_pay_sched_b_marker).Check_Date, g_sysdate) <> NVL(Pay_Sched_Rec.Check_Date, g_sysdate) THEN
      --Record has changed, so update.
      FII_AP_Pay_Sched_UI_MS(FII_AP_Pay_Sched_UI_MS.Count+1) := Pay_Sched_Rec;
    END IF;

    g_pay_sched_b_marker := FII_AP_Pay_Sched_B_MS.Next(g_pay_sched_b_marker);

  ELSE --Pay_Sched_Rec does not exist in previous load, so insert.
    FII_AP_Pay_Sched_UI_MS(FII_AP_Pay_Sched_UI_MS.Count+1) := Pay_Sched_Rec;
  END IF;

  END IF; --IF Update_Only_Flag = 'Y'

EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Insert_Pay_Sched_B_Rec.');
  RAISE;

END Insert_Pay_Sched_B_Rec;

------------------------------------------------------------------
-- Procedure INSERT_INVOICE_B_REC
-- Purpose
--   This INSERT_INVOICE_B_REC routine inserts records into
--   FII_AP_Invoice_UI_MS, and/or FII_AP_Invoice_D_MS
--   by comparing the record passed as a parameter with the current
--   record in FII_AP_Invoice_B_MS (existing data).
------------------------------------------------------------------
PROCEDURE INSERT_INVOICE_B_REC(Invoice_Rec FII_AP_Invoice_B%ROWTYPE) IS

BEGIN
  g_state := 'Inside INSERT_INVOICE_B_REC Procedure.';

--  This API call is no longer necessary since we call it at the beginning of the invoice loop.
--  INSERT_DELETED_REC(Invoice_Rec.Invoice_ID, NULL);

  --Check if Invoice_Rec exists from previous load.
  IF g_invoice_b_marker IS NOT NULL
  AND FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_ID = Invoice_Rec.Invoice_ID THEN
    --Check if Invoice_Rec has been updated.
    IF FII_AP_Invoice_B_MS(g_invoice_b_marker).Org_ID <> Invoice_Rec.Org_ID
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Supplier_ID <> Invoice_Rec.Supplier_ID
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_Type <> Invoice_Rec.Invoice_Type
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_Number <> Invoice_Rec.Invoice_Number
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_Date <> Invoice_Rec.Invoice_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_Amount <> Invoice_Rec.Invoice_Amount
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Base_Amount <> Invoice_Rec.Base_Amount
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Prim_Amount <> Invoice_Rec.Prim_Amount
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Sec_Amount <> Invoice_Rec.Sec_Amount
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_Currency_Code <> Invoice_Rec.Invoice_Currency_Code
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Base_Currency_Code <> Invoice_Rec.Base_Currency_Code
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Entered_Date <> Invoice_Rec.Entered_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Payment_Currency_Code <> Invoice_Rec.Payment_Currency_Code
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Fully_Paid_Date <> Invoice_Rec.Fully_Paid_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Terms_ID <> Invoice_Rec.Terms_ID
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Source <> Invoice_Rec.Source
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).E_Invoices_Flag <> Invoice_Rec.E_Invoices_Flag
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Cancel_Flag <> Invoice_Rec.Cancel_Flag
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Cancel_Date <> Invoice_Rec.Cancel_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Dist_Count <> Invoice_Rec.Dist_Count
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Due_Date <> Invoice_Rec.Due_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Discount_Offered <> Invoice_Rec.Discount_Offered
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Discount_Offered_B <> Invoice_Rec.Discount_Offered_B
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Prim_Discount_Offered <> Invoice_Rec.Prim_Discount_Offered
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Sec_Discount_Offered <> Invoice_Rec.Sec_Discount_Offered
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).First_Hold_Date <> Invoice_Rec.First_Hold_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Exchange_Date <> Invoice_Rec.Exchange_Date
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Exchange_Rate <> Invoice_Rec.Exchange_Rate
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Exchange_Rate_Type <> Invoice_Rec.Exchange_Rate_Type
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Payment_Status_Flag <> Invoice_Rec.Payment_Status_Flag
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Payment_Cross_Rate <> Invoice_Rec.Payment_Cross_Rate
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Fully_Paid_Amount <> Invoice_Rec.Fully_Paid_Amount
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Fully_Paid_Amount_B <> Invoice_Rec.Fully_Paid_Amount_B
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Prim_Fully_Paid_Amount <> Invoice_Rec.Prim_Fully_Paid_Amount
    OR FII_AP_Invoice_B_MS(g_invoice_b_marker).Sec_Fully_Paid_Amount <> Invoice_Rec.Sec_Fully_Paid_Amount THEN

      --Record has changed, so update.
      FII_AP_Invoice_UI_MS(FII_AP_Invoice_UI_MS.Count+1) := Invoice_Rec;
    END IF;

    g_invoice_b_marker := FII_AP_Invoice_B_MS.Next(g_invoice_b_marker);

  ELSE --Invoice_Rec does not exist in previous load, so insert.
    FII_AP_Invoice_UI_MS(FII_AP_Invoice_UI_MS.Count+1) := Invoice_Rec;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Insert_Invoice_B_Rec.');
  RAISE;

END Insert_Invoice_B_Rec;


------------------------------------------------------------------
-- Procedure POPULATE_MEMORY_STRUCTURES
-- Purpose
--   This POPULATE_MEMORY_STRUCTURES routine inserts records into
--   global memory structures stored in memory.
------------------------------------------------------------------
PROCEDURE POPULATE_MEMORY_STRUCTURES IS
  l_timestamp1 BINARY_INTEGER;
  l_timestamp1_tmp BINARY_INTEGER;
BEGIN
  g_state := 'Begin populating Memory Structures.';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;

  l_timestamp1 := DBMS_UTILITY.Get_Time;
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  SELECT AI.Org_ID                    Org_ID,
         AI.Vendor_ID                 Supplier_ID,
         AI.Invoice_ID                Invoice_ID,
         AI.Invoice_Type_Lookup_Code  Invoice_Type,
         AI.Invoice_Num               Invoice_Number,
         TRUNC(AI.Invoice_Date)       Invoice_Date,
         AI.Invoice_Amount            Invoice_Amount,
         AI.Invoice_Currency_Code     Invoice_Currency_Code,
         ASP.Base_Currency_Code       Base_Currency_Code,
         TRUNC(NVL(AI.Exchange_Date, AI.Invoice_Date)) Exchange_Date,
         AI.Exchange_Rate             Exchange_Rate,
         NVL(AI.Exchange_Rate_Type, 'No Rate Type') Exchange_Rate_Type,
         TRUNC(AI.Creation_Date)      Entered_Date,
         AI.Created_By                Created_By,
         AI.Payment_Currency_Code     Payment_Currency_Code,
         AI.Payment_Status_Flag       Payment_Status_Flag,
         AI.Payment_Cross_Rate        Payment_Cross_Rate,
         AI.Terms_ID                  Terms_ID,
         AI.Source                    Source,
         CASE WHEN g_manual_sources like '%''' || to_char(upper(AI.Source)) || '''%'
              THEN 'N' ELSE 'Y' END E_Invoices_Flag,
         DECODE(AI.Cancelled_Date, NULL, 'N', 'Y') Cancel_Flag,
         AI.Cancelled_Date            Cancel_Date,
         COUNT(DISTINCT AID.Invoice_Distribution_ID) Dist_Count,
         NVL(FC.Minimum_Accountable_Unit, 0.01)  Minimum_Accountable_Unit,
         FRATES.Functional_MAU        Functional_MAU,
         FRATES.Conversion_Rate       To_Func_Rate,
         DECODE(AI.Invoice_Currency_Code, g_prim_currency, 1,
                FRATES.Conversion_Rate * RATES.Prim_Conversion_Rate) To_Prim_Rate,
         DECODE(AI.Invoice_Currency_Code, g_sec_currency, 1,
                FRATES.Conversion_Rate * RATES.Sec_Conversion_Rate) To_Sec_Rate,
         ID.Invoice_B_Flag            Invoice_B_Flag,
         ID.Pay_Sched_B_Flag          Pay_Sched_B_Flag
  BULK COLLECT INTO FII_AP_Inv_MS
  FROM FII_AP_Invoice_IDS ID,
       AP_Invoices_All AI,
       AP_Invoice_Distributions_All AID,
       AP_System_Parameters_All ASP,
       FND_Currencies FC,
       FII_AP_PS_Rates_Temp RATES,
       FII_AP_Func_Rates_Temp FRATES
  WHERE ID.Invoice_ID = AI.Invoice_ID
  AND   AI.Invoice_ID = AID.Invoice_ID (+)
  AND   AI.Org_ID = ASP.Org_ID
  AND   AI.Payment_Currency_Code = FC.Currency_Code
  AND   FRATES.To_Currency   = ASP.Base_Currency_Code
  AND   FRATES.From_Currency = AI.Payment_Currency_Code
  AND   FRATES.Trx_Date      = TRUNC(NVL(AI.Exchange_Date, AI.Invoice_Date))
  AND   DECODE(NVL(AI.Exchange_Rate_Type, 'No Rate Type'),'User', AI.Exchange_Rate,1) =
               DECODE(FRATES.Conversion_Type,'User', FRATES.Conversion_Rate,1)
  AND   FRATES.Conversion_Type    = NVL(AI.Exchange_Rate_Type, 'No Rate Type')
  AND   RATES.Functional_Currency = ASP.Base_Currency_Code
  AND   RATES.Trx_Date            = TRUNC(AI.Invoice_Date)
  AND   (ID.Invoice_B_Flag = 'Y' OR ID.Pay_Sched_B_Flag = 'Y')
  GROUP BY AI.Org_ID, AI.Vendor_ID, AI.Invoice_ID, AI.Invoice_Type_Lookup_Code, AI.Invoice_Num,
           AI.Invoice_Date, AI.Invoice_Amount, AI.Invoice_Currency_Code,
           ASP.Base_Currency_Code, AI.Exchange_Date, AI.Exchange_Rate, AI.Exchange_Rate_Type,
           AI.Creation_Date, AI.Created_By, AI.Payment_Currency_Code, AI.Payment_Status_Flag,
           AI.Payment_Cross_Rate, AI.Terms_ID, AI.Source, AI.Cancelled_Date, FC.Minimum_Accountable_Unit,
           FRATES.Functional_MAU, FRATES.Conversion_Rate, RATES.Prim_Conversion_Rate, RATES.Sec_Conversion_Rate,
           ID.Invoice_B_Flag, ID.Pay_Sched_B_Flag
  ORDER BY AI.Invoice_ID;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;


  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Invoices Memory Structure has been populated with ' || FII_AP_Inv_MS.COUNT || ' Invoices.');
    FII_UTIL.put_line('The time taken to populate the Invoices Memory Structure is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  SELECT PS.Invoice_ID                Invoice_ID,
         PS.Payment_Num               Payment_Num,
         PS.Due_Date                  Due_Date,
         PS.Discount_Date             Discount_Date,
         PS.Gross_Amount              Gross_Amount,
         PS.Second_Discount_Date      Second_Discount_Date,
         PS.Third_Discount_Date       Third_Discount_Date,
         NVL(PS.Discount_Amount_Available, 0) Discount_Amount_Available,
         NVL(PS.Second_Disc_Amt_Available, 0) Second_Disc_Amt_Available,
         NVL(PS.Third_Disc_Amt_Available, 0)  Third_Disc_Amt_Available,
         PS.Created_By                Created_By,
         NULL                         Fully_Paid_Date
  BULK COLLECT INTO FII_AP_Pay_Sched_MS
  FROM FII_AP_Invoice_IDS ID,
       AP_Payment_Schedules_All PS
  WHERE ID.Invoice_ID =  PS.Invoice_ID
  AND   (ID.Invoice_B_Flag = 'Y' OR ID.Pay_Sched_B_Flag = 'Y')
  ORDER BY PS.Invoice_ID, PS.Payment_Num;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Payment Schedules Memory Structure has been populated with ' || FII_AP_Pay_Sched_MS.COUNT || ' Payment Schedules.');
    FII_UTIL.put_line('The time taken to populate the Payment Schedules Memory Structure is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  SELECT AIP.Amount                    Amount,
         AIP.Check_ID                  Check_ID,
         AIP.Invoice_ID                Invoice_ID,
         AIP.Invoice_Payment_ID        Invoice_Payment_ID,
         AIP.Payment_Num               Payment_Num,
         AIP.Created_By                Created_By,
         AIP.Creation_Date             Creation_Date,
         NVL(AIP.Discount_Taken, 0)    Discount_Taken,
         AC.Check_Date                 Check_Date,
        DECODE(IBY_SYS_PROF_B.Processing_Type,NULL,DECODE(AC.Payment_Method_Lookup_Code, 'EFT', 'E', 'WIRE', 'E', 'M')
        ,DECODE(IBY_SYS_PROF_B.Processing_Type, 'ELECTRONIC', 'E', 'M')) Processing_Type
  BULK COLLECT INTO FII_AP_Inv_Pay_MS
  FROM FII_AP_Invoice_IDS ID,
       AP_Invoice_Payments_ALL AIP,
       AP_Checks_ALL AC,
       IBY_SYS_PMT_PROFILES_B IBY_SYS_PROF_B, --IBY CHANGE
       IBY_ACCT_PMT_PROFILES_B IBY_ACCT_PROF_B--IBY CHANGE
  WHERE ID.Invoice_ID = AIP.Invoice_ID
  AND   AIP.Check_ID = AC.Check_ID
  AND  AC.Payment_Profile_ID = IBY_ACCT_PROF_B.Payment_Profile_ID(+)--IBY CHANGE
  AND   IBY_ACCT_PROF_B.system_profile_code = IBY_SYS_PROF_B.system_profile_code(+)--IBY CHANGE
  AND   (ID.Invoice_B_Flag = 'Y' OR ID.Pay_Sched_B_Flag = 'Y')
  AND   AC.Void_Date IS NULL
  ORDER BY AIP.Invoice_ID, AIP.Payment_Num, AIP.Creation_Date;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Invoice Payments Memory Structure has been populated with ' || FII_AP_Inv_Pay_MS.COUNT || ' Invoice Payments.');
    FII_UTIL.put_line('The time taken to populate the Invoices Memory Structure is: ' || to_char(l_timestamp1_tmp/100) || ' seconds .');
  end if;



  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  SELECT /*+ USE_NL (ID, AID) */ AID.Invoice_ID              Invoice_ID,
         AID.Line_Type_Lookup_Code   Line_Type_Lookup_Code,
         SUM(AID.Amount)             Amount,
         TRUNC(AID.Creation_Date)    Creation_Date,
         MAX(AID.Invoice_Distribution_ID) Invoice_Distribution_ID --Any invoice distribution id is ok.  Just used to make the record unique.
  BULK COLLECT INTO FII_AP_WH_Tax_MS
  FROM FII_AP_Invoice_IDS ID,
       AP_Invoice_Distributions_ALL AID,
       AP_Invoice_Lines_ALL AIL
  WHERE ID.Invoice_ID = AID.Invoice_ID
  AND  AID.Invoice_ID = AIL.Invoice_ID
  AND  AID.Invoice_Line_Number = AIL.Line_Number
  AND  (ID.Invoice_B_Flag = 'Y' OR ID.Pay_Sched_B_Flag = 'Y')
  AND  (AID.Line_Type_Lookup_Code IN ('AWT') OR (AID.Line_Type_Lookup_Code IN ('NONREC_TAX', 'REC_TAX') AND AID.Prepay_Distribution_ID IS NOT NULL))
  AND  (AIL.Invoice_Includes_Prepay_Flag IS NULL OR AIL.Invoice_Includes_Prepay_Flag = 'N')
  --AND   AID.Reversal_Flag IS NULL
  AND NVL(AID.Reversal_Flag,'N') = 'N'
  GROUP BY AID.Invoice_ID, AID.Line_Type_Lookup_Code,
           TRUNC(AID.Creation_Date)
  ORDER BY AID.Invoice_ID, TRUNC(AID.Creation_Date), AID.Line_Type_Lookup_Code;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Withholding/Tax Memory Structure has been populated with ' || FII_AP_WH_Tax_MS.COUNT || ' Withholding/Tax Distributions.');
    FII_UTIL.put_line('The time taken to populate the Withholding/Tax Memory Structure is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  SELECT /*+ ORDERED USE_NL(AC) */
         TEMP2.Invoice_ID              Invoice_ID,
         -1 * SUM(TEMP2.Amount)        Amount,
         TEMP2.Creation_Date           Creation_Date,
         AC.Check_ID                   Check_ID,
         AC.Check_Date                 Check_Date,
         DECODE(IBY_SYS_PROF_B.Processing_Type,NULL,DECODE(AC.Payment_Method_Lookup_Code, 'EFT', 'E', 'WIRE', 'E', 'M')
        ,DECODE(IBY_SYS_PROF_B.Processing_Type, 'ELECTRONIC', 'E', 'M')) Processing_Type,
         -1 * SUM(TEMP2.Amount)        Unallocated_Amount
  BULK COLLECT INTO FII_AP_Prepay_Applied_MS
  FROM (SELECT /*+ NO_MERGE ORDERED USE_NL(AIP) */
               TEMP1.Invoice_ID,
               TEMP1.Creation_Date,
               TEMP1.Amount,
               MIN(AIP.Check_ID) Check_ID
        FROM (SELECT /*+ NO_MERGE ORDERED USE_NL(AID, TEMP) */
                     AID.Invoice_ID,
                     TRUNC(AID.Creation_Date) Creation_Date,
                     TEMP.Invoice_ID Prepay_Invoice_ID,
                     SUM(AID.Amount) Amount
              FROM FII_AP_Invoice_IDS ID,
                   AP_Invoice_Distributions_All AID,
                   AP_Invoice_Lines_ALL AIL,
                   AP_Invoice_Distributions_ALL TEMP
              WHERE ID.Invoice_ID = AID.Invoice_ID
              AND AID.Invoice_ID = AIL.Invoice_ID
              AND AID.Invoice_Line_Number = AIL.Line_Number
              AND (ID.Invoice_B_Flag = 'Y' OR ID.Pay_Sched_B_Flag = 'Y')
              AND AID.Line_Type_Lookup_Code = 'PREPAY'
              --AND AID.Reversal_Flag IS NULL
              AND NVL(AID.Reversal_Flag,'N') = 'N'
              AND (AIL.Invoice_Includes_Prepay_Flag IS NULL OR AIL.Invoice_Includes_Prepay_Flag = 'N')
              AND AID.Prepay_Distribution_ID = TEMP.Invoice_Distribution_ID
              GROUP BY AID.Invoice_ID, TRUNC(AID.Creation_Date), TEMP.Invoice_ID) TEMP1,
              AP_Invoice_Payments_All AIP
         WHERE TEMP1.Prepay_Invoice_ID = AIP.Invoice_ID
         GROUP BY TEMP1.Invoice_ID, TEMP1.Creation_Date, TEMP1.Prepay_Invoice_ID, TEMP1.Amount) TEMP2,
       AP_Checks_All AC,
       IBY_SYS_PMT_PROFILES_B IBY_SYS_PROF_B,--IBY CHANGE
                IBY_ACCT_PMT_PROFILES_B IBY_ACCT_PROF_B--IBY CHANGE
  WHERE TEMP2.Check_ID = AC.Check_ID
 AND    AC.Payment_Profile_ID = IBY_ACCT_PROF_B.Payment_Profile_ID(+)--IBY CHANGE
         AND    IBY_ACCT_PROF_B.system_profile_code= IBY_SYS_PROF_B.system_profile_code(+)--IBY CHANGE
  GROUP BY TEMP2.Invoice_ID, TEMP2.Creation_Date, AC.Check_ID, AC.Check_Date,
  IBY_SYS_PROF_B.Processing_Type,AC.Payment_Method_Lookup_Code

  ORDER BY TEMP2.Invoice_ID, TEMP2.Creation_Date, AC.Check_ID;


  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Prepayments Applied Memory Structure has been populated with ' || FII_AP_Prepay_Applied_MS.COUNT || ' Prepayments Applied .');
    FII_UTIL.put_line('The time taken to populate the Prepayments Applied Memory Structure is: ' || to_char(l_timestamp1_tmp/100) || ' seconds .');
  end if;






  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  /* Populate with existing data to compare to new data and reduce MV log.*/
  SELECT /*+ ordered index(PSUM, FII_AP_PAY_SCHED_B_N1) */
         PSUM.Time_ID, PSUM.Period_Type_ID, PSUM.Action_Date, PSUM.Action,
         PSUM.Update_Sequence, PSUM.Org_ID, PSUM.Supplier_ID, PSUM.Invoice_ID,
         PSUM.Base_Currency_Code, PSUM.Trx_Date, PSUM.Payment_Num, PSUM.Due_Date,
         PSUM.Amount_Remaining, PSUM.Past_Due_Amount, PSUM.Discount_Available,
         PSUM.Discount_Taken, PSUM.Discount_Lost, PSUM.Payment_Amount,
         PSUM.On_Time_Payment_Amt, PSUM.Late_Payment_Amt, PSUM.No_Days_Late,
         PSUM.Due_Bucket1, PSUM.Due_Bucket2, PSUM.Due_Bucket3, PSUM.Past_Due_Bucket1,
         PSUM.Past_Due_Bucket2, PSUM.Past_Due_Bucket3, PSUM.Amount_Remaining_B,
         PSUM.Past_Due_Amount_B, PSUM.Discount_Available_B, PSUM.Discount_Taken_B,
         PSUM.Discount_Lost_B, PSUM.Payment_Amount_B, PSUM.On_Time_Payment_Amt_B,
         PSUM.Late_Payment_Amt_B, PSUM.Due_Bucket1_B, PSUM.Due_Bucket2_B,
         PSUM.Due_Bucket3_B, PSUM.Past_Due_Bucket1_B, PSUM.Past_Due_Bucket2_B,
         PSUM.Past_Due_Bucket3_B, PSUM.Prim_Amount_Remaining, PSUM.Prim_Past_Due_Amount,
         PSUM.Prim_Discount_Available, PSUM.Prim_Discount_Taken, PSUM.Prim_Discount_Lost,
         PSUM.Prim_Payment_Amount, PSUM.Prim_On_Time_Payment_Amt,
         PSUM.Prim_Late_Payment_Amt, PSUM.Prim_Due_Bucket1, PSUM.Prim_Due_Bucket2,
         PSUM.Prim_Due_Bucket3, PSUM.Prim_Past_Due_Bucket1, PSUM.Prim_Past_Due_Bucket2,
         PSUM.Prim_Past_Due_Bucket3, PSUM.Sec_Amount_Remaining, PSUM.Sec_Past_Due_Amount,
         PSUM.Sec_Discount_Available, PSUM.Sec_Discount_Taken, PSUM.Sec_Discount_Lost,
         PSUM.Sec_Payment_Amount, PSUM.Sec_On_Time_Payment_Amt, PSUM.Sec_Late_Payment_Amt,
         PSUM.Sec_Due_Bucket1, PSUM.Sec_Due_Bucket2, PSUM.Sec_Due_Bucket3,
         PSUM.Sec_Past_Due_Bucket1, PSUM.Sec_Past_Due_Bucket2, PSUM.Sec_Past_Due_Bucket3,
         PSUM.Fully_Paid_Date, PSUM.Check_ID, PSUM.Payment_Method, PSUM.Last_Update_Date,
         PSUM.Last_Updated_By, PSUM.Creation_Date, PSUM.Created_By, PSUM.Last_Update_Login,
         PSUM.Check_Date, PSUM.Inv_Pymt_Flag, PSUM.Unique_ID
  BULK COLLECT INTO FII_AP_Pay_Sched_B_MS
  FROM FII_AP_Invoice_IDS ID,
       FII_AP_Pay_Sched_B PSUM
  WHERE ID.Invoice_ID = PSUM.Invoice_ID
  AND   (ID.Pay_Sched_B_Flag = 'Y' OR ID.Delete_Inv_Flag='Y')
  ORDER BY PSUM.Invoice_ID,
           PSUM.Payment_Num,
           PSUM.Action_Date,
           DECODE(PSUM.Action, 'CREATION', 1,
                               'DISCOUNT', 2,
                               'DUE BUCKET', 3,
                               'DUE', 3,
                               'PAST BUCKET', 3,
                               'TAX', 4,
                               'WITHHOLDING', 5,
                               'PAYMENT', 6,
                               'PREPAYMENT', 7),
           DECODE(PSUM.Inv_Pymt_Flag, NULL, 0, 'N', 1, 'Y', 2, 0),
           NVL(PSUM.Unique_ID, 0);

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Memory Structure FII_AP_Pay_Sched_B_MS has been populated with ' || FII_AP_Pay_Sched_B_MS.COUNT || ' records.');
    FII_UTIL.put_line('The time taken to populate FII_AP_Pay_Sched_B_MS is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;


  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;


  SELECT /*+ ordered index(AI, FII_AP_INVOICE_B_U1) */
         AI.Org_ID, AI.Supplier_ID, AI.Invoice_ID, AI.Invoice_Type, AI.Invoice_Number,
         AI.Invoice_Date, AI.Invoice_Amount, AI.Base_Amount, AI.Prim_Amount,
         AI.Sec_Amount, Ai.Invoice_Currency_Code, AI.Base_Currency_Code, AI.Entered_Date,
         AI.Payment_Currency_Code, AI.Fully_Paid_Date, AI.Terms_ID, AI.Source,
         AI.E_Invoices_Flag, AI.Cancel_Flag, AI.Cancel_Date, AI.Dist_Count, AI.Due_Date,
         AI.Discount_Offered, AI.Discount_Offered_B, AI.Prim_Discount_Offered,
         AI.Sec_Discount_Offered, AI.First_Hold_Date, AI.Last_Update_Date,
         AI.Last_Updated_By, AI.Creation_Date, AI.Created_By, AI.Last_Update_Login,
         AI.Exchange_Date, AI.Exchange_Rate, AI.Exchange_Rate_Type, AI.Payment_Status_Flag,
         AI.Payment_Cross_Rate, AI.Fully_Paid_Amount, AI.Fully_Paid_Amount_B,
         AI.Prim_Fully_Paid_Amount, AI.Sec_Fully_Paid_Amount
  BULK COLLECT INTO FII_AP_Invoice_B_MS
  FROM FII_AP_Invoice_IDS ID,
       FII_AP_Invoice_B AI
  WHERE ID.Invoice_ID = AI.Invoice_ID
  AND   ID.Invoice_B_Flag = 'Y'
  ORDER BY AI.Invoice_ID;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The Memory Structure FII_AP_Invoice_B_MS has been populated with ' || FII_AP_Invoice_B_MS.COUNT || ' records.');
    FII_UTIL.put_line('The time taken to populate FII_AP_Invoice_B_MS is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;


  l_timestamp1 := DBMS_UTILITY.Get_Time - l_timestamp1;

  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The time taken to populate all Memory Structures is: ' || to_char(l_timestamp1/100) || ' seconds.');
  end if;

EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Populate_Memory_Structures.');
  RAISE;

END POPULATE_MEMORY_STRUCTURES;


------------------------------------------------------------------
-- Procedure POPULATE_TABLES_FROM_MS
-- Purpose
--   This POPULATE_TABLES_FROM_MS routine inserts records into
--   tables from the respective memory structures.
------------------------------------------------------------------

PROCEDURE POPULATE_TABLES_FROM_MS IS
  l_timestamp1 BINARY_INTEGER;
  l_timestamp1_tmp BINARY_INTEGER;
BEGIN
  l_timestamp1 := DBMS_UTILITY.Get_Time;

  g_state := 'Bulk inserting into FII_AP_Invoice_D_GT from FII_AP_Invoice_D_MS.';
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  IF FII_AP_Invoice_D_MS.Count > 0 THEN
    FORALL i IN FII_AP_Invoice_D_MS.First..FII_AP_Invoice_D_MS.Last
      INSERT INTO FII_AP_Invoice_D_GT VALUES FII_AP_Invoice_D_MS(i);
  END IF;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to bulk insert into FII_AP_Invoice_D_GT is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  g_state := 'Bulk inserting into FII_AP_Invoice_UI_GT from FII_AP_Invoice_UI_MS.';
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  IF FII_AP_Invoice_UI_MS.Count > 0 THEN
    FORALL i IN FII_AP_Invoice_UI_MS.First..FII_AP_Invoice_UI_MS.Last
      INSERT INTO FII_AP_Invoice_UI_GT VALUES FII_AP_Invoice_UI_MS(i);
  END IF;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to bulk insert records into FII_AP_Invoice_UI_GT is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  g_state := 'Bulk inserting into FII_AP_Pay_Sched_D_GT from FII_AP_Pay_Sched_D_MS.';
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  IF FII_AP_Pay_Sched_D_MS.Count > 0 THEN
    FORALL i IN FII_AP_Pay_Sched_D_MS.First..FII_AP_Pay_Sched_D_MS.Last
      INSERT INTO FII_AP_Pay_Sched_D_GT VALUES FII_AP_Pay_Sched_D_MS(i);
  END IF;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to bulk insert into FII_AP_Pay_Sched_D_GT is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  g_state := 'Bulk inserting into FII_AP_Pay_Sched_UI_GT from FII_AP_Pay_Sched_UI_MS.';
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  IF FII_AP_Pay_Sched_UI_MS.Count > 0 THEN
    FORALL i IN FII_AP_Pay_Sched_UI_MS.First..FII_AP_Pay_Sched_UI_MS.Last
      INSERT INTO FII_AP_Pay_Sched_UI_GT VALUES FII_AP_Pay_Sched_UI_MS(i);
  END IF;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to bulk insert records into FII_AP_Pay_Sched_UI_GT is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;


  g_state := 'Bulk inserting into FII_AP_Aging_Bkts_B from FII_AP_Aging_Bkts_B_MS.';
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  IF FII_AP_Aging_Bkts_B_MS.Count > 0 THEN
    FORALL i IN FII_AP_Aging_Bkts_B_MS.First..FII_AP_Aging_Bkts_B_MS.Last
      INSERT INTO FII_AP_AGING_BKTS_B VALUES FII_AP_Aging_Bkts_B_MS(i);
  END IF;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to bulk insert into FII_AP_Aging_Bkts_B is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  g_state := 'Bulk inserting into FII_AP_Due_Counts_B from FII_AP_Due_Counts_B_MS.';
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  IF FII_AP_Due_Counts_B_MS.Count > 0 THEN
    FORALL i IN FII_AP_Due_Counts_B_MS.First..FII_AP_Due_Counts_B_MS.Last
      INSERT INTO FII_AP_DUE_COUNTS_B VALUES FII_AP_Due_Counts_B_MS(i);
  END IF;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to bulk insert into FII_AP_Due_Counts_B is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  l_timestamp1 := DBMS_UTILITY.Get_Time - l_timestamp1;
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The time taken to populate all Tables from Memory Structures is: ' || to_char(l_timestamp1/100) || ' seconds.');
  end if;

EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Populate_Tables_From_MS.');
  RAISE;

END Populate_Tables_From_MS;

------------------------------------------------------------------
-- Procedure MAINTAIN_PAY_SCHED_B
-- Purpose
--   This MAINTAIN_PAY_SCHED_B routine deletes deleted records,
--   updates changed records and inserts new records into base
--   summary table FII_AP_PAY_SCHED_B.
------------------------------------------------------------------

PROCEDURE MAINTAIN_PAY_SCHED_B IS
  l_timestamp1 BINARY_INTEGER;
  l_timestamp1_tmp BINARY_INTEGER;
BEGIN

  g_state := 'Deleting records from FII_AP_Pay_Sched_B.';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  l_timestamp1 := DBMS_UTILITY.Get_Time;
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  DELETE FROM FII_AP_Pay_Sched_B PSUM
  WHERE EXISTS
  (SELECT 1
   FROM FII_AP_Pay_Sched_D_GT D
   WHERE D.Invoice_ID = PSUM.Invoice_ID
   AND D.Payment_Num = PSUM.Payment_Num
   AND D.Action_Date = PSUM.Action_Date
   AND D.Action = PSUM.Action
   AND NVL(D.Inv_Pymt_Flag, ' ') = NVL(PSUM.Inv_Pymt_Flag, ' ')
   AND NVL(D.Unique_ID, -99) = NVL(PSUM.Unique_ID, -99));

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to delete records from FII_AP_Pay_Sched_B is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  g_state := 'Updating and Inserting records in FII_AP_Pay_Sched_B.';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  MERGE INTO FII_AP_Pay_Sched_B PSUM
  USING FII_AP_Pay_Sched_UI_GT UI
  ON (PSUM.Invoice_ID = UI.Invoice_ID
  AND PSUM.Payment_Num = UI.Payment_Num
  AND PSUM.Action_Date = UI.Action_Date
  AND PSUM.Action = UI.Action
  AND NVL(PSUM.Inv_Pymt_Flag, ' ') =  NVL(UI.Inv_Pymt_Flag, ' ')
  AND NVL(PSUM.Unique_ID, -99) = NVL(UI.Unique_ID, -99))
  WHEN MATCHED THEN
    UPDATE SET PSUM.Org_ID = UI.Org_ID,
               PSUM.Supplier_ID = UI.Supplier_ID,
               PSUM.Base_Currency_Code = UI.Base_Currency_Code,
               PSUM.Trx_Date = UI.Trx_Date,
               PSUM.Due_Date = UI.Due_Date,
               PSUM.Amount_Remaining = UI.Amount_Remaining,
               PSUM.Past_Due_Amount = UI.Past_Due_Amount,
               PSUM.Discount_Available = UI.Discount_Available,
               PSUM.Discount_Taken = UI.Discount_Taken,
               PSUM.Discount_Lost = UI.Discount_Lost,
               PSUM.Payment_Amount = UI.Payment_Amount,
               PSUM.On_Time_Payment_Amt = UI.On_Time_Payment_Amt,
               PSUM.Late_Payment_Amt = UI.Late_Payment_Amt,
               PSUM.No_Days_Late = UI.No_Days_Late,
               PSUM.Due_Bucket1 = UI.Due_Bucket1,
               PSUM.Due_Bucket2 = UI.Due_Bucket2,
               PSUM.Due_Bucket3 = UI.Due_Bucket3,
               PSUM.Past_Due_Bucket1 = UI.Past_Due_Bucket1,
               PSUM.Past_Due_Bucket2 = UI.Past_Due_Bucket2,
               PSUM.Past_Due_Bucket3 = UI.Past_Due_Bucket3,
               PSUM.Amount_Remaining_B = UI.Amount_Remaining_B,
               PSUM.Past_Due_Amount_B = UI.Past_Due_Amount_B,
               PSUM.Discount_Available_B = UI.Discount_Available_B,
               PSUM.Discount_Taken_B = UI.Discount_Taken_B,
               PSUM.Discount_Lost_B = UI.Discount_Lost_B,
               PSUM.Payment_Amount_B = UI.Payment_Amount_B,
               PSUM.On_Time_Payment_Amt_B = UI.On_Time_Payment_Amt_B,
               PSUM.Late_Payment_Amt_B = UI.Late_Payment_Amt_B,
               PSUM.Due_Bucket1_B = UI.Due_Bucket1_B,
               PSUM.Due_Bucket2_B = UI.Due_Bucket2_B,
               PSUM.Due_Bucket3_B = UI.Due_Bucket3_B,
               PSUM.Past_Due_Bucket1_B = UI.Past_Due_Bucket1_B,
               PSUM.Past_Due_Bucket2_B = UI.Past_Due_Bucket2_B,
               PSUM.Past_Due_Bucket3_B = UI.Past_Due_Bucket3_B,
               PSUM.Prim_Amount_Remaining = UI.Prim_Amount_Remaining,
               PSUM.Prim_Past_Due_Amount = UI.Prim_Past_Due_Amount,
               PSUM.Prim_Discount_Available = UI.Prim_Discount_Available,
               PSUM.Prim_Discount_Taken = UI.Prim_Discount_Taken,
               PSUM.Prim_Discount_Lost = UI.Prim_Discount_Lost,
               PSUM.Prim_Payment_Amount = UI.Prim_Payment_Amount,
               PSUM.Prim_On_Time_Payment_Amt = UI.Prim_On_Time_Payment_Amt,
               PSUM.Prim_Late_Payment_Amt = UI.Prim_Late_Payment_Amt,
               PSUM.Prim_Due_Bucket1 = UI.Prim_Due_Bucket1,
               PSUM.Prim_Due_Bucket2 = UI.Prim_Due_Bucket2,
               PSUM.Prim_Due_Bucket3 = UI.Prim_Due_Bucket3,
               PSUM.Prim_Past_Due_Bucket1 = UI.Prim_Past_Due_Bucket1,
               PSUM.Prim_Past_Due_Bucket2 = UI.Prim_Past_Due_Bucket2,
               PSUM.Prim_Past_Due_Bucket3 = UI.Prim_Past_Due_Bucket3,
               PSUM.Sec_Amount_Remaining = UI.Sec_Amount_Remaining,
               PSUM.Sec_Past_Due_Amount = UI.Sec_Past_Due_Amount,
               PSUM.Sec_Discount_Available = UI.Sec_Discount_Available,
               PSUM.Sec_Discount_Taken = UI.Sec_Discount_Taken,
               PSUM.Sec_Discount_Lost = UI.Sec_Discount_Lost,
               PSUM.Sec_Payment_Amount = UI.Sec_Payment_Amount,
               PSUM.Sec_On_Time_Payment_Amt = UI.Sec_On_Time_Payment_Amt,
               PSUM.Sec_Late_Payment_Amt = UI.Sec_Late_Payment_Amt,
               PSUM.Sec_Due_Bucket1 = UI.Sec_Due_Bucket1,
               PSUM.Sec_Due_Bucket2 = UI.Sec_Due_Bucket2,
               PSUM.Sec_Due_Bucket3 = UI.Sec_Due_Bucket3,
               PSUM.Sec_Past_Due_Bucket1 = UI.Sec_Past_Due_Bucket1,
               PSUM.Sec_Past_Due_Bucket2 = UI.Sec_Past_Due_Bucket2,
               PSUM.Sec_Past_Due_Bucket3 = UI.Sec_Past_Due_Bucket3,
               PSUM.Check_ID = UI.Check_ID,
               PSUM.Payment_Method = UI.Payment_Method,
               PSUM.Created_By = UI.Created_By,
               PSUM.Check_Date = UI.Check_Date,
               PSUM.Last_Update_Date = UI.Last_Update_Date
  WHEN NOT MATCHED THEN
    INSERT (PSUM.Time_ID, PSUM.Period_Type_ID, PSUM.Action_Date, PSUM.Action,
         PSUM.Update_Sequence, PSUM.Org_ID, PSUM.Supplier_ID, PSUM.Invoice_ID,
         PSUM.Base_Currency_Code, PSUM.Trx_Date, PSUM.Payment_Num, PSUM.Due_Date,
         PSUM.Amount_Remaining, PSUM.Past_Due_Amount, PSUM.Discount_Available,
         PSUM.Discount_Taken, PSUM.Discount_Lost, PSUM.Payment_Amount,
         PSUM.On_Time_Payment_Amt, PSUM.Late_Payment_Amt, PSUM.No_Days_Late,
         PSUM.Due_Bucket1, PSUM.Due_Bucket2, PSUM.Due_Bucket3, PSUM.Past_Due_Bucket1,
         PSUM.Past_Due_Bucket2, PSUM.Past_Due_Bucket3, PSUM.Amount_Remaining_B,
         PSUM.Past_Due_Amount_B, PSUM.Discount_Available_B, PSUM.Discount_Taken_B,
         PSUM.Discount_Lost_B, PSUM.Payment_Amount_B, PSUM.On_Time_Payment_Amt_B,
         PSUM.Late_Payment_Amt_B, PSUM.Due_Bucket1_B, PSUM.Due_Bucket2_B,
         PSUM.Due_Bucket3_B, PSUM.Past_Due_Bucket1_B, PSUM.Past_Due_Bucket2_B,
         PSUM.Past_Due_Bucket3_B, PSUM.Prim_Amount_Remaining, PSUM.Prim_Past_Due_Amount,
         PSUM.Prim_Discount_Available, PSUM.Prim_Discount_Taken, PSUM.Prim_Discount_Lost,
         PSUM.Prim_Payment_Amount, PSUM.Prim_On_Time_Payment_Amt,
         PSUM.Prim_Late_Payment_Amt, PSUM.Prim_Due_Bucket1, PSUM.Prim_Due_Bucket2,
         PSUM.Prim_Due_Bucket3, PSUM.Prim_Past_Due_Bucket1, PSUM.Prim_Past_Due_Bucket2,
         PSUM.Prim_Past_Due_Bucket3, PSUM.Sec_Amount_Remaining, PSUM.Sec_Past_Due_Amount,
         PSUM.Sec_Discount_Available, PSUM.Sec_Discount_Taken, PSUM.Sec_Discount_Lost,
         PSUM.Sec_Payment_Amount, PSUM.Sec_On_Time_Payment_Amt, PSUM.Sec_Late_Payment_Amt,
         PSUM.Sec_Due_Bucket1, PSUM.Sec_Due_Bucket2, PSUM.Sec_Due_Bucket3,
         PSUM.Sec_Past_Due_Bucket1, PSUM.Sec_Past_Due_Bucket2, PSUM.Sec_Past_Due_Bucket3,
         PSUM.Fully_Paid_Date, PSUM.Check_ID, PSUM.Payment_Method, PSUM.Last_Update_Date,
         PSUM.Last_Updated_By, PSUM.Creation_Date, PSUM.Created_By, PSUM.Last_Update_Login,
         PSUM.Check_Date, PSUM.Inv_Pymt_Flag, PSUM.Unique_ID)
    VALUES (UI.Time_ID, UI.Period_Type_ID, UI.Action_Date, UI.Action,
         UI.Update_Sequence, UI.Org_ID, UI.Supplier_ID, UI.Invoice_ID,
         UI.Base_Currency_Code, UI.Trx_Date, UI.Payment_Num, UI.Due_Date,
         UI.Amount_Remaining, UI.Past_Due_Amount, UI.Discount_Available,
         UI.Discount_Taken, UI.Discount_Lost, UI.Payment_Amount,
         UI.On_Time_Payment_Amt, UI.Late_Payment_Amt, UI.No_Days_Late,
         UI.Due_Bucket1, UI.Due_Bucket2, UI.Due_Bucket3, UI.Past_Due_Bucket1,
         UI.Past_Due_Bucket2, UI.Past_Due_Bucket3, UI.Amount_Remaining_B,
         UI.Past_Due_Amount_B, UI.Discount_Available_B, UI.Discount_Taken_B,
         UI.Discount_Lost_B, UI.Payment_Amount_B, UI.On_Time_Payment_Amt_B,
         UI.Late_Payment_Amt_B, UI.Due_Bucket1_B, UI.Due_Bucket2_B,
         UI.Due_Bucket3_B, UI.Past_Due_Bucket1_B, UI.Past_Due_Bucket2_B,
         UI.Past_Due_Bucket3_B, UI.Prim_Amount_Remaining, UI.Prim_Past_Due_Amount,
         UI.Prim_Discount_Available, UI.Prim_Discount_Taken, UI.Prim_Discount_Lost,
         UI.Prim_Payment_Amount, UI.Prim_On_Time_Payment_Amt,
         UI.Prim_Late_Payment_Amt, UI.Prim_Due_Bucket1, UI.Prim_Due_Bucket2,
         UI.Prim_Due_Bucket3, UI.Prim_Past_Due_Bucket1, UI.Prim_Past_Due_Bucket2,
         UI.Prim_Past_Due_Bucket3, UI.Sec_Amount_Remaining, UI.Sec_Past_Due_Amount,
         UI.Sec_Discount_Available, UI.Sec_Discount_Taken, UI.Sec_Discount_Lost,
         UI.Sec_Payment_Amount, UI.Sec_On_Time_Payment_Amt, UI.Sec_Late_Payment_Amt,
         UI.Sec_Due_Bucket1, UI.Sec_Due_Bucket2, UI.Sec_Due_Bucket3,
         UI.Sec_Past_Due_Bucket1, UI.Sec_Past_Due_Bucket2, UI.Sec_Past_Due_Bucket3,
         UI.Fully_Paid_Date, UI.Check_ID, UI.Payment_Method, UI.Last_Update_Date,
         UI.Last_Updated_By, UI.Creation_Date, UI.Created_By, UI.Last_Update_Login,
         UI.Check_Date, UI.Inv_Pymt_Flag, UI.Unique_ID);


  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to update and insert records in FII_AP_Pay_Sched_B is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  l_timestamp1 := DBMS_UTILITY.Get_Time - l_timestamp1;
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The time taken to maintain FII_AP_Pay_Sched_B is: ' || to_char(l_timestamp1/100) || ' seconds.');
  end if;


EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Maintain_Pay_Sched_B.');
  RAISE;

END Maintain_Pay_Sched_B;

------------------------------------------------------------------
-- Procedure MAINTAIN_INVOICE_B
-- Purpose
--   This MAINTAIN_INVOICE_B routine deletes deleted records,
--   updates changed records and inserts new records into base
--   summary table FII_AP_INVOICE_B.
------------------------------------------------------------------

PROCEDURE MAINTAIN_INVOICE_B IS
  l_timestamp1 BINARY_INTEGER;
  l_timestamp1_tmp BINARY_INTEGER;
BEGIN

  g_state := 'Deleting records from FII_AP_Invoice_B.';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  l_timestamp1 := DBMS_UTILITY.Get_Time;
  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  DELETE FROM FII_AP_Invoice_B AI
  WHERE EXISTS
  (SELECT 1
   FROM FII_AP_Invoice_D_GT D
   WHERE D.Invoice_ID = AI.Invoice_ID);

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to delete records from FII_AP_Invoice_B is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  g_state := 'Updating and Inserting records in FII_Invoice_B.';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line(g_state);
  end if;

  l_timestamp1_tmp := DBMS_UTILITY.Get_Time;

  MERGE INTO FII_AP_Invoice_B AI
  USING FII_AP_Invoice_UI_GT UI
  ON (AI.Invoice_ID = UI.Invoice_ID)
  WHEN MATCHED THEN
    UPDATE SET AI.Org_ID = UI.Org_ID,
               AI.Supplier_ID = UI.Supplier_ID,
               AI.Invoice_Type = UI.Invoice_Type,
               AI.Invoice_Number = UI.Invoice_Number,
               AI.Invoice_Date = UI.Invoice_Date,
               AI.Invoice_Amount = UI.Invoice_Amount,
               AI.Base_Amount = UI.Base_Amount,
               AI.Prim_Amount = UI.Prim_Amount,
               AI.Sec_Amount = UI.Sec_Amount,
               AI.Invoice_Currency_Code = UI.Invoice_Currency_Code,
               AI.Base_Currency_Code = UI.Base_Currency_Code,
               AI.Entered_Date = UI.Entered_Date,
               AI.Payment_Currency_Code = UI.Payment_Currency_Code,
               AI.Fully_Paid_Date = UI.Fully_Paid_Date,
               AI.Terms_ID = UI.Terms_ID,
               AI.Source = UI.Source,
               AI.E_Invoices_Flag = UI.E_Invoices_Flag,
               AI.Cancel_Flag = UI.Cancel_Flag,
               AI.Cancel_Date = UI.Cancel_Date,
               AI.Dist_Count = UI.Dist_Count,
               AI.Due_Date = UI.Due_Date,
               AI.Discount_Offered = UI.Discount_Offered,
               AI.Discount_Offered_B = UI.Discount_Offered_B,
               AI.Prim_Discount_Offered = UI.Prim_Discount_Offered,
               AI.Sec_Discount_Offered = UI.Sec_Discount_Offered,
               AI.First_Hold_Date = UI.First_Hold_Date,
               AI.Exchange_Date = UI.Exchange_Date,
               AI.Exchange_Rate = UI.Exchange_Rate,
               AI.Exchange_Rate_Type = UI.Exchange_Rate_Type,
               AI.Payment_Status_Flag = UI.Payment_Status_Flag,
               AI.Payment_Cross_Rate = UI.Payment_Cross_Rate,
               AI.Fully_Paid_Amount = UI.Fully_Paid_Amount,
               AI.Fully_Paid_Amount_B = UI.Fully_Paid_Amount_B,
               AI.Prim_Fully_Paid_Amount = UI.Prim_Fully_Paid_Amount,
               AI.Sec_Fully_Paid_Amount = UI.Sec_Fully_Paid_Amount,
               AI.Last_Update_Date = UI.Last_Update_Date
  WHEN NOT MATCHED THEN
    INSERT (AI.Org_ID, AI.Supplier_ID, AI.Invoice_ID, AI.Invoice_Type, AI.Invoice_Number,
         AI.Invoice_Date, AI.Invoice_Amount, AI.Base_Amount, AI.Prim_Amount,
         AI.Sec_Amount, Ai.Invoice_Currency_Code, AI.Base_Currency_Code, AI.Entered_Date,
         AI.Payment_Currency_Code, AI.Fully_Paid_Date, AI.Terms_ID, AI.Source,
         AI.E_Invoices_Flag, AI.Cancel_Flag, AI.Cancel_Date, AI.Dist_Count, AI.Due_Date,
         AI.Discount_Offered, AI.Discount_Offered_B, AI.Prim_Discount_Offered,
         AI.Sec_Discount_Offered, AI.First_Hold_Date, AI.Last_Update_Date,
         AI.Last_Updated_By, AI.Creation_Date, AI.Created_By, AI.Last_Update_Login,
         AI.Exchange_Date, AI.Exchange_Rate, AI.Exchange_Rate_Type, AI.Payment_Status_Flag,
         AI.Payment_Cross_Rate, AI.Fully_Paid_Amount, AI.Fully_Paid_Amount_B,
         AI.Prim_Fully_Paid_Amount, AI.Sec_Fully_Paid_Amount)
    VALUES (UI.Org_ID, UI.Supplier_ID, UI.Invoice_ID, UI.Invoice_Type, UI.Invoice_Number,
         UI.Invoice_Date, UI.Invoice_Amount, UI.Base_Amount, UI.Prim_Amount,
         UI.Sec_Amount, Ui.Invoice_Currency_Code, UI.Base_Currency_Code, UI.Entered_Date,
         UI.Payment_Currency_Code, UI.Fully_Paid_Date, UI.Terms_ID, UI.Source,
         UI.E_Invoices_Flag, UI.Cancel_Flag, UI.Cancel_Date, UI.Dist_Count, UI.Due_Date,
         UI.Discount_Offered, UI.Discount_Offered_B, UI.Prim_Discount_Offered,
         UI.Sec_Discount_Offered, UI.First_Hold_Date, UI.Last_Update_Date,
         UI.Last_Updated_By, UI.Creation_Date, UI.Created_By, UI.Last_Update_Login,
         UI.Exchange_Date, UI.Exchange_Rate, UI.Exchange_Rate_Type, UI.Payment_Status_Flag,
         UI.Payment_Cross_Rate, UI.Fully_Paid_Amount, UI.Fully_Paid_Amount_B,
         UI.Prim_Fully_Paid_Amount, UI.Sec_Fully_Paid_Amount);


  l_timestamp1_tmp := DBMS_UTILITY.Get_Time - l_timestamp1_tmp;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('The time taken to update and insert records in FII_AP_Invoice_B is: ' || to_char(l_timestamp1_tmp/100) || ' seconds.');
  end if;

  l_timestamp1 := DBMS_UTILITY.Get_Time - l_timestamp1;
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('The time taken to maintain FII_AP_Invoice_B is: ' || to_char(l_timestamp1/100) || ' seconds.');
  end if;


EXCEPTION
  WHEN OTHERS THEN
  FII_UTIL.put_line('Error in procedure Maintain_Invoice_B.');
  RAISE;

END Maintain_Invoice_B;

------------------------------------------------------------------
-- Procedure POPULATE_INV_PAY_SCHED_SUM
-- Purpose
--   This POPULATE_INV_PAY_SCHED_SUM routine inserts records into base
--   summary tables FII_AP_INVOICE_B, FII_AP_PAY_SCHED_B,
--   FII_AP_AGING_BKTS_B and FII_AP_DUE_COUNTS_B using data cached in memory.
------------------------------------------------------------------

PROCEDURE POPULATE_INV_PAY_SCHED_SUM IS
      l_invoice Inv_Rec;
      l_pay_sched Pay_Sched_Rec;
      l_inv_pay Inv_Pay_Rec;
      l_wh_tax WH_Tax_Rec;
      l_prepay_applied Prepay_Applied_Rec;

      l_timestamp2     BINARY_INTEGER := 0; --Used to keep track of total time to populate the memory structures for FII_AP_Pay_Sched_B.
      l_timestamp2_tmp BINARY_INTEGER;
      l_timestamp3     BINARY_INTEGER := 0; --Used to keep track of total time to populate the memory structures for FII_AP_Invoice_B.
      l_timestamp3_tmp BINARY_INTEGER;
      l_timestamp4     BINARY_INTEGER := 0; --Used to keep track of total time to populate FII_AP_Aging_Bkts_B and FII_AP_Due_Counts_B.
      l_timestamp4_tmp BINARY_INTEGER;
BEGIN

  g_state := 'Deleting existing records from FII_AP_AGING_BKTS_B';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  DELETE /*+ index(A, FII_AP_AGING_BKTS_B_N1) */ FROM FII_AP_Aging_Bkts_B A
  WHERE  Invoice_ID IN (SELECT Invoice_ID
                        FROM   FII_AP_Invoice_IDS
                        WHERE Pay_Sched_B_Flag = 'Y');

  g_state := 'Deleting existing records from FII_AP_DUE_COUNTS_B';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
  end if;

  DELETE /*+ index(A, FII_AP_DUE_COUNTS_B_N1) */ FROM FII_AP_Due_Counts_B A
  WHERE  Invoice_ID IN (SELECT Invoice_ID
                        FROM   FII_AP_Invoice_IDS
                        WHERE Pay_Sched_B_Flag = 'Y');


  g_state := 'Populating g_seq_id from fii_ap_pay_sched_b';

  SELECT fii_ap_pay_sched_b_s.nextval
  INTO   g_seq_id
  FROM   dual;


  /* Enhancement 4227813: Manual invoice sources are defined by the profile option
     'FII: Manual Invoice Sources'.  Do dummy select in order to verify that the
     format of the profile option is valid.  Correct format is: 'Source1',..,'SourceN'*/
     g_state := 'Verifying that profile option ''FII: Manual Invoice Sources'' is valid.';

     g_manual_sources := upper(g_manual_sources);
     IF g_manual_sources IS NULL THEN g_manual_sources := ''''''; END IF;
     BEGIN
     execute immediate('SELECT 1 FROM (SELECT '' '' SOURCE FROM DUAL)
                        WHERE SOURCE IN (' || g_manual_sources || ')');
     EXCEPTION
        WHEN OTHERS THEN
        RAISE g_invalid_manual_source;
     END;


--Populate Memory Structures to be Cached in Memory.
  POPULATE_MEMORY_STRUCTURES;


--Initialize global markers to traverse through Memory Structures.
  g_state := 'Initializing global markers to traverse through Memory Structures.';
  g_pay_sched_b_marker := FII_AP_Pay_Sched_B_MS.First;
  g_invoice_b_marker := FII_AP_Invoice_B_MS.First;
  l_pay_sched_marker := FII_AP_Pay_Sched_MS.First;
  l_inv_pay_marker := FII_AP_Inv_Pay_MS.First;
  l_wh_tax_marker := FII_AP_WH_Tax_MS.First;
  l_prepay_applied_marker := FII_AP_Prepay_Applied_MS.First;

g_state := 'Begin looping through Invoices Memory Structure.';
if g_debug_flag = 'Y' then
   FII_UTIL.put_line(g_state);
end if;

FOR x in 1..FII_AP_Inv_MS.COUNT LOOP
DECLARE
  FII_AP_PS_Aging_MS PS_Aging_Type;

  l_inv_f_paid_date DATE   := NULL;
  l_inv_f_paid_amt  NUMBER := 0;
  l_inv_disc_avail  NUMBER := 0;
  l_inv_due_date    DATE   := NULL;
  l_inv_has_mult_ps VARCHAR2(1) := 'N';

  l_invoice_b FII_AP_INVOICE_B%ROWTYPE;

  l_ps_aging PS_Aging_Rec;
  l_ps_aging_marker VARCHAR2(50);
  l_aging_bkts_b FII_AP_AGING_BKTS_B%ROWTYPE;
  l_due_counts_b FII_AP_DUE_COUNTS_B%ROWTYPE;

  l_inv_db1      NUMBER := 0;
  l_inv_db2      NUMBER := 0;
  l_inv_db3      NUMBER := 0;
  l_inv_pdb3     NUMBER := 0;
  l_inv_pdb2     NUMBER := 0;
  l_inv_pdb1     NUMBER := 0;
  l_inv_due      NUMBER := 0;
  l_inv_past_due NUMBER := 0;

  l_supplier_merge_flag VARCHAR2(1);

BEGIN
  l_invoice := FII_AP_Inv_MS(x);

  --Check if there has been a supplier merge.
  INSERT_DELETED_REC(l_invoice.Invoice_ID, NULL);
  If g_invoice_b_marker IS NOT NULL
  AND FII_AP_Invoice_B_MS(g_invoice_b_marker).Invoice_ID = l_invoice.Invoice_ID
  AND FII_AP_Invoice_B_MS(g_invoice_b_marker).Supplier_ID <> l_invoice.Supplier_ID THEN
    l_supplier_merge_flag := 'Y';
  ELSE l_supplier_merge_flag := 'N';
  END IF;

  g_state := 'Begin looping through the Payment Schedules Memory Structure for Invoice ' || l_invoice.Invoice_ID || ' with Invoice_B_Flag = ''' || l_invoice.Invoice_B_Flag || ''' and Pay_Sched_B_Flag = ''' || l_invoice.Pay_Sched_B_Flag || '''.';

  WHILE l_pay_sched_marker IS NOT NULL AND
    FII_AP_Pay_Sched_MS(l_pay_sched_marker).Invoice_ID = l_invoice.Invoice_ID LOOP
    DECLARE
      FII_AP_Pay_Sched_Temp_MS Pay_Sched_Temp_Type;
      l_pay_sched_temp Pay_Sched_Temp_Rec;
      l_pay_sched_temp_marker VARCHAR2(50);

      l_ps_amount_remaining NUMBER; --REQUIRED
      l_ps_disc_avail NUMBER := 0;
      l_ps_disc_lost NUMBER := 0; --REQUIRED
      l_ps_disc_taken NUMBER := 0; --REQUIRED
      l_ps_disc_recently_taken NUMBER := 0; --REQUIRED

      l_last_action_date DATE;
    BEGIN

      l_pay_sched := FII_AP_Pay_Sched_MS(l_pay_sched_marker);

      l_ps_amount_remaining := l_pay_sched.Gross_Amount;

      g_state := 'Checking Invoice_B_Flag for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

      IF l_invoice.Invoice_B_Flag = 'Y' THEN
        l_inv_disc_avail := l_inv_disc_avail + l_pay_sched.Discount_Amount_Available;
        l_inv_due_date := LEAST(NVL(l_inv_due_date, TRUNC(l_pay_sched.Due_Date)), TRUNC(l_pay_sched.Due_Date));
      END IF;

      g_state := 'Checking Pay_Sched_B_Flag for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

      IF l_invoice.Pay_Sched_B_Flag = 'Y' OR l_supplier_merge_flag = 'Y' THEN

        l_timestamp2_tmp := DBMS_UTILITY.Get_Time;

        g_state := 'Checking if multiple payment schedules exist for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_inv_has_mult_ps = 'N'
        AND FII_AP_Pay_Sched_MS.Next(l_pay_sched_marker) IS NOT NULL
        AND l_pay_sched.Invoice_ID = FII_AP_Pay_Sched_MS(FII_AP_Pay_Sched_MS.Next(l_pay_sched_marker)).Invoice_ID THEN
          l_inv_has_mult_ps := 'Y';
        END IF;

        --Insert 'CREATION' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting ''CREATION'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL THEN
          l_pay_sched_temp.Action := 'CREATION';
          l_pay_sched_temp.Action_Date := l_invoice.Entered_Date;
          l_pay_sched_temp.Number1 := l_pay_sched.Gross_Amount;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/1') := l_pay_sched_temp;
        END IF;

        --Insert first 'DISCOUNT' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting first ''DISCOUNT'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Discount_Date) + 1 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'DISCOUNT';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Discount_Date) + 1;
          l_pay_sched_temp.Number1 := 1;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/2/1') := l_pay_sched_temp;
        END IF;

        --Insert second 'DISCOUNT' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting second ''DISCOUNT'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Second_Discount_Date) + 1 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'DISCOUNT';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Second_Discount_Date) + 1;
          l_pay_sched_temp.Number1 := 2;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/2/2') := l_pay_sched_temp;
        END IF;

        --Insert third 'DISCOUNT' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting third ''DISCOUNT'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Third_Discount_Date) + 1 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'DISCOUNT';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Third_Discount_Date) + 1;
          l_pay_sched_temp.Number1 := 3;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/2/3') := l_pay_sched_temp;
        END IF;

        --Insert first 'DUE BUCKET' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting first ''DUE BUCKET'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date > g_due_bucket2
        AND TRUNC(l_pay_sched.Due_Date) - g_due_bucket2 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'DUE BUCKET';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Due_Date) - g_due_bucket2;
          l_pay_sched_temp.Number1 := 1;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/3') := l_pay_sched_temp;
        END IF;

        --Insert second 'DUE BUCKET' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting second ''DUE BUCKET'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date > g_due_bucket3
        AND TRUNC(l_pay_sched.Due_Date) - g_due_bucket3 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'DUE BUCKET';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Due_Date) - g_due_bucket3;
          l_pay_sched_temp.Number1 := 2;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/3') := l_pay_sched_temp;
        END IF;

        --Insert 'DUE' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting ''DUE'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Due_Date) >= l_invoice.Entered_Date
        AND TRUNC(l_pay_sched.Due_Date) + 1 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'DUE';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Due_Date) + 1;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/3') := l_pay_sched_temp;
        END IF;

        --Insert first 'PAST BUCKET' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting first ''PAST BUCKET'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Due_Date) + g_past_bucket3 + 1 > l_invoice.Entered_Date
        AND TRUNC(l_pay_sched.Due_Date) + g_past_bucket3 + 1 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'PAST BUCKET';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Due_Date) + g_past_bucket3 + 1;
          l_pay_sched_temp.Number1 := 1;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/3') := l_pay_sched_temp;
        END IF;

        --Insert second 'PAST BUCKET' record into FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Inserting second ''PAST BUCKET'' record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        IF l_invoice.Invoice_Type <> 'PREPAYMENT'
        AND l_invoice.Cancel_Date IS NULL
        AND TRUNC(l_pay_sched.Due_Date) + g_past_bucket2 + 1 > l_invoice.Entered_Date
        AND TRUNC(l_pay_sched.Due_Date) + g_past_bucket2 + 1 <= g_sysdate THEN
          l_pay_sched_temp.Action := 'PAST BUCKET';
          l_pay_sched_temp.Action_Date := TRUNC(l_pay_sched.Due_Date) + g_past_bucket2 + 1;
          l_pay_sched_temp.Number1 := 2;
          FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/3') := l_pay_sched_temp;
        END IF;

        l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
        l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

      END IF; --IF l_invoice.Pay_Sched_B_Flag = 'Y' ...

      g_state := 'Begin looping through the Invoice Payments Memory Structure for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

      WHILE l_inv_pay_marker IS NOT NULL
      AND FII_AP_Inv_Pay_MS(l_inv_pay_marker).Invoice_ID = l_invoice.Invoice_ID
      AND FII_AP_Inv_Pay_MS(l_inv_pay_marker).Payment_Num = l_pay_sched.Payment_Num LOOP

        l_inv_pay := FII_AP_Inv_Pay_MS(l_inv_pay_marker);

        g_state := 'Inserting invoice payment record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Invoice Payment ' || l_inv_pay.Invoice_Payment_ID || '.';


        IF l_invoice.Pay_Sched_B_Flag = 'Y' OR l_supplier_merge_flag = 'Y' THEN

          l_timestamp2_tmp := DBMS_UTILITY.Get_Time;

          IF l_invoice.Cancel_Date IS NULL THEN
            IF l_invoice.Invoice_Type = 'PREPAYMENT' THEN
              l_pay_sched_temp.Action := 'PREPAYMENT';
            ELSE l_pay_sched_temp.Action := 'PAYMENT';
            END IF;
            l_pay_sched_temp.Action_Date := TRUNC(l_inv_pay.Creation_Date);
            l_pay_sched_temp.Number1 := l_inv_pay.Amount;
            l_pay_sched_temp.Number2 := l_inv_pay.Discount_Taken;
            l_pay_sched_temp.Number3 := l_inv_pay.Created_By;
            l_pay_sched_temp.Number4 := l_inv_pay.Check_ID;
            l_pay_sched_temp.Number5 := l_inv_pay.Invoice_Payment_ID;
            l_pay_sched_temp.Date1 := l_inv_pay.Check_Date;
            l_pay_sched_temp.String1 := l_inv_pay.Processing_Type;
            FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/5/' || l_inv_pay.Invoice_Payment_ID) := l_pay_sched_temp;
          END IF;

          l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
          l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

        END IF; --IF l_invoice.Pay_Sched_B_Flag = 'Y' ...

g_state := 'Updating invoice variables with invoice payment amounts for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Invoice Payment ' || l_inv_pay.Invoice_Payment_ID || '.';

        IF l_invoice.Invoice_B_Flag = 'Y' THEN
          l_inv_f_paid_date := TRUNC(l_inv_pay.Creation_Date);
          l_inv_f_paid_amt := l_inv_f_paid_amt + l_inv_pay.Amount + l_inv_pay.Discount_Taken;
        END IF;

        l_inv_pay_marker := FII_AP_Inv_Pay_MS.Next(l_inv_pay_marker);
      END LOOP; --End of Invoice Payments Loop.

      g_state := 'Begin looping through the Withholding/Tax Memory Structure for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

      l_ps_wh_tax_marker := NULL;
      WHILE l_wh_tax_marker IS NOT NULL
      AND FII_AP_WH_Tax_MS(l_wh_tax_marker).Invoice_ID = l_invoice.Invoice_ID LOOP
        l_wh_tax := FII_AP_WH_Tax_MS(l_wh_tax_marker);

        --Mark the first wh/tax record for this invoice.  If this invoice has more payment schedules,
        --go back to the first wh/tax record and prorate amounts.  Wh/Tax is at the invoice level.
        IF l_ps_wh_tax_marker IS NULL THEN l_ps_wh_tax_marker := l_wh_tax_marker; END IF;

        g_state := 'Inserting withholding/tax record into FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Invoice Distribution ' || l_wh_tax.Invoice_Distribution_ID || '.';

        IF l_invoice.Pay_Sched_B_Flag = 'Y' OR l_supplier_merge_flag = 'Y' THEN

          l_timestamp2_tmp := DBMS_UTILITY.Get_Time;

          IF --l_invoice.Invoice_Type <> 'PREPAYMENT' AND
            l_invoice.Cancel_Date IS NULL THEN
            IF l_wh_tax.Line_Type_Lookup_Code = 'AWT' THEN
              l_pay_sched_temp.Action := 'WITHHOLDING';
            ELSE l_pay_sched_temp.Action := 'TAX';
            END IF;
            l_pay_sched_temp.Action_Date := TRUNC(l_wh_tax.Creation_Date);
            IF l_invoice.Invoice_Amount = 0 THEN
              l_pay_sched_temp.Number1 := 0;
            ELSE l_pay_sched_temp.Number1 := l_pay_sched.Gross_Amount * l_wh_tax.Amount / l_invoice.Invoice_Amount;
            END IF;
            FII_AP_Pay_Sched_Temp_MS(to_char(l_pay_sched_temp.Action_Date, 'RRRR/MM/DD') || '/4/' || l_wh_tax.Invoice_Distribution_ID) := l_pay_sched_temp;
          END IF; --l_invoice.Cancel_Date IS NULL THEN ...

          l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
          l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

        END IF; --IF l_invoice.Pay_Sched_B_Flag = 'Y' ...

        l_wh_tax_marker := FII_AP_WH_Tax_MS.Next(l_wh_tax_marker);
      END LOOP; --End of Witholding/Tax Loop.

      --Only reset the wh/tax marker to the first wh/tax record for this invoice if a higher payment schedule
      --exists for this invoice and has yet to be traversed.
      g_state := 'Reseting wh/tax marker for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

      IF l_ps_wh_tax_marker IS NOT NULL
      AND FII_AP_Pay_Sched_MS.Next(l_pay_sched_marker) IS NOT NULL
      AND l_pay_sched.Invoice_ID = FII_AP_Pay_Sched_MS(FII_AP_Pay_Sched_MS.Next(l_pay_sched_marker)).Invoice_ID THEN
        l_wh_tax_marker := l_ps_wh_tax_marker;
      END IF;


      IF l_invoice.Pay_Sched_B_Flag = 'Y' OR l_supplier_merge_flag = 'Y' THEN

        l_timestamp2_tmp := DBMS_UTILITY.Get_Time;

        --Loop through FII_AP_Pay_Sched_Temp_MS.
        g_state := 'Looping through the temporary memory structure FII_AP_Pay_Sched_Temp_MS for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

        l_pay_sched_temp_marker := FII_AP_Pay_Sched_Temp_MS.First;

        WHILE l_pay_sched_temp_marker IS NOT NULL OR
              --If the last action for a payment schedule is a prepayment applied.
             (l_prepay_applied_marker IS NOT NULL
              AND FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Invoice_ID = l_invoice.Invoice_ID
--This is an assumption anyway.
              AND TRUNC(FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Creation_Date) >= NVL(l_last_Action_Date, TRUNC(FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Creation_Date))
              AND l_ps_amount_remaining <> 0) LOOP
          DECLARE
            l_pay_sched_temp Pay_Sched_Temp_Rec;
            l_pay_sched_b FII_AP_PAY_SCHED_B%ROWTYPE;

            l_ps_db1  NUMBER := 0;
            l_ps_db2  NUMBER := 0;
            l_ps_db3  NUMBER := 0;
            l_ps_pdb3 NUMBER := 0;
            l_ps_pdb2 NUMBER := 0;
            l_ps_pdb1 NUMBER := 0;
          BEGIN
            IF l_pay_sched_temp_marker IS NOT NULL THEN
              l_pay_sched_temp := FII_AP_Pay_Sched_Temp_MS(l_pay_sched_temp_marker);
            END IF;

            g_state := 'Deciding what action to insert for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

            --Check if a Prepayment Applied 'PAYMENT' record should be inserted first.
            IF l_pay_sched_temp_marker IS NULL OR
               (l_pay_sched_temp_marker IS NOT NULL
            AND l_prepay_applied_marker IS NOT NULL
            AND FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Invoice_ID = l_invoice.Invoice_ID
            AND ((TRUNC(FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Creation_Date)
                                                      < l_pay_sched_temp.Action_Date) OR
                 (TRUNC(FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Creation_Date)
                                                      = l_pay_sched_temp.Action_Date AND
                  l_pay_sched_temp.Action IN ('PAYMENT', 'PREPAYMENT')))
            AND l_ps_amount_remaining <> 0) THEN
              DECLARE
                l_prepay_amount         NUMBER;
                l_Amount_Remaining_T    NUMBER;
                l_Past_Due_Amount_T     NUMBER;
                l_On_Time_Payment_Amt_T NUMBER;
                l_Late_Payment_Amt_T    NUMBER;
                l_Payment_Amount_T      NUMBER;
                l_Due_Bucket1_T         NUMBER;
                l_Due_Bucket2_T         NUMBER;
                l_Due_Bucket3_T         NUMBER;
                l_Past_Due_Bucket1_T    NUMBER;
                l_Past_Due_Bucket2_T    NUMBER;
                l_Past_Due_Bucket3_T    NUMBER;
              BEGIN

                l_prepay_applied := FII_AP_Prepay_Applied_MS(l_prepay_applied_marker);

                g_state := 'Inserting prepayment applied record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

                IF l_prepay_applied.Unallocated_Amount <= l_ps_amount_remaining THEN
                  l_prepay_amount := l_prepay_applied.Unallocated_Amount;
                  l_prepay_applied_marker := FII_AP_Prepay_Applied_MS.Next(l_prepay_applied_marker);
                ELSE
                  l_prepay_applied.Unallocated_Amount := l_prepay_applied.Unallocated_Amount - l_ps_amount_remaining;
                  FII_AP_Prepay_Applied_MS(l_prepay_applied_marker) := l_prepay_applied;
                  l_prepay_amount := l_ps_amount_remaining;
                END IF;

                IF l_invoice.Invoice_B_Flag = 'Y' THEN
                  l_inv_f_paid_date := GREATEST(NVL(l_inv_f_paid_date,TRUNC(l_prepay_applied.Creation_Date)), TRUNC(l_prepay_applied.Creation_Date));
                  l_inv_f_paid_amt := l_inv_f_paid_amt + l_prepay_amount;
                END IF;

                IF l_invoice.Invoice_Type <> 'PREPAYMENT' AND l_invoice.Cancel_Date IS NULL THEN

                  l_Amount_Remaining_T := -1 * l_prepay_amount;
                  IF TRUNC(l_pay_sched.Due_Date) - TRUNC(l_prepay_applied.Creation_Date) < 0 THEN
                    l_Past_Due_Amount_T := -1 * l_prepay_amount;
                    l_On_Time_Payment_Amt_T := 0;
                    l_Late_Payment_Amt_T := l_prepay_amount;
                    l_pay_sched_b.No_Days_Late := TRUNC(l_prepay_applied.Creation_Date) - TRUNC(l_pay_sched.Due_Date);
                  ELSE l_Past_Due_Amount_T := 0;
                       l_On_Time_Payment_Amt_T := l_prepay_amount;
                       l_Late_Payment_Amt_T := 0;
                       l_pay_sched_b.No_Days_Late := 0;
                  END IF;
                  l_Payment_Amount_T := l_prepay_amount;

                  IF TRUNC(l_pay_sched.Due_Date) - TRUNC(l_prepay_applied.Creation_Date) >= g_due_bucket1 THEN
                    l_Due_Bucket1_T := -1 * l_prepay_amount;
                    l_ps_db1 := -1;
                  ELSE l_Due_Bucket1_T := 0;
                  END IF;

                  IF TRUNC(l_pay_sched.Due_Date) - TRUNC(l_prepay_applied.Creation_Date) <= g_due_bucket2
                  AND TRUNC(l_pay_sched.Due_Date) - TRUNC(l_prepay_applied.Creation_Date) > g_due_bucket3 THEN
                    l_Due_Bucket2_T := -1 * l_prepay_amount;
                    l_ps_db2 := -1;
                  ELSE l_Due_Bucket2_T := 0;
                  END IF;

                  IF TRUNC(l_pay_sched.Due_Date) - TRUNC(l_prepay_applied.Creation_Date) <= g_due_bucket3
                  AND TRUNC(l_pay_sched.Due_Date) - TRUNC(l_prepay_applied.Creation_Date) >= 0 THEN
                    l_Due_Bucket3_T := -1 * l_prepay_amount;
                    l_ps_db3 := -1;
                  ELSE l_Due_Bucket3_T := 0;
                  END IF;

                  IF TRUNC(l_prepay_applied.Creation_Date) - TRUNC(l_pay_sched.Due_Date) >= g_past_bucket1 THEN
                    l_Past_Due_Bucket1_T := -1 * l_prepay_amount;
                    l_ps_pdb1 := -1;
                  ELSE l_Past_Due_Bucket1_T := 0;
                  END IF;

                  IF TRUNC(l_prepay_applied.Creation_Date) - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket2
                  AND TRUNC(l_prepay_applied.Creation_Date) - TRUNC(l_pay_sched.Due_Date) > g_past_bucket3 THEN
                    l_Past_Due_Bucket2_T := -1 * l_prepay_amount;
                    l_ps_pdb2 := -1;
                  ELSE l_Past_Due_Bucket2_T := 0;
                  END IF;

                  IF TRUNC(l_prepay_applied.Creation_Date) - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket3
                  AND TRUNC(l_prepay_applied.Creation_Date) - TRUNC(l_pay_sched.Due_Date) > 0 THEN
                    l_Past_Due_Bucket3_T := -1 * l_prepay_amount;
                    l_ps_pdb3 := -1;
                  ELSE l_Past_Due_Bucket3_T := 0;
                  END IF;

                  l_pay_sched_b.Time_ID := To_Number(To_Char(TRUNC(l_prepay_applied.Creation_Date), 'J'));
                  l_pay_sched_b.Period_Type_ID := 1;
                  l_pay_sched_b.Action_Date := TRUNC(l_prepay_applied.Creation_Date);
                  l_pay_sched_b.Action := 'PAYMENT';
                  l_pay_sched_b.Update_Sequence := g_seq_id;
                  l_pay_sched_b.Org_ID := l_invoice.Org_ID;
                  l_pay_sched_b.Supplier_ID := l_invoice.Supplier_ID;
                  l_pay_sched_b.Invoice_ID := l_invoice.Invoice_ID;
                  l_pay_sched_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
                  l_pay_sched_b.Trx_Date := l_invoice.Invoice_Date;
                  l_pay_sched_b.Payment_Num := l_pay_sched.Payment_Num;
                  l_pay_sched_b.Due_Date := TRUNC(l_pay_sched.Due_Date);
                  l_pay_sched_b.Amount_Remaining := ROUND(l_Amount_Remaining_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Amount := ROUND(l_Past_Due_Amount_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Discount_Available := 0;
                  l_pay_sched_b.Discount_Taken := 0;
                  l_pay_sched_b.Discount_Lost := 0;
                  l_pay_sched_b.Payment_Amount := ROUND(l_Payment_Amount_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.On_Time_Payment_Amt := ROUND(l_On_Time_Payment_Amt_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Late_Payment_Amt := ROUND(l_Late_Payment_Amt_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket1 := ROUND(l_Due_Bucket1_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket2 := ROUND(l_Due_Bucket2_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket3 := ROUND(l_Due_Bucket3_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket1 := ROUND(l_Past_Due_Bucket1_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket2 := ROUND(l_Past_Due_Bucket2_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket3 := ROUND(l_Past_Due_Bucket3_T / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Amount_Remaining_B := ROUND((l_Amount_Remaining_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Amount_B := ROUND((l_Past_Due_Amount_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Discount_Available_B := 0;
                  l_pay_sched_b.Discount_Taken_B := 0;
                  l_pay_sched_b.Discount_Lost_B := 0;
                  l_pay_sched_b.Payment_Amount_B := ROUND((l_Payment_Amount_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.On_Time_Payment_Amt_B := ROUND((l_On_Time_Payment_Amt_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Late_Payment_Amt_B := ROUND((l_Late_Payment_Amt_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket1_B := ROUND((l_Due_Bucket1_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket2_B := ROUND((l_Due_Bucket2_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket3_B := ROUND((l_Due_Bucket3_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket1_B := ROUND((l_Past_Due_Bucket1_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket2_B := ROUND((l_Past_Due_Bucket2_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket3_B := ROUND((l_Past_Due_Bucket3_T * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Amount_Remaining := ROUND((l_Amount_Remaining_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Past_Due_Amount := ROUND((l_Past_Due_Amount_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Discount_Available := 0;
                  l_pay_sched_b.Prim_Discount_Taken := 0;
                  l_pay_sched_b.Prim_Discount_Lost := 0;
                  l_pay_sched_b.Prim_Payment_Amount := ROUND((l_Payment_Amount_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_On_Time_Payment_Amt := ROUND((l_On_Time_Payment_Amt_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Late_Payment_Amt := ROUND((l_Late_Payment_Amt_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Due_Bucket1 := ROUND((l_Due_Bucket1_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Due_Bucket2 := ROUND((l_Due_Bucket2_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Due_Bucket3 := ROUND((l_Due_Bucket3_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Past_Due_Bucket1 := ROUND((l_Past_Due_Bucket1_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Past_Due_Bucket2 := ROUND((l_Past_Due_Bucket2_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Prim_Past_Due_Bucket3 := ROUND((l_Past_Due_Bucket3_T * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Amount_Remaining := ROUND((l_Amount_Remaining_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Past_Due_Amount := ROUND((l_Past_Due_Amount_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Discount_Available := 0;
                  l_pay_sched_b.Sec_Discount_Taken := 0;
                  l_pay_sched_b.Sec_Discount_Lost := 0;
                  l_pay_sched_b.Sec_Payment_Amount := ROUND((l_Payment_Amount_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_On_Time_Payment_Amt := ROUND((l_On_Time_Payment_Amt_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Late_Payment_Amt := ROUND((l_Late_Payment_Amt_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Due_Bucket1 := ROUND((l_Due_Bucket1_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Due_Bucket2 := ROUND((l_Due_Bucket2_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Due_Bucket3 := ROUND((l_Due_Bucket3_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Past_Due_Bucket1 := ROUND((l_Past_Due_Bucket1_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Past_Due_Bucket2 := ROUND((l_Past_Due_Bucket2_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  l_pay_sched_b.Sec_Past_Due_Bucket3 := ROUND((l_Past_Due_Bucket3_T * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                  IF l_ps_amount_remaining + l_pay_sched_b.Amount_Remaining = 0 THEN
                    l_pay_sched_b.Fully_Paid_Date := l_pay_sched_b.Action_Date;
                  ELSE l_pay_sched_b.Fully_Paid_Date := NULL;
                  END IF;
                  l_pay_sched_b.Check_ID := l_prepay_applied.Check_ID;
                  --IBY CHANGE
                  IF l_prepay_applied.Processing_Type IN ('ELECTRONIC') OR l_prepay_applied.Processing_Type IN ('EFT') OR l_prepay_applied.Processing_Type IN ('WIRE') THEN
                    l_pay_sched_b.Payment_Method := 'E';
                  ELSE l_pay_sched_b.Payment_Method := 'M';
                  END IF;
                  l_pay_sched_b.Last_Update_Date := sysdate;
                  l_pay_sched_b.Last_Updated_By := g_fii_user_id;
                  l_pay_sched_b.Creation_Date := sysdate;
                  l_pay_sched_b.Created_By := l_pay_sched.Created_By;
                  l_pay_sched_b.Last_Update_Login := g_fii_login_id;
                  l_pay_sched_b.Check_Date := l_prepay_applied.Check_Date;
                  l_pay_sched_b.Inv_Pymt_Flag := 'N';
                  l_pay_sched_b.Unique_ID := l_prepay_applied.Check_ID;


                  l_ps_amount_remaining := l_ps_amount_remaining + l_pay_sched_b.Amount_Remaining;
                  l_last_action_date := l_pay_sched_b.Action_Date;

                  IF l_invoice.Pay_Sched_B_Flag = 'N' AND l_supplier_merge_flag = 'Y' THEN
                    Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'Y');
                  ELSE Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'N');
                  END IF;

                  IF l_ps_amount_remaining = 0 THEN
                    l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
                    l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

                    l_timestamp4_tmp := DBMS_UTILITY.Get_Time;

                  g_state := 'Updating aging buckets memory structure(s) with applied prepayment for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

                    IF l_inv_has_mult_ps = 'N' THEN
                      l_aging_bkts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                      l_aging_bkts_b.Period_Type_ID := 1;
                      l_aging_bkts_b.Org_ID := l_invoice.Org_ID;
                      l_aging_bkts_b.Supplier_ID := l_invoice.Supplier_ID;
                      l_aging_bkts_b.Invoice_ID := l_invoice.Invoice_ID;
                      l_aging_bkts_b.Action_Date := l_pay_sched_b.Action_Date;
                      l_aging_bkts_b.Due_Bucket1_Cnt := l_ps_db1;
                      l_aging_bkts_b.Due_Bucket2_Cnt := l_ps_db2;
                      l_aging_bkts_b.Due_Bucket3_Cnt := l_ps_db3;
                      l_aging_bkts_b.Past_Due_Bucket3_Cnt := l_ps_pdb3;
                      l_aging_bkts_b.Past_Due_Bucket2_Cnt := l_ps_pdb2;
                      l_aging_bkts_b.Past_Due_Bucket1_Cnt := l_ps_pdb1;
                      l_aging_bkts_b.Last_Update_Date := sysdate;
                      l_aging_bkts_b.Last_Updated_By := g_fii_user_id;
                      l_aging_bkts_b.Creation_Date := sysdate;
                      l_aging_bkts_b.Created_By := g_fii_user_id;
                      l_aging_bkts_b.Last_Update_Login := g_fii_login_id;
                      FII_AP_Aging_Bkts_B_MS(FII_AP_Aging_Bkts_B_MS.Count+1) := l_aging_bkts_b;

                      l_due_counts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                      l_due_counts_b.Period_Type_ID := 1;
                      l_due_counts_b.Org_ID := l_invoice.Org_ID;
                      l_due_counts_b.Supplier_ID := l_invoice.Supplier_ID;
                      l_due_counts_b.Invoice_ID := l_invoice.Invoice_ID;
                      l_due_counts_b.Action_Date := l_pay_sched_b.Action_Date;
                      l_due_counts_b.Due_Cnt := l_ps_db1 + l_ps_db2 + l_ps_db3;
                      l_due_counts_b.Past_Due_Cnt := l_ps_pdb1 + l_ps_pdb2 + l_ps_pdb3;
                      l_due_counts_b.Last_Update_Date := sysdate;
                      l_due_counts_b.Last_Updated_By := g_fii_user_id;
                      l_due_counts_b.Creation_Date := sysdate;
                      l_due_counts_b.Created_By := g_fii_user_id;
                      l_due_counts_b.Last_Update_Login := g_fii_login_id;
                      FII_AP_Due_Counts_B_MS(FII_AP_Due_Counts_B_MS.Count+1) := l_due_counts_b;

                    ELSE
                      BEGIN
                        l_ps_aging := FII_AP_PS_Aging_MS(to_char(l_pay_sched_b.Action_Date, 'RRRR/MM/DD'));

                        l_ps_aging.Action_Date := l_ps_aging.Action_Date;
                        l_ps_aging.Due_Bucket1 := l_ps_aging.Due_Bucket1 + l_ps_db1;
                        l_ps_aging.Due_Bucket2 := l_ps_aging.Due_Bucket2 + l_ps_db2;
                        l_ps_aging.Due_Bucket3 := l_ps_aging.Due_Bucket3 + l_ps_db3;
                        l_ps_aging.Past_Due_Bucket3 := l_ps_aging.Past_Due_Bucket3 + l_ps_pdb3;
                        l_ps_aging.Past_Due_Bucket2 := l_ps_aging.Past_Due_Bucket2 + l_ps_pdb2;
                        l_ps_aging.Past_Due_Bucket1 := l_ps_aging.Past_Due_Bucket1 + l_ps_pdb1;
                        FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                      EXCEPTION
                        WHEN NO_DATA_FOUND THEN

                          l_ps_aging.Action_Date := l_pay_sched_b.Action_Date;
                          l_ps_aging.Due_Bucket1 := l_ps_db1;
                          l_ps_aging.Due_Bucket2 := l_ps_db2;
                          l_ps_aging.Due_Bucket3 := l_ps_db3;
                          l_ps_aging.Past_Due_Bucket3 := l_ps_pdb3;
                          l_ps_aging.Past_Due_Bucket2 := l_ps_pdb2;
                          l_ps_aging.Past_Due_Bucket1 := l_ps_pdb1;
                          FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                        WHEN OTHERS THEN
                          FII_UTIL.put_line('Error occured while inserting applied prepayment record into FII_AP_Aging_MS.');
                          RAISE;
                      END;
                    END IF; --IF l_inv_has_mult_ps = 'N' THEN

                    l_timestamp4_tmp := DBMS_UTILITY.Get_Time - l_timestamp4_tmp;
                    l_timestamp4 := l_timestamp4 + l_timestamp4_tmp;

                    l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;

                  END IF; --IF l_ps_amount_remaining = 0 THEN
                ELSIF l_invoice.Invoice_Type = 'PREPAYMENT' AND l_invoice.Cancel_Date IS NULL THEN
                  l_ps_amount_remaining := l_ps_amount_remaining + ROUND(-1 * l_prepay_amount / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                END IF; --IF l_invoice.Invoice_Type <> 'PREPAYMENT' AND l_invoice.Cancel_Date IS NULL THEN
              END;
            --Do not insert a Prepayment Applied 'PAYMENT', so insert a record from FII_AP_Pay_Sched_Temp_MS.
            ELSIF l_pay_sched_temp.Action = 'CREATION' THEN
              g_state := 'Inserting ''CREATION'' record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';

              l_pay_sched_b.Time_ID := To_Number(To_Char(l_pay_sched_temp.Action_Date, 'J'));
              l_pay_sched_b.Period_Type_ID := 1;
              l_pay_sched_b.Action_Date := l_pay_sched_temp.Action_Date;
              l_pay_sched_b.Action := l_pay_sched_temp.Action;
              l_pay_sched_b.Update_Sequence := g_seq_id;
              l_pay_sched_b.Org_ID := l_invoice.Org_ID;
              l_pay_sched_b.Supplier_ID := l_invoice.Supplier_ID;
              l_pay_sched_b.Invoice_ID := l_invoice.Invoice_ID;
              l_pay_sched_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
              l_pay_sched_b.Trx_Date := l_invoice.Invoice_Date;
              l_pay_sched_b.Payment_Num := l_pay_sched.Payment_Num;
              l_pay_sched_b.Due_Date := TRUNC(l_pay_sched.Due_Date);
              l_pay_sched_b.Amount_Remaining := l_pay_sched.Gross_Amount;
              IF TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date < 0 THEN
                l_pay_sched_b.Past_Due_Amount := l_pay_sched.Gross_Amount;
              ELSE l_pay_sched_b.Past_Due_Amount := 0;
              END IF;
              l_pay_sched_b.Discount_Available := l_pay_sched.Discount_Amount_Available;
              l_pay_sched_b.Discount_Taken := 0;
              l_pay_sched_b.Discount_Lost := 0;
              l_pay_sched_b.Payment_Amount := 0;
              l_pay_sched_b.On_Time_Payment_Amt := 0;
              l_pay_sched_b.Late_Payment_Amt := 0;
              l_pay_sched_b.No_Days_Late := 0;

              IF TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date >= g_due_bucket1 THEN
                l_pay_sched_b.Due_Bucket1 := l_pay_sched.Gross_Amount;
                l_ps_db1 := 1;
              ELSE l_pay_sched_b.Due_Bucket1 := 0;
              END IF;

              IF TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date <= g_due_bucket2
              AND TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date > g_due_bucket3 THEN
                l_pay_sched_b.Due_Bucket2 := l_pay_sched.Gross_Amount;
                l_ps_db2 := 1;
              ELSE l_pay_sched_b.Due_Bucket2 := 0;
              END IF;

              IF TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date <= g_due_bucket3
              AND TRUNC(l_pay_sched.Due_Date) - l_invoice.Entered_Date >= 0 THEN
                l_pay_sched_b.Due_Bucket3 := l_pay_sched.Gross_Amount;
                l_ps_db3 := 1;
              ELSE l_pay_sched_b.Due_Bucket3 := 0;
              END IF;

              IF l_invoice.Entered_Date - TRUNC(l_pay_sched.Due_Date) >= g_past_bucket1 THEN
                l_pay_sched_b.Past_Due_Bucket1 := l_pay_sched.Gross_Amount;
                l_ps_pdb1 := 1;
              ELSE l_pay_sched_b.Past_Due_Bucket1 := 0;
              END IF;

              IF l_invoice.Entered_Date - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket2
              AND l_invoice.Entered_Date - TRUNC(l_pay_sched.Due_Date) > g_past_bucket3 THEN
                l_pay_sched_b.Past_Due_Bucket2 := l_pay_sched.Gross_Amount;
                l_ps_pdb2 := 1;
              ELSE l_pay_sched_b.Past_Due_Bucket2 := 0;
              END IF;

              IF l_invoice.Entered_Date - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket3
              AND l_invoice.Entered_Date - TRUNC(l_pay_sched.Due_Date) > 0 THEN
                l_pay_sched_b.Past_Due_Bucket3 := l_pay_sched.Gross_Amount;
                l_ps_pdb3 := 1;
              ELSE l_pay_sched_b.Past_Due_Bucket3 := 0;
              END IF;

              l_pay_sched_b.Amount_Remaining_B := ROUND((l_pay_sched_b.Amount_Remaining * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Amount_B := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Discount_Available_B := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Discount_Taken_B := 0;
              l_pay_sched_b.Discount_Lost_B := 0;
              l_pay_sched_b.Payment_Amount_B := 0;
              l_pay_sched_b.On_Time_Payment_Amt_B := 0;
              l_pay_sched_b.Late_Payment_Amt_B := 0;
              l_pay_sched_b.Due_Bucket1_B := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Due_Bucket2_B := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Due_Bucket3_B := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Bucket1_B := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Bucket2_B := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Bucket3_B := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Prim_Amount_Remaining := ROUND((l_pay_sched_b.Amount_Remaining * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Amount := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Discount_Available := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Discount_Taken := 0;
              l_pay_sched_b.Prim_Discount_Lost := 0;
              l_pay_sched_b.Prim_Payment_Amount := 0;
              l_pay_sched_b.Prim_On_Time_Payment_Amt := 0;
              l_pay_sched_b.Prim_Late_Payment_Amt := 0;
              l_pay_sched_b.Prim_Due_Bucket1 := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Due_Bucket2 := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Due_Bucket3 := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Bucket1 := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Bucket2 := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Bucket3 := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Sec_Amount_Remaining := ROUND((l_pay_sched_b.Amount_Remaining * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Amount := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Discount_Available := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Discount_Taken := 0;
              l_pay_sched_b.Sec_Discount_Lost := 0;
              l_pay_sched_b.Sec_Payment_Amount := 0;
              l_pay_sched_b.Sec_On_Time_Payment_Amt := 0;
              l_pay_sched_b.Sec_Late_Payment_Amt := 0;
              l_pay_sched_b.Sec_Due_Bucket1 := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Due_Bucket2 := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Due_Bucket3 := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Bucket1 := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Bucket2 := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Bucket3 := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Fully_Paid_Date := NULL;
              l_pay_sched_b.Check_ID := NULL;
              l_pay_sched_b.Payment_Method := NULL;
              l_pay_sched_b.Last_Update_Date := sysdate;
              l_pay_sched_b.Last_Updated_By := g_fii_user_id;
              l_pay_sched_b.Creation_Date := sysdate;
              l_pay_sched_b.Created_By := l_pay_sched.Created_By;
              l_pay_sched_b.Last_Update_Login := g_fii_login_id;
              l_pay_sched_b.Check_Date := NULL;


              l_ps_disc_avail := l_ps_disc_avail + l_pay_sched_b.Discount_Available;
              l_last_action_date := l_pay_sched_b.Action_Date;

              IF l_invoice.Pay_Sched_B_Flag = 'N' AND l_supplier_merge_flag = 'Y' THEN
                    Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'Y');
                  ELSE Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'N');
              END IF;

              l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
              l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

              l_timestamp4_tmp := DBMS_UTILITY.Get_Time;

              g_state := 'Updating aging buckets memory structure(s) with creation record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';
              IF l_inv_has_mult_ps = 'N' THEN
                l_aging_bkts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                l_aging_bkts_b.Period_Type_ID := 1;
                l_aging_bkts_b.Org_ID := l_invoice.Org_ID;
                l_aging_bkts_b.Supplier_ID := l_invoice.Supplier_ID;
                l_aging_bkts_b.Invoice_ID := l_invoice.Invoice_ID;
                l_aging_bkts_b.Action_Date := l_pay_sched_b.Action_Date;
                l_aging_bkts_b.Due_Bucket1_Cnt := l_ps_db1;
                l_aging_bkts_b.Due_Bucket2_Cnt := l_ps_db2;
                l_aging_bkts_b.Due_Bucket3_Cnt := l_ps_db3;
                l_aging_bkts_b.Past_Due_Bucket3_Cnt := l_ps_pdb3;
                l_aging_bkts_b.Past_Due_Bucket2_Cnt := l_ps_pdb2;
                l_aging_bkts_b.Past_Due_Bucket1_Cnt := l_ps_pdb1;
                l_aging_bkts_b.Last_Update_Date := sysdate;
                l_aging_bkts_b.Last_Updated_By := g_fii_user_id;
                l_aging_bkts_b.Creation_Date := sysdate;
                l_aging_bkts_b.Created_By := g_fii_user_id;
                l_aging_bkts_b.Last_Update_Login := g_fii_login_id;
                FII_AP_Aging_Bkts_B_MS(FII_AP_Aging_Bkts_B_MS.Count+1) := l_aging_bkts_b;

                l_due_counts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                l_due_counts_b.Period_Type_ID := 1;
                l_due_counts_b.Org_ID := l_invoice.Org_ID;
                l_due_counts_b.Supplier_ID := l_invoice.Supplier_ID;
                l_due_counts_b.Invoice_ID := l_invoice.Invoice_ID;
                l_due_counts_b.Action_Date := l_pay_sched_b.Action_Date;
                l_due_counts_b.Due_Cnt := l_ps_db1 + l_ps_db2 + l_ps_db3;
                l_due_counts_b.Past_Due_Cnt := l_ps_pdb1 + l_ps_pdb2 + l_ps_pdb3;
                l_due_counts_b.Last_Update_Date := sysdate;
                l_due_counts_b.Last_Updated_By := g_fii_user_id;
                l_due_counts_b.Creation_Date := sysdate;
                l_due_counts_b.Created_By := g_fii_user_id;
                l_due_counts_b.Last_Update_Login := g_fii_login_id;
                FII_AP_Due_Counts_B_MS(FII_AP_Due_Counts_B_MS.Count+1) := l_due_counts_b;


              ELSE
                BEGIN
                  l_ps_aging := FII_AP_PS_Aging_MS(to_char(l_pay_sched_b.Action_Date, 'RRRR/MM/DD'));

                  l_ps_aging.Action_Date := l_ps_aging.Action_Date;
                  l_ps_aging.Due_Bucket1 := l_ps_aging.Due_Bucket1 + l_ps_db1;
                  l_ps_aging.Due_Bucket2 := l_ps_aging.Due_Bucket2 + l_ps_db2;
                  l_ps_aging.Due_Bucket3 := l_ps_aging.Due_Bucket3 + l_ps_db3;
                  l_ps_aging.Past_Due_Bucket3 := l_ps_aging.Past_Due_Bucket3 + l_ps_pdb3;
                  l_ps_aging.Past_Due_Bucket2 := l_ps_aging.Past_Due_Bucket2 + l_ps_pdb2;
                  l_ps_aging.Past_Due_Bucket1 := l_ps_aging.Past_Due_Bucket1 + l_ps_pdb1;
                  FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN

                    l_ps_aging.Action_Date := l_pay_sched_b.Action_Date;
                    l_ps_aging.Due_Bucket1 := l_ps_db1;
                    l_ps_aging.Due_Bucket2 := l_ps_db2;
                    l_ps_aging.Due_Bucket3 := l_ps_db3;
                    l_ps_aging.Past_Due_Bucket3 := l_ps_pdb3;
                    l_ps_aging.Past_Due_Bucket2 := l_ps_pdb2;
                    l_ps_aging.Past_Due_Bucket1 := l_ps_pdb1;
                    FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                  WHEN OTHERS THEN
                    FII_UTIL.put_line('Error occured while inserting creation record into FII_AP_Aging_MS.');
                    RAISE;
                END;
              END IF;

              l_timestamp4_tmp := DBMS_UTILITY.Get_Time - l_timestamp4_tmp;
              l_timestamp4 := l_timestamp4 + l_timestamp4_tmp;

              l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;

              l_pay_sched_temp_marker := FII_AP_Pay_Sched_Temp_MS.Next(l_pay_sched_temp_marker);

            ELSIF l_pay_sched_temp.Action = 'DISCOUNT' THEN
              IF l_ps_amount_remaining <> 0 THEN
              g_state := 'Inserting discount record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Discount Number ' || l_pay_sched_temp.Number1 || '.';

                l_pay_sched_b.Time_ID := To_Number(To_Char(l_pay_sched_temp.Action_Date, 'J'));
                l_pay_sched_b.Period_Type_ID := 1;
                l_pay_sched_b.Action_Date := l_pay_sched_temp.Action_Date;
                l_pay_sched_b.Action := l_pay_sched_temp.Action;
                l_pay_sched_b.Update_Sequence := g_seq_id;
                l_pay_sched_b.Org_ID := l_invoice.Org_ID;
                l_pay_sched_b.Supplier_ID := l_invoice.Supplier_ID;
                l_pay_sched_b.Invoice_ID := l_invoice.Invoice_ID;
                l_pay_sched_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
                l_pay_sched_b.Trx_Date := l_invoice.Invoice_Date;
                l_pay_sched_b.Payment_Num := l_pay_sched.Payment_Num;
                l_pay_sched_b.Due_Date := TRUNC(l_pay_sched.Due_Date);
                l_pay_sched_b.Amount_Remaining := 0;
                l_pay_sched_b.Past_Due_Amount := 0;
                IF l_pay_sched_temp.Number1 = 1 THEN
                  l_pay_sched_b.Discount_Available := -1 * (l_pay_sched.Discount_Amount_Available
                                                            - l_ps_disc_recently_taken
                                                            - l_pay_sched.Second_Disc_Amt_Available);
                  l_pay_sched_b.Discount_Lost := l_pay_sched.Discount_Amount_Available
                                                 - l_ps_disc_recently_taken
                                                 - l_pay_sched.Second_Disc_Amt_Available;
                ELSIF l_pay_sched_temp.Number1 = 2 THEN
                  l_pay_sched_b.Discount_Available := -1 * (l_pay_sched.Second_Disc_Amt_Available
                                                            - l_ps_disc_recently_taken
                                                            - l_pay_sched.Third_Disc_Amt_Available);
                  l_pay_sched_b.Discount_Lost := l_pay_sched.Second_Disc_Amt_Available
                                                 - l_ps_disc_recently_taken
                                                 - l_pay_sched.Third_Disc_Amt_Available;
                ELSIF l_pay_sched_temp.Number1 = 3 THEN
                  l_pay_sched_b.Discount_Available := -1 * (l_pay_sched.Third_Disc_Amt_Available
                                                            - l_ps_disc_recently_taken);
                  l_pay_sched_b.Discount_Lost := l_pay_sched.Third_Disc_Amt_Available
                                                 - l_ps_disc_recently_taken;
                END IF;
                l_pay_sched_b.Discount_Taken := 0;
                l_pay_sched_b.Payment_Amount := 0;
                l_pay_sched_b.On_Time_Payment_Amt := 0;
                l_pay_sched_b.Late_Payment_Amt := 0;
                l_pay_sched_b.No_Days_Late := 0;
                l_pay_sched_b.Due_Bucket1 := 0;
                l_pay_sched_b.Due_Bucket2 := 0;
                l_pay_sched_b.Due_Bucket3 := 0;
                l_pay_sched_b.Past_Due_Bucket1 := 0;
                l_pay_sched_b.Past_Due_Bucket2 := 0;
                l_pay_sched_b.Past_Due_Bucket3 := 0;
                l_pay_sched_b.Amount_Remaining_B := 0;
                l_pay_sched_b.Past_Due_Amount_B := 0;
                l_pay_sched_b.Discount_Available_B := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Discount_Taken_B := 0;
                l_pay_sched_b.Discount_Lost_B := ROUND((l_pay_sched_b.Discount_Lost * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Payment_Amount_B := 0;
                l_pay_sched_b.On_Time_Payment_Amt_B := 0;
                l_pay_sched_b.Late_Payment_Amt_B := 0;
                l_pay_sched_b.Due_Bucket1_B := 0;
                l_pay_sched_b.Due_Bucket2_B := 0;
                l_pay_sched_b.Due_Bucket3_B := 0;
                l_pay_sched_b.Past_Due_Bucket1_B := 0;
                l_pay_sched_b.Past_Due_Bucket2_B := 0;
                l_pay_sched_b.Past_Due_Bucket3_B := 0;
                l_pay_sched_b.Prim_Amount_Remaining := 0;
                l_pay_sched_b.Prim_Past_Due_Amount := 0;
                l_pay_sched_b.Prim_Discount_Available := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Discount_Taken := 0;
                l_pay_sched_b.Prim_Discount_Lost := ROUND((l_pay_sched_b.Discount_Lost * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Payment_Amount := 0;
                l_pay_sched_b.Prim_On_Time_Payment_Amt := 0;
                l_pay_sched_b.Prim_Late_Payment_Amt := 0;
                l_pay_sched_b.Prim_Due_Bucket1 := 0;
                l_pay_sched_b.Prim_Due_Bucket2 := 0;
                l_pay_sched_b.Prim_Due_Bucket3 := 0;
                l_pay_sched_b.Prim_Past_Due_Bucket1 := 0;
                l_pay_sched_b.Prim_Past_Due_Bucket2 := 0;
                l_pay_sched_b.Prim_Past_Due_Bucket3 := 0;
                l_pay_sched_b.Sec_Amount_Remaining := 0;
                l_pay_sched_b.Sec_Past_Due_Amount := 0;
                l_pay_sched_b.Sec_Discount_Available := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Discount_Taken := 0;
                l_pay_sched_b.Sec_Discount_Lost := ROUND((l_pay_sched_b.Discount_Lost * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Payment_Amount := 0;
                l_pay_sched_b.Sec_On_Time_Payment_Amt := 0;
                l_pay_sched_b.Sec_Late_Payment_Amt := 0;
                l_pay_sched_b.Sec_Due_Bucket1 := 0;
                l_pay_sched_b.Sec_Due_Bucket2 := 0;
                l_pay_sched_b.Sec_Due_Bucket3 := 0;
                l_pay_sched_b.Sec_Past_Due_Bucket1 := 0;
                l_pay_sched_b.Sec_Past_Due_Bucket2 := 0;
                l_pay_sched_b.Sec_Past_Due_Bucket3 := 0;
                l_pay_sched_b.Fully_Paid_Date := NULL;
                l_pay_sched_b.Check_ID := NULL;
                l_pay_sched_b.Payment_Method := NULL;
                l_pay_sched_b.Last_Update_Date := sysdate;
                l_pay_sched_b.Last_Updated_By := g_fii_user_id;
                l_pay_sched_b.Creation_Date := sysdate;
                l_pay_sched_b.Created_By := l_pay_sched.Created_By;
                l_pay_sched_b.Last_Update_Login := g_fii_login_id;
                l_pay_sched_b.Check_Date := NULL;
                l_pay_sched_b.Unique_ID := l_pay_sched_temp.Number1;

                l_ps_disc_avail := l_ps_disc_avail + l_pay_sched_b.Discount_Available;
                l_ps_disc_lost := l_ps_disc_lost + l_pay_sched_b.Discount_Lost;
                l_ps_disc_recently_taken := 0;
                l_last_action_date := l_pay_sched_b.Action_Date;

                IF l_invoice.Pay_Sched_B_Flag = 'N' AND l_supplier_merge_flag = 'Y' THEN
                  Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'Y');
                ELSE Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'N');
                END IF;


              END IF; --IF l_ps_amount_remaining > 0 THEN
              l_pay_sched_temp_marker := FII_AP_Pay_Sched_Temp_MS.Next(l_pay_sched_temp_marker);

            ELSIF l_pay_sched_temp.Action IN ('DUE BUCKET', 'DUE', 'PAST BUCKET') THEN
              IF l_ps_amount_remaining <> 0 THEN

                g_state := 'Inserting Due Bucket/Due/Past Bucket record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Date ' || l_pay_sched_temp.Action_Date || '.';

                l_pay_sched_b.Time_ID := To_Number(To_Char(l_pay_sched_temp.Action_Date, 'J'));
                l_pay_sched_b.Period_Type_ID := 1;
                l_pay_sched_b.Action_Date := l_pay_sched_temp.Action_Date;
                l_pay_sched_b.Action := l_pay_sched_temp.Action;
                l_pay_sched_b.Update_Sequence := g_seq_id;
                l_pay_sched_b.Org_ID := l_invoice.Org_ID;
                l_pay_sched_b.Supplier_ID := l_invoice.Supplier_ID;
                l_pay_sched_b.Invoice_ID := l_invoice.Invoice_ID;
                l_pay_sched_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
                l_pay_sched_b.Trx_Date := l_invoice.Invoice_Date;
                l_pay_sched_b.Payment_Num := l_pay_sched.Payment_Num;
                l_pay_sched_b.Due_Date := TRUNC(l_pay_sched.Due_Date);
                l_pay_sched_b.Amount_Remaining := 0;
                IF l_pay_sched_temp.Action = 'DUE' THEN
                  l_pay_sched_b.Past_Due_Amount := l_ps_amount_remaining;
                ELSE l_pay_sched_b.Past_Due_Amount := 0;
                END IF;
                l_pay_sched_b.Discount_Available := 0;
                l_pay_sched_b.Discount_Taken := 0;
                l_pay_sched_b.Discount_Lost := 0;
                l_pay_sched_b.Payment_Amount := 0;
                l_pay_sched_b.On_Time_Payment_Amt := 0;
                l_pay_sched_b.Late_Payment_Amt := 0;
                l_pay_sched_b.No_Days_Late := 0;

                IF l_pay_sched_temp.Action = 'DUE BUCKET' AND l_pay_sched_temp.Number1 = 1 THEN
                  l_pay_sched_b.Due_Bucket1 := -1 * l_ps_amount_remaining;
                  l_ps_db1 := -1;
                ELSE l_pay_sched_b.Due_Bucket1 := 0;
                END IF;

                IF l_pay_sched_temp.Action = 'DUE BUCKET' AND l_pay_sched_temp.Number1 = 1 THEN
                  l_pay_sched_b.Due_Bucket2 := l_ps_amount_remaining;
                  l_ps_db2 := 1;
                ELSIF l_pay_sched_temp.Action = 'DUE BUCKET' AND l_pay_sched_temp.Number1 = 2 THEN
                  l_pay_sched_b.Due_Bucket2 := -1 * l_ps_amount_remaining;
                  l_ps_db2 := -1;
                ELSE l_pay_sched_b.Due_Bucket2 := 0;
                END IF;

                IF l_pay_sched_temp.Action = 'DUE BUCKET' AND l_pay_sched_temp.Number1 = 2 THEN
                  l_pay_sched_b.Due_Bucket3 := l_ps_amount_remaining;
                  l_ps_db3 := 1;
                ELSIF l_pay_sched_temp.Action = 'DUE' THEN
                  l_pay_sched_b.Due_Bucket3 := -1 * l_ps_amount_remaining;
                  l_ps_db3 := -1;
                ELSE l_pay_sched_b.Due_Bucket3 := 0;
                END IF;

                IF l_pay_sched_temp.Action = 'PAST BUCKET' AND l_pay_sched_temp.Number1 = 2 THEN
                  l_pay_sched_b.Past_Due_Bucket1 := l_ps_amount_remaining;
                  l_ps_pdb1 := 1;
                ELSE l_pay_sched_b.Past_Due_Bucket1 := 0;
                END IF;

                IF l_pay_sched_temp.Action = 'PAST BUCKET' AND l_pay_sched_temp.Number1 = 1 THEN
                  l_pay_sched_b.Past_Due_Bucket2 := l_ps_amount_remaining;
                  l_ps_pdb2 := 1;
                ELSIF l_pay_sched_temp.Action = 'PAST BUCKET' AND l_pay_sched_temp.Number1 = 2 THEN
                  l_pay_sched_b.Past_Due_Bucket2 := -1 * l_ps_amount_remaining;
                  l_ps_pdb2 := -1;
                ELSE l_pay_sched_b.Past_Due_Bucket2 := 0;
                END IF;

                IF l_pay_sched_temp.Action = 'DUE' THEN
                  l_pay_sched_b.Past_Due_Bucket3 := l_ps_amount_remaining;
                  l_ps_pdb3 := 1;
                ELSIF l_pay_sched_temp.Action = 'PAST BUCKET' AND l_pay_sched_temp.Number1 = 1 THEN
                  l_pay_sched_b.Past_Due_Bucket3 := -1 * l_ps_amount_remaining;
                  l_ps_pdb3 := -1;
                ELSE l_pay_sched_b.Past_Due_Bucket3 := 0;
                END IF;

                l_pay_sched_b.Amount_Remaining_B := 0;
                l_pay_sched_b.Past_Due_Amount_B := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Discount_Available_B := 0;
                l_pay_sched_b.Discount_Taken_B := 0;
                l_pay_sched_b.Discount_Lost_B := 0;
                l_pay_sched_b.Payment_Amount_B := 0;
                l_pay_sched_b.On_Time_Payment_Amt_B := 0;
                l_pay_sched_b.Late_Payment_Amt_B := 0;
                l_pay_sched_b.Due_Bucket1_B := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Due_Bucket2_B := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Due_Bucket3_B := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Past_Due_Bucket1_B := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Past_Due_Bucket2_B := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Past_Due_Bucket3_B := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
                l_pay_sched_b.Prim_Amount_Remaining := 0;
                l_pay_sched_b.Prim_Past_Due_Amount := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Discount_Available := 0;
                l_pay_sched_b.Prim_Discount_Taken := 0;
                l_pay_sched_b.Prim_Discount_Lost := 0;
                l_pay_sched_b.Prim_Payment_Amount := 0;
                l_pay_sched_b.Prim_On_Time_Payment_Amt := 0;
                l_pay_sched_b.Prim_Late_Payment_Amt := 0;
                l_pay_sched_b.Prim_Due_Bucket1 := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Due_Bucket2 := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Due_Bucket3 := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Past_Due_Bucket1 := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Past_Due_Bucket2 := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Prim_Past_Due_Bucket3 := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Sec_Amount_Remaining := 0;
                l_pay_sched_b.Sec_Past_Due_Amount := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Discount_Available := 0;
                l_pay_sched_b.Sec_Discount_Taken := 0;
                l_pay_sched_b.Sec_Discount_Lost := 0;
                l_pay_sched_b.Sec_Payment_Amount := 0;
                l_pay_sched_b.Sec_On_Time_Payment_Amt := 0;
                l_pay_sched_b.Sec_Late_Payment_Amt := 0;
                l_pay_sched_b.Sec_Due_Bucket1 := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Due_Bucket2 := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Due_Bucket3 := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Past_Due_Bucket1 := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Past_Due_Bucket2 := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Sec_Past_Due_Bucket3 := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                l_pay_sched_b.Fully_Paid_Date := NULL;
                l_pay_sched_b.Check_ID := NULL;
                l_pay_sched_b.Payment_Method := NULL;
                l_pay_sched_b.Last_Update_Date := sysdate;
                l_pay_sched_b.Last_Updated_By := g_fii_user_id;
                l_pay_sched_b.Creation_Date := sysdate;
                l_pay_sched_b.Created_By := l_pay_sched.Created_By;
                l_pay_sched_b.Last_Update_Login := g_fii_login_id;
                l_pay_sched_b.Check_Date := NULL;

                l_last_action_date := l_pay_sched_b.Action_Date;

                IF l_invoice.Pay_Sched_B_Flag = 'N' AND l_supplier_merge_flag = 'Y' THEN
                  Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'Y');
                ELSE Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'N');
                END IF;

                l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
                l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

                l_timestamp4_tmp := DBMS_UTILITY.Get_Time;

                g_state := 'Updating aging buckets memory structure(s) with Due Bucket/Due/Past Bucket for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Date ' || l_pay_sched_b.Action_Date || '.';

                IF l_inv_has_mult_ps = 'N' THEN
                  l_aging_bkts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                  l_aging_bkts_b.Period_Type_ID := 1;
                  l_aging_bkts_b.Org_ID := l_invoice.Org_ID;
                  l_aging_bkts_b.Supplier_ID := l_invoice.Supplier_ID;
                  l_aging_bkts_b.Invoice_ID := l_invoice.Invoice_ID;
                  l_aging_bkts_b.Action_Date := l_pay_sched_b.Action_Date;
                  l_aging_bkts_b.Due_Bucket1_Cnt := l_ps_db1;
                  l_aging_bkts_b.Due_Bucket2_Cnt := l_ps_db2;
                  l_aging_bkts_b.Due_Bucket3_Cnt := l_ps_db3;
                  l_aging_bkts_b.Past_Due_Bucket3_Cnt := l_ps_pdb3;
                  l_aging_bkts_b.Past_Due_Bucket2_Cnt := l_ps_pdb2;
                  l_aging_bkts_b.Past_Due_Bucket1_Cnt := l_ps_pdb1;
                  l_aging_bkts_b.Last_Update_Date := sysdate;
                  l_aging_bkts_b.Last_Updated_By := g_fii_user_id;
                  l_aging_bkts_b.Creation_Date := sysdate;
                  l_aging_bkts_b.Created_By := g_fii_user_id;
                  l_aging_bkts_b.Last_Update_Login := g_fii_login_id;
                  FII_AP_Aging_Bkts_B_MS(FII_AP_Aging_Bkts_B_MS.Count+1) := l_aging_bkts_b;

                  IF l_ps_db1 + l_ps_db2 + l_ps_db3 <> 0 OR
                     l_ps_pdb1 + l_ps_pdb2 + l_ps_pdb3 <> 0 THEN
                    l_due_counts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                    l_due_counts_b.Period_Type_ID := 1;
                    l_due_counts_b.Org_ID := l_invoice.Org_ID;
                    l_due_counts_b.Supplier_ID := l_invoice.Supplier_ID;
                    l_due_counts_b.Invoice_ID := l_invoice.Invoice_ID;
                    l_due_counts_b.Action_Date := l_pay_sched_b.Action_Date;
                    l_due_counts_b.Due_Cnt := l_ps_db1 + l_ps_db2 + l_ps_db3;
                    l_due_counts_b.Past_Due_Cnt := l_ps_pdb1 + l_ps_pdb2 + l_ps_pdb3;
                    l_due_counts_b.Last_Update_Date := sysdate;
                    l_due_counts_b.Last_Updated_By := g_fii_user_id;
                    l_due_counts_b.Creation_Date := sysdate;
                    l_due_counts_b.Created_By := g_fii_user_id;
                    l_due_counts_b.Last_Update_Login := g_fii_login_id;
                    FII_AP_Due_Counts_B_MS(FII_AP_Due_Counts_B_MS.Count+1) := l_due_counts_b;
                  END IF;

              ELSE
                BEGIN
                  l_ps_aging := FII_AP_PS_Aging_MS(to_char(l_pay_sched_b.Action_Date, 'RRRR/MM/DD'));

                  l_ps_aging.Action_Date := l_ps_aging.Action_Date;
                  l_ps_aging.Due_Bucket1 := l_ps_aging.Due_Bucket1 + l_ps_db1;
                  l_ps_aging.Due_Bucket2 := l_ps_aging.Due_Bucket2 + l_ps_db2;
                  l_ps_aging.Due_Bucket3 := l_ps_aging.Due_Bucket3 + l_ps_db3;
                  l_ps_aging.Past_Due_Bucket3 := l_ps_aging.Past_Due_Bucket3 + l_ps_pdb3;
                  l_ps_aging.Past_Due_Bucket2 := l_ps_aging.Past_Due_Bucket2 + l_ps_pdb2;
                  l_ps_aging.Past_Due_Bucket1 := l_ps_aging.Past_Due_Bucket1 + l_ps_pdb1;
                  FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                EXCEPTION
                  WHEN NO_DATA_FOUND THEN

                    l_ps_aging.Action_Date := l_pay_sched_b.Action_Date;
                    l_ps_aging.Due_Bucket1 := l_ps_db1;
                    l_ps_aging.Due_Bucket2 := l_ps_db2;
                    l_ps_aging.Due_Bucket3 := l_ps_db3;
                    l_ps_aging.Past_Due_Bucket3 := l_ps_pdb3;
                    l_ps_aging.Past_Due_Bucket2 := l_ps_pdb2;
                    l_ps_aging.Past_Due_Bucket1 := l_ps_pdb1;
                    FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                  WHEN OTHERS THEN
                    FII_UTIL.put_line('Error occured while inserting due bucket/due/past bucket record into FII_AP_Aging_MS.');
                    RAISE;
                END;
              END IF;

              l_timestamp4_tmp := DBMS_UTILITY.Get_Time - l_timestamp4_tmp;
              l_timestamp4 := l_timestamp4 + l_timestamp4_tmp;

              l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;

              END IF; --IF l_ps_amount_remaining > 0
              l_pay_sched_temp_marker := FII_AP_Pay_Sched_Temp_MS.Next(l_pay_sched_temp_marker);


            ELSIF l_pay_sched_temp.Action IN ('PAYMENT', 'PREPAYMENT') THEN

              g_state := 'Inserting invoice payment record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Marker ' || l_pay_sched_temp_marker || '.';

              l_pay_sched_b.Time_ID := To_Number(To_Char(l_pay_sched_temp.Action_Date, 'J'));
              l_pay_sched_b.Period_Type_ID := 1;
              l_pay_sched_b.Action_Date := l_pay_sched_temp.Action_Date;
              l_pay_sched_b.Action := l_pay_sched_temp.Action;
              l_pay_sched_b.Update_Sequence := g_seq_id;
              l_pay_sched_b.Org_ID := l_invoice.Org_ID;
              l_pay_sched_b.Supplier_ID := l_invoice.Supplier_ID;
              l_pay_sched_b.Invoice_ID := l_invoice.Invoice_ID;
              l_pay_sched_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
              l_pay_sched_b.Trx_Date := l_invoice.Invoice_Date;
              l_pay_sched_b.Payment_Num := l_pay_sched.Payment_Num;
              l_pay_sched_b.Due_Date := TRUNC(l_pay_sched.Due_Date);
              l_pay_sched_b.Amount_Remaining := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
              IF l_invoice.Invoice_Type = 'PREPAYMENT' THEN
                l_pay_sched_b.Past_Due_Amount := 0;
              ELSIF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date < 0 THEN
                l_pay_sched_b.Past_Due_Amount := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
              ELSE l_pay_sched_b.Past_Due_Amount := 0;
              END IF;
              l_pay_sched_b.Discount_Taken := l_pay_sched_temp.Number2;
              IF l_ps_amount_remaining + l_pay_sched_b.Amount_Remaining <> 0 THEN
                l_pay_sched_b.Discount_Available := -1 * l_pay_sched_temp.Number2;
                l_pay_sched_b.Discount_Lost := 0;
              ELSE
                l_pay_sched_b.Discount_Available := -1 * l_ps_disc_avail;
                l_pay_sched_b.Discount_Lost := GREATEST(l_pay_sched.Discount_Amount_Available,
                                                        l_pay_sched.Second_Disc_Amt_Available,
                                                        l_pay_sched.Third_Disc_Amt_Available)
                                               - l_ps_disc_taken - l_ps_disc_lost
                                               - l_pay_sched_temp.Number2;
              END IF;
              l_pay_sched_b.Payment_Amount := l_pay_sched_temp.Number1;
              IF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date < 0 THEN
                l_pay_sched_b.On_Time_Payment_Amt := 0;
                l_pay_sched_b.Late_Payment_Amt := l_pay_sched_temp.Number1;
                l_pay_sched_b.No_Days_Late := l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date);
              ELSE
                l_pay_sched_b.On_Time_Payment_Amt := l_pay_sched_temp.Number1;
                l_pay_sched_b.Late_Payment_Amt := 0;
                l_pay_sched_b.No_Days_Late := 0;
              END IF;

              IF l_invoice.Invoice_Type <> 'PREPAYMENT'
              AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date >= g_due_bucket1 THEN
                l_pay_sched_b.Due_Bucket1 := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
                l_ps_db1 := -1;
              ELSE l_pay_sched_b.Due_Bucket1 := 0;
              END IF;

              IF l_invoice.Invoice_Type <> 'PREPAYMENT'
              AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date <= g_due_bucket2
              AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date > g_due_bucket3 THEN
                l_pay_sched_b.Due_Bucket2 := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
                l_ps_db2 := -1;
              ELSE l_pay_sched_b.Due_Bucket2 := 0;
              END IF;

              IF l_invoice.Invoice_Type <> 'PREPAYMENT'
              AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date <= g_due_bucket3
              AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date >= 0 THEN
                l_pay_sched_b.Due_Bucket3 := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
                l_ps_db3 := -1;
              ELSE l_pay_sched_b.Due_Bucket3 := 0;
              END IF;

              IF l_invoice.Invoice_Type <> 'PREPAYMENT'
              AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) >= g_past_bucket1 THEN
                l_pay_sched_b.Past_Due_Bucket1 := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
                l_ps_pdb1 := -1;
              ELSE l_pay_sched_b.Past_Due_Bucket1 := 0;
              END IF;

              IF l_invoice.Invoice_Type <> 'PREPAYMENT'
              AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket2
              AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) > g_past_bucket3 THEN
                l_pay_sched_b.Past_Due_Bucket2 := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
                l_ps_pdb2 := -1;
              ELSE l_pay_sched_b.Past_Due_Bucket2 := 0;
              END IF;

              IF l_invoice.Invoice_Type <> 'PREPAYMENT'
              AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket3
              AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) > 0 THEN
                l_pay_sched_b.Past_Due_Bucket3 := -1 * (l_pay_sched_temp.Number1 + l_pay_sched_temp.Number2);
                l_ps_pdb3 := -1;
              ELSE l_pay_sched_b.Past_Due_Bucket3 := 0;
              END IF;

              l_pay_sched_b.Amount_Remaining_B := ROUND((l_pay_sched_b.Amount_Remaining * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Amount_B := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Discount_Available_B := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Discount_Taken_B := ROUND((l_pay_sched_b.Discount_Taken * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Discount_Lost_B := ROUND((l_pay_sched_b.Discount_Lost * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Payment_Amount_B := ROUND((l_pay_sched_b.Payment_Amount * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.On_Time_Payment_Amt_B := ROUND((l_pay_sched_b.On_Time_Payment_Amt * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Late_Payment_Amt_B := ROUND((l_pay_sched_b.Late_Payment_Amt * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Due_Bucket1_B := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Due_Bucket2_B := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Due_Bucket3_B := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Bucket1_B := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Bucket2_B := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Past_Due_Bucket3_B := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Func_Rate)/l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
              l_pay_sched_b.Prim_Amount_Remaining := ROUND((l_pay_sched_b.Amount_Remaining * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Amount := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Discount_Available := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Discount_Taken := ROUND((l_pay_sched_b.Discount_Taken * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Discount_Lost := ROUND((l_pay_sched_b.Discount_Lost * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Payment_Amount := ROUND((l_pay_sched_b.Payment_Amount * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_On_Time_Payment_Amt := ROUND((l_pay_sched_b.On_Time_Payment_Amt * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Late_Payment_Amt := ROUND((l_pay_sched_b.Late_Payment_Amt * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Due_Bucket1 := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Due_Bucket2 := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Due_Bucket3 := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Bucket1 := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Bucket2 := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Prim_Past_Due_Bucket3 := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
              l_pay_sched_b.Sec_Amount_Remaining := ROUND((l_pay_sched_b.Amount_Remaining * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Amount := ROUND((l_pay_sched_b.Past_Due_Amount * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Discount_Available := ROUND((l_pay_sched_b.Discount_Available * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Discount_Taken := ROUND((l_pay_sched_b.Discount_Taken * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Discount_Lost := ROUND((l_pay_sched_b.Discount_Lost * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Payment_Amount := ROUND((l_pay_sched_b.Payment_Amount * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_On_Time_Payment_Amt := ROUND((l_pay_sched_b.On_Time_Payment_Amt * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Late_Payment_Amt := ROUND((l_pay_sched_b.Late_Payment_Amt * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Due_Bucket1 := ROUND((l_pay_sched_b.Due_Bucket1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Due_Bucket2 := ROUND((l_pay_sched_b.Due_Bucket2 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Due_Bucket3 := ROUND((l_pay_sched_b.Due_Bucket3 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Bucket1 := ROUND((l_pay_sched_b.Past_Due_Bucket1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Bucket2 := ROUND((l_pay_sched_b.Past_Due_Bucket2 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              l_pay_sched_b.Sec_Past_Due_Bucket3 := ROUND((l_pay_sched_b.Past_Due_Bucket3 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
              IF l_ps_amount_remaining + l_pay_sched_b.Amount_Remaining <> 0 THEN
                l_pay_sched_b.Fully_Paid_Date := NULL;
              ELSE l_pay_sched_b.Fully_Paid_Date := l_pay_sched_temp.Action_Date;
              END IF;
              l_pay_sched_b.Check_ID := l_pay_sched_temp.Number4;
              --IBY CHANGE
              IF l_pay_sched_temp.String1 IN ('ELECTRONIC') OR l_pay_sched_temp.String1 IN ('EFT') OR l_pay_sched_temp.String1 IN ('WIRE') THEN
                l_pay_sched_b.Payment_Method := 'E';
              ELSE l_pay_sched_b.Payment_Method := 'M';
              END IF;
              l_pay_sched_b.Last_Update_Date := sysdate;
              l_pay_sched_b.Last_Updated_By := g_fii_user_id;
              l_pay_sched_b.Creation_Date := sysdate;
              l_pay_sched_b.Created_By := l_pay_sched_temp.Number3;
              l_pay_sched_b.Last_Update_Login := g_fii_login_id;
              l_pay_sched_b.Check_Date := l_pay_sched_temp.Date1;
              l_pay_sched_b.Inv_Pymt_Flag := 'Y';
              l_pay_sched_b.Unique_ID := l_pay_sched_temp.Number5;

              l_ps_amount_remaining := l_ps_amount_remaining + l_pay_sched_b.Amount_Remaining;
              l_ps_disc_avail := l_ps_disc_avail + l_pay_sched_b.Discount_Available;
              l_ps_disc_lost := l_ps_disc_lost + l_pay_sched_b.Discount_Lost;
              l_ps_disc_taken := l_ps_disc_taken + l_pay_sched_b.Discount_Taken;
              l_ps_disc_recently_taken := l_ps_disc_recently_taken + l_pay_sched_b.Discount_Taken;
              l_last_action_date := l_pay_sched_b.Action_Date;

              IF l_invoice.Pay_Sched_B_Flag = 'N' AND l_supplier_merge_flag = 'Y' THEN
                Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'Y');
              ELSE Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'N');
              END IF;


              IF l_ps_amount_remaining = 0 THEN
                l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
                l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

                l_timestamp4_tmp := DBMS_UTILITY.Get_Time;


                g_state := 'Updating aging buckets memory structure(s) with invoice payment for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Marker ' || l_pay_sched_temp_marker || '.';
                IF l_inv_has_mult_ps = 'N' THEN
                  l_aging_bkts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                  l_aging_bkts_b.Period_Type_ID := 1;
                  l_aging_bkts_b.Org_ID := l_invoice.Org_ID;
                  l_aging_bkts_b.Supplier_ID := l_invoice.Supplier_ID;
                  l_aging_bkts_b.Invoice_ID := l_invoice.Invoice_ID;
                  l_aging_bkts_b.Action_Date := l_pay_sched_b.Action_Date;
                  l_aging_bkts_b.Due_Bucket1_Cnt := l_ps_db1;
                  l_aging_bkts_b.Due_Bucket2_Cnt := l_ps_db2;
                  l_aging_bkts_b.Due_Bucket3_Cnt := l_ps_db3;
                  l_aging_bkts_b.Past_Due_Bucket3_Cnt := l_ps_pdb3;
                  l_aging_bkts_b.Past_Due_Bucket2_Cnt := l_ps_pdb2;
                  l_aging_bkts_b.Past_Due_Bucket1_Cnt := l_ps_pdb1;
                  l_aging_bkts_b.Last_Update_Date := sysdate;
                  l_aging_bkts_b.Last_Updated_By := g_fii_user_id;
                  l_aging_bkts_b.Creation_Date := sysdate;
                  l_aging_bkts_b.Created_By := g_fii_user_id;
                  l_aging_bkts_b.Last_Update_Login := g_fii_login_id;
                  FII_AP_Aging_Bkts_B_MS(FII_AP_Aging_Bkts_B_MS.Count+1) := l_aging_bkts_b;

                  l_due_counts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                  l_due_counts_b.Period_Type_ID := 1;
                  l_due_counts_b.Org_ID := l_invoice.Org_ID;
                  l_due_counts_b.Supplier_ID := l_invoice.Supplier_ID;
                  l_due_counts_b.Invoice_ID := l_invoice.Invoice_ID;
                  l_due_counts_b.Action_Date := l_pay_sched_b.Action_Date;
                  l_due_counts_b.Due_Cnt := l_ps_db1 + l_ps_db2 + l_ps_db3;
                  l_due_counts_b.Past_Due_Cnt := l_ps_pdb1 + l_ps_pdb2 + l_ps_pdb3;
                  l_due_counts_b.Last_Update_Date := sysdate;
                  l_due_counts_b.Last_Updated_By := g_fii_user_id;
                  l_due_counts_b.Creation_Date := sysdate;
                  l_due_counts_b.Created_By := g_fii_user_id;
                  l_due_counts_b.Last_Update_Login := g_fii_login_id;
                  FII_AP_Due_Counts_B_MS(FII_AP_Due_Counts_B_MS.Count+1) := l_due_counts_b;

                ELSE
                  BEGIN
                    l_ps_aging := FII_AP_PS_Aging_MS(to_char(l_pay_sched_b.Action_Date, 'RRRR/MM/DD'));

                    l_ps_aging.Action_Date := l_ps_aging.Action_Date;
                    l_ps_aging.Due_Bucket1 := l_ps_aging.Due_Bucket1 + l_ps_db1;
                    l_ps_aging.Due_Bucket2 := l_ps_aging.Due_Bucket2 + l_ps_db2;
                    l_ps_aging.Due_Bucket3 := l_ps_aging.Due_Bucket3 + l_ps_db3;
                    l_ps_aging.Past_Due_Bucket3 := l_ps_aging.Past_Due_Bucket3 + l_ps_pdb3;
                    l_ps_aging.Past_Due_Bucket2 := l_ps_aging.Past_Due_Bucket2 + l_ps_pdb2;
                    l_ps_aging.Past_Due_Bucket1 := l_ps_aging.Past_Due_Bucket1 + l_ps_pdb1;
                    FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN

                      l_ps_aging.Action_Date := l_pay_sched_b.Action_Date;
                      l_ps_aging.Due_Bucket1 := l_ps_db1;
                      l_ps_aging.Due_Bucket2 := l_ps_db2;
                      l_ps_aging.Due_Bucket3 := l_ps_db3;
                      l_ps_aging.Past_Due_Bucket3 := l_ps_pdb3;
                      l_ps_aging.Past_Due_Bucket2 := l_ps_pdb2;
                      l_ps_aging.Past_Due_Bucket1 := l_ps_pdb1;
                      FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                    WHEN OTHERS THEN
                      FII_UTIL.put_line('Error occured while inserting invoice payment record into FII_AP_Aging_MS.');
                      RAISE;
                  END;
                END IF; --IF l_inv_has_mult_ps = 'N' THEN

                l_timestamp4_tmp := DBMS_UTILITY.Get_Time - l_timestamp4_tmp;
                l_timestamp4 := l_timestamp4 + l_timestamp4_tmp;

                l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;

              END IF; --IF l_ps_amount_remaining = 0 THEN

              l_pay_sched_temp_marker := FII_AP_Pay_Sched_Temp_MS.Next(l_pay_sched_temp_marker);


            ELSIF l_pay_sched_temp.Action IN ('WITHHOLDING', 'TAX') THEN
              IF l_invoice.Invoice_Type <> 'PREPAYMENT' THEN
                g_state := 'Inserting wh/tax record for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Marker ' || l_pay_sched_temp_marker || '.';

                l_pay_sched_b.Time_ID := To_Number(To_Char(l_pay_sched_temp.Action_Date, 'J'));
                l_pay_sched_b.Period_Type_ID := 1;
                l_pay_sched_b.Action_Date := l_pay_sched_temp.Action_Date;
                l_pay_sched_b.Action := l_pay_sched_temp.Action;
                l_pay_sched_b.Update_Sequence := g_seq_id;
                l_pay_sched_b.Org_ID := l_invoice.Org_ID;
                l_pay_sched_b.Supplier_ID := l_invoice.Supplier_ID;
                l_pay_sched_b.Invoice_ID := l_invoice.Invoice_ID;
                l_pay_sched_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
                l_pay_sched_b.Trx_Date := l_invoice.Invoice_Date;
                l_pay_sched_b.Payment_Num := l_pay_sched.Payment_Num;
                l_pay_sched_b.Due_Date := TRUNC(l_pay_sched.Due_Date);

                l_pay_sched_b.Amount_Remaining := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                l_pay_sched_b.Amount_Remaining_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                l_pay_sched_b.Prim_Amount_Remaining := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                l_pay_sched_b.Sec_Amount_Remaining := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;

                IF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date < 0 THEN
                  l_pay_sched_b.Past_Due_Amount := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Amount_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Past_Due_Amount := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate) / g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Past_Due_Amount := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate) / g_secondary_mau) * g_secondary_mau;
                ELSE l_pay_sched_b.Past_Due_Amount := 0;
                     l_pay_sched_b.Past_Due_Amount_B := 0;
                     l_pay_sched_b.Prim_Past_Due_Amount := 0;
                     l_pay_sched_b.Sec_Past_Due_Amount := 0;
                END IF;

                l_pay_sched_b.Discount_Available := 0;
                l_pay_sched_b.Discount_Available_B := 0;
                l_pay_sched_b.Prim_Discount_Available := 0;
                l_pay_sched_b.Sec_Discount_Available := 0;
                l_pay_sched_b.Discount_Taken := 0;
                l_pay_sched_b.Discount_Taken_B := 0;
                l_pay_sched_b.Prim_Discount_Taken := 0;
                l_pay_sched_b.Sec_Discount_Taken := 0;
                l_pay_sched_b.Discount_Lost := 0;
                l_pay_sched_b.Discount_Lost_B := 0;
                l_pay_sched_b.Prim_Discount_Lost := 0;
                l_pay_sched_b.Sec_Discount_Lost := 0;
                l_pay_sched_b.Payment_Amount := 0;
                l_pay_sched_b.Payment_Amount_B := 0;
                l_pay_sched_b.Prim_Payment_Amount := 0;
                l_pay_sched_b.Sec_Payment_Amount := 0;
                l_pay_sched_b.On_Time_Payment_Amt := 0;
                l_pay_sched_b.On_Time_Payment_Amt_B := 0;
                l_pay_sched_b.Prim_On_Time_Payment_Amt := 0;
                l_pay_sched_b.Sec_On_Time_Payment_Amt := 0;
                l_pay_sched_b.Late_Payment_Amt := 0;
                l_pay_sched_b.Late_Payment_Amt_B := 0;
                l_pay_sched_b.Prim_Late_Payment_Amt := 0;
                l_pay_sched_b.Sec_Late_Payment_Amt := 0;

                IF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date < 0 THEN
                  l_pay_sched_b.No_Days_Late := l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date);
                ELSE l_pay_sched_b.No_Days_Late := 0;
                END IF;

                IF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date >= g_due_bucket1 THEN
                  l_pay_sched_b.Due_Bucket1 := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket1_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Due_Bucket1 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate)/g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Due_Bucket1 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate)/g_secondary_mau) * g_secondary_mau;

                  l_ps_db1 := -1;

                ELSE l_pay_sched_b.Due_Bucket1 := 0;
                     l_pay_sched_b.Due_Bucket1_B := 0;
                     l_pay_sched_b.Prim_Due_Bucket1 := 0;
                     l_pay_sched_b.Sec_Due_Bucket1 := 0;
                END IF;

                IF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date <= g_due_bucket2
                AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date > g_due_bucket3 THEN
                  l_pay_sched_b.Due_Bucket2 := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket2_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Due_Bucket2 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate)/g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Due_Bucket2 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate)/g_secondary_mau) * g_secondary_mau;

                  l_ps_db2 := -1;

                ELSE l_pay_sched_b.Due_Bucket2 := 0;
                     l_pay_sched_b.Due_Bucket2_B := 0;
                     l_pay_sched_b.Prim_Due_Bucket2 := 0;
                     l_pay_sched_b.Sec_Due_Bucket2 := 0;
                END IF;

                IF TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date <= g_due_bucket3
                AND TRUNC(l_pay_sched.Due_Date) - l_pay_sched_temp.Action_Date >= 0 THEN
                  l_pay_sched_b.Due_Bucket3 := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Due_Bucket3_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Due_Bucket3 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate)/g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Due_Bucket3 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate)/g_secondary_mau) * g_secondary_mau;

                  l_ps_db3 := -1;

                ELSE l_pay_sched_b.Due_Bucket3 := 0;
                     l_pay_sched_b.Due_Bucket3_B := 0;
                     l_pay_sched_b.Prim_Due_Bucket3 := 0;
                     l_pay_sched_b.Sec_Due_Bucket3 := 0;
                END IF;

                IF l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) >= g_past_bucket1 THEN
                  l_pay_sched_b.Past_Due_Bucket1 := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket1_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Past_Due_Bucket1 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate)/g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Past_Due_Bucket1 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate)/g_secondary_mau) * g_secondary_mau;

                  l_ps_pdb3 := -1;

                ELSE l_pay_sched_b.Past_Due_Bucket1 := 0;
                     l_pay_sched_b.Past_Due_Bucket1_B := 0;
                     l_pay_sched_b.Prim_Past_Due_Bucket1 := 0;
                     l_pay_sched_b.Sec_Past_Due_Bucket1 := 0;
                END IF;

                IF l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket2
                AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) > g_past_bucket3 THEN
                  l_pay_sched_b.Past_Due_Bucket2 := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket2_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Past_Due_Bucket2 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate)/g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Past_Due_Bucket2 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate)/g_secondary_mau) * g_secondary_mau;

                  l_ps_pdb2 := -1;

                ELSE l_pay_sched_b.Past_Due_Bucket2 := 0;
                     l_pay_sched_b.Past_Due_Bucket2_B := 0;
                     l_pay_sched_b.Prim_Past_Due_Bucket2 := 0;
                     l_pay_sched_b.Sec_Past_Due_Bucket2 := 0;
                END IF;

                IF l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) <= g_past_bucket3
                AND l_pay_sched_temp.Action_Date - TRUNC(l_pay_sched.Due_Date) > 0 THEN
                  l_pay_sched_b.Past_Due_Bucket3 := ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Past_Due_Bucket3_B := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Func_Rate)/l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
                  l_pay_sched_b.Prim_Past_Due_Bucket3 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Prim_Rate)/g_primary_mau) * g_primary_mau;
                  l_pay_sched_b.Sec_Past_Due_Bucket3 := ROUND((l_pay_sched_temp.Number1 * l_invoice.To_Sec_Rate)/g_secondary_mau) * g_secondary_mau;

                  l_ps_pdb1 := -1;

                ELSE l_pay_sched_b.Past_Due_Bucket3 := 0;
                     l_pay_sched_b.Past_Due_Bucket3_B := 0;
                     l_pay_sched_b.Prim_Past_Due_Bucket3 := 0;
                     l_pay_sched_b.Sec_Past_Due_Bucket3 := 0;
                END IF;

                l_pay_sched_b.Fully_Paid_Date := NULL;
                l_pay_sched_b.Check_ID := NULL;
                l_pay_sched_b.Payment_Method := NULL;
                l_pay_sched_b.Last_Update_Date := sysdate;
                l_pay_sched_b.Last_Updated_By := g_fii_user_id;
                l_pay_sched_b.Creation_Date := sysdate;
                l_pay_sched_b.Created_By := l_pay_sched.Created_By;
                l_pay_sched_b.Last_Update_Login := g_fii_login_id;
                l_pay_sched_b.Check_Date := NULL;

                l_ps_amount_remaining := l_ps_amount_remaining + l_pay_sched_b.Amount_Remaining;
                l_last_action_date := l_pay_sched_b.Action_Date;

                IF l_invoice.Pay_Sched_B_Flag = 'N' AND l_supplier_merge_flag = 'Y' THEN
                  Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'Y');
                ELSE Insert_Pay_Sched_B_Rec(l_pay_sched_b, 'N');
                END IF;

                IF l_ps_amount_remaining = 0 THEN
                  l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
                  l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

                  l_timestamp4_tmp := DBMS_UTILITY.Get_Time;

                  g_state := 'Updating aging buckets memory structure(s) with wh/tax for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || ', Marker ' || l_pay_sched_temp_marker || '.';

                  IF l_inv_has_mult_ps = 'N' THEN
                    l_aging_bkts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                    l_aging_bkts_b.Period_Type_ID := 1;
                    l_aging_bkts_b.Org_ID := l_invoice.Org_ID;
                    l_aging_bkts_b.Supplier_ID := l_invoice.Supplier_ID;
                    l_aging_bkts_b.Invoice_ID := l_invoice.Invoice_ID;
                    l_aging_bkts_b.Action_Date := l_pay_sched_b.Action_Date;
                    l_aging_bkts_b.Due_Bucket1_Cnt := l_ps_db1;
                    l_aging_bkts_b.Due_Bucket2_Cnt := l_ps_db2;
                    l_aging_bkts_b.Due_Bucket3_Cnt := l_ps_db3;
                    l_aging_bkts_b.Past_Due_Bucket3_Cnt := l_ps_pdb3;
                    l_aging_bkts_b.Past_Due_Bucket2_Cnt := l_ps_pdb2;
                    l_aging_bkts_b.Past_Due_Bucket1_Cnt := l_ps_pdb1;
                    l_aging_bkts_b.Last_Update_Date := sysdate;
                    l_aging_bkts_b.Last_Updated_By := g_fii_user_id;
                    l_aging_bkts_b.Creation_Date := sysdate;
                    l_aging_bkts_b.Created_By := g_fii_user_id;
                    l_aging_bkts_b.Last_Update_Login := g_fii_login_id;
                    FII_AP_Aging_Bkts_B_MS(FII_AP_Aging_Bkts_B_MS.Count+1) := l_aging_bkts_b;

                    l_due_counts_b.Time_ID := TO_NUMBER(TO_CHAR(l_pay_sched_b.Action_Date,'J'));
                    l_due_counts_b.Period_Type_ID := 1;
                    l_due_counts_b.Org_ID := l_invoice.Org_ID;
                    l_due_counts_b.Supplier_ID := l_invoice.Supplier_ID;
                    l_due_counts_b.Invoice_ID := l_invoice.Invoice_ID;
                    l_due_counts_b.Action_Date := l_pay_sched_b.Action_Date;
                    l_due_counts_b.Due_Cnt := l_ps_db1 + l_ps_db2 + l_ps_db3;
                    l_due_counts_b.Past_Due_Cnt := l_ps_pdb1 + l_ps_pdb2 + l_ps_pdb3;
                    l_due_counts_b.Last_Update_Date := sysdate;
                    l_due_counts_b.Last_Updated_By := g_fii_user_id;
                    l_due_counts_b.Creation_Date := sysdate;
                    l_due_counts_b.Created_By := g_fii_user_id;
                    l_due_counts_b.Last_Update_Login := g_fii_login_id;
                    FII_AP_Due_Counts_B_MS(FII_AP_Due_Counts_B_MS.Count+1) := l_due_counts_b;

                  ELSE
                    BEGIN
                      l_ps_aging := FII_AP_PS_Aging_MS(to_char(l_pay_sched_b.Action_Date, 'RRRR/MM/DD'));

                      l_ps_aging.Action_Date := l_ps_aging.Action_Date;
                      l_ps_aging.Due_Bucket1 := l_ps_aging.Due_Bucket1 + l_ps_db1;
                      l_ps_aging.Due_Bucket2 := l_ps_aging.Due_Bucket2 + l_ps_db2;
                      l_ps_aging.Due_Bucket3 := l_ps_aging.Due_Bucket3 + l_ps_db3;
                      l_ps_aging.Past_Due_Bucket3 := l_ps_aging.Past_Due_Bucket3 + l_ps_pdb3;
                      l_ps_aging.Past_Due_Bucket2 := l_ps_aging.Past_Due_Bucket2 + l_ps_pdb2;
                      l_ps_aging.Past_Due_Bucket1 := l_ps_aging.Past_Due_Bucket1 + l_ps_pdb1;
                      FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN

                        l_ps_aging.Action_Date := l_pay_sched_b.Action_Date;
                        l_ps_aging.Due_Bucket1 := l_ps_db1;
                        l_ps_aging.Due_Bucket2 := l_ps_db2;
                        l_ps_aging.Due_Bucket3 := l_ps_db3;
                        l_ps_aging.Past_Due_Bucket3 := l_ps_pdb3;
                        l_ps_aging.Past_Due_Bucket2 := l_ps_pdb2;
                        l_ps_aging.Past_Due_Bucket1 := l_ps_pdb1;
                        FII_AP_PS_Aging_MS(to_char(l_ps_aging.Action_Date, 'RRRR/MM/DD')) := l_ps_aging;

                      WHEN OTHERS THEN
                        FII_UTIL.put_line('Error occured while inserting wh/tax record into FII_AP_Aging_MS.');
                        RAISE;
                    END;
                  END IF; --IF l_inv_has_mult_ps = 'N' THEN

                  l_timestamp4_tmp := DBMS_UTILITY.Get_Time - l_timestamp4_tmp;
                  l_timestamp4 := l_timestamp4 + l_timestamp4_tmp;

                  l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;

                END IF; --IF l_ps_amount_remaining = 0 THEN
              ELSE --l_invoice.Invoice_Type = 'PREPAYMENT'
                l_ps_amount_remaining := l_ps_amount_remaining + ROUND(l_pay_sched_temp.Number1 / l_invoice.Minimum_Accountable_Unit) * l_invoice.Minimum_Accountable_Unit;
              END IF;

              l_pay_sched_temp_marker := FII_AP_Pay_Sched_Temp_MS.Next(l_pay_sched_temp_marker);

            END IF; --l_pay_sched_temp.Action = ... THEN ...


          END;

        END LOOP; --End of FII_AP_Pay_Sched_Temp_MS Loop.

        l_timestamp2_tmp := DBMS_UTILITY.Get_Time - l_timestamp2_tmp;
        l_timestamp2 := l_timestamp2 + l_timestamp2_tmp;

      ELSIF l_invoice.Pay_Sched_B_Flag = 'N' AND l_invoice.Invoice_B_Flag = 'Y' THEN

        l_timestamp3_tmp := DBMS_UTILITY.Get_Time;

        g_state := 'Invoice has Pay_Sched_B_Flag = ''N'' so advance prepayment applied marker for Invoice ' || l_invoice.Invoice_ID || ', Payment Number ' || l_pay_sched.Payment_Num || '.';
        WHILE l_prepay_applied_marker IS NOT NULL
        AND FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Invoice_ID = l_invoice.Invoice_ID LOOP
           l_prepay_applied := FII_AP_Prepay_Applied_MS(l_prepay_applied_marker);

           l_inv_f_paid_date := GREATEST(l_inv_f_paid_date, TRUNC(l_prepay_applied.Creation_Date));
           l_inv_f_paid_amt := l_inv_f_paid_amt + l_prepay_applied.Amount;

           l_prepay_applied_marker := FII_AP_Prepay_Applied_MS.Next(l_prepay_applied_marker);
        END LOOP;

        l_timestamp3_tmp := DBMS_UTILITY.Get_Time - l_timestamp3_tmp;
        l_timestamp3 := l_timestamp3 + l_timestamp3_tmp;

      END IF; --l_invoice.Pay_Sched_B_Flag = 'Y' THEN Loop through FII_AP_Pay_Sched_Temp_MS.


      l_pay_sched_marker := FII_AP_Pay_Sched_MS.Next(l_pay_sched_marker);
    END;
  END LOOP; --End of Payment Schedules Loop.


  WHILE l_prepay_applied_marker IS NOT NULL
    AND FII_AP_Prepay_Applied_MS(l_prepay_applied_marker).Invoice_ID <= l_invoice.Invoice_ID LOOP
      if g_debug_flag = 'Y' then
        fii_util.put_line('WARNING: Not all prepayment applied to invoice ' || l_invoice.Invoice_ID || ' have been allocated.');
      end if;
      l_prepay_applied_marker := FII_AP_Prepay_Applied_MS.Next(l_prepay_applied_marker);
  END LOOP;

---------------- BEGIN INSERTING INTO FII_AP_INVOICE_B Memory Structures --------------
  g_state := 'Inserting invoice for Invoice ' || l_invoice.Invoice_ID || '.';
  IF l_invoice.Invoice_B_Flag = 'Y' THEN
    l_timestamp3_tmp := DBMS_UTILITY.Get_Time;

    l_invoice_b.Org_ID := l_invoice.Org_ID;
    l_invoice_b.Supplier_ID := l_invoice.Supplier_ID;
    l_invoice_b.Invoice_ID := l_invoice.Invoice_ID;
    l_invoice_b.Invoice_Type := l_invoice.Invoice_Type;
    l_invoice_b.Invoice_Number := l_invoice.Invoice_Number;
    l_invoice_b.Invoice_Date := l_invoice.Invoice_Date;
    l_invoice_b.Invoice_Amount := l_invoice.Invoice_Amount;
    l_invoice_b.Base_Amount := ROUND((l_invoice.Invoice_Amount * l_invoice.To_Func_Rate)
                                     / l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
    l_invoice_b.Prim_Amount := ROUND((l_invoice.Invoice_Amount * l_invoice.To_Prim_Rate)
                                     / g_primary_mau) * g_primary_mau;
    l_invoice_b.Sec_Amount := ROUND((l_invoice.Invoice_Amount * l_invoice.To_Sec_Rate)
                                    / g_secondary_mau) * g_secondary_mau;
    l_invoice_b.Invoice_Currency_Code := l_invoice.Invoice_Currency_Code;
    l_invoice_b.Base_Currency_Code := l_invoice.Base_Currency_Code;
    l_invoice_b.Entered_Date := l_invoice.Entered_Date;
    l_invoice_b.Payment_Currency_Code := l_invoice.Payment_Currency_Code;
    IF l_invoice.Payment_Status_Flag = 'Y' THEN
      l_invoice_b.Fully_Paid_Date := l_inv_f_paid_date;
    ELSE l_invoice_B.Fully_Paid_Date := NULL;
    END IF;
    l_invoice_b.Terms_ID := l_invoice.Terms_ID;
    l_invoice_b.Source := l_invoice.Source;
    l_invoice_b.E_Invoices_Flag := l_invoice.E_Invoices_Flag;
    l_invoice_b.Cancel_Flag := l_invoice.Cancel_Flag;
    l_invoice_b.Cancel_Date := l_invoice.Cancel_Date;
    l_invoice_b.Dist_Count := l_invoice.Dist_Count;
    l_invoice_b.Due_Date := TRUNC(l_inv_due_date);
    l_invoice_b.Discount_Offered := l_inv_disc_avail;
    l_invoice_b.Discount_Offered_B := ROUND((l_inv_disc_avail * l_invoice.To_Func_Rate)
                                            / l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
    l_invoice_b.Prim_Discount_Offered := ROUND((l_inv_disc_avail * l_invoice.To_Prim_Rate)
                                               / g_primary_mau) * g_primary_mau;
    l_invoice_b.Sec_Discount_Offered := ROUND((l_inv_disc_avail * l_invoice.To_Sec_Rate)
                                              / g_secondary_mau) * g_secondary_mau;
    l_invoice_b.Last_Update_Date := sysdate;
    l_invoice_b.Last_Updated_By := g_fii_user_id;
    l_invoice_b.Creation_Date := sysdate;
    l_invoice_b.Created_By := l_invoice.Created_By;
    l_invoice_b.Last_Update_Login := g_fii_login_id;
    l_invoice_b.Exchange_Date := l_invoice.Exchange_Date;
    l_invoice_b.Exchange_Rate := l_invoice.Exchange_Rate;
    l_invoice_b.Exchange_Rate_Type := l_invoice.Exchange_Rate_Type;
    l_invoice_b.Payment_Status_Flag := l_invoice.Payment_Status_Flag;
    l_invoice_b.Payment_Cross_Rate := l_invoice.Payment_Cross_Rate;
    IF l_invoice.Payment_Status_Flag = 'Y' THEN
      l_invoice_b.Fully_Paid_Amount := l_inv_f_paid_amt;
    ELSE l_invoice_b.Fully_Paid_Amount := NULL;
    END IF;
    l_invoice_b.Fully_Paid_Amount_B := ROUND((l_invoice_b.Fully_Paid_Amount * l_invoice.To_Func_Rate)
                                             / l_invoice.Functional_MAU) * l_invoice.Functional_MAU;
    l_invoice_b.Prim_Fully_Paid_Amount := ROUND((l_invoice_b.Fully_Paid_Amount * l_invoice.To_Prim_Rate)
                                                / g_primary_mau) * g_primary_mau;
    l_invoice_b.Sec_Fully_Paid_Amount := ROUND((l_invoice_b.Fully_Paid_Amount * l_invoice.To_Sec_Rate)
                                               / g_secondary_mau) * g_secondary_mau;

    Insert_Invoice_B_Rec(l_invoice_b);

    l_timestamp3_tmp := DBMS_UTILITY.Get_Time - l_timestamp3_tmp;
    l_timestamp3 := l_timestamp3 + l_timestamp3_tmp;

  END IF; --IF l_invoice.Invoice_B_Flag = 'Y' THEN
---------------- END INSERTING INTO FII_AP_INVOICE_B Memory Structures --------------

----------------- BEGIN INSERTING INTO FII_AP_AGING_BKTS_B_MS AND FII_AP_DUE_COUNTS_B ------------------

  l_timestamp4_tmp := DBMS_UTILITY.Get_Time;

  IF (l_invoice.Pay_Sched_B_Flag = 'Y' OR l_supplier_merge_flag = 'Y')
  AND l_inv_has_mult_ps = 'Y' THEN

    g_state := 'Inserting aging records into FII_AP_Aging_Bkts_B_MS and FII_AP_Due_Counts_B_MS for Invoice ' || l_invoice.Invoice_ID || ' with multiple payment schedules.';

    l_ps_aging_marker := FII_AP_PS_Aging_MS.First;
    WHILE l_ps_aging_marker IS NOT NULL LOOP
      g_state := 'Looping FII_AP_PS_Aging_MS for Invoice ' || l_invoice.Invoice_ID || ', Marker ' || l_ps_aging_marker || '.';

      l_ps_aging := FII_AP_PS_Aging_MS(l_ps_aging_marker);

      IF l_inv_db1 = 0 AND l_ps_aging.Due_Bucket1 > 0 THEN
        l_aging_bkts_b.Due_Bucket1_Cnt := 1;
      ELSE l_aging_bkts_b.Due_Bucket1_Cnt := 0;
      END IF;
      l_inv_db1 := l_inv_db1 + l_ps_aging.Due_Bucket1;
      IF l_inv_db1 = 0 AND l_ps_aging.Due_Bucket1 < 0 THEN
        l_aging_bkts_b.Due_Bucket1_Cnt := -1;
      END IF;

      IF l_inv_db2 = 0 AND l_ps_aging.Due_Bucket2 > 0 THEN
        l_aging_bkts_b.Due_Bucket2_Cnt := 1;
      ELSE l_aging_bkts_b.Due_Bucket2_Cnt := 0;
      END IF;
      l_inv_db2 := l_inv_db2 + l_ps_aging.Due_Bucket2;
      IF l_inv_db2 = 0 AND l_ps_aging.Due_Bucket2 < 0 THEN
        l_aging_bkts_b.Due_Bucket2_Cnt := -1;
      END IF;

      IF l_inv_db3 = 0 AND l_ps_aging.Due_Bucket3 > 0 THEN
        l_aging_bkts_b.Due_Bucket3_Cnt := 1;
      ELSE l_aging_bkts_b.Due_Bucket3_Cnt := 0;
      END IF;
      l_inv_db3 := l_inv_db3 + l_ps_aging.Due_Bucket3;
      IF l_inv_db3 = 0 AND l_ps_aging.Due_Bucket3 < 0 THEN
        l_aging_bkts_b.Due_Bucket3_Cnt := -1;
      END IF;

      IF l_inv_pdb3 = 0 AND l_ps_aging.Past_Due_Bucket3 > 0 THEN
        l_aging_bkts_b.Past_Due_Bucket3_Cnt := 1;
      ELSE l_aging_bkts_b.Past_Due_Bucket3_Cnt := 0;
      END IF;
      l_inv_pdb3 := l_inv_pdb3 + l_ps_aging.Past_Due_Bucket3;
      IF l_inv_pdb3 = 0 AND l_ps_aging.Past_Due_Bucket3 < 0 THEN
        l_aging_bkts_b.Past_Due_Bucket3_Cnt := -1;
      END IF;

      IF l_inv_pdb2 = 0 AND l_ps_aging.Past_Due_Bucket2 > 0 THEN
        l_aging_bkts_b.Past_Due_Bucket2_Cnt := 1;
      ELSE l_aging_bkts_b.Past_Due_Bucket2_Cnt := 0;
      END IF;
      l_inv_pdb2 := l_inv_pdb2 + l_ps_aging.Past_Due_Bucket2;
      IF l_inv_pdb2 = 0 AND l_ps_aging.Past_Due_Bucket2 < 0 THEN
        l_aging_bkts_b.Past_Due_Bucket2_Cnt := -1;
      END IF;

      IF l_inv_pdb1 = 0 AND l_ps_aging.Past_Due_Bucket1 > 0 THEN
        l_aging_bkts_b.Past_Due_Bucket1_Cnt := 1;
      ELSE l_aging_bkts_b.Past_Due_Bucket1_Cnt := 0;
      END IF;
      l_inv_pdb1 := l_inv_pdb1 + l_ps_aging.Past_Due_Bucket1;
      IF l_inv_pdb1 = 0 AND l_ps_aging.Past_Due_Bucket1 < 0 THEN
        l_aging_bkts_b.Past_Due_Bucket1_Cnt := -1;
      END IF;

      IF l_aging_bkts_b.Due_Bucket1_Cnt <> 0 OR
         l_aging_bkts_b.Due_Bucket2_Cnt <> 0 OR
         l_aging_bkts_b.Due_Bucket3_Cnt <> 0 OR
         l_aging_bkts_b.Past_Due_Bucket3_Cnt <> 0 OR
         l_aging_bkts_b.Past_Due_Bucket2_Cnt <> 0 OR
         l_aging_bkts_b.Past_Due_Bucket1_Cnt <> 0 THEN --Insert into FII_AP_AGING_BKTS_B_MS.

        g_state := 'Inserting aging record in FII_AP_Aging_Bkts_B_MS for Invoice ' || l_invoice.Invoice_ID || ', Marker ' || l_ps_aging_marker || '.';

        l_aging_bkts_b.Time_ID := TO_NUMBER(TO_CHAR(l_ps_aging.Action_Date,'J'));
        l_aging_bkts_b.Period_Type_ID := 1;
        l_aging_bkts_b.Org_ID := l_invoice.Org_ID;
        l_aging_bkts_b.Supplier_ID := l_invoice.Supplier_ID;
        l_aging_bkts_b.Invoice_ID := l_invoice.Invoice_ID;
        l_aging_bkts_b.Action_Date := l_ps_aging.Action_Date;
        l_aging_bkts_b.Last_Update_Date := sysdate;
        l_aging_bkts_b.Last_Updated_By := g_fii_user_id;
        l_aging_bkts_b.Creation_Date := sysdate;
        l_aging_bkts_b.Created_By := g_fii_user_id;
        l_aging_bkts_b.Last_Update_Login := g_fii_login_id;
        FII_AP_Aging_Bkts_B_MS(FII_AP_Aging_Bkts_B_MS.Count+1) := l_aging_bkts_b;
      END IF;

      IF l_inv_due = 0 AND l_ps_aging.Due_Bucket1 + l_ps_aging.Due_Bucket2 + l_ps_aging.Due_Bucket3 > 0 THEN
        l_due_counts_b.Due_Cnt := 1;
      ELSE l_due_counts_b.Due_Cnt := 0;
      END IF;
      l_inv_due := l_inv_due + l_ps_aging.Due_Bucket1 + l_ps_aging.Due_Bucket2 + l_ps_aging.Due_Bucket3;
      IF l_inv_due = 0 AND l_ps_aging.Due_Bucket1 + l_ps_aging.Due_Bucket2 + l_ps_aging.Due_Bucket3 < 0 THEN
        l_due_counts_b.Due_Cnt := -1;
      END IF;

      IF l_inv_past_due = 0 AND l_ps_aging.Past_Due_Bucket1
                              + l_ps_aging.Past_Due_Bucket2
                              + l_ps_aging.Past_Due_Bucket3 > 0 THEN
        l_due_counts_b.Past_Due_Cnt := 1;
      ELSE l_due_counts_b.Past_Due_Cnt := 0;
      END IF;
      l_inv_past_due := l_inv_past_due + l_ps_aging.Past_Due_Bucket1
                                       + l_ps_aging.Past_Due_Bucket2
                                       + l_ps_aging.Past_Due_Bucket3;
      IF l_inv_past_due = 0 AND l_ps_aging.Past_Due_Bucket1
                              + l_ps_aging.Past_Due_Bucket2
                              + l_ps_aging.Past_Due_Bucket3 < 0 THEN
        l_due_counts_b.Past_Due_Cnt := -1;
      END IF;

      IF l_due_counts_b.Due_Cnt <> 0 OR
         l_due_counts_b.Past_Due_Cnt <> 0 THEN --Insert into FII_AP_DUE_COUNTS_B_MS.
        g_state := 'Inserting aging record in FII_AP_Due_Counts_B_MS for Invoice ' || l_invoice.Invoice_ID || ', Marker ' || l_ps_aging_marker || '.';

        l_due_counts_b.Time_ID := TO_NUMBER(TO_CHAR(l_ps_aging.Action_Date,'J'));
        l_due_counts_b.Period_Type_ID := 1;
        l_due_counts_b.Org_ID := l_invoice.Org_ID;
        l_due_counts_b.Supplier_ID := l_invoice.Supplier_ID;
        l_due_counts_b.Invoice_ID := l_invoice.Invoice_ID;
        l_due_counts_b.Action_Date := l_ps_aging.Action_Date;
        l_due_counts_b.Last_Update_Date := sysdate;
        l_due_counts_b.Last_Updated_By := g_fii_user_id;
        l_due_counts_b.Creation_Date := sysdate;
        l_due_counts_b.Created_By := g_fii_user_id;
        l_due_counts_b.Last_Update_Login := g_fii_login_id;
        FII_AP_Due_Counts_B_MS(FII_AP_Due_Counts_B_MS.Count+1) := l_due_counts_b;
      END IF;

      l_ps_aging_marker := FII_AP_PS_Aging_MS.Next(l_ps_aging_marker);
    END LOOP; --End of FII_AP_PS_Aging_MS Loop.
  END IF; --IF l_invoice.Pay_Sched_B_Flag = 'Y'  THEN

  l_timestamp4_tmp := DBMS_UTILITY.Get_Time - l_timestamp4_tmp;
  l_timestamp4 := l_timestamp4 + l_timestamp4_tmp;
------------------ END INSERTING INTO FII_AP_AGING_BKTS_B_MS AND FII_AP_DUE_COUNTS_B -------------------

END;
END LOOP; --End of Invoices Loop.

  --If there are remaining records not processed from existing base summary tables, they must be deleted.
  INSERT_DELETED_REC(NULL, NULL);

--Print out time breakdown for each table.
if g_debug_flag = 'Y' then
  FII_UTIL.put_line('The time taken to populate the memory structures for FII_AP_Pay_Sched_B is: ' || to_char(l_timestamp2/100) || ' seconds.');
  FII_UTIL.put_line('The time taken to populate the memory structures for FII_AP_Invoice_B is: ' || to_char(l_timestamp3/100) || ' seconds.');
  FII_UTIL.put_line('The time taken to populate FII_AP_Aging_Bkts_B_MS and FII_AP_Due_Counts_B_MS is: ' || to_char(l_timestamp4/100) || ' seconds.');
end if;


--Populate Tables from Memory Structures.
  POPULATE_TABLES_FROM_MS;

--Update, Insert, or Delete Records into FII_AP_Pay_Sched_B.
  MAINTAIN_PAY_SCHED_B;

--Update, Insert, or Delete Records into FII_AP_Invoice_B.
  MAINTAIN_INVOICE_B;


  g_state := 'Updating Supplier_ID in FII_AP_AGING_BKTS_B';
  UPDATE FII_AP_AGING_BKTS_B AB
  SET    Supplier_ID   =  (SELECT AI.Supplier_ID
                           FROM   FII_AP_Invoice_B AI
                           WHERE  AI.Invoice_ID = AB.Invoice_ID)
  WHERE  AB.Invoice_ID IN (SELECT Key_Value1_Num
                           FROM   FII_AP_DBI_LOG_T
                           WHERE  Table_Name = 'AP_INVOICES'
                           AND    Operation_Flag = 'U');

  g_state := 'Updating Supplier_ID in FII_AP_DUE_COUNTS_B';
  UPDATE FII_AP_DUE_COUNTS_B DC
  SET    Supplier_ID   =  (SELECT AI.Supplier_ID
                           FROM   FII_AP_Invoice_B AI
                           WHERE  AI.Invoice_ID = DC.Invoice_ID)
  WHERE  DC.Invoice_ID IN (SELECT Key_Value1_Num
                           FROM   FII_AP_DBI_LOG_T
                           WHERE  Table_Name = 'AP_INVOICES'
                           AND    Operation_Flag = 'U');



EXCEPTION
   WHEN OTHERS THEN
      g_errbuf:=sqlerrm;
      g_retcode:= -1;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);
      RAISE;
END POPULATE_INV_PAY_SCHED_SUM;


-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

-- Procedure
--   Collect()
-- Purpose
--   This Collect routine Handles all functions involved in the AP summarization
--   and populating FII AP summary tables .

-----------------------------------------------------------
--  PROCEDURE COLLECT
-----------------------------------------------------------
Procedure Collect(Errbuf          IN OUT NOCOPY VARCHAR2,
                  Retcode         IN OUT NOCOPY VARCHAR2
                  ) IS

  l_dir                VARCHAR2(400);
  l_start_date    DATE := NULL;
  l_end_date      DATE := NULL;
  l_period_from   DATE := NULL;
  l_period_to     DATE := NULL;

  l_start_date_temp    DATE := NULL;

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
  l_dir:='/sqlcom/log';

  ----------------------------------------------------------------
  -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
  -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
  -- the log files and output files are written to
  ----------------------------------------------------------------
  FII_UTIL.initialize('FII_AP_INV_SUM_INC.log','FII_AP_INV_SUM_INC.out',l_dir, 'FII_AP_INV_SUM_INC');

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


  g_state := 'Calling BIS_COLLECTION_UTILITIES.setup';
  IF(NOT BIS_COLLECTION_UTILITIES.setup('FII_AP_INV_SUM_INC')) THEN
        raise_application_error(-20000, errbuf);
        return;
  END IF;

  ------------------------------------------------------------
  --Get timestamps used to maintain ap_dbi_log.
  --g_timestamp1 - current timestamp.
  --g_timestamp2 - last Payables Operation/Expenses load.
  --g_timestamp3 - last Payables Expenses load, if implemented.
  --g_timestamp4 - last Payables Operation load.
  -------------------------------------------------------------
  g_state := 'Defining timestamps to maintain ap_dbi_log.';
  IF g_debug_flag = 'Y' then
    FII_UTIL.put_line('');
    FII_UTIL.put_line(g_state);
    fii_util.put_line('');
  END IF;

  g_timestamp1 := BIS_COLLECTION_UTILITIES.G_Start_Date;

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_SUM_INIT',
                                                   l_start_date, l_end_date,
                                                   l_period_from, l_period_to);

  g_start_date := NVL(l_period_from, BIS_COMMON_PARAMETERS.Get_Global_Start_Date);

  BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_SUM_INC',
                                                   l_start_date_temp, l_end_date,
                                                   l_period_from, l_period_to);

  l_start_date := GREATEST(NVL(l_start_date, BIS_COMMON_PARAMETERS.Get_Global_Start_Date),
                           NVL(l_start_date_temp, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));

  g_timestamp2 := l_start_date;
  g_timestamp4 := l_start_date;

  IF g_exp_imp_prof_flag = 'Y' THEN

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_DISTRIBUTIONS_B_L',
                                                     l_start_date, l_end_date,
                                                     l_period_from, l_period_to);

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_DISTRIBUTIONS_B_I',
                                                     l_start_date_temp, l_end_date,
                                                     l_period_from, l_period_to);

    l_start_date := GREATEST(NVL(l_start_date, BIS_COMMON_PARAMETERS.Get_Global_Start_Date),
                             NVL(l_start_date_temp, BIS_COMMON_PARAMETERS.Get_Global_Start_Date));

    g_timestamp3 := l_start_date;
    g_timestamp2 := GREATEST(g_timestamp2, g_timestamp3);
  END IF;

  g_last_start_date := TRUNC(g_timestamp4);

  g_act_part1 := MOD(TO_NUMBER(TO_CHAR(TRUNC(g_timestamp1), 'J')), 32);
  g_act_part2 := MOD(TO_NUMBER(TO_CHAR(TRUNC(g_timestamp1+1), 'J')), 32);

  g_old_act_part1 := MOD(TO_NUMBER(TO_CHAR(TRUNC(g_timestamp2), 'J')), 32);
  g_old_act_part2 := MOD(TO_NUMBER(TO_CHAR(TRUNC(g_timestamp2+1), 'J')), 32);

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('Start date is: ' || g_start_date);
   FII_UTIL.put_line('Last load included invoices to date ' || g_last_start_date);

   FII_UTIL.put_line('Current Load Timestamp is: ' || to_char(g_timestamp1, 'YYYY/MM/DD HH24:MI:SS'));
   FII_UTIL.put_line('Previous Payables Load Timestamp is: ' || to_char(g_timestamp2, 'YYYY/MM/DD HH24:MI:SS'));
   FII_UTIL.put_line('Previous Payables Expenses Load Timestamp is: ' || to_char(g_timestamp3, 'YYYY/MM/DD HH24:MI:SS'));
   FII_UTIL.put_line('Previous Payables Operations Load Timestamp is: ' || to_char(g_timestamp4, 'YYYY/MM/DD HH24:MI:SS'));
  end if;

  IF g_timestamp4 + 30 < g_timestamp1 THEN
    g_errbuf := fnd_message.get_string('FII', 'FII_AP_RUN_INIT');
    RAISE G_RUN_INIT;
  END IF;


  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Calling the Init procedure to initialize the global variables');
   FII_UTIL.put_line('-------------------------------------------------');
  end if;

  INIT;


  g_state := 'Truncating temp tables used to populate base tables';
  TRUNCATE_TABLE('FII_AP_PS_RATES_TEMP');
  TRUNCATE_TABLE('FII_AP_FUNC_RATES_TEMP');
--  TRUNCATE_TABLE('FII_AP_PAY_SCHED_TEMP');
--  TRUNCATE_TABLE('FII_AP_PAY_SCHED_ID');
--  TRUNCATE_TABLE('FII_AP_WH_TAX_T');
--  TRUNCATE_TABLE('FII_AP_PREPAY_T');

  TRUNCATE_TABLE('FII_AP_DBI_LOG_T');
  TRUNCATE_TABLE('FII_AP_INVOICE_IDS');

  INSERT into FII_AP_DBI_LOG_T(Key_Value1_Num,
                               Key_Value2_Num,
                               Table_Name,
                               Operation_Flag,
                               Creation_Date,
                               Created_By,
                               Last_Update_Date,
                               Last_Updated_By,
                               Last_Update_Login)
  SELECT Key_Value1_Num,
         Key_Value2_Num,
         Table_Name,
         Operation_Flag,
         sysdate Creation_Date,
         g_fii_user_id Created_By,
         sysdate Last_Update_Date,
         g_fii_user_id Last_Updated_By,
         g_fii_login_id Last_Update_Login
  FROM (SELECT Key_Value1 Key_Value1_Num,
               Key_Value2 Key_Value2_Num,
               Table_Name,
               Operation_Flag
        FROM AP_DBI_LOG
        WHERE Creation_Date >= g_timestamp2
        AND   Creation_Date < g_timestamp1
        UNION
        SELECT Key_Value1_ID Key_Value1_Num,
               Key_Value2_ID Key_Value2_Num,
               Table_Name,
               Operation_Flag
        FROM FII_AP_DBI_Log_PS_T)
  GROUP BY Key_Value1_Num, Key_Value2_Num, Table_Name, Operation_Flag;

  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_DBI_LOG_T');

  COMMIT;


  g_state := 'Inserting records into the FII_AP_INVOICE_IDS table';
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('');
     FII_UTIL.put_line(g_state);
     FII_UTIL.start_timer;
     FII_UTIL.put_line('');
  end if;

  INSERT INTO FII_AP_Invoice_IDS
        (Invoice_ID,
         Invoice_B_Flag,
         Pay_Sched_B_Flag,
         Get_Rate_Flag,
         Delete_Inv_Flag,
         Last_Update_Date,
         Last_Updated_By,
         Creation_Date,
         Created_By,
         Last_Update_Login)
  SELECT INVIDS.Invoice_ID,
         CASE WHEN MAX(DECODE(Rank, 1, 1, 0)) = 1 THEN 'Y' ELSE 'N' END Invoice_B_Flag,
         CASE WHEN MAX(DECODE(Rank, 2, 1, 0)) = 1 THEN 'Y' ELSE 'N' END Pay_Sched_B_Flag,
         CASE WHEN MAX(DECODE(Rank,1, DECODE(Operation_Flag, 'D', 0, 1), 0)) = 1 OR MAX(DECODE(Rank, 2, 1, 0)) = 1
              THEN 'Y' ELSE 'N' END Get_Rate_Flag,
         CASE WHEN MAX(CASE WHEN Rank = 1
                            AND  Table_Name = 'AP_INVOICES'
                            AND  Operation_Flag = 'D' THEN 1 ELSE 0 END) = 1
              THEN 'Y' ELSE 'N' END Delete_Inv_Flag,
         sysdate Last_Update_Date,
         g_fii_user_id Last_Updated_By,
         sysdate Creation_Date,
         g_fii_user_id Created_By,
         g_fii_login_id Last_Update_Login
  FROM (SELECT Key_Value1_Num Invoice_ID,
               1 Rank,
               Table_Name,
               Operation_Flag
        FROM FII_AP_DBI_LOG_T
        WHERE Table_Name IN ('AP_INVOICES', 'AP_HOLDS', 'AP_PAYMENT_SCHEDULES',
                             'AP_INVOICE_DISTRIBUTIONS')
        UNION
        SELECT Invoice_ID,
               2 Rank,
               Table_Name,
               Operation_Flag
        FROM (
              SELECT Key_Value1_Num Invoice_ID,
                     Table_Name,
                     Operation_Flag
              FROM   FII_AP_DBI_LOG_T
              WHERE  Table_Name = 'AP_PAYMENT_SCHEDULES'
              UNION
              SELECT LOG.Key_Value1_Num Invoice_ID,
                     LOG.Table_Name Table_Name,
                     LOG.Operation_Flag Operation_Flag
              FROM   FII_AP_DBI_LOG_T LOG, AP_Invoice_Distributions_All AID
              WHERE  LOG.Table_Name = 'AP_INVOICE_DISTRIBUTIONS'
              AND    LOG.Key_Value2_Num = AID.Invoice_Distribution_ID
              AND    AID.Line_Type_Lookup_Code IN ('PREPAY', 'AWT', 'NONREC_TAX', 'REC_TAX')
              UNION
              SELECT AIP.Invoice_ID Invoice_ID,
                     Table_Name,
                     Operation_Flag
              FROM   FII_AP_DBI_LOG_T LOG, AP_Invoice_Payments_All AIP
              WHERE  Table_Name = 'AP_INVOICE_PAYMENTS'
              AND    LOG.Key_Value1_Num = AIP.Invoice_Payment_ID
              UNION
              SELECT PS.Invoice_ID Invoice_ID,
                     'OTHER' Table_Name,
                     'U' Operation_Flag
              FROM   AP_Payment_Schedules_All PS
              WHERE  Payment_Status_Flag IN ('N', 'P')
              AND   ((g_last_start_date <= TRUNC(PS.Discount_Date)
                     AND TRUNC(PS.Discount_Date) < g_sysdate)
              OR     (g_last_start_date <= TRUNC(PS.Second_Discount_Date)
                     AND TRUNC(PS.Second_Discount_Date) < g_sysdate)
              OR     (g_last_start_date <= TRUNC(PS.Third_Discount_Date)
                     AND TRUNC(PS.Third_Discount_Date) < g_sysdate)
              OR     (g_last_start_date <= (TRUNC(PS.Due_Date) - g_due_bucket2 - 1)
                     AND (TRUNC(PS.Due_Date) - g_due_bucket2 - 1) < g_sysdate)
              OR     (g_last_start_date <= (TRUNC(PS.Due_Date) - g_due_bucket3 - 1)
                     AND (TRUNC(PS.Due_Date) - g_due_bucket3 - 1) < g_sysdate)
              OR     (g_last_start_date <= TRUNC(PS.Due_Date)
                     AND TRUNC(PS.Due_Date) < g_sysdate)
              OR     (g_last_start_date <= (TRUNC(PS.Due_Date) + g_past_bucket3)
                     AND (TRUNC(PS.Due_Date) + g_past_bucket3) < g_sysdate)
              OR     (g_last_start_date <= (TRUNC(PS.Due_Date) + g_past_bucket2)
                     AND (TRUNC(PS.Due_Date) + g_past_bucket2) < g_sysdate)))) INVIDS
            GROUP BY INVIDS.Invoice_ID;

    /* Commenting this code as per performance bug review
    Bug 4943180.  Don't find any functional reason, why we should join
    to AP_INVOICES_ALL table here. Only join here between AP_INVOICES_ALL
    and INVIDS is on invoice_id and that is a outer join. All other
    whereclauses doesn't do much in that situation */


                     /*,
       AP_Invoices_All AI
  WHERE INVIDS.Invoice_ID = AI.Invoice_ID (+)
  AND (AI.Invoice_Type_Lookup_Code IS NULL OR AI.Invoice_Type_Lookup_Code <> 'EXPENSE REPORT')
  AND (AI.Invoice_Amount IS NULL OR AI.Invoice_Amount <> 0 OR (AI.Invoice_Amount = 0 AND AI.Cancelled_Date IS NOT NULL))
  AND (AI.Creation_Date IS NULL OR TRUNC(AI.Creation_Date) >= g_start_date)*/



  FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_INVOICE_IDS');


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
       FII_UTIL.put_line('Calling procedure DELETE_SUMMARY');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    DELETE_SUMMARY;
    g_retcode := 0;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_INV_PAY_SCHED_SUM');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_INV_PAY_SCHED_SUM;
    g_retcode := 0;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_HOLDS_SUM');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_HOLDS_SUM;
    g_retcode := 0;


    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('-------------------------------------------------');
       FII_UTIL.put_line('Calling procedure POPULATE_HOLD_HISTORY');
       FII_UTIL.put_line('-------------------------------------------------');
    end if;

    POPULATE_HOLD_HISTORY;
    g_retcode := 0;

    FOR i IN 0..31 LOOP --i represents the partition of ap_dbi_log.

      IF g_timestamp3 + 30 >= g_timestamp1 AND g_exp_imp_prof_flag = 'Y' THEN --Copy records into Expense log table.

        g_state := 'Copying records from partition ' || i || ' into FII_AP_DBI_LOG_EXP_T.';
        if g_debug_flag = 'Y' then
          fii_util.put_line(g_state);
        end if;


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

    TRUNCATE_TABLE('FII_AP_DBI_LOG_PS_T');

    g_state := 'Truncating temp tables after used to populate base tables';
--    TRUNCATE_TABLE('FII_AP_PAY_SCHED_TEMP');
--    TRUNCATE_TABLE('FII_AP_PAY_SCHED_ID);
--    TRUNCATE_TABLE('FII_AP_WH_TAX_T');
--    TRUNCATE_TABLE('FII_AP_PREPAY_T');


  END IF;

  COMMIT;

  if g_debug_flag = 'Y' then
     FII_UTIL.put_line('return code is ' || retcode);
  end if;
  Retcode := g_retcode;

  g_state := 'Calling BIS_COLLECTION_UTILITIES.wrapup';
  BIS_COLLECTION_UTILITIES.wrapup(
      p_status => TRUE,
      p_period_from => l_period_from,
      p_period_to => g_timestamp1);


EXCEPTION
  WHEN OTHERS THEN
    g_errbuf:=g_errbuf;
    g_retcode:= -1;
    retcode:=g_retcode;
    g_exception_msg  := g_retcode || ':' || g_errbuf;
    FII_UTIL.put_line('Error occured while ' || g_state);
    FII_UTIL.put_line(g_exception_msg);

END;

END FII_AP_INV_SUM_INC;

/
