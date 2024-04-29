--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_LINES_F_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_LINES_F_C" AS
/* $Header: FIIAP09B.pls 120.31 2006/01/19 12:30:15 sgautam ship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_errbuf      VARCHAR2(2000) := NULL;
 g_retcode     VARCHAR2(200) := NULL;
 g_missing_rates      Number:=0;
 g_collect_er         Varchar2(1);   -- Added for iExpense Enhancement,12-DEC-02
 g_acct_or_inv_date   Number;    -- Added for Currency Conversion Date Enhancement , 04-APR-03

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
   DELETE FII_AP_INV_LINES_FSTG
   WHERE  COLLECTION_STATUS = 'LOCAL READY'OR ( COLLECTION_STATUS = 'RATE NOT AVAILABLE' OR COLLECTION_STATUS = 'INVALID CURRENCY')
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
   -- Need to store invoice_line_number in the temp table. Change done for Inv Lines Uptake
   -- See design doc on fol for more details
   ------------------------------------------------------------------------------------------------------

   INSERT INTO fii_ap_tmp_line_pk(
               Primary_Key1,
               Primary_Key2,
	       Primary_key4,
               Primary_Key5  )
   SELECT
              TO_NUMBER(SUBSTR (INV_LINE_PK, 1, INSTR(INV_LINE_PK, '-' )-1)),
              TO_NUMBER(SUBSTR (INV_LINE_PK, INSTR(INV_LINE_PK, '-')+1,INSTR(INV_LINE_PK, '-',1,2) -
(INSTR(INV_LINE_PK,'-')+1))) ,
              TO_NUMBER(SUBSTR(INV_LINE_PK,INSTR('INV_LINE_PK','-',1,2)+1,INSTR(INV_LINE_PK,'-',1,3)-
	      (INSTR(INV_LINE_PK,'-',1,2)+1))),
              g_acct_or_inv_date

   FROM  FII_AP_INV_LINES_FSTG fil

   WHERE

               fil.COLLECTION_STATUS = 'RATE NOT AVAILABLE'
   OR
               fil.COLLECTION_STATUS = 'INVALID CURRENCY';

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

   UPDATE FII_AP_INV_LINES_FSTG
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
   fii_flex_mapping.init_cache('FII_AP_INV_LINES_F');

   Insert Into FII_AP_INV_LINES_FSTG(
     APPROVAL_STATUS,
     ACCOUNTING_DATE,
     ACCOUNTING_DATE_FK,
     ACCRUAL_POSTED_FLAG,
     AMT_INCLUDES_TAX_FLAG,
     ASSETS_TRACKING_FLAG,
     AWT_FLAG,
     AWT_GROUP_ID,
     BASE_CURRENCY_CODE,
     BATCH_ID,
     CASH_JE_BATCH_ID,
     CASH_POSTED_FLAG,
     CATEGORY_ID,
     CCID,
     CREATION_DATE,
     DUNS_FK,
     EMPLOYEE_FK,
     ENCUMBERED_FLAG,
     EXCHANGE_DATE,
     EXCHANGE_RATE,
     EXCHANGE_RATE_TYPE,
     EXCHANGE_RATE_VAR,
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
     INCOME_TAX_REGION,
     INSTANCE,
     INSTANCE_FK,
     INV_CURRENCY_FK,
     INV_DATE,
     INV_FK,
     INV_LINE_AMT_B,
     INV_LINE_AMT_G,
     INV_LINE_AMT_T,
     INV_LINE_COUNT,
     INV_LINE_DESCRIPTION,
     INV_LINE_PK,
     INV_LINE_TYPE_FK,
     INV_NUM,
     INV_PRICE_VAR_AMT_B,
     INV_PRICE_VAR_AMT_G,
     INV_PRICE_VAR_AMT_T,
     INV_SOURCE_FK,
     INV_TYPE,
     INV_UNIT_PRICE_B,
     INV_UNIT_PRICE_G,
     INV_UNIT_PRICE_T,
     ITEM_DESCRIPTION,
     ITEM_FK,
     ITEM_ID,
     LAST_UPDATE_DATE,
     MATCH_LINE_AMT_B,
     MATCH_LINE_AMT_G,
     MATCH_LINE_AMT_T,
     MATCH_LINE_COUNT,
     MATCH_STATUS_FLAG,
     ORG_FK,
     PAYMENT_TERM_FK,
     POSTED_AMT_B,
     POSTED_AMT_G,
     POSTED_AMT_T,
     POSTED_FLAG,
     PO_AMT_B,
     PO_AMT_G,
     PO_AMT_T,
     PO_DISTRIBUTION_ID,
     PO_NUMBER,
     PO_UNIT_PRICE_B,
     PO_UNIT_PRICE_G,
     PO_UNIT_PRICE_T,
     PROJECT_ID,
     QTY_VAR_AMT_B,
     QTY_VAR_AMT_G,
     QTY_VAR_AMT_T,
     QUANTITY_INVOICED_G,
     QUANTITY_INVOICED_T,
     SIC_CODE_FK,
     SOB_FK,
     SUPPLIER_FK,
     SUPPLIER_SITE_ID,
     TOTAL_VAR_AMT_B,
     TOTAL_VAR_AMT_G,
     TOTAL_VAR_AMT_T,
     TYPE_1099,
     UNMATCH_LINE_AMT_B,
     UNMATCH_LINE_AMT_G,
     UNMATCH_LINE_AMT_T,
     UNMATCH_LINE_COUNT,
     UNSPSC_FK,
     UOM_G_FK,
     UOM_T_FK,
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
     VAT_CODE,
     OPERATION_CODE,
     COLLECTION_STATUS,
     DISCOUNT_AMT_T,    --Added the following three columns for New Information Enhancement, nov/12/2002
     DISCOUNT_AMT_B,
     DISCOUNT_AMT_G,
     PROJECT_FK,        --Added the following four columns for New Information Enhancement, nov/26/2002
     EXPENDITURE_TYPE,
     VOUCHER_NUMBER,
     DOC_SEQUENCE_VALUE,
     TASK_ID,           -- Addded for bug#2926033
     RCV_TRANSACTION_ID) -- Added for bug#3116554
   select
     APPROVAL_STATUS,
     ACCOUNTING_DATE,
     NVL(ACCOUNTING_DATE_FK,'NA_EDW'),
     ACCRUAL_POSTED_FLAG,
     AMT_INCLUDES_TAX_FLAG,
     ASSETS_TRACKING_FLAG,
     AWT_FLAG,
     AWT_GROUP_ID,
     BASE_CURRENCY_CODE,
     BATCH_ID,
     CASH_JE_BATCH_ID,
     CASH_POSTED_FLAG,
     CATEGORY_ID,
     CCID,
     CREATION_DATE,
     NVL(DUNS_FK,'NA_EDW'),
     NVL(EMPLOYEE_FK,'NA_EDW'),
     ENCUMBERED_FLAG,
     EXCHANGE_DATE,
     EXCHANGE_RATE,
     EXCHANGE_RATE_TYPE,
     EXCHANGE_RATE_VAR,
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
     INCOME_TAX_REGION,
     INSTANCE,
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(INV_CURRENCY_FK,'NA_EDW'),
     INV_DATE,
     NVL(INV_FK,'NA_EDW'),
     INV_LINE_AMT_B,
     round((INV_LINE_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     INV_LINE_AMT_T,
     INV_LINE_COUNT,
     INV_LINE_DESCRIPTION,
     INV_LINE_PK,
     NVL(INV_LINE_TYPE_FK,'NA_EDW'),
     INV_NUM,
     INV_PRICE_VAR_AMT_B,
     round((INV_PRICE_VAR_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     INV_PRICE_VAR_AMT_T,
     NVL(INV_SOURCE_FK,'NA_EDW'),
     INV_TYPE,
     INV_UNIT_PRICE_B,
     round((INV_UNIT_PRICE_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     INV_UNIT_PRICE_T,
     ITEM_DESCRIPTION,
     NVL(ITEM_FK,'NA_EDW'),
     ITEM_ID,
     LAST_UPDATE_DATE,
     MATCH_LINE_AMT_B,
     round((MATCH_LINE_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     MATCH_LINE_AMT_T,
     MATCH_LINE_COUNT,
     MATCH_STATUS_FLAG,
     NVL(ORG_FK,'NA_EDW'),
     NVL(PAYMENT_TERM_FK,'NA_EDW'),
     POSTED_AMT_B,
     round((POSTED_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     POSTED_AMT_T,
     POSTED_FLAG,
     PO_AMT_B,
     round((PO_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     PO_AMT_T,
     PO_DISTRIBUTION_ID,
     PO_NUMBER,
     PO_UNIT_PRICE_B,
     round((PO_UNIT_PRICE_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     PO_UNIT_PRICE_T,
     PROJECT_ID,
     QTY_VAR_AMT_B,
     round((QTY_VAR_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     QTY_VAR_AMT_T,
     QUANTITY_INVOICED_G,
     QUANTITY_INVOICED_T,
     NVL(SIC_CODE_FK,'NA_EDW'),
     NVL(SOB_FK,'NA_EDW'),
     NVL(SUPPLIER_FK,'NA_EDW'),
     SUPPLIER_SITE_ID,
     TOTAL_VAR_AMT_B,
     round((TOTAL_VAR_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     TOTAL_VAR_AMT_T,
     TYPE_1099,
     UNMATCH_LINE_AMT_B,
     round((UNMATCH_LINE_AMT_B*GLOBAL_CURRENCY_RATE)/l_mau)*l_mau,
     UNMATCH_LINE_AMT_T,
     UNMATCH_LINE_COUNT,
     NVL(UNSPSC_FK,'NA_EDW'),
     NVL(UOM_G_FK,'NA_EDW'),
     NVL(UOM_T_FK,'NA_EDW'),
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
     --USER_MEASURE1,
     invoice_distribution_id,
     --USER_MEASURE2,
     set_of_books_id,
--     USER_MEASURE3,
     old_dist_line_number,
     USER_MEASURE4,
     USER_MEASURE5,
     VAT_CODE,
     NULL, -- OPERATION_CODE
     decode(GLOBAL_CURRENCY_RATE,
            NULL, 'RATE NOT AVAILABLE',
            -1, 'RATE NOT AVAILABLE',
            -2, 'RATE NOT AVAILABLE',
            'LOCAL READY'),
     0,             --added the following three columns for New Information Enhancement, Nov/12/2002
     0,
     GLOBAL_CURRENCY_RATE,
     PROJECT_FK,        --Added the following four columns for New Information Enhancement, nov/26/2002
     EXPENDITURE_TYPE,
     VOUCHER_NUMBER,
     DOC_SEQUENCE_VALUE,
     TASK_ID,            -- Added for bug#2926033
     RCV_TRANSACTION_ID  -- Added for bug#3116554
   from FII_AP_INV_LINES_FCV;

   fii_flex_mapping.free_mem_all;
   edw_log.put_line('g_row_count');
   edw_log.put_line(TO_CHAR(sql%rowcount));
   RETURN(sql%rowcount);

 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;
edw_log.put_line('inside exception of local push');
     rollback;
     RETURN(-1);

END;
-----------------------------------------------------------
--  PROCEDURE UPDATE_DISCOUNT_AMT
--  NEW PROCEDURE ESPECIALLY FOR CALCULATING THE DISTRIBUTED
--  DISCOUNT AMOUNT FOR MERILL LYNCH, NOV-12-2002
--  Modified by PHU on DEC-30-2002
-----------------------------------------------------------
 PROCEDURE UPDATE_DISCOUNT_AMT  IS
  l_mau NUMBER;

  cursor c_tmp is
     select apk.PRIMARY_KEY_CHAR1 pk,
            apk.PRIMARY_KEY4      amt_t,
            apk.PRIMARY_KEY5      amt_b
       from fii_ap_tmp_line_pk    apk
      where apk.SEQ_ID = -878;

  l_temp_date                DATE;
  l_duration                 NUMBER;
  l_count                    NUMBER:=0;

 l_fii_schema          VARCHAR2(30);
 l_status              VARCHAR2(30);
 l_industry            VARCHAR2(30);

 BEGIN

   edw_log.put_line('Updating credit amount information in local staging table');
   edw_log.put_line('');

  -- get minimum accountable unit of the warehouse currency;

    l_mau := nvl( edw_currency.get_mau, 0.01);

  -- truncate fii_ap_tmp_line_pk

    TRUNCATE_TABLE ('fii_ap_tmp_line_pk');

  -- populate fii_ap_tmp_line_pk from local staging

   l_temp_date := sysdate;

   insert into  fii_ap_tmp_line_pk (
                SEQ_ID,
                PRIMARY_KEY1,       --invoice_id
		PRIMARY_KEY2, --old_dist_line_number
              /*  PRIMARY_KEY_CHAR2,  ap_ae_lines_all.reference8 */
                PRIMARY_KEY3,      --invoice_distribution_id,
		PRIMARY_KEY4,  --set of books id
                PRIMARY_KEY_CHAR1)  --inv_line_pk

   select
          -919,
          to_number(substr(fstg.inv_line_pk, 1, instr(fstg.inv_line_pk, '-') - 1)),
       /*   substr(fstg.inv_line_pk, instr(fstg.inv_line_pk, '-', 1, 1) + 1,
                  instr(fstg.inv_line_pk, '-', 1, 2) -
                  instr(fstg.inv_line_pk, '-', 1, 1) - 1), */
          fstg.user_measure3, --old_dist_line_number
          fstg.user_measure1, --invoice_distribution_id
	  fstg.user_measure2,
          fstg.inv_line_pk
   from   fii_ap_inv_lines_fstg fstg
   where  fstg.collection_status = 'LOCAL READY';

   l_duration := sysdate - l_temp_date;
   edw_log.put_line ('Process Time for Insert into TMP: '||edw_log.duration(l_duration));

  -- populate Discount Amounts into fii_ap_tmp_line_pk

   l_temp_date := sysdate;



   /* need to analyze the temp table */

   IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_fii_schema,
              TABNAME => 'FII_AP_TMP_LINE_PK') ;
   END IF;

