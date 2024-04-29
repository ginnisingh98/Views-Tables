--------------------------------------------------------
--  DDL for Package Body PN_EXP_TO_AP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_EXP_TO_AP" AS
  -- $Header: PNTXPMTB.pls 120.14.12010000.3 2010/01/19 09:19:09 nkapling ship $

-------------------------------------------------------------------
-- For loading PN's Invoice Info into AP's Interface Tables
-- ( Run as a Conc Process )
-------------------------------------------------------------------

-- ************************************************************************
--                     Package level DECLARATIONS go here
-- ************************************************************************

-- variables for ref cursor
   l_one NUMBER := 1;
   l_id  NUMBER := -1;

-- the main query string
-- this will be used by all procedures

   l_func_curr_code  gl_sets_of_books.currency_code%TYPE;

   Q_Payitem       VARCHAR2(5000);

   l_Select_Clause VARCHAR2(5000):= '
   SELECT
      pi.ORG_ID as org_id,
      pi.payment_item_id,
      pi.payment_term_id as payment_term_id,
      pi.export_currency_amount,
      pi.export_currency_code,
      pi.vendor_id,
      pi.vendor_site_id as vendor_site_id,
      pt.project_id,
      pt.task_id,
      pt.organization_id,
      pt.expenditure_type,
      pt.expenditure_item_date,
      pt.tax_group_id,
      pt.tax_code_id,
      pt.tax_classification_code,
      pt.tax_included,
      pt.distribution_set_id,
      le.lease_num,
      le.lease_id,
      NVL(pld.send_entries, ''Y'') as send_entries,
      pi.payment_schedule_id,
      ps.period_name,
      PNP_UTIL_FUNC.get_start_date(ps.period_name,pn_mo_cache_utils.get_current_org_id) as gl_date,
      pt.normalize,
      pi.due_date,
      pt.ap_ar_term_id,
      TRUNC(pi.accounted_date),
      pi.rate,
      pi.ap_invoice_num,
      pt.payment_purpose_code,
      pt.payment_term_type_code,
      pn_exp_to_ap.get_liability_acc(pi.payment_term_id,
                                     pi.vendor_id,
                                     pi.vendor_site_id) as lia_account,
      pt.legal_entity_id as legal_entity_id,
      decode(UPPER(PNP_UTIL_FUNC.check_conversion_type('''||l_func_curr_code||''',pn_mo_cache_utils.get_current_org_id))
             , ''USER'', decode(pi.export_currency_code
                                ,'''||l_func_curr_code||''', 1
                                ,pi.rate)
             , NULL) as conv_rate,
      PNP_UTIL_FUNC.check_conversion_type('''||l_func_curr_code||''',pn_mo_cache_utils.get_current_org_id)
             as conv_rate_type,
      pi.grouping_rule_id as item_grouping_rule_id,
      pt.grouping_rule_id as term_grouping_rule_id,
      pld.grouping_rule_id as lease_grouping_rule_id
   FROM pn_payment_items         pi,
        pn_payment_schedules_all ps,
        pn_payment_terms_all     pt,
        pn_leases_all            le,
        pn_lease_details_all     pld,
        fnd_lookups              type_lookup,
        fnd_lookups              purpose_lookup,
        po_vendors               vendor,
        hr_operating_units       ou,
        pn_pay_group_rules       ppgr
   WHERE pi.payment_term_id               = pt.payment_term_id
   AND   pi.payment_schedule_id           = ps.payment_schedule_id
   AND   nvl(pi.export_to_ap_flag,''N'')  = ''Y''
   AND   pi.payment_item_type_lookup_code = ''CASH''
   AND   pt.lease_id                      = le.lease_id
   AND   pld.lease_id                     = le.lease_id
   AND   le.parent_lease_id               IS NULL
   AND   pi.transferred_to_ap_flag        IS NULL
   AND   pi.vendor_id                     IS NOT NULL
   AND   pi.export_currency_amount        <> 0
   AND   pi.grouping_rule_id              = ppgr.grouping_rule_id (+)
   AND   type_lookup.lookup_type          = ''PN_PAYMENT_TERM_TYPE''
   AND   type_lookup.lookup_code          = pt.payment_term_type_code
   AND   purpose_lookup.lookup_type       = ''PN_PAYMENT_PURPOSE_TYPE''
   AND   purpose_lookup.lookup_code       = pt.payment_purpose_code
   AND   vendor.vendor_id                 = pi.vendor_id
   AND   ou.organization_id               = pi.org_id
   AND   1                                = :l_one ';

-- where clauses for 3 cases of grouping rule attached to
-- 1. item level
   l_where_clause_item  VARCHAR2(2000) := ' AND pi.grouping_rule_id IS NOT NULL
                                            AND pi.grouping_rule_id = :l_id ';

-- 2. term level
   l_where_clause_term  VARCHAR2(2000) := ' AND pi.grouping_rule_id IS NULL
                                            AND pt.grouping_rule_id IS NOT NULL
                                            AND pt.grouping_rule_id = :l_id ';
-- 3. lease level
   l_where_clause_lease VARCHAR2(2000) := ' AND pi.grouping_rule_id  IS NULL
                                            AND pt.grouping_rule_id  IS NULL
                                            AND pld.grouping_rule_id IS NOT NULL
                                            AND pld.grouping_rule_id = :l_id ';
-- 4. system option level
   l_where_clause_sysop VARCHAR2(2000) := ' AND pi.grouping_rule_id  IS NULL
                                            AND pt.grouping_rule_id  IS NULL
                                            AND pld.grouping_rule_id IS NULL
                                            AND -1                   = :l_id ';

-- order by clause to be used for all cases for mandatory attributes
--
-- mapping is as follows for the mandatory attributes
--
-- Supplier         pi.vendor_id
-- Supplier Site    pi.vendor_site_id
-- Payment Terms    pt.ap_ar_term_id
-- GL Date          gl_date
-- Invoice Date     pi.due_date
-- Currency code    pi.export_currency_code
-- Exchange rate    conv_rate
-- Exchange date    pi.accounted_date
-- Exchange type    conv_rate_type
-- Legal entity id  legal_entity_id

   l_order_by_clause VARCHAR2(2000) := ' pi.vendor_id,
                                         pi.vendor_site_id,
                                         pt.ap_ar_term_id,
                                         gl_date,
                                         pi.due_date,
                                         pi.export_currency_code,
                                         conv_rate,
                                         TRUNC(pi.accounted_date),
                                         conv_rate_type,
                                         legal_entity_id  ';

-- order by clause to be used for cases of grouping rule attached to
-- 1. item level

   l_order_by_clause_item    VARCHAR2(2000) := ' ORDER BY item_grouping_rule_id, ';

-- 2. term level

   l_order_by_clause_term    VARCHAR2(2000) := ' ORDER BY term_grouping_rule_id, ';

-- 3. lease level

   l_order_by_clause_lease   VARCHAR2(2000) := ' ORDER BY lease_grouping_rule_id, ';

-- 4. order by for optional attributes

   l_order_by_clause_grpby   VARCHAR2(2000) := '';

-- 5. default

   l_order_by_clause_default VARCHAR2(2000) := ' ORDER BY le.lease_id ';

-- export to AP items cache for grouping and processing

   exp_ap_cache              exp_ap_tbl_typ;
   exp_ap_lines_cache        exp_ap_tbl_typ;
   exp_ap_dist_cache         exp_ap_tbl_typ;

-- account distribution info

   CURSOR get_acnt_info(p_term_id NUMBER) IS
      SELECT account_id,
             account_class,
             percentage
      FROM   pn_distributions_all
      WHERE  payment_term_id = p_term_id;

   TYPE acnt_type IS TABLE OF get_acnt_info%ROWTYPE
   INDEX BY BINARY_INTEGER;

   lia_acnt_tab              acnt_type;
   exp_acnt_tab              acnt_type;
   acc_acnt_tab              acnt_type;

   l_total_exp_amt           NUMBER := 0;
   l_total_exp_percent       NUMBER := 0;
   l_diff_amt                NUMBER := 0;
   l_amt                     NUMBER := 0;
   l_exp_amt                 NUMBER := 0;
   l_lia_cnt                 NUMBER := 0;
   l_exp_cnt                 NUMBER := 0;
   l_acc_cnt                 NUMBER := 0;

-- tax name

   CURSOR get_tax_name(p_tax_id NUMBER) IS
      SELECT name
      FROM   ap_tax_codes_all
      WHERE  tax_id = p_tax_id;

   l_tax_name                ap_tax_codes.name%TYPE;
   l_tax_code_override_flag  ap_invoice_lines_interface.tax_code_override_flag%TYPE := NULL;

-- functional currrency code

   CURSOR get_func_curr_code(p_set_of_books_id IN NUMBER) IS
      SELECT currency_code
      FROM   gl_sets_of_books
      WHERE  set_of_books_id = p_set_of_books_id;

-- currency precision

   l_precision               NUMBER;
   l_ext_precision           NUMBER;
   l_min_acct_unit           NUMBER;

-- system level grouping rule ID

   CURSOR get_system_grouping_rule_id(p_org_ID IN NUMBER) IS
      SELECT grouping_rule_id
      FROM pn_system_setup_options
      WHERE org_id = p_org_ID;

-- group by attributes

   CURSOR get_group_bys(p_grouping_rule_id IN NUMBER) IS
      SELECT group_by_id,
             grouping_rule_id,
             group_by_lookup_code
      FROM pn_pay_group_bys
      WHERE grouping_rule_id = p_grouping_rule_id;

-- group by flags

   l_grpby_INVOICENUM        BOOLEAN := FALSE;
   l_grpby_LEASENUM          BOOLEAN := FALSE;
   l_grpby_PAYPURPOSE        BOOLEAN := FALSE;
   l_grpby_PAYTYPE           BOOLEAN := FALSE;

-- counters for total and error

   l_total_ctr               NUMBER := 0;
   l_error_ctr               NUMBER := 0;

-- for interface

   l_invoice_id              ap_invoices_interface.invoice_id%type;
   l_invoice_num             ap_invoices_interface.invoice_num%type;
   l_invoice_line_id         ap_invoice_lines_interface.invoice_line_id%type;

-- other variables

   l_system_grouping_rule_id NUMBER;
   l_created_by              NUMBER := FND_GLOBAL.USER_ID;
   l_creation_date           DATE   := sysdate;
   l_last_updated_by         NUMBER := FND_GLOBAL.USER_ID;
   l_last_update_login       NUMBER := FND_GLOBAL.LOGIN_ID;
   l_last_update_date        DATE   := sysdate;
   l_context                 VARCHAR2(2000);

/* EXCEPTIONS */
   BAD_ITEM_EXCEPTION EXCEPTION;
   BAD_INVOICE_NUM    EXCEPTION;
   FATAL_ERROR        EXCEPTION;

-- variables for dbms_sql
   l_cursor           INTEGER;
   l_rows             INTEGER;
   l_count            INTEGER;
   l_cursor_2         INTEGER;
   Q_Payitem1         VARCHAR2(5000);
   l_rows_2           INTEGER;
   l_count_2          INTEGER;



/*       ******************* END OF DECLARATIONS *******************        */

/* ************************************************************************
                           PROCEDURES BEGIN HERE
   ************************************************************************ */

--------------------------------------------------------------------------------
--  NAME         : get_liability_acc
--  DESCRIPTION  : Gets the Liability account for a payment item given the
--                 Payment Term ID. If a Term has no Liabilty account defined in
--                 its distributions, the Liability account is defaulted from
--                 the Vendor Site; in case a Liability account is not defined
--                 for a Vendor Site, it is defaulted from the Vendor.
--  PURPOSE      : Gets the Liability account.
--  INVOKED FROM : The main query
--  ARGUMENTS    : p_payment_term_id - Payment Term ID
--                 p_vendor_id       - Vendor ID in PO_VENDORS
--                 p_vendor_site_id  - Vendor Site ID in PO_VENDOR_SITES
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  19-DEC-2003  Kiran    o Created
--  12-SEP-2005  sdmahesh o Removed NVL from the cursor get_lia_vendor_site
--                          query
--------------------------------------------------------------------------------
FUNCTION get_liability_acc(p_payment_term_id NUMBER,
                           p_vendor_id       NUMBER,
                           p_vendor_site_id  NUMBER)
RETURN NUMBER IS

   CURSOR get_lia_acnt(p_term_id IN NUMBER) IS
      SELECT account_id
      FROM   pn_distributions_all
      WHERE  payment_term_id = p_term_id
      AND    account_class = 'LIA';

   CURSOR get_lia_vendor_site(p_vendor_site IN NUMBER) IS
      SELECT site.accts_pay_code_combination_id as accts_pay_code_combination_id
      FROM   po_vendor_sites site
      WHERE  site.vendor_site_id = p_vendor_site_id;

   account_id NUMBER := NULL;

