--------------------------------------------------------
--  DDL for Package Body AR_MATCH_REV_COGS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_MATCH_REV_COGS_GRP" AS
/* $Header: ARCGSRVB.pls 120.17.12010000.20 2009/10/19 16:02:21 mraymond ship $ */

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

/*=======================================================================+
 |  Global Constants
 +=======================================================================*/

  g_pkg_name  CONSTANT VARCHAR2(30):= 'ar_match_rev_cogs_grp';
  g_om_context ra_interface_lines.interface_line_context%type;

  g_so_line_id NUMBER := 0;
  g_period_number NUMBER := 0;
  g_potential_revenue  NUMBER := 0;

  g_bulk_fetch_rows NUMBER := 1000;

 /* 5664384 - This is a semi-temporary solution to a problem with
      analytic functions for accumulating the total potential revenue
      for a given so_line as of the specificed period.

      NOTE:  I expect to replace this with aggregate functions as soon
      as we can determine the correct approach. */
FUNCTION potential_revenue(p_so_line_id IN NUMBER, p_period_number IN NUMBER)
   RETURN NUMBER IS

BEGIN
   IF p_so_line_id <> g_so_line_id OR
      p_period_number <> g_period_number
   THEN
      SELECT sum(l.revenue_amount)
      INTO   g_potential_revenue
      FROM   ra_customer_trx_lines_all l
      WHERE  EXISTS
         (SELECT /*+ INDEX (cogs AR_TRX_COGS_N1) */
                 'eligible transaction captured in GT table'
          FROM   ar_trx_cogs_gt cogs
          WHERE  cogs.so_line_id = p_so_line_id
          AND    cogs.period_number <= p_period_number
          AND    cogs.customer_trx_id = l.customer_trx_id
          AND    cogs.customer_trx_line_id = l.customer_trx_line_id);

     g_so_line_id := p_so_line_id;
     g_period_number := p_period_number;
   END IF;

   RETURN g_potential_revenue;

   /* Removed EXCEPTION block.  There is no known scenario where
      a NDF or other failure would be acceptable or managable. */

END;


PROCEDURE period_status (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_eff_period_num IN  NUMBER,
  p_sob_id         IN  NUMBER,
  x_status         OUT NOCOPY  VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2) IS

  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name	 CONSTANT VARCHAR2(30)	:= 'period_status';

  CURSOR status IS
    SELECT closing_status
    FROM gl_period_statuses ps
    WHERE adjustment_period_flag = 'N'
    AND application_id = 222
    AND set_of_books_id = p_sob_id
    AND effective_period_num = p_eff_period_num;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'ar_match_rev_cogs_grp.period_status()+ ');
  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT period_status_grp;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
           p_current_version_number => l_api_version,
           p_caller_version_number  => p_api_version,
   	   p_api_name               => l_api_name,
           p_pkg_name 	    	    => g_pkg_name) THEN

    RAISE fnd_api.g_exc_unexpected_error;

  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    fnd_msg_pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN status;
  FETCH status INTO x_status;
  CLOSE status;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'ar_match_rev_cogs_grp.period_status()- ');
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO period_status_grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO period_status_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO period_status_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

END period_status;


