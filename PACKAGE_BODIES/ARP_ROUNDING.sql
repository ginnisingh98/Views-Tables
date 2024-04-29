--------------------------------------------------------
--  DDL for Package Body ARP_ROUNDING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ROUNDING" AS
/* $Header: ARPLCREB.pls 120.38.12010000.9 2009/12/15 23:11:48 mraymond ship $ */

 /*-------------------------------+
  |  Global variable declarations |
  +-------------------------------*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

  iTRUE  CONSTANT NUMBER  := 1;
  iFALSE CONSTANT NUMBER  := 0;
  cr	CONSTANT char(1) := NULL;

  trx_for_rof           ra_cust_trx_line_gl_dist_all.customer_trx_id%type;
                        /*Added for Bugs 2480898, 2493896, 2497841 */
  rqid_for_rof          ra_cust_trx_line_gl_dist_all.request_id%type;

  /* 7039838 - determines if call is from an autoinvoice inspired
       session */
  g_autoinv             BOOLEAN;
  g_autoinv_request_id  NUMBER;

  TYPE l_line_id_type IS TABLE OF ra_cust_trx_line_gl_dist_all.customer_trx_line_id%type
        INDEX BY BINARY_INTEGER;
  TYPE l_amount_type IS TABLE OF ra_cust_trx_line_gl_dist_all.amount%type
        INDEX BY BINARY_INTEGER;
  TYPE l_percent_type IS TABLE OF ra_cust_trx_line_gl_dist_all.percent%type
        INDEX BY BINARY_INTEGER;
  TYPE l_acct_class IS TABLE OF ra_cust_trx_line_gl_dist_all.account_class%type
        INDEX BY BINARY_INTEGER;
  TYPE l_rec_offset IS TABLE OF ra_cust_trx_line_gl_dist_all.rec_offset_flag%type
        INDEX BY BINARY_INTEGER;
  TYPE l_date_type IS TABLE OF ra_cust_trx_line_gl_dist_all.gl_date%type
        INDEX BY BINARY_INTEGER;

-- Private cursor

  select_sql_c number;

-- To hold values fetched from the Select stmt

TYPE select_rec_type IS RECORD
(
  rec_customer_trx_id                     BINARY_INTEGER,
  rec_code_combination_id                 BINARY_INTEGER,
  round_customer_trx_id                   BINARY_INTEGER
);

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    set_rec_offset_flag		                		     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets the rec_offset_flag in ra_cust_trx_line_gl_dist for REC offsetting|
 |    UNEARN/UNBILL rows if the flag has not been set already.  Procedure
 |    has two parameters.  If called with customer_trx_id, it sets the flags
 |    for that transaction.  If called by request_id, it sets the flags
 |    for invoices targeted by CM transactions in that request_id group.
 |    So, the request_id parameter is designed specifically for use by
 |    autoinvoice.
 |                                                                           |
 | SCOPE - PUBLIC                                                           |
 |    called from correct_rule_records_by_line and
 |        from within ARP_CREDIT_MEMO_MODULE                                 |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 | 		     p_customer_trx_id          			     |
 |                   p_request_id                                     |
 |              OUT:                                                         |
 |									     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 2-Aug-2002    Sahana    Bug2480898/Bug2493896: rec_offset_flag is not set |
 |                         for older transactions causing rounding logic to  |
 |                         corrupt UNEARN/UNBILL distributions               |
 | 28-AUG-2002   M Raymond Bug 2535023 - Added request-id parameter so this
 |                           could be safely called by arp_credit_memo_module
 |                           for autoinvoice.
 | 10-SEP-2002   M Raymond Corrected typo in request_id version.
 | 28-MAY2003    H Yu      BUG#2750340 XLA Uptake
 | 26-JUL-2006   M Raymond 5200647 - modified sql for performance impr.
 | 27-OCT-2006   M Raymond 5611397 - Added hints
 | 30-NOV-2007   M Raymond 6658402 - redesigned for performance issues
 | 27-MAR-2008   M Raymond 6782405 - Added result parameter
 |                            0 = no action needed, 1 = set rows, -1 = failure
 | 14-MAY-2008   M Raymond 7039838 - FT tuning
 +===========================================================================*/
PROCEDURE set_rec_offset_flag(p_customer_trx_id IN
              ra_customer_trx.customer_trx_id%type,
               p_request_id IN ra_customer_trx.request_id%type,
               p_result     OUT NOCOPY NUMBER ) IS

  CURSOR inv_needing_rof(pp_request_id NUMBER) IS
      SELECT DISTINCT inv_trx.customer_trx_id
      FROM   RA_CUSTOMER_TRX  cm_trx,
             RA_CUSTOMER_TRX  inv_trx,
             RA_CUST_TRX_LINE_GL_DIST  inv_rec
      WHERE  cm_trx.request_id = pp_request_id
      AND    cm_trx.previous_customer_trx_id = inv_trx.customer_trx_id
      AND    inv_trx.invoicing_rule_id IS NOT NULL
      AND    inv_trx.customer_trx_id = inv_rec.customer_trx_id
      AND    inv_rec.account_class = 'REC'
      AND    inv_rec.account_set_flag = 'N'
      AND    inv_rec.latest_rec_flag = 'Y'
      AND NOT EXISTS
            (SELECT /*+ NO_UNNEST NO_PUSH_SUBQ */
                    'rof already set'
             FROM   ra_cust_trx_line_gl_dist g2
             WHERE  g2.customer_trx_id = inv_trx.customer_trx_id
             AND    g2.account_set_flag = 'N'
             AND    g2.account_class in ('UNEARN','UNBILL')
             AND    g2.rec_offset_flag = 'Y');

    t_trx_id       l_line_id_type;
    l_no_rof       NUMBER;
    l_count        NUMBER;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rounding.set_rec_offset_flag()+');
  END IF;

       p_result := 0; -- no action needed

        IF (p_customer_trx_id is not NULL)
        THEN

           IF (trx_for_rof is NULL OR
               trx_for_rof <> p_customer_trx_id)
           THEN

              /* We should only attempt to set ROF if
                 a) target trx has been through Rev Rec
                 b) target trx has no ROF flag for any one line
              */

              SELECT count(*)
              INTO   l_no_rof
              FROM   ra_customer_trx_lines tl
              WHERE  tl.customer_trx_id = p_customer_trx_id
              AND    tl.line_type = 'LINE'
              AND    tl.autorule_complete_flag IS NULL
              AND    tl.accounting_rule_id IS NOT NULL
              AND NOT EXISTS
                    (SELECT /*+ NO_UNNEST NO_PUSH_SUBQ */
                            'rof already set'
                     FROM   ra_cust_trx_line_gl_dist g2
                     WHERE  g2.customer_trx_id = tl.customer_trx_id
                     AND    g2.account_set_flag = 'N'
                     AND    g2.account_class in ('UNEARN','UNBILL')
                     AND    g2.rec_offset_flag = 'Y');

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug(' l_no_rof = ' || l_no_rof);
              END IF;

              IF l_no_rof > 0
              THEN

                 /* The UNNEST hint below was included as a defensive
                    posture to an optimizer bug.  Without it, some
                    10G databases do a full scan on gl_dist for the
                    update line. */

                 /* 7039838 - added autoinv specific logic for
                      FT tuning effort */
                 IF g_autoinv
                 THEN

                 UPDATE RA_CUST_TRX_LINE_GL_DIST
                 SET    rec_offset_flag = 'Y'
                 WHERE  cust_trx_line_gl_dist_id in
                   (SELECT /*+ PUSH_SUBQ UNNEST
                               index(tl RA_CUSTOMER_TRX_LINES_N4) */
                           g.cust_trx_line_gl_dist_id
                    FROM   ra_cust_trx_line_gl_dist g,
                           ra_customer_trx_lines    tl,
                           ra_cust_trx_line_gl_dist grec
                    WHERE  tl.customer_trx_id = p_customer_trx_id
                    AND    tl.request_id = g_autoinv_request_id
                    AND    tl.accounting_rule_id is not null
                    AND    tl.customer_trx_line_id = g.customer_trx_line_id
                    AND    tl.line_type = 'LINE'
                    AND    grec.customer_trx_id = tl.customer_trx_id
                    AND    grec.account_class = 'REC'
                    AND    grec.latest_rec_flag = 'Y'
                    AND    grec.gl_date = g.gl_date
                    AND    g.account_set_flag = 'N'
                    AND    g.account_class in ('UNEARN','UNBILL')
                    AND    g.revenue_adjustment_id is null
                    AND    g.request_id is not null
                    AND    sign(g.amount) = sign(tl.revenue_amount)
                    AND    g.rec_offset_flag is null);

                 ELSE

                 UPDATE RA_CUST_TRX_LINE_GL_DIST
                 SET    rec_offset_flag = 'Y'
                 WHERE  cust_trx_line_gl_dist_id in
                   (SELECT /*+ PUSH_SUBQ UNNEST */
                           g.cust_trx_line_gl_dist_id
                    FROM   ra_cust_trx_line_gl_dist g,
                           ra_customer_trx_lines    tl,
                           ra_cust_trx_line_gl_dist grec
                    WHERE  tl.customer_trx_id = p_customer_trx_id
                    AND    tl.accounting_rule_id is not null
                    AND    tl.customer_trx_line_id = g.customer_trx_line_id
                    AND    tl.line_type = 'LINE'
                    AND    grec.customer_trx_id = tl.customer_trx_id
                    AND    grec.account_class = 'REC'
                    AND    grec.latest_rec_flag = 'Y'
                    AND    grec.gl_date = g.gl_date
                    AND    g.account_set_flag = 'N'
                    AND    g.account_class in ('UNEARN','UNBILL')
                    AND    g.revenue_adjustment_id is null
                    AND    g.request_id is not null
                    AND    sign(g.amount) = sign(tl.revenue_amount)
                    AND    g.rec_offset_flag is null);

                 END IF; -- end g_autoinv

                    l_count := SQL%ROWCOUNT;

                  IF PG_DEBUG in ('Y', 'C') THEN
                     arp_util.debug('   updated ' || l_count ||
                            ' rec_offset rows.');
                  END IF;

                    /* indicate if rows were set or not */
                    IF l_count > 0
                    THEN
                       p_result := 1; -- rows were set
                    ELSE
                       p_result := -1; -- no rows were set
                    END IF;

              END IF;

                 /* Now set trx_for_rof so this does not execute again
                    for this transaction within this session. */
                 trx_for_rof := p_customer_trx_id;
           END IF;

        ELSE
          /* Request ID - specifically for CMs via autoinvoice */
          IF (rqid_for_rof is NULL or
              rqid_for_rof <> p_request_id)
          THEN

             /* 6658402 - Executing a bulk fetch, then a
                  forall update to improve performance */
             OPEN inv_needing_rof(p_request_id);
 	     FETCH inv_needing_rof BULK COLLECT INTO
                             t_trx_id;

             l_no_rof := inv_needing_rof%ROWCOUNT;

             CLOSE inv_needing_rof;

             IF l_no_rof > 0
             THEN
               FORALL i IN t_trx_id.FIRST .. t_trx_id.LAST
               UPDATE RA_CUST_TRX_LINE_GL_DIST G
                 SET    rec_offset_flag = 'Y'
                 WHERE G.cust_trx_line_gl_dist_id in
                   (SELECT /*+ PUSH_SUBQ ORDERED UNNEST */
                           inv_g.cust_trx_line_gl_dist_id
                    FROM   ra_customer_trx_lines    inv_l,
                           ra_cust_trx_line_gl_dist inv_g,
                           ra_cust_trx_line_gl_dist inv_grec
                    WHERE  inv_l.customer_trx_id = t_trx_id(i)
                    AND    inv_l.accounting_rule_id is not null
                    AND    inv_l.customer_trx_line_id =
                              inv_g.customer_trx_line_id
                    AND    inv_l.line_type = 'LINE'
                    AND    inv_grec.customer_trx_id = inv_l.customer_trx_id
                    AND    inv_grec.account_class = 'REC'
                    AND    inv_grec.latest_rec_flag = 'Y'
                    AND    inv_grec.gl_date = inv_g.gl_date
                    AND    inv_g.account_set_flag = 'N'
                    AND    inv_g.account_class in ('UNEARN','UNBILL')
                    AND    inv_g.revenue_adjustment_id is null
                    AND    inv_g.request_id is not null
                    AND    sign(inv_g.amount) = sign(inv_l.revenue_amount)
                    AND    inv_g.rec_offset_flag is null);

              l_count := SQL%ROWCOUNT;

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_util.debug('   updated ' || l_count || ' rec_offset rows.');
              END IF;
              IF l_count > 0
              THEN
                  /* we updated some.  Technically, this does not mean
                     we are out of the woods, but we'll assume it set them */
                  p_result := 1;
              ELSE
                  /* no rows updated when some needed it */
                  p_result := -1;
              END IF;

              rqid_for_rof := p_request_id;
             END IF;
          END IF;
        END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_rounding.set_rec_offset_flag()-');
  END IF;
EXCEPTION
WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_process_dist.set_rec_offset_flag()');
   RAISE;
END;

/*===========================================================================+
 | PRIVATE PROCEDURE                                                                 |
 |    true_lines_by_gl_date		                		     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure tests each gl_date for a transaction line to verify
 |    that the gl_dist rows sum to zero on that date.  If they do not,
 |    we update a dist row on that date for the delta amount and/or percent.
 |    The row chosen for update is the one with the max gl_dist_id on that
 |    date with an amount that has the same sign as the extended_amount
 |    of the line.
 |
 |    This means that we will generally update REV lines for both invoices
 |    and credit memos - unless there is a more recent adjustment on the
 |    line, which will push us to choose the latest adjustment distribution.
 |                                                                           |
 |    As a bonus, we now also check RAM distributions separately from
 |    conventional distributions and round them (by line_id, gl_date, and
 |    revenue_adjustment_id) if they need it.
 |
 | SCOPE - PRIVATE                                                           |
 |    called from correct_rule_records_by_line
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 | 		     p_customer_trx_id          			     |
 |              OUT:                                                         |
 |									     |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 05-SEP-2002   M RAYMOND   Bug 2535023 - Created
 | 09-SEP-2002   M RAYMOND   Bug 2543675 - Excluded non-rule trx from
 |                                         being processed.
 | 13-SEP-2002   M RAYMOND   Bug 2543675 - Process RAM dists to make sure
 |                                         that they balance, too.
 |
 +===========================================================================*/
PROCEDURE true_lines_by_gl_date(p_customer_trx_id IN
              ra_customer_trx.customer_trx_id%type) IS

  /* Cursor for TRUing by gl_date
     Detects GL_DATES that do not sum to zero.
     This is usually due to behavior of older
     autoaccounting or shortcomings in trx workbench
     calculations.  It should not pick up non-rule trx
     or CMs on non-rule trx.*/
  CURSOR true_rows_by_date(p_trx_id NUMBER) IS
     select g.customer_trx_line_id, g.gl_date,
            sum(g.amount), sum(g.acctd_amount), sum(g.percent),
            nvl(revenue_adjustment_id, -99) revenue_adjustment_id
     from   ra_cust_trx_line_gl_dist g,
            ra_customer_trx h,
            ra_customer_trx prev_h
     where  h.customer_trx_id = p_trx_id
     and    h.previous_customer_trx_id = prev_h.customer_trx_id (+)
     and    nvl(h.invoicing_rule_id, prev_h.invoicing_rule_id) is not null
     and    g.customer_trx_id = h.customer_trx_id
     and    g.account_class in ('REV','UNEARN','UNBILL')
     and    g.account_set_flag = 'N'
     and    g.rec_offset_flag is null
     and    g.posting_control_id = -3
     group by g.customer_trx_line_id, g.gl_date, nvl(g.revenue_adjustment_id, -99)
     having sum(amount) <> 0 or sum(acctd_amount) <> 0 or sum(percent) <> 0;

  CURSOR true_rows_by_date_gt IS
     select g.customer_trx_line_id, g.gl_date,
            sum(g.amount), sum(g.acctd_amount), sum(g.percent),
            nvl(g.revenue_adjustment_id, -99) revenue_adjustment_id
     from   ra_cust_trx_line_gl_dist g,
            ar_line_rev_adj_gt gt,
            ra_customer_trx h,
            ra_customer_trx prev_h
     where  h.customer_trx_id = g.customer_trx_id
     and    h.previous_customer_trx_id = prev_h.customer_trx_id (+)
     and    nvl(h.invoicing_rule_id, prev_h.invoicing_rule_id) is not null
     and    g.customer_trx_line_id = gt.customer_trx_line_id
     and    g.account_class in ('REV','UNEARN','UNBILL')
     and    g.account_set_flag = 'N'
     and    g.rec_offset_flag is null
     and    g.posting_control_id = -3
     group by g.customer_trx_line_id, g.gl_date, nvl(g.revenue_adjustment_id, -99)
     having sum(g.amount) <> 0 or sum(g.acctd_amount) <> 0 or sum(g.percent) <> 0;


  /* Tables for truing lines */
  t_true_line_id  l_line_id_type;
  t_true_gl_date  l_date_type;
  t_true_amount   l_amount_type;
  t_true_acctd    l_amount_type;
  t_true_percent  l_percent_type;
  t_true_ram_id   l_line_id_type;

  l_rows_needing_truing NUMBER;

BEGIN
     arp_util.debug('arp_rounding.true_lines_by_gl_date()+');

     IF (p_customer_trx_id IS NOT NULL)
     THEN
        /* True the rows (if required) */
        OPEN true_rows_by_date(P_CUSTOMER_TRX_ID);
           FETCH true_rows_by_date BULK COLLECT INTO
                             t_true_line_id,
                             t_true_gl_date,
                             t_true_amount,
                             t_true_acctd,
                             t_true_percent,
                             t_true_ram_id;

        l_rows_needing_truing := true_rows_by_date%ROWCOUNT;

        CLOSE true_rows_by_date;
     ELSE
        /* True the rows (if required) */
        OPEN true_rows_by_date_gt;
           FETCH true_rows_by_date_gt BULK COLLECT INTO
                             t_true_line_id,
                             t_true_gl_date,
                             t_true_amount,
                             t_true_acctd,
                             t_true_percent,
                             t_true_ram_id;

        l_rows_needing_truing := true_rows_by_date_gt%ROWCOUNT;

        CLOSE true_rows_by_date_gt;

     END IF;

     /* Now update all the rows that require it */

     arp_standard.debug('Rows that need truing: ' || l_rows_needing_truing);

     IF (l_rows_needing_truing > 0) THEN

        FORALL i IN t_true_line_id.FIRST .. t_true_line_id.LAST
            UPDATE ra_cust_trx_line_gl_dist g
            SET    amount = amount - t_true_amount(i),
                   percent = percent - t_true_percent(i),
                   acctd_amount = acctd_amount - t_true_acctd(i),
                   last_updated_by = arp_global.last_updated_by,
                   last_update_date = sysdate
            WHERE  cust_trx_line_gl_dist_id in (
              /* SELECT GL_DIST_ID FOR EACH DATE THAT
                 REQUIRES TRUING */
              select MAX(g.cust_trx_line_gl_dist_id)
              from   ra_cust_trx_line_gl_dist g,
                     ra_customer_trx_lines    tl
              where  g.customer_trx_line_id = t_true_line_id(i)
              and    g.gl_date              = t_true_gl_date(i)
              and    g.customer_trx_line_id = tl.customer_trx_line_id
              and    sign(g.amount) = sign(tl.revenue_amount)
              and    g.account_set_flag = 'N'
              and    g.rec_offset_flag is null
              and    nvl(g.revenue_adjustment_id, -99) = t_true_ram_id(i)
              and    g.posting_control_id = -3
              /* END OF GL_DIST BY DATE SELECT */
              );

       IF (l_rows_needing_truing <> SQL%ROWCOUNT) THEN

          /* There was a problem and we did not update the correct number
             of rows.  Display the rows requiring update and indicate if they were
             updated. */

          arp_standard.debug('Mismatch between lines found and lines updated for truing (see below)');

          arp_standard.debug('Rows targeted for truing:');

          FOR err in t_true_line_id.FIRST .. t_true_line_id.LAST LOOP

              arp_standard.debug( t_true_line_id(err) || '  ' ||
                                       t_true_gl_date(err) || '  ' ||
                                       t_true_amount(err) || ' ' ||
                                       t_true_acctd(err) || ' ' ||
                                       t_true_percent(err) || '   ' ||
                                       SQL%BULK_ROWCOUNT(err));

          END LOOP;

          /* While I am concerned if we were unable to find a row for truing,
             I don't think it is grounds for failing the process because it
             could be some unforeseen situation.  So, I let it fall into
             the standard rounding code where we will make sure the transaction
             line balances.  */

       END IF;

     END IF;

     arp_util.debug('arp_rounding.true_lines_by_gl_date()-');
EXCEPTION
WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_rounding.true_lines_by_gl_date()');
   RAISE;
END;

/*===========================================================================+
 | PRIVATE PROCEDURE                                                        |
 |    correct_suspense		                		     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure tweaks SUSPENSE lines in cases where line-level
 |    rounding and autoinvoice clearing are both enabled.  This same issue
 |    is handled properly for header-level rounding by a previous bug.
 |                                                                           |
 |    Technically speaking, this code only actually processes (corrects)
 |    when the transaction has rules.  Non-rule transactions already round
 |    arbitrarily to a single REV or SUSPENSE distribution.
 |
 | SCOPE - PRIVATE                                                           |
 |    called from do_line_level_rounding
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |    arp_util.debug                                                         |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 | 		     p_customer_trx_id          			     |
 |                   p_request_id                                     |
 |              OUT:                                                         |
 |          IN/ OUT:							     |
 |                    None						     |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 29-APR-04     M Raymond Created
 | 26-MAY-04     M Raymond 3651898 - removed error handling condition
 |                         as it was raising an error unnecessarily
 | 01-JUN-04     M Raymond Converted from FUNCTION to PROCEDURE
 +===========================================================================*/
PROCEDURE correct_suspense(p_customer_trx_id IN
              ra_customer_trx.customer_trx_id%type) IS

   l_acctd_correction ra_cust_trx_line_gl_dist.acctd_amount%type;
   l_rows  NUMBER;
BEGIN
       arp_util.debug('arp_rounding.correct_suspense()+');

        IF (p_customer_trx_id is not NULL)
        THEN

           l_acctd_correction :=
              get_dist_round_acctd_amount(p_customer_trx_id);

           IF (l_acctd_correction <> 0)
           THEN
                 UPDATE RA_CUST_TRX_LINE_GL_DIST
                 SET    acctd_amount = acctd_amount + l_acctd_correction
                 WHERE  cust_trx_line_gl_dist_id in
                   (SELECT MAX(g.cust_trx_line_gl_dist_id)
                    FROM   ra_cust_trx_line_gl_dist g
                    WHERE  g.account_class = 'SUSPENSE'
                    AND    g.account_set_flag = 'N'
                    AND    g.customer_trx_id = p_customer_trx_id
                    AND    g.posting_control_id = -3
                    AND    g.acctd_amount = (
                       SELECT MAX(g2.acctd_amount)
                       FROM   ra_cust_trx_line_gl_dist g2
                       WHERE  g2.customer_trx_id = p_customer_trx_id
                       AND    g2.account_class = 'SUSPENSE'
                       AND    g2.account_set_flag = 'N'
                       AND    g2.posting_control_id = -3));

                 l_rows := SQL%ROWCOUNT;
                 arp_util.debug('   updated ' || l_rows
                                               || ' suspense rows.');

           ELSE
                 arp_util.debug('   no suspense correction required');
           END IF;

        END IF;
/***********************************************
 * MRC Processing Bug 4018317 Added the call   *
 * required for new procedure correct_suspense *
 **********************************************/
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('doing rounding for MRC if necessary');
  END IF;
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_SUSPENSE',
                   NULL, /*P_REQUEST_ID */
                   P_CUSTOMER_TRX_ID,
                   NULL,    /* customer trx line id */
                   NULL, /*p_trx_class_to_process */
         	   NULL,   /* concat_segs */
                   NULL,  /* balanced round_ccid */
                   NULL, /*p_check_rules_flag*/
                   NULL /*p_period_set_name */
                  );
  IF PG_DEBUG in ('Y', 'C') THEN
   arp_util.debug('arp_rounding.correct_suspense-');
  END IF;
EXCEPTION
WHEN OTHERS THEN
   arp_util.debug('EXCEPTION:  arp_process_dist.correct_suspense()');
