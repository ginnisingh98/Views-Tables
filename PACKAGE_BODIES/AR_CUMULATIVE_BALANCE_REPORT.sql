--------------------------------------------------------
--  DDL for Package Body AR_CUMULATIVE_BALANCE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_CUMULATIVE_BALANCE_REPORT" AS
/* $Header: ARXCUABB.pls 120.12.12010000.2 2009/05/18 06:10:52 tthangav ship $ */


  -- comments
  -- company segment is GL_BALANCING
  -- natural account segment is GL_ACCOUNT

  TYPE flex_table IS TABLE OF FND_FLEX_VALUES.flex_value%TYPE
    INDEX BY BINARY_INTEGER;

  TYPE gl_accounts_type
  IS TABLE OF  ar_ccid_by_gl_accounts.gl_account%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE components_type
  IS TABLE OF ar_gl_acct_balances.component%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE natural_accounts_type
  IS TABLE OF gl_code_combinations.segment1%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE trx_type_type
  IS TABLE OF ar_receipt_methods.name%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE trx_number_type
  IS TABLE OF ar_cash_receipts_all.receipt_number%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE trx_date_type
  IS TABLE OF ra_customer_trx_all.trx_date%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE currency_code_type
  IS TABLE OF ra_customer_trx_all.invoice_currency_code%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE gl_date_type
  IS TABLE OF --{Replace ra_cust_trx_line_gl_dist_all.gl_date%TYPE by
              ar_xla_ctlgd_lines_v.gl_date%TYPE
              --}
  INDEX BY BINARY_INTEGER;

  TYPE acctd_amount_dr_type
  IS TABLE OF ar_gl_acct_balances.acctd_amount_dr%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE acctd_amount_cr_type
  IS TABLE OF ar_gl_acct_balances.acctd_amount_cr%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE amount_dr_type
  IS TABLE OF ar_gl_acct_balances.amount_dr%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE amount_cr_type
  IS TABLE OF ar_gl_acct_balances.amount_cr%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE code_combination_id_type
  IS TABLE OF ar_gl_acct_balances.code_combination_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE customer_trx_id_type
  IS TABLE OF ar_gl_acct_balances.customer_trx_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE cash_receipt_id_type
  IS TABLE OF ar_gl_acct_balances.cash_receipt_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE adjustment_id_type
  IS TABLE OF ar_gl_acct_balances.adjustment_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE org_id_type
  IS TABLE OF ar_gl_acct_balances.org_id%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE last_update_date_type
  IS TABLE OF ar_gl_acct_balances.last_update_date%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE last_updated_by_type
  IS TABLE OF ar_gl_acct_balances.last_updated_by%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE creation_date_type
  IS TABLE OF ar_gl_acct_balances.creation_date%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE created_by_type
  IS TABLE OF ar_gl_acct_balances.created_by%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE last_update_login_type
  IS TABLE OF ar_gl_acct_balances.last_update_login%TYPE
  INDEX BY BINARY_INTEGER;

  TYPE ref_cur IS REF CURSOR;

  g_ar_system_parameters      	VARCHAR2(40) DEFAULT NULL;
  g_ar_system_parameters_all    VARCHAR2(40) DEFAULT NULL;
  g_ar_adjustments 		VARCHAR2(40) DEFAULT NULL;
  g_ar_adjustments_all 		VARCHAR2(40) DEFAULT NULL;
  g_ar_cash_receipt_history	VARCHAR2(40) DEFAULT NULL;
  g_ar_cash_receipt_history_all	VARCHAR2(40) DEFAULT NULL;
  g_ar_cash_receipts 		VARCHAR2(40) DEFAULT NULL;
  g_ar_cash_receipts_all	VARCHAR2(40) DEFAULT NULL;
  g_ar_distributions		VARCHAR2(40) DEFAULT NULL;
  g_ar_distributions_all	VARCHAR2(40) DEFAULT NULL;
  g_ra_customer_trx		VARCHAR2(40) DEFAULT NULL;
  g_ra_customer_trx_all		VARCHAR2(40) DEFAULT NULL;
  g_ra_cust_trx_gl_dist		VARCHAR2(40) DEFAULT NULL;
  g_ra_cust_trx_gl_dist_all	VARCHAR2(40) DEFAULT NULL;
  g_ar_misc_cash_dists		VARCHAR2(40) DEFAULT NULL;
  g_ar_misc_cash_dists_all	VARCHAR2(40) DEFAULT NULL;
  g_ar_receivable_apps 		VARCHAR2(40) DEFAULT NULL;
  g_ar_receivable_apps_all	VARCHAR2(40) DEFAULT NULL;
  g_ar_receipt_methods          VARCHAR2(40) DEFAULT NULL;
  g_ra_cust_trx_types           VARCHAR2(40) DEFAULT NULL;
  g_ra_cust_trx_types_all       VARCHAR2(40) DEFAULT NULL;
  g_ar_transaction_history      VARCHAR2(40) DEFAULT NULL;
  g_ar_transaction_history_all  VARCHAR2(40) DEFAULT NULL;

  -- Variables to hold the where clause based on the input parameters
  /* Variable length increased from 200 to 500 for bug:5181586*/
  g_dist_org_where        VARCHAR2(500);
  g_crh_org_where         VARCHAR2(500);
  g_cr_org_where          VARCHAR2(500);
  g_rm_org_where          VARCHAR2(500);
  g_mcd_org_where         VARCHAR2(500);
  g_br_org_where          VARCHAR2(500);
  g_adj_org_where         VARCHAR2(500);
  g_ard_org_where         VARCHAR2(500);
  g_trx_org_where         VARCHAR2(500);
  g_rec_org_where         VARCHAR2(500);
  g_type_org_where        VARCHAR2(500);
  g_sys_org_where    	  VARCHAR2(500);
  g_balances_where        VARCHAR2(500);
  /* Change for bug:5181586 ends*/
  detail flex_table;
  pg_debug VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');


PROCEDURE debug (p_string VARCHAR2, p_mode VARCHAR2 DEFAULT 'ALWAYS') IS

BEGIN

  IF (p_mode = 'ALWAYS') THEN

    fnd_file.put_line (
      which => fnd_file.log,
      buff  => p_string);

  ELSIF pg_debug IN ('Y', 'C') THEN

    fnd_file.put_line (
      which => fnd_file.log,
      buff  => p_string);

  END IF;

END debug;


PROCEDURE process_clob (p_xml_clob CLOB) IS

  l_clob_size   NUMBER;
  l_offset      NUMBER;
  l_chunk_size  INTEGER;
  l_chunk       VARCHAR2(32767);

  l_chunk1       VARCHAR2(32767);
  l_chunk2       VARCHAR2(32767);
  l_offset_temp number;

BEGIN

  debug('ar_cumulative_balance_report.process_clob(+)');

  -- get length of internal lob and open the dest. file.
  l_clob_size := dbms_lob.getlength(p_xml_clob);

  IF (l_clob_size = 0) THEN
    debug('CLOB is empty');
    RETURN;
  END IF;

  l_offset     := 1;
  l_chunk_size := 3000;

  debug('Unloading... '  || l_clob_size);

  WHILE (l_clob_size > 0) LOOP

    -- debug('Off Set: ' || l_offset);

    l_chunk := dbms_lob.substr (p_xml_clob, l_chunk_size, l_offset);

     --debug('Off Set: ' || l_offset);
     --debug(l_chunk);

     -- Bug 6696706 - As per input from fnd bug 6868010 this is modified

     l_offset_temp :=  DBMS_LOB.INSTR(l_chunk,'</',1,1);
     l_offset_temp :=  DBMS_LOB.INSTR(l_chunk,'>',l_offset_temp,1);
     l_chunk1 := dbms_lob.substr (l_chunk, l_offset_temp, 1);
     l_chunk2 := dbms_lob.substr (l_chunk, l_chunk_size-l_offset_temp, l_offset_temp+1);

    fnd_file.put(
      which => fnd_file.output,
      buff  => l_chunk1);
    fnd_file.new_line(fnd_file.output);
    fnd_file.put(
      which => fnd_file.output,
      buff  => l_chunk2);

    /*fnd_file.put(
      which => fnd_file.output,
      buff  => l_chunk);*/

     -- Bug 6696706 ends

    l_clob_size := l_clob_size - l_chunk_size;
    l_offset := l_offset + l_chunk_size;

  END LOOP;

  fnd_file.new_line(fnd_file.output,1);

  debug('ar_cumulative_balance_report.process_clob(-)');

EXCEPTION
  WHEN OTHERS THEN
    debug('EXCEPTION: OTHERS process_clob');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

END process_clob;


FUNCTION get_gl_account_segment
  RETURN VARCHAR2 IS

  l_gl_account_segment  varchar2(50);

  CURSOR segment IS
   SELECT application_column_name
   FROM   fnd_segment_attribute_values
   WHERE attribute_value  = 'Y'
   AND segment_attribute_type = 'GL_ACCOUNT'
   AND id_flex_num in
   (SELECT chart_of_accounts_id
    FROM   gl_sets_of_books sob,
           ar_system_parameters sys
    WHERE sob.set_of_books_id = sys.set_of_books_id);

BEGIN

  debug('ar_cumulative_balance_report.get_gl_account_segment(+)');

  OPEN  segment;
  FETCH segment INTO l_gl_account_segment;
  CLOSE segment;

  debug('ar_cumulative_balance_report.get_gl_account_segment(-)');
  RETURN l_gl_account_segment;

END get_gl_account_segment;


PROCEDURE perform_updates IS

  l_update_stmt         VARCHAR2(32767);

