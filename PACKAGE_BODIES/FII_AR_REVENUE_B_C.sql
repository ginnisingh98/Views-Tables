--------------------------------------------------------
--  DDL for Package Body FII_AR_REVENUE_B_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_AR_REVENUE_B_C" AS
/* $Header: FIIAR18B.pls 120.96 2007/03/21 19:45:38 juding ship $ */

 g_errbuf               VARCHAR2(2000) := NULL;
 g_retcode              VARCHAR2(20) := NULL;
 g_section              VARCHAR2(20) := NULL;
 g_sob_id               NUMBER := NULL;
 g_gl_from_date         DATE;
 g_gl_to_date           DATE;
 g_lud_from_date        DATE := NULL;
 g_lud_to_date          DATE := NULL;
 g_ccid_not_prepared    BOOLEAN := TRUE;
 g_fii_schema           VARCHAR2(30);
 g_tablespace           VARCHAR2(30);
 g_instance_code        VARCHAR2(30);
 g_mau_prim             NUMBER;
 g_mau_sec              NUMBER;
 g_worker_num           NUMBER;
 g_resume_flag          varchar2(1);
 g_rev_acct_changed     BOOLEAN;
 g_truncate_staging     varchar2(1) := 'N';
 g_truncate_id          varchar2(1) := 'N';
 g_fii_user_id          NUMBER(15);
 g_fii_login_id         NUMBER(15);
 g_debug_flag           VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
 g_global_start_date    DATE := NULL;
 -- haritha
 g_program_type         VARCHAR2(1);

 ONE_SECOND    CONSTANT NUMBER := 0.000011574;  -- 1 second
 INTERVAL      CONSTANT NUMBER := 10;            -- 10 days
 MAX_LOOP      CONSTANT NUMBER := 180;          -- 180 loops = 180 minutes
 LAST_PHASE    CONSTANT NUMBER := 4;

 G_TABLE_NOT_EXIST      EXCEPTION;
 G_PROCEDURE_FAILURE    EXCEPTION;
 G_NO_CHILD_PROCESS     EXCEPTION;
 G_CCID_FAILED          EXCEPTION;
 PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
 G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;

 g_usage_code CONSTANT VARCHAR2(10) := 'DBI';
 g_table_name          VARCHAR2(50) := 'FII_AR_REVENUE_B';

 g_program_code_R  CONSTANT VARCHAR2(30) := 'RECEIVABLES REVENUE';
 g_program_code_DR CONSTANT VARCHAR2(30) := 'RECEIVABLES DEF REVENUE';

 g_non_upgraded_ledgers  BOOLEAN := FALSE;

-- ---------------------------------
-- PRIVATE PROCEDURES AND FUNCTIONS
-- ---------------------------------

-- ---------------------------------------------------------------
-- PROCEDURE CHECK_XLA_CONVERSION_STATUS
-- ---------------------------------------------------------------
PROCEDURE CHECK_XLA_CONVERSION_STATUS IS
/*
    -- FA
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

    -- AP
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
*/
    -- AR
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
               AND fslg.usage_code             = g_usage_code) fset
     WHERE s.ledger_id        = fset.ledger_id
       AND ps.application_id  = 222
       AND ps.set_of_books_id = fset.ledger_id
       AND ps.end_date       >= g_global_Start_Date
       AND ps.migration_status_code <> 'U';

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
         v1         => 'Receivables',
         t2         => 'LEDGER',
         v2         => ledger_record.name,
         t3         => 'START_DATE',
         v3         => g_global_Start_Date);

   END LOOP;

EXCEPTION

  WHEN OTHERS THEN

  g_retcode := -1;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: CHECK_XLA_CONVERSION_STATUS
           Message: '||sqlerrm;
  FII_UTIL.put_line(g_errbuf);
  raise g_procedure_failure;

END CHECK_XLA_CONVERSION_STATUS;

---------------------------------------------------
-- PROCEDURE DROP_TABLE
---------------------------------------------------
PROCEDURE drop_table (p_table_name IN VARCHAR2) IS
  l_stmt VARCHAR2(400);

BEGIN

  l_stmt:='DROP TABLE '||g_fii_schema||'.'|| p_table_name;

 if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Dropping temp table '||p_table_name);
  fii_util.put_line(l_stmt);
 end if;

  EXECUTE IMMEDIATE l_stmt;

EXCEPTION

 WHEN g_table_not_exist THEN
    NULL;      -- Oracle 942, table does not exist, no actions

 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: DROP_TABLE
           Message: ' || sqlerrm;
  RAISE g_procedure_failure;

END drop_table;


---------------------------------------------------
-- PROCEDURE TRUNCATE_TABLE
---------------------------------------------------
PROCEDURE truncate_table (p_table_name IN VARCHAR2,
                          p_partition  IN VARCHAR2 DEFAULT 'ALL') IS
  l_stmt VARCHAR2(400);

BEGIN
-- DEBUG
-- return;
  IF (p_partition = 'ALL') THEN
    l_stmt := 'truncate table '||g_fii_schema||'.'||p_table_name;
  ELSE
    l_stmt := 'alter table '||g_fii_schema||'.'||p_table_name||
              ' truncate partition '||p_partition;
  END IF;

 if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_line(l_stmt);
 end if;
  execute immediate l_stmt;

EXCEPTION

 WHEN g_table_not_exist THEN
  NULL;      -- Oracle 942, table does not exist, no actions

 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: TRUNCATE_TABLE
           Message: '||sqlerrm;
  raise g_procedure_failure;
END truncate_table;

-----------------------------------------------------------------------
-- PROCEDURE CLEAN_UP
-----------------------------------------------------------------------
PROCEDURE Clean_Up IS


BEGIN
-- DEBUG
-- return;
  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('Running procedure CLEAN_UP');
    FII_UTIL.put_line('');
--  FII_UTIL.put_line('Truncating table FII_AR_REVENUE_JOBS');
  end if;
   truncate_table('fii_ar_revenue_jobs');

   IF (g_truncate_id = 'Y') THEN
 --          if g_debug_flag = 'Y' then
--      FII_UTIL.put_line('Truncating table FII_AR_REVENUE_ID');
--      end if;
      truncate_table('fii_ar_revenue_id');
   END IF;

   IF (g_truncate_staging = 'Y') THEN
--    if g_debug_flag = 'Y' then
--      FII_UTIL.put_line('Truncating table FII_AR_REVENUE_STG');
--    end if;
    truncate_table('fii_ar_revenue_stg');

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


------------------------------------------------------
-- PROCEDURE Init
------------------------------------------------------
PROCEDURE Init IS
  l_status      VARCHAR2(30);
  l_industry    VARCHAR2(30);
  l_stmt        VARCHAR2(50);
BEGIN

   -----------------------------------------------
   -- Do the necessary setups for logging and output
   -----------------------------------------------
   g_section := 'Section 20';

  -- --------------------------------------------------------
  -- Find the schema owner and tablespace
  -- FII_AR_REVENUE_B is using
  -- --------------------------------------------------------
  g_section := 'Section 30';
  IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
  THEN NULL;
  END IF;

  g_section := 'Section 40';
  -- Bug 4942753: Changed to select from dba_tables instead of all_tables
  SELECT tablespace_name
  INTO   g_tablespace
  FROM   dba_tables
  WHERE  table_name = g_table_name
  AND    owner = g_fii_schema;

  g_section := 'Section 50';
  ------------------------------------------------------
  -- get minimum accountable unit of the global currency
  ------------------------------------------------------
  g_mau_prim := NVL(FII_CURRENCY.GET_MAU_PRIMARY, 0.01 );
  g_mau_sec := NVL(FII_CURRENCY.GET_MAU_SECONDARY, 0.01 );

  g_section := 'Section 60';

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
        FII_UTIL.put_line('Procedure INIT. Can not get User ID and/or Login ID, therefore program terminated.');
        g_retcode := -1;
    RAISE;

  WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: INIT
           Section: '||g_section||'
           Message: '||sqlerrm;
  raise g_procedure_failure;

END Init;

-----------------------------------------------------------
-- PROCEDURE UNIQUE_CONST_RECORDS
-- this procedure creates temp table fii_ar_uni_con_rec to stores
--  the records  which violate the
-- unique constraint condition on FII_AR_REVENUE_B.
-- The records in the table fii_ar_uni_con_rec may be investigated
-- to identify the reason for unique const violation.
-- The temp table fii_ar_uni_con_rec is dropped at the begining
-- of the subsequent Load / Update programs.
-----------------------------------------------------------

PROCEDURE UNIQUE_CONST_RECORDS IS
  l_stmt VARCHAR2(400);
  l_count  NUMBER;


BEGIN


 l_stmt:='
    CREATE TABLE fii_ar_uni_con_rec
    NOLOGGING storage (initial 4K next 16K MAXEXTENTS UNLIMITED) as
      SELECT * FROM FII_AR_REVENUE_STG b
       WHERE b.revenue_pk in
      (SELECT b2.revenue_pk FROM FII_AR_REVENUE_STG b2
                    GROUP BY b2.revenue_pk
                    HAVING count(*)>1) ';

  fii_util.put_line('');
  fii_util.put_line('There are duplicate records in the staging table.
This needs to be fixed before inserting records in FII_AR_REVENUE_B.
Created temp table fii_ar_uni_con_rec which stores
records that violate unique constraint on FII_AR_REVENUE_B. Please investigate
this table for duplicate records.');
  fii_util.put_line('');

  if g_debug_flag = 'Y' then
  fii_util.put_line(l_stmt);
  fii_util.start_timer;
  end if;

  EXECUTE IMMEDIATE l_stmt;

  if g_debug_flag = 'Y' then
  fii_util.put_line(' Processed '||SQL%ROWCOUNT||' rows');
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
  end if;

COMMIT;


EXCEPTION

 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: UNIQUE_CONST_RECORDS
           Message: ' || sqlerrm;
  RAISE g_procedure_failure;

END UNIQUE_CONST_RECORDS;

-----------------------------------------------------------
-- FUNCTION POPULATE_STG
-- inserting records into staging table
-----------------------------------------------------------
FUNCTION POPULATE_STG (
        p_view_type_id NUMBER,
        p_job_num      NUMBER) RETURN NUMBER IS
        l_stmt         VARCHAR2(2000);
          l_row_count    NUMBER;
          v_date         DATE;
          v_date1        DATE;

BEGIN

if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.start_timer;
 end if;


  IF (p_view_type_id = 4) THEN

  INSERT INTO  FII_AR_REVENUE_STG (
    REVENUE_PK,
    GL_DATE_ID,
    GL_DATE,
    INVENTORY_ITEM_ID,
    OPERATING_UNIT_ID,
    COMPANY_ID,
    COST_CENTER_ID,
    INVOICE_NUMBER,
    INVOICE_DATE,
    ORDER_LINE_ID,
    BILL_TO_PARTY_ID,
    FUNCTIONAL_CURRENCY,
    TRANSACTION_CURRENCY,
    LEDGER_ID,
    INVOICE_ID,
    AMOUNT_T,
    AMOUNT_B,
    EXCHANGE_DATE,
    TOP_MODEL_ITEM_ID,
    ORGANIZATION_ID,
    item_organization_id,
    om_product_revenue_flag,
    TRANSACTION_CLASS,
    FIN_CATEGORY_ID,
    INVOICE_LINE_ID,
    SALES_CHANNEL,
    ORDER_NUMBER,
    POSTED_FLAG,
    PRIM_CONVERSION_RATE,
    SEC_CONVERSION_RATE,
    PROD_CATEGORY_ID,
    CHART_OF_ACCOUNTS_ID,
    FIN_CAT_TYPE_CODE,
    REV_BOOKED_DATE,
    CHILD_ORDER_LINE_ID)
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   g_program_code_R,  'R',
                                   g_program_code_DR, 'DR',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code in (g_program_code_R,
                                                g_program_code_DR)
                     AND XAD.Enabled_Flag = 'Y'
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
  SELECT /*+ NO_EXPAND */
     DISTINCT
     'AR-'||ctl.customer_trx_line_id||'-'||
         to_char(trunc(aeh.accounting_date),'YYYY/MM/DD')||'-'||
         ael.code_combination_id                                       REVENUE_PK,
     to_number(to_char(trunc(aeh.accounting_date),'J'))                       GL_DATE_ID,
--Bug 3455965: use TRUNC for date
     TRUNC(aeh.accounting_date)                                        GL_DATE,
--     ctl_parent.inventory_item_id                                      INVENTORY_ITEM_ID,
     CASE
             when  (ctl_parent.line_type like  'LINE'
                       and  ctl_parent.inventory_item_id = sl_child.inventory_item_id
                       and  sl_child.ship_from_org_id   IS NOT NULL )
                       THEN  ctl_parent.inventory_item_id
             when  (ctl_parent.line_type like  'LINE'  and ctl_parent.WAREHOUSE_ID  IS NOT NULL)
                        THEN  ctl_parent.inventory_item_id
          ELSE
              to_number(NULL)

     END                                                                 INVENTORY_ITEM_ID,
     ct.org_id                                                      OPERATING_UNIT_ID,
     ccdim.company_id COMPANY_ID,
     ccdim.cost_center_id COST_CENTER_ID,
     substrb(ct.trx_number,1,30)                                       INVOICE_NUMBER,
     trunc(ct.trx_date)                                                INVOICE_DATE,
     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_parent.line_id,
           'INTERCOMPANY', sl_parent.line_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                ORDER_LINE_ID,
     bill_acct.party_id                                                BILL_TO_PARTY_ID,
     sob.currency_code                                                 FUNCTIONAL_CURRENCY,
     nvl(ct.invoice_currency_code,sob.currency_code)                   TRANSACTION_CURRENCY,
     ct.set_of_books_id                                             SET_OF_BOOKS_ID,
     ct.customer_trx_id                                                INVOICE_ID,
     sum( NVL(lnk.unrounded_entered_cr,0) -
          NVL(lnk.unrounded_entered_dr,0) )                            AMOUNT_T,
     sum( NVL(lnk.unrounded_accounted_cr,0) -
          NVL(lnk.unrounded_accounted_dr,0) )                          AMOUNT_B,
     trunc(aeh.accounting_date)                                        EXCHANGE_DATE,
/*     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_parent.inventory_item_id,
           'INTERCOMPANY', sl_parent.inventory_item_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                TOP_MODEL_ITEM_ID,
     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_parent.ship_from_org_id,
           'INTERCOMPANY', sl_parent.ship_from_org_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                ORGANIZATION_ID,
     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_child.ship_from_org_id,
           'INTERCOMPANY', sl_child.ship_from_org_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                item_organization_id, */
    CASE
           when ( ctl_parent.line_type like  'LINE'
                    and  ctl_parent.inventory_item_id = sl_child.inventory_item_id
                    and  sl_parent.ship_from_org_id IS NOT NULL)
                    THEN   sl_parent.inventory_item_id
            ELSE
                to_number(NULL)
    END                                                                  TOP_MODEL_ITEM_ID,
    DECODE(ctl_parent.line_type, 'LINE',
             DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                      sl_parent.ship_from_org_id, to_number(null)),
                to_number(NULL) )                                      ORGANIZATION_ID,
     DECODE(ctl_parent.line_type, 'LINE',
             DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                      sl_child.ship_from_org_id, ctl_parent.WAREHOUSE_ID ),
       to_number(NULL))                                                item_organization_id,
     decode(ctl_parent.interface_line_context, 'ORDER ENTRY',
       decode(nvl( sl_child.item_type_code, 'X' ), 'SERVICE',
       'N', 'Y'),
     'N')                                                              om_product_revenue_flag,
     decode(ctt.type,'GUAR','GUR',substrb(ctt.type,1,3))               TRANSACTION_CLASS,
     ccdim.natural_account_id FIN_CATEGORY_ID,
     ctl.customer_trx_line_id                                          INVOICE_LINE_ID,
     nvl(substrb(sh.sales_channel_code,1,30), '-1')                    SALES_CHANNEL,
     substrb( DECODE(ctl_parent.interface_line_context,
              'ORDER ENTRY',ctl_parent.interface_line_attribute1,
              'INTERCOMPANY',ctl_parent.interface_line_attribute1,
              ctl_parent.sales_order),1,30)                            ORDER_NUMBER,
     'Y'                                POSTED_FLAG,
     fii_currency.get_global_rate_primary(sob.currency_code,
                  trunc(least(trunc(aeh.accounting_date), sysdate)))                                  PRIM_CONVERSION_RATE,
     fii_currency.get_global_rate_secondary(sob.currency_code,
                  trunc(least(trunc(aeh.accounting_date), sysdate)))                                  SEC_CONVERSION_RATE,
     ccdim.prod_category_id PROD_CATEGORY_ID,
     sob.chart_of_accounts_id                                          CHART_OF_ACCOUNTS_ID,
     -- ffcta.fin_cat_type_code FIN_CAT_TYPE_CODE,
     AC.fin_cat_type_code FIN_CAT_TYPE_CODE,
     decode(sh.booked_flag, 'Y', trunc(nvl(sl_child.order_firmed_date,
          sh.booked_date)), to_date(null))                             REV_BOOKED_DATE,
     decode(ctl.interface_line_context, 'ORDER ENTRY',ctl.interface_line_attribute6,
              null)                                         CHILD_ORDER_LINE_ID
   FROM
     fii_ar_revenue_id               fpk,
     ra_customer_trx_lines_all       ctl,
     ra_customer_trx_all             ct,
     ra_cust_trx_types_all           ctt,
     ra_cust_trx_line_gl_dist_all    ctlgd,
     gl_code_combinations            glcc,
     fii_gl_ccid_dimensions          ccdim,
     fii_slg_assignments             slga,
     fii_source_ledger_groups        fslg,
     -- fii_fin_cat_type_assgns         ffcta,
     ra_customer_trx_lines_all       ctl_parent,
     gl_ledgers_public_v             sob,
     hz_cust_accounts                bill_acct,
     oe_order_lines_all              sl_child,
     oe_order_lines_all              sl_parent,
     oe_order_headers_all            sh,
     ACCNT_CLASS AC,
     xla_ae_headers aeh,
     xla_ae_lines ael,
     xla_distribution_links lnk
  WHERE fpk.view_type_id= 4
  AND   fpk.job_num =  p_job_num
  AND   aeh.ae_header_id = fpk.primary_key1
  AND   aeh.application_id = 222
  AND   aeh.balance_type_code = 'A'
  AND   aeh.gl_transfer_status_code = 'Y'
  AND   ael.application_id = 222
  AND   aeh.ae_header_id = ael.ae_header_id
  AND   lnk.application_id = 222
  AND   ael.ae_header_id = lnk.ae_header_id
  AND   ael.ae_line_num = lnk.ae_line_num
  AND   lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
  AND   lnk.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
  AND   aeh.ledger_id = ctlgd.set_of_books_id
  AND   nvl(ctl.interface_line_context, 'xxx') <> 'PA INVOICES'
  AND   ct.customer_trx_id = ctl.customer_trx_id
  AND   ct.complete_flag = 'Y'
  AND   ctt.cust_trx_type_id(+) = ct.cust_trx_type_id
  AND   ctt.org_id (+) = ct.org_id
  AND   NVL(ctt.post_to_gl,'Y') = 'Y'
  AND   ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
  AND   ctlgd.account_set_flag = 'N'
  -- AND   ctlgd.gl_posted_date IS NOT NULL
  AND   NVL(lnk.unrounded_entered_cr,0) - NVL(lnk.unrounded_entered_dr,0) <> 0
  -- AND   ctlgd.gl_date IS NOT NULL
  AND   glcc.code_combination_id = ael.code_combination_id
  AND   ccdim.code_combination_id = glcc.code_combination_id
  AND   ( slga.bal_seg_value_id = ccdim.company_id
       OR slga.bal_seg_value_id = -1 )
  AND   slga.chart_of_accounts_id = ccdim.chart_of_accounts_id
  AND   slga.ledger_id = ctl.set_of_books_id
  -- AND   ffcta.fin_category_id = ccdim.natural_account_id
  -- AND   ffcta.fin_cat_type_code in ('R', 'DR')
  AND   ctl_parent.customer_trx_line_id =
            nvl(ctl.previous_customer_trx_line_id,ctl.customer_trx_line_id)
  AND   sob.ledger_id = ct.set_of_books_id
  AND   bill_acct.cust_account_id(+) = ct.bill_to_customer_id
  AND   sl_child.line_id (+) =
           case when (ctl_parent.interface_line_context in ('ORDER ENTRY', 'INTERCOMPANY')
                      and ltrim(ctl_parent.interface_line_attribute6, '0123456789') is NULL)
                then  to_number(ctl_parent.interface_line_attribute6)
                else  to_number(NULL) end
  AND   sh.header_id (+) = sl_child.header_id
  AND   sl_parent.line_id(+) = NVL(sl_child.top_model_line_id, sl_child.line_id)
  AND   slga.source_ledger_group_id = fslg.source_ledger_group_id
  AND   fslg.usage_code = g_usage_code
  AND ael.accounting_class_code = AC.Accounting_Class_Code
  AND ( aeh.ledger_id = AC.Ledger_ID OR AC.Ledger_ID IS NULL )
  GROUP BY
  ctl.customer_trx_line_id,
  trunc(aeh.accounting_date),
  ael.code_combination_id,
  ctl_parent.inventory_item_id,
  ct.org_id,            --bug 3361888
  ccdim.company_id,
  ccdim.cost_center_id,
  ct.trx_number,
  ctl_parent.line_type,
  ctl_parent.interface_line_context,
  sl_child.item_type_code,
  sl_child.inventory_item_id,
  sl_parent.line_id,
  bill_acct.party_id,
  sob.currency_code,
  ct.invoice_currency_code,
  ct.set_of_books_id,   --bug 3361888
  ct.customer_trx_id,
  ct.trx_date,
  sysdate,
  sl_parent.inventory_item_id,
  sl_parent.ship_from_org_id,
  sl_child.ship_from_org_id,
  ctt.type,
  ccdim.natural_account_id,
  sh.sales_channel_code,
  ctl_parent.interface_line_attribute1,
  ctl_parent.sales_order,
  ccdim.prod_category_id,
  sob.chart_of_accounts_id,
  -- ffcta.fin_cat_type_code,
  AC.Fin_Cat_Type_Code,
  ctl_parent.WAREHOUSE_ID,
  decode(sh.booked_flag, 'Y', trunc(nvl(sl_child.order_firmed_date, sh.booked_date)), to_date(null)),
  ctl.interface_line_context,
  ctl.interface_line_attribute6;

  ELSIF (p_view_type_id = 3) THEN

  INSERT INTO  FII_AR_REVENUE_STG (
    REVENUE_PK,
    GL_DATE_ID,
    GL_DATE,
    INVENTORY_ITEM_ID,
    OPERATING_UNIT_ID,
--commented by ilavenil    COMPANY_COST_CENTER_ORG_ID,
    COMPANY_ID,
    COST_CENTER_ID,
--above columns added by ilavenil
    INVOICE_NUMBER,
    INVOICE_DATE,
    ORDER_LINE_ID,
    BILL_TO_PARTY_ID,
    FUNCTIONAL_CURRENCY,
    TRANSACTION_CURRENCY,
    LEDGER_ID,
    INVOICE_ID,
    AMOUNT_T,
    AMOUNT_B,
    EXCHANGE_DATE,
    TOP_MODEL_ITEM_ID,
    ORGANIZATION_ID,
    item_organization_id,
    om_product_revenue_flag,
    TRANSACTION_CLASS,
    FIN_CATEGORY_ID,
    INVOICE_LINE_ID,
    SALES_CHANNEL,
    ORDER_NUMBER,
    POSTED_FLAG,
    PRIM_CONVERSION_RATE,
    SEC_CONVERSION_RATE,
    PROD_CATEGORY_ID,
    CHART_OF_ACCOUNTS_ID,
    FIN_CAT_TYPE_CODE,
    REV_BOOKED_DATE,
    CHILD_ORDER_LINE_ID)
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   g_program_code_R,  'R',
                                   g_program_code_DR, 'DR',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code = g_program_code_R
                     AND XAD.Enabled_Flag = 'Y'
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
  SELECT /*+ NO_EXPAND */
     DISTINCT
     'ADJ-'||ad.line_id                                                REVENUE_PK,
     to_number(to_char(trunc(aeh.accounting_date),'J'))                       GL_DATE_ID,
