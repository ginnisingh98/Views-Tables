--------------------------------------------------------
--  DDL for Package Body ARRX_COGS_REP_INNER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_COGS_REP_INNER" AS
/* $Header: ARRXRCGB.pls 120.1 2005/10/30 04:45:55 appldev noship $ */


/*========================================================================
 |  Package Global Variables
 +=======================================================================*/

  pg_debug varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  TYPE number_table IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

  TYPE varchar_table IS TABLE OF VARCHAR2(240)
    INDEX BY BINARY_INTEGER;

FUNCTION get_cost(
  p_account_class   VARCHAR2,
  p_rec_offset_flag VARCHAR2,
  p_line_id         NUMBER,
  p_base_transaction_value NUMBER) RETURN NUMBER IS

  CURSOR rev_rows IS
    SELECT count(*)
    FROM   ra_cust_trx_line_gl_dist_all
    WHERE  customer_trx_line_id = p_line_id
    AND    account_set_flag = 'N'
    AND    account_class = 'REV';

  l_cost  NUMBER DEFAULT 0;
  l_count NUMBER DEFAULT 0;

BEGIN

  -- This routine figures out how many REV dist lines exists
  -- and depending on the count would figure out if the cost
  -- should be added to the total or not.
  -- case 1 - The account class for the current row is UNEARN and there
  --          exists no REV rows then count the cost.  Otherwise
  --          the cost would show up as zero .
  -- case 2 - There are rev rows and the accont class for the current
  --          row is UNEARN then ignore it.
  -- case 3 - For all other scenario go ahead and count the cost.

  IF (p_account_class = 'UNEARN') THEN
    IF (p_rec_offset_flag =  'Y') THEN
      OPEN rev_rows;
      FETCH rev_rows INTO l_count;
      CLOSE rev_rows;
      IF (l_count = 0) THEN
        RETURN p_base_transaction_value;
      END IF;
    END IF;
  ELSE -- 'REV' entry
    RETURN p_base_transaction_value;
  END IF;

  RETURN 0;

END get_cost;


PROCEDURE populate_description IS

  l_dummy BOOLEAN;
  l_description ar_cogs_rev_itf.cogs_acct_description%TYPE;

  -- Please note that now description has code_combination_id
  --
  CURSOR getdesc IS
    SELECT cgs.cogs_acct_description code_combination_id,
           gcc.chart_of_accounts_id
    FROM   ar_cogs_rev_itf cgs, gl_code_combinations gcc
    WHERE  cgs.cogs_acct_description = gcc.code_combination_id;

BEGIN

  -- Bug # 3840430
  -- The description in gl_code_combinations is not the right one.
  -- To get the description we need to call the function
  -- fnd_flex_keyval.concatenated_descriptions however this will only
  -- work if the cc id was validated just before that.  To do that
  -- we need the code_combination_id which is not stored in the
  -- ar_cogs_rev_itf table.  So, we are overloading the description
  -- column temporariliy to store the code_combination_id and here
  -- we will update it with the corresponding description.

  fnd_file.put_line(fnd_file.log, 'populate_description');

  FOR rec IN getdesc  LOOP

    l_dummy := fnd_flex_keyval.validate_ccid(
                'SQLGL',
                'GL#',
                rec.chart_of_accounts_id,
                rec.code_combination_id);
    l_description := fnd_flex_keyval.concatenated_descriptions;

    fnd_file.put_line(fnd_file.log, 'CC ID: ' || rec.code_combination_id);
    fnd_file.put_line(fnd_file.log, 'Description: ' || l_description);

    UPDATE ar_cogs_rev_itf
    SET   cogs_acct_description = l_description
    WHERE cogs_acct_description = rec.code_combination_id;

 END LOOP;

END populate_description;