--bug 3012243: consider DR columns in calculating discount
-- bug 3381164 : added leading hint to imporve the performance
   insert into  fii_ap_tmp_line_pk (
                SEQ_ID,
                PRIMARY_KEY_CHAR1, --inv_line_pk
                PRIMARY_KEY4,      --discount_amt_t
                PRIMARY_KEY5)      --discount_amt_b
      SELECT  -878,
                apk.PRIMARY_KEY_CHAR1,
                sum (nvl (aphd.amount,0)),
                sum(nvl(aphd.paid_base_amount,0))
 FROM  fii_ap_tmp_line_pk apk,
              ap_invoice_payments_all aip,
              ap_payment_hist_dists aphd,
              ap_payment_history_all aph
 WHERE apk.PRIMARY_KEY1 = aip.invoice_id
 AND aip.invoice_payment_id = aphd.invoice_payment_id
 AND aphd.PAY_DIST_LOOKUP_CODE = 'DISCOUNT'
 AND aphd.invoice_distribution_id = apk.PRIMARY_KEY3
 AND nvl(aph.historical_flag, 'N') = 'N'
 AND APH.check_id = aip.check_id
 AND aph.payment_history_id=aphd.payment_history_id
 AND aphd.bank_curr_amount is null
 AND aphd.cleared_base_amount is null
 group by apk.primary_key_char1
