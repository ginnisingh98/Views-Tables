--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_PAYMTS_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_PAYMTS_F_C" AS
/* $Header: FIIAP10B.pls 120.13 2004/11/19 06:09:49 sgautam ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf      VARCHAR2(2000) := NULL;
 g_retcode     VARCHAR2(200) := NULL;
 g_missing_rates      Number:=0;
 g_collect_er         Varchar2(1);  -- Added for iExpense Enhancement,12-DEC-02
 g_acct_or_inv_date   Number;    -- Added for Currency Conversion Date Enhancement , 07-APR-03
-----------------------------------------------------------
--  PROCEDURE TRUNCATE_TABLE
-----------------------------------------------------------

 PROCEDURE TRUNCATE_TABLE (table_name varchar2)
 IS

  l_fii_schema          VARCHAR2(30);
  l_stmt       VARCHAR2(200);
  l_status     VARCHAR2(30);
  l_industry      VARCHAR2(30);

 BEGIN
      IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
         l_stmt := 'TRUNCATE TABLE ' || l_fii_schema ||'.'||table_name;
         EXECUTE IMMEDIATE l_stmt;
      END IF;
      edw_log.put_line(' ');
      edw_log.put_line('Truncating '|| table_name||' table');

 END;

-----------------------------------------------------------
--  PROCEDURE DELETE_STG
-----------------------------------------------------------

 PROCEDURE DELETE_STG
 IS

 BEGIN
   DELETE FII_AP_INV_PAYMTS_FSTG
   WHERE  COLLECTION_STATUS = 'LOCAL READY' OR ( COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR COLLECTION_STATUS = 'INVALID CURRENCY')
   AND    INSTANCE = (SELECT INSTANCE_CODE
                     FROM   EDW_LOCAL_INSTANCE);
 END;
------------------------------------------------------------
--PROCEDURE INSERT_MISSING_RATES_IN_TMP
-------------------------------------------------------------
--Identify records that have missing rates and insert them in a temp table

PROCEDURE INSERT_MISSING_RATES_IN_TMP
IS

 BEGIN

   -- --------------------------------------------------------------------------------------------------
   -- The variable g_acct_or_inv_date is added in the below mentioned select statement.
   -- The profile option stored in the global variable g_acct_or_inv_date
   -- will be stored in the column Primary_Key5 . Modified for Currency Conversion Date Enhancement,25-APR-03
   -----------------------------------------------------------------------------------------------------

   INSERT INTO fii_ap_tmp_ipay_pk( Primary_Key1,Primary_Key5)
   SELECT
              TO_NUMBER(SUBSTR (INV_PAYMENT_PK, 1, INSTR(INV_PAYMENT_PK, '-' )-1)) ,
   g_acct_or_inv_date

   FROM  FII_AP_INV_PAYMTS_FSTG fsi

   WHERE

               fsi.COLLECTION_STATUS = 'RATE NOT AVAILABLE'
   OR
               fsi.COLLECTION_STATUS = 'INVALID CURRENCY';

   IF (sql%rowcount > 0) THEN
        g_retcode := 1;
        g_missing_rates := 1;
   END IF;
--Generates "Warning" message in the Status column of Concurrent Manager "Requests" table

      edw_log.put_line(' ');
      edw_log.put_line('INSERTING ' || to_char(sql%rowcount) || ' rows from staging table');
      edw_log.put_line('g_retcode is '||g_retcode);
 END;

--------------------------------------------------
--FUNCTION LOCAL_SAME_AS_REMOTE
---------------------------------------------------

 FUNCTION LOCAL_SAME_AS_REMOTE RETURN BOOLEAN
 IS

 l_instance1                Varchar2(100) :=Null;
 l_instance2                Varchar2(100) :=Null;

 BEGIN


   SELECT instance_code
   INTO   l_instance1
   FROM   edw_local_instance;

   SELECT instance_code
   INTO   l_instance2
   FROM   edw_local_instance@edw_apps_to_wh;

   IF (l_instance1 = l_instance2) THEN
      RETURN TRUE;
   END IF;

   RETURN FALSE;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN

     RETURN FALSE;

 END;


--------------------------------------------------
--FUNCTION SET_STATUS_READY
---------------------------------------------------

 FUNCTION SET_STATUS_READY RETURN NUMBER
 IS

 BEGIN

   UPDATE FII_AP_INV_PAYMTS_FSTG
   SET    COLLECTION_STATUS = 'READY'
   WHERE  COLLECTION_STATUS = 'LOCAL READY'
   AND    INSTANCE = (SELECT INSTANCE_CODE
                     FROM   EDW_LOCAL_INSTANCE);

   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     rollback;
     RETURN(-1);

 END;

-----------------------------------------------------------
--FUNCTION PUSH_TO_LOCAL
-----------------------------------------------------------

 FUNCTION PUSH_TO_LOCAL RETURN NUMBER IS

  l_mau                 number;   -- minimum accountable unit of
                                  -- global warehouse currency

  L_MAU_NOT_AVAILABLE  exception;

BEGIN

  -- get minimum accountable unit of the warehouse currency;

  l_mau := nvl( edw_currency.get_mau, 0.01 );

   -- ------------------------------------------------
   -- We set the COLLECTION_STATUS to 'LOCAL READY'.
   -- In case of source=target, we need to separate
   -- out the records in progress vs the records which
   -- is ready to be picked up by collection enginee.
   -- In our case, we consider the records to be in
   -- progress until all the child processes have
   -- completed successfully.
   -- ------------------------------------------------
   fii_flex_mapping.init_cache('FII_AP_INV_PAYMTS_F');

   Insert Into FII_AP_INV_PAYMTS_FSTG(
     ACCOUNTING_DATE,
     ACCRUAL_POSTED_FLAG,
     ASSETS_ADDITION_FLAG,
     BANK_ACCOUNT_ID,
     BASE_CURRENCY_CODE,
     CASH_JE_BATCH_ID,
     CASH_POSTED_FLAG,
     CCID,
     CHECK_DATE,
     CREATION_DATE,
     DISC_AMT_LOST_B,
     DISC_AMT_LOST_G,
     DISC_AMT_LOST_T,
     DISC_AMT_TAKEN_B,
     DISC_AMT_TAKEN_G,
     DISC_AMT_TAKEN_T,
     DUNS_FK,
     EARLY_DISC_PAYMENT_AMT_B,
     EARLY_DISC_PAYMENT_AMT_G,
     EARLY_DISC_PAYMENT_AMT_T,
     EARLY_DISC_PAYMENT_COUNT,
     EARLY_DISC_PAYMENT_DAYS,
     EARLY_NET_PAYMENT_AMT_B,
     EARLY_NET_PAYMENT_AMT_G,
     EARLY_NET_PAYMENT_AMT_T,
     EARLY_NET_PAYMENT_COUNT,
     EARLY_NET_PAYMENT_DAYS,
     EMPLOYEE_FK,
     FUTURE_PAY_POSTED_FLAG,
     GEOGRAPHY_FK,
     GL_ACCT10_FK,
     GL_ACCT1_FK,
     GL_ACCT2_FK,
     GL_ACCT3_FK,
     GL_ACCT4_FK,
     GL_ACCT5_FK,
     GL_ACCT6_FK,
     GL_ACCT7_FK,
     GL_ACCT8_FK,
     GL_ACCT9_FK,
     INSTANCE,
     INSTANCE_FK,
     INVOICE_DATE,
     INV_CURRENCY_CODE,
     INV_EXCHANGE_DATE,
     INV_EXCHANGE_RATE,
     INV_EXCHANGE_RATE_TYPE,
     INV_FK,
     INV_NUM,
     INV_PAYMENT_PK,
     INV_PAYMENT_STATUS_FLAG,
     INV_PAYMENT_TYPE,
     INV_SOURCE,
     INV_SOURCE_FK,
     INV_TYPE,
     JE_BATCH_ID,
     LAST_UPDATE_DATE,
     LATE_DISC_DAYS,
     LATE_DISC_PAYMENT_AMT_B,
     LATE_DISC_PAYMENT_AMT_G,
     LATE_DISC_PAYMENT_AMT_T,
     LATE_DISC_PAYMENT_COUNT,
     LATE_NET_PAYMENT_AMT_B,
     LATE_NET_PAYMENT_AMT_G,
     LATE_NET_PAYMENT_AMT_T,
     LATE_NET_PAYMENT_COUNT,
     LATE_NET_PAYMENT_DAYS,
     ORG_FK,
     PAYMENT_AMT_B,
     PAYMENT_AMT_G,
     PAYMENT_AMT_T,
     PAYMENT_COUNT,
     PAYMENT_CURRENCY_CODE,
     PAYMENT_CURRENCY_FK,
     PAYMENT_DATE_FK,
     PAYMENT_EXCHANGE_DATE,
     PAYMENT_EXCHANGE_RATE,
     PAYMENT_EXCHANGE_RATE_TYPE,
     PAYMENT_FK,
     PAYMENT_TERM_FK,
     POSTED_FLAG,
     SIC_CODE_FK,
     SOB_FK,
     SUPPLIER_FK,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     USER_FK1,
     USER_FK2,
     USER_FK3,
     USER_FK4,
     USER_FK5,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     OPERATION_CODE,
     COLLECTION_STATUS,
     CHECK_AMT_B,  -- added these four columns for New Information Enhancement
     CHECK_AMT_T,
     CHECK_AMT_G,
     CHECK_NUMBER)
   select
     ACCOUNTING_DATE,
     ACCRUAL_POSTED_FLAG,
     ASSETS_ADDITION_FLAG,
     BANK_ACCOUNT_ID,
     BASE_CURRENCY_CODE,
     CASH_JE_BATCH_ID,
     CASH_POSTED_FLAG,
     CCID,
     CHECK_DATE,
     CREATION_DATE,
     DISC_AMT_LOST_B,
            round((DISC_AMT_LOST_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     DISC_AMT_LOST_T,
     DISC_AMT_TAKEN_B,
            round((DISC_AMT_TAKEN_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     DISC_AMT_TAKEN_T,
     NVL(DUNS_FK,'NA_EDW'),
     EARLY_DISC_PAYMENT_AMT_B,
            round((EARLY_DISC_PAYMENT_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     EARLY_DISC_PAYMENT_AMT_T,
     EARLY_DISC_PAYMENT_COUNT,
     EARLY_DISC_PAYMENT_DAYS,
     EARLY_NET_PAYMENT_AMT_B,
            round((EARLY_NET_PAYMENT_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     EARLY_NET_PAYMENT_AMT_T,
     EARLY_NET_PAYMENT_COUNT,
     EARLY_NET_PAYMENT_DAYS,
     NVL(EMPLOYEE_FK,'NA_EDW'),
     FUTURE_PAY_POSTED_FLAG,
     NVL(GEOGRAPHY_FK,'NA_EDW'),
     NVL(GL_ACCT10_FK,'NA_EDW'),
     NVL(GL_ACCT1_FK,'NA_EDW'),
     NVL(GL_ACCT2_FK,'NA_EDW'),
     NVL(GL_ACCT3_FK,'NA_EDW'),
     NVL(GL_ACCT4_FK,'NA_EDW'),
     NVL(GL_ACCT5_FK,'NA_EDW'),
     NVL(GL_ACCT6_FK,'NA_EDW'),
     NVL(GL_ACCT7_FK,'NA_EDW'),
     NVL(GL_ACCT8_FK,'NA_EDW'),
     NVL(GL_ACCT9_FK,'NA_EDW'),
     INSTANCE,
     NVL(INSTANCE_FK,'NA_EDW'),
     INVOICE_DATE,
     INV_CURRENCY_CODE,
     INV_EXCHANGE_DATE,
     INV_EXCHANGE_RATE,
     INV_EXCHANGE_RATE_TYPE,
     NVL(INV_FK,'NA_EDW'),
     INV_NUM,
     INV_PAYMENT_PK,
     INV_PAYMENT_STATUS_FLAG,
     INV_PAYMENT_TYPE,
     INV_SOURCE,
     NVL(INV_SOURCE_FK,'NA_EDW'),
     INV_TYPE,
     JE_BATCH_ID,
     LAST_UPDATE_DATE,
     LATE_DISC_DAYS,
     LATE_DISC_PAYMENT_AMT_B,
            round((LATE_DISC_PAYMENT_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     LATE_DISC_PAYMENT_AMT_T,
     LATE_DISC_PAYMENT_COUNT,
     LATE_NET_PAYMENT_AMT_B,
            round((LATE_NET_PAYMENT_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     LATE_NET_PAYMENT_AMT_T,
     LATE_NET_PAYMENT_COUNT,
     LATE_NET_PAYMENT_DAYS,
     NVL(ORG_FK,'NA_EDW'),
     PAYMENT_AMT_B,
            round((PAYMENT_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     PAYMENT_AMT_T,
     PAYMENT_COUNT,
     PAYMENT_CURRENCY_CODE,
     NVL(PAYMENT_CURRENCY_FK,'NA_EDW'),
     NVL(PAYMENT_DATE_FK,'NA_EDW'),
     PAYMENT_EXCHANGE_DATE,
     PAYMENT_EXCHANGE_RATE,
     PAYMENT_EXCHANGE_RATE_TYPE,
     NVL(PAYMENT_FK,'NA_EDW'),
     NVL(PAYMENT_TERM_FK,'NA_EDW'),
     POSTED_FLAG,
     NVL(SIC_CODE_FK,'NA_EDW'),
     NVL(SOB_FK,'NA_EDW'),
     NVL(SUPPLIER_FK,'NA_EDW'),
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     NULL, -- OPERATION_CODE
     decode(GLOBAL_CURRENCY_RATE,
            NULL, 'RATE NOT AVAILABLE',
            -1, 'RATE NOT AVAILABLE',
            -2, 'RATE NOT AVAILABLE',
            'LOCAL READY'),
     CHECK_AMT_B, -- added these four columns for New Information Enhancement
     CHECK_AMT_T,
     round((CHECK_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau CHECK_AMT_G,
     CHECK_NUMBER
   from FII_AP_INV_PAYMTS_FCV;
   fii_flex_mapping.free_mem_all;
   edw_log.put_line('g_row_count is');
   edw_log.put_line(TO_CHAR(sql%rowcount));
   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     rollback;
     RETURN(-1);

END;

-----------------------------------------------------------
--  FUNCTION PUSH_REMOTE
-----------------------------------------------------------
 FUNCTION PUSH_REMOTE RETURN NUMBER
 IS

  BEGIN
   Insert Into FII_AP_INV_PAYMTS_FSTG@EDW_APPS_TO_WH(
     ACCOUNTING_DATE,
     ACCRUAL_POSTED_FLAG,
     ASSETS_ADDITION_FLAG,
     BANK_ACCOUNT_ID,
     BASE_CURRENCY_CODE,
     CASH_JE_BATCH_ID,
     CASH_POSTED_FLAG,
     CCID,
     CHECK_DATE,
     CREATION_DATE,
     DISC_AMT_LOST_B,
     DISC_AMT_LOST_G,
     DISC_AMT_LOST_T,
     DISC_AMT_TAKEN_B,
     DISC_AMT_TAKEN_G,
     DISC_AMT_TAKEN_T,
     DUNS_FK,
     EARLY_DISC_PAYMENT_AMT_B,
     EARLY_DISC_PAYMENT_AMT_G,
     EARLY_DISC_PAYMENT_AMT_T,
     EARLY_DISC_PAYMENT_COUNT,
     EARLY_DISC_PAYMENT_DAYS,
     EARLY_NET_PAYMENT_AMT_B,
     EARLY_NET_PAYMENT_AMT_G,
     EARLY_NET_PAYMENT_AMT_T,
     EARLY_NET_PAYMENT_COUNT,
     EARLY_NET_PAYMENT_DAYS,
     EMPLOYEE_FK,
     FUTURE_PAY_POSTED_FLAG,
     GEOGRAPHY_FK,
     GL_ACCT10_FK,
     GL_ACCT1_FK,
     GL_ACCT2_FK,
     GL_ACCT3_FK,
     GL_ACCT4_FK,
     GL_ACCT5_FK,
     GL_ACCT6_FK,
     GL_ACCT7_FK,
     GL_ACCT8_FK,
     GL_ACCT9_FK,
     INSTANCE,
     INSTANCE_FK,
     INVOICE_DATE,
     INV_CURRENCY_CODE,
     INV_EXCHANGE_DATE,
     INV_EXCHANGE_RATE,
     INV_EXCHANGE_RATE_TYPE,
     INV_FK,
     INV_NUM,
     INV_PAYMENT_PK,
     INV_PAYMENT_STATUS_FLAG,
     INV_PAYMENT_TYPE,
     INV_SOURCE,
     INV_SOURCE_FK,
     INV_TYPE,
     JE_BATCH_ID,
     LAST_UPDATE_DATE,
     LATE_DISC_DAYS,
     LATE_DISC_PAYMENT_AMT_B,
     LATE_DISC_PAYMENT_AMT_G,
     LATE_DISC_PAYMENT_AMT_T,
     LATE_DISC_PAYMENT_COUNT,
     LATE_NET_PAYMENT_AMT_B,
     LATE_NET_PAYMENT_AMT_G,
     LATE_NET_PAYMENT_AMT_T,
     LATE_NET_PAYMENT_COUNT,
     LATE_NET_PAYMENT_DAYS,
     ORG_FK,
     PAYMENT_AMT_B,
     PAYMENT_AMT_G,
     PAYMENT_AMT_T,
     PAYMENT_COUNT,
     PAYMENT_CURRENCY_CODE,
     PAYMENT_CURRENCY_FK,
     PAYMENT_DATE_FK,
     PAYMENT_EXCHANGE_DATE,
     PAYMENT_EXCHANGE_RATE,
     PAYMENT_EXCHANGE_RATE_TYPE,
     PAYMENT_FK,
     PAYMENT_TERM_FK,
     POSTED_FLAG,
     SIC_CODE_FK,
     SOB_FK,
     SUPPLIER_FK,
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     USER_FK1,
     USER_FK2,
     USER_FK3,
     USER_FK4,
     USER_FK5,
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     OPERATION_CODE,
     COLLECTION_STATUS,
     CHECK_AMT_B,  -- added these four columns for New Information Enhancement
     CHECK_AMT_T,
     CHECK_AMT_G,
     CHECK_NUMBER)
   select
     ACCOUNTING_DATE,
     substrb(ACCRUAL_POSTED_FLAG,1,1),
     substrb(ASSETS_ADDITION_FLAG,1,1),
     BANK_ACCOUNT_ID,
     substrb(BASE_CURRENCY_CODE,1,15),
     CASH_JE_BATCH_ID,
     substrb(CASH_POSTED_FLAG,1,1),
     CCID,
     CHECK_DATE,
     CREATION_DATE,
     DISC_AMT_LOST_B,
     DISC_AMT_LOST_G,
     DISC_AMT_LOST_T,
     DISC_AMT_TAKEN_B,
     DISC_AMT_TAKEN_G,
     DISC_AMT_TAKEN_T,
     NVL(DUNS_FK,'NA_EDW'),
     EARLY_DISC_PAYMENT_AMT_B,
     EARLY_DISC_PAYMENT_AMT_G,
     EARLY_DISC_PAYMENT_AMT_T,
     EARLY_DISC_PAYMENT_COUNT,
     EARLY_DISC_PAYMENT_DAYS,
     EARLY_NET_PAYMENT_AMT_B,
     EARLY_NET_PAYMENT_AMT_G,
     EARLY_NET_PAYMENT_AMT_T,
     EARLY_NET_PAYMENT_COUNT,
     EARLY_NET_PAYMENT_DAYS,
     NVL(EMPLOYEE_FK,'NA_EDW'),
     substrb(FUTURE_PAY_POSTED_FLAG,1,1),
     NVL(GEOGRAPHY_FK,'NA_EDW'),
     NVL(GL_ACCT10_FK,'NA_EDW'),
     NVL(GL_ACCT1_FK,'NA_EDW'),
     NVL(GL_ACCT2_FK,'NA_EDW'),
     NVL(GL_ACCT3_FK,'NA_EDW'),
     NVL(GL_ACCT4_FK,'NA_EDW'),
     NVL(GL_ACCT5_FK,'NA_EDW'),
     NVL(GL_ACCT6_FK,'NA_EDW'),
     NVL(GL_ACCT7_FK,'NA_EDW'),
     NVL(GL_ACCT8_FK,'NA_EDW'),
     NVL(GL_ACCT9_FK,'NA_EDW'),
     substrb(INSTANCE,1,40),
     NVL(INSTANCE_FK,'NA_EDW'),
     INVOICE_DATE,
     substrb(INV_CURRENCY_CODE,1,15),
     INV_EXCHANGE_DATE,
     INV_EXCHANGE_RATE,
     substrb(INV_EXCHANGE_RATE_TYPE,1,30),
     NVL(INV_FK,'NA_EDW'),
     substrb(INV_NUM,1,50),
     substrb(INV_PAYMENT_PK,1,120),
     substrb(INV_PAYMENT_STATUS_FLAG,1,1),
     substrb(INV_PAYMENT_TYPE,1,25),
     substrb(INV_SOURCE,1,25),
     NVL(INV_SOURCE_FK,'NA_EDW'),
     substrb(INV_TYPE,1,25),
     JE_BATCH_ID,
     LAST_UPDATE_DATE,
     LATE_DISC_DAYS,
     LATE_DISC_PAYMENT_AMT_B,
     LATE_DISC_PAYMENT_AMT_G,
     LATE_DISC_PAYMENT_AMT_T,
     LATE_DISC_PAYMENT_COUNT,
     LATE_NET_PAYMENT_AMT_B,
     LATE_NET_PAYMENT_AMT_G,
     LATE_NET_PAYMENT_AMT_T,
     LATE_NET_PAYMENT_COUNT,
     LATE_NET_PAYMENT_DAYS,
     NVL(ORG_FK,'NA_EDW'),
     PAYMENT_AMT_B,
     PAYMENT_AMT_G,
     PAYMENT_AMT_T,
     PAYMENT_COUNT,
     substrb(PAYMENT_CURRENCY_CODE,1,15),
     NVL(PAYMENT_CURRENCY_FK,'NA_EDW'),
     NVL(PAYMENT_DATE_FK,'NA_EDW'),
     PAYMENT_EXCHANGE_DATE,
     PAYMENT_EXCHANGE_RATE,
     substrb(PAYMENT_EXCHANGE_RATE_TYPE,1,30),
     NVL(PAYMENT_FK,'NA_EDW'),
     NVL(PAYMENT_TERM_FK,'NA_EDW'),
     substrb(POSTED_FLAG,1,1),
     NVL(SIC_CODE_FK,'NA_EDW'),
     NVL(SOB_FK,'NA_EDW'),
     NVL(SUPPLIER_FK,'NA_EDW'),
     USER_ATTRIBUTE1,
     USER_ATTRIBUTE10,
     USER_ATTRIBUTE2,
     USER_ATTRIBUTE3,
     USER_ATTRIBUTE4,
     USER_ATTRIBUTE5,
     USER_ATTRIBUTE6,
     USER_ATTRIBUTE7,
     USER_ATTRIBUTE8,
     USER_ATTRIBUTE9,
     NVL(USER_FK1,'NA_EDW'),
     NVL(USER_FK2,'NA_EDW'),
     NVL(USER_FK3,'NA_EDW'),
     NVL(USER_FK4,'NA_EDW'),
     NVL(USER_FK5,'NA_EDW'),
     USER_MEASURE1,
     USER_MEASURE2,
     USER_MEASURE3,
     USER_MEASURE4,
     USER_MEASURE5,
     NULL, -- OPERATION_CODE
     'READY',
     CHECK_AMT_B, -- added these four columns for New Information Enhancement
     CHECK_AMT_T,
     CHECK_AMT_G,
     CHECK_NUMBER
    from FII_AP_INV_PAYMTS_FSTG
    WHERE collection_status = 'LOCAL READY';
--ensures that only the records with collection status of local ready will be pushed to remote fstg
   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     rollback;
     RETURN(-1);

END;


---------------------------------------------------
-- PROCEDURE IDENTIFY_CHANGE
---------------------------------------------------

 PROCEDURE IDENTIFY_CHANGE(p_count OUT NOCOPY NUMBER)
 IS

 l_fii_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);
 l_stmt              VARCHAR2(5000);        -- Added for iExpense Enhancement,12-DEC-02
 l_er_stmt           VARCHAR2(100) := NULL; -- Added for iExpense Enhancement,12-DEC-02

 BEGIN

   p_count := 0;

   --** Added for iExpense Enhancement,12-DEC-02
   IF (g_collect_er <> 'Y') THEN
         l_er_stmt := ' AND ai.invoice_type_lookup_code <> ''EXPENSE REPORT'' ';
   END IF;
   --**

   --** Modified for iExpense Enhancement,12-DEC-02

   -- --------------------------------------------------------------------------------------------------
   -- The variable g_acct_or_inv_date is added in the below mentioned select statement.
   -- The value of the profile option stored in the global variable g_acct_or_inv_date
   -- will be stored in the column Primary_Key5 . Modified for Currency Conversion Date Enhancement, 7-APR-03
   -----------------------------------------------------------------------------------------------------

   l_stmt := ' INSERT INTO fii_ap_tmp_ipay_pk( Primary_Key1,Primary_Key5 )
   SELECT  aip.invoice_payment_id,
           :g_acct_or_inv_date
   FROM    ap_invoice_payments_all aip,
           ap_invoices_all ai
   WHERE   aip.last_update_date BETWEEN :g_push_date_range1 and :g_push_date_range2
   AND     aip.invoice_id = ai.invoice_id'||l_er_stmt||'
   UNION
   SELECT  aip.invoice_payment_id,
           :g_acct_or_inv_date
   FROM    ap_invoice_payments_all aip,
           ap_invoices_all ai
   WHERE   ai.last_update_date BETWEEN :g_push_date_range1 and :g_push_date_range2
   AND     ai.invoice_id = aip.invoice_id'||l_er_stmt||'
   UNION
   SELECT  aip.invoice_payment_id,
           :g_acct_or_inv_date
   FROM    ap_invoice_payments_all aip,
           ap_payment_schedules_all aps,
           ap_invoices_all ai
   WHERE   aps.last_update_date BETWEEN :g_push_date_range1 and :g_push_date_range2
   AND     aps.invoice_id = aip.invoice_id
   AND     aps.payment_num = aip.payment_num
   AND     aip.invoice_id = ai.invoice_id'||l_er_stmt;
   --**

   /* IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_fii_schema,
              TABNAME => 'FII_TMP_PK') ;
   END IF; */

   --** Added for iExpense Enhancement,12-DEC-02
   edw_log.debug_line('');
   edw_log.debug_line(l_stmt);
   execute immediate l_stmt using g_acct_or_inv_date,g_push_date_range1,g_push_date_range2,
                                  g_acct_or_inv_date,g_push_date_range1,g_push_date_range2,
                                  g_acct_or_inv_date,g_push_date_range1,g_push_date_range2;
   --**

   p_count := sql%rowcount;
   edw_log.put_line( 'NO OF ROWS CHANGED '||to_char(p_count));

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
     rollback;