BEGIN

  debug('ar_cumulative_balance_report.perform_updates(+)');

  -- update null trx number, type, date, currency for invoices and CMS.

  l_update_stmt :=
    'UPDATE ar_base_gl_acct_balances bal
     SET (trx_number, trx_type, trx_date, currency) =
     (
      SELECT receipt_number, rm.name, receipt_date, currency_code
      FROM ' || g_ar_cash_receipts_all || ', '
             || g_ar_receipt_methods || '
      WHERE  cr.receipt_method_id = rm.receipt_method_id
      AND    cr.cash_receipt_id = bal.cash_receipt_id
      AND    rownum = 1
     )
     WHERE bal.cash_receipt_id IS NOT NULL
     AND   bal.trx_number IS NULL';

  l_update_stmt := l_update_stmt || g_balances_where;
  debug(l_update_stmt, 'N');

  EXECUTE IMMEDIATE l_update_stmt;

  debug('update statement 2(a): ' || SQL%ROWCOUNT);

  l_update_stmt :=
    'UPDATE ar_gl_acct_balances bal
     SET (trx_number, trx_type, trx_date, currency) =
     (
      SELECT receipt_number, rm.name, receipt_date, currency_code
      FROM ' || g_ar_cash_receipts_all || ', '
             || g_ar_receipt_methods || '
      WHERE  cr.receipt_method_id = rm.receipt_method_id
      AND    cr.cash_receipt_id = bal.cash_receipt_id
      AND    rownum = 1
     )
     WHERE bal.cash_receipt_id IS NOT NULL
     AND   bal.trx_number IS NULL';

  debug(l_update_stmt, 'N');

  EXECUTE IMMEDIATE l_update_stmt;

  debug('update statement 2(b): ' || SQL%ROWCOUNT);


  -- update null trx number, type, date, currency for invoices and CMS.

  l_update_stmt :=
    'UPDATE ar_base_gl_acct_balances bal
     SET (trx_number, trx_type, trx_date, currency) =
     (
      SELECT trx_number, ctt.name, trx_date, invoice_currency_code
      FROM ' || g_ra_customer_trx_all || ', '
             || g_ra_cust_trx_types_all || '
      WHERE  trx.cust_trx_type_id = ctt.cust_trx_type_id
      AND    trx.customer_trx_id = bal.customer_trx_id
      AND    rownum = 1
     )
     WHERE bal.customer_trx_id IS NOT NULL
     AND   bal.trx_number IS NULL';

  l_update_stmt := l_update_stmt || g_balances_where;
  debug(l_update_stmt, 'N');

  EXECUTE IMMEDIATE l_update_stmt;

  debug('update statement 1(a): ' || SQL%ROWCOUNT);


  l_update_stmt :=
    'UPDATE ar_gl_acct_balances bal
     SET (trx_number, trx_type, trx_date, currency) =
     (
      SELECT trx_number, ctt.name, trx_date, invoice_currency_code
      FROM ' || g_ra_customer_trx_all || ', '
             || g_ra_cust_trx_types_all || '
      WHERE  trx.cust_trx_type_id = ctt.cust_trx_type_id
      AND    trx.customer_trx_id = bal.customer_trx_id
      AND    rownum = 1
     )
     WHERE bal.customer_trx_id IS NOT NULL
     AND   bal.trx_number IS NULL';

  debug(l_update_stmt, 'N');

  EXECUTE IMMEDIATE l_update_stmt;

  debug('update statement 1(b): ' || SQL%ROWCOUNT);

  COMMIT;

  debug('ar_cumulative_balance_report.perform_updates(-)');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: NO_DATA_FOUND perform_updates');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: OTHERS perform_updates');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

END perform_updates;


PROCEDURE insert_dist_data (
  p_start_date        DATE,
  p_end_date          DATE,
  p_period_status     VARCHAR2) IS

  components_tab        components_type;
  gl_account_tab        gl_accounts_type;
  natural_account_tab   natural_accounts_type;
  trx_type_tab          trx_type_type;
  trx_number_tab        trx_number_type;
  trx_date_tab          trx_date_type;
  currency_code_tab     currency_code_type;
  gl_date_tab           gl_date_type;
  last_update_date_tab  last_update_date_type;
  last_updated_by_tab   last_updated_by_type;
  creation_date_tab     creation_date_type;
  created_by_tab        created_by_type;
  last_update_login_tab last_update_login_type;
  acctd_amount_dr_tab   acctd_amount_dr_type;
  acctd_amount_cr_tab   acctd_amount_cr_type;
  amount_dr_tab         amount_dr_type;
  amount_cr_tab         amount_cr_type;
  code_combination_id_tab  code_combination_id_type;
  customer_trx_id_tab   customer_trx_id_type;
  cash_receipt_id_tab   cash_receipt_id_type;
  adjustment_id_tab     adjustment_id_type;
  org_id_tab            org_id_type;
  l_last_fetch          boolean;
  l_sql_stmt            VARCHAR2(32767);
  l_ref_cursor          ref_cur;
  l_user_id             fnd_user.user_id%TYPE;
  l_precision           fnd_currencies.precision%TYPE;

  CURSOR precision IS
    SELECT cur.precision
    FROM   gl_sets_of_books sob,
           fnd_currencies cur
    WHERE  sob.currency_code = cur.currency_code
    AND    sob.set_of_books_id = arp_standard.sysparm.set_of_books_id;

