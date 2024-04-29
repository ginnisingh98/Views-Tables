--------------------------------------------------------
--  DDL for Package Body ARP_RECON_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RECON_REP" as
/* $Header: ARGLRECB.pls 120.24.12010000.8 2010/03/03 01:31:58 dgaurab ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');
LOG_LEVEL varchar2(1) := NVL(FND_PROFILE.value('AFLOG_LEVEL'), '6');

PROCEDURE log(msg_txt IN  VARCHAR2) IS
BEGIN
IF (PG_DEBUG='Y' AND LOG_LEVEL='1') THEN
  FND_FILE.put_line(fnd_file.log,msg_txt);
 END IF;
END log;

/*========================================================================+
  Function which returns the global variable g_reporting_level
 ========================================================================*/

FUNCTION get_reporting_level return VARCHAR2 is
BEGIN
    return arp_recon_rep.var_tname.g_reporting_level;
END get_reporting_level;

/*========================================================================+
 Function which returns the global variable g_reporting_entity_id
 ========================================================================*/

FUNCTION get_reporting_entity_id return NUMBER is
BEGIN
    return arp_recon_rep.var_tname.g_reporting_entity_id;
END get_reporting_entity_id;

/*========================================================================+
  Function which returns the global variable g_set_of_books_id
 ========================================================================*/

FUNCTION get_set_of_books_id return NUMBER is
BEGIN
    return arp_recon_rep.var_tname.g_set_of_books_id;
END get_set_of_books_id;

/*========================================================================+
  Function which returns the global variable g_chart_of_accounts_id
  ========================================================================*/

FUNCTION get_chart_of_accounts_id return NUMBER is
BEGIN
    return arp_recon_rep.var_tname.g_chart_of_accounts_id;
END get_chart_of_accounts_id;

/*========================================================================+
   Function which returns the global variable g_gl_date_from
  ========================================================================*/

FUNCTION get_gl_date_from return DATE is
BEGIN
    return arp_recon_rep.var_tname.g_gl_date_from;
END get_gl_date_from;

/*========================================================================+
   Function which returns the global variable g_gl_date_to
  ========================================================================*/

FUNCTION get_gl_date_to return DATE is
BEGIN
    return arp_recon_rep.var_tname.g_gl_date_to;
END get_gl_date_to;

/*========================================================================+
   Function which returns the global variable g_posting_status
 ========================================================================*/

FUNCTION get_posting_status return VARCHAR2 is
BEGIN
    return arp_recon_rep.var_tname.g_posting_status;
END get_posting_status;

/*========================================================================+
  Function which returns the maximum gl_date possible
 ========================================================================*/

FUNCTION get_max_gl_date return DATE IS
BEGIN
    return arp_recon_rep.var_tname.g_max_gl_date;
END get_max_gl_date;

/*========================================================================+
  Function which returns the period name
 ========================================================================*/

FUNCTION get_period_name return VARCHAR2 IS
BEGIN
    return arp_recon_rep.var_tname.g_period_name;
END get_period_name;

/*========================================================================+
  Function which returns the functional currency
 ========================================================================*/

FUNCTION get_functional_currency return VARCHAR2 IS
BEGIN
    return arp_recon_rep.var_tname.g_functional_currency;
END get_functional_currency;

/*========================================================================+
  Function which returns the value of g_out_of_balance_only
 ========================================================================*/

FUNCTION get_out_of_balance_only return VARCHAR2 IS
BEGIN
   return arp_recon_rep.var_tname.g_out_of_balance_only;
END get_out_of_balance_only;

/*========================================================================+
 | PUBLIC PROCEDURE GET_DETAIL_ACCOUNTS                                   |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to generate the list of account segments to   |
 |   be queried for a given summary account                               |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 16-NOV-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

/* Build the where condition for a single parent
   Package private procedure */
PROCEDURE build_where_clause(p_code_combinations OUT NOCOPY VARCHAR2) is

     l_count    binary_integer;
     i          binary_integer;

BEGIN
log('build_where_clause (+)');

    p_code_combinations := ' ';

    l_count := detail.count;

    FOR i in 1..l_count LOOP
       p_code_combinations := p_code_combinations || ''''||detail(i)||'''';
       IF i <> l_count THEN
          p_code_combinations := p_code_combinations ||' , ';
       END IF;
    END LOOP;

  log('build_where_clause (-)');
END build_where_clause;

PROCEDURE get_detail_accounts(p_value_set_id      IN     NUMBER,
                              p_parent_value      IN     VARCHAR2,
                              p_code_combinations OUT NOCOPY VARCHAR2)
IS
    parent                FLEX_TABLE;
    i                     BINARY_INTEGER := 1;
    j                     BINARY_INTEGER := 0;
    listed                BOOLEAN        := FALSE;
    l_count               NUMBER ;

    Cursor FlexCursor (c_value varchar2) is
     Select  flex_value,
             summary_flag
     from    fnd_flex_value_children_v
     where   flex_value_set_id = p_value_set_id
     and     parent_flex_value = c_value;

BEGIN

   log('get_detail_accounts (+)');
    arp_standard.debug('get_detail_accounts (+)');

   /*  Algorithm:
       Read the details for the incoming parent value. If the detail of the incoming parent is also
       a parent, store it. Remove the current parent from the list once the child accounts are
       retrieved. Recurse until no parents remain. */

       parent(i) := p_parent_value;

       WHILE i > 0 LOOP
          FOR r in FlexCursor(parent(1)) LOOP
              IF r.summary_flag = 'Y' THEN
                /* store the parent value for later use */
                i         := i + 1;
                parent(i) := r.flex_value;
              ELSE
               /* This is a detail account. Store it */

               /* avoid duplicating any flex_values */
               listed := FALSE;
               FOR x in 1..j LOOP
                 IF detail(x) = r.Flex_value THEN
                    listed := TRUE;
                    exit;
                 END IF;
               END LOOP;
               IF NOT listed THEN
                  j         := j + 1;
                  detail(j) := r.flex_value;
               END IF;
             END IF;
           END LOOP;

          /* shift all parents up one level
           and decrement the parent index */

           FOR x in 1..(i-1) LOOP
              parent(x) := parent(x+1);
           END LOOP;
           parent.DELETE(i);
           i := i - 1;
       END LOOP;

       l_count := detail.count;

       arp_standard.debug('No of rows : '|| l_count);

       IF l_count = 0 THEN
          detail(1) := p_parent_value;
       END IF;

       /* Build the string of the code combinations */

       build_where_clause(p_code_combinations);

       arp_standard.debug('p_code_combinations :' ||p_code_combinations);

       arp_standard.debug('get_detail_accounts (-)');
       log('get_detail_accounts (-)');
EXCEPTION
    WHEN OTHERS THEN
      arp_standard.debug(sqlcode);
      arp_standard.debug(sqlerrm);
      arp_standard.debug('get_detail_accounts (EXCEPTION)');
END get_detail_accounts;


/*========================================================================+
 | PUBLIC PROCEDURE INIT                                                  |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |   This procedure is used to initialize the reporting context. This     |
 |   procedure sets the table names to be used in the queries.
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 16-NOV-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

PROCEDURE INIT(p_set_of_books_id IN NUMBER) IS
BEGIN
log('INIT (+)');
    /*
     * When the report is run for reporting book client info will be set for the particular
     * set of books ID.  We will use that information to determine which sql statements to
     * execute. The checking of profile is done to make sure that if the user submits the
     * report from reporting responsibility it would still work and in this case even though
     * report is run for reporting book we still need to point to regular AR views
     */
    /* Set the table names based on the sob type */
         arp_recon_rep.var_tname.l_ar_system_parameters_all := 'ar_system_parameters_all';
         arp_recon_rep.var_tname.l_ar_payment_schedules_all := 'ar_payment_schedules_all';
         arp_recon_rep.var_tname.l_ar_adjustments_all := 'ar_adjustments_all';
         arp_recon_rep.var_tname.l_ar_cash_receipt_history_all := 'ar_cash_receipt_history_all';
         arp_recon_rep.var_tname.l_ar_batches_all := 'ar_batches_all';
         arp_recon_rep.var_tname.l_ar_cash_receipts_all := 'ar_cash_receipts_all';

         -- BUG#4429368 Replace ar_distributions_all by ar_xla_ard_lines_v
         arp_recon_rep.var_tname.l_ar_distributions_all := 'ar_xla_ard_lines_v';

         arp_recon_rep.var_tname.l_ra_customer_trx_all := 'ra_customer_trx_all';
         arp_recon_rep.var_tname.l_ra_batches_all := 'ra_batches_all';

         -- BUG#4429368 Replace ra_cust_trx_line_gl_dist_all by ar_xla_ctlgd_lines_v
         arp_recon_rep.var_tname.l_ra_cust_trx_gl_dist_all := 'ar_xla_ctlgd_lines_v';

         arp_recon_rep.var_tname.l_ar_misc_cash_dists_all := 'ar_misc_cash_distributions_all';
         arp_recon_rep.var_tname.l_ar_rate_adjustments_all := 'ar_rate_adjustments_all';
         arp_recon_rep.var_tname.l_ar_receivable_apps_all := 'ar_receivable_applications_all';

 log('INIT (-)');

END INIT;

/*========================================================================+
   Bug fix: 4708930
   Function which replaces the special characters in the strings to form
   a valid XML string
 +========================================================================*/
FUNCTION format_string(p_string varchar2) return varchar2 IS

  l_string varchar2(2000);
BEGIN

    l_string := replace(p_string,'&','&'||'amp;');
    l_string := replace(l_string,'<','&'||'lt;');
    l_string := replace(l_string,'>','&'||'gt;');

    RETURN l_string;

END format_string;

/*========================================================================+
 | PUBLIC PROCEDURE ARADJ_JOURNAL_LOAD_XML                                |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |  This procedure is used to generate the XML data required for reporting|
 |  Adjustments Journals                                                  |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 03-FEB-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/
PROCEDURE aradj_journal_load_xml (
          p_reporting_level      IN   VARCHAR2,
          p_reporting_entity_id  IN   NUMBER,
          p_sob_id               IN   NUMBER,
          p_coa_id               IN   NUMBER,
          p_co_seg_low           IN   VARCHAR2,
          p_co_seg_high          IN   VARCHAR2,
          p_gl_date_from         IN   VARCHAR2,
          p_gl_date_to           IN   VARCHAR2,
          p_posting_status       IN   VARCHAR2,
          p_gl_account_low       IN   VARCHAR2,
          p_gl_account_high      IN   VARCHAR2,
          p_summary_account      IN   NUMBER,
          p_receivable_mode      IN   VARCHAR2,
          p_result               OUT NOCOPY CLOB) IS

     l_result                CLOB;
     tempResult              CLOB;
     l_version               varchar2(20);
     l_compatibility         varchar2(20);
     l_suffix                varchar2(2);
     l_majorVersion          number;
     l_resultOffset          number;
     l_xml_header            varchar2(3000);
     l_xml_header_length     number;
     l_errNo                 NUMBER;
     l_errMsg                VARCHAR2(200);
     queryCtx                DBMS_XMLquery.ctxType;
     qryCtx                  DBMS_XMLGEN.ctxHandle;
     l_xml_query             VARCHAR2(32767);
     l_natural_segment_col   VARCHAR2(50);
     l_flex_value_set_id     NUMBER;
     l_code_combinations     VARCHAR2(32767);
     TYPE ref_cur IS REF CURSOR;
     l_xml_stmt              ref_cur;
     l_rows_processed        NUMBER;
     l_new_line              VARCHAR2(1);
     l_coa_id                NUMBER;   /*bug fix 5654975 */
     /* Variables to hold the report heading */
     l_sob_id                NUMBER;
     l_sob_name              VARCHAR2(100);
     l_functional_currency   VARCHAR2(15);
     l_organization          VARCHAR2(60);
     l_format                VARCHAR2(40);
     l_close_tag             VARCHAR2(100);
     l_reporting_entity_name VARCHAR2(80);
     l_reporting_level_name  VARCHAR2(30);
     l_status_meaning        VARCHAR2(30);
     l_receivable_mode_meaning VARCHAR2(10);
     /* Variables to hold the where clause based on the input parameters*/
     /* Increased variables length to 32767 for bug 5654975 */
     /* Variables data length changed from 200 to 500 to address bug:5184277*/
     l_adj_org_where         VARCHAR2(32767);
     l_ard_org_where         VARCHAR2(32767);
     l_trx_org_where         VARCHAR2(32767);
     l_pay_org_where         VARCHAR2(32767);
     l_rec_org_where         VARCHAR2(32767);
     l_type_org_where        VARCHAR2(32767);
     l_sysparam_org_where    VARCHAR2(32767);
     /*Changes to address bug:5184277 ends*/

     l_co_seg_where          VARCHAR2(32767);
     l_account_where         VARCHAR2(32767);
     l_account_seg_where     VARCHAR2(32767);
     l_gl_date_where         VARCHAR2(1000);
     l_source_type_where     VARCHAR2(32767);
     l_posting_status_where  VARCHAR2(1000);
     l_report_date           VARCHAR2(25);
     l_ld_sp                 VARCHAR2(1) := 'Y';
     l_message               VARCHAR2(2000);
     l_encoding              VARCHAR2(20);
     l_message_acct          VARCHAR2(1000);
BEGIN