BEGIN
-- ** uncomment the following for debugging **
-- PNP_DEBUG_PKG.log('pn_exp_to_ap.get_liability_acc (+)');
-- PNP_DEBUG_PKG.log('p_payment_term_id: '||p_payment_term_id);
-- PNP_DEBUG_PKG.log('p_vendor_id: '      ||p_vendor_id);
-- PNP_DEBUG_PKG.log('p_vendor_site_id: ' ||p_vendor_site_id);

  l_context := 'Getting account info for Payment term ID: '
                ||p_payment_term_id;

  FOR lia_acc IN get_lia_acnt(p_payment_term_id) LOOP
     account_id := lia_acc.account_id;
  END LOOP;

  IF account_id IS NULL THEN
     FOR lia_acc IN get_lia_vendor_site(p_vendor_site_id) LOOP
        account_id := lia_acc.accts_pay_code_combination_id;
     END LOOP;
  END IF;

-- ** uncomment the following for debugging **
-- PNP_DEBUG_PKG.log('account_id: '||account_id);
-- PNP_DEBUG_PKG.log('pn_exp_to_ap.get_liability_acc (-)');

  RETURN account_id;

EXCEPTION
   WHEN others THEN
      RAISE;

END get_liability_acc;

--------------------------------------------------------------------------------
--  NAME         : populate_group_by_flags
--  DESCRIPTION  : Populates group by flags to be used later by
--                 get_order_by_grpby to create the order by clause and by
--                 group_and_export_to_AP for flagging groups.
--  PURPOSE      : Populates group by flags
--  INVOKED FROM : exp_to_ap
--  ARGUMENTS    : p_grouping_rule_id - Grouping Rule ID
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  19-DEC-2003  Kiran    o Created
--------------------------------------------------------------------------------
PROCEDURE populate_group_by_flags(p_grouping_rule_id IN NUMBER) IS

BEGIN
   PNP_DEBUG_PKG.log('pn_exp_to_ap.populate_group_by_flags (+)');
   PNP_DEBUG_PKG.log('p_grouping_rule_id: '||p_grouping_rule_id);

   l_context := 'Populating group by flags for Grouping Rule ID: '
                 || p_grouping_rule_id;

-- init the flags

   l_grpby_INVOICENUM := FALSE;
   l_grpby_LEASENUM   := FALSE;
   l_grpby_PAYPURPOSE := FALSE;
   l_grpby_PAYTYPE    := FALSE;

   FOR group_bys IN get_group_bys(p_grouping_rule_id) LOOP

      IF group_bys.group_by_lookup_code = 'INVOICENUM' THEN
         l_grpby_INVOICENUM := TRUE;
      ELSIF group_bys.group_by_lookup_code = 'LEASENUM' THEN
         l_grpby_LEASENUM   := TRUE;
      ELSIF group_bys.group_by_lookup_code = 'PAYPURPOSE' THEN
         l_grpby_PAYPURPOSE := TRUE;
      ELSIF group_bys.group_by_lookup_code = 'PAYTYPE' THEN
         l_grpby_PAYTYPE    := TRUE;
      END IF;

   END LOOP;

   PNP_DEBUG_PKG.log('pn_exp_to_ap.populate_group_by_flags (-)');

EXCEPTION
   WHEN others THEN
      RAISE;
END populate_group_by_flags;

--------------------------------------------------------------------------------
--  NAME         : get_order_by_grpby
--  DESCRIPTION  : Conditionally creates the order by clause incrementally,
--                 based on the global grouping flags set by call to
--                 populate_group_by_flags
--  ** NOTE      : Call this only after a call to populate_group_by_flags
--  PURPOSE      : Creates the order by clause for grouping attributes
--  INVOKED FROM : exp_to_ap
--  ARGUMENTS    : none
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  19-DEC-2003  Kiran    o Created
--------------------------------------------------------------------------------
PROCEDURE get_order_by_grpby IS

BEGIN
   PNP_DEBUG_PKG.log('pn_exp_to_ap.get_order_by_grpby (+)');

   l_context := 'Creating order by clause';

   IF l_grpby_INVOICENUM THEN
      l_order_by_clause_grpby := l_order_by_clause_grpby || ' , pi.ap_invoice_num ';
   END IF;

   IF l_grpby_LEASENUM THEN
      l_order_by_clause_grpby := l_order_by_clause_grpby || ' , le.lease_num ';
   END IF;

   IF l_grpby_PAYPURPOSE THEN
      l_order_by_clause_grpby := l_order_by_clause_grpby || ' , pt.payment_purpose_code ';
   END IF;

   IF l_grpby_PAYTYPE THEN
      l_order_by_clause_grpby := l_order_by_clause_grpby || ' , pt.payment_term_type_code ';
   END IF;

   PNP_DEBUG_PKG.log('pn_exp_to_ap.get_order_by_grpby (-)');

EXCEPTION
   WHEN others THEN
      RAISE;

END get_order_by_grpby;

--------------------------------------------------------------------------------
--  NAME         : bind_variables_to_cursor
--  PURPOSE      : Binding the variables to the cursor passed
--  INVOKED FROM : cache_exp_items
--  ARGUMENTS    : p_lease_num_low
--                 p_lease_num_high
--                 p_sch_dt_low
--                 p_sch_dt_high
--                 p_due_dt_low
--                 p_due_dt_high
--                 p_pay_prps_code
--                 p_prd_name
--                 p_amt_low
--                 p_amt_high
--                 p_vendor_id
--                 p_inv_num
--                 p_grp_param
--                 p_cursor
--  HISTORY      :
-- 30-NOV-05 Hareesha      o Created
--------------------------------------------------------------------------------
PROCEDURE bind_variables_to_cursor(
                                    p_lease_num_low      VARCHAR2,
                                    p_lease_num_high     VARCHAR2,
                                    p_sch_dt_low         VARCHAR2,
                                    p_sch_dt_high        VARCHAR2,
                                    p_due_dt_low         VARCHAR2,
                                    p_due_dt_high        VARCHAR2,
                                    p_pay_prps_code      VARCHAR2,
                                    p_prd_name           VARCHAR2,
                                    p_amt_low            NUMBER,
                                    p_amt_high           NUMBER,
                                    p_vendor_id          NUMBER,
                                    p_inv_num            VARCHAR2,
                                    p_grp_param          VARCHAR2,
                                    p_cursor             INTEGER) IS

 BEGIN

   PNP_DEBUG_PKG.log('pn_exp_to_ap.bind_variables_to_cursor (+)');

   dbms_sql.bind_variable
            (p_cursor,'l_one',l_one );
   dbms_sql.bind_variable
            (p_cursor,'l_id',l_id );

   IF p_grp_param IS NULL THEN

      IF p_lease_num_low IS NOT NULL AND p_lease_num_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_lease_num_low',p_lease_num_low );
         dbms_sql.bind_variable
            (p_cursor,'l_lease_num_high',p_lease_num_high );

      ELSIF p_lease_num_low IS NULL AND p_lease_num_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_lease_num_high',p_lease_num_high );

      ELSIF p_lease_num_low IS NOT NULL AND p_lease_num_high IS NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_lease_num_low',p_lease_num_low );
      END IF;

      IF p_sch_dt_low IS NOT NULL AND p_sch_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_sch_dt_high',fnd_date.canonical_to_date(p_sch_dt_high) );
         dbms_sql.bind_variable
            (p_cursor,'l_sch_dt_low',fnd_date.canonical_to_date(p_sch_dt_low) );

      ELSIF p_sch_dt_low IS NULL AND p_sch_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_sch_dt_high',fnd_date.canonical_to_date(p_sch_dt_high) );

      ELSIF p_sch_dt_low IS NOT NULL AND p_sch_dt_high IS NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_sch_dt_low',fnd_date.canonical_to_date(p_sch_dt_low) );
      END IF;

      IF p_due_dt_low IS NOT NULL AND p_due_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_due_dt_low',fnd_date.canonical_to_date(p_due_dt_low) );
         dbms_sql.bind_variable
            (p_cursor,'l_due_dt_high',fnd_date.canonical_to_date(p_due_dt_high) );

      ELSIF p_due_dt_low IS NULL AND p_due_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_due_dt_high',fnd_date.canonical_to_date(p_due_dt_high) );

      ELSIF p_due_dt_low IS NOT NULL AND p_due_dt_high IS NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_due_dt_low',fnd_date.canonical_to_date(p_due_dt_low) );
      END IF;

      IF p_pay_prps_code IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_pay_prps_code',p_pay_prps_code );
      END IF;

      IF p_prd_name IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_prd_name',p_prd_name );
      END IF;

      IF p_amt_low IS NOT NULL AND p_amt_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_amt_low',p_amt_low );
         dbms_sql.bind_variable
            (p_cursor,'l_amt_high',p_amt_high );

      ELSIF p_amt_low IS NULL AND p_amt_high IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_amt_high',p_amt_high );

      ELSIF p_amt_low IS NOT NULL AND p_amt_high IS NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_amt_low',p_amt_low );
      END IF;

      IF p_vendor_id IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_vendor_id',p_vendor_id );
      END IF;

      IF p_inv_num IS NOT NULL THEN
         dbms_sql.bind_variable
            (p_cursor,'l_inv_num',p_inv_num );
      END IF;

   ELSE
      dbms_sql.bind_variable
         (p_cursor,'l_grp_param',p_grp_param );
   END IF;

   PNP_DEBUG_PKG.log('pn_exp_to_ap.bind_variables_to_cursor (-)');


EXCEPTION
   WHEN FATAL_ERROR THEN
      RAISE;
   WHEN others THEN
      RAISE;

END bind_variables_to_cursor;

--------------------------------------------------------------------------------
--  NAME         : cache_exp_items
--  DESCRIPTION  : Uses the query string created in Q_Payitems to query and
--                 cache the valid payment items. At a given time, the cache is
--                 designed to contain items with the same grouping rule. The
--                 items are also ordered in groups, but the groups will need to
--                 be identified at begin/end and flagged accordingly.
--  PURPOSE      : Cache items for export to AP
--  INVOKED FROM : exp_to_ap
--  ARGUMENTS    :
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
-- 19-DEC-03 Kiran    o Created
-- 22-NOV-04 Kiran    o Fixed validations for terms distributions
-- 19-NOV-04 Anand    o Bug # 4015081 - invoice number should be unique for a
--                      a vendor - org_id combination.
-- 15-JUN-05 Kiran    o Bug # 4303846 Used exceptions to handle errors.
-- 26-OCT-05 Hareesha o ATG mandated changes for SQL literals using dbms_sql.
-- 30-NOV-05 Hareesha o Code changes for LE uptake.
--------------------------------------------------------------------------------
PROCEDURE cache_exp_items (p_lease_num_low      VARCHAR2,
                           p_lease_num_high     VARCHAR2,
                           p_sch_dt_low         VARCHAR2,
                           p_sch_dt_high        VARCHAR2,
                           p_due_dt_low         VARCHAR2,
                           p_due_dt_high        VARCHAR2,
                           p_pay_prps_code      VARCHAR2,
                           p_prd_name           VARCHAR2,
                           p_amt_low            NUMBER,
                           p_amt_high           NUMBER,
                           p_vendor_id          NUMBER,
                           p_inv_num            VARCHAR2,
                           p_grp_param          VARCHAR2)

IS

-- ref cursor

   l_index   NUMBER := 0;
   l_lia_acc NUMBER := 0;

   -- local variables to temporarily hold fetched values
   v_org_id                                NUMBER;
   v_pn_payment_item_id                    NUMBER;
   v_pn_payment_term_id                    NUMBER;
   v_pn_export_currency_amount             NUMBER;
   v_pn_export_currency_code               VARCHAR2(15);
   v_pn_vendor_id                          NUMBER;
   v_pn_vendor_site_id                     NUMBER;
   v_pn_project_id                         NUMBER;
   v_pn_task_id                            NUMBER;
   v_pn_organization_id                    NUMBER;
   v_pn_expenditure_type                   VARCHAR2(30);
   v_pn_expenditure_item_date              DATE;
   v_pn_tax_group_id                       NUMBER;
   v_pn_tax_code_id                        NUMBER;
   v_pn_tax_classification_code            VARCHAR2(30);
   v_pn_tax_included                       VARCHAR2(1);
   v_pn_legal_entity_id                    NUMBER;
   v_pn_distribution_set_id                NUMBER;
   v_pn_lease_num                          VARCHAR2(30);
   v_pn_lease_id                           NUMBER;
   v_pn_send_entries                       VARCHAR2(1);
   v_pn_payment_schedule_id                NUMBER;
   v_pn_period_name                        VARCHAR2(15);
   v_gl_date                               DATE;
   v_pn_normalize                          VARCHAR2(1);
   v_pn_due_date                           DATE;
   v_pn_ap_ar_term_id                      NUMBER;
   v_pn_accounted_date                     DATE;
   v_pn_rate                               NUMBER;
   v_pn_ap_invoice_num                     VARCHAR2(50);
   v_pn_payment_purpose_code               VARCHAR2(30);
   v_pn_payment_term_type_code             VARCHAR2(30);
   v_pn_lia_account                        NUMBER;
   v_conv_rate                             NUMBER;
   v_conv_rate_type                        VARCHAR2(30);
   v_item_grouping_rule_id                 NUMBER;
   v_term_grouping_rule_id                 NUMBER;
   v_lease_grouping_rule_id                NUMBER;

   CURSOR c_inv_num( p_invoice_num IN VARCHAR2
                    ,p_vendor_id   IN NUMBER
                    ,p_org_ID      IN NUMBER) IS
      SELECT 1
      FROM   DUAL
      WHERE EXISTS(SELECT 1
                   FROM   ap_invoices_all
                   WHERE  invoice_num = p_invoice_num
                   AND    vendor_id = p_vendor_id
                   AND    org_ID = p_org_ID);

   CURSOR c_inv_num_itf( p_invoice_num IN VARCHAR2
                        ,p_vendor_id   IN NUMBER
                        ,p_org_ID      IN NUMBER) IS
      SELECT 1
      FROM   DUAL
      WHERE EXISTS(SELECT 1
                   FROM   ap_invoices_interface
                   WHERE  invoice_num = p_invoice_num
                   AND    vendor_id = p_vendor_id
                   AND    org_ID = p_org_ID);

   TYPE NUMBER_tbl_typ IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   term_ID_tbl  NUMBER_tbl_typ;
   LE_tbl       NUMBER_tbl_typ;

   l_index_2 NUMBER;