UNION
    SELECT  -878,
                    apk.PRIMARY_KEY_CHAR1,
                    NVL(sum(xal.entered_cr), 0) - NVL(sum(xal.entered_dr), 0),
                    NVL(sum(NVL(xal.accounted_cr, xal.entered_cr)), 0) -
                           NVL(sum(NVL(xal.accounted_dr, xal.entered_dr)), 0)
    FROM    fii_ap_tmp_line_pk apk,
                   ap_invoice_payments_all aip,
               --    ap_payment_history_all aph,
                   xla_ae_lines    xal,
		   xla_ae_headers  xah
    WHERE apk.PRIMARY_KEY1 = aip.invoice_id
    AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
    AND apk.PRIMARY_KEY2 = xal.Upg_Tax_Reference_ID2
    AND xal.accounting_class_code = 'DISCOUNT'
  --  AND APH.check_id = aip.check_id
  --  AND nvl(aph.historical_flag, 'N') = 'Y'
   AND xal.application_id=200
   AND xah.ae_header_id=xal.ae_header_id
   AND xah.ledger_id = apk.primary_key4
    group by apk.primary_key_char1;

   l_duration := sysdate - l_temp_date;
   edw_log.put_line ('Process Time for Insert into TMP w/ Discount: ' ||
                          edw_log.duration(l_duration));

  -- update fii_ap_inv_lines_fstg from fii_ap_tmp_line_pk

   l_temp_date := sysdate;

   FOR v_tmp IN c_tmp LOOP

  -- NOTE: discount_amt_g was populated with GLOBAL_CURRENCY_RATE previously

      UPDATE /*+ ORDERED USE_NL (FSTG) */
              fii_ap_inv_lines_fstg fstg
      SET   discount_amt_t = v_tmp.amt_t,
            discount_amt_b = v_tmp.amt_b,
            discount_amt_g = ROUND(v_tmp.amt_b * discount_amt_g /l_mau)*l_mau
      WHERE fstg.inv_line_pk = v_tmp.pk;
      l_count := l_count + 1;

   END LOOP;

  -- set DISCOUNT_AMT_G = 0  for those no discount records
      update FII_AP_INV_LINES_FSTG
      set    DISCOUNT_AMT_G = 0
      where  DISCOUNT_AMT_B = 0;

   l_duration := sysdate - l_temp_date;
   edw_log.put_line ('Process Time for Update: ' || edw_log.duration(l_duration));
   edw_log.put_line ('# of Updated Records: ' || l_count);