BEGIN

  debug('ar_cumulative_balance_report.insert_dist_data(+)');
  debug('start date: ' || to_char(p_start_date));
  debug('end date: '   || to_char(p_end_date));
  debug('status: '     || p_period_status);

  l_user_id := fnd_global.user_id;

  debug('l_user_id: ' || l_user_id);

  -- In order to round the amount columns we must figure how many places
  -- we must round.  That is being determined here by looking at the
  -- currency precision of the set of books.

  OPEN precision;
  FETCH precision INTO l_precision;
  CLOSE precision;

  debug('rounding precision: ' || l_precision);

  l_sql_stmt :=
   'SELECT
      MAX(component),
      MAX(gl_account) gl_account,
      natural_account,
      trx_type,
      trx_number,
      trx_date,
      entered_currency,
      MAX(activity_gl_date) activity_gl_date,
      round(sum(acctd_amt_dr), ' || l_precision || ') acctd_amt_dr,
      round(sum(acctd_amt_cr), ' || l_precision || ') acctd_amt_cr,
      round(sum(amount_dr), ' || l_precision || ') amount_dr,
      round(sum(amount_cr), ' || l_precision || ') amount_cr,
      code_combination_id,
      customer_trx_id,
      cash_receipt_id,
      adjustment_id,
      max(org_id) org_id,
      sysdate creation_date,
      ' || l_user_id || '  created_by,
      sysdate last_update_date,
      ' || l_user_id || '  last_updated_by,
      ' || l_user_id || '  last_update_login
    FROM
    (
      -- pick up distributions from the ra_cust_trx_line_gl_dist_all
      SELECT
        ''DIST'' component,
        MAX(glc.gl_account) gl_account,
        glc.natural_account,
        ctt.name trx_type,
        trx_number,
        trx_date,
        invoice_currency_code entered_currency,
        MAX(dist.gl_date) activity_gl_date,
        sum(DECODE(account_class,
              ''REC'',decode(sign(acctd_amount),-1,0,acctd_amount),
              ''REV'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
              ''TAX'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
              ''ROUND'',decode(sign(acctd_amount), -1,abs(acctd_amount),0),
              ''UNEARN'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
              ''UNBILL'',decode(sign(acctd_amount), -1, abs(acctd_amount),0),
              ''SUSPENSE'',decode(sign(acctd_amount),-1, abs(acctd_amount),0),0))
                 acctd_amt_dr,
         sum(DECODE(account_class,
              ''REC'',decode(sign(acctd_amount),-1,abs(acctd_amount),0),
              ''REV'',decode(sign(acctd_amount), -1, 0,acctd_amount),
              ''TAX'',decode(sign(acctd_amount), -1, 0,acctd_amount),
              ''ROUND'',decode(sign(acctd_amount), -1,0,acctd_amount),
              ''UNEARN'',decode(sign(acctd_amount), -1, 0,acctd_amount),
              ''UNBILL'',decode(sign(acctd_amount), -1, 0,acctd_amount),
              ''SUSPENSE'',decode(sign(acctd_amount), -1, 0,acctd_amount),0))
                 acctd_amt_cr ,
         sum(DECODE(account_class,
              ''REC'',decode(sign(amount), -1 ,0, amount),
              ''REV'',decode(sign(amount), -1, abs(amount),0),
              ''TAX'',decode(sign(amount), -1, abs(amount),0),
              ''ROUND'',decode(sign(amount), -1,abs(amount),0),
              ''UNEARN'',decode(sign(amount), -1, abs(amount),0),
              ''UNBILL'',decode(sign(amount), -1, abs(amount),0),
              ''SUSPENSE'',decode(sign(acctd_amount),-1, abs(acctd_amount),0),0))
                 amount_dr,
        sum(DECODE(account_class,
              ''REC'',decode(sign(amount), -1 ,abs(amount),0),
              ''REV'',decode(sign(amount), -1, 0,amount),
              ''TAX'',decode(sign(amount), -1, 0,amount),
              ''ROUND'',decode(sign(amount), -1,0,amount),
              ''UNEARN'',decode(sign(amount), -1, 0,amount),
              ''UNBILL'',decode(sign(amount), -1, 0,amount),
              ''SUSPENSE'',decode(sign(amount), -1, 0,amount),0))
                 amount_cr,
        dist.code_combination_id,
        dist.customer_trx_id customer_trx_id,
        null cash_receipt_id,
        null adjustment_id,
        max(dist.org_id) org_id
      FROM ' ||
           g_ra_cust_trx_gl_dist_all || ', ' ||
           g_ra_customer_trx_all || ', ' ||
           g_ra_cust_trx_types_all ||
           ', ar_ccid_by_gl_accounts glc
      WHERE dist.gl_date BETWEEN :p_start_date AND :p_end_date
      AND   dist.account_set_flag = ''N''
      AND   trx.complete_flag = ''Y''
      AND   dist.customer_trx_id = trx.customer_trx_id
      AND   trx.cust_trx_type_id = ctt.cust_trx_type_id
      AND   dist.code_combination_id = glc.code_combination_id '
      || g_dist_org_where
      || g_trx_org_where
      || g_type_org_where || '
      -- AND   dist.posting_control_id > 0
      GROUP BY
        glc.natural_account,
        ctt.name,
        trx_number,
        trx_date,
        invoice_currency_code,
        dist.code_combination_id,
        dist.customer_trx_id,
        null,
        null
      -- pick up distributions from the tables ar_distributions_all for
      -- ar_cash_receipt_history
      UNION ALL
      SELECT
        ''CRH'' component,
        MAX(glc.gl_account) gl_account,
        glc.natural_account,
        rm.name trx_type,
        cr.receipt_number trx_number,
        cr.receipt_date trx_date,
        cr.currency_code entered_currency,
        MAX(crh.gl_date) activity_gl_date,
        sum(acctd_amount_dr) acctd_amt_dr,
        sum(acctd_amount_cr) acctd_amt_cr,
        sum(amount_dr) amt_dr, sum(amount_cr) amt_cr,
        ard.code_combination_id,
        null customer_trx_id,
        crh.cash_receipt_id cash_receipt_id,
        null adjustment_id,
        max(ard.org_id) org_id
      FROM ' ||
        g_ar_distributions_all || ', ' ||
        g_ar_cash_receipt_history_all || ', ' ||
        g_ar_cash_receipts_all ||  ', ' ||
        g_ar_receipt_methods || ' , ' ||
        'ar_ccid_by_gl_accounts glc
      WHERE crh.gl_date between :p_start_date and :p_end_date
      AND   crh.cash_receipt_history_id = ard.source_id
      AND   ard.source_table = ''CRH''
      AND   ard.code_combination_id = glc.code_combination_id
      AND   crh.cash_receipt_id = cr.cash_receipt_id
      AND   cr.receipt_method_id = rm.receipt_method_id '
      || g_ard_org_where
      || g_crh_org_where
      || g_cr_org_where || '
      -- AND crh.posting_control_id > 0
      GROUP BY
        glc.natural_account,
        rm.name,
        cr.receipt_number,
        cr.receipt_date,
        cr.currency_code,
        --null,
        ard.code_combination_id,
        null,
        crh.cash_receipt_id,
        null
      -- pick up distributions from the table ar_distributions_all for
      -- receivable_applications_all
      UNION ALL
      SELECT
        ''RA'' component,
        MAX(glc.gl_account) gl_account,
        glc.natural_account,
        null trx_type,
        null trx_number,
        null trx_date,
        null entered_currency,
        max(ra.gl_date) activity_gl_date,
        sum(acctd_amount_dr) acctd_amt_dr,
        sum(acctd_amount_cr) acctd_amt_cr,
        sum(amount_dr) amt_dr,
        sum(amount_cr) amt_cr,
        ard.code_combination_id,
        decode(ra.application_type,''CASH'',
          decode(ra.status, ''APP'', ra.applied_customer_trx_id, null),
          ''CM'', decode(sign(ra.amount_applied),-1,
          decode(ard.amount_dr,null,ra.customer_trx_id,
          ra.applied_customer_trx_id),
          decode(ard.amount_dr,null,ra.applied_customer_trx_id,
          ra.customer_trx_id))) customer_trx_id,
        decode(ra.status, ''APP'', to_number(null), ra.cash_receipt_id)
          cash_receipt_id,
        null adjustment_id,
        max(ard.org_id) org_id
      FROM ' ||
        g_ar_distributions_all || ', ' ||
        g_ar_receivable_apps_all || ', ' ||
        ' ar_ccid_by_gl_accounts glc
      WHERE ra.gl_date BETWEEN :p_start_date and :p_end_date
      AND ra.receivable_application_id = ard.source_id
      AND ard.source_table = ''RA''
      AND ard.code_combination_id = glc.code_combination_id '
      || g_ard_org_where
      || g_rec_org_where || '
      -- AND ra.posting_control_id > 0
      GROUP BY
        glc.natural_account,
        null,
        null,
        null,
        null,
        --null,
        ard.code_combination_id,
        decode(ra.application_type,''CASH'',
        decode(ra.status,''APP'',ra.applied_customer_trx_id,null),
          ''CM'',decode(sign(ra.amount_applied),-1,
               decode(ard.amount_dr,null,ra.customer_trx_id,
                 ra.applied_customer_trx_id),
        decode(ard.amount_dr,null,ra.applied_customer_trx_id,
                 ra.customer_trx_id))),
        decode(ra.status,''APP'',to_number(null),ra.cash_receipt_id),
        null
      -- pick up distributions from the table ar_distributions_all for
      -- ar_misc_cash_distributions
      UNION ALL
      SELECT
        ''MCH'' component,
        MAX(glc.gl_account) gl_account,
        glc.natural_account,
        rm.name trx_type,
        cr.receipt_number trx_number,
        cr.receipt_date trx_date,
        cr.currency_code entered_currency,
        MAX(mcd.gl_date),
        sum(acctd_amount_dr) acctd_amt_dr,
        sum(acctd_amount_cr) acctd_amt_cr,
        sum(amount_dr) amt_dr, sum(amount_cr) amt_cr,
        ard.code_combination_id,
        null customer_trx_id,
        mcd.cash_receipt_id,
        null adjustment_id,
        max(ard.org_id) org_id
      FROM ' ||
        g_ar_distributions_all || ', ' ||
        g_ar_misc_cash_dists_all || ', ' ||
        g_ar_cash_receipts_all || ', ' ||
        g_ar_receipt_methods  || ', ' ||
        ' ar_ccid_by_gl_accounts glc
      WHERE mcd.gl_date between :p_start_date and :p_end_date
      AND mcd.misc_cash_distribution_id = ard.source_id
      AND ard.source_table = ''MCD''
      AND ard.code_combination_id = glc.code_combination_id
      AND mcd.cash_receipt_id = cr.cash_receipt_id
      AND cr.receipt_method_id = rm.receipt_method_id '
      || g_ard_org_where
      || g_mcd_org_where
      || g_cr_org_where || '
      -- AND mcd.posting_control_id > 0
      GROUP BY
        glc.natural_account,
        rm.name,
        cr.receipt_number,
        cr.receipt_date,
        cr.currency_code,
        --null,
        ard.code_combination_id,
        null,
        mcd.cash_receipt_id,
        null
      -- pick up distributions from the table ar_distributions_all for
      -- ar_adjustments
      UNION ALL
      SELECT
        ''ADJ'' component,
        MAX(glc.gl_account) gl_account,
        glc.natural_account,
        ctt.name trx_type,
        trx_number,
        trx_date,
        invoice_currency_code entered_currency,
        MAX(adj.gl_date) activity_gl_date,
        sum(acctd_amount_dr) acctd_amt_dr,
        sum(acctd_amount_cr) acctd_amt_cr,
        sum(amount_dr) amt_dr, sum(amount_cr) amt_cr,
        ard.code_combination_id,
        decode(adj.amount,-1,
          decode(ard.amount_dr,null, adj.customer_trx_id, null),
          decode(ard.amount_cr,null, adj.customer_trx_id, null))
          customer_trx_id,
        null cash_receipt_id,
        decode(adj.amount,-1,
          decode(ard.amount_cr,null, adj.adjustment_id, null),
          decode(ard.amount_dr,null, adj.adjustment_id, null))
          adjustment_id,
        max(ard.org_id) org_id
      FROM ' ||
        g_ar_distributions_all  || ', ' ||
        g_ar_adjustments_all    || ', ' ||
        g_ra_customer_trx_all   || ', ' ||
        g_ra_cust_trx_types_all || ', ' ||
        ' ar_ccid_by_gl_accounts glc
      WHERE adj.gl_date between :p_start_date and :p_end_date
      AND   adj.adjustment_id = ard.source_id
      AND   ard.source_table = ''ADJ''
      AND   ard.code_combination_id = glc.code_combination_id
      AND   adj.customer_trx_id = trx.customer_trx_id
      AND   trx.cust_trx_type_id = ctt.cust_trx_type_id '
      || g_ard_org_where
      || g_adj_org_where
      || g_trx_org_where
      || g_type_org_where || '
      -- AND adj.posting_control_id > 0
      GROUP BY
        glc.natural_account,
        ctt.name,
        trx_number,
        trx_date,
        invoice_currency_code,
        --null,
        ard.code_combination_id,
        decode(adj.amount,-1,
        decode(ard.amount_dr,null, adj.customer_trx_id, null),
        decode(ard.amount_cr,null, adj.customer_trx_id, null)),
        null,
        decode(adj.amount,-1,
        decode(ard.amount_cr,null, adj.adjustment_id, null),
        decode(ard.amount_dr,null, adj.adjustment_id, null))
      -- pick up distributions from the table ar_distributions_all for
      -- ar_transaction_history (BR)
      UNION ALL
      SELECT
        ''BR'' component,
        MAX(glc.gl_account) gl_account,
        glc.natural_account,
        null trx_type,
        null trx_number,
        null trx_date,
        null entered_currency,
        max(br.gl_date) activity_gl_date,
        sum(acctd_amount_dr) acctd_amt_dr,
        sum(acctd_amount_cr) acctd_amt_cr,
        sum(amount_dr) amt_dr, sum(amount_cr) amt_cr,
        ard.code_combination_id,
        br.customer_trx_id customer_trx_id,
        null cash_receipt_id,
        null adjustment_id,
        max(ard.org_id) org_id
      FROM ' ||
        g_ar_distributions_all || ', ' ||
        g_ar_transaction_history_all || ', ' ||
        ' ar_ccid_by_gl_accounts glc
      WHERE br.gl_date between :p_start_date and :p_end_date
      AND   br.transaction_history_id = ard.source_id
      AND   ard.source_table = ''TH''
      AND   ard.code_combination_id = glc.code_combination_id '
      || g_ard_org_where
      || g_br_org_where || '
      -- AND br.posting_control_id > 0
      GROUP BY
        glc.natural_account,
        null,
        null,
        null,
        null,
        --null,
        ard.code_combination_id,
        customer_trx_id,
        null,
        null
      )
      GROUP BY
        natural_account,
        trx_type,
        trx_number,
        trx_date,
        entered_currency,
        -- activity_gl_date,
        null,
        null,
        null,
        null,
        null,
        code_combination_id,
        customer_trx_id,
        cash_receipt_id,
        adjustment_id,
        sysdate,
        ' || l_user_id || ' ,
        sysdate,
        ' || l_user_id || ' ,
        ' || l_user_id || ' ';

  debug ('Dynamic SQL constructed');
  -- debug (l_sql_stmt);

  OPEN l_ref_cursor FOR l_sql_stmt USING
    p_start_date, p_end_date,
    p_start_date, p_end_date,
    p_start_date, p_end_date,
    p_start_date, p_end_date,
    p_start_date, p_end_date,
    p_start_date, p_end_date;

  LOOP
    FETCH l_ref_cursor BULK COLLECT INTO
      components_tab,
      gl_account_tab,
      natural_account_tab,
      trx_type_tab,
      trx_number_tab,
      trx_date_tab,
      currency_code_tab,
      gl_date_tab,
      acctd_amount_dr_tab,
      acctd_amount_cr_tab,
      amount_dr_tab,
      amount_cr_tab,
      code_combination_id_tab,
      customer_trx_id_tab,
      cash_receipt_id_tab,
      adjustment_id_tab,
      org_id_tab,
      last_update_date_tab,
      last_updated_by_tab,
      creation_date_tab,
      created_by_tab,
      last_update_login_tab
    LIMIT 1000;

    IF l_ref_cursor%NOTFOUND THEN
      l_last_fetch := TRUE;
    END IF;

    IF code_combination_id_tab.COUNT = 0 and l_last_fetch THEN
      EXIT;
    END IF;

    IF p_period_status = 'CLOSED' THEN

      FORALL i IN 1..code_combination_id_tab.count
        INSERT INTO ar_base_gl_acct_balances
        (
           component,
           gl_account,
           natural_account,
           trx_type,
           trx_number,
           trx_date,
           currency,
           activity_gl_date,
           code_combination_id ,
           customer_trx_id,
           cash_receipt_id,
           adjustment_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           acctd_amount_dr,
           acctd_amount_cr,
           amount_dr,
           amount_cr,
           org_id
          )
        VALUES
          (
           components_tab(i),
           gl_account_tab(i),
           natural_account_tab(i),
           trx_type_tab(i),
           trx_number_tab(i),
           trx_date_tab(i),
           currency_code_tab(i),
           gl_date_tab(i),
           code_combination_id_tab(i),
           customer_trx_id_tab(i),
           cash_receipt_id_tab(i),
           adjustment_id_tab(i),
           last_update_date_tab(i),
           last_updated_by_tab(i),
           creation_date_tab(i),
           created_by_tab(i),
           last_update_login_tab(i),
           acctd_amount_dr_tab(i),
           acctd_amount_cr_tab(i),
           amount_dr_tab(i),
           amount_cr_tab(i),
           org_id_tab(i)
         );

    ELSE

      FORALL i IN 1..code_combination_id_tab.count
        INSERT INTO ar_gl_acct_balances
        (
          component,
          gl_account,
          natural_account,
          trx_type,
          trx_number,
          trx_date,
          currency,
          activity_gl_date,
          code_combination_id ,
          customer_trx_id  ,
          cash_receipt_id  ,
          adjustment_id    ,
          last_update_date,
          last_updated_by ,
          creation_date   ,
          created_by     ,
          last_update_login,
          acctd_amount_dr,
          acctd_amount_cr,
          amount_dr,
          amount_cr,
          org_id
        )
        VALUES
        (
          components_tab(i),
          gl_account_tab(i),
          natural_account_tab(i),
          trx_type_tab(i),
          trx_number_tab(i),
          trx_date_tab(i),
          currency_code_tab(i),
          gl_date_tab(i),
          code_combination_id_tab(i),
          customer_trx_id_tab(i),
          cash_receipt_id_tab(i),
          adjustment_id_tab(i),
          last_update_date_tab(i),
          last_updated_by_tab(i),
          creation_date_tab(i),
          created_by_tab(i),
          last_update_login_tab(i),
          acctd_amount_dr_tab(i),
          acctd_amount_cr_tab(i),
          amount_dr_tab(i),
          amount_cr_tab(i),
          org_id_tab(i)
        );

    END IF;

    IF l_last_fetch THEN
      EXIT;
    END IF;

    COMMIT;

  END LOOP;

  CLOSE l_ref_cursor;

  debug('ar_cumulative_balance_report.insert_dist_data(-)');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: NO_DATA_FOUND insert_dist_data');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: OTHERS insert_dist_data');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