END;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   do_setup()                                                            |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function checks the parameters for validity and sets some        |
 |   default values.                                                       |
 |                                                                         |
 | REQUIRES                                                                |
 |   All IN parameters.                                                    |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE   if no errors occur and all of the parameters are valid.        |
 |   FALSE  otherwise.                                                     |
 |                                                                         |
 | NOTES                                                                   |
 |   The function does the following parameter validations:                |
 |                                                                         |
 |   1) Either the REQUEST_ID,  CUSTOMER_TRX_ID or CUSTOMER_TRX_LINE_ID    |
 |      parameters must be not null.                                       |
 |                                                                         |
 |   2) If REQUEST_ID is specified, CUSTOMER_TRX_ID and                    |
 |      CUSTOMER_TRX_LINE_ID must be null.                                 |
 |                                                                         |
 |   3) If CUSTOMER_TRX_LINE_ID is specified, CUSTOMER_TRX_ID must be      |
 |      specified.                                                         |
 |                                                                         |
 |   4) TRX_CLASS_TO_PROCESS must be either null, REGULAR_CM, INV or ALL.  |
 |                                                                         |
 |   5) CHECK_RULES_FLAG must be either null, Y or N.                      |
 |                                                                         |
 |   6) P_TRX_HEADER_LEVEL_ROUNDING must be either null, Y or N.           |
 |                                                                         |
 |   7) P_ACTIVITY_FLAG must be either null, Y or N.                       |
 |                                                                         |
 |   8) P_TRX_HEADER_LEVEL_ROUNDING is Y then either the REQUEST_ID or     |
 |      CUSTOMER_TRX_ID parameters must be not null.                       |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/


FUNCTION do_setup( P_REQUEST_ID                    IN NUMBER,
                   P_CUSTOMER_TRX_ID               IN NUMBER,
                   P_CUSTOMER_TRX_LINE_ID          IN NUMBER,
                   P_BASE_PRECISION                IN NUMBER,
                   P_BASE_MIN_ACCOUNTABLE_UNIT     IN VARCHAR2,
                   P_TRX_CLASS_TO_PROCESS          IN VARCHAR2,
                   P_CHECK_RULES_FLAG              IN VARCHAR2,
                   P_DEBUG_MODE                    IN VARCHAR2,
                   BASE_PRECISION                  OUT NOCOPY NUMBER,
                   BASE_MIN_ACCOUNTABLE_UNIT       OUT NOCOPY NUMBER,
                   TRX_CLASS_TO_PROCESS            OUT NOCOPY VARCHAR2,
                   CHECK_RULES_FLAG                OUT NOCOPY VARCHAR2,
                   PERIOD_SET_NAME                 OUT NOCOPY VARCHAR2,
                   P_ROWS_PROCESSED                OUT NOCOPY NUMBER,
                   P_ERROR_MESSAGE                 OUT NOCOPY VARCHAR2,
                   P_TRX_HEADER_LEVEL_ROUNDING     IN  VARCHAR2,
                   P_ACTIVITY_FLAG                 IN  VARCHAR2,
                   ACTIVITY_FLAG                   OUT NOCOPY VARCHAR2,
                   TRX_HEADER_ROUND_CCID           OUT NOCOPY NUMBER
                 ) RETURN NUMBER IS

BEGIN

 /*-------------------------------+
  |  Enable debug mode if desired |
  +-------------------------------*/

 IF    (p_debug_mode = 'Y')
 THEN
       arp_standard.enable_debug;
 ELSE  IF (p_debug_mode = 'N')
       THEN
           arp_standard.disable_debug;
       END IF;
 END IF;

 IF PG_DEBUG in ('Y', 'C') THEN
    arp_standard.debug('  arp_rounding.do_setup()+ ' ||
                    TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
 END IF;

  /*----------------------+
    | Validate parameters |
    +---------------------*/
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('Request_id: ' || p_request_id ||
                     ' ctid: '|| p_customer_trx_id ||'  ctlid: '||
                     p_customer_trx_line_id || '  class: ' ||
                     trx_class_to_process || '  Rules: '||
                     check_rules_flag);
   END IF;


  /*---------------------------------------------------+
   |  6) P_TRX_HEADER_LEVEL_ROUNDING must be Y or N.   |
   +---------------------------------------------------*/

  if   (
          p_trx_header_level_rounding not in ('Y', 'N')
       )
  then
       p_error_message := 'arp_rounding - ' ||
       arp_standard.fnd_message('AR_CUST_INVALID_PARAMETER', 'PARAMETER', p_trx_header_level_rounding, 'P_TRX_HEADER_LEVEL_ROUNDING');

       return(iFALSE);
  end if;

  /*-------------------------------------------------------------+
   |  1) Either the REQUEST_ID,  CUSTOMER_TRX_ID or              |
   |     CUSTOMER_TRX_LINE_ID parameters must be not null.       |
   |                                                             |
   |  2) If REQUEST_ID is specified, CUSTOMER_TRX_ID and         |
   |     CUSTOMER_TRX_LINE_ID must be null.                      |
   |                                                             |
   |  3) If CUSTOMER_TRX_LINE_ID is specified, CUSTOMER_TRX_ID   |
   |     must be specified.                                      |
   |                                                             |
   |  8) If p_trx_header_level_rounding  = Y then either the     |
   |     REQUEST_ID or CUSTOMER_TRX_ID parameters must be        |
   |     not null.                                               |
   +------------------------------------------------------------*/

 IF   (
        (
          p_request_id           IS NULL AND
          p_customer_trx_id      IS NULL AND
          p_customer_trx_line_id IS NULL
        )
       OR
        (
          p_request_id       IS NOT NULL AND
          (p_customer_trx_id IS NOT NULL OR p_customer_trx_line_id IS NOT NULL)
        )
       OR
        (
          p_customer_trx_line_id is not null AND
          p_customer_trx_id is null
        )
       OR
        ( p_trx_header_level_rounding = 'Y' AND
          p_request_id is null              AND
          p_customer_trx_id is null
        )
       )
  THEN
       p_error_message := 'arp_rounding - ' ||
               arp_standard.fnd_message(arp_standard.MD_MSG_NUMBER,
                                       'AR-PLCRE-PARAM-ID') || ' - ' ||
                          arp_standard.fnd_message('AR-PLCRE-PARAM-ID');
       RETURN( iFALSE );

  END IF;


  /*------------------------------------------+
   |  4) TRX_CLASS_TO_PROCESS must be either: |
   |     null, REGULAR_CM, INV or ALL.        |
   +------------------------------------------*/

  IF (
      p_trx_class_to_process IS NOT NULL AND
      p_trx_class_to_process NOT IN ('REGULAR_CM', 'INV', 'ALL')
     )
  THEN
      p_error_message := 'arp_rounding - ' ||
           arp_standard.fnd_message(arp_standard.MD_MSG_NUMBER,
                                    'AR-PLCRE-PARAM-CLASS') || ' - ' ||
                          arp_standard.fnd_message('AR-PLCRE-PARAM-CLASS');
      RETURN( iFALSE );
  ELSE
      trx_class_to_process := p_trx_class_to_process;
  END IF;


  /*---------------------------------------------------+
   |  5) CHECK_RULES_FLAG must be either null, Y or N. |
   +---------------------------------------------------*/

  IF (
      p_check_rules_flag IS NOT NULL AND
      p_check_rules_flag NOT IN ('Y', 'N')
     )
  THEN
      p_error_message := 'arp_rounding - ' ||
            arp_standard.fnd_message(arp_standard.MD_MSG_NUMBER,
                                 'AR-PLCRE-PARAM-RULES') || ' - ' ||
                          arp_standard.fnd_message('AR-PLCRE-PARAM-RULES');
      RETURN( iFALSE );
  ELSE
       check_rules_flag := p_check_rules_flag;
  END IF;

  /*---------------------------------------------------+
   |  7) P_ACTIVITY_FLAG must be either null, Y or N. |
   +---------------------------------------------------*/
/* bug 912501 : Added 'G' for the possible values of p_activity_flag */
  if   (
          p_activity_flag is not null AND
          p_activity_flag not in ('Y', 'N','G')
       )
  then
       p_error_message := 'arp_rounding - ' ||
       arp_standard.fnd_message('AR_CUST_INVALID_PARAMETER', 'PARAMETER', p_activity_flag, 'PARAMETER', 'P_ACTIVITY_FLAG');

       return(iFALSE);
  else
       activity_flag := p_activity_flag;
  end if;

   /*--------------------+
    | Set default values |
    +--------------------*/

  p_rows_processed := 0;

  IF (p_trx_class_to_process IS NULL)
  THEN
      trx_class_to_process := 'ALL';
  END IF;

  IF (p_check_rules_flag IS NULL)
  THEN
      check_rules_flag := 'N';
  END IF;

  if    (p_activity_flag is null)
  then  activity_flag := 'N';
  end if;

  if (
        (p_base_precision is null and p_base_min_accountable_unit is null)
      OR
      ( p_check_rules_flag = 'Y' )
     )
  THEN

     SELECT
            precision,
            minimum_accountable_unit,
            period_set_name
     INTO
            base_precision,
            base_min_accountable_unit,
            period_set_name
     FROM
            fnd_currencies       f,
            gl_sets_of_books     b,
            ar_system_parameters p
     WHERE
            p.set_of_books_id = b.set_of_books_id
     AND    f.currency_code   = b.currency_code;

  ELSE

      base_precision            := p_base_precision;
      base_min_accountable_unit := p_base_min_accountable_unit;
  end if;

  trx_header_round_ccid :=
         arp_global.sysparam.trx_header_round_ccid;

   /*------------------------------------------+
    | Set default values                       |
    | If p_trx_header_level_rounding  = Y then |
    | trx_header_round_ccid should be not null |
    +------------------------------------------*/

  if   (
          p_trx_header_level_rounding = 'Y' AND
          (trx_header_round_ccid is null  OR
           trx_header_round_ccid = -1)
       )
  then
       FND_MESSAGE.set_name('AR','AR-PLCRE-THLR-CCID');
       p_error_message := 'arp_rounding - ' || fnd_message.get;
       return(iFALSE);
  end if;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_rounding.do_setup()- ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  RETURN( iTRUE );

END do_setup;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   insert_round_records()                                                |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function inserts one record of account_class ROUND into the      |
 |   ra_cust_trx_line_gl_dist table.                                       |
 |                                                                         |
 |   If the ROUND record already exist for a transaction then it is not    |
 |   inserted again. Like the REC record there will be only 1 (2 in case of|
 |   transaction with rule) ROUND record for each transaction.             |
 |   The ROUND record is copied from the REC record of the invoice         |
 |                                                                         |
 |   Some of the column values for the ROUND record  are as follows:       |
 |                                                                         |
 |   customer_trx_line_id = NULL                                           |
 |   gl_date              = receivable gl_date                             |
 |   latest_rec_flag      = NULL                                           |
 |   account_set_flag     = receivable account_set_flag                    |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   An ORACLE ERROR EXCEPTION if an ORACLE error occurs                   |
 |                                                                         |
 | NOTES                                                                   |
 |   *** PLEASE READ THE PACKAGE LEVEL NOTE BEFORE MODIFYING THIS FUNCTION.|
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 | 13-Aug-2002    Debbie Jancis    Modified for mrc trigger replacement    |
 |                                 added calls for insert into             |
 |                                 ra_cust_trx_line_gl_dist                |
 | 24-SEP-2002    M.Ryzhikova      Modified for mrc trigger replacement.   |
 | 01-OCT-2003    M Raymond        Bug 3067588 - made this function public
 +-------------------------------------------------------------------------*/

FUNCTION insert_round_records( P_REQUEST_ID IN NUMBER,
                               P_CUSTOMER_TRX_ID       IN NUMBER,
                               P_ROWS_PROCESSED        IN OUT NOCOPY NUMBER,
                               P_ERROR_MESSAGE            OUT NOCOPY VARCHAR2,
                               P_BASE_PRECISION        IN NUMBER,
                               P_BASE_MAU              IN NUMBER,
                               P_TRX_CLASS_TO_PROCESS  IN VARCHAR2,
                               P_TRX_HEADER_ROUND_CCID IN NUMBER)
RETURN NUMBER IS

 rows  NUMBER;

 l_gl_dist_key_value_list gl_ca_utility_pkg.r_key_value_arr;   /* mrc */
 --BUG#2750340
 l_xla_ev_rec             ARP_XLA_EVENTS.XLA_EVENTS_TYPE;

begin

  rows := 0;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.insert_round_record()+ ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

if (p_request_id is not null )
then
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('p_request_id is not null ....' || to_char(p_request_id));
   END IF;

insert into ra_cust_trx_line_gl_dist
 (POST_REQUEST_ID           ,
  POSTING_CONTROL_ID        ,
  ACCOUNT_CLASS             ,
  RA_POST_LOOP_NUMBER       ,
  CUSTOMER_TRX_ID           ,
  ACCOUNT_SET_FLAG          ,
  ACCTD_AMOUNT              ,
  USSGL_TRANSACTION_CODE    ,
  USSGL_TRANSACTION_CODE_CONTEXT  ,
  ATTRIBUTE11                     ,
  ATTRIBUTE12                     ,
  ATTRIBUTE13                     ,
  ATTRIBUTE14                     ,
  ATTRIBUTE15                     ,
  LATEST_REC_FLAG                 ,
  ORG_ID                          ,
  CUST_TRX_LINE_GL_DIST_ID        ,
  CUSTOMER_TRX_LINE_ID            ,
  CODE_COMBINATION_ID             ,
  SET_OF_BOOKS_ID                 ,
  LAST_UPDATE_DATE                ,
  LAST_UPDATED_BY                 ,
  CREATION_DATE                   ,
  CREATED_BY                      ,
  LAST_UPDATE_LOGIN               ,
  PERCENT                         ,
  AMOUNT                          ,
  GL_DATE                         ,
  GL_POSTED_DATE                  ,
  CUST_TRX_LINE_SALESREP_ID       ,
  COMMENTS                        ,
  ATTRIBUTE_CATEGORY              ,
  ATTRIBUTE1                      ,
  ATTRIBUTE2                      ,
  ATTRIBUTE3                      ,
  ATTRIBUTE4                      ,
  ATTRIBUTE5                      ,
  ATTRIBUTE6                      ,
  ATTRIBUTE7                      ,
  ATTRIBUTE8                      ,
  ATTRIBUTE9                      ,
  ATTRIBUTE10                     ,
  REQUEST_ID                      ,
  PROGRAM_APPLICATION_ID          ,
  PROGRAM_ID                      ,
  PROGRAM_UPDATE_DATE             ,
  CONCATENATED_SEGMENTS           ,
  ORIGINAL_GL_DATE                )
select
POST_REQUEST_ID,
-3,
'ROUND',
RA_POST_LOOP_NUMBER,
CUSTOMER_TRX_ID,
ACCOUNT_SET_FLAG,
NULL,  /* acctd_amount */
USSGL_TRANSACTION_CODE,
USSGL_TRANSACTION_CODE_CONTEXT,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
NULL,      /* LATEST_REC_FLAG */
ORG_ID,
RA_CUST_TRX_LINE_GL_DIST_s.nextval,
CUSTOMER_TRX_LINE_ID,
P_TRX_HEADER_ROUND_CCID,  /* CODE_COMBINATION_ID */
SET_OF_BOOKS_ID,
SYSDATE,
arp_global.last_updated_by,
SYSDATE,
arp_global.created_by,
arp_global.last_update_login,
PERCENT,
NULL,  /* AMOUNT */
GL_DATE,
GL_POSTED_DATE,
CUST_TRX_LINE_SALESREP_ID,
COMMENTS,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
arp_global.request_id,
arp_global.program_application_id,
arp_global.program_id,
arp_global.program_update_date,
CONCATENATED_SEGMENTS,
ORIGINAL_GL_DATE
from ra_cust_trx_line_gl_dist rec
where account_class = 'REC'
and   latest_rec_flag = 'Y'
and   gl_posted_date is null
and   rec.request_id = p_request_id
/* bug3311759 : Removed
and   not exists ( select 1
                   from   ra_cust_trx_line_gl_dist dist2
                   where  dist2.customer_trx_id = rec.customer_trx_id
                   and    dist2.account_class in ('UNEARN','UNBILL')
                   and    dist2.account_set_flag = 'N')
*/
and   not exists ( select 1
                   from   ra_cust_trx_line_gl_dist dist2
                   where  dist2.customer_trx_id = rec.customer_trx_id
                   and    dist2.account_class = 'ROUND'
                   and    dist2.account_set_flag = rec.account_set_flag);

    rows := SQL%ROWCOUNT;

    IF (rows > 0) THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('calling mrc engine for insertion of gl dist data');
       END IF;
       ar_mrc_engine.mrc_bulk_process(
                    p_request_id   => p_request_id,
                    p_table_name   => 'GL_DIST');
    END IF;
end if;

if p_customer_trx_id is not null
then
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('customer trx id is not null....  ===  ' || to_char(p_customer_trx_id));
   END IF;

insert into ra_cust_trx_line_gl_dist
 (POST_REQUEST_ID           ,
  POSTING_CONTROL_ID        ,
  ACCOUNT_CLASS             ,
  RA_POST_LOOP_NUMBER       ,
  CUSTOMER_TRX_ID           ,
  ACCOUNT_SET_FLAG          ,
  ACCTD_AMOUNT              ,
  USSGL_TRANSACTION_CODE    ,
  USSGL_TRANSACTION_CODE_CONTEXT  ,
  ATTRIBUTE11                     ,
  ATTRIBUTE12                     ,
  ATTRIBUTE13                     ,
  ATTRIBUTE14                     ,
  ATTRIBUTE15                     ,
  LATEST_REC_FLAG                 ,
  ORG_ID                          ,
  CUST_TRX_LINE_GL_DIST_ID        ,
  CUSTOMER_TRX_LINE_ID            ,
  CODE_COMBINATION_ID             ,
  SET_OF_BOOKS_ID                 ,
  LAST_UPDATE_DATE                ,
  LAST_UPDATED_BY                 ,
  CREATION_DATE                   ,
  CREATED_BY                      ,
  LAST_UPDATE_LOGIN               ,
  PERCENT                         ,
  AMOUNT                          ,
  GL_DATE                         ,
  GL_POSTED_DATE                  ,
  CUST_TRX_LINE_SALESREP_ID       ,
  COMMENTS                        ,
  ATTRIBUTE_CATEGORY              ,
  ATTRIBUTE1                      ,
  ATTRIBUTE2                      ,
  ATTRIBUTE3                      ,
  ATTRIBUTE4                      ,
  ATTRIBUTE5                      ,
  ATTRIBUTE6                      ,
  ATTRIBUTE7                      ,
  ATTRIBUTE8                      ,
  ATTRIBUTE9                      ,
  ATTRIBUTE10                     ,
  REQUEST_ID                      ,
  PROGRAM_APPLICATION_ID          ,
  PROGRAM_ID                      ,
  PROGRAM_UPDATE_DATE             ,
  CONCATENATED_SEGMENTS           ,
  ORIGINAL_GL_DATE                )
select
POST_REQUEST_ID,
-3,
'ROUND',
RA_POST_LOOP_NUMBER,
CUSTOMER_TRX_ID,
ACCOUNT_SET_FLAG,
NULL,  /* acctd_amount */
USSGL_TRANSACTION_CODE,
USSGL_TRANSACTION_CODE_CONTEXT,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
NULL,      /* LATEST_REC_FLAG */
ORG_ID,
RA_CUST_TRX_LINE_GL_DIST_s.nextval,
CUSTOMER_TRX_LINE_ID,
P_TRX_HEADER_ROUND_CCID,  /* CODE_COMBINATION_ID */
SET_OF_BOOKS_ID,
SYSDATE,
arp_global.last_updated_by,
SYSDATE,
arp_global.created_by,
arp_global.last_update_login,
PERCENT,
NULL,    /* AMOUNT */
GL_DATE,
GL_POSTED_DATE,
CUST_TRX_LINE_SALESREP_ID,
COMMENTS,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
arp_global.request_id,
arp_global.program_application_id,
arp_global.program_id,
arp_global.program_update_date,
CONCATENATED_SEGMENTS,
ORIGINAL_GL_DATE
from ra_cust_trx_line_gl_dist rec
where account_class = 'REC'
and   latest_rec_flag = 'Y'
and   gl_posted_date is null
and   rec.customer_trx_id = p_customer_trx_id
/* bug3311759 : Removed
and   not exists ( select 1
                   from   ra_cust_trx_line_gl_dist dist2
                   where  dist2.customer_trx_id = rec.customer_trx_id
                   and    dist2.account_class in ('UNEARN','UNBILL')
                   and    dist2.account_set_flag = 'N')
*/
and   not exists ( select 1
                   from   ra_cust_trx_line_gl_dist dist2
                   where  dist2.customer_trx_id = rec.customer_trx_id
                   and    dist2.account_class = 'ROUND'
                   and    dist2.account_set_flag = rec.account_set_flag);

    rows := SQL%ROWCOUNT;

   IF ( rows > 0 ) THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Rows were inserted into gl dist ');
        END IF;

         SELECT cust_trx_line_gl_dist_id
         BULK COLLECT INTO l_gl_dist_key_value_list
         FROM ra_cust_trx_line_gl_dist rec
         where  rec.customer_trx_id = p_customer_trx_id
         and  account_class = 'ROUND';


        /*-----------------------------------------------------+
         | call mrc engine to insert RA_CUST_TRX_LINES_GL_DIST |
         +-----------------------------------------------------*/
         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('before calling maintain_mrc ');
         END IF;

         ar_mrc_engine.maintain_mrc_data(
                    p_event_mode       => 'INSERT',
                    p_table_name       => 'RA_CUST_TRX_LINE_GL_DIST',
                    p_mode             => 'BATCH',
                    p_key_value_list   => l_gl_dist_key_value_list) ;

--BUG#2750340
        /*-----------------------------------------------------+
         | Need to call ARP_XLA for denormalizing the event_id |
         | on round distribution                               |
         +-----------------------------------------------------*/
          l_xla_ev_rec.xla_from_doc_id := p_customer_trx_id;
          l_xla_ev_rec.xla_to_doc_id := p_customer_trx_id;
          l_xla_ev_rec.xla_doc_table := 'CT';
          l_xla_ev_rec.xla_mode := 'O';
          l_xla_ev_rec.xla_call := 'D';
          arp_xla_events.create_events(l_xla_ev_rec);

    END IF;
IF PG_DEBUG in ('Y', 'C') THEN
   arp_standard.debug('after mrc if customer trx id is not null');
END IF;

end if;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(
          'Rows Processed: '||
           rows);
  END IF;

  p_rows_processed := p_rows_processed + rows;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.insert_round_record()- ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  return(iTRUE);
EXCEPTION
	WHEN others THEN
        p_error_message := 'arp_rounding - ' || SQLERRM;
        return(iFALSE);
end insert_round_records;

/* Bug 2736599 - this routine has been obsoleted due to problems with
   header level rounding in conjunction with SUSPENSE accounts */

FUNCTION get_line_round_acctd_amount( P_CUSTOMER_TRX_ID   IN NUMBER)

RETURN NUMBER IS

l_round_acctd_amount NUMBER;

begin

 /*****************************************************
 * Bug 13434104                                       *
 * Removed the call to gl_currency_api.convert_amount *
 ******************************************************/
     select nvl(rec.acctd_amount,0) -
            sum( decode(fc.minimum_accountable_unit,
                        null, round(l.extended_amount *
                              nvl(ct.exchange_rate,1),
                                          fc.precision),
                        round( (l.extended_amount *
                                nvl(ct.exchange_rate,1)
                                ) / fc.minimum_accountable_unit
                                ) * fc.minimum_accountable_unit
                        )
                  )
     into   l_round_acctd_amount
     from   ra_customer_trx ct,
            ra_customer_trx_lines l,
            ra_cust_trx_line_gl_dist rec,
            fnd_currencies fc,
            gl_sets_of_books gsb
     where  ct.customer_trx_id = l.customer_trx_id
     and    ct.customer_trx_id = rec.customer_trx_id
     and    ct.customer_trx_id = P_CUSTOMER_TRX_ID
     and    ct.set_of_books_id = gsb.set_of_books_id
     and    fc.currency_code   = gsb.currency_code
     and    rec.account_class = 'REC'
     and    rec.latest_rec_flag = 'Y'
     group by rec.acctd_amount;

     return l_round_acctd_amount;

exception
when no_data_found then
return 0;

end get_line_round_acctd_amount;

/*************************************************************************
 PRIVATE FUNCTION     get_dist_round_acctd_amount                        *
 This function is obsolete as we are keeping the release 10 constraint   *
 Sum of all distribtions acctd_amount should be equal to the line amount *
 converted to functional currency.                                       *
**************************************************************************/
FUNCTION get_dist_round_acctd_amount(P_CUSTOMER_TRX_ID IN NUMBER)
RETURN NUMBER IS

l_round_acctd_amount NUMBER;

begin
     select
              nvl(rec.acctd_amount,0) - sum(nvl(lgd.acctd_amount,0))
       into   l_round_acctd_amount
       from   ra_cust_trx_line_gl_dist lgd,
              ra_cust_trx_line_gl_dist rec
       where  lgd.customer_trx_id = rec.customer_trx_id
       and    rec.customer_trx_id = P_CUSTOMER_TRX_ID
       and    rec.account_class = 'REC'
       and    rec.latest_rec_flag = 'Y'
       and    lgd.account_set_flag = 'N'
       and    lgd.account_class not in ('REC', 'ROUND')
       group by rec.acctd_amount;

      return l_round_acctd_amount;

exception
when no_data_found then
return 0;

end get_dist_round_acctd_amount;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   correct_round_records()                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function calculates the rounding difference in the acctd_amount  |
 |   for a give transaction and update it's ROUND record with it.          |
 |                                                                         |
 |   The rounding difference is calculated as follows :                    |
 |                                                                         |
 |   round acctd_amount =                                                  |
 |         receivable acctd_amount -                                       |
 |         Sum( line amount converted to functional currency rounded for   |
 |              functional currency)                                       |
 |                                                                         |
 |   This function also update the following columns of the round record.  |
 |   amount = 0                                                            |
 |   code_combination_id = code_combination_id for ROUND account after     |
 |                         substituting the balancing segment with REC     |
 |                         account                                         |
 |   concatenated_segments = concatenated_segments returned by the         |
 |                           replace_balancing_segment function            |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   An ORACLE ERROR EXCEPTION if an ORACLE error occurs                   |
 |                                                                         |
 | NOTES                                                                   |
 |   *** PLEASE READ THE PACKAGE LEVEL NOTE BEFORE MODIFYING THIS FUNCTION.|
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION correct_round_records( P_REQUEST_ID IN NUMBER,
                                P_CUSTOMER_TRX_ID       IN NUMBER,
                                P_CUSTOMER_TRX_LINE_ID  IN NUMBER,
                                P_ROWS_PROCESSED    IN OUT NOCOPY NUMBER,
                                P_ERROR_MESSAGE        OUT NOCOPY VARCHAR2,
                                P_BASE_PRECISION        IN NUMBER,
                                P_BASE_MAU              IN NUMBER,
                                P_TRX_CLASS_TO_PROCESS  IN VARCHAR2,
                                concat_segs             IN VARCHAR2,
                                balanced_round_ccid     IN NUMBER)
 RETURN NUMBER IS

  /* Bug 2736599 - replaced get_line_round_acctd_amount with
       get_dist_round_acctd_amount to resolve issues with
       header level rounding and SUSPENSE accounts */

l_line_round_acctd_amount number := nvl(get_dist_round_acctd_amount(P_CUSTOMER_TRX_ID),0);

l_count number;

begin

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_round_record()+ ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   arp_standard.debug('P_CUSTOMER_TRX_ID: ' || P_CUSTOMER_TRX_ID);
END IF;


update ra_cust_trx_line_gl_dist dist
set   (amount, acctd_amount, code_combination_id, concatenated_segments) =
      (select 0,
              l_line_round_acctd_amount,
              nvl(balanced_round_ccid,-1),
              concatenated_segments
       from   ra_customer_trx ct
       where  ct.customer_trx_id = dist.customer_trx_id
       ),
last_updated_by = arp_global.last_updated_by,    /* Bug 2089972 */
last_update_date = sysdate
where  dist.customer_trx_id = P_CUSTOMER_TRX_ID
and    dist.account_class = 'ROUND'
and    dist.gl_posted_date is null
and    (
        nvl(dist.amount,0) <>  0  OR
        nvl(dist.acctd_amount, 0)<> l_line_round_acctd_amount OR
        dist.code_combination_id <> nvl(balanced_round_ccid,-1) OR
        dist.acctd_amount is null OR
        dist.amount is null
        );

  l_count := SQL%ROWCOUNT;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Rows Processed: '||
           l_count);
  END IF;

  p_rows_processed := p_rows_processed + l_count;

  /* MRC Processing */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('  doing rounding for MRC if necessary');
  END IF;
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_ROUND_RECORDS',
                   P_REQUEST_ID,
                   P_CUSTOMER_TRX_ID,
                   P_CUSTOMER_TRX_LINE_ID,
                   P_TRX_CLASS_TO_PROCESS,
                   concat_segs,
                   balanced_round_ccid
                  );

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_rounding.correct_round_record()- ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  return(iTRUE);