log ('aradj_journal_load_xml (+)');

       /* Assign the input parameters to the global variables */
       arp_recon_rep.var_tname.g_reporting_level       := p_reporting_level;
       arp_recon_rep.var_tname.g_reporting_entity_id   := p_reporting_entity_id;
       /*  bug 5654975  p_coa_id,p_sob_id is passed incorrectly when the user
          has access to multiple Ledgers */
     --   arp_recon_rep.var_tname.g_set_of_books_id       := p_sob_id;
     --   arp_recon_rep.var_tname.g_chart_of_accounts_id  := p_coa_id;
       arp_recon_rep.var_tname.g_gl_date_from          := fnd_date.canonical_to_date(p_gl_date_from);
       arp_recon_rep.var_tname.g_gl_date_to            := fnd_date.canonical_to_date(p_gl_date_to);
       arp_recon_rep.var_tname.g_posting_status        := p_posting_status;

       /* Added Conditional Implication to address bug:5181586*/
       IF p_reporting_level = 1000 THEN
         SELECT  sob.name sob_name,
	         sob.set_of_books_id,
                 sob.currency_code functional_currency,
		 sob.chart_of_accounts_id
          INTO   l_sob_name,
	         l_sob_id,
                 l_functional_currency,
		 l_coa_id
          FROM   gl_sets_of_books sob
         WHERE  sob.set_of_books_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       ELSIF p_reporting_level = 3000 THEN
         SELECT sob.name sob_name,
	        sob.set_of_books_id,
                sob.currency_code functional_currency,
		sob.chart_of_accounts_id
           INTO l_sob_name,
	        l_sob_id,
                l_functional_currency,
                l_coa_id
           FROM gl_sets_of_books sob,
                ar_system_parameters_all sysparam
          WHERE sob.set_of_books_id = sysparam.set_of_books_id
            AND sysparam.org_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       END IF;
       /* Changes for bug:5181586 ends*/

       arp_recon_rep.var_tname.g_chart_of_accounts_id  := l_coa_id;
       arp_recon_rep.var_tname.g_set_of_books_id       := l_sob_id;

       /* Initialize the reporting context */
       init(p_sob_id);

       /* Set the org conditions */

       XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

       l_adj_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('adj',NULL);
       l_ard_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('ard',NULL);
       l_trx_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('trx',NULL);
       l_pay_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('pay',NULL);
       l_rec_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('rec',NULL);
       l_type_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('type',NULL);
       l_sysparam_org_where  :=  XLA_MO_REPORTING_API.Get_Predicate('sysparam',NULL);


       /* Replace the bind variables with global functions */
       l_adj_org_where       :=  replace(l_adj_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ard_org_where       :=  replace(l_ard_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_trx_org_where       :=  replace(l_trx_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_pay_org_where       :=  replace(l_pay_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_rec_org_where       :=  replace(l_rec_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_type_org_where      :=  replace(l_type_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_sysparam_org_where      :=  replace(l_sysparam_org_where,
                                       ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');


       l_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,80);
       l_reporting_level_name :=  substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);

       /* Multi Org Uptake: Show appropriate message to the user depending upon the security profile */
       IF p_reporting_level = '1000' THEN
          l_ld_sp:= mo_utils.check_ledger_in_sp(p_reporting_entity_id);
       END IF;

       IF l_ld_sp = 'N' THEN
         FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
         l_message := FND_MESSAGE.get;
       END IF;

       /* Bug fix 4942083*/
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                      p_reporting_entity_id,
                                      arp_recon_rep.var_tname.g_gl_date_from,
                                      arp_recon_rep.var_tname.g_gl_date_to) THEN
           FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');--Changed as per Bug 5578884 the parameter to AR from FND as the message is in AR product
           l_message_acct := FND_MESSAGE.Get;
       END IF;

       /* Get the org name */
       IF p_reporting_level = '3000' THEN
         select substrb(hou.name,1,60)
         into   l_organization
         from hr_organization_units hou
         where hou.organization_id = arp_recon_rep.var_tname.g_reporting_entity_id;
       ELSE
         select meaning
         into   l_organization
         from ar_lookups
         where lookup_code ='ALL' and lookup_type ='ALL';
       END IF;

       /* Build the WHERE clauses */
       /*buf fix 5654975 Replaced p_coa_id with l_coa_id*/

      IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
         l_co_seg_where := NULL;
      ELSIF p_co_seg_low IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '<=',
                         p_operand1 => p_co_seg_high);
      ELSIF p_co_seg_high IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '>=',
                         p_operand1 => p_co_seg_low);
      ELSE
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => 'BETWEEN',
                         p_operand1 => p_co_seg_low,
                         p_operand2 => p_co_seg_high);
      END IF;

      IF p_gl_date_from IS NULL and p_gl_date_to IS NULL THEN
         l_gl_date_where := NULL;
      ELSIF p_gl_date_from IS NULL THEN
         l_gl_date_where :=' and adj.gl_date <=  arp_recon_rep.get_gl_date_to()';
      ELSIF p_gl_date_to  IS NULL THEN
         l_gl_date_where :=' and adj.gl_date >=  arp_recon_rep.get_gl_date_from() ' ;
      ELSE
         l_gl_date_where := ' and adj.gl_date between arp_recon_rep.get_gl_date_from() and arp_recon_rep.get_gl_date_to() ';
      END IF;

      IF p_gl_account_low IS NOT NULL AND p_gl_account_high IS NOT NULL THEN
        l_account_where := ' AND ' || AR_CALC_AGING.FLEX_SQL(
                                                p_application_id=> 101,
                                                p_id_flex_code =>'GL#',
                                                p_id_flex_num =>l_coa_id,
                                                p_table_alias => 'gc',
                                                p_mode => 'WHERE',
                                                p_qualifier => 'ALL',
                                                p_function=> 'BETWEEN',
                                                p_operand1 => p_gl_account_low,
                                                p_operand2 => p_gl_account_high);
      ELSE
         l_account_where := NULL;
      END IF;

      IF p_summary_account IS NOT NULL THEN
          SELECT fcav.application_column_name, flex_value_set_id
          INTO   l_natural_segment_col , l_flex_value_set_id
          FROM   fnd_segment_attribute_values fcav,
                 fnd_id_flex_segments fifs
          WHERE  fcav.application_id = 101
          AND    fcav.id_flex_code = 'GL#'
          AND    fcav.id_flex_num = arp_recon_rep.var_tname.g_chart_of_accounts_id
          AND    fcav.attribute_value = 'Y'
          AND    fcav.segment_attribute_type = 'GL_ACCOUNT'
          AND    fifs.application_id = fcav.application_id
          AND    fifs.id_flex_code = fcav.id_flex_code
          AND    fifs.id_flex_num = fcav.id_flex_num
          AND    fcav.application_column_name = fifs.application_column_name;

         get_detail_accounts(l_flex_value_set_id, p_summary_account, l_code_combinations);

         l_account_seg_where := ' and gc.'||l_natural_segment_col||' in ('||l_code_combinations||' )';
     ELSE
         l_account_seg_where := NULL;
     END IF;

     IF nvl(p_receivable_mode,'N') = 'Y' THEN
        l_source_type_where := ' and ard.source_type in (''REC'',''UNPAIDREC'') ';
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'Y';
     ELSE
        l_source_type_where := NULL;
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'N';
     END IF;

     IF  p_posting_status IS NOT NULL THEN
        select meaning
        into   l_status_meaning
        from   ar_lookups
        where  lookup_type = 'POSTED_STATUS'
        and    lookup_code = arp_recon_rep.var_tname.g_posting_status;

       l_posting_status_where := 'and nvl(adj.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) =
                                             decode(arp_recon_rep.get_posting_status(),
                                                    ''POSTED'',adj.gl_posted_date,
                                                    ''UNPOSTED'',TO_DATE(''01/01/0001'',''MM/DD/YYYY''),
                                                    nvl(adj.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')))';
     ELSE
       l_status_meaning        := NULL;
       l_posting_status_where  := NULL;
     END IF;

     l_xml_query := '
                   select trx.invoice_currency_code,
                          type.name,
                          adj.posting_control_id,
                          trx.trx_number,
                          to_char(pay.due_date,''YYYY-MM-DD'') due_date,
                          to_char(pay.gl_date,''YYYY-MM-DD'') trx_gl_date,
                          to_char(adj.gl_date,''YYYY-MM-DD'') adj_gl_date,
                          adj.adjustment_number,
                          decode(adj.adjustment_type,''C'', look.meaning,
                                 decode(rec.type, ''FINCHRG'',''Finance'',''Adjustment'')) adj_class,
                          rec.name activity,
                          substrb(party.party_name,1,50) customer_name,
                          cust.account_number customer_number,
                          to_char(trx.trx_date,''YYYY-MM-DD'') trx_date,
                          nvl(ard.amount_dr,0) entered_debit,
                          nvl(ard.amount_cr,0) entered_credit,
                          nvl(ard.acctd_amount_dr,0) acctd_debit,
                          nvl(ard.acctd_amount_cr,0) acctd_credit,
                          gc.code_combination_id account_code_combination_id,
                          l_cat.meaning category,
                          ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''ALL'',gc.code_combination_id) account,
                          ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_BALANCING'',gc.code_combination_id) company,
                          ar_calc_aging.get_description(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_ACCOUNT'',gc.code_combination_id) account_desc
                  from    hz_cust_accounts              cust,
                          hz_parties                    party,
                          ra_cust_trx_types_all         type,
                          gl_code_combinations          gc,
                         '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' pay,
                          ar_receivables_trx_all        rec,
                         '||arp_recon_rep.var_tname.l_ra_customer_trx_all||' trx,
                         '||arp_recon_rep.var_tname.l_ar_adjustments_all||' adj,
                         '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          ar_lookups                    look,
                          ar_lookups                    l_cat
                  where   trx.complete_flag = ''Y''
                    and   cust.cust_account_id = trx.bill_to_customer_id
                    and   cust.party_id = party.party_id
                    and   trx.set_of_books_id = arp_recon_rep.get_set_of_books_id()
                    and   trx.cust_trx_type_id =  type.cust_trx_type_id
                    and   trx.customer_trx_id  =   pay.customer_trx_id
                    and   pay.payment_schedule_id = adj.payment_schedule_id
                    and   nvl(adj.status, ''A'') = ''A''
                    and   type.type in (''INV'',''DEP'',''GUAR'',''CM'',''DM'',''CB'')
                    and   nvl(type.org_id,-99) = nvl(trx.org_id,-99)
                    and   look.lookup_type = ''INV/CM''
                    and   look.lookup_code = type.type
                    and   nvl(adj.postable,''Y'') = ''Y''
                    and   adj.receivables_trx_id is not null
                    and   adj.receivables_trx_id <> -15
                    and   adj.receivables_trx_id = rec.receivables_trx_id
                    and   nvl(rec.org_id,-99) = nvl(trx.org_id,-99)
                    and   ard.source_id = adj.adjustment_id
                    and   ard.source_table = ''ADJ''
                    and   gc.code_combination_id = ard.code_combination_id
                    and   gc.chart_of_accounts_id = arp_recon_rep.get_chart_of_accounts_id()
                    and   l_cat.lookup_type = ''ARRGTA_FUNCTION_MAPPING''
                    and   l_cat.lookup_code = (''ADJ_''||ard.source_type)
                 '||l_adj_org_where||'
                 '||l_ard_org_where||'
                 '||l_rec_org_where||'
                 '||l_trx_org_where||'
                 '||l_pay_org_where||'
                 '||l_type_org_where||'
                 '||l_gl_date_where ||'
                 '||l_co_seg_where ||'
                 '||l_account_where ||'
                 '||l_account_seg_where ||'
                 '||l_source_type_where||'
                 '||l_posting_status_where||'
                 order by company, category, account,adj_gl_date, adjustment_number' ;

   DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
   l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

   IF (l_majorVersion > 8 and l_majorVersion < 9) THEN
       BEGIN
           queryCtx := DBMS_XMLQuery.newContext(l_xml_query);
           DBMS_XMLQuery.setRaiseNoRowsException(queryCtx,TRUE);
           l_result := DBMS_XMLQuery.getXML(queryCtx);
           DBMS_XMLQuery.closeContext(queryCtx);
           l_rows_processed := 1;
       EXCEPTION WHEN OTHERS THEN
           DBMS_XMLQuery.getExceptionContent(queryCtx,l_errNo,l_errMsg);
           IF l_errNo = 1403 THEN
             l_rows_processed := 0;
           END IF;
           DBMS_XMLQuery.closeContext(queryCtx);
       END;
   ELSIF (l_majorVersion >= 9 ) THEN
       qryCtx   := DBMS_XMLGEN.newContext(l_xml_query);
       l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
       l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
       DBMS_XMLGEN.closeContext(qryCtx);
   END IF;

   IF l_rows_processed <> 0 THEN
       l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
       tempResult       := l_result;
   ELSE
       l_resultOffset   := 0;
   END IF;

       l_new_line := '
';
   select to_char(sysdate,'YYYY-MM-DD')
    into  l_report_date
   from   dual;

   /* Bug 4708930
      Get the special characters replaced */
    l_reporting_entity_name   :=  format_string(l_reporting_entity_name);
    l_reporting_level_name    :=  format_string(l_reporting_level_name);
    l_organization            :=  format_string(l_organization);
    l_receivable_mode_meaning :=  format_string(l_receivable_mode_meaning);
    l_status_meaning          :=  format_string(l_status_meaning);
    l_sob_name                :=  format_string(l_sob_name);
    l_message                 :=  format_string(l_message);
    l_message_acct	      :=  format_string(l_message_acct);

   /* Prepare the tag for the report heading */
   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   l_xml_header     := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<ARADJJOURNAL>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT>'||l_message||'</MSG_TXT>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT_ACCT>'||l_message_acct||'</MSG_TXT_ACCT>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_LEVEL>'||l_reporting_level_name||'</REPORTING_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_ENTITY>'||l_reporting_entity_name||'</REPORTING_ENTITY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SOB_ID>'||p_sob_id||'</SOB_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_LOW>'||p_co_seg_low||'</CO_SEG_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_HIGH>'||p_co_seg_high||'</CO_SEG_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_FROM>'||to_char(fnd_date.canonical_to_date(p_gl_date_from),'YYYY-MM-DD')||'</GL_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_TO>'||to_char(fnd_date.canonical_to_date(p_gl_date_to),'YYYY-MM-DD')||'</GL_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <POSTING_STATUS>'||l_status_meaning||'</POSTING_STATUS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_LOW>'||p_gl_account_low||'</GL_ACCOUNT_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_HIGH>'||p_gl_account_high||'</GL_ACCOUNT_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SUMMARY_ACCOUNT>'||p_summary_account||'</SUMMARY_ACCOUNT>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REC_MODE_ONLY>'||l_receivable_mode_meaning||'</REC_MODE_ONLY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NUM_ROWS>'||l_rows_processed||'</NUM_ROWS>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'    <REPORT_HEADING>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SET_OF_BOOKS>'||l_sob_name||'</SET_OF_BOOKS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORGANIZATION>'||l_organization||'</ORGANIZATION>';
   l_xml_header     := l_xml_header ||l_new_line||'        <FUNCTIONAL_CURRENCY>'||l_functional_currency||'</FUNCTIONAL_CURRENCY>';
   l_xml_header     := l_xml_header ||l_new_line||'    </REPORT_HEADING>';

   l_close_tag      := l_new_line||'</ARADJJOURNAL>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
      dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                    l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);

   ar_cumulative_balance_report.process_clob(tempResult);
   p_result :=  tempResult;

  log ('aradj_journal_load_xml (-)');

END aradj_journal_load_xml;

/*========================================================================+
 | PUBLIC PROCEDURE ARUNAPP_JOURNAL_LOAD_XML                              |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |  This procedure is used to generate the XML data required for reporting|
 |  Unapplied Receipts Journals                                           |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 03-FEB-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/
PROCEDURE arunapp_journal_load_xml (
          p_reporting_level        IN   VARCHAR2,
          p_reporting_entity_id    IN   NUMBER,
          p_sob_id                 IN   NUMBER,
          p_coa_id                 IN   NUMBER,
          p_co_seg_low             IN   VARCHAR2,
          p_co_seg_high            IN   VARCHAR2,
          p_gl_date_from           IN   VARCHAR2,
          p_gl_date_to             IN   VARCHAR2,
          p_posting_status         IN   VARCHAR2,
          p_gl_account_low         IN   VARCHAR2,
          p_gl_account_high        IN   VARCHAR2,
          p_summary_account        IN   NUMBER,
          p_receivable_mode        IN   VARCHAR2,
          p_result                 OUT  NOCOPY CLOB) IS

     l_result                CLOB;
     tempResult              CLOB;
     l_version               varchar2(20);
     l_compatibility         varchar2(20);
     l_suffix                varchar2(2);
     l_majorVersion          number;
     l_resultOffset          number;
     l_xml_header            varchar2(3000);
     l_xml_header_length     number;
     l_errNo                 NUMBER;
     l_errMsg                VARCHAR2(200);
     queryCtx                DBMS_XMLquery.ctxType;
     qryCtx                  DBMS_XMLGEN.ctxHandle;
     l_xml_query             VARCHAR2(32767);
     l_natural_segment_col   VARCHAR2(50);
     l_flex_value_set_id     NUMBER;
     l_code_combinations     VARCHAR2(32767);
     TYPE ref_cur IS REF CURSOR;
     l_xml_stmt              ref_cur;
     l_rows_processed        NUMBER;
     l_new_line              VARCHAR2(1) ;
     l_coa_id                NUMBER;  /*bug fix 5654975*/
     /* Variables to hold the report heading */
     l_sob_id                NUMBER;
     l_sob_name              VARCHAR2(100);
     l_functional_currency   VARCHAR2(15);
     l_organization          VARCHAR2(60);
     l_format                VARCHAR2(40);
     l_close_tag             VARCHAR2(100);
     l_reporting_entity_name VARCHAR2(80);
     l_reporting_level_name  VARCHAR2(30);
     l_status_meaning        VARCHAR2(30);
     l_gl_account_type_meaning VARCHAR2(100);
     l_receivable_mode_meaning VARCHAR2(10);

     /* Variables to hold the where clause based on the input parameters*/
     /* Changed length of the variables from 200 to 500 to address bug:5181586*/
    /* Increased variables length to 32767 for bug 5654975 */
     l_ra_org_where          VARCHAR2(32767);
     l_ard_org_where         VARCHAR2(32767);
     l_ps_org_where          VARCHAR2(32767);
     l_cr_org_where          VARCHAR2(32767);
     l_crh_org_where         VARCHAR2(32767);
     l_bat_org_where         VARCHAR2(32767);
     l_bs_org_where          VARCHAR2(32767);
     l_sysparam_org_where    VARCHAR2(32767);
     /* Changes to variable length ends*/
     l_co_seg_where          VARCHAR2(32767);
     l_account_where         VARCHAR2(32767);
     l_account_seg_where     VARCHAR2(32767);
     l_gl_date_where         VARCHAR2(1000);
     l_gl_date_ard_where     VARCHAR2(1000);
     l_source_type_where     VARCHAR2(32767);
     l_gl_date_closed_where  VARCHAR2(1000);
     l_posting_status_where  VARCHAR2(1000);
     l_posting_status_ard_where  VARCHAR2(500);
     l_report_date           VARCHAR2(25);
     l_ld_sp                 VARCHAR2(1) := 'Y';
     l_message               VARCHAR2(2000);
     l_message_acct          VARCHAR2(1000);
     l_encoding		     VARCHAR2(20);