-- fii_util.stop_timer;
-- fii_util.print_timer('Duration');

EXCEPTION
      WHEN OTHERS THEN
        g_errbuf:=sqlerrm;
        g_retcode:=sqlcode;
        rollback;
        raise;

END;


-----------------------------------------------------------
--  FUNCTION PUSH_REMOTE
-----------------------------------------------------------
 FUNCTION PUSH_REMOTE RETURN NUMBER
 IS

  BEGIN

   -- Bug 3716166. Added substrb to all the varchar2 columns.

   Insert Into FII_AP_INV_LINES_FSTG@EDW_APPS_TO_WH(
     APPROVAL_STATUS,
     ACCOUNTING_DATE,
     ACCOUNTING_DATE_FK,
     ACCRUAL_POSTED_FLAG,
     AMT_INCLUDES_TAX_FLAG,
     ASSETS_TRACKING_FLAG,
     AWT_FLAG,
     AWT_GROUP_ID,
     BASE_CURRENCY_CODE,
     BATCH_ID,
     CASH_JE_BATCH_ID,
     CASH_POSTED_FLAG,
     CATEGORY_ID,
     CCID,
     CREATION_DATE,
     DUNS_FK,
     EMPLOYEE_FK,
     ENCUMBERED_FLAG,
     EXCHANGE_DATE,
     EXCHANGE_RATE,
     EXCHANGE_RATE_TYPE,
     EXCHANGE_RATE_VAR,
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
     INCOME_TAX_REGION,
     INSTANCE,
     INSTANCE_FK,
     INV_CURRENCY_FK,
     INV_DATE,
     INV_FK,
     INV_LINE_AMT_B,
     INV_LINE_AMT_G,
     INV_LINE_AMT_T,
     INV_LINE_COUNT,
     INV_LINE_DESCRIPTION,
     INV_LINE_PK,
     INV_LINE_TYPE_FK,
     INV_NUM,
     INV_PRICE_VAR_AMT_B,
     INV_PRICE_VAR_AMT_G,
     INV_PRICE_VAR_AMT_T,
     INV_SOURCE_FK,
     INV_TYPE,
     INV_UNIT_PRICE_B,
     INV_UNIT_PRICE_G,
     INV_UNIT_PRICE_T,
     ITEM_DESCRIPTION,
     ITEM_FK,
     ITEM_ID,
     LAST_UPDATE_DATE,
     MATCH_LINE_AMT_B,
     MATCH_LINE_AMT_G,
     MATCH_LINE_AMT_T,
     MATCH_LINE_COUNT,
     MATCH_STATUS_FLAG,
     ORG_FK,
     PAYMENT_TERM_FK,
     POSTED_AMT_B,
     POSTED_AMT_G,
     POSTED_AMT_T,
     POSTED_FLAG,
     PO_AMT_B,
     PO_AMT_G,
     PO_AMT_T,
     PO_DISTRIBUTION_ID,
     PO_NUMBER,
     PO_UNIT_PRICE_B,
     PO_UNIT_PRICE_G,
     PO_UNIT_PRICE_T,
     PROJECT_ID,
     QTY_VAR_AMT_B,
     QTY_VAR_AMT_G,
     QTY_VAR_AMT_T,
     QUANTITY_INVOICED_G,
     QUANTITY_INVOICED_T,
     SIC_CODE_FK,
     SOB_FK,
     SUPPLIER_FK,
     SUPPLIER_SITE_ID,
     TOTAL_VAR_AMT_B,
     TOTAL_VAR_AMT_G,
     TOTAL_VAR_AMT_T,
     TYPE_1099,
     UNMATCH_LINE_AMT_B,
     UNMATCH_LINE_AMT_G,
     UNMATCH_LINE_AMT_T,
     UNMATCH_LINE_COUNT,
     UNSPSC_FK,
     UOM_G_FK,
     UOM_T_FK,
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
     VAT_CODE,
     OPERATION_CODE,
     COLLECTION_STATUS,
     DISCOUNT_AMT_T,  --Added the following three columns for New Information Enhancement, nov/12/2002
     DISCOUNT_AMT_B,
     DISCOUNT_AMT_G,
     PROJECT_FK,        --Added the following four columns for New Information Enhancement, nov/26/2002
     EXPENDITURE_TYPE,
     VOUCHER_NUMBER,
     DOC_SEQUENCE_VALUE,
     TASK_ID,            -- Added for bug#2926033
     RCV_TRANSACTION_ID) -- Added for bug#3116554
   select
     substrb(APPROVAL_STATUS,1,25),
     ACCOUNTING_DATE,
     NVL(ACCOUNTING_DATE_FK,'NA_EDW'),
     substrb(ACCRUAL_POSTED_FLAG, 1, 1),
     substrb(AMT_INCLUDES_TAX_FLAG, 1, 1),
     substrb(ASSETS_TRACKING_FLAG, 1, 1),
     substrb(AWT_FLAG, 1, 1),
     AWT_GROUP_ID,
     substrb(BASE_CURRENCY_CODE,1,15),
     BATCH_ID,
     CASH_JE_BATCH_ID,
     substrb(CASH_POSTED_FLAG,1,1),
     CATEGORY_ID,
     CCID,
     CREATION_DATE,
     NVL(DUNS_FK,'NA_EDW'),
     NVL(EMPLOYEE_FK,'NA_EDW'),
     substrb(ENCUMBERED_FLAG,1,1),
     EXCHANGE_DATE,
     EXCHANGE_RATE,
     substrb(EXCHANGE_RATE_TYPE,1,30),
     EXCHANGE_RATE_VAR,
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
     substrb(INCOME_TAX_REGION,1,10),
     substrb(INSTANCE,1,40),
     NVL(INSTANCE_FK,'NA_EDW'),
     NVL(INV_CURRENCY_FK,'NA_EDW'),
     INV_DATE,
     NVL(INV_FK,'NA_EDW'),
     INV_LINE_AMT_B,
     INV_LINE_AMT_G,
     INV_LINE_AMT_T,
     INV_LINE_COUNT,
     substrb(INV_LINE_DESCRIPTION,1,240),
     substrb(INV_LINE_PK,1,120),
     NVL(INV_LINE_TYPE_FK,'NA_EDW'),
     substrb(INV_NUM, 1, 50),
     INV_PRICE_VAR_AMT_B,
     INV_PRICE_VAR_AMT_G,
     INV_PRICE_VAR_AMT_T,
     NVL(INV_SOURCE_FK,'NA_EDW'),
     substrb(INV_TYPE,1,25),
     INV_UNIT_PRICE_B,
     INV_UNIT_PRICE_G,
     INV_UNIT_PRICE_T,
     substrb(ITEM_DESCRIPTION,1,240),
     NVL(ITEM_FK,'NA_EDW'),
     ITEM_ID,
     LAST_UPDATE_DATE,
     MATCH_LINE_AMT_B,
     MATCH_LINE_AMT_G,
     MATCH_LINE_AMT_T,
     MATCH_LINE_COUNT,
     substrb(MATCH_STATUS_FLAG,1,1),
     NVL(ORG_FK,'NA_EDW'),
     NVL(PAYMENT_TERM_FK,'NA_EDW'),
     POSTED_AMT_B,
     POSTED_AMT_G,
     POSTED_AMT_T,
     substrb(POSTED_FLAG,1,1),
     PO_AMT_B,
     PO_AMT_G,
     PO_AMT_T,
     PO_DISTRIBUTION_ID,
     substrb(PO_NUMBER,1,20),
     PO_UNIT_PRICE_B,
     PO_UNIT_PRICE_G,
     PO_UNIT_PRICE_T,
     PROJECT_ID,
     QTY_VAR_AMT_B,
     QTY_VAR_AMT_G,
     QTY_VAR_AMT_T,
     QUANTITY_INVOICED_G,
     QUANTITY_INVOICED_T,
     NVL(SIC_CODE_FK,'NA_EDW'),
     NVL(SOB_FK,'NA_EDW'),
     NVL(SUPPLIER_FK,'NA_EDW'),
     SUPPLIER_SITE_ID,
     TOTAL_VAR_AMT_B,
     TOTAL_VAR_AMT_G,
     TOTAL_VAR_AMT_T,
     substrb(TYPE_1099,1,10),
     UNMATCH_LINE_AMT_B,
     UNMATCH_LINE_AMT_G,
     UNMATCH_LINE_AMT_T,
     UNMATCH_LINE_COUNT,
     NVL(UNSPSC_FK,'NA_EDW'),
     NVL(UOM_G_FK,'NA_EDW'),
     NVL(UOM_T_FK,'NA_EDW'),
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
     substrb(VAT_CODE,1,15),
     NULL, -- OPERATION_CODE
     'READY',
     NVL(DISCOUNT_AMT_T, 0),  --added the following three columns for New Information Enhancement, nov/12/2002
     NVL(DISCOUNT_AMT_B, 0),
     NVL(DISCOUNT_AMT_G, 0),
     PROJECT_FK,        --Added the following four columns for New Information Enhancement, nov/26/2002
     substrb(EXPENDITURE_TYPE,1,30),
     substrb(VOUCHER_NUMBER,1,50),
     DOC_SEQUENCE_VALUE,
     TASK_ID,            -- Addded for bug#2926033
     RCV_TRANSACTION_ID  -- Added for bug#3116554
   from FII_AP_INV_LINES_FSTG
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
 l_stmt              VARCHAR2(5000);         -- Added for iExpense Enhancement,12-DEC-02
 l_er_stmt           VARCHAR2(100) := NULL;  -- Added for iExpense Enhancement,12-DEC-02

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
   -- will be stored in the column Primary_Key5 . Modified for Currency Conversion Date Enhancement, 4-APR-03
   -----------------------------------------------------------------------------------------------------

   l_stmt := ' INSERT INTO fii_ap_tmp_line_pk(
                Primary_Key1,
		Primary_Key2,
		Primary_Key4,
		Primary_Key5)
	SELECT
           aid.invoice_id,
           aid.distribution_line_number,
	   aid.invoice_line_number,
	   :g_acct_or_inv_date
   FROM    ap_invoice_distributions_all aid,
           ap_invoices_all ai,
	   ap_invoice_lines_all ail
   WHERE   aid.invoice_id = ai.invoice_id
   AND     aid.invoice_line_number=ail.line_number
   AND     ail.invoice_id=ai.invoice_id
   AND     aid.posted_flag=''Y''
   -- for bug 2601797:      AND     ai.cancelled_date IS NULL
   AND     (aid.last_update_date between :g_push_date_range1 and :g_push_date_range2
            OR ai.last_update_date between :g_push_date_range1 and :g_push_date_range2 )'||l_er_stmt||'
   UNION
   SELECT
            aid.invoice_id,
            aid.distribution_line_number,
	    aid.invoice_line_number,
	    :g_acct_or_inv_date
    FROM    ap_invoice_distributions_all aid,
            ap_invoices_all ai,
            ap_invoice_lines_all ail,
            po_distributions_all pd,
            po_lines_all pl,
       po_headers_all ph,
       po_line_locations_all pll
    WHERE  ( pl.last_update_date between  :g_push_date_range1 and :g_push_date_range2
    or ph.last_update_date between  :g_push_date_range1 and :g_push_date_range2
    or  pll.last_update_date between  :g_push_date_range1 and :g_push_date_range2)
    AND     pl.po_line_id = pd.po_line_id
    AND     pd.po_distribution_id = aid.po_distribution_id
    AND     aid.invoice_id = ai.invoice_id
    AND     aid.invoice_line_number=ail.line_number
    AND     ail.invoice_id=ai.invoice_id
    AND     aid.posted_flag=''Y''
    AND    ph.po_header_id = pl.po_header_id
    AND  pll.line_location_id = pd.line_location_id '||l_er_stmt||'
    UNION
  SELECT  aid.invoice_id,
        aid.distribution_line_number,
	aid.invoice_line_number,
	:g_acct_or_inv_date
 FROM  ap_invoice_distributions_all aid,
       ap_invoices_all ai,
       ap_invoice_payments_all aip,
       ap_payment_hist_dists aphd,
       ap_payment_history_all aph
 WHERE aid.invoice_id = ai.invoice_id
 AND aid.invoice_id = aip.invoice_id
 AND aid.posted_flag = ''Y''
 AND aip.invoice_payment_id = aphd.invoice_payment_id
 AND aphd.PAY_DIST_LOOKUP_CODE = ''DISCOUNT''
 AND aphd.invoice_distribution_id = aid.invoice_distribution_id
 AND nvl(aph.historical_flag, ''N'') = ''N''
 AND APH.check_id = aip.check_id
 AND aph.payment_history_id=aphd.payment_history_id
 AND aphd.bank_curr_amount is null
 AND aphd.cleared_base_amount is null
 AND aphd.last_update_date between :g_push_date_range1 and :g_push_date_range2 '||l_er_stmt||'
