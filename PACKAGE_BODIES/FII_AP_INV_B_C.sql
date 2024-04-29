--------------------------------------------------------
--  DDL for Package Body FII_AP_INV_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AP_INV_B_C" AS
/* $Header: FIIAP17B.pls 120.76 2007/11/27 06:53:40 hsoorea ship $ */

	g_fii_schema   VARCHAR2(30);
--	g_tablespace    VARCHAR2(50) := NULL;
	g_expense_ccid_count NUMBER := 0;
 	g_errbuf      VARCHAR2(2000) := NULL;
 	g_retcode     VARCHAR2(200) := NULL;
	g_exception_msg  VARCHAR2(4000) := NULL;
	g_today DATE;
	g_start_date DATE;
	g_end_date DATE;
	g_mode VARCHAR2(20) := NULL;
	g_prim_currency VARCHAR2(15) := NULL;
   	g_sec_currency VARCHAR2(15) := NULL;
	g_warehouse_rate_type VARCHAR2(30) := NULL;
   	g_state VARCHAR2(200);
   	g_phase VARCHAR2(200);
   	g_ap_application_id NUMBER;
   	g_gl_application_id NUMBER;
   	g_has_lud              BOOLEAN := FALSE;
   	MAX_LOOP      CONSTANT NUMBER := 180;
   	interval_size CONSTANT NUMBER := 1000;
        G_TABLE_NOT_EXIST EXCEPTION;
	PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
        G_CCID_FAILED        EXCEPTION;
	G_PROCEDURE_FAILURE    EXCEPTION;
        G_NO_CHILD_PROCESS   EXCEPTION;
   	G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;
        G_IMP_NOT_SET EXCEPTION;
        G_MISSING_RATES EXCEPTION;
        G_NEED_SECONDARY_INFO EXCEPTION;

   	G_LUD_TO_DATE DATE;
	g_prim_rate_type VARCHAR2(30);
	g_sec_rate_type VARCHAR2(30);
	g_prim_rate_type_name VARCHAR2(30);
	g_sec_rate_type_name VARCHAR2(30);
 	g_lud_from_date DATE;
   g_fix_rates varchar(1);
   g_section              VARCHAR2(20) := NULL;
   g_num                  NUMBER;
   g_primary_mau          NUMBER;
   g_secondary_mau        NUMBER;
   g_worker_num           NUMBER;
   g_fii_user_id          NUMBER(15);
   g_fii_login_id         NUMBER(15);
   g_truncate_staging     VARCHAR2(1) := 'N';
   g_truncate_id          VARCHAR2(1) := 'N';
   g_truncate_rates       VARCHAR2(1) := 'N';
   g_debug_flag           VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
   g_exp_imp_prof_flag    VARCHAR2(1) := NVL(FND_PROFILE.value('FII_AP_DBI_EXP_IMP'), 'N');
   g_oper_imp_prof_flag   VARCHAR2(1) := NVL(FND_PROFILE.value('FII_AP_DBI_IMP'), 'N');
   ONE_SECOND    CONSTANT NUMBER := 0.000011574;  -- 1 second

   g_program_type         VARCHAR2(1);

   g_usage_code CONSTANT  VARCHAR2(10) := 'DBI'; --CHAR will fail join
   g_table_name           VARCHAR2(50) := 'FII_AP_INV_B';
   g_ind_exp_classes      VARCHAR2(1000);
   g_xla_ret_code         VARCHAR2(1) := NULL;
   g_apps_schema_name     VARCHAR2(50) := NVL(FII_UTIL.get_apps_schema_name, 'APPS');

-- ---------------------------------------------------------------
-- PROCEDURE CHECK_XLA_CONVERSION_STATUS
--Bug 5437394
-- ---------------------------------------------------------------
PROCEDURE CHECK_XLA_CONVERSION_STATUS(p_start_date DATE) IS

    CURSOR c_non_upgraded_ledgers IS
		SELECT DISTINCT
           s.ledger_id,
           s.name
      FROM gl_period_statuses  ps,
           gl_ledgers_public_v s,
           (SELECT DISTINCT slga.ledger_id
              FROM fii_slg_assignments         slga,
                   fii_source_ledger_groups    fslg
             WHERE slga.source_ledger_group_id = fslg.source_ledger_group_id
               AND fslg.usage_code             =g_usage_code) fset
     WHERE s.ledger_id        = fset.ledger_id
       AND ps.application_id  = 200
       AND ps.set_of_books_id = fset.ledger_id
       AND ps.end_date       >= p_start_date
       AND ps.migration_status_code <> 'U';

BEGIN

   if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Calling procedure: CHECK_XLA_CONVERSION_STATUS');
      FII_UTIL.put_line('');
   end if;

   FOR ledger_record in c_non_upgraded_ledgers  LOOP
      g_xla_ret_code := 'W';
      FII_MESSAGE.write_log(
         msg_name   => 'FII_XLA_NON_UPGRADED_LEDGER',
         token_num  => 3,
         t1         => 'PRODUCT',
         v1         => 'Payables',
         t2         => 'LEDGER',
         v2         => ledger_record.name,
         t3         => 'START_DATE',
         v3         => p_start_date);
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

---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
PROCEDURE drop_table (p_table_name in varchar2) is
    l_stmt varchar2(400);
BEGIN
    l_stmt:='DROP table '||g_fii_schema||'.'||p_table_name;
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('');
      FII_UTIL.put_line(l_stmt);
    end if;
    EXECUTE IMMEDIATE l_stmt;

EXCEPTION
    WHEN G_TABLE_NOT_EXIST THEN
        null;      -- Oracle 942, table does not exist, no actions
    WHEN OTHERS THEN
        g_errbuf := 'Error in Procedure: DROP_TABLE  Message: '||sqlerrm;
        RAISE;
END Drop_Table;

-----------------------------------------------------------------------
-- PROCEDURE CLEAN_UP
-----------------------------------------------------------------------
PROCEDURE Clean_Up IS


BEGIN
   g_state := 'Inside the procedure CLEAN_UP';

 if g_debug_flag = 'Y' then
   FII_UTIL.put_line('Calling procedure CLEAN_UP');
   FII_UTIL.put_line('');

   FII_UTIL.put_line('Truncate table FII_AP_SUM_WORK_JOBS');
 end if;
   truncate_table('FII_AP_SUM_WORK_JOBS');

   IF (g_truncate_id = 'Y') THEN
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Truncate table FII_AP_Unpost_Headers_T');
    end if;
		truncate_table('FII_AP_Unpost_Headers_T');
   END IF;

   IF (g_truncate_staging = 'Y') THEN
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Truncate table FII_AP_INV_STG');
    end if;
      truncate_table('FII_AP_INV_STG');
   END IF;

   -- haritha
   IF (g_truncate_rates = 'Y') THEN
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Truncate table FII_AP_INV_RATES_TEMP');
    end if;
      truncate_table('FII_AP_INV_RATES_TEMP');
   END IF;



EXCEPTION
   WHEN OTHERS Then
        g_retcode:=-1;
        g_errbuf := '
---------------------------------
Error in Procedure: Clean_Up
Message: ' || sqlerrm;
        RAISE g_procedure_failure;

END Clean_up;

---------------------------------------------------
-- FUNCTION CHECK_IF_SET_UP_CHANGE
---------------------------------------------------
FUNCTION CHECK_IF_SET_UP_CHANGE RETURN VARCHAR2 IS
    l_result VARCHAR2(10);
    l_count1 number :=0 ;
    l_count2 number :=0 ;

BEGIN
  g_state := 'Check if Source Ledger Group set up has changed';
  if g_debug_flag = 'Y' then
    FII_UTIL.put_line('');
    FII_UTIL.put_line( 'Check if Source Ledger Group set up has changed');
  end if;

    SELECT DECODE(item_value, 'Y', 'TRUE', 'FALSE')
    INTO l_result
    FROM fii_change_log
    WHERE log_item = 'AP_RESUMMARIZE';

    IF l_result = 'TRUE' THEN

     BEGIN
       SELECT 1
       INTO l_count1
       FROM fii_ap_inv_b
       WHERE ROWNUM = 1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN l_count1 := 0;
     END;

     BEGIN
       SELECT 1
       INTO l_count2
       FROM fii_ap_inv_stg
       WHERE ROWNUM = 1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN l_count2 := 0;
     END;

             IF (l_count1 = 0 AND l_count2 = 0)  then
                   UPDATE fii_change_log
                   SET item_value = 'N',
                       last_update_date  = SYSDATE,
                       last_update_login = g_fii_login_id,
                       last_updated_by   = g_fii_user_id
                   WHERE log_item = 'AP_RESUMMARIZE';

                   COMMIT;

                   l_result := 'FALSE';
             END IF;

   END IF;

    RETURN l_result;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN 'FALSE';
   WHEN OTHERS THEN
        g_retcode := -1;
        g_errbuf := '
-----------------------------
Error occured in Function: CHECK_IF_SET_UP_CHANGE
Message: ' || sqlerrm;
    RAISE;
END CHECK_IF_SET_UP_CHANGE;


--------------------------------------------------
-- PROCEDURE POPULATE_INV_ID_TEMP
---------------------------------------------------
FUNCTION POPULATE_INV_ID_TEMP RETURN NUMBER IS
   l_count NUMBER;
BEGIN

  --------------------------------------------------------------------------------
  -- FII_AP_UNPOST_HEADERS_T stores the header id of records that have a null
  -- gl_sl_link_id and may be updated during the incremental load.
  --------------------------------------------------------------------------------

  g_state := 'Inserting records into FII_AP_UNPOST_HEADERS_T table';
  IF g_debug_flag = 'Y' then
         FII_UTIL.put_line('');
         FII_UTIL.put_line(g_state);
         fii_util.start_timer;
         fii_util.put_line('');
  END IF;

  INSERT INTO FII_AP_UNPOST_HEADERS_T (
          AE_HEADER_ID,
          REF_AE_HEADER_ID,
          TEMP_LINE_NUM,
          SEQUENCE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN
          )
  SELECT  AE_Header_ID     AE_HEADER_ID,
          Ref_AE_Header_ID REF_AE_HEADER_ID,
          Temp_Line_Num    TEMP_LINE_NUM,
          Rownum           SEQUENCE_ID,
          sysdate          LAST_UPDATE_DATE,
          g_fii_user_id    LAST_UPDATED_BY,
          sysdate          CREATION_DATE,
          g_fii_user_id    CREATED_BY,
          g_fii_login_id   LAST_UPDATE_LOGIN
  FROM (SELECT AE_Header_ID, Ref_AE_Header_ID, Temp_Line_Num
        FROM FII_AP_Inv_B
        WHERE GL_SL_Link_ID IS NULL);

  l_count := SQL%ROWCOUNT;

  IF g_debug_flag = 'Y' then
         FII_UTIL.stop_timer;
         FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT||' records in FII_AP_UNPOST_HEADERS_T');
         FII_UTIL.print_timer('Duration');
  END IF;

  RETURN l_count;
EXCEPTION
    WHEN OTHERS THEN
        g_errbuf:=sqlerrm;
        g_retcode:= -1;
        g_exception_msg  := g_retcode || ':' || g_errbuf;
        FII_UTIL.put_line('Error occured while ' || g_state);
        FII_UTIL.put_line(g_exception_msg);
        RAISE;
END POPULATE_INV_ID_TEMP;

-----------------------------------------------------------
--  PROCEDURE POPULATE_AP_SUM_STG
-----------------------------------------------------------
PROCEDURE POPULATE_AP_SUM_STG (p_start_range IN number,
                               p_end_range   IN number,
                               p_phase         IN number) is
    l_stmt VARCHAR2(1000);