BEGIN
log('arunapp_journal_load_xml (+)');



      /* Assign the input parameters to the global variables */
       arp_recon_rep.var_tname.g_reporting_level       := p_reporting_level;
       arp_recon_rep.var_tname.g_reporting_entity_id   := p_reporting_entity_id;
     /*  bug 5654975  p_sob_id is passed incorrectly when the user
          has access to multiple Ledgers */
      -- arp_recon_rep.var_tname.g_set_of_books_id       := p_sob_id;
       /* Bug fix 5678284
         p_coa_id is passed incorrectly when the user has access to multiple Ledgers */
       --arp_recon_rep.var_tname.g_chart_of_accounts_id  := p_coa_id;
       arp_recon_rep.var_tname.g_gl_date_from          := fnd_date.canonical_to_date(p_gl_date_from);
       arp_recon_rep.var_tname.g_gl_date_to            := fnd_date.canonical_to_date(p_gl_date_to);
       arp_recon_rep.var_tname.g_posting_status        := p_posting_status;
       arp_recon_rep.var_tname.g_max_gl_date           := to_date('31-12-4712','DD-MM-YYYY');



       /* Added Conditional Implication to address bug:5181586*/
       /*Added set of books id and chart of accounts id for bug 5654975*/
       IF p_reporting_level = 1000 THEN
         SELECT  sob.name sob_name,
	         sob.set_of_books_id,
                 sob.currency_code functional_currency,
		 sob.chart_of_accounts_id
          INTO   l_sob_name,
	         l_sob_id,
                 l_functional_currency,
		 l_coa_id
          FROM   gl_sets_of_books sob
         WHERE  sob.set_of_books_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       ELSIF p_reporting_level = 3000 THEN
         SELECT sob.name sob_name,
                sob.set_of_books_id,
                sob.currency_code functional_currency,
		sob.chart_of_accounts_id
           INTO l_sob_name,
	        l_sob_id,
                l_functional_currency,
                l_coa_id
           FROM gl_sets_of_books sob,
                ar_system_parameters_all sysparam
          WHERE sob.set_of_books_id = sysparam.set_of_books_id
            AND sysparam.org_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       END IF;
       /* Changes for bug:5181586 ends*/

       arp_recon_rep.var_tname.g_set_of_books_id       := l_sob_id;
       arp_recon_rep.var_tname.g_chart_of_accounts_id  := l_coa_id;

       /* Initialize the reporting context */
       init(p_sob_id);

       /* Set the org conditions */

       XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

       l_ra_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('ra',NULL);
       l_ard_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('ard',NULL);
       l_ps_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('ps',NULL);
       l_cr_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('cr',NULL);
       l_crh_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('crh',NULL);
       l_bat_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('bat',NULL);
       l_bs_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('bs',NULL);
       l_sysparam_org_where  :=  XLA_MO_REPORTING_API.Get_Predicate('sysparam',NULL);

       /* Replace the bind variables with global functions */
       l_ra_org_where        :=  replace(l_ra_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ard_org_where       :=  replace(l_ard_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ps_org_where        :=  replace(l_ps_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_cr_org_where        :=  replace(l_cr_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_crh_org_where       :=  replace(l_crh_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_bat_org_where       :=  replace(l_bat_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_bs_org_where        :=  replace(l_bs_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');

       l_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,80);
       l_reporting_level_name :=  substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);

       /* Multi Org Uptake: Show appropriate message to the user depending upon the security profile */
       IF p_reporting_level = '1000' THEN
          l_ld_sp:= mo_utils.check_ledger_in_sp(p_reporting_entity_id);
       END IF;

       IF l_ld_sp = 'N' THEN
         FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
         l_message := FND_MESSAGE.get;
       END IF;

       /* Bug fix 4942083*/
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                      p_reporting_entity_id,
                                      arp_recon_rep.var_tname.g_gl_date_from,
                                      arp_recon_rep.var_tname.g_gl_date_to) THEN
           FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');--Changed as per Bug 5578884 the parameter to AR from FND as the message is in AR product
           l_message_acct := FND_MESSAGE.Get;
       END IF;

       /* Get the org name */
       IF p_reporting_level = '3000' THEN
         select substrb(hou.name,1,60)
         into   l_organization
         from hr_organization_units hou
         where hou.organization_id = arp_recon_rep.var_tname.g_reporting_entity_id;
       ELSE
         select meaning
         into   l_organization
         from ar_lookups
         where lookup_code ='ALL' and lookup_type ='ALL';
       END IF;

      /* Build the WHERE clauses */
      /*Replaced p_coa_id with l_coa_id for bug 5654975*/

      IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
         l_co_seg_where := NULL;
      ELSIF p_co_seg_low IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '<=',
                         p_operand1 => p_co_seg_high);
      ELSIF p_co_seg_high IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '>=',
                         p_operand1 => p_co_seg_low);
      ELSE
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => 'BETWEEN',
                         p_operand1 => p_co_seg_low,
                         p_operand2 => p_co_seg_high);
      END IF;

     /* Bug fix 5678284 : Added l_gl_date_ard_where*/
      IF p_gl_date_from IS NULL and p_gl_date_to IS NULL THEN
         l_gl_date_where := NULL;
         l_gl_date_ard_where := NULL;
      ELSIF p_gl_date_from IS NULL THEN
         l_gl_date_where :=' and ra.gl_date <=  arp_recon_rep.get_gl_date_to()';
         l_gl_date_ard_where :=' and ard.gl_date <=  arp_recon_rep.get_gl_date_to()';
      ELSIF p_gl_date_to  IS NULL THEN
         l_gl_date_where :=' and ra.gl_date >=  arp_recon_rep.get_gl_date_from() ' ;
         l_gl_date_ard_where :=' and ard.gl_date >=  arp_recon_rep.get_gl_date_from() ' ;
      ELSE
         l_gl_date_where := ' and ra.gl_date between arp_recon_rep.get_gl_date_from() and arp_recon_rep.get_gl_date_to() ';
         l_gl_date_ard_where := ' and ard.gl_date between arp_recon_rep.get_gl_date_from() and arp_recon_rep.get_gl_date_to() ';
      END IF;

      IF p_gl_date_from IS NULL and p_gl_date_to IS NULL THEN
        l_gl_date_closed_where := 'and ps.gl_date_closed = arp_recon_rep.get_max_gl_date()';
      ELSIF p_gl_date_from IS NOT NULL THEN
        l_gl_date_closed_where := 'and ps.gl_date_closed >= arp_recon_rep.get_gl_date_from() ';
      ELSIF p_gl_date_to IS NOT NULL THEN
        l_gl_date_closed_where := 'and ps.gl_date_closed >= arp_recon_rep.get_gl_date_to()';
      END IF;

      IF p_gl_account_low IS NOT NULL AND p_gl_account_high IS NOT NULL THEN
        l_account_where := ' AND ' || AR_CALC_AGING.FLEX_SQL(
                                                p_application_id=> 101,
                                                p_id_flex_code =>'GL#',
                                                p_id_flex_num =>l_coa_id,
                                                p_table_alias => 'gc',
                                                p_mode => 'WHERE',
                                                p_qualifier => 'ALL',
                                                p_function=> 'BETWEEN',
                                                p_operand1 => p_gl_account_low,
                                                p_operand2 => p_gl_account_high);
      ELSE
         l_account_where := NULL;
      END IF;

      IF p_summary_account IS NOT NULL THEN
          SELECT fcav.application_column_name, flex_value_set_id
          INTO   l_natural_segment_col , l_flex_value_set_id
          FROM   fnd_segment_attribute_values fcav,
                 fnd_id_flex_segments fifs
          WHERE  fcav.application_id = 101
          AND    fcav.id_flex_code = 'GL#'
          AND    fcav.id_flex_num = arp_recon_rep.var_tname.g_chart_of_accounts_id
          AND    fcav.attribute_value = 'Y'
          AND    fcav.segment_attribute_type = 'GL_ACCOUNT'
          AND    fifs.application_id = fcav.application_id
          AND    fifs.id_flex_code = fcav.id_flex_code
          AND    fifs.id_flex_num = fcav.id_flex_num
          AND    fcav.application_column_name = fifs.application_column_name;

         get_detail_accounts(l_flex_value_set_id, p_summary_account, l_code_combinations);

         l_account_seg_where := ' and gc.'||l_natural_segment_col||' in ('||l_code_combinations||' )';
     ELSE
         l_account_seg_where := NULL;
     END IF;

    /* Is this parameter redundant ?*/

    IF nvl(p_receivable_mode,'N') = 'Y' THEN
        l_source_type_where := ' and ard.source_type in (''UNAPP'', ''UNID'',''ACC'',''OTHER ACC'') ';
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'Y';
     ELSE
        l_source_type_where := NULL;
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'N';
     END IF;

     IF  p_posting_status IS NOT NULL THEN
        select meaning
        into   l_status_meaning
        from   ar_lookups
        where  lookup_type = 'POSTED_STATUS'
        and    lookup_code = arp_recon_rep.var_tname.g_posting_status;

       l_posting_status_where := 'and nvl(ra.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) =
                                             decode(arp_recon_rep.get_posting_status(),
                                                    ''POSTED'',ra.gl_posted_date,
                                                    ''UNPOSTED'',TO_DATE(''01/01/0001'',''MM/DD/YYYY''),
                                                    nvl(ra.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')))';
       /* Bug fix 5678284 : Added l_posting_status_ard_where*/
       l_posting_status_ard_where := 'and nvl(ard.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) =
                                             decode(arp_recon_rep.get_posting_status(),
                                                    ''POSTED'',ard.gl_posted_date,
                                                    ''UNPOSTED'',TO_DATE(''01/01/0001'',''MM/DD/YYYY''),
                                                    nvl(ard.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')))';
     ELSE
       l_status_meaning        := NULL;
       l_posting_status_where  := NULL;
       l_posting_status_ard_where  := NULL;
     END IF;


   l_xml_query := '
                     select cr.receipt_number payment_number,
                            arm.name payment_method,
                            substrb(party.party_name,1,50) customer_name,
                            cust.account_number customer_number,
                            to_char(ra.gl_date,''YYYY-MM-DD'') app_gl_date,
                            to_char(ps.gl_date,''YYYY-MM-DD'') payment_gl_date,
                            nvl(ard.amount_dr,0) entered_debit,
                            nvl(ard.amount_cr,0) entered_credit,
                            nvl(ard.acctd_amount_dr,0) acctd_debit,
                            nvl(ard.acctd_amount_cr,0) acctd_credit,
                            to_char(cr.receipt_date,''YYYY-MM-DD'') receipt_date,
                            cr.currency_code receipt_currency,
                            gc.code_combination_id,
                            bs.name receipt_source,
                            bat.name batch_name,
                            l_cat.meaning category,
                            /* 7008877 */
                            ard.line_id,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''ALL'',gc.code_combination_id) account,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_BALANCING'',gc.code_combination_id) company,
                            ar_calc_aging.get_description(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_ACCOUNT'',gc.code_combination_id) account_desc
                     from  '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr,
                             ar_receipt_methods arm,
                            '||arp_recon_rep.var_tname.l_ar_cash_receipt_history_all||' crh,
                            gl_code_combinations gc,
                            hz_cust_accounts cust,
                            hz_parties  party,
                            '||arp_recon_rep.var_tname.l_ar_batches_all||' bat,
                            ar_batch_sources_all bs,
                            '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra,
                            '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' ps,
                            '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                            ar_lookups l_cat
                 where  nvl(ra.confirmed_flag,''Y'') = ''Y''
                   and  ra.status in (''UNAPP'',''ACC'',''UNID'',''OTHER ACC'')
                   and  ps.cash_receipt_id = ra.cash_receipt_id
                   and  ps.class = ''PMT''
                   '||l_gl_date_closed_where||'
                   and  cr.cash_receipt_id = ra.cash_receipt_id
                   and  nvl(cr.confirmed_flag,''Y'') = ''Y''
                   and  cr.receipt_method_id = arm.receipt_method_id
                   and  crh.cash_receipt_id = cr.cash_receipt_id
                   and  crh.first_posted_record_flag = ''Y''
                   and  crh.batch_id = bat.batch_id(+)
                   and  bat.batch_source_id = bs.batch_source_id(+)
                   and  bat.org_id = bs.org_id(+)
                   and  gc.code_combination_id = ard.code_combination_id
                   and  gc.chart_of_accounts_id = arp_recon_rep.get_chart_of_accounts_id()
                   and  ard.source_id = ra.receivable_application_id
                   and  ard.source_table = ''RA''
                   and  cr.pay_from_customer = cust.cust_account_id(+)
                   and  cust.party_id = party.party_id(+)
                   and  l_cat.lookup_type = ''ARRGTA_FUNCTION_MAPPING''
                   and  l_cat.lookup_code = ''TRADE_''||ard.source_type
                   '||l_ra_org_where||'
                   '||l_ard_org_where||'
                   '||l_ps_org_where||'
                   '||l_cr_org_where||'
                   '||l_crh_org_where||'
                   '||l_bat_org_where||'
                   '||l_bs_org_where||'
                   '||l_gl_date_where ||'
                   '||l_co_seg_where ||'
                   '||l_account_where ||'
                   '||l_account_seg_where ||'
                   '||l_source_type_where||'
                   '||l_posting_status_where||'
                   UNION
                   select cr.receipt_number payment_number,
                            arm.name payment_method,
                            substrb(party.party_name,1,50) customer_name,
                            cust.account_number customer_number,
                            to_char(ard.gl_date,''YYYY-MM-DD'') app_gl_date,
                            to_char(ps.gl_date,''YYYY-MM-DD'') payment_gl_date,
                            nvl(ard.amount_dr,0) entered_debit,
                            nvl(ard.amount_cr,0) entered_credit,
                            nvl(ard.acctd_amount_dr,0) acctd_debit,
                            nvl(ard.acctd_amount_cr,0) acctd_credit,
                            to_char(cr.receipt_date,''YYYY-MM-DD'') receipt_date,
                            cr.currency_code receipt_currency,
                            gc.code_combination_id,
                            bs.name receipt_source,
                            bat.name batch_name,
                            l_cat.meaning category,
                             /* 7008877 */
                            ard.line_id,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''ALL'',gc.code_combination_id) account,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_BALANCING'',gc.code_combination_id) company,
                            ar_calc_aging.get_description(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_ACCOUNT'',gc.code_combination_id) account_desc
                     from  '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr,
                             ar_receipt_methods arm,
                            '||arp_recon_rep.var_tname.l_ar_cash_receipt_history_all||' crh,
                            gl_code_combinations gc,
                            hz_cust_accounts cust,
                            hz_parties  party,
                            '||arp_recon_rep.var_tname.l_ar_batches_all||' bat,
                            ar_batch_sources_all bs,
                            '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' ps,
                            '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                            ar_lookups l_cat
                 where  ard.source_type = ''UNAPP''
                   and  ps.cash_receipt_id = ard.cash_receipt_id
                   and  ps.class = ''PMT''
                   '||l_gl_date_closed_where||'
                   and  cr.cash_receipt_id = ps.cash_receipt_id
                   and  nvl(cr.confirmed_flag,''Y'') = ''Y''
                   and  cr.receipt_method_id = arm.receipt_method_id
                   and  crh.cash_receipt_id = cr.cash_receipt_id
                   and  crh.first_posted_record_flag = ''Y''
                   and  crh.batch_id = bat.batch_id(+)
                   and  bat.batch_source_id = bs.batch_source_id(+)
                   and  bat.org_id = bs.org_id(+)
                   and  gc.code_combination_id = ard.code_combination_id
                   and  gc.chart_of_accounts_id = arp_recon_rep.get_chart_of_accounts_id()
                   and  ard.cash_receipt_id = ps.cash_receipt_id
                   and  ard.source_table in(''CRH'', ''RA'')
                   and  cr.pay_from_customer = cust.cust_account_id(+)
                   and  cust.party_id = party.party_id(+)
                   and  l_cat.lookup_type = ''ARRGTA_FUNCTION_MAPPING''
                   and  l_cat.lookup_code = ''TRADE_''||ard.source_type
                   '||l_ard_org_where||'
                   '||l_ps_org_where||'
                   '||l_cr_org_where||'
                   '||l_crh_org_where||'
                   '||l_bat_org_where||'
                   '||l_bs_org_where||'
                   '||l_gl_date_ard_where ||'
                   '||l_co_seg_where ||'
                   '||l_account_where ||'
                   '||l_account_seg_where ||'
                   '||l_posting_status_ard_where;

   DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
   l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

   IF (l_majorVersion > 8 and l_majorVersion < 9) THEN
       BEGIN
           queryCtx := DBMS_XMLQuery.newContext(l_xml_query);
           DBMS_XMLQuery.setRaiseNoRowsException(queryCtx,TRUE);
           l_result := DBMS_XMLQuery.getXML(queryCtx);
           DBMS_XMLQuery.closeContext(queryCtx);
           l_rows_processed := 1;
       EXCEPTION WHEN OTHERS THEN
           DBMS_XMLQuery.getExceptionContent(queryCtx,l_errNo,l_errMsg);
           IF l_errNo = 1403 THEN
             l_rows_processed := 0;
           END IF;
           DBMS_XMLQuery.closeContext(queryCtx);
       END;

   ELSIF (l_majorVersion >= 9 ) THEN
       qryCtx   := DBMS_XMLGEN.newContext(l_xml_query);
       l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
       l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
       DBMS_XMLGEN.closeContext(qryCtx);
   END IF;

   IF l_rows_processed <> 0 THEN
       l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
       tempResult       := l_result;
   ELSE
       l_resultOffset   := 0;
   END IF;

   l_new_line := '
';

   select to_char(sysdate,'YYYY-MM-DD')
    into  l_report_date
   from   dual;

   /* Bug 4708930
      Get the special characters replaced */
    l_reporting_entity_name   :=  format_string(l_reporting_entity_name);
    l_reporting_level_name    :=  format_string(l_reporting_level_name);
    l_organization            :=  format_string(l_organization);
    l_receivable_mode_meaning :=  format_string(l_receivable_mode_meaning);
    l_status_meaning          :=  format_string(l_status_meaning);
    l_sob_name                :=  format_string(l_sob_name);
    l_message                 :=  format_string(l_message);
    l_message_acct	      :=  format_string(l_message_acct);

   /* Prepare the tag for the report heading */
   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   l_xml_header     := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<ARUNAPPJOURNAL>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT>'||l_message||'</MSG_TXT>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT_ACCT>'||l_message_acct||'</MSG_TXT_ACCT>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_LEVEL>'||l_reporting_level_name||'</REPORTING_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_ENTITY>'||l_reporting_entity_name||'</REPORTING_ENTITY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SOB_ID>'||p_sob_id||'</SOB_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_LOW>'||p_co_seg_low||'</CO_SEG_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_HIGH>'||p_co_seg_high||'</CO_SEG_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_FROM>'||to_char(fnd_date.canonical_to_date(p_gl_date_from),'YYYY-MM-DD')||'</GL_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_TO>'||to_char(fnd_date.canonical_to_date(p_gl_date_to),'YYYY-MM-DD')||'</GL_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <POSTING_STATUS>'||l_status_meaning||'</POSTING_STATUS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_LOW>'||p_gl_account_low||'</GL_ACCOUNT_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_HIGH>'||p_gl_account_high||'</GL_ACCOUNT_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SUMMARY_ACCOUNT>'||p_summary_account||'</SUMMARY_ACCOUNT>';
   l_xml_header     := l_xml_header ||l_new_line||'        <RECEIVABLES_MODE_ONLY>'||l_receivable_mode_meaning||'</RECEIVABLES_MODE_ONLY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NUM_ROWS>'||l_rows_processed||'</NUM_ROWS>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'    <REPORT_HEADING>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SET_OF_BOOKS>'||l_sob_name||'</SET_OF_BOOKS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORGANIZATION>'||l_organization||'</ORGANIZATION>';
   l_xml_header     := l_xml_header ||l_new_line||'        <FUNCTIONAL_CURRENCY>'||l_functional_currency||'</FUNCTIONAL_CURRENCY>';
   l_xml_header     := l_xml_header ||l_new_line||'    </REPORT_HEADING>';

   l_close_tag      := l_new_line||'</ARUNAPPJOURNAL>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
      dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                    l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);

   ar_cumulative_balance_report.process_clob(tempResult);
   p_result :=  tempResult;