FUNCTION get_costing_period_status (
  p_period_name  VARCHAR2)
  RETURN VARCHAR2 IS

  l_api_version     NUMBER := 1.0;
  l_init_msg_list   VARCHAR2(30) DEFAULT FND_API.G_TRUE;
  l_eff_period_num  NUMBER;
  l_set_of_books_id NUMBER;
  l_status          VARCHAR2(30);
  l_return_status   VARCHAR2(30);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(150);

  CURSOR epm IS
    SELECT effective_period_num, sp.set_of_books_id
    FROM   gl_period_statuses ps, ar_system_parameters sp
    WHERE  ps.set_of_books_id     = sp.set_of_books_id
    AND    adjustment_period_flag = 'N'
    AND    application_id         = 222
    AND    period_name            = p_period_name;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'ar_match_rev_cogs_grp.get_costing_period_status()+ ');
  END IF;

  OPEN epm;
  FETCH epm INTO l_eff_period_num, l_set_of_books_id;
  CLOSE epm;


  cst_revenuecogsmatch_grp.return_periodstatuses(
    p_api_version           => l_api_version,
    p_init_msg_list         => l_init_msg_list,
    p_commit		    => NULL,
    p_validation_level	    => NULL,
    x_return_status         => l_return_status,
    x_msg_count             => l_msg_count,
    x_msg_data		    => l_msg_data,
    p_set_of_books_id       => l_set_of_books_id,
    p_effective_period_num  => l_eff_period_num,
    x_closed_cst_periods    => l_status);

  --l_status := 'C';

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'ar_match_rev_cogs_grp.get_costing_period_status()- ');
  END IF;

  RETURN l_status;

END get_costing_period_status;