end correct_round_records;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   correct_receivables_header()                                          |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects rounding errors in the Receivable records.     |
 |   This is the only function that modifies account set records because   |
 |   only the Receivable account set record has an amount.                 |
 |   This function corrects errors 1 as specified in the high level        |
 |   design document (release 10).                                         |
 |   The REC acctd_amount is calculated as follows:                        |
 |   acctd_amount = REC amount converted to functional currency.           |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   An ORACLE ERROR EXCEPTION if an ORACLE error occurs                   |
 |                                                                         |
 | NOTES                                                                   |
 |   *** PLEASE READ THE PACKAGE LEVEL NOTE BEFORE MODIFYING THIS FUNCTION.|
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/
FUNCTION correct_receivables_header(  P_REQUEST_ID IN NUMBER,
                                      P_CUSTOMER_TRX_ID       IN NUMBER,
                                      P_CUSTOMER_TRX_LINE_ID  IN NUMBER,
                                      P_ROWS_PROCESSED    IN OUT NOCOPY NUMBER,
                                      P_ERROR_MESSAGE        OUT NOCOPY VARCHAR2,
                                      P_BASE_PRECISION        IN NUMBER,
                                      P_BASE_MAU              IN NUMBER,
                                      P_TRX_CLASS_TO_PROCESS  IN VARCHAR2)
                                   RETURN NUMBER IS
  l_count number;

begin

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_receivables_header()+ ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  if (p_request_id is not null)
  then

/******************************************************
 * Bug 13434104                                       *
 * Removed the call to gl_currency_api.convert_amount *
 ******************************************************/

update ra_cust_trx_line_gl_dist rec
set (amount, acctd_amount, percent) =
    ( select nvl(rec.amount, 0) +
             (sum(l.extended_amount) - nvl(rec.amount, 0) ),
             nvl(rec.acctd_amount, 0) +
             ( decode(p_base_mau,
                      null, round(sum(l.extended_amount) *
                              max(nvl(exchange_rate,1)),
                              p_base_precision),
                      round( (sum(l.extended_amount) *
                                max(nvl(exchange_rate,1))
                               ) / p_base_mau
                              ) * p_base_mau
                      )
              - nvl(rec.acctd_amount, 0)
             ),    /* acctd_amount */
            rec.percent + (100 - rec.percent) /* percent */
      from  ra_customer_trx t,
            ra_customer_trx_lines l
      where t.customer_trx_id = l.customer_trx_id
      and   t.customer_trx_id = rec.customer_trx_id
      group by l.customer_trx_id,
               t.trx_number,
               t.exchange_rate_type,
               t.invoice_currency_code,
               t.exchange_date,
               exchange_rate
 ),
last_updated_by = arp_global.last_updated_by,   /* Bug 2089972 */
last_update_date = sysdate
where customer_trx_id in
    ( select l.customer_trx_id
      from   ra_customer_trx_lines l,
             ra_customer_trx t,
             ra_cust_trx_line_gl_dist d
      where  t.customer_trx_id = l.customer_trx_id
      and    t.customer_trx_id = d.customer_trx_id
      and    d.account_class   = 'REC'
      and    d.latest_rec_flag = 'Y'
   /*-------------------------------------------
                 ---CUT HERE---                */
      and    d.request_id      = p_request_id
   /*                                          *
    *------------------------------------------*/
      and    nvl(t.previous_customer_trx_id, -1) =
                decode(p_trx_class_to_process,
                       'INV',        -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                                     nvl(t.previous_customer_trx_id, -1) )
      having (
               sum(l.extended_amount) <> nvl(d.amount, 0)  OR
               100 <> nvl(d.percent, 0) OR
                      decode(p_base_mau,
                             null, round(sum(l.extended_amount) *
                                  max(nvl(exchange_rate,1)),
                                  p_base_precision),
                              round( (sum(l.extended_amount) *
                                    max(nvl(exchange_rate,1))
                                   ) / p_base_mau
                                 ) * p_base_mau
                             )
                  <> nvl(d.acctd_amount, 0) OR
               d.acctd_amount is null OR
               d.amount is null
             )
      group by l.customer_trx_id,
               t.trx_number,
               d.amount,
               d.acctd_amount,
               d.percent,
               t.invoice_currency_code,
               t.exchange_date,
               t.exchange_rate_type,
               exchange_rate
 )
and rec.account_class = 'REC'
and rec.gl_posted_date is null;

  end if; /* request_id case */

  if (p_customer_trx_id is not null)
  then

/******************************************************
 * Bug 13434104                                       *
 * Removed the call to gl_currency_api.convert_amount *
 ******************************************************/

  /* 7039838 - If executed from autoinv, then added several hints
      and additional binds for performance */
     IF g_autoinv
     THEN
update ra_cust_trx_line_gl_dist rec
set (amount, acctd_amount, percent) =
    ( select /*+ index(L RA_CUSTOMER_TRX_LINES_N4) */
             nvl(rec.amount, 0) +
             (sum(l.extended_amount) - nvl(rec.amount, 0) ),
             nvl(rec.acctd_amount, 0) +
             ( decode(p_base_mau,
                     null, round(sum(l.extended_amount) *
                                 max(nvl(exchange_rate,1)),
                                 p_base_precision),
                           round( (sum(l.extended_amount) *
                                   max(nvl(exchange_rate,1))
                                  ) / p_base_mau
                                 ) * p_base_mau
                     )
              - nvl(rec.acctd_amount, 0)
             ),    /* acctd_amount */
            rec.percent + (100 - rec.percent) /* percent */
      from  ra_customer_trx t,
            ra_customer_trx_lines l
      where t.customer_trx_id = l.customer_trx_id
      and   l.customer_trx_id = rec.customer_trx_id
      and   l.request_id = g_autoinv_request_id -- 7039838
      group by l.customer_trx_id,
               t.trx_number,
               t.invoice_currency_code,
               t.exchange_date,
               t.exchange_rate_type,
               exchange_rate
 ),
last_updated_by = arp_global.last_updated_by,   /*Bug 2089972 */
last_update_date = sysdate
where customer_trx_id in
    ( select /*+ leading(T,D,L) use_hash(L)
                 index(L RA_CUSTOMER_TRX_LINES_N4) */
             l.customer_trx_id
      from   ra_customer_trx t,
             ra_customer_trx_lines l,
             ra_cust_trx_line_gl_dist d
      where  t.customer_trx_id = l.customer_trx_id
      and    l.customer_trx_id = d.customer_trx_id
      and    l.request_id = g_autoinv_request_id   -- 7039838
      and    l.customer_trx_id = p_customer_trx_id -- 7039838
      and    d.account_class   = 'REC'
      and    d.latest_rec_flag = 'Y'
   /*-------------------------------------------------
                    ---CUT HERE---                   */
      and    d.customer_trx_id = p_customer_trx_id
   /*
    *------------------------------------------------*/
      and    nvl(t.previous_customer_trx_id, -1) =
                decode(p_trx_class_to_process,
                       'INV',        -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                                     nvl(t.previous_customer_trx_id, -1) )
      having (
               sum(l.extended_amount) <> nvl(d.amount, 0)  OR
               100 <> nvl(d.percent, 0) OR
               decode(p_base_mau,
                      null, round(sum(l.extended_amount) *
                                  max(nvl(exchange_rate,1)),
                                  p_base_precision),
                            round( (sum(l.extended_amount) *
                                    max(nvl(exchange_rate,1))
                                   ) / p_base_mau
                                 ) * p_base_mau
                       )
                  <> nvl(d.acctd_amount, 0) OR
               d.acctd_amount is null OR
               d.amount is null
             )
      group by l.customer_trx_id,
               t.trx_number,
               d.amount,
               d.acctd_amount,
               d.percent,
               t.invoice_currency_code,
               t.exchange_date,
               t.exchange_rate_type,
               exchange_rate
 )
and rec.account_class = 'REC'
and rec.gl_posted_date is null;

     ELSE
     /* Not autoinvoice, probably Rev Rec or forms logic */
update ra_cust_trx_line_gl_dist rec
set (amount, acctd_amount, percent) =
    ( select nvl(rec.amount, 0) +
             (sum(l.extended_amount) - nvl(rec.amount, 0) ),
             nvl(rec.acctd_amount, 0) +
             ( decode(p_base_mau,
                     null, round(sum(l.extended_amount) *
                                 max(nvl(exchange_rate,1)),
                                 p_base_precision),
                           round( (sum(l.extended_amount) *
                                   max(nvl(exchange_rate,1))
                                  ) / p_base_mau
                                 ) * p_base_mau
                     )
              - nvl(rec.acctd_amount, 0)
             ),    /* acctd_amount */
            rec.percent + (100 - rec.percent) /* percent */
      from  ra_customer_trx t,
            ra_customer_trx_lines l
      where t.customer_trx_id = l.customer_trx_id
      and   l.customer_trx_id = rec.customer_trx_id
      group by l.customer_trx_id,
               t.trx_number,
               t.invoice_currency_code,
               t.exchange_date,
               t.exchange_rate_type,
               exchange_rate
 ),
last_updated_by = arp_global.last_updated_by,   /*Bug 2089972 */
last_update_date = sysdate
where customer_trx_id in
    ( select l.customer_trx_id
      from   ra_customer_trx t,
             ra_customer_trx_lines l,
             ra_cust_trx_line_gl_dist d
      where  t.customer_trx_id = l.customer_trx_id
      and    l.customer_trx_id = d.customer_trx_id
      and    d.account_class   = 'REC'
      and    d.latest_rec_flag = 'Y'
   /*-------------------------------------------------
                    ---CUT HERE---                   */
      and    d.customer_trx_id = p_customer_trx_id
   /*
    *------------------------------------------------*/
      and    nvl(t.previous_customer_trx_id, -1) =
                decode(p_trx_class_to_process,
                       'INV',        -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                                     nvl(t.previous_customer_trx_id, -1) )
      having (
               sum(l.extended_amount) <> nvl(d.amount, 0)  OR
               100 <> nvl(d.percent, 0) OR
               decode(p_base_mau,
                      null, round(sum(l.extended_amount) *
                                  max(nvl(exchange_rate,1)),
                                  p_base_precision),
                            round( (sum(l.extended_amount) *
                                    max(nvl(exchange_rate,1))
                                   ) / p_base_mau
                                 ) * p_base_mau
                       )
                  <> nvl(d.acctd_amount, 0) OR
               d.acctd_amount is null OR
               d.amount is null
             )
      group by l.customer_trx_id,
               t.trx_number,
               d.amount,
               d.acctd_amount,
               d.percent,
               t.invoice_currency_code,
               t.exchange_date,
               t.exchange_rate_type,
               exchange_rate
 )
and rec.account_class = 'REC'
and rec.gl_posted_date is null;

     END IF; /* g_autoinv case */
  end if; /* customer_trx_id case */

  l_count := SQL%ROWCOUNT;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Rows Processed: '||
           l_count);
  END IF;

  p_rows_processed := p_rows_processed + l_count;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_rounding.correct_receivables_header()- ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  /* MRC Processing */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('  doing rounding for MRC if necessary');
  END IF;
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_RECEIVABLES_HEADER',
                   P_REQUEST_ID,
                   P_CUSTOMER_TRX_ID,
                   P_CUSTOMER_TRX_LINE_ID,
                   P_TRX_CLASS_TO_PROCESS
                  );

  return(iTRUE);

end correct_receivables_header;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   correct_receivables_records()                                         |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects rounding errors in the Receivable records.     |
 |   This is the only function that modifies account set records because   |
 |   only the Receivable account set record has an amount.                 |
 |   This function corrects errors 1 and 2 as specified in the high level  |
 |   design document.                                                      |
 |                                                                         |
 | REQUIRES                                                                |
 |   All IN parameters                                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   An ORACLE ERROR EXCEPTION if an ORACLE error occurs                   |
 |                                                                         |
 | NOTES                                                                   |
 |   *** PLEASE READ THE PACKAGE LEVEL NOTE BEFORE MODIFYING THIS FUNCTION.|
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 | Nilesh Acharya   24-July-98    Changes for triangulation                |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION correct_receivables_records(
		P_REQUEST_ID            IN NUMBER,
                P_CUSTOMER_TRX_ID       IN NUMBER,
                P_CUSTOMER_TRX_LINE_ID  IN NUMBER,
                P_ROWS_PROCESSED        IN OUT NOCOPY NUMBER,
                P_ERROR_MESSAGE         OUT NOCOPY VARCHAR2,
                P_BASE_PRECISION        IN NUMBER,
                P_BASE_MAU              IN NUMBER,
                P_TRX_CLASS_TO_PROCESS  IN VARCHAR2)

         RETURN NUMBER IS
  l_count number;
BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_receivables_record()+ ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  IF (p_request_id IS NOT NULL)
  THEN

/******************************************************
 * Bug 13434104                                       *
 * Removed the call to gl_currency_api.convert_amount *
 ******************************************************/

UPDATE ra_cust_trx_line_gl_dist rec
SET (amount, acctd_amount, percent) =
    ( SELECT
             NVL(rec.amount, 0) +
             (SUM(l.extended_amount) - NVL(rec.amount, 0) ),
             NVL(rec.acctd_amount, 0) +
             (
              sum( decode(p_base_mau,
                          null, round(l.extended_amount *
                                 nvl(exchange_rate,1),
                                 p_base_precision),
                           round( (l.extended_amount *
                                   nvl(exchange_rate,1)
                                   ) / p_base_mau
                                 ) * p_base_mau
                           )
                  )
                 - NVL(rec.acctd_amount, 0)
             ),    /* acctd_amount */
            rec.percent + (100 - rec.percent) /* percent */
      FROM
            ra_customer_trx_lines l,
            ra_customer_trx t
      WHERE
            t.customer_trx_id = rec.customer_trx_id
      AND   l.customer_trx_id = t.customer_trx_id
      GROUP BY
            l.customer_trx_id,
            t.trx_number
    ),
last_updated_by = arp_global.last_updated_by,       /* Bug 2089972 */
last_update_date = sysdate
WHERE customer_trx_id IN
    ( SELECT
             l.customer_trx_id
      FROM
             ra_customer_trx_lines l,
             ra_customer_trx t,
             ra_cust_trx_line_gl_dist d
      WHERE
             t.customer_trx_id = d.customer_trx_id
      AND    l.customer_trx_id = t.customer_trx_id
      AND    d.account_class   = 'REC'
      AND    d.latest_rec_flag = 'Y'
   /*-------------------------------------------
                 ---CUT HERE---                */
      AND    d.request_id      = p_request_id
   /*                                          *
    *------------------------------------------*/
      AND    NVL(t.previous_customer_trx_id, -1) =
                DECODE(p_trx_class_to_process,
                       'INV',        -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                                     nvl(t.previous_customer_trx_id, -1) )
      having (
               sum(l.extended_amount) <> nvl(d.amount, 0)  OR
               100 <> nvl(d.percent, 0) OR
              sum(
                                decode(p_base_mau,
                                       null, round(l.extended_amount *
                                             nvl(exchange_rate,1),
                                             p_base_precision),
                                       round( (l.extended_amount *
                                               nvl(exchange_rate,1)
                                               ) / p_base_mau
                                             ) * p_base_mau
                                       )
                   )
                  <> nvl(d.acctd_amount, 0) OR
               d.acctd_amount is null OR
               d.amount is null
             )
      GROUP BY
               l.customer_trx_id,
               t.trx_number,
               d.amount,
               d.acctd_amount,
               d.percent
    )
AND rec.account_class  = 'REC'
AND rec.gl_posted_date IS NULL;

  END IF; /* request_id case */

  IF (p_customer_trx_id IS NOT NULL)
  THEN

UPDATE ra_cust_trx_line_gl_dist rec
SET (amount, acctd_amount, percent) =
    ( SELECT
             NVL(rec.amount, 0) +
             (SUM(l.extended_amount) - NVL(rec.amount, 0) ),
             NVL(rec.acctd_amount, 0) +
             (
              sum(
                                decode(p_base_mau,
                                       null, round(l.extended_amount *
                                             nvl(exchange_rate,1),
                                             p_base_precision),
                                       round( (l.extended_amount *
                                               nvl(exchange_rate,1)
                                               ) / p_base_mau
                                             ) * p_base_mau
                                       )
                   )
                 - NVL(rec.acctd_amount, 0)
             ),
            rec.percent + (100 - rec.percent) /* percent */
      FROM
            ra_customer_trx_lines l,
            ra_customer_trx t
      WHERE
            t.customer_trx_id = rec.customer_trx_id
      AND   l.customer_trx_id = t.customer_trx_id
      GROUP BY
            l.customer_trx_id,
            t.trx_number
    ),
last_updated_by = arp_global.last_updated_by,                /* Bug 2089972 */
last_update_date = sysdate
WHERE customer_trx_id IN
    ( SELECT
             l.customer_trx_id
      FROM
             ra_customer_trx t,
             ra_customer_trx_lines l,
             ra_cust_trx_line_gl_dist d
      WHERE
             t.customer_trx_id = d.customer_trx_id
      AND    l.customer_trx_id = t.customer_trx_id
      AND    d.account_class   = 'REC'
      AND    d.latest_rec_flag = 'Y'
   /*-------------------------------------------------
                    ---CUT HERE---                   */
      AND    d.customer_trx_id = p_customer_trx_id
   /*
    *------------------------------------------------*/
      AND    NVL(t.previous_customer_trx_id, -1) =
                DECODE(p_trx_class_to_process,
                       'INV', -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                                     nvl(t.previous_customer_trx_id, -1) )
      having (
               sum(l.extended_amount) <> nvl(d.amount, 0)  OR
               100 <> nvl(d.percent, 0) OR
              sum(
                                decode(p_base_mau,
                                       null, round(l.extended_amount *
                                             nvl(exchange_rate,1),
                                             p_base_precision),
                                       round( (l.extended_amount *
                                               nvl(exchange_rate,1)
                                               ) / p_base_mau
                                             ) * p_base_mau
                                       )
                   )
                  <> nvl(d.acctd_amount, 0) OR
               d.acctd_amount is null OR
               d.amount is null
             )
      GROUP BY
               l.customer_trx_id,
               t.trx_number,
               d.amount,
               d.acctd_amount,
               d.percent
    )
AND rec.account_class  = 'REC'
AND rec.gl_posted_date IS NULL;

  END IF; /* customer_trx_id case */


  l_count := sql%rowcount;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug(
          'Rows Processed: '||
           l_count);
  END IF;

  p_rows_processed := p_rows_processed + l_count;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_receivables_record()- ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  /* MRC Processing */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('doing rounding for MRC if necessary');
  END IF;
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_RECEIVABLES_RECORDS',
                   P_REQUEST_ID,
                   P_CUSTOMER_TRX_ID,
                   P_CUSTOMER_TRX_LINE_ID,
                   P_TRX_CLASS_TO_PROCESS
                  );

  RETURN( iTRUE );
EXCEPTION
  WHEN others THEN
    p_error_message := SQLERRM;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION:  arp_rounding.correct_receivables_record()- '||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
    END IF;
    RETURN(iFALSE);

END correct_receivables_records;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   correct_nonrule_line_records()                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects errors in the tax, freight, charges and        |
 |   AutoInvoice Clearing lines as well as in LINE lines that do not       |
 |   use rules.                                                            |
 |   This function corrects errors 3 - 8 as specified in the high level    |
 |   design document.                                                      |
 |                                                                         |
 | REQUIRES                                                                |
 |   All IN parameters                                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   An ORACLE ERROR EXCEPTION if an ORACLE error occurs                   |
 |                                                                         |
 | NOTES                                                                   |
 |   *** PLEASE READ THE PACKAGE LEVEL NOTE BEFORE MODIFYING THIS FUNCTION.|
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 |    15-NOV-98      Manoj Gudivaka   Fix for Bug 718096)                  |
 |    29-JUL-02      M Raymond        Added hints for bug 2398437
 |    07-OCT-02      M Raymond        Restructured nonrule sql to
 |                                    resolve performance problem from
 |                                    bug 2539296.
 |    14-MAY-08      M Raymond       7039838 Performance tuning
 +-------------------------------------------------------------------------*/
 /*------------------------------------------------------------------------+
 | Modification for bug 718096                                             |
 |                                                                         |
 | Removed "account class" from the group by clause so that the rounding is|
 | done on the whole transaction amount rather than indiviually for the    |
 | Revenue amount and the Suspense Amount.                                 |
 |                                                                         |
 | The following Decode statement has been removed and replaced with       |
 | just the "extended amount"                                              |
 |                                                                         |
 |     DECODE(lgd2.account_class,                                          |
 |                         'REV', ctl.revenue_amount,                      |
 |                    'SUSPENSE', ctl.extended_amount - ctl.revenue_amount,|
 |                                ctl.extended_amount)                     |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION correct_nonrule_line_records(
		P_REQUEST_ID            IN NUMBER,
                P_CUSTOMER_TRX_ID       IN NUMBER,
                P_CUSTOMER_TRX_LINE_ID  IN NUMBER,
                P_ROWS_PROCESSED        IN OUT NOCOPY NUMBER,
                P_ERROR_MESSAGE         OUT NOCOPY VARCHAR2,
                P_BASE_PRECISION        IN NUMBER,
                P_BASE_MAU              IN NUMBER,
                P_TRX_CLASS_TO_PROCESS  IN VARCHAR2)

         RETURN NUMBER IS
  l_count number;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_nonrule_line_records()+ ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  IF (p_request_id IS NOT NULL)
  THEN

  /* Bug 2539296 - The sql below was slightly restructured for better
     performance in large databases.  I basically restructured the join
     order around ra_customer_trx instead of the gl_dist tables.
  */

