--------------------------------------------------------
--  DDL for Package Body PN_EXP_TO_AR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_EXP_TO_AR" as
  -- $Header: PNTXBILB.pls 120.9.12010000.2 2008/09/04 12:26:56 mumohan ship $

/* All Cursor declarations go here */
   CURSOR get_dist(p_term_id NUMBER) IS
      SELECT account_id,
             account_class,
             percentage
      FROM   pn_distributions_all
      WHERE  payment_term_id = p_term_id;

   CURSOR get_desc (p_lookup_code varchar2) is
      SELECT meaning
      FROM   fnd_lookups
      WHERE  lookup_type = 'PN_PAYMENT_PURPOSE_TYPE'
      AND    lookup_code = p_lookup_code;

   CURSOR get_rule_name (p_rule_id number) is
      SELECT name,
             type,
             frequency
      FROM   ra_rules
      WHERE  rule_id = p_rule_id;

   CURSOR get_receipt_name (p_receipt_method_id number) is
      SELECT name
      FROM   ar_receipt_methods
      WHERE  receipt_method_id = p_receipt_method_id;

   CURSOR get_salesrep_number (p_salesrep_id number, p_org_id NUMBER) is
      SELECT SALESREP_NUMBER,SALES_CREDIT_TYPE_ID
      FROM   ra_salesreps
      WHERE  salesrep_id = p_salesrep_id
      AND    org_id = p_org_id;

   CURSOR get_cust_trx_name (p_cust_trx_type_id number) is
      SELECT name
      FROM   ra_cust_trx_types
      WHERE  cust_trx_type_id = p_cust_trx_type_id;

   CURSOR get_term_name (p_term_id number) is
      SELECT name
      FROM   ra_terms
      WHERE  term_id = p_term_id;

   CURSOR get_loc_code(p_location_id number) is
      SELECT pl.location_code
      FROM   pn_locations_all pl
      WHERE  pl.location_id = p_location_id;

   CURSOR get_batch_source_name is
      SELECT name,
             rev_acc_allocation_rule,
             allow_sales_credit_flag,
             derive_date_flag
      FROM   ra_batch_sources
      WHERE  batch_source_id = 24;

   CURSOR get_tax_code (p_tax_code_id number) is
      SELECT tax_code
      FROM   ar_vat_tax
      WHERE  vat_tax_id = p_tax_code_id;

   CURSOR acnt_cls_cur(p_term_id NUMBER) IS
      SELECT account_class
      FROM   pn_distributions_all
      WHERE  payment_term_id = p_term_id;

   CURSOR gl_segment_check IS
      SELECT 'Y'
      FROM   ra_account_defaults def,
             ra_account_default_segments seg
      WHERE  seg.table_name = 'RA_SALESREPS'
      AND    def.gl_default_id = seg.gl_default_id
      AND    def.type = 'REV';

   CURSOR sys_param_check IS
     SELECT 'Y'
     FROM   ar_system_parameters
     WHERE  salesrep_required_flag = 'Y';

   CURSOR get_func_curr_code(p_set_of_books_id IN NUMBER) IS
     SELECT currency_code
     FROM   gl_sets_of_books
     WHERE  set_of_books_id = p_set_of_books_id;

   CURSOR get_send_flag(p_lease_id NUMBER) IS
      SELECT nvl(send_entries,'Y')
      FROM   pn_lease_details_all
      WHERE  lease_id = p_lease_id;

   CURSOR get_opt_attr IS
      SELECT gb.COLUMN_ID
      FROM   RA_GROUP_BYS gb,
             RA_GROUPING_TRX_TYPES gt,
             RA_GROUPING_RULES gr,
             RA_BATCH_SOURCES bs
      WHERE  gb.GROUPING_TRX_TYPE_ID = gt.GROUPING_TRX_TYPE_ID
      AND    gt.GROUPING_RULE_ID     = gr.GROUPING_RULE_ID
      AND    gr.GROUPING_RULE_ID     = bs.GROUPING_RULE_ID
      AND    bs.BATCH_SOURCE_ID      = 24
      AND    NVL(bs.org_id,-99) = NVL(pn_mo_cache_utils.get_current_org_id,-99); --Bug#6319026

   CURSOR get_post_to_gl(p_trx_type_id NUMBER, p_org_id NUMBER) IS
      SELECT post_to_gl
      FROM   ra_cust_trx_types_all
      WHERE  cust_trx_type_id = p_trx_type_id
      AND    org_id = p_org_id;

   /* Global Flags */
   g_invalid_group_flag  BOOLEAN := FALSE;
   g_no_group_flag       BOOLEAN := FALSE;
   g_grp_by_purpose_flag BOOLEAN := FALSE;
   g_grp_by_type_flag    BOOLEAN := FALSE;
   g_grp_by_lenum_flag   BOOLEAN := FALSE;

   l_func_curr_code      GL_SETS_OF_BOOKS.currency_code%TYPE;
   Q_Billitem_grp        VARCHAR2(30000);
   Q_Billitem_nogrp      VARCHAR2(30000);
   l_ord_clause          VARCHAR(1000) :=
   ' order by
     TRUNC(pi.accounted_date),conv_rate,             conv_rate_type,
     pi.export_currency_code, pt.cust_trx_type_id,   gl_date,
     pt.inv_rule_id,          pt.salesrep_id,        pt.cust_po_number,
     pt.receipt_method_id,    pt.ap_ar_term_id,      pi.due_date,
     pi.customer_id,          hzc.cust_acct_site_id, hzc1.cust_acct_site_id,
     legal_entity_id';

   g_cursor_grp                          INTEGER;
   g_cursor_nogrp                        INTEGER;
   g_cursor_select_grp                   INTEGER;
   g_cursor_select_nogrp                 INTEGER;
   Q_select_grp                          VARCHAR2(32000);
   Q_select_nogrp                        VARCHAR2(32000);

   /* exceptions */
   GENERIC_EXPORT_EXCEPTION EXCEPTION;
--------------------------------------------------------------------------------
-- For setting PN's Invoice Info
-- ( Run as a Conc Process )
--   17-FEB-04  Satish  o Fixed for BUG# 2938185. Added 11 parameters
--                        for this procedure to be called from SRS screen.
--                        When invoced from SRS screen will will call with
--                        11 params. Form will call this with with only
--                        group_id after all items are updated with same
--                        export_group_id in the form.
--  29-APR-04   Anand   o Added another condition before calling proc
--                        PN_EXP_TO_AR.EXP_TO_AR_GRP. This condition is needed
--                        when grouping rule name has no optional attr attched.
--                        In this case, we need to group by ONLY mandatory attr
--                        Bug#3586774
--  28-OCT-05 sdmahesh  o ATG mandated changes for SQL literals
--  24-JUL-06 Hareesha  o Bug# 5398654 Consider the lease-no ,sched dt,
--                        due dt,amt due ranges while exporting.
--  07-AUG-06 Hareesha  o Bug #5405883 Modified Q_Billitem_grp and
--                        Q_Billitem_nogrp to select schedule_date.
--------------------------------------------------------------------------------
PROCEDURE Exp_To_AR (
                      errbuf               OUT NOCOPY        VARCHAR2
                     ,retcode              OUT NOCOPY        VARCHAR2
                     ,p_lease_num_low      VARCHAR2
                     ,p_lease_num_high     VARCHAR2
                     ,p_sch_dt_low         VARCHAR2
                     ,p_sch_dt_high        VARCHAR2
                     ,p_due_dt_low         VARCHAR2
                     ,p_due_dt_high        VARCHAR2
                     ,p_pay_prps_code      VARCHAR2
                     ,p_prd_name           VARCHAR2
                     ,p_amt_low            NUMBER
                     ,p_amt_high           NUMBER
                     ,p_customer_id        NUMBER
                     ,p_grp_param          VARCHAR2
                     )
IS

   INVALID_GROUP_RULE              EXCEPTION;
   err_msg                         VARCHAR2(2000);
   l_lease_num_where_clause        VARCHAR2(4000);
   l_sch_date_where_clause         VARCHAR2(4000);
   l_due_date_where_clause         VARCHAR2(4000);
   l_pay_prps_where_clause         VARCHAR2(4000);
   l_prd_name_where_clause         VARCHAR2(4000);
   l_amt_where_clause              VARCHAR2(4000);
   l_customer_where_clause         VARCHAR2(4000);
   l_param_where_clause            VARCHAR2(30000);
   l_groupId                       VARCHAR2(10);
   l_set_of_books_id               NUMBER := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                       pn_mo_cache_utils.get_current_org_id));


BEGIN
   pnp_debug_pkg.log('-------- PN_EXP_TO_AR.EXP_TO_AR --------- (+)');

   OPEN  get_func_curr_code(l_set_of_books_id);
   FETCH get_func_curr_code INTO l_func_curr_code;
   CLOSE get_func_curr_code;

   Q_Billitem_grp :=
             'SELECT  pi.payment_item_id,    pi.payment_term_id,
              pi.export_currency_code,      pi.export_currency_amount,
              pi.customer_id AS customer_id,   hzc.cust_acct_site_id,
              hzc1.cust_acct_site_id,       pt.tax_code_id,
              pt.tax_classification_code,   pt.legal_entity_id AS legal_entity_id,
              pt.inv_rule_id,               pt.account_rule_id,
              pt.ap_ar_term_id,             pt.cust_trx_type_id AS cust_trx_type_id,
              pt.receipt_method_id,         pt.cust_po_number,
              pt.tax_included,              pt.salesrep_id,
              pt.project_attribute_category,pt.project_attribute3,
              pt.project_attribute4,        pt.project_attribute5,
              pt.project_attribute6,        pt.project_attribute7,
              pi.org_id AS org_id,          le.lease_num,
              pi.payment_schedule_id,       ps.period_name,
              pt.payment_purpose_code,      le.lease_id,
              pi.due_date,                  pt.normalize,
              TRUNC(pi.accounted_date),     pi.rate,
              pt.location_id,               NVL(pld.send_entries, ''Y''),
              pd.account_id             as rec_account,
              TO_DATE(DECODE(pt.inv_rule_id||pt.account_rule_id||cust_trx.post_to_gl
                     ,''Y'', to_char(PNP_UTIL_FUNC.Get_Start_Date(ps.period_name,
                                                                  pn_mo_cache_utils.get_current_org_id)
                     , ''MM/DD/YYYY'')
                     ,NULL)
                     ,''MM/DD/YYYY'')   as gl_date,
              DECODE(UPPER('''||l_func_curr_code||''')
                    ,UPPER(pi.export_currency_code),1
                    ,DECODE(UPPER(PNP_UTIL_FUNC.check_conversion_type('''||l_func_curr_code||''',
                                                                      pn_mo_cache_utils.get_current_org_id))
                            ,''USER'',pi.rate
                            ,NULL))     as conv_rate,
              DECODE(UPPER('''||l_func_curr_code||''')
                    ,UPPER(pi.export_currency_code),''User''
                    ,PNP_UTIL_FUNC.check_conversion_type('''||l_func_curr_code||''',
                                                         pn_mo_cache_utils.get_current_org_id)
                     )                  as conv_rate_type,
              pt.payment_purpose_code   as payment_purpose,
              pt.payment_term_type_code as payment_type,
              TO_DATE(DECODE(rr.type||rr.frequency ,''ASPECIFIC'',NULL,
                             to_char(PNP_UTIL_FUNC.Get_Start_Date(ps.period_name,
                                                                  pn_mo_cache_utils.get_current_org_id)
                             , ''MM/DD/YYYY''))
                     ,''MM/DD/YYYY'') as rule_gl_date,
              ps.schedule_date as schedule_date
      FROM    PN_PAYMENT_ITEMS  pi,    PN_PAYMENT_SCHEDULES_ALL ps,
              PN_PAYMENT_TERMS_ALL  pt,    PN_LEASES_ALL le,
              PN_LEASE_DETAILS_ALL  pld,   HZ_CUST_SITE_USES_ALL hzc,
              HZ_CUST_SITE_USES_ALL hzc1,  HZ_PARTIES party,
              HZ_CUST_ACCOUNTS_ALL cust_acc,   FND_LOOKUPS type_lookup,
              FND_LOOKUPS purpose_lookup,  HR_OPERATING_UNITS ou,
              PN_DISTRIBUTIONS_ALL pd,         RA_CUST_TRX_TYPES_ALL cust_trx,
              RA_RULES rr
      WHERE   pi.payment_term_id                = pt.payment_term_id
      AND     pi.payment_schedule_id            = ps.payment_schedule_id
      AND     pi.export_to_ar_flag              = ''Y''
      AND     pi.payment_item_type_lookup_code  = ''CASH''
      AND     pt.lease_id                       = le.lease_id
      AND     pld.lease_id                      = le.lease_id
      AND     le.lease_class_code               <> ''DIRECT''
      AND     hzc.site_use_id                   = pi.customer_site_use_id
      AND     hzc1.site_use_id (+)              = pi.cust_ship_site_id
      AND     NVL(pi.transferred_to_ar_flag, ''N'') = ''N''
      AND     type_lookup.lookup_type           = ''PN_PAYMENT_TERM_TYPE''
      AND     type_lookup.lookup_code           = pt.payment_term_type_code
      AND     purpose_lookup.lookup_type        = ''PN_PAYMENT_PURPOSE_TYPE''
      AND     purpose_lookup.lookup_code        = pt.payment_purpose_code
      AND     party.party_id                    = cust_acc.party_id
      AND     cust_acc.cust_account_id          = pi.customer_id
      AND     ou.organization_id                = pi.org_id
      AND     pi.export_currency_amount         <> 0
      AND     pd.payment_term_id                = pt.payment_term_id
      AND     pd.account_class                  = ''REC''
      AND     pt.cust_trx_type_id               = cust_trx.cust_trx_type_id
      AND     NVL(cust_trx.org_id,-99)          = NVL(pt.org_id,NVL(cust_trx.org_id,-99))
      AND     rr.rule_id(+)                     = pt.account_rule_id
      ';
    Q_Billitem_nogrp :=
    '      SELECT  pi.payment_item_id,                       pi.payment_term_id,
              pi.export_currency_code,                  pi.export_currency_amount,
              pi.customer_id AS customer_id,            hzc.cust_acct_site_id,
              hzc1.cust_acct_site_id,                   pt.tax_code_id,
              pt.tax_classification_code,               pt.legal_entity_id AS legal_entity_id,
              pt.inv_rule_id,                           pt.account_rule_id,
              pt.ap_ar_term_id,                         pt.cust_trx_type_id AS cust_trx_type_id,
              pt.receipt_method_id,                     pt.cust_po_number,
              pt.tax_included,                          pt.salesrep_id,
              pt.project_attribute_category,            pt.project_attribute3,
              pt.project_attribute4,                    pt.project_attribute5,
              pt.project_attribute6,                    pt.project_attribute7,
              pi.org_id AS org_id,le.lease_num,         pi.payment_schedule_id,
              ps.period_name,                           pt.payment_purpose_code,
              le.lease_id,                              pi.due_date,
              pt.normalize,                             TRUNC(pi.accounted_date),pi.rate,
              PT.Location_id,
              pt.payment_purpose_code   as payment_purpose,
              pt.payment_term_type_code as payment_type,
              ps.schedule_date as schedule_date
      FROM    PN_PAYMENT_ITEMS  pi,                         PN_PAYMENT_SCHEDULES_ALL ps,
              PN_PAYMENT_TERMS_ALL  pt,                     PN_LEASES_ALL            le,
              HZ_CUST_SITE_USES_ALL hzc,                    HZ_CUST_SITE_USES_ALL    hzc1,
              hz_parties        party,                      hz_cust_accounts_ALL     cust_acc,
              fnd_lookups       type_lookup,                fnd_lookups          purpose_lookup,
              hr_operating_units   ou
      WHERE   pi.payment_term_id                    = pt.payment_term_id
      AND     pi.payment_schedule_id                =  ps.payment_schedule_id
      AND     pi.export_to_ar_flag                  =  ''Y''
      AND     pi.payment_item_type_lookup_code      =  ''CASH''
      AND     pt.lease_id                           =  le.lease_id
      AND     le.lease_class_code                  <> ''DIRECT''
      AND     hzc.site_use_id                       = pi.customer_site_use_id
      AND     hzc1.site_use_id (+)                  = pi.cust_ship_site_id
      AND     NVL(pi.transferred_to_ar_flag, ''N'') = ''N''
      AND     type_lookup.lookup_type               = ''PN_PAYMENT_TERM_TYPE''
      AND     type_lookup.lookup_code               = pt.payment_term_type_code
      AND     purpose_lookup.lookup_type            = ''PN_PAYMENT_PURPOSE_TYPE''
      AND     purpose_lookup.lookup_code            = pt.payment_purpose_code
      AND     party.party_id                        = cust_acc.party_id
      AND     cust_acc.cust_account_id              = pi.customer_id
      AND     ou.organization_id                    = pi.org_id
      AND     pi.export_currency_amount  <> 0 ' ;

   g_invalid_group_flag := FALSE;
   g_no_group_flag := FALSE;
   g_grp_by_purpose_flag := FALSE;
   g_grp_by_type_flag := FALSE;
   g_grp_by_lenum_flag := FALSE;

   FOR opt_attr IN get_opt_attr
   LOOP
      IF opt_attr.COLUMN_ID = 27 THEN
         g_no_group_flag := TRUE;
         EXIT;
      ELSIF opt_attr.COLUMN_ID = 34 THEN
         g_grp_by_purpose_flag := TRUE;
      ELSIF opt_attr.COLUMN_ID = 88 THEN
         g_grp_by_type_flag := TRUE;
      ELSIF opt_attr.COLUMN_ID = 89 THEN
         g_grp_by_lenum_flag := TRUE;
      ELSE
         g_invalid_group_flag := TRUE;
      END IF;
   END LOOP;

   IF p_grp_param IS NULL THEN

      SELECT  TO_CHAR(pn_payments_group_s.NEXTVAL)
      INTO    l_groupId
      FROM    DUAL;

      IF p_lease_num_low IS NOT NULL AND
         p_lease_num_high IS NOT NULL THEN
         l_lease_num_where_clause := ' AND le.lease_num  BETWEEN :l_lease_num_low AND :l_lease_num_high';

      ELSIF p_lease_num_low IS NULL AND
         p_lease_num_high IS NOT NULL THEN
         l_lease_num_where_clause := ' AND le.lease_num <= :l_lease_num_high';

      ELSIF p_lease_num_low IS NOT NULL AND
         p_lease_num_high IS NULL THEN
         l_lease_num_where_clause := ' AND le.lease_num >= :l_lease_num_low';

      ELSE
         l_lease_num_where_clause := ' AND 2=2 ';
      END IF;

      IF p_sch_dt_low IS NOT NULL AND
         p_sch_dt_high IS NOT NULL THEN
         l_sch_date_where_clause := ' AND ps.schedule_date BETWEEN :l_sch_dt_low AND :l_sch_dt_high';

      ELSIF p_sch_dt_low IS NULL AND
         p_sch_dt_high IS NOT NULL THEN
         l_sch_date_where_clause := ' AND ps.schedule_date <= :l_sch_dt_high';

      ELSIF p_sch_dt_low IS NOT NULL AND
         p_sch_dt_high IS NULL THEN
         l_sch_date_where_clause := ' AND ps.schedule_date >= :l_sch_dt_low';

      ELSE
          l_sch_date_where_clause := ' AND 3=3 ';
      END IF;

      IF p_due_dt_low IS NOT NULL AND
         p_due_dt_high IS NOT NULL THEN
         l_due_date_where_clause := ' AND pi.due_date BETWEEN :l_due_dt_low AND :l_due_dt_high';

      ELSIF p_due_dt_low IS NULL AND
         p_due_dt_high IS NOT NULL THEN
         l_due_date_where_clause := ' AND pi.due_date <= :l_due_dt_high';

      ELSIF p_due_dt_low IS NOT NULL AND
         p_due_dt_high IS NULL THEN
         l_due_date_where_clause := ' AND pi.due_date >= :l_due_dt_low';

      ELSE
          l_due_date_where_clause := ' AND 3=3 ';
      END IF;

      IF p_pay_prps_code IS NOT NULL THEN
         l_pay_prps_where_clause := ' AND pt.payment_purpose_code = :l_pay_prps_code';

      ELSE
         l_pay_prps_where_clause := ' AND 4=4 ';
      END IF;

      IF p_prd_name IS NOT NULL THEN
         l_prd_name_where_clause := ' AND ps.period_name = :l_prd_name';

      ELSE
         l_prd_name_where_clause := ' AND 5=5';
      END IF;

      IF p_amt_low IS NOT NULL AND
         p_amt_high IS NOT NULL THEN
         l_amt_where_clause := ' AND pi.actual_amount BETWEEN :l_amt_low AND :l_amt_high';

      ELSIF p_amt_low IS NULL AND
         p_amt_high IS NOT NULL THEN
         l_amt_where_clause := ' AND pi.actual_amount <= :l_amt_high';

      ELSIF p_amt_low IS NOT NULL AND
         p_amt_high IS NULL THEN
         l_amt_where_clause := ' AND pi.actual_amount >= :l_amt_low';

      ELSE
         l_amt_where_clause := ' AND 6=6 ';
      END IF;

      IF p_customer_id IS NOT NULL THEN
         l_customer_where_clause := ' AND pi.customer_id = :l_customer_id';
      ELSE
         l_customer_where_clause := ' AND 7=7 ';
      END IF;
      l_param_where_clause := l_lease_num_where_clause ||
                              l_sch_date_where_clause ||
                              l_due_date_where_clause ||
                              l_pay_prps_where_clause ||
                              l_prd_name_where_clause ||
                              l_amt_where_clause ||
                              l_customer_where_clause;
   ELSE
      l_param_where_clause := ' AND pi.export_group_id = :l_grp_param';
      l_groupId := p_grp_param;
   END IF;

  IF g_no_group_flag THEN

       Q_Billitem_nogrp := Q_Billitem_nogrp ||l_param_where_clause;
       PN_EXP_TO_AR.EXP_TO_AR_NO_GRP(errbuf
                                     ,retcode
                                     ,l_groupId
                                     ,p_lease_num_low
                                     ,p_lease_num_high
                                     ,p_sch_dt_low
                                     ,p_sch_dt_high
                                     ,p_due_dt_low
                                     ,p_due_dt_high
                                     ,p_pay_prps_code
                                     ,p_prd_name
                                     ,p_amt_low
                                     ,p_amt_high
                                     ,p_customer_id
                                     ,p_grp_param
                                     );
  ELSIF g_invalid_group_flag AND NOT(g_no_group_flag) THEN
    RAISE INVALID_GROUP_RULE;

  ELSIF g_grp_by_purpose_flag OR
        g_grp_by_type_flag OR
        g_grp_by_lenum_flag OR
        (NOT(g_invalid_group_flag) AND NOT(g_no_group_flag)) THEN

        /* Form the Order by clause of optional attributes and print the optional attributes */
       IF g_grp_by_purpose_flag THEN
          fnd_message.set_name ('PN','PN_EXPAR_PMT_PUR');
          pnp_debug_pkg.put_log_msg(fnd_message.get);
          l_ord_clause := l_ord_clause || ' , payment_purpose';
       END IF;
       IF g_grp_by_type_flag THEN
          fnd_message.set_name ('PN','PN_EXPAR_PMT_TYP');
          pnp_debug_pkg.put_log_msg(fnd_message.get);
          l_ord_clause := l_ord_clause || ' , payment_type';
       END IF;
       IF g_grp_by_lenum_flag THEN
          fnd_message.set_name ('PN','PN_EXPAR_LSNO');
          pnp_debug_pkg.put_log_msg(fnd_message.get);
          l_ord_clause := l_ord_clause || ' , le.lease_num';
       END IF;
       Q_Billitem_grp := Q_Billitem_grp ||l_param_where_clause || l_ord_clause;
       PN_EXP_TO_AR.EXP_TO_AR_GRP(errbuf
                                  ,retcode
                                  ,l_groupId
                                  ,p_lease_num_low
                                  ,p_lease_num_high
                                  ,p_sch_dt_low
                                  ,p_sch_dt_high
                                  ,p_due_dt_low
                                  ,p_due_dt_high
                                  ,p_pay_prps_code
                                  ,p_prd_name
                                  ,p_amt_low
                                  ,p_amt_high
                                  ,p_customer_id
                                  ,p_grp_param
                                  );
  END IF;

  pnp_debug_pkg.log('-------- PN_EXP_TO_AR.EXP_TO_AR --------- (-)');