END;

-- ---------------------------------
-- PUBLIC PROCEDURES
-- ---------------------------------

-----------------------------------------------------------
--  PROCEDURE PUSH
-----------------------------------------------------------
 Procedure Push(Errbuf      in out NOCOPY  Varchar2,
                Retcode     in out NOCOPY  Varchar2,
                p_from_date  IN   Varchar2,
                p_to_date    IN   Varchar2) IS
 l_fact_name   Varchar2(30) :='FII_AP_INV_PAYMTS_F'  ;
 l_date1                Date:=Null;
 l_date2                Date:=Null;
 l_temp_date                Date:=Null;
 l_row_count            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
 l_from_date                Date:=Null;
 l_to_date                  Date:=Null;
 my_payment_currency    Varchar2(2000):=NULL;
 my_inv_date            Varchar2(2000) := NULL;
 my_collection_status   Varchar2(2000):=NULL;

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
 l_push_local_failure       EXCEPTION;
 l_push_remote_failure      EXCEPTION;
 l_set_status_failure       EXCEPTION;
 l_iden_change_failure      EXCEPTION;
 rows                   Number:=0;
 rows1                   Number:=0;
 l_count Number := 0; --bug#3947925

   l_to_currency     VARCHAR2(15); -- Added for Currency Conversion Date Enhancement , 7-APR-03
   l_msg             VARCHAR2(120):=NULL; -- Added for Currency Conversion Date Enhancement , 18-APR-03
   l_set_completion_status BOOLEAN; --bug#3207823
   ----------------------------------------------------------------------------------------------
   -- This cursor is for getting records where the CONVERSION_DATE (i.e. GL_DATE or INVOICE_DATE )
   -- is less than the sysdate i.e. in past.  Added for Currency Conversion Date Enhancement , 7-APR-03
   ----------------------------------------------------------------------------------------------
   --bug#3411042 : BASE_CURRENCY_CODE should be printed in the o/p file
	--              since the exchange rate is calculated using
	--              BASE_CURRENCY_CODE


   cursor c1 is select DISTINCT  BASE_CURRENCY_CODE from_currency,
	                                 Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INVOICE_DATE) CONVERSION_DATE,
	                                 COLLECTION_STATUS
	                        From FII_AP_INV_PAYMTS_FSTG
	                       where (COLLECTION_STATUS='RATE NOT AVAILABLE'
	                                  OR COLLECTION_STATUS = 'INVALID CURRENCY')
	                                  AND trunc(Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INVOICE_DATE)) <= trunc(sysdate);


   -----------------------------------------------------------------------------------------------------
   -- This cursor is for getting records where the CONVERSION_DATE (i.e. GL_DATE or INVOICE_DATE )
   -- is greater than the syssdate i.e. in future.  Added for Currency Conversion Date Enhancement , 7-APR-03
   -----------------------------------------------------------------------------------------------------
   --bug#3411042 : BASE_CURRENCY_CODE should be printed in the o/p file
	--              since the exchange rate is calculated using
	--              BASE_CURRENCY_CODE

   cursor c2 is select DISTINCT  BASE_CURRENCY_CODE from_currency,
	                                 Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INVOICE_DATE) CONVERSION_DATE,
	                                 COLLECTION_STATUS
	                        From FII_AP_INV_PAYMTS_FSTG
	                       where (COLLECTION_STATUS='RATE NOT AVAILABLE'
	                                  OR COLLECTION_STATUS = 'INVALID CURRENCY')
	                                  AND trunc(Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INVOICE_DATE)) > trunc(sysdate);