--Bug 3455965: use TRUNC for date
     TRUNC(aeh.accounting_date)                                        GL_DATE,
--     ctl_parent.inventory_item_id                                      INVENTORY_ITEM_ID,
    /*  CASE
             when  (ctl_parent.line_type like  'LINE'
                    and    ctl_parent.inventory_item_id = sl_child.inventory_item_id
                       and    sl_child.ship_from_org_id   IS NOT NULL )
                       THEN  ctl_parent.inventory_item_id
             when  (ctl_parent.line_type like  'LINE'  and ctl_parent.WAREHOUSE_ID  IS NOT NULL)
                        THEN  ctl_parent.inventory_item_id
                  ELSE
              to_number(NULL)

     END                                                                 INVENTORY_ITEM_ID, */
    to_number (null)                                                   INVENTORY_ITEM_ID,
     adj.org_id                                                        OPERATING_UNIT_ID,
--commented by ilavenil     ccdim.company_cost_center_org_id                                  COMPANY_COST_CENTER_ORG_ID,
     ccdim.company_id COMPANY_ID,
     ccdim.cost_center_id COST_CENTER_ID,
     substrb(ct.trx_number,1,30)                                       INVOICE_NUMBER,
     trunc(ct.trx_date)                                                INVOICE_DATE,
/*     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_parent.line_id,
           'INTERCOMPANY', sl_parent.line_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                ORDER_LINE_ID, */
     to_number(null)                                                   ORDER_LINE_ID,
     bill_acct.party_id                                                BILL_TO_PARTY_ID,
     sob.currency_code                                                 FUNCTIONAL_CURRENCY,
     nvl(ct.invoice_currency_code,sob.currency_code)                   TRANSACTION_CURRENCY,
     aeh.ledger_id                                                     SET_OF_BOOKS_ID,
     ct.customer_trx_id                                                INVOICE_ID,
     decode(gcc.account_type,'A',
            sum( NVL(lnk.unrounded_entered_dr,0) -
                 NVL(lnk.unrounded_entered_cr,0) ),
            sum( NVL(lnk.unrounded_entered_cr,0) -
                 NVL(lnk.unrounded_entered_dr,0) )
           )                                                           AMOUNT_T,
      decode(gcc.account_type,'A',
            sum( NVL(lnk.unrounded_accounted_dr,0) -
                 NVL(lnk.unrounded_accounted_cr,0) ),
            sum( NVL(lnk.unrounded_accounted_cr,0) -
                 NVL(lnk.unrounded_accounted_dr,0) )
            )                                                          AMOUNT_B,
     trunc(aeh.accounting_date)                                        EXCHANGE_DATE,
/*     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_parent.inventory_item_id,
           'INTERCOMPANY', sl_parent.inventory_item_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                TOP_MODEL_ITEM_ID,
     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_parent.ship_from_org_id,
           'INTERCOMPANY', sl_parent.ship_from_org_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                ORGANIZATION_ID,
     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
         DECODE(ctl_parent.interface_line_context,
           'ORDER ENTRY', sl_child.ship_from_org_id,
           'INTERCOMPANY', sl_child.ship_from_org_id, to_number(NULL)),
         to_number(NULL)),
       to_number(NULL))                                                item_organization_id, */
/*     CASE
           when ( ctl_parent.line_type like  'LINE'
                   and  ctl_parent.inventory_item_id = sl_child.inventory_item_id
                   and  sl_parent.ship_from_org_id IS NOT NULL)
                    THEN   sl_parent.inventory_item_id
              ELSE
                to_number(NULL)
     END                                                                  TOP_MODEL_ITEM_ID, */
     to_number(null)                                                   TOP_MODEL_ITEM_ID,
/*     DECODE(ctl_parent.line_type, 'LINE',
             DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                     sl_parent.ship_from_org_id, to_number(null)),
                to_number(NULL) )                                      ORGANIZATION_ID, */
     to_number(null)                                                   ORGANIZATION_ID,
/*     DECODE(ctl_parent.line_type, 'LINE',
       DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                      sl_child.ship_from_org_id, ctl_parent.WAREHOUSE_ID ),
             to_number(NULL))                                          item_organization_id, */
        to_number(null)                                                item_organization_id,
/*   decode(ctl_parent.interface_line_context, 'ORDER ENTRY',
       decode(nvl( sl_child.item_type_code, 'X' ), 'SERVICE',
       'N', 'Y'),
     'N')                              om_product_revenue_flag, */
     'N'                               om_product_revenue_flag,
     'ADJ'                                                             TRANSACTION_CLASS,
     ccdim.natural_account_id FIN_CATEGORY_ID,
     0                                          INVOICE_LINE_ID,
     -- nvl(substrb(sh.sales_channel_code,1,30), '-1')                    SALES_CHANNEL,
     '-1'                                                             SALES_CHANNEL,
/*     substrb( DECODE(ctl_parent.interface_line_context,
              'ORDER ENTRY',ctl_parent.interface_line_attribute1,
              'INTERCOMPANY',ctl_parent.interface_line_attribute1,
              ctl_parent.sales_order),1,30)                            ORDER_NUMBER, */
     null                                                              ORDER_NUMBER,
     'Y'                                  POSTED_FLAG,
     FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY(sob.currency_code,
                  trunc(least(trunc(aeh.accounting_date), sysdate)))          PRIM_CONVERSION_RATE,
     FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(sob.currency_code,
                  trunc(least(trunc(aeh.accounting_date), sysdate)))          SEC_CONVERSION_RATE,
     ccdim.prod_category_id                                            PROD_CATEGORY_ID,
     sob.chart_of_accounts_id                                          CHART_OF_ACCOUNTS_ID,
     -- ffcta.fin_cat_type_code                                           FIN_CAT_TYPE_CODE,
     AC.fin_cat_type_code FIN_CAT_TYPE_CODE,
--     decode(sh.booked_flag, 'Y', trunc(sh.booked_date), to_date(null))         REV_BOOKED_DATE
     to_date(null)                                                     REV_BOOKED_DATE,
     null                                                              CHILD_ORDER_LINE_ID
   FROM
     fii_ar_revenue_id               fpk,
     ar_adjustments_all              adj,
     ar_distributions_all            ad,
     gl_code_combinations            gcc,
     fii_gl_ccid_dimensions          ccdim,
     fii_slg_assignments             slga,
     fii_source_ledger_groups        fslg,
     -- fii_fin_cat_type_assgns         ffcta,
     ra_customer_trx_all             ct,
--     ra_customer_trx_lines_all       ctl,
--     ra_customer_trx_lines_all       ctl_parent,
--     oe_order_lines_all              sl_child,
--     oe_order_headers_all            sh,
 --    oe_order_lines_all              sl_parent,
     gl_ledgers_public_v             sob,
     hz_cust_accounts                bill_acct,
     ACCNT_CLASS AC,
     xla_ae_headers aeh,
     xla_ae_lines ael,
     xla_distribution_links lnk
  WHERE fpk.view_type_id = 3
  AND   fpk.job_num   = p_job_num
  -- AND   adj.adjustment_id = fpk.Primary_Key1
  AND   aeh.ae_header_id = fpk.primary_key1
  AND   aeh.application_id = 222
  AND   aeh.balance_type_code = 'A'
  AND   aeh.gl_transfer_status_code = 'Y'
  AND   ael.application_id = 222
  AND   aeh.ae_header_id = ael.ae_header_id
  AND   lnk.application_id = 222
  AND   ael.ae_header_id = lnk.ae_header_id
  AND   ael.ae_line_num = lnk.ae_line_num
  AND   lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
  AND   lnk.source_distribution_id_num_1 = ad.line_id
  AND   aeh.ledger_id = adj.set_of_books_id
  AND   NVL(adj.status, 'A') = 'A'
  AND   NVL(adj.postable,'Y') = 'Y'
  -- AND   adj.gl_posted_date IS NOT NULL
  AND   ad.source_id = adj.adjustment_id
  AND   ad.source_table = 'ADJ'
  AND   gcc.code_combination_id = ael.code_combination_id
  AND   ccdim.code_combination_id = gcc.code_combination_id
  AND   slga.chart_of_accounts_id = ccdim.chart_of_accounts_id
  AND   ( slga.bal_seg_value_id = ccdim.company_id
       OR slga.bal_seg_value_id = -1 )
  AND   slga.ledger_id = aeh.ledger_id
  -- AND   ffcta.fin_category_id = ccdim.natural_account_id
  -- AND   ffcta.fin_cat_type_code = 'R'
  AND   ct.customer_trx_id = adj.customer_trx_id
  AND   nvl(ct.org_id, -999) = nvl(adj.org_id, -999)
  AND   ct.complete_flag = 'Y'
  -- AND   ctl.customer_trx_line_id (+) = nvl2(adj.customer_trx_line_id,0,0)
  -- AND   nvl(ctl.interface_line_context, 'xxx') <> 'PA INVOICES'
  -- AND   ctl_parent.customer_trx_line_id (+) =
  --          nvl(ctl.previous_customer_trx_line_id,ctl.customer_trx_line_id)
  -- AND   sl_child.line_id (+) =
  --         case when (ctl_parent.interface_line_context in ('ORDER ENTRY', 'INTERCOMPANY')
  --                    and ltrim(ctl_parent.interface_line_attribute6, '0123456789') is NULL)
  --              then  to_number(ctl_parent.interface_line_attribute6)
  --              else  to_number(NULL) end
  -- AND   sh.header_id (+) = sl_child.header_id
  -- AND   sl_parent.line_id(+) = NVL(sl_child.top_model_line_id, sl_child.line_id)
  AND   slga.source_ledger_group_id = fslg.source_ledger_group_id
  AND   fslg.usage_code = g_usage_code
  AND   sob.ledger_id = aeh.ledger_id
  AND   bill_acct.cust_account_id(+) = ct.bill_to_customer_id
  AND ael.accounting_class_code = AC.Accounting_Class_Code
  AND ( aeh.ledger_id = AC.Ledger_ID OR AC.Ledger_ID IS NULL )
  group by
     ad.line_id,
     to_number(to_char(trunc(aeh.accounting_date),'J')),
     TRUNC(aeh.accounting_date),
     adj.org_id,
     ccdim.company_id,
     ccdim.cost_center_id,
     substrb(ct.trx_number,1,30),
     trunc(ct.trx_date),
     bill_acct.party_id,
     sob.currency_code,
     nvl(ct.invoice_currency_code,sob.currency_code),
     aeh.ledger_id,
     ct.customer_trx_id,
     gcc.account_type,
     ccdim.natural_account_id,
     trunc(least(trunc(aeh.accounting_date), sysdate)),
     ccdim.prod_category_id,
     sob.chart_of_accounts_id,
     -- ffcta.fin_cat_type_code,
     AC.Fin_Cat_Type_Code;

  END IF;

  l_row_count := SQL%ROWCOUNT;

 if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Inserting records into staging  table');
  fii_util.put_line('Inserted '||l_row_count||' rows');
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
 end if;

  commit;

  RETURN(l_row_count);

EXCEPTION
  WHEN OTHERS THEN
    g_retcode := -2;
    g_errbuf := '
  ---------------------------------
  Error in Procedure: POPULATE_STG
           Message: '||sqlerrm;
  raise g_procedure_failure;

END POPULATE_STG;

-----------------------------------------------------------
-- PROCEDURE AR_STG_BF
-- Inserting records into staging table
-- for DR before g_gl_from_date
-- Parameter p_view_type_id and p_job_num are kept for future needs
-----------------------------------------------------------
FUNCTION AR_STG_BF (
    p_view_type_id NUMBER,
    p_job_num      NUMBER) RETURN NUMBER IS

    l_row_count    NUMBER;

BEGIN

  if g_debug_flag = 'Y' then
    fii_util.put_line('');
    fii_util.put_line('Started inserting rows into staging table for def rev transactions prior to global start date.');
    fii_util.start_timer;
  end if;

  IF (p_view_type_id = 4) THEN
-- Bug 4942753: Per Lester's suggestion, reordered the XLA tables
INSERT /*+ APPEND PARALLEL(F) */ INTO  FII_AR_REVENUE_STG F (
        REVENUE_PK,
        GL_DATE_ID,
        GL_DATE,
        INVENTORY_ITEM_ID,
        OPERATING_UNIT_ID,
        COMPANY_ID,
        COST_CENTER_ID,
        INVOICE_NUMBER,
        INVOICE_DATE,
        ORDER_LINE_ID,
        BILL_TO_PARTY_ID,
        FUNCTIONAL_CURRENCY,
        TRANSACTION_CURRENCY,
        LEDGER_ID,
        INVOICE_ID,
        AMOUNT_T,
        AMOUNT_B,
        EXCHANGE_DATE,
        TOP_MODEL_ITEM_ID,
        ORGANIZATION_ID,
        item_organization_id,
        om_product_revenue_flag,
        TRANSACTION_CLASS,
        FIN_CATEGORY_ID,
        INVOICE_LINE_ID,
        SALES_CHANNEL,
        ORDER_NUMBER,
        POSTED_FLAG,
        PRIM_CONVERSION_RATE,
        SEC_CONVERSION_RATE,
        PROD_CATEGORY_ID,
        CHART_OF_ACCOUNTS_ID,
        FIN_CAT_TYPE_CODE,
        REV_BOOKED_DATE,
        CHILD_ORDER_LINE_ID)
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   g_program_code_R,  'R',
                                   g_program_code_DR, 'DR',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code = g_program_code_DR
                     AND XAD.Enabled_Flag = 'Y'
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
    select  /*+ ordered use_hash(X,sob,glcc) use_nl(ctl_parent,bill_acct,sl_child,sl_parent,sh)
        swap_join_inputs(sob) swap_join_inputs(glcc)
            parallel(X) parallel(Y) parallel(glcc) parallel(ctl_parent) parallel(sob)
                parallel(bill_acct) parallel(sl_child) parallel(sl_parent) parallel(sh) */
            DISTINCT 'AR-'||X.x_customer_trx_line_id||'-'||
              to_char(X.x_gl_date,'YYYY/MM/DD')||'-'|| X.x_code_combination_id          REVENUE_PK,
            to_number(to_char(X.x_gl_date,'J'))                                         GL_DATE_ID,
            TRUNC(X.x_gl_date)                                                          GL_DATE,
            CASE
            when  (ctl_parent.line_type like  'LINE'
                    and ctl_parent.inventory_item_id = sl_child.inventory_item_id
                    and sl_child.ship_from_org_id IS NOT NULL )
                    THEN  ctl_parent.inventory_item_id
            when  (ctl_parent.line_type like  'LINE'
                    and ctl_parent.WAREHOUSE_ID  IS NOT NULL)
                    THEN  ctl_parent.inventory_item_id
            ELSE
                    to_number(NULL)
            END                                                                         INVENTORY_ITEM_ID,
            X.x_org_id                                                                  OPERATING_UNIT_ID,
            Y.y_company_id                                                              COMPANY_ID,
            Y.y_cost_center_id                                                          COST_CENTER_ID,
            substrb(X.x_trx_number,1,30)                                                INVOICE_NUMBER,
            trunc(X.x_trx_date)                                                         INVOICE_DATE,
            DECODE(ctl_parent.line_type, 'LINE',
                    DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                            DECODE(ctl_parent.interface_line_context,
                                    'ORDER ENTRY', sl_parent.line_id,
                                    'INTERCOMPANY', sl_parent.line_id,
                                    to_number(NULL)),
                            to_number(NULL)),
                    to_number(NULL))                                                    ORDER_LINE_ID,
            bill_acct.party_id                                                          BILL_TO_PARTY_ID,
            sob.currency_code                                                           FUNCTIONAL_CURRENCY,
            nvl(X.x_invoice_currency_code,sob.currency_code)                            TRANSACTION_CURRENCY,
            X.x_ct_set_of_books_id                                                      SET_OF_BOOKS_ID,
            X.x_customer_trx_id                                                         INVOICE_ID,
            (X.x_amount)                                                             AMOUNT_T,
            (X.x_acctd_amount)                                                       AMOUNT_B,
            trunc(X.x_gl_date)                                                          EXCHANGE_DATE,
            CASE
            when (ctl_parent.line_type like  'LINE'
                    and  ctl_parent.inventory_item_id = sl_child.inventory_item_id
                    and  sl_parent.ship_from_org_id IS NOT NULL)
            THEN    sl_parent.inventory_item_id
            ELSE
                    to_number(NULL)
            END                                                                         TOP_MODEL_ITEM_ID,
            DECODE(ctl_parent.line_type, 'LINE',
                    DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                            sl_parent.ship_from_org_id, to_number(null)),
                            to_number(NULL))                                            ORGANIZATION_ID,
            DECODE(ctl_parent.line_type, 'LINE',
                    DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                            sl_child.ship_from_org_id, ctl_parent.WAREHOUSE_ID),
                    to_number(NULL))                                                    item_organization_id,
            decode(ctl_parent.interface_line_context, 'ORDER ENTRY',
                    decode(nvl( sl_child.item_type_code, 'X' ), 'SERVICE',
                            'N', 'Y'),
                    'N')                                                                om_product_revenue_flag,
            decode(X.x_type,'GUAR','GUR',substrb(X.x_type,1,3))                         TRANSACTION_CLASS,
            Y.y_natural_account_id                                                      FIN_CATEGORY_ID,
            X.x_customer_trx_line_id                                                    INVOICE_LINE_ID,
            nvl(substrb(sh.sales_channel_code,1,30), '-1')                              SALES_CHANNEL,
            substrb( DECODE(ctl_parent.interface_line_context,
                            'ORDER ENTRY', ctl_parent.interface_line_attribute1,
                            'INTERCOMPANY', ctl_parent.interface_line_attribute1,
                            ctl_parent.sales_order),1,30)                               ORDER_NUMBER,
            'Y'                                                                         POSTED_FLAG,
            -1                                                                          PRIM_CONVERSION_RATE,
            -1                                                                          SEC_CONVERSION_RATE,
            Y.y_prod_category_id                                                        PROD_CATEGORY_ID,
            sob.chart_of_accounts_id                                                    CHART_OF_ACCOUNTS_ID,
            -- Y.y_fin_cat_type_code                                                       FIN_CAT_TYPE_CODE,
            X.x_fin_cat_type_code                                                       FIN_CAT_TYPE_CODE,
            decode(sh.booked_flag, 'Y', trunc(nvl(sl_child.order_firmed_date,
                     sh.booked_date)), to_date(null))                                   REV_BOOKED_DATE,
            X.x_child_order_line_id                                                     CHILD_ORDER_LINE_ID
    from    (
            select  /*+ no_merge cardinality(1000000) parallel(ccdim) parallel(slga) parallel(ffcta) parallel(fslg) */
                    ccdim.code_combination_id    y_code_combination_id,
                    ccdim.company_id             y_company_id,
                    ccdim.cost_center_id         y_cost_center_id,
                    ccdim.natural_account_id     y_natural_account_id,
                    ccdim.prod_category_id       y_prod_category_id,
                    slga.ledger_id               y_ledger_id
                    -- ffcta.fin_cat_type_code      y_fin_cat_type_code
            from    fii_source_ledger_groups fslg,
                    fii_slg_assignments slga,
                    fii_gl_ccid_dimensions  ccdim
                    -- fii_fin_cat_type_assgns ffcta
            where   (slga.bal_seg_value_id = ccdim.company_id
                    OR slga.bal_seg_value_id = -1
                    )
            AND     slga.chart_of_accounts_id = ccdim.chart_of_accounts_id
            -- AND     ffcta.fin_category_id = ccdim.natural_account_id
            AND     slga.source_ledger_group_id = fslg.source_ledger_group_id
            AND     fslg.usage_code = g_usage_code
            -- AND     ffcta.fin_cat_type_code = 'DR'
            ) Y,
            (
 select  /*+ no_merge cardinality(10000000) ordered full(fpk) use_hash(ctl,ct,ctt,ctlgd)
                        parallel(fpk) parallel(ctl) parallel(ct) parallel(ctt) parallel(ctlgd) */
                    ael.code_combination_id              x_code_combination_id,
                    trunc(aeh.accounting_date)           x_gl_date,
                    sum( NVL(lnk.unrounded_entered_cr,0) -
                         NVL(lnk.unrounded_entered_dr,0) )    x_amount,
                    sum( NVL(lnk.unrounded_accounted_cr,0) -
                         NVL(lnk.unrounded_accounted_dr,0) )  x_acctd_amount,
                    ctl.set_of_books_id                  x_set_of_books_id,
                    ctl.previous_customer_trx_line_id    x_prev_customer_trx_line_id,
                    ctl.customer_trx_line_id             x_customer_trx_line_id,
                    ct.org_id                            x_org_id,
                    ct.trx_number                        x_trx_number,
                    ct.invoice_currency_code             x_invoice_currency_code,
                    ct.customer_trx_id                   x_customer_trx_id,
                    ct.trx_date                          x_trx_date,
                    ct.set_of_books_id                   x_ct_set_of_books_id,
                    ct.bill_to_customer_id               x_bill_to_customer_id,
                    ctt.type                             x_type,
                    decode(ctl.interface_line_context, 'ORDER ENTRY',ctl.interface_line_attribute6,
                    null)                                x_child_order_line_id,
                    AC.Fin_Cat_Type_Code                 x_fin_cat_type_code
            from    fii_ar_revenue_id   fpk,
                    ra_customer_trx_lines_all   ctl,
                    ra_customer_trx_all ct,
                    ra_cust_trx_types_all   ctt,
                    ra_cust_trx_line_gl_dist_all ctlgd,
                    ACCNT_CLASS AC,
                    xla_distribution_links lnk,
                    xla_ae_lines ael,
                    xla_ae_headers aeh
            WHERE   fpk.view_type_id= 4
            AND     fpk.job_num =   p_job_num
            AND     ctl.customer_trx_line_id = fpk.primary_key1
            AND     nvl(ctl.interface_line_context, 'xxx') <> 'PA INVOICES'
            AND     ct.customer_trx_id = ctl.customer_trx_id
            AND     ct.complete_flag = 'Y'
            AND     ctt.cust_trx_type_id(+) = ct.cust_trx_type_id
            AND     ctt.org_id (+) = ct.org_id
            AND     NVL(ctt.post_to_gl,'Y') = 'Y'
            AND     ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
            AND     ctlgd.account_set_flag = 'N'
            AND NVL(lnk.unrounded_entered_cr,0) -
                NVL(lnk.unrounded_entered_dr,0) <> 0
            AND aeh.accounting_date < g_gl_from_date
            AND aeh.application_id = 222
            AND aeh.balance_type_code = 'A'
            AND aeh.gl_transfer_status_code = 'Y'
            AND ael.application_id = 222
            AND aeh.ae_header_id = ael.ae_header_id
            AND lnk.application_id = 222
            AND ael.ae_header_id = lnk.ae_header_id
            AND ael.ae_line_num = lnk.ae_line_num
            AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
            AND lnk.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
            AND aeh.ledger_id = ctlgd.set_of_books_id
            AND ael.accounting_class_code = AC.Accounting_Class_Code
            AND ( aeh.ledger_id = AC.Ledger_ID OR AC.Ledger_ID IS NULL )
           GROUP BY
                    ael.code_combination_id,
                    trunc(aeh.accounting_date),
                    ctl.set_of_books_id,
                    ctl.previous_customer_trx_line_id,
                    ctl.customer_trx_line_id,
                    ct.org_id,
                    ct.trx_number,
                    ct.invoice_currency_code,
                    ct.customer_trx_id,
                    ct.trx_date,
                    ct.set_of_books_id,
                    ct.bill_to_customer_id,
                    ctt.type,
                    ctl.interface_line_context,
                    ctl.interface_line_attribute6,
                    AC.Fin_Cat_Type_Code
            ) X,
            gl_ledgers_public_v sob,
            gl_code_combinations glcc,
            ra_customer_trx_lines_all ctl_parent,
            hz_cust_accounts bill_acct,
            oe_order_lines_all  sl_child,
            oe_order_lines_all  sl_parent,
            oe_order_headers_all sh
    WHERE   Y.y_code_combination_id = X.x_code_combination_id
    AND     Y.y_code_combination_id = glcc.code_combination_id
    AND     Y.y_ledger_id = X.x_set_of_books_id
    AND     ctl_parent.customer_trx_line_id = nvl(X.x_prev_customer_trx_line_id,X.x_customer_trx_line_id)
    AND     sob.ledger_id = X.x_ct_set_of_books_id
    AND     bill_acct.cust_account_id(+) = X.x_bill_to_customer_id
    AND     sl_child.line_id (+) =
               case  when (ctl_parent.interface_line_context in ('ORDER ENTRY', 'INTERCOMPANY')
                           and ltrim(ctl_parent.interface_line_attribute6, '0123456789') is NULL)
                     then to_number(ctl_parent.interface_line_attribute6)
                     else  to_number(NULL)
               end
    AND     sh.header_id (+) = sl_child.header_id
    AND     sl_parent.line_id(+) = NVL(sl_child.top_model_line_id, sl_child.line_id);

  ELSIF (p_view_type_id = 3) THEN

    NULL;   -- No ADJ for DR

  END IF;

  l_row_count := SQL%ROWCOUNT;

  if g_debug_flag = 'Y' then
    fii_util.put_line('');