PROCEDURE populate_rows (
  p_gl_date_low   	 IN  DATE,
  p_gl_date_high  	 IN  DATE,
  p_sales_order_low      IN  VARCHAR2 DEFAULT NULL,
  p_sales_order_high	 IN  VARCHAR2 DEFAULT NULL,
  p_posted_lines_only	 IN  VARCHAR2 DEFAULT NULL,
  p_unmatched_items_only IN  VARCHAR2 DEFAULT NULL,
  p_user_id 		 IN  NUMBER,
  p_request_id      	 IN  NUMBER,
  x_retcode         	 OUT NOCOPY NUMBER,
  x_errbuf          	 OUT NOCOPY VARCHAR2) IS

  l_posting_control_id  NUMBER DEFAULT NULL;
  l_gl_batch_id         NUMBER DEFAULT NULL;
  l_precision           fnd_currencies.precision%TYPE;

  CURSOR precision IS
    SELECT cur.precision
    FROM   gl_sets_of_books sob,
           fnd_currencies cur
    WHERE  sob.currency_code = cur.currency_code
    AND    sob.set_of_books_id = arp_standard.sysparm.set_of_books_id;

BEGIN

  -- This routine populate the interface table so the detail RXi report
  -- can publish the report based on the data in the interface table.

  IF pg_debug in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_COGS_REP_INNER.POPULATE_ROWS()+');
  END IF;

  fnd_file.put_line(fnd_file.log, 'request id: ' || p_request_id);
  fnd_file.put_line(fnd_file.log, 'user id : ' || p_user_id);
  fnd_file.put_line(fnd_file.log, 'low gl date: ' || p_gl_date_low);
  fnd_file.put_line(fnd_file.log, 'high gl date: ' || p_gl_date_high);
  fnd_file.put_line(fnd_file.log, 'low sales order: ' || p_sales_order_low);
  fnd_file.put_line(fnd_file.log, 'high sales order: ' || p_sales_order_high);
  fnd_file.put_line(fnd_file.log, 'posted lines only: ' ||
    p_posted_lines_only);
  fnd_file.put_line(fnd_file.log, 'unmatched items only: ' ||
    p_posted_lines_only);

  -- In order to round the amount columns we must figure how many places
  -- we must round.  That is being determined here by looking at the
  -- currency precision of the set of books.

  OPEN precision;
  FETCH precision INTO l_precision;
  CLOSE precision;

  -- start out with a fresh table.
  DELETE FROM ar_cogs_rev_itf;

  -- respond to the user preference set in the program parameter.
  -- if yes then exclude lines with posting control id of -3

  IF p_posted_lines_only = 'Y' THEN
    l_posting_control_id := -3;
    l_gl_batch_id        := -1;
  END IF;

  fnd_file.put_line(fnd_file.log, 'table being populated with selected rows');

  -- the commented columns are populated later for better readability.

  INSERT INTO ar_cogs_rev_itf
  (
    request_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    set_of_books_id,
    cogs_gl_account,
    cogs_acct_description,
    customer_name,
    sales_order_type,
    sales_order,
    sales_order_line,
    trx_class,
    trx_number,
    trx_line_number,
    order_amount_orig,
    cogs_amount_orig,
    cogs_amount_period,
    rev_amount_period
  )
  SELECT
    p_request_id                                          request_id,
    p_user_id                                             create_by,
    sysdate                                               creation_date,
    p_user_id                                             last_udpated_by,
    sysdate                                               last_update_date,
    p_user_id                                             last_update_login,
    arp_standard.sysparm.set_of_books_id,
    MAX(fnd_flex_ext.get_segs(
      'SQLGL',
      'GL#',
      gcc.chart_of_accounts_id,
      gcc.code_combination_id))                           cogs_account,
    MAX(gcc.code_combination_id)                          description,
    party.party_name                                      customer,
    lines.interface_line_attribute2                       order_type,
    lines.interface_line_attribute1                       order_num,
    lines.sales_order_line                                sales_order_line,
    trx_type.type                                         trx_class,
    trx.trx_number                                        trx_number,
    lines.line_number                                     trx_line_number,
    ROUND((SUM(lines.revenue_amount)/
      count(dist.cust_trx_line_gl_dist_id)), l_precision) orig_revenue,
    SUM
    ( arrx_cogs_rep_inner.get_cost(
       dist.account_class,
       dist.rec_offset_flag,
       lines.customer_trx_line_id,
       mta.base_transaction_value))                       orig_cost,
    ROUND((SUM
      (
       DECODE
       (
        (DECODE(sign(mmt.transaction_date -fnd_date.chardate_to_date(p_gl_date_low)), -1, 0, 1)
         +
         DECODE(sign(mmt.transaction_date -fnd_date.chardate_to_date(p_gl_date_high)), 1, 0, 1)
        ),
        2,  arrx_cogs_rep_inner.get_cost(
             dist.account_class,
             dist.rec_offset_flag,
             lines.customer_trx_line_id,  mta.base_transaction_value), 0
       )
      )), l_precision)                                    cost,
    ROUND((SUM
      (
       DECODE
       (
        (
         DECODE(sign(dist.gl_date - fnd_date.chardate_to_date(p_gl_date_low)), -1, 0, 1)
         +
         DECODE(sign(dist.gl_date - fnd_date.chardate_to_date(p_gl_date_high)), 1, 0, 1)
        ),
        2, DECODE(dist.account_class, 'UNEARN', 0, dist.acctd_amount), 0
       )
      ))/count(DISTINCT mmt.transaction_id), l_precision) revenue
  FROM  ra_cust_trx_line_gl_dist   dist,
        ra_customer_trx_lines      lines,
        mtl_material_transactions  mmt,
        mtl_transaction_accounts   mta,
        ra_customer_trx            trx,
        hz_cust_accounts           acct,
        hz_parties                 party,
        mtl_system_items_b         msi,
        ra_cust_trx_types          trx_type,
        gl_code_combinations       gcc,
        cst_item_costs             cic,
	mtl_parameters             mp
  WHERE  dist.customer_trx_line_id        = lines.customer_trx_line_id
  AND    dist.account_set_flag            = 'N'
  AND    dist.account_class               IN  ('REV', 'UNEARN')
  AND    lines.customer_trx_id            = trx.customer_trx_id
  AND    lines.inventory_item_id          = msi.inventory_item_id
  AND    lines.interface_line_attribute10 = msi.organization_id
  AND    lines.line_type                  = 'LINE'
  AND    lines.interface_line_context     = 'ORDER ENTRY'
  AND    lines.interface_line_attribute6  = mmt.trx_source_line_id
  AND    mmt.transaction_source_type_id   IN (2, 12)
  AND    mmt.transaction_action_id        IN (1, 27)
  AND    mmt.costed_flag IS NULL
  AND    mmt.organization_id              = msi.organization_id
  AND    mmt.inventory_item_id            = msi.inventory_item_id
  AND    mmt.transaction_id               = mta.transaction_id
  AND    mta.accounting_line_type         <> 2
  AND    msi.inventory_item_id            = cic.inventory_item_id
  AND    msi.organization_id              = cic.organization_id
  AND    msi.organization_id              = mp.organization_id
  AND    cic.cost_type_id                 = mp.primary_cost_method
  AND    msi.shippable_item_flag          = 'Y'
  AND    msi.costing_enabled_flag         = 'Y'
  AND    msi.invoiceable_item_flag        = 'Y'
  AND    msi.invoice_enabled_flag         = 'Y'
  AND    cic.inventory_asset_flag         = 1
  AND    trx.cust_trx_type_id             = trx_type.cust_trx_type_id
  AND    trx_type.type                    IN ('INV', 'CM')
  AND    trx.bill_to_customer_id          = acct.cust_account_id
  AND    acct.party_id                    = party.party_id
  AND    mta.reference_account            = gcc.code_combination_id
  AND    dist.gl_date
         BETWEEN p_gl_date_low AND p_gl_date_high
  AND    lines.interface_line_attribute1
         BETWEEN NVL(p_sales_order_low, lines.interface_line_attribute1) AND
                 NVL(p_sales_order_high, lines.interface_line_attribute1)
  AND    dist.posting_control_id <> NVL(l_posting_control_id, -99999999999)
  AND    mta.gl_batch_id <> NVL(l_gl_batch_id, -99999999999)
  GROUP BY mta.reference_account,
           party.party_name,
           lines.interface_line_attribute2,
           lines.interface_line_attribute1,
           trx_type.type,
           trx.trx_number,
           lines.sales_order_line,
           lines.interface_line_attribute6,
           lines.line_number;

  fnd_file.put_line(fnd_file.log, 'table populated with selected rows');

  --
  -- just for better readability I am computing the percentages
  -- and actual adjustment needed separately here. the formula for
  -- cogs adjustment is:  (%rev - %cogs) * cogs_amount_orig
  --

  UPDATE ar_cogs_rev_itf
  SET    rev_percent_period  = ROUND((((rev_amount_period/order_amount_orig) *
                                DECODE(trx_class, 'CM', -100, 100))),
                                l_precision),
         cogs_percent_period = ROUND(((cogs_amount_period/cogs_amount_orig)
                                * DECODE(trx_class, 'CM', -100, 100)),
                                l_precision),
         cogs_adjustment     = ROUND(((((rev_amount_period/order_amount_orig))
                                -  (cogs_amount_period/cogs_amount_orig)) *
                                cogs_amount_orig), l_precision)
  WHERE  cogs_amount_orig  <> 0
  AND    order_amount_orig <> 0;

  -- Bug # 3840467
  -- take care of null columns

  UPDATE ar_cogs_rev_itf
  SET    rev_percent_period  = 0,
         cogs_percent_period = 0,
         cogs_adjustment     = 0
  WHERE  cogs_amount_orig    = 0
  AND    order_amount_orig   = 0;

  fnd_file.put_line(fnd_file.log, 'update done');

  -- respond to the user preference set in the program parameter.
  -- this too could have been done in the main SQL, but
  -- preferred to do this here for better readability and maintainablity.

  IF p_unmatched_items_only = 'Y' THEN

     DELETE FROM ar_cogs_rev_itf
     WHERE rev_percent_period = cogs_percent_period;

     fnd_file.put_line(fnd_file.log, 'deleting matched items');

  END IF;

  -- Bug # 3840430
  populate_description;

  fnd_file.put_line(fnd_file.log, 'description populated');

  IF pg_debug in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_COGS_REP_INNER.POPULATE_ROWS()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF pg_debug in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: arrx_cogs_rep_inner.populate_rows()');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: arrx_cogs_rep_inner.populate_rows()');
    END IF;
    RAISE;