log('arunapp_journal_load_xml (-)');

END arunapp_journal_load_xml;

/*========================================================================+
 | PUBLIC PROCEDURE ARAPP_JOURNAL_LOAD_XML                                |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |  This procedure is used to generate the XML data required for reporting|
 |  Applied Receipts Journals                                             |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 03-FEB-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

PROCEDURE arapp_journal_load_xml (
          p_reporting_level       IN   VARCHAR2,
          p_reporting_entity_id   IN   NUMBER,
          p_sob_id                IN   NUMBER,
          p_coa_id                IN   NUMBER,
          p_co_seg_low            IN   VARCHAR2,
          p_co_seg_high           IN   VARCHAR2,
          p_gl_date_from          IN   VARCHAR2,
          p_gl_date_to            IN   VARCHAR2,
          p_posting_status        IN   VARCHAR2,
          p_gl_account_low        IN   VARCHAR2,
          p_gl_account_high       IN   VARCHAR2,
          p_summary_account       IN   NUMBER,
          p_receivable_mode       IN   VARCHAR2,
          p_result                OUT NOCOPY CLOB) IS
     l_result                CLOB;
     tempResult              CLOB;
     l_version               varchar2(20);
     l_compatibility         varchar2(20);
     l_suffix                varchar2(2);
     l_majorVersion          number;
     l_resultOffset          number;
     l_xml_header            varchar2(3000);
     l_xml_header_length     number;
     l_errNo                 NUMBER;
     l_errMsg                VARCHAR2(200);
     queryCtx                DBMS_XMLquery.ctxType;
     qryCtx                  DBMS_XMLGEN.ctxHandle;
     l_xml_query             VARCHAR2(32767);
     l_natural_segment_col   VARCHAR2(50);
     l_flex_value_set_id     NUMBER;
     l_code_combinations     VARCHAR2(32767);
     TYPE ref_cur IS REF CURSOR;
     l_xml_stmt              ref_cur;
     l_rows_processed        NUMBER;
     l_new_line              VARCHAR2(1);
     l_coa_id                NUMBER;  /*bufg fix 5654975*/
     /* Variables to hold the report heading */
     l_sob_id                NUMBER;
     l_sob_name              VARCHAR2(100);
     l_functional_currency   VARCHAR2(15);
     l_organization          VARCHAR2(60);
     l_format                VARCHAR2(40);
     l_close_tag             VARCHAR2(100);
     l_reporting_entity_name VARCHAR2(80);
     l_reporting_level_name  VARCHAR2(30);
     l_status_meaning        VARCHAR2(30);
     l_receivable_mode_meaning VARCHAR2(10);
     /* Variables to hold the where clause based on the input parameters*/
     /* Variables length changed from 200 to 500 to address bug:5181586*/
     /* Increased variables length to 32767 for bug 5654975 */
     l_ra_org_where          VARCHAR2(32767);
     l_ard_org_where         VARCHAR2(32767);
     l_ard1_org_where        VARCHAR2(32767);
     l_ps_org_where          VARCHAR2(32767);
     l_cr_org_where          VARCHAR2(32767);
     l_crh_org_where         VARCHAR2(32767);
     l_bat_org_where         VARCHAR2(32767);
     l_bs_org_where          VARCHAR2(32767);
     l_sysparam_org_where    VARCHAR2(32767);
     /* Changes to variable length ends*/
     l_co_seg_where          VARCHAR2(32767);
     l_account_where         VARCHAR2(32767);
     l_account_seg_where     VARCHAR2(32767);
     l_gl_date_where         VARCHAR2(1000);
     l_gl_date_ard_where     VARCHAR2(1000);
     /* Variable length changed from 900 to 1000 to address bug:5181586*/
     l_source_type_where     VARCHAR2(32767);
     /*Change to variable length ends*/
     l_posting_status_where  VARCHAR2(1000);
     l_posting_status_ard_where  VARCHAR2(1000);
     l_report_date           VARCHAR2(25);
     l_ld_sp                 VARCHAR2(1) := 'Y';
     l_message               VARCHAR2(2000);
     l_encoding		     VARCHAR2(20);
     l_message_acct          VARCHAR2(1000);
BEGIN