PROCEDURE populate_cst_tables (
  p_api_version    IN  NUMBER,
  p_init_msg_list  IN  VARCHAR2 := fnd_api.g_false,
  p_commit         IN  VARCHAR2 := fnd_api.g_false,
  p_from_gl_date DATE,
  p_to_gl_date   DATE,
  p_ledger_id      IN  NUMBER DEFAULT NULL,
  x_status         OUT NOCOPY VARCHAR2,
  x_return_status  OUT NOCOPY  VARCHAR2,
  x_msg_count      OUT NOCOPY  NUMBER,
  x_msg_data       OUT NOCOPY  VARCHAR2) IS

  l_request_id          NUMBER;
  l_user_id             NUMBER;
  l_login_id            NUMBER;
  l_pgm_app_id          NUMBER;
  l_pgm_id              NUMBER;
  l_api_version  CONSTANT NUMBER := 1.0;
  l_api_name     CONSTANT VARCHAR2(30) := 'populate_cst_tables';
  l_rows                NUMBER;
  l_so_rows             NUMBER;
  l_so_rows_inserted    NUMBER;
  l_last_fetch          BOOLEAN := FALSE;
  l_original_org        NUMBER;
  l_original_context    VARCHAR2(1);

   /* 5664384 - table and cursor to fetch affected sales orders */
   TYPE so_number_table_type IS
      TABLE OF VARCHAR2(128)
      INDEX BY BINARY_INTEGER;
   so_numbers so_number_table_type;

   TYPE so_org_table_type IS
      TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
   so_orgs    so_org_table_type;

   TYPE rowid_table_type IS
      TABLE OF VARCHAR2(128)
      INDEX BY BINARY_INTEGER;
   gld_rowids rowid_table_type;

   TYPE cogs_request_id_type IS
      TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
   gld_cogs_request_ids cogs_request_id_type;

   /* 7463284 - New cursor to limit gl_dist rows by sob_id */
   CURSOR so_numbers_c(p_request_id NUMBER,
                       p_org_id     NUMBER,
                       p_sob_id     NUMBER,
                       p_start_date DATE,
                       p_end_date   DATE) IS
     SELECT DISTINCT l.sales_order, l.org_id
      FROM   ra_customer_trx_lines_all    l,
             ra_cust_trx_line_gl_dist_all gld,
             gl_date_period_map           gl_map,
             gl_sets_of_books             gl_sob
      WHERE  gld.cogs_request_id = p_request_id
      AND    gld.org_id = p_org_id
      AND    gld.account_class = 'REV'
      AND    gld.latest_rec_flag IS NULL
      AND    gld.gl_date = gl_map.accounting_date
      AND    gld.customer_trx_line_id = l.customer_trx_line_id
      AND    gl_sob.set_of_books_id = p_sob_id
      AND    gl_sob.period_set_name = gl_map.period_set_name
      AND    gl_sob.accounted_period_type = gl_map.period_type
      AND    gl_map.accounting_date BETWEEN p_start_date
                                        AND p_end_date;


   CURSOR gld_rows_c(p_request_id NUMBER,
                     p_org_id     NUMBER,
                     p_sob_id     NUMBER,
                     p_start_date DATE,
                     p_end_date   DATE) IS
      SELECT gld.ROWID,
          Decode(gld.account_set_flag, 'Y', -100,
            Decode(l.interface_line_context, g_om_context,
              Decode(l.sales_order, NULL, -98,
                Decode(l.sales_order_line, NULL, -97,
                  Decode(l.interface_line_attribute6, NULL, -96,
                    p_request_id))),-100)) cogs_request_id
      FROM   ra_customer_trx_lines_all    l,
             ra_cust_trx_line_gl_dist_all gld,
             gl_date_period_map           gl_map,
             gl_sets_of_books             gl_sob
      WHERE  gld.cogs_request_id IS NULL
      AND    gld.org_id = p_org_id
      AND    gld.account_class = 'REV'
      AND    gld.latest_rec_flag IS NULL
      AND    gld.gl_date = gl_map.accounting_date
      AND    gld.customer_trx_line_id = l.customer_trx_line_id
      AND    gl_sob.set_of_books_id = p_sob_id
      AND    gl_sob.period_set_name = gl_map.period_set_name
      AND    gl_sob.accounted_period_type = gl_map.period_type
      AND    gl_map.accounting_date BETWEEN p_start_date
                                        AND p_end_date;

   /* 8334354 - changed from sob to org/sob */
   CURSOR ar_operations(p_sob_id NUMBER) IS
      SELECT org_id, set_of_books_id
      FROM   ar_system_parameters_all
      WHERE  set_of_books_id = NVL(p_sob_id, set_of_books_id)
      AND    set_of_books_id > 0
      AND    org_id > 0;

   /* Diagnostic - dump of bad rows */
   CURSOR bad_rows(p_org_id    NUMBER,
                   p_from_date DATE,
                   p_to_date   DATE) IS
      SELECT cogs_request_id, count(*) error_count,
             DECODE(cogs_request_id, -100, 'model or non-OM',
                                     -99, 'corrupt or missing line',
                                     -98, 'null sales_order',
                                     -97, 'null sales_order_line',
                                     -96, 'null int_attr6 col') meaning
      FROM   ra_cust_trx_line_gl_dist_all
      WHERE  org_id = p_org_id
      AND    cogs_request_id BETWEEN -98 AND -1
      AND    gl_date BETWEEN p_from_date AND p_to_date
      AND    account_class = 'REV'
      AND    latest_rec_flag IS NULL
      GROUP BY cogs_request_id;

   /* debug - dump content of GT table */
   CURSOR trx_gt IS
      SELECT *
      FROM   ar_trx_cogs_gt;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'ar_match_rev_cogs_grp.populate_cst_tables()+ ');
     arp_debug.debug('   p_ledger_id = ' || p_ledger_id);
     arp_debug.debug('   p_gl_date   = ' || p_from_gl_date ||
                       ' to ' || p_to_gl_date);

  END IF;

  -- Standard Start of API savepoint
  SAVEPOINT populate_cst_tables_grp;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (
           p_current_version_number => l_api_version,
           p_caller_version_number  => p_api_version,
   	   p_api_name               => l_api_name,
           p_pkg_name 	    	    => g_pkg_name) THEN

    RAISE fnd_api.g_exc_unexpected_error;

  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    fnd_msg_pub.initialize;
  END IF;

  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Populate WHO column variables
   l_request_id := fnd_global.conc_request_id;
   l_user_id    := fnd_global.user_id;
   l_login_id   := fnd_global.login_id;
   l_pgm_app_id := fnd_global.prog_appl_id;
   l_pgm_id     := fnd_global.conc_program_id;

   /* 8821317 - store original values so we can restore them later */
   l_original_org     := mo_global.get_current_org_id;
   l_original_context := mo_global.get_access_mode;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('   cogs_request_id = ' || l_request_id);
  END IF;

  /* PROGRAM FLOW
     This program now executes in 4 steps or stages.  They are:
      step 1 - tag gl_dist rows with cogs_request_id
        Only tags REV rows with request_id if they are for a sales order.
        Non sales order REV lines get a specific negative int (see below).
        Currently fetches only 1000 rows at a time.
      step 2 - collect unique sales orders for processing
      step 3 - populate ar_trx_cogs_gt table with summarization of data
      step 4 - merge data in cst_revenue_recognition_lines

     The detailed flow looks like this:

     FOR org in orgs(by sob_id) LOOP
        LOOP
           Open/Fetch data from gl_dist table
           - If no gl_dist rows, goto next_org
           Exit loop if no rows
           Update gl_dist table with cogs_request_id
        END LOOP

        LOOP
           Open/Fetch unique sales orders
           - If no orders, goto next_org

           Insert into ar_trx_cogs_gt
        END LOOP

        Merge into cst_revenue_recognition_lines
     <<next_org>>
     END LOOP
  */

  FOR c_org IN ar_operations(p_ledger_id)
  LOOP

   IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug('Processing org_id =' || c_org.org_id || ',  sob_id = ' ||
         c_org.set_of_books_id);
   END IF;

   /* Step 1 - Tag eligible gl_dist rows based on date range.
      This results in all gl_dist rows for this ledger and date
      range having a value stamped in cogs_request_id.  The value
      will be the request_id of this job for REV dists on OE lines,
      or one of the following values:

      +ve  :  request_id of the COGS job that identified this row
      -100 :  model distribution (account_set_flag = Y)
                  or non-OM transaction
      -99  :  REC, ROUND, or other misjoined distributions
      -98  :  OM line, but sales_order is NULL
      -97  :  OM line, but sales_order_line is NULL
      -96  :  OM line, but interface_line_attr6 is NULL

      So -96, -97, and -98 values indicate some malformed OM data.
      -99 could contain orphan dists or other mystery rows that did not
      maintain normal AR data integrity.
   */

    /* Loop and bulk fetch blocks of records */
    l_last_fetch := FALSE;
    OPEN  gld_rows_c(l_request_id, c_org.org_id,
                     c_org.set_of_books_id, p_from_gl_date, p_to_gl_date);
    LOOP

      /* fetch gld rows for updating cogs_request_id */
      FETCH gld_rows_c BULK COLLECT INTO gld_rowids, gld_cogs_request_ids
                   LIMIT g_bulk_fetch_rows;

      l_rows := gld_rows_c%ROWCOUNT;

      IF gld_rows_c%NOTFOUND
      THEN
         l_last_fetch := TRUE;
      END IF;

      IF PG_DEBUG in ('Y', 'C')
      THEN
         arp_debug.debug('  fetched ' || gld_rowids.count ||
                      ' distinct gld row(s) for update.');
      END IF;

      /* If no rows at all, skip to next org */
      IF l_rows = 0
      THEN
         IF PG_DEBUG in ('Y','C')
         THEN
            arp_debug.debug('  skipping to next org');
         END IF;
         CLOSE gld_rows_c; -- need to close it before we skip
         goto next_org;
      END IF;

      /* If last fetch, then exit fetch loop */
      IF gld_rowids.count = 0 AND l_last_fetch
      THEN
         IF PG_DEBUG in ('Y','C')
         THEN
            arp_debug.debug('   last fetch for this org.  Exiting fetch loop');
         END IF;
         EXIT;
      END IF;

      /* 8821317 - ra_cust_trx_line_gl_dist_bri trigger raising
         unexpected error during trigger execution.  Setting org
         avoids error */
      mo_global.set_policy_context('S',c_org.org_id);

      /* Now update the gld rows with cogs_request_ids */
      FORALL i in 1 .. gld_rowids.count
        UPDATE ra_cust_trx_line_gl_dist_all gld
        SET cogs_request_id = gld_cogs_request_ids(i)
        WHERE rowid = gld_rowids(i);

      IF PG_DEBUG in ('Y', 'C')
      THEN
         l_rows := SQL%ROWCOUNT;
         arp_debug.debug('  updated ' || l_rows ||
                      ' distinct gld row(s).');
      END IF;

    END LOOP;
    /* End of loop for bulk fetch */

    CLOSE gld_rows_c;

   /* Step 2 - Identify the unique sales orders that affect or
      are affected in the specified GL_DATE range. */

   /* NOTE:  The question has come up as to why we use sales_order..
      The answer.. the original order and price adjustment lines will
      bear the sales order number.  Additionally, RMAs for that trx
      will also come in with different values in ILA6, but the same
      value for sales_order.  So it was the obvious (and easiest)
      way to group related transactions from OM */

   /* 7291422 - we now drive from the flagged gl_dist rows in
      step 1 to identify the sales orders.  While I am not
      certain it will make things better, it certainly simplifies the
      sql for future tuning efforts. */

      OPEN  so_numbers_c(l_request_id, c_org.org_id,
                         c_org.set_of_books_id, p_from_gl_date, p_to_gl_date);

      LOOP
        FETCH so_numbers_c BULK COLLECT INTO so_numbers, so_orgs
             LIMIT g_bulk_fetch_rows;

        l_so_rows := so_numbers_c%ROWCOUNT;

        /* If no rows found (last search), then exit loop */
        IF so_numbers.count = 0 and
           so_numbers_c%NOTFOUND
        THEN
           EXIT;
        END IF;

        /* Test total rows returned, if zero, then nothing to process
           in this org.. go to next one */
        IF l_so_rows = 0
        THEN
           IF PG_DEBUG in ('Y','C')
           THEN
              arp_debug.debug('   no sales orders to process - skip to next org');
           END IF;
           CLOSE so_numbers_c;
           goto next_org;
        END IF;

        /* Rows found, insert into ar_trx_cogs_gt */

        /* Step 3 - populate AR_TRX_COGS_GT with summarized data.  Data is
           recorded per invoice line and GL period.  The potential revenue
           (revenue_line_amount) is recorded in each period that a transaction
           line effects but it must be considered only once in creating
           the divisor for the final revenue percentage.  This is currently
           handled via a function call */

        FORALL i in 1 .. so_numbers.count
          INSERT INTO ar_trx_cogs_gt
           ( customer_trx_id,
             customer_trx_line_id,
             previous_customer_trx_line_id,
             so_line_id,
             period_number,
             revenue_dist_amount,
             revenue_line_amount,
             latest_gl_date,
             org_id,
             set_of_books_id
           )
           SELECT /*+ ORDERED */
             tl.customer_trx_id,
             tl.customer_trx_line_id,
             tl.previous_customer_trx_line_id,
             to_number(
                decode(tl.previous_customer_trx_line_id, NULL,
                         tl.interface_line_attribute6,
                           tli.interface_line_attribute6)),
             gps.effective_period_num,
             sum(tlgld.amount), -- revenue_dist_amount
             tl.revenue_amount, -- revenue_line_amount (not currently used)
             MAX(tlgld.gl_date),-- latest_gl_date
             tl.org_id,
             tl.set_of_books_id
           FROM   ra_customer_trx_lines_all    tl,
                  ra_customer_trx_lines_all    tli,
                  ra_cust_trx_line_gl_dist_all tlgld,
                  gl_period_statuses           gps
           WHERE
               tl.sales_order = so_numbers(i)
           AND tl.org_id = so_orgs(i)
           AND tl.customer_trx_line_id = tlgld.customer_trx_line_id
           AND tlgld.account_set_flag = 'N'
           AND tlgld.account_class = 'REV'
           AND tl.previous_customer_trx_line_id = tli.customer_trx_line_id (+)
           AND tl.interface_line_context = g_om_context -- 7349970
           AND NVL(tli.interface_line_context,tl.interface_line_context) =
                  g_om_context
           AND NVL(tli.interface_line_attribute6, tl.interface_line_attribute6)
                  IS NOT NULL
           AND NVL(tli.sales_order_line, tl.sales_order_line)
                  IS NOT NULL -- 7349970
           AND gps.set_of_books_id = tl.set_of_books_id
           AND gps.application_id = 222
           AND gps.adjustment_period_flag = 'N'
           AND tlgld.gl_date between gps.start_date and gps.end_date
           AND NVL(LENGTH(REPLACE(TRANSLATE(
                DECODE(tl.previous_customer_trx_line_id, NULL,
                   tl.interface_line_attribute6, tli.interface_line_attribute6),
                    '123456789','0000000000'),'0','')),0) = 0
           GROUP BY
              tl.customer_trx_id, tl.customer_trx_line_id,
              tl.previous_customer_trx_line_id,
              to_number(
                 decode(tl.previous_customer_trx_line_id, NULL,
                          tl.interface_line_attribute6,
                            tli.interface_line_attribute6)),
              gps.effective_period_num, tl.revenue_amount,
              tl.org_id, tl.set_of_books_id;

         l_so_rows_inserted := SQL%ROWCOUNT;

         IF PG_DEBUG in ('Y','C')
         THEN
            arp_debug.debug('  inserted ' || l_so_rows_inserted ||
                ' row(s) into ar_trx_cogs_gt');
         END IF;

      END LOOP;

      CLOSE so_numbers_c;

      IF PG_DEBUG in ('Y', 'C')
      THEN
         arp_debug.debug('  processed ' || l_so_rows ||
                      ' distinct orders.');
      END IF;

  /* debug logic +/
  IF PG_DEBUG in ('Y', 'C')
  THEN
     arp_debug.debug('start - dump of ar_trx_cogs_gt');
     FOR gt IN trx_gt LOOP
          arp_debug.debug(gt.customer_trx_id || '~' ||
                         gt.customer_trx_line_id || '~' ||
                         gt.previous_customer_trx_line_id || '~' ||
                         gt.so_line_id);
     END LOOP;
     arp_debug.debug('end - dump of ar_trx_cogs_gt');
  END IF;
  /+ end - debug logic */

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(c_org.org_id ||
                       ':   completed..' );
  END IF;

  /* 7291422 - Diagnostics to identify missed or bad orders */
  IF PG_DEBUG in ('Y','C')
  THEN
     FOR c_problem_rows IN bad_rows(c_org.org_id,
                                    p_from_gl_date, p_to_gl_date)
     LOOP
        arp_debug.debug(c_problem_rows.meaning || '(' ||
               c_problem_rows.cogs_request_id || ')  count=' ||
               c_problem_rows.error_count);
     END LOOP;
  END IF;

    <<next_org>>
    NULL;
  END LOOP; -- c_org

  /* 8821317 - retore org and context to original values */
  mo_global.set_policy_context(l_original_context, l_original_org);

  /* Step 4 - Now merge the resulting data into cst_reve_rec_lines.
      NOTE:  We are using the function potential_revenue() to fetch
      an accumulated total for the equation below.  This can probably be
      replaced with some sort of analytical function when time allows.

      NOTE:  The rev_percent calculation is actually a matrix
       of return values depending on the zero or non-zero state
       of the numerator and denominator in the actual calc

            Num

           0   !0
             +
        0  1 |  1
   Den  +----+---
       !0  0 |  Num/Den

      What this means is that if the denominator (sum of line
      revenue_amounts) is zero, we always return a 1 (100%).
      If the denominator is not 0, then we do the calculation
      of Numerator (sum of rev dist amounts) / denominator.
      In cases where the numerator is zero and the denominator
      is not zero, the calc would return zero so we skip it and
      just return zero directly.
*/

  IF PG_DEBUG in ('Y','C')
  THEN
     arp_debug.debug('  Merging into cst_revenue_recognition_lines');
  END IF;

  MERGE INTO cst_revenue_recognition_lines crrl
  USING
    (
      SELECT
         rev.so_line_id,
         max(rev.latest_gl_date) gl_date,
         gps.effective_period_num period_number,
         DECODE(ar_match_rev_cogs_grp.potential_revenue(
                  rev.so_line_id,gps.effective_period_num),0,1,
              DECODE(SUM(rev.revenue_dist_amount),0,0,
            ROUND(SUM(rev.revenue_dist_amount) /
               ar_match_rev_cogs_grp.potential_revenue(rev.so_line_id,
                                          gps.effective_period_num),4)))
            rev_percent,
         max(rev.org_id) org_id,
         gps.set_of_books_id set_of_books_id
      FROM   ar_trx_cogs_gt rev,
             gl_period_statuses gps
      WHERE gps.application_id = 222
      AND gps.set_of_books_id = rev.set_of_books_id
      AND gps.start_date <= p_to_gl_date
      AND gps.adjustment_period_flag = 'N'
      AND rev.period_number <= gps.effective_period_num
      GROUP BY rev.so_line_id, gps.effective_period_num,
               gps.set_of_books_id, gps.start_date, gps.end_date
      HAVING   max(rev.latest_gl_date) between
                 gps.start_date AND gps.end_date
    ) Q
    ON (Q.so_line_id = crrl.revenue_om_line_id AND
        Q.period_number = crrl.acct_period_num)
  WHEN MATCHED THEN
    UPDATE SET
      revenue_recognition_percent = Q.rev_percent,
      last_event_date             = Q.gl_date,
      potentially_unmatched_flag  =
          DECODE(revenue_recognition_percent, Q.rev_percent,
              potentially_unmatched_flag,'Y'),
      request_id                  =
          DECODE(revenue_recognition_percent, Q.rev_percent,
              request_id,l_request_id)
  WHEN NOT MATCHED THEN
    INSERT (revenue_om_line_id,
            acct_period_num,
            revenue_recognition_percent,
            last_event_date,
            operating_unit_id,
            ledger_id,
            customer_trx_line_id,
            potentially_unmatched_flag,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            request_id,
            program_application_id,
            program_id,
            program_update_date)
    VALUES (Q.so_line_id,
            Q.period_number,
            Q.rev_percent,
            Q.gl_date,
            Q.org_id,
            Q.set_of_books_id,
            NULL,
            'Y',
            sysdate,
            l_user_id,
            sysdate,
            l_user_id,
            l_login_id,
            l_request_id,
            l_pgm_app_id,
            l_pgm_id,
            sysdate
            );

    FND_MSG_PUB.count_and_get
      (  p_count  => x_msg_count
       , p_data   => x_msg_data
      );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_debug.debug(  'ar_match_rev_cogs_grp.populate_cst_tables()- ');
  END IF;