EXCEPTION

  WHEN INVALID_GROUP_RULE THEN
    fnd_message.set_name ('PN', 'PN_INVALID_GROUP_RULE_ATTACHED');
    err_msg := fnd_message.get;
    pnp_debug_pkg.put_log_msg(err_msg);
    errbuf := err_msg;
    retcode := 2;
  WHEN OTHERS THEN
    RAISE;

END EXP_TO_AR;

/*-----------------------------------------------------------------------------
Description:
   Call this procedure if a Grouping Rule is specified such that
   Items can be grouped into one invoice

HISTORY:
-- 03-DEC-03 atuppad  o Created
-- 20-AUG-04 kkhegde  o Bug 3836127 - truncated location code to 30 characters
                        before inserting into interface_line_attribute2
-- 22-NOV-04 kkhegde  o Bug 3751438 - fixed the validation for distributions
-- 22-DEC-04 Kiran    o Fix for 3751438 - corrected it for bug # 4083036
-- 10-MAR-05 piagrawa o Bug #4231051 - Truncated the attribute values to 30
--                      characters before inserting into ra_interface_lines,
--                      ra_interface_salescredits and
--                      ra_interface_distributions tables
-- 15-JUL-05 hareesha o Bug 4284035 - Replaced RA_INTERFACE_DISTRIBUTIONS_ALL
--                                     with _ALL table.
-- 11-OCT-05 pikhar   o Bug 4652946 - Added trunc to pi.accounted_date in
--                      Q_Billitem, l_ord_clause
-- 28-OCT-05 sdmahesh o ATG mandated changes for SQL literals
-- 24-MAR-06 Hareesha o Bug 5116270 Modified get_salesrep_number to pass
--                      org_id as parameter.
-- 07-AUG-06 Hareesha o Bug #5405883 Inserted schedule_date as rule_start_date
--                      into ra_interface_lines_all instead of rule_gl_date.
-----------------------------------------------------------------------------*/
Procedure EXP_TO_AR_GRP (
   errbuf  IN OUT NOCOPY VARCHAR2
  ,retcode IN OUT NOCOPY VARCHAR2
  ,p_groupId            VARCHAR2
  ,p_lease_num_low      VARCHAR2
  ,p_lease_num_high     VARCHAR2
  ,p_sch_dt_low         VARCHAR2
  ,p_sch_dt_high        VARCHAR2
  ,p_due_dt_low         VARCHAR2
  ,p_due_dt_high        VARCHAR2
  ,p_pay_prps_code      VARCHAR2
  ,p_prd_name           VARCHAR2
  ,p_amt_low            NUMBER
  ,p_amt_high           NUMBER
  ,p_customer_id        NUMBER
  ,p_grp_param          VARCHAR2
)
IS

   l_acnt_cls                         PN_DISTRIBUTIONS.account_class%TYPE;
   l_percent                          PN_DISTRIBUTIONS.percentage%TYPE;
   l_location_code                    PN_LOCATIONS.LOCATION_CODE%TYPE;
   l_inv_rule_name                    RA_RULES.NAME%TYPE;
   l_inv_rule_type                    RA_RULES.TYPE%TYPE;
   l_inv_rule_freq                    RA_RULES.FREQUENCY%TYPE;
   l_acc_rule_name                    RA_RULES.NAME%TYPE;
   l_acc_rule_type                    RA_RULES.TYPE%TYPE;
   l_acc_rule_freq                    RA_RULES.FREQUENCY%TYPE;
   l_desc                             RA_INTERFACE_LINES.description%TYPE;
   l_salesrep_number                  RA_SALESREPS.SALESREP_NUMBER%TYPE;
   l_sales_credit_id                  RA_SALESREPS.SALES_CREDIT_TYPE_ID%TYPE;
   l_cust_trx_name                    RA_CUST_TRX_TYPES.NAME%TYPE;
   l_term_name                        RA_TERMS.NAME%TYPE;
   l_pay_method_name                  AR_RECEIPT_METHODS.NAME%TYPE;
   l_amt                              NUMBER;
   l_prior_payment_schedule_id        NUMBER   := -999;
   l_last_updated_by                  NUMBER := FND_GLOBAL.USER_ID;
   l_last_update_login                NUMBER := FND_GLOBAL.LOGIN_ID;
   l_last_update_date                 DATE := sysdate;
   l_context                          VARCHAR2(200);
   l_batch_name                       RA_BATCH_SOURCES.NAME%TYPE;
   l_precision                        NUMBER;
   l_ext_precision                    NUMBER;
   l_min_acct_unit                    NUMBER;
   t_count                            NUMBER := 0;
   e_count                            NUMBER := 0;
   s_count                            NUMBER := 0;
   l_tax_code                         AR_VAT_TAX.tax_code%TYPE;
   l_tax_classification_code          pn_payment_terms.tax_classification_code%TYPE;
   l_rev_acc_alloc_rule               RA_BATCH_SOURCES.rev_acc_allocation_rule%TYPE;
   l_rev_flag                         VARCHAR2(1);
   l_rec_flag                         VARCHAR2(1);
   l_ast_flag                         VARCHAR2(1);
   l_rec_cnt                          NUMBER;
   l_prof_optn                        VARCHAR2(30);
   l_err_msg1                         VARCHAR2(2000);
   l_err_msg2                         VARCHAR2(2000);
   l_err_msg3                         VARCHAR2(2000);
   l_err_msg4                         VARCHAR2(2000);
   l_sys_para                         VARCHAR2(1);
   l_gl_seg                           VARCHAR2(1);
   l_sal_cred                         VARCHAR2(1);
   l_total_rev_amt                    NUMBER := 0;
   l_total_rev_percent                NUMBER := 0;
   l_diff_amt                         NUMBER := 0;
   l_set_of_books_id                  NUMBER := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                          pn_mo_cache_utils.get_current_org_id));
   l_func_curr_code                   GL_SETS_OF_BOOKS.currency_code%TYPE;
   exp_ar_tbl                         exp_ar_tbl_type;
   l_total_items                      NUMBER := 0;
   l_index                            NUMBER := 1;
   l_start                            NUMBER;
   l_next                             NUMBER;
   l_count                            NUMBER;
   l_item_prcsed                      NUMBER := 0;
   l_rec_insert_flag                  BOOLEAN := TRUE;
   l_valid_rec_accs                   BOOLEAN := TRUE;
   l_grp                              NUMBER;
   l_post_to_gl                       RA_CUST_TRX_TYPES_ALL.POST_TO_GL%TYPE;
   l_derive_date_flag                 RA_BATCH_SOURCES.derive_date_flag%TYPE;
   l_rule_start_date                  RA_INTERFACE_LINES.RULE_START_DATE%TYPE := NULL;
   l_count_grp                     INTEGER;
   l_rows_grp                      INTEGER;
   v_pn_payment_item_id            PN_PAYMENT_ITEMS.payment_item_id%TYPE;
   v_pn_payment_term_id            PN_PAYMENT_ITEMS.payment_term_id%TYPE;
   v_pn_export_currency_code       PN_PAYMENT_ITEMS.export_currency_code%TYPE;
   v_pn_export_currency_amount     PN_PAYMENT_ITEMS.export_currency_amount%TYPE;
   v_pn_customer_id                PN_PAYMENT_ITEMS.customer_id%TYPE;
   v_pn_customer_site_use_id       PN_PAYMENT_ITEMS.customer_site_use_id%TYPE;
   v_pn_cust_ship_site_id          PN_PAYMENT_TERMS.cust_ship_site_id%TYPE;
   v_pn_tax_code_id                PN_PAYMENT_TERMS.tax_code_id%TYPE;
   v_pn_tax_classification_code    PN_PAYMENT_TERMS.tax_classification_code%TYPE;
   v_pn_legal_entity_id            PN_PAYMENT_TERMS.legal_entity_id%TYPE;
   v_pn_inv_rule_id                PN_PAYMENT_TERMS.inv_rule_id%TYPE;
   v_pn_account_rule_id            PN_PAYMENT_TERMS.account_rule_id%TYPE;
   v_pn_term_id                    PN_PAYMENT_TERMS.ap_ar_term_id%TYPE;
   v_pn_trx_type_id                PN_PAYMENT_TERMS.cust_trx_type_id%TYPE;
   v_pn_pay_method_id              PN_PAYMENT_TERMS.receipt_method_id%TYPE;
   v_pn_po_number                  PN_PAYMENT_TERMS.cust_po_number%TYPE;
   v_pn_tax_included               PN_PAYMENT_TERMS.tax_included%TYPE;
   v_pn_salesrep_id                PN_PAYMENT_TERMS.salesrep_id%TYPE;
   v_pn_proj_attr_catg             PN_PAYMENT_TERMS.project_attribute_category%TYPE;
   v_pn_proj_attr3                 PN_PAYMENT_TERMS.project_attribute3%TYPE;
   v_pn_proj_attr4                 PN_PAYMENT_TERMS.project_attribute4%TYPE;
   v_pn_proj_attr5                 PN_PAYMENT_TERMS.project_attribute5%TYPE;
   v_pn_proj_attr6                 PN_PAYMENT_TERMS.project_attribute6%TYPE;
   v_pn_proj_attr7                 PN_PAYMENT_TERMS.project_attribute7%TYPE;
   v_pn_org_id                     PN_PAYMENT_TERMS.org_id%TYPE;
   v_pn_lease_num                  PN_LEASES.lease_num%TYPE;
   v_pn_payment_schedule_id        PN_PAYMENT_ITEMS.payment_schedule_id%TYPE;
   v_pn_period_name                PN_PAYMENT_SCHEDULES.period_name%TYPE;
   v_pn_description                PN_PAYMENT_TERMS.payment_purpose_code%TYPE;
   v_pn_lease_id                   PN_LEASES.lease_id%TYPE;
   v_transaction_date              PN_PAYMENT_ITEMS.due_date%TYPE;
   v_normalize                     PN_PAYMENT_TERMS.normalize%TYPE;
   v_pn_accounted_date             PN_PAYMENT_ITEMS.accounted_date%TYPE;
   v_pn_rate                       PN_PAYMENT_ITEMS.rate%TYPE;
   v_location_id                   PN_LOCATIONS.LOCATION_ID%TYPE;
   v_send_entries                  PN_LEASE_DETAILS.send_entries%TYPE;
   v_rec_account                   PN_DISTRIBUTIONS.account_id%TYPE;
   v_gl_date                       RA_CUST_TRX_LINE_GL_DIST.gl_date%TYPE;
   v_conv_rate_type                PN_CURRENCIES.conversion_type%TYPE;
   v_conv_rate                     PN_PAYMENT_ITEMS.rate%TYPE;
   v_payment_purpose               PN_PAYMENT_TERMS.payment_purpose_code%TYPE;
   v_payment_type                  PN_PAYMENT_TERMS.payment_term_type_code%TYPE;
   v_rule_gl_date                  RA_CUST_TRX_LINE_GL_DIST.gl_date%TYPE;
   v_schedule_date                 PN_PAYMENT_SCHEDULES.schedule_date%TYPE;
   v_pn_payment_term_id1           PN_PAYMENT_ITEMS.payment_term_id%TYPE;
   v_pn_le_id1                     PN_PAYMENT_TERMS.legal_entity_id%TYPE;
   v_pn_customer_id1               PN_PAYMENT_ITEMS.customer_id%TYPE;
   v_pn_trx_type_id1               PN_PAYMENT_TERMS.cust_trx_type_id%TYPE;
   v_pn_org_id1                    PN_PAYMENT_TERMS.org_id%TYPE;
   l_rows_select_grp               NUMBER;
   l_count_select_grp              NUMBER;
   TYPE le_ar_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE term_ar_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   le_ar_tbl                         le_ar_tbl_type;
   term_ar_tbl                       term_ar_tbl_type;