END insert_dist_data;


FUNCTION flex_sql(
  p_application_id in number,
  p_id_flex_code in varchar2,
  p_id_flex_num in number default null,
  p_table_alias in varchar2,
  p_mode in varchar2,
  p_qualifier in varchar2,
  p_function in varchar2 default null,
  p_operand1 in varchar2 default null,
  p_operand2 in varchar2 default null) return varchar2 IS

  l_ret_param varchar2(2000);

BEGIN

  debug('ar_cumulative_balance_report.flex_sql(+)');

  -- This is a wrapper function for the fa_rx_flex_pkg. When patch 4128137 is
  -- released, we need to replace this call with the corresponding
  -- FND API calls

  l_ret_param := fa_rx_flex_pkg.flex_sql (
    p_application_id   => p_application_id,
    p_id_flex_code     => p_id_flex_code,
    p_id_flex_num      => p_id_flex_num,
    p_table_alias      => p_table_alias,
    p_mode             => p_mode,
    p_qualifier        => p_qualifier,
    p_function         => p_function,
    p_operand1         => p_operand1,
    p_operand2         => p_operand2);

  debug('ar_cumulative_balance_report.flex_sql(-)');

  RETURN l_ret_param;

END flex_sql;


FUNCTION get_seg_condition (
  p_qualifier VARCHAR2,
  p_seg_low   VARCHAR2,
  p_seg_high  VARCHAR2,
  p_coa_id    NUMBER)
  RETURN VARCHAR2 IS

  l_seg_where VARCHAR2(4000);

BEGIN

  debug('ar_cumulative_balance_report.get_seg_codition(+)');

  IF p_seg_low IS NULL AND p_seg_high IS NULL THEN

    l_seg_where := NULL;

  ELSIF p_seg_low IS NULL THEN

    l_seg_where := ' AND ' ||
      flex_sql(
        p_application_id => 101,
        p_id_flex_code => 'GL#',
        p_id_flex_num => p_coa_id,
        p_table_alias => 'gcc',
        p_mode => 'WHERE',
        p_qualifier => p_qualifier,
        p_function => '<=',
        p_operand1 => p_seg_high);

  ELSIF p_seg_high IS NULL THEN

    l_seg_where := ' AND ' ||
      flex_sql(
        p_application_id => 101,
        p_id_flex_code => 'GL#',
        p_id_flex_num => p_coa_id,
        p_table_alias => 'gcc',
        p_mode => 'WHERE',
        p_qualifier => p_qualifier,
        p_function => '>=',
        p_operand1 => p_seg_low);

  ELSE

    l_seg_where := ' AND ' ||
      flex_sql(p_application_id => 101,
        p_id_flex_code => 'GL#',
        p_id_flex_num => p_coa_id,
        p_table_alias => 'gcc',
        p_mode => 'WHERE',
        p_qualifier => p_qualifier,
        p_function => 'BETWEEN',
        p_operand1 => p_seg_low,
        p_operand2 => p_seg_high);

  END IF;

  debug('ar_cumulative_balance_report.get_seg_codition(-)');

  RETURN l_seg_where;

END get_seg_condition;


PROCEDURE populate_ccids (
  p_chart_of_accounts_id IN   NUMBER,
  p_coa_id               IN   NUMBER,
  p_co_seg_low           IN   VARCHAR2,
  p_co_seg_high          IN   VARCHAR2,
  p_gl_account_low       IN   VARCHAR2,
  p_gl_account_high      IN   VARCHAR2) IS


  l_user_id        fnd_user.user_id%TYPE;
  l_segment_name   fnd_segment_attribute_values.application_column_name%TYPE;
  l_sql_stmt       VARCHAR2(4000);
  l_delete_stmt    VARCHAR2(200);
  l_account_where  VARCHAR2(200);
  l_co_seg_where   VARCHAR2(200);
  l_min_start_date DATE;
  l_max_end_date   DATE;