END populate_rows;


PROCEDURE populate_summary (
  p_gl_date_low   	 IN  DATE,
  p_gl_date_high  	 IN  DATE,
  p_chart_of_accounts_id IN  NUMBER,
  p_gl_account_low       IN  VARCHAR2 DEFAULT NULL,
  p_gl_account_high      IN  VARCHAR2 DEFAULT NULL,
  p_posted_lines_only	 IN  VARCHAR2 DEFAULT NULL,
  p_user_id 		 IN  NUMBER,
  p_request_id      	 IN  NUMBER,
  x_retcode         	 OUT NOCOPY NUMBER,
  x_errbuf          	 OUT NOCOPY VARCHAR2) IS

  l_precision            fnd_currencies.precision%TYPE;
  l_cc_id_low            gl_code_combinations.code_combination_id%TYPE;
  l_cc_id_high           gl_code_combinations.code_combination_id%TYPE;

  l_gl_acct_tbl          varchar_table;
  l_gl_acct_desc_tbl     varchar_table;
  l_cogs_adjustment_tbl  number_table;

  CURSOR precision IS
    SELECT cur.precision
    FROM   gl_sets_of_books sob,
           fnd_currencies cur
    WHERE  sob.currency_code = cur.currency_code
    AND    sob.set_of_books_id = arp_standard.sysparm.set_of_books_id;

  CURSOR summary_rows IS
    SELECT cogs_gl_account,
           cogs_acct_description,
           ROUND(SUM(cogs_adjustment), l_precision)
    FROM ar_cogs_rev_itf
    GROUP BY cogs_gl_account, cogs_acct_description;