--Cursor declaration required to generate output file containing rows with above collection status
Begin

  execute immediate 'alter session set global_names=false' ; --bug#3207823

  Errbuf :=NULL;
   Retcode:=0;
  l_from_date :=to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
  l_to_date   :=to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  IF (Not EDW_COLLECTION_UTIL.setup(l_fact_name)) THEN
    errbuf := fnd_message.get;
    RAISE_APPLICATION_ERROR(-20000,'Error in SETUP: ' || errbuf);
  END IF;
  FII_AP_INV_PAYMTS_F_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_AP_INV_PAYMTS_F_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
l_date1 := g_push_date_range1;
l_date2 := g_push_date_range2;
   edw_log.put_line( 'The collection range is from '||
        to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

    --bug#3947925
   --Check whether missing rates table has data or not. If not then copy missing rates
   --from temp table to the missing rates table. This is required to avoid full refresh
   --of the fact after application of this patch.
   execute immediate 'select count(*) from FII_AP_IPAY_MSNG_RATES' into l_count;

   if (l_count=0) then
     insert into fii_ap_ipay_msng_rates(Primary_Key1,
                                        Primary_key2,
					Primary_key3)
				select Primary_key1,
				       Primary_key2,
				       Primary_Key5
				from  fii_ap_tmp_ipay_pk;
      commit;
    else

    TRUNCATE_TABLE('FII_AP_TMP_IPAY_PK');--bug#3947925

   --bug#3947925
   --move the missing rates related info. from the missing rates
   --table to the temp table for further processing.
    Insert into fii_ap_tmp_ipay_pk(Primary_Key1,
                                   Primary_Key2,
				   Primary_Key5)
                            select Primary_Key1,
			           Primary_Key2,
				   Primary_Key3
                            from fii_ap_ipay_msng_rates;
    end if;

   -- ---------------------------------------------------------
   -- Fetch profile option value
   -- ---------------------------------------------------------
   g_collect_er := NVL(FND_PROFILE.value('FII_COLLECT_ER'),'N');  -- Added for iExpense Enhancement,12-DEC-02

   ----------------------------------------------------------------------------------------------------------
   -- See whether to use accounting date or invoice date . Added for Currency Conversion Date Enhancement 7-APR-03
   ----------------------------------------------------------------------------------------------------------
   IF NVL(FND_PROFILE.value('FII_ACCT_OR_INV_DATE'),'N') = 'Y' THEN
	 g_acct_or_inv_date := 1;
   ELSE
	 g_acct_or_inv_date := 0;
   END IF;

   --  --------------------------------------------------------
   --  1. Clean up any records left from previous process in
   --     the local staging table.
   --  --------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Cleaning up unprocessed records left in local staging table');
   IF (NOT LOCAL_SAME_AS_REMOTE) THEN
         TRUNCATE_TABLE('FII_AP_INV_PAYMTS_FSTG');
   ELSE
         DELETE_STG;
   END IF;
     select count(*) into rows1 from FII_AP_INV_PAYMTS_FSTG;
     edw_log.put_line('Number of rows in stg after truncating or deleting'||rows1 );
   --  --------------------------------------------------------
   --  2. Identify Changed AP Invoice Payments record
   --  --------------------------------------------------------
    edw_log.put_line(' ');
    edw_log.put_line('Identifying changed AP Invoice Payments record');
    fii_util.start_timer;
    IDENTIFY_CHANGE(l_row_count);
    fii_util.stop_timer;
    fii_util.print_timer('Identified '||l_row_count||' changed records');

   --  --------------------------------------------------------
   --  3. Pushing data to local staging table
   --  --------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Pushing data');
   fii_util.start_timer;
   g_row_count := PUSH_TO_LOCAL;
   fii_util.stop_timer;
   fii_util.print_timer('Process Time');

   IF (g_row_count = -1) THEN
      RAISE L_push_local_failure;
   END IF;

   edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         ' rows into the local staging table');
   edw_log.put_line(' ');

   --  --------------------------------------------------------
   --  4. Delete all temp table records
   --  --------------------------------------------------------
   TRUNCATE_TABLE('fii_ap_tmp_ipay_pk');
     select count(*) into rows from fii_ap_tmp_ipay_pk ;
     edw_log.put_line('Number of rows in tmp_pk after truncating or deleting '||rows );

   --  ------------------------------------------------------------------------------------------------
   --  4A. Insert missing rates from local fstg into tmp_pk table  printing data to file
   --  ------------------------------------------------------------------------------------------------

   INSERT_MISSING_RATES_IN_TMP;

   ---------------------------------------------------------------------
   --  Read The Warehouse Currency
   -- Added for Currency Conversion Date Enhancement
   ----------------------------------------------------------------------
         select  /*+ FULL(SP) CACHE(SP) */
	          warehouse_currency_code into l_to_currency
	 from edw_local_system_parameters SP;

   if (g_missing_rates >0) then
        --------------------------------------------------------------------
	-- Print Records where conversion date is in past
	-- Added for Currency Conversion Date Enhancement
	---------------------------------------------------------------------