BEGIN

  IF p_phase = 1 THEN

        g_state := 'Populating FII_AP_Inv_STG with updated data using the FII_AP_Unpost_Headers_T table';
        if g_debug_flag = 'Y' then
          FII_UTIL.put_line(g_state);
          FII_UTIL.start_timer;
        end if;

   INSERT INTO FII_AP_INV_STG (
          AE_HEADER_ID,
          REF_AE_HEADER_ID,
          TEMP_LINE_NUM,
          GL_SL_LINK_ID,
          GL_SL_LINK_TABLE)
   SELECT XDL.AE_Header_ID AE_Header_ID,
          XDL.Ref_AE_Header_ID Ref_AE_Header_ID,
          XDL.Temp_Line_Num Temp_Line_Num,
          XAL.GL_SL_Link_ID GL_SL_Link_ID,
          XAL.GL_SL_Link_Table GL_SL_Link_Table
   FROM FII_AP_Unpost_Headers_T ID,
        XLA_AE_Lines XAL,
        XLA_Distribution_Links XDL
   WHERE ID.AE_Header_ID = XDL.AE_Header_ID
   AND   ID.Ref_AE_Header_ID = XDL.Ref_AE_Header_ID
   AND   ID.Temp_Line_Num = XDL.Temp_Line_Num
   AND   XDL.Application_ID = 200
   AND   XDL.AE_Header_ID = XAL.AE_Header_ID
   AND   XDL.AE_Line_Num = XAL.AE_Line_Num
   AND   XAL.Application_ID = 200
   AND   XAL.GL_SL_Link_ID IS NOT NULL
   AND   ID.sequence_id >= p_start_range
   AND   ID.sequence_id <= p_end_range;

       if g_debug_flag = 'Y' then
	FII_UTIL.put_line('Inserted '||sql%rowcount||' rows INTO FII_AP_INV_STG table');
        FII_UTIL.stop_timer;
        FII_UTIL.print_timer('Duration');
       end if;


  ELSE --This is a Phase 2 job.

        g_state := 'Populating FII_AP_Inv_STG with new data using the header identifier.  Header range is from ' || p_start_range || ' to ' || p_end_range || '.';
        if g_debug_flag = 'Y' then
          FII_UTIL.put_line(g_state);
          FII_UTIL.start_timer;
        end if;

  	INSERT INTO FII_AP_INV_STG
                         (LEDGER_ID,
                          ACCOUNT_DATE,
                          INV_CURRENCY_CODE,
                          AMOUNT_T,
                          INVOICE_ID,
                          INVOICE_DISTRIBUTION_ID,
                          AMOUNT_B,
                          PO_MATCHED_FLAG,
                          SOURCE,
                          INV_DIST_CREATED_BY,
                          SUPPLIER_SITE_ID,
                          INV_DIST_CREATION_DATE,
                          SUPPLIER_ID,
                          INVOICE_TYPE,
                          POSTED_FLAG,
                          FIN_CATEGORY_ID,
                          COMPANY_ID,
                          COST_CENTER_ID,
                          CHART_OF_ACCOUNTS_ID,
                          DIST_CCID,
                          PO_DISTRIBUTION_ID,
                          QUANTITY_INVOICED,
                          PROJECT_ID,
                          TASK_ID,
                          PRIM_CONVERSION_RATE,
                          SEC_CONVERSION_RATE,
                          APPROVED_FLAG,
                          ORG_ID,
                          EMPLOYEE_ID,
                          LINE_TYPE_LOOKUP_CODE,
                          INVOICE_NUM,
                          DISCRETIONARY_EXPENSE_FLAG,
                          TRANS_CURRENCY_CODE,
                          INVOICE_DATE,
                          DISTRIBUTION_LINE_NUMBER,
                          USER_DIM1_ID,
                          USER_DIM2_ID,
                          EXP_REPORT_HEADER_ID,
                          PO_HEADER_ID,
                          PO_RELEASE_ID,
                          PO_NUM,
                          AE_HEADER_ID,
                          REF_AE_HEADER_ID,
                          TEMP_LINE_NUM,
                          GL_SL_LINK_ID,
                          GL_SL_LINK_TABLE,
                          INVENTORY_ITEM_ID,
                          PURCHASING_CATEGORY_ID,
                          ITEM_DESCRIPTION)
        WITH ACCNT_CLASS AS (SELECT /*+ MATERIALIZE */ XAD.Ledger_ID,
                                     XACA.Accounting_Class_Code
                             FROM XLA_Assignment_Defns_B XAD,
                                  XLA_Acct_Class_Assgns XACA
                             WHERE XAD.Program_Code = 'PAYABLES DBI EXPENSES'
                             AND XAD.Enabled_Flag = 'Y'
                             AND XAD.Program_Code = XACA.Program_Code
                             AND XAD.Assignment_Code = XACA.Assignment_Code)
	SELECT   /*+ ORDERED no_expand use_hash(XAL,XAH,XTE,XDL,RH,AID,AI,FND,PO,AIL)
    	parallel(ai) parallel(fnd) parallel(aid) parallel(po) parallel(xah) parallel(xte) parallel(xal) parallel(xdl) parallel(ail)
    	swap_join_inputs(AC) swap_join_inputs(FND) swap_join_inputs(PO)
	pq_distribute(xah,hash,hash) pq_distribute(xte,hash,hash) pq_distribute(xal,hash,hash) pq_distribute(xdl,hash,hash)
	pq_distribute(aid,hash,hash) pq_distribute(po,hash,hash) pq_distribute(fnd,hash,hash) pq_distribute(ai,hash,hash)
	pq_distribute(ail,hash,hash)
	*/ aid.set_of_books_id SET_OF_BOOKS_ID,
                    trunc(aid.accounting_date) ACCOUNT_DATE,
                    gsob.currency_code INV_CURRENCY_CODE,
                    NVL(XDL.Unrounded_Entered_DR, 0) - NVL(XDL.Unrounded_Entered_CR, 0) Amount_T,
                    aid.invoice_id INVOICE_ID,
                    aid.invoice_distribution_id INVOICE_DISTRIBUTION_ID,
                    NVL(XDL.Unrounded_Accounted_DR, 0) - NVL(XDL.Unrounded_Accounted_CR, 0) Amount_B,
                    decode(aid.po_distribution_id, Null, 'N', 'Y') PO_MATCHED_FLAG,
                    ai.source SOURCE,
                    nvl(fnd.EMPLOYEE_ID,-1) INV_DIST_CREATED_BY,
                    NVL(ai.vendor_site_id, -1) SUPPLIER_SITE_ID,
                    trunc(aid.creation_date) INV_DIST_CREATION_DATE,
                    ai.vendor_id SUPPLIER_ID,
                    ai.invoice_type_lookup_code INVOICE_TYPE,
                    NVL(aid.posted_flag, 'N') POSTED_FLAG,
                    glcc.NATURAL_ACCOUNT_ID FIN_CATEGORY_ID,
                    glcc.company_id,
                    glcc.cost_center_id,
                    gsob.chart_of_accounts_id CHART_OF_ACCOUNTS_ID,
                    XAL.Code_Combination_ID DIST_CCID,
                    aid.po_distribution_id,
                    aid.quantity_invoiced,
                    aid.project_id,
                    aid.task_id,
                    decode(gsob.currency_code, g_prim_currency, 1,
                           fii_currency.get_global_rate_primary( gsob.currency_code,
                                                                 trunc(least(aid.accounting_date,sysdate)))) PRIM_CONVERSION_RATE,
                    decode(gsob.currency_code, g_sec_currency, 1,
                           fii_currency.get_global_rate_secondary( gsob.currency_code,
                                                                   trunc(least(aid.accounting_date,sysdate)))) SEC_CONVERSION_RATE,
                    NVL(aid.match_status_flag, 'N')  APPROVED_FLAG,
                    NVL(ai.org_id, -1) ORG_ID,
                    nvl(po.employee_id, ai.paid_on_behalf_employee_id),
                    aid.LINE_TYPE_LOOKUP_CODE,
                    ai.invoice_num,
                    CASE
                       WHEN ai.invoice_type_lookup_code = 'EXPENSE REPORT'
                       AND  ai.source in ('XpenseXpress', 'SelfService', 'CREDIT CARD', 'Oracle Project Accounting')
                       AND  NVL(aid.match_status_flag, 'N') = 'A'
                       THEN 'Y'
                       WHEN ai.invoice_type_lookup_code = 'STANDARD'
                       AND  ai.source = 'CREDIT CARD'
                       AND  ai.PAID_ON_BEHALF_EMPLOYEE_ID is not null
                       AND  NVL(aid.match_status_flag, 'N') = 'A'
                       THEN 'Y'
                       ELSE 'N'
                    END Discretionary_Expense_Flag,
                    ai.invoice_currency_code Trans_Currency_Code,
                    ai.invoice_date Invoice_Date,
                    aid.distribution_line_number Distribution_Line_Number,
                    glcc.user_dim1_id,
                    glcc.user_dim2_id,
                    rh.report_header_id Exp_Report_Header_ID,
                    PD.PO_Header_ID,
                    PD.PO_Release_ID,
                    PH.Segment1 PO_Num,
                    XAH.AE_Header_ID AE_Header_ID,
                    XDL.Ref_AE_Header_ID Ref_AE_Header_ID,
                    XDL.Temp_Line_Num Temp_Line_Num,
                    XAL.GL_SL_Link_ID GL_SL_Link_ID,
                    XAL.GL_SL_Link_Table GL_SL_Link_Table,
                    AIL.Inventory_Item_ID Inventory_Item_ID,
                    AIL.Purchasing_Category_ID Purchasing_Category_ID,
                    AIL.Item_Description Item_Description
                  FROM
                    XLA_AE_Lines XAL,
                    ACCNT_CLASS AC,
                    XLA_Distribution_Links XDL,
                     ap_invoice_distributions_all aid,
                     XLA_AE_Headers XAH,
        						XLA_Transaction_Entities XTE,
   									AP_Invoice_Lines_ALL AIL,
        						ap_invoices_all ai,
        						po_vendors po, --AP_SUPPLIERS PO,
        						fnd_user fnd,
                     (select vouchno,
               case when count(1) > 1 then -1
                    else min(report_header_id) end report_header_id
        from ap_expense_report_headers_all
        where accounting_date >= g_start_date
        group by vouchno) rh,
                         po_distributions_all pd,
        po_headers_all ph,
        gl_ledgers_public_v gsob,
        fii_gl_ccid_dimensions glcc,
        fii_slg_assignments slga,
        fii_source_ledger_groups fslg
   WHERE XAH.Entity_ID = XTE.Entity_ID
   AND   XAH.AE_Header_ID = XAL.AE_Header_ID
   AND   XAL.AE_Header_ID = XDL.AE_Header_ID
   AND   XAL.AE_Line_Num = XDL.AE_Line_Num
   AND   XAH.Ledger_ID = AID.Set_Of_Books_ID
   AND   XAL.Accounting_Class_Code = AC.Accounting_Class_Code
   AND   (AC.ledger_id IS NULL  OR AID.Set_Of_Books_ID = AC.Ledger_ID)
   AND   XDL.Source_Distribution_Type IN ('AP_INV_DIST', 'AP_PMT_DIST', 'AP_PREPAY')
   AND   XDL.Source_Distribution_ID_Num_1 = AID.Invoice_Distribution_ID
   AND   AID.Invoice_ID = AIL.Invoice_ID
   AND   AID.Invoice_Line_Number = AIL.Line_Number
   AND   ai.invoice_id = aid.invoice_id
   AND   aid.set_of_books_id = gsob.ledger_id
   AND   XAL.Code_Combination_ID = glcc.code_combination_id
   AND   glcc.chart_of_accounts_id = slga.chart_of_accounts_id
   AND  (glcc.company_id = slga.bal_seg_value_id
         OR slga.bal_seg_value_id = -1 )
   AND   aid.set_of_books_id = slga.ledger_id
   AND   slga.source_ledger_group_id = fslg.source_ledger_group_id
   AND   fslg.usage_code = g_usage_code
   AND   fnd.user_id = nvl(aid.created_by, ai.cancelled_by)
   AND   XAH.Application_ID = 200
   AND   XAH.Balance_Type_Code = 'A'
   AND   XTE.Application_ID = 200
   AND   XAL.Application_ID = 200
   AND   XDL.Application_ID = 200
   AND   XAH.Accounting_Entry_Status_Code = 'F'
   AND   XTE.Entity_Code = 'AP_INVOICES'
   AND   XAH.AE_Header_ID >= p_start_range
   AND   XAH.AE_Header_ID <= p_end_range
   AND   ai.vendor_id = po.vendor_id
   AND   aid.accounting_date >= g_start_date
   AND   ai.invoice_id = rh.vouchno (+)
   AND   aid.po_distribution_id = pd.po_distribution_id (+)
   AND   pd.po_header_id = ph.po_header_id (+)
   AND   xal.accounting_date >= g_start_date
   AND   xah.accounting_date >= g_start_date
   AND   ail.accounting_date >= g_start_date;

       if g_debug_flag = 'Y' then
	FII_UTIL.put_line('Inserted '||sql%rowcount||' rows INTO FII_AP_INV_STG table');
        FII_UTIL.stop_timer;
        FII_UTIL.print_timer('Duration');
       end if;


  END IF;


	COMMIT;

   ------------------------------------------------------------------
   -- Account_date and creation_date are truncated so that multiple
   -- records with same date are not inserted into the staging table,
   -- which causes problem with merge statement
   ------------------------------------------------------------------