BEGIN

  debug('ar_cumulative_balance_report.populate_ccids(+)');
  debug('p_coa_id              : ' || p_coa_id);
  debug('p_co_seg_low          : ' || p_co_seg_low );
  debug('p_co_seg_high         : ' || p_co_seg_high);
  debug('p_gl_account_low      : ' || p_gl_account_low);
  debug('p_gl_account_high     : ' || p_gl_account_high);

  -- Step 1
  -- Populate the interim table ar_interim_ccid_by_gl_account with the
  -- code combinations for the given gl_account.

  l_user_id      := fnd_global.user_id;
  l_segment_name := get_gl_account_segment();

  debug('Natural segment: ' || l_segment_name);

  DELETE FROM ar_ccid_by_gl_accounts;

  debug('number of rows deleted: ' || SQL%ROWCOUNT);

  l_sql_stmt :=
    'INSERT INTO ar_ccid_by_gl_accounts
     (
      code_combination_id,
      natural_account,
      gl_account,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login
     )
     (
      SELECT
        code_combination_id, ' ||
        l_segment_name || ' , ' ||
        'fnd_flex_ext.get_segs
         (
          ''SQLGL'',
          ''GL#'', ' ||
          p_chart_of_accounts_id || ' ,
          code_combination_id) gl_account ' || ',
        sysdate,
        ' || l_user_id || ' ,
        sysdate,
        ' || l_user_id || ' ,
        ' || l_user_id || '
      FROM gl_code_combinations gcc
      WHERE gcc.account_type IN (''A'', ''L'')
      AND chart_of_accounts_id = ' || p_chart_of_accounts_id || '
      AND ' || l_segment_name || ' IS NOT NULL ) ';

  -- debug(l_sql_stmt);

  EXECUTE IMMEDIATE l_sql_stmt ;

  debug('number of rows inserted: ' || SQL%ROWCOUNT);

  debug('ar_cumulative_balance_report.populate_ccids(-)');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: NO_DATA_FOUND populate_ccids');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: OTHERS populate_ccids');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

END populate_ccids;


FUNCTION refresh_verdict (p_gl_as_of_date DATE)
  RETURN VARCHAR2 IS

  l_num_rows          NUMBER;
  l_max_trx_date      DATE;
  l_max_activity_date DATE;
  l_sql_stmt          VARCHAR2(4000);

BEGIN

  debug('ar_cumulative_balance_report.refresh_verdict(+)');

  l_sql_stmt := 'SELECT count(*), max(trx_date), max(activity_gl_date)
                 FROM ar_base_gl_acct_balances bal WHERE 1=1 ' ;

  l_sql_stmt := l_sql_stmt || g_balances_where;

  debug('sql statement');
  debug(l_sql_stmt);

  EXECUTE IMMEDIATE l_sql_stmt
  INTO l_num_rows, l_max_trx_date, l_max_activity_date ;

  debug('Number of Rows in Base Table For This Org: ' || l_num_rows);
  debug('Max Trx Date: ' || l_max_trx_date);
  debug('Max Activity Date : ' || l_max_activity_date);

  IF ( (l_num_rows = 0) OR
       (p_gl_as_of_date < l_max_trx_date) OR
       (p_gl_as_of_date < l_max_activity_date)) THEN

    debug('ar_cumulative_balance_report.refresh_verdict(-)');
    RETURN 'Y';

  END IF;

  debug('ar_cumulative_balance_report.refresh_verdict(-)');
  RETURN 'N';

END refresh_verdict;


PROCEDURE populate_data (
  p_reporting_level      IN   VARCHAR2,
  p_reporting_entity_id  IN   NUMBER,
  p_reporting_format     IN   VARCHAR2,
  p_chart_of_accounts_id IN   NUMBER,
  p_sob_id               IN   NUMBER,
  p_coa_id               IN   NUMBER,
  p_co_seg_low           IN   VARCHAR2,
  p_co_seg_high          IN   VARCHAR2,
  p_gl_as_of_date        IN   VARCHAR2,
  p_gl_account_low       IN   VARCHAR2,
  p_gl_account_high      IN   VARCHAR2,
  p_refresh_tables       IN   VARCHAR2  DEFAULT 'N') IS

  l_user_id        fnd_user.user_id%TYPE;
  l_segment_name   fnd_segment_attribute_values.application_column_name%TYPE;
  l_sql_stmt       VARCHAR2(4000);
  /* Variable length increased from 200 to 500 for bug:5181586*/
  l_delete_stmt    VARCHAR2(500);
  /* Change for bug:5181586 ends*/
  l_account_where  VARCHAR2(200);
  l_co_seg_where   VARCHAR2(200);
  l_min_start_date DATE;
  l_max_end_date   DATE;
  l_refresh_tables VARCHAR2(1) DEFAULT 'N';

  CURSOR c IS
    SELECT MIN(start_date), MAX(end_date)
    FROM  ar_closed_gl_periods
    WHERE closing_status = 'C';

BEGIN

  debug('ar_cumulative_balance_report.populate_data(+)');
  debug('p_reporting_level     : ' || p_reporting_level);
  debug('p_reporting_entity_id : ' || p_reporting_entity_id);
  debug('p_reporting_format    : ' || p_reporting_format);
  debug('p_sob_id              : ' || p_sob_id);
  debug('p_coa_id              : ' || p_coa_id);
  debug('p_co_seg_low          : ' || p_co_seg_low );
  debug('p_co_seg_high         : ' || p_co_seg_high);
  debug('p_gl_as_of_date       : ' || p_gl_as_of_date);
  debug('p_gl_account_low      : ' || p_gl_account_low);
  debug('p_gl_account_high     : ' || p_gl_account_high);
  -- debug('p_refresh_tables      : ' || p_refresh_tables);

  -- Step 1
  -- Populate the interim table ar_interim_ccid_by_gl_account with the
  -- code combinations for the given gl_account.

  l_user_id      := fnd_global.user_id;
  l_segment_name := get_gl_account_segment();

  debug('user ID: ' || l_user_id);
  debug('Natural segment: ' || l_segment_name);

  populate_ccids(
    p_chart_of_accounts_id => p_chart_of_accounts_id,
    p_coa_id               => p_coa_id,
    p_co_seg_low           => p_co_seg_low,
    p_co_seg_high          => p_co_seg_high,
    p_gl_account_low       => p_gl_account_low,
    p_gl_account_high      => p_gl_account_high);

  -- after a detailed discussion, we decided that as of now no option
  -- will be given to refresh the tables or not.  we will advise
  -- our customer to run this report with the last audit date when
  -- they run it for the first time.  ANy subsequence run would not
  -- refresh tables unless they give an earlier date.
  --
  -- as result, i will intercept the code here and find out if we should
  -- refresh or not.

  l_refresh_tables := refresh_verdict(p_gl_as_of_date);
  debug('l_refresh_tables      : ' || l_refresh_tables);

  IF l_refresh_tables = 'Y' THEN

    debug( 'Refresh option selected');

    -- For the given p_gl_as_of_date determine how many gl_periods are there
    -- since inception and store them in interim table ar_closed_gl_periods
    /* EXISTS clause added to handle more rows returned by the sub-query of SOB for bug:5181586*/

    INSERT INTO ar_closed_gl_periods
    (
      period_name,
      start_date,
      end_date,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      period_year,
      closing_status
    )
    (
      SELECT
        period_name,
        start_date,
        end_date,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_user_id,
        period_year,
        closing_status
      FROM gl_period_statuses
      WHERE adjustment_period_flag = 'N'
      AND application_id = 222
      AND end_date <= p_gl_as_of_date
      AND EXISTS
      (
        SELECT set_of_books_id
        FROM   ar_system_parameters
      )
      AND NOT EXISTS
      (
        SELECT 'x'
        FROM ar_closed_gl_periods
      )
    );

    /* Change for Bug:5181586 ends*/
    debug('Done - INSERT INTO ar_closed_gl_periods');

    --  For each period in ar_closed_gl_periods that is CLOSED,
    --  we know that additional entries cannot occur hence we do a
    --  one time upgrade to get the transaction wise balances for
    --  all closed periods.

    OPEN c;
    FETCH c INTO l_min_start_date, l_max_end_date;
    CLOSE c;

    debug('start date: ' || l_min_start_date);
    debug('end date: ' || l_max_end_date);

    l_delete_stmt := 'DELETE FROM  ar_base_gl_acct_balances bal WHERE 1=1 ';
    l_delete_stmt := l_delete_stmt ||  g_balances_where;

    debug('Delete Statement: ' || l_delete_stmt);
    EXECUTE IMMEDIATE l_delete_stmt;

    debug('base (all): number of rows deleted: ' || SQL%ROWCOUNT);

    debug('calling insert_dist_data passing status as CLOSED');

    insert_dist_data(
      p_start_date       => l_min_start_date ,
      p_end_date         => l_max_end_date,
      p_period_status    => 'CLOSED');

    debug('base: deleting all lines whose cr and dr cancel each other');

    l_delete_stmt := 'DELETE FROM ar_base_gl_acct_balances bal
                      WHERE nvl(acctd_amount_dr,0) = nvl(acctd_amount_cr,0) ';
    l_delete_stmt := l_delete_stmt || g_balances_where;

    debug('Delete Statement: ' || l_delete_stmt);
    EXECUTE IMMEDIATE l_delete_stmt;

    debug('Number of rows deleted: ' || SQL%ROWCOUNT);

  ELSE

    OPEN c;
    FETCH c INTO l_min_start_date, l_max_end_date;
    CLOSE c;

    debug('start date: ' || l_min_start_date);
    debug('end date: ' || l_max_end_date);

  END IF;  -- l_refresh_tables = 'Y'
  COMMIT;

  -- now let us construct the data after the cut off date.

  l_delete_stmt := 'DELETE FROM  ar_gl_acct_balances bal WHERE 1=1 ';
  l_delete_stmt := l_delete_stmt ||  g_balances_where;
  --debug('Delete Statement: ' || l_delete_stmt);
  EXECUTE IMMEDIATE l_delete_stmt;
  debug('number of rows deleted: ' || SQL%ROWCOUNT);

  debug( 'p_start_date: ' || to_char(l_max_end_date+1));
  debug( 'p_end_date: ' || to_char(p_gl_as_of_date));

  insert_dist_data(
    p_start_date       => l_max_end_date+1,
    p_end_date         => p_gl_as_of_date,
    p_period_status    => 'OPEN');

  debug('deleting all lines whose cr and dr cancel each other');
  l_delete_stmt := 'DELETE FROM ar_gl_acct_balances bal
                    WHERE nvl(acctd_amount_dr,0) = nvl(acctd_amount_cr,0) ';
  l_delete_stmt := l_delete_stmt || g_balances_where;
  --debug('Delete Statement: ' || l_delete_stmt);
  EXECUTE IMMEDIATE l_delete_stmt;
  debug('Number of rows deleted: ' || SQL%ROWCOUNT);

  COMMIT;

  debug('ar_cumulative_balance_report.populate_data(-)');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: NO_DATA_FOUND populate_data');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: OTHERS populate_data');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