--  fii_util.put_line('Extracting Deferred Revenue transactions prior to global_start date to staging table');
    fii_util.put_line('Inserted  '||l_row_count||' rows into staging table.');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  end if;

  commit;

  RETURN(l_row_count);

EXCEPTION
  WHEN OTHERS THEN
    g_retcode := -2;
    g_errbuf := '
  ---------------------------------
  Error in Procedure: AR_STG_BF
           Message: '||sqlerrm;
  raise g_procedure_failure;

END AR_STG_BF;

-----------------------------------------------------------
--  FUNCTION POPULATE_SUM
--  inserting / updating records in base summary table
-----------------------------------------------------------
FUNCTION POPULATE_SUM RETURN NUMBER IS
  l_stmt         VARCHAR2(1500);
  seq_id         NUMBER :=0;
  l_row_count    NUMBER;
BEGIN

  SELECT FII_AR_REVENUE_B_S.nextval INTO seq_id FROM dual;

 if g_debug_flag = 'Y' then
   fii_util.put_line(' ');
   fii_util.put_line('Merging data into base summary table');
   fii_util.start_timer;
   fii_util.put_line('');
  end if;

 MERGE  INTO FII_AR_REVENUE_B f
          USING (SELECT /*+ cardinality(stg,1) */ * FROM  FII_AR_REVENUE_STG stg
                  WHERE prim_conversion_rate > 0
                  OR   sec_conversion_rate > 0) stg
          ON (  stg.revenue_pk = f.revenue_pk)
   WHEN MATCHED THEN
         UPDATE SET
                f.AMOUNT_T = stg.AMOUNT_T,
                f.AMOUNT_B = stg.AMOUNT_B,
                f.PRIM_AMOUNT_G = ROUND(stg.AMOUNT_B * NVL(stg.prim_conversion_rate, 1) /
                        to_char(g_mau_prim)) * to_char(g_mau_prim),
                f.SEC_AMOUNT_G = ROUND(stg.AMOUNT_B * NVL(stg.sec_conversion_rate, 1) /
                        to_char(g_mau_sec)) * to_char(g_mau_sec),
                f.UPDATE_SEQUENCE = seq_id,
                f.LAST_UPDATED_BY =  g_fii_user_id,
                f.LAST_UPDATE_LOGIN = g_fii_login_id,
                f.LAST_UPDATE_DATE = SYSDATE
   WHEN NOT MATCHED THEN
        INSERT  (
                f.REVENUE_PK,
                f.GL_DATE_ID,
                f.GL_DATE,
                f.INVENTORY_ITEM_ID,
                f.OPERATING_UNIT_ID,
                f.COMPANY_ID,
                f.COST_CENTER_ID,
                f.INVOICE_NUMBER,
                f.ORDER_LINE_ID,
                f.BILL_TO_PARTY_ID,
                f.FUNCTIONAL_CURRENCY,
                f.TRANSACTION_CURRENCY,
                f.LEDGER_ID,
                f.INVOICE_ID,
                f.AMOUNT_T,
                f.AMOUNT_B,
                f.PRIM_AMOUNT_G,
                f.SEC_AMOUNT_G,
                f.TOP_MODEL_ITEM_ID,
                f.ORGANIZATION_ID,
                f.item_organization_id,
                f.om_product_revenue_flag,
                f.TRANSACTION_CLASS,
                f.FIN_CATEGORY_ID,
                f.ORDER_NUMBER,
                f.SALES_CHANNEL,
                f.INVOICE_LINE_ID,
                f.LAST_UPDATE_DATE,
                f.CREATION_DATE,
                f.POSTED_FLAG,
                f.PROD_CATEGORY_ID,
                f.CHART_OF_ACCOUNTS_ID,
                f.UPDATE_SEQUENCE,
                f.LAST_UPDATED_BY,
                f.CREATED_BY,
                f.LAST_UPDATE_LOGIN,
                f.INVOICE_DATE,
                f.FIN_CAT_TYPE_CODE,
                f.REV_BOOKED_DATE,
                f.CHILD_ORDER_LINE_ID)
        VALUES (
                stg.REVENUE_PK,
                stg.GL_DATE_ID,
                stg.GL_DATE,
                stg.INVENTORY_ITEM_ID,
                stg.OPERATING_UNIT_ID,
                stg.COMPANY_ID,
                stg.COST_CENTER_ID,
                stg.INVOICE_NUMBER,
                stg.ORDER_LINE_ID,
                stg.BILL_TO_PARTY_ID,
                stg.FUNCTIONAL_CURRENCY,
                stg.TRANSACTION_CURRENCY,
                stg.LEDGER_ID,
                stg.INVOICE_ID,
                stg.AMOUNT_T,
                stg.AMOUNT_B,
                ROUND(stg.AMOUNT_B * NVL(stg.prim_conversion_rate, 1) /
                        to_char(g_mau_prim)) * to_char(g_mau_prim),
                ROUND(stg.AMOUNT_B * NVL(stg.sec_conversion_rate, 1) /
                        to_char(g_mau_sec)) * to_char(g_mau_sec),
                stg.TOP_MODEL_ITEM_ID,
                stg.ORGANIZATION_ID,
                stg.item_organization_id,
                stg.om_product_revenue_flag,
                stg.TRANSACTION_CLASS,
                stg.FIN_CATEGORY_ID,
                stg.ORDER_NUMBER,
                stg.SALES_CHANNEL,
                stg.INVOICE_LINE_ID,
                SYSDATE,
                SYSDATE,
                stg.POSTED_FLAG,
                stg.PROD_CATEGORY_ID,
                stg.CHART_OF_ACCOUNTS_ID,
                seq_id,
                g_fii_user_id,
                g_fii_user_id,
                g_fii_login_id,
                stg.invoice_date,
                stg.FIN_CAT_TYPE_CODE,
                 stg.REV_BOOKED_DATE,
                stg.CHILD_ORDER_LINE_ID);


    l_row_count := SQL%ROWCOUNT;
 if g_debug_flag = 'Y' then
   fii_util.put_line('Processed  '||l_row_count||' rows');
   fii_util.stop_timer;
   fii_util.print_timer('Duration');
  end if;

commit;

   RETURN(l_row_count);

/*   DELETE FROM FII_AR_REVENUE_B f
   WHERE  f.UPDATE_SEQUENCE <> seq_id
   AND    f.TRANSACTION_CLASS <> 'ADJ'
   AND    f.INVOICE_LINE_ID IN (SELECT fpk.primary_key1 FROM FII_AR_REVENUE_ID fpk
                                WHERE fpk.view_type_id = 4);


   COMMIT;
*/
EXCEPTION
 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: POPULATE_SUM
           Message: '||sqlerrm;
  ROLLBACK;
  RAISE g_procedure_failure;

END POPULATE_SUM;


-----------------------------------------------------------
--  FUNCTION VERIFY_MISSING_RATES
-----------------------------------------------------------

FUNCTION VERIFY_MISSING_RATES RETURN NUMBER IS
   l_stmt                    VARCHAR2(1000);
   l_miss_rates_prim         NUMBER :=0;
   l_miss_rates_sec          NUMBER :=0;
   l_miss_rates          NUMBER := 0;
   l_ccid                    VARCHAR2(2000):=NULL;
   l_miss_ccid               NUMBER :=0;
   l_miss_date               NUMBER :=0;
   l_transaction_currency    VARCHAR2(4):=NULL;
   l_exchange_date           DATE := NULL;
   l_stg_count               NUMBER :=0;
   l_prim_return             NUMBER :=0;
   l_sec_return              NUMBER :=0;

   l_prim_currency_code     VARCHAR2(30);
   l_sec_currency_code      VARCHAR2(30);
   l_prim_rate_type         VARCHAR2(30);
   l_sec_rate_type          VARCHAR2(30);
   l_prim_rate_type_name    VARCHAR2(30);
   l_sec_rate_type_name     VARCHAR2(30);

   -------------------------------------------------------
   -- Cursor declaration required to generate output file
   -- containing rows with MISSING CONVERSION RATES
   -------------------------------------------------------
   CURSOR c1 IS SELECT DISTINCT TRANSACTION_CURRENCY,
       decode( prim_conversion_rate,
                -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
                trunc(least(EXCHANGE_DATE,sysdate))) EXCHANGE_DATE
   FROM  FII_AR_REVENUE_STG
   WHERE prim_conversion_rate < 0;

   CURSOR c2 IS SELECT DISTINCT TRANSACTION_CURRENCY,
       decode( sec_conversion_RATE,
                -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
                 trunc(least(EXCHANGE_DATE,sysdate))) EXCHANGE_DATE
   FROM FII_AR_REVENUE_STG
   WHERE sec_conversion_RATE < 0;

   CURSOR c3 IS SELECT DISTINCT FUNCTIONAL_CURRENCY,
       decode( prim_conversion_rate,
                -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
                  trunc(least(TRX_DATE,sysdate))) TRX_DATE
   FROM  FII_AR_REVENUE_RATES_TEMP
   WHERE prim_conversion_rate < 0;

   CURSOR c4 IS SELECT DISTINCT FUNCTIONAL_CURRENCY,
       decode( sec_conversion_RATE,
                -3, to_date( '01/01/1999', 'MM/DD/YYYY' ),
                  trunc(least(TRX_DATE,sysdate))) TRX_DATE
   FROM FII_AR_REVENUE_RATES_TEMP
   WHERE sec_conversion_RATE < 0;

BEGIN

  -----------------------------------------------------------
  -- we will check staging table if there's any missing rates.
  -- If yes, we will print out missing rate report and return
  -- -1.  If there's no missing rate, then we will return 1.
  -----------------------------------------------------------
 if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_timestamp;
  fii_util.put_line('Checking whether there are any missing exchange rates.');
 end if;


  IF g_program_type = 'L' THEN

    -- Bug 4942753: Change to return 1 if any row exists
    BEGIN
      SELECT 1
      INTO l_miss_rates
      FROM FII_AR_REVENUE_RATES_TEMP
      WHERE ((prim_conversion_rate < 0) OR (sec_conversion_rate < 0))
      AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_miss_rates := 0;
    END;

  ELSE

    -- Bug 4942753: Change to return 1 if any row exists
    BEGIN
      SELECT 1
      INTO l_miss_rates
      FROM FII_AR_REVENUE_STG
      WHERE ((prim_conversion_rate < 0) OR (sec_conversion_rate < 0))
      AND ROWNUM = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_miss_rates := 0;
    END;

  END IF;

  ---------------------------------------------------
  -- Print out missing rates report
  ---------------------------------------------------

   l_prim_currency_code := bis_common_parameters.get_currency_code;
   l_sec_currency_code  := bis_common_parameters.get_secondary_currency_code;
   l_prim_rate_type     := bis_common_parameters.get_rate_type;
   l_sec_rate_type      := bis_common_parameters.get_secondary_rate_type;

    begin
        select user_conversion_type into l_prim_rate_type_name
        from gl_daily_conversion_types
        where conversion_type = l_prim_rate_type;

        if l_sec_rate_type is not null then
            select user_conversion_type into l_sec_rate_type_name
            from gl_daily_conversion_types
            where conversion_type = l_sec_rate_type;
        else
            l_sec_rate_type_name := null;
        end if;
    exception
        when others then
            fii_util.write_log(
                'Failed to convert rate_type to rate_type_name' );
            raise;
    end;

   IF (l_miss_rates > 0) THEN

       IF g_program_type = 'L' THEN

          -- Bug 4942753: Change to return 1 if any row exists
          BEGIN
            SELECT  1
            INTO    l_miss_rates_prim
            FROM    FII_AR_REVENUE_RATES_TEMP
            WHERE   prim_conversion_rate < 0
            AND     ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_miss_rates_prim := 0;
          END;

          -- Bug 4942753: Change to return 1 if any row exists
          BEGIN
            SELECT  1
            INTO    l_miss_rates_sec
            FROM    FII_AR_REVENUE_RATES_TEMP
            WHERE   sec_conversion_rate < 0
            AND     ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_miss_rates_sec := 0;
          END;

       ELSE

          -- Bug 4942753: Change to return 1 if any row exists
          BEGIN
            SELECT  1
            INTO    l_miss_rates_prim
            FROM    FII_AR_REVENUE_STG
            WHERE   prim_conversion_rate < 0
            AND     ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_miss_rates_prim := 0;
          END;

          -- Bug 4942753: Change to return 1 if any row exists
          BEGIN
            SELECT  1
            INTO    l_miss_rates_sec
            FROM    FII_AR_REVENUE_STG
            WHERE   sec_conversion_rate < 0
            AND     ROWNUM = 1;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
              l_miss_rates_sec := 0;
          END;

      END IF;

    IF (l_miss_rates_prim > 0) THEN
    --  if g_debug_flag = 'Y' then
            fii_util.put_line(' ');
            fii_util.put_line('There are some missing prim exchange rates.');
         --  end if;
            bis_collection_utilities.writeMissingRateHeader;


            IF g_program_type = 'L' THEN

            FOR  rate_record in c3
                LOOP
                null;
                bis_collection_utilities.writeMissingRate(
                         l_prim_rate_type_name,
                     rate_record.functional_currency,
                     l_prim_currency_code,
                    rate_record.trx_date);
                END LOOP;

                ELSE

            FOR  rate_record in c1
                LOOP
                null;
                bis_collection_utilities.writeMissingRate(
                         l_prim_rate_type_name,
                     rate_record.transaction_currency,
                     l_prim_currency_code,
                    rate_record.exchange_date);
                END LOOP;

            END IF;
    END IF;

    IF (l_miss_rates_sec > 0) THEN
     -- if g_debug_flag = 'Y' then
            fii_util.put_line(' ');
            fii_util.put_line('There are some missing sec conversion rates.');
         --  end if;

            bis_collection_utilities.writeMissingRateHeader;

                IF g_program_type = 'L' THEN

                FOR  rate_record in c4
                LOOP
                null;
                    bis_collection_utilities.writeMissingRate(
                     l_sec_rate_type_name,
                     rate_record.functional_currency,
                     l_sec_currency_code,
                        rate_record.trx_date);
            END LOOP;

            ELSE

            FOR  rate_record in c2
                LOOP
                null;
                    bis_collection_utilities.writeMissingRate(
                     l_sec_rate_type_name,
                     rate_record.transaction_currency,
                     l_sec_currency_code,
                        rate_record.exchange_date);
            END LOOP;

            END IF;
    END IF;

    RETURN -1;
   ELSE
    RETURN 1;
   END IF;

EXCEPTION

  WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: VERIFY_MISSING_RATES
           Message: '||sqlerrm;

  RAISE g_procedure_failure;

END VERIFY_MISSING_RATES;


---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE
--  view_type_id = 3  (AR ADJ)
--  view_type_id = 4  (AR INV)
--  only for Incremental update --
---------------------------------------------------
FUNCTION IDENTIFY_CHANGE(
        p_type          IN  VARCHAR2) RETURN NUMBER IS

  l_count       NUMBER := 0;
  l_lud         VARCHAR2(500) := NULL;
  l_sob         VARCHAR2(200) := NULL;
  l_gl_from     VARCHAR2(80);
  l_gl_to       VARCHAR2(80);
  l_lud_from    VARCHAR2(80);
  l_lud_to      VARCHAR2(80);
  l_max_group_id  NUMBER(15);
  l_stmt        VARCHAR2(1500);
  l_where       VARCHAR2(500) := NULL;

BEGIN

   l_count := 0;
   g_section := 'Section 10';