EXCEPTION
    WHEN OTHERS THEN
        g_errbuf:=sqlerrm;
        g_retcode:= -1;
        g_exception_msg  := g_retcode || ':' || g_errbuf;
        FII_UTIL.put_line('Error occured while ' || g_state);
        FII_UTIL.put_line(g_exception_msg);
    RAISE;

END POPULATE_AP_SUM_STG;

-----------------------------------------------------------
--  PROCEDURE REGISTER_JOBS
-----------------------------------------------------------
FUNCTION REGISTER_JOBS RETURN NUMBER IS
    l_max_number1   NUMBER;
    l_start_number1 NUMBER;
    l_max_number2   NUMBER;
    l_start_number2 NUMBER;
    l_end_number   NUMBER;
    l_count        NUMBER := 0;
BEGIN

    g_state := 'Inside the procedure REGISTER_JOBS';

    ----------------------------------------------------------------
    -- There are two types of jobs:
    -- Phase 1: Updated data is stored in fii_ap_unpost_headers_t.
    -- Phase 2: New data has a header id greater than the current
    -- maximum header id.
    ----------------------------------------------------------------

    --Find start and end range for Phase 1 jobs.
    SELECT nvl(max(sequence_id), -1), nvl(min(sequence_id), -1)
    INTO l_max_number1, l_start_number1
    FROM FII_AP_Unpost_Headers_T;


    --Find start and end re for Phase 2 jobs.
    SELECT MAX(NVL(AE_Header_ID, -1)) + 1 INTO l_start_number2 FROM FII_AP_INV_B;
    SELECT MAX(AE_Header_ID) INTO l_max_number2 FROM XLA_AE_HEADERS;

    IF l_max_number1 = -1 AND l_start_number1 = -1 AND l_max_number2 <= l_start_number2 THEN
      RETURN -1;
    END IF;

    g_phase := 'Register phase 1 jobs for workers';

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_state);
    end if;

    WHILE (l_start_number1 < (l_max_number1 + 1)) LOOP
      l_end_number:= l_start_number1 + INTERVAL_SIZE;

      INSERT INTO FII_AP_SUM_WORK_JOBS (start_range, end_range, worker_number, status, phase_id)
      VALUES (l_start_number1, least(l_end_number, l_max_number1), 0, 'UNASSIGNED', 1);

      l_count := l_count + 1;
      l_start_number1 := least(l_end_number, l_max_number1) + 1;
    END LOOP;

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Inserted ' || l_count || ' jobs into FII_AP_SUM_WORK_JOBS table');
    end if;


    g_phase := 'Register phase 2 jobs for workers';

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line(g_state);
    end if;


    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('New data processed during this incremental load is from header ' || l_start_number2 || ' to ' || l_max_number2);
    end if;

    WHILE (l_start_number2 < (l_max_number2 + 1)) LOOP
      l_end_number:= l_start_number2 + INTERVAL_SIZE;

      INSERT INTO FII_AP_SUM_WORK_JOBS (start_range, end_range, worker_number, status, phase_id)
      VALUES (l_start_number2, least(l_end_number, l_max_number2), 0, 'UNASSIGNED', 2);

      l_count := l_count + 1;
      l_start_number2 := least(l_end_number, l_max_number2) + 1;
    END LOOP;

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Inserted ' || l_count || ' jobs into FII_AP_SUM_WORK_JOBS table');
    end if;

    RETURN 1;

EXCEPTION
    WHEN OTHERS THEN
        g_retcode := -2;
        g_errbuf := '
  ---------------------------------
  Error in Procedure: REGISTER_JOBS
           Phase: '||g_phase||'
           Message: '||sqlerrm;
    RAISE g_procedure_failure;

END REGISTER_JOBS;

---------------------------------------------------
-- FUNCTION LAUNCH_WORKER
---------------------------------------------------
-- p_worker_no is the worker number of this particular worker

FUNCTION LAUNCH_WORKER(p_worker_no  NUMBER) RETURN NUMBER IS
   l_request_id         NUMBER;
BEGIN

  g_state := 'Inside Launch Worker procedure for worker ' || p_worker_no;
  if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_state);
  end if;


    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'FII',
                          'FII_AP_INV_B_C_SUBWORKER',
                          NULL,
                          NULL,
                          FALSE,
                          p_worker_no);

    -- This is the concurrent executable of the subworker.

    IF (l_request_id = 0) THEN
        rollback;
        g_retcode := -2;
        g_errbuf := '
        ---------------------------------
        Error in Procedure: LAUNCH_WORKER
        Message: '||fnd_message.get;
        RAISE G_NO_CHILD_PROCESS;

    END IF;

   RETURN l_request_id;

EXCEPTION
   WHEN G_NO_CHILD_PROCESS THEN
   	g_retcode := -1;
   	FII_UTIL.put_line('No child process launched');
   	raise;
   WHEN OTHERS THEN
    	rollback;
    	g_retcode := -2;
    	g_errbuf := '
  ---------------------------------
  Error in Procedure: LAUNCH_WORKER
           Message: '||sqlerrm;
    RAISE g_procedure_failure;

END LAUNCH_WORKER;

-----------------------------------------------------------
--  FUNCTION VERIFY_MISSING_RATES
-----------------------------------------------------------
FUNCTION VERIFY_MISSING_RATES (p_program_type IN VARCHAR2) return number IS
    l_stmt VARCHAR2(1000);
    l_miss_rates_prim number :=0;
    l_miss_rates_sec  number :=0;
    l_payment_currency    Varchar2(2000):=NULL;
    l_actg_date            Varchar2(2000) := NULL;

   --------------------------------------------------------
   -- Cursor declaration required to generate output file
   -- containing rows with MISSING CONVERSION RATES
   --------------------------------------------------------
    CURSOR prim_MissingRate IS
        SELECT DISTINCT INV_CURRENCY_CODE from_currency, decode(prim_conversion_rate,-3,
                  to_date('01/01/1999','MM/DD/RRRR'), LEAST(ACCOUNT_DATE, sysdate)) actg_dt
        FROM FII_AP_INV_STG stg
        WHERE  stg.prim_conversion_rate < 0 ;

    CURSOR sec_MissingRate IS
        SELECT DISTINCT INV_CURRENCY_CODE from_currency,  decode(sec_conversion_rate,-3,
                    to_date('01/01/1999','MM/DD/RRRR'),LEAST(ACCOUNT_DATE, sysdate)) actg_dt
        FROM FII_AP_INV_STG stg
        WHERE  stg.sec_conversion_rate < 0 ;

   CURSOR prim_MissingRate_L IS
        SELECT DISTINCT FUNCTIONAL_CURRENCY from_currency, decode(prim_conversion_rate,-3,
             to_date('01/01/1999','MM/DD/RRRR'), LEAST(TRX_DATE, sysdate)) actg_dt
        FROM FII_AP_INV_RATES_TEMP rates
        WHERE  rates.prim_conversion_rate < 0 ;

   CURSOR sec_MissingRate_L IS
        SELECT DISTINCT FUNCTIONAL_CURRENCY from_currency,  decode(sec_conversion_rate,-3,
                  to_date('01/01/1999','MM/DD/RRRR'), LEAST(TRX_DATE, sysdate)) actg_dt
        FROM FII_AP_INV_RATES_TEMP rates
        WHERE  rates.sec_conversion_rate < 0 ;

BEGIN
   g_state := 'Checking to see which additional rates need to be defined, if any';

   IF p_program_type = 'L' THEN

     BEGIN
   	SELECT 1 INTO l_miss_rates_prim FROM FII_AP_INV_RATES_TEMP rates WHERE rates.prim_conversion_rate < 0;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN l_miss_rates_prim := 0;
     END;

     BEGIN
   	SELECT 1 INTO l_miss_rates_sec FROM FII_AP_INV_RATES_TEMP rates WHERE rates.sec_conversion_rate < 0;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN l_miss_rates_sec := 0;
     END;

   ELSE

     BEGIN
   	SELECT 1 INTO l_miss_rates_prim FROM FII_AP_INV_STG stg WHERE stg.prim_conversion_rate < 0;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN l_miss_rates_prim := 0;
     END;

     BEGIN
   	SELECT 1 INTO l_miss_rates_sec FROM FII_AP_INV_STG stg WHERE stg.sec_conversion_rate < 0;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN l_miss_rates_sec := 0;
     END;

   END IF;

   --------------------------------------------------------
   -- Print out translated messages to let user know there
   -- are missing exchange rate information
   --------------------------------------------------------
	IF (l_miss_rates_prim > 0 OR
        l_miss_rates_sec > 0) THEN
        	FII_MESSAGE.write_output(
            	msg_name    => 'BIS_DBI_CURR_PARTIAL_LOAD',
            	token_num   => 0);
	END IF;

   --------------------------------------------------------
   -- Print out missing rates report
   --------------------------------------------------------

/* Start : Mofified code as part for Bug 4219468 */

 IF 	(l_miss_rates_prim > 0) OR
	(l_miss_rates_sec > 0)	THEN

	BIS_COLLECTION_UTILITIES.writeMissingRateHeader;

        IF p_program_type = 'L' THEN

           FOR rate_record in prim_MissingRate_L
           LOOP
                    BIS_COLLECTION_UTILITIES.writeMissingRate(
                    g_prim_rate_type_name,
                    rate_record.from_currency,
                    g_prim_currency,
                    rate_record.actg_dt);
           END LOOP;

           FOR rate_record in sec_MissingRate_L
           LOOP
                    BIS_COLLECTION_UTILITIES.writeMissingRate(
                    g_sec_rate_type_name,
                    rate_record.from_currency,
                    g_sec_currency,
                    rate_record.actg_dt);
           END LOOP;

        ELSE

           FOR rate_record in prim_MissingRate
           LOOP
                    BIS_COLLECTION_UTILITIES.writeMissingRate(
                    g_prim_rate_type_name,
                    rate_record.from_currency,
                    g_prim_currency,
                    rate_record.actg_dt);
           END LOOP;

           FOR rate_record in sec_MissingRate
           LOOP
                    BIS_COLLECTION_UTILITIES.writeMissingRate(
                    g_sec_rate_type_name,
                    rate_record.from_currency,
                    g_sec_currency,
                    rate_record.actg_dt);
           END LOOP;

        END IF;
   RETURN -1;
   ELSE
   RETURN 1;
 END IF;