UPDATE ra_cust_trx_line_gl_dist lgd
SET    (amount, acctd_amount)  =
       (SELECT /*+ index(rec1 RA_CUST_TRX_LINE_GL_DIST_N6) ordered */ NVL(lgd.amount, 0) -
                            (
                             SUM(lgd2.amount) -
                              (
                                 DECODE(lgd.gl_date,
                                        rec1.gl_date, 1,
                                        0) *
                                        ctl.extended_amount
                              )
                            ),  /* entered amount */
               NVL(lgd.acctd_amount, 0) -
                 (
                   SUM(lgd2.acctd_amount) -
                   (
                     DECODE(lgd.gl_date,
                            rec1.gl_date, 1,
                            0) *
                     DECODE(p_base_mau,
                                  NULL, ROUND( ctl.extended_amount *
                                               NVL(ct.exchange_rate,1),
                                               p_base_precision),
                                        ROUND( ( ctl.extended_amount *
                                                 NVL(ct.exchange_rate,1)
                                               ) / p_base_mau ) * p_base_mau
                           )
                   )
                 )              /* accounted amount */
                 FROM
                          ra_customer_trx_lines ctl,
                          ra_customer_trx ct,
                          ra_cust_trx_line_gl_dist lgd2,
                          ra_cust_trx_line_gl_dist rec1
                 WHERE
                          ctl.customer_trx_line_id = lgd2.customer_trx_line_id
                 AND      ctl.customer_trx_id      = ct.customer_trx_id
                 AND      lgd.customer_trx_line_id = ctl.customer_trx_line_id
-- 718096          AND      lgd.account_class        = lgd2.account_class
                 AND      lgd2.account_set_flag    = 'N'
                 AND      rec1.customer_trx_id     = ct.customer_trx_id
                 AND      rec1.account_class       = 'REC'
                 AND      rec1.latest_rec_flag     = 'Y'
                 AND      NVL(lgd.gl_date, to_date( 2415021, 'J') )  =
                          NVL(lgd2.gl_date, to_date( 2415021, 'J') )
                 GROUP BY
                          ctl.customer_trx_line_id,
-- 718096                   lgd2.account_class,
                          rec1.gl_date,
                          ctl.extended_amount,
                          ctl.revenue_amount,
                          ct.exchange_rate
       ),
       percent =
       (SELECT /*+ index(rec2 RA_CUST_TRX_LINE_GL_DIST_N6) */  DECODE(lgd.account_class || lgd.account_set_flag,
                         'SUSPENSEN', lgd.percent,
                         'UNBILLN', lgd.percent,
                         'UNEARNN', lgd.percent,
                         NVL(lgd.percent, 0) -
                               (
                                 SUM(NVL(lgd4.percent, 0))
                                     - DECODE(rec2.gl_date,
                                              NVL(lgd.gl_date,
                                                  rec2.gl_date), 100,
                                              0)
                               )
                        )  /* percent */
        FROM
                  ra_cust_trx_line_gl_dist lgd4,
                  ra_cust_trx_line_gl_dist rec2
        WHERE
                  lgd.customer_trx_line_id = lgd4.customer_trx_line_id
        AND       rec2.customer_trx_id     = lgd.customer_trx_id
	AND       rec2.customer_trx_id     = lgd4.customer_trx_id
        AND       rec2.account_class       = 'REC'
        AND       rec2.latest_rec_flag     = 'Y'
        AND       lgd4.account_set_flag    = lgd.account_set_flag
        AND       DECODE(lgd4.account_set_flag,
                         'Y', lgd4.account_class,
                         lgd.account_class) = lgd.account_class
        AND       NVL(lgd.gl_date, to_date( 2415021, 'J') )  =
                  NVL(lgd4.gl_date, to_date( 2415021, 'J') )
        GROUP BY
                  rec2.gl_date,
                  lgd.gl_date
       ),
last_updated_by = arp_global.last_updated_by,   /* Bug 2089972 */
last_update_date = sysdate
 WHERE cust_trx_line_gl_dist_id  IN
       (SELECT /*+ index(rec3 RA_CUST_TRX_LINE_GL_DIST_N6) */
               MIN(DECODE(lgd3.gl_posted_date,
                          NULL, lgd3.cust_trx_line_gl_dist_id,
                          NULL) )
        FROM
               ra_customer_trx_lines ctl,
               ra_customer_trx t,
               ra_cust_trx_line_gl_dist lgd3,
               ra_cust_trx_line_gl_dist rec3
        WHERE
               t.request_id         = p_request_id
        AND    T.CUSTOMER_TRX_ID    = CTL.CUSTOMER_TRX_ID
        AND   (CTL.LINE_TYPE IN ( 'TAX','FREIGHT','CHARGES','SUSPENSE'  ) OR
              (CTL.LINE_TYPE = 'LINE'  AND CTL.ACCOUNTING_RULE_ID IS NULL ))
        AND    LGD3.CUSTOMER_TRX_LINE_ID = CTL.CUSTOMER_TRX_LINE_ID
        AND    LGD3.ACCOUNT_SET_FLAG = 'N'
        AND    REC3.CUSTOMER_TRX_ID = T.CUSTOMER_TRX_ID
        AND    REC3.ACCOUNT_CLASS = 'REC'
        AND    REC3.LATEST_REC_FLAG = 'Y'
        AND    NVL(t.previous_customer_trx_id, -1) =
                DECODE(p_trx_class_to_process,
                       'INV', -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                       NVL(t.previous_customer_trx_id, -1) )
        GROUP BY
                 ctl.customer_trx_line_id,
--  718096         lgd3.account_class,
                 lgd3.gl_date,
                 rec3.gl_date,
                 ctl.extended_amount,
                 ctl.revenue_amount,
                 t.exchange_rate
        HAVING (
                  SUM(NVL(lgd3.amount, 0))
                                  <> ctl.extended_amount *
                                     DECODE(lgd3.gl_date,
                                            rec3.gl_date, 1,
                                            0)
                OR
                  SUM(NVL(lgd3.acctd_amount, 0)) <>
                  DECODE(lgd3.gl_date,
                         rec3.gl_date, 1,
                         0) *
                  DECODE(p_base_mau,
                         NULL, ROUND( ctl.extended_amount *
                                      NVL(t.exchange_rate,1),
                                      p_base_precision ),
                               ROUND( ( ctl.extended_amount *
                                       NVL(t.exchange_rate,1)
                                      ) / p_base_mau ) * p_base_mau
                        )
               )
       UNION
       SELECT /*+ index(rec5 RA_CUST_TRX_LINE_GL_DIST_N6) INDEX (lgd5 ra_cust_trx_line_gl_dist_n7) */
             TO_NUMBER(
                         MIN(DECODE(lgd5.gl_posted_date||lgd5.account_class||
                                    lgd5.account_set_flag,
                                     'REVN',     lgd5.cust_trx_line_gl_dist_id,
                                     'REVY',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXN',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXY',     lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTN', lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTY', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESN', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESY', lgd5.cust_trx_line_gl_dist_id,
                                     'UNEARNY',  lgd5.cust_trx_line_gl_dist_id,
                                     'UNBILLY',  lgd5.cust_trx_line_gl_dist_id,
                                     NULL ) )
                      )
       FROM
              ra_cust_trx_line_gl_dist lgd5,
              ra_cust_trx_line_gl_dist rec5,
              ra_customer_trx_lines ctl2,
              ra_customer_trx t
       WHERE
              T.REQUEST_ID = p_request_id
       AND    T.CUSTOMER_TRX_ID = REC5.CUSTOMER_TRX_ID
       AND    CTL2.CUSTOMER_TRX_LINE_ID = LGD5.CUSTOMER_TRX_LINE_ID
       AND    REC5.CUSTOMER_TRX_ID = LGD5.CUSTOMER_TRX_ID
       AND    REC5.ACCOUNT_CLASS = 'REC'
       AND    REC5.LATEST_REC_FLAG = 'Y'
       AND   (CTL2.LINE_TYPE IN ( 'TAX','FREIGHT','CHARGES','SUSPENSE')
                OR
             (CTL2.LINE_TYPE = 'LINE'  AND
             (CTL2.ACCOUNTING_RULE_ID IS NULL  OR LGD5.ACCOUNT_SET_FLAG = 'Y' )))
       GROUP BY
                lgd5.customer_trx_line_id,
                lgd5.gl_date,
                rec5.gl_date,
                lgd5.account_set_flag,
                DECODE(lgd5.account_set_flag,
                       'N', NULL,
                       lgd5.account_class)
       HAVING
              SUM(NVL(lgd5.percent, 0)) <>
                 DECODE( NVL(lgd5.gl_date, rec5.gl_date),
                         rec5.gl_date, 100,
                         0)
     );

   END IF;  /* request_id case */

   IF (p_customer_trx_id IS NOT NULL AND p_customer_trx_line_id IS NULL)
   THEN

      IF g_autoinv
      THEN
         /* version tuned for autoinvoice with request_id joins */