log('arapp_journal_load_xml (+)');

       /* Assign the input parameters to the global variables */
       arp_recon_rep.var_tname.g_reporting_level       := p_reporting_level;
       arp_recon_rep.var_tname.g_reporting_entity_id   := p_reporting_entity_id;
      /*  bug 5654975  p_coa_id,p_sob_id is passed incorrectly when the user
          has access to multiple Ledgers */
      -- arp_recon_rep.var_tname.g_set_of_books_id       := p_sob_id;
      -- arp_recon_rep.var_tname.g_chart_of_accounts_id  := p_coa_id;
       arp_recon_rep.var_tname.g_gl_date_from          := fnd_date.canonical_to_date(p_gl_date_from);
       arp_recon_rep.var_tname.g_gl_date_to            := fnd_date.canonical_to_date(p_gl_date_to);
       arp_recon_rep.var_tname.g_posting_status        := p_posting_status;

       /* Added Conditional Implication to address bug:5181586*/
       /*Added set of books id and char of accounts id for bug fix  5654975 */
       IF p_reporting_level = 1000 THEN
         SELECT  sob.name sob_name,
	         sob.set_of_books_id,
                 sob.currency_code functional_currency,
		 sob.chart_of_accounts_id
          INTO   l_sob_name,
	         l_sob_id,
                 l_functional_currency,
		 l_coa_id
          FROM   gl_sets_of_books sob
         WHERE  sob.set_of_books_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       ELSIF p_reporting_level = 3000 THEN
         SELECT sob.name sob_name,
	        sob.set_of_books_id,
                sob.currency_code functional_currency,
		sob.chart_of_accounts_id
           INTO l_sob_name,
	        l_sob_id,
                l_functional_currency,
                l_coa_id
           FROM gl_sets_of_books sob,
                ar_system_parameters_all sysparam
          WHERE sob.set_of_books_id = sysparam.set_of_books_id
            AND sysparam.org_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       END IF;
       /* Changes for bug:5181586 ends*/

       arp_recon_rep.var_tname.g_set_of_books_id       := l_sob_id;
       arp_recon_rep.var_tname.g_chart_of_accounts_id  := l_coa_id;

       /* Initialize the reporting context */
       init(p_sob_id);

       /* Set the org conditions */

       XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

       l_ra_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('ra',NULL);
       l_ard_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('ard',NULL);
       l_ard1_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('ard1',NULL);
       l_ps_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('ps',NULL);
       l_cr_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('cr',NULL);
       l_crh_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('crh',NULL);
       l_bat_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('bat',NULL);
       l_bs_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('bs',NULL);
       l_sysparam_org_where  :=  XLA_MO_REPORTING_API.Get_Predicate('sysparam',NULL);

       /* Replace the bind variables with global functions */
       l_ra_org_where        :=  replace(l_ra_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ard_org_where       :=  replace(l_ard_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ard1_org_where      :=  replace(l_ard1_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ps_org_where        :=  replace(l_ps_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_cr_org_where        :=  replace(l_cr_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_crh_org_where       :=  replace(l_crh_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_bat_org_where       :=  replace(l_bat_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_bs_org_where        :=  replace(l_bs_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_sysparam_org_where  :=  replace(l_sysparam_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');


       l_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,80);
       l_reporting_level_name :=  substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);

       /* Multi Org Uptake: Show appropriate message to the user depending upon the security profile */
       IF p_reporting_level = '1000' THEN
          l_ld_sp:= mo_utils.check_ledger_in_sp(p_reporting_entity_id);
       END IF;

       IF l_ld_sp = 'N' THEN
         FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
         l_message := FND_MESSAGE.get;
       END IF;

       /* Bug fix 4942083*/
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                      p_reporting_entity_id,
                                      arp_recon_rep.var_tname.g_gl_date_from,
                                      arp_recon_rep.var_tname.g_gl_date_to) THEN
           FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');--Changed as per Bug 5578884 the parameter to AR from FND as the message is in AR product
           l_message_acct := FND_MESSAGE.Get;
       END IF;

       /* Get the org name */
       IF p_reporting_level = '3000' THEN
         select substrb(hou.name,1,60)
         into   l_organization
         from hr_organization_units hou
         where hou.organization_id = arp_recon_rep.var_tname.g_reporting_entity_id;
       ELSE
         select meaning
         into   l_organization
         from ar_lookups
         where lookup_code ='ALL' and lookup_type ='ALL';
       END IF;


       /* Build the WHERE clauses */
       /*Replaced p_coa_id with l_coa_id for bug 5654975*/

      IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
         l_co_seg_where := NULL;
      ELSIF p_co_seg_low IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '<=',
                         p_operand1 => p_co_seg_high);
      ELSIF p_co_seg_high IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '>=',
                         p_operand1 => p_co_seg_low);
      ELSE
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => 'BETWEEN',
                         p_operand1 => p_co_seg_low,
                         p_operand2 => p_co_seg_high);
      END IF;


      IF p_gl_date_from IS NULL and p_gl_date_to IS NULL THEN
         l_gl_date_where := NULL;
	 l_gl_date_ard_where := NULL;
      ELSIF p_gl_date_from IS NULL THEN
         l_gl_date_where :=' and ra.gl_date <=  arp_recon_rep.get_gl_date_to()';
	 l_gl_date_ard_where :=' and ard.gl_date <=  arp_recon_rep.get_gl_date_to()';
      ELSIF p_gl_date_to  IS NULL THEN
         l_gl_date_where :=' and ra.gl_date >=  arp_recon_rep.get_gl_date_from() ' ;
	 l_gl_date_ard_where :=' and ard.gl_date >=  arp_recon_rep.get_gl_date_from() ' ;
      ELSE
         l_gl_date_where := ' and ra.gl_date between arp_recon_rep.get_gl_date_from() and arp_recon_rep.get_gl_date_to() ';
	 l_gl_date_ard_where := ' and ard.gl_date between arp_recon_rep.get_gl_date_from() and arp_recon_rep.get_gl_date_to() ';
      END IF;

      IF p_gl_account_low IS NOT NULL AND p_gl_account_high IS NOT NULL THEN
        l_account_where := ' AND ' || AR_CALC_AGING.FLEX_SQL(
                                                p_application_id=> 101,
                                                p_id_flex_code =>'GL#',
                                                p_id_flex_num =>l_coa_id,
                                                p_table_alias => 'gc',
                                                p_mode => 'WHERE',
                                                p_qualifier => 'ALL',
                                                p_function=> 'BETWEEN',
                                                p_operand1 => p_gl_account_low,
                                                p_operand2 => p_gl_account_high);
      ELSE
         l_account_where := NULL;
      END IF;

      IF p_summary_account IS NOT NULL THEN
          SELECT fcav.application_column_name, flex_value_set_id
          INTO   l_natural_segment_col , l_flex_value_set_id
          FROM   fnd_segment_attribute_values fcav,
                 fnd_id_flex_segments fifs
          WHERE  fcav.application_id = 101
          AND    fcav.id_flex_code = 'GL#'
          AND    fcav.id_flex_num = arp_recon_rep.var_tname.g_chart_of_accounts_id
          AND    fcav.attribute_value = 'Y'
          AND    fcav.segment_attribute_type = 'GL_ACCOUNT'
          AND    fifs.application_id = fcav.application_id
          AND    fifs.id_flex_code = fcav.id_flex_code
          AND    fifs.id_flex_num = fcav.id_flex_num
          AND    fcav.application_column_name = fifs.application_column_name;

         get_detail_accounts(l_flex_value_set_id, p_summary_account, l_code_combinations);

         l_account_seg_where := ' and gc.'||l_natural_segment_col||' in ('||l_code_combinations||' )';
     ELSE
         l_account_seg_where := NULL;
     END IF;


     IF nvl(p_receivable_mode,'N') = 'Y' THEN
         l_source_type_where := ' and ((ard.source_type = ''REC'')
                                       OR (ps.class =''BR''
                                            and not exists (select line_id
                                                            from '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard1
                                                        where ard1.source_id = ra.receivable_application_id
                                                          and   ard1.source_type = ''REC''
                                                          and   ard1.source_table =''RA''
                                                          '|| l_ard1_org_where || ')
                                            and ard.source_type in (''REMITTANCE'',''FACTOR'',''UNPAIDREC'')))';
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'Y';
     ELSE
         l_source_type_where := NULL;
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'N';
     END IF;

     IF  p_posting_status IS NOT NULL THEN

        select meaning
        into   l_status_meaning
        from   ar_lookups
        where  lookup_type = 'POSTED_STATUS'
        and    lookup_code = arp_recon_rep.var_tname.g_posting_status;

       l_posting_status_where := 'and nvl(ra.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) =
                                             decode(arp_recon_rep.get_posting_status(),
                                                    ''POSTED'',ra.gl_posted_date,
                                                    ''UNPOSTED'',TO_DATE(''01/01/0001'',''MM/DD/YYYY''),
                                                    nvl(ra.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')))';

       l_posting_status_ard_where := 'and nvl(ard.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) =
                                             decode(arp_recon_rep.get_posting_status(),
                                                    ''POSTED'',ard.gl_posted_date,
                                                    ''UNPOSTED'',TO_DATE(''01/01/0001'',''MM/DD/YYYY''),
                                                    nvl(ard.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')))';
     ELSE
       l_status_meaning        := NULL;
       l_posting_status_where  := NULL;
     END IF;

       l_xml_query := '
                     select cr.receipt_number payment_number,
                            arm.name payment_method,
                            substrb(party.party_name,1,50) customer_name,
                            cust.account_number customer_number,
                            to_char(ra.gl_date,''YYYY-MM-DD'') app_gl_date,
                            to_char(crh.gl_date,''YYYY-MM-DD'') payment_gl_date,
                            nvl(ard.amount_dr,0) entered_debit,
                            nvl(ard.amount_cr,0) entered_credit,
                            nvl(ard.acctd_amount_dr,0) acctd_debit,
                            nvl(ard.acctd_amount_cr,0) acctd_credit,
                            to_char(cr.receipt_date,''YYYY-MM-DD'') receipt_date,
                            cr.currency_code receipt_currency,
                            ps.trx_number trx_number,
                            gc.code_combination_id,
                            bs.name receipt_source,
                            bat.name batch_name,
                            l_cat.meaning category,
                            ard.currency_code currency_code,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''ALL'',gc.code_combination_id) account,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_BALANCING'',gc.code_combination_id) company,
                            ar_calc_aging.get_description(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_ACCOUNT'',gc.code_combination_id) account_desc
                     from  '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr,
                             ar_receipt_methods arm,
                            '||arp_recon_rep.var_tname.l_ar_cash_receipt_history_all||' crh,
                            gl_code_combinations gc,
                            hz_cust_accounts cust,
                            hz_parties  party,
                            '||arp_recon_rep.var_tname.l_ar_batches_all||' bat,
                            ar_batch_sources_all bs,
                            '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra,
                            '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' ps,
                            '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                            ar_lookups l_cat
                   where  nvl(ra.confirmed_flag,''Y'') = ''Y''
                   and  ra.status = ''APP''
                   and  cr.cash_receipt_id = ra.cash_receipt_id
		   and  cr.reversal_date IS NULL
                   and  nvl(cr.confirmed_flag,''Y'') = ''Y''
                   and  cr.receipt_method_id = arm.receipt_method_id
                   and  crh.cash_receipt_id = cr.cash_receipt_id
                   and  crh.first_posted_record_flag = ''Y''
                   and  crh.batch_id = bat.batch_id(+)
                   and  ps.payment_schedule_id = ra.applied_payment_schedule_id
                   and  bat.batch_source_id = bs.batch_source_id(+)
                   and  bat.org_id = bs.org_id(+)
                   and  gc.code_combination_id = ard.code_combination_id
                   and  gc.chart_of_accounts_id = arp_recon_rep.get_chart_of_accounts_id()
                   and  ard.source_id = ra.receivable_application_id
                   and  ard.source_table = ''RA''
                   and  cr.pay_from_customer = cust.cust_account_id(+)
                   and  cust.party_id = party.party_id(+)
                   and  l_cat.lookup_type = ''ARRGTA_FUNCTION_MAPPING''
                   and  ((ra.amount_applied_from IS NULL
                         and l_cat.lookup_code = (''TRADE_''||ard.source_type))
                      or( ra.amount_applied_from IS NOT NULL
                          and l_cat.lookup_code = (''CCURR_''||ard.source_type))
                      or(ps.class =''BR'' and l_cat.lookup_code = (''BR_''||ard.source_type)))
                   '||l_ra_org_where||'
                   '||l_ard_org_where||'
                   '||l_ps_org_where||'
                   '||l_cr_org_where||'
                   '||l_crh_org_where||'
                   '||l_bat_org_where||'
                   '||l_bs_org_where||'
                   '||l_gl_date_where ||'
                   '||l_co_seg_where ||'
                   '||l_account_where ||'
                   '||l_account_seg_where ||'
                   '||l_source_type_where||'
                   '||l_posting_status_where||'
		   UNION
                   select cr.receipt_number payment_number,
                            arm.name payment_method,
                            substrb(party.party_name,1,50) customer_name,
                            cust.account_number customer_number,
                            to_char(ard.gl_date,''YYYY-MM-DD'') app_gl_date,
                            to_char(crh.gl_date,''YYYY-MM-DD'') payment_gl_date,
                            nvl(ard.amount_dr,0) entered_debit,
                            nvl(ard.amount_cr,0) entered_credit,
                            nvl(ard.acctd_amount_dr,0) acctd_debit,
                            nvl(ard.acctd_amount_cr,0) acctd_credit,
                            to_char(cr.receipt_date,''YYYY-MM-DD'') receipt_date,
                            cr.currency_code receipt_currency,
                            ps.trx_number trx_number,
                            gc.code_combination_id,
                            bs.name receipt_source,
                            bat.name batch_name,
                            l_cat.meaning category,
                            ard.currency_code currency_code,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''ALL'',gc.code_combination_id) account,
                            ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_BALANCING'',gc.code_combination_id) company,
                            ar_calc_aging.get_description(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_ACCOUNT'',gc.code_combination_id) account_desc
                     from  '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr,
                             ar_receipt_methods arm,
                            '||arp_recon_rep.var_tname.l_ar_cash_receipt_history_all||' crh,
                            gl_code_combinations gc,
                            hz_cust_accounts cust,
                            hz_parties  party,
                            '||arp_recon_rep.var_tname.l_ar_batches_all||' bat,
                            ar_batch_sources_all bs,
                            '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra,
                            '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' ps,
                            '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                            ar_lookups l_cat
                   where  nvl(ra.confirmed_flag,''Y'') = ''Y''
                   and  ra.status = ''APP''
		   and  cr.reversal_date IS NOT NULL
                   and  cr.cash_receipt_id = ra.cash_receipt_id
                   and  nvl(cr.confirmed_flag,''Y'') = ''Y''
                   and  cr.receipt_method_id = arm.receipt_method_id
                   and  crh.cash_receipt_id = cr.cash_receipt_id
                   and  crh.first_posted_record_flag = ''Y''
                   and  crh.batch_id = bat.batch_id(+)
                   and  ps.payment_schedule_id = ra.applied_payment_schedule_id
                   and  bat.batch_source_id = bs.batch_source_id(+)
                   and  bat.org_id = bs.org_id(+)
                   and  gc.code_combination_id = ard.code_combination_id
                   and  gc.chart_of_accounts_id = arp_recon_rep.get_chart_of_accounts_id()
                   and  ard.source_id = ra.receivable_application_id
                   and  ard.source_table = ''RA''
                   and  cr.pay_from_customer = cust.cust_account_id(+)
                   and  cust.party_id = party.party_id(+)
                   and  l_cat.lookup_type = ''ARRGTA_FUNCTION_MAPPING''
                   and  ((ra.amount_applied_from IS NULL
                         and l_cat.lookup_code = (''TRADE_''||ard.source_type))
                      or( ra.amount_applied_from IS NOT NULL
                          and l_cat.lookup_code = (''CCURR_''||ard.source_type))
                      or(ps.class =''BR'' and l_cat.lookup_code = (''BR_''||ard.source_type)))
                   '||l_ra_org_where||'
                   '||l_ard_org_where||'
                   '||l_ps_org_where||'
                   '||l_cr_org_where||'
                   '||l_crh_org_where||'
                   '||l_bat_org_where||'
                   '||l_bs_org_where||'
                   '||l_gl_date_ard_where ||'
                   '||l_co_seg_where ||'
                   '||l_account_where ||'
                   '||l_account_seg_where ||'
                   '||l_source_type_where||'
                   '||l_posting_status_ard_where;


   DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
   l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

   IF (l_majorVersion > 8 and l_majorVersion < 9) THEN
       BEGIN
           queryCtx := DBMS_XMLQuery.newContext(l_xml_query);
           DBMS_XMLQuery.setRaiseNoRowsException(queryCtx,TRUE);
           l_result := DBMS_XMLQuery.getXML(queryCtx);
           DBMS_XMLQuery.closeContext(queryCtx);
           l_rows_processed := 1;
       EXCEPTION WHEN OTHERS THEN
           DBMS_XMLQuery.getExceptionContent(queryCtx,l_errNo,l_errMsg);
           IF l_errNo = 1403 THEN
             l_rows_processed := 0;
           END IF;
           DBMS_XMLQuery.closeContext(queryCtx);
       END;
   ELSIF (l_majorVersion >= 9 ) THEN
       qryCtx   := DBMS_XMLGEN.newContext(l_xml_query);
       l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
       l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
       DBMS_XMLGEN.closeContext(qryCtx);
   END IF;

   IF l_rows_processed <> 0 THEN
       l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
       tempResult       := l_result;
   ELSE
       l_resultOffset   := 0;
   END IF;

   l_new_line := '
';

   select to_char(sysdate,'YYYY-MM-DD')
    into  l_report_date
   from   dual;

   /* Bug 4708930
      Get the special characters replaced */
    l_reporting_entity_name   :=  format_string(l_reporting_entity_name);
    l_reporting_level_name    :=  format_string(l_reporting_level_name);
    l_organization            :=  format_string(l_organization);
    l_receivable_mode_meaning :=  format_string(l_receivable_mode_meaning);
    l_status_meaning          :=  format_string(l_status_meaning);
    l_sob_name                :=  format_string(l_sob_name);
    l_message                 :=  format_string(l_message);
    l_message_acct	      :=  format_string(l_message_acct);

   /* Prepare the tag for the report heading */
   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   l_xml_header     := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<ARAPPJOURNAL>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT>'||l_message||'</MSG_TXT>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT_ACCT>'||l_message_acct||'</MSG_TXT_ACCT>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_LEVEL>'||l_reporting_level_name||'</REPORTING_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_ENTITY>'||l_reporting_entity_name||'</REPORTING_ENTITY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SOB_ID>'||p_sob_id||'</SOB_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_LOW>'||p_co_seg_low||'</CO_SEG_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_HIGH>'||p_co_seg_high||'</CO_SEG_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_FROM>'||to_char(fnd_date.canonical_to_date(p_gl_date_from),'YYYY-MM-DD')||'</GL_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_TO>'||to_char(fnd_date.canonical_to_date(p_gl_date_to),'YYYY-MM-DD')||'</GL_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <POSTING_STATUS>'||l_status_meaning||'</POSTING_STATUS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_LOW>'||p_gl_account_low||'</GL_ACCOUNT_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_HIGH>'||p_gl_account_high||'</GL_ACCOUNT_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SUMMARY_ACCOUNT>'||p_summary_account||'</SUMMARY_ACCOUNT>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REC_MODE_ONLY>'||l_receivable_mode_meaning||'</REC_MODE_ONLY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NUM_ROWS>'||l_rows_processed||'</NUM_ROWS>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'    <REPORT_HEADING>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SET_OF_BOOKS>'||l_sob_name||'</SET_OF_BOOKS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORGANIZATION>'||l_organization||'</ORGANIZATION>';
   l_xml_header     := l_xml_header ||l_new_line||'        <FUNCTIONAL_CURRENCY>'||l_functional_currency||'</FUNCTIONAL_CURRENCY>';
   l_xml_header     := l_xml_header ||l_new_line||'    </REPORT_HEADING>';

   l_close_tag      := l_new_line||'</ARAPPJOURNAL>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
      dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                    l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);

   ar_cumulative_balance_report.process_clob(tempResult);
   p_result :=  tempResult;

log('arapp_journal_load_xml (-)');

END arapp_journal_load_xml;

/*========================================================================+
 | PUBLIC PROCEDURE ARCM_JOURNAL_LOAD_XML                                 |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |  This procedure is used to generate the XML data required for reporting|
 |  ON Account Credit Memo Gain or Loss Journals                          |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 03-FEB-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/
PROCEDURE arcm_journal_load_xml (
          p_reporting_level       IN   VARCHAR2,
          p_reporting_entity_id   IN   NUMBER,
          p_sob_id                IN   NUMBER,
          p_coa_id                IN   NUMBER,
          p_co_seg_low            IN   VARCHAR2,
          p_co_seg_high           IN   VARCHAR2,
          p_gl_date_from          IN   VARCHAR2,
          p_gl_date_to            IN   VARCHAR2,
          p_posting_status        IN   VARCHAR2,
          p_gl_account_low        IN   VARCHAR2,
          p_gl_account_high       IN   VARCHAR2,
          p_summary_account       IN   NUMBER,
          p_receivable_mode       IN   VARCHAR2,
          p_result                OUT NOCOPY CLOB) IS
     l_result                CLOB;
     tempResult              CLOB;
     l_version               varchar2(20);
     l_compatibility         varchar2(20);
     l_suffix                varchar2(2);
     l_majorVersion          number;
     l_resultOffset          number;
     l_xml_header            varchar2(3000);
     l_xml_header_length     number;
     l_errNo                 NUMBER;
     l_errMsg                VARCHAR2(200);
     queryCtx                DBMS_XMLquery.ctxType;
     qryCtx                  DBMS_XMLGEN.ctxHandle;
     l_xml_query             VARCHAR2(32767);
     l_natural_segment_col   VARCHAR2(50);
     l_flex_value_set_id     NUMBER;
     l_code_combinations     VARCHAR2(32767);
     TYPE ref_cur IS REF CURSOR;
     l_xml_stmt              ref_cur;
     l_rows_processed        NUMBER;
     l_new_line              VARCHAR2(1) ;
     l_coa_id                NUMBER;  /*bug fix 5654975*/
     /* Variables to hold the report heading */
     l_sob_id                NUMBER;
     l_sob_name              VARCHAR2(100);
     l_functional_currency   VARCHAR2(15);
     l_organization          VARCHAR2(60);
     l_format                VARCHAR2(40);
     l_close_tag             VARCHAR2(100);
     l_reporting_entity_name VARCHAR2(80);
     l_reporting_level_name  VARCHAR2(30);
     l_status_meaning        VARCHAR2(30);
     l_receivable_mode_meaning VARCHAR2(10);
     /* Variables to hold the where clause based on the input parameters*/
     /* Variables length changed from 200 to 500 to address bug:5181586*/
     /* Increased variables length to 32767 for bug 5654975 */
     l_ard_org_where         VARCHAR2(32767);
     l_ps_org_where          VARCHAR2(32767);
     l_ps1_org_where         VARCHAR2(32767);
     l_ra_org_where          VARCHAR2(32767);
     l_sysparam_org_where    VARCHAR2(32767);
     /* Changes to variable length ends*/
     l_co_seg_where          VARCHAR2(32767);
     l_account_where         VARCHAR2(32767);
     l_account_seg_where     VARCHAR2(32767);
     l_gl_date_where         VARCHAR2(1000);
     l_source_type_where     VARCHAR2(32767);
     l_posting_status_where  VARCHAR2(1000);
     l_report_date           VARCHAR2(25);
     l_ld_sp                 VARCHAR2(1) := 'Y';
     l_message               VARCHAR2(2000);
     l_message_acct          VARCHAR2(1000);
     l_encoding		     VARCHAR2(20);
BEGIN

log('arcm_journal_load_xml (+)');

       /* Assign the input parameters to the global variables */
       arp_recon_rep.var_tname.g_reporting_level       := p_reporting_level;
       arp_recon_rep.var_tname.g_reporting_entity_id   := p_reporting_entity_id;
        /*  bug 5654975  p_coa_id,p_sob_id is passed incorrectly when the user
          has access to multiple Ledgers */
      -- arp_recon_rep.var_tname.g_set_of_books_id       := p_sob_id;
      -- arp_recon_rep.var_tname.g_chart_of_accounts_id  := p_coa_id;
       arp_recon_rep.var_tname.g_gl_date_from          := fnd_date.canonical_to_date(p_gl_date_from);
       arp_recon_rep.var_tname.g_gl_date_to            := fnd_date.canonical_to_date(p_gl_date_to);
       arp_recon_rep.var_tname.g_posting_status        := p_posting_status;

       /* Added Conditional Implication to address bug:5181586*/
       /* Added set of books id and chart of accounts id for bug fix 565497*/
       IF p_reporting_level = 1000 THEN
         SELECT  sob.name sob_name,
	         sob.set_of_books_id,
                 sob.currency_code functional_currency,
		 sob.chart_of_accounts_id
          INTO   l_sob_name,
	         l_sob_id,
                 l_functional_currency,
		 l_coa_id
          FROM   gl_sets_of_books sob
         WHERE  sob.set_of_books_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       ELSIF p_reporting_level = 3000 THEN
         SELECT sob.name sob_name,
	        sob.set_of_books_id,
                sob.currency_code functional_currency,
		sob.chart_of_accounts_id
           INTO l_sob_name,
	        l_sob_id,
                l_functional_currency,
                l_coa_id
           FROM gl_sets_of_books sob,
                ar_system_parameters_all sysparam
          WHERE sob.set_of_books_id = sysparam.set_of_books_id
            AND sysparam.org_id = arp_recon_rep.var_tname.g_reporting_entity_id;

       END IF;
       /* Changes for bug:5181586 ends*/
       arp_recon_rep.var_tname.g_set_of_books_id       := l_sob_id;
       arp_recon_rep.var_tname.g_chart_of_accounts_id  := l_coa_id;


       /* Initialize the reporting context */
       init(p_sob_id);

       /* Set the org conditions */

       XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

       l_ra_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('ra',NULL);
       l_ard_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('ard',NULL);
       l_ps_org_where        :=  XLA_MO_REPORTING_API.Get_Predicate('ps',NULL);
       l_ps1_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('ps1',NULL);
       l_sysparam_org_where  :=  XLA_MO_REPORTING_API.Get_Predicate('sysparam',NULL);


       /* Replace the bind variables with global functions */
       l_ra_org_where        := replace(l_ra_org_where,
                                     ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ard_org_where       := replace(l_ard_org_where,
                                    ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ps_org_where        := replace(l_ps_org_where,
                                    ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ps1_org_where       := replace(l_ps1_org_where,
                                    ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_sysparam_org_where  := replace(l_sysparam_org_where,
                                    ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,80);
       l_reporting_level_name :=  substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);

       /* Multi Org Uptake: Show appropriate message to the user depending upon the security profile */
       IF p_reporting_level = '1000' THEN
          l_ld_sp:= mo_utils.check_ledger_in_sp(p_reporting_entity_id);
       END IF;

       IF l_ld_sp = 'N' THEN
         FND_MESSAGE.SET_NAME('FND','FND_MO_RPT_PARTIAL_LEDGER');
         l_message := FND_MESSAGE.get;
       END IF;

       /* Bug fix 4942083*/
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                      p_reporting_entity_id,
                                      arp_recon_rep.var_tname.g_gl_date_from,
                                      arp_recon_rep.var_tname.g_gl_date_to) THEN
           FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');--Changed as per Bug 5578884 the parameter to AR from FND as the message is in AR product
           l_message_acct := FND_MESSAGE.Get;
       END IF;

       IF p_reporting_level = '3000' THEN
         select substrb(hou.name,1,60)
         into   l_organization
         from hr_organization_units hou
         where hou.organization_id = arp_recon_rep.var_tname.g_reporting_entity_id;
       ELSE
         select meaning
         into   l_organization
         from ar_lookups
         where lookup_code ='ALL' and lookup_type ='ALL';
       END IF;

       /* Build the WHERE clauses */
       /*Replaced p_coa_id with l_coa_id for bug 5654975 */

      IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
         l_co_seg_where := NULL;
      ELSIF p_co_seg_low IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '<=',
                         p_operand1 => p_co_seg_high);
      ELSIF p_co_seg_high IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '>=',
                         p_operand1 => p_co_seg_low);
      ELSE
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => l_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => 'BETWEEN',
                         p_operand1 => p_co_seg_low,
                         p_operand2 => p_co_seg_high);
      END IF;

      IF p_gl_date_from IS NULL and p_gl_date_to IS NULL THEN
         l_gl_date_where := NULL;
      ELSIF p_gl_date_from IS NULL THEN
         l_gl_date_where :=' and ra.gl_date <=  arp_recon_rep.get_gl_date_to()';
      ELSIF p_gl_date_to  IS NULL THEN
         l_gl_date_where :=' and ra.gl_date >=  arp_recon_rep.get_gl_date_from() ' ;
      ELSE
         l_gl_date_where := ' and ra.gl_date between arp_recon_rep.get_gl_date_from() and arp_recon_rep.get_gl_date_to() ';
      END IF;

      IF p_gl_account_low IS NOT NULL AND p_gl_account_high IS NOT NULL THEN
        l_account_where := ' AND ' || AR_CALC_AGING.FLEX_SQL(
                                                p_application_id=> 101,
                                                p_id_flex_code =>'GL#',
                                                p_id_flex_num =>l_coa_id,
                                                p_table_alias => 'gc',
                                                p_mode => 'WHERE',
                                                p_qualifier => 'ALL',
                                                p_function=> 'BETWEEN',
                                                p_operand1 => p_gl_account_low,
                                                p_operand2 => p_gl_account_high);
      ELSE
         l_account_where := NULL;
      END IF;

      IF p_summary_account IS NOT NULL THEN
          SELECT fcav.application_column_name, flex_value_set_id
          INTO   l_natural_segment_col , l_flex_value_set_id
          FROM   fnd_segment_attribute_values fcav,
                 fnd_id_flex_segments fifs
          WHERE  fcav.application_id = 101
          AND    fcav.id_flex_code = 'GL#'
          AND    fcav.id_flex_num = arp_recon_rep.var_tname.g_chart_of_accounts_id
          AND    fcav.attribute_value = 'Y'
          AND    fcav.segment_attribute_type = 'GL_ACCOUNT'
          AND    fifs.application_id = fcav.application_id
          AND    fifs.id_flex_code = fcav.id_flex_code
          AND    fifs.id_flex_num = fcav.id_flex_num
          AND    fcav.application_column_name = fifs.application_column_name;

         get_detail_accounts(l_flex_value_set_id, p_summary_account, l_code_combinations);

         l_account_seg_where := ' and gc.'||l_natural_segment_col||' in ('||l_code_combinations||' )';
     ELSE
         l_account_seg_where := NULL;
     END IF;

     IF nvl(p_receivable_mode,'N') = 'Y' THEN
        l_source_type_where := ' and ard.source_type in(''EXCH_GAIN'', ''EXCH_LOSS'')';
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'Y';
     ELSE
        l_source_type_where := NULL;
        select meaning
        into    l_receivable_mode_meaning
        from   fnd_lookups
        where  lookup_type = 'YES_NO'
        and    lookup_code = 'N';
     END IF;

     IF  p_posting_status IS NOT NULL THEN
        select meaning
        into   l_status_meaning
        from   ar_lookups
        where  lookup_type = 'POSTED_STATUS'
        and    lookup_code = arp_recon_rep.var_tname.g_posting_status;

       l_posting_status_where := 'and nvl(ra.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')) =
                                             decode(arp_recon_rep.get_posting_status(),
                                                    ''POSTED'',ra.gl_posted_date,
                                                    ''UNPOSTED'',TO_DATE(''01/01/0001'',''MM/DD/YYYY''),
                                                    nvl(ra.gl_posted_date,TO_DATE(''01/01/0001'',''MM/DD/YYYY'')))';
     ELSE
       l_status_meaning        := NULL;
       l_posting_status_where  := NULL;
     END IF;

   l_xml_query := '
                   select substrb(party.party_name,1,50) customer_name,
                          cust.account_number customer_number,
                          ps.trx_number cm_number,
                          ps1.trx_number trx_number,
                          nvl(ard.amount_dr,0) entered_debit,
                          nvl(ard.amount_cr,0) entered_credit,
                          nvl(ard.acctd_amount_dr,0) acctd_debit,
                          nvl(ard.acctd_amount_cr,0) acctd_credit,
                          to_char(ps.trx_date,''YYYY-MM-DD'') cm_date,
                          to_char(ps1.trx_date,''YYYY-MM-DD'') trx_date,
                          to_char(ra.gl_date,''YYYY-MM-DD'') app_gl_date,
                          to_char(ps.gl_date,''YYYY-MM-DD'') cm_gl_date,
                          to_char(ps1.gl_date,''YYYY-MM-DD'') trx_gl_date,
                          ps.invoice_currency_code   cm_currency_code,
                          ps1.invoice_currency_code  trx_currency_code,
                          to_char(ps.exchange_date,''YYYY-MM-DD'') cm_exchange_date,
                          to_char(ps1.exchange_date,''YYYY-MM-DD'') trx_exchange_date,
                          ps.exchange_rate cm_exchange_rate,
                          ps1.exchange_rate trx_exchange_rate,
                          l_cat.meaning category,
                          ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''ALL'',gc.code_combination_id) account,
                          ar_calc_aging.get_value(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_BALANCING'',gc.code_combination_id) company,
                          ar_calc_aging.get_description(101,''GL#'',arp_recon_rep.get_chart_of_accounts_id(),''GL_ACCOUNT'',gc.code_combination_id) account_desc
                    from '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra ,
                         '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard ,
                         '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' ps ,
                         '||arp_recon_rep.var_tname.l_ar_payment_schedules_all||' ps1 ,
                         gl_code_combinations gc,
                         hz_cust_accounts cust,
                         hz_parties  party,
                         ar_lookups l_cat
                   where nvl(ra.confirmed_flag,''Y'') = ''Y''
                     and ra.application_type = ''CM''
                     and ra.status = ''APP''
                     and ard.source_table = ''RA''
                     and ard.source_id = ra.receivable_application_id
                     and ra.payment_schedule_id = ps.payment_schedule_id
                     and ra.applied_payment_schedule_id = ps1.payment_schedule_id
                     and cust.cust_account_id = ps.customer_id
                     and cust.party_id = party.party_id
                     and gc.code_combination_id = ard.code_combination_id
                     and gc.chart_of_accounts_id = arp_recon_rep.get_chart_of_accounts_id()
                     and l_cat.lookup_type = ''ARRGTA_FUNCTION_MAPPING''
                     and l_cat.lookup_code = (''CMAPP_''||ard.source_type)
                     '||l_ard_org_where||'
                     '||l_ra_org_where||'
                     '||l_ps_org_where||'
                     '||l_ps1_org_where||'
                     '||l_gl_date_where ||'
                     '||l_co_seg_where ||'
                     '||l_account_where ||'
                     '||l_account_seg_where ||'
                     '||l_source_type_where||'
                     '||l_posting_status_where||'
                     order by company, category, account,app_gl_date, cm_number' ;

   DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
   l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

   IF (l_majorVersion > 8 and l_majorVersion < 9) THEN
       BEGIN
           queryCtx := DBMS_XMLQuery.newContext(l_xml_query);
           DBMS_XMLQuery.setRaiseNoRowsException(queryCtx,TRUE);
           l_result := DBMS_XMLQuery.getXML(queryCtx);
           DBMS_XMLQuery.closeContext(queryCtx);
           l_rows_processed := 1;
       EXCEPTION WHEN OTHERS THEN
           DBMS_XMLQuery.getExceptionContent(queryCtx,l_errNo,l_errMsg);
           IF l_errNo = 1403 THEN
             l_rows_processed := 0;
           END IF;
           DBMS_XMLQuery.closeContext(queryCtx);
       END;
   ELSIF (l_majorVersion >= 9 ) THEN
       qryCtx   := DBMS_XMLGEN.newContext(l_xml_query);
       l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
       l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
       DBMS_XMLGEN.closeContext(qryCtx);
   END IF;
   IF l_rows_processed <> 0 THEN
       l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
       tempResult       := l_result;
   ELSE
       l_resultOffset   := 0;
   END IF;

   l_new_line := '
';

   select to_char(sysdate,'YYYY-MM-DD')
    into  l_report_date
   from   dual;

   /* Bug 4708930
      Get the special characters replaced */
    l_reporting_entity_name   :=  format_string(l_reporting_entity_name);
    l_reporting_level_name    :=  format_string(l_reporting_level_name);
    l_organization            :=  format_string(l_organization);
    l_receivable_mode_meaning :=  format_string(l_receivable_mode_meaning);
    l_status_meaning          :=  format_string(l_status_meaning);
    l_sob_name                :=  format_string(l_sob_name);
    l_message                 :=  format_string(l_message);
    l_message_acct	      :=  format_string(l_message_acct);

   /* Prepare the tag for the report heading */
   l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
   l_xml_header     := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
   l_xml_header     := l_xml_header ||l_new_line||'<ARCMJOURNAL>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT>'||l_message||'</MSG_TXT>';
   l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT_ACCT>'||l_message_acct||'</MSG_TXT_ACCT>';
   l_xml_header     := l_xml_header ||l_new_line||'    <PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_LEVEL>'||l_reporting_level_name||'</REPORTING_LEVEL>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REPORTING_ENTITY>'||l_reporting_entity_name||'</REPORTING_ENTITY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SOB_ID>'||p_sob_id||'</SOB_ID>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_LOW>'||p_co_seg_low||'</CO_SEG_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <CO_SEG_HIGH>'||p_co_seg_high||'</CO_SEG_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_FROM>'||to_char(fnd_date.canonical_to_date(p_gl_date_from),'YYYY-MM-DD')||'</GL_DATE_FROM>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_DATE_TO>'||to_char(fnd_date.canonical_to_date(p_gl_date_to),'YYYY-MM-DD')||'</GL_DATE_TO>';
   l_xml_header     := l_xml_header ||l_new_line||'        <POSTING_STATUS>'||l_status_meaning||'</POSTING_STATUS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_LOW>'||p_gl_account_low||'</GL_ACCOUNT_LOW>';
   l_xml_header     := l_xml_header ||l_new_line||'        <GL_ACCOUNT_HIGH>'||p_gl_account_high||'</GL_ACCOUNT_HIGH>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SUMMARY_ACCOUNT>'||p_summary_account||'</SUMMARY_ACCOUNT>';
   l_xml_header     := l_xml_header ||l_new_line||'        <REC_MODE_ONLY>'||l_receivable_mode_meaning||'</REC_MODE_ONLY>';
   l_xml_header     := l_xml_header ||l_new_line||'        <NUM_ROWS>'||l_rows_processed||'</NUM_ROWS>';
   l_xml_header     := l_xml_header ||l_new_line||'    </PARAMETERS>';
   l_xml_header     := l_xml_header ||l_new_line||'    <REPORT_HEADING>';
   l_xml_header     := l_xml_header ||l_new_line||'        <SET_OF_BOOKS>'||l_sob_name||'</SET_OF_BOOKS>';
   l_xml_header     := l_xml_header ||l_new_line||'        <ORGANIZATION>'||l_organization||'</ORGANIZATION>';
   l_xml_header     := l_xml_header  ||l_new_line||'       <FUNCTIONAL_CURRENCY>'||l_functional_currency||'</FUNCTIONAL_CURRENCY>';
   l_xml_header     := l_xml_header  ||l_new_line||'  </REPORT_HEADING>';

   l_close_tag      := l_new_line||'</ARCMJOURNAL>'||l_new_line;
   l_xml_header_length := length(l_xml_header);
   IF l_rows_processed <> 0 THEN
      dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
      dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                    l_xml_header_length,l_resultOffset);
   ELSE
      dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
      dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
      dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
   END IF;

   dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);

   ar_cumulative_balance_report.process_clob(tempResult);
   p_result :=  tempResult;

