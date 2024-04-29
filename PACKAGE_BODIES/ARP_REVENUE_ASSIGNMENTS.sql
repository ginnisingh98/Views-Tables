--------------------------------------------------------
--  DDL for Package Body ARP_REVENUE_ASSIGNMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_REVENUE_ASSIGNMENTS" AS
/*$Header: ARREVUB.pls 120.4.12010000.2 2009/02/24 19:50:58 mraymond ship $*/

PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'Y');

/* ==================================================================================
 | PROCEDURE build_for_credit
 |
 | DESCRIPTION
 |   This procedure populates ar_revenue_assignments_gt (a global temporary
 |   table) with rows from ar_revenue_assignments (the view).  In 11i apps,
 |   the CBO seems to have a lot of trouble with any sql containing this
 |   view.  So this is an effort to offload that work to a separate
 |   sql step.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_session_id         IN      number
 |      p_period_set_name    IN      Period set name
 |      p_request_id         IN      request_id (if coming from RAXTRX)
 |      p_customer_trx_id    IN      customer_trx_id
 |      p_customer_trx_line_id IN    customer_trx_line_id
 |
 | DEV NOTE:  customer_trx_line_id in the global temporary table actually
 |  refer to the invoice line_id (previous_customer_trx_line_id).  That is because
 |  the view expected to join based on previous_customer_trx_line_id.
 |
 |  session_id is an integer number that is assigned by the calling program each time
 |  it calls this package.  It can be any number as long as it is unique within
 |  each sql session.
 |
 { 18-SEP-2005  M Raymond    4602892 Added 'distinct' to inserts to prevent the
 |                           creation of multiple rows in _GT table and, ultimately
 |                           the cartesian insert of extra gl_dist rows.
 *===================================================================================*/

PROCEDURE build_for_credit(
      p_session_id         IN     number,
      p_period_set_name    IN     gl_periods.period_set_name%TYPE,
      p_use_inv_acctg      IN     varchar2,
      p_request_id         IN     ra_customer_trx_all.request_id%TYPE,
      p_customer_trx_id    IN     ra_customer_trx_all.customer_trx_id%TYPE,
      p_customer_trx_line_id  IN  ra_customer_trx_lines_all.customer_trx_line_id%TYPE)
   IS