/*        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        ***Information for Missing Currency Conversion Rates***        ');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Following Section displays records where Conversion Dates are in Past.');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'To fix the issue , please enter rates for these Conversion Dates and re-collect the fact.');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FROM CURRENCY   TO CURRENCY     CONVERSION DATE    COLLECTION STATUS');
*/
        FND_MESSAGE.SET_NAME('FII','FII_MISS_CONV_RATES');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        ***'||fnd_message.get||'***        ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
        FND_MESSAGE.SET_NAME('FII','FII_PAST_CONV_RATES');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
	FND_MESSAGE.SET_NAME('FII','FII_FROM_CURRENCY');
	l_msg := l_msg||fnd_message.get||'   ';
        FND_MESSAGE.SET_NAME('FII','FII_TO_CURRENCY');
	l_msg := l_msg||fnd_message.get||'     ';
        FND_MESSAGE.SET_NAME('FII','FII_MISS_CONV_DATES');
	l_msg := l_msg||fnd_message.get||'    ';
        FND_MESSAGE.SET_NAME('FII','FII_COLLECTION_STATUS');
	l_msg := l_msg||fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_msg);
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-------------   -----------     ---------------    -----------------');

	FOR c in c1 loop
		my_payment_currency := c.FROM_CURRENCY;
		my_inv_date := c.CONVERSION_DATE;
		my_collection_status := c.COLLECTION_STATUS;

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, my_payment_currency||
          '             '||l_to_currency||'              '||my_inv_date||'         '||my_collection_status);

	end loop;

	------------------------------------------------------------------------------
	-- Print records where conversion date is in future
	-- Added for Currency Conversion Date Enhancement
	-------------------------------------------------------------------------------