END populate_data;


PROCEDURE init (p_set_of_books_id IN NUMBER) IS

  l_sysparam_sob_id     NUMBER;
  l_mrc_sob_type_code   VARCHAR2(1);

  CURSOR sob_type IS
    SELECT mrc_sob_type_code
    FROM   gl_sets_of_books
    WHERE  set_of_books_id = p_set_of_books_id;

  CURSOR system_options IS
    select set_of_books_id
    from   ar_system_parameters;

BEGIN

  debug('ar_cumulative_balance_report.init(+)');

  IF p_set_of_books_id <> -1999 THEN
    OPEN  sob_type;
    FETCH sob_type INTO l_mrc_sob_type_code;
    CLOSE sob_type;
  ELSE
    l_mrc_sob_type_code := 'P';
  END IF;

  OPEN  system_options;
  FETCH system_options INTO l_sysparam_sob_id;
  CLOSE system_options;

  IF (upper(l_mrc_sob_type_code) = 'R') THEN
    fnd_client_info.set_currency_context(p_set_of_books_id);
  END IF;

  IF l_sysparam_sob_id = p_set_of_books_id THEN
     l_mrc_sob_type_code := 'P';
  END IF;

  IF upper(l_mrc_sob_type_code) = 'P' THEN

    g_ar_system_parameters := 'ar_system_parameters sys';
    g_ar_system_parameters_all := 'ar_system_parameters_all sys';
    g_ar_adjustments := 'ar_adjustments adj';
    g_ar_adjustments_all := 'ar_adjustments_all adj';
    g_ar_cash_receipt_history := 'ar_cash_receipt_history crh';
    g_ar_cash_receipt_history_all := 'ar_cash_receipt_history_all crh';
    g_ar_cash_receipts := 'ar_cash_receipts cr';
    g_ar_cash_receipts_all := 'ar_cash_receipts_all cr';
--{Replaced
--    g_ar_distributions := 'ar_distributions ard';
    g_ar_distributions := 'ar_xla_ard_lines_v ard';
--    g_ar_distributions_all := 'ar_distributions_all ard';
    g_ar_distributions_all := 'ar_xla_ard_lines_v ard';
--}
    g_ra_customer_trx := 'ra_customer_trx trx';
    g_ra_customer_trx_all := 'ra_customer_trx_all trx';
--{Replaced
--    g_ra_cust_trx_gl_dist := 'ra_cust_trx_line_gl_dist dist';
    g_ra_cust_trx_gl_dist := 'ar_xla_ctlgd_lines_v dist';
--    g_ra_cust_trx_gl_dist_all := 'ra_cust_trx_line_gl_dist_all dist';
    g_ra_cust_trx_gl_dist_all := 'ar_xla_ctlgd_lines_v dist';
--}
    g_ar_misc_cash_dists := 'ar_misc_cash_distributions mcd';
    g_ar_misc_cash_dists_all := 'ar_misc_cash_distributions_all mcd';
    g_ar_receivable_apps := 'ar_receivable_applications ra';
    g_ar_receivable_apps_all := 'ar_receivable_applications_all ra';
    g_ar_receipt_methods := 'ar_receipt_methods rm';
    g_ra_cust_trx_types := 'ra_cust_trx_types ctt';
    g_ra_cust_trx_types_all := 'ra_cust_trx_types_all ctt';
    g_ar_transaction_history := 'ar_transaction_history br';
    g_ar_transaction_history_all := 'ar_transaction_history_all br';

  ELSE

    g_ar_system_parameters := 'ar_system_parameters_mrc_v sys';
    g_ar_system_parameters_all := 'ar_system_parameters_all_mrc_v sys';
    g_ar_adjustments := 'ar_adjustments_mrc_v adj';
    g_ar_adjustments_all := 'ar_adjustments_all_mrc_v adj';
    g_ar_cash_receipt_history := 'ar_cash_receipt_hist_mrc_v crh';
    g_ar_cash_receipt_history_all := 'ar_cash_receipt_hist_all_mrc_v crh';
    g_ar_cash_receipts := 'ar_cash_receipts cr';
    g_ar_cash_receipts_all := 'ar_cash_receipts_all_mrc_v cr';
    g_ar_distributions := 'ar_distributions_mrc_v ard';
    g_ar_distributions_all := 'ar_distributions_all_mrc_v ard';
    g_ra_customer_trx := 'ra_customer_trx_mrc_v trx';
    g_ra_customer_trx_all := 'ra_customer_trx_all_mrc_v trx';
    g_ra_cust_trx_gl_dist := 'ra_trx_line_gl_dist_all_mrc_v dist';
    g_ra_cust_trx_gl_dist_all := 'ra_trx_line_gl_dist_mrc_v dist';
    g_ar_misc_cash_dists := 'ar_misc_cash_dists_mrc_v mcd';
    g_ar_misc_cash_dists_all := 'ar_misc_cash_dists_all_mrc_v mcd';
    g_ar_receivable_apps := 'ar_receivable_apps_mrc_v ra';
    g_ar_receivable_apps_all := 'ar_receivable_apps_all_mrc_v ra';
    g_ar_receipt_methods := 'ar_receipt_methods rm';
    g_ra_cust_trx_types := 'ra_cust_trx_types ctt';
    g_ra_cust_trx_types_all := 'ra_cust_trx_types_all ctt';
    g_ar_transaction_history := 'ar_transaction_history br';
    g_ar_transaction_history_all := 'ar_transaction_history_all br';

  END IF;

  debug('ar_cumulative_balance_report.init(-)');

END init;


PROCEDURE generate_xml (
  p_reporting_level      IN   VARCHAR2,
  p_reporting_entity_id  IN   NUMBER,
  p_reporting_format     IN   VARCHAR2,
  p_sob_id               IN   NUMBER,
  p_coa_id               IN   NUMBER,
  p_co_seg_low           IN   VARCHAR2,
  p_co_seg_high          IN   VARCHAR2,
  p_gl_as_of_date        IN   VARCHAR2,
  p_gl_account_low       IN   VARCHAR2,
  p_gl_account_high      IN   VARCHAR2,
  p_refresh              IN   VARCHAR2  DEFAULT 'N',
  p_result               OUT NOCOPY CLOB) IS

  l_xml_stmt              ref_cur;
  l_result                CLOB;
  tempResult              CLOB;
  l_gl_as_of_date         DATE;
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
  l_base_query            VARCHAR2(32767);
  l_recent_query          VARCHAR2(32767);
  l_gl_account_where      VARCHAR2(4000);
  l_company_where         VARCHAR2(4000);
  l_natural_segment_col   VARCHAR2(50);
  l_flex_value_set_id     NUMBER;
  l_code_combinations     VARCHAR2(1000);
  l_rows_processed        NUMBER;
  l_new_line              VARCHAR2(1) := '';

  -- Variables to hold the report heading
  l_sob_id                NUMBER;
  l_chart_of_accounts_id  NUMBER;
  l_sob_name              VARCHAR2(100);
  l_functional_currency   VARCHAR2(15);
  l_organization          VARCHAR2(60);
  l_format                VARCHAR2(40);
  l_close_tag             VARCHAR2(100);
  l_reporting_entity_name VARCHAR2(80);
  l_reporting_level_name  VARCHAR2(30);
  l_status_meaning        VARCHAR2(30);
  l_gl_account_type_meaning VARCHAR2(100);
  l_dummy_where           VARCHAR2(200);
  l_group_by              VARCHAR2(4000);
  l_reporting_format      VARCHAR2(30);
  l_ld_sp                 VARCHAR2(1) := 'Y';
  l_message               VARCHAR2(2000);
  l_encoding		  VARCHAR2(20);
  l_message_acct          VARCHAR2(1000);

  CURSOR format (p_format VARCHAR2) IS
    SELECT meaning
    FROM   ar_lookups
    WHERE  lookup_type = 'AR_ARXCUABR_REPORTING_FORMAT'
    AND    lookup_code = p_format;


  CURSOR all_value IS
    SELECT meaning
    FROM ar_lookups
    WHERE lookup_code ='ALL'
    AND lookup_type ='ALL';