UNION
  SELECT   aid.invoice_id,
           aid.distribution_line_number,
	   aid.invoice_line_number,
	   :g_acct_or_inv_date
  FROM ap_invoice_distributions_all aid,
       ap_invoices_all ai,
       ap_invoice_payments_all aip,
    --   ap_payment_history_all aph,
       xla_ae_lines    xal,
       xla_ae_headers xah
 WHERE aid.invoice_id = ai.invoice_id
 AND aid.invoice_id = aip.invoice_id
 AND aip.invoice_payment_id = xal.Upg_Tax_Reference_ID3
 AND aid.old_dist_line_number = xal.Upg_Tax_Reference_ID2
 AND xal.accounting_class_code = ''DISCOUNT''
-- AND APH.check_id = aip.check_id
 --AND nvl(aph.historical_flag, ''N'') = ''Y''
AND xal.last_update_date between :g_push_date_range1 and :g_push_date_range2
 AND xal.application_id=200
 AND xah.ae_header_id=xal.ae_header_id
 AND xah.ledger_id=aid.set_of_books_id '||l_er_stmt;
    --**

   /* IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_fii_schema,
              TABNAME => 'FII_TMP_PK') ;
   END IF; */



   --** Added for iExpense Enhancement,12-DEC-02
   edw_log.debug_line('');
   edw_log.debug_line(l_stmt);
   execute immediate l_stmt using g_acct_or_inv_date,g_push_date_range1,g_push_date_range2,
                                  g_push_date_range1,g_push_date_range2,
                                  g_acct_or_inv_date,g_push_date_range1,g_push_date_range2,
                                  g_push_date_range1,g_push_date_range2,
                                  g_push_date_range1,g_push_date_range2,
                                  g_acct_or_inv_date,g_push_date_range1,g_push_date_range2,
				  g_acct_or_inv_date,g_push_date_range1,g_push_date_range2;

 p_count := sql%rowcount;


   edw_log.debug_line( 'NO OF ROWS CHANGED '||
   to_char(p_count));

   IF (FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, l_fii_schema)) THEN
     FND_STATS.GATHER_TABLE_STATS(OWNNAME => l_fii_schema,
              TABNAME => 'FII_AP_TMP_LINE_PK') ;
   END IF;
   --**



 EXCEPTION
   WHEN OTHERS THEN
     g_errbuf:=sqlerrm;
     g_retcode:=sqlcode;

     rollback;