/*	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'Following Section displays records where Conversion Dates are in Future.');
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT, 'FROM CURRENCY   TO CURRENCY     CONVERSION DATE    COLLECTION STATUS');
*/
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
        FND_MESSAGE.SET_NAME('FII','FII_FUTURE_CONV_RATES');
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'  ');
	l_msg := NULL;
	FND_MESSAGE.SET_NAME('FII','FII_FROM_CURRENCY');
	l_msg := l_msg||fnd_message.get||'   ';
        FND_MESSAGE.SET_NAME('FII','FII_TO_CURRENCY');
	l_msg := l_msg||fnd_message.get||'     ';
        FND_MESSAGE.SET_NAME('FII','FII_MISS_CONV_DATES');
	l_msg := l_msg||fnd_message.get||'    ';
        FND_MESSAGE.SET_NAME('FII','FII_COLLECTION_STATUS');
	l_msg := l_msg||fnd_message.get;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_msg);
	FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '-------------   -----------     ---------------    -----------------');

	FOR d in c2 loop
		my_payment_currency := d.FROM_CURRENCY;
		my_inv_date := d.CONVERSION_DATE;
		my_collection_status := d.COLLECTION_STATUS;

          FND_FILE.PUT_LINE(FND_FILE.OUTPUT, my_payment_currency||
          '             '||l_to_currency||'              '||my_inv_date||'         '||my_collection_status);

	end loop;
   end if;

   --  ------------------------------------------------------------------------------------------------------------
   --  4B. Delete records with missing rates from local staging table
   --  ------------------------------------------------------------------------------------------------------------