--   if g_debug_flag = 'Y' then
--     fii_util.put_line('Identify Change for Revenue and Deferred Revenue records for view type '||p_type);
--   end if;

   --  --------------------------------------------
   --  Identify changed rows based on gl date and
   --  last update date
   --  --------------------------------------------
   -- l_gl_from := 'to_date('''||to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS')||
    --            ''',''YYYY/MM/DD HH24:MI:SS'')';

   -- l_gl_to   := 'to_date('''||to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS')||
   --             ''',''YYYY/MM/DD HH24:MI:SS'')';

   -- l_lud_from := 'to_date('''||to_char(g_lud_from_date,'YYYY/MM/DD HH24:MI:SS')||
   --             ''',''YYYY/MM/DD HH24:MI:SS'')';

   -- l_lud_to   := 'to_date('''||to_char(g_lud_to_date,'YYYY/MM/DD HH24:MI:SS')||
     --           ''',''YYYY/MM/DD HH24:MI:SS'')';

    l_gl_from := to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS');

   l_gl_to   := to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS');

   l_lud_from := to_char(g_lud_from_date,'YYYY/MM/DD HH24:MI:SS');

   l_lud_to   := to_char(g_lud_to_date,'YYYY/MM/DD HH24:MI:SS');

   select to_number(item_value) into l_max_group_id
   from FII_CHANGE_LOG
   where log_item = 'AR_MAX_GROUP_ID';

--   if g_debug_flag = 'Y' then
--        fii_util.put_line ('l_gl_from: ' ||l_gl_from);
--        fii_util.put_line ('l_gl_to: ' ||l_gl_to);
--   end if;


   IF (p_type = 'AR ADJ')  THEN
/*
     --  ----------------------------------------
     --  For ar adjustments, find the list of
     --  adjustments which has been updated
     --  ----------------------------------------

       l_stmt := '
        INSERT INTO FII_AR_REVENUE_ID (
              view_type_id,
              primary_key1)
        SELECT --+ ORDERED USE_NL(ADJ)
              7,
              adj.adjustment_id
        from   ra_customer_trx_all t,
               ar_adjustments_all  adj,
               ( select distinct ledger_id
                 from fii_slg_assignments slga,
                      fii_source_ledger_groups fslg
                 where slga.source_ledger_group_id = fslg.source_ledger_group_id
                 and fslg.usage_code = :a
               ) lidset
        WHERE  t.complete_flag   = ''Y''
        AND    t.last_update_date BETWEEN to_date(:b,''YYYY/MM/DD HH24:MI:SS'')  and to_date(:c,''YYYY/MM/DD HH24:MI:SS'')
        and    t.customer_trx_id = adj.customer_trx_id
        and    nvl(adj.status, ''A'')  = ''A''
        and    nvl(adj.postable,''Y'') = ''Y''
        and    adj.amount <> 0
        and    t.set_of_books_id = lidset.ledger_id';

     if g_debug_flag = 'Y' then
 --      fii_util.put_line(' ');
   --    fii_util.put_line(l_stmt);
       fii_util.start_timer;
     end if;
       EXECUTE IMMEDIATE l_stmt using g_usage_code, l_lud_from, l_lud_to;
       l_count := SQL%ROWCOUNT;
     if g_debug_flag = 'Y' then
  --     fii_util.put_line(' ');
       fii_util.stop_timer;
       fii_util.print_timer('Duration');
     end if;


     l_stmt := '
     INSERT INTO FII_AR_REVENUE_ID (
            view_type_id,
            primary_key1)
     SELECT
            7,
            t.adjustment_id
     FROM   ar_adjustments_all t,
            ( select distinct ledger_id
              from fii_slg_assignments slga,
                   fii_source_ledger_groups fslg
              where slga.source_ledger_group_id = fslg.source_ledger_group_id
              AND fslg.usage_code = :a
            ) lidset
     WHERE t.gl_date BETWEEN to_date(:b,''YYYY/MM/DD HH24:MI:SS'')  AND to_date(:c,''YYYY/MM/DD HH24:MI:SS'')
     AND    t.last_update_date BETWEEN to_date(:d,''YYYY/MM/DD HH24:MI:SS'')  and to_date(:e,''YYYY/MM/DD HH24:MI:SS'')
     AND    NVL(t.status, ''A'')  = ''A''
     AND    NVL(t.postable,''Y'') = ''Y''
     AND    t.amount <> 0
     AND    t.set_of_books_id = lidset.ledger_id';

   if g_debug_flag = 'Y' then
   --  fii_util.put_line(' ');
    --  fii_util.put_line(l_stmt);
     fii_util.start_timer;
   end if;
     EXECUTE IMMEDIATE l_stmt using g_usage_code, l_gl_from, l_gl_to, l_lud_from, l_lud_to;
     l_count := l_count + SQL%ROWCOUNT;
   if g_debug_flag = 'Y' then
    -- fii_util.put_line(' ');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;
*/ NULL;

/*   ELSIF (p_type = 'AR INV') THEN

     --  -----------------------------------------
     --  For ra_customer_trx_lines_all.
     --  -----------------------------------------

       l_stmt := '
       INSERT INTO FII_AR_REVENUE_ID (
               view_type_id,
               primary_key1)
       SELECT
               8,
               ctl.customer_trx_line_id
       FROM    ra_customer_trx_all ct,
               ra_customer_trx_lines_all ctl,
               ( select distinct ledger_id
                 from fii_slg_assignments slga,
                      fii_source_ledger_groups fslg
                 where slga.source_ledger_group_id = fslg.source_ledger_group_id
                 and fslg.usage_code = :a
               ) lidset
       WHERE   ct.last_update_date between to_date(:b,''YYYY/MM/DD HH24:MI:SS'')  and to_date(:c,''YYYY/MM/DD HH24:MI:SS'')
       AND     ct.customer_trx_id = ctl.customer_trx_id
       AND     ct.complete_flag = ''Y''
       AND     ct.set_of_books_id = lidset.ledger_id
       UNION
       SELECT
               8,
               ct.customer_trx_line_id
       FROM    ra_customer_trx_lines_all ct,
               ( select distinct ledger_id
                 from fii_slg_assignments slga,
                      fii_source_ledger_groups fslg
                 where slga.source_ledger_group_id = fslg.source_ledger_group_id
                 and fslg.usage_code = :d
               ) lidset
       WHERE   nvl(ct.interface_line_context, ''xxx'') NOT IN (''PA INVOICES'')
       AND     ct.last_update_date between to_date(:e,''YYYY/MM/DD HH24:MI:SS'') AND to_date(:f,''YYYY/MM/DD HH24:MI:SS'')
       AND     ct.set_of_books_id = lidset.ledger_id';

     if g_debug_flag = 'Y' then
     --  fii_util.put_line(' ');
      --  fii_util.put_line(l_stmt);
       fii_util.start_timer;
     end if;
       EXECUTE IMMEDIATE l_stmt  using g_usage_code,l_lud_from, l_lud_to, g_usage_code, l_lud_from, l_lud_to;
       l_count := SQL%ROWCOUNT;
     if g_debug_flag = 'Y' then
      -- fii_util.put_line(' ');
       fii_util.stop_timer;
       fii_util.print_timer('Duration');
     end if;
*/

   ELSIF (p_type = 'AR DL') THEN
     --  -----------------------------------------
     --  For ra_cust_trx_line_gl_dist_all
     --  -----------------------------------------

     ---------------------------------------------
     -- For 'AR DL', if identifying future dated
     -- transactions, do not filter by last updated
     -- hours.  We will scan only one month into
     -- the future.  Future dated records too far
     -- into the future will be picked up gradually
     -- into the future.  This is why we can't
     -- filter by last_updated hours.
     ----------------------------------------------
      IF (g_gl_to_date > SYSDATE) THEN

        -- This logic has been moved to procedure MAIN
        -- g_gl_to_date := ADD_MONTHS(sysdate, 1);
        -- l_gl_to := to_char(g_gl_to_date, 'YYYY/MM/DD HH24:MI:SS');

          l_stmt := 'INSERT INTO FII_AR_REVENUE_ID (
                            view_type_id,
                            primary_key1)
                         SELECT /*+ INDEX(aeh, xla_ae_headers_N5) */
                            dup.view_type_id,
                            aeh.ae_header_id
                         FROM   xla_ae_headers aeh,
                                ( select /*+ no_merge */ distinct ledger_id
                                  from fii_slg_assignments slga,
                                       fii_source_ledger_groups fslg
                                  where slga.source_ledger_group_id = fslg.source_ledger_group_id
                                  and fslg.usage_code = :m
                                ) lidset,
                                ( select 8 view_type_id from dual
                                  union all
                                  select 7 view_type_id from dual
                                ) dup
                         WHERE  aeh.accounting_date BETWEEN to_date(:n,''YYYY/MM/DD HH24:MI:SS'')  AND to_date(:o,''YYYY/MM/DD HH24:MI:SS'')
                         AND    aeh.application_id = 222
                         AND    aeh.balance_type_code = ''A''
                         AND    aeh.gl_transfer_status_code = ''Y''
                         AND    aeh.ledger_id = lidset.ledger_id';

            if g_debug_flag = 'Y' then
                 fii_util.put_line(' ');
             --    fii_util.put_line(l_stmt);
                 fii_util.start_timer;
            end if;
            EXECUTE IMMEDIATE l_stmt using g_usage_code, l_gl_from, l_gl_to;
            l_count := SQL%ROWCOUNT;
            if g_debug_flag = 'Y' then
       --         fii_util.put_line(' ');
                fii_util.stop_timer;
                fii_util.print_timer('Duration');
            end if;

     ELSE
        l_stmt := 'INSERT INTO FII_AR_REVENUE_ID (
                            view_type_id,
                            primary_key1)
                        SELECT /*+ INDEX(aeh, xla_ae_headers_N5) */
                            dup.view_type_id,
                            aeh.ae_header_id
                         FROM   xla_ae_headers aeh,
                                ( select distinct ledger_id
                                  from fii_slg_assignments slga,
                                       fii_source_ledger_groups fslg
                                  where slga.source_ledger_group_id = fslg.source_ledger_group_id
                                  and fslg.usage_code = :a
                                ) lidset,
                                ( select 8 view_type_id from dual
                                  union all
                                  select 7 view_type_id from dual
                                ) dup
                         WHERE  aeh.accounting_date BETWEEN to_date(:b,''YYYY/MM/DD HH24:MI:SS'')  AND to_date(:c,''YYYY/MM/DD HH24:MI:SS'')
                         AND    aeh.group_id > :m
                         AND    aeh.application_id = 222
                         AND    aeh.balance_type_code = ''A''
                         AND    aeh.gl_transfer_status_code = ''Y''
                         AND    aeh.ledger_id = lidset.ledger_id';

            if g_debug_flag = 'Y' then
        --      fii_util.put_line(' ');
              -- fii_util.put_line(l_stmt);
              fii_util.start_timer;
           end if;
           EXECUTE IMMEDIATE l_stmt using g_usage_code, l_gl_from, l_gl_to, l_max_group_id;
           l_count := SQL%ROWCOUNT;
           if g_debug_flag = 'Y' then
         --     fii_util.put_line(' ');
              fii_util.stop_timer;
              fii_util.print_timer('Duration');
          end if;


    END IF;

    /* if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.put_line(l_stmt);
     fii_util.start_timer;
    end if;
     EXECUTE IMMEDIATE l_stmt;
     l_count := SQL%ROWCOUNT;
   if g_debug_flag = 'Y' then
     fii_util.put_line(' ');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;  */

   END IF;


   -- ------------------------------------------
   -- Commit for the child process to pick up
   -- -----------------------------------------
   COMMIT;

   RETURN(l_count);

EXCEPTION
 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: IDENTIFY_CHANGE
           Parameter: p_type='||p_type||'
                      l_gl_from='||l_gl_from||'
                      l_gl_to='||l_gl_to||'
                      l_lud_from='||l_lud_from||'
                      l_lud_to='||l_lud_to||'
                    --  g_sob_id='||g_sob_id||'
           Section: '||g_section||'
           Message: '||sqlerrm;
  RAISE g_procedure_failure;

END IDENTIFY_CHANGE;

---------------------------------------------------
-- FUNCTION IDENTIFY_CHANGE_INIT
--  view_type_id = 3  (AR ADJ)
--  view_type_id = 4  (AR INV)
--  Only for Initial load --
--  Must have: DR before g_gl_from_date
--  Parameter p_type is kept for future needs
---------------------------------------------------
FUNCTION IDENTIFY_CHANGE_INIT(
    p_type IN VARCHAR2) RETURN NUMBER IS

    l_count NUMBER := 0;
    l_stmt  VARCHAR2(5000);
    l_stmt2 VARCHAR2(1024);
        k_status   VARCHAR2(30);
        k_industry   VARCHAR2(30);
        k_ar_schema  VARCHAR2(30);



BEGIN
    g_section := 'Section 10';

    if g_debug_flag = 'Y' then
        fii_util.put_line('Running function IDENTIFY_CHANGE_INIT to identify deferred rev records prior to global start date for view type '||p_type);
    end if;

    IF (p_type = 'AR ADJ')  THEN

        NULL;   -- No ADJ for DR

    ELSIF (p_type = 'AR INV') THEN

    -- This table has been introduced in financals 115.9,
    -- but DBI6.1 can only assume dependency on financals 115.8
    --

    IF(FND_INSTALLATION.GET_APP_INFO('AR', k_status, k_industry, k_ar_schema))
    THEN NULL;
    END IF;

    -- Bug 4942753: Changed to select from dba_tables instead of all_tables
    --              and changed to return 1 if any row exists
    BEGIN
      select 1 into l_count from dba_tables
      where table_name = 'AR_DEFERRED_LINES_ALL'
      and   owner = k_ar_schema
      and   rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count := 0;
    END;

    if l_count > 0 then
            l_stmt2 := '
                        union all
                        select     /*+ parallel(trail) */
                             CUSTOMER_TRX_LINE_ID lid
                        from     AR_DEFERRED_LINES_ALL trail';
    else
        -- Bug 4942753: Changed to select from dba_tables instead of all_tables
        --              and changed to return 1 if any row exists
        BEGIN
          select 1 into l_count from dba_tables
          where table_name = 'AR_RAMC_AUDIT_TRAIL'
          and   owner = k_ar_schema
          and   rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;
        END;

        if l_count = 0 then
            l_stmt2 := '';
        else
            l_stmt2 := '
                        union all
                        select     /*+ parallel(trail) full(trail) */
                             CUSTOMER_TRX_LINE_ID lid
                        from     AR_RAMC_AUDIT_TRAIL trail';
        end if;
    end if;

               l_stmt := '
               INSERT  /*+ APPEND PARALLEL(F) */ INTO FII_AR_REVENUE_ID F
               (
                 view_type_id,
                 job_num,
                 primary_key1
               )
               select     /*+ no_merge parallel(z) */ distinct 4,
                    1,
                    lid
               from     (
                     select     /*+ no_merge PARALLEL(A) */
                           a.invoice_line_id lid
                     from     FII_AR_REVENUE_STG A
                     union all
                     select     /*+ ordered parallel(b) parallel(y)
                                    pq_distibute(y, none, broadcast) */
                          decode(y.a,
                          1,
                          b.from_cust_trx_line_id,
                          b.to_cust_trx_line_id) lid
                     from ( select /*+ no_merge */ 1 a, org_id
                            from ar_system_parameters_all
                            union all
                            select 2 a, org_id
                            from ar_system_parameters_all ) y,
                          ar_revenue_adjustments_all b
                     where y.org_id = b.org_id
                     union all
                     select     /*+ PARALLEL(line) PARALLEL(rule) */
                          line.CUSTOMER_TRX_LINE_ID lid
                     from     ra_customer_trx_lines_all line,
                              RA_RULES rule
                     where     line.ACCOUNTING_RULE_ID = rule.RULE_ID
                     and     rule.DEFERRED_REVENUE_FLAG = ''Y''' ||l_stmt2|| '
                     ) z
               where     lid is not null ';

        if g_debug_flag = 'Y' then
            fii_util.put_line('');
    --      fii_util.put_line(l_stmt);
            fii_util.start_timer;
        end if;

        EXECUTE IMMEDIATE l_stmt;
        l_count := SQL%ROWCOUNT;

        if g_debug_flag = 'Y' then
            fii_util.put_line('');
            fii_util.stop_timer;
            fii_util.print_timer('Duration');
        end if;

    END IF;

    COMMIT;

  FND_STATS.gather_table_stats
           (ownname => g_fii_schema,
            tabname => 'FII_AR_REVENUE_ID');

  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  fii_util.put_line('Altering session enable parallel DML after FND_STATS call, bug  4127183.');

    RETURN(l_count);

EXCEPTION
    WHEN OTHERS THEN
        g_retcode := -2;
        g_errbuf := '
        ---------------------------------
        Error in Procedure: IDENTIFY_CHANGE_INIT
               Parameter: p_type='||p_type||'
               Section: '||g_section||'
               Message: '||sqlerrm;
        RAISE g_procedure_failure;

END IDENTIFY_CHANGE_INIT;

-----------------------------------------------------------
-- FUNCTION CHECK_SLG_ASSIGNMENT
-----------------------------------------------------------
FUNCTION CHECK_SLG_ASSIGNMENT RETURN BOOLEAN IS
        l_result VARCHAR2(20);
        l_count1 number  := 0;
        l_count2 number  := 0;
BEGIN
--        g_section := 'section 10';

  --   if g_debug_flag = 'Y' then
 --       fii_util.put_line(g_section);
   --  end if;

        SELECT NVL(item_value, 'N')
        INTO l_result
        FROM fii_change_log
        WHERE log_item = 'AR_RESUMMARIZE';

      IF l_result = 'Y' THEN
             -- Bug 4942753: Change to return 1 if any row exists
             BEGIN
               SELECT 1
                 INTO l_count1
                 FROM fii_ar_revenue_b
                WHERE ROWNUM = 1;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_count1 := 0;
             END;

             -- Bug 4942753: Change to return 1 if any row exists
             BEGIN
               SELECT 1
                 INTO l_count2
                 FROM fii_ar_revenue_stg
                WHERE ROWNUM = 1;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_count2 := 0;
             END;

             IF (l_count1 = 0 AND l_count2 = 0)  then
                   UPDATE fii_change_log
                   SET item_value = 'N',
                 last_update_date  = SYSDATE,
                 last_update_login = g_fii_login_id,
                 last_updated_by   = g_fii_user_id
                   WHERE log_item = 'AR_RESUMMARIZE'
                     AND item_value = 'Y';

                   COMMIT;
                   RETURN FALSE;
             ELSE
                   RETURN TRUE;
             END IF;
      END IF;

      RETURN FALSE;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
            RETURN FALSE;

 WHEN OTHERS THEN
  g_retcode := -1;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: CHECK_SLG_ASSIGNMENT
           Message: '||sqlerrm;
  RAISE g_procedure_failure;

END CHECK_SLG_ASSIGNMENT;

-----------------------------------------------------------
-- FUNCTION CHECK_PRODUCT_ASSIGNMENT
-----------------------------------------------------------
FUNCTION CHECK_PRODUCT_ASSIGNMENT RETURN BOOLEAN IS
        l_result VARCHAR2(20);
        l_count1 number  := 0;
        l_count2 number  := 0;
BEGIN
        -- g_section := 'section 10';

  --   if g_debug_flag = 'Y' then
   --     fii_util.put_line(g_section);
    --  end if;

        SELECT NVL(item_value, 'N')
        INTO l_result
        FROM fii_change_log
        WHERE log_item = 'AR_PROD_CHANGE';

      IF l_result = 'Y' THEN
             -- Bug 4942753: Change to return 1 if any row exists
             BEGIN
               SELECT 1
                 INTO l_count1
                 FROM fii_ar_revenue_b
                WHERE ROWNUM = 1;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_count1 := 0;
             END;

             -- Bug 4942753: Change to return 1 if any row exists
             BEGIN
               SELECT 1
                 INTO l_count2
                 FROM fii_ar_revenue_stg
                WHERE ROWNUM = 1;
             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 l_count2 := 0;
             END;

             IF (l_count1 = 0 AND l_count2 = 0)  then
                   UPDATE fii_change_log
                   SET item_value = 'N',
                 last_update_date  = SYSDATE,
                 last_update_login = g_fii_login_id,
                 last_updated_by   = g_fii_user_id
                   WHERE log_item = 'AR_PROD_CHANGE'
                     AND item_value = 'Y';

                   COMMIT;
                   RETURN FALSE;
             ELSE
                   RETURN TRUE;
             END IF;
      END IF;

      RETURN FALSE;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
            RETURN FALSE;

 WHEN OTHERS THEN
  g_retcode := -1;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: CHECK_PRODUCT_ASSIGNMENT
           Message: '||sqlerrm;
  RAISE g_procedure_failure;

END CHECK_PRODUCT_ASSIGNMENT;

-----------------------------------------------------------
--  PROCEDURE REGISTER_PREP_JOBS
-----------------------------------------------------------
PROCEDURE REGISTER_PREP_JOBS IS
 l_from_temp    DATE :=Null;
 l_to_temp      DATE :=Null;
 l_count        NUMBER := 0;

BEGIN

  -- ----------------------------------------------
  -- Registering first set of jobs.  Includes
  -- identifying changed records as well as
  -- updating processing tables
  -- ----------------------------------------------
  g_section := 'Section 10';
  if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_line('Registering jobs to handle preperation work');
  fii_util.start_timer;
  end if;

  -- --------------------------------------------------
  -- Registering AR change identification as  separate
  -- jobs broken out by time ranges due to volume
  -- --------------------------------------------------
  if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Registering jobs for AR INV, AR ADJ  trans types: '||
                 to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS')||' to '||
                 to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS'));
  end if;


  -- haritha
  /* Register jobs to get future-dated transactions for 'AR INV' and
       'AR ADJ' */
      INSERT INTO FII_AR_REVENUE_JOBS (
            function,
            phase,
            priority,
            date_parameter1,
            date_parameter2,
            date_parameter3,
            date_parameter4,
            char_parameter1,
            status)
      SELECT
            'IDENTIFY_CHANGE',
            1,
            t.priority,
            g_gl_from_date,
            g_gl_to_date,
            g_lud_from_date,
            g_lud_to_date,
            t.data_type,
            'UNASSIGNED'
      FROM  (SELECT 'AR INV' data_type, 1 priority FROM DUAL UNION ALL
             SELECT 'AR ADJ' data_type, 3 priority FROM DUAL) t;

          l_count := l_count + 2;

      COMMIT;

  -- --------------------------------------------------
  -- Registering change identification for rest of
  -- other data types
  -- --------------------------------------------------
  g_section := 'Section 20';

  if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Registering jobs for AR DL  trans type: '||
                 to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS')||' to '||
                 to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS'));
  end if;

  l_from_temp := g_gl_from_date;
  l_to_temp := least(sysdate,last_day(l_from_temp), l_from_temp+INTERVAL);

  WHILE (l_from_temp <= sysdate )
  LOOP

    INSERT INTO FII_AR_REVENUE_JOBS (
        function,
        phase,
        priority,
        date_parameter1,
        date_parameter2,
        date_parameter3,
        date_parameter4,
        char_parameter1,
        status)
    VALUES (
        'IDENTIFY_CHANGE',
        1,
        3,
        l_from_temp,
        l_to_temp,
        g_lud_from_date,
        g_lud_to_date,
        'AR DL',
        'UNASSIGNED');

    l_from_temp := l_to_temp + ONE_SECOND;
    l_to_temp := least(sysdate,last_day(l_to_temp+1),l_to_temp+INTERVAL);
    l_count := l_count + 1;
  END LOOP;

  COMMIT;

  -- haritha
  /* Register jobs to get future-dated transactions for AR DL*/

     INSERT INTO FII_AR_REVENUE_JOBS (
             function,
             phase,
             priority,
             date_parameter1,
             date_parameter2,
             date_parameter3,
             date_parameter4,
             char_parameter1,
             status)
         VALUES (
             'IDENTIFY_CHANGE',
             1,
             3,
             sysdate + ONE_SECOND,
             g_gl_to_date,
             g_lud_from_date,
             g_lud_to_date,
             'AR DL',
             'UNASSIGNED');

     l_count := l_count + 1;