/* End : Modified code as part for Bug 4219468 */


EXCEPTION
	WHEN OTHERS THEN
   		g_errbuf:=sqlerrm;
      		g_retcode:= -1;
      		g_exception_msg  := g_retcode || ':' || g_errbuf;
                FII_UTIL.put_line('Error occured while ' || g_state);
      	        FII_UTIL.put_line(g_exception_msg);
      	RAISE;
END VERIFY_MISSING_RATES;

-----------------------------------------------------------
--  PROCEDURE POPULATE_AP_BASE_SUM
-----------------------------------------------------------
 PROCEDURE POPULATE_AP_BASE_SUM IS
   l_stmt VARCHAR2(1000);
   seq_id NUMBER :=0;
BEGIN
  	SELECT FII_AP_INV_B_S.nextval INTO seq_id FROM dual;

        if g_debug_flag = 'Y' then
          FII_UTIL.put_line('');
          FII_UTIL.put_line('-------------------------------------------------');
          FII_UTIL.put_line('Populating FII_AP_INV_B FROM FII_AP_INV_STG table');
        end if;

	g_state := 'Populating FII_AP_INV_B FROM FII_AP_INV_STG table';

        -- haritha.
        -- Removed the where condition to check for invoice_id and other attributes
        -- of a distribution. Instead added the invoice_distribution_id condition.
        -- Also added the additional columns for insertion.

  	MERGE /*+ use_nl(bsum) */ INTO FII_AP_INV_B BSUM
        USING (SELECT  *
               FROM FII_AP_INV_STG
               WHERE  (nvl(prim_conversion_rate,1) > 0 OR nvl(sec_conversion_rate,1) > 0)
                 ) STG
        ON (BSUM.Ref_AE_Header_ID = STG.Ref_AE_Header_ID
            AND BSUM.Temp_Line_Num = STG.Temp_Line_Num
            AND BSUM.AE_Header_ID = STG.AE_Header_ID)
        WHEN MATCHED THEN UPDATE SET BSUM.GL_SL_Link_ID = STG.GL_SL_Link_ID,
                                     BSUM.GL_SL_Link_Table = STG.GL_SL_Link_Table
        WHEN NOT MATCHED THEN INSERT(bsum.LEDGER_ID,
                                     bsum.ACCOUNT_DATE,
                                     bsum.INV_CURRENCY_CODE,
                                     bsum.AMOUNT_T,
                                     bsum.INVOICE_ID,
                                     bsum.INVOICE_DISTRIBUTION_ID,
                                     bsum.AMOUNT_B,
                                     bsum.PO_MATCHED_FLAG,
                                     bsum.SOURCE,
                                     bsum.INV_DIST_CREATED_BY,
                                     bsum.SUPPLIER_SITE_ID,
                                     bsum.INV_DIST_CREATION_DATE,
                                     bsum.SUPPLIER_ID,
                                     bsum.INVOICE_TYPE,
                                     bsum.POSTED_FLAG,
                                     bsum.FIN_CATEGORY_ID,
                                     bsum.COMPANY_ID,
                                     bsum.COST_CENTER_ID,
                                     bsum.CHART_OF_ACCOUNTS_ID,
                                     bsum.DIST_CCID,
                                     bsum.PO_DISTRIBUTION_ID,
                                     bsum.QUANTITY_INVOICED,
                                     bsum.PROJECT_ID,
                                     bsum.TASK_ID,
                                     bsum.PRIM_AMOUNT_G,
                                     bsum.SEC_AMOUNT_G,
                                     bsum.UPDATE_SEQUENCE,
                                     bsum.APPROVED_FLAG,
                                     bsum.ORG_ID,
                                     bsum.last_update_date,
                                     bsum.last_updated_by,
                                     bsum.creation_date,
                                     bsum.created_by,
                                     bsum.last_update_login,
                                     bsum.account_date_id,
                                     bsum.employee_id,
                                     bsum.dist_count,
                                     bsum.LINE_TYPE_LOOKUP_CODE,
                                     bsum.invoice_num,
                                     bsum.discretionary_expense_flag,
                                     bsum.trans_currency_code,
                                     bsum.invoice_date,
                                     bsum.distribution_line_number,
                                     bsum.user_dim1_id,
                                     bsum.user_dim2_id,
                                     bsum.exp_report_header_id,
                                     bsum.po_header_id,
                                     bsum.po_release_id,
                                     bsum.po_num,
                                     BSUM.AE_Header_ID,
                                     BSUM.Ref_AE_Header_ID,
                                     BSUM.Temp_Line_Num,
                                     BSUM.GL_SL_Link_ID,
                                     BSUM.GL_SL_Link_Table,
                                     BSUM.Inventory_Item_ID,
                                     BSUM.Purchasing_Category_ID,
                                     BSUM.Item_Description)
                              VALUES
                                    (stg.LEDGER_ID,
                                     stg.ACCOUNT_DATE,
                                     stg.INV_CURRENCY_CODE,
                                     stg.AMOUNT_T,
                                     stg.INVOICE_ID,
                                     stg.INVOICE_DISTRIBUTION_ID,
                                     stg.AMOUNT_B,
                                     stg.PO_MATCHED_FLAG,
                                     stg.SOURCE,
                                     stg.INV_DIST_CREATED_BY,
                                     stg.SUPPLIER_SITE_ID,
                                     stg.INV_DIST_CREATION_DATE,
                                     stg.SUPPLIER_ID,
                                     stg.INVOICE_TYPE,
                                     stg.POSTED_FLAG,
                                     stg.FIN_CATEGORY_ID,
                                     stg.COMPANY_ID,
                                     stg.COST_CENTER_ID,
                                     stg.CHART_OF_ACCOUNTS_ID,
                                     stg.DIST_CCID,
                                     stg.PO_DISTRIBUTION_ID,
                                     stg.QUANTITY_INVOICED,
                                     stg.PROJECT_ID,
                                     stg.TASK_ID,
                                     round((stg.amount_b*stg.prim_conversion_rate)/to_number(g_primary_mau))*to_number(g_primary_mau),
                                     round((stg.amount_b*stg.sec_conversion_rate)/to_number(g_secondary_mau))*to_number(g_secondary_mau),
                                     seq_id,
                                     stg.APPROVED_FLAG,
                                     stg.org_id,
                                     sysdate,
                                     g_fii_user_id,
                                     sysdate,
                                     g_fii_user_id,
                                     g_fii_login_id,
                                     to_number (to_char(stg.ACCOUNT_DATE, 'J')),
                                     stg.employee_id,
                                     1,
                                     stg.LINE_TYPE_LOOKUP_CODE,
                                     stg.invoice_num,
                                     stg.discretionary_expense_flag,
                                     stg.trans_currency_code,
                                     trunc(stg.invoice_date),
                                     stg.distribution_line_number,
                                     stg.user_dim1_id,
                                     stg.user_dim2_id,
                                     stg.exp_report_header_id,
                                     stg.po_header_id,
                                     stg.po_release_id,
                                     stg.po_num,
                                     STG.AE_Header_ID,
                                     STG.Ref_AE_Header_ID,
                                     STG.Temp_Line_Num,
                                     STG.GL_SL_Link_ID,
                                     STG.GL_SL_Link_Table,
                                     STG.Inventory_Item_ID,
                                     STG.Purchasing_Category_ID,
                                     STG.Item_Description);

  if g_debug_flag = 'Y' then
	FII_UTIL.put_line('Merged ' || SQL%ROWCOUNT || ' records into FII_AP_INV_B');
   FII_UTIL.put_line('');
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

END POPULATE_AP_BASE_SUM;

-----------------------------------------------------------
--PROCEDURE CHILD_SETUP
-----------------------------------------------------------
PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS
    l_dir         VARCHAR2(400);
    l_stmt        VARCHAR2(100);
BEGIN
      g_state := 'Inside the procedure CHILD_SETUP';
--    l_stmt := ' ALTER SESSION SET global_names = false';
--    EXECUTE IMMEDIATE l_stmt;


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
    FII_UTIL.initialize(p_object_name||'.log',p_object_name||'.out',l_dir,'FII_AP_INV_B_Worker');


    g_fii_user_id := FND_GLOBAL.User_Id;
    g_fii_login_id := FND_GLOBAL.Login_Id;

    EXCEPTION
    WHEN OTHERS THEN
    rollback;
        g_retcode := -2;
        g_errbuf := '  ---------------------------------
        Error in Procedure: CHILD_SETUP  Message: '||sqlerrm;
    RAISE g_procedure_failure;
END CHILD_SETUP;

-------------------
-- PROCEDURE Init
-------------------
PROCEDURE Init is
    l_status              VARCHAR2(30);
    l_industry            VARCHAR2(30);
    l_stmt                VARCHAR2(50);
BEGIN
    g_state := 'Initializing the global variables';

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- FII_AP_INV_B is using
  -- --------------------------------------------------------
    g_section := 'Section 20';
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Section 20');
    end if;

    IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
    THEN NULL;
     if g_debug_flag = 'Y' then
        FII_UTIL.put_line('g_fii_schema is '||g_fii_schema);
      end if;
    END IF;

    g_section := 'Section 30';
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Section 30');
    end if;

/*  Commenting out as unncessary.  Query affects performance.

    g_phase := 'Find FII tablespace';

    SELECT tablespace_name
    INTO   g_tablespace
    FROM   all_tables
    WHERE  table_name = g_table_name
    AND    owner = g_fii_schema;

    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('g_tablespace is '||g_tablespace);
    end if;
    g_section := 'Section 35';
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Section 35');
    end if;
*/
    -- --------------------------------------------------------
    -- get minimum accountable unit of the warehouse currency
    -- --------------------------------------------------------
    	g_phase := 'Find currency information';

    	g_primary_mau := nvl(fii_currency.get_mau_primary, 0.01 );
    	g_secondary_mau:= nvl(fii_currency.get_mau_secondary, 0.01);

	g_prim_currency := bis_common_parameters.get_currency_code;
    	g_sec_currency := bis_common_parameters.get_secondary_currency_code;

    	g_phase := 'Find User ID and User Login';

    	g_fii_user_id :=  FND_GLOBAL.User_Id;
    	g_fii_login_id := FND_GLOBAL.Login_Id;
	g_prim_rate_type := bis_common_parameters.get_rate_type;
	g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

        if ((g_sec_currency IS NULL and g_sec_rate_type IS NOT NULL) OR
            (g_sec_currency IS NOT NULL and g_sec_rate_type IS NULL)) THEN
           RAISE G_NEED_SECONDARY_INFO;
        END IF;

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
			fii_util.write_log(
				'Failed to convert rate_type to rate_type_name' );
			raise;
	end;

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
    WHEN G_NEED_SECONDARY_INFO THEN
        g_retcode := -1;
        g_errbuf := fnd_message.get_string('FII', 'FII_AP_SEC_MISS');
        RAISE;
    WHEN OTHERS THEN
        g_retcode := -1;
        g_errbuf := '
  ---------------------------------
  Error in Procedure: INIT
           Section: '||g_section||'
           Phase: '||g_phase||'
           Message: '||sqlerrm;
    RAISE g_procedure_failure;

END Init;

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
   l_devphase VARCHAR2(500) := NULL;
   l_devstatus VARCHAR2(500) := NULL;
   l_message VARCHAR2(500) := NULL;