--  DELETE_STG;

   --  --------------------------------------------------------
   --  5. Pushing data to remote staging table
   --  --------------------------------------------------------
   IF (NOT LOCAL_SAME_AS_REMOTE) THEN
           -- -----------------------------------------------
           -- The target warehouse is not the same database
           -- as the source OLTP, which is the typical case.
           -- We move data from local to remote staging table
           -- and clean up local staging
           -- -----------------------------------------------
           edw_log.put_line(' ');
           edw_log.put_line('Moving data from local staging table to remote staging table');
           fii_util.start_timer;
           g_row_count := PUSH_REMOTE;
           fii_util.stop_timer;
           fii_util.print_timer('Duration');

           IF (g_row_count = -1) THEN RAISE l_push_remote_failure; END IF;

           edw_log.put_line(' ');
           edw_log.put_line('Cleaning local staging table');

           fii_util.start_timer;
           TRUNCATE_TABLE('FII_AP_INV_PAYMTS_FSTG');
           fii_util.stop_timer;
           fii_util.print_timer('Duration');

    ELSE
           -- -----------------------------------------------
           -- The target warehouse is the same database
           -- as the source OLTP.  We set the status of all our
           -- records status 'LOCAL READY' to 'READY'
           -- -----------------------------------------------

           edw_log.put_line(' ');
           edw_log.put_line('Marking records in staging table with READY status');

           fii_util.start_timer;
           g_row_count := SET_STATUS_READY;
           fii_util.stop_timer;
           fii_util.print_timer('Duration');
           commit;
           DELETE_STG;
           IF (g_row_count = -1) THEN RAISE l_set_status_failure; END IF;
     END IF;

     --bug#3947925
     --Clean up the old records from missing rates table and store the
     --latest records with missing rates from the current collection
     -- to the missing rates table from the temp table.

     delete from fii_ap_ipay_msng_rates;

     insert into fii_ap_ipay_msng_rates(Primary_Key1,
                                        Primary_Key2,
				        Primary_Key3)
                                 select Primary_Key1,
				        Primary_Key2,
					Primary_Key5
                                 from fii_ap_tmp_ipay_pk;
     -- -----------------------------------------------
     -- Successful.  Commit and call
     -- wrapup to commit and insert messages into logs
     -- -----------------------------------------------