if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Registered jobs for AR DL: '||l_count||' jobs covering '||
                   to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS')||' to '||
                   to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS'));
 end if;


  -- --------------------------------------------------
  -- Registering remaining miscellaneous jobs
  -- --------------------------------------------------
  g_section := 'Section 30';
  if g_debug_flag = 'Y' then
    fii_util.put_line('');
    fii_util.put_line('Registering remaining misc jobs ');
  end if;

  INSERT INTO FII_AR_REVENUE_JOBS (
        function,
        phase,
        priority,
        date_parameter1,
        date_parameter2,
        status)
  SELECT
        function,
        phase,
        priority,
        g_gl_from_date,
        g_gl_to_date,
        'UNASSIGNED'
  FROM (select 'VERIFY_CCID_UP_TO_DATE' function, 2 phase, 1 priority from dual union all
        select 'REGISTER_EXTRACT_JOBS' function, 3 phase, 1 priority from dual) t;
    --  union all select 'DETECT_DELETED_INV' function, 4 phase, 2 priority from dual ) t;

  l_count := l_count + 2;

if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_line('Registered '||l_count||' jobs');
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
end if;


EXCEPTION
 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: REGISTER_PREP_JOBS
           Section: '||g_section||'
           Message: '||sqlerrm;
  RAISE g_procedure_failure;

END REGISTER_PREP_JOBS;




-----------------------------------------------------------
--  PROCEDURE REGISTER_EXTRACT_JOBS
-----------------------------------------------------------
PROCEDURE REGISTER_EXTRACT_JOBS IS
  -- Constants
  BATCH_SIZE      CONSTANT  NUMBER := 2000000; -- double 1000000
  AR_ADJ_FACTOR   CONSTANT  NUMBER := 9; -- 9 joins * 0.14 ct:adj ratio *
  AR_FACTOR       CONSTANT  NUMBER := 377;   -- 10 joins * 37.7 ct:ctlgd ratio

  -- Variables
  TYPE Batch_Rec IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  l_batch_size              Batch_Rec;
  l_stmt                    VARCHAR2(200);
  l_count                   NUMBER;
  l_priority                NUMBER;
  l_curr_batch              NUMBER;
  l_curr_job_num            NUMBER;

BEGIN

  -- --------------------------------------
  -- Set batch sizes for each type of data
  -- --------------------------------------
  g_section := 'Section 10';
  l_batch_size(3) := TRUNC(BATCH_SIZE / AR_ADJ_FACTOR);
  l_batch_size(4) := TRUNC(BATCH_SIZE / AR_FACTOR);

  -- ---------------------------------
  -- Loop to register the jobs
  -- Drop index to improve performance
  -- ---------------------------------
  g_section := 'Section 50';
  if g_debug_flag = 'Y' then
    fii_util.put_line('');
    fii_util.put_line('Register extraction jobs');
  end if;

  l_curr_job_num := 1;
  FOR l_view_type_id in 3..4 LOOP

    g_section := 'Section 60';
    if g_debug_flag = 'Y' then
      fii_util.start_timer;
    end if;


    insert into fii_ar_revenue_id (
      view_type_id,
      job_num,
      primary_key1)
    select
      l_view_type_id,
      l_curr_job_num + ceil(rownum / l_batch_size(l_view_type_id)) - 1,
      primary_key1
    from (select distinct
            primary_key1
          from fii_ar_revenue_id
          where view_type_id = l_view_type_id + 4) t;


    l_count := nvl(SQL%ROWCOUNT,0);
    if g_debug_flag = 'Y' then
      fii_util.put_line('');
      fii_util.put_timestamp;
      fii_util.put_line('Registered '||
                      ceil(l_count / l_batch_size(l_view_type_id))||
                     ' job(s) for view type '||l_view_type_id);
      fii_util.stop_timer;
      fii_util.print_timer('Duration');
    end if;
    commit;

    WHILE (l_count > 0) LOOP

      g_section := 'Section 70';

      -- -----------------------------------
      -- priority set based on batch size
      -- -----------------------------------
      l_curr_batch := least(l_batch_size(l_view_type_id), l_count);

      IF (l_curr_batch >= 0.75 * l_batch_size(l_view_type_id)) THEN
        l_priority := 1;
      ELSIF (l_curr_batch <= 0.25 * l_batch_size(l_view_type_id)) THEN
        l_priority := 3;
      ELSE
        l_priority := 2;
      END IF;

      insert into FII_AR_REVENUE_JOBS (
          function,
          phase,
          priority,
          number_parameter1,
          number_parameter2,
          status)
      values (
          'POPULATE_STG',
          4,
          l_priority,
          l_view_type_id,
          l_curr_job_num,
          'UNASSIGNED' );

      l_curr_job_num := l_curr_job_num + 1;
      l_count := l_count - l_curr_batch;

    END LOOP;
    commit;

  END LOOP;

return;
EXCEPTION
 WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: REGISTER_EXTRACT_JOBS
           Section: '||g_section||'
           Message: '||sqlerrm;
  raise g_procedure_failure;

END REGISTER_EXTRACT_JOBS;

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
   l_dummy         boolean;
   l_submit_failed EXCEPTION;
   l_call_status   boolean;

BEGIN
-- DEBUG
--  return;

  if g_debug_flag = 'Y' then
   FII_UTIL.put_line('Calling Procedure: VERIFY_CCID_UP_TO_DATE');
   FII_UTIL.put_line('');
  end if;

   g_section := 'Section 10';