BEGIN
   g_state := 'Calling Procedure: VERIFY_CCID_UP_TO_DATE';
 if g_debug_flag = 'Y' then
   FII_UTIL.put_line('Calling Procedure: VERIFY_CCID_UP_TO_DATE');
   FII_UTIL.put_line('');
  end if;

   g_phase := 'Verifying if CCID Dimension is up to date';
   if g_debug_flag = 'Y' then
     FII_UTIL.put_line(g_phase);
   end if;

   IF(FII_GL_CCID_C.NEW_CCID_IN_GL) THEN
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('CCID Dimension is not up to date, calling CCID Dimension update
 program');
    end if;
      g_phase := 'Calling CCID Dimension update program';
      l_request_id := FND_REQUEST.SUBMIT_REQUEST('FII',
                                                 'FII_GL_CCID_C',
												 NULL, NULL, FALSE, 'I');
      IF (l_request_id = 0) THEN
         rollback;
         g_retcode := -1;
         raise G_NO_CHILD_PROCESS;
      END IF;

      COMMIT;

      l_result := FND_CONCURRENT.wait_for_request(l_request_id,
                                                  5,
                                                  600,
                                                  l_phase,
                                                  l_status,
                                                  l_devphase,
                                                  l_devstatus,
                                                  l_message);

      IF l_result THEN
       if g_debug_flag = 'Y' then
         FII_UTIL.put_line('CCID Dimension populated successfully');
       end if;
      ELSE
       FII_UTIL.put_line('CCID Dimension populated unsuccessfully');
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
         g_errbuf := '
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Phase: Submitting Child process to run CCID program';
         raise;
     WHEN G_CCID_FAILED THEN
         g_retcode := -1;
         g_errbuf := '
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Phase: Running CCID program';
         raise;
     WHEN OTHERS Then
         g_retcode := -1;
         g_errbuf := '
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Phase: ' || g_phase || '
Message: '||sqlerrm;
         raise;
END VERIFY_CCID_UP_TO_DATE;

---------------------------------
-- PROCEDURE INSERT_INTO_STG
---------------------------------

PROCEDURE INSERT_INTO_STG (p_parallel_query IN NUMBER,
                           p_sort_area_size IN NUMBER,
                           p_hash_area_size IN NUMBER) IS

l_stmt VARCHAR2(1000);

BEGIN

l_stmt := 'alter session set hash_area_size = '||p_hash_area_size;
execute immediate l_stmt;
l_stmt := 'alter session set sort_area_size= '|| p_sort_area_size;
execute immediate l_stmt;

g_state := 'Loading data into staging table';
if g_debug_flag = 'Y' then
fii_util.put_line(' ');
fii_util.put_line('Loading data into staging table');
fii_util.start_timer;
fii_util.put_line('');
end if;


 INSERT /*+ APPEND PARALLEL(F) */ INTO FII_AP_INV_STG F
                         (LEDGER_ID,
                          ACCOUNT_DATE,
                          INV_CURRENCY_CODE,
                          AMOUNT_T,
                          INVOICE_ID,
                          AMOUNT_B,
                          PO_MATCHED_FLAG,
                          SOURCE,
                          INV_DIST_CREATED_BY,
                          SUPPLIER_SITE_ID,
                          INV_DIST_CREATION_DATE,
                          SUPPLIER_ID,
--                        DIST_COUNT,
                          INVOICE_TYPE,
                          POSTED_FLAG,
                          FIN_CATEGORY_ID,
                          COMPANY_ID,
                          COST_CENTER_ID,
                          CHART_OF_ACCOUNTS_ID,
                          PRIM_CONVERSION_RATE,
                          SEC_CONVERSION_RATE,
                          APPROVED_FLAG,
                          ORG_ID,
                          INVOICE_DISTRIBUTION_ID,
                          DIST_CCID,
                          PO_DISTRIBUTION_ID,
                          QUANTITY_INVOICED,
                          PROJECT_ID,
                          TASK_ID,
                          EMPLOYEE_ID,
                          LINE_TYPE_LOOKUP_CODE,
                          INVOICE_NUM,
                          DISCRETIONARY_EXPENSE_FLAG,
                          TRANS_CURRENCY_CODE,
                          INVOICE_DATE,
                          DISTRIBUTION_LINE_NUMBER,
                          USER_DIM1_ID,
                          USER_DIM2_ID,
                          EXP_REPORT_HEADER_ID,
                          PO_HEADER_ID,
                          PO_RELEASE_ID,
                          PO_NUM,
                          AE_HEADER_ID,
                          REF_AE_HEADER_ID,
                          TEMP_LINE_NUM,
                          GL_SL_LINK_ID,
                          GL_SL_LINK_TABLE,
                          INVENTORY_ITEM_ID,
                          PURCHASING_CATEGORY_ID,
                          ITEM_DESCRIPTION)
 WITH ACCNT_CLASS AS (SELECT /*+ MATERIALIZE */ XAD.Ledger_ID,
                             XACA.Accounting_Class_Code
                      FROM XLA_Assignment_Defns_B XAD,
                           XLA_Acct_Class_Assgns XACA
                      WHERE XAD.Program_Code = 'PAYABLES DBI EXPENSES'
                      AND XAD.Enabled_Flag = 'Y'
                      AND XAD.Program_Code = XACA.Program_Code
                      AND XAD.Assignment_Code = XACA.Assignment_Code)
 select /*+ ORDERED no_expand use_hash(XAL,XAH,XTE,XDL,RH,AID,AI,FND,PO,AIL)
    	parallel(ai) parallel(fnd) parallel(aid) parallel(po) parallel(xah) parallel(xte) parallel(xal) parallel(xdl) parallel(ail)
    	swap_join_inputs(AC) swap_join_inputs(FND) swap_join_inputs(PO)
	pq_distribute(xah,hash,hash) pq_distribute(xte,hash,hash) pq_distribute(xal,hash,hash) pq_distribute(xdl,hash,hash)
	pq_distribute(aid,hash,hash) pq_distribute(po,hash,hash) pq_distribute(fnd,hash,hash) pq_distribute(ai,hash,hash)
	pq_distribute(ail,hash,hash)
	*/
	aid.set_of_books_id set_of_books_id,
        nvl(trunc(aid.accounting_date),trunc(aid.accounting_date)) account_date,
	v.currency_code inv_currency_code,
        NVL(XDL.Unrounded_Entered_DR, 0) - NVL(XDL.Unrounded_Entered_CR, 0) Amount_T,
	aid.invoice_id invoice_id,
        NVL(XDL.Unrounded_Accounted_DR, 0) - NVL(XDL.Unrounded_Accounted_CR, 0) Amount_B,
	nvl2(aid.po_distribution_id, 'Y', 'N') po_matched_flag,
        ai.source source,
        nvl(fnd.employee_id, -1) inv_dist_created_by,
	nvl(ai.vendor_site_id, -1) supplier_site_id,
	trunc(aid.creation_date) inv_dist_creation_date,
        ai.vendor_id supplier_id,
        ai.invoice_type_lookup_code invoice_type,
	nvl(aid.posted_flag, 'N') posted_flag,
        v.natural_account_id fin_category_id,
        v.company_id company_id,
        v.cost_center_id cost_center_id,
	v.chart_of_accounts_id chart_of_accounts_id,
        -1 prim_conversion_rate,
        -1 sec_conversion_rate,
        nvl(aid.match_status_flag, 'N') approved_flag,
        nvl(ai.org_id, -1) org_id,
	aid.invoice_distribution_id invoice_distribution_id,
        XAL.Code_Combination_ID dist_ccid,
        aid.po_distribution_id po_distribution_id,
        aid.quantity_invoiced quantity_invoiced,
	aid.project_id project_id,
        aid.task_id task_id,
        nvl(po.employee_id, ai.paid_on_behalf_employee_id) employee_id,
        aid.line_type_lookup_code line_type_lookup_code,
	ai.invoice_num invoice_num,
        CASE
           WHEN ai.invoice_type_lookup_code = 'EXPENSE REPORT'
           AND  ai.source in ('XpenseXpress', 'SelfService', 'CREDIT CARD', 'Oracle Project Accounting')
           AND  nvl(aid.match_status_flag, 'N') = 'A'
           THEN 'Y'
           WHEN ai.invoice_type_lookup_code = 'STANDARD'
           AND  ai.source = 'CREDIT CARD'
           AND  ai.PAID_ON_BEHALF_EMPLOYEE_ID is not null
           AND  nvl(aid.match_status_flag, 'N') = 'A'
           THEN 'Y'
           ELSE 'N'
        END Discretionary_Expense_Flag,
        ai.invoice_currency_code Trans_Currency_Code,
        ai.invoice_date Invoice_Date,
        aid.distribution_line_number Distribution_Line_Number,
        v.user_dim1_id,
        v.user_dim2_id,
        rh.report_header_id exp_report_header_id,
        pd.po_header_id,
        pd.po_release_id,
        ph.segment1 po_num,
        XAH.AE_Header_ID AE_Header_ID,
        XDL.Ref_AE_Header_ID Ref_AE_Header_ID,
        XDL.Temp_Line_Num Temp_Line_Num,
        XAL.GL_SL_Link_ID GL_SL_Link_ID,
        XAL.GL_SL_Link_Table GL_SL_Link_Table,
        AIL.Inventory_Item_ID Inventory_Item_ID,
        AIL.Purchasing_Category_ID Purchasing_Category_ID,
        AIL.Item_Description Item_Description
   from (select /*+ no_merge no_expand parallel(glcc) */
	       gsob.ledger_id, glcc.code_combination_id,
	       gsob.currency_code, glcc.natural_account_id,
	       glcc.company_id, glcc.cost_center_id,
	       gsob.chart_of_accounts_id, glcc.user_dim1_id,
               glcc.user_dim2_id
          from fii_source_ledger_groups fslg, fii_slg_assignments slga,
               gl_ledgers_public_v gsob, fii_gl_ccid_dimensions glcc
         where slga.chart_of_accounts_id = glcc.chart_of_accounts_id
           and slga.bal_seg_value_id in (glcc.company_id, -1)
           and slga.source_ledger_group_id = fslg.source_ledger_group_id
           and slga.ledger_id = gsob.ledger_id
           and fslg.usage_code = g_usage_code) v,
           XLA_AE_Lines XAL,
            ACCNT_CLASS AC,
        XLA_Distribution_Links XDL,
        ap_invoice_distributions_all aid,
        XLA_AE_Headers XAH,
        XLA_Transaction_Entities XTE,
   	    AP_Invoice_Lines_ALL AIL,
        ap_invoices_all ai,
        po_vendors po, --AP_SUPPLIERS PO,
        fnd_user fnd,
         (SELECT /*+ no_merge parallel(H) */
              VOUCHNO,
              CASE WHEN COUNT(*) > 1 THEN -1
                   ELSE MIN(REPORT_HEADER_ID) END REPORT_HEADER_ID
        FROM AP_EXPENSE_REPORT_HEADERS_ALL H
        WHERE ACCOUNTING_DATE >= g_start_date
        GROUP BY VOUCHNO) RH,
        po_distributions_all pd,
        po_headers_all ph
    where XAH.Entity_ID = XTE.Entity_ID
    AND   XAH.AE_Header_ID = XAL.AE_Header_ID
    AND   XAL.AE_Header_ID = XDL.AE_Header_ID
    AND   XAL.AE_Line_Num = XDL.AE_Line_Num
    AND   XAH.Ledger_ID = AID.Set_Of_Books_ID
    AND XAL.Accounting_Class_Code = AC.Accounting_Class_Code
    AND  (AC.ledger_id IS NULL  OR AID.Set_Of_Books_ID = AC.Ledger_ID)
    AND   XDL.Source_Distribution_Type IN ('AP_INV_DIST', 'AP_PMT_DIST', 'AP_PREPAY')
    AND   XDL.Source_Distribution_ID_Num_1 = AID.Invoice_Distribution_ID
    AND   AID.Invoice_ID = AIL.Invoice_ID
    AND   AID.Invoice_Line_Number = AIL.Line_Number
    and   ai.invoice_id = aid.invoice_id
    and   ai.vendor_id = po.vendor_id
    and   fnd.user_id = nvl(aid.created_by, ai.cancelled_by)
    and   aid.set_of_books_id = v.ledger_id
    and   XAL.Code_Combination_ID = v.code_combination_id
    AND   XAH.Application_ID = 200
    AND   XAH.Balance_Type_Code = 'A'
    AND   XTE.Application_ID = 200
    AND   XAL.Application_ID = 200
    AND   XDL.Application_ID = 200
    AND   XAH.Accounting_Entry_Status_Code = 'F'
    AND   XTE.Entity_Code = 'AP_INVOICES'
    and   aid.accounting_date >= g_start_date
    AND   ai.invoice_id = rh.vouchno (+)
    AND   aid.po_distribution_id = pd.po_distribution_id (+)
    AND   pd.po_header_id = ph.po_header_id (+)
    AND   xal.accounting_date >= g_start_date
    AND   ail.ACCOUNTING_DATE >= g_start_date
    AND   xah.accounting_date >= g_start_date;


if g_debug_flag = 'Y' then
fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
fii_util.stop_timer;
fii_util.print_timer('Duration');
end if;

commit;

END INSERT_INTO_STG;

------------------------------------
---- PROCEDURE INSERT_RATES
------------------------------------

PROCEDURE INSERT_RATES IS

BEGIN
g_state := 'Loading data into rates table';
if g_debug_flag = 'Y' then
fii_util.put_line(' ');
fii_util.put_line('Loading data into rates table');
fii_util.start_timer;
fii_util.put_line('');
end if;

--modified by ilavenil to handle future dated transaction.  The change is usage of least(...,sysdate)
insert into fii_ap_inv_rates_temp
(FUNCTIONAL_CURRENCY,
 TRX_DATE,
 PRIM_CONVERSION_RATE,
 SEC_CONVERSION_RATE)
select cc functional_currency,
       dt trx_date,
       decode(cc, g_prim_currency, 1, FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY (cc,least(dt,sysdate))) PRIM_CONVERSION_RATE,
       decode(cc, g_sec_currency, 1, FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(cc,least(dt,sysdate))) SEC_CONVERSION_RATE
       from (
       select /*+ no_merge */ distinct
             inv_currency_code cc,
             account_date dt
       from FII_AP_INV_STG
       );

   if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;

END INSERT_RATES;

---------------------------------------
----- PROCEDURE INSERT_INTO_SUMMARY
---------------------------------------

PROCEDURE INSERT_INTO_SUMMARY (p_parallel_query IN NUMBER) IS

l_stmt VARCHAR2(50);
seq_id  NUMBER := 0;

BEGIN
g_state := 'Loading data into base summary table';
if g_debug_flag = 'Y' then
fii_util.put_line(' ');
fii_util.put_line('Loading data into base summary table');
fii_util.start_timer;
fii_util.put_line('');
end if;

SELECT FII_AP_INV_B_S.nextval INTO seq_id FROM dual;

-- haritha.
-- Added additional columns for insertion.

INSERT   /*+ APPEND PARALLEL(F) */ INTO FII_AP_INV_B F (
                LEDGER_ID,
                ACCOUNT_DATE,
                ACCOUNT_DATE_ID,
                INV_CURRENCY_CODE,
                AMOUNT_T,
                INVOICE_ID,
                INVOICE_DISTRIBUTION_ID,
                AMOUNT_B,
                PO_MATCHED_FLAG,
                SOURCE,
                INV_DIST_CREATED_BY,
                SUPPLIER_SITE_ID,
                INV_DIST_CREATION_DATE,
                SUPPLIER_ID,
                INVOICE_TYPE,
                POSTED_FLAG,
                FIN_CATEGORY_ID,
                COMPANY_ID,
                COST_CENTER_ID,
                CHART_OF_ACCOUNTS_ID,
                DIST_CCID,
                PO_DISTRIBUTION_ID,
                QUANTITY_INVOICED,
                PROJECT_ID,
                TASK_ID,
                PRIM_AMOUNT_G,
                SEC_AMOUNT_G,
                UPDATE_SEQUENCE,
                APPROVED_FLAG,
                ORG_ID,
                LAST_UPDATE_DATE,
                LAST_UPDATED_BY,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                EMPLOYEE_ID,
                DIST_COUNT,
                LINE_TYPE_LOOKUP_CODE,
                INVOICE_NUM,
                DISCRETIONARY_EXPENSE_FLAG,
                TRANS_CURRENCY_CODE,
                INVOICE_DATE,
                DISTRIBUTION_LINE_NUMBER,
                USER_DIM1_ID,
                USER_DIM2_ID,
                EXP_REPORT_HEADER_ID,
                PO_HEADER_ID,
                PO_RELEASE_ID,
                PO_NUM,
                AE_HEADER_ID,
                REF_AE_HEADER_ID,
                TEMP_LINE_NUM,
                GL_SL_LINK_ID,
                GL_SL_LINK_TABLE,
                INVENTORY_ITEM_ID,
                PURCHASING_CATEGORY_ID,
                ITEM_DESCRIPTION)
        SELECT /*+ PARALLEL(stg) PARALLEL(rates) */
                stg.ledger_id,
                stg.account_date,
                to_number (to_char(stg.ACCOUNT_DATE, 'J')),
                stg.inv_currency_code,
                stg.amount_t amount_t,
                stg.invoice_id,
                stg.invoice_distribution_id,
                stg.amount_b amount_b,
                stg.po_matched_flag,
                stg.source,
                stg.inv_dist_created_by,
                stg.supplier_site_id,
                stg.inv_dist_creation_date,
                stg.supplier_id,
                stg.invoice_type,
                stg.posted_flag,
                stg.FIN_CATEGORY_ID,
                stg.company_id,
                stg.cost_center_id,
                stg.chart_of_accounts_id,
                stg.dist_ccid,
                stg.po_distribution_id,
                stg.quantity_invoiced,
                stg.project_id,
                stg.task_id,
                round((stg.amount_b*rates.prim_conversion_rate)/to_number(g_primary_mau))*to_number(g_primary_mau),
                round((stg.amount_b*rates.sec_conversion_rate)/to_number(g_secondary_mau))*to_number(g_secondary_mau),
                seq_id,
                stg.approved_flag,
                stg.org_id,
                sysdate,
                g_fii_user_id,
                sysdate,
                g_fii_login_id,
                g_fii_login_id,
                stg.employee_id,
                1,
                stg.LINE_TYPE_LOOKUP_CODE,
                stg.invoice_num,
                stg.discretionary_expense_flag,
                stg.trans_currency_code,
                trunc(stg.invoice_date) invoice_date,
                stg.distribution_line_number,
                stg.user_dim1_id,
                stg.user_dim2_id,
                stg.exp_report_header_id,
                stg.po_header_id,
                stg.po_release_id,
                stg.po_num,
                STG.AE_Header_ID,
                STG.Ref_AE_Header_ID,
                STG.Temp_Line_Num,
                STG.GL_SL_Link_ID,
                STG.GL_SL_Link_Table,
                STG.Inventory_Item_ID,
                STG.Purchasing_Category_ID,
                STG.Item_Description
       FROM FII_AP_INV_STG stg,  fii_ap_inv_rates_temp rates
       where stg.account_date = rates.trx_date
       and   stg.inv_currency_code = rates.functional_currency;

       if g_debug_flag = 'Y' then
         fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
       end if;

       commit;

END INSERT_INTO_SUMMARY;
-- ------------------------------------------------------------
-- Public Functions and Procedures
-- ------------------------------------------------------------

-- Procedure
--   Collect()
-- Purpose
--   This Collect routine Handles all functions involved in the AP summarization
--   and populating FII base summary table and cleaning.

-----------------------------------------------------------
--  PROCEDURE Collect
-----------------------------------------------------------
PROCEDURE Collect(Errbuf         IN OUT NOCOPY VARCHAR2,
      	          Retcode        IN OUT NOCOPY VARCHAR2,
     	          p_from_date    IN     VARCHAR2,
                  p_to_date      IN     VARCHAR2,
                  p_no_worker    IN     NUMBER,
                  p_program_type IN     VARCHAR2,
                  p_parallel_query IN   NUMBER,
                  p_hash_area_size   IN    NUMBER,
                  p_sort_area_size   IN    NUMBER
                  ) IS
    l_status        VARCHAR2(30);
    l_industry      VARCHAR2(30);
    l_stmt          VARCHAR2(4000);
    l_dir           VARCHAR2(400);
    l_start_date    DATE;
    l_end_date      DATE;
    TYPE WorkerList is table of NUMBER index by binary_integer;
    l_worker        WorkerList;

    l_global_param_list dbms_sql.varchar2_table;

    l_new_inv_id_count NUMBER;

    -- Declaring local variables to populate the start date
    -- and end date for incremental mode.
    l_last_start_date    DATE;
    l_last_end_date      DATE;
    l_last_period_from   DATE;
    l_last_period_to     DATE;
    l_lud_hours          NUMBER;

    l_rowcount           NUMBER;
    l_last_sup_merge     DATE;

    l_timestamp DATE;
BEGIN
        g_state := 'Inside the procedure COLLECT';

 	retcode := 0;

        g_program_type := p_program_type;

--	l_stmt := ' ALTER SESSION SET global_names = false';
--  	EXECUTE IMMEDIATE l_stmt;

   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------

	l_dir:=FII_UTIL.get_utl_file_dir;

   ----------------------------------------------------------------
   -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ----------------------------------------------------------------
        IF g_program_type = 'L' THEN
              FII_UTIL.initialize('FII_AP_INV_B.log','FII_AP_INV_B.out',l_dir,'FII_AP_INV_B_L');
        ELSE
              FII_UTIL.initialize('FII_AP_INV_B.log','FII_AP_INV_B.out',l_dir, 'FII_AP_INV_B_I');
        END IF;

  -------------------------------------------------------------
  -- Check if FII: DBI Payables Invoice Distributions Implementation profile
  -- is turned on.  If yes, continue, otherwise, error out.  User
  -- need to turn on this profile option before running this program
  ---------------------------------------------------------------
  IF g_exp_imp_prof_flag = 'N' THEN
      g_state := 'Checking Implementation profile option';
      FII_MESSAGE.write_log(
      msg_name    => 'FII_AP_DBI_EXP_IMP',
      token_num   => 0);
      g_retcode := -2;
      -- Following text changed for bug 6473260
      g_errbuf := 'FII: DBI Payables Invoice Distributions Implementation profile option is not turned on';
      -- End of change for bug 6473260
      RAISE G_IMP_NOT_SET;
  END IF;

   -----------------------------------------------------
   -- Calling BIS API to do common set ups
   -- If it returns false, then program should error
   -- out
   -----------------------------------------------------
   l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
   l_global_param_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
   l_global_param_list(3) := 'BIS_PRIMARY_RATE_TYPE';
   IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
       FII_UTIL.put_line(fnd_message.get_string('FII', 'FII_BAD_GLOBAL_PARA'));
       retcode := -1;
       return;
   END IF;


   -- ------------------------------------------
   -- Initalize other variables
   -- ------------------------------------------
  if g_debug_flag = 'Y' then
   FII_UTIL.put_line(' ');
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('Initialization');
  end if;
   INIT;
  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line(' ');
  end if;

	IF p_program_type = 'L' THEN
                g_state := 'Running Initial Load, truncate staging and base summary table.';
		IF g_debug_flag = 'Y' then
			FII_UTIL.put_line('Running Initial Load, truncate staging and base summary table.');
		END IF;
  		TRUNCATE_TABLE('FII_AP_INV_STG');
  		TRUNCATE_TABLE('FII_AP_INV_B');
		COMMIT;
	END IF;

   -- Load and Increment programs should record the dates seperately
   -- so that the dates are derived correctly for incremental mode.
   g_state := 'Calling BIS_COLLECTION_UTILITIES.setup';
   IF p_program_type = 'L' THEN
      IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_AP_INV_B_L')) THEN
          raise_application_error(-20000,errbuf);
          return;
      END IF;
   ELSE
      IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_AP_INV_B_I')) THEN
          raise_application_error(-20000,errbuf);
          return;
      END IF;
   END IF;

	------------------------------------------
	-- Check setups only if we are running in
	-- Incremental Mode, p_program_type = 'I'
	-------------------------------------------
	IF (p_program_type = 'I') THEN
   	---------------------------------------------
   	-- Check if any set up got changed.  If yes,
   	-- then we need to truncate the summary table
   	-- and then reload
   	---------------------------------------------
  		IF(CHECK_IF_SET_UP_CHANGE = 'TRUE') THEN
 			FII_MESSAGE.write_output(
            msg_name    => 'FII_TRUNC_SUMMARY',
            token_num   => 0);

      		FII_UTIL.put_line(fnd_message.get_string('FII', 'FII_TRUNC_SUMMARY'));
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
        g_state := 'Updating change log';
    	UPDATE fii_change_log
    	SET item_value = 'N',
		    last_update_date  = SYSDATE,
		    last_update_login = g_fii_login_id,
		    last_updated_by   = g_fii_user_id
    	WHERE log_item = 'AP_RESUMMARIZE';

    	COMMIT;
	END IF;

   g_today := sysdate;

   -- haritha
   -- For Incremental mode we no longer need to select the invoices based
   -- on the start and end date. The invoices will be selected from the log
   -- table. Hence removed the logic to populate start and end dates for the
   -- incremental mode.

   IF p_program_type = 'L' THEN

      -------------------------------------------------------------
      -- When running in Initial mode, the default values of the
      -- parameters are defined in the concurrent program seed data
      -- We will always collect up to sysdate to make sure no records
      -- are missed from the collection
      -------------------------------------------------------------
      l_start_date := trunc(to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS'));
      l_end_date   := sysdate + 1 - ONE_SECOND;

      g_start_date := l_start_date;
      g_end_date := l_end_date;

   END IF;
  if g_debug_flag = 'Y' then
   FII_UTIL.put_line(' ');
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line('The date range of collection is from ' || to_char(g_start_date, 'MM/DD/YYYY HH24:MI:SS') || '.');
   FII_UTIL.put_line('-------------------------------------------------');
   FII_UTIL.put_line(' ');
  end if;

  --Calling CHECK_XLA_CONVERSION_STATUS==Bug 5437394

  CHECK_XLA_CONVERSION_STATUS(l_start_date);



	--------------------------------------------------------------------
   -- Checking to see if there's any record in the staging table.
   -- If yes, then that means the previous load failed due to missing
   -- exchange rates.  In this case, we run in resume mode.
   -- If no, then program will insert records into staging table
   --------------------------------------------------------------------
   BEGIN
     SELECT 1 INTO g_num FROM fii_ap_inv_stg where rownum = 1;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN g_num := 0;
   END;

   IF (g_num > 0) THEN
        g_fix_rates := 'Y';
   ELSE
        g_fix_rates := 'N';
   END IF;

   ---------------------------------------------------
   -- If not running in resume mode, then insert new
   -- records into staging table
   -- If running in resume mode, then fix the exchange
   -- rates in the staging table, then verify once
   -- again if there are missing exchange rates
   ---------------------------------------------------
	IF (g_fix_rates = 'N') THEN

      ----------------------------------------------------------
      -- This variable indicates that if exception occur, do
      -- we need to truncate the staging table.
      -- We are about to submit the child process which will
      -- insert records into staging table.  If any exception
      -- occured during the child process run, the staging table
      -- should be truncated.  After all child process are done
      -- inserting records into staging table, this flag will
      -- be set to 'N'.
      ----------------------------------------------------------
      g_truncate_staging := 'Y';

      ----------------------------------------------------------
      -- This variable indicates that if exception occur, do
      -- we need to truncate the temporary Revenue_ID table.
      -- We need to truncate this table if the program starts
      -- fresh at the beginning.
      -- We will reset this variable to 'N' after we have
      -- populate it.  We will not truncate it until next time
      -- when the program starts fresh (non-resume).  We want
      -- to preserve this table for debugging purpose.
      ----------------------------------------------------------
      g_truncate_id := 'Y';

      g_truncate_rates := 'Y';

		----------------------------------------------------------
      -- Call CLEAN_UP to clean up processing tables before
      -- start
      ----------------------------------------------------------
		CLEAN_UP;

      ---------------------------------------------------------
      -- After we do initial clean up, we will set this flag to
      -- 'N' to preserve the temporary Revenue ID table for
      -- debugging purpose
      ---------------------------------------------------------
      g_truncate_id := 'N';

      -------------------------------------------------
      -- For Incremental Load, Populate Invoice IDs of the qualified invoices
      -- into an Invoice ID temp table
      -------------------------------------------------
      IF g_program_type = 'I' THEN

               if g_debug_flag = 'Y' then
                   FII_UTIL.put_line('Populating Invoice ID table');
   	           FII_UTIL.start_timer;
   	       end if;
               l_new_inv_id_count :=  POPULATE_INV_ID_TEMP;
               if g_debug_flag = 'Y' then
                   FII_UTIL.stop_timer;
                   FII_UTIL.print_timer('Duration');
               end if;

      END IF;
      ----------------------------------------------------------------
      -- After the new invoices are identified, we need to call the
      -- CCID API to make sure that the CCID dimension is up to date.
      -- The reason we call this API after we have identified the
      -- new invoices instead of calling this API at the beginning of
      -- the programs is because that it is possible that after we
      -- called the API, new CCIDs can be created, and
      -- then we will pull this new invoice in the POPULATE_INV_ID_TEMP
      -- If CCID dimension is not up to date, VERIFY_CCID_UP_TO_DATE
      -- will also call the CCID Dimension load program to update
      -- CCID dimension.
      ----------------------------------------------------------------
      g_phase := 'Verifying if CCID Dimension is up to date';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line(g_phase);
      end if;

      VERIFY_CCID_UP_TO_DATE;

  IF p_program_type = 'L' THEN
                g_phase := 'Bypassing SLA security.';
                if g_debug_flag = 'Y' then
                  FII_UTIL.put_line(g_phase);
                end if;

                xla_security_pkg.set_security_context(p_application_id => 602);

		INSERT_INTO_STG (p_parallel_query, p_sort_area_size, p_hash_area_size);
  		INSERT_RATES;

                FND_STATS.GATHER_TABLE_STATS(OWNNAME => 'FII', TABNAME => 'FII_AP_INV_STG', PERCENT=> 5);

  ELSE

      --------------------------------------------
      -- Register  jobs
      --------------------------------------------
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line(' ');
        FII_UTIL.put_line('Populating Jobs Table');
        FII_UTIL.put_timestamp;
      end if;
      l_new_inv_id_count := REGISTER_JOBS;
      COMMIT;

      --------------------------------------------------------
      -- REGISTER_JOBS will return -1 if there are no new
      -- records to process, else 1. If there are no new
      -- records to process the program will exit immediately
      -- with complete successful status.
      --------------------------------------------------------
      IF (l_new_inv_id_count = 0) THEN

        if g_debug_flag = 'Y' then
          FII_UTIL.put_line('No Records to Process, exit.');
        end if;

         ----------------------------------------------------------------
         -- Calling BIS API to record the range we collect.  Only do this
         -- when we have a successful collection
         ----------------------------------------------------------------
         BIS_COLLECTION_UTILITIES.wrapup(
           p_status => TRUE,
           p_period_from => g_start_date,
           p_period_to => g_end_date);
         g_retcode := 0;
         RETURN;
       END IF;

	   --------------------------------------------------------
	   -- Launch worker
	   --------------------------------------------------------
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('Launching Workers');
    end if;
      FOR i IN 1..p_no_worker
      LOOP /* p_no_worker is the parameter user submitted
            to specify how many workers they want to
            submit */
           l_worker(i) := LAUNCH_WORKER(i);
           if g_debug_flag = 'Y' then
             FII_UTIL.put_line('  Worker '||i||' request id: '||l_worker(i));
           end if;
      END LOOP;

      COMMIT;

      --------------------------------------------
      -- Monitor workers
      -- ------------------------------------------
      g_state := 'Monitoring workers';
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
        BEGIN  LOOP

            SELECT nvl(sum(decode(status,'UNASSIGNED',1,0)),0),
            nvl(sum(decode(status,'COMPLETED',1,0)),0),
            nvl(sum(decode(status,'IN PROCESS',1,0)),0),
            nvl(sum(decode(status,'FAILED',1,0)),0),
            count(*)
            INTO l_unassigned_cnt,
            l_completed_cnt,
            l_wip_cnt,
            l_failed_cnt,
            l_tot_cnt
            FROM   FII_AP_SUM_WORK_JOBS;

          if g_debug_flag = 'Y' then
            FII_UTIL.put_line('Job status - Unassigned:'||l_unassigned_cnt||
           ' In Process:'||l_wip_cnt||
           ' Completed:'||l_completed_cnt||
           ' Failed:'||l_failed_cnt);
          end if;

            IF (l_failed_cnt > 0) THEN
                g_retcode := -2;
                g_errbuf := ' Error in Main Procedure: Message: At least one of the workers have errored out';
                RAISE g_procedure_failure;

            END IF;

            ----------------------------------------------
            -- IF the number of complete count equals to
            -- the total count, then that means all workers
            -- have completed.  Then we can exit the loop
            ----------------------------------------------
            IF (l_tot_cnt = l_completed_cnt) THEN
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
                g_errbuf := ' Error in Main Procedure: Message: No progress have been made for '||MAX_LOOP||' minutes. Terminating.';

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
        END;

        END IF;

   ----------------------------------------------
   -- Else, we are running in resume mode
   ----------------------------------------------
	ELSE

       ----------------------------------------------------------
       -- This variable indicates that if exception occur, do
       -- we need to truncate the staging table.
       -- When running in resume mode, we do not want to truncate
       -- staging table
       ----------------------------------------------------------
       g_truncate_staging := 'N';

       g_state := 'Updating records with missing primary rates in FII_AP_INV_STG table';
       if g_debug_flag = 'Y' then
        FII_UTIL.put_line('');
        FII_UTIL.put_line('---------------------------------------------------------------------');
        FII_UTIL.put_line('Updating records with missing primary rates in FII_AP_INV_STG table ');
        FII_UTIL.start_timer;
       end if;

--modified by ilavenil to handle future dated transaction.  The change is usage of least(...,sysdate)
        UPDATE FII_AP_INV_STG stg
        SET stg.PRIM_CONVERSION_RATE = DECODE(stg.inv_currency_code, g_prim_currency, 1,
                                              fii_currency.get_global_rate_primary(stg.inv_currency_code,
                                              least(stg.account_date,sysdate)))
        WHERE stg.PRIM_CONVERSION_RATE < 0;

       l_rowcount := SQL%ROWCOUNT;
       if g_debug_flag = 'Y' then
        FII_UTIL.put_line('');
        FII_UTIL.put_line('Updated ' || l_rowcount || ' records for primary conversion rate');
        FII_UTIL.stop_timer;
        FII_UTIL.print_timer('Duration');

        FII_UTIL.put_line('');
        FII_UTIL.put_line('---------------------------------------------------------------------');
        FII_UTIL.put_line('Updating records with missing secondary rates in FII_AP_INV_STG table ');
        FII_UTIL.start_timer;
       end if;
       g_state := 'Updating records with missing secondary rates in FII_AP_INV_STG table ';

--modified by ilavenil to handle future dated transaction.  The change is usage of least(...,sysdate)
        UPDATE FII_AP_INV_STG stg
        SET stg.SEC_CONVERSION_RATE = decode(stg.inv_currency_code, g_sec_currency, 1,
                                             fii_currency.get_global_rate_secondary(stg.inv_currency_code,
                                                                                   least( stg.account_date,sysdate)))
        WHERE stg.SEC_CONVERSION_RATE < 0;

      l_rowcount := SQL%ROWCOUNT;
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('');
        FII_UTIL.put_line('Updated ' || l_rowcount || ' records for secondary conversion rate');
        FII_UTIL.stop_timer;
        FII_UTIL.print_timer('Duration');
      end if;

        COMMIT;

   END IF;  /* IF (g_fix_rates = 'N') */

   -----------------------------------------------------------------------
   -- Checking to see if the missing rate records exists in the staging
   -- table.  If yes, program will exit with warning status.  All records
   -- would remain in staging table, no records would be loaded into
   -- summary table.
   -- If no, then all records will be loaded into summary table
   -----------------------------------------------------------------------

	IF (VERIFY_MISSING_RATES(p_program_type) = -1) THEN
      ----------------------------------------------------------
      -- This variable indicates that if exception occur, do
      -- we need to truncate the staging table.
      -- If we reach this stage, that means all the child worker
      -- has completed inserting all records into staging table
      -- any exception occuring from now do not require staging
      -- table to be truncated
      ----------------------------------------------------------
                g_truncate_staging := 'N';

		CLEAN_UP;

                g_retcode := -1;
                Retcode := g_retcode;

                g_state := 'Verifying Missing Rates';
                g_errbuf := fnd_message.get_string('FII', 'FII_MISS_EXCH_RATE_FOUND');
                RAISE G_MISSING_RATES;

   -----------------------------------------------------------------------
   -- If there are no missing exchange rate records, then we will insert
   -- records from the staging table into the summary table
   -----------------------------------------------------------------------
	ELSE
      if g_debug_flag = 'Y' then
			FII_UTIL.start_timer;
	   end if;

      IF p_program_type = 'L' THEN --Initial Load
         INSERT_INTO_SUMMARY(p_parallel_query);
      ELSE --Incremental Load

         POPULATE_AP_BASE_SUM;

         --Need to handle supplier/supplier site merge during incremental.
         g_state := 'Retrieving last supplier or supplier site merge.';
         SELECT MAX(Last_Update_Date) INTO l_last_sup_merge
         FROM AP_Duplicate_Vendors_All
         WHERE Process_Flag = 'Y';

         BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_B_L', l_last_start_date,
                                                      l_last_end_date, l_last_period_from,
                                                      l_last_period_to);
         l_timestamp := nvl(l_last_start_date, bis_common_parameters.get_global_start_date);

         BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_B_I', l_last_start_date,
                                                      l_last_end_date, l_last_period_from,
                                                      l_last_period_to);
         l_timestamp := greatest(l_timestamp, nvl(l_last_start_date, bis_common_parameters.get_global_start_date));

         IF trunc(l_last_sup_merge) >= trunc(l_timestamp) THEN
           g_state := 'Updating Supplier_ID and Supplier_Site_ID from AP_Duplicate_Vendors_All.';

           UPDATE FII_AP_Inv_B BSUM
           SET (Supplier_ID, Supplier_Site_ID) =
               (SELECT Vendor_ID, NVL(Vendor_Site_ID, Duplicate_Vendor_Site_ID)
                FROM AP_Duplicate_Vendors_All DV1
                WHERE DV1.Duplicate_Vendor_ID = BSUM.Supplier_ID
                AND DV1.Duplicate_Vendor_Site_ID = BSUM.Supplier_Site_ID
                AND DV1.Process_Flag = 'Y'
                AND TRUNC(DV1.Last_Update_Date) >= TRUNC(l_timestamp))
           WHERE (Supplier_ID, Supplier_Site_ID) IN
                 (SELECT Duplicate_Vendor_ID, Duplicate_Vendor_Site_ID
                  FROM AP_Duplicate_Vendors_All DV2
                  WHERE DV2.Process_Flag = 'Y'
                  AND TRUNC(DV2.Last_Update_Date) >= TRUNC(l_timestamp));


         END IF;

      END IF;

      if g_debug_flag = 'Y' then
	     FII_UTIL.stop_timer;
	   end if;

      -------------------------------------------------------------------
      -- After we have merged the records from the staging table into the
      -- base summary table, we can clean up the staging table when we
      -- call the CLEAN_UP procedure
      -------------------------------------------------------------------
      g_truncate_staging := 'Y';


	   CLEAN_UP;

      ----------------------------------------------------------------
      -- Calling BIS API to record the range we collect.  Only do this
      -- when we have a successful collection
      ----------------------------------------------------------------
      g_state := 'Calling BIS_COLLECTION_UTILITIES.wrapup';
      BIS_COLLECTION_UTILITIES.wrapup(
                     p_status => TRUE,
                     p_period_from => g_start_date,
                     p_period_to => g_end_date);

      g_retcode := 0;

	END IF; /* IF (VERIFY_MISSING_RATES = -1) */

      if g_debug_flag = 'Y' then
	FII_UTIL.put_line('return code is ' || retcode);
      end if;

	Retcode := g_retcode;