BEGIN

  debug('ar_cumulative_balance_report.generate_xml()+');
  debug('p_reporting_level     : ' || p_reporting_level);
  debug('p_reporting_entity_id : ' || p_reporting_entity_id);
  debug('p_reporting_format    : ' || p_reporting_format);
  debug('p_sob_id              : ' || p_sob_id);
  debug('p_coa_id              : ' || p_coa_id);
  debug('p_co_seg_low          : ' || p_co_seg_low );
  debug('p_co_seg_high         : ' || p_co_seg_high);
  debug('p_gl_account_low      : ' || p_gl_account_low);
  debug('p_gl_account_high     : ' || p_gl_account_high);
  debug('p_refresh_tables      : ' || p_refresh);

  debug('p_gl_as_of_date       : ' || p_gl_as_of_date);
  l_gl_as_of_date := TRUNC(TO_DATE(p_gl_as_of_date, 'YYYY-MM-DD HH24:MI:SS'));
  debug( 'l_gl_as_of_date       : ' || l_gl_as_of_date);
/* Start Bug 6502401: Get SOB and Chart of Accounts ID */
      IF p_reporting_level = 1000 THEN
         SELECT  sob.name sob_name,
	         sob.set_of_books_id,
                 sob.currency_code functional_currency,
		 sob.chart_of_accounts_id
          INTO   l_sob_name,
	         l_sob_id,
                 l_functional_currency,
		 l_chart_of_accounts_id
          FROM   gl_sets_of_books sob
          WHERE  sob.set_of_books_id = p_reporting_entity_id;

      ELSIF p_reporting_level = 3000 THEN
         SELECT sob.name sob_name,
	        sob.set_of_books_id,
                sob.currency_code functional_currency,
		sob.chart_of_accounts_id,
		substr(hou.name,1,60) organization
           INTO l_sob_name,
	        l_sob_id,
                l_functional_currency,
                l_chart_of_accounts_id,
		l_organization
           FROM gl_sets_of_books sob,
                ar_system_parameters_all sysparam,
		hr_organization_units hou
          WHERE sob.set_of_books_id = sysparam.set_of_books_id
	  AND   hou.organization_id = sysparam.org_id
          AND   sysparam.org_id = p_reporting_entity_id;
      END IF;