--  if g_debug_flag = 'Y' then
 --  FII_UTIL.put_line(g_section);
 -- end if;

   IF(FII_GL_CCID_C.NEW_CCID_IN_GL) THEN
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('CCID Dimension is not up to date, calling CCID Dimension update
 program');
    end if;

      l_dummy := FND_REQUEST.SET_MODE(TRUE);

      l_request_id := FND_REQUEST.SUBMIT_REQUEST('FII',
                                                 'FII_GL_CCID_C',
                                                 NULL, NULL, FALSE, 'I');

      commit;

      IF (l_request_id = 0) THEN
         rollback;
         g_retcode := -1;
         raise G_NO_CHILD_PROCESS;
      END IF;

      g_section := 'Section 20';

      l_call_status := FND_CONCURRENT.wait_for_request(l_request_id,
                                                  30, -- interval 30 seconds
                                                  3600, -- waiting max 1 hour
                                                  l_phase,
                                                  l_status,
                                                  l_devphase,
                                                  l_devstatus,
                                                  l_message);

if g_debug_flag = 'Y' then
FII_UTIL.put_line('devphase : ' || l_devphase || ' devstatus: ' || l_devstatus);
end if;

   IF (NVL(l_devphase='COMPLETE' AND l_devstatus='NORMAL', FALSE)) THEN
       if g_debug_flag = 'Y' then
         FII_UTIL.put_line('CCID Dimension populated successfully');
       end if;
      ELSE
      -- if g_debug_flag = 'Y' then
         FII_UTIL.put_line('CCID Dimension populated unsuccessfully');
       --  end if;
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
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Phase: Running CCID program');
         raise;
     WHEN OTHERS Then
         g_retcode := -1;
         FII_UTIL.put_line('
----------------------------
Error in Procedure : VERIFY_CCID_UP_TO_DATE
Section: ' || g_section || '
Message: '||sqlerrm);
         raise;
END VERIFY_CCID_UP_TO_DATE;

---------------------------------------------------
-- FUNCTION LAUNCH_WORKER
---------------------------------------------------

FUNCTION LAUNCH_WORKER(p_worker_no      NUMBER) RETURN NUMBER IS
   l_request_id         NUMBER;


BEGIN
--  DEBUG
   l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          'FII',
                          'FII_AR_REVENUE_B_C_SUBWORKER',
                          NULL,
                          NULL,
                          FALSE,         -- sub request,may need to set true
                          p_worker_no);

   IF (l_request_id = 0) THEN
     rollback;
     g_retcode := -2;
     g_errbuf := '
  ---------------------------------
  Error in Procedure: LAUNCH_WORKER
           Message: '||fnd_message.get;
  raise g_procedure_failure;

   END IF;

   RETURN l_request_id;

EXCEPTION
  WHEN OTHERS THEN
  rollback;
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: LAUNCH_WORKER
           Message: '||sqlerrm;
  raise g_procedure_failure;

END LAUNCH_WORKER;



---------------------------------------------------
-- FUNCTION DETECT_DELETED_INV
---------------------------------------------------
  FUNCTION DETECT_DELETED_INV RETURN NUMBER IS
  l_gl_from     VARCHAR2(80);
  l_gl_to       VARCHAR2(80);
  l_stmt        VARCHAR2(1500);
  l_count       NUMBER;
  l_instance_fk_key NUMBER;
BEGIN

  drop_table('fii_ar_revenue_sum_del1');
  drop_table('fii_ar_revenue_sum_del2');

  l_gl_from := 'to_date('''||to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS')||
                ''',''YYYY/MM/DD HH24:MI:SS'')';
  l_gl_to   := 'to_date('''||to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS')||
                ''',''YYYY/MM/DD HH24:MI:SS'')';

  g_section := 'Section 20';
  l_stmt:='
    CREATE TABLE '||g_fii_schema||'.fii_ar_revenue_sum_del1
    TABLESPACE '||g_tablespace||'
    NOLOGGING storage (initial 4K next 16K MAXEXTENTS UNLIMITED) as
    select distinct
          invoice_id
    from  FII_AR_REVENUE_B
    where transaction_class <> ''ADJ'' ';

 if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Process step 1');
  fii_util.start_timer;
  fii_util.put_line('');
  fii_util.put_line(l_stmt);
 end if;
  execute immediate l_stmt;
 if g_debug_flag = 'Y' then
  fii_util.put_line(' Processed '||SQL%ROWCOUNT||' rows');
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
 end if;
  commit;

  g_section := 'Section 30';
  l_stmt:='
    CREATE TABLE '||g_fii_schema||'.fii_ar_revenue_sum_del2
    TABLESPACE '||g_tablespace||'
    NOLOGGING storage (initial 4K next 16K MAXEXTENTS UNLIMITED) as
    select
           wh.invoice_id invoice_id
    from   '||g_fii_schema||'.fii_ar_revenue_sum_del1 wh,
           ra_customer_trx_all       trx
    where  wh.invoice_id = trx.customer_trx_id (+)
    AND    trx.customer_trx_id IS NULL  ';

if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Process step 2');
  fii_util.start_timer;
  fii_util.put_line('');
  fii_util.put_line(l_stmt);
  fii_util.put_line('');
 end if;
  execute immediate l_stmt;
 if g_debug_flag = 'Y' then
  fii_util.put_line(' Processed '||SQL%ROWCOUNT||' rows');
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
 end if;
  commit;


  g_section := 'Section 40';
  l_stmt:='
   delete from FII_AR_REVENUE_B
     where transaction_class <> ''ADJ''
     and invoice_id in (select invoice_id
   FROM  '||g_fii_schema||'.fii_ar_revenue_sum_del2) ';

if g_debug_flag = 'Y' then
  fii_util.put_line('');
  fii_util.put_line('Process step 3');
  fii_util.start_timer;
  fii_util.put_line('');
  fii_util.put_line(l_stmt);
  fii_util.put_line('');
end if;
  execute immediate l_stmt;
  l_count := SQL%ROWCOUNT;
if g_debug_flag = 'Y' then
  fii_util.put_line('Identified '||l_count||' invoices deleted in transaction system');
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
end if;
  commit;

  drop_table('fii_ar_revenue_sum_del1');
  drop_table('fii_ar_revenue_sum_del2');

  return(l_count);

EXCEPTION
  WHEN OTHERS THEN
  rollback;
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: DETECT_DELETED_INV
           Section: '||g_section||'
           Message: '||sqlerrm;
  raise g_procedure_failure;

END DETECT_DELETED_INV;



-- -------------------------------
-- PROCEDURE DUPLICATE_RECORDS
-- identifying and deleting duplicate records from the base summary table
---------------------------------


-----------------------------------------------------------
--PROCEDURE CHILD_SETUP
-----------------------------------------------------------
PROCEDURE CHILD_SETUP(p_object_name VARCHAR2) IS
  l_dir         VARCHAR2(400);
  l_stmt        VARCHAR2(100);
BEGIN


        ------------------------------------------------------
        -- Set default directory in case if the profile option
        -- BIS_DEBUG_LOG_DIRECTORY is not set up
        ------------------------------------------------------
        l_dir:=FII_UTIL.get_utl_file_dir;
-- DEBUG
--        l_dir:='/sqlcom/log/olaptrw';

        ----------------------------------------------------------------
        -- fii_util.initialize will get profile options FII_DEBUG_MODE
        -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
        -- the log files and output files are written to
        ----------------------------------------------------------------
        fii_util.initialize(p_object_name||'.log',p_object_name||'.out',l_dir, 'FII_AR_REVENUE_B_C_SUBWORKER');

         g_fii_user_id := FND_GLOBAL.User_Id;
         g_fii_login_id := FND_GLOBAL.Login_Id;

EXCEPTION
        WHEN OTHERS THEN
                rollback;
                g_retcode := -1;
                g_errbuf := '
  ---------------------------------
  Error in Procedure: CHILD_SETUP
           Message: '||sqlerrm;
                raise g_procedure_failure;
END CHILD_SETUP;

------------------------------------------------------------------------------
-- FUNCTION REV_ACCTS_CHANGED
-- Check whether there are any deletions to natural accounts assigned
-- to 'R' or 'DR'.
-- If yes, then give a message to truncate the base summary table and
-- re-run the load program.
------------------------------------------------------------------------------
FUNCTION REV_ACCTS_CHANGED RETURN BOOLEAN IS
    l_stmt        varchar2(2000);
    l_change_1    number :=0;

BEGIN
           ---------------------------------------------------------
           -- to check whether there are any deletions to natural
           -- accounts assigned to 'Revenue'.  Only when deletion
           -- happens do we ask the user to truncate Revenue summary
           -- and reload.  If new accounts were added to 'Revenue'
           -- users do not need to truncate Revenue summary, this
           -- program will insert the new accounts into FII_AR_REV_ACCTS
           -- after it populates the Revenue summary table
           ---------------------------------------------------------
           g_section := 'Section 10';
           drop_table('fii_ar_rev_accts_temp');

           if g_debug_flag = 'Y' then
               FII_UTIL.put_line('Creating temp table FII_AR_REV_ACCTS_TEMP');
               fii_util.start_timer;
           end if;

           g_section := 'Section 20';

           /*
           l_stmt:='
              CREATE TABLE '||g_fii_schema||'.fii_ar_rev_accts_temp
              TABLESPACE '||g_tablespace||'
              NOLOGGING STORAGE (INITIAL 4K NEXT 16K MAXEXTENTS UNLIMITED) AS
              SELECT fin_category_id cur_rev_acct_id,
                     fin_cat_type_code cur_fin_cat_type_code
              FROM fii_fin_cat_type_assgns ffcta
              WHERE ffcta.fin_cat_type_code in (''R'', ''DR'') ';
           */
           l_stmt:='
              CREATE TABLE '||g_fii_schema||'.fii_ar_rev_accts_temp
              TABLESPACE '||g_tablespace||'
              NOLOGGING STORAGE (INITIAL 4K NEXT 16K MAXEXTENTS UNLIMITED) AS
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   '''||g_program_code_R||''',  ''R'',
                                   '''||g_program_code_DR||''', ''DR'',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code in ('''||g_program_code_R||''',
                                                '''||g_program_code_DR||''')
                     AND XAD.Enabled_Flag = ''Y''
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
              SELECT * FROM ACCNT_CLASS ';

           EXECUTE IMMEDIATE l_stmt;

           if g_debug_flag = 'Y' then
               fii_util.stop_timer;
               fii_util.print_timer('Duration');
           end if;

           g_section := 'Section 30';

           /*
           l_stmt:= '
           SELECT COUNT(*)
           FROM fii_ar_rev_accts fra,
           '||g_fii_schema||'.fii_ar_rev_accts_temp temp
           WHERE fra.rev_acct_id = temp.cur_rev_acct_id(+)
           AND   fra.fin_cat_type_code = temp.cur_fin_cat_type_code(+)
           AND   temp.cur_rev_acct_id IS NULL ';
           */
           l_stmt:= '
           SELECT COUNT(*)
           FROM fii_ar_rev_accts fra
           WHERE NOT EXISTS (
               SELECT 1
               FROM '||g_fii_schema||'.fii_ar_rev_accts_temp temp
               WHERE ( fra.rev_acct_id = temp.Ledger_ID
                    OR temp.Ledger_ID IS NULL )
               AND   fra.rev_acct = temp.Accounting_Class_Code
               AND   fra.fin_cat_type_code = temp.Fin_Cat_Type_Code
           ) ';

           EXECUTE IMMEDIATE l_stmt INTO l_change_1;

           IF  l_change_1 > 0   THEN
                RETURN TRUE;
           ELSE
                RETURN FALSE;
           END IF;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            g_retcode := -2;
            g_errbuf := '
          ---------------------------------
          Error in Procedure: REV_ACCTS_CHANGED
           Section: '||g_section||'
          Message: '||sqlerrm;
          RAISE g_procedure_failure;
END REV_ACCTS_CHANGED;

PROCEDURE AR_STG (p_sort_area_size IN NUMBER,
                  p_hash_area_size IN NUMBER,
                  p_parallel_query IN NUMBER) IS

l_stmt      VARCHAR2(1000);
l_section              VARCHAR2(20) := NULL;

BEGIN

l_section := 'Section 10';

l_stmt := 'alter session set workarea_size_policy=manual';
execute immediate l_stmt;
l_stmt := 'alter session set sort_area_size=' || p_sort_area_size;
execute immediate l_stmt;
l_stmt := 'alter session set hash_area_size= ' ||p_hash_area_size;
execute immediate l_stmt;


l_section := 'Section 20';

if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_line('Loading data into staging table');
  fii_util.start_timer;
  fii_util.put_line('');
end if;

-- Bug 4942753: Per Lester's suggestion, reordered the XLA tables and
--              add date filters on the transaction tables adj and ctlgd
INSERT /*+ APPEND PARALLEL(F) */ INTO  FII_AR_REVENUE_STG F (
    REVENUE_PK,
    GL_DATE_ID,
    GL_DATE,
    INVENTORY_ITEM_ID,
    OPERATING_UNIT_ID,
    COMPANY_ID,
    COST_CENTER_ID,
    INVOICE_NUMBER,
    INVOICE_DATE,
    ORDER_LINE_ID,
    BILL_TO_PARTY_ID,
    FUNCTIONAL_CURRENCY,
    TRANSACTION_CURRENCY,
    LEDGER_ID,
    INVOICE_ID,
    AMOUNT_T,
    AMOUNT_B,
    EXCHANGE_DATE,
    TOP_MODEL_ITEM_ID,
    ORGANIZATION_ID,
    item_organization_id,
    om_product_revenue_flag,
    TRANSACTION_CLASS,
    FIN_CATEGORY_ID,
    INVOICE_LINE_ID,
    SALES_CHANNEL,
    ORDER_NUMBER,
    POSTED_FLAG,
    PRIM_CONVERSION_RATE,
    SEC_CONVERSION_RATE,
    PROD_CATEGORY_ID,
    CHART_OF_ACCOUNTS_ID,
    FIN_CAT_TYPE_CODE,
    REV_BOOKED_DATE,
    CHILD_ORDER_LINE_ID)
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   g_program_code_R,  'R',
                                   g_program_code_DR, 'DR',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code in (g_program_code_R,
                                                g_program_code_DR)
                     AND XAD.Enabled_Flag = 'Y'
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
SELECT  /*+ ORDERED use_hash(v1,gcc,ccdim,slga,fslg,ctl_parent,bill_acct,ct,ctl)
         use_hash(ctl) use_nl(sob,ctt) pq_distribute(ct,hash,hash) */ DISTINCT
    decode(v1.transaction_class,'ADJ','ADJ-'||v1.REVENUE_PK,'AR-'||v1.REVENUE_PK||'-'||to_char(v1.gl_date,'YYYY/MM/DD')
        ||'-'||v1.code_combination_id)              REVENUE_PK,
    to_number(to_char(v1.gl_date,'J'))              GL_DATE_ID,
--Bug 3455965: use TRUNC for date
    TRUNC(v1.gl_date)                                               GL_DATE,
--  ctl_parent.inventory_item_id                                    INVENTORY_ITEM_ID,
        CASE
             when  (ctl_parent.line_type like  'LINE'
                    and    ctl_parent.inventory_item_id = sl_child.inventory_item_id
                       and    sl_child.ship_from_org_id   IS NOT NULL )
                       THEN  ctl_parent.inventory_item_id
             when  (ctl_parent.line_type like  'LINE'  and ctl_parent.WAREHOUSE_ID  IS NOT NULL)
                        THEN  ctl_parent.inventory_item_id
                  ELSE
              to_number(NULL)

       END                                                                 INVENTORY_ITEM_ID,
--bug 3361888
    DECODE(v1.transaction_class, 'ADJ', v1.org_id, ct.org_id)           OPERATING_UNIT_ID,
            ccdim.company_id COMPANY_ID,
            ccdim.cost_center_id COST_CENTER_ID,
    substrb(ct.trx_number,1,30)                                     INVOICE_NUMBER,
    trunc(ct.trx_date)                                              INVOICE_DATE,
    DECODE(ctl_parent.line_type, 'LINE', DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
            DECODE(ctl_parent.interface_line_context, 'ORDER ENTRY', sl_parent.line_id,
            'INTERCOMPANY', sl_parent.line_id, to_number(NULL)), to_number(NULL)),
        to_number(NULL))                                        ORDER_LINE_ID,
    bill_acct.party_id                                              BILL_TO_PARTY_ID,
    sob.currency_code                                               FUNCTIONAL_CURRENCY,
    nvl(ct.invoice_currency_code,sob.currency_code)                 TRANSACTION_CURRENCY,
--bug 3361888
    DECODE(v1.transaction_class, 'ADJ', v1.set_of_books_id, ct.set_of_books_id)
                                                                        SET_OF_BOOKS_ID,
    ct.customer_trx_id                                              INVOICE_ID,
    nvl2(v1.transaction_class,decode(gcc.account_type,'A', nvl(v1.amount_dr,0) - nvl(v1.amount_cr,0),
        nvl(v1.amount_cr,0) - nvl(v1.amount_dr,0)), AMOUNT_DR)  AMOUNT_T,
    nvl2(v1.transaction_class,decode(gcc.account_type,'A', nvl(v1.acctd_amount_dr,0) - nvl(v1.acctd_amount_cr,0),
        nvl(v1.acctd_amount_cr,0) - nvl(v1.acctd_amount_dr,0)),
        ACCTD_AMOUNT_DR)                    AMOUNT_B,
    trunc(nvl2(v1.transaction_class,v1.gl_date,ct.trx_date))    EXCHANGE_DATE,
/*  DECODE(ctl_parent.line_type, 'LINE', DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
        DECODE(ctl_parent.interface_line_context, 'ORDER ENTRY', sl_parent.inventory_item_id,
            'INTERCOMPANY', sl_parent.inventory_item_id, to_number(NULL)), to_number(NULL)),
            to_number(NULL))                                TOP_MODEL_ITEM_ID,
    DECODE(ctl_parent.line_type, 'LINE', DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
        DECODE(ctl_parent.interface_line_context, 'ORDER ENTRY', sl_parent.ship_from_org_id, 'INTERCOMPANY',
        sl_parent.ship_from_org_id, to_number(NULL)), to_number(NULL)),
         to_number(NULL))                                       ORGANIZATION_ID,
    DECODE(ctl_parent.line_type, 'LINE', DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
        DECODE(ctl_parent.interface_line_context, 'ORDER ENTRY', sl_child.ship_from_org_id, 'INTERCOMPANY',
        sl_child.ship_from_org_id, to_number(NULL)), to_number(NULL)),
         to_number(NULL))                                       item_organization_id, */
     CASE
           when ( ctl_parent.line_type like  'LINE'
                     and  ctl_parent.inventory_item_id = sl_child.inventory_item_id
                     and  sl_parent.ship_from_org_id IS NOT NULL)
                    THEN   sl_parent.inventory_item_id
              ELSE
                    to_number(NULL)
     END                                                                  TOP_MODEL_ITEM_ID,
     DECODE(ctl_parent.line_type, 'LINE',
           DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                  sl_parent.ship_from_org_id, to_number(null)),
                to_number(NULL) )                                      ORGANIZATION_ID,
     DECODE(ctl_parent.line_type, 'LINE',
           DECODE(ctl_parent.inventory_item_id, sl_child.inventory_item_id,
                      sl_child.ship_from_org_id, ctl_parent.WAREHOUSE_ID ),
       to_number(NULL))                                                item_organization_id,
     decode(ctl_parent.interface_line_context, 'ORDER ENTRY',
       decode(nvl( sl_child.item_type_code, 'X' ), 'SERVICE',
       'N', 'Y'),
     'N')                                                       om_product_revenue_flag,
    nvl(v1.transaction_class,decode(ctt.type,'GUAR','GUR',substrb(ctt.type,1,3)))   TRANSACTION_CLASS,
    ccdim.natural_account_id FIN_CATEGORY_ID,
    nvl(v1.customer_trx_line_id,ctl.customer_trx_line_id)           INVOICE_LINE_ID,
    nvl(substrb(sh.sales_channel_code,1,30), '-1')                  SALES_CHANNEL,
    substrb( DECODE(ctl_parent.interface_line_context, 'ORDER ENTRY',ctl_parent.interface_line_attribute1,
        'INTERCOMPANY', ctl_parent.interface_line_attribute1,
        ctl_parent.sales_order),1,30)                           ORDER_NUMBER,
    v1.POSTED_FLAG,
    -1                              PRIM_CONVERSION_RATE,
    -1                              SEC_CONVERSION_RATE,
    ccdim.prod_category_id PROD_CATEGORY_ID,
    sob.chart_of_accounts_id                                        CHART_OF_ACCOUNTS_ID,
    -- ffcta.fin_cat_type_code FIN_CAT_TYPE_CODE,
    v1.fin_cat_type_code FIN_CAT_TYPE_CODE,
        decode(sh.booked_flag, 'Y', trunc(nvl(sl_child.order_firmed_date,
                           sh.booked_date)), to_date(null))             REV_BOOKED_DATE,
        decode(ctl.interface_line_context, 'ORDER ENTRY',ctl.interface_line_attribute6,
        null)                                                CHILD_ORDER_LINE_ID
FROM    (select /*+ PARALLEL(a) */ * from fii_source_ledger_groups a)   fslg,
        (select /*+ PARALLEL(a) */ * from fii_slg_assignments a)        slga,
        (select /*+ PARALLEL(a) */ * from fii_gl_ccid_dimensions a) ccdim,
        -- (select /*+ PARALLEL(a) */ * from fii_fin_cat_type_assgns a)  ffcta,
        (select /*+ PARALLEL(a) */ * from gl_code_combinations a)   gcc,
        (
    SELECT  /*+ PARALLEL(adj) PARALLEL(ad) parallel(lidset)
                PARALLEL(AC) PARALLEL(lnk) PARALLEL(ael) PARALLEL(aeh) */
        ad.line_id  REVENUE_PK,
        trunc(aeh.accounting_date)  GL_DATE,
        adj.org_id,
        aeh.ledger_id               SET_OF_BOOKS_ID,
        sum( NVL(lnk.unrounded_entered_dr,0) )   AMOUNT_DR,
        sum( NVL(lnk.unrounded_entered_cr,0) )   AMOUNT_CR,
        sum( NVL(lnk.unrounded_accounted_dr,0) ) ACCTD_AMOUNT_DR,
        sum( NVL(lnk.unrounded_accounted_cr,0) ) ACCTD_AMOUNT_CR,
        'ADJ' TRANSACTION_CLASS,
        0 customer_trx_line_id,
        adj.customer_trx_id,
        ael.code_combination_id,
        'Y' POSTED_FLAG,
        AC.Fin_Cat_Type_Code
    FROM    ar_adjustments_all              adj,
            ar_distributions_all            ad,
            (
            select /*+ no_merge use_hash(slga,fslg) */ distinct ledger_id
            from fii_slg_assignments slga, fii_source_ledger_groups fslg
            where slga.source_ledger_group_id = fslg.source_ledger_group_id
            and fslg.usage_code = g_usage_code
            ) lidset,
            ACCNT_CLASS AC,
            xla_distribution_links lnk,
            xla_ae_lines ael,
            xla_ae_headers aeh
    WHERE   aeh.accounting_date BETWEEN g_gl_from_date AND g_gl_to_date
    AND     adj.gl_date BETWEEN g_gl_from_date AND g_gl_to_date
    AND     NVL(adj.status, 'A')  = 'A'
    AND     NVL(adj.postable,'Y') = 'Y'
    -- AND      adj.amount <> 0
    AND     ad.source_id = adj.adjustment_id
    AND     ad.source_table = 'ADJ'
    AND aeh.ledger_id = lidset.ledger_id
    AND aeh.application_id = 222
    AND aeh.balance_type_code = 'A'
    AND aeh.gl_transfer_status_code = 'Y'
    AND ael.application_id = 222
    AND aeh.ae_header_id = ael.ae_header_id
    AND lnk.application_id = 222
    AND ael.ae_header_id = lnk.ae_header_id
    AND ael.ae_line_num = lnk.ae_line_num
    AND lnk.source_distribution_type = 'AR_DISTRIBUTIONS_ALL'
    AND lnk.source_distribution_id_num_1 = ad.line_id
    AND aeh.ledger_id = adj.set_of_books_id
    AND ael.accounting_class_code = AC.Accounting_Class_Code
    AND ( aeh.ledger_id = AC.Ledger_ID OR AC.Ledger_ID IS NULL )
    group by
        ad.line_id,
        trunc(aeh.accounting_date),
        adj.org_id,
        aeh.ledger_id,
        adj.customer_trx_id,
        ael.code_combination_id,
        AC.Fin_Cat_Type_Code
    UNION ALL
    SELECT  /*+ PARALLEL(ctlgd) parallel(lidset)
                PARALLEL(AC) PARALLEL(lnk) PARALLEL(ael) PARALLEL(aeh) */
            ctlgd.customer_trx_line_id  REVENUE_PK,
            trunc(aeh.accounting_date),
            to_number(null),  -- ctlgd.org_id,
            to_number(null),  -- ctlgd.set_of_books_id,
            sum( NVL(lnk.unrounded_entered_cr,0) - NVL(lnk.unrounded_entered_dr,0) ) AMOUNT_T,
            0,
            sum( NVL(lnk.unrounded_accounted_cr,0) - NVL(lnk.unrounded_accounted_dr,0) ) AMOUNT_B,
            0,
            NULL                    TRANSACTION_CLASS,
            ctlgd.customer_trx_line_id,
            NULL,
            ael.code_combination_id,
            'Y' POSTED_FLAG,
            AC.Fin_Cat_Type_Code
    FROM    ra_cust_trx_line_gl_dist_all    ctlgd,
            (
            select /*+ no_merge use_hash(slga,fslg) */ distinct ledger_id
            from fii_slg_assignments slga, fii_source_ledger_groups fslg
            where slga.source_ledger_group_id = fslg.source_ledger_group_id
            and fslg.usage_code = g_usage_code
            ) lidset,
            ACCNT_CLASS AC,
            xla_distribution_links lnk,
            xla_ae_lines ael,
            xla_ae_headers aeh
    WHERE aeh.accounting_date BETWEEN g_gl_from_date AND g_gl_to_date
    AND ctlgd.gl_date BETWEEN g_gl_from_date AND g_gl_to_date
    AND ctlgd.account_set_flag = 'N'
    AND NVL(lnk.unrounded_entered_cr,0) - NVL(lnk.unrounded_entered_dr,0) <> 0
    AND aeh.ledger_id = lidset.ledger_id
    AND ctlgd.customer_trx_line_id IS NOT NULL
    AND aeh.application_id = 222
    AND aeh.balance_type_code = 'A'
    AND aeh.gl_transfer_status_code = 'Y'
    AND ael.application_id = 222
    AND aeh.ae_header_id = ael.ae_header_id
    AND lnk.application_id = 222
    AND ael.ae_header_id = lnk.ae_header_id
    AND ael.ae_line_num = lnk.ae_line_num
    AND lnk.source_distribution_type = 'RA_CUST_TRX_LINE_GL_DIST_ALL'
    AND lnk.source_distribution_id_num_1 = ctlgd.cust_trx_line_gl_dist_id
    AND aeh.ledger_id = ctlgd.set_of_books_id
    AND ael.accounting_class_code = AC.Accounting_Class_Code
    AND ( aeh.ledger_id = AC.Ledger_ID OR AC.Ledger_ID IS NULL )
    GROUP   BY ctlgd.customer_trx_line_id,
            trunc(aeh.accounting_date),
            ael.code_combination_id,
            AC.Fin_Cat_Type_Code
    ) v1,
    (select /*+ PARALLEL(a) */ * from ra_customer_trx_lines_all a) ctl,
    (select /*+ PARALLEL(a) */ * from ra_customer_trx_all a)    ct,
           --**bug 3437052: move sob 2 places down
        (select /*+ PARALLEL(a) */ * from gl_ledgers_public_v a) sob,
        (select /*+ PARALLEL(a) */ * from ra_cust_trx_types_all a)  ctt,
    (select /*+ PARALLEL(a) */ * from hz_cust_accounts a)        bill_acct  ,
    (select /*+ PARALLEL(a) */ * from ra_customer_trx_lines_all a) ctl_parent,
    (select /*+ PARALLEL(a) */ * from oe_order_lines_all a)      sl_child,
    (select /*+ PARALLEL(a) */ * from oe_order_headers_all a)    sh,
    (select /*+ PARALLEL(a) */ * from oe_order_lines_all a)      sl_parent
WHERE   ccdim.code_combination_id = gcc.code_combination_id
  AND   slga.chart_of_accounts_id = ccdim.chart_of_accounts_id
  AND   ( slga.bal_seg_value_id = ccdim.company_id
       OR slga.bal_seg_value_id = -1 )
  AND   slga.ledger_id = DECODE(v1.transaction_class, 'ADJ', v1.set_of_books_id, ct.set_of_books_id)
  -- AND   ffcta.fin_category_id = ccdim.natural_account_id
  -- AND   ffcta.fin_cat_type_code in ('R', 'DR')
  AND   ctl_parent.customer_trx_line_id (+) =
            nvl(ctl.previous_customer_trx_line_id,ctl.customer_trx_line_id)
  AND   sl_child.line_iD (+) =
           case when (ctl_parent.interface_line_context in ('ORDER ENTRY', 'INTERCOMPANY')
                      and ltrim(ctl_parent.interface_line_attribute6, '0123456789') is NULL)
                then  to_number(ctl_parent.interface_line_attribute6)
                else  to_number(NULL) end
  AND   sh.header_id (+) = sl_child.header_id
  AND   sl_parent.line_id(+) = NVL(sl_child.top_model_line_id, sl_child.line_id)
                              --**bug 3361888
  AND   sob.ledger_id = DECODE(v1.transaction_class, 'ADJ', v1.set_of_books_id, ct.set_of_books_id)
  AND   gcc.code_combination_id = v1.code_combination_id
  AND   bill_acct.cust_account_id(+) = ct.bill_to_customer_id
  AND   ct.complete_flag = 'Y'
  AND   nvl(ctl.interface_line_context, 'xxx') <> 'PA INVOICES'
  AND   ctl.customer_trx_line_id (+) = v1.customer_trx_line_id
  AND   ct.customer_trx_id = DECODE(v1.transaction_class,'ADJ',v1.customer_trx_id,ctl.customer_trx_id)
  AND   nvl(ct.org_id, -999) = DECODE(v1.transaction_class,'ADJ',nvl(v1.org_id, -999),nvl(ct.org_id, -999))
  AND   ctt.cust_trx_type_id(+) = ct.cust_trx_type_id
  AND   ctt.org_id (+) = ct.org_id
  AND   slga.source_ledger_group_id = fslg.source_ledger_group_id
  AND   fslg.usage_code = g_usage_code
  AND   NVL(ctt.post_to_gl,'Y') = 'Y';

  if g_debug_flag = 'Y' then
    fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into staging table.');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  end if;

  commit;

  EXCEPTION

  WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: AR_STG
           Section: '||l_section||'
           Message: '||sqlerrm;
  raise g_procedure_failure;

END AR_STG;

PROCEDURE AR_RATES IS

   l_global_prim_curr_code  VARCHAR2(30);
   l_global_sec_curr_code   VARCHAR2(30);
   l_stmt VARCHAR2(200);

BEGIN

   l_global_prim_curr_code := bis_common_parameters.get_currency_code;
   l_global_sec_curr_code  := bis_common_parameters.get_secondary_currency_code;

if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_line('Loading data into rates table');
  fii_util.start_timer;
  fii_util.put_line('');
end if;


insert into fii_ar_revenue_rates_temp
(FUNCTIONAL_CURRENCY,
 TRX_DATE,
 PRIM_CONVERSION_RATE,
 SEC_CONVERSION_RATE)
    select cc functional_currency,
       dt trx_date,
       decode(cc, l_global_prim_curr_code, 1, FII_CURRENCY.GET_GLOBAL_RATE_PRIMARY (cc,least(dt, sysdate))) PRIM_CONVERSION_RATE,
       decode(cc, l_global_sec_curr_code, 1, FII_CURRENCY.GET_GLOBAL_RATE_SECONDARY(cc,least(dt, sysdate))) SEC_CONVERSION_RATE
    from (
       select /*+ no_merge parallel(stg) */ distinct
              FUNCTIONAL_CURRENCY cc,
              TRUNC(GL_DATE) dt
       from FII_AR_REVENUE_STG stg
    );

   if g_debug_flag = 'Y' then
     fii_util.put_line('Processed '||SQL%ROWCOUNT||' rows into rates table');
     fii_util.stop_timer;
     fii_util.print_timer('Duration');
   end if;

  EXCEPTION

  WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: AR_RATES
           Message: '||sqlerrm;
  raise g_procedure_failure;


END AR_RATES;

PROCEDURE AR_SUMMARY (p_parallel_query IN NUMBER) IS

seq_id  NUMBER := 0;
l_stmt  VARCHAR2(1000);


BEGIN

    if g_debug_flag = 'Y' then
      fii_util.put_line(' ');
          fii_util.put_line('Started loading data into base summary table');
          fii_util.start_timer;
          fii_util.put_line('');
        end if;

    SELECT FII_AR_REVENUE_B_S.nextval INTO seq_id FROM dual;

        INSERT   /*+ APPEND PARALLEL(F) */ INTO FII_AR_REVENUE_B F (
                REVENUE_PK,
                GL_DATE_ID,
                GL_DATE,
                INVENTORY_ITEM_ID,
                OPERATING_UNIT_ID,
--commented by ilavenil                COMPANY_COST_CENTER_ORG_ID,
                COMPANY_ID,
                COST_CENTER_ID,
--above columns added by ilavenil
                INVOICE_NUMBER,
                ORDER_LINE_ID,
                BILL_TO_PARTY_ID,
                FUNCTIONAL_CURRENCY,
                TRANSACTION_CURRENCY,
                LEDGER_ID,
                INVOICE_ID,
                AMOUNT_T,
                AMOUNT_B,
                PRIM_AMOUNT_G,
                SEC_AMOUNT_G,
                TOP_MODEL_ITEM_ID,
                ORGANIZATION_ID,
                item_organization_id,
                om_product_revenue_flag,
                TRANSACTION_CLASS,
                FIN_CATEGORY_ID,
                ORDER_NUMBER,
                SALES_CHANNEL,
                INVOICE_LINE_ID,
                LAST_UPDATE_DATE,
                CREATION_DATE,
                POSTED_FLAG,
                PROD_CATEGORY_ID,
                CHART_OF_ACCOUNTS_ID,
                UPDATE_SEQUENCE,
                LAST_UPDATED_BY,
                CREATED_BY,
                LAST_UPDATE_LOGIN,
                INVOICE_DATE,
                FIN_CAT_TYPE_CODE,
                REV_BOOKED_DATE,
                CHILD_ORDER_LINE_ID)
        SELECT /*+ ORDERED PARALLEL(stg) PARALLEL(rates) USE_HASH(stg, rates) */
                stg.REVENUE_PK,
                stg.GL_DATE_ID,
                stg.GL_DATE,
                stg.INVENTORY_ITEM_ID,
                stg.OPERATING_UNIT_ID,
--commented by ilavenil                stg.COMPANY_COST_CENTER_ORG_ID,
                stg.company_id COMPANY_ID,
                stg.cost_center_id COST_CENTER_ID,
--above 2 columns added by ilavenil
                stg.INVOICE_NUMBER,
                stg.ORDER_LINE_ID,
                stg.BILL_TO_PARTY_ID,
                stg.FUNCTIONAL_CURRENCY,
                stg.TRANSACTION_CURRENCY,
                stg.LEDGER_ID,
                stg.INVOICE_ID,
                stg.AMOUNT_T,
                stg.AMOUNT_B,
                ROUND(stg.AMOUNT_B * NVL(rates.prim_conversion_rate, 1) /
                        to_char(g_mau_prim)) * to_char(g_mau_prim),
                ROUND(stg.AMOUNT_B * NVL(rates.sec_conversion_rate, 1) /
                        to_char(g_mau_sec)) * to_char(g_mau_sec),
                stg.TOP_MODEL_ITEM_ID,
                stg.ORGANIZATION_ID,
                stg.item_organization_id,
                stg.om_product_revenue_flag,
                stg.TRANSACTION_CLASS,
                stg.FIN_CATEGORY_ID,
                stg.ORDER_NUMBER,
                stg.SALES_CHANNEL,
                stg.INVOICE_LINE_ID,
                SYSDATE,
                SYSDATE,
                stg.POSTED_FLAG,
                stg.PROD_CATEGORY_ID,
                stg.CHART_OF_ACCOUNTS_ID,
                seq_id,
                g_fii_user_id,
                g_fii_user_id,
                g_fii_login_id,
                stg.invoice_date,
                stg.fin_cat_type_code,
                stg.REV_BOOKED_DATE,
                stg.CHILD_ORDER_LINE_ID
       FROM  fii_ar_revenue_rates_temp rates, FII_AR_REVENUE_STG stg
       where TRUNC(stg.GL_DATE) = rates.trx_date
       and   stg.functional_currency = rates.functional_currency;

       if g_debug_flag = 'Y' then
         fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows into base summary table.');
         fii_util.stop_timer;
         fii_util.print_timer('Duration');
       end if;

       commit;

  EXCEPTION

  WHEN OTHERS THEN
  g_retcode := -2;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: AR_SUMMARY
           Message: '||sqlerrm;

  if instr(sqlerrm,'ORA-00001') > 0  then
  UNIQUE_CONST_RECORDS;
  end if;

  raise g_procedure_failure;

END AR_SUMMARY;


-----------------------------------------------------------
-- FUNCTION CHECK_GLOBAL_VARIABLES
-----------------------------------------------------------
FUNCTION CHECK_GLOBAL_VARIABLES RETURN BOOLEAN IS

BEGIN
--        g_section := 'section 10';

 --    if g_debug_flag = 'Y' then
  --      fii_util.put_line(g_section);
   --  end if;

   IF  g_gl_from_date IS NULL  THEN
         fii_util.put_line(' ');
         fii_util.put_line(
            'Function CHECK_GLOBAL_VARIABLES: g_gl_from_date is NULL');
         RETURN TRUE;
   ELSIF g_gl_to_date IS NULL  THEN
         fii_util.put_line(' ');
         fii_util.put_line(
            'Function CHECK_GLOBAL_VARIABLES: g_gl_to_date is NULL');
         RETURN TRUE;
   ELSIF (g_gl_to_date < g_gl_from_date) THEN
         fii_util.put_line(' ');
         fii_util.put_line(
            'Function CHECK_GLOBAL_VARIABLES: g_gl_to_date < g_gl_from_date');
         RETURN TRUE;
   ELSIF g_program_type IS NULL  THEN
         fii_util.put_line(' ');
         fii_util.put_line(
            'Function CHECK_GLOBAL_VARIABLES: g_program_type is NULL');
         RETURN TRUE;
   ELSIF g_program_type = 'I' THEN
            IF g_lud_from_date IS NULL THEN
               fii_util.put_line(' ');
               fii_util.put_line(
                  'Function CHECK_GLOBAL_VARIABLES: g_lud_from_date is NULL');
               RETURN TRUE;
            ELSIF g_lud_to_date IS NULL THEN
               fii_util.put_line(' ');
               fii_util.put_line(
                  'Function CHECK_GLOBAL_VARIABLES: g_lud_to_date is NULL');
               RETURN TRUE;
            ELSE
               RETURN FALSE;
            END IF;
   ELSE
         RETURN FALSE;
   END IF;


EXCEPTION

 WHEN OTHERS THEN
  g_retcode := -1;
  g_errbuf := '
  ---------------------------------
  Error in Procedure: CHECK_GLOBAL_VARIABLES
           Message: '||sqlerrm;
  RAISE g_procedure_failure;

END CHECK_GLOBAL_VARIABLES;

-----------------------------------------------------------
-- FUNCTION UPDATE_GLOBAL_START_DATE_TBL
-- Update table FII_GLOBAL_START_DATES if necessary:
--  1. The table does not have exactly one row
--                      OR
--  2. The table has exactly one row,
--     but it is different from p_glbl_strt_dt
-----------------------------------------------------------
FUNCTION UPDATE_GLOBAL_START_DATE_TBL( p_glbl_strt_dt DATE ) RETURN NUMBER IS
    l_count         NUMBER;
    l_glbl_strt_dt  DATE;
    l_updated       NUMBER;
BEGIN
    l_updated := 0;

    select count(*) into l_count
    from FII_GLOBAL_START_DATES;

    if l_count = 1 then
        select GLOBAL_START_DATE into l_glbl_strt_dt
        from FII_GLOBAL_START_DATES;

        if l_glbl_strt_dt <> p_glbl_strt_dt then
            update FII_GLOBAL_START_DATES
            set GLOBAL_START_DATE = p_glbl_strt_dt,
                LAST_UPDATE_DATE  = sysdate,
                LAST_UPDATED_BY   = g_fii_user_id,
                LAST_UPDATE_LOGIN = g_fii_login_id;

            l_updated := 1;
        end if;
    else
        if l_count > 1 then
            TRUNCATE_TABLE('FII_GLOBAL_START_DATES');
        end if;

        insert into FII_GLOBAL_START_DATES(
            GLOBAL_START_DATE,
            CREATION_DATE, CREATED_BY,
            LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN
        )
        values(
            p_glbl_strt_dt,
            sysdate, g_fii_user_id,
            sysdate, g_fii_user_id, g_fii_login_id
        );

        l_updated := 1;
    end if;

    return l_updated;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        g_retcode := -2;
        g_errbuf := '
      ---------------------------------
      Error in Procedure: UPDATE_GLOBAL_START_DATE_TBL
      Message: '||sqlerrm;
      RAISE g_procedure_failure;
END UPDATE_GLOBAL_START_DATE_TBL;

-----------------------------------------------------------
--  PROCEDURE MAIN
-----------------------------------------------------------
PROCEDURE MAIN(Errbuf                  IN OUT  NOCOPY VARCHAR2,
               Retcode                 IN OUT  NOCOPY VARCHAR2,
               p_sob_id                IN      NUMBER,
               p_gl_from_date          IN      VARCHAR2,
               p_gl_to_date            IN      VARCHAR2,
               p_no_worker             IN      NUMBER,
               p_program_type          IN      VARCHAR2,
               p_parallel_query        IN      NUMBER,
               p_sort_area_size        IN      NUMBER,
               p_hash_area_size        IN      NUMBER) IS
 l_count        NUMBER := 0;
l_dup         NUMBER := 0;
 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------
 l_section      VARCHAR2(200) := NULL;
 l_stmt         varchar2(1000);
 l_stg_count    NUMBER := 0;

 -- Declaring local variables to initialize the dates for the
 -- incremental mode
 l_last_start_date    DATE :=NULL;
 l_last_end_date      DATE :=NULL;
 l_last_period_from   DATE :=NULL;
 l_last_period_to1     DATE :=NULL;
 l_last_period_to2     DATE :=NULL;
 l_last_start_date1    DATE :=NULL;
 l_last_start_date2    DATE :=NULL;
 l_gl_from_date1       DATE :=NULL;
 l_gl_from_date2       DATE :=NULL;

 TYPE WorkerList is table of NUMBER
      index by binary_integer;
 l_worker               WorkerList;

 l_global_param_list dbms_sql.varchar2_table;

  l_slg_chg  BOOLEAN;
  l_prd_chg  BOOLEAN;
  l_dir         VARCHAR2(150) := NULL;

BEGIN

  Errbuf :=NULL;
  Retcode:=0;

  l_section := 'M-Section 10';

  g_program_type := p_program_type;

  IF l_dir is null THEN
       l_dir := FII_UTIL.get_utl_file_dir;
  END IF;

   ------------------------------------------------
   -- Initialize API will fetch the FII_DEBUG_MODE
   -- profile option and intialize g_debug variable
   -- accordingly.  It will also read in profile
   -- option BIS_DEBUG_LOG_DIRECTORY to find out
   -- the log directory
   ------------------------------------------------

  IF   g_program_type = 'I'  THEN
   fii_util.initialize('FII_AR_REV_SUM.log','FII_AR_REV_SUM.out',l_dir, 'FII_AR_REVENUE_B_I');
  ELSIF g_program_type = 'L'  THEN
   fii_util.initialize('FII_AR_REV_SUM.log','FII_AR_REV_SUM.out',l_dir, 'FII_AR_REVENUE_B_L');
  END IF;

  IF   g_program_type = 'I'  THEN
      IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_AR_REVENUE_B_I')) THEN
          raise_application_error(-20000,errbuf);
              return;
      END IF;
  ELSIF g_program_type = 'L'  THEN
      IF (NOT BIS_COLLECTION_UTILITIES.setup('FII_AR_REVENUE_B_L')) THEN
              raise_application_error(-20000,errbuf);
              return;
      END IF;
  END IF;

  EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

  fii_util.put_line('Altering session enable parallel DML after BIS_COLLECTION_UTILITIES.setup call, bug  4127183.');

    --------------------------------------------
    -- Initalization
    --------------------------------------------
  l_section := 'M-Section 12';
    IF g_debug_flag = 'Y' then
        fii_util.put_line(' ');
        fii_util.put_line('Calling INIT procedure');
    END IF;
    INIT;

       ----------------------------------------------------
       --  drop table fii_ar_uni_con_rec. This table stores
       --  temporarily records that violated unique constraint
       --  condition when inserting records into FII_AR_REVENUE_B
       --  during previous Load /Update program. If the fii_ar_uni_con_rec doesnot
       --  exist, then nothing is done. The fii_ar_uni_con_rec will
       -- be created if there is any unique constraint violation
       --  during Load /Update program
      -----------------------------------------------------------

   BEGIN
           IF g_debug_flag = 'Y' then
              fii_util.put_line('');
              fii_util.put_line('Dropped temp table fii_ar_uni_con_rec, if it is there.');
           END IF;


        EXECUTE IMMEDIATE 'DROP table fii_ar_uni_con_rec ';


   EXCEPTION
      WHEN OTHERS THEN
        null;
   END;

    -----------------------------------------------------
    -- Calling BIS API to do common set ups
    -- If it returns false, then program should error out
    -----------------------------------------------------
  l_section := 'M-Section 14';
    l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
    l_global_param_list(2) := 'BIS_PRIMARY_CURRENCY_CODE';
    l_global_param_list(3) := 'BIS_PRIMARY_RATE_TYPE';

    IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
             FII_MESSAGE.write_log( msg_name   => 'FII_BAD_GLOBAL_PARA',
                               token_num  => 0);
             FII_MESSAGE.write_output(msg_name   => 'FII_BAD_GLOBAL_PARA',
                               token_num  => 0);
          retcode := -1;
          return;
       END IF;

   g_global_start_date := bis_common_parameters.get_global_start_date;

   IF p_program_type = 'L' THEN
           IF g_debug_flag = 'Y' then
              fii_util.put_line('');
              FII_UTIL.put_line('Running Initial Load, truncate staging and base summary tables.');
           END IF;
-- DEBUG
           TRUNCATE_TABLE('FII_AR_REVENUE_STG');
           TRUNCATE_TABLE('FII_AR_REVENUE_B');
           TRUNCATE_TABLE('FII_AR_REV_ACCTS');
           BIS_COLLECTION_UTILITIES.DELETELOGFOROBJECT('FII_AR_REVENUE_B_I');
           BIS_COLLECTION_UTILITIES.DELETELOGFOROBJECT('FII_AR_REVENUE_B_L');
           COMMIT;
   END IF;

  -------------------------------------------------------------
  -- When running in Initial mode, the default values of the
  -- parameters are defined in the concurrent program seed data
  -------------------------------------------------------------
  l_section := 'M-Section 16';


   IF g_debug_flag = 'Y' then
              fii_util.put_line('');
      FII_UTIL.put_line('Getting start date and end date for which records are to be collected in base summary table.');
   END IF;

   IF p_program_type = 'L' THEN

       g_gl_from_date := trunc(to_date(p_gl_from_date,'YYYY/MM/DD HH24:MI:SS'));

       -- Set g_gl_to_date to at least 7 days in the future.
       g_gl_to_date := trunc(
                greatest( to_date(p_gl_to_date,'YYYY/MM/DD HH24:MI:SS'),
                          sysdate + 7 ) ) + 1 - ONE_SECOND;

        l_count := UPDATE_GLOBAL_START_DATE_TBL( g_gl_from_date );
            FND_STATS.gather_table_stats (ownname => g_fii_schema,
                          tabname => 'FII_GLOBAL_START_DATES');

                EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

                fii_util.put_line('Altering session enable parallel DML after FND_STATS call, bug  4127183.');

   ELSE

     -----------------------------------------------------------------
     -- When running in Incremental mode, the values of the parameters
     -- are derived
     -----------------------------------------------------------------
     BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AR_REVENUE_B_I',
                                                     l_last_start_date1,
                                                     l_last_end_date,
                                                     l_last_period_from,
                                                     l_last_period_to1);
            IF  l_last_start_date1 IS NOT NULL THEN
                 l_last_start_date := l_last_start_date1;
                 SELECT trunc(min(stu.start_date))
                 INTO   l_gl_from_date1
                 FROM   gl_period_statuses stu,
                        fii_slg_assignments slga,
                        fii_source_ledger_groups fslg
                 WHERE  slga.ledger_id = stu.set_of_books_id
                 AND    slga.source_ledger_group_id = fslg.source_ledger_group_id
                 AND    fslg.usage_code = g_usage_code
                 AND    stu.application_id = 222
                 AND    (stu.closing_status = 'O' OR (stu.closing_status IN ('C', 'P')
                 AND    stu.last_update_date > l_last_start_date))
                 AND    stu.end_date >= g_global_start_date;


                 -- g_gl_from_date := greatest(l_gl_from_date1,g_global_start_date);
                 g_gl_from_date := nvl(
                     greatest(l_gl_from_date1,g_global_start_date),
                     sysdate + 7 );

                 -----------------------------------------------------------
                 -- For general records, we will scan 10 years into the future
                 -- For 'AR DL', we will scan only one month into the future.  For
                 -- future records, we will not filter by last update date
                 -- because if a future dated records (May 2005) is entered
                 -- now (June, 2003), we will not pick it up when we reach
                 -- May, 2005. (This logic is also embedded in Identify_change
                 -- function.
                 --
                 -- For any records, scan 7 days in the future.
                 ------------------------------------------------------------

                 -- g_gl_to_date := ADD_MONTHS(g_gl_from_date, 120);
                 g_gl_to_date := sysdate + 7;

                 g_lud_from_date := l_last_start_date - (1/24);

                 g_lud_to_date := sysdate;


           ELSIF l_last_start_date1 IS NULL THEN
         --  --------------------------------------------------------------------
         -- in case of first incemental update, get_last_refresh_dates for
         -- previous incremental updates will be NULL. So we look at the LOAD
         -- get_last_refresh_dates.
         -- The LOAD may be run on 7-Mar-2003 but the the records may be collected
         -- upto 31-DEC-2002. To get the records from 31-DEC-2002 we use the least
         -- of l_last_start_date2, l_last_period_to2
         -- --------------------------------------------------------------------------
                 BIS_COLLECTION_UTILITIES.get_last_refresh_dates('FII_AR_REVENUE_B_L',
                                                     l_last_start_date2,
                                                     l_last_end_date,
                                                     l_last_period_from,
                                                     l_last_period_to2);
                 l_last_start_date := LEAST (l_last_start_date2, l_last_period_to2);
                 SELECT trunc(min(stu.start_date))
                 INTO   l_gl_from_date2
                 FROM   gl_period_statuses stu,
                        fii_slg_assignments slga,
                        fii_source_ledger_groups fslg
                 WHERE  slga.ledger_id = stu.set_of_books_id
                 AND    slga.source_ledger_group_id = fslg.source_ledger_group_id
                 AND    fslg.usage_code = g_usage_code
                 AND    stu.application_id = 222
                 AND    (stu.closing_status = 'O' OR (stu.closing_status IN ('C', 'P')
                 AND    stu.last_update_date > l_last_start_date))
                 AND    stu.end_date >= g_global_start_date;

                 -- g_gl_from_date := GREATEST(l_gl_from_date2,g_global_start_date);
                 g_gl_from_date := nvl(
                     GREATEST(l_gl_from_date2,g_global_start_date),
                     sysdate + 7 );

                 -- g_gl_to_date := ADD_MONTHS(g_gl_from_date, 120);
                 g_gl_to_date := sysdate + 7;

                 g_lud_from_date := l_last_start_date - (1/24);

                 g_lud_to_date := sysdate;


            END IF;

  END IF;

  -----------------------------------------------------------
  -- checking whether global variables : g_gl_from_date,
  -- g_gl_to_date, g_program_type are not null
  ----------------------------------------------------------
    IF g_debug_flag = 'Y' THEN
         fii_util.put_line(' ');
         fii_util.put_line('Checking that Global Variables are not null.');
    END IF;

    IF (CHECK_GLOBAL_VARIABLES) THEN
    --  if g_debug_flag = 'Y' then
         fii_util.put_line(' ');
         fii_util.put_line('Function CHECK_GLOBAL_VARIABLES: One of the global variables like g_gl_from_date, g_gl_to_date,
             g_program_type, g_lud_from_date, g_lud_to_date is NULL. Hence program terminated');
    --  end if;
      retcode := -1;
      RETURN;
    END IF;

  -------------------------------------------------
  -- Print out useful date range information
  -------------------------------------------------
  if g_debug_flag = 'Y' then
    fii_util.put_line(' ');
         fii_util.put_line('This program will collect data with GL dates between '||
          to_char(g_gl_from_date,'MM/DD/YYYY HH24:MI:SS')||' and '||
          to_char(g_gl_to_date,'MM/DD/YYYY HH24:MI:SS'));
     IF p_program_type = 'I' THEN
         fii_util.put_line('This program will collect data with Last update date range between '||
          to_char(g_lud_from_date,'MM/DD/YYYY HH24:MI:SS')||' and '||
          to_char(g_lud_to_date,'MM/DD/YYYY HH24:MI:SS'));
     end if;
  end if;

    l_section := 'Verifying if all AR periods have been upgraded for XLA';
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line(l_section);
    end if;

    CHECK_XLA_CONVERSION_STATUS;

    -- end in warning if any non-sla-upgraded data exists
    if (g_non_upgraded_ledgers) then
       retcode := 1;
       errbuf := 'Some AR periods have not been upgraded for XLA';
    end if;

    ------------------------------------------
    -- Check setups only if we are running in
    -- Incremental Mode, p_program_type = 'I'
    ------------------------------------------
    IF (p_program_type = 'I') THEN

        ---------------------------------------------
        -- Check if any set up got changed.  If yes,
        -- then we need to truncate the summary table
        -- and then reload
        ---------------------------------------------
        l_section := 'M-Section 23';


                l_slg_chg := CHECK_SLG_ASSIGNMENT;
                l_prd_chg := CHECK_PRODUCT_ASSIGNMENT;

        IF (l_slg_chg) THEN

            --------------------------------------------
            -- Write out translated message to let user
            -- know they need to truncate the summary
            -- table first before loading
            --------------------------------------------
              fii_message.write_output(
                 msg_name    => 'FII_TRUNC_SUMMARY',
                 token_num   => 0);

                FII_UTIL.put_line('Function CHECK_SLG_ASSIGNMENT: Source Ledger Group setup has changed. Please run the Request Set in the Initial mode to repopulate the summaries.');

        END IF;


        IF (l_prd_chg) THEN

            --------------------------------------------
            -- Write out translated message to let user
            -- know they need to truncate the summary
            -- table first before loading
            --------------------------------------------
              fii_message.write_output(
                  msg_name    => 'FII_TRUNC_SUMMARY_PRD',
                  token_num   => 0);

                FII_UTIL.put_line('Function CHECK_PRODUCT_ASSIGNMENT: Product Assignment has changed. Please run the Request Set in the Initial mode to repopulate the summaries.');

        END IF;

                -- should fail the program if either slg or prd changed
        IF (l_slg_chg OR l_prd_chg) THEN
              retcode := -1;
              RETURN;
        END IF;

    -----------------------------------------------------------
    -- checking whether there are any changes
    -- to natural account assigned to 'Revenue' financial item
    -----------------------------------------------------------
            l_section := 'M-Section 24';

                 if g_debug_flag = 'Y' then
                     fii_util.put_line('');
                     fii_util.put_line('Calling function REV_ACCTS_CHANGED.');
                 --    fii_util.put_line(l_stmt);
                  end if;

            g_rev_acct_changed := REV_ACCTS_CHANGED;

            IF (g_rev_acct_changed) THEN

        --------------------------------------------
        -- Write out translated message to let user
        -- know they need to truncate the summary
        -- table first before loading
        --------------------------------------------
                     fii_util.put_line('');
                     fii_util.put_line('Function: REV_ACCTS_CHANGED.
                     There has been a change in mapping for the Financial Categories Revenue
                     and/or Deferred Revenue since the last Load / Update program.
                     Please run the Request Set in the Initial mode to repopulate the summaries.');

                     errbuf := 'Error: Change in Revenue / Deferred Revenue Accounts.';


            fii_message.write_output(
                msg_name    => 'FII_TRUNC_SUMMARY_REV_ACCTS',
                token_num   => 0);
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

    UPDATE fii_change_log
        SET item_value = 'N',
            last_update_date  = SYSDATE,
            last_update_login = g_fii_login_id,
            last_updated_by   = g_fii_user_id
        WHERE log_item = 'AR_RESUMMARIZE'
          AND item_value = 'Y';

    UPDATE fii_change_log
        SET item_value = 'N',
            last_update_date  = SYSDATE,
            last_update_login = g_fii_login_id,
            last_updated_by   = g_fii_user_id
        WHERE log_item = 'AR_PROD_CHANGE'
          AND item_value = 'Y';

            COMMIT;

    END IF;

    ----------------------------------------------------------
    -- Determine if we need to resume.  If there are records
    -- in staging table, then that means there are records
    -- with missing exchange rate information left from the
    -- previous run.  In this case, we will not process any
    -- more new records, we will only process records already
    -- in the staging table
    ----------------------------------------------------------
    if g_debug_flag = 'Y' then
      FII_UTIL.put_line('');
      FII_UTIL.put_line('Determining if we need to resume from previous run');
      FII_UTIL.put_line('');
    end if;

    -- Bug 4942753: Change to return 1 if any row exists
    BEGIN
      SELECT 1
      INTO l_stg_count
      FROM fii_ar_revenue_stg
      WHERE rownum = 1;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_stg_count := 0;
    END;

    IF (l_stg_count > 0) THEN
      g_resume_flag := 'Y';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('Resuming from previous run');
        FII_UTIL.put_line('');
      end if;
    ELSE
      g_resume_flag := 'N';
      if g_debug_flag = 'Y' then
        FII_UTIL.put_line('Not resuming from previous run.  Starting with fresh collection');
        FII_UTIL.put_line('');
      end if;
    END IF;


  --------------------------------------------------------------
  -- If resume flag is 'N', then this program starts from the
  -- beginning and we insert records into staging table.
  -- If resume flag is 'Y', we update the exchange rates
  -- in the staging table (assuming users have provided the
  -- missing exchange rates)
  --------------------------------------------------------------
  IF(g_resume_flag = 'N') THEN

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

        -- ------------------------------------------
      -- Register phase 1 and 2 jobs
      -- ------------------------------------------
      l_section := 'M-Section 30';

        CLEAN_UP;

      ---------------------------------------------------------
      -- After we do initial clean up, we will set this flag to
      -- 'N' to preserve the temporary Revenue ID table for
      -- debugging purpose
      ---------------------------------------------------------
      g_truncate_id := 'N';

      l_section := 'M-Section 31';

    IF p_program_type = 'L' THEN

        AR_STG(p_sort_area_size, p_hash_area_size, p_parallel_query);

        -- perf tune
        FND_STATS.gather_table_stats
           (ownname => g_fii_schema,
            tabname => 'FII_AR_REVENUE_STG');

        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

        fii_util.put_line('Altering session enable parallel DML after FND_STATS call, bug  4127183.');

        -- Bug 4942753: Changed to return 1 if any row exists
        BEGIN
          /*
          select 1 into l_count
          from fii_fin_cat_type_assgns
          where fin_cat_type_code = 'DR'
          and rownum = 1;
          */
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   g_program_code_R,  'R',
                                   g_program_code_DR, 'DR',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code = g_program_code_DR
                     AND XAD.Enabled_Flag = 'Y'
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
          select 1 into l_count
          from ACCNT_CLASS
          where rownum = 1;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_count := 0;
        END;

        -- Only call these two functions when some financial category
        -- has been assigned type DR.
        if l_count > 0 then
            l_count := IDENTIFY_CHANGE_INIT( 'AR INV' );
            if g_debug_flag = 'Y' then
                fii_util.put_line('Function IDENTIFY_CHANGE_INIT identified '||l_count||' rows');
            end if;

            l_count := AR_STG_BF( 4, 1 );
            if g_debug_flag = 'Y' then
                fii_util.put_line('Function AR_STG_BF collected '||l_count||' rows into staging table.');
            end if;
        end if;

        AR_RATES;

    ELSE

      if g_debug_flag = 'Y' then
        fii_util.put_line(' ');
        fii_util.put_timestamp;
      end if;
      REGISTER_PREP_JOBS;
      COMMIT;

      -- ------------------------------------------
      -- Launch workers
      -- ------------------------------------------
      l_section := 'M-Section 40';
      if g_debug_flag = 'Y' then
        fii_util.put_line(' ');
        fii_util.put_timestamp;
        fii_util.put_line('Launching '||p_no_worker||' workers');
        fii_util.start_timer;
      end if;

      FOR i IN 1..p_no_worker LOOP
          l_worker(i) := LAUNCH_WORKER(i);
          if g_debug_flag = 'Y' then
            fii_util.put_line('  Worker '||i||' request id: '||
                     l_worker(i));
          end if;
      END LOOP;

      COMMIT;

      -- ------------------------------------------
      -- Monitor workers
      -- ------------------------------------------
      l_section := 'M-Section 50';
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
  LOOP

    SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
           NVL(sum(decode(status,'COMPLETED',1,0)),0),
           NVL(sum(decode(status,'IN PROCESS',1,0)),0),
           NVL(sum(decode(status,'FAILED',1,0)),0),
           COUNT(*)
    INTO l_unassigned_cnt,
           l_completed_cnt,
           l_wip_cnt,
           l_failed_cnt,
           l_tot_cnt
    FROM   FII_AR_REVENUE_JOBS;

  if g_debug_flag = 'Y' then
    fii_util.put_line('Job status - Unassigned:'||l_unassigned_cnt||
                     ' In Process:'||l_wip_cnt||
                     ' Completed:'||l_completed_cnt||
                     ' Failed:'||l_failed_cnt);
   end if;

    IF (l_failed_cnt > 0) THEN
      g_retcode := -2;
      g_errbuf := '
  ---------------------------------
  Error in Procedure: MAIN
           Message: At least one of the workers have errored out';
      RAISE g_procedure_failure;

    END IF;

    IF (l_tot_cnt = l_completed_cnt) THEN
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


    IF (l_cycle > MAX_LOOP) THEN
      g_retcode := -2;
      g_errbuf := '
  ---------------------------------
  Error in Procedure: MAIN
             Message: No progress have been made for '||MAX_LOOP||' minutes.
                      Terminating';

      raise g_procedure_failure;
    END IF;

    -- -----------------------
    -- Sleep 60 Seconds
    -- -----------------------
    dbms_lock.sleep(60);

    l_last_unassigned_cnt := l_unassigned_cnt;
    l_last_completed_cnt := l_completed_cnt;
    l_last_wip_cnt := l_wip_cnt;

  END LOOP;

if g_debug_flag = 'Y' then
  fii_util.stop_timer;
  fii_util.print_timer('Duration');
end if;
  END;

  END IF;

  ---------------------------------------------------------------
  -- If we are in resume mode, then we will fix the missing rates
  -- in the staging table before verifying if there's missing
  -- rates again
  ---------------------------------------------------------------
  ELSE /* If g_resume_flag is 'Y' */

       ----------------------------------------------------------
       -- This variable indicates that if exception occur, do
       -- we need to truncate the staging table.
       -- When running in resume mode, we do not want to truncate
       -- staging table
       ----------------------------------------------------------
         g_truncate_staging := 'N';

     if g_debug_flag = 'Y' then
       fii_util.put_line('Program running in resume mode.  Fixing missing exchange rates in staging table');
       fii_util.put_line('');

       FII_UTIL.start_timer;
     end if;

       Update FII_AR_REVENUE_STG stg
       SET  prim_conversion_rate =
                  fii_currency.get_global_rate_primary(stg.functional_currency, least(stg.exchange_date, sysdate))
       WHERE stg.prim_conversion_rate < 0;
--      commit;
     if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' records for primary currency rates in staging table');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');

       FII_UTIL.start_timer;
     end if;
       commit;

       Update FII_AR_REVENUE_STG stg
       SET  sec_conversion_rate =
               fii_currency.get_global_rate_secondary(stg.functional_currency, least(stg.exchange_date, sysdate))
       WHERE stg.sec_conversion_rate < 0;
 --      commit;
    if g_debug_flag = 'Y' then
       FII_UTIL.put_line('Updated ' || SQL%ROWCOUNT || ' records for secondary currency rates in staging table');
       FII_UTIL.stop_timer;
       FII_UTIL.print_timer('Duration');
    end if;
       commit;


   END IF; -- IF (g_resume_flag = 'N')

  if g_debug_flag = 'Y' then
    fii_util.put_line(' ');
    fii_util.put_line('Running function VERIFY_MISSING_RATES.');
  end if;

                IF g_program_type = 'I' then
                       if g_debug_flag = 'Y' then
                            fii_util.put_line(' ');
                            fii_util.put_timestamp;
                            fii_util.put_line('Anayzing staging table before checking missing rates.');
                       end if;

                      FND_STATS.gather_table_stats (ownname => g_fii_schema,
                      tabname => 'FII_AR_REVENUE_STG');

                      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';

                      fii_util.put_line('Altering session enable parallel DML after FND_STATS call, bug  4127183.');


                END IF;

  l_count := VERIFY_MISSING_RATES;

  ------------------------------------------------
  -- If there are missing rates reported, program
  -- will exit immediately with warning status
  ------------------------------------------------
  IF l_count = -1 THEN
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
    errbuf := fnd_message.get_string('FII', 'FII_MISS_EXCH_RATE_FOUND');
    Retcode := g_retcode;
    RETURN;
  END IF;

  --------------------------------------------
  -- This part of code merges records from stg
  -- into base.  We only execute it when running
  -- in 'I' mode.
  ---------------------------------------------
  if g_debug_flag = 'Y' then
            fii_util.put_line(' ');
            fii_util.put_line('Running procedure to populate base summary table');
  end if;
  IF (g_program_type = 'L') THEN
        AR_SUMMARY (p_parallel_query);
  ELSE
             -- to check for duplicate records in staging table during Update prog.
             if g_debug_flag = 'Y' then
            fii_util.put_line(' ');
            fii_util.put_line('Checking for duplicate records in staging table.');
             end if;
             SELECT count(*) INTO l_dup
               from (SELECT 1
                     FROM FII_AR_REVENUE_STG b2
                     GROUP BY b2.revenue_pk
                    HAVING count(*)>1
                    );
              IF l_dup > 0 THEN
                 UNIQUE_CONST_RECORDS;
                 g_retcode := -1;
                 g_errbuf := 'Error: Duplicate Records in staging table';
                 RAISE  g_procedure_failure;
              END IF;
      l_count := POPULATE_SUM;
  END IF;
  -------------------------------------------------------------------
  -- After we have merged the records from the staging table into the
  -- base summary table, we can clean up the staging table when we
  -- call the CLEAN_UP procedure
  -------------------------------------------------------------------
  g_truncate_staging := 'Y';

  ---------------------------------------------------------------
  -- after load is completed, insert into table fii_ar_rev_accts
  -- new accounts assigned to 'Revenue'.
  ---------------------------------------------------------------
  if g_debug_flag = 'Y' then
            fii_util.put_line(' ');
    fii_util.put_line('Inserting new revenue accounts in fii_ar_rev_accts ');
    fii_util.start_timer;
  end if;

  /*
  IF (p_program_type = 'L') THEN

    --------------------------------------------------
    -- Inserting natural accounts which are revenue
    -- related into FII_AR_REV_ACCTS table
    --------------------------------------------------
    INSERT INTO fii_ar_rev_accts (rev_acct_id, fin_cat_type_code)
    SELECT ffcta.fin_category_id, ffcta.fin_cat_type_code
    FROM fii_fin_cat_type_assgns ffcta
    WHERE ffcta.fin_cat_type_code in ('R', 'DR');

  ELSE

    l_stmt := '
           INSERT INTO fii_ar_rev_accts (rev_acct_id, fin_cat_type_code)
           SELECT temp.cur_rev_acct_id, temp.cur_fin_cat_type_code
           FROM '||g_fii_schema||'.fii_ar_rev_accts_temp temp,
                fii_ar_rev_accts fra
           WHERE temp.cur_rev_acct_id = fra.rev_acct_id(+)
           AND   temp.cur_fin_cat_type_code = fra.fin_cat_type_code(+)
           AND   fra.rev_acct_id IS NULL ';

    if g_debug_flag = 'Y' then
        fii_util.put_line('');
--      fii_util.put_line(l_stmt);
    end if;

    EXECUTE IMMEDIATE l_stmt;

  END IF;
  */

  IF (p_program_type <> 'L') THEN

    TRUNCATE_TABLE('FII_AR_REV_ACCTS');

  END IF;

  INSERT INTO fii_ar_rev_accts (rev_acct_id, rev_acct, fin_cat_type_code)
WITH ACCNT_CLASS AS (SELECT XAD.Ledger_ID,
                            XACA.Accounting_Class_Code,
                            decode(XAD.Program_Code,
                                   g_program_code_R,  'R',
                                   g_program_code_DR, 'DR',
                                   NULL) Fin_Cat_Type_Code
                     FROM XLA_Assignment_Defns_B XAD,
                          XLA_Acct_Class_Assgns XACA
                     WHERE XAD.Program_Code in (g_program_code_R,
                                                g_program_code_DR)
                     AND XAD.Enabled_Flag = 'Y'
                     AND XAD.Program_Code = XACA.Program_Code
                     AND XAD.Assignment_Code = XACA.Assignment_Code)
  SELECT * FROM ACCNT_CLASS;

  if g_debug_flag = 'Y' then
    fii_util.put_line(' ');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
  end if;

  COMMIT;


IF (p_program_type = 'I') THEN
      SELECT sum(rows_processed)
      INTO   l_count
      FROM   fii_ar_revenue_jobs
      WHERE  function = 'POPULATE_STG';

 if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_line('Processed  '||l_count||' row(s) into staging table.');
 end if;
END IF;

/*  SELECT sum(rows_processed)
  INTO   l_count
  FROM   fii_ar_revenue_jobs
  WHERE  function = 'DETECT_DELETED_INV';
  if g_debug_flag = 'Y' then
    fii_util.put_line('Found '||l_count||' invoice(s) deleted');
  end if;
*/
  COMMIT;

   CLEAN_UP;

  ----------------------------------------------------------------
  -- Record AR_MAX_GROUP_ID in FII_CHANGE_LOG
  ----------------------------------------------------------------

  MERGE INTO FII_CHANGE_LOG log
        USING ( SELECT 'AR_MAX_GROUP_ID' LOG_ITEM,
                       to_char( nvl(max(group_id), -1) ) ITEM_VALUE
                FROM xla_ae_headers ) new
        ON ( new.LOG_ITEM = log.LOG_ITEM )
  WHEN MATCHED THEN
        UPDATE SET
          log.ITEM_VALUE = new.ITEM_VALUE,
          log.LAST_UPDATE_DATE  = SYSDATE,
          log.LAST_UPDATE_LOGIN = g_fii_login_id,
          log.LAST_UPDATED_BY   = g_fii_user_id
  WHEN NOT MATCHED THEN
        INSERT( LOG_ITEM,
                ITEM_VALUE,
                CREATION_DATE,
                CREATED_BY,
                LAST_UPDATE_DATE,
                LAST_UPDATE_LOGIN,
                LAST_UPDATED_BY )
        VALUES( new.LOG_ITEM,
                new.ITEM_VALUE,
                SYSDATE,
                g_fii_user_id,
                SYSDATE,
                g_fii_login_id,
                g_fii_user_id );

  COMMIT;

  ----------------------------------------------------------------
  -- Calling BIS API to record the range we collect.  Only do this
  -- when we have a successful collection
  ----------------------------------------------------------------

  BIS_COLLECTION_UTILITIES.wrapup(
                p_status => TRUE,
                p_period_from => g_gl_from_date,
                p_period_to => g_gl_to_date);


-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------

EXCEPTION
  WHEN G_PROCEDURE_FAILURE THEN
    Errbuf := g_errbuf;
    Retcode := g_retcode;
    fii_util.put_line(Errbuf);

    --------------------------------
    -- Terminate the child processes
    --------------------------------
    UPDATE FII_AR_REVENUE_JOBS
    SET    status = 'FAILED'
    WHERE  rownum < 2;

    COMMIT;

    CLEAN_UP;
     drop_table('fii_ar_rev_accts_temp');
  WHEN OTHERS THEN
    Retcode:= -1;
    Errbuf := '
  ---------------------------------
  Error in Procedure: MAIN
           Section: '||l_section||'
           Message: '||sqlerrm;
    fii_util.put_line(Errbuf);

    --------------------------------
    -- Terminate the child processes
    --------------------------------
    UPDATE FII_AR_REVENUE_JOBS
    SET    status = 'FAILED'
    WHERE  rownum < 2;

    COMMIT;

    CLEAN_UP;
    drop_table('fii_ar_rev_accts_temp');
END MAIN;


--------------------------------------------------
-- PROCEDURE WORKER
---------------------------------------------------
PROCEDURE WORKER(
                Errbuf          IN OUT  NOCOPY VARCHAR2,
                Retcode         IN OUT  NOCOPY VARCHAR2,
                p_worker_no     IN      NUMBER) IS

 -- -------------------------------------------
 -- Put any additional developer variables here
 -- -------------------------------------------
 l_unassigned_cnt       NUMBER := 0;
 l_failed_cnt           NUMBER := 0;
 l_curr_unasgn_cnt      NUMBER := 0;
 l_curr_comp_cnt        NUMBER := 0;
 l_curr_tot_cnt         NUMBER := 0;
 l_count                NUMBER;
 l_curr_phase           NUMBER;
 l_function             FII_AR_REVENUE_JOBS.function%TYPE;
 l_num_parameter1       FII_AR_REVENUE_JOBS.number_parameter1%TYPE;
 l_num_parameter2       FII_AR_REVENUE_JOBS.number_parameter2%TYPE;
 l_char_parameter1      FII_AR_REVENUE_JOBS.char_parameter1%TYPE;
 l_char_parameter2      FII_AR_REVENUE_JOBS.char_parameter2%TYPE;
 l_section              VARCHAR2(20) := NULL;

BEGIN
  Errbuf :=NULL;
  Retcode:=0;

  l_section := 'W-Section 10';
  -- -----------------------------------------------
  -- Set up directory structure for child process
  -- -----------------------------------------------
  CHILD_SETUP('FII_AR_REVENUE_B_C_SUBWORKER'||p_worker_no);

 if g_debug_flag = 'Y' then
  fii_util.put_line(' ');
  fii_util.put_timestamp;
  fii_util.put_line('Worker '||p_worker_no||' Starting');
 end if;

  -- ------------------------------------------
  -- Initalization
  -- ------------------------------------------
  l_section := 'W-Section 20';
  if g_debug_flag = 'Y' then
    fii_util.put_line(' ');
    fii_util.put_line('Calling INIT procedure for worker.');
  end if;
  INIT;

  g_worker_num := p_worker_no;


  -- ------------------------------------------
  -- Loop thru job list
  -- -----------------------------------------
  l_curr_phase := 1;

  LOOP

    l_section := 'W-Section 30';
    SELECT NVL(sum(decode(status,'UNASSIGNED',1,0)),0),
           NVL(sum(decode(status,'FAILED',1,0)),0),
           NVL(sum(decode(status,'UNASSIGNED',
                      decode(phase, l_curr_phase, 1, 0), 0)),0),
           NVL(sum(decode(status,'COMPLETED',
                      decode(phase, l_curr_phase, 1, 0), 0)),0),
           NVL(sum(decode(phase, l_curr_phase, 1, 0)),0)
    INTO   l_unassigned_cnt,
           l_failed_cnt,
           l_curr_unasgn_cnt,
           l_curr_comp_cnt,
           l_curr_tot_cnt
    FROM   FII_AR_REVENUE_JOBS;


    l_section := 'W-Section 40';
    IF (l_failed_cnt > 0) THEN
--    if g_debug_flag = 'Y' then
      fii_util.put_line('');
      fii_util.put_line('Another worker have errored out.  Stop processing.');
 --    end if;
      EXIT;
    END IF;

    IF (l_curr_phase = LAST_PHASE AND
        l_unassigned_cnt = 0) THEN
     if g_debug_flag = 'Y' then
      fii_util.put_line('');
      fii_util.put_line('No more jobs left.  Terminating.');
     end if;
      EXIT;
    END IF;


    IF (l_curr_unasgn_cnt > 0) THEN

      l_section := 'W-Section 50';
      UPDATE FII_AR_REVENUE_JOBS
      SET    status = 'IN PROCESS',
               start_time = sysdate,
               worker = g_worker_num
      WHERE  status = 'UNASSIGNED'
      AND    phase = l_curr_phase
      AND    priority = (
             SELECT min(priority)
             FROM   fii_ar_revenue_jobs
             WHERE  status = 'UNASSIGNED'
             AND    phase = l_curr_phase)
      AND    rownum < 2;

      l_count := SQL%ROWCOUNT;

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

        l_count := NULL;
        l_section := 'W-Section 60';

        SELECT function,
             date_parameter1,
             date_parameter2,
             date_parameter3,
             date_parameter4,
             number_parameter1,
             number_parameter2,
             char_parameter1,
             char_parameter2
        INTO l_function,
             g_gl_from_date,
             g_gl_to_date,
             g_lud_from_date,
             g_lud_to_date,
             l_num_parameter1,
             l_num_parameter2,
             l_char_parameter1,
             l_char_parameter2
        FROM FII_AR_REVENUE_JOBS
        WHERE worker = p_worker_no
        AND  status = 'IN PROCESS';


        l_section := 'W-Section 70';
        if g_debug_flag = 'Y' then
          fii_util.put_line('');
          fii_util.put_line('');
          fii_util.put_line('------------------------------------------------------');
          fii_util.put_timestamp;
        end if;

        IF (l_function = 'IDENTIFY_CHANGE') THEN

        if g_debug_flag = 'Y' then
          fii_util.put_line('Job1: Calling IDENTIFY_CHANGE function for Revenue and Deferred Revenue records.');
          fii_util.put_line('Parameters: type='||l_char_parameter1);
          fii_util.put_line('            gl from date='||
                            to_char(g_gl_from_date,'YYYY/MM/DD HH24:MI:SS'));
          fii_util.put_line('            gl to date='||
                            to_char(g_gl_to_date,'YYYY/MM/DD HH24:MI:SS'));
          fii_util.put_line('            last updated from date='||
                            to_char(g_lud_from_date,'YYYY/MM/DD HH24:MI:SS'));
          fii_util.put_line('            last updated to date='||
                            to_char(g_lud_to_date,'YYYY/MM/DD HH24:MI:SS'));
        end if;

          l_count := IDENTIFY_CHANGE(l_char_parameter1);
          if g_debug_flag = 'Y' then
           fii_util.put_line('Identified '||l_count||' rows');
          end if;
        ELSIF (l_function = 'VERIFY_CCID_UP_TO_DATE') THEN
                 if g_debug_flag = 'Y' then
             fii_util.put_line('Job2: Calling VERIFY_CCID_UP_TO_DATE procedure.');
         end if;
             VERIFY_CCID_UP_TO_DATE;
        ELSIF (l_function = 'REGISTER_EXTRACT_JOBS') THEN
         if g_debug_flag = 'Y' then
          fii_util.put_line('Job3: Calling REGISTER_EXTRACT_JOBS procedure.');
         end if;
          REGISTER_EXTRACT_JOBS;
--        ELSIF (l_function = 'DETECT_DELETED_INV') THEN
--         if g_debug_flag = 'Y' then
--          fii_util.put_line('Job: Detect deleted invoices');
--         end if;
--          l_count := DETECT_DELETED_INV;
        ELSIF (l_function = 'POPULATE_STG') THEN
          if g_debug_flag = 'Y' then
            fii_util.put_line('Job4: Calling POPULATE_STG function');
            fii_util.put_line('Parameters: view type='||l_num_parameter1);
            fii_util.put_line('            jobs sequence='||l_num_parameter2);
          end if;
          l_count := POPULATE_STG(l_num_parameter1,l_num_parameter2);
               -- FND_STATS.gather_table_stats
                 --      (ownname => g_fii_schema,
                  --      tabname => 'FII_AR_REVENUE_STG');
        ELSE
          g_errbuf := '
  ---------------------------------
  Error in Procedure: WORKER
           Message: Job type incorrect:'||l_function;
          raise g_procedure_failure;
        END IF;

        COMMIT;

        l_section := 'W-Section 80';
        UPDATE FII_AR_REVENUE_JOBS
        SET  status = 'COMPLETED',
             end_time = sysdate,
             rows_processed = l_count
        WHERE  worker = p_worker_no
        AND   status = 'IN PROCESS';
        COMMIT;

      EXCEPTION
        WHEN OTHERS THEN

        g_retcode := -2;
        UPDATE FII_AR_REVENUE_JOBS
        SET  status = 'FAILED',
             end_time = sysdate
        WHERE  worker = p_worker_no
        AND   status = 'IN PROCESS';
        COMMIT;
        RAISE;

      END;
      END IF;

    ELSIF (l_curr_comp_cnt < l_curr_tot_cnt) THEN
      -- -----------------------
      -- Sleep 60 Seconds
      -- -----------------------
      l_section := 'W-Section 90';
      if g_debug_flag = 'Y' then
        fii_util.put_line('');
        fii_util.put_line('');
        fii_util.put_line('------------------------------------------------------');
        fii_util.put_timestamp;
      end if;
      dbms_lock.sleep(60);

    ELSIF (l_curr_comp_cnt = l_curr_tot_cnt) THEN

      l_section := 'W-Section 100';
      IF (l_curr_phase = LAST_PHASE) THEN
        EXIT;
      ELSE
        l_curr_phase := l_curr_phase + 1;
      END IF;

    END IF;


  END LOOP;

 if g_debug_flag = 'Y' then
  fii_util.put_timestamp;
 end if;

EXCEPTION
        WHEN G_PROCEDURE_FAILURE THEN
                Errbuf := g_errbuf;
                Retcode := g_retcode;
                fii_util.put_line(Errbuf);

        WHEN OTHERS THEN
                Retcode:= -2;
                Errbuf := '
  ---------------------------------
  Error in Procedure: WORKER
           Section: '||l_section||'
           Message: '||sqlerrm;
           fii_util.put_line(Errbuf);

      -------------------------------------------------
      -- Write out translated message to let user know
      -- the subworker completed with failure status
      -------------------------------------------------
      FII_MESSAGE.write_output(
         msg_name    => 'FII_PROG_STATUS',
         token_num   => 2,
         t1          => 'USER_PROG_NAME',
         v1          => 'Update Receivables Revenue Summary Subworker',
         t2          => 'STATUS',
         v2          => 'failed!');


END WORKER;

END FII_AR_REVENUE_B_C;

/