log('arcm_journal_load_xml (-)');
END arcm_journal_load_xml;


/*========================================================================+
 | PUBLIC PROCEDURE ARGLRECON_LOAD_XML                                    |
 |                                                                        |
 | DESCRIPTION                                                            |
 |                                                                        |
 |  This procedure is used to generate the XML data required for          |
 |  creating the AR to GL Reconciliation Report                           |
 |                                                                        |
 | PSEUDO CODE/LOGIC                                                      |
 |                                                                        |
 | PARAMETERS                                                             |
 |                                                                        |
 |                                                                        |
 | KNOWN ISSUES                                                           |
 |                                                                        |
 | NOTES                                                                  |
 |                                                                        |
 |                                                                        |
 | MODIFICATION HISTORY                                                   |
 | Date                  Author            Description of Changes         |
 | 03-FEB-2004           rkader            Created                        |
 |                                                                        |
 *=======================================================================*/

PROCEDURE arglrecon_load_xml(
          p_reporting_level      IN   VARCHAR2,
          p_reporting_entity_id  IN   NUMBER,
          p_sob_id               IN   NUMBER,
          p_coa_id               IN   NUMBER,
          p_out_of_balance_only  IN   VARCHAR2,
          p_co_seg_low           IN   VARCHAR2,
          p_co_seg_high          IN   VARCHAR2,
          p_period_name          IN   VARCHAR2,
          p_gl_account_low       IN   VARCHAR2,
          p_gl_account_high      IN   VARCHAR2,
          p_summary_account      IN   VARCHAR2,
          p_result               OUT  NOCOPY CLOB) IS

     l_gl_date_from          date;
     l_gl_date_to            date;
     l_result                CLOB;
     tempResult              CLOB;
     l_version               varchar2(20);
     l_compatibility         varchar2(20);
     l_suffix                varchar2(2);
     l_majorVersion          number;
     l_resultOffset          number;
     l_rows_processed        number;
     l_xml_header            varchar2(1000);
     l_xml_header_length     number;
     queryCtx                DBMS_XMLquery.ctxType;
     qryCtx                  DBMS_XMLGEN.ctxHandle;
     l_xml_query             VARCHAR2(32767);
     l_natural_segment_col   VARCHAR2(50);
     l_flex_value_set_id     NUMBER;
     l_code_combinations     VARCHAR2(32767);
     l_new_line              VARCHAR2(1);
     /* Variables to hold the report heading */
     l_sob_id                NUMBER;
     l_sob_name              VARCHAR2(100);
     l_functional_currency   VARCHAR2(15);
     l_organization          VARCHAR2(60);
     l_format                VARCHAR2(40);
     l_close_tag             VARCHAR2(100);
     l_reporting_entity_name VARCHAR2(80);
     l_reporting_level_name  VARCHAR2(30);
     l_errNo                 NUMBER;
     l_errMsg                VARCHAR2(200);
     /* Variables to hold the where clause based on the input parameters*/
     /* Variables length changed from 200 to 500 to address bug:5181586*/
     /* Increased variables length to 32767 for bug 5654975 */
     l_ra_org_where          VARCHAR2(32767);
     l_crh_org_where         VARCHAR2(32767);
     l_cr_org_where          VARCHAR2(32767);/* Bug fix 6432847 */
     l_gl_dist_org_where     VARCHAR2(32767);
     l_mcd_org_where         VARCHAR2(32767);
     l_ard_org_where         VARCHAR2(32767);
     l_adj_org_where         VARCHAR2(32767);
     l_ath_org_where         VARCHAR2(32767);
     l_sysparam_org_where    VARCHAR2(32767);
     /* Changes to variable length ends*/
     l_co_seg_where          VARCHAR2(32767);
     l_account_where         VARCHAR2(32767);
     l_account_seg_where     VARCHAR2(32767);
     l_report_date           VARCHAR2(25);
     l_encoding		     VARCHAR2(20);
     l_message_acct          VARCHAR2(1000);