BEGIN
   IF PG_DEBUG IN ('Y','C')
   THEN
      arp_standard.debug('arp_revenue_assignments.build_for_credit()+');
      arp_standard.debug('  p_session_id = ' || p_session_id);
      arp_standard.debug('  p_period_set_name = ' || p_period_set_name);
      arp_standard.debug('  p_use_inv_acctg = ' || p_use_inv_acctg);
      arp_standard.debug('  p_request_id = ' || p_request_id);
      arp_standard.debug('  p_customer_trx_id = ' || p_customer_trx_id);
      arp_standard.debug('  p_customer_trx_line_id = ' || p_customer_trx_line_id);
   END IF;

   IF (p_request_id is not null)
   THEN
     IF PG_DEBUG IN ('Y','C')
     THEN
        arp_standard.debug('arp_revenue_assignments - using request_id');
     END IF;

     INSERT INTO AR_REVENUE_ASSIGNMENTS_GT
       (SESSION_ID,
        CUSTOMER_TRX_LINE_ID,
        COMPLETE_FLAG,
        ACCOUNT_CLASS,
        LUMP_SUM_FLAG,
        RULE_TYPE,
        PERIOD_NUMBER,
        PERCENT,
        RULE_DATE,
        SET_OF_BOOKS_ID,
        PERIOD_TYPE,
        MAX_REGULAR_PERIOD_LENGTH)
     select distinct p_session_id,
       tl.previous_customer_trx_line_id,
       t.complete_flag,
       ral.lookup_code account_class,
       decode(rr.type, 'ACC_DUR', decode(rrs_lump.rule_id, null, 'N', 'Y'), 'N') lump_sum_flag,
       rr.type,
       rrs.period_number,
       decode(rr.type, 'ACC_DUR',
         decode(rrs_lump.rule_id, null,
                 (1/nvl(itl.accounting_rule_duration, 1)) ,
            decode(rrs.period_number, 1, rrs_lump.percent / 100,
               (1 / decode(itl.accounting_rule_duration, 1, 1, null, 1,
                         itl.accounting_rule_duration - 1)) *
                   (1 - rrs_lump.percent/100))) * 100,
             rrs.percent) percent,
       rrs.rule_date,
       tl.set_of_books_id,
       decode(rr.frequency, 'SPECIFIC', gsb.accounted_period_type,
            decode(tl.previous_customer_trx_line_id, NULL, rr.frequency,
                 gsb.accounted_period_type)) period_type,
       apt.max_regular_period_length
      from
       ra_customer_trx_lines tl,
       ra_customer_trx_lines itl,
       ra_customer_trx t,
       ra_rules rr,
       ra_rule_schedules rrs,
       ra_rule_schedules rrs_lump,
       ar_lookups ral,
       gl_sets_of_books gsb,
       ar_period_types apt
      where
              tl.customer_trx_id = t.customer_trx_id
       and    tl.accounting_rule_id = rr.rule_id
       and    tl.set_of_books_id = gsb.set_of_books_id
       and    tl.previous_customer_trx_line_id =
              itl.customer_trx_line_id (+)
       and    gsb.accounted_period_type = apt.period_type
       and    ral.lookup_type = 'AUTOGL_TYPE'
       and   (ral.lookup_code = 'REV' or
              ral.lookup_code = decode(t.invoicing_rule_id, -2, 'UNEARN',
                                                            -3, 'UNBILL'))
       and   rrs.period_number <= DECODE(rr.type, 'PP_DR_PP', 1,
                                                  'PP_DR_ALL', 1,
                  nvl(itl.accounting_rule_duration, rr.occurrences))
       and    rrs_lump.rule_id (+) = rr.rule_id
       and    rrs_lump.period_number (+) = 1
       and    decode(rr.type, 'A',rr.rule_id, -1) = rrs.rule_id
       and    t.request_id = p_request_id
       and    t.previous_customer_trx_id is not null;

   ELSIF (p_customer_trx_line_id is not null)
   THEN
     IF PG_DEBUG IN ('Y','C')
     THEN
        arp_standard.debug('arp_revenue_assignments - using line_id');
     END IF;

     INSERT INTO AR_REVENUE_ASSIGNMENTS_GT
       (SESSION_ID,
        CUSTOMER_TRX_LINE_ID,
        COMPLETE_FLAG,
        ACCOUNT_CLASS,
        LUMP_SUM_FLAG,
        RULE_TYPE,
        PERIOD_NUMBER,
        PERCENT,
        RULE_DATE,
        SET_OF_BOOKS_ID,
        PERIOD_TYPE,
        MAX_REGULAR_PERIOD_LENGTH)
     select distinct p_session_id,
       tl.previous_customer_trx_line_id,
       t.complete_flag,
       ral.lookup_code account_class,
       decode(rr.type, 'ACC_DUR', decode(rrs_lump.rule_id, null, 'N', 'Y'), 'N') lump_sum_flag,
       rr.type,
       rrs.period_number,
       decode(rr.type, 'ACC_DUR',
         decode(rrs_lump.rule_id, null, 1/nvl(itl.accounting_rule_duration, 1),
            decode(rrs.period_number, 1, rrs_lump.percent / 100,
               (1 / decode(itl.accounting_rule_duration, 1, 1, null, 1,
                         itl.accounting_rule_duration - 1)) *
                   (1 - rrs_lump.percent/100))) * 100,
             rrs.percent) percent,
       rrs.rule_date,
       tl.set_of_books_id,
       decode(rr.frequency, 'SPECIFIC', gsb.accounted_period_type,
            decode(tl.previous_customer_trx_line_id, NULL, rr.frequency,
                 gsb.accounted_period_type)) period_type,
       apt.max_regular_period_length
      from
       ra_customer_trx_lines tl,
       ra_customer_trx_lines itl,
       ra_customer_trx t,
       ra_rules rr,
       ra_rule_schedules rrs,
       ra_rule_schedules rrs_lump,
       ar_lookups ral,
       gl_sets_of_books gsb,
       ar_period_types apt
      where
              tl.customer_trx_line_id = p_customer_trx_line_id
       and    tl.customer_trx_id = t.customer_trx_id
       and    tl.accounting_rule_id = rr.rule_id
       and    tl.set_of_books_id = gsb.set_of_books_id
       and    tl.previous_customer_trx_line_id =
              itl.customer_trx_line_id (+)
       and    gsb.accounted_period_type = apt.period_type
       and    ral.lookup_type = 'AUTOGL_TYPE'
       and   (ral.lookup_code = 'REV' or
              ral.lookup_code = decode(t.invoicing_rule_id, -2, 'UNEARN',
                                                            -3, 'UNBILL'))
       and   rrs.period_number <= DECODE(rr.type, 'PP_DR_PP', 1,
                                                  'PP_DR_ALL', 1,
                  nvl(itl.accounting_rule_duration, rr.occurrences))
       and    rrs_lump.rule_id (+) = rr.rule_id
       and    rrs_lump.period_number (+) = 1
       and    decode(rr.type, 'A',rr.rule_id, -1) = rrs.rule_id;

   ELSE
     IF PG_DEBUG IN ('Y','C')
     THEN
        arp_standard.debug('arp_revenue_assignments - using trx_id');
     END IF;

     INSERT INTO AR_REVENUE_ASSIGNMENTS_GT
       (SESSION_ID,
        CUSTOMER_TRX_LINE_ID,
        COMPLETE_FLAG,
        ACCOUNT_CLASS,
        LUMP_SUM_FLAG,
        RULE_TYPE,
        PERIOD_NUMBER,
        PERCENT,
        RULE_DATE,
        SET_OF_BOOKS_ID,
        PERIOD_TYPE,
        MAX_REGULAR_PERIOD_LENGTH)
     select distinct p_session_id,
       tl.previous_customer_trx_line_id,
       t.complete_flag,
       ral.lookup_code account_class,
       decode(rr.type, 'ACC_DUR', decode(rrs_lump.rule_id, null, 'N', 'Y'), 'N') lump_sum_flag,
       rr.type,
       rrs.period_number,
       decode(rr.type, 'ACC_DUR',
         decode(rrs_lump.rule_id, null, 1/nvl(itl.accounting_rule_duration, 1),
            decode(rrs.period_number, 1, rrs_lump.percent / 100,
               (1 / decode(itl.accounting_rule_duration, 1, 1, null, 1,
                         itl.accounting_rule_duration - 1)) *
                   (1 - rrs_lump.percent/100))) * 100,
             rrs.percent) percent,
       rrs.rule_date,
       tl.set_of_books_id,
       decode(rr.frequency, 'SPECIFIC', gsb.accounted_period_type,
            decode(tl.previous_customer_trx_line_id, NULL, rr.frequency,
                 gsb.accounted_period_type)) period_type,
       apt.max_regular_period_length
      from
       ra_customer_trx_lines tl,
       ra_customer_trx_lines itl,
       ra_customer_trx t,
       ra_rules rr,
       ra_rule_schedules rrs,
       ra_rule_schedules rrs_lump,
       ar_lookups ral,
       gl_sets_of_books gsb,
       ar_period_types apt
      where
              t.customer_trx_id = p_customer_trx_id
       and    tl.customer_trx_id = t.customer_trx_id
       and    tl.accounting_rule_id = rr.rule_id
       and    tl.set_of_books_id = gsb.set_of_books_id
       and    tl.previous_customer_trx_line_id =
              itl.customer_trx_line_id (+)
       and    gsb.accounted_period_type = apt.period_type
       and    ral.lookup_type = 'AUTOGL_TYPE'
       and   (ral.lookup_code = 'REV' or
              ral.lookup_code = decode(t.invoicing_rule_id, -2, 'UNEARN',
                                                            -3, 'UNBILL'))
       and   rrs.period_number <=
                  nvl(itl.accounting_rule_duration, rr.occurrences)
       and    rrs_lump.rule_id (+) = rr.rule_id
       and    rrs_lump.period_number (+) = 1
       and    decode(rr.type, 'A',rr.rule_id, -1) = rrs.rule_id;

   END IF;

   /* 7666667 - If we are processing any PPRR rules, set the PPRR_AMOUNT
      column for use in prorating credits */
   IF p_use_inv_acctg = 'Y'
   THEN
     UPDATE ar_revenue_assignments_gt ragt
     SET    pprr_amount =
      (SELECT   Sum(ilgd.amount)
       FROM   ra_customer_trx_lines      il,
              ra_cust_trx_line_gl_dist   ilgd,
              ar_periods                 arp1, -- first period
              ar_periods                 arp2  -- current period
       WHERE  ragt.customer_trx_line_id = il.customer_trx_line_id
       AND    il.rule_start_date BETWEEN arp1.start_date AND arp1.end_date
       AND    arp2.new_period_num >= arp1.new_period_num
       AND    arp1.period_type = ragt.period_type
       AND    arp1.period_set_name = p_period_set_name
       AND    arp2.period_type = ragt.period_type
       AND    arp2.period_set_name = p_period_set_name
       AND    ragt.period_number = (arp2.new_period_num - arp1.new_period_num + 1)
       AND    il.customer_trx_line_id = ilgd.customer_trx_line_id
       AND    ilgd.account_class = ragt.account_class
       AND    ilgd.account_set_flag = 'N'
       AND    ilgd.rec_offset_flag IS NULL
       AND    ilgd.gl_date BETWEEN arp2.start_date AND arp2.end_date)
     WHERE  ragt.rule_type in ('PP_DR_PP','PP_DR_ALL')
     AND    ragt.session_id = p_session_id;

     IF PG_DEBUG IN ('Y','C')
     THEN
        arp_standard.debug(' row(s) updated for pprr = ' || SQL%ROWCOUNT);
     END IF;
   END IF;

   IF PG_DEBUG in ('Y', 'C') THEN
       arp_standard.debug('DUMP of ar_revenue_assignments_gt ');
       DECLARE
          CURSOR c01 IS
             SELECT
                SESSION_ID,
                CUSTOMER_TRX_LINE_ID,
                COMPLETE_FLAG,
                ACCOUNT_CLASS,
                LUMP_SUM_FLAG,
                RULE_TYPE,
                PERIOD_NUMBER,
                PERCENT,
                RULE_DATE,
                SET_OF_BOOKS_ID,
                PERIOD_TYPE,
                MAX_REGULAR_PERIOD_LENGTH,
                PPRR_AMOUNT
             FROM AR_REVENUE_ASSIGNMENTS_GT
             WHERE session_id = p_session_id
             ORDER BY CUSTOMER_TRX_LINE_ID, PERIOD_NUMBER;
             i NUMBER := 1;
       BEGIN
          FOR c01_rec IN c01 LOOP
           arp_standard.debug('['|| i || ']:' ||
           c01_rec.CUSTOMER_TRX_LINE_ID || '~' ||
           c01_rec.COMPLETE_FLAG || '~' ||
           c01_rec.ACCOUNT_CLASS || '~' ||
           c01_rec.LUMP_SUM_FLAG || '~' ||
           c01_rec.RULE_TYPE || '~' ||
           c01_rec.PERIOD_NUMBER || '~' ||
           c01_rec.PERCENT || '~' ||
           c01_rec.RULE_DATE || '~' ||
           c01_rec.SET_OF_BOOKS_ID || '~' ||
           c01_rec.PERIOD_TYPE || '~' ||
           c01_rec.MAX_REGULAR_PERIOD_LENGTH || '~' ||
           c01_rec.PPRR_AMOUNT);
           i := i + 1;
          END LOOP;
       END;

      arp_standard.debug('arp_revenue_assignments.build_for_credit()-');

    END IF;

END;

END arp_revenue_assignments;

/