BEGIN

  -- This routine populate the interface table so the summary RXi report
  -- can publish the report based on the data in the interface table.

  fnd_file.put_line(fnd_file.log, 'ARRX_C_COGS_REP_INNER.POPULATE_SUMMARY()+');

  IF pg_debug in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'POPULATE_SUMMARY()+');
  END IF;

  fnd_file.put_line(fnd_file.log, 'request id: ' || p_request_id);
  fnd_file.put_line(fnd_file.log, 'user id : ' || p_user_id);
  fnd_file.put_line(fnd_file.log, 'low gl date: ' || p_gl_date_low);
  fnd_file.put_line(fnd_file.log, 'high gl date: ' || p_gl_date_high);
  fnd_file.put_line(fnd_file.log, 'chart of account id : ' ||
    p_chart_of_accounts_id);
  fnd_file.put_line(fnd_file.log, 'low gl account: ' || p_gl_account_low);
  fnd_file.put_line(fnd_file.log, 'high gl account: ' || p_gl_account_high);
  fnd_file.put_line(fnd_file.log, 'posted lines only: ' ||
    p_posted_lines_only);

  -- In order to round the amount columns we must figure how many places
  -- we must round.  That is being determined here by looking at the
  -- currency precision of the set of books.

  OPEN precision;
  FETCH precision INTO l_precision;
  CLOSE precision;

  -- let the populate_rows do the work as far as fetching the detail rows
  -- are concerned. Once that is done we can sum it up at the cogs account
  -- level.

  fnd_file.put_line(fnd_file.log, 'calling populate_rows');

  populate_rows
  (
    p_gl_date_low   	   => p_gl_date_low,
    p_gl_date_high  	   => p_gl_date_high,
    p_sales_order_low      => NULL,
    p_sales_order_high	   => NULL,
    p_posted_lines_only    => p_posted_lines_only,
    p_unmatched_items_only => 'Y',
    p_user_id 		   => p_user_id,
    p_request_id      	   => p_request_id,
    x_retcode         	   => x_retcode,
    x_errbuf          	   => x_errbuf
  );

  fnd_file.put_line(fnd_file.log, 'returned from populate_rows');

  OPEN  summary_rows;
  FETCH summary_rows BULK COLLECT INTO
    l_gl_acct_tbl,
    l_gl_acct_desc_tbl,
    l_cogs_adjustment_tbl;
  CLOSE summary_rows;

  fnd_file.put_line(fnd_file.log, 'clearing detail rows from the table');

  -- remove the details rows and then populate summary rows.
  DELETE FROM ar_cogs_rev_itf;

  fnd_file.put_line(fnd_file.log, 'summary rows count: ' ||
    l_gl_acct_tbl.COUNT);

  FORALL i IN 1..l_gl_acct_tbl.COUNT
    INSERT INTO ar_cogs_rev_itf
    (
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      set_of_books_id,
      cogs_gl_account,
      cogs_acct_description,
      cogs_adjustment
    )
    VALUES
    (
      p_request_id,
      p_user_id,
      sysdate,
      p_user_id,
      sysdate,
      p_user_id,
      arp_standard.sysparm.set_of_books_id,
      l_gl_acct_tbl(i),
      l_gl_acct_desc_tbl(i),
      l_cogs_adjustment_tbl(i)
    );

  fnd_file.put_line(fnd_file.log, 'table populated with summary rows');

  IF ((p_gl_account_low IS NOT NULL) OR (p_gl_account_low IS NOT NULL)) THEN

     fnd_file.put_line(fnd_file.log, 'keep only the rows within acct range');

     DELETE FROM ar_cogs_rev_itf
     WHERE COGS_GL_ACCOUNT
     NOT BETWEEN p_gl_account_low AND p_gl_account_high;

  END IF;

  IF pg_debug in ('Y', 'C') THEN
    fnd_file.put_line(fnd_file.log, 'ARRX_COGS_REP_INNER.POPULATE_SUMMARY()-');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF pg_debug in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: arrx_cogs_rep_inner.populate_rows()');
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug in ('Y', 'C') THEN
      arp_standard.debug('EXCEPTION: arrx_cogs_rep_inner.populate_rows()');
    END IF;
    RAISE;

END populate_summary;


/*========================================================================
 | INITIALIZATION SECTION
 |
 | DESCRIPTION
 |
 *=======================================================================*/

BEGIN

   NULL;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     arp_standard.debug('exception: arrx_cogs_rep_inner.initialize()');
     RAISE;

  WHEN OTHERS THEN
     arp_standard.debug('exception: arrx_cogs_rep_inner.initialize()');
     RAISE;

END arrx_cogs_rep_inner;

/