BEGIN

log('arglrecon_load_xml(+)');

       /* Assign the input parameters to the global variables */
       /* AR to GL Reconciliation Report can be run only for the Set of Books
          So hard coding the reporting_level and context */

       arp_recon_rep.var_tname.g_reporting_level       := 1000;
       arp_recon_rep.var_tname.g_reporting_entity_id   := p_reporting_entity_id;
       arp_recon_rep.var_tname.g_set_of_books_id       := p_reporting_entity_id;
       arp_recon_rep.var_tname.g_chart_of_accounts_id  := p_coa_id;
       arp_recon_rep.var_tname.g_period_name           := p_period_name;
       arp_recon_rep.var_tname.g_out_of_balance_only   := p_out_of_balance_only;

       /* Initialize the reporting context */
       init(p_sob_id);

       /* Set the org conditions */

       XLA_MO_REPORTING_API.Initialize(1000,p_reporting_entity_id, 'AUTO');

       l_ra_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('ra',NULL);
       l_adj_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('adj',NULL);
       l_ard_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('ard',NULL);
       l_gl_dist_org_where  :=  XLA_MO_REPORTING_API.Get_Predicate('gl_dist',NULL);
       l_sysparam_org_where :=  XLA_MO_REPORTING_API.Get_Predicate('sysparam',NULL);
       l_mcd_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('mcd',NULL);
       l_crh_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('crh',NULL);
       l_cr_org_where       :=  XLA_MO_REPORTING_API.Get_Predicate('cr',NULL); /* Bug fix 6432847 */
       l_ath_org_where      :=  XLA_MO_REPORTING_API.Get_Predicate('ath',NULL);

       /* Replace the bind variables with global functions */
       l_ra_org_where        :=  replace(l_ra_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_adj_org_where       :=  replace(l_adj_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ard_org_where       :=  replace(l_ard_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_gl_dist_org_where   :=  replace(l_gl_dist_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_sysparam_org_where  :=  replace(l_sysparam_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_mcd_org_where       :=  replace(l_mcd_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_crh_org_where       :=  replace(l_crh_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       /* Bug fix 6432847 */
       l_cr_org_where        :=  replace(l_cr_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');
       l_ath_org_where       :=  replace(l_ath_org_where,
                                   ':p_reporting_entity_id','arp_recon_rep.get_reporting_entity_id()');

       l_reporting_entity_name := substrb(XLA_MO_REPORTING_API.get_reporting_entity_name,1,80);
       l_reporting_level_name :=  substrb(XLA_MO_REPORTING_API.get_reporting_level_name,1,30);

       /* Get the org name */
         select meaning
         into   l_organization
         from ar_lookups
         where lookup_code ='ALL' and lookup_type ='ALL';

       /* Build the other WHERE clauses */
      IF p_co_seg_low IS NULL AND p_co_seg_high IS NULL THEN
         l_co_seg_where := NULL;
      ELSIF p_co_seg_low IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => p_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '<=',
                         p_operand1 => p_co_seg_high);
      ELSIF p_co_seg_high IS NULL THEN
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => p_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => '>=',
                         p_operand1 => p_co_seg_low);
      ELSE
         l_co_seg_where := ' AND ' ||
                AR_CALC_AGING.FLEX_SQL(p_application_id => 101,
                         p_id_flex_code => 'GL#',
                         p_id_flex_num => p_coa_id,
                         p_table_alias => 'GC',
                         p_mode => 'WHERE',
                         p_qualifier => 'GL_BALANCING',
                         p_function => 'BETWEEN',
                         p_operand1 => p_co_seg_low,
                         p_operand2 => p_co_seg_high);
      END IF;

      IF p_gl_account_low IS NOT NULL AND p_gl_account_high IS NOT NULL THEN
        l_account_where := ' AND ' || AR_CALC_AGING.FLEX_SQL(
                                                p_application_id=> 101,
                                                p_id_flex_code =>'GL#',
                                                p_id_flex_num =>p_coa_id,
                                                p_table_alias => 'gc',
                                                p_mode => 'WHERE',
                                                p_qualifier => 'ALL',
                                                p_function=> 'BETWEEN',
                                                p_operand1 => p_gl_account_low,
                                                p_operand2 => p_gl_account_high);
      ELSE
         l_account_where := NULL;
      END IF;


      IF p_summary_account IS NOT NULL THEN
          SELECT fcav.application_column_name, flex_value_set_id
          INTO   l_natural_segment_col , l_flex_value_set_id
          FROM   fnd_segment_attribute_values fcav,
                 fnd_id_flex_segments fifs
          WHERE  fcav.application_id = 101
          AND    fcav.id_flex_code = 'GL#'
          AND    fcav.id_flex_num = arp_recon_rep.var_tname.g_chart_of_accounts_id
          AND    fcav.attribute_value = 'Y'
          AND    fcav.segment_attribute_type = 'GL_ACCOUNT'
          AND    fifs.application_id = fcav.application_id
          AND    fifs.id_flex_code = fcav.id_flex_code
          AND    fifs.id_flex_num = fcav.id_flex_num
          AND    fcav.application_column_name = fifs.application_column_name;

         get_detail_accounts(l_flex_value_set_id, p_summary_account, l_code_combinations);

         l_account_seg_where := ' AND gc.'||l_natural_segment_col||' in ('||l_code_combinations||' )';
     ELSE
         l_account_seg_where := NULL;
     END IF;

         /* Get the report Headings */
         /* Added Conditional Implication to address bug:5181586*/
         IF p_reporting_level = 1000 THEN
           SELECT  sob.name sob_name,
                   sob.currency_code functional_currency
            INTO   l_sob_name,
                   l_functional_currency
            FROM   gl_sets_of_books sob
           WHERE  sob.set_of_books_id = arp_recon_rep.var_tname.g_reporting_entity_id;

         ELSIF p_reporting_level = 3000 THEN
           SELECT sob.name sob_name,
                  sob.currency_code functional_currency
             INTO l_sob_name,
                  l_functional_currency
             FROM gl_sets_of_books sob,
                  ar_system_parameters_all sysparam
            WHERE sob.set_of_books_id = sysparam.set_of_books_id
              AND sysparam.org_id = arp_recon_rep.var_tname.g_reporting_entity_id;

         END IF;
         /* Changes for bug:5181586 ends*/

        arp_recon_rep.var_tname.g_functional_currency       := l_functional_currency;

       /* Get the format mask for the function currency */
       select fnd_currency.get_format_mask(l_functional_currency,40)
         into l_format
         from dual;
       /* Get the period start and end dates */
       SELECT p.start_date, p.end_date
       INTO   l_gl_date_from , l_gl_date_to
       FROM    gl_periods p, gl_sets_of_books b
       WHERE   p.period_set_name = b.period_set_name
       AND     p.period_type = b.accounted_period_type
       AND     b.set_of_books_id = arp_recon_rep.var_tname.g_set_of_books_id
       AND     p.period_name = arp_recon_rep.var_tname.g_period_name;
        arp_recon_rep.var_tname.g_gl_date_from  := l_gl_date_from;
        arp_recon_rep.var_tname.g_gl_date_to    := l_gl_date_to;

       /* Bug fix 4942083*/
       IF arp_util.Open_Period_Exists(p_reporting_level,
                                      p_reporting_entity_id,
                                      arp_recon_rep.var_tname.g_gl_date_from,
                                      arp_recon_rep.var_tname.g_gl_date_to) THEN
           FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');--Changed as per Bug 5578884 the parameter to AR from FND as the message is in AR product
           l_message_acct := FND_MESSAGE.Get;
       END IF;

       execute immediate '
                          insert into ar_gl_recon_gt(code_combination_id,
                                                      receivables_dr,receivables_cr,
                                                      account_type, account_type_code)
               (select dat.code_combination_id,
                       sum(nvl(acctd_amount_dr,0)) receivables_debit,
                       sum(nvl(acctd_amount_cr,0)) receivables_credit,
                       lookup.description account_type,
                       gc.account_type account_type_code
                from (

-- Bug 6943555

                     select    decode(sign(sum(nvl(b.acctd_amount_dr,0))- sum(nvl(b.acctd_amount_cr,0))),
                              		      +1, (sum(nvl(b.acctd_amount_dr,0))- sum(nvl(b.acctd_amount_cr,0))),
		                                    0) acctd_amount_dr,
		                            decode(sign(sum(nvl(b.acctd_amount_dr,0))- sum(nvl(b.acctd_amount_cr,0))),
		                                    -1, (sum(nvl(b.acctd_amount_cr,0))- sum(nvl(b.acctd_amount_dr,0))),
		                                    0) acctd_amount_cr,
		                            b.code_combination_id

                     from

                      (select
                         DECODE(account_class, ''REC'',decode(sign(acctd_amount), -1 ,0, acctd_amount),
                                   ''REV'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
                                   ''TAX'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
                                   ''ROUND'',decode(sign(acctd_amount), -1,abs(acctd_amount),0),
                                   ''UNEARN'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
                                   ''FREIGHT'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
                          ''UNBILL'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),0) acctd_amount_dr,
                          DECODE(account_class, ''REC'',decode(sign(acctd_amount), -1 ,abs(acctd_amount),0),
                                ''REV'',decode(sign(acctd_amount), -1, 0,acctd_amount),
                                ''TAX'',decode(sign(acctd_amount), -1, 0,acctd_amount),
                                ''ROUND'',decode(sign(acctd_amount), -1,0,acctd_amount),
                                ''UNEARN'',decode(sign(acctd_amount), -1, 0,acctd_amount),
                                ''FREIGHT'',decode(sign(acctd_amount), -1, 0,acctd_amount),
                            ''UNBILL'',decode(sign(acctd_amount), -1, 0,acctd_amount),0) acctd_amount_cr,
                           gl_dist.code_combination_id code_combination_id,
                           gl_dist.ae_header_id ae_header_id,
                           gl_dist.ae_line_num  ae_line_num
                     from '||arp_recon_rep.var_tname.l_ra_cust_trx_gl_dist_all||' gl_dist
                     where gl_dist.gl_date between  :gl_date_from and :gl_date_to
		     /* Bug fix 6631925 */
		     and   gl_dist.account_set_flag = ''N''
                     and   gl_dist.posting_control_id <> -3
                     '||l_gl_dist_org_where||'
                     UNION ALL
                     select ard.acctd_amount_dr acctd_amount_dr ,
                            ard.acctd_amount_cr acctd_amount_cr ,
                            ard.code_combination_id code_combination_id,
                            ard.ae_header_id ae_header_id,
                            ard.ae_line_num  ae_line_num
                    from  '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_cash_receipt_history_all||' crh,
                          '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr /* Bug fix 6432847 */
                    where crh.gl_date between :gl_date_from and :gl_date_to
                      and crh.posting_control_id <> -3
                      and crh.cash_receipt_history_id = ard.source_id
                      /* Bug 6432847 : select receipts that are not reversed */
                      and  cr.cash_receipt_id = crh.cash_receipt_id
                      and  cr.reversal_date IS NULL
                      and  ard.source_table = ''CRH''
                      '||l_ard_org_where||'
                      '||l_crh_org_where||'
                      '||l_cr_org_where||'
                     /* Bug fix 6432847: select receipts that are reversed*/
                     UNION ALL
                     select ard.acctd_amount_dr acctd_amount_dr ,
                            ard.acctd_amount_cr acctd_amount_cr ,
                            ard.code_combination_id code_combination_id,
                            ard.ae_header_id ae_header_id,
                            ard.ae_line_num  ae_line_num
                    from  '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_cash_receipt_history_all||' crh,
                          '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr
                    where cr.reversal_date IS NOT NULL
                      and crh.cash_receipt_id = cr.cash_receipt_id
                      and crh.posting_control_id <> -3
                      and crh.cash_receipt_history_id = ard.source_id
                      and  ard.gl_date between :gl_date_from and :gl_date_to
                      and  ard.source_table = ''CRH''
                      '||l_ard_org_where||'
                      '||l_crh_org_where||'
                      '||l_cr_org_where||'
                     UNION ALL
                   /* Bug fix 6432847: with ra.gl_date condition, select
                      applications which are not unapplied */
                   select ard.acctd_amount_dr acctd_amount_dr ,
                          ard.acctd_amount_cr acctd_amount_cr ,
                          ard.code_combination_id code_combination_id,
                          ard.ae_header_id ae_header_id,
                          ard.ae_line_num  ae_line_num
                   from   '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra,
                          '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr /* Bug fix 6432847 */
                   where  ra.gl_date between :gl_date_from and :gl_date_to
                     and  cr.cash_receipt_id = ra.cash_receipt_id
                     and  cr.reversal_date IS NULL
                     and  ra.posting_control_id <> -3
                     and  ra.receivable_application_id = ard.source_id
                     and  ard.source_table = ''RA''
                     and  ra.application_type = ''CASH''
                      '||l_ard_org_where||'
                      '||l_ra_org_where||'
                      '||l_cr_org_where||'
                     UNION ALL
                   /* Bug fix 6432847: with ard.gl_date condition, select
                      applications which are unapplied */
                   select ard.acctd_amount_dr acctd_amount_dr ,
                          ard.acctd_amount_cr acctd_amount_cr ,
                          ard.code_combination_id code_combination_id,
                          ard.ae_header_id ae_header_id,
                          ard.ae_line_num  ae_line_num
                   from   '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra,
                          '||arp_recon_rep.var_tname.l_ar_cash_receipts_all||' cr /* Bug fix 6432847 */
                   where  ard.gl_date between :gl_date_from and :gl_date_to
                     and  cr.reversal_date IS NOT NULL
                     and  ra.cash_receipt_id = cr.cash_receipt_id
                     and  ra.posting_control_id <> -3
                     and  ra.receivable_application_id = ard.source_id
                     and  ard.source_table = ''RA''
                     and  ra.application_type = ''CASH''
                      '||l_ard_org_where||'
                      '||l_ra_org_where||'
                      '||l_cr_org_where||'
                  /* Bug fix 5679071 : UNAPP records should be displayed based on how it was posted */
                     UNION ALL
                    select ard.acctd_amount_dr acctd_amount_dr ,
                          ard.acctd_amount_cr acctd_amount_cr ,
                          ard.code_combination_id code_combination_id,
                          ard.ae_header_id ae_header_id,
                          ard.ae_line_num  ae_line_num
                   from   '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_receivable_apps_all||' ra
                     where  ard.gl_date between :gl_date_from and :gl_date_to
                     and  ra.posting_control_id <> -3
                     and  ra.receivable_application_id = ard.source_id
                     and  ard.source_table = ''RA''
                     and  ra.application_type <> ''CASH''
                      '||l_ard_org_where||'
                      '||l_ra_org_where||'
                     UNION ALL
                  select ard.acctd_amount_dr acctd_amount_dr ,
                     ard.acctd_amount_cr acctd_amount_cr ,
                     ard.code_combination_id code_combination_id,
                     ard.ae_header_id ae_header_id,
                     ard.ae_line_num  ae_line_num
                     from   '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_misc_cash_dists_all||' mcd
                   where ard.gl_date between :gl_date_from and :gl_date_to
                     and  mcd.posting_control_id <> -3
                     and  mcd.misc_cash_distribution_id = ard.source_id
                     and  ard.source_table = ''MCD''
                      '||l_ard_org_where||'
                      '||l_mcd_org_where||'
                     UNION ALL
               select ard.acctd_amount_dr acctd_amount_dr ,
                          ard.acctd_amount_cr acctd_amount_cr ,
                          ard.code_combination_id code_combination_id,
                          ard.ae_header_id ae_header_id,
                          ard.ae_line_num  ae_line_num
                   from    '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          '||arp_recon_rep.var_tname.l_ar_adjustments_all||' adj
                  where   adj.gl_date between :gl_date_from and :gl_date_to
                    and   adj.posting_control_id <> -3
                    and   adj.adjustment_id = ard.source_id
                    and   ard.source_table = ''ADJ''
                      '||l_ard_org_where||'
                      '||l_adj_org_where||'
                     UNION ALL
                   select ard.acctd_amount_dr acctd_amount_dr ,
                          ard.acctd_amount_cr acctd_amount_cr ,
                          ard.code_combination_id code_combination_id,
                          ard.ae_header_id ae_header_id,
                          ard.ae_line_num  ae_line_num
                   from '||arp_recon_rep.var_tname.l_ar_distributions_all||' ard,
                          ar_transaction_history_all ath
                    where ath.gl_date between :gl_date_from and :gl_date_to
                          and ath.posting_control_id <> -3
                    and   ath.transaction_history_id = ard.source_id
                    and   ard.source_table = ''TH''
                      '||l_ard_org_where||'
                      '||l_ath_org_where||'
/* 6964153 */
                     UNION ALL
                   SELECT xal.accounted_dr acctd_amount_dr,
			  xal.accounted_cr acctd_amount_cr,
			  xal.code_combination_id code_combination_id,
		          xal.ae_header_id ae_header_id,
			  xal.ae_line_num  ae_line_num
		          from   xla_ae_lines xal,
		                 xla_ae_headers xah,
		                 xla_transaction_entities_upg xte
		         where  xal.accounting_class_code = ''BALANCE''
		         and xah.ledger_id = xte.ledger_id
		         and    xah.entity_id = xte.entity_id
                         and    xal.ae_header_id = xah.ae_header_id
		         and    xah.accounting_date
                         between :gl_date_from and :gl_date_to
		         and    xal.application_id = 222
		         and    xah.application_id = 222
                         and    xte.application_id = 222
                         and    xte.ledger_id = :reporting_entity_id     )b

                 group by b.ae_header_id,b.ae_line_num,b.code_combination_id

                   ) dat,
                    gl_code_combinations gc,
                    gl_lookups lookup
               where dat.code_combination_id = gc.code_combination_id
                 and lookup.lookup_code = gc.account_type
                 and lookup.lookup_type = ''ACCOUNT TYPE'''||
                 l_co_seg_where||
                 l_account_where||
                 l_account_seg_where||'
               group by dat.code_combination_id,lookup.description, gc.code_combination_id,gc.account_type)'
       USING
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to,
             l_gl_date_from, l_gl_date_to, p_reporting_entity_id ;


            update ar_gl_recon_gt argt
            set (opening_balance_dr,
                 opening_balance_cr,
                 period_activity_dr,
                 period_activity_cr) = (select nvl(glb.begin_balance_dr,0),
                                               nvl(glb.begin_balance_cr,0),
                                               nvl(glb.period_net_dr,0),
                                               nvl(glb.period_net_cr,0)
                                         from  gl_balances glb
                                       where   glb.period_name = get_period_name()
                                        and    glb.code_combination_id = argt.code_combination_id
                                        and    glb.actual_flag = 'A'
                                        and    glb.ledger_id = get_set_of_books_id()
                                        and    glb.currency_code = get_functional_currency());

           update ar_gl_recon_gt argt
           set (subledger_not_ar_dr ,
                subledger_not_ar_cr ,
                subledger_manual_dr ,
                subledger_manual_cr ,
                subledger_rec_dr,
                subledger_rec_cr,
                gl_unposted_dr,
                gl_unposted_cr) =
                   (select sum(decode(gjh.je_source,'Manual', 0,
                                                    'Receivables', 0,
                                                    decode(gjl.status,
                                                           'P',gjl.accounted_dr,0))) subledger_not_ar_dr ,
                           sum(decode(gjh.je_source,'Manual', 0,
                                                    'Receivables', 0,
                                                    decode(gjl.status,
                                                           'P',gjl.accounted_cr,0))) subledger_not_ar_cr,
                           sum(decode(gjh.je_source, 'Manual',
                                          decode(gjl.status,'P',
                                                  gjl.accounted_dr,0),0)) subledger_manual_dr ,
                           sum(decode(gjh.je_source, 'Manual',
                                          decode(gjl.status,'P',
                                                  gjl.accounted_cr,0),0)) subledger_manual_cr,
                           sum(decode(gjh.je_source, 'Receivables',
                                          decode(gjl.status,'P',
                                                  gjl.accounted_dr,0),0)) subledger_receivables_dr ,
                           sum(decode(gjh.je_source, 'Receivables',
                                          decode(gjl.status,'P',
                                                  gjl.accounted_cr,0),0)) subledger_receivables_cr,
                           sum(decode(gjl.status,'P',0,gjl.accounted_dr)) gl_unposted_dr,
                           sum(decode(gjl.status,'P',0,gjl.accounted_cr)) gl_unposted_cr
                      from gl_je_lines gjl,
                           gl_je_headers gjh
                     where gjl.code_combination_id = argt.code_combination_id
                       and gjl.period_name = get_period_name()
                       and gjl.ledger_id = get_set_of_books_id()
                       and gjl.je_header_id = gjh.je_header_id
                       and gjh.actual_flag = 'A'
                       and gjh.currency_code <> 'STAT'
                     group by gjl.code_combination_id);

                     update ar_gl_recon_gt argt
                     set (gl_interface_dr, gl_interface_cr) =
                             (select sum(nvl(gif.accounted_dr,0)) gl_interface_dr,
                                     sum(nvl(gif.accounted_cr,0)) gl_interface_cr
                               from  gl_interface gif,
                                     gl_je_sources gjs
                               where gif.code_combination_id = argt.code_combination_id
                                and  gif.accounting_date between get_gl_date_from() and get_gl_date_to()
                                and  gif.user_je_source_name = gjs.user_je_source_name
                                and  gjs.je_source_name = 'Receivables'
                                and  gif.actual_flag = 'A'
                               group by gif.code_combination_id);

             update ar_gl_recon_gt
               set account = ar_calc_aging.get_value(101,'GL#',
                             arp_recon_rep.get_chart_of_accounts_id(),'ALL',code_combination_id),
                   company = ar_calc_aging.get_value(101,'GL#',
                             arp_recon_rep.get_chart_of_accounts_id(),'GL_BALANCING',code_combination_id),
                  account_desc = ar_calc_aging.get_description(101,'GL#',
                           arp_recon_rep.get_chart_of_accounts_id(),'GL_ACCOUNT',code_combination_id);

          l_xml_query := '
                          select code_combination_id,
                                 account_type,
                                 account,
                                 account_desc,
                                 company,
                                 decode(account_type_code,''A'',1,''L'',2,''R'',3,''E'',4) account_type_code,
                                 nvl(opening_balance_dr,0)  begin_gl_bal_debit,
                                 nvl(opening_balance_cr,0)  begin_gl_bal_credit,
                                 nvl(opening_balance_dr,0)+nvl(period_activity_dr,0) end_gl_bal_debit,
                                 nvl(opening_balance_cr,0)+nvl(period_activity_cr,0) end_gl_bal_credit,
                                 nvl(subledger_not_ar_dr,0) subledger_not_ar_debit,
                                 nvl(subledger_not_ar_cr,0) subledger_not_ar_credit,
                                 nvl(subledger_manual_dr,0) subledger_manual_debit,
                                 nvl(subledger_manual_cr,0) subledger_manual_credit,
                                 nvl(subledger_rec_dr,0) subledger_receivables_debit,
                                 nvl(subledger_rec_cr,0) subledger_receivables_credit,
                                 nvl(gl_unposted_dr,0)  gl_unposted_debit,
                                 nvl(gl_unposted_cr,0)  gl_unposted_credit,
                                 nvl(gl_interface_dr,0) gl_interface_debit,
                                 nvl(gl_interface_cr,0) gl_interface_credit,
                                 nvl(receivables_dr,0)  receivables_debit,
                                 nvl(receivables_cr,0)  receivables_credit
                            from ar_gl_recon_gt
                            where ''N'' = arp_recon_rep.get_out_of_balance_only()
                             or   nvl(receivables_dr,0)- nvl(subledger_rec_dr,0) <> 0
                             or   nvl(receivables_cr,0)- nvl(subledger_rec_cr,0) <> 0
                            order by account_type_code,
                                     company,
                                     ar_calc_aging.get_value(101,''GL#'',
                                                          arp_recon_rep.get_chart_of_accounts_id(),
                                                          ''GL_ACCOUNT'',code_combination_id)';

   DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
   l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

   IF (l_majorVersion > 8 and l_majorVersion < 9) THEN
       BEGIN
           queryCtx := DBMS_XMLQuery.newContext(l_xml_query);
           DBMS_XMLQuery.setRaiseNoRowsException(queryCtx,TRUE);
           l_result := DBMS_XMLQuery.getXML(queryCtx);
           DBMS_XMLQuery.closeContext(queryCtx);
           l_rows_processed := 1;
       EXCEPTION WHEN OTHERS THEN
           DBMS_XMLQuery.getExceptionContent(queryCtx,l_errNo,l_errMsg);
           IF l_errNo = 1403 THEN
             l_rows_processed := 0;
           END IF;
           DBMS_XMLQuery.closeContext(queryCtx);
       END;
   ELSIF (l_majorVersion >= 9 ) THEN
       qryCtx   := DBMS_XMLGEN.newContext(l_xml_query);
       l_result := DBMS_XMLGEN.getXML(qryCtx,DBMS_XMLGEN.NONE);
       l_rows_processed := DBMS_XMLGEN.getNumRowsProcessed(qryCtx);
       DBMS_XMLGEN.closeContext(qryCtx);
   END IF;

   IF l_rows_processed <> 0 THEN
       l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
       tempResult       := l_result;
   ELSE
       l_resultOffset   := 0;
   END IF;

   l_new_line := '
';
   select to_char(sysdate,'YYYY-MM-DD')
    into  l_report_date
   from   dual;

   /* Bug 4708930
      Get the special characters replaced */
    l_reporting_entity_name   :=  format_string(l_reporting_entity_name);
    l_reporting_level_name    :=  format_string(l_reporting_level_name);
    l_organization            :=  format_string(l_organization);
    l_sob_name                :=  format_string(l_sob_name);
    l_message_acct            :=  format_string(l_message_acct);

                /* Prepare the tag for the report heading */
                l_encoding       := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
                l_xml_header     := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
                l_xml_header     := l_xml_header ||l_new_line||'<ARGLRECON>';
                l_xml_header     := l_xml_header ||l_new_line||' <MSG_TXT_ACCT>'||l_message_acct||'</MSG_TXT_ACCT>';
                l_xml_header     := l_xml_header ||l_new_line||'<PERIOD>'||p_period_name||'</PERIOD>';
                l_xml_header     := l_xml_header ||l_new_line||'<REPORT_DATE>'||l_report_date||'</REPORT_DATE>';
                l_xml_header     := l_xml_header ||l_new_line||'<REPORTING_LEVEL>'||l_reporting_level_name||'</REPORTING_LEVEL>';
                l_xml_header     := l_xml_header ||l_new_line||'<REPORTING_ENTITY>'||l_reporting_entity_name||'</REPORTING_ENTITY>';
                l_xml_header     := l_xml_header ||l_new_line||'<SOB_ID>'||p_sob_id||'</SOB_ID>';
                l_xml_header     := l_xml_header ||l_new_line||'<OUT_OF_BAL_ONLY>'||p_out_of_balance_only||'</OUT_OF_BAL_ONLY>';
                l_xml_header     := l_xml_header ||l_new_line||'<CO_SEG_LOW>'||p_co_seg_low||'</CO_SEG_LOW>';
                l_xml_header     := l_xml_header ||l_new_line||'<CO_SEG_HIGH>'||p_co_seg_high||'</CO_SEG_HIGH>';
                l_xml_header     := l_xml_header ||l_new_line||'<GL_DATE_FROM>'||to_char(l_gl_date_from,'YYYY-MM-DD')||'</GL_DATE_FROM>';
                l_xml_header     := l_xml_header ||l_new_line||'<GL_DATE_TO>'||to_char(l_gl_date_to,'YYYY-MM-DD')||'</GL_DATE_TO>';
                l_xml_header     := l_xml_header ||l_new_line||'<GL_ACCOUNT_LOW>'||p_gl_account_low||'</GL_ACCOUNT_LOW>';
                l_xml_header     := l_xml_header ||l_new_line||'<GL_ACCOUNT_HIGH>'||p_gl_account_high||'</GL_ACCOUNT_HIGH>';
                l_xml_header     := l_xml_header ||l_new_line||'<SUMMARY_ACCOUNT>'||p_summary_account||'</SUMMARY_ACCOUNT>';
                l_xml_header     := l_xml_header ||l_new_line||'<SET_OF_BOOKS>'||l_sob_name||'</SET_OF_BOOKS>';
                l_xml_header     := l_xml_header ||l_new_line||'<ORGANIZATION>'||l_organization||'</ORGANIZATION>';
                l_xml_header     := l_xml_header ||l_new_line||'<FUNCTIONAL_CURRENCY>'||l_functional_currency||'</FUNCTIONAL_CURRENCY>';
                l_xml_header     := l_xml_header ||l_new_line||'<NUM_ROWS>'||l_rows_processed||'</NUM_ROWS>';
                l_xml_header     := l_xml_header ||l_new_line||'<CURRENCY_FORMAT>'||l_format||'</CURRENCY_FORMAT>'||l_new_line;
                l_close_tag      := l_new_line||'</ARGLRECON>'||l_new_line;

        l_xml_header_length := length(l_xml_header);
        IF l_rows_processed <> 0 THEN
           dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
           dbms_lob.copy(tempResult,l_result,dbms_lob.getlength(l_result)-l_resultOffset,
                         l_xml_header_length,l_resultOffset);
        ELSE
           dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
           dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
           dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
        END IF;

        dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);

        ar_cumulative_balance_report.process_clob(tempResult);
        p_result :=  tempResult;

log('arglrecon_load_xml(-)');

END arglrecon_load_xml;

END ARP_RECON_REP;

/