--if XLA check failed, exit job with warning so that user will look into log files
--Bug 5437394
  IF  (g_xla_ret_code is not null) THEN
  		Retcode := 1;
  END IF;

EXCEPTION
    WHEN G_IMP_NOT_SET THEN
      retcode:=g_retcode;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);

    WHEN G_MISSING_RATES THEN
      retcode := g_retcode;
      g_exception_msg := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);

    WHEN OTHERS THEN
      g_errbuf:=g_errbuf;
      g_retcode:= -1;
      retcode:=g_retcode;
      g_exception_msg  := g_retcode || ':' || g_errbuf;
      FII_UTIL.put_line('Error occured while ' || g_state);
      FII_UTIL.put_line(g_exception_msg);

	   ---------------------------------------------------------------
      -- Truncating the staging table so the next time the program
      -- is ran, the program will start from beginning.  If we leave
      -- records in staging table, this program would run in resume
      -- mode.  We purposely don't want to truncate FII_AP_INV_ID
      -- because we can use it for debugging purpose if the program
      -- error out.  FII_AP_INV_ID always gets truncated at the start
      -- of the program.
      ---------------------------------------------------------------
		Truncate_table('FII_AP_INV_STG');

		Truncate_table('FII_AP_SUM_WORK_JOBS');

      ----------------------------------------------------------------
      -- When exception occurs, we need to restore the AP_DBI_LOG table
      -- to its original state by setting those records back to 'N'.
      -- THose records will be re-processed in the next run.
      -----------------------------------------------------------------
      FII_UTIL.put_line('Restoring AP_DBI_LOG table to its original state');

      IF p_program_type = 'L' THEN
         UPDATE ap_dbi_log log
         SET exp_processed_flag = 'N'
         WHERE exp_processed_flag = 'Y';
      ELSE
         UPDATE ap_dbi_log
         SET exp_processed_flag = 'N'
         WHERE exp_processed_flag = 'S';
      END IF;
      COMMIT;


      RAISE;