END;

PROCEDURE UPDATE_DIST_CCID IS
         cursor ccid_cursor is
        	select distinct primary_key1 ccid, primary_key_char1 inv_line_pk
  		from fii_ap_tmp_line_pk;
BEGIN
	TRUNCATE_TABLE('fii_ap_tmp_line_pk');

	insert into fii_ap_tmp_line_pk(Primary_key1,
                                       Primary_key_Char1)
        with accounting_class AS (SELECT distinct xaca.accounting_class_Code
                      FROM xla_assignment_defns_B xad,
                           xla_acct_class_assgns xaca
                      WHERE XAD.Program_Code = 'PAYABLES EDW EXPENSES'
                      AND XAD.Enabled_Flag = 'Y'
                      AND XAD.Program_Code = XACA.Program_Code
                      AND XAD.Assignment_Code = XACA.Assignment_Code)
       			 select  /*+ parallel(fstg) parallel(xah) parallel(xte) parallel(xal) parallel(xdl) */   xal.code_combination_id,
                		     inv_line_pk
                           from xla_ae_headers xah,
                                xla_transaction_entities xte,
                                xla_distribution_links xdl,
                                xla_ae_lines xal,
                                fii_ap_inv_lines_fstg fstg,
                                accounting_class ac
                           where xte.entity_code='AP_INVOICES'
                             and xah.entity_id=xte.entity_id
                             and xah.ae_header_id=xal.ae_header_id
                             and xal.ae_header_id=xdl.ae_header_id
                             and xal.ae_line_num=xdl.ae_line_num
                             and xdl.source_distribution_id_num_1=fstg.user_measure1
			     and xdl.Source_Distribution_Type IN ('AP_INV_DIST', 'AP_PMT_DIST', 'AP_PREPAY')
                             and xal.application_id=200
                             and xah.application_id=200
                             and xte.application_id=200
			     and xdl.application_id=200
                             and xah.accounting_entry_status_code='F'
                             and xal.accounting_class_code = ac.accounting_class_code
			     and xah.ledger_id=xte.ledger_id
                             and fstg.user_measure2=xah.ledger_id
			     and xah.balance_type_code='A';
                                                   -- user_measure2 will be populated with ledger_id in push_to_local procedure
                             		            --user_measure1 will be populated with invoice_distribution_id in push_to_local

  			    FOR l_ccid IN  ccid_cursor LOOP
     					 update fii_ap_inv_lines_fstg fstg
      					 set fstg.CCID = l_ccid.ccid
     					 where fstg.inv_line_pk=l_ccid.inv_line_pk;
   			    END LOOP;


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
 l_fact_name   Varchar2(30) :='FII_AP_INV_LINES_F'  ;
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
 l_count                NUMBER:=0; --bug3818907


   l_to_currency     VARCHAR2(15); -- Added for Currency Conversion Date Enhancement , 4-APR-03
   l_msg             VARCHAR2(120):=NULL; -- Added for Currency Conversion Date Enhancement , 18-APR-03
   l_set_completion_status BOOLEAN; --bug#3207823

   ----------------------------------------------------------------------------------------------
   -- This cursor is for getting records where the CONVERSION_DATE (i.e. GL_DATE or INVOICE_DATE )
   -- is less than the sysdate i.e. in past.  Added for Currency Conversion Date Enhancement , 4-APR-03
   ----------------------------------------------------------------------------------------------
    --bug#3303683 : BASE_CURRENCY_CODE should be printed in the o/p file
	--              since the exchange rate is calculated using
	--              BASE_CURRENCY_CODE

   cursor c1 is select  DISTINCT  BASE_CURRENCY_CODE from_currency,
	                                 Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INV_DATE) CONVERSION_DATE,
	                                 COLLECTION_STATUS
	                        From FII_AP_INV_LINES_FSTG
	                       where (COLLECTION_STATUS='RATE NOT AVAILABLE'
	                                  OR COLLECTION_STATUS = 'INVALID CURRENCY')
	                                  AND trunc(Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INV_DATE)) <= trunc(sysdate);

   -----------------------------------------------------------------------------------------------------
   -- This cursor is for getting records where the CONVERSION_DATE (i.e. GL_DATE or INVOICE_DATE )
   -- is greater than the syssdate i.e. in future.  Added for Currency Conversion Date Enhancement , 4-APR-03
   -----------------------------------------------------------------------------------------------------
	--bug#3303683 : BASE_CURRENCY_CODE should be printed in the o/p file
	--              since the exchange rate is calculated using
	--              BASE_CURRENCY_CODE

   cursor c2 is select DISTINCT  BASE_CURRENCY_CODE  FROM_CURRENCY,
	                                 Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INV_DATE) CONVERSION_DATE,
	                                 COLLECTION_STATUS
	                        From FII_AP_INV_LINES_FSTG
	                       where (COLLECTION_STATUS='RATE NOT AVAILABLE'
	                                  OR COLLECTION_STATUS = 'INVALID CURRENCY')
	                                  AND trunc(Decode(g_acct_or_inv_date,
	                                              1, ACCOUNTING_DATE,
	                                               INV_DATE)) >  trunc(sysdate);


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
  FII_AP_INV_LINES_F_C.g_push_date_range1 := nvl(l_from_date,
  		EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  FII_AP_INV_LINES_F_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
l_date1 := g_push_date_range1;
l_date2 := g_push_date_range2;
   edw_log.put_line( 'The collection range is from '||
        to_char(l_date1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(l_date2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');


   --bug#3818907
   --Check whether missing rates table has data or not. If not then copy missing rates
   --from temp table to the missing rates table. This is required to avoid full refresh
   --of the fact after application of this patch.
   execute immediate 'select count(*) from FII_AP_LINE_MSNG_RATES' into l_count;

   if (l_count=0) then
     insert into fii_ap_line_msng_rates(Primary_Key1,
                                        Primary_key2,
					Primary_key3,
					Primary_key4)  /* Inv line Uptake */
				select Primary_key1,
				       Primary_key2,
				       Primary_Key5,
				       Primary_Key4
				from  fii_ap_tmp_line_pk;
      commit;
    else

    TRUNCATE_TABLE('FII_AP_TMP_LINE_PK');--bug#3818907

   --bug#3818907
   --move the missing rates related info. from the missing rates
   --table to the temp table for further processing.
    Insert into fii_ap_tmp_line_pk(Primary_Key1,
                                   Primary_Key2,
				   Primary_Key5,
				   Primary_Key4)   /* Inv Line Uptake */
                            select Primary_Key1,
			           Primary_Key2,
				   Primary_Key3,
				   Primary_Key4
                            from fii_ap_line_msng_rates;
    end if;


   -- ---------------------------------------------------------
   -- Fetch profile option value
   -- ---------------------------------------------------------
   g_collect_er := NVL(FND_PROFILE.value('FII_COLLECT_ER'),'N');   -- Added for iExpense Enhancement,12-DEC-02

   ----------------------------------------------------------------------------------------------------------
   -- See whether to use accounting date or invoice date . Added for Currency Conversion Date Enhancement 4-APR-03
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
         TRUNCATE_TABLE('FII_AP_INV_LINES_FSTG');
   ELSE
         DELETE_STG;
   END IF;


   --  --------------------------------------------------------
   --  2. Identify Changed AP Invoice Lines record
   --  --------------------------------------------------------
    edw_log.put_line(' ');
    edw_log.put_line('Identifying changed AP Invoice Lines record');
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
   --  3.5 Populating the discount_amt_t, discount_amt_b,
   --  discount_amt_g columns in the local staging table
   --  add this procedure call for merill lynch, nov/12/2002
   --  --------------------------------------------------------

   edw_log.put_line(' ');
   edw_log.put_line('Populate discount_amt columns');
   fii_util.start_timer;

   UPDATE_DIST_CCID; -- added for SLA-AP Uptake

   UPDATE_DISCOUNT_AMT;
   fii_util.stop_timer;


   --  --------------------------------------------------------
   --  4. Delete all temp table records
   --  --------------------------------------------------------
     TRUNCATE_TABLE('fii_ap_tmp_line_pk');

   --  ------------------------------------------------------------------------------------------------
   --  4A. Insert missing rates from local fstg into tmp_pk table  printing data to file
   --  ------------------------------------------------------------------------------------------------

   INSERT_MISSING_RATES_IN_TMP;

   ---------------------------------------------------------------------
   --  Read The Warehouse Currency
   ----------------------------------------------------------------------
         select  /*+ FULL(SP) CACHE(SP) */
	          warehouse_currency_code into l_to_currency
	 from edw_local_system_parameters SP;

   if (g_missing_rates >0) then
     	--------------------------------------------------------------------
	-- Print Records where conversion date is in past
	-- Added for Currency Conversion Date Enhancement
	---------------------------------------------------------------------
   /*   FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'        ***Information for Missing Currency Conversion Rates***        ');
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
           TRUNCATE_table('FII_AP_INV_LINES_FSTG');
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
           COMMIT;
           DELETE_STG;
           IF (g_row_count = -1) THEN RAISE l_set_status_failure; END IF;
     END IF;

     --bug#3818907
     --Clean up the old records from missing rates table and store the
     --latest records with missing rates from the current collection
     -- to the missing rates table from the temp table.

     delete from fii_ap_line_msng_rates;

     insert into fii_ap_line_msng_rates(Primary_Key1,
                                        Primary_Key2,
				        Primary_Key3,
					Primary_Key4)  /* Inv Lines Uptake */
                                 select Primary_Key1,
				        Primary_Key2,
					Primary_Key5,
					Primary_Key4
                                 from fii_ap_tmp_line_pk;

     -- -----------------------------------------------
     -- Successful.  Commit and call
     -- wrapup to commit and insert messages into logs
     -- -----------------------------------------------
     edw_log.put_line(' ');
     edw_log.put_line('Inserted '||nvl(g_row_count,0)||
         ' rows into the staging table');
     edw_log.put_line(' ');
  --   COMMIT;
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
     --bug#3818907
     --Program is on the verge of completing successfully,so clean up
     -- the temp table
    begin
      TRUNCATE_TABLE('FII_AP_TMP_LINE_PK');
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
End FII_AP_INV_LINES_F_C;

/