BEGIN

    /* Get the Optional Attributes of the Grouping Rule mentioned in Batch Source */
    l_context := 'Getting the Optional Attributes of the Grouping Rule mentioned in Batch Source';

    fnd_message.set_name ('PN','PN_EXPAR_OPT');
    pnp_debug_pkg.put_log_msg(fnd_message.get);
    l_context := 'Getting the Batch Source Name';
    pnp_debug_pkg.log(l_context);
    /* get the batch source name */
    OPEN get_batch_source_name;
    FETCH get_batch_source_name into l_batch_name, l_rev_acc_alloc_rule,
                                     l_sal_cred, l_derive_date_flag;
    CLOSE get_batch_source_name;

    l_index := 1;
    le_ar_tbl.delete;
    term_ar_tbl.delete;

    Q_select_grp := 'SELECT payment_term_id,
                       customer_id,
                       cust_trx_type_id,
                       org_id
                  FROM ('||Q_Billitem_grp||')
                 WHERE legal_entity_id IS NULL';
    g_cursor_select_grp  := dbms_sql.open_cursor;
    dbms_sql.parse(g_cursor_select_grp,Q_select_grp,dbms_sql.native);
    do_binding (g_cursor_select_grp
               ,p_lease_num_low
               ,p_lease_num_high
               ,p_sch_dt_low
               ,p_sch_dt_high
               ,p_due_dt_low
               ,p_due_dt_high
               ,p_pay_prps_code
               ,p_prd_name
               ,p_amt_low
               ,p_amt_high
               ,p_customer_id
               ,p_grp_param
               );

    dbms_sql.define_column (g_cursor_select_grp,1,v_pn_payment_term_id1);
    dbms_sql.define_column (g_cursor_select_grp,2,v_pn_customer_id1);
    dbms_sql.define_column (g_cursor_select_grp,3,v_pn_trx_type_id1);
    dbms_sql.define_column (g_cursor_select_grp,4,v_pn_org_id1);
    l_rows_select_grp   := dbms_sql.execute(g_cursor_select_grp);

    LOOP
      BEGIN
        l_count_select_grp := dbms_sql.fetch_rows(g_cursor_select_grp);
        EXIT WHEN l_count_select_grp <> 1;
        dbms_sql.column_value (g_cursor_select_grp, 1,term_ar_tbl(l_index));
        dbms_sql.column_value (g_cursor_select_grp, 2,v_pn_customer_id1);
        dbms_sql.column_value (g_cursor_select_grp,3,v_pn_trx_type_id1);
        dbms_sql.column_value (g_cursor_select_grp,4,v_pn_org_id1);
        le_ar_tbl(l_index) := pn_r12_util_pkg.get_le_for_ar(v_pn_customer_id1,
                                                            v_pn_trx_type_id1,
                                                            v_pn_org_id1);

        l_index := l_index+1;
      END;
    END LOOP;

    FORALL i IN term_ar_tbl.FIRST..term_ar_tbl.LAST
      UPDATE pn_payment_terms_all
      SET legal_entity_id = le_ar_tbl(i)
      WHERE payment_term_id = term_ar_tbl(i);

    IF dbms_sql.is_open (g_cursor_select_grp) THEN
        dbms_sql.close_cursor (g_cursor_select_grp);
    END IF;

    l_context := 'Opening the cursor';
    g_cursor_grp := dbms_sql.open_cursor;
    dbms_sql.parse(g_cursor_grp, Q_Billitem_grp, dbms_sql.native);
    do_binding (g_cursor_grp
                ,p_lease_num_low
                ,p_lease_num_high
                ,p_sch_dt_low
                ,p_sch_dt_high
                ,p_due_dt_low
                ,p_due_dt_high
                ,p_pay_prps_code
                ,p_prd_name
                ,p_amt_low
                ,p_amt_high
                ,p_customer_id
                ,p_grp_param
                );


    /* === LOGIC ===
      o open the ref cursor using the query that we dynamically
        constructed.
      o fetch all the valid items into the PL/SQL table of
        records.
       === LOGIC === */

    /* Initialize the table and loop index */
    l_index := 1;
    exp_ar_tbl.DELETE;
    dbms_sql.define_column (g_cursor_grp, 1, v_pn_payment_item_id);
    dbms_sql.define_column (g_cursor_grp, 2, v_pn_payment_term_id);
    dbms_sql.define_column (g_cursor_grp, 3, v_pn_export_currency_code,15);
    dbms_sql.define_column (g_cursor_grp, 4, v_pn_export_currency_amount);
    dbms_sql.define_column (g_cursor_grp, 5, v_pn_customer_id );
    dbms_sql.define_column (g_cursor_grp, 6, v_pn_customer_site_use_id );
    dbms_sql.define_column (g_cursor_grp, 7, v_pn_cust_ship_site_id);
    dbms_sql.define_column (g_cursor_grp, 8, v_pn_tax_code_id);
    dbms_sql.define_column (g_cursor_grp, 9, v_pn_tax_classification_code,30);
    dbms_sql.define_column (g_cursor_grp, 10,v_pn_legal_entity_id);
    dbms_sql.define_column (g_cursor_grp, 11,v_pn_inv_rule_id );
    dbms_sql.define_column (g_cursor_grp, 12,v_pn_account_rule_id);
    dbms_sql.define_column (g_cursor_grp, 13,v_pn_term_id);
    dbms_sql.define_column (g_cursor_grp, 14,v_pn_trx_type_id);
    dbms_sql.define_column (g_cursor_grp, 15,v_pn_pay_method_id);
    dbms_sql.define_column (g_cursor_grp, 16,v_pn_po_number,50);
    dbms_sql.define_column (g_cursor_grp, 17,v_pn_tax_included,1);
    dbms_sql.define_column (g_cursor_grp, 18,v_pn_salesrep_id);
    dbms_sql.define_column (g_cursor_grp, 19,v_pn_proj_attr_catg,30);
    dbms_sql.define_column (g_cursor_grp, 20,v_pn_proj_attr3,150);
    dbms_sql.define_column (g_cursor_grp, 21,v_pn_proj_attr4,150);
    dbms_sql.define_column (g_cursor_grp, 22,v_pn_proj_attr5,150);
    dbms_sql.define_column (g_cursor_grp, 23,v_pn_proj_attr6,150);
    dbms_sql.define_column (g_cursor_grp, 24,v_pn_proj_attr7,150);
    dbms_sql.define_column (g_cursor_grp, 25,v_pn_org_id);
    dbms_sql.define_column (g_cursor_grp, 26,v_pn_lease_num,30);
    dbms_sql.define_column (g_cursor_grp, 27,v_pn_payment_schedule_id);
    dbms_sql.define_column (g_cursor_grp, 28,v_pn_period_name,15);
    dbms_sql.define_column (g_cursor_grp, 29,v_pn_description,30);
    dbms_sql.define_column (g_cursor_grp, 30,v_pn_lease_id);
    dbms_sql.define_column (g_cursor_grp, 31,v_transaction_date);
    dbms_sql.define_column (g_cursor_grp, 32,v_normalize,1);
    dbms_sql.define_column (g_cursor_grp, 33,v_pn_accounted_date);
    dbms_sql.define_column (g_cursor_grp, 34,v_pn_rate);
    dbms_sql.define_column (g_cursor_grp, 35,v_location_id);
    dbms_sql.define_column (g_cursor_grp, 36,v_send_entries,1);
    dbms_sql.define_column (g_cursor_grp, 37,v_rec_account);
    dbms_sql.define_column (g_cursor_grp, 38,v_gl_date);
    dbms_sql.define_column (g_cursor_grp, 39,v_conv_rate);
    dbms_sql.define_column (g_cursor_grp, 40,v_conv_rate_type,30);
    dbms_sql.define_column (g_cursor_grp, 41,v_payment_purpose,30);
    dbms_sql.define_column (g_cursor_grp, 42,v_payment_type,30);
    dbms_sql.define_column (g_cursor_grp, 43,v_rule_gl_date);
    dbms_sql.define_column (g_cursor_grp, 44,v_schedule_date);

    l_rows_grp   := dbms_sql.execute(g_cursor_grp);
    LOOP
      BEGIN
        l_context := 'Fetching from the cursor';
        l_count_grp := dbms_sql.fetch_rows( g_cursor_grp);
        EXIT WHEN l_count_grp <> 1;
        dbms_sql.column_value (g_cursor_grp, 1, exp_ar_tbl(l_index).pn_payment_item_id);
        dbms_sql.column_value (g_cursor_grp, 2, exp_ar_tbl(l_index).pn_payment_term_id);
        dbms_sql.column_value (g_cursor_grp, 3, exp_ar_tbl(l_index).pn_export_currency_code);
        dbms_sql.column_value (g_cursor_grp, 4, exp_ar_tbl(l_index).pn_export_currency_amount);
        dbms_sql.column_value (g_cursor_grp, 5, exp_ar_tbl(l_index).pn_customer_id);
        dbms_sql.column_value (g_cursor_grp, 6, exp_ar_tbl(l_index).pn_customer_site_use_id);
        dbms_sql.column_value (g_cursor_grp, 7, exp_ar_tbl(l_index).pn_cust_ship_site_id);
        dbms_sql.column_value (g_cursor_grp, 8, exp_ar_tbl(l_index).pn_tax_code_id);
        dbms_sql.column_value (g_cursor_grp, 9, exp_ar_tbl(l_index).pn_tax_classification_code);
        dbms_sql.column_value (g_cursor_grp, 10,exp_ar_tbl(l_index).pn_legal_entity_id);
        dbms_sql.column_value (g_cursor_grp, 11,exp_ar_tbl(l_index).pn_inv_rule_id);
        dbms_sql.column_value (g_cursor_grp, 12,exp_ar_tbl(l_index).pn_account_rule_id);
        dbms_sql.column_value (g_cursor_grp, 13,exp_ar_tbl(l_index).pn_term_id);
        dbms_sql.column_value (g_cursor_grp, 14,exp_ar_tbl(l_index).pn_trx_type_id);
        dbms_sql.column_value (g_cursor_grp, 15,exp_ar_tbl(l_index).pn_pay_method_id);
        dbms_sql.column_value (g_cursor_grp, 16,exp_ar_tbl(l_index).pn_po_number);
        dbms_sql.column_value (g_cursor_grp, 17,exp_ar_tbl(l_index).pn_tax_included);
        dbms_sql.column_value (g_cursor_grp, 18,exp_ar_tbl(l_index).pn_salesrep_id);
        dbms_sql.column_value (g_cursor_grp, 19,exp_ar_tbl(l_index).pn_proj_attr_catg);
        dbms_sql.column_value (g_cursor_grp, 20,exp_ar_tbl(l_index).pn_proj_attr3);
        dbms_sql.column_value (g_cursor_grp, 21,exp_ar_tbl(l_index).pn_proj_attr4);
        dbms_sql.column_value (g_cursor_grp, 22,exp_ar_tbl(l_index).pn_proj_attr5);
        dbms_sql.column_value (g_cursor_grp, 23,exp_ar_tbl(l_index).pn_proj_attr6);
        dbms_sql.column_value (g_cursor_grp, 24,exp_ar_tbl(l_index).pn_proj_attr7);
        dbms_sql.column_value (g_cursor_grp, 25,exp_ar_tbl(l_index).pn_org_id);
        dbms_sql.column_value (g_cursor_grp, 26,exp_ar_tbl(l_index).pn_lease_num);
        dbms_sql.column_value (g_cursor_grp, 27,exp_ar_tbl(l_index).pn_payment_schedule_id);
        dbms_sql.column_value (g_cursor_grp, 28,exp_ar_tbl(l_index).pn_period_name);
        dbms_sql.column_value (g_cursor_grp, 29,exp_ar_tbl(l_index).pn_description);
        dbms_sql.column_value (g_cursor_grp, 30,exp_ar_tbl(l_index).pn_lease_id);
        dbms_sql.column_value (g_cursor_grp, 31,exp_ar_tbl(l_index).transaction_date);
        dbms_sql.column_value (g_cursor_grp, 32,exp_ar_tbl(l_index).normalize);
        dbms_sql.column_value (g_cursor_grp, 33,exp_ar_tbl(l_index).pn_accounted_date);
        dbms_sql.column_value (g_cursor_grp, 34,exp_ar_tbl(l_index).pn_rate);
        dbms_sql.column_value (g_cursor_grp, 35,exp_ar_tbl(l_index).location_id);
        dbms_sql.column_value (g_cursor_grp, 36,exp_ar_tbl(l_index).send_entries);
        dbms_sql.column_value (g_cursor_grp, 37,exp_ar_tbl(l_index).rec_account);
        dbms_sql.column_value (g_cursor_grp, 38,exp_ar_tbl(l_index).gl_date);
        dbms_sql.column_value (g_cursor_grp, 39,exp_ar_tbl(l_index).conv_rate);
        dbms_sql.column_value (g_cursor_grp, 40,exp_ar_tbl(l_index).conv_rate_type);
        dbms_sql.column_value (g_cursor_grp, 41,exp_ar_tbl(l_index).payment_purpose);
        dbms_sql.column_value (g_cursor_grp, 42,exp_ar_tbl(l_index).payment_type);
        dbms_sql.column_value (g_cursor_grp, 43,exp_ar_tbl(l_index).rule_gl_date);
        dbms_sql.column_value (g_cursor_grp, 44,exp_ar_tbl(l_index).schedule_date);

        l_rev_flag   := 'N';
        l_rec_flag   := 'N';
        l_ast_flag   := 'N';
        l_rec_cnt    := 0;
        l_prof_optn  := pn_mo_cache_utils.get_profile_value('PN_ACCOUNTING_OPTION',
                        pn_mo_cache_utils.get_current_org_id);

        FOR dist_rec IN acnt_cls_cur(exp_ar_tbl(l_index).pn_payment_term_id)
        LOOP

           IF dist_rec.account_class IN ('REV') THEN
              l_rev_flag := 'Y';
           ELSIF dist_rec.account_class IN ('REC') THEN
              l_rec_flag := 'Y';
           ELSIF dist_rec.account_class IN ('UNEARN') THEN
              l_ast_flag := 'Y';
           END IF;

           l_rec_cnt := l_rec_cnt + 1;

        END LOOP;

        t_count := t_count + 1;

        /* Check for Invalid Items here */
        IF UPPER(exp_ar_tbl(l_index).conv_rate_type) = 'USER'
          AND exp_ar_tbl(l_index).conv_rate IS NULL THEN

          fnd_message.set_name ('PN', 'PN_CONV_RATE_REQD');
          l_err_msg4 := fnd_message.get;
          pnp_debug_pkg.put_log_msg(l_err_msg4);

          RAISE GENERIC_EXPORT_EXCEPTION;

        END IF;

        IF exp_ar_tbl(l_index).pn_term_id IS NULL
          OR exp_ar_tbl(l_index).pn_trx_type_id IS NULL THEN

          fnd_message.set_name ('PN', 'PN_PTRM_TRX_REQD_MSG');
          l_err_msg3 := fnd_message.get;
          pnp_debug_pkg.put_log_msg(l_err_msg3);

          RAISE GENERIC_EXPORT_EXCEPTION;

        END IF;

        IF NVL(exp_ar_tbl(l_index).normalize,'N') = 'Y' THEN

          IF (l_rev_flag <> 'Y' OR l_rec_flag <> 'Y' OR l_ast_flag <> 'Y') THEN

            fnd_message.set_name ('PN', 'PN_ALL_ACNT_DIST_MSG');
            l_err_msg1 := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_err_msg1);

            RAISE GENERIC_EXPORT_EXCEPTION;

          END IF;

        ELSIF NVL(exp_ar_tbl(l_index).normalize,'N') = 'N' THEN

          IF (l_prof_optn = 'Y' AND (l_rev_flag <> 'Y' OR l_rec_flag <> 'Y')) OR
             (l_prof_optn IN ('M', 'N') AND ((l_rev_flag = 'Y' AND l_rec_flag <> 'Y') OR
                                             (l_rev_flag <> 'Y' AND l_rec_flag = 'Y')))
          THEN

            fnd_message.set_name ('PN', 'PN_REVREC_DIST_MSG');
            l_err_msg2 := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_err_msg2);

            RAISE GENERIC_EXPORT_EXCEPTION;

          END IF;

        END IF;

        exp_ar_tbl(l_index).set_of_books_id
          := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                       pn_mo_cache_utils.get_current_org_id));
        -- increase the index only if the item needs to be inserted into interface tables
        l_index := l_index+1;

      EXCEPTION

        WHEN GENERIC_EXPORT_EXCEPTION THEN
          e_count := e_count + 1;
          /* The below condition takes care that if the last record
             is invalid, it is not part of PL/SQL table */
          IF t_count = l_total_items THEN
            exp_ar_tbl.DELETE(l_index);
          END IF;

        WHEN OTHERS THEN
          RAISE;

      END;

    END LOOP; /* loop for c_billitem */
    IF dbms_sql.is_open (g_cursor_grp) THEN
        dbms_sql.close_cursor (g_cursor_grp);
    END IF;


    /*CLOSE c_billitem;*/
    /* we have now fetched all valid items into the table */

    /* === LOGIC ===
       o loop through the table to identify the groups.
       o the items are already ordered appropriately.
       o once we identify a group,
          if the REC account for a group is not same then
             reject the whole group
          elsif the group is valid then
             insert into AR interface tables appropriately
             for all lines belonging to one group,
                insert only one distribution for REC with 0 amount
          end if
       === LOGIC === */

    /* Initialize the counters */
    l_start := 1;
    l_next := 2;
    l_item_prcsed := 0;
    l_count := exp_ar_tbl.count;

    fnd_message.set_name ('PN','PN_EXPAR_ITM_PROC');
    fnd_message.set_token ('NUM',l_count);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    l_context := 'Finding the Groups of items';
    pnp_debug_pkg.log(l_context);

    -- start loopin thru the table
    WHILE (l_item_prcsed < l_count)
    LOOP

      IF ( (l_next <= l_count)
       AND ((exp_ar_tbl(l_start).gl_date                 = exp_ar_tbl(l_next).gl_date)
            OR (exp_ar_tbl(l_start).gl_date IS NULL AND exp_ar_tbl(l_next).gl_date IS NULL))
       AND ((exp_ar_tbl(l_start).pn_inv_rule_id          = exp_ar_tbl(l_next).pn_inv_rule_id)
            OR (exp_ar_tbl(l_start).pn_inv_rule_id IS NULL AND exp_ar_tbl(l_next).pn_inv_rule_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_pay_method_id        = exp_ar_tbl(l_next).pn_pay_method_id)
            OR (exp_ar_tbl(l_start).pn_pay_method_id IS NULL AND exp_ar_tbl(l_next).pn_pay_method_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_salesrep_id          = exp_ar_tbl(l_next).pn_salesrep_id)
            OR (exp_ar_tbl(l_start).pn_salesrep_id IS NULL AND exp_ar_tbl(l_next).pn_salesrep_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_po_number            = exp_ar_tbl(l_next).pn_po_number)
            OR (exp_ar_tbl(l_start).pn_po_number IS NULL AND exp_ar_tbl(l_next).pn_po_number IS NULL))
       AND ((exp_ar_tbl(l_start).set_of_books_id         = exp_ar_tbl(l_next).set_of_books_id)
            OR (exp_ar_tbl(l_start).set_of_books_id IS NULL AND exp_ar_tbl(l_next).set_of_books_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_export_currency_code = exp_ar_tbl(l_next).pn_export_currency_code)
            OR (exp_ar_tbl(l_start).pn_export_currency_code IS NULL AND exp_ar_tbl(l_next).pn_export_currency_code IS NULL))
       AND ((exp_ar_tbl(l_start).pn_trx_type_id          = exp_ar_tbl(l_next).pn_trx_type_id)
            OR (exp_ar_tbl(l_start).pn_trx_type_id IS NULL AND exp_ar_tbl(l_next).pn_trx_type_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_term_id              = exp_ar_tbl(l_next).pn_term_id)
            OR (exp_ar_tbl(l_start).pn_term_id IS NULL AND exp_ar_tbl(l_next).pn_term_id IS NULL))
       AND ((exp_ar_tbl(l_start).conv_rate_type          = exp_ar_tbl(l_next).conv_rate_type)
            OR (exp_ar_tbl(l_start).conv_rate_type IS NULL AND exp_ar_tbl(l_next).conv_rate_type IS NULL))
       AND ((exp_ar_tbl(l_start).conv_rate               = exp_ar_tbl(l_next).conv_rate)
            OR (exp_ar_tbl(l_start).conv_rate IS NULL AND exp_ar_tbl(l_next).conv_rate IS NULL))
       AND ((exp_ar_tbl(l_start).pn_accounted_date       = exp_ar_tbl(l_next).pn_accounted_date)
            OR (exp_ar_tbl(l_start).pn_accounted_date IS NULL AND exp_ar_tbl(l_next).pn_accounted_date IS NULL))
       AND ((exp_ar_tbl(l_start).pn_customer_id          = exp_ar_tbl(l_next).pn_customer_id)
            OR (exp_ar_tbl(l_start).pn_customer_id IS NULL AND exp_ar_tbl(l_next).pn_customer_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_customer_site_use_id = exp_ar_tbl(l_next).pn_customer_site_use_id)
            OR (exp_ar_tbl(l_start).pn_customer_site_use_id IS NULL AND exp_ar_tbl(l_next).pn_customer_site_use_id IS NULL))
       AND ((exp_ar_tbl(l_start).pn_cust_ship_site_id    = exp_ar_tbl(l_next).pn_cust_ship_site_id)
            OR (exp_ar_tbl(l_start).pn_cust_ship_site_id IS NULL AND exp_ar_tbl(l_next).pn_cust_ship_site_id IS NULL))
       AND ((exp_ar_tbl(l_start).transaction_date        = exp_ar_tbl(l_next).transaction_date)
            OR (exp_ar_tbl(l_start).transaction_date IS NULL AND exp_ar_tbl(l_next).transaction_date IS NULL))
       AND ((exp_ar_tbl(l_start).pn_legal_entity_id = exp_ar_tbl(l_next).pn_legal_entity_id)
            OR (exp_ar_tbl(l_start).pn_legal_entity_id IS NULL AND exp_ar_tbl(l_next).pn_legal_entity_id IS NULL))
       AND ((g_grp_by_purpose_flag AND exp_ar_tbl(l_start).payment_purpose = exp_ar_tbl(l_next).payment_purpose)
            OR (NOT g_grp_by_purpose_flag))
       AND ((g_grp_by_type_flag AND exp_ar_tbl(l_start).payment_type = exp_ar_tbl(l_next).payment_type)
            OR (NOT g_grp_by_type_flag))
       AND ((g_grp_by_lenum_flag AND exp_ar_tbl(l_start).pn_lease_num = exp_ar_tbl(l_next).pn_lease_num)
            OR (NOT g_grp_by_lenum_flag))
       AND ((NVL(l_derive_date_flag,'N') = 'Y' AND
             exp_ar_tbl(l_start).rule_gl_date = exp_ar_tbl(l_next).rule_gl_date) OR
            (exp_ar_tbl(l_start).rule_gl_date IS NULL AND exp_ar_tbl(l_next).rule_gl_date IS NULL))
          ) THEN

          -- increment 'next' counter. we are still getting the group.
          l_next := l_next + 1;

      ELSE -- we have a group!

        l_context := 'Group found. Checking REC account';
        pnp_debug_pkg.log(l_context);

        -- validate the group for REC account.
        l_valid_rec_accs := TRUE;

        FOR l_grp IN l_start+1 .. l_next-1 LOOP

           IF (exp_ar_tbl(l_start).rec_account
                <> exp_ar_tbl(l_grp).rec_account) THEN

              l_item_prcsed := l_next-1;
              e_count := e_count + l_next - l_start;
              l_start := l_next;
              l_next := l_next + 1;
              l_valid_rec_accs := FALSE;
              fnd_message.set_name ('PN', 'PN_UNMATCHING_REC_ACCNT');
              pnp_debug_pkg.put_log_msg(fnd_message.get);
              EXIT;

           END IF;

        END LOOP;

        -- if REC account is valid, continue!
        IF l_valid_rec_accs THEN

          l_context := 'Group Valid. Processing the grouped items';
          pnp_debug_pkg.log(l_context);

          fnd_message.set_name ('PN','PN_EXPAR_ITM_QLFY');
          fnd_message.set_token ('NUM',(l_next-l_start));
          pnp_debug_pkg.put_log_msg(fnd_message.get);

          l_rec_insert_flag    := TRUE;
          l_last_updated_by    := FND_GLOBAL.USER_ID;
          l_last_update_login  := FND_GLOBAL.LOGIN_ID;
          l_last_update_date   := sysdate;

          /* if we reached here, we have a group worth inserting
             loop through the PL/SQL table and insert
               o one record per item in group into ra_interface_lines
               o distributions into ra_interface_distributions for REV
                 and UNEARN based on pn_distributions for each line
               o ONLY one record in ra_interface_distributions for REC
                 for ALL items
          */

          FOR l_grp IN l_start .. l_next-1 LOOP

            /* Default the precision to 2 */
            l_precision := 2;

            /* Get the correct precision for the currency so that the amount can be rounded off */
            fnd_currency.get_info(exp_ar_tbl(l_grp).pn_export_currency_code,
                                  l_precision, l_ext_precision, l_min_acct_unit);
            pnp_debug_pkg.put_log_msg('
================================================================================');
            fnd_message.set_name ('PN','PN_EXPAR_PMT_PRM');
            fnd_message.set_token ('ITM_ID',exp_ar_tbl(l_grp).pn_payment_item_id);
            fnd_message.set_token ('CUST_ID',TO_CHAR(exp_ar_tbl(l_grp).pn_customer_id));
            fnd_message.set_token ('REC_AMT',0);
            fnd_message.set_token ('DATE',exp_ar_tbl(l_grp).gl_date);
            pnp_debug_pkg.put_log_msg('
================================================================================');


            /* Print the Conversion Rate and Type */
            fnd_message.set_name ('PN','PN_CRACC_CV_RATE');
            fnd_message.set_token ('CR',exp_ar_tbl(l_grp).conv_rate);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            fnd_message.set_name ('PN','PN_CRACC_CV_TYPE');
            fnd_message.set_token ('CT',exp_ar_tbl(l_grp).conv_rate_type);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* Print send entries flag for the lease */
            fnd_message.set_name ('PN','PN_EXPAR_PMT_LS');
            fnd_message.set_token ('ID',exp_ar_tbl(l_grp).pn_lease_id);
            fnd_message.set_token ('SEND',exp_ar_tbl(l_grp).send_entries);
            pnp_debug_pkg.put_log_msg(fnd_message.get);


            /* Initialize the variables */
            l_desc := NULL;
            l_inv_rule_name := NULL;
            l_inv_rule_type := NULL;
            l_inv_rule_freq := NULL;
            l_acc_rule_name := NULL;
            l_acc_rule_type := NULL;
            l_acc_rule_freq := NULL;
            l_pay_method_name := NULL;
            l_salesrep_number := NULL;
            l_sales_credit_id := NULL;
            l_cust_trx_name := NULL;
            l_term_name := NULL;
            l_location_code := NULL;
            l_gl_seg := NULL;
            l_sys_para := NULL;
            l_post_to_gl := NULL;
            l_tax_code := NULL;

            /* get the description */
            OPEN get_desc(exp_ar_tbl(l_grp).PN_DESCRIPTION);
            FETCH get_desc into l_desc;
            CLOSE get_desc;

            /* get the invoicing rule name */
            OPEN get_rule_name(exp_ar_tbl(l_grp).pn_inv_rule_id);
            FETCH get_rule_name into l_inv_rule_name, l_inv_rule_type, l_inv_rule_freq;
            CLOSE get_rule_name;

            fnd_message.set_name ('PN','PN_EXPAR_INV_RULE');
            fnd_message.set_token ('NAME',l_inv_rule_name);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* get the accounting rule name */
            OPEN get_rule_name(exp_ar_tbl(l_grp).pn_account_rule_id);
            FETCH get_rule_name into l_acc_rule_name,l_acc_rule_type, l_acc_rule_freq;
            CLOSE get_rule_name;

            fnd_message.set_name ('PN','PN_EXPAR_ACC_RUL_NAME');
            fnd_message.set_token ('NAME',l_acc_rule_name);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            fnd_message.set_name ('PN','PN_EXPAR_ACC_RUL_TYPE');
            fnd_message.set_token ('TYPE',l_acc_rule_type);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            fnd_message.set_name ('PN','PN_EXPAR_GL_RUL_FREQ');
            fnd_message.set_token ('FREQ',l_acc_rule_freq);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            IF exp_ar_tbl(l_grp).pn_account_rule_id IS NOT NULL AND
               (l_acc_rule_type <> 'A' OR
                l_acc_rule_freq <> 'SPECIFIC') AND
               NVL(l_derive_date_flag,'N') = 'Y' THEN

               l_rule_start_date := exp_ar_tbl(l_grp).schedule_date;
            ELSE
               l_rule_start_date := NULL;
            END IF;

            fnd_message.set_name ('PN','PN_EXPAR_RUL_ST_DT');
            fnd_message.set_token ('DATE',l_rule_start_date);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* get the payment method name */
            OPEN get_receipt_name(exp_ar_tbl(l_grp).pn_pay_method_id);
            FETCH get_receipt_name into l_pay_method_name;
            CLOSE get_receipt_name;

            /* get the payment method name */
            fnd_message.set_name ('PN','PN_EXPAR_PMT_MTHD');
            fnd_message.set_token ('METHOD',l_pay_method_name);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* get the salesrep number */
            OPEN get_salesrep_number(exp_ar_tbl(l_grp).pn_salesrep_id,
                                     exp_ar_tbl(l_grp).pn_org_id);
            FETCH get_salesrep_number into l_salesrep_number,l_sales_credit_id;
            CLOSE get_salesrep_number;

            fnd_message.set_name ('PN','PN_EXPAR_SALES_REP');
            fnd_message.set_token ('NAME',l_salesrep_number);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* get the cust transaction type name */
            OPEN get_cust_trx_name(exp_ar_tbl(l_grp).pn_trx_type_id);
            FETCH get_cust_trx_name into l_cust_trx_name;
            CLOSE get_cust_trx_name;

            fnd_message.set_name ('PN','PN_EXPAR_TRNX_TYPE');
            fnd_message.set_token ('TYPE',l_cust_trx_name);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* Get Post To GL value for the transcation type */
            OPEN get_post_to_gl(exp_ar_tbl(l_grp).pn_trx_type_id,exp_ar_tbl(l_grp).pn_org_id);
            FETCH get_post_to_gl INTO l_post_to_gl;
            CLOSE get_post_to_gl;

            fnd_message.set_name ('PN','PN_EXPAR_POST');
            fnd_message.set_token ('TOK',l_post_to_gl);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* get the term name */
            OPEN get_term_name(exp_ar_tbl(l_grp).pn_term_id);
            FETCH get_term_name into l_term_name;
            CLOSE get_term_name;

            fnd_message.set_name ('PN','PN_EXPAR_PMT_TERM');
            fnd_message.set_token ('NUM',l_term_name);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* get the primary location code */
            OPEN get_loc_code(exp_ar_tbl(l_grp).location_id) ;
            FETCH get_loc_code into l_location_code;
            if get_loc_code%notfound then
               l_location_code:= null;
            end if;
            CLOSE get_loc_code;

            fnd_message.set_name ('PN','PN_XPEAM_LOC');
            fnd_message.set_token ('LOC_CODE',l_location_code);
            pnp_debug_pkg.put_log_msg(fnd_message.get);


            /* get the vat tax code */

            IF NOT pn_r12_util_pkg.is_r12 THEN
              OPEN get_tax_code(exp_ar_tbl(l_grp).pn_tax_code_id);
              FETCH get_tax_code into l_tax_code;
              CLOSE get_tax_code;
            ELSE
              l_tax_code := exp_ar_tbl(l_grp).pn_tax_classification_code;
            END IF;

            /* check for salesrep in GL Segments */
            OPEN  gl_segment_check;
            FETCH gl_segment_check INTO l_gl_seg;
            CLOSE gl_segment_check;

            fnd_message.set_name ('PN','PN_EXPAR_GL_SALES');
            fnd_message.set_token ('TOK',l_gl_seg);
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            /* Check for System Parameters in AR System Options */
            OPEN  sys_param_check;
            FETCH sys_param_check INTO l_sys_para;
            CLOSE sys_param_check;

            fnd_message.set_name ('PN','PN_EXPAR_AR_SALES');
            fnd_message.set_token ('TOK',l_sys_para);
            pnp_debug_pkg.put_log_msg(fnd_message.get);


            l_context := 'Inserting into interface lines';

            INSERT INTO ra_interface_lines_all

            (amount_includes_tax_flag           -- tax inclusive flag
            ,tax_code                           -- tax code
            ,legal_entity_id                              -- legal entity
            ,org_id                             -- org id
            ,gl_date                            -- gl date
            ,uom_code                           -- uom
            ,invoicing_rule_id                  -- invoicing rule id
            ,invoicing_rule_name                -- invoicing rule name
            ,accounting_rule_id                 -- accounting rule id
            ,accounting_rule_name               -- accounting rule name
            ,receipt_method_id                  -- payment method id
            ,receipt_method_name                -- payment method name
            ,quantity                           -- quantity invoiced
            ,unit_selling_price                 -- unit selling price
            ,primary_salesrep_id                -- primary sales person id
            ,primary_salesrep_number            -- primary sales rep number
            ,purchase_order                     -- purchase order
            ,batch_source_name                  -- Batch source name
            ,set_of_books_id                    -- set of books id
            ,line_type                          -- line type
            ,description                        -- description
            ,currency_code                      -- currency code
            ,amount                             -- amount
            ,cust_trx_type_id                   -- transaction type id
            ,cust_trx_type_name                 -- transaction type name
            ,term_id                            -- payment term id
            ,term_name                          -- payment term name
            ,conversion_type
            ,conversion_rate
            ,conversion_date
            ,interface_line_context
            ,interface_line_attribute1
            ,interface_line_attribute2
            ,interface_line_attribute3
            ,interface_line_attribute4
            ,interface_line_attribute5
            ,interface_line_attribute6
            ,interface_line_attribute7
            ,interface_line_attribute8
            ,interface_line_attribute9
            ,interface_line_attribute10
            ,orig_system_bill_customer_id       -- bill to customer id
            ,orig_system_bill_address_id        -- bill to customer site address
            ,orig_system_ship_customer_id       -- ship to customer id
            ,orig_system_ship_address_id        -- ship to customer site address
            ,trx_date                           -- transaction date
            ,rule_start_date
            )
            VALUES
            (exp_ar_tbl(l_grp).pn_tax_included
            ,l_tax_code
            ,exp_ar_tbl(l_grp).pn_legal_entity_id
            ,exp_ar_tbl(l_grp).pn_org_id
            ,exp_ar_tbl(l_grp).gl_date
            ,'EA'
            ,exp_ar_tbl(l_grp).pn_inv_rule_id
            ,l_inv_rule_name
            ,exp_ar_tbl(l_grp).pn_account_rule_id
            ,l_acc_rule_name
            ,exp_ar_tbl(l_grp).pn_pay_method_id
            ,l_pay_method_name
            ,1
            ,round(exp_ar_tbl(l_grp).pn_export_currency_amount,l_precision)
            ,exp_ar_tbl(l_grp).pn_salesrep_id
            ,l_salesrep_number
            ,exp_ar_tbl(l_grp).pn_po_number
            ,l_batch_name
            ,pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
              pn_mo_cache_utils.get_current_org_id)
            ,'LINE'
            ,l_desc
            ,exp_ar_tbl(l_grp).pn_export_currency_code
            ,round(exp_ar_tbl(l_grp).pn_export_currency_amount,l_precision)
            ,exp_ar_tbl(l_grp).pn_trx_type_id
            ,l_cust_trx_name
            ,exp_ar_tbl(l_grp).pn_term_id
            ,l_term_name
            ,exp_ar_tbl(l_grp).conv_rate_type
            ,exp_ar_tbl(l_grp).conv_rate
            ,exp_ar_tbl(l_grp).pn_accounted_date
            ,'Property-Projects'
            ,SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num
                     , 1
                     , 30 - LENGTHB(' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)))
                     || ' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)
            ,nvl(SUBSTRB(l_location_code,1,30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr3, 1, 30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr4, 1, 30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr5, 1, 30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr6, 1, 30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr7, 1, 30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_purpose, 1,30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_type, 1, 30),'N/A')
            ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num, 1, 30),'N/A')
            ,exp_ar_tbl(l_grp).pn_customer_id
            ,exp_ar_tbl(l_grp).pn_customer_site_use_id
            ,exp_ar_tbl(l_grp).pn_customer_id
            ,exp_ar_tbl(l_grp).pn_cust_ship_site_id
            ,exp_ar_tbl(l_grp).transaction_date
            ,l_rule_start_date
            );

            /* Inserting data in RA_INTERFACE_SALESCREDITS */
            IF exp_ar_tbl(l_grp).pn_salesrep_id IS NOT NULL
               AND (l_gl_seg   = 'Y'
               OR   l_sys_para = 'Y'
               OR   l_sal_cred = 'Y' ) THEN

              INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
              (
               salesrep_id
              ,salesrep_number
              ,sales_credit_type_id
              ,sales_credit_percent_split
              ,org_id
              ,interface_line_context
              ,interface_line_attribute1
              ,interface_line_attribute2
              ,interface_line_attribute3
              ,interface_line_attribute4
              ,interface_line_attribute5
              ,interface_line_attribute6
              ,interface_line_attribute7
              ,interface_line_attribute8
              ,interface_line_attribute9
              ,interface_line_attribute10
              ,created_by
              ,creation_date
              ,last_updated_by
              ,last_update_date
              ,last_update_login
              )
              VALUES
              (
               exp_ar_tbl(l_grp).pn_salesrep_id
              ,l_salesrep_number
              ,l_sales_credit_id
              ,100
              ,exp_ar_tbl(l_grp).pn_org_id
              ,'Property-Projects'
              ,SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num
                       , 1
                       , 30 - LENGTHB(' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)))
                       || ' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)
              ,nvl(SUBSTRB(l_location_code,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr3,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr4,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr5,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr6,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr7,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_purpose,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_type,1,30),'N/A')
              ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num,1,30),'N/A')
              ,l_last_updated_by
              ,sysdate
              ,l_last_updated_by
              ,sysdate
              ,l_last_update_login
              );


            END IF;

            /* Insert into Distributions for REC acount */
            /* This has to be done only once for the grouped items */
            IF l_rec_insert_flag THEN

              l_context := 'Inserting into Distributions for REC acount for this group';
              pnp_debug_pkg.log(l_context ||' : '|| exp_ar_tbl(l_grp).rec_account);

              INSERT INTO ra_interface_distributions_all
              (account_class
              ,percent
              ,amount
              ,code_combination_id
              ,created_by
              ,creation_date
              ,last_updated_by
              ,last_update_date
              ,last_update_login
              ,org_id
              ,interface_line_context
              ,interface_line_attribute1
              ,interface_line_attribute2
              ,interface_line_attribute3
              ,interface_line_attribute4
              ,interface_line_attribute5
              ,interface_line_attribute6
              ,interface_line_attribute7
              ,interface_line_attribute8
              ,interface_line_attribute9
              ,interface_line_attribute10
              )
              VALUES
               ('REC'
               ,100
               ,0
               ,exp_ar_tbl(l_grp).rec_account
               ,l_last_updated_by
               ,sysdate
               ,l_last_updated_by
               ,sysdate
               ,l_last_update_login
               ,exp_ar_tbl(l_grp).pn_org_id
               ,'Property-Projects'
               ,SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num
                        , 1
                        , 30 - LENGTHB(' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)))
                        || ' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)
               ,nvl(SUBSTRB(l_location_code,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr3,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr4,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr5,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr6,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr7,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_purpose,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_type,1,30),'N/A')
               ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num,1,30),'N/A')
               );
               l_context := 'Inserted into Distributions for REC acount';
               pnp_debug_pkg.log(l_context);
               l_rec_insert_flag := FALSE;

            END IF; -- if REC has not been inserted yet

            l_context := 'Getting Revenue amt.';
            pnp_debug_pkg.log('Getting Revenue Amount');

            fnd_message.set_name ('PN','PN_EXPAR_REV_AMT');
            fnd_message.set_token ('AMT',to_char(round(exp_ar_tbl(l_grp).pn_export_currency_amount,l_precision)));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            l_total_rev_amt := 0;
            l_total_rev_percent := 0;

            FOR acnt_rec IN get_dist(exp_ar_tbl(l_grp).pn_payment_term_id)
            LOOP

               IF acnt_rec.account_class = 'REV' THEN

                  l_acnt_cls := 'REV';

                  IF (nvl(exp_ar_tbl(l_grp).normalize,'N') = 'N' and
                     (exp_ar_tbl(l_grp).pn_inv_rule_id IS NOT NULL OR exp_ar_tbl(l_grp).pn_account_rule_id IS NOT NULL
                      OR l_rev_acc_alloc_rule = 'Percent')) THEN

                      l_percent  := acnt_rec.percentage;
                      l_amt      := null;

                  ELSE

                     l_percent  := null;
                     l_amt      := round((exp_ar_tbl(l_grp).pn_export_currency_amount * acnt_rec.percentage)/100,l_precision);
                     l_total_rev_amt := l_total_rev_amt + l_amt;
                     l_total_rev_percent := l_total_rev_percent + acnt_rec.percentage;

                     IF l_total_rev_percent = 100 then

                        l_diff_amt := l_total_rev_amt - exp_ar_tbl(l_grp).pn_export_currency_amount;
                        l_amt := l_amt - l_diff_amt;

                     END IF;

                  END IF;

                  fnd_message.set_name ('PN','PN_EXPAR_REV_AMT_DIST');
                  fnd_message.set_token ('NUM',to_char(round(l_amt,l_precision)));
                  pnp_debug_pkg.put_log_msg(fnd_message.get);

                  fnd_message.set_name ('PN','PN_EXPAR_REV_PCT_DIST');
                  fnd_message.set_token ('PCT',to_char(round(l_percent,2)));
                  pnp_debug_pkg.put_log_msg(fnd_message.get);

               ELSIF acnt_rec.account_class = 'UNEARN'   THEN

                  l_acnt_cls := 'REV';
                  IF exp_ar_tbl(l_grp).pn_inv_rule_id IS NOT NULL OR exp_ar_tbl(l_grp).pn_account_rule_id IS NOT NULL
                     OR l_rev_acc_alloc_rule = 'Percent' THEN

                     l_percent  := acnt_rec.percentage;
                     l_amt      := null;

                  ELSIF  nvl(exp_ar_tbl(l_grp).normalize,'N') = 'Y' then
                     l_percent  := 100;
                     l_amt      := round(exp_ar_tbl(l_grp).PN_EXPORT_CURRENCY_AMOUNT,l_precision);

                  ELSE
                     l_percent  := null;
                     l_amt      := round((exp_ar_tbl(l_grp).PN_EXPORT_CURRENCY_AMOUNT),l_precision);

                  END IF;

                  fnd_message.set_name ('PN','PN_EXPAR_ACR_AMT_DIST');
                  fnd_message.set_token ('NUM',to_char(round(l_amt,l_precision)));
                  pnp_debug_pkg.put_log_msg(fnd_message.get);

                  fnd_message.set_name ('PN','PN_EXPAR_ACR_PCT_DIST');
                  fnd_message.set_token ('PCT',to_char(round(l_percent,2)));
                  pnp_debug_pkg.put_log_msg(fnd_message.get);

               END IF;

               IF (acnt_rec.account_class = 'UNEARN'  and
                  NVL(exp_ar_tbl(l_grp).NORMALIZE,'N') = 'Y' and
                  NVL(exp_ar_tbl(l_grp).send_entries,'Y') = 'Y') OR
                  (acnt_rec.account_class = 'REV' AND
                  (NVL(exp_ar_tbl(l_grp).NORMALIZE,'N') <> 'Y' OR
                  (NVL(exp_ar_tbl(l_grp).NORMALIZE,'N') = 'Y'
                  AND nvl(exp_ar_tbl(l_grp).send_entries,'Y') = 'N'))) THEN

                  pnp_debug_pkg.log('Inserting into distributions for account types of REV and UNEARN');
                  l_context := 'Inserting into Distributions for account types of REV and UNEARN';

                  INSERT INTO ra_interface_distributions_all
                   (account_class
                   ,percent
                   ,amount
                   ,code_combination_id
                   ,created_by
                   ,creation_date
                   ,last_updated_by
                   ,last_update_date
                   ,last_update_login
                   ,org_id
                   ,interface_line_context
                   ,interface_line_attribute1
                   ,interface_line_attribute2
                   ,interface_line_attribute3
                   ,interface_line_attribute4
                   ,interface_line_attribute5
                   ,interface_line_attribute6
                   ,interface_line_attribute7
                   ,interface_line_attribute8
                   ,interface_line_attribute9
                   ,interface_line_attribute10
                   )
                   VALUES
                  (l_acnt_cls
                  ,l_percent
                  ,round(l_amt,l_precision)
                  ,acnt_rec.account_id
                  ,l_last_updated_by
                  ,sysdate
                  ,l_last_updated_by
                  ,sysdate
                  ,l_last_update_login
                  ,exp_ar_tbl(l_grp).pn_org_id
                  ,'Property-Projects'
                  ,SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num
                           , 1
                           , 30 - LENGTHB(' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)))
                           || ' - ' ||to_char(exp_ar_tbl(l_grp).pn_payment_item_id)
                  ,nvl(SUBSTRB(l_location_code,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr3,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr4,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr5,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr6,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_proj_attr7,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_purpose,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).payment_type,1,30),'N/A')
                  ,nvl(SUBSTRB(exp_ar_tbl(l_grp).pn_lease_num,1,30),'N/A')
                  );

                 pnp_debug_pkg.log('Inserted into distributions for account types of REV and UNEARN');
               END IF;

            END LOOP;

            l_context := 'Updating Payment Items';
            pnp_debug_pkg.log('Updating payment items for payment item id : ' ||
                               to_char(exp_ar_tbl(l_grp).pn_payment_item_id) );

            UPDATE PN_PAYMENT_ITEMS_ALL
            SET    transferred_to_ar_flag = 'Y' ,
                   ar_ref_code            = exp_ar_tbl(l_grp).pn_payment_item_id,
                   last_updated_by        = l_last_updated_by,
                   last_update_login      = l_last_update_login,
                   last_update_date       = l_last_update_date ,
                   export_group_id        = p_groupId
            WHERE  payment_item_id        = exp_ar_tbl(l_grp).pn_payment_item_id;

            IF (SQL%NOTFOUND) then
              pnp_debug_pkg.log('Could not update row for Payment_Item_Id = ' ||
                                 exp_ar_tbl(l_grp).Pn_Payment_Item_Id) ;
              fnd_message.set_name('PN', 'PN_TRANSFER_TO_AR_FLAG_NOT_SET');
              errbuf  := fnd_message.get;
              rollback;
              retcode := 2;
              return;
            END IF;


            IF ( exp_ar_tbl(l_grp).PN_Payment_Schedule_Id <> l_Prior_Payment_Schedule_Id ) THEN

              l_Prior_Payment_Schedule_Id  :=  exp_ar_tbl(l_grp).PN_Payment_Schedule_Id;
              l_context := 'Updating Payment Schedules';

              pnp_debug_pkg.log('Updating payment schedules for payment sch id : ' ||
                                 to_char(exp_ar_tbl(l_grp).PN_Payment_Schedule_Id) );


              UPDATE PN_PAYMENT_SCHEDULES_ALL
              SET    Transferred_By_User_Id  = l_last_updated_by,
                     Transfer_Date           = l_last_update_date
              WHERE  Payment_Schedule_Id     = exp_ar_tbl(l_grp).PN_Payment_Schedule_Id;

              IF (SQL%NOTFOUND) then
                pnp_debug_pkg.log('Could not update row for Payment_Schedule_Id = '
                                          || exp_ar_tbl(l_grp).PN_Payment_Schedule_Id) ;
                fnd_message.set_name('PN', 'PN_TRANSFER_TO_AR_INFO_NOT_SET');
                errbuf  := fnd_message.get;
                rollback;
                retcode := 2;
                return;
              END IF;
            END IF;

            s_count := s_count + 1;

          END LOOP;  --  Finished inserting a Group

          /* Set the l_start and l_next accordingly */
          l_item_prcsed := l_next - 1;
          l_start := l_next;
          l_next  := l_next + 1;

        END IF; -- proceed if REC accounts are valid

      END IF;  -- Group processed!!

    END LOOP;  -- End loop for main WHILE

    exp_ar_tbl.DELETE;
    COMMIT;

    pnp_debug_pkg.put_log_msg('
================================================================================');

    fnd_message.set_name ('PN','PN_EXPAR_PROC_SUC');
    fnd_message.set_token ('NUM',S_Count);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    fnd_message.set_name ('PN','PN_EXPAR_PROC_FAIL');
    fnd_message.set_token ('NUM',E_Count);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    fnd_message.set_name ('PN','PN_EXPAR_PROC_TOT');
    fnd_message.set_token ('NUM',T_Count);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    pnp_debug_pkg.put_log_msg('
================================================================================');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    pnp_debug_pkg.log('NO_DATA_FOUND: ' || l_context);
    raise;

  WHEN OTHERS THEN
    pnp_debug_pkg.log(substrb('OTHERS: ' || l_context,1,244));
    fnd_message.set_name('PN', 'PN_TRANSFER_TO_AR_PROBLEM');
    Errbuf  := substrb(SQLERRM,1,244);
    Retcode := 2;
    rollback;
    raise;

END EXP_TO_AR_GRP;

/*-----------------------------------------------------------------------------
Description:
   Call this Procedure if the Default Grouping is specified
   at the Batch Source Name level.
   This means that we need to have the same old default
   behaviour when the grouping rule is default one

HISTORY:
-- 03-DEC-03 atuppad  o Created
-- 20-AUG-04 kkhegde  o Bug 3836127 - truncated location code to 30 characters
                        before inserting into interface_line_attribute2
-- 22-NOV-04 kkhegde  o Bug 3751438 - fixed the validation for distributions
-- 22-DEC-04 Kiran    o Fix for 3751438 - corrected it for bug # 4083036
-- 10-MAR-05 piagrawa o Bug #4231051 - Truncated the attribute values to 30
--                      characters before inserting into ra_interface_lines,
--                      ra_interface_salescredits and
--                      ra_interface_distributions tables
-- 12-SEP-05 Parag    o Bug #4284035 Modified insert statement to include org_id
-- 11-OCT-05 pikhar   o Bug 4652946 - Added trunc to pi.accounted_date in
--                      Q_Billitem
-- 28-OCT-05 sdmahesh o ATG mandated changes for SQL literals
-- 28-NOV-05 sdmahesh o Passed org_id to GET_START_DATE,check_conversion_type
-- 24-MAR-06 Hareesha o Bug 5116270 Modified get_salesrep_number to pass
--                      org_id as parameter.
-- 07-AUG-06 Hareesha o Bug #5405883 Inserted schedule_date as rule_start_date
--                      into ra_interface_lines_all instead of rule_gl_date.
-----------------------------------------------------------------------------*/

Procedure EXP_TO_AR_NO_GRP (
  errbuf                IN OUT NOCOPY     VARCHAR2
  ,retcode               IN OUT NOCOPY    VARCHAR2
  ,p_groupId                              VARCHAR2
  ,p_lease_num_low                        VARCHAR2
  ,p_lease_num_high                       VARCHAR2
  ,p_sch_dt_low                           VARCHAR2
  ,p_sch_dt_high                          VARCHAR2
  ,p_due_dt_low                           VARCHAR2
  ,p_due_dt_high                          VARCHAR2
  ,p_pay_prps_code                        VARCHAR2
  ,p_prd_name                             VARCHAR2
  ,p_amt_low                              NUMBER
  ,p_amt_high                             NUMBER
  ,p_customer_id                          NUMBER
  ,p_grp_param                            VARCHAR2
)
IS
   v_pn_lease_num                     PN_LEASES.lease_num%TYPE;
   v_pn_lease_id                      PN_LEASES.lease_id%TYPE;
   v_pn_period_name                   PN_PAYMENT_SCHEDULES.period_name%TYPE;
   v_pn_code_combination_id           PN_PAYMENT_TERMS.code_combination_id%TYPE;
   v_pn_cust_ship_site_id             PN_PAYMENT_TERMS.cust_ship_site_id%TYPE;
   v_pn_tax_code_id                   PN_PAYMENT_TERMS.tax_code_id%TYPE;
   v_pn_tcc                           PN_PAYMENT_TERMS.tax_classification_code%TYPE;
   v_pn_le                            PN_PAYMENT_TERMS.legal_entity_id%TYPE;
   v_pn_inv_rule_id                   PN_PAYMENT_TERMS.inv_rule_id%TYPE;
   v_pn_account_rule_id               PN_PAYMENT_TERMS.account_rule_id%TYPE;
   v_pn_term_id                       PN_PAYMENT_TERMS.ap_ar_term_id%TYPE;
   v_pn_trx_type_id                   PN_PAYMENT_TERMS.cust_trx_type_id%TYPE;
   v_pn_pay_method_id                 PN_PAYMENT_TERMS.receipt_method_id%TYPE;
   v_pn_po_number                     PN_PAYMENT_TERMS.cust_po_number%TYPE;
   v_pn_tax_included                  PN_PAYMENT_TERMS.tax_included%TYPE;
   v_pn_salesrep_id                   PN_PAYMENT_TERMS.salesrep_id%TYPE;
   v_pn_proj_attr_catg                PN_PAYMENT_TERMS.project_attribute_category%TYPE;
   v_pn_proj_attr1                    PN_PAYMENT_TERMS.project_attribute1%TYPE;
   v_pn_proj_attr2                    PN_PAYMENT_TERMS.project_attribute2%TYPE;
   v_pn_proj_attr3                    PN_PAYMENT_TERMS.project_attribute3%TYPE;
   v_pn_proj_attr4                    PN_PAYMENT_TERMS.project_attribute4%TYPE;
   v_pn_proj_attr5                    PN_PAYMENT_TERMS.project_attribute5%TYPE;
   v_pn_proj_attr6                    PN_PAYMENT_TERMS.project_attribute6%TYPE;
   v_pn_proj_attr7                    PN_PAYMENT_TERMS.project_attribute7%TYPE;
   v_pn_org_id                        PN_PAYMENT_TERMS.org_id%TYPE;
   v_pn_description                   PN_PAYMENT_TERMS.payment_purpose_code%TYPE;
   v_transaction_date                 PN_PAYMENT_ITEMS.due_date%TYPE;
   v_normalize                        PN_PAYMENT_TERMS.normalize%TYPE;
   v_pn_payment_item_id               PN_PAYMENT_ITEMS.payment_item_id%TYPE;
   v_pn_payment_term_id               PN_PAYMENT_ITEMS.payment_term_id%TYPE;
   v_pn_export_currency_code          PN_PAYMENT_ITEMS.export_currency_code%TYPE;
   v_pn_export_currency_amount        PN_PAYMENT_ITEMS.export_currency_amount%TYPE;
   v_pn_customer_id                   PN_PAYMENT_ITEMS.customer_id%TYPE ;
   v_pn_customer_site_use_id          PN_PAYMENT_ITEMS.customer_site_use_id%TYPE;
   v_pn_payment_schedule_id           PN_PAYMENT_ITEMS.payment_schedule_id%TYPE;
   v_pn_accounted_date                PN_PAYMENT_ITEMS.accounted_date%TYPE;
   v_pn_rate                          PN_PAYMENT_ITEMS.rate%TYPE;
   l_acnt_cls                         PN_DISTRIBUTIONS.account_class%TYPE;
   l_percent                          PN_DISTRIBUTIONS.percentage%TYPE;
   l_location_code                    PN_LOCATIONS.location_code%TYPE;
   l_inv_rule_name                    RA_RULES.name%TYPE;
   l_inv_rule_type                    RA_RULES.type%TYPE;
   l_inv_rule_freq                    RA_RULES.frequency%TYPE;
   l_acc_rule_name                    RA_RULES.name%TYPE;
   l_acc_rule_type                    RA_RULES.type%TYPE;
   l_acc_rule_freq                    RA_RULES.frequency%TYPE;
   l_desc                             RA_INTERFACE_LINES.description%TYPE;
   l_salesrep_number                  RA_SALESREPS.salesrep_number%TYPE;
   l_sales_credit_id                  RA_SALESREPS.sales_credit_type_id%TYPE;
   l_cust_trx_name                    RA_CUST_TRX_TYPES.name%TYPE;
   l_term_name                        RA_TERMS.name%TYPE;
   l_pay_method_name                  AR_RECEIPT_METHODS.name%TYPE;
   l_amt                              NUMBER;
   l_prior_payment_schedule_id        NUMBER   := -999;
   l_last_updated_by                  NUMBER := FND_GLOBAL.USER_ID;
   l_last_update_login                NUMBER := FND_GLOBAL.LOGIN_ID;
   l_last_update_date                 DATE := sysdate;
   l_start_date                       RA_CUST_TRX_LINE_GL_DIST.gl_date%TYPE ;
   l_context                          VARCHAR2(2000);
   l_batch_name                       RA_BATCH_SOURCES.name%TYPE;
   l_precision                        NUMBER;
   l_ext_precision                    NUMBER;
   l_min_acct_unit                    NUMBER;
   t_count                            NUMBER := 0;
   e_count                            NUMBER := 0;
   s_count                            NUMBER := 0;
   l_tax_code                         AR_VAT_TAX.tax_code%TYPE;
   l_rev_acc_alloc_rule               RA_BATCH_SOURCES.rev_acc_allocation_rule%TYPE;
   l_rev_flag                         VARCHAR2(1);
   l_rec_flag                         VARCHAR2(1);
   l_ast_flag                         VARCHAR2(1);
   l_rec_cnt                          NUMBER;
   l_prof_optn                        VARCHAR2(30);
   l_err_msg1                         VARCHAR2(2000);
   l_err_msg2                         VARCHAR2(2000);
   l_err_msg3                         VARCHAR2(2000);
   l_err_msg4                         VARCHAR2(2000);
   l_sys_para                         VARCHAR2(1);
   l_gl_seg                           VARCHAR2(1);
   l_sal_cred                         VARCHAR2(1);
   l_total_rev_amt                    NUMBER := 0;
   l_total_rev_percent                NUMBER := 0;
   l_diff_amt                         NUMBER := 0;
   l_set_of_books_id                  NUMBER := to_number(pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
                                                          pn_mo_cache_utils.get_current_org_id));
   l_func_curr_code                   GL_SETS_OF_BOOKS.currency_code%TYPE;
   l_conv_rate_type                   PN_CURRENCIES.conversion_type%TYPE;
   l_conv_rate                        PN_PAYMENT_ITEMS.rate%TYPE;
   v_location_id                      PN_LOCATIONS.location_id%TYPE;
   l_send_flag                        PN_LEASE_DETAILS_ALL.send_entries%TYPE := 'Y';
   l_lease_id                         NUMBER := 0;
   v_pur_code                         PN_PAYMENT_TERMS.payment_purpose_code%TYPE;
   v_pur_type_code                    PN_PAYMENT_TERMS.payment_term_type_code%TYPE;
   l_post_to_gl                       RA_CUST_TRX_TYPES_ALL.post_to_gl%TYPE;
   l_derive_date_flag                 RA_BATCH_SOURCES.derive_date_flag%TYPE;
   l_rule_start_date                  RA_INTERFACE_LINES.rule_start_date%TYPE := NULL;
   l_rows_nogrp                       INTEGER;
   l_count_nogrp                      INTEGER;
   v_pn_payment_term_id1              PN_PAYMENT_ITEMS_ALL.payment_term_id%TYPE;
   v_pn_le_id1                        PN_PAYMENT_TERMS_ALL.legal_entity_id%TYPE;
   v_pn_customer_id1                  PN_PAYMENT_ITEMS_ALL.customer_id%TYPE;
   v_pn_trx_type_id1                   PN_PAYMENT_TERMS.cust_trx_type_id%TYPE;
   v_pn_org_id1                       PN_PAYMENT_TERMS_ALL.org_id%TYPE;
   v_schedule_date                    PN_PAYMENT_SCHEDULES_ALL.schedule_date%TYPE;

   l_rows_select_nogrp               NUMBER;
   l_count_select_nogrp              NUMBER;
   TYPE le_ar_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   TYPE term_ar_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   le_ar_tbl                       le_ar_tbl_type;
   term_ar_tbl                     term_ar_tbl_type;
   l_index                         NUMBER ;


BEGIN

    fnd_message.set_name ('PN','PN_EXPAR_PMT_MSG');
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    l_context := 'Forming the query statement';
    pnp_debug_pkg.log('Forming the query statement');


    l_context := 'Getting the Batch Source Name';
    pnp_debug_pkg.log('Getting the Batch Source Name');

    /* get the batch source name */
    OPEN get_batch_source_name;
    FETCH get_batch_source_name into l_batch_name, l_rev_acc_alloc_rule,
                                     l_sal_cred, l_derive_date_flag;
    CLOSE get_batch_source_name;

    fnd_message.set_name ('PN','PN_EXPAR_BTCH_SRC_NAME');
    fnd_message.set_token ('NAME',l_batch_name);
    pnp_debug_pkg.put_log_msg(fnd_message.get);

    Q_select_nogrp := 'SELECT payment_term_id,
                              customer_id,
                              cust_trx_type_id,
                              org_id
                       FROM ('||Q_Billitem_nogrp||')
                       WHERE legal_entity_id IS NULL';
   g_cursor_select_nogrp := dbms_sql.open_cursor;
   dbms_sql.parse(g_cursor_select_nogrp,Q_select_nogrp,dbms_sql.native);
   do_binding (g_cursor_select_nogrp
              ,p_lease_num_low
              ,p_lease_num_high
              ,p_sch_dt_low
              ,p_sch_dt_high
              ,p_due_dt_low
              ,p_due_dt_high
              ,p_pay_prps_code
              ,p_prd_name
              ,p_amt_low
              ,p_amt_high
              ,p_customer_id
              ,p_grp_param
              );


    l_index := 1;
    le_ar_tbl.delete;
    term_ar_tbl.delete;
    dbms_sql.define_column (g_cursor_select_nogrp,1,v_pn_payment_term_id1);
    dbms_sql.define_column (g_cursor_select_nogrp,2,v_pn_customer_id1);
    dbms_sql.define_column (g_cursor_select_nogrp,3,v_pn_trx_type_id1);
    dbms_sql.define_column (g_cursor_select_nogrp,4,v_pn_org_id1);
    l_rows_select_nogrp   := dbms_sql.execute(g_cursor_select_nogrp);

    LOOP
      BEGIN
        l_count_select_nogrp := dbms_sql.fetch_rows(g_cursor_select_nogrp);
        EXIT WHEN l_count_select_nogrp <> 1;
        dbms_sql.column_value (g_cursor_select_nogrp,1,term_ar_tbl(l_index));
        dbms_sql.column_value (g_cursor_select_nogrp,2,v_pn_customer_id1);
        dbms_sql.column_value (g_cursor_select_nogrp,3,v_pn_trx_type_id1);
        dbms_sql.column_value (g_cursor_select_nogrp,4,v_pn_org_id1);
        le_ar_tbl(l_index) := pn_r12_util_pkg.get_le_for_ar(v_pn_customer_id1,
                                                            v_pn_trx_type_id1,
                                                            v_pn_org_id1);
        l_index := l_index+1;
      END;
    END LOOP;

    FORALL i IN term_ar_tbl.FIRST..term_ar_tbl.LAST
      UPDATE pn_payment_terms_all
      SET legal_entity_id = le_ar_tbl(i)
      WHERE payment_term_id = term_ar_tbl(i);

    IF dbms_sql.is_open (g_cursor_select_nogrp) THEN
        dbms_sql.close_cursor (g_cursor_select_nogrp);
    END IF;

    g_cursor_nogrp := dbms_sql.open_cursor;
    dbms_sql.parse(g_cursor_nogrp, Q_Billitem_nogrp, dbms_sql.native);
    do_binding (g_cursor_nogrp
                ,p_lease_num_low
                ,p_lease_num_high
                ,p_sch_dt_low
                ,p_sch_dt_high
                ,p_due_dt_low
                ,p_due_dt_high
                ,p_pay_prps_code
                ,p_prd_name
                ,p_amt_low
                ,p_amt_high
                ,p_customer_id
                ,p_grp_param
                );
    l_context := 'Opening the cursor';

    /*OPEN c_billitem for q_billitem ;*/
    dbms_sql.define_column (g_cursor_nogrp, 1, v_pn_payment_item_id);
    dbms_sql.define_column (g_cursor_nogrp, 2, v_pn_payment_term_id);
    dbms_sql.define_column (g_cursor_nogrp, 3, v_pn_export_currency_code,15);
    dbms_sql.define_column (g_cursor_nogrp, 4, v_pn_export_currency_amount);
    dbms_sql.define_column (g_cursor_nogrp, 5, v_pn_customer_id);
    dbms_sql.define_column (g_cursor_nogrp, 6, v_pn_customer_site_use_id);
    dbms_sql.define_column (g_cursor_nogrp, 7, v_pn_cust_ship_site_id);
    dbms_sql.define_column (g_cursor_nogrp, 8, v_pn_tax_code_id);
    dbms_sql.define_column (g_cursor_nogrp, 9, v_pn_tcc,30);
    dbms_sql.define_column (g_cursor_nogrp, 10,v_pn_le);
    dbms_sql.define_column (g_cursor_nogrp, 11,v_pn_inv_rule_id);
    dbms_sql.define_column (g_cursor_nogrp, 12,v_pn_account_rule_id);
    dbms_sql.define_column (g_cursor_nogrp, 13,v_pn_term_id);
    dbms_sql.define_column (g_cursor_nogrp, 14,v_pn_trx_type_id);
    dbms_sql.define_column (g_cursor_nogrp, 15,v_pn_pay_method_id);
    dbms_sql.define_column (g_cursor_nogrp, 16,v_pn_po_number,50);
    dbms_sql.define_column (g_cursor_nogrp, 17,v_pn_tax_included,1);
    dbms_sql.define_column (g_cursor_nogrp, 18,v_pn_salesrep_id);
    dbms_sql.define_column (g_cursor_nogrp, 19,v_pn_proj_attr_catg,30);
    dbms_sql.define_column (g_cursor_nogrp, 20,v_pn_proj_attr3,150);
    dbms_sql.define_column (g_cursor_nogrp, 21,v_pn_proj_attr4,150);
    dbms_sql.define_column (g_cursor_nogrp, 22,v_pn_proj_attr5,150);
    dbms_sql.define_column (g_cursor_nogrp, 23,v_pn_proj_attr6,150);
    dbms_sql.define_column (g_cursor_nogrp, 24,v_pn_proj_attr7,150);
    dbms_sql.define_column (g_cursor_nogrp, 25,v_pn_org_id);
    dbms_sql.define_column (g_cursor_nogrp, 26,v_pn_lease_num,30);
    dbms_sql.define_column (g_cursor_nogrp, 27,v_pn_payment_schedule_id);
    dbms_sql.define_column (g_cursor_nogrp, 28,v_pn_period_name,15);
    dbms_sql.define_column (g_cursor_nogrp, 29,v_pn_description,30);
    dbms_sql.define_column (g_cursor_nogrp, 30,v_pn_lease_id);
    dbms_sql.define_column (g_cursor_nogrp, 31,v_transaction_date);
    dbms_sql.define_column (g_cursor_nogrp, 32,v_normalize,1);
    dbms_sql.define_column (g_cursor_nogrp, 33,v_pn_accounted_date);
    dbms_sql.define_column (g_cursor_nogrp, 34,v_pn_rate);
    dbms_sql.define_column (g_cursor_nogrp, 35,v_location_id);
    dbms_sql.define_column (g_cursor_nogrp, 36,v_pur_code,30);
    dbms_sql.define_column (g_cursor_nogrp, 37,v_pur_type_code,30);
    dbms_sql.define_column (g_cursor_nogrp, 38, v_schedule_date);


    l_rows_nogrp   := dbms_sql.execute(g_cursor_nogrp);

    LOOP /* looping for c_billitem */

      BEGIN

        l_context := 'Fetching from the cursor';

        l_count_nogrp := dbms_sql.fetch_rows(g_cursor_nogrp);
        EXIT WHEN l_count_nogrp <> 1;
        dbms_sql.column_value (g_cursor_nogrp, 1, v_pn_payment_item_id);
        dbms_sql.column_value (g_cursor_nogrp, 2, v_pn_payment_term_id);
        dbms_sql.column_value (g_cursor_nogrp, 3, v_pn_export_currency_code);
        dbms_sql.column_value (g_cursor_nogrp, 4, v_pn_export_currency_amount);
        dbms_sql.column_value (g_cursor_nogrp, 5, v_pn_customer_id);
        dbms_sql.column_value (g_cursor_nogrp, 6, v_pn_customer_site_use_id);
        dbms_sql.column_value (g_cursor_nogrp, 7, v_pn_cust_ship_site_id);
        dbms_sql.column_value (g_cursor_nogrp, 8, v_pn_tax_code_id);
        dbms_sql.column_value (g_cursor_nogrp, 9, v_pn_tcc);
        dbms_sql.column_value (g_cursor_nogrp, 10,v_pn_le);
        dbms_sql.column_value (g_cursor_nogrp, 11,v_pn_inv_rule_id);
        dbms_sql.column_value (g_cursor_nogrp, 12,v_pn_account_rule_id);
        dbms_sql.column_value (g_cursor_nogrp, 13,v_pn_term_id);
        dbms_sql.column_value (g_cursor_nogrp, 14,v_pn_trx_type_id);
        dbms_sql.column_value (g_cursor_nogrp, 15,v_pn_pay_method_id);
        dbms_sql.column_value (g_cursor_nogrp, 16,v_pn_po_number);
        dbms_sql.column_value (g_cursor_nogrp, 17,v_pn_tax_included);
        dbms_sql.column_value (g_cursor_nogrp, 18,v_pn_salesrep_id);
        dbms_sql.column_value (g_cursor_nogrp, 19,v_pn_proj_attr_catg);
        dbms_sql.column_value (g_cursor_nogrp, 20,v_pn_proj_attr3);
        dbms_sql.column_value (g_cursor_nogrp, 21,v_pn_proj_attr4);
        dbms_sql.column_value (g_cursor_nogrp, 22,v_pn_proj_attr5);
        dbms_sql.column_value (g_cursor_nogrp, 23,v_pn_proj_attr6);
        dbms_sql.column_value (g_cursor_nogrp, 24,v_pn_proj_attr7);
        dbms_sql.column_value (g_cursor_nogrp, 25,v_pn_org_id);
        dbms_sql.column_value (g_cursor_nogrp, 26,v_pn_lease_num);
        dbms_sql.column_value (g_cursor_nogrp, 27,v_pn_payment_schedule_id);
        dbms_sql.column_value (g_cursor_nogrp, 28,v_pn_period_name);
        dbms_sql.column_value (g_cursor_nogrp, 29,v_pn_description);
        dbms_sql.column_value (g_cursor_nogrp, 30,v_pn_lease_id);
        dbms_sql.column_value (g_cursor_nogrp, 31,v_transaction_date);
        dbms_sql.column_value (g_cursor_nogrp, 32,v_normalize);
        dbms_sql.column_value (g_cursor_nogrp, 33,v_pn_accounted_date);
        dbms_sql.column_value (g_cursor_nogrp, 34,v_pn_rate);
        dbms_sql.column_value (g_cursor_nogrp, 35,v_location_id);
        dbms_sql.column_value (g_cursor_nogrp, 36,v_pur_code);
        dbms_sql.column_value (g_cursor_nogrp, 37,v_pur_type_code);
        dbms_sql.column_value (g_cursor_nogrp, 38,v_schedule_date);

        /* Check for Conversion Type and Conversion Rate for Currency Code */
        OPEN  get_func_curr_code(l_set_of_books_id);
        FETCH get_func_curr_code INTO l_func_curr_code;
        CLOSE get_func_curr_code;

        IF UPPER(l_func_curr_code) = UPPER(v_pn_export_currency_code) THEN
           l_conv_rate := 1;
           l_conv_rate_type := 'User';

        ELSE
           l_conv_rate_type := PNP_UTIL_FUNC.check_conversion_type(l_func_curr_code,
                                                                   pn_mo_cache_utils.get_current_org_id);
           IF UPPER(l_conv_rate_type) = 'USER' THEN
              l_conv_rate := v_pn_rate;
           ELSE
              l_conv_rate := NULL;
           END IF;
        END IF;

        fnd_message.set_name ('PN','PN_CRACC_CV_RATE');
        fnd_message.set_token ('CR',l_conv_rate);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_CRACC_CV_TYPE');
        fnd_message.set_token ('CT',l_conv_rate_type);
        pnp_debug_pkg.put_log_msg(fnd_message.get);


        /* Get send entries flag for the lease */
        IF l_lease_id <> v_pn_lease_id THEN
           OPEN  get_send_flag(v_pn_lease_id);
           FETCH get_send_flag INTO l_send_flag;
           CLOSE get_send_flag;
           l_lease_id := v_pn_lease_id;
           fnd_message.set_name ('PN','PN_EXPAR_PMT_LS');
           fnd_message.set_token ('ID',l_lease_id);
           fnd_message.set_token ('SEND',l_send_flag);
           pnp_debug_pkg.put_log_msg(fnd_message.get);

        END IF;

        l_rev_flag   := 'N';
        l_rec_flag   := 'N';
        l_ast_flag   := 'N';
        l_rec_cnt    := 0;
        l_total_rev_amt := 0;
        l_total_rev_percent := 0;
        l_prof_optn  := pn_mo_cache_utils.get_profile_value('PN_ACCOUNTING_OPTION',
                        pn_mo_cache_utils.get_current_org_id);

        FOR dist_rec IN acnt_cls_cur(v_pn_payment_term_id)
        LOOP

           IF dist_rec.account_class IN ('REV') THEN
              l_rev_flag := 'Y';
           ELSIF dist_rec.account_class IN ('REC') THEN
              l_rec_flag := 'Y';
           ELSIF dist_rec.account_class IN ('UNEARN') THEN
              l_ast_flag := 'Y';
           END IF;

           l_rec_cnt := l_rec_cnt + 1;

        END LOOP;

        t_count := t_count + 1;

        IF UPPER(l_conv_rate_type) = 'USER' AND
          l_conv_rate IS NULL THEN

          fnd_message.set_name ('PN', 'PN_CONV_RATE_REQD');
          l_err_msg4 := fnd_message.get;
          pnp_debug_pkg.put_log_msg(l_err_msg4);

          RAISE GENERIC_EXPORT_EXCEPTION;

        END IF;

        IF v_pn_term_id IS NULL OR v_pn_trx_type_id IS NULL THEN

          fnd_message.set_name ('PN', 'PN_PTRM_TRX_REQD_MSG');
          l_err_msg3 := fnd_message.get;
          pnp_debug_pkg.put_log_msg(l_err_msg3);

          RAISE GENERIC_EXPORT_EXCEPTION;

        END IF;

        IF NVL(v_normalize,'N') = 'Y' THEN

          IF (l_rev_flag <> 'Y' OR l_rec_flag <> 'Y' OR l_ast_flag <> 'Y') THEN

            fnd_message.set_name ('PN', 'PN_ALL_ACNT_DIST_MSG');
            l_err_msg1 := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_err_msg1);

            RAISE GENERIC_EXPORT_EXCEPTION;
          END IF;

        ELSIF NVL(v_normalize,'N') = 'N' THEN

          IF (l_prof_optn = 'Y' AND (l_rev_flag <> 'Y' OR l_rec_flag <> 'Y')) OR
             (l_prof_optn IN ('M', 'N') AND ((l_rev_flag = 'Y' AND l_rec_flag <> 'Y') OR
                                             (l_rev_flag <> 'Y' AND l_rec_flag = 'Y')))
          THEN

            fnd_message.set_name ('PN', 'PN_REVREC_DIST_MSG');
            l_err_msg2 := fnd_message.get;
            pnp_debug_pkg.put_log_msg(l_err_msg2);

            RAISE GENERIC_EXPORT_EXCEPTION;

          END IF;

        END IF;

        /* Default the precision to 2 */
        l_precision := 2;

        /* Get the correct precision for the currency so that the amount can be rounded off */
        fnd_currency.get_info(v_pn_export_currency_code, l_precision, l_ext_precision, l_min_acct_unit);

        /* if post to Gl is N, then do not populate gl_date in interface table */
        OPEN get_post_to_gl(v_pn_trx_type_id,v_pn_org_id);
        FETCH get_post_to_gl INTO l_post_to_gl;
        CLOSE get_post_to_gl;

        IF v_pn_inv_rule_id IS NOT NULL OR v_pn_account_rule_id IS NOT NULL
           OR NVL(l_post_to_gl,'Y') = 'N' THEN

           l_start_date := null;
        ELSE

           l_start_date := PNP_UTIL_FUNC.Get_Start_Date(v_pn_period_name,
                                                        pn_mo_cache_utils.get_current_org_id);
        END IF;

            pnp_debug_pkg.put_log_msg('
================================================================================');
            fnd_message.set_name ('PN','PN_EXPAR_PMT_PRM');
            fnd_message.set_token ('ITM_ID',v_pn_payment_item_id);
            fnd_message.set_token ('CUST_ID',TO_CHAR(v_pn_customer_id));
            fnd_message.set_token ('REC_AMT',TO_CHAR(ROUND(v_pn_export_currency_amount,l_precision)));
            fnd_message.set_token ('DATE',l_start_date);
            pnp_debug_pkg.put_log_msg('
================================================================================');

        /* Initialize the variables */
        l_desc := NULL;
        l_inv_rule_name := NULL;
        l_inv_rule_type := NULL;
        l_inv_rule_freq := NULL;
        l_acc_rule_name := NULL;
        l_acc_rule_type := NULL;
        l_acc_rule_freq := NULL;
        l_pay_method_name := NULL;
        l_salesrep_number := NULL;
        l_sales_credit_id := NULL;
        l_cust_trx_name := NULL;
        l_term_name := NULL;
        l_location_code := NULL;
        l_gl_seg := NULL;
        l_sys_para := NULL;
        l_tax_code := NULL;

        /* get the description */
        OPEN get_desc(V_PN_DESCRIPTION);
        FETCH get_desc into l_desc;
        CLOSE get_desc;

        /* get the invoicing rule name */
        OPEN get_rule_name(v_pn_inv_rule_id);
        FETCH get_rule_name into l_inv_rule_name, l_inv_rule_type, l_inv_rule_freq;
        CLOSE get_rule_name;

        fnd_message.set_name ('PN','PN_EXPAR_INV_RULE');
        fnd_message.set_token ('NAME',l_inv_rule_name);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the accounting rule name */
        OPEN get_rule_name(v_pn_account_rule_id);
        FETCH get_rule_name into l_acc_rule_name, l_acc_rule_type, l_acc_rule_freq;
        CLOSE get_rule_name;

        fnd_message.set_name ('PN','PN_EXPAR_ACC_RUL_NAME');
        fnd_message.set_token ('NAME',l_acc_rule_name);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_EXPAR_ACC_RUL_TYPE');
        fnd_message.set_token ('TYPE',l_acc_rule_type);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_EXPAR_GL_RUL_FREQ');
        fnd_message.set_token ('FREQ',l_acc_rule_freq);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        IF v_pn_account_rule_id IS NOT NULL AND
           (l_acc_rule_type <> 'A' OR
            l_acc_rule_freq <> 'SPECIFIC') AND
           NVL(l_derive_date_flag,'N') = 'Y' THEN

           l_rule_start_date := v_schedule_date;
        ELSE
           l_rule_start_date := NULL;
        END IF;

        fnd_message.set_name ('PN','PN_EXPAR_RUL_ST_DT');
        fnd_message.set_token ('DATE',l_rule_start_date);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the payment method name */
        OPEN get_receipt_name(v_pn_pay_method_id);
        FETCH get_receipt_name into l_pay_method_name;
        CLOSE get_receipt_name;

        fnd_message.set_name ('PN','PN_EXPAR_PMT_MTHD');
        fnd_message.set_token ('METHOD',l_pay_method_name);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the salesrep number */
        OPEN get_salesrep_number(v_pn_salesrep_id,v_pn_org_id);
        FETCH get_salesrep_number into l_salesrep_number,l_sales_credit_id;
        CLOSE get_salesrep_number;

        fnd_message.set_name ('PN','PN_EXPAR_SALES_REP');
        fnd_message.set_token ('NAME',l_salesrep_number);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the cust transaction type name */
        OPEN get_cust_trx_name(v_pn_trx_type_id);
        FETCH get_cust_trx_name into l_cust_trx_name;
        CLOSE get_cust_trx_name;

        fnd_message.set_name ('PN','PN_EXPAR_TRNX_TYPE');
        fnd_message.set_token ('TYPE',l_cust_trx_name);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        fnd_message.set_name ('PN','PN_EXPAR_POST');
        fnd_message.set_token ('TOK',l_post_to_gl);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the term name */
        OPEN get_term_name(v_pn_term_id);
        FETCH get_term_name into l_term_name;
        CLOSE get_term_name;

        fnd_message.set_name ('PN','PN_EXPAR_PMT_TERM');
        fnd_message.set_token ('NUM',l_term_name);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the primary location code */
        OPEN get_loc_code(v_location_id) ;
        FETCH get_loc_code into l_location_code;
        IF get_loc_code%NOTFOUND THEN
           l_location_code:= NULL;
        END IF;
        CLOSE get_loc_code;

        fnd_message.set_name ('PN','PN_EXPAR_LOC_CODE');
        fnd_message.set_token ('LOC_CODE',l_location_code);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* get the vat tax code */

        IF NOT pn_r12_util_pkg.is_r12 THEN
          OPEN get_tax_code(v_pn_tax_code_id);
          FETCH get_tax_code into l_tax_code;
          CLOSE get_tax_code;
        ELSE
          l_tax_code := v_pn_tcc;
        END IF;

        /* check for salesrep in GL Segments */
        OPEN  gl_segment_check;
        FETCH gl_segment_check INTO l_gl_seg;
        CLOSE gl_segment_check;

        fnd_message.set_name ('PN','PN_EXPAR_GL_SALES');
        fnd_message.set_token ('TOK',l_gl_seg);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        /* Check for System Parameters in AR System Options */
        OPEN  sys_param_check;
        FETCH sys_param_check INTO l_sys_para;
        CLOSE sys_param_check;

        fnd_message.set_name ('PN','PN_EXPAR_AR_SALES');
        fnd_message.set_token ('TOK',l_sys_para);
        pnp_debug_pkg.put_log_msg(fnd_message.get);

        l_context := 'Inserting into interface lines';

        INSERT INTO ra_interface_lines_all
        (  amount_includes_tax_flag   -- tax inclusive flag
          ,tax_code                   -- tax code
          ,legal_entity_id            -- legal entity id
          ,org_id                     -- org id
          ,gl_date                    -- gl date
          ,uom_code                   -- uom
          ,invoicing_rule_id          -- invoicing rule id
          ,invoicing_rule_name        -- invoicing rule name
          ,accounting_rule_id         -- accounting rule id
          ,accounting_rule_name       -- accounting rule name
          ,receipt_method_id          -- payment method id
          ,receipt_method_name        -- payment method name
          ,quantity                   -- quantity invoiced
          ,unit_selling_price         -- unit selling price
          ,primary_salesrep_id        -- primary sales person id
          ,primary_salesrep_number    -- primary sales rep number
          ,purchase_order             -- purchase order
          ,batch_source_name          -- Batch source name
          ,set_of_books_id            -- set of books id
          ,line_type                  -- line type
          ,description                -- description
          ,currency_code              -- currency code
          ,amount                     -- amount
          ,cust_trx_type_id           -- transaction type id
          ,cust_trx_type_name         -- transaction type name
          ,term_id                    -- payment term id
          ,term_name                  -- payment term name
          ,conversion_type
          ,conversion_rate
          ,conversion_date
          ,interface_line_context
          ,interface_line_attribute1
          ,interface_line_attribute2
          ,interface_line_attribute3
          ,interface_line_attribute4
          ,interface_line_attribute5
          ,interface_line_attribute6
          ,interface_line_attribute7
          ,interface_line_attribute8
          ,interface_line_attribute9
          ,interface_line_attribute10
          ,orig_system_bill_customer_id      -- bill to customer id
          ,orig_system_bill_address_id       -- bill to customer site address
          ,orig_system_ship_customer_id      -- ship to customer id
          ,orig_system_ship_address_id       -- ship to customer site address
          ,trx_date                          -- transaction date
          ,rule_start_date
        )
        VALUES
        (  v_pn_tax_included
          ,l_tax_code
          ,v_pn_le
          ,v_pn_org_id
          ,l_start_date
          ,'EA'
          ,v_pn_inv_rule_id
          ,l_inv_rule_name
          ,v_pn_account_rule_id
          ,l_acc_rule_name
          ,v_pn_pay_method_id
          ,l_pay_method_name
          ,1
          ,round(v_pn_export_currency_amount,l_precision)
          ,v_pn_salesrep_id
          ,l_salesrep_number
          ,v_pn_po_number
          ,l_batch_name
          ,pn_mo_cache_utils.get_profile_value('PN_SET_OF_BOOKS_ID',
           pn_mo_cache_utils.get_current_org_id)
          ,'LINE'
          ,l_desc
          ,v_pn_export_currency_code
          ,round(v_pn_export_currency_amount,l_precision)
          ,v_pn_trx_type_id
          , l_cust_trx_name
          ,v_pn_term_id
          ,l_term_name
          ,l_conv_rate_type
          ,l_conv_rate
          ,v_pn_accounted_date
          ,'Property-Projects'
          ,SUBSTRB(v_pn_lease_num
                   , 1
                   , 30 - LENGTHB( ' - ' ||to_char(v_pn_payment_item_id)))
                   || ' - ' ||to_char(v_pn_payment_item_id)
          ,nvl(SUBSTRB(l_location_code,1,30),'N/A')
          ,nvl(SUBSTRB(v_pn_proj_attr3,1,30),'N/A')
          ,nvl(SUBSTRB(v_pn_proj_attr4,1,30),'N/A')
          ,nvl(SUBSTRB(v_pn_proj_attr5,1,30),'N/A')
          ,nvl(SUBSTRB(v_pn_proj_attr6,1,30),'N/A')
          ,nvl(SUBSTRB(v_pn_proj_attr7,1,30),'N/A')
          ,nvl(SUBSTRB(v_pur_code,1,30),'N/A')
          ,nvl(SUBSTRB(v_pur_type_code,1,30),'N/A')
          ,nvl(SUBSTRB(v_pn_lease_num,1,30),'N/A')
          ,v_pn_customer_id
          ,v_pn_customer_site_use_id
          ,v_pn_customer_id
          ,v_pn_cust_ship_site_id
          ,v_transaction_date
          ,l_rule_start_date
        );

        /* Inserting data in RA_INTERFACE_SALESCREDITS */

        IF v_pn_salesrep_id IS NOT NULL
          AND (l_gl_seg   = 'Y'
          OR   l_sys_para = 'Y'
          OR   l_sal_cred = 'Y' ) THEN

          INSERT INTO RA_INTERFACE_SALESCREDITS_ALL
          (
            salesrep_id
           ,salesrep_number
           ,sales_credit_type_id
           ,sales_credit_percent_split
           ,interface_line_context
           ,interface_line_attribute1
           ,interface_line_attribute2
           ,interface_line_attribute3
           ,interface_line_attribute4
           ,interface_line_attribute5
           ,interface_line_attribute6
           ,interface_line_attribute7
           ,interface_line_attribute8
           ,interface_line_attribute9
           ,interface_line_attribute10
           ,created_by
           ,creation_date
           ,last_updated_by
           ,last_update_date
           ,last_update_login
           ,org_id
          )
          VALUES
          (
            v_pn_salesrep_id
           ,l_salesrep_number
           ,l_sales_credit_id
           ,100
           ,'Property-Projects'
           , SUBSTRB(v_pn_lease_num
                     , 1
                     , 30 - LENGTHB(' - ' ||to_char(v_pn_payment_item_id)))
                     || ' - ' ||to_char(v_pn_payment_item_id)
           ,NVL(SUBSTRB(l_location_code,1,30),'N/A')
           ,NVL(SUBSTRB(v_pn_proj_attr3,1,30),'N/A')
           ,NVL(SUBSTRB(v_pn_proj_attr4,1,30),'N/A')
           ,NVL(SUBSTRB(v_pn_proj_attr5,1,30),'N/A')
           ,NVL(SUBSTRB(v_pn_proj_attr6,1,30),'N/A')
           ,NVL(SUBSTRB(v_pn_proj_attr7,1,30),'N/A')
           ,NVL(SUBSTRB(v_pur_code,1,30),'N/A')
           ,NVL(SUBSTRB(v_pur_type_code,1,30),'N/A')
           ,NVL(SUBSTRB(v_pn_lease_num,1,30),'N/A')
           ,l_last_updated_by
           ,sysdate
           ,l_last_updated_by
           ,sysdate
           ,l_last_update_login
           ,v_pn_org_id
          );

        END IF;

        l_context := 'Getting Revenue amt.';
        pnp_debug_pkg.log('Getting Revenue Amount');

        fnd_message.set_name ('PN','PN_EXPAR_REV_AMT');
        fnd_message.set_token ('AMT',to_char(round(v_pn_export_currency_amount,l_precision)));
        pnp_debug_pkg.put_log_msg(fnd_message.get);


        FOR acnt_rec IN get_dist(v_pn_payment_term_id)
        LOOP

          IF acnt_rec.account_class = 'REC' THEN

            l_acnt_cls := 'REC';
            l_percent  := 100;
            l_amt      := V_PN_EXPORT_CURRENCY_AMOUNT;

            fnd_message.set_name ('PN','PN_EXPAR_BTCH_RCV_AMT');
            fnd_message.set_token ('NUM',to_char(l_amt));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

          ELSIF acnt_rec.account_class = 'REV' THEN

            l_acnt_cls := 'REV';

            IF (nvl(v_normalize,'N') = 'N' and
               (v_pn_inv_rule_id IS NOT NULL OR v_pn_account_rule_id IS NOT NULL
                OR l_rev_acc_alloc_rule = 'Percent')) THEN

              l_percent  := acnt_rec.percentage;
              l_amt      := null;

            ELSE

              l_percent  := null;

              l_amt      := round((v_pn_export_currency_amount * acnt_rec.percentage)/100,l_precision);


              l_total_rev_amt := l_total_rev_amt + l_amt;
              l_total_rev_percent := l_total_rev_percent + acnt_rec.percentage;

              if l_total_rev_percent = 100 then

                l_diff_amt := l_total_rev_amt - v_pn_export_currency_amount;
                l_amt := l_amt - l_diff_amt;

              end if;

            END IF;

            fnd_message.set_name ('PN','PN_EXPAR_REV_AMT_DIST');
            fnd_message.set_token ('NUM',to_char(round(l_amt,l_precision)));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            fnd_message.set_name ('PN','PN_EXPAR_REV_PCT_DIST');
            fnd_message.set_token ('PCT',to_char(round(l_percent,2)));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

          ELSIF acnt_rec.account_class = 'UNEARN'   THEN

            l_acnt_cls := 'REV';

            IF v_pn_inv_rule_id IS NOT NULL OR v_pn_account_rule_id IS NOT NULL
               OR l_rev_acc_alloc_rule = 'Percent' THEN

               l_percent  := acnt_rec.percentage;
               l_amt      := null;

            ELSIF  nvl(v_normalize,'N') = 'Y' then
               l_percent  := 100;
               l_amt      := round(V_PN_EXPORT_CURRENCY_AMOUNT,l_precision);


            ELSE

               l_percent  := null;
               l_amt      := round((V_PN_EXPORT_CURRENCY_AMOUNT),l_precision);

            END IF;

            fnd_message.set_name ('PN','PN_EXPAR_ACR_AMT_DIST');
            fnd_message.set_token ('NUM',to_char(round(l_amt,l_precision)));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

            fnd_message.set_name ('PN','PN_EXPAR_ACR_PCT_DIST');
            fnd_message.set_token ('PCT',to_char(round(l_percent,2)));
            pnp_debug_pkg.put_log_msg(fnd_message.get);

          END IF;

          l_last_updated_by   := FND_GLOBAL.USER_ID;
          l_last_update_login := FND_GLOBAL.LOGIN_ID;
          l_last_update_date  := sysdate;

          pnp_debug_pkg.log('Inserting into distributions');
          l_context := 'Inserting into Distributions';

          IF (acnt_rec.account_class = 'UNEARN'  AND
              NVL(V_NORMALIZE,'N') = 'Y' AND
              NVL(l_send_flag,'Y') = 'Y') OR
              (acnt_rec.account_class = 'REC') OR
              (acnt_rec.account_class = 'REV' AND
              (NVL(V_NORMALIZE,'N') <> 'Y' OR
              (NVL(V_NORMALIZE,'N') = 'Y' AND NVL(l_send_flag,'Y') = 'N'))) THEN


             INSERT INTO ra_interface_distributions_all
               (  account_class
                 ,percent
                 ,amount
                 ,code_combination_id
                 ,created_by
                 ,creation_date
                 ,last_updated_by
                 ,last_update_date
                 ,last_update_login
                 ,org_id
                 ,interface_line_context
                 ,interface_line_attribute1
                 ,interface_line_attribute2
                 ,interface_line_attribute3
                 ,interface_line_attribute4
                 ,interface_line_attribute5
                 ,interface_line_attribute6
                 ,interface_line_attribute7
                 ,interface_line_attribute8
                 ,interface_line_attribute9
                 ,interface_line_attribute10
               )
               VALUES
               ( l_acnt_cls
                ,l_percent
                ,ROUND(l_amt,l_precision)
                ,acnt_rec.account_id
                ,l_last_updated_by
                ,SYSDATE
                ,l_last_updated_by
                ,SYSDATE
                ,l_last_update_login
                ,v_pn_org_id
                ,'Property-Projects'
                , SUBSTRB(v_pn_lease_num
                          , 1
                          , 30 - LENGTHB(' - ' ||to_char(v_pn_payment_item_id)))
                          || ' - ' ||to_char(v_pn_payment_item_id)
                ,NVL(SUBSTRB(l_location_code,1,30),'N/A')
                ,NVL(SUBSTRB(v_pn_proj_attr3,1,30),'N/A')
                ,NVL(SUBSTRB(v_pn_proj_attr4,1,30),'N/A')
                ,NVL(SUBSTRB(v_pn_proj_attr5,1,30),'N/A')
                ,NVL(SUBSTRB(v_pn_proj_attr6,1,30),'N/A')
                ,NVL(SUBSTRB(v_pn_proj_attr7,1,30),'N/A')
                ,NVL(SUBSTRB(v_pur_code,1,30),'N/A')
                ,NVL(SUBSTRB(v_pur_type_code,1,30),'N/A')
                ,NVL(SUBSTRB(v_pn_lease_num,1,30),'N/A')
              );

           END IF;
           pnp_debug_pkg.log('Inserted into distributions');

        END LOOP;

        l_context := 'Updating Payment Items';
        pnp_debug_pkg.log('Updating payment items for payment item id : ' ||
                           to_char(v_pn_payment_item_id) );

        UPDATE PN_PAYMENT_ITEMS_ALL
        SET transferred_to_ar_flag = 'Y' ,
            ar_ref_code            = v_pn_payment_item_id,
            last_updated_by        = l_last_updated_by,
            last_update_login      = l_last_update_login,
            last_update_date       = l_last_update_date ,
            export_group_id        = p_groupId
        WHERE payment_item_id      = v_pn_payment_item_id;

        IF (SQL%NOTFOUND) then
           pnp_debug_pkg.log('Could not update row for Payment_Item_Id = ' ||
                     V_PN_Payment_Item_Id) ;
           fnd_message.set_name('PN', 'PN_TRANSFER_TO_AR_FLAG_NOT_SET');
           errbuf  := fnd_message.get;
           rollback;
           retcode := 2;
           return;
        END IF;


        IF ( V_PN_Payment_Schedule_Id <> l_Prior_Payment_Schedule_Id ) THEN

            l_Prior_Payment_Schedule_Id  :=  V_PN_Payment_Schedule_Id;

            l_context := 'Updating Payment Schedules';

            pnp_debug_pkg.log('Updating payment schedules for payment sch id : ' ||
                               to_char(V_PN_Payment_Schedule_Id) );

            UPDATE PN_PAYMENT_SCHEDULES_ALL
            SET Transferred_By_User_Id    = l_last_updated_by,
                Transfer_Date             = l_last_update_date
            WHERE  Payment_Schedule_Id    = V_PN_Payment_Schedule_Id;

            IF (SQL%NOTFOUND) then
              pnp_debug_pkg.log('Could not update row for Payment_Schedule_Id = '
                                        || V_PN_Payment_Schedule_Id) ;
              fnd_message.set_name('PN', 'PN_TRANSFER_TO_AR_INFO_NOT_SET');
              errbuf  := fnd_message.get;
              rollback;
              retcode := 2;
              return;
            END IF;
         END IF;

         s_count := s_count + 1;

      EXCEPTION

        WHEN GENERIC_EXPORT_EXCEPTION THEN
          e_count := e_count + 1;

        WHEN OTHERS THEN
          RAISE;

      END;

    END LOOP; /* looping for c_billitem */

    IF dbms_sql.is_open (g_cursor_nogrp) THEN
        dbms_sql.close_cursor (g_cursor_nogrp);
    END IF;


    COMMIT;

    /*CLOSE c_billitem;*/

  pnp_debug_pkg.put_log_msg('
================================================================================');


  fnd_message.set_name ('PN','PN_EXPAR_PROC_SUC');
  fnd_message.set_token ('NUM',S_Count);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_EXPAR_PROC_FAIL');
  fnd_message.set_token ('NUM',E_Count);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_EXPAR_PROC_TOT');
  fnd_message.set_token ('NUM',T_Count);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  pnp_debug_pkg.put_log_msg('
================================================================================');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    pnp_debug_pkg.log('NO_DATA_FOUND: ' || l_context);
    raise;

  WHEN OTHERS THEN
    pnp_debug_pkg.log(substrb('OTHERS: ' || l_context,1,244));
    fnd_message.set_name('PN', 'PN_TRANSFER_TO_AR_PROBLEM');
    Errbuf  := substrb(SQLERRM,1,244);
    Retcode := 2;
    rollback;
    raise;

END EXP_TO_AR_NO_GRP;

PROCEDURE do_binding (p_cursor             NUMBER
                     ,p_lease_num_low      VARCHAR2
                     ,p_lease_num_high     VARCHAR2
                     ,p_sch_dt_low         VARCHAR2
                     ,p_sch_dt_high        VARCHAR2
                     ,p_due_dt_low         VARCHAR2
                     ,p_due_dt_high        VARCHAR2
                     ,p_pay_prps_code      VARCHAR2
                     ,p_prd_name           VARCHAR2
                     ,p_amt_low            NUMBER
                     ,p_amt_high           NUMBER
                     ,p_customer_id        NUMBER
                     ,p_grp_param          VARCHAR2
                     )  IS
BEGIN
   PNP_DEBUG_PKG.log('pn_exp_to_ar.do_binding (+)');
   IF p_grp_param IS NULL THEN
     IF p_lease_num_low IS NOT NULL AND
       p_lease_num_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_lease_num_low',p_lease_num_low);
         dbms_sql.bind_variable(p_cursor,'l_lease_num_high',p_lease_num_high);
     ELSIF p_lease_num_low IS NULL AND
       p_lease_num_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_lease_num_high',p_lease_num_high);
     ELSIF p_lease_num_low IS NOT NULL AND
       p_lease_num_high IS NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_lease_num_low',p_lease_num_low);
     END IF;
     IF p_sch_dt_low IS NOT NULL AND
       p_sch_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_sch_dt_low',fnd_date.canonical_to_date(p_sch_dt_low));
         dbms_sql.bind_variable(p_cursor,'l_sch_dt_high',fnd_date.canonical_to_date(p_sch_dt_high));
     ELSIF p_sch_dt_low IS NULL AND
       p_sch_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_sch_dt_high',fnd_date.canonical_to_date(p_sch_dt_high));
     ELSIF p_sch_dt_low IS NOT NULL AND
       p_sch_dt_high IS NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_sch_dt_low',fnd_date.canonical_to_date(p_sch_dt_low));
     END IF;
     IF p_due_dt_low IS NOT NULL AND
       p_due_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_due_dt_low',fnd_date.canonical_to_date(p_due_dt_low));
         dbms_sql.bind_variable(p_cursor,'l_due_dt_high',fnd_date.canonical_to_date(p_due_dt_high));
     ELSIF p_due_dt_low IS NULL AND
       p_due_dt_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_due_dt_high',fnd_date.canonical_to_date(p_due_dt_high));
     ELSIF p_due_dt_low IS NOT NULL AND
       p_due_dt_high IS NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_due_dt_low',fnd_date.canonical_to_date(p_due_dt_low));
     END IF;
     IF p_pay_prps_code IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_pay_prps_code',p_pay_prps_code);
     END IF;
     IF p_prd_name IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_prd_name',p_prd_name);
     END IF;
     IF p_amt_low IS NOT NULL AND
       p_amt_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_amt_low',p_amt_low);
         dbms_sql.bind_variable(p_cursor,'l_amt_high',p_amt_high);
     ELSIF p_amt_low IS NULL AND
       p_amt_high IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_amt_high',p_amt_high);
     ELSIF p_amt_low IS NOT NULL AND
       p_amt_high IS NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_amt_low',p_amt_low);
     END IF;
     IF p_customer_id IS NOT NULL THEN
         dbms_sql.bind_variable(p_cursor,'l_customer_id',p_customer_id);
     END IF;
   ELSE
    dbms_sql.bind_variable(p_cursor,'l_grp_param',p_grp_param);
   END IF;
   PNP_DEBUG_PKG.log('pn_exp_to_ar.do_binding (-)');
END do_binding;



------------------------------
-- End of Package
------------------------------
END PN_EXP_TO_AR;

/