UPDATE ra_cust_trx_line_gl_dist lgd
SET    (amount, acctd_amount)  =
       (SELECT /*+ index(LGD2 RA_CUST_TRX_LINE_GL_DIST_N10) */
                   NVL(lgd.amount, 0) -
                            (
                             SUM(lgd2.amount) -
                             (
                                 DECODE(lgd.gl_date,
                                        rec1.gl_date, 1,
                                        0) *
                                 DECODE(DECODE(lgd2.account_class,
                                               'UNEARN','REV',
                                               lgd2.account_class),
                                        'REV',       ctl.revenue_amount,
                                        'SUSPENSE',  ctl.extended_amount -
                                                     ctl.revenue_amount,
                                        ctl.extended_amount)
                             )
                            ),  /* entered amount */
               NVL(lgd.acctd_amount, 0) -
                 (
                   SUM(lgd2.acctd_amount) -
                   (
                     DECODE(lgd.gl_date,
                            rec1.gl_date, 1,
                            0) *
                     DECODE(p_base_mau,
                         NULL, ROUND(DECODE(DECODE(lgd2.account_class,
                                                   'UNEARN','REV',
                                                   lgd2.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                     NVL(ct.exchange_rate,1),
                                     p_base_precision ),
                               ROUND( (DECODE(DECODE(lgd2.account_class,
                                                     'UNEARN','REV',
                                                     lgd2.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                       NVL(ct.exchange_rate,1)
                                      ) / p_base_mau
                                    ) * p_base_mau
                        )
                   )
                 )              /* accounted amount */
                 FROM
                          ra_cust_trx_line_gl_dist lgd2,
                          ra_customer_trx_lines ctl,
                          ra_customer_trx ct,
                          ra_cust_trx_line_gl_dist rec1
                 WHERE
                          rec1.customer_trx_id      = lgd.customer_trx_id
                 AND      rec1.account_class        = 'REC'
                 AND      rec1.latest_rec_flag      = 'Y'
                 AND      ct.customer_trx_id        = rec1.customer_trx_id
                 AND      ctl.customer_trx_id       = ct.customer_trx_id
                 AND      ctl.customer_trx_line_id  = lgd.customer_trx_line_id
                 AND      lgd2.customer_trx_line_id = lgd.customer_trx_line_id
                 AND      lgd2.account_class        = lgd.account_class
                 AND      lgd2.account_set_flag     = 'N'
                 AND      lgd2.request_id = g_autoinv_request_id
                 AND      NVL(lgd2.gl_date, to_date( 2415021, 'J') )  =
                             NVL(lgd.gl_date, to_date( 2415021, 'J') )
                 GROUP BY
                          ctl.customer_trx_line_id,
                          DECODE(lgd2.account_class,'UNEARN','REV',
                                 lgd2.account_class),
                          rec1.gl_date,
                          ctl.extended_amount,
                          ctl.revenue_amount,
                          ct.exchange_rate
       ),
       percent =
       (SELECT /*+ index(LGD4 RA_CUST_TRX_LINE_GL_DIST_N10) */
                  DECODE(lgd.account_class || lgd.account_set_flag,
                         'SUSPENSEN', lgd.percent,
                         'UNBILLN', lgd.percent,
                         'UNEARNN', lgd.percent,
                         NVL(lgd.percent, 0) -
                               (
                                 SUM(NVL(lgd4.percent, 0))
                                 - DECODE(rec2.gl_date,
                                          NVL(lgd.gl_date, rec2.gl_date),
                                          100, 0)
                               )
                        )  /* percent */
        FROM
                  ra_cust_trx_line_gl_dist lgd4,
                  ra_cust_trx_line_gl_dist rec2
        WHERE
                  rec2.customer_trx_id      = lgd.customer_trx_id
        AND       rec2.account_class        = 'REC'
        AND       rec2.latest_rec_flag      = 'Y'
        AND       lgd4.customer_trx_line_id = lgd.customer_trx_line_id
        AND       lgd4.account_set_flag     = lgd.account_set_flag
        AND       DECODE(lgd4.account_set_flag,
                         'Y', lgd4.account_class,
                         lgd.account_class) = lgd.account_class
        AND       NVL(lgd4.gl_date, to_date( 2415021, 'J') )  =
                     NVL(lgd.gl_date, to_date( 2415021, 'J') )
        AND       lgd4.request_id = g_autoinv_request_id
        GROUP BY
                  rec2.gl_date,
                  lgd.gl_date
       ),
last_updated_by = arp_global.last_updated_by,       /* Bug 2089972 */
last_update_date = sysdate
WHERE cust_trx_line_gl_dist_id  IN
       (SELECT /*+ leading(T,LGD3,REC3,CTL)
	           use_hash(CTL) index(CTL RA_CUSTOMER_TRX_LINES_N4)
	           index(LGD3 RA_CUST_TRX_LINE_GL_DIST_N6)
	           index(REC3 RA_CUST_TRX_LINE_GL_DIST_N6) */
               MIN(DECODE(lgd3.gl_posted_date,
                          NULL, lgd3.cust_trx_line_gl_dist_id,
                          NULL) )
        FROM
               ra_customer_trx_lines ctl,
               ra_cust_trx_line_gl_dist lgd3,
               ra_cust_trx_line_gl_dist rec3,
               ra_customer_trx t
        WHERE
               t.customer_trx_id        = p_customer_trx_id
        AND    rec3.customer_trx_id     = t.customer_trx_id
        AND    rec3.account_class       = 'REC'
        AND    rec3.latest_rec_flag     = 'Y'
        AND    lgd3.customer_trx_id     = t.customer_trx_id
        AND    lgd3.account_set_flag    = 'N'
        AND    ctl.customer_trx_line_id = lgd3.customer_trx_line_id
        AND    (
                  ctl.line_type IN ('TAX', 'FREIGHT', 'CHARGES', 'SUSPENSE')
                OR
                  (ctl.line_type = 'LINE' AND ctl.accounting_rule_id IS NULL)
               )
        AND    ctl.request_id = g_autoinv_request_id
        AND    ctl.customer_trx_id = p_customer_trx_id
        AND    NVL(t.previous_customer_trx_id, -1) =
                DECODE(p_trx_class_to_process,
                       'INV', -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                       NVL(t.previous_customer_trx_id, -1) )
        GROUP BY
                 ctl.customer_trx_line_id,
                 DECODE(lgd3.account_class,'UNEARN','REV',lgd3.account_class),
                 lgd3.gl_date,
                 rec3.gl_date,
                 ctl.extended_amount,
                 ctl.revenue_amount,
                 t.exchange_rate
        HAVING (
                  SUM(NVL(lgd3.amount, 0))
                            <> DECODE(DECODE(lgd3.account_class,
                                             'UNEARN','REV',lgd3.account_class),
                                     'REV',       ctl.revenue_amount,
                                     'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                      ctl.extended_amount) *
                               DECODE(lgd3.gl_date,
                                      rec3.gl_date, 1,
                                      0)
                OR
                  SUM(NVL(lgd3.acctd_amount, 0)) <>
                  DECODE(lgd3.gl_date,
                         rec3.gl_date, 1,
                         0) *
                  DECODE(p_base_mau,
                         NULL, ROUND(DECODE(DECODE(lgd3.account_class,
                                                   'UNEARN','REV',
                                                   lgd3.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                     NVL(t.exchange_rate,1),
                                     p_base_precision),
                         ROUND( (DECODE(DECODE(lgd3.account_class,
                                               'UNEARN','REV',
                                               lgd3.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                       NVL(t.exchange_rate,1)
                                ) / p_base_mau
                              ) * p_base_mau
                        )
               )
       UNION
       SELECT  /*+ leading(CTL2 LGD5,REC5)
	           use_hash(LGD5) index(CTL2 RA_CUSTOMER_TRX_LINES_N4)
		   index(REC5 RA_CUST_TRX_LINE_GL_DIST_N6)
		   index(LGD5 RA_CUST_TRX_LINE_GL_DIST_N6) */
               TO_NUMBER(
                         MIN(DECODE(lgd5.gl_posted_date||lgd5.account_class||
                                    lgd5.account_set_flag,
                                     'REVN',     lgd5.cust_trx_line_gl_dist_id,
                                     'REVY',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXN',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXY',     lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTN', lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTY', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESN', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESY', lgd5.cust_trx_line_gl_dist_id,
                                     'UNEARNY',  lgd5.cust_trx_line_gl_dist_id,
                                     'UNBILLY',  lgd5.cust_trx_line_gl_dist_id,
                                     NULL
                                   )
                            )
                       )
       FROM
              ra_cust_trx_line_gl_dist rec5,
              ra_cust_trx_line_gl_dist lgd5,
              ra_customer_trx_lines ctl2
       WHERE
              ctl2.customer_trx_id      = p_customer_trx_id
       AND    ctl2.request_id           = g_autoinv_request_id
       AND    rec5.customer_trx_id      = lgd5.customer_trx_id
       AND    rec5.account_class        = 'REC'
       AND    rec5.latest_rec_flag      = 'Y'
       AND    lgd5.customer_trx_line_id = ctl2.customer_trx_line_id
       AND    lgd5.customer_trx_id      = p_customer_trx_id
       AND    (
                ctl2.line_type IN ('TAX', 'FREIGHT', 'CHARGES', 'SUSPENSE')
                OR
                (ctl2.line_type = 'LINE'   AND
                 (ctl2.accounting_rule_id  IS NULL OR
                     lgd5.account_set_flag = 'Y')
                )
              )
       GROUP BY
                lgd5.customer_trx_line_id,
                lgd5.gl_date,
                rec5.gl_date,
                lgd5.account_set_flag,
                DECODE(lgd5.account_set_flag,
                       'N', NULL,
                       lgd5.account_class)
       HAVING SUM(NVL(lgd5.percent, 0)) <>
              DECODE( NVL(lgd5.gl_date, rec5.gl_date),
                      rec5.gl_date, 100,
                      0)
       );

      ELSE
         /* original version (used by forms and Rev Rec */

         /* 9160123 - simplied where clause for this statement */

UPDATE ra_cust_trx_line_gl_dist lgd
SET    (amount, acctd_amount)  =
       (SELECT NVL(lgd.amount, 0) -
                            (
                             SUM(lgd2.amount) -
                             (
                                 DECODE(lgd.gl_date,
                                        rec1.gl_date, 1,
                                        0) *
                                 DECODE(DECODE(lgd2.account_class,
                                               'UNEARN','REV',
                                               lgd2.account_class),
                                        'REV',       ctl.revenue_amount,
                                        'SUSPENSE',  ctl.extended_amount -
                                                     ctl.revenue_amount,
                                        ctl.extended_amount)
                             )
                            ),  /* entered amount */
               NVL(lgd.acctd_amount, 0) -
                 (
                   SUM(lgd2.acctd_amount) -
                   (
                     DECODE(lgd.gl_date,
                            rec1.gl_date, 1,
                            0) *
                     DECODE(p_base_mau,
                         NULL, ROUND(DECODE(DECODE(lgd2.account_class,
                                                   'UNEARN','REV',
                                                   lgd2.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                     NVL(ct.exchange_rate,1),
                                     p_base_precision ),
                               ROUND( (DECODE(DECODE(lgd2.account_class,
                                                     'UNEARN','REV',
                                                     lgd2.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                       NVL(ct.exchange_rate,1)
                                      ) / p_base_mau
                                    ) * p_base_mau
                        )
                   )
                 )              /* accounted amount */
                 FROM
                          ra_cust_trx_line_gl_dist lgd2,
                          ra_customer_trx_lines ctl,
                          ra_customer_trx ct,
                          ra_cust_trx_line_gl_dist rec1
                 WHERE
                          rec1.customer_trx_id      = lgd.customer_trx_id
                 AND      rec1.account_class        = 'REC'
                 AND      rec1.latest_rec_flag      = 'Y'
                 AND      ct.customer_trx_id        = rec1.customer_trx_id
                 AND      ctl.customer_trx_id       = ct.customer_trx_id
                 AND      ctl.customer_trx_line_id  = lgd.customer_trx_line_id
                 AND      lgd2.customer_trx_line_id = lgd.customer_trx_line_id
                 AND      lgd2.account_class        = lgd.account_class
                 AND      lgd2.account_set_flag     = 'N'
                 AND      NVL(lgd2.gl_date, to_date( 2415021, 'J') )  =
                             NVL(lgd.gl_date, to_date( 2415021, 'J') )
                 GROUP BY
                          ctl.customer_trx_line_id,
                          DECODE(lgd2.account_class,'UNEARN','REV',
                                 lgd2.account_class),
                          rec1.gl_date,
                          ctl.extended_amount,
                          ctl.revenue_amount,
                          ct.exchange_rate
       ),
       percent =
       (SELECT    DECODE(lgd.account_class || lgd.account_set_flag,
                         'SUSPENSEN', lgd.percent,
                         'UNBILLN', lgd.percent,
                         'UNEARNN', lgd.percent,
                         NVL(lgd.percent, 0) -
                               (
                                 SUM(NVL(lgd4.percent, 0))
                                 - DECODE(rec2.gl_date,
                                          NVL(lgd.gl_date, rec2.gl_date),
                                          100, 0)
                               )
                        )  /* percent */
        FROM
                  ra_cust_trx_line_gl_dist lgd4,
                  ra_cust_trx_line_gl_dist rec2
        WHERE
                  rec2.customer_trx_id      = lgd.customer_trx_id
        AND       rec2.account_class        = 'REC'
        AND       rec2.latest_rec_flag      = 'Y'
        AND       lgd4.customer_trx_line_id = lgd.customer_trx_line_id
        AND       lgd4.account_set_flag     = lgd.account_set_flag
        AND       DECODE(lgd4.account_set_flag,
                         'Y', lgd4.account_class,
                         lgd.account_class) = lgd.account_class
        AND       NVL(lgd4.gl_date, to_date( 2415021, 'J') )  =
                     NVL(lgd.gl_date, to_date( 2415021, 'J') )
        GROUP BY
                  rec2.gl_date,
                  lgd.gl_date
       ),
last_updated_by = arp_global.last_updated_by,       /* Bug 2089972 */
last_update_date = sysdate
WHERE cust_trx_line_gl_dist_id  IN
       (SELECT MIN(DECODE(lgd3.gl_posted_date,
                          NULL, lgd3.cust_trx_line_gl_dist_id,
                          NULL) )
        FROM
               ra_customer_trx_lines ctl,
               ra_cust_trx_line_gl_dist lgd3,
               ra_cust_trx_line_gl_dist rec3,
               ra_customer_trx t
        WHERE
               t.customer_trx_id        = p_customer_trx_id
        AND    rec3.customer_trx_id     = t.customer_trx_id
        AND    rec3.account_class       = 'REC'
        AND    rec3.latest_rec_flag     = 'Y'
        AND    lgd3.customer_trx_id     = t.customer_trx_id
        AND    lgd3.account_set_flag    = 'N'
        AND    ctl.customer_trx_line_id = lgd3.customer_trx_line_id
        AND    (
                  ctl.line_type IN ('TAX', 'FREIGHT', 'CHARGES', 'SUSPENSE')
                OR
                  (ctl.line_type = 'LINE' AND ctl.accounting_rule_id IS NULL)
               )
        AND    NVL(t.previous_customer_trx_id, -1) =
                DECODE(p_trx_class_to_process,
                       'INV', -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                       NVL(t.previous_customer_trx_id, -1) )
        GROUP BY
                 ctl.customer_trx_line_id,
                 DECODE(lgd3.account_class,'UNEARN','REV',lgd3.account_class),
                 lgd3.gl_date,
                 rec3.gl_date,
                 ctl.extended_amount,
                 ctl.revenue_amount,
                 t.exchange_rate
        HAVING (
                  SUM(NVL(lgd3.amount, 0))
                            <> DECODE(DECODE(lgd3.account_class,
                                             'UNEARN','REV',lgd3.account_class),
                                     'REV',       ctl.revenue_amount,
                                     'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                      ctl.extended_amount) *
                               DECODE(lgd3.gl_date,
                                      rec3.gl_date, 1,
                                      0)
                OR
                  SUM(NVL(lgd3.acctd_amount, 0)) <>
                  DECODE(lgd3.gl_date,
                         rec3.gl_date, 1,
                         0) *
                  DECODE(p_base_mau,
                         NULL, ROUND(DECODE(DECODE(lgd3.account_class,
                                                   'UNEARN','REV',
                                                   lgd3.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                     NVL(t.exchange_rate,1),
                                     p_base_precision),
                         ROUND( (DECODE(DECODE(lgd3.account_class,
                                               'UNEARN','REV',
                                               lgd3.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                       NVL(t.exchange_rate,1)
                                ) / p_base_mau
                              ) * p_base_mau
                        )
               )
       UNION
       SELECT /*+ index( REC5 RA_CUST_TRX_LINE_GL_DIST_N6) */
              TO_NUMBER(
                         MIN(DECODE(lgd5.gl_posted_date||lgd5.account_class||
                                    lgd5.account_set_flag,
                                     'REVN',     lgd5.cust_trx_line_gl_dist_id,
                                     'REVY',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXN',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXY',     lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTN', lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTY', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESN', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESY', lgd5.cust_trx_line_gl_dist_id,
                                     'UNEARNY',  lgd5.cust_trx_line_gl_dist_id,
                                     'UNBILLY',  lgd5.cust_trx_line_gl_dist_id,
                                     NULL
                                   )
                            )
                       )
       FROM
              ra_cust_trx_line_gl_dist rec5,
              ra_cust_trx_line_gl_dist lgd5,
              ra_customer_trx_lines ctl2
       WHERE
              rec5.customer_trx_id      = p_customer_trx_id
       AND    rec5.account_class        = 'REC'
       AND    rec5.latest_rec_flag      = 'Y'
       AND    rec5.customer_trx_id      = ctl2.customer_trx_id
       AND    ctl2.customer_trx_line_id = lgd5.customer_trx_line_id
       AND    lgd5.account_set_flag =
                  DECODE(ctl2.line_type, 'LINE',
                     DECODE(ctl2.accounting_rule_id, NULL, 'N', 'Y'),
                            lgd5.account_set_flag)
       GROUP BY
                lgd5.customer_trx_line_id,
                lgd5.gl_date,
                rec5.gl_date,
                lgd5.account_set_flag,
                DECODE(lgd5.account_set_flag,
                       'N', NULL,
                       lgd5.account_class)
       HAVING SUM(NVL(lgd5.percent, 0)) <>
              DECODE( NVL(lgd5.gl_date, rec5.gl_date),
                      rec5.gl_date, 100,
                      0)
       );

      END IF; /* g_autoinv case */
   END IF; /* customer_trx_id case */

   IF (p_customer_trx_line_id IS NOT NULL)
   THEN

UPDATE ra_cust_trx_line_gl_dist lgd
SET    (amount, acctd_amount)  =
       (SELECT NVL(lgd.amount, 0) -
                            (
                             SUM(lgd2.amount) -
                             (
                                 DECODE(lgd.gl_date,
                                        rec1.gl_date, 1,
                                        0) *
                                 DECODE(DECODE(lgd2.account_class,
                                               'UNEARN','REV',
                                               lgd2.account_class),
                                        'REV',       ctl.revenue_amount,
                                        'SUSPENSE',  ctl.extended_amount -
                                                     ctl.revenue_amount,
                                        ctl.extended_amount)
                             )
                            ),  /* entered amount */
               NVL(lgd.acctd_amount, 0) -
                 (
                   SUM(lgd2.acctd_amount) -
                   (
                     DECODE(lgd.gl_date,
                            rec1.gl_date, 1,
                            0) *
                     DECODE(p_base_mau,
                         NULL, ROUND(DECODE(DECODE(lgd2.account_class,
                                                   'UNEARN','REV',
                                                   lgd2.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                     NVL(ct.exchange_rate,1),
                                     p_base_precision ),
                               ROUND( (DECODE(DECODE(lgd2.account_class,
                                                     'UNEARN','REV',
                                                     lgd2.account_class),
                                             'REV',       ctl.revenue_amount,
                                             'SUSPENSE',  ctl.extended_amount -
                                                          ctl.revenue_amount,
                                             ctl.extended_amount) *
                                       NVL(ct.exchange_rate,1)
                                      ) / p_base_mau
                                    ) * p_base_mau
                        )
                   )
                 )              /* accounted amount */
                 FROM
                          ra_cust_trx_line_gl_dist lgd2,
                          ra_customer_trx_lines ctl,
                          ra_customer_trx ct,
                          ra_cust_trx_line_gl_dist rec1
                 WHERE
                          rec1.customer_trx_id      = lgd.customer_trx_id
                 and      rec1.account_class        = 'REC'
                 and      rec1.latest_rec_flag      = 'Y'
                 and      ct.customer_trx_id        = rec1.customer_trx_id
                 and      ctl.customer_trx_id       = ct.customer_trx_id
                 and      ctl.customer_trx_line_id  = lgd.customer_trx_line_id
                 and      lgd2.customer_trx_line_id = lgd.customer_trx_line_id
                 and      lgd2.account_class        = lgd.account_class
                 and      lgd2.account_set_flag     = 'N'
                 and      NVL(lgd2.gl_date, to_date( 2415021, 'J') )  =
                             NVL(lgd.gl_date, to_date( 2415021, 'J') )
                 GROUP BY
                          ctl.customer_trx_line_id,
                          DECODE(lgd2.account_class,'UNEARN','REV',
                                 lgd2.account_class),
                          rec1.gl_date,
                          ctl.extended_amount,
                          ctl.revenue_amount,
                          ct.exchange_rate
       ),
       percent =
       (SELECT    DECODE(lgd.account_class || lgd.account_set_flag,
                         'SUSPENSEN', lgd.percent,
                         'UNBILLN', lgd.percent,
                         'UNEARNN', lgd.percent,
                         NVL(lgd.percent, 0) -
                               (
                                 SUM(NVL(lgd4.percent, 0))
                                 - DECODE(rec2.gl_date,
                                          NVL(lgd.gl_date, rec2.gl_date),
                                          100, 0)
                               )
                        )  /* percent */
        FROM
                  ra_cust_trx_line_gl_dist lgd4,
                  ra_cust_trx_line_gl_dist rec2
        WHERE
                  rec2.customer_trx_id      = lgd.customer_trx_id
        AND       rec2.account_class        = 'REC'
        AND       rec2.latest_rec_flag      = 'Y'
        AND       lgd4.customer_trx_line_id = lgd.customer_trx_line_id
        AND       lgd4.account_set_flag     = lgd.account_set_flag
        AND       DECODE(lgd4.account_set_flag,
                         'Y', lgd4.account_class,
                         lgd.account_class) = lgd.account_class
        AND       NVL(lgd4.gl_date, to_date( 2415021, 'J') )  =
                     NVL(lgd.gl_date, to_date( 2415021, 'J') )
        GROUP BY
                  rec2.gl_date,
                  lgd.gl_date
       ),
last_updated_by = arp_global.last_updated_by,    /* Bug 2089972 */
last_update_date = sysdate
 WHERE cust_trx_line_gl_dist_id  IN
       (SELECT MIN(DECODE(lgd3.gl_posted_date,
                          NULL, lgd3.cust_trx_line_gl_dist_id,
                          NULL) )
        FROM
               ra_cust_trx_line_gl_dist lgd3,
               ra_cust_trx_line_gl_dist rec3,
               ra_customer_trx t,
               ra_customer_trx_lines ctl
        WHERE
               ctl.customer_trx_line_id  = p_customer_trx_line_id
        AND    t.customer_trx_id         = ctl.customer_trx_id
        AND    rec3.customer_trx_id      = t.customer_trx_id
        AND    rec3.account_class        = 'REC'
        AND    rec3.latest_rec_flag      = 'Y'
        AND    (
                  ctl.line_type IN ('TAX', 'FREIGHT', 'CHARGES', 'SUSPENSE')
                OR
                  (ctl.line_type = 'LINE' AND ctl.accounting_rule_id IS NULL)
               )
        AND    lgd3.customer_trx_line_id = ctl.customer_trx_line_id
        AND    lgd3.account_set_flag     = 'N'
        AND    NVL(t.previous_customer_trx_id, -1) =
                DECODE(p_trx_class_to_process,
                       'INV',        -1,
                       'REGULAR_CM', t.previous_customer_trx_id,
                       NVL(t.previous_customer_trx_id, -1) )
        GROUP BY
                 ctl.customer_trx_line_id,
                 DECODE(lgd3.account_class,'UNEARN','REV',lgd3.account_class),
                 lgd3.gl_date,
                 rec3.gl_date,
                 ctl.extended_amount,
                 ctl.revenue_amount,
                 t.exchange_rate
        HAVING (
                  SUM(NVL(lgd3.amount, 0))
                            <> DECODE(DECODE(lgd3.account_class,
                                             'UNEARN','REV',lgd3.account_class),
                                      'REV',       ctl.revenue_amount,
                                      'SUSPENSE',  ctl.extended_amount -
                                                   ctl.revenue_amount,
                                      ctl.extended_amount) *
                               DECODE(lgd3.gl_date,
                                      rec3.gl_date, 1,
                                      0)
                OR
                  SUM(NVL(lgd3.acctd_amount, 0)) <>
                  DECODE(lgd3.gl_date,
                         rec3.gl_date, 1,
                         0) *
                  DECODE(p_base_mau,
                         NULL, ROUND(DECODE(DECODE(lgd3.account_class,
                                                   'UNEARN','REV',
                                                   lgd3.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                     NVL(t.exchange_rate,1),
                                     p_base_precision),
                         ROUND( (DECODE(DECODE(lgd3.account_class,
                                               'UNEARN','REV',
                                               lgd3.account_class),
                                            'REV',       ctl.revenue_amount,
                                            'SUSPENSE',  ctl.extended_amount -
                                                         ctl.revenue_amount,
                                            ctl.extended_amount) *
                                       NVL(t.exchange_rate,1)
                                ) / p_base_mau
                              ) * p_base_mau
                        )
               )
       UNION
       SELECT TO_NUMBER(
                         MIN(DECODE(lgd5.gl_posted_date||lgd5.account_class||
                                    lgd5.account_set_flag,
                                     'REVN',     lgd5.cust_trx_line_gl_dist_id,
                                     'REVY',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXN',     lgd5.cust_trx_line_gl_dist_id,
                                     'TAXY',     lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTN', lgd5.cust_trx_line_gl_dist_id,
                                     'FREIGHTY', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESN', lgd5.cust_trx_line_gl_dist_id,
                                     'CHARGESY', lgd5.cust_trx_line_gl_dist_id,
                                     'UNEARNY',  lgd5.cust_trx_line_gl_dist_id,
                                     'UNBILLY',  lgd5.cust_trx_line_gl_dist_id,
                                     NULL) )
                       )
       FROM
              ra_cust_trx_line_gl_dist lgd5,
              ra_cust_trx_line_gl_dist rec5,
              ra_customer_trx_lines ctl2
       WHERE
              ctl2.customer_trx_line_id = p_customer_trx_line_id
       AND    rec5.customer_trx_id      = lgd5.customer_trx_id
       AND    rec5.account_class        = 'REC'
       AND    rec5.latest_rec_flag      = 'Y'
       AND    lgd5.customer_trx_line_id = ctl2.customer_trx_line_id
       AND    (
                  ctl2.line_type IN ('TAX', 'FREIGHT', 'CHARGES', 'SUSPENSE')
                OR
                  (ctl2.line_type = 'LINE'   AND
                    (ctl2.accounting_rule_id IS NULL OR
                     lgd5.account_set_flag   = 'Y')
                  )
               )
       GROUP BY
                lgd5.customer_trx_line_id,
                lgd5.gl_date,
                rec5.gl_date,
                lgd5.account_set_flag,
                DECODE(lgd5.account_set_flag,
                       'N', NULL,
                       lgd5.account_class)
       HAVING SUM(NVL(lgd5.percent, 0)) <>
              DECODE( NVL(lgd5.gl_date, rec5.gl_date),
                      rec5.gl_date, 100,
                      0)
       );



   END IF; /* customer_trx_line_id case */

   l_count := sql%rowcount;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(
          'Rows Processed: '||
          l_count);
   END IF;

   p_rows_processed := p_rows_processed + l_count;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.correct_nonrule_line_records()- ' ||
                      TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

  /* MRC Processing */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('doing rounding for MRC if necessary');
  END IF;
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_NONRULE_LINE_RECORDS',
                   P_REQUEST_ID,
                   P_CUSTOMER_TRX_ID,
                   P_CUSTOMER_TRX_LINE_ID,
                   P_TRX_CLASS_TO_PROCESS
                  );

  RETURN( iTRUE );
 EXCEPTION
  WHEN others THEN
    p_error_message := SQLERRM;
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('EXCEPTION:  arp_rounding.correct_nonrule_line_records failed()- '||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
    END IF;
    RETURN(iFALSE);

END correct_nonrule_line_records;

/* Bug 2576253 - removed logic for FUNCTION correct_rule_records */

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   correct_rule_records_by_line()                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects errors in lines that use rules.                |
 |   It is a complete (from the ground up) rewrite of the logic in
 |   correct_rule_records.  The function correct_rule_records was designed
 |   to compensate for partially generated invoices (a norm in 10.7 and
 |   prior versions).  Accomodating that behavior resulted in very complex
 |   (and slow) logic.
 |
 |   The new function is broken into two pieces and relies upon bulk updates
 |   to update multiple rows at one time.  The first component is the
 |   driving cursor that identifies the specific lines that require rounding
 |   (customer_trx_line_id, account_class, amount, acctd_amount, and percent).
 |   The amount, acctd_amount, and percent are all DELTA values (the amount of
 |   rounding required.  To avoid problems with partially generated CMs (via
 |   ARTECMMB.pls, this logic will not round if the autorule_complete_flag is
 |   not null.  To avoid issues with old transactions, I now skip lines
 |   that have no unposted distributions.
 |
 |   The second component is an update statement that is fed by a second
 |   (included) subquery that identifies the specific gl_dist lines to update
 |   for each customer_trx_line_id.  This routine will always update the
 |   gl_dist line with the latest gl_date, highest amount, and if the prior
 |   two columns are the same, max(gl_dist_id).  This means that gl_dist_id
 |   is now only the tiebreaker, not the driving column.  For bug 2495595,
 |   we now only consider rows with posting_control_id = -3 to be recipients
 |   of rounding amounts.
 |
 |   Another noteworthy feature as of bug 2390821 is that we now round
 |   the REV, UNEARN (rec offset), and UNEARN (rev offset) separately.
 |   This was necessary because the original logic assummed (incorrectly)
 |   that the rec_offset UNEARN or UNBILL rows would be in balance naturally.
 |
 |   In bug 2480898, 2493896, and 2497841, we learned that older transactions
 |   that do not have rec_offset_flag set will be corrupted if they pass
 |   through the rounding logic again.  This happens if users manipulate
 |   the distributions of a completed and posted rule-based transaction.
 |   So, we now watch for transactions that do not have the rec_offset_flag
 |   set and set them where possible.  Will will not round a transaction line
 |   unless there is a rec_offset_flag=Y row for that line.
 |
 |   In bug 2535023 (see bug 2543675), we discovered that older versions of
 |   autoaccounting and unexpected behavior in ARXTWMAI can lead to situations
 |   where distributions are out of balance in interim (not last) period(s).
 |   When rounding fires, it would correct (but in last period) creating out
 |   of balance entries in two or more periods.  To prevent this, we included
 |   a new procedure called true_lines_by_gl_date to push rows back in synch
 |   before we actually round them for the line in total.
 |
 |   In bug 2449955, we figured out that we were not handling deferred
 |   lines on ARREARS invoices properly. We should treat them as if they
 |   were not deferred at all (just like conventional non-deferred rules).
 |
 |   In bugs 6325023 and 6473284, we learned that SLA will not post
 |   distributions with entered and acctd amounts having opposite signs.
 |   Since this is possible for transactions that are not in functional
 |   currency with very small line amounts (<.20).  To resolve that,
 |   we added logic to detect these situations and to insert a separate
 |   distributions to record amount and percent corrections and another
 |   distribution if the acctd_amount correction is the wrong sign.
 |
 |   For example, if the rounding correction would reverse the sign of
 |   the acctd_amount, then we will insert a separate distribution to
 |   record that correction.  However, if the entered and acctd corrections
 |   are themselves of opposite signs, then we'll insert one positive
 |   and a separate one with zero amount and negative acctd_amount.
 |
 |   This matrix helps explain what we round each line (by account_class)
 |   to:
 |
 |   CLASS  ROF  DEF   RULE   RESULT    NOTES
 |   REV    N    N     -2/-3  rev_amt
 |   REV    N    Y     -2     0         form adjustments
 |   REV    N    Y     -3     rev_amt
 |   UE     N    N     -2/-3  rev_amt*-1
 |   UE     Y    N     -2/-3  rev_amt
 |   UE     N    Y     -2     0         form adjustments
 |   UE     Y    Y     -2/-3  rev_amt
 |   UE     N    Y     -3     rev_amt   overrides deferred rules
 |
 | REQUIRES                                                                |
 |   All IN parameters                                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   An ORACLE ERROR EXCEPTION if an ORACLE error occurs                   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |
 |  Created by bug 2150541
 |
 |   06-JUN-2002   M Raymond  2398021   Restructured both select and update
 |                                      to accomodate rounding of the
 |                                      rec_offset_rows.                   |
 |   09-JUL-2002   M Raymond  2445800   Added a where clause to accomodate
 |                                      CMs against invoices that have been
 |                                      reversed and regenerated by RAM.
 |   31-JUL-2002   M Raymond  2487744   Modified logic for deferred rules
 |                                      to round CMs against deferred invoices.
 |   02-AUG-2002   M Raymond  2492345   Exclude model rows when determining
 |                                      the max gl_date
 |   03-AUG-2002   M Raymond  2497841   Test and (when necessary) set the
 |                                      rec_offset_flag
 |                                      Added parameter for suppressing
 |                                      rec_offset_flag on calls from
 |                                      revenue recognition.
 |   20-AUG-2002   M Raymond  2480852   Change handling of deferred rules
 |                                      and revenue adjustments.
 |   20-AUG-2002   M Raymond  2480852   Exclude posted rows from being
 |                                      recipients of rounding amounts.
 |   26-AUG-2002   M Raymond  2532648   Exclude posted rows from rounding
 |                                      completely.
 |   27-AUG-2002   M Raymond  2532648   Re-implemented skipping of lines
 |                                      bearing deferred rules.
 |   04-SEP-2002   M Raymond  2535023   Revised SELECT to carefully round
 |                                      form adjustments on deferred rule lines
 |                                      to zero instead of extended amount.
 |   05-SEP-2002   M Raymond  2535023   Added a separate private procedure
 |                                      called true_lines_by_gl_date.  Now
 |                                      calling this routine to make sure
 |                                      gl_dates in all periods balance before
 |                                      I round the line in total.
 |   10-SEP-2002   M Raymond  2559944   Not handling deferred lines for
 |                                      ARREARS invoices properly.  Revised
 |                                      CURSOR to properly ignore defers
 |                                      on ARREARS invoices.
 |   13-SEP-2002   M Raymond  2543576   Switched from extended_amount to
 |                                      revenue_amount.  This accomodates
 |                                      situations where suspense accounts are
 |                                      in use.  Just FYI, ext_amt = qty * prc
 |                                      and rev_amt can equal ext_amt unless
 |                                      the user passed a different ext_amt
 |                                      via autoinvoice and had clearing
 |                                      enabled.  The amt passed by user
 |                                      and used for line is stored in
 |                                      revenue_amount
 |   14-SEP-2002   M Raymond  2569870   Prevented RAM dists from being
 |                                      recipient of rounding (UPDATE).  Also
 |                                      changed SELECT to exclude rule-based
 |                                      lines when no rec_offset row exists.
 |   06-MAR-2003   M Raymond  2632863   Fixed rounding errors when dist in
 |                                      last period was of opposite sign
 |                                      ex: CM vs .2/12 invoice
 |   02-OCT-2003   M Raymond  3033850/3067588
 |                                      Modified code to execute three times
 |                                      for same, opposite, and zero rounding.
 |                                      Also removed sign subquery.
 |   04-MAY-2004   M Raymond  3605089   Added logic for SUSPENSE to this
 |                                      logic to round for salescredit
 |                                      splits.  later removed logic as
 |                                      it does not resolve issue at hand.
 |                                      See ARPLCREB.pls 115.64 if SUSPENSE
 |                                      rounding comes in conjunction with
 |                                      salescredits.
 |   06-OCT-2007   M Raymond  6325023/6473284 - Added logic to handle
 |                                      unusual rounding issues for
 |                                      acctd amounts.
 +-------------------------------------------------------------------------*/

FUNCTION correct_rule_records_by_line(
		P_REQUEST_ID           IN NUMBER,
                P_CUSTOMER_TRX_ID      IN NUMBER,
                P_ROWS_PROCESSED       IN OUT NOCOPY NUMBER,
                P_ERROR_MESSAGE        OUT NOCOPY VARCHAR2,
                P_BASE_PRECISION       IN NUMBER,
                P_BASE_MAU             IN NUMBER,
                P_TRX_CLASS_TO_PROCESS IN VARCHAR2,
                P_CHECK_RULES_FLAG     IN VARCHAR2,
                P_PERIOD_SET_NAME      IN OUT NOCOPY VARCHAR2,
                P_FIX_REC_OFFSET       IN VARCHAR2 DEFAULT 'Y')

         RETURN NUMBER IS

  t_line_id       l_line_id_type;
  t_gl_id         l_line_id_type;
  t_round_amount  l_amount_type;
  t_round_percent l_percent_type;
  t_round_acctd   l_amount_type;
  t_account_class l_acct_class;
  t_rec_offset    l_rec_offset;

  l_rows_needing_rounding NUMBER;
  l_rows_rounded NUMBER := 0;
  l_rows_rounded_this_pass NUMBER := 0;
  l_phase NUMBER := 0;

  l_result NUMBER;
  /* Cursor for FINAL rounding
     Detects which customer_trx_line_ids require rounding
     and determines the amount, acctd_amount, and percent
     for each account_class */

  /* Dev note:  The EXISTS clause for rec_offset_flag (rof)
     was added as a precaution.  It has a noticable impact on
     the explain plan - so it may be necessary to remove it
     if performance becomes an issue in this code.  An alternative
     would be to put it in the UPDATE instead, thus limiting the number
     of times it gets called.*/

  CURSOR round_rows_by_trx(p_trx_id NUMBER,
                           p_base_mau NUMBER,
                           p_base_precision NUMBER) IS
  select l.customer_trx_line_id, g.account_class,
         /* AMOUNT LOGIC */
         (DECODE(g.rec_offset_flag, 'Y', l.revenue_amount,
             DECODE(r.deferred_revenue_flag, 'Y',
                DECODE(t.invoicing_rule_id, -2, 0, l.revenue_amount),
               l.revenue_amount))
          - (sum(g.amount) *
               DECODE(g.account_class, 'REV', 1,
                  DECODE(g.rec_offset_flag, 'Y', 1, -1))))
                     * DECODE(g.account_class, 'REV', 1,
                          DECODE(g.rec_offset_flag, 'Y', 1, -1))  ROUND_AMT,
         /* PERCENT LOGIC */
         (DECODE(g.rec_offset_flag, 'Y', 100,
             DECODE(r.deferred_revenue_flag, 'Y',
                DECODE(t.invoicing_rule_id, -2, 0, 100),
                100))
          - (sum(g.percent) *
               DECODE(g.account_class, 'REV', 1,
                 DECODE(g.rec_offset_flag, 'Y', 1, -1))))
                  * DECODE(g.account_class, 'REV', 1,
                      DECODE(g.rec_offset_flag, 'Y', 1, -1))  ROUND_PCT,
         /* ACCTD_AMOUNT LOGIC */
         (DECODE(p_base_mau, NULL,
            ROUND(DECODE(g.rec_offset_flag, 'Y', l.revenue_amount,
                     DECODE(r.deferred_revenue_flag, 'Y',
                        DECODE(t.invoicing_rule_id, -2, 0, l.revenue_amount),
                             l.revenue_amount))
                   * nvl(t.exchange_rate,1), p_base_precision),
            ROUND((DECODE(g.rec_offset_flag, 'Y', l.revenue_amount,
                      DECODE(r.deferred_revenue_flag, 'Y',
                        DECODE(t.invoicing_rule_id, -2, 0, l.revenue_amount),
                             l.revenue_amount))
                   * nvl(t.exchange_rate,1)) / p_base_mau) * p_base_mau)
          - (sum(g.acctd_amount) *
               DECODE(g.account_class, 'REV', 1,
                 DECODE(g.rec_offset_flag, 'Y', 1, -1))))
                  * DECODE(g.account_class, 'REV', 1,
                      DECODE(g.rec_offset_flag, 'Y', 1, -1))  ROUND_ACCT_AMT,
         /* END ACCTD_AMOUNT LOGIC */
         g.rec_offset_flag
  from   ra_customer_trx_lines l,
         ra_cust_trx_line_gl_dist g,
         ra_customer_trx t,
         ra_rules r
  where  t.customer_trx_id = p_trx_id
  and    l.customer_trx_id = t.customer_trx_id
  and    l.customer_trx_id = g.customer_trx_id
  and    l.customer_trx_line_id = g.customer_trx_line_id
         /* Skip any entries created by revenue adjustments
            or for deferred rules */
  and    l.accounting_rule_id = r.rule_id
  and    g.revenue_adjustment_id is NULL
         /* Only round transaction lines with rules */
  and    l.accounting_rule_id is not NULL
  and    l.autorule_complete_flag is NULL
  and    g.account_class IN ('REV','UNEARN','UNBILL')
  and    g.account_set_flag = 'N'
         /* Only round lines that actually have a rec_offset row */
  and exists ( SELECT 'has rof row'
               FROM   ra_cust_trx_line_gl_dist rof
               WHERE  rof.customer_trx_line_id = g.customer_trx_line_id
               AND    rof.account_set_flag = 'N'
               AND    rof.account_class in ('UNEARN','UNBILL')
               AND    rof.rec_offset_flag = 'Y')
  having
         /* AMOUNT LOGIC */
         (sum(g.amount) <>  DECODE(g.account_class, 'REV', l.revenue_amount,
                              DECODE(g.rec_offset_flag, 'Y', l.revenue_amount,
                                             l.revenue_amount * -1)) *
                  DECODE(r.deferred_revenue_flag, 'Y',
                    DECODE(g.rec_offset_flag, 'Y', 1,
                      DECODE(t.invoicing_rule_id, -2, 0, 1)),1) or
         /* PERCENT LOGIC */
         sum(g.percent) <> DECODE(g.account_class, 'REV', 100,
                            DECODE(g.rec_offset_flag, 'Y', 100, -100)) *
                  DECODE(r.deferred_revenue_flag, 'Y',
                    DECODE(g.rec_offset_flag, 'Y', 1,
                      DECODE(t.invoicing_rule_id, -2, 0, 1)),1) or
         /* ACCTD_AMOUNT LOGIC */
         sum(g.acctd_amount) <> DECODE(p_base_mau, NULL,
                    ROUND(l.revenue_amount * nvl(t.exchange_rate,1), p_base_precision),
                    ROUND((l.revenue_amount * nvl(t.exchange_rate,1)) /
                                            p_base_mau) * p_base_mau) *
                  DECODE(r.deferred_revenue_flag, 'Y',
                    DECODE(g.rec_offset_flag, 'Y', 1,
                      DECODE(t.invoicing_rule_id, -2, 0, 1)),1) *
                  DECODE(g.account_class, 'REV', 1,
                    DECODE(g.rec_offset_flag, 'Y', 1, -1)))
         /* Only round lines w/unposted distributions */
  and    min(g.posting_control_id) = -3
group by l.customer_trx_line_id, g.account_class, g.rec_offset_flag,
         l.revenue_amount, t.exchange_rate, r.deferred_revenue_flag,
         t.invoicing_rule_id;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug( 'arp_rounding.correct_rule_records_by_line()+ ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  IF (P_CUSTOMER_TRX_ID IS NOT NULL) THEN
    /* Form and Rev Rec variant */

    IF (P_FIX_REC_OFFSET = 'Y') THEN
       /* Verify that rec_offset_flag(s) are set for this transaction
          and set them if they are not */
       set_rec_offset_flag(p_customer_trx_id, null, l_result);

       IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('  result from set_rec_offset_flag() call : ' || l_result);
       END IF;

    END IF;

     /* This is phase 1 of rounding.
        Here, we make sure that debits equal credits (REV and UNEARN dists)
        on a gl_date basis.  We do this for both RAM and conventional
        distributions.  If there is a problem, we correct it
        on that date. */
     true_lines_by_gl_date(p_customer_trx_id);

     /* This is phase 2 of rounding.
        With this cursor and subsequent UPDATE, we detect situations
        where REV, UNEARN, or UNEARN(rof) for each line do not total
        to the revenue_amount of the line.  This routine assumes that
        the previous one has executed and that everything is already
        in balance by gl_date.

        NOTE:  Under normal circumstances, this routine will only make
        changes to distributions as part of Revenue Recognition.  It
        should not make changes based on form-level adjustments or
        RAM adjustments (after Revenue Recognition has completed).

        As of bug 3033850, I revised the rounding logic to execute up
        to three separate times/phases to handle unusual cases (opposite sign,
        zero dists)  The code will execute first for same sign rounding,
        then opposite sign, and finally, using zero sign dists.  The code
        should be able to detect if rounding is complete and exit after
        having rounded all the distributions.  Even if only 1 or two phases
        have been completed.

        The phases/passes are:
          1=Dists with any sign (same, opposite, or zero) as line (UPDATE)
          2=Dists where corrections cause signs to mismatch (+/-) (INSERT)
          3=Continuation of 4, corrections themselves have opposite signs (INSERT)

        Note:  phase 2 and 3 will only function if the acctd_amount
             correction is a different sign than the entered amount.

        */

     OPEN round_rows_by_trx(P_CUSTOMER_TRX_ID, P_BASE_MAU, P_BASE_PRECISION);
	FETCH round_rows_by_trx BULK COLLECT INTO
                             t_line_id,
                             t_account_class,
                             t_round_amount,
                             t_round_percent,
                             t_round_acctd,
                             t_rec_offset;

        l_rows_needing_rounding := round_rows_by_trx%ROWCOUNT;

        CLOSE round_rows_by_trx;

  ELSE
     /* Autoinvoice variant */
     /* No reason to round line-based distributions */
     l_rows_needing_rounding := 0;
     RETURN (iTRUE);

  END IF;

  /* Now update all the rows that require it */

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Rows that need rounding: ' || l_rows_needing_rounding);
  END IF;

  IF (l_rows_needing_rounding > 0) THEN

     /* DEBUG CODE +/
                FOR err in t_line_id.FIRST .. t_line_id.LAST LOOP
                   arp_standard.debug(err || ' ' || t_line_id(err)|| '  ' ||
                                      t_account_class(err) ||
                     '  ' || t_rec_offset(err) ||
                     '  ' || t_round_amount(err) ||
                     ' ' || t_round_acctd(err) || ' ' ||
                     t_round_percent(err) );
                END LOOP;
     /+ END DEBUG CODE */

     /* START - Main Loop */
     WHILE (l_phase < 3 and l_rows_needing_rounding - l_rows_rounded > 0)
     LOOP

        l_phase := l_phase + 1;

        IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('  Pass = ' || l_phase);
        END IF;

        IF l_phase = 1
        THEN

          /* 9160123 - changed rounding code from 5 phases to 3 and
             simplified the update logic.  The original phases 1-3
             are now handled in a single call (phase 1).  The original
             phases 4 and 5 are now 2 and 3 respectively.  The need
             for phases 1-3 was replaced in the simplified logic by
             DECODES that map a '3', '2', or '1' as 9th digit in the sorted
             string that uses gl_date, amount, and gl_dist_id.  This logic
             was forward ported from version 115.59.15101.3.  */

          /* In the logic below, we fetch the gl_date, a single
             digit (3, 2, or 1) representing signs, the amount, and
             the gl_dist_id and append them in that order.. the result
             looks like this:

             200908123000000000000123.710000000000123412341234
             GL_DATE|#|GL_DIST_AMOUNT__|GL_DIST_ID___________|

             In this example, the gl_date of this gl_dist row
             is 12-AUG-2009. The '3' indicates that the gl_dist
             amount and line.revenue_amount are of same sign.
             The gl_dist.amount is 123.71 and the gl_dist_id is
             123412341234.  The sql would return only the gl_dist_id
             of the distribution for each account class to be
             rounded.

             The sql selects one REV, one UNEARN(rof), and
             one UNEARN(non-rof) for each trx_line_id.  */


          FORALL i IN t_line_id.FIRST .. t_line_id.LAST
           UPDATE ra_cust_trx_line_gl_dist
           SET    amount = amount + t_round_amount(i),
                  percent = percent + t_round_percent(i),
                  acctd_amount = acctd_amount + t_round_acctd(i),
                  last_updated_by = arp_global.last_updated_by,
                  last_update_date = sysdate
           WHERE  cust_trx_line_gl_dist_id in (
              /* Bug 4082528 - Select restructured */
              /* START OF GL_DIST_ID SELECT */
              select
                to_number(substr(max(
                       to_char(g.gl_date,'YYYYMMDD') ||
                       decode(sign(g.amount *
                                 DECODE(g.account_class, 'REV', 1,
                                   DECODE(g.rec_offset_flag, 'Y', 1, -1))),
                              sign(tl.revenue_amount), '3',
                           sign(tl.revenue_amount * -1), '2', '1') ||
                       ltrim(to_char(abs(g.amount),'099999999999999.00')) ||
                       ltrim(to_char(g.cust_trx_line_gl_dist_id,
                                          '0999999999999999999999'))),28))
              from   ra_cust_trx_line_gl_dist g,
                     ra_customer_trx_lines tl
              where  g.customer_trx_line_id = t_line_id(i)
              and    tl.customer_trx_line_id = g.customer_trx_line_id
              and    g.account_class = t_account_class(i)
              and    g.account_set_flag = 'N'
                     /* ONLY USE UNPOSTED ROWS */
              and    g.posting_control_id = -3
                     /* ONLY CONSIDERS REC_OFFSET_FLAG IF NOT NULL */
              and    nvl(g.rec_offset_flag, '~') = nvl(t_rec_offset(i), '~')
                     /* DO NOT ROUND RAM DISTRIBUTIONS */
              and    g.revenue_adjustment_id is null
                     /* SKIP UPDATE IF SIGNS ARE OPPOSITE */
              and   (sign(g.amount + t_round_amount(i)) =
                     sign(g.acctd_amount + t_round_acctd(i)) or
                     sign(g.amount + t_round_amount(i)) = 0)
              /* END OF GL_DIST_ID SELECT */
              );
        ELSE
           /* 6325023 - added 2nd phase to handle SLA issues where
              entered and acctd_amount dists have opposite signs */
           /* 6473284 - Added 3rd phase to extend fix for 6325023 to
               cover some odd corner cases. */


           FORALL i in t_line_id.first .. t_line_id.last
            INSERT INTO RA_CUST_TRX_LINE_GL_DIST
              (CUST_TRX_LINE_GL_DIST_ID,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE,
               POSTING_CONTROL_ID,
               SET_OF_BOOKS_ID,
               CUSTOMER_TRX_LINE_ID,
               CUSTOMER_TRX_ID,
               ACCOUNT_CLASS,
               CODE_COMBINATION_ID,
               AMOUNT,
               ACCTD_AMOUNT,
               PERCENT,
               GL_DATE,
               ORIGINAL_GL_DATE,
               ACCOUNT_SET_FLAG,
               COMMENTS,
               ATTRIBUTE_CATEGORY,
               ATTRIBUTE1,
               ATTRIBUTE2,
               ATTRIBUTE3,
               ATTRIBUTE4,
               ATTRIBUTE5,
               ATTRIBUTE6,
               ATTRIBUTE7,
               ATTRIBUTE8,
               ATTRIBUTE9,
               ATTRIBUTE10,
               ATTRIBUTE11,
               ATTRIBUTE12,
               ATTRIBUTE13,
               ATTRIBUTE14,
               ATTRIBUTE15,
               LATEST_REC_FLAG,
               USSGL_TRANSACTION_CODE,
               REC_OFFSET_FLAG,
               USER_GENERATED_FLAG,
               ORG_ID,
               REQUEST_ID,
               CUST_TRX_LINE_SALESREP_ID,
               ROUNDING_CORRECTION_FLAG
              )
        SELECT
            RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            -3,
            SET_OF_BOOKS_ID,
            CUSTOMER_TRX_LINE_ID,
            CUSTOMER_TRX_ID,
            ACCOUNT_CLASS,
            CODE_COMBINATION_ID,
            DECODE(l_phase, 2, t_round_amount(i), 0),
            DECODE(l_phase, 2,
              DECODE(SIGN(t_round_amount(i)),0,t_round_acctd(i),
                   ABS(t_round_acctd(i)) * SIGN(t_round_amount(i))),
              t_round_acctd(i) * 2),
            DECODE(l_phase, 2, t_round_percent(i), 0),
            GL_DATE,
            ORIGINAL_GL_DATE,
            ACCOUNT_SET_FLAG,
            'PHASE ' || l_phase || ':  Rounding correction derived from ' ||
               cust_trx_line_gl_dist_id,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            LATEST_REC_FLAG,
            USSGL_TRANSACTION_CODE,
            REC_OFFSET_FLAG,
            USER_GENERATED_FLAG,
            ORG_ID,
            REQUEST_ID,
            CUST_TRX_LINE_SALESREP_ID,
            'Y'
        FROM  RA_CUST_TRX_LINE_GL_DIST_ALL
        WHERE CUST_TRX_LINE_GL_DIST_ID IN (
              /* SELECT GL_DIST_ID FOR EACH LINE THAT
                 REQUIRES ROUNDING */
              select
                to_number(substr(max(
                       to_char(g.gl_date,'YYYYMMDD') ||
                       decode(sign(g.amount *
                                 DECODE(g.account_class, 'REV', 1,
                                   DECODE(g.rec_offset_flag, 'Y', 1, -1))),
                              sign(tl.revenue_amount), '3',
                           sign(tl.revenue_amount * -1), '2', '1') ||
                       ltrim(to_char(abs(g.amount),'099999999999999.00')) ||
                       ltrim(to_char(g.cust_trx_line_gl_dist_id,
                                          '0999999999999999999999'))),28))
              from   ra_cust_trx_line_gl_dist g,
                     ra_customer_trx_lines tl
              where  g.customer_trx_line_id = t_line_id(i)
              and    tl.customer_trx_line_id = g.customer_trx_line_id
              and    g.account_class = t_account_class(i)
              and    g.account_set_flag = 'N'
                     /* ONLY USE UNPOSTED ROWS */
              and    g.posting_control_id = -3
                     /* ONLY CONSIDERS REC_OFFSET_FLAG IF NOT NULL */
              and    nvl(g.rec_offset_flag, '~') = nvl(t_rec_offset(i), '~')
                     /* DO NOT ROUND RAM DISTRIBUTIONS */
              and    g.revenue_adjustment_id is null
              /* END OF GL_DIST_ID SELECT */
              );

        END IF;

       l_rows_rounded_this_pass := 0;

       /* START - Cleanup loop */
       FOR upd in t_line_id.FIRST .. t_line_id.LAST LOOP

          IF(SQL%BULK_ROWCOUNT(upd) = 1)
          THEN

          /* This piece of code determines that 1 row was updated
             for each invoice line and account class.  Once the
             row is updated, we need to remove it from further
             consideration.  To do that, we change the line_id
             to line_id * -1 (a row that should never exist)
             and this prevents it from being processed in
             subsequent passes.

             Incidentally, I tried to just delete the
             processed rows - but this caused subsequent
             passes to fail with ORA errors due to missing
             plsql table rows.  The bulk update requires
             a continuous list in sequential order and, by deleting
             rows from the table, we cause the update to fail.
          */

              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('  Target: ' || t_line_id(upd) ||
                                '  ' || t_account_class(upd) ||
                                '  ' || t_rec_offset(upd) ||
                                '  ' || t_round_amount(upd) ||
                                '  ' || t_round_acctd(upd) ||
                                ' ' || t_round_percent(upd) ||
                                ' ' || SQL%BULK_ROWCOUNT(upd));
              END IF;


              IF l_phase = 2
              THEN
                 /* extra checks to see if we need last phase */
                 IF t_round_amount(upd) = 0
                    OR  t_round_acctd(upd) = 0
                    OR  SIGN(t_round_amount(upd)) = SIGN(t_round_acctd(upd))
                 THEN
                    /* This phase inserted complete dists
                       so no need to insert another dist */
                    l_rows_rounded_this_pass := l_rows_rounded_this_pass + 1;
                    t_line_id(upd) := -1 * t_line_id(upd);
                 ELSE
                    /* Do not change the line_id or increment.. this
                        forces the last phase and an insert of
                        a dist with amount=0 and acctd_amount=<correction * 2>
                    */
                    NULL;
                 END IF;
              ELSE
                 /* previous behavior */
                 l_rows_rounded_this_pass := l_rows_rounded_this_pass + 1;
                 /* make line_id negative so it causes no further updates */
                 t_line_id(upd) := -1 * t_line_id(upd);
              END IF;
          END IF;

          IF(SQL%BULK_ROWCOUNT(upd) > 1)
          THEN
             /* Failure condition 1
                This section of code executes only when more than
                one line is updated for a given customer_trx_line_id
                and account_class.  That would mean that the rounding
                logic was unable to identify a single line for update
                and rounding would then raise an error to roll back
                any corrections or calculations for this transaction.

                Revenue recognition has been modified to roll back
                transactions that fail and to document the lines
                that have problems.  */

             IF PG_DEBUG in ('Y', 'C')
             THEN

                FOR err in t_line_id.FIRST .. t_line_id.LAST LOOP
                   arp_standard.debug(t_line_id(err)|| '  ' ||
                                      t_account_class(err) ||
                     '  ' || t_rec_offset(err) ||
                     '  ' || t_round_amount(err) ||
                     ' ' || t_round_acctd(err) || ' ' ||
                     t_round_percent(err) || '   ' || SQL%BULK_ROWCOUNT(err));
                END LOOP;

             END IF;

             p_error_message := 'arp.rounding:  Error identifying rows for correction.  trx_id = ' || p_customer_trx_id;

             RETURN(iFALSE);

          END IF;

       END LOOP; /* END - Cleanup loop */

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('    Rows rounded this pass : ' || l_rows_rounded_this_pass);
       END IF;

       l_rows_rounded := l_rows_rounded + l_rows_rounded_this_pass;

     END LOOP;  /* END - Main processing loop */

       IF (l_rows_needing_rounding <> l_rows_rounded) THEN

          /* Failure condition 2
             In this situation, the total number of distributions corrected
             does not match the number expected.  Because of condition 1
             handled above, this would only occur if we were unable to
             locate any rows to assess rounding corrections to for
             one or more invoice lines.  Such situations highlight
             shortcomings in this logic that must be investigated
             and corrected.
          */

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Mismatch between lines found and lines updated (see below)');
             arp_standard.debug('  Rows targeted: ' || l_rows_needing_rounding);
             arp_standard.debug('  Rows rounded : ' || l_rows_rounded);

             FOR err in t_line_id.FIRST .. t_line_id.LAST LOOP

                 arp_standard.debug(t_line_id(err) || '  ' || t_account_class(err) ||
                     '  ' || t_rec_offset(err) ||
                     '  ' || t_round_amount(err) || ' ' || t_round_acctd(err) || ' ' ||
                     t_round_percent(err) || '   ' || SQL%BULK_ROWCOUNT(err));

             END LOOP;

          END IF;

            p_error_message := ' arp_rounding: Error identifying rows for correction. ' ||
                               ' trx_id = ' || p_customer_trx_id;

          RETURN(iFALSE);
       END IF;

       p_rows_processed := p_rows_processed + l_rows_rounded;
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Total number of rows updated:  ' || l_rows_rounded);
       END IF;

  /* MRC Processing */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('doing rounding for MRC if necessary');
  END IF;
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_RULE_RECORDS_BY_LINE',
                   P_REQUEST_ID,
                   P_CUSTOMER_TRX_ID,
                   NULL,    /* customer trx line id */
                   P_TRX_CLASS_TO_PROCESS,
         	   NULL,   /* concat_segs */
                   NULL,  /* balanced round_ccid */
                   p_check_rules_flag,
                   p_period_set_name
                  );

  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_rule_records_by_line()- ' ||
                     TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

  RETURN(iTRUE);
END correct_rule_records_by_line;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 |   correct_rev_adj_by_line()                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects rounding errors resulting from revenue
 |   adjustments created via ar_revenue_adjustment_pvt.dists_by_model
 |   routine.  The logic contained below is almost identical to
 |   correct_rule_records_by_line (although it has been altered to
 |   drive from AR_LINE_REV_ADJ_GT table (capable of rounding
 |   multiple transactions or adjustments at one time).
 |
 |   See description of correct_rule_records_by_line for details about
 |   the architecture of this function.
 |
 |   NOTE:  Due to the unique data available for RAM adjustments, it was
 |   not possible to round percents consistently at this time.  amount and
 |   acctd_amount columns will be rounded -- but percents will not.
 +-------------------------------------------------------------------------*/

FUNCTION correct_rev_adj_by_line
        RETURN NUMBER IS

  t_line_id       l_line_id_type;
  t_gl_id         l_line_id_type;
  t_round_amount  l_amount_type;
  t_round_percent l_percent_type;
  t_round_acctd   l_amount_type;
  t_account_class l_acct_class;
  t_rev_adj_id    l_line_id_type;

  l_rows_needing_rounding NUMBER;
  l_rows_rounded NUMBER := 0;
  l_rows_rounded_this_pass NUMBER := 0;
  l_phase NUMBER := 0;

  /* Cursor for FINAL rounding
     Detects which customer_trx_line_ids require rounding
     and determines the amount, acctd_amount, and percent
     for each account_class */

  CURSOR round_rows_by_trx(p_base_mau NUMBER,
                           p_base_precision NUMBER) IS
  select /*+ leading(gt t) index(l ra_customer_trx_lines_u1) index(g ra_cust_trx_line_gl_dist_n1)*/
         l.customer_trx_line_id, g.account_class,
         /* AMOUNT LOGIC */
         (gt.amount
          - (sum(g.amount)
              * DECODE(g.account_class, 'REV',1,-1)))
                 * DECODE(g.account_class, 'REV',1,-1)        ROUND_AMT,
         /* END AMOUNT LOGIC */
         /* Leaving percent alone for now */
         0                                                    ROUND_PCT,
         /* ACCTD_AMOUNT LOGIC */
         (DECODE(p_base_mau, NULL,
            ROUND(gt.amount
               * nvl(t.exchange_rate,1), p_base_precision),
            ROUND((gt.amount
               * nvl(t.exchange_rate,1))
                    / p_base_mau) * p_base_mau)
          - (sum(g.acctd_amount)
               * DECODE(g.account_class, 'REV', 1, -1)))
                  * DECODE(g.account_class, 'REV', 1, -1)     ROUND_ACCT_AMT,
         /* END ACCTD_AMOUNT LOGIC */
         gt.revenue_adjustment_id
  from   ra_customer_trx_lines    l,
         ar_line_rev_adj_gt       gt,
         ra_cust_trx_line_gl_dist g,
         ra_customer_trx          t
  where  t.customer_trx_id = gt.customer_trx_id
  and    l.customer_trx_id = t.customer_trx_id
  and    l.customer_trx_id = g.customer_trx_id
  and    l.customer_trx_line_id = g.customer_trx_line_id
/* Bug Number 6782307 -- Added the below join condition */
  and    l.customer_trx_line_id = gt.customer_trx_line_id
  and    g.revenue_adjustment_id = gt.revenue_adjustment_id
  and    l.autorule_complete_flag is NULL
  and    g.account_class IN ('REV','UNEARN','UNBILL')
  and    g.account_set_flag = 'N'
  having
         /* AMOUNT LOGIC */
         (sum(g.amount) <>  gt.amount *
                   DECODE(g.account_class, 'REV',1,-1) or
         /* PERCENT LOGIC
         sum(g.percent) <> DECODE(g.account_class, 'REV', 100,
                            DECODE(g.rec_offset_flag, 'Y', 100, -100)) *
                  DECODE(r.deferred_revenue_flag, 'Y',
                    DECODE(g.rec_offset_flag, 'Y', 1,
                      DECODE(t.invoicing_rule_id, -2, 0, 1)),1) or */
         /* ACCTD_AMOUNT LOGIC */
         sum(g.acctd_amount) <> DECODE(p_base_mau, NULL,
                    ROUND(gt.amount
                       * nvl(t.exchange_rate,1), p_base_precision),
                    ROUND((gt.amount
                       * nvl(t.exchange_rate,1)) /
                               p_base_mau) * p_base_mau) *
                  DECODE(g.account_class, 'REV', 1,-1))
         /* Only round lines w/unposted distributions */
  and    min(g.posting_control_id) = -3
group by l.customer_trx_line_id, g.account_class,
         gt.revenue_adjustment_id, gt.amount, t.exchange_rate;

BEGIN

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_rev_adj_by_line()+ ');
  END IF;

     /* This is phase 1 of rounding.
        Here, we make sure that debits equal credits (REV and UNEARN dists)
        on a gl_date basis.  We do this for both RAM and conventional
        distributions.  If there is a problem, we correct it
        on that date. */

     /* Passing null to this routine forces it to drive using a join
        to ar_line_rev_adj_gt table */
     true_lines_by_gl_date(null);

     /* This is phase 2 of rounding.
        With this cursor and subsequent UPDATE, we detect situations
        where REV or UNEARN for each line do not total
        to the adjustment amount of the line.  This routine assumes that
        the previous one has executed and that everything is already
        in balance by gl_date.

        The phases are 1=Dists with same sign as line
                       2=Dists with opposite sign as line
                       3=Dists with zero amount (when line is non-zero
                       4=Dists where acctd_amount sign changes */

     OPEN round_rows_by_trx(AR_RAAPI_UTIL.g_min_acc_unit,
                            AR_RAAPI_UTIL.g_trx_precision);
	FETCH round_rows_by_trx BULK COLLECT INTO
                             t_line_id,
                             t_account_class,
                             t_round_amount,
                             t_round_percent,
                             t_round_acctd,
                             t_rev_adj_id;

        l_rows_needing_rounding := round_rows_by_trx%ROWCOUNT;

        CLOSE round_rows_by_trx;

  /* Now update all the rows that require it */

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('Rows that need rounding: ' || l_rows_needing_rounding);
  END IF;

  IF (l_rows_needing_rounding > 0) THEN

     /* DEBUG CODE +/
                FOR err in t_line_id.FIRST .. t_line_id.LAST LOOP
                   arp_standard.debug(err || ' ' || t_line_id(err)|| '  ' ||
                                      t_account_class(err) ||
                     '  ' || t_round_amount(err) ||
                     ' ' || t_round_acctd(err) || ' ' ||
                     t_round_percent(err) );
                END LOOP;
     /+ END DEBUG CODE */

     /* START - Main Loop */
     WHILE (l_phase < 5 and l_rows_needing_rounding - l_rows_rounded > 0)
     LOOP

        l_phase := l_phase + 1;

        IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug('  Pass = ' || l_phase);
        END IF;

        IF l_phase <=3
        THEN
          FORALL i IN t_line_id.FIRST .. t_line_id.LAST
           UPDATE ra_cust_trx_line_gl_dist
           SET    amount = amount + t_round_amount(i),
                  percent = percent + t_round_percent(i),
                  acctd_amount = acctd_amount + t_round_acctd(i),
                  last_updated_by = arp_global.last_updated_by,
                  last_update_date = sysdate
           WHERE  cust_trx_line_gl_dist_id in (
              /* SELECT GL_DIST_ID FOR EACH LINE THAT
                 REQUIRES ROUNDING */
              select MAX(g.cust_trx_line_gl_dist_id)
              from   ra_cust_trx_line_gl_dist g,
                     ra_cust_trx_line_gl_dist gmax,
                     ra_customer_trx_lines tl
              where  g.customer_trx_line_id = t_line_id(i)
              and    tl.customer_trx_line_id = g.customer_trx_line_id
              and    g.account_class = t_account_class(i)
              and    g.account_set_flag = 'N'
                     /* ONLY USE UNPOSTED ROWS */
              and    g.posting_control_id = -3
                     /* ONLY CONSIDERS NON-REC_OFFSET ROWS */
              and    g.rec_offset_flag IS NULL
                     /* only a specific rev_adj */
              and    g.revenue_adjustment_id = t_rev_adj_id(i)
                     /* FORCES USE OF ROW IN LAST PERIOD */
              and    g.gl_date = (
                         select max(gl_date)
                         from ra_cust_trx_line_gl_dist gdmax
                         where gdmax.customer_trx_line_id = g.customer_trx_line_id
                         and   gdmax.account_class = g.account_class
                         and   nvl(gdmax.rec_offset_flag, '~') =
                                         nvl(g.rec_offset_flag, '~')
                         and   gdmax.account_set_flag = 'N'
                         and   gdmax.posting_control_id = -3
                         and   gdmax.revenue_adjustment_id = t_rev_adj_id(i))
              and    gmax.customer_trx_line_id = g.customer_trx_line_id
              and    gmax.account_class = g.account_class
              and    gmax.account_set_flag = 'N'
              and    nvl(gmax.rec_offset_flag, '~') = nvl(g.rec_offset_flag, '~')
              and    gmax.gl_date = g.gl_date
                     /* ONLY RAM DISTRIBUTIONS */
              and    g.revenue_adjustment_id = gmax.revenue_adjustment_id
                     /* USE DISTS THAT MATCH SIGN OF LINE FIRST,
                        THEN OTHERS (ZERO, NEGATIVE). */
              and    (SIGN(g.amount) = SIGN(tl.revenue_amount) *
                                   DECODE(g.account_class, 'REV', 1,
                                      DECODE(g.rec_offset_flag, 'Y', 1, -1)) *
                                   DECODE(l_phase, 1, 1, 2, -1, 0))
                      /* SKIP UPDATE IF SIGNS AR OPPOSITE */
              and   (sign(g.amount + t_round_amount(i)) =
                     sign(g.acctd_amount + t_round_acctd(i)) or
                     sign(g.amount + t_round_amount(i)) = 0)
              having
                     /* USE LINE WITH LARGEST ABS(AMOUNT) */
                     g.amount = decode(sign(g.amount), -1, MIN(gmax.amount),
                                                        1, MAX(gmax.amount),
                                                        0)
              group by g.amount
              /* END OF GL_DIST_ID SELECT */
              );
        ELSE
           /* 6325023 - added 4th phase to handle SLA issues where
              entered and acctd_amount dists have opposite signs */
           /* 6473284 - Added 5th phase to extend fix for 6325023 to
               cover some odd corner cases.

              In discussing these phases, we are now focused on
              the signs of the amount and acctd corrections only.  If
              Either is zero or they are same sign, then we update the
              existing dists (phase 1-3), however, if the corrections force
              the resulting amount or acctd to be a different sign, then
              phase 4 and 5 may each insert additional distributions.

              Phase 4 inserts a new distribution if the signs become
              opposites after rounding.  Phase 5 splits entered and
              acctd when the amounts themselves are opposite signs

              Based on bug 6473284, I'm going to coin a new phrase..
              cases where the rounding is pennies is now called
              near-zero rounding.  Phases 4 and 5 are specific to
              cases where the rounding amount is near-zero (pennies)
              and the effect of that rounding makes the distributions
              change signs unpredictably.   This is just FYI   */

           FORALL i in t_line_id.first .. t_line_id.last
            INSERT INTO RA_CUST_TRX_LINE_GL_DIST
              (CUST_TRX_LINE_GL_DIST_ID,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE,
               POSTING_CONTROL_ID,
               SET_OF_BOOKS_ID,
               CUSTOMER_TRX_LINE_ID,
               CUSTOMER_TRX_ID,
               ACCOUNT_CLASS,
               CODE_COMBINATION_ID,
               AMOUNT,
               ACCTD_AMOUNT,
               PERCENT,
               GL_DATE,
               ORIGINAL_GL_DATE,
               ACCOUNT_SET_FLAG,
               COMMENTS,
               ATTRIBUTE_CATEGORY,
               ATTRIBUTE1,
               ATTRIBUTE2,
               ATTRIBUTE3,
               ATTRIBUTE4,
               ATTRIBUTE5,
               ATTRIBUTE6,
               ATTRIBUTE7,
               ATTRIBUTE8,
               ATTRIBUTE9,
               ATTRIBUTE10,
               ATTRIBUTE11,
               ATTRIBUTE12,
               ATTRIBUTE13,
               ATTRIBUTE14,
               ATTRIBUTE15,
               LATEST_REC_FLAG,
               USSGL_TRANSACTION_CODE,
               REC_OFFSET_FLAG,
               USER_GENERATED_FLAG,
               ORG_ID,
               REQUEST_ID,
               CUST_TRX_LINE_SALESREP_ID,
               REVENUE_ADJUSTMENT_ID,
               EVENT_ID,
               ROUNDING_CORRECTION_FLAG
              )
        SELECT
            RA_CUST_TRX_LINE_GL_DIST_S.NEXTVAL,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            -3,
            SET_OF_BOOKS_ID,
            CUSTOMER_TRX_LINE_ID,
            CUSTOMER_TRX_ID,
            ACCOUNT_CLASS,
            CODE_COMBINATION_ID,
            DECODE(l_phase, 4, t_round_amount(i), 0),
            DECODE(l_phase, 4,
              DECODE(SIGN(t_round_amount(i)),0,t_round_acctd(i),
                   ABS(t_round_acctd(i)) * SIGN(t_round_amount(i))),
              t_round_acctd(i) * 2),
            DECODE(l_phase, 4, t_round_percent(i), 0),
            GL_DATE,
            ORIGINAL_GL_DATE,
            ACCOUNT_SET_FLAG,
            'PHASE ' || l_phase || ':  Rounding correction derived from ' ||
               cust_trx_line_gl_dist_id,
            ATTRIBUTE_CATEGORY,
            ATTRIBUTE1,
            ATTRIBUTE2,
            ATTRIBUTE3,
            ATTRIBUTE4,
            ATTRIBUTE5,
            ATTRIBUTE6,
            ATTRIBUTE7,
            ATTRIBUTE8,
            ATTRIBUTE9,
            ATTRIBUTE10,
            ATTRIBUTE11,
            ATTRIBUTE12,
            ATTRIBUTE13,
            ATTRIBUTE14,
            ATTRIBUTE15,
            LATEST_REC_FLAG,
            USSGL_TRANSACTION_CODE,
            REC_OFFSET_FLAG,
            USER_GENERATED_FLAG,
            ORG_ID,
            REQUEST_ID,
            CUST_TRX_LINE_SALESREP_ID,
            REVENUE_ADJUSTMENT_ID,
            EVENT_ID,
            'Y'
        FROM  RA_CUST_TRX_LINE_GL_DIST_ALL
        WHERE CUST_TRX_LINE_GL_DIST_ID IN (
              /* SELECT GL_DIST_ID FOR EACH LINE THAT
                 REQUIRES ROUNDING */
              select
                to_number(substr(max(
                       to_char(g.gl_date,'YYYYMMDD') ||
                       decode(sign(g.amount *
                                 DECODE(g.account_class, 'REV', 1,
                                   DECODE(g.rec_offset_flag, 'Y', 1, -1))),
                              sign(tl.revenue_amount), '3',
                           sign(tl.revenue_amount * -1), '2', '1') ||
                       ltrim(to_char(abs(g.amount),'099999999999999.00')) ||
                       ltrim(to_char(g.cust_trx_line_gl_dist_id,
                                          '0999999999999999999999'))),28))
              from   ra_cust_trx_line_gl_dist g,
                     ra_customer_trx_lines tl
              where  g.customer_trx_line_id = t_line_id(i)
              and    tl.customer_trx_line_id = g.customer_trx_line_id
              and    g.account_class = t_account_class(i)
              and    g.account_set_flag = 'N'
                     /* ONLY USE UNPOSTED ROWS */
              and    g.posting_control_id = -3
                     /* REVENUE ADJUSTMENTS DO NOT AFFECT REC OFFSET ROWS */
              and    g.rec_offset_flag IS NULL
                     /* ONLY ROUND RAM DISTRIBUTIONS */
              and    g.revenue_adjustment_id = t_rev_adj_id(i)
              /* END OF GL_DIST_ID SELECT */
              );

        END IF;

       l_rows_rounded_this_pass := 0;

       /* START - Cleanup loop */
       FOR upd in t_line_id.FIRST .. t_line_id.LAST LOOP

          IF(SQL%BULK_ROWCOUNT(upd) = 1)
          THEN

          /* This piece of code determines that 1 row was updated
             for each invoice line and account class.  Once the
             row is updated, we need to remove it from further
             consideration.  To do that, we change the line_id
             to line_id * -1 (a row that should never exist)
             and this prevents it from being processed in
             subsequent passes.

             Incidentally, I tried to just delete the
             processed rows - but this caused subsequent
             passes to fail with ORA errors due to missing
             plsql table rows.  The bulk update requires
             a continuous list in sequential order and, by deleting
             rows from the table, we cause the update to fail.
          */


              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_standard.debug('  Target: ' || t_line_id(upd) ||
                                '  ' || t_account_class(upd) ||
                                '  ' || t_round_amount(upd) ||
                                '  ' || t_round_acctd(upd) ||
                                ' ' || t_round_percent(upd) ||
                                ' ' || SQL%BULK_ROWCOUNT(upd));
              END IF;

              IF l_phase = 4
              THEN
                 /* extra checks to see if we need last phase */
                 IF t_round_amount(upd) = 0
                    OR  t_round_acctd(upd) = 0
                    OR  SIGN(t_round_amount(upd)) = SIGN(t_round_acctd(upd))
                 THEN
                    /* This phase inserted complete dists
                       so no need to insert another dist */
                    l_rows_rounded_this_pass := l_rows_rounded_this_pass + 1;
                    t_line_id(upd) := -1 * t_line_id(upd);
                 ELSE
                    /* Do not change the line_id or increment.. this
                        forces the last phase and an insert of
                        a dist with amount=0 and acctd_amount=<correction * 2>
                    */
                    NULL;
                 END IF;
              ELSE
                 /* previous behavior */
                 l_rows_rounded_this_pass := l_rows_rounded_this_pass + 1;
                 /* make line_id negative so it causes no further updates */
                 t_line_id(upd) := -1 * t_line_id(upd);
              END IF;

          END IF;

          IF(SQL%BULK_ROWCOUNT(upd) > 1)
          THEN
             /* Failure condition 1
                This section of code executes only when more than
                one line is updated for a given customer_trx_line_id
                and account_class.  That would mean that the rounding
                logic was unable to identify a single line for update
                and rounding would then raise an error to roll back
                any corrections or calculations for this transaction.

                Revenue recognition has been modified to roll back
                transactions that fail and to document the lines
                that have problems.  */

             IF PG_DEBUG in ('Y', 'C')
             THEN

                FOR err in t_line_id.FIRST .. t_line_id.LAST LOOP
                   arp_standard.debug(t_line_id(err)|| '  ' ||
                                      t_account_class(err) ||
                     '  ' || t_round_amount(err) ||
                     ' ' || t_round_acctd(err) || ' ' ||
                     t_round_percent(err) || '   ' || SQL%BULK_ROWCOUNT(err));
                END LOOP;

             END IF;

             RETURN(iFALSE);

          END IF;

       END LOOP; /* END - Cleanup loop */

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('    Rows rounded (this pass) : ' || l_rows_rounded_this_pass);
       END IF;

       l_rows_rounded := l_rows_rounded + l_rows_rounded_this_pass;

     END LOOP;  /* END - Main processing loop */

       IF (l_rows_needing_rounding <> l_rows_rounded) THEN

          /* Failure condition 2
             In this situation, the total number of distributions corrected
             does not match the number expected.  Because of condition 1
             handled above, this would only occur if we were unable to
             locate any rows to assess rounding corrections to for
             one or more invoice lines.  Such situations highlight
             shortcomings in this logic that must be investigated
             and corrected.
          */

          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('Mismatch between lines found and lines updated [see below]');
             arp_standard.debug('  Rows targeted: ' || l_rows_needing_rounding);
             arp_standard.debug('  Rows rounded : ' || l_rows_rounded);

             FOR err in t_line_id.FIRST .. t_line_id.LAST LOOP

                 arp_standard.debug(t_line_id(err) || '  ' || t_account_class(err) ||
                     '  ' || t_round_amount(err) || ' ' || t_round_acctd(err) || ' ' ||
                     t_round_percent(err) || '   ' || SQL%BULK_ROWCOUNT(err));

             END LOOP;

          END IF;

          RETURN(iFALSE);
       END IF;

       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug('Total number of rows updated:  ' || l_rows_rounded);
       END IF;

  /* MRC Processing */
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('doing rounding for MRC if necessary');
  END IF;

  /* This call to the MRC wrapper will eventually call a clone of this
     routine that was designed to round MRC gld table data.  The MRC
     call like the primary sob one utilizes the amounts and line_ids
     from ar_line_rev_adj_gt (global temporary table).

     Note that mrc_correct_rounding verifies that MRC is enabled before
     doing anything */
  ar_mrc_engine2.mrc_correct_rounding(
                   'CORRECT_REV_ADJ_BY_LINE',
                   NULL,    -- request_id
                   NULL,    -- customer_trx_id
                   NULL,    -- customer trx line id
                   NULL,
         	   NULL,    -- concat_segs
                   NULL,    -- balanced round_ccid
                   NULL,
                   NULL     -- period_set_name
                  );
  END IF;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_rev_adj_by_line()-');
  END IF;

  RETURN(iTRUE);
END correct_rev_adj_by_line;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 | correct_line_level_rounding                                             |
 |                                                                         |
 | DESCRIPTION                                                             |
 | This function calls functions to correct rounding errors in             |
 | ra_cust_trx_line_gl_dist.                                               |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_CUSTOMER_TRX_ID                                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   FALSE otherwise.                                                      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/
FUNCTION do_line_level_rounding(
                 P_REQUEST_ID            IN NUMBER,
                 P_CUSTOMER_TRX_ID       IN NUMBER,
                 P_CUSTOMER_TRX_LINE_ID  IN NUMBER,
                 P_ROWS_PROCESSED        IN OUT NOCOPY NUMBER,
                 P_ERROR_MESSAGE            OUT NOCOPY VARCHAR2,
                 P_BASE_PRECISION        IN NUMBER,
                 P_BASE_MIN_ACCOUNTABLE_UNIT IN NUMBER,
                 P_PERIOD_SET_NAME       IN OUT NOCOPY VARCHAR2,
                 P_CHECK_RULES_FLAG      IN VARCHAR2,
                 P_TRX_CLASS_TO_PROCESS  IN VARCHAR2,
                 P_FIX_REC_OFFSET        IN VARCHAR2 DEFAULT 'Y')
                 RETURN NUMBER IS

begin

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.do_line_level_rounding()+ ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

    /*--------------------------------------------------------------+
     |  Correct each type of rounding error. Each function corrects |
     |  a different kind of error.                                  |
     +--------------------------------------------------------------*/

    /*--------------------------------------------------------------+
     |  Correct each type of rounding error. Each function corrects |
     |  a different kind of error.                                  |
     +--------------------------------------------------------------*/

   if ( correct_receivables_records( P_REQUEST_ID,
                                     P_CUSTOMER_TRX_ID,
                                     P_CUSTOMER_TRX_LINE_ID,
                                     P_ROWS_PROCESSED,
                                     P_ERROR_MESSAGE,
                                     P_BASE_PRECISION,
                                     P_BASE_MIN_ACCOUNTABLE_UNIT,
                                     P_TRX_CLASS_TO_PROCESS) = iFALSE)
   then return(iFALSE);
   end If;


   if ( correct_nonrule_line_records( P_REQUEST_ID,
                                      P_CUSTOMER_TRX_ID,
                                      P_CUSTOMER_TRX_LINE_ID,
                                      P_ROWS_PROCESSED,
                                      P_ERROR_MESSAGE,
                                      P_BASE_PRECISION,
                                      P_BASE_MIN_ACCOUNTABLE_UNIT,
                                      P_TRX_CLASS_TO_PROCESS) = iFALSE)
   then return(iFALSE);
   end If;

   if ( correct_rule_records_by_line( P_REQUEST_ID,
                              P_CUSTOMER_TRX_ID,
                              P_ROWS_PROCESSED,
                              P_ERROR_MESSAGE,
                              P_BASE_PRECISION,
                              P_BASE_MIN_ACCOUNTABLE_UNIT,
                              P_TRX_CLASS_TO_PROCESS,
                              P_CHECK_RULES_FLAG,
                              P_PERIOD_SET_NAME,
                              P_FIX_REC_OFFSET) = iFALSE)
   then return(iFALSE);
   end If;

   correct_suspense(p_customer_trx_id);

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.do_line_level_rounding()- ' ||
                      to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   return(iTRUE);

end do_line_level_rounding;


/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 | replace_balancing_segment                                               |
 |                                                                         |
 | DESCRIPTION                                                             |
 |                                                                         |
 | This function accepts the REC and the ROUND code_combination_id,        |
 | replaces balancing segement of the ROUND accounting combination with    |
 | the REC segement and returns the new code_combination_id.               |
 |                                                                         |
 | REQUIRES                                                                |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   FALSE otherwise.                                                      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |      Satheesh Nambiar - 01/18/00                                        |
 |                         Bug 1152919. Added error_message as out NOCOPY         |
 |                         parameter to this private function              |
 +-------------------------------------------------------------------------*/

FUNCTION replace_balancing_segment( original_ccid IN NUMBER,
                                    balancing_ccid IN NUMBER,
                                    return_ccid   OUT NOCOPY NUMBER,
                                    concat_segs   OUT NOCOPY VARCHAR2,
                                    error_message OUT NOCOPY VARCHAR2)
RETURN NUMBER IS

--concat_segs varchar2(240);
concat_ids varchar2(2000);
concat_descrs varchar2(2000);

begin

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.replace_balancing_segment()+ ' ||
                      to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   if not AR_FLEXBUILDER_WF_PKG.SUBSTITUTE_BALANCING_SEGMENT(
                          arp_global.chart_of_accounts_id,
                          original_ccid,
                          balancing_ccid,
                          return_ccid,
                          concat_segs,
                          concat_ids,
                          concat_descrs,
                          error_message )
   then

      IF PG_DEBUG in ('Y', 'C') THEN
         arp_standard.debug('EXCEPTION:  substitute_balancing_segment failed ' ||
                           return_ccid);
      END IF;
      return(iFALSE);
   end if;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug(' original_ccid: ' || original_ccid ||
                            ' balancing_ccid: ' || balancing_ccid ||
                            ' return_ccid: ' || return_ccid ||
                            ' concat_segs: ' || concat_segs
                      );
      arp_standard.debug( 'arp_rounding.replace_balancing_segment()- ' ||
                      to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   return(iTRUE);

end replace_balancing_segment;

/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 | correct_header_level_rounding                                           |
 |                                                                         |
 | DESCRIPTION                                                             |
 | This function calls functions to correct rounding errors in             |
 | ra_cust_trx_line_gl_dist.                                               |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_CUSTOMER_TRX_ID                                                     |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   FALSE otherwise.                                                      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/
FUNCTION correct_header_level_rounding(
                 P_REQUEST_ID IN NUMBER,
                 P_CUSTOMER_TRX_ID           IN NUMBER,
                 P_CUSTOMER_TRX_LINE_ID      IN NUMBER,
                 P_ROWS_PROCESSED            IN OUT NOCOPY NUMBER,
                 P_ERROR_MESSAGE            OUT NOCOPY VARCHAR2,
                 P_BASE_PRECISION            IN NUMBER,
                 P_BASE_MIN_ACCOUNTABLE_UNIT IN NUMBER,
                 P_PERIOD_SET_NAME           IN OUT NOCOPY VARCHAR2,
                 P_CHECK_RULES_FLAG          IN VARCHAR2,
                 P_TRX_CLASS_TO_PROCESS      IN VARCHAR2,
                 P_REC_CODE_COMBINATION_ID   IN NUMBER,
                 P_TRX_HEADER_ROUND_CCID     IN NUMBER,
                 P_FIX_REC_OFFSET            IN VARCHAR2 DEFAULT 'Y')
RETURN NUMBER IS

balanced_round_ccid number;
concat_segs varchar2(240);

begin

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('arp_rounding.correct_header_level_rounding()+ ' ||
                     to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
  END IF;

    /*--------------------------------------------------------------+
     |  Correct each type of rounding error. Each function corrects |
     |  a different kind of error.                                  |
     +--------------------------------------------------------------*/

   if ( correct_receivables_header( P_REQUEST_ID,
                                    P_CUSTOMER_TRX_ID,
                                    P_CUSTOMER_TRX_LINE_ID,
                                    P_ROWS_PROCESSED,
                                    P_ERROR_MESSAGE,
                                    P_BASE_PRECISION,
                                    P_BASE_MIN_ACCOUNTABLE_UNIT,
                                    P_TRX_CLASS_TO_PROCESS) = iFALSE)
   then return(iFALSE);
   end If;


   if ( correct_nonrule_line_records( P_REQUEST_ID,
                                      P_CUSTOMER_TRX_ID,
                                      P_CUSTOMER_TRX_LINE_ID,
                                      P_ROWS_PROCESSED,
                                      P_ERROR_MESSAGE,
                                      P_BASE_PRECISION,
                                      P_BASE_MIN_ACCOUNTABLE_UNIT,
                                      P_TRX_CLASS_TO_PROCESS) = iFALSE)
   then return(iFALSE);
   end If;

   if ( correct_rule_records_by_line( P_REQUEST_ID,
                              P_CUSTOMER_TRX_ID,
                              P_ROWS_PROCESSED,
                              P_ERROR_MESSAGE,
                              P_BASE_PRECISION,
                              P_BASE_MIN_ACCOUNTABLE_UNIT,
                              P_TRX_CLASS_TO_PROCESS,
                              P_CHECK_RULES_FLAG,
                              P_PERIOD_SET_NAME,
                              P_FIX_REC_OFFSET) = iFALSE)
   then return(iFALSE);
   end If;

   --Bug 954681 and 1158340: Call the replace_balancing_segment routine
   --only if the REC ccid is valid.
  IF P_REC_CODE_COMBINATION_ID  > -1  THEN

   if ( replace_balancing_segment( P_TRX_HEADER_ROUND_CCID,
                                   P_REC_CODE_COMBINATION_ID,
                                   balanced_round_ccid,
                                   CONCAT_SEGS ,
                                   P_ERROR_MESSAGE) = iFALSE)
   then
    return(iFALSE);
   end If;
  END IF;

   /*--------------------------------------------------------------+
    |  If the balanced_round_ccid is returned as -1 then           |
    |  it gets the value of p_trx_header_round_ccid which is valid |
    |  code combination id as opposed to -1                        |
    +--------------------------------------------------------------*/
   /* Bug 5707676. if P_REC_CODE_COMBINATION_ID is -1 then balanced_round_ccid will NOT be initialized. So put NVL in if clause */

   if ( nvl(balanced_round_ccid,-1) = -1)

   then
        balanced_round_ccid := P_TRX_HEADER_ROUND_CCID;
   end if;

   if ( correct_round_records( P_REQUEST_ID,
                               P_CUSTOMER_TRX_ID,
                               P_CUSTOMER_TRX_LINE_ID,
                               P_ROWS_PROCESSED,
                               P_ERROR_MESSAGE,
                               P_BASE_PRECISION,
                               P_BASE_MIN_ACCOUNTABLE_UNIT,
                               P_TRX_CLASS_TO_PROCESS,
                               CONCAT_SEGS,
                               BALANCED_ROUND_CCID) = iFALSE)
   then return(iFALSE);
   end If;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.correct_header_level_rounding()- ' ||
                      to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   return(iTRUE);

end correct_header_level_rounding;

PROCEDURE get_select_column_values(
        P_SELECT_SQL_C   IN INTEGER,
        P_SELECT_REC IN OUT NOCOPY SELECT_REC_TYPE ) IS
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rounding.get_select_column_values()+' );
    END IF;

    dbms_sql.column_value( p_select_sql_c, 1,
                           p_select_rec.rec_customer_trx_id);
    dbms_sql.column_value( p_select_sql_c, 2,
                           p_select_rec.rec_code_combination_id);
    dbms_sql.column_value( p_select_sql_c, 3,
                           p_select_rec.round_customer_trx_id);

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rounding.get_select_column_values()-' );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('EXCEPTION: arp_rounding.get_select_column_values()');
        END IF;
        RAISE;
END get_select_column_values;

PROCEDURE dump_select_rec( P_SELECT_REC IN SELECT_REC_TYPE ) IS
BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rounding.dump_select_rec()+' );
       arp_standard.debug('  Dumping select record: ');
       arp_standard.debug('  rec_customer_trx_id=' ||
                 p_select_rec.rec_customer_trx_id);
       arp_standard.debug('  rec_code_combination_id=' ||
                 p_select_rec.rec_code_combination_id);
       arp_standard.debug('  round_customer_trx_id=' ||
                 p_select_rec.round_customer_trx_id);
       arp_standard.debug( 'arp_rounding.dump_select_rec()-' );
    END IF;

EXCEPTION
    WHEN OTHERS THEN
       IF PG_DEBUG in ('Y', 'C') THEN
          arp_standard.debug( 'EXCEPTION: arp_rounding.dump_select_rec()' );
       END IF;
        RAISE;
END dump_select_rec;


PROCEDURE define_columns( P_SELECT_SQL_C IN INTEGER,
                          P_SELECT_REC IN SELECT_REC_TYPE) IS
BEGIN

    arp_standard.debug( 'arp_rounding.define_columns()+' );

    ------------------------------------------------------------
    -- Define columns
    ------------------------------------------------------------
        arp_standard.debug( '  Defining columns for select_sql_c');

        dbms_sql.define_column( p_select_sql_c, 1,
                                p_select_rec.rec_customer_trx_id );
        dbms_sql.define_column( p_select_sql_c, 2,
                                p_select_rec.rec_code_combination_id );
        dbms_sql.define_column( p_select_sql_c, 3,
                                p_select_rec.round_customer_trx_id );

    arp_standard.debug( 'arp_rounding.define_columns()-' );

EXCEPTION
   WHEN OTHERS THEN
        arp_standard.debug( 'EXCEPTION: Error defining columns for select_sql_c' );
        RAISE;
END;


PROCEDURE build_select_sql(
                           P_REQUEST_ID IN INTEGER,
                           P_CUSTOMER_TRX_ID IN INTEGER,
                           P_SELECT_SQL_C IN OUT NOCOPY INTEGER  ) IS

    l_select_sql   VARCHAR2(1000);
    l_where_pred   VARCHAR2(500);

BEGIN

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rounding.build_select_sql()+' );
    END IF;

    ------------------------------------------------
    -- Construct where predicate
    ------------------------------------------------

    IF ( p_customer_trx_id IS NOT NULL ) THEN
        ----------------------------------------------------
        -- Passed customer_trx_id
        ----------------------------------------------------

        l_where_pred :=
'AND rec.customer_trx_id = :p_customer_trx_id ';
    ELSE

        l_where_pred :=
'AND rec.request_id = :p_request_id ';

    END IF;

    l_select_sql :=
'select rec.customer_trx_id,
rec.code_combination_id,
round.customer_trx_id
from
ra_cust_trx_line_gl_dist rec,
ra_cust_trx_line_gl_dist round
where
rec.customer_trx_id = round.customer_trx_id(+)
and    rec.account_set_flag = round.account_set_flag(+)' ||
l_where_pred  ||
'and    rec.account_class = ''REC''
and    rec.latest_rec_flag = ''Y''
and    round.account_class(+) = ''ROUND''';

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('select_sql =  ' ||
                       l_select_sql);
   END IF;

    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------

   BEGIN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug('Parsing select stmt');
        END IF;

        p_select_sql_c := dbms_sql.open_cursor;
        dbms_sql.parse( p_select_sql_c, l_select_sql, dbms_sql.v7 );

        IF ( p_customer_trx_id IS NOT NULL ) THEN
            ----------------------------------------------------
            -- Passed customer_trx_id
            ----------------------------------------------------
            dbms_sql.bind_variable(p_select_sql_c, ':p_customer_trx_id', p_customer_trx_id);

        ELSE

            dbms_sql.bind_variable(p_select_sql_c, ':p_request_id', p_request_id);

        END IF;

    EXCEPTION
      WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_standard.debug('build_select_sql: ' ||  'EXCEPTION: Error parsing select stmt' );
          END IF;
          RAISE;
    END;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug( 'arp_rounding.build_select_sql()-' );
    END IF;


EXCEPTION
    WHEN OTHERS THEN
        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'EXCEPTION: arp_rounding.build_select_sql()' );
        END IF;

        RAISE;
END build_select_sql;
/*-------------------------------------------------------------------------+
 | PRIVATE FUNCTION                                                        |
 | do_header_level_rounding                                                |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function inserts a record of account_class = ROUND into          |
 |   ra_cust_trx_line_gl_dist table. If the transaction was created before |
 |   setting the header level rounding option On then this function will   |
 |   insert the round record only if there is no activity on it otherwise  |
 |   it will do the release 10 rounding (do_line_level_rounding).          |
 |   Also if arp_rounding is called from revenue recognition program then  |
 |   this function will not insert the ROUND record but revenue recognition|
 |   will insert it.                                                       |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_REQUEST_ID, P_CUSTOMER_TRX_ID                                       |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   FALSE otherwise.                                                      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |                                                                         |
 +-------------------------------------------------------------------------*/

FUNCTION do_header_level_rounding
                 ( P_REQUEST_ID                    IN NUMBER,
                   P_CUSTOMER_TRX_ID               IN NUMBER,
                   P_CUSTOMER_TRX_LINE_ID          IN NUMBER,
                   P_ROWS_PROCESSED            IN OUT NOCOPY NUMBER,
                   P_ERROR_MESSAGE                OUT NOCOPY VARCHAR2,
                   P_BASE_PRECISION                IN NUMBER,
                   P_BASE_MIN_ACCOUNTABLE_UNIT     IN VARCHAR2,
                   P_TRX_CLASS_TO_PROCESS          IN VARCHAR2,
                   P_PERIOD_SET_NAME           IN OUT NOCOPY VARCHAR2,
                   P_CHECK_RULES_FLAG              IN VARCHAR2,
                   P_TRX_HEADER_LEVEL_ROUNDING     IN VARCHAR2,
                   P_ACTIVITY_FLAG                 IN VARCHAR2,
                   P_TRX_HEADER_ROUND_CCID         IN NUMBER,
                   P_FIX_REC_OFFSET                IN VARCHAR2 DEFAULT 'Y'
                 )
RETURN NUMBER IS

  l_select_rec              select_rec_type;
  l_null_rec       CONSTANT select_rec_type := l_select_rec;
  l_ignore                  INTEGER;
  l_request_id              INTEGER;
  l_customer_trx_id         INTEGER;

begin

 /* bug 912501 : Added 'G' for the possible values of p_activity_flag */
   if (p_activity_flag = 'Y' OR p_activity_flag = 'G') OR (p_check_rules_flag = 'Y' )
   then
      NULL;
   else
      if ( insert_round_records( P_REQUEST_ID,
                                 P_CUSTOMER_TRX_ID,
                                 P_ROWS_PROCESSED,
                                 P_ERROR_MESSAGE,
                                 P_BASE_PRECISION,
                                 P_BASE_MIN_ACCOUNTABLE_UNIT,
                                 P_TRX_CLASS_TO_PROCESS,
                                 P_TRX_HEADER_ROUND_CCID) = iFALSE)
      then return(iFALSE);
      end if;
   end if;


   -----------------------------------------------------------------------
   -- Create dynamic sql
   -----------------------------------------------------------------------
   IF PG_DEBUG in ('Y', 'C') THEN
     arp_standard.debug('  Creating dynamic sql');
  END IF;

   build_select_sql( P_REQUEST_ID,
                     P_CUSTOMER_TRX_ID,
                     SELECT_SQL_C);

   -----------------------------------------------------------
   -- Define columns
   -----------------------------------------------------------
   define_columns( select_sql_c, l_select_rec );

   ---------------------------------------------------------------
   -- Execute sql
   ---------------------------------------------------------------
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('  Executing select sql' );
   END IF;

   BEGIN
       l_ignore := dbms_sql.execute( select_sql_c );

   EXCEPTION
      WHEN OTHERS THEN
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('EXCEPTION: Error executing select sql' );
            END IF;
            RAISE;
   END;

   --------------------------------------------------------------
   -- Fetch rows
   --------------------------------------------------------------
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug('  Fetching select stmt');
   END IF;

   begin
      loop
         if (dbms_sql.fetch_rows( select_sql_c ) > 0)
         then

            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug('  fetched a row' );
            END IF;
            l_select_rec := l_null_rec;
            ------------------------------------------------------
            -- Get column values
            ------------------------------------------------------
            get_select_column_values( select_sql_c, l_select_rec );

            dump_select_rec( l_select_rec );
         else
            IF PG_DEBUG in ('Y', 'C') THEN
               arp_standard.debug(   '  Done fetching');
            END IF;
            EXIT;
         end if;

       -- further processing.

         l_customer_trx_id := l_select_rec.rec_customer_trx_id;

         IF PG_DEBUG in ('Y', 'C') THEN
            arp_standard.debug(  'rec_customer_trx_id: '||  l_customer_trx_id);
         END IF;

         if (l_select_rec.round_customer_trx_id is null)
         then
            -- ROUND record does not exist for this transaction
            -- This means the transaction was created before
            -- setting TRX_HEADER_LEVEL_ROUNDING ON
            -- Round the transaction with release 10 method

            if ( do_line_level_rounding( l_REQUEST_ID,
                                         l_CUSTOMER_TRX_ID,
                                         P_CUSTOMER_TRX_LINE_ID,
                                         P_ROWS_PROCESSED,
                                         P_ERROR_MESSAGE,
                                         P_BASE_PRECISION,
                                         P_BASE_MIN_ACCOUNTABLE_UNIT,
                                         P_PERIOD_SET_NAME,
                                         P_CHECK_RULES_FLAG,
                                         P_TRX_CLASS_TO_PROCESS,
                                         P_FIX_REC_OFFSET) = iFALSE)
            then return(iFALSE);
            end If;
         else
            if ( correct_header_level_rounding( l_REQUEST_ID,
                                                l_CUSTOMER_TRX_ID,
                                                P_CUSTOMER_TRX_LINE_ID,
                                                P_ROWS_PROCESSED,
                                                P_ERROR_MESSAGE,
                                                P_BASE_PRECISION,
                                                P_BASE_MIN_ACCOUNTABLE_UNIT,
                                                P_PERIOD_SET_NAME,
                                                P_CHECK_RULES_FLAG,
                                                P_TRX_CLASS_TO_PROCESS,
                                        l_select_rec.rec_code_combination_id,
                                        P_TRX_HEADER_ROUND_CCID) = iFALSE)
            then return(iFALSE);
            end If;
         end if;
      end loop;
--Bug 1777081:Close the cursor to avoid the maximum cursor exceeding error.

      dbms_sql.close_cursor(select_sql_c);
   end;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.do_header_level_rounding()- ' ||
                      to_char(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   return(iTRUE);

end do_header_level_rounding;


/*-------------------------------------------------------------------------+
 | PUBLIC FUNCTION                                                         |
 |   correct_dist_rounding_errors()                                        |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects all rounding errors in the                     |
 |   ra_cust_trx_line_gl_dist table.                                       |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_REQUEST_ID, P_CUSTOMER_TRX_ID or P_CUSTOMER_TRX_LINE_ID             |
 |   If header level rounding is enforced then requires either of          |
 |   P_REQUEST_ID, P_CUSTOMER_TRX_ID.                                      |
 |                                                                         |
 | RETURNS                                                                 |
 |   TRUE  if no errors occur                                              |
 |   FALSE otherwise.                                                      |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   03-AUG-2002  MRAYMOND   Added p_fix_rec_offset parameter to indicate
 |                            when to run the fix logic.
 +-------------------------------------------------------------------------*/

FUNCTION correct_dist_rounding_errors
                 ( P_REQUEST_ID                    IN NUMBER,
                   P_CUSTOMER_TRX_ID               IN NUMBER,
                   P_CUSTOMER_TRX_LINE_ID          IN NUMBER,
                   P_ROWS_PROCESSED                IN OUT NOCOPY NUMBER,
                   P_ERROR_MESSAGE                 OUT NOCOPY VARCHAR2,
                   P_BASE_PRECISION                IN NUMBER,
                   P_BASE_MIN_ACCOUNTABLE_UNIT     IN VARCHAR2,
                   P_TRX_CLASS_TO_PROCESS          IN VARCHAR2  DEFAULT 'ALL',
                   P_CHECK_RULES_FLAG              IN VARCHAR2  DEFAULT 'N',
                   P_DEBUG_MODE                    IN VARCHAR2,
                   P_TRX_HEADER_LEVEL_ROUNDING     IN VARCHAR2  DEFAULT 'N',
                   P_ACTIVITY_FLAG                 IN VARCHAR2  DEFAULT 'N',
                   P_FIX_REC_OFFSET                IN VARCHAR2  DEFAULT 'Y'
                 )
	RETURN NUMBER IS

  base_precision            NUMBER;
  base_min_accountable_unit NUMBER;
  trx_class_to_process      VARCHAR2(15);
  check_rules_flag          VARCHAR2(2);
  period_set_name           VARCHAR2(15);
  trx_header_round_ccid     number;
  l_select_rec              select_rec_type;
  l_null_rec       CONSTANT select_rec_type := l_select_rec;
  l_ignore                  INTEGER;
  activity_flag             VARCHAR2(1);


BEGIN

  /*-------------------------------------------------------+
   |  Set a savepoint to rollback to if the function fails |
   +-------------------------------------------------------*/

   SAVEPOINT ARPLBCRE_1;

   IF ( do_setup(
                 P_REQUEST_ID,
                 P_CUSTOMER_TRX_ID,
                 P_CUSTOMER_TRX_LINE_ID,
                 P_BASE_PRECISION,
                 P_BASE_MIN_ACCOUNTABLE_UNIT,
                 P_TRX_CLASS_TO_PROCESS,
                 P_CHECK_RULES_FLAG,
                 P_DEBUG_MODE,
                 BASE_PRECISION,
                 BASE_MIN_ACCOUNTABLE_UNIT,
                 TRX_CLASS_TO_PROCESS,
                 CHECK_RULES_FLAG,
                 PERIOD_SET_NAME,
                 P_ROWS_PROCESSED,
                 P_ERROR_MESSAGE,
                 P_TRX_HEADER_LEVEL_ROUNDING,
                 P_ACTIVITY_FLAG,
                 ACTIVITY_FLAG,
                 TRX_HEADER_ROUND_CCID
               ) = iFALSE )
   THEN
       RETURN( iFALSE );
   END IF;


   /*----------------------------------------------+
    |  Print out NOCOPY the parameters in debug mode only |
    +----------------------------------------------*/

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.correct_dist_rounding_errors()+ ' ||
                      TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
      arp_standard.debug('  Request_id: ' || p_request_id ||
                     ' ctid: '|| p_customer_trx_id ||'  ctlid: '||
                     p_customer_trx_line_id || '  class: ' ||
                     trx_class_to_process || '  Rules: '||
                     check_rules_flag);
      arp_standard.debug(' Precision: ' || base_precision ||
                     '  MAU: ' || base_min_accountable_unit ||
                     '  Period Set: '|| period_set_name);
      arp_standard.debug('p_trx_header_level_rounding: ' ||
                     p_trx_header_level_rounding || ' p_activity_flag:' ||
                     p_activity_flag || ' trx_header_round_ccid:' ||
                     trx_header_round_ccid);
   END IF;

    /*--------------------------------------------------------------+
     |  Correct each type of rounding error. Each function corrects |
     |  a different kind of error.                                  |
     +--------------------------------------------------------------*/


   if (p_trx_header_level_rounding = 'Y')
   then
      if ( do_header_level_rounding( P_REQUEST_ID,
                                     P_CUSTOMER_TRX_ID,
                                     P_CUSTOMER_TRX_LINE_ID,
                                     P_ROWS_PROCESSED,
                                     P_ERROR_MESSAGE,
                                     BASE_PRECISION,
                                     BASE_MIN_ACCOUNTABLE_UNIT,
                                     TRX_CLASS_TO_PROCESS,
                                     PERIOD_SET_NAME,
                                     CHECK_RULES_FLAG,
                                     P_TRX_HEADER_LEVEL_ROUNDING,
                                     ACTIVITY_FLAG,
                                     TRX_HEADER_ROUND_CCID,
                                     P_FIX_REC_OFFSET) = iFALSE)
      then return(iFALSE);
      end if;
   else
      /* Do the release 10 rounding */
      if ( do_line_level_rounding( P_REQUEST_ID,
                                   P_CUSTOMER_TRX_ID,
                                   P_CUSTOMER_TRX_LINE_ID,
                                   P_ROWS_PROCESSED,
                                   P_ERROR_MESSAGE,
                                   BASE_PRECISION,
                                   BASE_MIN_ACCOUNTABLE_UNIT,
                                   PERIOD_SET_NAME,
                                   CHECK_RULES_FLAG,
                                   TRX_CLASS_TO_PROCESS,
                                   P_FIX_REC_OFFSET) = iFALSE)
      then return(iFALSE);
      end if;
   end if;

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_standard.debug( 'arp_rounding.correct_dist_rounding_errors()- ' ||
                      TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
   END IF;

   RETURN( iTRUE );

  /*---------------------------------------------------------------------+
   |  If any of the functions encounter an ORACLE error, that error is   |
   |  trapped here. The message is copied into the error_message         |
   |  parameter, and the function rolls back and returns FALSE.          |
   +---------------------------------------------------------------------*/

EXCEPTION
   WHEN OTHERS THEN
        p_error_message := SQLERRM;

        ROLLBACK TO SAVEPOINT ARPLBCRE_1;

        IF PG_DEBUG in ('Y', 'C') THEN
           arp_standard.debug( 'arp_rounding.correct_dist_rounding_errors()+ ' ||
                         TO_CHAR(sysdate, 'DD-MON-YY HH:MI:SS'));
        END IF;

        RETURN( iFALSE );


END correct_dist_rounding_errors;

/*-------------------------------------------------------------------------+
 | PUBLIC PROCEDURE                                                        |
 |   correct_scredit_rounding_errs()                                       |
 |                                                                         |
 | DESCRIPTION                                                             |
 |   This function corrects all rounding errors in the                     |
 |   ra_cust_trx_line_salesreps table.                                     |
 |                                                                         |
 | REQUIRES                                                                |
 |   P_CUSTOMER_TRX_ID							   |
 |                                                                         |
 | NOTES                                                                   |
 |                                                                         |
 | EXAMPLE                                                                 |
 |                                                                         |
 | MODIFICATION HISTORY                                                    |
 |   30-AUG-95  Charlie Tomberg       Created                              |
 |   03-OCT-03  M Raymond      Bug 3155664 - commented out nonrev scredit
 |                             rounding logic (it was ineffective)
 |                             and modified rev scredit logic to avoid
 |                             ORA-979 errors.
 +-------------------------------------------------------------------------*/

PROCEDURE correct_scredit_rounding_errs( p_customer_trx_id   IN NUMBER,
                                         p_rows_processed   OUT NOCOPY NUMBER
                                         ) IS

  l_count number;

BEGIN

  /*-------------------------------------------------------+
   |  Set a savepoint to rollback to if the function fails |
   +-------------------------------------------------------*/

   SAVEPOINT ARPLBCRE_2;

   arp_util.print_fcn_label( 'arp_rounding.correct_scredit_rounding_errs()+ ');

 /*-------------------------------------------------------------------------+
  |  Correct errors in the revenue_amount_split and revenue_percent_split   |
  |  columns:                                                               |
  |                                                                         |
  |    - Insure that the sum of the revenue percents equals 100 if the sum  |
  |      of the revenue amounts equals the line amount.                     |
  |    - Insure that the sum of revenue amounts equals the line amount if   |
  |      the sum of the revenue percents equals 100.                        |
  +-------------------------------------------------------------------------*/

   UPDATE ra_cust_trx_line_salesreps ctls
   SET     (
              ctls.revenue_amount_split,
              ctls.revenue_percent_split
           ) =
           (
             SELECT ctls.revenue_amount_split +
                    (
                       ctl1.extended_amount -
                       SUM(
                             NVL(ctls1.revenue_amount_split, 0)
                          )
                    ),
                    ctls.revenue_percent_split +
                    (
                       100 -
                       SUM(
                             NVL(ctls1.revenue_percent_split, 0)
                          )
                    )
             FROM     ra_customer_trx_lines ctl1,
                      ra_cust_trx_line_salesreps ctls1
             WHERE    ctl1.customer_trx_line_id = ctls1.customer_trx_line_id
             AND      ctls.customer_trx_line_id = ctls1.customer_trx_line_id
             GROUP BY ctls1.customer_trx_line_id,
                      ctl1.extended_amount,
                      ctls.revenue_amount_split,
                      ctls.revenue_percent_split
           )
   WHERE   ctls.cust_trx_line_salesrep_id in
           (
             SELECT   MIN(cust_trx_line_salesrep_id)
             FROM     ra_cust_trx_line_salesreps ctls,
                      ra_customer_trx_lines ctl
             WHERE    ctl.customer_trx_line_id = ctls.customer_trx_line_id
             AND      ctl.customer_trx_id      = p_customer_trx_id
             GROUP BY ctls.customer_trx_line_id,
                      ctl.extended_amount
             HAVING   (
                       -- Check Revenue Amount Split
                        ctl.extended_amount <> SUM(
                                             NVL(ctls.revenue_amount_split, 0)
                                                  )  AND
                        100 = SUM(
                                    NVL(ctls.revenue_percent_split, 0)
                                  )
                      )
                    OR
                      -- Check Revenue Percent Split
                      (
                         100   <> SUM(
                                       NVL(ctls.revenue_percent_split, 0)
                                     ) AND
                         ctl.extended_amount = SUM(
                                            NVL(ctls.revenue_amount_split, 0)
                                                  )
                      )
           );

   l_count := sql%rowcount;

  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('Salescredit Revenue Errors Corrected    : ' || l_count);
  END IF;

   p_rows_processed := l_count;

   arp_util.print_fcn_label( 'arp_rounding.correct_scredit_rounding_errs()- ');

EXCEPTION
   WHEN OTHERS THEN

    ROLLBACK TO SAVEPOINT ARPLBCRE_2;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('EXCEPTION:  arp_rounding.correct_scredit_rounding_errs()');
       arp_util.debug('p_customer_trx_id = ' || p_customer_trx_id);
    END IF;


    RAISE;

end correct_scredit_rounding_errs;

BEGIN
   /* 7039838 - Detect if this is an autoinvoice session.  If so,
      set g_autoinv to TRUE, otherwise FALSE.  This will
      impact the content of several sqls in this package
      for performance tuning.  */
   BEGIN
      SELECT req.request_id
      INTO   g_autoinv_request_id
      FROM  fnd_concurrent_programs prog,
            fnd_concurrent_requests req
      WHERE req.request_id = FND_GLOBAL.CONC_REQUEST_ID
      AND   req.concurrent_program_id = prog.concurrent_program_id
      AND   prog.application_id = 222
      AND   prog.concurrent_program_name = 'RAXTRX';

      IF g_autoinv_request_id is not NULL
      THEN
         g_autoinv := TRUE;
      ELSE
         /* Dummy condition, never gets executed */
         g_autoinv := FALSE;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         g_autoinv := FALSE;
   END;
END ARP_ROUNDING;

/