EXCEPTION
  WHEN fnd_api.g_exc_error THEN
    ROLLBACK TO populate_cst_tables_grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN fnd_api.g_exc_unexpected_error THEN
    ROLLBACK TO populate_cst_tables_grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

  WHEN OTHERS THEN
    IF (SQLCODE = -20001) THEN
       ROLLBACK TO populate_cst_tables_grp;
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ar_match_rev_cogs_grp.populate_cst_tables : '||SQLERRM);
       FND_MSG_PUB.Add;

       fnd_msg_pub.count_and_get (
         p_encoded => fnd_api.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data);
       RETURN;
    ELSE
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MESSAGE.SET_NAME ('AR','GENERIC_MESSAGE');
       FND_MESSAGE.SET_TOKEN('GENERIC_TEXT','ar_match_rev_cogs_grp.populate_cst_tables : '||SQLERRM);
       FND_MSG_PUB.Add;
    END IF;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(  SQLCODE);
       arp_debug.debug(  SQLERRM);
    END IF;

    ROLLBACK TO populate_cst_tables_grp;
    fnd_msg_pub.count_and_get (
      p_encoded => fnd_api.g_false,
      p_count   => x_msg_count,
      p_data    => x_msg_data);

END populate_cst_tables;

BEGIN
   g_om_context := NVL(fnd_profile.value('ONT_SOURCE_CODE'),'###NOT_SET###');
END ar_match_rev_cogs_grp;

/