BEGIN
   PNP_DEBUG_PKG.log('pn_exp_to_ap.cache_exp_items (+)');

   l_context := 'Caching items for export to AP';

-- init
   exp_ap_cache.DELETE;
   l_index := 0;
   l_index_2 := 0;

   l_cursor := dbms_sql.open_cursor;

   dbms_sql.parse(l_cursor, Q_Payitem, dbms_sql.native);

   bind_variables_to_cursor(p_lease_num_low,
                            p_lease_num_high,
                            p_sch_dt_low,
                            p_sch_dt_high,
                            p_due_dt_low,
                            p_due_dt_high,
                            p_pay_prps_code,
                            p_prd_name,
                            p_amt_low,
                            p_amt_high,
                            p_vendor_id,
                            p_inv_num,
                            p_grp_param,
                            l_cursor);

   Q_Payitem1 := 'SELECT DISTINCT payment_term_id,
                                  vendor_site_id,
                                  lia_account,
                                  org_id
                                  FROM ( '
                  || Q_Payitem ||
                  ' ) WHERE legal_entity_id IS NULL ';

   term_ID_tbl.DELETE;
   LE_tbl.DELETE;

   l_cursor_2 := dbms_sql.open_cursor;
   dbms_sql.parse(l_cursor_2, Q_Payitem1, dbms_sql.native);

   pnp_debug_pkg.log('Q_Payitem1:'||Q_Payitem1);

   bind_variables_to_cursor(p_lease_num_low,
                            p_lease_num_high,
                            p_sch_dt_low,
                            p_sch_dt_high,
                            p_due_dt_low,
                            p_due_dt_high,
                            p_pay_prps_code,
                            p_prd_name,
                            p_amt_low,
                            p_amt_high,
                            p_vendor_id,
                            p_inv_num,
                            p_grp_param,
                            l_cursor_2);

   l_rows_2   := dbms_sql.execute(l_cursor_2);

   dbms_sql.define_column (l_cursor_2, 1, v_pn_payment_term_id);
   dbms_sql.define_column (l_cursor_2, 2, v_pn_vendor_site_id);
   dbms_sql.define_column (l_cursor_2, 3, v_pn_lia_account);
   dbms_sql.define_column (l_cursor_2, 4, v_org_id);


   LOOP

     l_count_2 := dbms_sql.fetch_rows( l_cursor_2 );
     EXIT WHEN l_count_2 <> 1;

     l_index_2 := l_index_2 + 1;

     dbms_sql.column_value (l_cursor_2, 1, term_ID_tbl(l_index_2));
     dbms_sql.column_value (l_cursor_2, 2, v_pn_vendor_site_id);
     dbms_sql.column_value (l_cursor_2, 3, v_pn_lia_account);
     dbms_sql.column_value (l_cursor_2, 4, v_org_id);

     LE_tbl(l_index_2) := pn_r12_util_pkg.get_le_for_ap(v_pn_lia_account,v_pn_vendor_site_id,v_org_id);

   END LOOP;

   IF dbms_sql.is_open (l_cursor_2) THEN
     dbms_sql.close_cursor (l_cursor_2);
   END IF;

   FORALL i IN term_ID_tbl.FIRST..term_ID_tbl.LAST
      UPDATE pn_payment_terms_all
      SET legal_entity_id = LE_tbl(i)
      WHERE payment_term_id = term_ID_tbl(i);

   l_rows   := dbms_sql.execute(l_cursor);

   dbms_sql.define_column (l_cursor, 1, v_org_id);
   dbms_sql.define_column (l_cursor, 2, v_pn_payment_item_id);
   dbms_sql.define_column (l_cursor, 3, v_pn_payment_term_id);
   dbms_sql.define_column (l_cursor, 4, v_pn_export_currency_amount);
   dbms_sql.define_column (l_cursor, 5, v_pn_export_currency_code,15);
   dbms_sql.define_column (l_cursor, 6, v_pn_vendor_id);
   dbms_sql.define_column (l_cursor, 7, v_pn_vendor_site_id);
   dbms_sql.define_column (l_cursor, 8, v_pn_project_id);
   dbms_sql.define_column (l_cursor, 9, v_pn_task_id);
   dbms_sql.define_column (l_cursor, 10,v_pn_organization_id);
   dbms_sql.define_column (l_cursor, 11,v_pn_expenditure_type,30);
   dbms_sql.define_column (l_cursor, 12,v_pn_expenditure_item_date);
   dbms_sql.define_column (l_cursor, 13,v_pn_tax_group_id);
   dbms_sql.define_column (l_cursor, 14,v_pn_tax_code_id);
   dbms_sql.define_column (l_cursor, 15,v_pn_tax_classification_code,30);
   dbms_sql.define_column (l_cursor, 16,v_pn_tax_included,1);
   dbms_sql.define_column (l_cursor, 17,v_pn_distribution_set_id);
   dbms_sql.define_column (l_cursor, 18,v_pn_lease_num,30);
   dbms_sql.define_column (l_cursor, 19,v_pn_lease_id);
   dbms_sql.define_column (l_cursor, 20,v_pn_send_entries,1);
   dbms_sql.define_column (l_cursor, 21,v_pn_payment_schedule_id);
   dbms_sql.define_column (l_cursor, 22,v_pn_period_name,15);
   dbms_sql.define_column (l_cursor, 23,v_gl_date);
   dbms_sql.define_column (l_cursor, 24,v_pn_normalize,1);
   dbms_sql.define_column (l_cursor, 25,v_pn_due_date);
   dbms_sql.define_column (l_cursor, 26,v_pn_ap_ar_term_id);
   dbms_sql.define_column (l_cursor, 27,v_pn_accounted_date);
   dbms_sql.define_column (l_cursor, 28,v_pn_rate);
   dbms_sql.define_column (l_cursor, 29,v_pn_ap_invoice_num,50);
   dbms_sql.define_column (l_cursor, 30,v_pn_payment_purpose_code,30);
   dbms_sql.define_column (l_cursor, 31,v_pn_payment_term_type_code,30);
   dbms_sql.define_column (l_cursor, 32,v_pn_lia_account);
   dbms_sql.define_column (l_cursor, 33,v_pn_legal_entity_id);
   dbms_sql.define_column (l_cursor, 34,v_conv_rate);
   dbms_sql.define_column (l_cursor, 35,v_conv_rate_type,30);
   dbms_sql.define_column (l_cursor, 36,v_item_grouping_rule_id);
   dbms_sql.define_column (l_cursor, 37,v_term_grouping_rule_id);
   dbms_sql.define_column (l_cursor, 38,v_lease_grouping_rule_id);

   LOOP

     l_index := l_index + 1;

     l_count := dbms_sql.fetch_rows( l_cursor );
     EXIT WHEN l_count <> 1;

     dbms_sql.column_value (l_cursor, 1, exp_ap_cache(l_index).org_id);
     dbms_sql.column_value (l_cursor, 2, exp_ap_cache(l_index).pn_payment_item_id);
     dbms_sql.column_value (l_cursor, 3, exp_ap_cache(l_index).pn_payment_term_id);
     dbms_sql.column_value (l_cursor, 4, exp_ap_cache(l_index).pn_export_currency_amount);
     dbms_sql.column_value (l_cursor, 5, exp_ap_cache(l_index).pn_export_currency_code);
     dbms_sql.column_value (l_cursor, 6, exp_ap_cache(l_index).pn_vendor_id);
     dbms_sql.column_value (l_cursor, 7, exp_ap_cache(l_index).pn_vendor_site_id);
     dbms_sql.column_value (l_cursor, 8, exp_ap_cache(l_index).pn_project_id);
     dbms_sql.column_value (l_cursor, 9, exp_ap_cache(l_index).pn_task_id);
     dbms_sql.column_value (l_cursor, 10,exp_ap_cache(l_index).pn_organization_id);
     dbms_sql.column_value (l_cursor, 11,exp_ap_cache(l_index).pn_expenditure_type);
     dbms_sql.column_value (l_cursor, 12,exp_ap_cache(l_index).pn_expenditure_item_date);
     dbms_sql.column_value (l_cursor, 13,exp_ap_cache(l_index).pn_tax_group_id);
     dbms_sql.column_value (l_cursor, 14,exp_ap_cache(l_index).pn_tax_code_id);
     dbms_sql.column_value (l_cursor, 15,exp_ap_cache(l_index).pn_tax_classification_code);
     dbms_sql.column_value (l_cursor, 16,exp_ap_cache(l_index).pn_tax_included);
     dbms_sql.column_value (l_cursor, 17,exp_ap_cache(l_index).pn_distribution_set_id);
     dbms_sql.column_value (l_cursor, 18,exp_ap_cache(l_index).pn_lease_num);
     dbms_sql.column_value (l_cursor, 19,exp_ap_cache(l_index).pn_lease_id);
     dbms_sql.column_value (l_cursor, 20,exp_ap_cache(l_index).pn_send_entries);
     dbms_sql.column_value (l_cursor, 21,exp_ap_cache(l_index).pn_payment_schedule_id);
     dbms_sql.column_value (l_cursor, 22,exp_ap_cache(l_index).pn_period_name);
     dbms_sql.column_value (l_cursor, 23,exp_ap_cache(l_index).gl_date);
     dbms_sql.column_value (l_cursor, 24,exp_ap_cache(l_index).pn_normalize);
     dbms_sql.column_value (l_cursor, 25,exp_ap_cache(l_index).pn_due_date);
     dbms_sql.column_value (l_cursor, 26,exp_ap_cache(l_index).pn_ap_ar_term_id);
     dbms_sql.column_value (l_cursor, 27,exp_ap_cache(l_index).pn_accounted_date);
     dbms_sql.column_value (l_cursor, 28,exp_ap_cache(l_index).pn_rate);
     dbms_sql.column_value (l_cursor, 29,exp_ap_cache(l_index).pn_ap_invoice_num);
     dbms_sql.column_value (l_cursor, 30,exp_ap_cache(l_index).pn_payment_purpose_code);
     dbms_sql.column_value (l_cursor, 31,exp_ap_cache(l_index).pn_payment_term_type_code);
     dbms_sql.column_value (l_cursor, 32,exp_ap_cache(l_index).pn_lia_account);
     dbms_sql.column_value (l_cursor, 33,exp_ap_cache(l_index).pn_legal_entity_id);
     dbms_sql.column_value (l_cursor, 34,exp_ap_cache(l_index).conv_rate);
     dbms_sql.column_value (l_cursor, 35,exp_ap_cache(l_index).conv_rate_type);
     dbms_sql.column_value (l_cursor, 36,exp_ap_cache(l_index).item_grouping_rule_id);
     dbms_sql.column_value (l_cursor, 37,exp_ap_cache(l_index).term_grouping_rule_id);
     dbms_sql.column_value (l_cursor, 38,exp_ap_cache(l_index).lease_grouping_rule_id);

     exp_ap_cache(l_index).processed := 'N';

      -- validate the item

      -- Note: tax_include flag for R12 can have 3 values: 'A', 'N', and 'S'
      -- 'A': Yes, 'N': No, 'S': Use system default
      -- Add logic to handle legacy data, where 'Y' : Yes, and 'N' / null = No

      IF pn_r12_util_pkg.is_r12 THEN
        IF exp_ap_cache(l_index).pn_tax_included = 'Y' THEN
            exp_ap_cache(l_index).pn_tax_included := 'A';
        END IF;
      END IF;

      l_total_exp_amt := 0;
      l_total_exp_percent := 0;

      IF exp_ap_cache(l_index).pn_distribution_set_id IS NULL
         AND exp_ap_cache(l_index).pn_project_id IS NULL THEN

         -- validate distributions
         l_lia_cnt        := 0;
         l_acc_cnt        := 0;
         l_exp_cnt        := 0;

         FOR acnt_rec IN get_acnt_info(exp_ap_cache(l_index).pn_payment_term_id) LOOP

            IF acnt_rec.account_class  = 'LIA' THEN
               l_lia_cnt := l_lia_cnt + 1;
            ELSIF acnt_rec.account_class  = 'EXP' THEN
               l_exp_cnt := l_exp_cnt + 1;
            ELSIF acnt_rec.account_class  = 'ACC' THEN
               l_acc_cnt := l_acc_cnt + 1;
            END IF;

         END LOOP; -- for account in

      END IF; -- if dist_set/project is null

      BEGIN

         IF exp_ap_cache(l_index).pn_distribution_set_id IS NULL AND
            exp_ap_cache(l_index).pn_project_id IS NULL THEN

            IF NVL(exp_ap_cache(l_index).pn_normalize,'N') = 'Y' AND
               (l_exp_cnt = 0 OR l_acc_cnt = 0) THEN

               fnd_message.set_name ('PN', 'PN_ALL_ACNT_DIST_MSG');
               PNP_DEBUG_PKG.put_log_msg(fnd_message.get);
               RAISE BAD_ITEM_EXCEPTION;

            ELSIF NVL(exp_ap_cache(l_index).pn_normalize,'N') = 'N' AND
               l_exp_cnt = 0 THEN

               fnd_message.set_name ('PN', 'PN_EXP_DIST_MSG');
               PNP_DEBUG_PKG.put_log_msg(fnd_message.get);
               RAISE BAD_ITEM_EXCEPTION;

            END IF;

         ELSIF UPPER(exp_ap_cache(l_index).conv_rate_type) = 'USER' AND
               exp_ap_cache(l_index).conv_rate IS NULL THEN

            fnd_message.set_name ('PN', 'PN_CONV_RATE_REQD');
            pnp_debug_pkg.put_log_msg(fnd_message.get);
            RAISE BAD_ITEM_EXCEPTION;

         ELSIF l_grpby_INVOICENUM THEN
            IF exp_ap_cache(l_index).pn_ap_invoice_num IS NOT NULL THEN
               FOR i IN c_inv_num(exp_ap_cache(l_index).pn_ap_invoice_num,
                                  exp_ap_cache(l_index).pn_vendor_id,
                                  exp_ap_cache(l_index).org_id)
               LOOP
                  fnd_message.set_name ('PN', 'PN_INV_NUM_ALREADY_EXIST');
                  pnp_debug_pkg.put_log_msg(fnd_message.get);
                  RAISE BAD_ITEM_EXCEPTION;
               END LOOP;
               FOR i IN c_inv_num_itf(exp_ap_cache(l_index).pn_ap_invoice_num,
                                      exp_ap_cache(l_index).pn_vendor_id,
                                      exp_ap_cache(l_index).org_id)
               LOOP
                  fnd_message.set_name ('PN', 'PN_INV_NUM_ALREADY_EXIST');
                  pnp_debug_pkg.put_log_msg(fnd_message.get);
                  RAISE BAD_ITEM_EXCEPTION;
               END LOOP;
            END IF;
         END IF;

      EXCEPTION
         WHEN BAD_ITEM_EXCEPTION THEN
            fnd_message.set_name ('PN','PN_EXPAP_ERR');
            fnd_message.set_token ('ID',exp_ap_cache(l_index).pn_payment_item_id);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            l_error_ctr := l_error_ctr + 1;

            exp_ap_cache.DELETE(l_index);
            l_index := l_index - 1;

         WHEN OTHERS THEN
            fnd_message.set_name ('PN','PN_EXPAP_ERR');
            fnd_message.set_token ('ID',exp_ap_cache(l_index).pn_payment_item_id);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            pnp_debug_pkg.put_log_msg(SQLERRM);
            RAISE;
      END;
   END LOOP;

   IF dbms_sql.is_open (l_cursor) THEN
     dbms_sql.close_cursor (l_cursor);
   END IF;

   l_total_ctr := l_total_ctr + l_index - 1;

   PNP_DEBUG_PKG.log('pn_exp_to_ap.cache_exp_items (-)');

EXCEPTION
   WHEN others THEN
      RAISE;

END cache_exp_items;

-------------------------------------------------------------------------------
--  NAME         : group_and_export_items
--  DESCRIPTION  : Loop through the PL/SQL table to find the groups of items
--                 that can be grouped into a single transcation.
--
--                 Once a group has been identified,
--                 Insert into AP Invoice interface one record for the
--                 Invoice with the Expense account.
--                 For each Invoice, insert into the AP Invoice Lines
--                 interface table as many records as the Distributions
--                 for Liability and Accrued Liability per item.
--
--  PURPOSE      : Groups and exports items to AP interface table
--  INVOKED FROM : exp_to_ap
--  ARGUMENTS    : errbuf    - Error Buffer
--                 retcode   - Rerurn Code, indicates if the CP should end in
--                             success or failure.
--                 p_group_id - Export Group ID
--                 p_param_where_clause  - Where clause from SYSTEM.last_query
--                                         from the Export to AP form.
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
-- 19-DEC-03 Kiran      o Created
-- 17-Jun-04 Kiran      o Bug # 4303846
--                        If GRP_BY_INVOICE_NUM and users specifies INVOICE_NUM
--                        If some other mandatory attribute stops us from
--                        creating a single group for all the items with
--                        the same invoice number then,
--                        DO NOT PROCESS ANY ITEM with that INVOICE_NUM
-- 30-NOV-05 Hareesha   o Code changes for LE uptake.
-- 24-SEP-07 rkartha    o Bug # 6392393. Added tax_classification_code in the INSERT
--                        statement into 'ap_invoice_lines_interface' table.
--------------------------------------------------------------------------------
PROCEDURE group_and_export_items(errbuf    IN OUT NOCOPY     VARCHAR2,
                                 retcode   IN OUT NOCOPY     NUMBER,
                                 p_group_id                  VARCHAR2,
                                 p_param_where_clause        VARCHAR2) IS

   l_lineNumber                NUMBER :=  0;
   l_prior_payment_schedule_id NUMBER := -999;
   l_start                     NUMBER := 0;
   l_next                      NUMBER := 0;
   l_item_prcsed               NUMBER := 0;
   l_count                     NUMBER := 0;
   l_header_amount             NUMBER;
   l_line_amount               NUMBER;

   CURSOR c_inv_num_itf( p_invoice_num IN VARCHAR2
                        ,p_vendor_id   IN NUMBER
                        ,p_org_ID      IN NUMBER) IS
      SELECT invoice_id
            ,invoice_num
      FROM   ap_invoices_interface
      WHERE  invoice_num = p_invoice_num
      AND    vendor_id = p_vendor_id
      AND    org_ID = p_org_ID;

   TYPE inv_rec IS RECORD
   ( invoice_id  ap_invoices_interface.invoice_id%TYPE
    ,invoice_num ap_invoices_interface.invoice_num%TYPE
    ,items_proc  NUMBER);

   TYPE inv_tab IS TABLE OF inv_rec INDEX BY BINARY_INTEGER;

   inserted_inv_t  inv_tab;
   bad_inv_t       inv_tab;
   l_temp_count    NUMBER;

   /* remove this after SEED bug for message PN_CANNOT_GRP_ON_INV is fixed */
   CURSOR exists_msg IS
      SELECT message_name
      FROM   fnd_new_messages
      WHERE  application_id = 240
      AND    message_name = 'PN_CANNOT_GRP_ON_INV';
   l_msg_exists BOOLEAN;

BEGIN

   PNP_DEBUG_PKG.log('pn_exp_to_ap.group_and_export_items (+)');

-- we already have the required items in the cache

   l_context := 'Exporting to AP with grouping';

   l_start := 1;
   l_next := 2;
   l_item_prcsed := 0;
   l_count := exp_ap_cache.COUNT;

   pnp_debug_pkg.log('The number of items to be processed :' || l_count);

   IF l_count < 1 THEN
      RETURN;
   END IF;

   l_context := 'Finding the Groups of items';

   /* init the tables */
   inserted_inv_t.DELETE;
   bad_inv_t.DELETE;

   WHILE (l_item_prcsed < l_count) LOOP

      IF ((l_next <= l_count) AND
          -- mandatory attrs
         (exp_ap_cache(l_start).pn_vendor_id = exp_ap_cache(l_next).pn_vendor_id) AND
         (exp_ap_cache(l_start).pn_vendor_site_id = exp_ap_cache(l_next).pn_vendor_site_id) AND
         ((exp_ap_cache(l_start).pn_ap_ar_term_id = exp_ap_cache(l_next).pn_ap_ar_term_id) OR
          (exp_ap_cache(l_start).pn_ap_ar_term_id IS NULL AND
           exp_ap_cache(l_next).pn_ap_ar_term_id IS NULL)) AND
         (exp_ap_cache(l_start).gl_date = exp_ap_cache(l_next).gl_date) AND
         (exp_ap_cache(l_start).pn_due_date = exp_ap_cache(l_next).pn_due_date) AND
         ((exp_ap_cache(l_start).pn_export_currency_code
           = exp_ap_cache(l_next).pn_export_currency_code) OR
          (exp_ap_cache(l_start).pn_export_currency_code IS NULL AND
           exp_ap_cache(l_next).pn_export_currency_code IS NULL)) AND
         ((exp_ap_cache(l_start).conv_rate = exp_ap_cache(l_next).conv_rate) OR
          (exp_ap_cache(l_start).conv_rate IS NULL AND
           exp_ap_cache(l_next).conv_rate IS NULL)) AND
         ((exp_ap_cache(l_start).pn_accounted_date = exp_ap_cache(l_next).pn_accounted_date) OR
          (exp_ap_cache(l_start).pn_accounted_date IS NULL AND
           exp_ap_cache(l_next).pn_accounted_date IS NULL)) AND
         ((exp_ap_cache(l_start).conv_rate_type = exp_ap_cache(l_next).conv_rate_type) OR
          (exp_ap_cache(l_start).conv_rate_type IS NULL AND
           exp_ap_cache(l_next).conv_rate_type IS NULL)) AND
         ((exp_ap_cache(l_start).pn_legal_entity_id = exp_ap_cache(l_next).pn_legal_entity_id) OR
          (exp_ap_cache(l_start).pn_legal_entity_id IS NULL AND
           exp_ap_cache(l_next).pn_legal_entity_id IS NULL)) AND
          -- mandatory attrs

          -- optional attrs
         ((l_grpby_INVOICENUM AND
          ((exp_ap_cache(l_start).pn_ap_invoice_num
            = exp_ap_cache(l_next).pn_ap_invoice_num) OR
           (exp_ap_cache(l_start).pn_ap_invoice_num IS NULL AND
            exp_ap_cache(l_next).pn_ap_invoice_num IS NULL))) OR
          (NOT l_grpby_INVOICENUM)) AND
         ((l_grpby_LEASENUM AND
          (exp_ap_cache(l_start).pn_lease_num = exp_ap_cache(l_next).pn_lease_num)) OR
          (NOT l_grpby_LEASENUM)) AND
         ((l_grpby_PAYPURPOSE AND
          (exp_ap_cache(l_start).pn_payment_purpose_code
           = exp_ap_cache(l_next).pn_payment_purpose_code)) OR
          (NOT l_grpby_PAYPURPOSE)) AND
         ((l_grpby_PAYTYPE AND
           (exp_ap_cache(l_start).pn_payment_term_type_code
            = exp_ap_cache(l_next).pn_payment_term_type_code)) OR
          (NOT l_grpby_PAYTYPE)) AND
         (exp_ap_cache(l_start).pn_lia_account = exp_ap_cache(l_next).pn_lia_account))
      THEN

         -- increment 'next' counter. we are still getting the super group.
         l_next := l_next + 1;

      ELSE -- we have group

         l_context := 'Get the amount for header.';

         l_header_amount := 0;

         FOR item IN l_start .. l_next-1 LOOP
            l_header_amount
            := l_header_amount + exp_ap_cache(item).pn_export_currency_amount;
         END LOOP;

         l_context := 'Insert into the header';

         -- Create the header

         l_lineNumber := 0;

         l_context := 'Inserting into ap_invoices_interface ...';

         fnd_currency.get_info(exp_ap_cache(l_start).pn_export_currency_code,
                               l_precision,
                               l_ext_precision,
                               l_min_acct_unit);

         IF l_grpby_INVOICENUM THEN
           l_invoice_num := exp_ap_cache(l_start).pn_ap_invoice_num;
         ELSE
           l_invoice_num := NULL;
         END IF;

         BEGIN
            IF l_invoice_num IS NOT NULL THEN
               /* if we find the l_invoice_num in the bad invoice num table,
                  dont bother processing the group */
               FOR bad_rec IN 1..bad_inv_t.COUNT LOOP
                  IF bad_inv_t(bad_rec).invoice_num = l_invoice_num THEN
                     RAISE BAD_INVOICE_NUM;
                  END IF;
               END LOOP;
               /* there is a chance a bad invoice number did not yet make into
                  the blacklist */
               FOR inv_rec IN
                  c_inv_num_itf
                     ( p_invoice_num => l_invoice_num
                      ,p_vendor_id   => exp_ap_cache(l_start).pn_vendor_id
                      ,p_org_ID      => exp_ap_cache(l_start).org_id)
               LOOP
                  IF bad_inv_t.LAST IS NULL THEN
                     l_temp_count := 1;
                  ELSE
                     l_temp_count := bad_inv_t.LAST + 1;
                  END IF;
                  bad_inv_t(l_temp_count).invoice_id  := inv_rec.invoice_id;
                  bad_inv_t(l_temp_count).invoice_num := inv_rec.invoice_num;
                  /* delete the data for the bad invoice number */
                  IF inv_rec.invoice_id = inserted_inv_t(inserted_inv_t.LAST).invoice_id AND
                     inv_rec.invoice_num = inserted_inv_t(inserted_inv_t.LAST).invoice_num
                  THEN
                     l_error_ctr := l_error_ctr + inserted_inv_t(inserted_inv_t.LAST).items_proc;
                     ROLLBACK TO beforeinsert;
                     RAISE BAD_INVOICE_NUM;
                  ELSE
                     RAISE FATAL_ERROR;
                  END IF;
               END LOOP;
            END IF;

            SAVEPOINT beforeinsert;

            INSERT INTO ap_invoices_interface
            (invoice_id
            ,invoice_num
            ,invoice_amount
            ,invoice_currency_code
            ,description
            ,source
            ,vendor_id
            ,vendor_site_id
            ,accts_pay_code_combination_id
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,created_by
            ,creation_date
            ,org_id
            ,group_id
            ,gl_date
            ,terms_date
            ,invoice_date
            ,invoice_received_date
            ,terms_id
            ,legal_entity_id
            ,exchange_rate
            ,exchange_rate_type
            ,exchange_date
	    ,CALC_TAX_DURING_IMPORT_FLAG
	    ,ADD_TAX_TO_INV_AMT_FLAG)--For Bug 9068811
             VALUES
            (AP_INVOICES_INTERFACE_S.nextval
            ,NVL(l_invoice_num
                ,'PN-'||PN_PAYMENT_ITEMS_NUM_S.nextval)
            ,ROUND(l_header_amount,l_precision)
            ,exp_ap_cache(l_start).pn_export_currency_code
            ,'Lease Number: ' || exp_ap_cache(l_start).pn_lease_num
            ,'Oracle Property Manager'
            ,exp_ap_cache(l_start).pn_vendor_id
            ,exp_ap_cache(l_start).pn_vendor_site_id
            ,exp_ap_cache(l_start).pn_lia_account
            ,l_last_updated_by
            ,l_last_update_date
            ,l_last_update_login
            ,l_created_by
            ,l_creation_date
            ,exp_ap_cache(l_start).org_id
            ,p_group_id
            ,exp_ap_cache(l_start).gl_date     -- gl_date
            ,exp_ap_cache(l_start).pn_due_date -- terms date
            ,exp_ap_cache(l_start).pn_due_date -- invoice date
            ,exp_ap_cache(l_start).pn_due_date -- invoice received date
            ,exp_ap_cache(l_start).pn_ap_ar_term_id
            ,exp_ap_cache(l_start).pn_legal_entity_id
            ,exp_ap_cache(l_start).conv_rate
            ,exp_ap_cache(l_start).conv_rate_type
            ,exp_ap_cache(l_start).pn_accounted_date
	    ,'Y'
	    ,'Y')--For Bug 9068811
            RETURNING invoice_id, invoice_num INTO l_invoice_id, l_invoice_num;

            IF inserted_inv_t.LAST IS NULL THEN
               l_temp_count := 1;
            ELSE
               l_temp_count := inserted_inv_t.LAST + 1;
            END IF;

            inserted_inv_t(l_temp_count).invoice_id := l_invoice_id;
            inserted_inv_t(l_temp_count).invoice_num := l_invoice_num;
            inserted_inv_t(l_temp_count).items_proc := l_next - l_start;

            fnd_message.set_name('PN','PN_EXPAP_HEAD_PARAM');
            fnd_message.set_token('INV_ID',l_invoice_id);
            fnd_message.set_token('INV_NUM',l_invoice_num);
            fnd_message.set_token('AMT',l_header_amount);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            PNP_DEBUG_PKG.put_log_msg(' ');
            -- now for the distributions

            FOR item IN l_start .. l_next-1 LOOP

               l_total_exp_amt := 0;
               l_total_exp_percent := 0;

               IF exp_ap_cache(item).pn_distribution_set_id IS NULL
                  AND exp_ap_cache(item).pn_project_id IS NULL THEN
                  -- validate distributions
                  -- Initailize the tables
                  lia_acnt_tab.delete;
                  acc_acnt_tab.delete;
                  exp_acnt_tab.delete;

                  l_lia_cnt := 0;
                  l_acc_cnt := 0;
                  l_exp_cnt := 0;

                  FOR acnt_rec IN get_acnt_info(exp_ap_cache(item).pn_payment_term_id) LOOP
                     IF acnt_rec.account_class  = 'LIA' THEN
                        l_lia_cnt := l_lia_cnt + 1;
                        lia_acnt_tab(l_lia_cnt) := acnt_rec;

                     ELSIF acnt_rec.account_class  = 'EXP' THEN
                        l_exp_cnt := l_exp_cnt + 1;
                        exp_acnt_tab(l_exp_cnt) := acnt_rec;

                     ELSIF acnt_rec.account_class  = 'ACC' THEN
                        l_acc_cnt := l_acc_cnt + 1;
                        acc_acnt_tab(l_acc_cnt) := acnt_rec;

                     END IF;
                  END LOOP; -- for account in

                  -- In case of terms that are not normalized, we may not get the liability
                  -- and/or Accrual A/C

                  IF l_lia_cnt = 0 THEN
                     lia_acnt_tab(1) := NULL;
                  END IF;

                  IF l_acc_cnt = 0 THEN
                     acc_acnt_tab(1) := NULL;
                  END IF;

               ELSE -- distribution_set/project info exists

                  lia_acnt_tab(1) := null;
                  exp_acnt_tab(1) := null;
                  acc_acnt_tab(1) := null;

               END IF; -- if dist_set/project is null

               IF pn_r12_util_pkg.is_r12 THEN
                 IF exp_ap_cache(item).pn_tax_classification_code IS NOT NULL THEN
                  l_tax_code_override_flag := 'Y';
                 END IF;

                 exp_ap_cache(item).pn_tax_code_id := null;
                 exp_ap_cache(item).pn_tax_group_id := null;

               ELSE

                 -- alls well and we are ready to insert into the AP ITF
                 -- Get tax name for the expense account

                 --
                 FOR rec IN  get_tax_name(nvl(exp_ap_cache(item).pn_tax_code_id,
                                             exp_ap_cache(item).pn_tax_group_id)) LOOP
                    l_tax_name := rec.name;
                 END LOOP;

                 -- If Tax Code Id or Tax Group Id is not null then populate
                 -- tax_code_override_flag.

                 IF exp_ap_cache(item).pn_tax_code_id IS NOT NULL OR
                    exp_ap_cache(item).pn_tax_group_id IS NOT NULL THEN
                    l_tax_code_override_flag := 'Y';
                 END IF;

                 exp_ap_cache(item).pn_tax_classification_code := null;
               END IF;

               -- Create a line for accrual amount if the term is normalized

               IF (nvl(exp_ap_cache(item).pn_normalize,'N') = 'Y' AND
                   nvl(exp_ap_cache(item).pn_send_entries,'Y') = 'Y') THEN

                  FOR i IN 1..acc_acnt_tab.COUNT LOOP

                     l_lineNumber := l_lineNumber + 1;

                     l_context := 'Inserting into ap_invoice_lines_interface ...';

                     INSERT INTO ap_invoice_lines_interface
                     (invoice_id
                     ,invoice_line_id
                     ,line_type_lookup_code
                     ,amount
                     ,description
                     ,dist_code_combination_id
		     ,DEFAULT_DIST_CCID
                     ,last_updated_by
                     ,last_update_date
                     ,last_update_login
                     ,created_by
                     ,creation_date
                     ,line_number
                     ,org_id
                     ,amount_includes_tax_flag -- Tax Inclusive
                     ,distribution_set_id
                     ,project_id
                     ,task_id
                     ,expenditure_type
                     ,expenditure_item_date
                     ,expenditure_organization_id
                     ,tax_code_id
                     ,tax_code
                     ,tax_classification_code
                     ,tax_code_override_flag)
                     VALUES
                     (l_invoice_id
                     ,AP_INVOICE_LINES_INTERFACE_S.nextval
                     ,'ITEM'
                     ,ROUND(((exp_ap_cache(item).pn_export_currency_amount)
                             * nvl(acc_acnt_tab(i).percentage,100)/100), l_precision)
                     ,'Lease Number: ' || exp_ap_cache(item).pn_lease_num
                     ,acc_acnt_tab(i).account_id
                     ,acc_acnt_tab(i).account_id
                     ,l_last_updated_by
                     ,l_last_update_date
                     ,l_last_update_login
                     ,l_created_by
                     ,l_creation_date
                     ,l_lineNumber
                     ,exp_ap_cache(item).org_id
                     ,exp_ap_cache(item).pn_tax_included
                     ,exp_ap_cache(item).pn_distribution_set_id
                     ,exp_ap_cache(item).pn_project_id
                     ,exp_ap_cache(item).pn_task_id
                     ,exp_ap_cache(item).pn_expenditure_type
                     ,exp_ap_cache(item).pn_expenditure_item_date
                     ,exp_ap_cache(item).pn_organization_id
                     ,nvl(exp_ap_cache(item).pn_tax_code_id,
                          exp_ap_cache(item).pn_tax_group_id)
                     ,l_tax_name
                     ,exp_ap_cache(item).pn_tax_classification_code
                     ,l_tax_code_override_flag)
                     RETURNING invoice_line_id, amount INTO l_invoice_line_id, l_line_amount;

                     fnd_message.set_name('PN','PN_EXPAP_LINE_PARAM');
                     fnd_message.set_token('INV_ID',l_invoice_id);
                     fnd_message.set_token('NUM',l_invoice_num);
                     fnd_message.set_token('ID',l_invoice_line_id);
                     fnd_message.set_token('AMT',l_line_amount);
                     fnd_message.set_token('PAY_ID',exp_ap_cache(item).pn_payment_item_id);
                     pnp_debug_pkg.put_log_msg(fnd_message.get);

                  END LOOP; -- for accrual_tab

               END IF; -- accrual entered if normalized

               -- Create a line for expense A/C

               IF ((nvl(exp_ap_cache(item).pn_normalize,'N') <> 'Y') OR
                   ((exp_ap_cache(item).pn_normalize = 'Y') AND
                     nvl(exp_ap_cache(item).pn_send_entries,'Y') = 'N')) THEN

                  l_exp_amt := round(exp_ap_cache(item).pn_export_currency_amount,l_precision);

                  FOR i IN 1..exp_acnt_tab.COUNT LOOP

                     l_lineNumber := l_lineNumber + 1;
                     l_context := 'Inserting into ap_invoice_lines_interface ...';

                     l_amt := ROUND((l_exp_amt * nvl(exp_acnt_tab(i).percentage,100)/100),l_precision);
                     l_total_exp_amt := l_total_exp_amt + l_amt;
                     l_total_exp_percent := l_total_exp_percent + nvl(exp_acnt_tab(i).percentage,100);

                     IF l_total_exp_percent = 100 THEN
                        l_diff_amt := l_total_exp_amt - l_exp_amt;
                        l_amt := l_amt - l_diff_amt;
                     END IF;

                     INSERT INTO ap_invoice_lines_interface
                     ( invoice_id
                     ,invoice_line_id
                     ,line_type_lookup_code
                     ,amount
                     ,description
                     ,dist_code_combination_id
		     ,DEFAULT_DIST_CCID
                     ,last_updated_by
                     ,last_update_date
                     ,last_update_login
                     ,created_by
                     ,creation_date
                     ,line_number
                     ,org_id
                     ,amount_includes_tax_flag -- Tax Inclusive
                     ,distribution_set_id
                     ,project_id
                     ,task_id
                     ,expenditure_type
                     ,expenditure_item_date
                     ,expenditure_organization_id
                     ,tax_code_id
                     ,tax_code
                     ,tax_classification_code    /*--Bug 6392393--*/
                     ,tax_code_override_flag)
                     VALUES
                     (l_invoice_id
                     ,AP_INVOICE_LINES_INTERFACE_S.nextval
                     ,'ITEM'
                     ,l_amt
                     ,'Lease Number: ' || exp_ap_cache(item).pn_lease_num
                     ,exp_acnt_tab(i).account_id
                     ,exp_acnt_tab(i).account_id
                     ,l_last_updated_by
                     ,l_last_update_date
                     ,l_last_update_login
                     ,l_created_by
                     ,l_creation_date
                     ,l_lineNumber
                     ,exp_ap_cache(item).org_id
                     ,exp_ap_cache(item).pn_tax_included
                     ,exp_ap_cache(item).pn_distribution_set_id
                     ,exp_ap_cache(item).pn_project_id
                     ,exp_ap_cache(item).pn_task_id
                     ,exp_ap_cache(item).pn_expenditure_type
                     ,exp_ap_cache(item).pn_expenditure_item_date
                     ,exp_ap_cache(item).pn_organization_id
                     ,nvl(exp_ap_cache(item).pn_tax_code_id,
                          exp_ap_cache(item).pn_tax_group_id)
                     ,l_tax_name
                     ,exp_ap_cache(item).pn_tax_classification_code /*--Bug 6392393--*/
                     ,l_tax_code_override_flag)
                     RETURNING invoice_line_id, amount INTO l_invoice_line_id, l_line_amount;

                     fnd_message.set_name('PN','PN_EXPAP_LINE_PARAM');
                     fnd_message.set_token('INV_ID',l_invoice_id);
                     fnd_message.set_token('NUM',l_invoice_num);
                     fnd_message.set_token('ID',l_invoice_line_id);
                     fnd_message.set_token('AMT',l_line_amount);
                     fnd_message.set_token('PAY_ID',exp_ap_cache(item).pn_payment_item_id);
                     pnp_debug_pkg.put_log_msg(fnd_message.get);

                  END LOOP;

               END IF; -- expense a/c

               ---------------------------------------------------------------
               -- Set Transferred Flag to 'Y' for all payment items exported
               -- to AP
               ---------------------------------------------------------------
               UPDATE pn_payment_items_all
               SET    transferred_to_ap_flag = 'Y' ,
                      ap_invoice_num         = l_invoice_num,
                      last_updated_by        = l_last_updated_by,
                      last_update_login      = l_last_update_login,
                      last_update_date       = l_last_update_date ,
                      export_group_id        = p_group_id
               WHERE  payment_item_id        = exp_ap_cache(item).pn_payment_item_id;

               IF (SQL%NOTFOUND) then
                  fnd_message.set_name('PN', 'PN_TRANSFER_TO_AP_FLAG_NOT_SET');
                  errbuf  := fnd_message.get;
                  pnp_debug_pkg.put_log_msg(errbuf);
                  ROLLBACK;
                  retcode := 2;
                  RETURN;
               END IF;

               IF (exp_ap_cache(item).pn_payment_schedule_id
                   <> l_prior_payment_schedule_id) THEN

                  l_prior_payment_schedule_id := exp_ap_cache(item).pn_payment_schedule_id;

                  UPDATE pn_payment_schedules_all
                  SET    transferred_by_user_id = l_last_updated_by,
                         transfer_date          = l_last_update_date,
                         last_updated_by        = l_last_updated_by,
                         last_update_login      = l_last_update_login,
                         last_update_date       = l_last_update_date
                  WHERE  payment_schedule_id    = exp_ap_cache(item).pn_payment_schedule_id;

                  IF (SQL%NOTFOUND) then
                     fnd_message.set_name('PN', 'PN_TRANSFER_TO_AP_INFO_NOT_SET');
                     errbuf  := fnd_message.get;
                     pnp_debug_pkg.put_log_msg(errbuf);
                     ROLLBACK;
                     retcode := 2;
                     RETURN;
                  END IF;

               END IF;

            END LOOP; -- now for the distributions

         EXCEPTION
            WHEN BAD_INVOICE_NUM THEN
               retcode := 1;
               l_error_ctr := l_error_ctr + l_next - l_start;
               /* this is for the backport - remove after seed bug is fixed */
               l_msg_exists := FALSE;
               FOR i IN exists_msg LOOP
                  l_msg_exists := TRUE;
               END LOOP;
               IF l_msg_exists THEN
                  fnd_message.set_name('PN', 'PN_CANNOT_GRP_ON_INV');
                  fnd_message.set_token('INV_NUM',l_invoice_num);
                  pnp_debug_pkg.put_log_msg(fnd_message.get);
               ELSE
                  pnp_debug_pkg.put_log_msg
                  ('The system is unable to group and process items with invoice number '||
                   l_invoice_num||
                   ' because some mandatory attributes do not match.');
               END IF;

            WHEN FATAL_ERROR THEN
               RAISE;

            WHEN OTHERS THEN
               errbuf := SQLERRM;
               pnp_debug_pkg.put_log_msg(errbuf);
               ROLLBACK;
               RAISE;

         END;

         /* get our counters right now
            else we will loop for eternity */
         l_item_prcsed := l_next - 1;
         l_start := l_next;
         l_next  := l_next + 1;
      END IF;
   END LOOP;

PNP_DEBUG_PKG.log('pn_exp_to_ap.group_and_export_items (-)');

EXCEPTION
   WHEN FATAL_ERROR THEN
      RAISE;
   WHEN others THEN
      RAISE;

END group_and_export_items;

--------------------------------------------------------------------------------
--  NAME         : export_items_nogrp
--  DESCRIPTION  : Creates entries in AP Interface for Invoice and Invoice Lines
--                 This procedure is the default functionality when Grouping
--                 Rule is not defined at any level.
--  PURPOSE      : Export items to AP without grouping.
--  INVOKED FROM : exp_to_ap
--  ARGUMENTS    : errbuf    - Error Buffer
--                 retcode   - Rerurn Code, indicates if the CP should end in
--                             success or failure.
--                 p_group_id - Export Group ID
--                 p_param_where_clause  - Where clause from SYSTEM.last_query
--                                         from the Export to AP form.
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  19-DEC-03  Kiran      o Created
--------------------------------------------------------------------------------
PROCEDURE export_items_nogrp(errbuf    IN OUT NOCOPY     VARCHAR2,
                             retcode   IN OUT NOCOPY     NUMBER,
                             p_group_id                  VARCHAR2,
                             p_param_where_clause        VARCHAR2) IS

   l_lineNumber                NUMBER :=  0;
   l_prior_payment_schedule_id NUMBER := -999;
   l_header_amount             NUMBER;
   l_line_amount               NUMBER;

BEGIN
   PNP_DEBUG_PKG.log('pn_exp_to_ap.export_items_nogrp (+)');

   /* we already have the required items in the cache */

   l_context := 'Exporting to AP with default functionality';

   pnp_debug_pkg.log(' Exporting to AP with default functionality exp_ap_cache.COUNT:'||exp_ap_cache.COUNT);

   FOR item IN 1..exp_ap_cache.COUNT LOOP

      l_total_exp_amt := 0;
      l_total_exp_percent := 0;

      IF exp_ap_cache(item).pn_distribution_set_id IS NULL AND
         exp_ap_cache(item).pn_project_id IS NULL THEN
      -- validate distributions
      -- Initailize the tables
         lia_acnt_tab.delete;
         acc_acnt_tab.delete;
         exp_acnt_tab.delete;

         l_lia_cnt := 0;
         l_acc_cnt := 0;
         l_exp_cnt := 0;

         FOR acnt_rec IN get_acnt_info(exp_ap_cache(item).pn_payment_term_id) LOOP
            IF acnt_rec.account_class  = 'LIA' THEN
               l_lia_cnt := l_lia_cnt + 1;
               lia_acnt_tab(l_lia_cnt) := acnt_rec;

            ELSIF acnt_rec.account_class  = 'EXP' THEN
               l_exp_cnt := l_exp_cnt + 1;
               exp_acnt_tab(l_exp_cnt) := acnt_rec;

            ELSIF acnt_rec.account_class  = 'ACC' THEN
               l_acc_cnt := l_acc_cnt + 1;
               acc_acnt_tab(l_acc_cnt) := acnt_rec;

            END IF;
         END LOOP; -- for account in

         /* In case of terms that are not normalized, we may not get the liability
            and/or Accrual A/C */

         IF l_lia_cnt = 0 THEN
            lia_acnt_tab(1) := NULL;
         END IF;

         IF l_acc_cnt = 0 THEN
            acc_acnt_tab(1) := NULL;
         END IF;

      ELSE -- distribution_set/project info exists

         lia_acnt_tab(1) := null;
         exp_acnt_tab(1) := null;
         acc_acnt_tab(1) := null;

      END IF; -- if dist_set/project is null

      IF pn_r12_util_pkg.is_r12 THEN
        IF exp_ap_cache(item).pn_tax_classification_code IS NOT NULL THEN
           l_tax_code_override_flag := 'Y';
        END IF;
        exp_ap_cache(item).pn_tax_code_id := null;
        exp_ap_cache(item).pn_tax_group_id := null;

      ELSE

        /* alls well and we are ready to insert into the AP ITF
           Get tax name for the expense account */

        OPEN get_tax_name(nvl(exp_ap_cache(item).pn_tax_code_id,
                          exp_ap_cache(item).pn_tax_group_id));
        FETCH get_tax_name INTO l_tax_name;
        IF get_tax_name%NOTFOUND then
           l_tax_name := null;
        END IF;
        CLOSE get_tax_name;

        /* If Tax Code Id or Tax Group Id is not null then populate
           tax_code_override_flag. */

        IF exp_ap_cache(item).pn_tax_code_id IS NOT NULL OR
           exp_ap_cache(item).pn_tax_group_id IS NOT NULL THEN
           l_tax_code_override_flag := 'Y';
        END IF;

      END IF;

      /* Create the header */

      l_lineNumber := 0;

      l_context := 'Inserting into ap_invoices_interface ...';

      pnp_debug_pkg.log(' Inserting into ap_invoices_interface ...');

      fnd_currency.get_info(exp_ap_cache(item).pn_export_currency_code,
                            l_precision,
                            l_ext_precision,
                            l_min_acct_unit);

      INSERT INTO ap_invoices_interface
      (invoice_id
      ,invoice_num
      ,invoice_amount
      ,invoice_currency_code
      ,description
      ,source
      ,vendor_id
      ,vendor_site_id
      ,accts_pay_code_combination_id
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,created_by
      ,creation_date
      ,ORG_ID
      ,GROUP_ID
      ,gl_date
      ,terms_date
      ,invoice_date
      ,invoice_received_date
      ,terms_id
      ,legal_entity_id
      ,exchange_rate
      ,exchange_rate_type
      ,exchange_date
      ,CALC_TAX_DURING_IMPORT_FLAG
      ,ADD_TAX_TO_INV_AMT_FLAG)--For Bug 9068811
      VALUES
      (AP_INVOICES_INTERFACE_S.nextval
      ,'PN-'||PN_PAYMENT_ITEMS_NUM_S.nextval
      ,ROUND(exp_ap_cache(item).pn_export_currency_amount,l_precision)
      ,exp_ap_cache(item).pn_export_currency_code
      ,'Lease Number: ' || exp_ap_cache(item).pn_lease_num
      ,'Oracle Property Manager'
      ,exp_ap_cache(item).pn_vendor_id
      ,exp_ap_cache(item).pn_vendor_site_id
      ,lia_acnt_tab(1).account_id
      ,l_last_updated_by
      ,l_last_update_date
      ,l_last_update_login
      ,l_created_by
      ,l_creation_date
      ,exp_ap_cache(item).org_id
      ,p_group_id
      ,exp_ap_cache(item).gl_date     -- gl_date
      ,exp_ap_cache(item).pn_due_date -- terms date
      ,exp_ap_cache(item).pn_due_date -- invoice date
      ,exp_ap_cache(item).pn_due_date -- invoice received date
      ,exp_ap_cache(item).pn_ap_ar_term_id
      ,exp_ap_cache(item).pn_legal_entity_id
      ,exp_ap_cache(item).conv_rate
      ,exp_ap_cache(item).conv_rate_type
      ,exp_ap_cache(item).pn_accounted_date
      ,'Y'
      ,'Y')--For Bug 9068811
      RETURNING invoice_id, invoice_num, invoice_amount
      INTO l_invoice_id, l_invoice_num, l_header_amount;

      fnd_message.set_name('PN','PN_EXPAP_HEAD_PARAM');
      fnd_message.set_token('INV_ID',l_invoice_id);
      fnd_message.set_token('INV_NUM',l_invoice_num);
      fnd_message.set_token('AMT',l_header_amount);
      pnp_debug_pkg.put_log_msg(fnd_message.get);

      PNP_DEBUG_PKG.put_log_msg(' ');
      /* Create a line for accrual amount if the term is normalized */

      IF (nvl(exp_ap_cache(item).pn_normalize,'N') = 'Y' AND
          nvl(exp_ap_cache(item).pn_send_entries,'Y') = 'Y') THEN

         FOR i IN 1..acc_acnt_tab.COUNT LOOP

            l_lineNumber := l_lineNumber + 1;

            l_context := 'Inserting into ap_invoice_lines_interface ...';

            INSERT INTO ap_invoice_lines_interface
            (invoice_id
            ,invoice_line_id
            ,line_type_lookup_code
            ,amount
            ,description
            ,dist_code_combination_id
	    ,DEFAULT_DIST_CCID
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,created_by
            ,creation_date
            ,line_number
            ,org_id
            ,amount_includes_tax_flag -- Tax Inclusive
            ,distribution_set_id
            ,project_id
            ,task_id
            ,expenditure_type
            ,expenditure_item_date
            ,expenditure_organization_id
            ,tax_code_id
            ,tax_code
            ,tax_classification_code
            ,tax_code_override_flag)
            values
            (l_invoice_id
            ,AP_INVOICE_LINES_INTERFACE_S.nextval
            ,'ITEM'
            ,ROUND(((exp_ap_cache(item).pn_export_currency_amount)
                    * nvl(acc_acnt_tab(i).percentage,100)/100), l_precision)
            ,'Lease Number: ' || exp_ap_cache(item).pn_lease_num
            ,acc_acnt_tab(i).account_id
            ,acc_acnt_tab(i).account_id
            ,l_last_updated_by
            ,l_last_update_date
            ,l_last_update_login
            ,l_created_by
            ,l_creation_date
            ,l_lineNumber
            ,exp_ap_cache(item).org_id
            ,exp_ap_cache(item).pn_tax_included
            ,exp_ap_cache(item).pn_distribution_set_id
            ,exp_ap_cache(item).pn_project_id
            ,exp_ap_cache(item).pn_task_id
            ,exp_ap_cache(item).pn_expenditure_type
            ,exp_ap_cache(item).pn_expenditure_item_date
            ,exp_ap_cache(item).pn_organization_id
            ,nvl(exp_ap_cache(item).pn_tax_code_id,
                 exp_ap_cache(item).pn_tax_group_id)
            ,l_tax_name
            ,exp_ap_cache(item).pn_tax_classification_code
            ,l_tax_code_override_flag)
            RETURNING invoice_line_id, amount
            INTO l_invoice_line_id, l_line_amount;

            fnd_message.set_name('PN','PN_EXPAP_LINE_PARAM');
            fnd_message.set_token('INV_ID',l_invoice_id);
            fnd_message.set_token('NUM',l_invoice_num);
            fnd_message.set_token('ID',l_invoice_line_id);
            fnd_message.set_token('AMT',l_line_amount);
            fnd_message.set_token('PAY_ID',exp_ap_cache(item).pn_payment_item_id);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

         END LOOP; -- for accrual_tab
      END IF; -- accrual entered if normalized

      -- Create a line for expense A/C

      IF ((nvl(exp_ap_cache(item).pn_normalize,'N') <> 'Y') OR
          ((exp_ap_cache(item).pn_normalize = 'Y') AND
           nvl(exp_ap_cache(item).pn_send_entries,'Y') = 'N')) THEN

         l_exp_amt := round(exp_ap_cache(item).pn_export_currency_amount,l_precision);

         FOR i IN 1..exp_acnt_tab.COUNT LOOP

            l_lineNumber := l_lineNumber + 1;
            l_context := 'Inserting into ap_invoice_lines_interface ...';

            l_amt := ROUND((l_exp_amt * nvl(exp_acnt_tab(i).percentage,100)/100),l_precision);
            l_total_exp_amt := l_total_exp_amt + l_amt;
            l_total_exp_percent := l_total_exp_percent + nvl(exp_acnt_tab(i).percentage,100);

            IF l_total_exp_percent = 100 THEN
               l_diff_amt := l_total_exp_amt - l_exp_amt;
               l_amt := l_amt - l_diff_amt;
            END IF;

            INSERT INTO ap_invoice_lines_interface
            (invoice_id
            ,invoice_line_id
            ,line_type_lookup_code
            ,amount
            ,description
            ,dist_code_combination_id
	    ,DEFAULT_DIST_CCID
            ,last_updated_by
            ,last_update_date
            ,last_update_login
            ,created_by
            ,creation_date
            ,line_number
            ,org_id
            ,amount_includes_tax_flag -- Tax Inclusive
            ,distribution_set_id
            ,project_id
            ,task_id
            ,expenditure_type
            ,expenditure_item_date
            ,expenditure_organization_id
            ,tax_code_id
            ,tax_code
            ,tax_classification_code
            ,tax_code_override_flag)
            VALUES
            (l_invoice_id
            ,AP_INVOICE_LINES_INTERFACE_S.nextval
            ,'ITEM'
            ,l_amt
            ,'Lease Number: ' || exp_ap_cache(item).pn_lease_num
            ,exp_acnt_tab(i).account_id
            ,exp_acnt_tab(i).account_id
            ,l_last_updated_by
            ,l_last_update_date
            ,l_last_update_login
            ,l_created_by
            ,l_creation_date
            ,l_lineNumber
            ,exp_ap_cache(item).org_id
            ,exp_ap_cache(item).pn_tax_included
            ,exp_ap_cache(item).pn_distribution_set_id
            ,exp_ap_cache(item).pn_project_id
            ,exp_ap_cache(item).pn_task_id
            ,exp_ap_cache(item).pn_expenditure_type
            ,exp_ap_cache(item).pn_expenditure_item_date
            ,exp_ap_cache(item).pn_organization_id
            ,nvl(exp_ap_cache(item).pn_tax_code_id,
                 exp_ap_cache(item).pn_tax_group_id)
            ,l_tax_name
            ,exp_ap_cache(item).pn_tax_classification_code
            ,l_tax_code_override_flag)
            RETURNING invoice_line_id, amount
            INTO l_invoice_line_id, l_line_amount;

            fnd_message.set_name('PN','PN_EXPAP_LINE_PARAM');
            fnd_message.set_token('INV_ID',l_invoice_id);
            fnd_message.set_token('NUM',l_invoice_num);
            fnd_message.set_token('ID',l_invoice_line_id);
            fnd_message.set_token('AMT',l_line_amount);
            fnd_message.set_token('PAY_ID',exp_ap_cache(item).pn_payment_item_id);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

         END LOOP;
      END IF; -- expense a/c

      ---------------------------------------------------------------
      -- Set Transferred Flag to 'Y' for all payment items exported
      -- to AP
      ---------------------------------------------------------------
      UPDATE pn_payment_items_all
      SET    transferred_to_ap_flag = 'Y' ,
             ap_invoice_num         = l_invoice_num,
             last_updated_by        = l_last_updated_by,
             last_update_login      = l_last_update_login,
             last_update_date       = l_last_update_date ,
             export_group_id        = p_group_id
      WHERE  payment_item_id        = exp_ap_cache(item).pn_payment_item_id;

      IF (SQL%NOTFOUND) then
         fnd_message.set_name('PN', 'PN_TRANSFER_TO_AP_FLAG_NOT_SET');
         errbuf  := fnd_message.get;
         rollback;
         retcode := 2;
         RETURN;
      END IF;

      IF (exp_ap_cache(item).pn_payment_schedule_id
          <> l_prior_payment_schedule_id ) THEN

         l_prior_payment_schedule_id := exp_ap_cache(item).pn_payment_schedule_id;

         UPDATE pn_payment_schedules_all
         SET    transferred_by_user_id = l_last_updated_by,
                transfer_date          = l_last_update_date,
                last_updated_by        = l_last_updated_by,
                last_update_login      = l_last_update_login,
                last_update_date       = l_last_update_date
         WHERE  payment_schedule_id    = exp_ap_cache(item).pn_payment_schedule_id;

         IF (SQL%NOTFOUND) then
            fnd_message.set_name('PN', 'PN_TRANSFER_TO_AP_INFO_NOT_SET');
            errbuf  := fnd_message.get;
            rollback;
            retcode := 2;
            return;
         END IF;

      END IF;
   END LOOP; -- for item in

PNP_DEBUG_PKG.log('pn_exp_to_ap.export_items_nogrp (-)');
EXCEPTION
   WHEN others THEN
      RAISE;

END export_items_nogrp;

--------------------------------------------------------------------------------
--  NAME         : exp_to_ap
--  DESCRIPTION  : Called from concurrent request
--
--                 For levels where grouping rule can be attached Loop
--                   For distinct Grouping Rules in a Level Loop
--                     o Populate the global Group By FLAGS
--                     o Create the Order By clause based on the Group By FLAGS
--                       and the Level
--                     o Cache the valid items to export
--                     o Group the items and export to AP
--                   End Loop for distinct Grouping Rules
--                 End Loop for levels
--
--                 If no Grouping Rules are defined at any level, use the
--                 Default functionality.
--
--  PURPOSE      : Groups invoices and transferrs to AP
--  INVOKED FROM : Concurrent request
--  ARGUMENTS    : errbuf, retcode, p_lease_num_low, p_lease_num_high,
--                 p_sch_dt_low, p_sch_dt_high, p_due_dt_low, p_due_dt_high,
--                 p_pay_prps_code, p_prd_name, p_amt_low, p_amt_high,
--                 p_vendor_id, p_inv_num.
--  REFERENCE    : PN_COMMON.debug()
--  HISTORY      :
--
--  19-DEC-03  Kiran          o Re written
--  12-FEB-04  Mrinal Misra   o Added parameters to exp_to_ap procedure and
--                              code to create l_param_where_clause.
--  17-FEB-04  Mrinal Misra   o Added p_grp_param as parameter to exp_to_ap
--                              procedure.
--  18-FEB-04  Kiran Hegde    o Added call to get_order_by_grpby in case of
--                              the grouping rule attached at SYSOP level
--  26-OCT-05  Hareesha       o ATG mandated changes for SQL literals using
--                              dbms_sql.
--  24-JUL-06  Hareesha       o Bug# 5398654 Consider the lease-no ,sched dt,
--                              due dt,amt due ranges while exporting.
--------------------------------------------------------------------------------
PROCEDURE exp_to_ap(errbuf    OUT NOCOPY VARCHAR2,
                    retcode   OUT NOCOPY NUMBER,
                    p_lease_num_low      VARCHAR2,
                    p_lease_num_high     VARCHAR2,
                    p_sch_dt_low         VARCHAR2,
                    p_sch_dt_high        VARCHAR2,
                    p_due_dt_low         VARCHAR2,
                    p_due_dt_high        VARCHAR2,
                    p_pay_prps_code      VARCHAR2,
                    p_prd_name           VARCHAR2,
                    p_amt_low            NUMBER,
                    p_amt_high           NUMBER,
                    p_vendor_id          NUMBER,
                    p_inv_num            VARCHAR2,
                    p_grp_param          VARCHAR2)
IS

   CURSOR get_grp_rule_item IS
      SELECT pi.grouping_rule_id
      FROM   pn_payment_items pi,
             pn_payment_terms_all pt,
             pn_leases_all le
      WHERE pi.payment_term_id               = pt.payment_term_id
      AND   pt.lease_id                      = le.lease_id
      AND   nvl(pi.export_to_ap_flag,'N')    = 'Y'
      AND   pi.payment_item_type_lookup_code ='CASH'
      AND   le.parent_lease_id               is NULL
      AND   pi.transferred_to_ap_flag        is NULL
      AND   pi.vendor_id                     is NOT NULL
      AND   pi.export_currency_amount        <> 0
      AND   pi.grouping_rule_id              IS NOT NULL
      GROUP BY pi.grouping_rule_id;

   CURSOR get_grp_rule_term IS
      SELECT pt.grouping_rule_id
      FROM   pn_payment_items pi,
             pn_payment_terms_all pt,
             pn_leases_all le
      WHERE pi.payment_term_id               = pt.payment_term_id
      AND   pt.lease_id                      = le.lease_id
      AND   nvl(pi.export_to_ap_flag,'N')    = 'Y'
      AND   pi.payment_item_type_lookup_code = 'CASH'
      AND   le.parent_lease_id               is NULL
      AND   pi.transferred_to_ap_flag        is NULL
      AND   pi.vendor_id                     is NOT NULL
      AND   pi.export_currency_amount        <> 0
      AND   pi.grouping_rule_id              IS NULL
      AND   pt.grouping_rule_id              IS NOT NULL
      GROUP BY pt.grouping_rule_id;

   CURSOR get_grp_rule_lease IS
      SELECT pld.grouping_rule_id
      FROM   pn_payment_items pi,
             pn_payment_terms_all pt,
             pn_leases_all le,
             pn_lease_details_all pld
      WHERE pi.payment_term_id               = pt.payment_term_id
      AND   pt.lease_id                      = le.lease_id
      AND   pld.lease_id                     = le.lease_id
      AND   nvl(pi.export_to_ap_flag,'N')    = 'Y'
      AND   pi.payment_item_type_lookup_code ='CASH'
      AND   le.parent_lease_id               is NULL
      AND   pi.transferred_to_ap_flag        is NULL
      AND   pi.vendor_id                     is NOT NULL
      AND   pi.export_currency_amount        <> 0
      AND   pi.grouping_rule_id              IS NULL
      AND   pt.grouping_rule_id              IS NULL
      AND   pld.grouping_rule_id             IS NOT NULL
      GROUP BY pld.grouping_rule_id;

   -- counters

   l_processing_level_ctr NUMBER := 0;
   l_lease_num_where_clause   VARCHAR2(4000);
   l_sch_date_where_clause    VARCHAR2(4000);
   l_due_date_where_clause    VARCHAR2(4000);
   l_pay_prps_where_clause    VARCHAR2(4000);
   l_prd_name_where_clause    VARCHAR2(4000);
   l_amt_where_clause         VARCHAR2(4000);
   l_vendor_where_clause      VARCHAR2(4000);
   l_inv_num_where_clause     VARCHAR2(4000);
   l_param_where_clause       VARCHAR2(4000);
   l_group_id                 VARCHAR2(10);
   l_set_of_books_id          NUMBER;

BEGIN

   PNP_DEBUG_PKG.log('pn_exp_to_ap.exp_to_ap (+)');

   l_context := 'Getting functional currency code';

   l_set_of_books_id :=
                  TO_NUMBER(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                                pn_mo_cache_utils.get_current_org_id));

   FOR rec IN get_func_curr_code(l_set_of_books_id) LOOP
      l_func_curr_code := rec.currency_code;
   END LOOP;

   IF p_grp_param IS NULL THEN

      SELECT  TO_CHAR(pn_payments_group_s.NEXTVAL)
      INTO    l_group_id
      FROM    dual;

      IF p_lease_num_low IS NOT NULL AND
         p_lease_num_high IS NOT NULL THEN

         l_lease_num_where_clause := ' AND le.lease_num  BETWEEN :l_lease_num_low AND :l_lease_num_high ';

      ELSIF p_lease_num_low IS NULL AND
         p_lease_num_high IS NOT NULL THEN

         l_lease_num_where_clause := ' AND le.lease_num <= :l_lease_num_high ';

      ELSIF p_lease_num_low IS NOT NULL AND
         p_lease_num_high IS NULL THEN

         l_lease_num_where_clause := ' AND le.lease_num >= :l_lease_num_low ';

      ELSE l_lease_num_where_clause := ' AND 2=2 ';
      END IF;

      IF p_sch_dt_low IS NOT NULL AND
         p_sch_dt_high IS NOT NULL THEN

         l_sch_date_where_clause := ' AND ps.schedule_date BETWEEN :l_sch_dt_low AND :l_sch_dt_high ';

      ELSIF p_sch_dt_low IS NULL AND
         p_sch_dt_high IS NOT NULL THEN

         l_sch_date_where_clause := ' AND ps.schedule_date <= :l_sch_dt_high ';

      ELSIF p_sch_dt_low IS NOT NULL AND
         p_sch_dt_high IS NULL THEN

         l_sch_date_where_clause := ' AND ps.schedule_date >= :l_sch_dt_low ';

      ELSE  l_sch_date_where_clause := ' AND 3=3 ';
      END IF;

      IF p_due_dt_low IS NOT NULL AND
         p_due_dt_high IS NOT NULL THEN

         l_due_date_where_clause := ' AND pi.due_date BETWEEN :l_due_dt_low AND :l_due_dt_high ';

      ELSIF p_due_dt_low IS NULL AND
         p_due_dt_high IS NOT NULL THEN

         l_due_date_where_clause := ' AND pi.due_date <= :l_due_dt_high ';

      ELSIF p_due_dt_low IS NOT NULL AND
         p_due_dt_high IS NULL THEN

         l_due_date_where_clause := ' AND pi.due_date >= :l_due_dt_low ';

      ELSE  l_due_date_where_clause := ' AND 3=3 ';
      END IF;

      IF p_pay_prps_code IS NOT NULL THEN

         l_pay_prps_where_clause := ' AND pt.payment_purpose_code =  :l_pay_prps_code ';

      ELSE l_pay_prps_where_clause := ' AND 4=4 ';
      END IF;

      IF p_prd_name IS NOT NULL THEN

         l_prd_name_where_clause := ' AND ps.period_name = :l_prd_name ';

      ELSE l_prd_name_where_clause := ' AND 5=5';
      END IF;

      IF p_amt_low IS NOT NULL AND
         p_amt_high IS NOT NULL THEN

        l_amt_where_clause := ' AND pi.actual_amount BETWEEN  :l_amt_low AND :l_amt_high ';

      ELSIF p_amt_low IS NULL AND
         p_amt_high IS NOT NULL THEN

         l_amt_where_clause := ' AND pi.actual_amount <= :l_amt_high ';

      ELSIF p_amt_low IS NOT NULL AND
         p_amt_high IS NULL THEN

         l_amt_where_clause := ' AND pi.actual_amount >=  :l_amt_low ';

      ELSE l_amt_where_clause := ' AND 6=6 ';
      END IF;

      IF p_vendor_id IS NOT NULL THEN

         l_vendor_where_clause := ' AND pi.vendor_id =  :l_vendor_id ';

      ELSE l_vendor_where_clause := ' AND 7=7 ';
      END IF;

      IF p_inv_num IS NOT NULL THEN

         l_inv_num_where_clause := ' AND pi.ap_invoice_num = :l_inv_num ';

      ELSE l_inv_num_where_clause := ' AND 8=8 ';
      END IF;

      l_param_where_clause := l_lease_num_where_clause ||
                              l_sch_date_where_clause ||
                              l_due_date_where_clause ||
                              l_pay_prps_where_clause ||
                              l_prd_name_where_clause ||
                              l_amt_where_clause ||
                              l_vendor_where_clause ||
                              l_inv_num_where_clause;

   ELSE

      l_param_where_clause := ' AND pi.export_group_id = :l_grp_param ';

      l_group_id := p_grp_param;
   END IF;


   FOR l_processing_level_ctr IN 1..4 LOOP

      IF l_processing_level_ctr = 1 THEN
      -- item level
      l_context := 'Processing items with Grouping Rule at Item level (+)';
      PNP_DEBUG_PKG.log(l_context);

         FOR grp IN get_grp_rule_item LOOP
            -- get group rule id
            l_id := grp.grouping_rule_id;
            -- populate flags
            populate_group_by_flags(l_id);
            -- get the order by for group bys
            get_order_by_grpby;

            Q_Payitem := l_Select_Clause ||
                         l_param_where_clause ||
                         l_where_clause_item ||
                         l_order_by_clause_item ||
                         l_order_by_clause ||
                         l_order_by_clause_grpby ||
                         ' , lia_account';

            PNP_DEBUG_PKG.log(' Q_Payitem : '|| Q_Payitem );

            -- get items
            cache_exp_items (
                    p_lease_num_low ,
                    p_lease_num_high,
                    p_sch_dt_low    ,
                    p_sch_dt_high   ,
                    p_due_dt_low    ,
                    p_due_dt_high   ,
                    p_pay_prps_code ,
                    p_prd_name      ,
                    p_amt_low       ,
                    p_amt_high      ,
                    p_vendor_id     ,
                    p_inv_num       ,
                    p_grp_param     );



            -- export items
            group_and_export_items(errbuf,
                                   retcode,
                                   l_group_id,
                                   l_param_where_clause);
         END LOOP;

         l_context := 'Processing items with Grouping Rule at Item level (-)';
         PNP_DEBUG_PKG.log(l_context);

      ELSIF l_processing_level_ctr = 2 THEN
         -- term level
         l_context := 'Processing items with Grouping Rule at Term level (+)';
         PNP_DEBUG_PKG.log(l_context);

         FOR grp IN get_grp_rule_term LOOP
            -- get group rule id
            l_id := grp.grouping_rule_id;
            -- populate flags
            populate_group_by_flags(l_id);
            -- get the order by for group bys
            get_order_by_grpby;

            Q_Payitem := l_Select_Clause ||
                         l_param_where_clause ||
                         l_where_clause_term ||
                         l_order_by_clause_term ||
                         l_order_by_clause ||
                         l_order_by_clause_grpby||
                         ' , lia_account';

            PNP_DEBUG_PKG.log(' Q_Payitem : '|| Q_Payitem );

            cache_exp_items (
                    p_lease_num_low ,
                    p_lease_num_high,
                    p_sch_dt_low    ,
                    p_sch_dt_high   ,
                    p_due_dt_low    ,
                    p_due_dt_high   ,
                    p_pay_prps_code ,
                    p_prd_name      ,
                    p_amt_low       ,
                    p_amt_high      ,
                    p_vendor_id     ,
                    p_inv_num       ,
                    p_grp_param     );


            -- export items
            group_and_export_items(errbuf,
                                   retcode,
                                   l_group_id,
                                   l_param_where_clause);

         END LOOP;

         l_context := 'Processing items with Grouping Rule at Term level (-)';
         PNP_DEBUG_PKG.log(l_context);

      ELSIF l_processing_level_ctr = 3 THEN
         -- lease level
         l_context := 'Processing items with Grouping Rule at Lease level (+)';
         PNP_DEBUG_PKG.log(l_context);

         FOR grp IN get_grp_rule_lease LOOP
            -- get group rule id
            l_id := grp.grouping_rule_id;
            -- populate flags
            populate_group_by_flags(l_id);
            -- get the order by for group bys
            get_order_by_grpby;

            Q_Payitem := l_Select_Clause ||
                         l_param_where_clause ||
                         l_where_clause_lease ||
                         l_order_by_clause_lease ||
                         l_order_by_clause||
                         l_order_by_clause_grpby||
                         ' , lia_account';

            PNP_DEBUG_PKG.log(' Q_Payitem : '|| Q_Payitem );

            cache_exp_items (
                    p_lease_num_low ,
                    p_lease_num_high,
                    p_sch_dt_low    ,
                    p_sch_dt_high   ,
                    p_due_dt_low    ,
                    p_due_dt_high   ,
                    p_pay_prps_code ,
                    p_prd_name      ,
                    p_amt_low       ,
                    p_amt_high      ,
                    p_vendor_id     ,
                    p_inv_num       ,
                    p_grp_param     );


            -- export items
            group_and_export_items(errbuf,
                                   retcode,
                                   l_group_id,
                                   l_param_where_clause);

         END LOOP;

         l_context := 'Processing items with Grouping Rule at Lease level (-)';
         PNP_DEBUG_PKG.log(l_context);

      ELSIF l_processing_level_ctr = 4 THEN
         -- system option level
         l_context := 'Processing items with Grouping Rule at System Option level (+)';
         PNP_DEBUG_PKG.log(l_context);

         l_id := -1;

         FOR rec IN get_system_grouping_rule_id(pn_mo_cache_utils.get_current_org_id) LOOP
            l_system_grouping_rule_id := rec.grouping_rule_id;
         END LOOP;

         IF l_system_grouping_rule_id IS NULL THEN
            -- no grouping rule at system level
            l_context := 'Default functionality. No grouping rule exists';
            PNP_DEBUG_PKG.log(l_context);

            l_system_grouping_rule_id := -1;

            Q_Payitem := l_Select_Clause ||
                         l_param_where_clause ||
                         l_where_clause_sysop ||
                         l_order_by_clause_default;

            PNP_DEBUG_PKG.log(' Q_Payitem : '|| Q_Payitem );

            cache_exp_items (
                    p_lease_num_low ,
                    p_lease_num_high,
                    p_sch_dt_low    ,
                    p_sch_dt_high   ,
                    p_due_dt_low    ,
                    p_due_dt_high   ,
                    p_pay_prps_code ,
                    p_prd_name      ,
                    p_amt_low       ,
                    p_amt_high      ,
                    p_vendor_id     ,
                    p_inv_num       ,
                    p_grp_param     );

            -- use default functionlity here
            export_items_nogrp(errbuf,
                               retcode,
                               l_group_id,
                               l_param_where_clause);

         ELSE
            -- need to create order by clause sysop here
            populate_group_by_flags(l_system_grouping_rule_id);
            -- get the order by for group bys
            get_order_by_grpby;

            Q_Payitem := l_Select_Clause ||
                         l_param_where_clause ||
                         l_where_clause_sysop ||
                         ' ORDER BY ' ||
                         l_order_by_clause ||
                         l_order_by_clause_grpby||
                         ' , lia_account';

            PNP_DEBUG_PKG.log(' Q_Payitem : '|| Q_Payitem );

            cache_exp_items (
                    p_lease_num_low ,
                    p_lease_num_high,
                    p_sch_dt_low    ,
                    p_sch_dt_high   ,
                    p_due_dt_low    ,
                    p_due_dt_high   ,
                    p_pay_prps_code ,
                    p_prd_name      ,
                    p_amt_low       ,
                    p_amt_high      ,
                    p_vendor_id     ,
                    p_inv_num       ,
                    p_grp_param     );

            -- export items
            group_and_export_items(errbuf,
                                   retcode,
                                   l_group_id,
                                   l_param_where_clause);


        END IF; -- if NOTFOUND

        l_context := 'Processing items with Grouping Rule at System Option level (-)';
        PNP_DEBUG_PKG.log(l_context);

     END IF; -- if l_processing_level_ctr
  END LOOP; -- for l_processing_level_ctr

  COMMIT;

  pnp_debug_pkg.put_log_msg('
===========================================================================');
  fnd_message.set_name ('PN','PN_EXPAP_PAY_PROC_SUC');
  fnd_message.set_token ('NUM',(l_total_ctr - l_error_ctr));
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_EXPAP_PAY_PROC_FAIL');
  fnd_message.set_token ('NUM',l_error_ctr);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_EXPAP_PAY_PROC_TOT');
  fnd_message.set_token ('NUM',l_total_ctr);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  pnp_debug_pkg.put_log_msg('
===========================================================================');
PNP_DEBUG_PKG.log('pn_exp_to_ap.exp_to_ap (-)');

EXCEPTION
   WHEN FATAL_ERROR THEN
      /* we should never get here */
      pnp_debug_pkg.LOG(SUBSTR(l_context,1,244));
      errbuf :=
      'A system error occured. A most likely cause is some other process is updating'
      ||'the AP interface tables. Please run the export program again';
      pnp_debug_pkg.put_log_msg(errbuf);
      retcode := 2;
      ROLLBACK;

   WHEN OTHERS THEN
      -- fnd_message.set_name('PN', 'PN_TRANSFER_TO_AP_PROBLEM');
      pnp_debug_pkg.LOG(SUBSTR(l_context,1,244));
      errbuf  := SQLERRM;
      retcode := 2;
      ROLLBACK;
      RAISE;

END EXP_TO_AP;

END PN_EXP_TO_AP;

/