END Collect;

--------------------------------------------------
-- PROCEDURE WORKER
---------------------------------------------------
PROCEDURE WORKER(
      Errbuf      IN OUT NOCOPY VARCHAR2,
      Retcode     IN OUT NOCOPY VARCHAR2,
      p_worker_no IN NUMBER) IS

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------
    l_unassigned_cnt    NUMBER := 0;
    l_failed_cnt     NUMBER := 0;
    l_curr_unasgn_cnt   NUMBER := 0;
    l_curr_comp_cnt        NUMBER := 0;
    l_curr_tot_cnt         NUMBER := 0;
    l_count    NUMBER;
    l_start_range NUMBER;
    l_end_range NUMBER;
    l_phase NUMBER;
    l_last_start_date DATE;
    l_last_end_date DATE;
    l_last_period_from DATE;
    l_last_period_to DATE;
BEGIN
    Errbuf :=NULL;
    Retcode:=0;

  -- -----------------------------------------------
  -- Set up directory structure for child process
  -- because child process do not call setup routine
  -- from EDWCORE
  -- -----------------------------------------------
    CHILD_SETUP('FII_AP_INV_B_C_SUBWORKER'||p_worker_no);

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AP_INV_B_L', l_last_start_date,
                                                      l_last_end_date, l_last_period_from,
                                                      l_last_period_to);
    g_start_date := nvl(l_last_period_from, bis_common_parameters.get_global_start_date);


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

  --g_worker_num := p_worker_no;

  -- ------------------------------------------
  -- Loop thru job list
  -- -----------------------------------------
    g_state := 'Loop thru job list';
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
        	FROM   FII_AP_SUM_WORK_JOBS;

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
    		ELSIF (l_curr_comp_cnt = l_curr_tot_cnt) THEN
    		if g_debug_flag = 'Y' then
      		FII_UTIL.put_line('');
      		FII_UTIL.put_line('All jobs completed, no more job.  Terminating');
      		end if;
      		EXIT;
    		ELSIF (l_curr_unasgn_cnt > 0) THEN
      		UPDATE FII_AP_SUM_WORK_JOBS
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
      IF (l_count > 0) THEN
      	BEGIN
        		SELECT start_range, end_range, phase_id
        		INTO l_start_range, l_end_range, l_phase
        		FROM FII_AP_SUM_WORK_JOBS jobs
        		WHERE jobs.worker_number = p_worker_no
        		AND   jobs.status = 'IN PROCESS';

                        g_phase := 'Bypassing SLA security.';
                        if g_debug_flag = 'Y' then
                          FII_UTIL.put_line(g_phase);
                        end if;

                        xla_security_pkg.set_security_context(p_application_id => 602);

                        ---------------------------------------------------------
                        --Do summarization using the start_range and end_range
                        ---------------------------------------------------------
         	        if g_debug_flag = 'Y' then
        		  FII_UTIL.start_timer;
                        end if;
        		POPULATE_AP_SUM_STG (l_start_range,  l_end_range, l_phase);
        		if g_debug_flag = 'Y' then
        		  FII_UTIL.stop_timer;
                          FII_UTIL.print_timer('Duration');
                        end if;

     			UPDATE FII_AP_SUM_WORK_JOBS jobs
     			SET    jobs.status = 'COMPLETED'
     			WHERE  jobs.status = 'IN PROCESS'
     			AND    jobs.worker_number = p_worker_no;

				COMMIT;

      	EXCEPTION
        		WHEN OTHERS THEN
        			g_retcode := -1;

				UPDATE FII_AP_SUM_WORK_JOBS
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
---------------------------------
Error in Procedure: WORKER
Message: '||sqlerrm;
        FII_UTIL.put_line(Errbuf);

        -------------------------------------------
        -- Update the WORKER_JOBS table to indicate
        -- this job has failed
        -------------------------------------------
            UPDATE FII_AP_SUM_WORK_JOBS
            SET  status = 'FAILED'
            WHERE  worker_number = p_worker_no
            AND   status = 'IN PROCESS';

			COMMIT;


END WORKER;
END FII_AP_INV_B_C;

/