/* End Bug 6502401 */
  -- initialize the reporting context
  init(p_sob_id);

  -- set the org conditions
  xla_mo_reporting_api.initialize(
    p_reporting_level     => p_reporting_level,
    p_reporting_entity_id => p_reporting_entity_id,
    p_pred_type           => 'AUTO');

  OPEN format(p_reporting_format);
  FETCH format INTO l_reporting_format;
  CLOSE format;

  debug( 'getting where clause');

  g_dist_org_where  :=  xla_mo_reporting_api.get_predicate('dist',NULL);
  g_trx_org_where   :=  xla_mo_reporting_api.get_predicate('trx',NULL);
  g_type_org_where  :=  xla_mo_reporting_api.get_predicate('ctt',NULL);
  g_ard_org_where   :=  xla_mo_reporting_api.get_predicate('ard',NULL);
  g_crh_org_where   :=  xla_mo_reporting_api.get_predicate('crh',NULL);
  g_cr_org_where    :=  xla_mo_reporting_api.get_predicate('cr',NULL);
  g_rm_org_where    :=  xla_mo_reporting_api.get_predicate('rm',NULL);
  g_rec_org_where   :=  xla_mo_reporting_api.get_predicate('ra',NULL);
  g_mcd_org_where   :=  xla_mo_reporting_api.get_predicate('mcd',NULL);
  g_adj_org_where   :=  xla_mo_reporting_api.get_predicate('adj',NULL);
  g_br_org_where    :=  xla_mo_reporting_api.get_predicate('br',NULL);
  g_sys_org_where   :=  xla_mo_reporting_api.get_Predicate('sys',NULL);
  g_balances_where  :=  xla_mo_reporting_api.get_Predicate('bal',NULL);

  debug( 'before: g_sys_org_where : ' || g_sys_org_where);

  -- replacing with actual reporting entity id

  g_dist_org_where :=  replace(g_dist_org_where, ':p_reporting_entity_id',
    p_reporting_entity_id);
  g_trx_org_where  :=  replace(g_trx_org_where, ':p_reporting_entity_id',
    p_reporting_entity_id);
  g_type_org_where :=  replace(g_type_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_ard_org_where  :=  replace(g_ard_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_crh_org_where  :=  replace(g_crh_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_cr_org_where   :=  replace(g_cr_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_rm_org_where   :=  replace(g_rm_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_rec_org_where  :=  replace(g_rec_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_mcd_org_where  :=  replace(g_mcd_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_adj_org_where  :=  replace(g_adj_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_br_org_where   :=  replace(g_br_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_sys_org_where  :=  replace(g_sys_org_where, ':p_reporting_entity_id',
     p_reporting_entity_id);
  g_balances_where  :=  replace(g_balances_where, ':p_reporting_entity_id',
     p_reporting_entity_id);

  debug('g_dist_org_where: ' || g_dist_org_where);
  debug('g_trx_org_where: '  || g_trx_org_where);
  debug('g_type_org_where: ' || g_type_org_where);
  debug('g_ard_org_where: '  || g_ard_org_where);
  debug('g_crh_org_where: '  || g_crh_org_where);
  debug('g_cr_org_where: '   || g_cr_org_where);
  debug('g_rm_org_where: '   || g_rm_org_where);
  debug('g_rec_org_where: '  || g_rec_org_where);
  debug('g_mcd_org_where: '  || g_mcd_org_where);
  debug('g_adj_org_where: '  || g_adj_org_where);
  debug('g_br_org_where: '   || g_br_org_where);
  debug('g_sys_org_where: '  || g_sys_org_where);
  debug('g_balances_where: ' || g_balances_where);

  l_reporting_entity_name :=
    substrb(xla_mo_reporting_api.get_reporting_entity_name,1,80);
  l_reporting_level_name :=
    substrb(xla_mo_reporting_api.get_reporting_level_name,1,30);

  debug( 'l_reporting_entity_name : ' || l_reporting_entity_name);
  debug( 'l_reporting_level_name : ' || l_reporting_level_name);


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
                                   l_gl_as_of_date) THEN
        FND_MESSAGE.SET_NAME('AR','AR_REPORT_ACC_NOT_GEN');--Changed as per Bug 5578884 the parameter to AR from FND as the message is in AR product
        l_message_acct := FND_MESSAGE.Get;
    END IF;


  -- Populate 'ALL' if it is run for SOB
  IF p_reporting_level <> '3000' THEN
    OPEN all_value;
    FETCH all_value INTO l_organization;
    CLOSE all_value;
  END IF;

  debug( 'SOB Name: ' || l_sob_name);
  debug( 'Func Currency: ' || l_functional_currency);
  debug( 'Org: ' || l_organization);
  debug( 'Chart of Accounts: ' || l_chart_of_accounts_id);

  populate_data(
    p_reporting_level      => p_reporting_level,
    p_reporting_entity_id  => p_reporting_entity_id,
    p_reporting_format     => p_reporting_format,
    p_chart_of_accounts_id => l_chart_of_accounts_id,
    p_sob_id               => l_sob_id,
    p_coa_id               => l_chart_of_accounts_id,
    p_co_seg_low           => p_co_seg_low,
    p_co_seg_high          => p_co_seg_high,
    p_gl_as_of_date        => l_gl_as_of_date,
    p_gl_account_low       => p_gl_account_low,
    p_gl_account_high      => p_gl_account_high,
    p_refresh_tables       => p_refresh);

  debug( 'returned from populate_data');

  perform_updates;

  l_base_query :=
   'SELECT
      decode (''' || p_reporting_format || ''', ''GL_ACCOUNT'',
        gl_account, natural_account) gl_account,
      trx_type,
      trx_number,
      to_char(trx_date,''YYYY-MM-DD'') trx_date,
      to_char(max(activity_gl_date),''YYYY-MM-DD'') activity_gl_date,
      currency,
      decode(sign(sum(nvl(acctd_amount_dr,0))-
                  sum(nvl(acctd_amount_cr,0))), -1, 0,
                  sum(nvl(acctd_amount_dr,0))-sum(nvl(acctd_amount_cr,0)))
        acctd_amount_dr,
      decode(sign(sum(nvl(acctd_amount_cr,0))-
                  sum(nvl(acctd_amount_dr,0))), -1, 0,
                  sum(nvl(acctd_amount_cr,0))-sum(nvl(acctd_amount_dr,0)))
        acctd_amount_cr,
      decode(sign(sum(nvl(amount_dr,0))-sum(nvl(amount_cr,0))), -1, 0,
                  sum(nvl(amount_dr,0))-sum(nvl(amount_cr,0)))
        amount_dr,
      decode(sign(sum(nvl(amount_cr,0))-sum(nvl(amount_dr,0))), -1, 0,
                  sum(nvl(amount_cr,0))-sum(nvl(amount_dr,0)))
        amount_cr
    FROM ar_base_gl_acct_balances bal,
         gl_code_combinations gcc
    WHERE bal.code_combination_id = gcc.code_combination_id ';

  l_recent_query :=
   'SELECT
      decode (''' || p_reporting_format || ''', ''GL_ACCOUNT'',
        gl_account, natural_account) gl_account,
      trx_type,
      trx_number,
      to_char(trx_date,''YYYY-MM-DD'') trx_date,
      to_char(max(activity_gl_date),''YYYY-MM-DD'') activity_gl_date,
      currency,
      decode(sign(sum(nvl(acctd_amount_dr,0))-
                  sum(nvl(acctd_amount_cr,0))), -1, 0,
                  sum(nvl(acctd_amount_dr,0))-sum(nvl(acctd_amount_cr,0)))
        acctd_amount_dr,
      decode(sign(sum(nvl(acctd_amount_cr,0))-
                  sum(nvl(acctd_amount_dr,0))), -1, 0,
                  sum(nvl(acctd_amount_cr,0))-sum(nvl(acctd_amount_dr,0)))
        acctd_amount_cr,
      decode(sign(sum(nvl(amount_dr,0))-sum(nvl(amount_cr,0))), -1, 0,
                  sum(nvl(amount_dr,0))-sum(nvl(amount_cr,0)))
        amount_dr,
      decode(sign(sum(nvl(amount_cr,0))-sum(nvl(amount_dr,0))), -1, 0,
                  sum(nvl(amount_cr,0))-sum(nvl(amount_dr,0)))
        amount_cr
    FROM ar_gl_acct_balances bal,
         gl_code_combinations gcc
    WHERE bal.code_combination_id = gcc.code_combination_id ';

  -- l_dummy_where := ' WHERE 1=1 ';
  l_group_by    := ' GROUP BY gl_account, natural_account, trx_type,
                              trx_number, trx_date, currency
                     HAVING   sum(nvl(acctd_amount_dr,0)) -
                              sum(nvl(acctd_amount_cr,0)) > 0
                              OR
                              sum(nvl(acctd_amount_cr,0)) -
                              sum(nvl(acctd_amount_dr,0)) > 0 ';

  --l_group_by    := ' GROUP BY gl_account, natural_account, trx_type,
  --                            trx_number, trx_date, currency ';

  l_base_query := l_base_query || g_balances_where;
  l_recent_query := l_recent_query || g_balances_where;

  -- build the other WHERE clauses

  l_gl_account_where := get_seg_condition (
    p_qualifier  => 'ALL',
    p_seg_low  => p_gl_account_low,
    p_seg_high => p_gl_account_high,
    p_coa_id   => p_coa_id);

  -- debug(l_gl_account_where);

  l_company_where := get_seg_condition (
    p_qualifier  => 'GL_BALANCING',
    p_seg_low  => p_co_seg_low,
    p_seg_high => p_co_seg_high,
    p_coa_id   => p_coa_id);

  -- debug(l_company_where);

  l_base_query := l_base_query     || l_gl_account_where || l_company_where;
  l_recent_query := l_recent_query || l_gl_account_where || l_company_where;

  l_xml_query := l_base_query   || l_group_by || ' UNION ALL ' ||
                 l_recent_query || l_group_by;

  -- l_xml_query := l_recent_query || l_group_by;

  debug('xmlquery:');
  debug(l_xml_query);

  -- get database version
  dbms_utility.db_version(
    version       => l_version,
    compatibility => l_compatibility);

  l_majorVersion := to_number(substr(l_version, 1, instr(l_version,'.')-1));

  debug('DB version : ' || l_majorVersion);

  IF (l_majorVersion > 8 and l_majorVersion < 9) THEN

    BEGIN
      queryCtx := DBMS_XMLQuery.newContext(l_xml_query);
      dbms_xmlquery.setRaiseNoRowsException(queryCtx,TRUE);
      debug('calling getxml');
      l_result := DBMS_XMLQuery.getXML(queryCtx);
      debug('returned from getxml');
      dbms_xmlquery.closeContext(queryCtx);
      l_rows_processed := 1;

    EXCEPTION WHEN OTHERS THEN
      dbms_xmlquery.getexceptioncontent(queryCtx,l_errNo,l_errMsg);
      IF l_errNo = 1403 THEN
        l_rows_processed := 0;
      END IF;
      dbms_xmlquery.closecontext(queryCtx);
    END;

  ELSIF (l_majorVersion >= 9 ) THEN

    qryctx   := dbms_xmlgen.newcontext(l_xml_query);
    debug('calling getxml');
    l_result := dbms_xmlgen.getxml(qryctx,dbms_xmlgen.none);
    debug('returned from getxml');
    l_rows_processed := dbms_xmlgen.getnumrowsprocessed(qryctx);
    debug('rows prcessed: ' || l_rows_processed);
    dbms_xmlgen.closecontext(qryCtx);

  END IF;

  debug('XML generation done: ' || l_rows_processed);

  IF l_rows_processed <> 0 THEN
    l_resultOffset   := DBMS_LOB.INSTR(l_result,'>');
    tempResult       := l_result;
  ELSE
    l_resultOffset   := 0;
  END IF;

  -- Prepare the tag for the report heading
  l_encoding   := fnd_profile.value('ICX_CLIENT_IANA_ENCODING');
  l_xml_header := '<?xml version="1.0" encoding="'||l_encoding||'"?>';
  l_xml_header := l_xml_header || l_new_line ||'<ARXCUABR>';
  l_xml_header := l_xml_header || l_new_line ||' <MSG_TXT>'||l_message||'</MSG_TXT>';
  l_xml_header := l_xml_header || l_new_line ||' <MSG_TXT_ACCT>'||l_message_acct||'</MSG_TXT_ACCT>';
  l_xml_header := l_xml_header || l_new_line ||'    <PARAMETERS>';
  l_xml_header := l_xml_header || l_new_line ||'        <REPORTING_LEVEL>'
    || l_reporting_level_name || '</REPORTING_LEVEL>';
  l_xml_header := l_xml_header || l_new_line ||'        <REPORTING_ENTITY>'
    || l_reporting_entity_name || '</REPORTING_ENTITY>';
  l_xml_header := l_xml_header || l_new_line ||'        <REPORTING_FORMAT>'
    || l_reporting_format || '</REPORTING_FORMAT>';
  l_xml_header := l_xml_header || l_new_line || '        <SOB_ID>'
    || p_sob_id ||'</SOB_ID>';
  l_xml_header := l_xml_header || l_new_line || '        <FUNCTIONAL_CURRENCY>'
    || l_functional_currency ||'</FUNCTIONAL_CURRENCY>';
  l_xml_header := l_xml_header || l_new_line || '        <CO_SEG_LOW>'
    || p_co_seg_low || '</CO_SEG_LOW>';
  l_xml_header := l_xml_header || l_new_line || '        <CO_SEG_HIGH>'
    || p_co_seg_high ||'</CO_SEG_HIGH>';
  l_xml_header := l_xml_header || l_new_line || '        <GL_AS_OF_DATE>'
    ||to_char(fnd_date.canonical_to_date(p_gl_as_of_date),'YYYY-MM-DD')
    || '</GL_AS_OF_DATE>';
  l_xml_header := l_xml_header || l_new_line || '        <GL_ACCOUNT_LOW>'
    || p_gl_account_low || '</GL_ACCOUNT_LOW>';
  l_xml_header := l_xml_header || l_new_line || '        <GL_ACCOUNT_HIGH>'
    || p_gl_account_high ||'</GL_ACCOUNT_HIGH>';
  l_xml_header := l_xml_header || l_new_line || '        <REFRESH_TABLE>'
    || p_refresh ||'</REFRESH_TABLE>';
  l_xml_header := l_xml_header || l_new_line || '        <NUM_ROWS>'
    || l_rows_processed || '</NUM_ROWS>';
  l_xml_header := l_xml_header || l_new_line || '    </PARAMETERS>';
  l_xml_header := l_xml_header || l_new_line || '    <REPORT_HEADING>';
  l_xml_header := l_xml_header || l_new_line || '        <SET_OF_BOOKS>'
    || l_sob_name ||'</SET_OF_BOOKS>';
  l_xml_header := l_xml_header || l_new_line || '        <ORGANIZATION>'
    || l_organization||'</ORGANIZATION>';
  l_xml_header := l_xml_header || l_new_line || '    </REPORT_HEADING>';

  l_close_tag  := l_new_line||'</ARXCUABR>' || l_new_line;
  l_xml_header_length := length(l_xml_header);

  debug('Header created');

  IF l_rows_processed <> 0 THEN
    dbms_lob.write(tempResult,l_xml_header_length,1,l_xml_header);
    dbms_lob.copy(tempResult, l_result,
      dbms_lob.getlength(l_result)-l_resultOffset,
      l_xml_header_length,l_resultOffset);
  ELSE
    dbms_lob.createtemporary(tempResult,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(tempResult,dbms_lob.lob_readwrite);
    dbms_lob.writeAppend(tempResult, length(l_xml_header), l_xml_header);
  END IF;

  dbms_lob.writeAppend(tempResult, length(l_close_tag), l_close_tag);
  process_clob(tempResult);
  p_result :=  tempResult;

  debug('ar_cumulative_balance_report.generate_xml()-');

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: NO_DATA_FOUND generate_xml');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: OTHERS generate_xml');
    debug(sqlcode);
    debug(sqlerrm);
    RAISE;

END generate_xml;


-- Package constructor
BEGIN

  NULL;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: ar_cumulative_balance_report.initialize');
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: ar_cumulative_balance_report.initialize');
    RAISE;

END ar_cumulative_balance_report;

/