--     COMMIT;
     edw_log.put_line(' ');
     edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         ' rows into the staging table');
     edw_log.put_line(' ');
     Retcode := g_retcode;
     EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count,null,g_push_date_range1, g_push_date_range2);
      if (g_missing_rates >0) then
     edw_log.put_line ('Records with missing rates identified in source and not loaded to warehouse');
     end if;
     commit;
      --bug#3947925
     --Program is on the verge of completing successfully,so clean up
     -- the temp table
    begin
      TRUNCATE_TABLE('FII_AP_TMP_IPAY_PK');
    exception
      when others then
        null;
    end;
 Exception
   WHEN L_IDEN_CHANGE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      edw_log.put_line('Identifying changed records have Failed');
      rollback;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_date_range1, g_push_date_range2);
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      --raise;
   WHEN L_PUSH_LOCAL_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      edw_log.put_line('Inserting into local staging have failed');
      rollback;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_date_range1, g_push_date_range2);
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      --raise;
   WHEN L_PUSH_REMOTE_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      edw_log.put_line('Data migration from local to remote staging have failed');
      rollback;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_date_range1, g_push_date_range2);
     /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      --raise;
   WHEN L_SET_STATUS_FAILURE THEN
      Errbuf:=g_errbuf;
      Retcode:=g_retcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      edw_log.put_line('Setting status to READY have failed');
      rollback;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_date_range1, g_push_date_range2);
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      --raise;
   WHEN OTHERS THEN
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
      l_exception_msg  := Retcode || ':' || Errbuf;
      rollback;
      EDW_COLLECTION_UTIL.wrapup(FALSE, 0, l_exception_msg,g_push_date_range1, g_push_date_range2);
      /* Set the completion status to error. bug#3207823 */
      l_set_completion_status:=FND_CONCURRENT.Set_Completion_Status(status=>'ERROR',message=>l_exception_msg);
      --raise;

End;
End FII_AP_INV_PAYMTS_F_C;

/
