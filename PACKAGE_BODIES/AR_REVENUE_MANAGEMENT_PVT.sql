--------------------------------------------------------
--  DDL for Package Body AR_REVENUE_MANAGEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_REVENUE_MANAGEMENT_PVT" AS
/* $Header: ARXRVMGB.pls 120.100.12010000.22 2010/05/27 19:43:40 mraymond ship $ */


/*=======================================================================+
 |  Declare Package Data Types and Variables
 +=======================================================================*/

 TYPE RefCurType IS REF CURSOR;

/*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/

  SUCCESS CONSTANT VARCHAR2(1)  := '0';
  WARNING CONSTANT VARCHAR2(1)  := '1';
  FAILURE CONSTANT VARCHAR2(1)  := '2';

  -- Following global variables are required for caching

  g_credit_class_tbl            varchar_table;
  g_currency_code_f    		fnd_currencies.currency_code%TYPE;
  g_precision_f	       	        fnd_currencies.precision%TYPE;
  g_minimum_accountable_unit_f  fnd_currencies.minimum_accountable_unit%TYPE;
  g_source                       VARCHAR2(30);
  g_om_context       ra_interface_lines.interface_line_context%type;

  pg_debug VARCHAR2(1) := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');


/*========================================================================
 | Local Functions and Procedures
 *=======================================================================*/

PROCEDURE debug (p_string VARCHAR2) IS

BEGIN

    arp_debug.debug(p_string);

END debug;

  /* 4521577 - This logic will default the contingency ID 5
     on any line for an invoice that has a term with due days
     greater than the value specified in system options
     term_threshold.  This default will not occur if the
     deferral_exclusion_flag is set to 'Y'.  It will also
     not occur if there are interface validation errors for
     the line.

     There are separate INSERT statements for Invoice API,
     Autoinvoice, and ARXTWMAI */

PROCEDURE insert_term_contingencies (
  p_request_id NUMBER,
  p_customer_trx_line_id NUMBER) IS

  l_user_id NUMBER;
  l_rows    NUMBER;
BEGIN
  debug('insert_term_contingencies()+');

  l_user_id := fnd_global.user_id;

  IF p_request_id IS NOT NULL
  THEN
     /* This is either invoice API or autoinvoice */
     IF (g_source = 'AR_INVOICE_API')
     THEN

       INSERT INTO ar_line_conts_all
       (
         customer_trx_line_id,
         contingency_id,
         contingency_code,
         expiration_date,
         expiration_days,
         expiration_event_date,
         reason_removal_date,
         completed_flag,
         defaulted_in_ar_flag,
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         org_id
       )
       SELECT
        max(ctl.customer_trx_line_id),
        5,
        '5',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        'Y',
        max(ctl.request_id),
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        max(ctl.org_id)
       FROM ra_customer_trx_lines_all      ctl,
            ra_customer_trx_all            ct,
            ra_terms_lines                 tl,
            ra_cust_trx_types_all          ctt
       WHERE ctl.request_id = p_request_id
       AND   ctl.customer_trx_id    = ct.customer_trx_id
       AND   ct.batch_source_id NOT IN (20, 21)
       AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND   ct.org_id = ctt.org_id
       AND   ctt.type = 'INV'
       AND   ctl.line_type = 'LINE'
       AND   ct.term_id = tl.term_id
       AND   NVL(ctl.deferral_exclusion_flag, 'N') = 'N'
       AND   NOT EXISTS
          (SELECT 'errors'
           FROM    ar_trx_errors_gt teg,
                   ar_trx_lines_gt  tlg
           WHERE   teg.trx_header_id = tlg.trx_header_id
           AND     teg.trx_line_id   = tlg.trx_line_id
           AND     tlg.customer_trx_line_id = ctl.customer_trx_line_id)
       AND   NOT EXISTS
          (SELECT 'prevent duplicate contingency'
           FROM   ar_line_conts_all   alc
           WHERE  alc.customer_trx_line_id = ctl.customer_trx_line_id
           AND    alc.contingency_id       = 5)
       GROUP BY ctl.customer_trx_line_id, tl.term_id
       HAVING  max(due_days) > arp_standard.sysparm.payment_threshold;

     ELSE /* Autoinvoice */
       INSERT INTO ar_line_conts_all
       (
         customer_trx_line_id,
         contingency_id,
         contingency_code,
         expiration_date,
         expiration_days,
         expiration_event_date,
         reason_removal_date,
         completed_flag,
         defaulted_in_ar_flag,
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         org_id
       )
       SELECT
        max(ctl.customer_trx_line_id),
        5,
        '5',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        'Y',
        max(ctl.request_id),
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        max(ctl.org_id)
       FROM ra_customer_trx_lines_all      ctl,
            ra_customer_trx_all            ct,
            ra_terms_lines                 tl,
            ra_cust_trx_types_all          ctt
       WHERE ctl.request_id = p_request_id
       AND   ctl.customer_trx_id    = ct.customer_trx_id
       AND   ct.batch_source_id NOT IN (20, 21)
       AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND   ct.org_id = ctt.org_id
       AND   ctt.type = 'INV'
       AND   ctl.line_type = 'LINE'
       AND   ct.term_id = tl.term_id
       AND   NVL(ctl.deferral_exclusion_flag, 'N') = 'N'
       AND   NOT EXISTS
          (SELECT 'errors'
           FROM    ra_interface_errors_all ie
           WHERE   ie.interface_line_id = ctl.customer_trx_line_id)
       AND   NOT EXISTS
          (SELECT 'prevent duplicate contingency'
           FROM   ar_line_conts_all   alc
           WHERE  alc.customer_trx_line_id = ctl.customer_trx_line_id
           AND    alc.contingency_id       = 5)
       GROUP BY ctl.customer_trx_line_id, tl.term_id
       HAVING  max(due_days) > arp_standard.sysparm.payment_threshold;
     END IF;
  ELSE /* Manual transaction */
       INSERT INTO ar_line_conts_all
       (
         customer_trx_line_id,
         contingency_id,
         contingency_code,
         expiration_date,
         expiration_days,
         expiration_event_date,
         reason_removal_date,
         completed_flag,
         defaulted_in_ar_flag,
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         org_id
       )
       SELECT
        ctl.customer_trx_line_id,
        5,
        '5',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        'Y',
        NULL,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        ctl.org_id
       FROM ra_customer_trx_lines_all      ctl,
            ra_customer_trx_all            ct,
            ra_terms_lines                 tl,
            ra_cust_trx_types_all          ctt
       WHERE ctl.customer_trx_line_id = p_customer_trx_line_id
       AND   ctl.customer_trx_id    = ct.customer_trx_id
       AND   ct.batch_source_id NOT IN (20, 21)
       AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND   ct.org_id = ctt.org_id
       AND   ctt.type = 'INV'
       AND   ctl.line_type = 'LINE'
       AND   ct.term_id = tl.term_id
       AND   NVL(ctl.deferral_exclusion_flag, 'N') = 'N'
       AND   NOT EXISTS
          (SELECT 'prevent duplicate contingency'
           FROM   ar_line_conts_all   alc
           WHERE  alc.customer_trx_line_id = ctl.customer_trx_line_id
           AND    alc.contingency_id       = 5)
       GROUP BY ctl.customer_trx_line_id, ctl.org_id,tl.term_id
       HAVING  max(tl.due_days) > arp_standard.sysparm.payment_threshold;
  END IF;

  l_rows := SQL%ROWCOUNT;

  debug('term contingencies inserted: ' || l_rows);
  debug('insert_term_contingencies()-');

END insert_term_contingencies;

  /* 4521577 - This logic will default the contingency ID 3
     on any line for an invoice that has a customer with
     a questionable credit classification.

     This default will not occur if the
     deferral_exclusion_flag is set to 'Y'.  It will also
     not occur if there are interface validation errors for
     the line.

     There are separate INSERT statements for Invoice API,
     Autoinvoice, and ARXTWMAI */

PROCEDURE insert_credit_contingencies (
  p_request_id NUMBER,
  p_customer_trx_line_id NUMBER) IS

  l_user_id NUMBER;
  l_rows    NUMBER;
BEGIN
  debug('insert_credit_contingencies()+');

  l_user_id := fnd_global.user_id;

  IF p_request_id IS NOT NULL
  THEN
     /* This is either invoice API or autoinvoice */
     IF (g_source = 'AR_INVOICE_API')
     THEN

       INSERT INTO ar_line_conts_all
       (
         customer_trx_line_id,
         contingency_id,
         contingency_code,
         expiration_date,
         expiration_days,
         expiration_event_date,
         reason_removal_date,
         completed_flag,
         defaulted_in_ar_flag,
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         org_id
       )
       SELECT
        ctl.customer_trx_line_id,
        3,
        '3',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        'Y',
        ctl.request_id,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        ctl.org_id
       FROM ra_customer_trx_lines_all      ctl,
            ra_customer_trx_all            ct,
            ra_cust_trx_types_all          ctt
       WHERE ctl.request_id = p_request_id
       AND   ctl.customer_trx_id    = ct.customer_trx_id
       AND   ct.batch_source_id NOT IN (20, 21)
       AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND   ct.org_id = ctt.org_id
       AND   ctt.type = 'INV'
       AND   ctl.line_type = 'LINE'
       AND   NVL(ctl.deferral_exclusion_flag, 'N') = 'N'
       AND   ar_revenue_management_pvt.creditworthy
               (ct.bill_to_customer_id, ct.bill_to_site_use_id)= 0
       AND   NOT EXISTS
          (SELECT 'errors'
           FROM    ar_trx_errors_gt teg,
                   ar_trx_lines_gt  tlg
           WHERE   teg.trx_header_id = tlg.trx_header_id
           AND     teg.trx_line_id   = tlg.trx_line_id
           AND     tlg.customer_trx_line_id = ctl.customer_trx_line_id)
       AND   NOT EXISTS
          (SELECT 'prevent duplicate contingency'
           FROM   ar_line_conts_all   alc
           WHERE  alc.customer_trx_line_id = ctl.customer_trx_line_id
           AND    alc.contingency_id       = 3);

     ELSE /* Autoinvoice */
       INSERT INTO ar_line_conts_all
       (
         customer_trx_line_id,
         contingency_id,
         contingency_code,
         expiration_date,
         expiration_days,
         expiration_event_date,
         reason_removal_date,
         completed_flag,
         defaulted_in_ar_flag,
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         org_id
       )
       SELECT
        ctl.customer_trx_line_id,
        3,
        '3',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        'Y',
        ctl.request_id,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        ctl.org_id
       FROM ra_customer_trx_lines_all      ctl,
            ra_customer_trx_all            ct,
            ra_cust_trx_types_all          ctt
       WHERE ctl.request_id = p_request_id
       AND   ctl.customer_trx_id    = ct.customer_trx_id
       AND   ct.batch_source_id NOT IN (20, 21)
       AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND   ct.org_id = ctt.org_id
       AND   ctt.type = 'INV'
       AND   ctl.line_type = 'LINE'
       AND   NVL(ctl.deferral_exclusion_flag, 'N') = 'N'
       AND   ar_revenue_management_pvt.creditworthy
               (ct.bill_to_customer_id, ct.bill_to_site_use_id)= 0
       AND   NOT EXISTS
          (SELECT 'errors'
           FROM    ra_interface_errors_all ie
           WHERE   ie.interface_line_id = ctl.customer_trx_line_id)
       AND   NOT EXISTS
          (SELECT 'prevent duplicate contingency'
           FROM   ar_line_conts_all   alc
           WHERE  alc.customer_trx_line_id = ctl.customer_trx_line_id
           AND    alc.contingency_id       = 3);
     END IF;
  ELSE /* Manual transaction */
       INSERT INTO ar_line_conts_all
       (
         customer_trx_line_id,
         contingency_id,
         contingency_code,
         expiration_date,
         expiration_days,
         expiration_event_date,
         reason_removal_date,
         completed_flag,
         defaulted_in_ar_flag,
         request_id,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login,
         org_id
       )
       SELECT
        ctl.customer_trx_line_id,
        3,
        '3',
        NULL,
        NULL,
        NULL,
        NULL,
        'N',
        'Y',
        NULL,
        l_user_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        ctl.org_id
       FROM ra_customer_trx_lines_all      ctl,
            ra_customer_trx_all            ct,
            ra_cust_trx_types_all          ctt
       WHERE ctl.customer_trx_line_id = p_customer_trx_line_id
       AND   ctl.customer_trx_id    = ct.customer_trx_id
       AND   ct.batch_source_id NOT IN (20, 21)
       AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
       AND   ct.org_id = ctt.org_id
       AND   ctt.type = 'INV'
       AND   ctl.line_type = 'LINE'
       AND   NVL(ctl.deferral_exclusion_flag, 'N') = 'N'
       AND   ar_revenue_management_pvt.creditworthy
               (ct.bill_to_customer_id, ct.bill_to_site_use_id)= 0
       AND   NOT EXISTS
          (SELECT 'prevent duplicate contingency'
           FROM   ar_line_conts_all   alc
           WHERE  alc.customer_trx_line_id = ctl.customer_trx_line_id
           AND    alc.contingency_id       = 3);
  END IF;

  l_rows := SQL%ROWCOUNT;

  debug('credit contingencies inserted: ' || l_rows);
  debug('insert_credit_contingencies()-');

END insert_credit_contingencies;

PROCEDURE populate_acceptance_rows (
  p_customer_trx_id      NUMBER DEFAULT NULL,
  p_customer_trx_line_id NUMBER DEFAULT NULL,
  p_mode                 VARCHAR2 DEFAULT 'EXPIRE') IS

  l_request_id NUMBER;

BEGIN

  debug('populate_acceptance_rows()+');
  debug('  p_customer_trx_id      : ' || p_customer_trx_id);
  debug('  p_customer_trx_line_id : ' || p_customer_trx_line_id);
  debug('  p_mode                 : ' || p_mode);

  l_request_id := nvl(p_customer_trx_line_id, nvl(p_customer_trx_id,
                    fnd_global.conc_request_id));

  IF (p_mode = 'RECORD') THEN

    INSERT INTO  ar_reviewed_lines_gt
    (
      customer_trx_line_id,
      customer_trx_id,
      amount_due_original,
      acctd_amount_due_original,
      amount_recognized,
      acctd_amount_recognized,
      amount_pending,
      acctd_amount_pending,
      line_type,
      so_line_id,
      request_id
    )
    SELECT
      dl.customer_trx_line_id line_id,
      max(dl.customer_trx_id) trx_id,
      max(dl.amount_due_original),
      max(dl.acctd_amount_due_original),
      max(dl.amount_recognized),
      max(dl.acctd_amount_recognized),
      max(dl.amount_pending),
      max(dl.acctd_amount_pending),
      'PARENT',
      max(interface_line_attribute6),
      l_request_id
    FROM   ar_deferred_lines   dl,
           ar_line_conts       lc,
           ar_deferral_reasons dr,
           ra_customer_trx_lines ctl
    WHERE  dl.customer_trx_line_id = lc.customer_trx_line_id
    AND    lc.contingency_id       = dr.contingency_id
    AND    ctl.customer_trx_line_id = lc.customer_trx_line_id
    AND    dr.revrec_event_code    = 'CUSTOMER_ACCEPTANCE'
    AND    lc.completed_flag       = 'N'
    AND    line_collectible_flag   = 'N'  -- not collectilbe
    AND    manual_override_flag    = 'N'  -- not manually overridden in
                                          -- RAM wizards
    AND    dl.customer_trx_id      = nvl(p_customer_trx_id,
                                         dl.customer_trx_id)
    AND    dl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                         dl.customer_trx_line_id)
    GROUP BY dl.customer_trx_line_id;

    debug('acceptance rows inserted: ' || SQL%ROWCOUNT);

  ELSE

    INSERT INTO  ar_reviewed_lines_gt
    (
      customer_trx_line_id,
      customer_trx_id,
      amount_due_original,
      acctd_amount_due_original,
      amount_recognized,
      acctd_amount_recognized,
      amount_pending,
      acctd_amount_pending,
      line_type,
      so_line_id,
      request_id
    )
    SELECT
      dl.customer_trx_line_id line_id,
      max(dl.customer_trx_id) trx_id,
      max(dl.amount_due_original),
      max(dl.acctd_amount_due_original),
      max(dl.amount_recognized),
      max(dl.acctd_amount_recognized),
      max(dl.amount_pending),
      max(dl.acctd_amount_pending),
      'PARENT',
      max(interface_line_attribute6),
      l_request_id
    FROM   ar_deferred_lines   dl,
           ar_line_conts       lc,
           ar_deferral_reasons dr,
           ra_customer_trx_lines ctl
    WHERE  dl.customer_trx_line_id = lc.customer_trx_line_id
    AND    lc.contingency_id       = dr.contingency_id
    AND    ctl.customer_trx_line_id = lc.customer_trx_line_id
    AND    dr.revrec_event_code    = 'CUSTOMER_ACCEPTANCE'
    AND    lc.completed_flag       = 'N'
    AND    line_collectible_flag   = 'N'  -- not collectilbe
    AND    manual_override_flag    = 'N'  -- not manually overridden in
                                          -- RAM wizards
    AND    dl.customer_trx_id      = nvl(p_customer_trx_id,
                                         dl.customer_trx_id)
    AND    dl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                         dl.customer_trx_line_id)
    AND    trunc(lc.expiration_date) <= trunc(sysdate)
    GROUP BY dl.customer_trx_line_id;

    debug('acceptance rows inserted: ' || SQL%ROWCOUNT);

  END IF;

  debug('populate_acceptance_rows()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: populate_acceptance_rows');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: populate_acceptance_rows');
      debug(sqlerrm);
      RAISE;

END populate_acceptance_rows;


PROCEDURE populate_no_contingency_rows (
  p_customer_trx_id      NUMBER DEFAULT NULL,
  p_customer_trx_line_id NUMBER DEFAULT NULL) IS

  l_request_id NUMBER;

BEGIN

  debug('populate_no_contingency_rows()+');
  debug('  p_customer_trx_id      : ' || p_customer_trx_id);
  debug('  p_customer_trx_line_id : ' || p_customer_trx_line_id);

  l_request_id := nvl(p_customer_trx_line_id, nvl(p_customer_trx_id,
                    fnd_global.conc_request_id));

  INSERT INTO  ar_reviewed_lines_gt
  (
    customer_trx_line_id,
    customer_trx_id,
    amount_due_original,
    acctd_amount_due_original,
    amount_recognized,
    acctd_amount_recognized,
    amount_pending,
    acctd_amount_pending,
    line_type,
    so_line_id,
    request_id
  )
  SELECT
    dl.customer_trx_line_id,
    dl.customer_trx_id,
    dl.amount_due_original,
    dl.acctd_amount_due_original,
    dl.amount_recognized,
    dl.acctd_amount_recognized,
    dl.amount_pending,
    dl.acctd_amount_pending,
    'PARENT',
    interface_line_attribute6,
    l_request_id
  FROM   ar_deferred_lines   dl,
         ra_customer_trx_lines ctl
  WHERE  dl.customer_trx_line_id = ctl.customer_trx_line_id
  AND    dl.customer_trx_id = nvl(p_customer_trx_id, dl.customer_trx_id)
  AND    dl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                       dl.customer_trx_line_id)
  AND NOT EXISTS
  ( SELECT 'already inserted'
    FROM   ar_reviewed_lines_gt rl
    WHERE  rl.customer_trx_line_id = dl.customer_trx_line_id);

  debug('no contingency rows inserted: ' || SQL%ROWCOUNT);

  debug('populate_no_contingency_rows()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: populate_no_contingency_rows');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: populate_no_contingency_rows');
      debug(sqlerrm);
      RAISE;

END populate_no_contingency_rows;


PROCEDURE populate_child_rows (
  p_customer_trx_id      NUMBER DEFAULT NULL,
  p_customer_trx_line_id NUMBER DEFAULT NULL) IS

  l_request_id NUMBER;
  l_rows       NUMBER;
BEGIN
  IF pg_debug IN ('Y', 'C') THEN
     debug('populate_child_rows()+');
     debug('  p_customer_trx_id : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' || p_customer_trx_line_id);
  END IF;

  l_request_id := nvl(p_customer_trx_line_id, nvl(p_customer_trx_id,
                    fnd_global.conc_request_id));


  /* 4996493 - modified child to parent for parameter trx and line_ids
      so that acceptance picks up the parent lines and any child lines
      associated with that parent */

  /* 5043785 - The sql below contains an ORDERED hint because it must
     join to RA_CUSTOMER_TRX_LINES before it attempts to join to the
     child lines via so_line_id.  In cases where the line is not from OM,
     this join will fail with an invalid number (if it is attempted).

     So the ORDERED hint along with the table order prevents the failure
     and results in no lines being inserted when the interface_line_context
     does not match the ONT_SOURCE_CODE profile */

  /* 5229211 - Added code to populate so_line_id */

  INSERT INTO  ar_reviewed_lines_gt
  (
    customer_trx_line_id,
    customer_trx_id,
    amount_due_original,
    acctd_amount_due_original,
    amount_recognized,
    acctd_amount_recognized,
    amount_pending,
    acctd_amount_pending,
    line_type,
    request_id,
    so_line_id,
    expiration_date
  )
  SELECT /*+ ORDERED */
    child.customer_trx_line_id line_id,
    max(child.customer_trx_id) trx_id,
    max(child.amount_due_original),
    max(child.acctd_amount_due_original),
    max(child.amount_recognized),
    max(child.acctd_amount_recognized),
    max(child.amount_pending),
    max(child.acctd_amount_pending),
    'CHILD',
    l_request_id,
    child_line.interface_line_attribute6,
    max(lc.expiration_date)
  FROM   ar_reviewed_lines_gt  parent,
         ra_customer_trx_lines parent_line,
         ar_deferred_lines     child,
         ra_customer_trx_lines child_line,
         ar_line_conts         lc,
         ar_deferral_reasons   dr
  WHERE  parent.customer_trx_id = parent_line.customer_trx_id
  AND    parent.customer_trx_line_id = parent_line.customer_trx_line_id
  AND    parent_line.interface_line_context = g_om_context
  AND    to_char(child.parent_line_id) = parent.so_line_id
  AND    child.customer_trx_line_id = child_line.customer_trx_line_id
  AND    child_line.customer_trx_line_id = lc.customer_trx_line_id
  AND    lc.contingency_id       = dr.contingency_id
  AND    dr.revrec_event_code    = 'CUSTOMER_ACCEPTANCE'
  AND    lc.completed_flag       = 'N'
  AND    line_collectible_flag   = 'N'  -- not collectilbe
  AND    manual_override_flag    = 'N'  -- not manually overridden in
                                        -- RAM wizards
  AND    parent.customer_trx_id      = nvl(p_customer_trx_id,
                                           parent.customer_trx_id)
  AND    parent.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                           parent.customer_trx_line_id)
  AND    trunc(lc.expiration_date) <= trunc(sysdate)
  GROUP BY child.customer_trx_line_id, child_line.interface_line_attribute6;

  IF pg_debug IN ('Y', 'C') THEN
     l_rows := SQL%ROWCOUNT;
     debug(' inserted ' || l_rows || ' row(s)');
     debug('populate_child_rows()-');
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: populate_child_rows');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: populate_child_rows');
      debug(sqlerrm);
      RAISE;

END populate_child_rows;


PROCEDURE populate_other_rows (
  p_customer_trx_id      NUMBER   DEFAULT NULL,
  p_customer_trx_line_id NUMBER   DEFAULT NULL,
  p_mode                 VARCHAR2 DEFAULT 'NORMAL') IS

  l_request_id NUMBER;
  l_count      NUMBER;
BEGIN

  debug('populate_other_rows()+');
  debug('  p_customer_trx_id : ' || p_customer_trx_id);
  debug('  p_customer_trx_line_id : ' || p_customer_trx_line_id);

  l_request_id := nvl(p_customer_trx_line_id, nvl(p_customer_trx_id,
                    fnd_global.conc_request_id));

  IF p_mode = 'NORMAL' THEN

  INSERT INTO  ar_reviewed_lines_gt
  (
    customer_trx_line_id,
    customer_trx_id,
    amount_due_original,
    acctd_amount_due_original,
    amount_recognized,
    acctd_amount_recognized,
    amount_pending,
    acctd_amount_pending,
    line_type,
    request_id,
    expiration_date
  )
  SELECT
    dl.customer_trx_line_id line_id,
    max(customer_trx_id) trx_id,
    max(amount_due_original),
    max(acctd_amount_due_original),
    max(amount_recognized),
    max(acctd_amount_recognized),
    max(amount_pending),
    max(acctd_amount_pending),
    'OTHERS',
    l_request_id,
    max(lc.expiration_date)
  FROM ar_deferred_lines   dl,
       ar_line_conts       lc,
       ar_deferral_reasons dr
  WHERE  dl.customer_trx_line_id  = lc.customer_trx_line_id
  AND    lc.contingency_id        = dr.contingency_id
  AND    lc.completed_flag        = 'N'
  AND    line_collectible_flag    = 'N'  -- not collectilbe
  AND    manual_override_flag     = 'N'  -- not manually overridden in
                                         -- RAM wizards
  AND    dr.revrec_event_code <> 'CUSTOMER_ACCEPTANCE'
  AND    trunc(lc.expiration_date) <= trunc(sysdate)
  AND    dl.customer_trx_id      = nvl(p_customer_trx_id, dl.customer_trx_id)
  AND    dl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                       dl.customer_trx_line_id)
  AND NOT EXISTS
  ( SELECT 'already inserted'
    FROM   ar_reviewed_lines_gt rl
    WHERE  rl.customer_trx_line_id = dl.customer_trx_line_id)
  GROUP BY dl.customer_trx_line_id;

  l_count := SQL%ROWCOUNT;

  ELSE

  INSERT INTO  ar_reviewed_lines_gt
  (
    customer_trx_line_id,
    customer_trx_id,
    amount_due_original,
    acctd_amount_due_original,
    amount_recognized,
    acctd_amount_recognized,
    amount_pending,
    acctd_amount_pending,
    line_type,
    request_id
  )
  SELECT
    dl.customer_trx_line_id line_id,
    max(customer_trx_id) trx_id,
    max(amount_due_original),
    max(acctd_amount_due_original),
    max(amount_recognized),
    max(acctd_amount_recognized),
    max(amount_pending),
    max(acctd_amount_pending),
    'UPDATE',
    l_request_id
  FROM ar_deferred_lines   dl,
       ar_line_conts       lc,
       ar_deferral_reasons dr
  WHERE  dl.customer_trx_line_id  = lc.customer_trx_line_id
  AND    lc.contingency_id        = dr.contingency_id
  AND    line_collectible_flag    = 'N'  -- not collectilbe
  AND    manual_override_flag     = 'N'  -- not manually overridden in
                                         -- RAM wizards
  AND    dl.customer_trx_id      = nvl(p_customer_trx_id, dl.customer_trx_id)
  AND    dl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                       dl.customer_trx_line_id)
  GROUP BY dl.customer_trx_line_id;

  l_count := SQL%ROWCOUNT;

  END IF;

  debug('  Other row(s) inserted : ' || l_count);
  debug('populate_other_rows()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: populate_other_rows');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: populate_other_rows');
      debug(sqlerrm);
      RAISE;

END populate_other_rows;


PROCEDURE record_acceptance_with_om (
  p_called_from       IN VARCHAR2,
  p_request_id        IN NUMBER DEFAULT NULL,
  p_customer_trx_id   IN NUMBER DEFAULT NULL,
  p_cust_trx_line_id  IN NUMBER DEFAULT NULL,
  p_date_accepted     IN DATE   DEFAULT NULL,
  x_return_status     OUT NOCOPY VARCHAR2,
  x_msg_count         OUT NOCOPY NUMBER,
  x_msg_data          OUT NOCOPY VARCHAR2) IS

  CURSOR rev_lines (p_req_id NUMBER) IS
    SELECT rl.customer_trx_line_id,
           rl.customer_trx_id,
           rl.so_line_id
    FROM   ar_reviewed_lines_gt  rl,
           ra_customer_trx_lines tl
    WHERE  rl.request_id = p_req_id
    AND    tl.customer_trx_line_id = rl.customer_trx_line_id
    AND    tl.customer_trx_id = rl.customer_trx_id
    AND    tl.interface_line_context = g_om_context;

  l_last_fetch                  BOOLEAN;
  l_customer_trx_id_tbl 	number_table;
  l_customer_trx_line_id_tbl	number_table;
  l_so_line_id_tbl       	number_table;

  l_request_rec                 oe_order_pub.request_rec_type;
  l_action_request_tbl          oe_order_pub.request_tbl_type;
  l_init_request_tbl            oe_order_pub.request_tbl_type;

  om_error			EXCEPTION;
  l_request_id                  NUMBER;
BEGIN

  debug('record_acceptance_with_om()+');

  l_action_request_tbl := l_init_request_tbl;

  /* 9476475 - Get the lowest common denominator, as line_id, trx_id, or
     request_id.  The request_id column in the GT is populated
     the same way */
  l_request_id := NVL(p_cust_trx_line_id,
                     NVL(p_customer_trx_id, p_request_id));

  debug('using ' || l_request_id || 'as request_id in join to GT');

  OPEN rev_lines(l_request_id);

  LOOP
    FETCH rev_lines BULK COLLECT INTO
      l_customer_trx_line_id_tbl,
      l_customer_trx_id_tbl,
      l_so_line_id_tbl
    LIMIT c_max_bulk_fetch_size;

    IF rev_lines%NOTFOUND THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('header_rows%NOTFOUND');
      END IF;
      l_last_fetch := TRUE;
    END IF;

    IF l_customer_trx_line_id_tbl.COUNT = 0 AND l_last_fetch THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('No more rows');
      END IF;
      EXIT;
    END IF;

    FOR i IN l_customer_trx_line_id_tbl.FIRST ..
             l_customer_trx_line_id_tbl.LAST LOOP

      -- ACTION REQUEST RECORD for acceptance

      l_request_rec.entity_code  := oe_globals.g_entity_line;
      l_request_rec.entity_id    := l_so_line_id_tbl(i);

      -- action requested
      -- l_request_rec.request_type := oe_globals.g_accept_fulfillment;
      l_request_rec.request_type := 'ACCEPT_FULFILLMENT';

      IF (p_called_from = 'SWEEPER') THEN
         -- implicit
         l_request_rec.param4 := 'Y';
         l_request_rec.date_param1 := sysdate;
      ELSE
        -- explicit
        l_request_rec.param4 := 'N';
        l_request_rec.date_param1 := p_date_accepted;
      END IF;


      -- inserting request record into action request table
      l_action_request_tbl(i) := l_request_rec;

      -- dumping request record contents...
      debug('Row number: '||i);
      debug('entity_code: '||l_action_request_tbl(i).entity_code);
      debug('entity_id: '||l_action_request_tbl(i).entity_id);
      debug('request_type: '||l_action_request_tbl(i).request_type);
      debug('param4: '||l_action_request_tbl(i).param4);
      debug('date_param1: '||l_action_request_tbl(i).date_param1);

    END LOOP;

    debug('Before calling OE_AR_Acceptance_GRP.Process_Acceptance_in_OM....');
    OE_AR_Acceptance_GRP.Process_Acceptance_in_OM(
        p_action_request_tbl => l_action_request_tbl,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data);

    IF x_return_status <> FND_API.g_ret_sts_success THEN
       debug('ERROR....Process_Acceptance_in_OM FAILED..');
       debug('OM return status = '||x_return_status);

       IF x_msg_count = 1 THEN
          debug(x_msg_data);
       ELSIF NVL(x_msg_count,0) = 0 THEN
          debug('No Messages');
       ELSE
          FOR i IN 1..x_msg_count LOOP
             debug(FND_MSG_PUB.get
                          (p_msg_index => i,
                           p_encoded   => FND_API.G_FALSE));
          END LOOP;
       END IF;

       RAISE om_error;
    END IF;

    debug('After calling OE_AR_Acceptance_GRP.Process_Acceptance_in_OM');

  END LOOP;

  debug('record_acceptance_with_om()-');

  EXCEPTION
    WHEN om_error THEN
    debug('ERROR calling OM: record_acceptance_with_om');
    debug(sqlerrm);
    RAISE;
    WHEN OTHERS THEN
    debug('OTHERS: record_acceptance_with_om');
    debug(sqlerrm);
    RAISE;

END record_acceptance_with_om;

/* Bug 4693399 - added customer_trx_line_id for manual invoices */
/* Bug 5843254 - split manual and batch logic to separate IF conditions.
      also added support for REFUND_POLICY as well as REFUND to
      the logic for removing unnecessary contingencies.  Note that
      REFUND is used on the seeded contingency and REFUND_POLICY
      is assigned to new ones. */
PROCEDURE delete_unwanted_contingencies (p_request_id NUMBER
				        ,p_customer_trx_line_id ra_customer_trx_lines.customer_trx_line_id%TYPE) IS

  /* debug cursor */
  CURSOR alc (p_req_id NUMBER, p_line_id NUMBER) IS
     select lc.customer_trx_line_id, lc.contingency_id,
            dr.policy_attached
     from   ar_line_conts lc,
            ar_deferral_reasons dr
     where  lc.contingency_id = dr.contingency_id
     and    ((p_req_id IS NULL and p_line_id IS NOT NULL AND
              lc.customer_trx_line_id = p_line_id) OR
             (p_req_id IS NOT NULL AND lc.request_id = p_req_id));

BEGIN

  /* DEBUG CODE */
  IF PG_DEBUG IN ('Y','C')
  THEN
     debug('delete_unwanted_contingencies()+');
     debug('  p_request_id : ' || p_request_id);
     debug('  p_customer_trx_line_id : ' || p_customer_trx_line_id);

     for c in alc(p_request_id, p_customer_trx_line_id) LOOP
        debug(c.customer_trx_line_id || ':' ||
              c.contingency_id || ':' ||
              c.policy_attached);
     end loop;
  END IF;
  /* END DEBUG CODE */

  -- The existence of refund clause does not necessarily mean
  -- the revenue should be deferred.  We should check the
  -- duration against the refund policy in the revenue policy
  -- tabs in the system options form.

  IF p_request_id IS NOT NULL
  THEN
     /* batch process, based on request_id */

     DELETE
     FROM   ar_line_conts lrc
     WHERE  customer_trx_line_id IN
        (SELECT customer_trx_line_id
         FROM   ra_customer_trx_lines ctl
         WHERE  ctl.request_id = p_request_id)
     AND    trunc(expiration_date) - trunc(sysdate) <
               NVL(arp_standard.sysparm.standard_refund,0)
     AND EXISTS
        (SELECT 'its a refund contingency'
         FROM   ar_deferral_reasons dr
         WHERE  dr.contingency_id = lrc.contingency_id
         AND    dr.policy_attached in ('REFUND','REFUND_POLICY'));

     debug('refund contingencies deleted: ' || SQL%ROWCOUNT);

  -- The existence of customer credit contingency does not necessarily
  -- mean the revenue should be deferred.  We should check the
  -- duration against the refund policy in the revenue policy
  -- tabs in the system options form.

     DELETE
     FROM   ar_line_conts lc
     WHERE  lc.customer_trx_line_id IN
         (SELECT customer_trx_line_id
          FROM   ra_customer_trx_lines ctl,
                 ra_customer_trx ct
          WHERE  ctl.customer_trx_id = ct.customer_trx_id
          AND    ctl.request_id = p_request_id
          AND    ar_revenue_management_pvt.creditworthy
                   (ct.bill_to_customer_id, ct.bill_to_site_use_id)= 1)
     AND EXISTS
        (SELECT 'its a CREDIT_CLASSIFICATION'
         FROM   ar_deferral_reasons dr
         WHERE  dr.contingency_id =  lc.contingency_id
         AND    dr.policy_attached = 'CREDIT_CLASSIFICATION');

     IF PG_DEBUG IN ('Y','C')
     THEN
        debug('customer credit contingencies deleted: ' || SQL%ROWCOUNT);
     END IF;

  -- The existence of payment term contingency does not necessarily mean
  -- the revenue should be deferred.  We should check the
  -- duration against the refund policy in the revenue policy
  -- tabs in the system options form.

     DELETE
     FROM   ar_line_conts lc
     WHERE  lc.customer_trx_line_id IN
         (SELECT customer_trx_line_id
          FROM   ra_customer_trx_lines ctl,
                 ra_customer_trx       ct,
                 ra_terms_lines        tl
          WHERE  ctl.customer_trx_id = ct.customer_trx_id
          AND    ct.term_id = tl.term_id
          AND    ctl.request_id = p_request_id
          GROUP BY ctl.customer_trx_line_id, tl.term_id
          HAVING  NVL(max(due_days),0) <=
             NVL(arp_standard.sysparm.payment_threshold,0))
     AND  EXISTS
         (SELECT 'its a PAYMENT_TERM'
          FROM   ar_deferral_reasons dr
          WHERE  dr.policy_attached = 'PAYMENT_TERM'
          AND    dr.contingency_id = lc.contingency_id);

     IF PG_DEBUG IN ('Y','C')
     THEN
        debug('payment term contingencies deleted: ' || SQL%ROWCOUNT);
     END IF;

  -- Revenue management should ignore lines with deferred accounting rules
  -- attached to it.  It is possible to add this logic in all the insert
  -- statements but that would mean adding an outer join, since not all
  -- lines have accounting rules.  So, I decided against it and made it
  -- simpler by deleting the rows.

  /* 5452544 - breaking sql into separate sections for interactive
      and batch processing */
     DELETE from ar_line_conts
     WHERE customer_trx_line_id IN
        (SELECT customer_trx_line_id
         FROM   ra_customer_trx_lines ctl,
                ra_rules r
         WHERE  ctl.request_id = p_request_id
         AND    ctl.accounting_rule_id IS NOT NULL
         AND    ctl.accounting_rule_id = r.rule_id
         AND    r.deferred_revenue_flag = 'Y');

     IF PG_DEBUG IN ('Y','C')
     THEN
        debug('contingencies for lines with deferred rule deleted: ' ||
           SQL%ROWCOUNT);
     END IF;
  ELSE
     /* manual process, based on customer_trx_line_id */
     DELETE
     FROM   ar_line_conts lrc
     WHERE  trunc(expiration_date) - trunc(sysdate) <
            NVL(arp_standard.sysparm.standard_refund,0)
     AND    lrc.customer_trx_line_id = p_customer_trx_line_id
     AND    EXISTS
            (SELECT 'a refund contingency'
             FROM   ar_deferral_reasons dr
             WHERE  dr.policy_attached in ('REFUND','REFUND_POLICY')
             AND    dr.contingency_id = lrc.contingency_id);

     debug('refund contingencies deleted: ' || SQL%ROWCOUNT);

  -- The existence of customer credit contingency does not necessarily
  -- mean the revenue should be deferred.  We should check the
  -- duration against the refund policy in the revenue policy
  -- tabs in the system options form.

     DELETE
     FROM   ar_line_conts lc
     WHERE  lc.customer_trx_line_id = p_customer_trx_line_id
     AND EXISTS
         (SELECT 'its a credit_classification contingency'
          FROM   ar_deferral_reasons dr
          WHERE  dr.contingency_id =  lc.contingency_id
          AND    dr.policy_attached = 'CREDIT_CLASSIFICATION')
     AND EXISTS
         (SELECT 'customer is not credit worthy'
          FROM   ra_customer_trx_lines ctl,
                 ra_customer_trx ct
          WHERE  ctl.customer_trx_id = ct.customer_trx_id
          AND    ctl.customer_trx_line_id = p_customer_trx_line_id
          AND    ar_revenue_management_pvt.creditworthy
                   (ct.bill_to_customer_id, ct.bill_to_site_use_id)= 1);

     IF PG_DEBUG IN ('Y','C')
     THEN
        debug('customer credit contingencies deleted: ' || SQL%ROWCOUNT);
     END IF;

  -- The existence of payment term contingency does not necessarily mean
  -- the revenue should be deferred.  We should check the
  -- duration against the refund policy in the revenue policy
  -- tabs in the system options form.

     DELETE
     FROM   ar_line_conts lc
     WHERE  lc.customer_trx_line_id = p_customer_trx_line_id
     AND EXISTS
         (SELECT 'it is a term contingency'
          FROM   ar_deferral_reasons dr
          WHERE  dr.policy_attached = 'PAYMENT_TERM'
          AND    dr.contingency_id = lc.contingency_id)
     AND EXISTS
         (SELECT 'term exceeds threshold'
          FROM   ra_customer_trx_lines ctl,
                 ra_customer_trx       ct,
                 ra_terms_lines        tl
          WHERE  ctl.customer_trx_id = ct.customer_trx_id
          AND    ct.term_id = tl.term_id
          AND    ctl.customer_trx_line_id = lc.customer_trx_line_id
          GROUP BY ctl.customer_trx_line_id, tl.term_id
          HAVING  NVL(max(due_days),0) <=
             NVL(arp_standard.sysparm.payment_threshold,0));

     IF PG_DEBUG IN ('Y','C')
     THEN
        debug('payment term contingencies deleted: ' || SQL%ROWCOUNT);
     END IF;

  -- Revenue management should ignore lines with deferred accounting rules
  -- attached to it.  It is possible to add this logic in all the insert
  -- statements but that would mean adding an outer join, since not all
  -- lines have accounting rules.  So, I decided against it and made it
  -- simpler by deleting the rows.

  /* 5452544 - breaking sql into separate sections for interactive
      and batch processing */
     DELETE FROM AR_LINE_CONTS A
     WHERE A.customer_trx_line_id = p_customer_trx_line_id
     AND   EXISTS (SELECT 'DEFERRED RULE'
                   FROM   ra_customer_trx_lines ctl,
                          ra_rules r
                   WHERE  ctl.customer_trx_line_id = A.customer_trx_line_id
                   AND    ctl.accounting_rule_id = r.rule_id
                   AND    r.deferred_revenue_flag = 'Y');

     IF PG_DEBUG IN ('Y','C')
     THEN
        debug('contingencies for lines with deferred rule deleted: ' ||
        SQL%ROWCOUNT);
     END IF;

  END IF;

  /* For imported transactions, remove contingencies if
      the imported lines are rejected by validations */
  IF (g_source = 'AR_INVOICE_API') THEN

    DELETE
    FROM ar_line_conts
    WHERE customer_trx_line_id IN
          (SELECT  customer_trx_line_id
           FROM    ar_trx_errors_gt teg,
                   ar_trx_lines_gt  tlg
           WHERE   teg.trx_header_id = tlg.trx_header_id
           AND     teg.trx_line_id   = tlg.trx_line_id
           AND     request_id = p_request_id);

  ELSIF p_request_id IS NOT NULL THEN

    DELETE
    FROM ar_line_conts
    WHERE customer_trx_line_id IN
          (SELECT ie.interface_line_id
           FROM    ra_interface_errors ie
           WHERE   request_id = p_request_id);

  END IF;

  IF PG_DEBUG IN ('Y','C')
  THEN
    debug('delete_unwanted_contingencies()-');
  END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: delete_unwanted_contingencies');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: delete_unwanted_contingencies');
      debug(sqlerrm);
      RAISE;

END delete_unwanted_contingencies;

/* This function returns the customer_trx_line_id of the parent line
    after fetching the attribute values from OM */
FUNCTION  get_line_id(p_so_line_id IN NUMBER) RETURN NUMBER IS
   l_line_flex_rec    ar_deferral_reasons_grp.line_flex_rec;
   l_return_status    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(2000);
   l_customer_trx_line_id   ra_customer_trx_lines_all.customer_trx_line_id%type;
BEGIN
     /* Call OM to get the DFF attributes for the parent line */
        OE_AR_Acceptance_GRP.Get_interface_attributes
                (p_line_id       => p_so_line_id,
                 x_line_flex_rec => l_line_flex_rec,
                 x_return_status => l_return_status,
                 x_msg_count     => l_msg_count,
                 x_msg_data      => l_msg_data);

     /* Now get the customer_trx_line_id of the parent */
     IF l_return_status = FND_API.G_RET_STS_SUCCESS
     THEN

        /* OM responded with the attributes, use them to go
            get the line id of the parent invoice line.  Note that
            this routine only returns the first 6 even though as
            many as 14 are used regularly by OM */

        /* 5622095 - limit return to only the row that has
           interface_line_attribute11 = '0'.  */

        /* 9037071 - Handle ORA-1422 by making join intentionally
           pick the first line that matches that criteria and
           has zeros in attribute11 and 14 */
        BEGIN
        SELECT MIN(customer_trx_line_id)
        INTO   l_customer_trx_line_id
        FROM   RA_CUSTOMER_TRX_LINES
        WHERE  interface_line_context    = l_line_flex_rec.interface_line_context
        AND    interface_line_attribute1 = l_line_flex_rec.interface_line_attribute1
        AND    interface_line_attribute2 = l_line_flex_rec.interface_line_attribute2
        AND    interface_line_attribute3 = l_line_flex_rec.interface_line_attribute3
        AND    interface_line_attribute4 = l_line_flex_rec.interface_line_attribute4
        AND    interface_line_attribute5 = l_line_flex_rec.interface_line_attribute5
        AND    interface_line_attribute6 = l_line_flex_rec.interface_line_attribute6
        AND    interface_line_attribute11 = '0'
        AND    interface_line_attribute14 = '0';

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
             debug('unable to locate matching line in ra_customer_trx_lines');
             l_customer_trx_line_id := -98;
        END;
     ELSE
        /* OM responded with an error
           return a bogus value so no joins are made */
        debug('unable to find parent line for so_line_id=' || p_so_line_id);
        l_customer_trx_line_id := -99;
     END IF;

     RETURN l_customer_trx_line_id;

END get_line_id;

PROCEDURE copy_parent_contingencies (p_request_id NUMBER) IS

  l_user_id NUMBER;
  l_exists  NUMBER := 0;

BEGIN

  debug('copy_parent_contingencies()+');
  debug('  p_request_id : ' || p_request_id);

  l_user_id := fnd_global.user_id;

  /* 5513146 - Check for lines in interface table before
     executing the INSERT.  */
  SELECT 1
  INTO   l_exists
  FROM   dual
  WHERE EXISTS (select 'at least one child'
                from   RA_INTERFACE_LINES il
                where  il.request_id = p_request_id
                and    il.parent_line_id is not null);

  IF l_exists <> 0
  THEN
    INSERT INTO ar_line_conts
    (
      customer_trx_line_id,
      contingency_id,
      contingency_code,
      expiration_date,
      expiration_days,
      expiration_event_date,
      reason_removal_date,
      completed_flag,
      defaulted_in_ar_flag,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      org_id
    )
    SELECT
      ctl.customer_trx_line_id,
      plc.contingency_id,
      plc.contingency_id,
      plc.expiration_date,
      plc.expiration_days,
      plc.expiration_event_date,
      plc.reason_removal_date,
      plc.completed_flag,
      'C',  -- indicates it was copied, not defaulted or imported
      p_request_id,
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      plc.org_id
    FROM   ra_customer_trx       ct,
           ra_customer_trx_lines ctl,
           ra_cust_trx_types     ctt,
           ra_interface_lines    il,
           ar_line_conts         plc
    WHERE  ct.request_id = p_request_id
    AND    ct.cust_trx_type_id = ctt.cust_trx_type_id
    AND    ctt.type = 'INV'
    AND    ct.customer_trx_id = ctl.customer_trx_id
    AND    ctl.line_type = 'LINE'
    AND    il.interface_line_id = ctl.customer_trx_line_id
    AND    il.parent_line_id IS NOT NULL
    AND    plc.customer_trx_line_id = get_line_id(il.parent_line_id)
    AND    NOT EXISTS (
         SELECT 'contingency already applied'
         FROM   ar_line_conts clc
         WHERE  clc.customer_trx_line_id = ctl.customer_trx_line_id
         AND    clc.contingency_code = plc.contingency_id);

    debug('rows copied ar_line_conts: ' || SQL%ROWCOUNT);

  END IF; -- end of l_exists condition

  debug('copy_parent_contingencies()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('  No child contingencies to copy');
      debug('copy_parrent_contingencies()-');
      RETURN;

    WHEN OTHERS THEN
      debug('OTHERS: copy_parent_contingencies');
      debug(sqlerrm);
      RAISE;

END copy_parent_contingencies;

/* Bug 4693399 - added customer_trx_line_id for manual invoices */
/* 5236506 - Do not default post or pre billing customer acceptance
    contingencies on OM lines */
PROCEDURE default_contingencies (p_request_id NUMBER
				,p_customer_trx_line_id ra_customer_trx_lines.customer_trx_line_id%TYPE) IS

  l_user_id NUMBER;

BEGIN

  debug('default_contingencies()+');
  debug('  p_request_id : ' || p_request_id);
  debug('  p_customer_trx_line_id : ' || p_customer_trx_line_id);

  /* 4521577 - Payment term and credit classifications need to be set
     first.  We'll remove them later if they are expired or
     not needed */

  /* 8889297 - Only call term and creditworthiness if
     those values are set in system options table */
  IF arp_standard.sysparm.payment_threshold IS NOT NULL
  THEN
     insert_term_contingencies(p_request_id, p_customer_trx_line_id);
  END IF;

  IF (arp_standard.sysparm.credit_classification1 IS NOT NULL OR
      arp_standard.sysparm.credit_classification2 IS NOT NULL OR
      arp_standard.sysparm.credit_classification3 IS NOT NULL)
  THEN
     insert_credit_contingencies(p_request_id, p_customer_trx_line_id);
  END IF;

IF p_request_id IS NULL AND
          p_customer_trx_line_id IS NOT NULL THEN
   INSERT INTO ar_rdr_parameters_gt
  (
    source_line_id,
    batch_source_id,
    profile_class_id,
    cust_account_id,
    cust_acct_site_id,
    cust_trx_type_id,
    -- item_category_id,  (xportal issue logged)
    inventory_item_id,
    memo_line_id,
    org_id,
    accounting_rule_id,
    ship_to_cust_acct_id,
    ship_to_site_use_id
  )
  SELECT
    ctl.customer_trx_line_id,
    ct.batch_source_id,
    decode(ctl.deferral_exclusion_flag, 'Y','',
           decode(hcp.cust_account_id,'','',
                  decode(hcp.site_use_id,'','',
                         hcp.profile_class_id))),
    ct.bill_to_customer_id,
    ct.bill_to_site_use_id,
    ctt.cust_trx_type_id,
    -- item_category_id
    ctl.inventory_item_id,
    ctl.memo_line_id,
    ct.org_id,
    ctl.accounting_rule_id,
    NVL(ctl.ship_to_customer_id,ct.ship_to_customer_id),
    NVL(ctl.ship_to_site_use_id,ct.ship_to_site_use_id)
 FROM
    ra_customer_trx ct,
    ra_customer_trx_lines ctl,
    hz_customer_profiles hcp,
    ra_cust_trx_types ctt
  WHERE (ctl.customer_trx_line_id = p_customer_trx_line_id)
  AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
  AND   ctt.type = 'INV'
  AND   ct.customer_trx_id = ctl.customer_trx_id
  AND   ctl.line_type = 'LINE'
  AND   ct.bill_to_customer_id = hcp.cust_account_id (+)
  AND   ct.bill_to_site_use_id = NVL(hcp.site_use_id, ct.bill_to_site_use_id )
  AND   nvl(ctl.deferral_exclusion_flag, 'N')  <> 'Y';

ELSIF p_request_id IS NOT NULL THEN

    INSERT INTO ar_rdr_parameters_gt
  (
    source_line_id,
    batch_source_id,
   profile_class_id,
    cust_account_id,
    cust_acct_site_id,
    cust_trx_type_id,
    -- item_category_id,  (xportal issue logged)
    inventory_item_id,
    memo_line_id,
    org_id,
    accounting_rule_id,
    ship_to_cust_acct_id,
    ship_to_site_use_id
  )
  SELECT
    ctl.customer_trx_line_id,
    ct.batch_source_id,
 decode(ctl.deferral_exclusion_flag, 'Y','',
           decode(hcp.cust_account_id,'','',
                  decode(hcp.site_use_id,'','',
                         hcp.profile_class_id))),
    ct.bill_to_customer_id,
    ct.bill_to_site_use_id,
    ctt.cust_trx_type_id,
    -- item_category_id
    ctl.inventory_item_id,
    ctl.memo_line_id,
    ct.org_id,
    ctl.accounting_rule_id,
    NVL(ctl.ship_to_customer_id,ct.ship_to_customer_id),
    NVL(ctl.ship_to_site_use_id,ct.ship_to_site_use_id)
 FROM
    ra_customer_trx ct,
    ra_customer_trx_lines ctl,
    hz_customer_profiles hcp,
    ra_cust_trx_types ctt
  WHERE ct.request_id = p_request_id
  AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
  AND   ctt.type = 'INV'
  AND   ct.customer_trx_id = ctl.customer_trx_id
  AND   ctl.line_type = 'LINE'
  AND   ct.bill_to_customer_id = hcp.cust_account_id (+)
  AND   ct.bill_to_site_use_id = nvl(hcp.site_use_id, ct.bill_to_site_use_id)
  AND   nvl(ctl.deferral_exclusion_flag, 'N')  <> 'Y';

END IF;

  debug('rows inserted in rule gt: ' || SQL%ROWCOUNT);
  /*
    Calling Hook Procedure to populate the attribute columns
  */
  AR_CUSTOM_PARAMS_HOOK_PKG.populateContingencyAttributes();

  fun_rule_pub.apply_rule_bulk (
    p_application_short_name  => 'AR',
    p_rule_object_name        => c_rule_object_name,
    p_param_view_name         => 'AR_RDR_PARAMETERS_GT',
    p_additional_where_clause => '1=1',
    p_primary_key_column_name => 'SOURCE_LINE_ID'
  );

  debug('returned after the call to fun_rules_pub.apply_rule_bulk');

  l_user_id := fnd_global.user_id;

  /* As from R12 contingency_id replaces contingency_code as the unique
     identifier along with customer_trx_line_id, but remains part of the key
     so to avoid a case change we populate contingency_code with contingency_id
  */

  /* 5236506 - added where clause condition to exclude the defaulting
     of specific contingencies for OM transactions.  To do this, we
     exclude the insert if the interface_line_context = g_om_context
     and the contingency revrec_event_code in (INVOICING or CUSTOMER_ACCE.)
     INVOICING is really 'pre-billing customer acceptance' and
     CUSTOMER_ACCEPTANCE is 'post-billing customer acceptance'.
  */

  /* 5222197 - Fix from 5236506 caused problems when transactions had
     no context specified.  Need to NVL that column to insure that
     the condition defaults to false */

  /* 5201842 - Added code to populate expiration_date, and
     expiration_event_date */

  /* 7039838 - conditionally call insert based on parameters */

  IF p_request_id IS NOT NULL
  THEN
    /* Modified logic for autoinvoice */
    INSERT INTO ar_line_conts
    (
      customer_trx_line_id,
      contingency_code,
      contingency_id,
      expiration_date,
      expiration_days,
      expiration_event_date,
      reason_removal_date,
      completed_flag,
      defaulted_in_ar_flag,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      org_id
    )
    SELECT  /*+ leading(rbr,ctl) use_hash(ctl)
                index(ctl,RA_CUSTOMER_TRX_LINES_N4) */
      rbr.id,
      dr.contingency_id,
      dr.contingency_id,
      decode(dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(ct.trx_date)
           + nvl(dr.expiration_days, 0),
        'SHIP_CONFIRM_DATE', trunc(ct.ship_date_actual)
           + nvl(dr.expiration_days, 0), NULL),
      MAX(expiration_days),
      decode(dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(ct.trx_date),
        'SHIP_CONFIRM_DATE', trunc(ct.ship_date_actual), NULL),
        decode(MAX(dr.expiration_event_code), 'INVOICING', sysdate, NULL)
      reason_removal_date,
        decode(MAX(dr.expiration_event_code), 'INVOICING', 'Y', 'N')
      completed_flag,
      'Y',
      p_request_id,
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      ct.org_id
    FROM fun_rule_bulk_result_gt rbr,
         ar_deferral_reasons      dr,
         ra_customer_trx_lines    ctl,
         ra_customer_trx          ct,
         ra_cust_trx_types        ctt
    WHERE rbr.result_value = dr.contingency_id
    AND   rbr.id = ctl.customer_trx_line_id
    AND   ctl.customer_trx_id    = ct.customer_trx_id
    AND   ctl.request_id = p_request_id               -- 7039838
    AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
    AND   ctt.type = 'INV'
    AND   ctl.line_type = 'LINE'
    AND   ct.batch_source_id NOT IN (20, 21)
    AND   sysdate BETWEEN NVL(dr.start_date,SYSDATE) AND
                          NVL(dr.end_date,SYSDATE)
    AND NOT (NVL(ctl.interface_line_context,'##NOT_MATCH##') = g_om_context AND
             dr.revrec_event_code in ('INVOICING','CUSTOMER_ACCEPTANCE'))
    AND NOT EXISTS
        ( SELECT 'contingency exists'
          FROM    ar_line_conts lc
          WHERE   lc.customer_trx_line_id = rbr.id
          AND     lc.contingency_id = rbr.result_value
        )
    GROUP BY rbr.id, dr.contingency_id, dr.expiration_event_code,
             dr.expiration_days, ct.org_id, ct.trx_date, ct.ship_date_actual;

  ELSE
    /* original logic */
    INSERT INTO ar_line_conts
    (
      customer_trx_line_id,
      contingency_code,
      contingency_id,
      expiration_date,
      expiration_days,
      expiration_event_date,
      reason_removal_date,
      completed_flag,
      defaulted_in_ar_flag,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      org_id
    )
    SELECT
      rbr.id,
      dr.contingency_id,
      dr.contingency_id,
      decode(dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(ct.trx_date)
           + nvl(dr.expiration_days, 0),
        'SHIP_CONFIRM_DATE', trunc(ct.ship_date_actual)
           + nvl(dr.expiration_days, 0), NULL),
      MAX(expiration_days),
      decode(dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(ct.trx_date),
        'SHIP_CONFIRM_DATE', trunc(ct.ship_date_actual), NULL),
        decode(MAX(dr.expiration_event_code), 'INVOICING', sysdate, NULL)
      reason_removal_date,
        decode(MAX(dr.expiration_event_code), 'INVOICING', 'Y', 'N')
      completed_flag,
      'Y',
      p_request_id,
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      l_user_id,
      ct.org_id
    FROM fun_rule_bulk_result_gt rbr,
         ar_deferral_reasons      dr,
         ra_customer_trx_lines    ctl,
         ra_customer_trx          ct,
         ra_cust_trx_types        ctt
    WHERE rbr.result_value = dr.contingency_id
    AND   rbr.id = ctl.customer_trx_line_id
    AND   ctl.customer_trx_id    = ct.customer_trx_id
    AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
    AND   ctt.type = 'INV'
    AND   ctl.line_type = 'LINE'
    AND   ct.batch_source_id NOT IN (20, 21)
    AND   sysdate BETWEEN NVL(dr.start_date,SYSDATE) AND
                          NVL(dr.end_date,SYSDATE)
    AND NOT (NVL(ctl.interface_line_context,'##NOT_MATCH##') = g_om_context AND
             dr.revrec_event_code in ('INVOICING','CUSTOMER_ACCEPTANCE'))
    AND NOT EXISTS
        ( SELECT 'contingency exists'
          FROM    ar_line_conts lc
          WHERE   lc.customer_trx_line_id = rbr.id
          AND     lc.contingency_id = rbr.result_value
        )
    GROUP BY rbr.id, dr.contingency_id, dr.expiration_event_code,
             dr.expiration_days, ct.org_id, ct.trx_date, ct.ship_date_actual;

  END IF; -- end p_request_id

  debug('rows inserted ar_line_conts: ' || SQL%ROWCOUNT);
  debug('default_contingencies()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: default_contingencies');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: default_contingencies');
      debug(sqlerrm);
      RAISE;

END default_contingencies;

PROCEDURE insert_contingencies_from_gt (p_request_id NUMBER) IS

  l_user_id NUMBER;

BEGIN

  debug('insert_contingencies_from_gt()+');
  debug(' p_request_id : ' || p_request_id);

  l_user_id := fnd_global.user_id;

  -- invoice creation api uses global temporary tables to accept
  -- input data as opposed to interface tables.

  /* As from R12 contingency_id replaces contingency_code as the unique
     identifier along with customer_trx_line_id, but remains part of the key
     so to avoid a case change we populate contingency_code with contingency_id
  */

  INSERT INTO ar_line_conts
  (
    customer_trx_line_id,
    contingency_id,
    contingency_code,
    expiration_date,
    expiration_days,
    expiration_event_date,
    reason_removal_date,
    completed_flag,
    completed_by,
    request_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login,
    org_id
  )
  SELECT
    tlg.customer_trx_line_id,
    tcg.contingency_id,
    tcg.contingency_id,
      nvl(trunc(tcg.expiration_date), decode(dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(thg.trx_date)
           + nvl(tcg.expiration_days, nvl(dr.expiration_days, 0)),
        'SHIP_CONFIRM_DATE', trunc(thg.ship_date_actual)
           + nvl(tcg.expiration_days, nvl(dr.expiration_days, 0)), NULL))
    expiration_date,
    nvl(tcg.expiration_days, dr.expiration_days) expiration_days,
      decode( dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(thg.trx_date),
        'SHIP_CONFIRM_DATE', trunc(thg.ship_date_actual),  NULL)
    expiration_event_date,
      decode(revrec_event_code, 'INVOICING',
        NVL(expiration_date, sysdate), NULL) reason_removal_date,
      decode(revrec_event_code, 'INVOICING', 'Y',nvl(completed_flag, 'N'))
    completed_flag,
      decode(revrec_event_code, 'INVOICING', completed_by, NULL)
    completed_by,
    tlg.request_id,
    l_user_id,
    sysdate,
    l_user_id,
    sysdate,
    l_user_id,
    thg.org_id
  FROM ar_trx_lines_gt            tlg,
       ar_trx_header_gt           thg,
       ra_cust_trx_types          ctt,
       ar_trx_contingencies_gt    tcg,
       ar_deferral_reasons        dr
  WHERE tlg.request_id = p_request_id
  AND   tlg.trx_header_id = thg.trx_header_id
  AND   thg.batch_source_id NOT IN (20, 21)
  AND   thg.cust_trx_type_id = ctt.cust_trx_type_id
  AND   ctt.type = 'INV'
  AND   tlg.line_type = 'LINE'
  AND   tlg.trx_line_id = tcg.trx_line_id
  AND   tcg.contingency_id = dr.contingency_id
  AND   NOT EXISTS
        ( SELECT 'errors exist'
          FROM    ar_trx_errors_gt err
          WHERE   err.trx_header_id = tlg.trx_header_id
          AND     err.trx_line_id   = tlg.trx_line_id
        );

  debug('gt contingencies inserted: ' || SQL%ROWCOUNT);
  debug('insert_contingencies_from_gt()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: insert_contingencies_from_gt');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: insert_contingencies_from_gt');
      debug(sqlerrm);
      RAISE;

END insert_contingencies_from_gt;


PROCEDURE insert_contingencies_from_itf (p_request_id NUMBER) IS

  l_user_id       NUMBER;

BEGIN

  debug('insert_contingencies_from_itf()+');
  debug( ' p_request_id : ' || p_request_id);

  l_user_id := fnd_global.user_id;

  -- now we are about to process the contingencies passed through the
  -- ar_interface_contingencies_all before we do that we have retrieve
  -- the context and using that determing the dynamic portion of
  -- where clause.

  /* As from R12 contingency_id replaces contingency_code as the unique
     identifier along with customer_trx_line_id, but remains part of the key
     so to avoid a case change we populate contingency_code with contingency_id
  */

  INSERT INTO ar_line_conts
  (
    customer_trx_line_id,
    contingency_id,
    contingency_code,
    expiration_date,
    expiration_days,
    expiration_event_date,
    reason_removal_date,
    completed_flag,
    completed_by,
    request_id,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    org_id
  )
  SELECT
    ctl.customer_trx_line_id,
    ic.contingency_id,
    ic.contingency_id,
      nvl(trunc(expiration_date), decode(dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(ct.trx_date)
           + nvl(ic.expiration_days, nvl(dr.expiration_days, 0)),
        'SHIP_CONFIRM_DATE', trunc(ct.ship_date_actual)
           + nvl(ic.expiration_days, nvl(dr.expiration_days, 0)), NULL))
    expiration_date,
    nvl(ic.expiration_days, dr.expiration_days) expiration_days,
      decode( dr.expiration_event_code,
        'TRANSACTION_DATE', trunc(ct.trx_date),
        'SHIP_CONFIRM_DATE', trunc(ct.ship_date_actual),  NULL)
    expiration_event_date,
      decode(revrec_event_code, 'INVOICING',
        nvl(expiration_date, sysdate),
          DECODE(NVL(completed_flag, 'N'),'Y',
             NVL(expiration_date,sysdate), NULL))
    reason_removal_date,
      decode(revrec_event_code, 'INVOICING', 'Y',nvl(completed_flag, 'N'))
    completed_flag,
      decode(revrec_event_code, 'INVOICING', completed_by, NULL)
    completed_by,
    ctl.request_id,
    l_user_id,
    sysdate,
    l_user_id,
    sysdate,
    ct.org_id
  FROM ra_customer_trx_lines      ctl,
       ra_customer_trx            ct,
       ra_cust_trx_types          ctt,
       ar_interface_conts         ic,
       ar_deferral_reasons        dr
  WHERE ctl.request_id = p_request_id
  AND   ctl.customer_trx_id    = ct.customer_trx_id
  AND   ct.batch_source_id NOT IN (20, 21)
  AND   ct.cust_trx_type_id = ctt.cust_trx_type_id
  AND   ctt.type = 'INV'
  AND   ctl.line_type = 'LINE'
  AND   ctl.customer_trx_line_id = ic.interface_line_id
  AND   ic.contingency_id = dr.contingency_id
  AND   NOT EXISTS
        (SELECT 'errors'
         FROM    ra_interface_errors ie
         WHERE   ie.interface_line_id = ctl.customer_trx_line_id);

  debug('itf contingencies inserted: ' || SQL%ROWCOUNT);
  debug('insert_contingencies_from_itf()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: insert_contingencies_from_itf');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: insert_contingencies_from_itf');
      debug(sqlerrm);
      RAISE;

END insert_contingencies_from_itf;

/* Bug 4693399 - added customer_trx_line_id for manual invoices */
PROCEDURE insert_deferred_lines (p_request_id NUMBER
				,p_customer_trx_line_id ra_customer_trx_lines.customer_trx_line_id%TYPE) IS

  l_user_id NUMBER;
  l_insert_stmt   VARCHAR2(4000);
  l_where_clause  VARCHAR2(4000);

BEGIN

  debug('insert_deferred_lines()+');
  debug('p_request_id : ' || p_request_id);
  debug('p_customer_trx_line_id : ' || p_customer_trx_line_id);

  l_user_id := fnd_global.user_id;

  -- please note we are joining with ar_line_conts
  -- becuase we want to insert rows in the parent table only if
  -- there exists a row in the child table.

  IF (g_source = 'AR_INVOICE_API') THEN

    INSERT INTO ar_deferred_lines
    (
      customer_trx_line_id,
      customer_trx_id,
      original_collectibility_flag,
      line_collectible_flag,
      manual_override_flag,
      amount_due_original,
      acctd_amount_due_original,
      amount_recognized,
      acctd_amount_recognized,
      amount_pending,
      acctd_amount_pending,
      parent_line_id,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      org_id
    )
    SELECT
      tlg.customer_trx_line_id,
      MAX(thg.customer_trx_id),
     'N',
     'N',
     'N',
      MAX(tlg.extended_amount),
      MAX(decode(g_minimum_accountable_unit_f, NULL,
        ROUND( tlg.extended_amount * nvl(thg.exchange_rate, 1),
          g_precision_f),
        ROUND((tlg.extended_amount * nvl(thg.exchange_rate, 1))
          / g_minimum_accountable_unit_f) * g_minimum_accountable_unit_f)),
      0,
      0,
      0,
      0,
      MAX(tlg.parent_line_id),
      MAX(tcg.attribute_category),
      MAX(tcg.attribute1),
      MAX(tcg.attribute2),
      MAX(tcg.attribute3),
      MAX(tcg.attribute4),
      MAX(tcg.attribute5),
      MAX(tcg.attribute6),
      MAX(tcg.attribute7),
      MAX(tcg.attribute8),
      MAX(tcg.attribute9),
      MAX(tcg.attribute10),
      MAX(tcg.attribute11),
      MAX(tcg.attribute12),
      MAX(tcg.attribute13),
      MAX(tcg.attribute14),
      MAX(tcg.attribute15),
      MAX(tlg.request_id),
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      thg.org_id
    FROM ar_trx_header_gt           thg,
         ar_trx_lines_gt            tlg,
         ar_trx_contingencies_gt    tcg,
         ar_line_conts  lrc
    WHERE tlg.request_id = p_request_id
    AND   tlg.customer_trx_id = thg.customer_trx_id
    AND   tlg.customer_trx_line_id = lrc.customer_trx_line_id
    AND   tlg.trx_header_id = tcg.trx_header_id
    AND   tlg.trx_line_id = tcg.trx_line_id
    GROUP BY tlg.customer_trx_line_id, thg.org_id;

    -- do the same for contingencies that are generated in this program
    -- not passed through the GT.  The reason we can't do this with one SQL
    -- is because we would like to copy the values passed in the attributes
    -- columns.

    INSERT INTO ar_deferred_lines
    (
      customer_trx_line_id,
      customer_trx_id,
      original_collectibility_flag,
      line_collectible_flag,
      manual_override_flag,
      amount_due_original,
      acctd_amount_due_original,
      amount_recognized,
      acctd_amount_recognized,
      amount_pending,
      acctd_amount_pending,
      parent_line_id,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      org_id
    )
    SELECT
      tlg.customer_trx_line_id,
      MAX(thg.customer_trx_id),
     'N',
     'N',
     'N',
      MAX(tlg.extended_amount),
      MAX(decode(g_minimum_accountable_unit_f, NULL,
        ROUND( tlg.extended_amount * nvl(thg.exchange_rate, 1),
          g_precision_f),
        ROUND((tlg.extended_amount * nvl(thg.exchange_rate, 1))
          / g_minimum_accountable_unit_f) * g_minimum_accountable_unit_f)),
      0,
      0,
      0,
      0,
      MAX(tlg.parent_line_id),
      MAX(tlg.request_id),
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      thg.org_id
    FROM ar_trx_header_gt           thg,
         ar_trx_lines_gt            tlg,
         ar_line_conts  lrc
    WHERE tlg.request_id = p_request_id
    AND   tlg.customer_trx_id = thg.customer_trx_id
    AND   tlg.customer_trx_line_id = lrc.customer_trx_line_id
    AND NOT EXISTS
      (SELECT 'line already inserted'
       FROM   ar_deferred_lines dl
       WHERE  dl.customer_trx_line_id = lrc.customer_trx_line_id)
    GROUP BY tlg.customer_trx_line_id, thg.org_id;

  ELSE
    IF p_request_id IS NOT NULL THEN
    INSERT INTO ar_deferred_lines
    (
      customer_trx_line_id,
      customer_trx_id,
      original_collectibility_flag,
      line_collectible_flag,
      manual_override_flag,
      amount_due_original,
      acctd_amount_due_original,
      amount_recognized,
      acctd_amount_recognized,
      amount_pending,
      acctd_amount_pending,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      org_id,
      parent_line_id
      )
      SELECT
      ctl.customer_trx_line_id,
      MAX(ct.customer_trx_id),
     'N',
     'N',
     'N',
      MAX(ctl.extended_amount),
      MAX(decode(g_minimum_accountable_unit_f, NULL,
        ROUND( ctl.extended_amount * nvl(ct.exchange_rate, 1),
          g_precision_f),
        ROUND((ctl.extended_amount * nvl(ct.exchange_rate, 1))
          / g_minimum_accountable_unit_f) * g_minimum_accountable_unit_f)),
      0,
      0,
      0,
      0,
      MAX(ic.attribute_category),
      MAX(ic.attribute1),
      MAX(ic.attribute2),
      MAX(ic.attribute3),
      MAX(ic.attribute4),
      MAX(ic.attribute5),
      MAX(ic.attribute6),
      MAX(ic.attribute7),
      MAX(ic.attribute8),
      MAX(ic.attribute9),
      MAX(ic.attribute10),
      MAX(ic.attribute11),
      MAX(ic.attribute12),
      MAX(ic.attribute13),
      MAX(ic.attribute14),
      MAX(ic.attribute15),
      MAX(ctl.request_id),
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      ct.org_id,
      MAX(il.parent_line_id)
      FROM ra_customer_trx            ct,
           ra_customer_trx_lines      ctl,
           ar_line_conts              lrc,
           ar_interface_conts         ic,
           ra_interface_lines         il
      WHERE ctl.request_id = p_request_id
      AND   ctl.customer_trx_id = ct.customer_trx_id
      AND   ctl.customer_trx_line_id = lrc.customer_trx_line_id
      AND   ctl.customer_trx_line_id = ic.interface_line_id
      AND   ctl.customer_trx_line_id = il.interface_line_id
      GROUP BY ctl.customer_trx_line_id, ct.org_id;

    END IF; -- p_request_id IS NOT NULL

    -- do the same for contingencies that are generated in this program
    -- not passed through the interface table.  The reason we can't do this
    -- with one SQL is because we would like to copy the values passed in the
    -- attributes columns.

    /* 5279702 - Populate parent_line_id when possible.  This
       is important for contingencies defaulted to child lines
       from parents. */

    INSERT INTO ar_deferred_lines
    (
      customer_trx_line_id,
      customer_trx_id,
      original_collectibility_flag,
      line_collectible_flag,
      manual_override_flag,
      amount_due_original,
      acctd_amount_due_original,
      amount_recognized,
      acctd_amount_recognized,
      amount_pending,
      acctd_amount_pending,
      request_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      org_id,
      parent_line_id
    )
    SELECT
      ctl.customer_trx_line_id,
      MAX(ct.customer_trx_id),
     'N',
     'N',
     'N',
      MAX(ctl.extended_amount),
      MAX(decode(g_minimum_accountable_unit_f, NULL,
        ROUND( ctl.extended_amount * nvl(ct.exchange_rate, 1),
          g_precision_f),
        ROUND((ctl.extended_amount * nvl(ct.exchange_rate, 1))
          / g_minimum_accountable_unit_f) * g_minimum_accountable_unit_f)),
      0,
      0,
      0,
      0,
      MAX(ctl.request_id),
      l_user_id,
      sysdate,
      l_user_id,
      sysdate,
      ct.org_id,
      MAX(il.parent_line_id)
    FROM ra_customer_trx        ct,
         ra_customer_trx_lines  ctl,
         ar_line_conts          lrc,
         ra_interface_lines     il
    WHERE ((p_request_id IS NULL AND p_customer_trx_line_id IS NOT NULL AND
            ctl.customer_trx_line_id = p_customer_trx_line_id) OR
           (p_request_id IS NOT NULL AND ctl.request_id = p_request_id))
    AND   ctl.customer_trx_id = ct.customer_trx_id
    AND   ctl.customer_trx_line_id = lrc.customer_trx_line_id
    AND   ctl.customer_trx_line_id = il.interface_line_id (+)
    AND NOT EXISTS
      (SELECT 'line already inserted'
       FROM   ar_deferred_lines dl
       WHERE  dl.customer_trx_line_id = lrc.customer_trx_line_id)
    GROUP BY ctl.customer_trx_line_id, ct.org_id;

  END IF;

  debug('deferred lines inserted: ' || SQL%ROWCOUNT);

  -- it is possible that the line gets imported with one pre-billing
  -- acceptance contingency. In that case, we would like to insert
  -- the a row in the ar_deferred_lines_all, however, we need to mark
  -- it as collectible now.

  IF p_request_id IS NOT NULL THEN
     UPDATE ar_deferred_lines dl
     SET    line_collectible_flag = 'Y'
     WHERE  dl.request_id = p_request_id
     AND NOT EXISTS
     (SELECT 'incomplete contingency'
      FROM   ar_line_conts_all lc
      WHERE  request_id = p_request_id
      AND    lc.customer_trx_line_id = dl.customer_trx_line_id
      AND    lc.completed_flag = 'N');
  ELSIF p_customer_trx_line_id IS NOT NULL THEN
     UPDATE ar_deferred_lines dl
     SET    line_collectible_flag = 'Y'
     WHERE  dl.customer_trx_line_id = p_customer_trx_line_id
     AND NOT EXISTS
     (SELECT 'incomplete contingency'
      FROM   ar_line_conts_all lc
      WHERE  customer_trx_line_id = p_customer_trx_line_id
      AND    lc.customer_trx_line_id = dl.customer_trx_line_id
      AND    lc.completed_flag = 'N');
  END IF;

  debug('deferred lines updated: ' || SQL%ROWCOUNT);

  debug('insert_deferred_lines()-');

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: insert_deferred_lines');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: insert_deferred_lines');
      debug(sqlerrm);
      RAISE;

END insert_deferred_lines;


FUNCTION validate_gt_contingencies (
  p_request_id  NUMBER)
  RETURN NUMBER IS

  l_error_count NUMBER DEFAULT 0;

BEGIN

  debug('validate_gt_contingencies()+');

  -- this subroutine validates contingecies passed through invice api.
  -- at the moment only validation we are doing is to see that contingency
  -- passed exists.

  -- we will not validate against start and end date until we expose
  -- the table.

  INSERT INTO ar_trx_errors_gt
   (
     trx_header_id,
     trx_line_id,
     trx_contingency_id,
     error_message,
     invalid_value
   )
   SELECT
     lgt.trx_header_id,
     lgt.trx_line_id,
     cgt.trx_contingency_id,
     arp_standard.fnd_message('AR_RVMG_INVALID_CONTINGENCY'),
     cgt.contingency_id
   FROM  ar_trx_lines_gt         lgt,
         ar_trx_header_gt        hgt,
         ar_trx_contingencies_gt cgt
   WHERE lgt.trx_header_id = hgt.trx_header_id
   AND   cgt.trx_line_id = lgt.trx_line_id
   AND NOT EXISTS
   (
     SELECT 'valid lookup code'
     FROM   ar_deferral_reasons l
     WHERE  l.contingency_id = cgt.contingency_id
   );

  l_error_count := SQL%ROWCOUNT;
  debug('contingency validation errors inserted: ' || l_error_count);

  -- do not let users populate the expiration date if the event attribute
  -- and/or num of days is populated

  /* 5026580 - Validation was testing all contingencies in
      interface table rather than just those paired with
      the target line. */

  /* 5556360 - only raise this validation error for incomplete
        contingencies.  We allow import with expiration_date
        on completed ones and use that date to set the
        event removal date accordingly */

  INSERT INTO ar_trx_errors_gt
   (
     trx_header_id,
     trx_line_id,
     trx_contingency_id,
     error_message,
     invalid_value
   )
   SELECT
     lgt.trx_header_id,
     lgt.trx_line_id,
     cgt.trx_contingency_id,
     arp_standard.fnd_message('AR_RVMG_NO_EXP_DATE'),
     cgt.contingency_id
   FROM  ar_trx_lines_gt         lgt,
         ar_trx_header_gt        hgt,
         ar_trx_contingencies_gt cgt,
         ar_deferral_reasons     dr
   WHERE lgt.trx_header_id = hgt.trx_header_id
   AND   cgt.trx_line_id = lgt.trx_line_id
   AND   cgt.contingency_id = dr.contingency_id
   AND   cgt.expiration_date IS NOT NULL
   AND   dr.expiration_event_code IS NOT NULL
   AND   NVL(cgt.completed_flag, 'N') = 'N';

  l_error_count := SQL%ROWCOUNT;
  debug('contingency validation errors inserted: ' || l_error_count);

  debug('validate_gt_contingencies()-');

  RETURN l_error_count;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: validate_gt_contingencies');
      debug(sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      debug('OTHERS: validate_gt_contingencies');
      debug(sqlerrm);
      RAISE;

END validate_gt_contingencies;


FUNCTION validate_itf_contingencies (
  p_request_id NUMBER)
  RETURN NUMBER IS

  l_error_count NUMBER DEFAULT 0;

BEGIN

  debug('validate_itf_continencies()+');
  debug(' p_request_id : ' || p_request_id);

  -- this subroutine validates contingecies passed through auto invoice.
  -- at the moment only validation we are doing is to see that contingency
  -- passed exists.

  -- we will not validate against start and end date until we expose
  -- the table.

  INSERT INTO ra_interface_errors
   (
     interface_line_id,
     interface_contingency_id,
     message_text,
     invalid_value,
     org_id
   )
   SELECT
     l.interface_line_id,
     c.interface_contingency_id,
     arp_standard.fnd_message('AR_RVMG_INVALID_CONTINGENCY'),
     c.contingency_id,
     l.org_id
   FROM  ra_interface_lines l,
         ar_interface_conts c
   WHERE l.request_id = p_request_id
   AND   c.interface_line_id = l.interface_line_id
   AND NOT EXISTS
   (
     SELECT 'valid lookup code'
     FROM   ar_deferral_reasons l
     WHERE  l.contingency_id = c.contingency_id
   );

  l_error_count := SQL%ROWCOUNT;
  debug('validation errors inserted: ' || l_error_count);
  debug('validate_itf_continencies()-');

  -- do not let users populate the expiration date if the event attribute
  -- and/or num of days is populated

  /* 5026580 - validation was detecting any contingencies
     with dates (not restricted to only those for each line) */

  /* 5556360 - Only raise this validation message for incomplete
        contingencies.  Complete ones should bypass this as
        we use the expiration_date to populate the
        event removal date */

  INSERT INTO ra_interface_errors
   (
     interface_line_id,
     interface_contingency_id,
     message_text,
     invalid_value,
     org_id
   )
   SELECT
     l.interface_line_id,
     c.interface_contingency_id,
     arp_standard.fnd_message('AR_RVMG_NO_EXP_DATE'),
     c.contingency_id,
     l.org_id
   FROM  ra_interface_lines l,
         ar_interface_conts c,
         ar_deferral_reasons dr
   WHERE l.request_id = p_request_id
   AND   c.interface_line_id = l.interface_line_id
   AND   dr.contingency_id = c.contingency_id
   AND   c.expiration_date IS NOT NULL
   AND   dr.expiration_event_code IS NOT NULL
   AND   NVL(c.completed_flag, 'N') = 'N';

  l_error_count := SQL%ROWCOUNT;
  debug('contingency validation errors inserted: ' || l_error_count);

  RETURN l_error_count;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      debug('NO_DATA_FOUND: validate_itf_contingencies');
      debug(sqlerrm);
      RAISE;

END validate_itf_contingencies;


FUNCTION validate_contingencies(p_request_id NUMBER)

  RETURN NUMBER IS

  l_error_count NUMBER DEFAULT 0;

BEGIN

  -- ths subroutine simply routes the validation to the correct helper
  -- routine depending on the source.

  debug('validate_continencies()+');

  IF (g_source = 'AR_INVOICE_API') THEN
    l_error_count := validate_gt_contingencies(p_request_id);
  ELSE
    l_error_count := validate_itf_contingencies(p_request_id);
  END IF;

  RETURN l_error_count;

  debug('validate_continencies()-');

END validate_contingencies;


PROCEDURE get_base_currency_info IS

  -- This cursor retrieves the functional currency details for the current
  -- set of books id.  This is done once per session.

  CURSOR currency IS
    SELECT c.currency_code,
           c.precision,
           c.minimum_accountable_unit
    FROM   ar_system_parameters sysp,
           gl_sets_of_books sob,
           fnd_currencies c
    WHERE  sob.set_of_books_id = sysp.set_of_books_id
    AND    sob.currency_code   = c.currency_code;

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
    debug('get_base_currency_info()+');
  END IF;

  OPEN currency;
  FETCH currency INTO g_currency_code_f,
                      g_precision_f,
                      g_minimum_accountable_unit_f;
  CLOSE currency;

  IF pg_debug IN ('Y', 'C') THEN
    debug('Functional Currency Code    : ' || g_currency_code_f);
    debug('           Precision        : ' || g_precision_f);
    debug('           accountable unit : ' ||
      g_minimum_accountable_unit_f);
  END IF;

  IF pg_debug IN ('Y', 'C') THEN
    debug('get_base_currency_info()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    debug('NO_DATA_FOUND: get_base_currency_info');
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('OTHERS: get_base_currency_info');
    debug(sqlerrm);
    RAISE;

END get_base_currency_info;


PROCEDURE update_deferred_lines (
  p_customer_trx_id 		NUMBER	  DEFAULT NULL,
  p_customer_trx_line_id 	NUMBER    DEFAULT NULL,
  p_line_status 		NUMBER    DEFAULT NULL,
  p_manual_override 		VARCHAR2  DEFAULT NULL,
  p_amount_recognized  		NUMBER    DEFAULT NULL,
  p_acctd_amount_recognized  	NUMBER    DEFAULT NULL,
  p_amount_pending  		NUMBER    DEFAULT NULL,
  p_acctd_amount_pending  	NUMBER    DEFAULT NULL) IS

  l_sysdate               DATE;
  l_last_updated_by       NUMBER;
  l_last_update_login     NUMBER;
  l_line_collectible      VARCHAR2(1) DEFAULT NULL;

BEGIN

  -- This procedure simply updates a row of data in the
  -- ar_deferred_lines table. It will only update columns
  -- for which data is provided, the rest will retain their
  -- original values.

  IF pg_debug IN ('Y', 'C') THEN
     debug('update_deferred_lines()+');
     debug('** update_deferred_lines parameters **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
  END IF;

  l_sysdate           := trunc(sysdate);
  l_last_updated_by   := arp_global.user_id;
  l_last_update_login := arp_global.last_update_login;

  IF (p_line_status = c_recognizable) THEN
    l_line_collectible := 'Y';
  END IF;

  IF (p_customer_trx_line_id IS NULL) THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('p_customer_trx_line_id IS NULL');
    END IF;

    UPDATE ar_deferred_lines
    SET line_collectible_flag 	  = nvl(l_line_collectible,
                                        line_collectible_flag),
        manual_override_flag   	  = nvl(p_manual_override,
                                        manual_override_flag),
        last_updated_by           = l_last_updated_by,
        last_update_date 	  = l_sysdate,
        last_update_login         = l_last_update_login
    WHERE customer_trx_id 	  = p_customer_trx_id;

  ELSE

    IF pg_debug IN ('Y', 'C') THEN
       debug('p_customer_trx_line_id IS NOT NULL');
    END IF;

    UPDATE ar_deferred_lines
    SET line_collectible_flag 	  = nvl(l_line_collectible,
                                        line_collectible_flag),
        manual_override_flag   	  = nvl(p_manual_override,
                                        manual_override_flag),
        amount_recognized         = nvl(p_amount_recognized,
                                        amount_recognized),
        acctd_amount_recognized   = nvl(p_acctd_amount_recognized,
                                        acctd_amount_recognized),
        amount_pending      	  = nvl(p_amount_pending, amount_pending),
        acctd_amount_pending      = nvl(p_acctd_amount_pending,
                                        acctd_amount_pending),
        last_updated_by           = l_last_updated_by,
        last_update_date 	  = l_sysdate,
        last_update_login         = l_last_update_login
    WHERE customer_trx_line_id 	  = p_customer_trx_line_id;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('update_deferred_lines()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: update_deferred_lines');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: update_deferred_lines');
       debug(sqlerrm);
    END IF;
    RAISE;

END update_deferred_lines;


FUNCTION rule_based (p_customer_trx_id IN NUMBER)
  RETURN BOOLEAN IS

  -- This cursor returns TRUE if there exists a invoicing rule
  -- for the invoice.

  CURSOR c IS
    SELECT 1
    FROM   ra_customer_trx rctl
    WHERE  rctl.customer_trx_id = p_customer_trx_id
    AND    invoicing_rule_id IS NOT NULL;

  l_dummy_flag   NUMBER;
  l_return_value BOOLEAN;

BEGIN

  -- This function determined if the invoice in question has
  -- invoicing rules assocaited with it.

  IF pg_debug IN ('Y', 'C') THEN
     debug('rule_based()+');
     debug('** rule_based parameter **');
     debug('rule_based: ' || '  p_customer_trx_id  : ' ||
       p_customer_trx_id);
  END IF;

  OPEN c;
  FETCH c INTO l_dummy_flag;
  l_return_value := c%FOUND;
  CLOSE c;

  IF pg_debug IN ('Y', 'C') THEN
     debug('rule_based()-');
  END IF;
  RETURN l_return_value;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: rule_based');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: rule_based');
       debug(sqlerrm);
    END IF;
    RAISE;

END rule_based;


FUNCTION distributions_created (p_customer_trx_id IN NUMBER)
  RETURN BOOLEAN IS

  -- This cursor returns TRUE if the distributions have been created
  -- for the invoice.

  CURSOR c IS
    SELECT 1
    FROM   ra_cust_trx_line_gl_dist
    WHERE  customer_trx_id = p_customer_trx_id
    AND    account_set_flag = 'N'
    AND    rownum = 1;

  l_dummy_flag   NUMBER;
  l_return_value BOOLEAN;

BEGIN

  -- This function determines if the revenue recognition has run
  -- called for this invoices with rules to create the distributions.

  IF pg_debug IN ('Y', 'C') THEN
     debug('distributions_created()+');
     debug('** distributions_created parameter **');
     debug('  p_customer_trx_id : ' || p_customer_trx_id);
  END IF;

  OPEN c;
  FETCH c INTO l_dummy_flag;
  l_return_value := c%FOUND;
  CLOSE c;

  IF pg_debug IN ('Y', 'C') THEN
     debug('distributions_created()-');
  END IF;

  RETURN l_return_value;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: distributions_created');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: distributions_created');
       debug(sqlerrm);
    END IF;
    RAISE;

END distributions_created;


FUNCTION monitored_transaction (p_customer_trx_id IN NUMBER)
  RETURN BOOLEAN IS

  -- This cursor checks to see if the invoice
  -- was analyzed by the revenue management engine.

  CURSOR monitored_txn IS
    SELECT 1
    FROM   ar_deferred_lines
    WHERE  customer_trx_id       = p_customer_trx_id
    AND    manual_override_flag  = 'N'
    AND    line_collectible_flag = 'N';

  l_dummy_flag	  NUMBER;
  l_return_value  BOOLEAN;

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('monitored_transaction()+');
     debug('** monitored_transaction parameter **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
  END IF;

  OPEN monitored_txn;
  FETCH monitored_txn INTO l_dummy_flag;

  IF monitored_txn%FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug  ('RAM-C Transaction');
    END IF;
    CLOSE monitored_txn;
    IF pg_debug IN ('Y', 'C') THEN
       debug('monitored_transaction()-');
    END IF;
    RETURN TRUE;
  END IF;
  CLOSE monitored_txn;

  IF pg_debug IN ('Y', 'C') THEN
     debug  ('Not a monitored transaction');
     debug('monitored_transaction()-');
  END IF;

  RETURN FALSE;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: monitored_transaction');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: ramc_transcation');
       debug(sqlerrm);
    END IF;
    RAISE;

END monitored_transaction;


PROCEDURE manual_override (
  p_customer_trx_id NUMBER,
  p_customer_trx_line_id NUMBER DEFAULT NULL) IS

  l_sysdate DATE;
  l_user_id NUMBER;

BEGIN

  --------------------------------------------------------------------------
  -- This procedure updates the manual_oveeride column in the
  -- ar_deferred_lines table to indicate that this line or transction
  -- has been manually manipulated by user in the RAM screens.  As a result
  -- of this update, the revenue management engine will not keep track of
  -- this line anymore.
  ---------------------------------------------------------------------------

  IF pg_debug IN ('Y', 'C') THEN
     debug('manual_override()+');
     debug('** manual_override parameters **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
  END IF;

  l_sysdate := trunc(sysdate);
  l_user_id := fnd_global.user_id;

  IF (p_customer_trx_line_id IS NULL) THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('Manual RAM adjustments done to the entire txn');
    END IF;

    update_deferred_lines (
      p_customer_trx_id	=> p_customer_trx_id,
      p_manual_override	=> 'Y');

  ELSE

    IF pg_debug IN ('Y', 'C') THEN
       debug('Manual RAM adjustments done to a specific line');
    END IF;

    update_deferred_lines (
      p_customer_trx_line_id 	=> p_customer_trx_line_id,
      p_manual_override		=> 'Y');

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('manual_override()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: manual_override');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: manual_override');
       debug(sqlerrm);
    END IF;
    RAISE;

END manual_override;


PROCEDURE update_for_event (
  p_cust_trx_line_id    IN  NUMBER,
  p_event_date		IN  DATE,
  p_event_code          IN  VARCHAR2) IS

  l_user_id NUMBER;
  l_dummy   NUMBER;
  l_revrec_event_code VARCHAR2(30);
  l_expiration_event_code VARCHAR2(30);

  -- select the contingencies for this line which
  -- was waiting for this event.
  CURSOR conts IS
    SELECT dr.contingency_id, revrec_event_code, expiration_event_code
    FROM   ar_line_conts lc,
           ar_deferral_reasons dr
    WHERE  lc.contingency_id = dr.contingency_id
    AND    lc.customer_trx_line_id = p_cust_trx_line_id
    AND    (dr.revrec_event_code = p_event_code OR
            dr.expiration_event_code = p_event_code);

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
    debug('update_for_event()+');
    debug('** update_for_event parameters **');
    debug('  p_cust_trx_line_id : ' ||
      p_cust_trx_line_id);
    debug('  p_event_code:  ' || p_event_code);
  END IF;

  -- if we reach here that means, we do care about this event.

  l_user_id := fnd_global.user_id;

  FOR cont_rec IN conts LOOP

    /* 5530037 - Revised logic to handle both
         expiration_event_code and revrec_event_code
         events.  Specifically, we removed the exclusionary
         IF/ELSIF logic

         DEV NOTE:  the expiration_date logic simply
         insures that the expiration_date is set correctly
         for contingencies that have PROOF_OF_DELIVERY
         for their alternate (time-based) expirations.

         While it is possible to have 'PROOF_OF_DELIVERY' for
         both expiration_event_code and revrec_event_code, the act
         of POD would complete the contingency
         immediately and the expiration_date would be meaningless.

         The original logic made the expiration and revrec events
         mutually exclusive where the design clearly intended to
         allow them together.

         Please note that I also added code to populate
         expiration_event_date in cases where it is the
         expiration_event_code activity that is happening.  This
         will insure that the expiration_event_date is always

    */

      UPDATE ar_line_conts
      SET    expiration_date     =
               DECODE(cont_rec.expiration_event_code, p_event_code,
                   NVL(p_event_date + expiration_days,expiration_date),
                   expiration_date),
             expiration_event_date =
               DECODE(cont_rec.expiration_event_code, p_event_code,
                   NVL(p_event_date,
                     NVL(expiration_date - expiration_days,
                        expiration_date))),
             completed_flag      =
               DECODE(cont_rec.revrec_event_code, p_event_code,'Y',
                   completed_flag),
             completed_by        =
               DECODE(cont_rec.revrec_event_code, p_event_code,
                   fnd_global.user_id, completed_by),
             reason_removal_date =
               DECODE(cont_rec.revrec_event_code, p_event_code,
                   sysdate, reason_removal_date),
             last_updated_by     = l_user_id,
             last_update_date    = sysdate,
             last_update_login   = l_user_id
      WHERE customer_trx_line_id = p_cust_trx_line_id
      AND   contingency_id       = cont_rec.contingency_id;

  END LOOP;

  IF pg_debug IN ('Y', 'C') THEN
     debug('update_for_event()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: update_for_event');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: update_for_event');
       debug(sqlerrm);
    END IF;
    RAISE;

END update_for_event;


PROCEDURE adjust_revenue (
  p_mode 		  IN VARCHAR2 DEFAULT c_earn_revenue,
  p_customer_trx_id 	  IN NUMBER,
  p_customer_trx_line_id  IN NUMBER,
  p_acctd_amount          IN NUMBER,
  p_gl_date		  IN DATE     DEFAULT NULL,
  p_comments		  IN VARCHAR2 DEFAULT NULL,
  p_ram_desc_flexfield    IN desc_flexfield,
  p_rev_adj_rec 	  IN ar_revenue_adjustment_pvt.rev_adj_rec_type,
  p_delta_amount	  IN NUMBER DEFAULT 0,
  p_acctd_delta_amount	  IN NUMBER DEFAULT 0,
  x_adjustment_number     OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY VARCHAR2,
  x_msg_count             OUT NOCOPY NUMBER,
  x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_api_version       	NUMBER := 2.0;
  l_init_msg_list     	VARCHAR2(30) DEFAULT fnd_api.g_true;
  l_commit	      	VARCHAR2(30) DEFAULT FND_API.G_FALSE;

  l_sysdate             DATE;
  l_user_id             NUMBER;

  l_line_count          NUMBER;
  l_status              NUMBER;

  l_adjustable_amount       NUMBER 	DEFAULT 0;
  l_acctd_adjustable_amount NUMBER	DEFAULT 0;

  l_item_key            wf_items.ITEM_KEY%TYPE;
  l_adjustment_id     	ar_adjustments.adjustment_id%TYPE;
  l_adjustment_number 	ar_adjustments.adjustment_number%TYPE;

  l_rev_adj_rec 	ar_revenue_adjustment_pvt.rev_adj_rec_type;

BEGIN

  /*------------------------------------------------------------------------
  | This procedure is a wrapper for RAM apis and also raises buisness events.
  | Amount in invoice currrency is passed as part of the p_rev_adj_rec record.
  | But, the accounted amoutn is not passed in the record, so that needs to
  | passed explicitly.
  +------------------------------------------------------------------------*/

  IF pg_debug IN ('Y', 'C') THEN
     debug('adjust_revenue()+');
     debug('** adjust_revenue parameters **');
     debug('  p_mode                 : ' || p_mode);
     debug('  p_gl_date              : ' || p_gl_date);
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
     debug('  p_amount               : ' || p_rev_adj_rec.amount);
     debug('  p_acctd_amount         : ' || p_acctd_amount);
     debug('  p_delta_amount         : ' || p_delta_amount);
     debug('  p_acctd_delta_amount   : ' || p_acctd_delta_amount);
     debug('  p_sales_credit_type    : ' || p_rev_adj_rec.sales_credit_type);
  END IF;

  /* 7569247 - removed zero amount check.. we need to let zero
     amount adjustments through so the lines will register
     for COGS */

  l_sysdate := trunc(sysdate);

  l_rev_adj_rec := p_rev_adj_rec;

  l_rev_adj_rec.source := c_revenue_management_source;

  l_rev_adj_rec.attribute1  := p_ram_desc_flexfield.attribute1;
  l_rev_adj_rec.attribute2  := p_ram_desc_flexfield.attribute2;
  l_rev_adj_rec.attribute3  := p_ram_desc_flexfield.attribute3;
  l_rev_adj_rec.attribute4  := p_ram_desc_flexfield.attribute4;
  l_rev_adj_rec.attribute5  := p_ram_desc_flexfield.attribute5;
  l_rev_adj_rec.attribute6  := p_ram_desc_flexfield.attribute6;
  l_rev_adj_rec.attribute7  := p_ram_desc_flexfield.attribute7;
  l_rev_adj_rec.attribute8  := p_ram_desc_flexfield.attribute8;
  l_rev_adj_rec.attribute9  := p_ram_desc_flexfield.attribute9;
  l_rev_adj_rec.attribute10 := p_ram_desc_flexfield.attribute10;
  l_rev_adj_rec.attribute11 := p_ram_desc_flexfield.attribute11;
  l_rev_adj_rec.attribute12 := p_ram_desc_flexfield.attribute12;
  l_rev_adj_rec.attribute13 := p_ram_desc_flexfield.attribute13;
  l_rev_adj_rec.attribute14 := p_ram_desc_flexfield.attribute14;
  l_rev_adj_rec.attribute15 := p_ram_desc_flexfield.attribute15;

  l_rev_adj_rec.attribute_category := p_ram_desc_flexfield.attribute_category;

  l_rev_adj_rec.comments := p_comments;

  IF (p_gl_date IS NOT NULL) THEN
    l_rev_adj_rec.gl_date := p_gl_date;
  ELSE
    l_rev_adj_rec.gl_date := (l_sysdate);
  END IF;

  -- *** Being called in earned mode ***
  IF  (p_mode = c_earn_revenue) THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('RAM being called in EARN mode');
    END IF;

    IF (rule_based(p_customer_trx_id) AND
        NOT distributions_created(p_customer_trx_id)) THEN

      IF pg_debug IN ('Y', 'C') THEN
         debug  ('revenue recognition has not run for this txn');
      END IF;

      -- call to the concurrent program
      l_status := arp_auto_rule.create_distributions(
        p_commit    => 'N',
        p_debug     => 'N',
        p_trx_id    => p_customer_trx_id);

      IF pg_debug IN ('Y', 'C') THEN
         debug  ('revenue recognition done');
      END IF;

    END IF;

    ar_raapi_util.constant_system_values;

    l_adjustable_amount := ar_raapi_util.adjustable_revenue (
      p_customer_trx_line_id  => p_customer_trx_line_id,
      p_adjustment_type       => 'EA',
      p_customer_trx_id       => p_customer_trx_id,
      p_salesrep_id           => NULL,
      p_sales_credit_type     => NULL,
      p_item_id               => NULL,
      p_category_id           => NULL,
      p_revenue_adjustment_id => NULL,
      p_line_count_out        => l_line_count,
      p_acctd_amount_out      => l_acctd_adjustable_amount);

    IF (l_acctd_adjustable_amount IS NULL) THEN
      l_acctd_adjustable_amount := 0;
    END IF;

    IF pg_debug IN ('Y', 'C') THEN
       debug('adjust_revenue - amount adjustable: ' ||
      l_adjustable_amount);
       debug('adjust_revenue - acctd amount adjustable: ' ||
      l_acctd_adjustable_amount);
    END IF;
    /*6157033 changed condition to avoid error in case of
       -ve adjustments with negative invoices*/
    IF (ABS(l_adjustable_amount) < ABS(l_rev_adj_rec.amount)) THEN

      ------------------------------------------------------------------------
      -- There must have been some credit memos that were applied
      -- to this invoice.  So, we can not recognize the computed
      -- amount, instead we should recognize only adjustable amount.
      -- Hence update ar_deferred_lines table by taking out the
      -- initial amount and then adding the adjustable amount.
      -----------------------------------------------------------------------

      IF pg_debug IN ('Y', 'C') THEN
         debug('Adjustable amount is less the computed amount');
      END IF;

      -- The reason we are subtracting the l_rev_adj_rec.amount from the
      -- recognized amount is because that is what has been added to
      -- l_rev_adj_rec.amount before coming to this subroutine. So, must take
      -- that out before adding the adjustable amount.


      /* 6008164 - This code actually causes amount_recognized to
          be incorrect for inv+adj+rec case.  In my case, the amounts
          were 100 - 102.61 + 100 = 97.39 when the rev_adj should have been
          for $100.  So I think l_rev_adj_rec.amount is wrong */
     /*  6157033 used delta amount passed to calculate correct amount
          to be recogonied*/
      UPDATE ar_deferred_lines
      SET amount_recognized       = amount_recognized + p_delta_amount -
                                    l_rev_adj_rec.amount +
                                    l_adjustable_amount,
          acctd_amount_recognized = acctd_amount_recognized + p_acctd_delta_amount -
                                    p_acctd_amount +
                                    l_acctd_adjustable_amount
      WHERE customer_trx_line_id  = p_customer_trx_line_id;

      l_rev_adj_rec.amount := l_adjustable_amount;

    END IF;

    IF pg_debug IN ('Y', 'C') THEN
       debug(l_rev_adj_rec.amount ||
      ' Being Earned For Customer Trx ID ' || p_customer_trx_id ||
      ' Line ID ' || p_customer_trx_line_id);
    END IF;

    /* 5462746 - The Sweeper may attempt to earn revenue
        twice -- once via the record_acceptance code and again
        in the actual sweeper code.  The second call fails
        if the amount is zero. */
    IF pg_debug IN ('Y', 'C')
    THEN
          debug('trx_id = ' || p_customer_trx_id || ' amount = ' ||
            l_rev_adj_rec.amount);
    END IF;

    /* 7569247 - Pushed earn_revenue call outside of IF amount <> 0
          case.  All adjustments, even zero ones must go through
          in order to work for COGS */

       ar_revenueadjust_pub.earn_revenue(
         p_api_version       => l_api_version,
         p_init_msg_list     => l_init_msg_list,
         p_rev_adj_rec       => l_rev_adj_rec,
         x_return_status     => x_return_status,
         x_msg_count         => x_msg_count,
         x_msg_data          => x_msg_data,
         x_adjustment_id     => l_adjustment_id,
         x_adjustment_number => x_adjustment_number);

  -- *** Being called in un-earn mode ***
  ELSE

    IF pg_debug IN ('Y', 'C') THEN
       debug('RAM being called in UN-EARN mode');
       debug(l_rev_adj_rec.amount ||
      ' UnEarned For Customer Trx ID ' || p_customer_trx_id ||
      ' Line ID ' || p_customer_trx_line_id);
    END IF;

    ar_revenueadjust_pub.unearn_revenue(
      p_api_version       => l_api_version,
      p_init_msg_list     => l_init_msg_list,
      p_rev_adj_rec       => l_rev_adj_rec,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data,
      x_adjustment_id     => l_adjustment_id,
      x_adjustment_number => x_adjustment_number);

  END IF;


  IF x_return_status  = fnd_api.g_ret_sts_success THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('Call To RAM API successful');
    END IF;

  ELSE

    IF pg_debug IN ('Y', 'C') THEN
       debug('RME encountered an ERROR with RAM!');
       debug('  p_customer_trx_id      : ' || p_customer_trx_id);
       debug('  p_customer_trx_line_id : ' ||
      p_customer_trx_line_id);
    END IF;

    fnd_msg_pub.get(fnd_msg_pub.g_first, fnd_api.g_false,
      x_msg_data, x_msg_count);

    IF pg_debug IN ('Y', 'C') THEN
       debug('Error Reported By RAM API: ' || x_msg_data);
    END IF;

    fnd_message.set_name ('AR','GENERIC_MESSAGE');
    fnd_message.set_token('GENERIC_TEXT', x_msg_data);
    app_exception.raise_exception;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('adjustment number: ' || l_adjustment_number);
     debug('adjustment id: ' || l_adjustment_id);
     debug('adjust_revenue()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: adjust_revenue');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: adjust_revenue');
       debug(sqlerrm);
    END IF;
    RAISE;

END adjust_revenue;


FUNCTION creditworthy (
  p_customer_account_id IN NUMBER,
  p_customer_site_use_id IN NUMBER)
  RETURN NUMBER IS

  -- This cursor retrives the party id for a customer account id.
  CURSOR cust_party IS
    SELECT party_id
    FROM hz_cust_accounts
    WHERE cust_account_id = p_customer_account_id;

  -- This cursor retrived credit classification at site level
  CURSOR site (p_party_id NUMBER, p_account_id NUMBER, p_site_use_id NUMBER )IS
    SELECT credit_classification
    FROM   hz_customer_profiles
    WHERE  party_id = p_party_id
    AND    cust_account_id = p_account_id
    AND    site_use_id = p_site_use_id;

  -- This cursor retrives credit classification at account level
  CURSOR account (p_party_id NUMBER, p_account_id NUMBER )IS
    SELECT credit_classification
    FROM   hz_customer_profiles
    WHERE  party_id = p_party_id
    AND    cust_account_id = p_account_id
    AND    site_use_id IS NULL;

  -- This cursor retrives credit classification at party level
  CURSOR party (p_party_id NUMBER) IS
    SELECT credit_classification
    FROM   hz_customer_profiles
    WHERE  party_id = p_party_id
    AND    cust_account_id = -1;

  -- This cursor traverses the party hierarchy.
  CURSOR party_hierarchy (p_child_id IN NUMBER) IS
    SELECT parent_id
    FROM hz_hierarchy_nodes
    WHERE child_id = p_child_id
    AND parent_table_name = 'HZ_PARTIES'
    AND parent_object_type = 'ORGANIZATION'
    AND hierarchy_type = 'CREDIT'
    AND level_number > 0
    AND effective_start_date <= trunc(sysdate)
    AND effective_end_date   >= trunc(sysdate);

  -- This cursor retrieves credit classifiction for parties
  -- in party hierarchy.
  CURSOR parent (p_party_id NUMBER) IS
    SELECT credit_classification
    FROM hz_customer_profiles
    WHERE party_id = p_party_id
    AND   cust_account_id = -1
    AND   site_use_id IS NULL;

  l_verdict               NUMBER DEFAULT collect;
  l_party_id     	  hz_cust_accounts.party_id%TYPE;
  l_parent_id    	  hz_cust_accounts.party_id%TYPE;

  l_credit_classification
    ar_system_parameters.credit_classification1%TYPE;

BEGIN

  -- This subroutine computes the credit classification.

  IF pg_debug IN ('Y', 'C') THEN
     debug('creditworthy()+');
     debug('** creditworthy parameters **');
     debug('  p_customer_account_id  : ' ||
       p_customer_account_id);
     debug('  p_customer_site_use_id : ' ||
       p_customer_site_use_id);
  END IF;

  IF NOT g_credit_class_tbl.EXISTS (p_customer_site_use_id) THEN

    OPEN  cust_party;
    FETCH cust_party INTO l_party_id;
    CLOSE cust_party;


    -- find out if a credit classificaion exist for bill to site, account
    -- or party level.

    IF pg_debug IN ('Y', 'C') THEN
      debug('Party ID: ' || l_party_id);
    END IF;

    --------------------------------------------------------------------------
    -- This following logic retrives the classifcation for a customer.  First
    -- First it looks to see if the classification is stored at the site level
    -- if it is not there then it looks at the account layer, and if it does
    -- not find it there it looks at the party level to see if it find a
    -- classifcation there.
    -------------------------------------------------------------------------

    IF pg_debug IN ('Y', 'C') THEN
      debug('Looking at site, account, party for classification');
    END IF;

    OPEN  site(l_party_id, p_customer_account_id, p_customer_site_use_id);
    FETCH site INTO l_credit_classification;
    CLOSE site;

    IF l_credit_classification IS NULL THEN

      IF pg_debug IN ('Y', 'C') THEN
       debug('(site) no credit classification');
      END IF;

      OPEN  account(l_party_id, p_customer_account_id);
      FETCH account INTO l_credit_classification;
      CLOSE account;

    END IF;

    IF l_credit_classification IS NULL THEN

      IF pg_debug IN ('Y', 'C') THEN
        debug('(account) no credit classification');
      END IF;

      OPEN  party(l_party_id);
      FETCH party INTO l_credit_classification;
      CLOSE party;

    END IF;

    IF l_credit_classification IS NULL THEN

      IF pg_debug IN ('Y', 'C') THEN
        debug('(party) no credit classification');
      END IF;

      -------------------------------------------------------------------------
      -- no credit classification was found  for bill to site, account
      -- or party level. So, now we have to look for it in the party
      -- hierarchy.
      --
      -- The following sql is used to to retrieve a classification by
      -- traversing the party hierarchy.  This sql will be executed for
      -- each party in the hierarchy.
      ------------------------------------------------------------------------

      OPEN party_hierarchy(l_party_id);

      LOOP
        FETCH party_hierarchy INTO l_parent_id;
        EXIT WHEN party_hierarchy%NOTFOUND;

        OPEN parent(l_parent_id);
        FETCH parent INTO l_credit_classification;
        CLOSE parent;

        IF pg_debug IN ('Y', 'C') THEN
          debug('Parent Party ID: ' || l_party_id);
        END IF;

        IF l_credit_classification IS NOT NULL THEN
          IF pg_debug IN ('Y', 'C') THEN
            debug('(parent) - classification : ' ||
              l_credit_classification);
          END IF;
          EXIT;
        END IF;
      END LOOP;

      CLOSE party_hierarchy;

    END IF;  -- l_credit_classification IS NULL

    g_credit_class_tbl(p_customer_site_use_id) := l_credit_classification;

  END IF;    -- NOT EXISTS


  IF pg_debug IN ('Y', 'C') THEN
    debug('credit Classification: ' || l_credit_classification);
    debug('creditworthy()-');
  END IF;

  IF g_credit_class_tbl(p_customer_site_use_id) IN (
       arp_standard.sysparm.credit_classification1,
       arp_standard.sysparm.credit_classification2,
       arp_standard.sysparm.credit_classification3) THEN

    l_verdict := defer;

  ELSE

    l_verdict := collect;

  END IF;

  RETURN l_verdict;


EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: creditworthy');
       debug(sqlerrm);
    END IF;
    RETURN NULL;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug(' creditworthy');
       debug(sqlerrm);
    END IF;
    RETURN NULL;

END creditworthy;


FUNCTION get_total_application(
  p_customer_trx_id IN NUMBER)
  RETURN NUMBER IS

  -- This cursor retrieves the toal receipts applied so far
  -- to an invoice.

  CURSOR total_app IS
    SELECT sum(amount_recognized) + sum(amount_pending)
    FROM   ar_deferred_lines
    WHERE  customer_trx_id = p_customer_trx_id;

  l_total_application  ar_deferred_lines.amount_recognized%TYPE;

BEGIN

  -- This functions gets total receipt amount applied against
  -- the invoice.

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_total_application()+');
     debug('** get_total_application parameters **');
     debug('  p_customer_trx_id  : ' || p_customer_trx_id);
  END IF;

  OPEN  total_app;
  FETCH total_app INTO l_total_application;
  CLOSE total_app;

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_total_application()-');
  END IF;

  RETURN l_total_application;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: get_total_application');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: get_total_application');
       debug(sqlerrm);
    END IF;
    RAISE;

END get_total_application;


FUNCTION get_acctd_total_application(
  p_customer_trx_id IN NUMBER)
  RETURN NUMBER IS

  -- This cursor retrieves the toal receipts applied so far
  -- to an invoice in functional currency.

  CURSOR acctd_total_app IS
    SELECT sum(acctd_amount_recognized) + sum(acctd_amount_pending)
    FROM   ar_deferred_lines
    WHERE  customer_trx_id = p_customer_trx_id;

  l_acctd_total_application  ar_deferred_lines.amount_recognized%TYPE;

BEGIN

  -- This functions gets total accounted amount receipt amount applied against
  -- the invoice.

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_acctd_total_application()+');
     debug('** get_acctd_total_application parameters **');
     debug('  p_customer_trx_id  : ' || p_customer_trx_id);
  END IF;

  OPEN  acctd_total_app;
  FETCH acctd_total_app INTO l_acctd_total_application;
  CLOSE acctd_total_app;

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_acctd_total_application()-');
  END IF;

  RETURN l_acctd_total_application;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: get_acctd_total_application');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: get_acctd_total_application');
       debug(sqlerrm);
    END IF;
    RAISE;

END get_acctd_total_application;


FUNCTION compute_line_amount (
  p_mode			IN NUMBER,
  p_amount_previously_applied	IN NUMBER,
  p_current_amount_applied	IN NUMBER,
  p_line_balance_orig 		IN NUMBER,
  p_currency_code 		IN VARCHAR2,
  p_sum_of_all_lines		IN NUMBER,
  p_current_line_balance	IN NUMBER,
  p_running_lines_balance 	IN OUT NOCOPY NUMBER,
  p_running_allocated_balance 	IN OUT NOCOPY NUMBER)
  RETURN NUMBER IS

  l_total_amount             ar_deferred_lines.amount_recognized%TYPE;
  l_computed_line_amount     ra_customer_trx_lines.extended_amount%TYPE;

BEGIN

  /*------------------------------------------------------------------------
  | This function is a generic function to compute the line balance
  | using a standard rounding logic.  This function is being called
  | both for invoice currency and functional currency. It is important
  | to understand the meanign of each parameter, so I give a detailed
  | explanations explantion for each parameter.
  |
  | PARAMETER DEFINITIONS:
  |
  | P_MODE
  |   to indicate if this procedure is called for receipt application
  |   or receipt reversal.  the processing is quite different between the
  |   two.
  |
  | P_AMOUNT_PREVIOUSLY_APPLIED
  |   this is the receipt amount that has been applied previously over time
  |   to this transaction.  this amount would reflect any receipts reversals
  |   if such an event happenned.  this could be zero when the first receipt
  |   application is being done.
  |
  | P_CURRENT_AMOUNT_APPLIED
  |   current receipt amount at our disposal to distribute over lines.
  |   to avoid rounding errors during receipt application we always sum the
  |   p_amount_previously_applied and p_current_amount_applied and then
  |   determine the line amount taking the whole amount into consideration.
  |
  | P_LINE_BALANCE_ORIGINAL
  |   this is the line balance during invoice creation.
  |
  | P_CURRENCY_CODE
  |   invoice currency code.
  |
  | P_SUM_OF_ALL_LINES
  |   line 1 original balance + line 2 original balance + line 3 ....
  |
  | P_CURRENT_LINE_BALANCE
  |   this is the receipt amount that has been applied previously over time
  |   to this line.
  |
  | P_RUNNING_LINES_BALANCE :
  |  this is sum of all lines processed so far, so for example, the first time
  |  it is called it will be equal to line1, then it will be line1 + line2
  |  then line 1 + line 2 + line 3 etc.
  |
  | RUNNING_ALLOCATED_BALANCE
  |  if we had $1000 to apply and we have applied $100 to Line 1
  |  then running_allocated balance would $100, then if we
  |  allocated $300 for line 2 then the balance would be $400
  |
  | COMPUTED_LINE_AMOUNT
  |   This is the amount computed that will be applied to the line.  Since,
  |   we determine the line amount taking the whole amount into
  |   consideration, we must subtract the p_current_line_balance amount.
  |
  | THE ALOGORITHM for rounding
  |
  | line amounts $10, $20, $30, $40, Rev Total $100, $10 to be applied
  |
  | Line 1  a -> 10 * 10/100  = 1 (allocated)
  | -------------------------------------------
  |
  | Line 2    -> (10 + 20)/100 * 10 = 3
  |
  |         b -> 3 - a = 2 (allocated)
  | -------------------------------------------
  |
  | Line 3    -> (10 + 20 + 30) * 10/100 = 6
  |
  |         c -> 6 - a - b = 3
  |
  | -------------------------------------------
  | Line .....
  |
  +--------------------------------------------------------------------------*/

  IF pg_debug IN ('Y', 'C') THEN
     debug('compute_line_amount()+');
     debug('** compute_line_amount parameters **');
     debug('  p_mode                       : ' || p_mode);
     debug('  p_amount_previously applied  : ' ||
    p_amount_previously_applied);
     debug('  p_current_amount_applied     : ' ||
    p_current_amount_applied);
     debug(' p_line_balance_orig           : ' ||
    p_line_balance_orig);
     debug(' p_currency_code               : ' ||
       p_currency_code);
     debug(' p_sum_of_all_lines            : ' ||
    p_sum_of_all_lines);
     debug(' p_current_line_balance        : ' ||
    p_current_line_balance);
     debug(' p_running_lines_balance       : ' ||
    p_running_lines_balance);
     debug(' p_running_allocated_balance  : ' ||
    p_running_allocated_balance);
  END IF;

  IF (p_sum_of_all_lines = 0) THEN
    RETURN 0;
  END IF;

  IF (p_mode = c_receipt_application_mode) THEN

    l_total_amount := p_amount_previously_applied + p_current_amount_applied;

  ELSE


    /*------------------------------------------------------------------------
    |
    | if this reversal makes the pending or recognized amount to go
    | down to zero, then we want to avoid having rounding errors as
    | follows : L1 -0.01, L2 -0.01 and L3 +0.02.  So, simply reverse
    | amount in the pending column or recognized column and we will
    | avoid the above scenario.
    +------------------------------------------------------------------------*/

    IF (p_current_amount_applied = p_amount_previously_applied) THEN
      RETURN p_current_line_balance;
    ELSE
      l_total_amount := p_current_amount_applied;
    END IF;

  END IF;

  p_running_lines_balance := p_running_lines_balance + p_line_balance_orig;

  l_computed_line_amount :=
    arpcurr.currround(
      p_running_lines_balance /
      p_sum_of_all_lines * l_total_amount,
      p_currency_code)
      - p_running_allocated_balance;

  p_running_allocated_balance := p_running_allocated_balance +
    l_computed_line_amount;

  IF pg_debug IN ('Y', 'C') THEN
     debug('Calculation  : ');
     debug('l_computed_line_amount := ');
     debug('  arpcurr.currround(');
     debug('    p_running_lines_balance / ');
     debug('    p_sum_of_all_lines * l_total_amount,');
     debug('    p_currency_code)');
     debug('    - p_running_allocated_balance');
     debug('-----------------------------------------');
     debug(' p_running_lines_balance       : ' ||
    p_running_lines_balance);
     debug(' p_sum_of_all_lines            : ' ||
    p_sum_of_all_lines);
     debug(' l_total_amount                : ' || l_total_amount);
     debug(' p_currency_code               : ' ||
       p_currency_code);
     debug(' p_running_allocated_balance   : ' ||
    p_running_allocated_balance);
     debug(' p_computed_line_amount        : ' ||
    l_computed_line_amount);
  END IF;


  IF (p_mode = c_receipt_application_mode) THEN
    l_computed_line_amount := l_computed_line_amount - p_current_line_balance;
  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('compute_line_amount()-');
  END IF;

  RETURN l_computed_line_amount;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: compute_line_amount');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: compute_line_amount');
       debug(sqlerrm);
    END IF;
    RAISE;

END compute_line_amount;


PROCEDURE get_receipt_parameters (
  p_mode 			IN  VARCHAR2 DEFAULT NULL,
  p_customer_trx_id 		IN  NUMBER   DEFAULT NULL,
  p_acctd_amount_applied        IN  NUMBER   DEFAULT NULL,  -- func currency
  p_exchange_rate		IN  NUMBER   DEFAULT NULL,
  p_invoice_currency_code       IN  VARCHAR2 DEFAULT NULL,
  p_tax_applied			IN  NUMBER   DEFAULT NULL,
  p_charges_applied		IN  NUMBER   DEFAULT NULL,
  p_freight_applied		IN  NUMBER   DEFAULT NULL,
  p_line_applied 		IN  NUMBER   DEFAULT NULL,
  p_gl_date                     IN  DATE     DEFAULT NULL,
  p_receivable_application_id   IN  NUMBER   DEFAULT NULL,
  x_customer_trx_id 		OUT NOCOPY  NUMBER ,
  x_acctd_amount_applied        OUT NOCOPY  NUMBER,  -- func currency
  x_exchange_rate		OUT NOCOPY  NUMBER,
  x_invoice_currency_code       OUT NOCOPY  VARCHAR2,
  x_tax_applied			OUT NOCOPY  NUMBER,
  x_charges_applied		OUT NOCOPY  NUMBER,
  x_freight_applied		OUT NOCOPY  NUMBER,
  x_line_applied 		OUT NOCOPY  NUMBER,
  x_gl_date                     OUT NOCOPY  DATE) IS

  -- This cursor determines the receipt application details given a
  -- receivable application id.

  CURSOR application IS
    SELECT applied_customer_trx_id,
           acctd_amount_applied_to,
           tax_applied,
           receivables_charges_applied,
           line_applied,
           freight_applied,
           gl_date
    FROM   ar_receivable_applications
    WHERE receivable_application_id = p_receivable_application_id;

  -- This cursor retrieves the currency information for the
  -- given invoice.

  CURSOR invoice (p_trx_id IN NUMBER) IS
    SELECT invoice_currency_code,
           exchange_rate
    FROM   ra_customer_trx
    WHERE  customer_trx_id = p_trx_id;

BEGIN

  /*------------------------------------------------------------------------
  | If this procedure is being called from receipt reversal then
  | the only thing we have is the receivable application id. As a result,
  | query the details from ar_receivable_applications_all table. and then
  | from the ra_customer_trx_all.
  | If this is being called from receipt application then simply copy the
  | passed variable into the local variables.
  +------------------------------------------------------------------------*/

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_receipt_parameters()+');
  END IF;

  IF (p_mode = c_receipt_application_mode) THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('receipt application mode');
    END IF;

    -- simply copy over.

    x_customer_trx_id 		:= p_customer_trx_id;
    x_acctd_amount_applied 	:= p_acctd_amount_applied;
    x_exchange_rate 		:= p_exchange_rate;
    x_invoice_currency_code 	:= p_invoice_currency_code;
    x_tax_applied 		:= p_tax_applied;
    x_charges_applied 		:= p_charges_applied;
    x_freight_applied 		:= p_freight_applied;
    x_line_applied 		:= p_line_applied;
    x_gl_date                   := p_gl_date;

  ELSE
    IF pg_debug IN ('Y', 'C') THEN
       debug('receipt reversal mode');
    END IF;

    OPEN application;
    FETCH application INTO
      x_customer_trx_id,
      x_acctd_amount_applied,
      x_tax_applied,
      x_charges_applied,
      x_line_applied,
      x_freight_applied,
      x_gl_date;

    CLOSE application;

    OPEN invoice (x_customer_trx_id);
    FETCH invoice INTO x_invoice_currency_code, x_exchange_rate;
    CLOSE invoice;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('** get_receipt_parameters **');
     debug('  p_mode                  : ' || p_mode);
     debug('  x_customer_trx_id       : ' || x_customer_trx_id);
     debug('  x_acctd_amount_applied  : ' ||
    x_acctd_amount_applied);
     debug('  x_exchange_rate         : ' || x_exchange_rate);
     debug('  x_invoice_currency_code : ' ||
    x_invoice_currency_code);
     debug('  x_tax_applied           : ' || x_tax_applied);
     debug('  x_charges_applied       : ' || x_charges_applied);
     debug('  x_line_applied          : ' || x_line_applied);
     debug('  x_freight_applied       : ' || x_freight_applied);
     debug('  x_gl_date               : ' || x_gl_date);
     debug('  p_recv..._appl..id      : ' ||
    p_receivable_application_id);
     debug('get_receipt_parameters()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: get_receipt_parameters');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: get_receipt_parameters');
       debug(sqlerrm);
    END IF;
    RAISE;

END get_receipt_parameters;


PROCEDURE review_contingencies(p_customer_trx_line_id IN NUMBER)  IS

  CURSOR contingencies IS
    SELECT lc.customer_trx_line_id,
           lc.contingency_id,
           lc.expiration_date
    FROM   ar_line_conts lc,
           ar_deferral_reasons dr
    WHERE  lc.customer_trx_line_id = p_customer_trx_line_id
    AND    lc.contingency_id = dr.contingency_id
    AND    lc.completed_flag = 'N'
    AND    lc.expiration_date IS NOT NULL
    AND    trunc(lc.expiration_date) <= trunc(sysdate);

  l_cust_trx_line_id_tbl  number_table;
  l_contingency_id_tbl  number_table;
  l_index                 NUMBER DEFAULT 1;

  l_last_updated_by       NUMBER;
  l_last_update_login     NUMBER;


BEGIN

  debug('review_contingencies()+');

  l_last_updated_by   := fnd_global.user_id;
  l_last_update_login := fnd_global.user_id;

  -- ***** should be converted into bulk fetch and

  FOR cont_rec IN contingencies LOOP

    l_cust_trx_line_id_tbl(l_index) := cont_rec.customer_trx_line_id;
    l_contingency_id_tbl(l_index) := cont_rec.contingency_id;
    l_index := l_index + 1;

  END LOOP;

  FORALL i in 1..l_index-1
    UPDATE ar_line_conts
    SET    completed_flag      = 'Y',
           reason_removal_date = sysdate,
           last_updated_by     = l_last_updated_by,
           last_update_date    = sysdate,
           last_update_login   = l_last_update_login
    WHERE  customer_trx_line_id = l_cust_trx_line_id_tbl(i)
    AND    contingency_id       = l_contingency_id_tbl(i);

  debug('review_contingencies()-');

END review_contingencies;


FUNCTION get_line_status (p_cust_trx_line_id IN NUMBER)
  RETURN NUMBER IS

  l_line_status               NUMBER DEFAULT c_recognizable;
  l_dummy                     NUMBER;
  l_exists_cash_based         BOOLEAN;
  l_exists_contingency_based  BOOLEAN;

  CURSOR cash_based IS
    SELECT 1
    FROM   ar_line_conts lc,
           ar_deferral_reasons dr
    WHERE  lc.contingency_id = dr.contingency_id
    AND    lc.customer_trx_line_id = p_cust_trx_line_id
    AND    lc.completed_flag = 'N'
    AND    dr.revrec_event_code = 'RECEIPT_APPLICATION';


  CURSOR contingency_based IS
    SELECT 1
    FROM   ar_line_conts lc,
           ar_deferral_reasons dr
    WHERE  lc.contingency_id = dr.contingency_id
    AND    lc.customer_trx_line_id = p_cust_trx_line_id
    AND    lc.completed_flag = 'N'
    AND    dr.revrec_event_code <> 'RECEIPT_APPLICATION';

BEGIN

  /*------------------------------------------------------------------------
  | In many part of this package there is a need to know the line status.
  | IS the line deferred because of line level, or header level concerns,
  | or is it both or none. Given the status the code has to handle it
  | differently.  So, this function determines which of the four
  | scenarios we are facing.
  +------------------------------------------------------------------------*/

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_line_status()+');
     debug('** get_line_status parameters **');
     debug('  line : ' || p_cust_trx_line_id);
  END IF;

  /* 7276627 call review_contingenices by customer_Trx_line_id */
  review_contingencies(p_cust_trx_line_id);

  OPEN cash_based;
  FETCH cash_based INTO l_dummy;
  l_exists_cash_based := cash_based%FOUND;
  CLOSE cash_based;

  OPEN contingency_based;
  FETCH contingency_based INTO l_dummy;
  l_exists_contingency_based := contingency_based%FOUND;
  CLOSE contingency_based;

  IF (l_exists_cash_based AND l_exists_contingency_based) THEN
    l_line_status := c_combination;
  ELSIF (l_exists_cash_based) THEN
    l_line_status := c_cash_based;
  ELSIF (l_exists_contingency_based) THEN
    l_line_status := c_contingency_based;
  ELSE
    l_line_status := c_recognizable;
  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('get_receipt_analyzer_scenario()-');
  END IF;

  RETURN l_line_status;

EXCEPTION
  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: get_line_status');
       debug(sqlerrm);
    END IF;
    RAISE;

END get_line_status;


/****************************************************************************/
/**** All the subroutines from this point onward are public subroutines. ****/
/****************************************************************************/


/*========================================================================
 | PUBLIC PROCEDURE update_line_conts
 |
 | DESCRIPTION
 |   This procedures lets calling programs update contingencies
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   RAM Wizard
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   None.
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 28-APR-2005           ORASHID           Subroutine Created
 | 29-JUN-2006           MRAYMOND     5201842 - Fixed expiration_event_date
 |                                      to use correct parameter.
 *===========================================================================*/

PROCEDURE update_line_conts (
  p_customer_trx_line_id   NUMBER,
  p_contingency_id         NUMBER,
  p_expiration_date        DATE      DEFAULT NULL,
  p_expiration_event_date  DATE      DEFAULT NULL,
  p_expiration_days        NUMBER    DEFAULT NULL,
  p_completed_flag         VARCHAR2  DEFAULT NULL,
  p_reason_removal_date    DATE      DEFAULT NULL) IS

  l_sysdate               DATE;
  l_last_updated_by       NUMBER;
  l_last_update_login     NUMBER;
  l_line_collectible      VARCHAR2(1) DEFAULT NULL;

BEGIN

  -- This procedure simply updates a row of data in the
  -- ar_deferred_lines table. It will only update columns
  -- for which data is provided, the rest will retain their
  -- original values.

  IF pg_debug IN ('Y', 'C') THEN
     debug('update_line_conts()+');
     debug('** parameters **');
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
     debug('  p_contingency_id : ' ||
       p_contingency_id);
  END IF;

  l_sysdate           := trunc(sysdate);
  l_last_updated_by   := arp_global.user_id;
  l_last_update_login := arp_global.last_update_login;

  UPDATE ar_line_conts
  SET expiration_date = nvl(p_expiration_date, expiration_date),
      expiration_event_date = nvl(p_expiration_event_date, expiration_event_date),
      expiration_days = nvl(p_expiration_days, expiration_days),
      completed_flag  = nvl(p_completed_flag, completed_flag),
      reason_removal_date    = nvl(p_reason_removal_date, reason_removal_date),
      last_updated_by        = l_last_updated_by,
      last_update_date 	     = l_sysdate,
      last_update_login      = l_last_update_login
  WHERE customer_trx_line_id = p_customer_trx_line_id
  AND  contingency_id = p_contingency_id;

  IF pg_debug IN ('Y', 'C') THEN
     debug('update_line_conts()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: update_line_conts');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: update_line_conts');
       debug(sqlerrm);
    END IF;
    RAISE;

END update_line_conts;


/*========================================================================
 | PUBLIC PROCEDURE delete_line_conts
 |
 | DESCRIPTION
 |   This procedures lets calling programs delete contingencies
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   RAM Wizard
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   None.
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 18-MAY-2005           ORASHID           Subroutine Created
 |
 *===========================================================================*/

PROCEDURE delete_line_conts (
  p_customer_trx_line_id   NUMBER,
  p_contingency_id         NUMBER) IS

BEGIN

  -- This procedure simply deletes a row of data in the
  -- ar_deferred_lines table. It will only delete columns
  -- for which data is provided, the rest will retain their
  -- original values.

  IF pg_debug IN ('Y', 'C') THEN
     debug('delete_line_conts()+');
     debug('** delete_line_conts parameters **');
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
     debug('  p_contingency_id : ' ||
       p_contingency_id);
  END IF;

  DELETE
  FROM  ar_line_conts
  WHERE customer_trx_line_id = p_customer_trx_line_id
  AND   contingency_id = p_contingency_id;

  IF pg_debug IN ('Y', 'C') THEN
     debug('delete_line_conts()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: delete_line_conts');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: delete_line_conts');
       debug(sqlerrm);
    END IF;
    RAISE;

END delete_line_conts;


/*========================================================================
 | PUBLIC FUNCTION revenue_management_enabled
 |
 | DESCRIPTION
 |   This function checks to if anyone of the fields in revenue policy tab
 |   in the system options form is filled out.  If so it knows this feature
 |   is in use.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Auto Invoice
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   None.
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 |
 *===========================================================================*/

FUNCTION revenue_management_enabled
  RETURN BOOLEAN IS

  l_return_value BOOLEAN DEFAULT FALSE;

BEGIN

  -- This subroutine is obsolete as of 11i10+.  As of the new of the
  -- new infrastructure Revenue Management is always turned on there
  -- there is no specific mechanism to explicitly turn off the feature.
  -- Nevertheless, if no cntingencies are passed for a line then
  -- it automatically means Revenue Management would not manage that
  -- transaction.  So, this subroutine returns TRUE in hard coded
  -- fashion.

  debug('ar_revenue_management_pvt.revenue_management_enabled()+');
  l_return_value := TRUE;

  debug('ar_revenue_management_pvt.revenue_management_enabled()-');
  RETURN l_return_value;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    debug('NO_DATA_FOUND: revenue_management_enabled');
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('OTHERS: revenue_management_enabled');
    debug(sqlerrm);
    RAISE;

END revenue_management_enabled;


/*========================================================================
 | PUBLIC FUNCTION line_collectible
 |
 | DESCRIPTION
 |
 |   This function simply checks to see if a line was deemed collectible by
 |   the revenue management engine.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   p_customer_trx_id
 |   p_customer_trx_line_id
 |
 | KNOWN ISSUES
 |   Enter business functionality which was de-scoped as part of the
 |   implementation. Ideally this should never be used.
 |
 | NOTES
 |   Any interesting aspect of the code in the package body which needs
 |   to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-SEP-2002           ORASHID           Subroutine Created
 | 24-SEP-2006           MRAYMOND     5374131 - Corrected problem with
 |                                       cursor where line_id was not
 |                                       used to restrict rows.
 *===========================================================================*/

FUNCTION line_collectible (
  p_customer_trx_id      NUMBER,
  p_customer_trx_line_id NUMBER)
  RETURN NUMBER IS

  -- This cursor determines if a line is collectible or not.
  -- It does not recompute, but simply looks it up.

  CURSOR c IS
    SELECT line_collectible_flag
    FROM   ar_deferred_lines
    WHERE  customer_trx_id = p_customer_trx_id
    AND    customer_trx_line_id = p_customer_trx_line_id;

  l_flag         ar_deferred_lines.line_collectible_flag%TYPE;
  l_return_value NUMBER;

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.line_collectible()+');
     debug('** line_collectible parameters **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
  END IF;

  OPEN c;
  FETCH c INTO l_flag;

  IF (l_flag = 'Y') THEN
    l_return_value := collect;
  ELSIF (l_flag = 'N') THEN
    l_return_value := defer;
  ELSE
    l_return_value := not_analyzed;
  END IF;

  CLOSE c;

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.line_collectible()-');
  END IF;

  RETURN l_return_value;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: line_collectible');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: line_collectible');
       debug(sqlerrm);
    END IF;
    RAISE;

END line_collectible;


/*========================================================================
 | PUBLIC FUNCTION txn_collectible
 |
 | DESCRIPTION
 |
 |   This function simply checks to see if a txn was deemed collectible by
 |   the revenue management engine by looking through each line.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Transactions Work Bench
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   p_customer_trx_id
 |
 | NOTES
 |
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 14-OCT-2002           ORASHID           Subroutine Created
 |
 *===========================================================================*/

FUNCTION txn_collectible (p_customer_trx_id IN NUMBER)
  RETURN BOOLEAN IS

  -- This cursor determines if a txn is collectible or not.
  -- It does not recompute, but simply looks it up.

  CURSOR c IS
    SELECT 1
    FROM   ar_deferred_lines
    WHERE  customer_trx_id = p_customer_trx_id
    AND    original_collectibility_flag = 'N'
    AND    manual_override_flag = 'N'
    AND    rownum = 1;

  l_flag         NUMBER;
  l_return_value BOOLEAN;

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.txn_collectible()+');
     debug('** txn_collectible parameters **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
  END IF;

  OPEN c;
  FETCH c INTO l_flag;
  l_return_value := c%NOTFOUND;
  CLOSE c;

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.txn_collectible()-');
  END IF;

  RETURN l_return_value;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: txn_collectible');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: txn_collectible');
       debug(sqlerrm);
    END IF;
    RAISE;

END txn_collectible;


/*========================================================================
 | PUBLIC PROCEDURE delete_failed_rows
 |
 | DESCRIPTION
 |
 |   This procedure deletes rows from the revenue management tables for
 |   a failed auto invoice run.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Auto Invoice.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   p_request_id
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 24-SEP-2002           ORASHID           Subroutine Created
 |
 *===========================================================================*/

PROCEDURE delete_failed_rows (p_request_id IN NUMBER) IS

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.delete_failed_rows()+');
     debug('** delete_failed_rows parameters **');
     debug('  p_request_id      : ' || p_request_id);
  END IF;

  DELETE FROM ar_deferred_lines
  WHERE request_id = p_request_id;

  DELETE FROM ar_line_conts
  WHERE request_id = p_request_id;

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.delete_failed_rows()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: delete_failed_rows');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: delete_failed_rows');
       debug(sqlerrm);
    END IF;
    RAISE;

END delete_failed_rows;


/*========================================================================
 | PUBLIC PROCEDURE delete_rejected_rows
 |
 | DESCRIPTION
 |
 |   This procedure deletes rows those are rejected by auto invoice
 |   from the revenue management tables.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Auto Invoice.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   p_request_id
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 23-OCT-2002           ORASHID           Subroutine Created
 | 06-APR-2004           MRAYMOND          Modified sql to remove all
 |                                         rows for a specific transaction
 |                                         when any one is in error.
 *===========================================================================*/

PROCEDURE delete_rejected_rows (p_request_id IN NUMBER) IS

BEGIN

  debug('ar_revenue_management_pvt.delete_rejected_rows()+');
  debug('** delete_rejected_rows parameters **');
  debug('  p_request_id         : ' || p_request_id);

  ---------------------------------------------------------------------------
  -- Remove all rows form the revenue management associated with each trx
  -- that has a line being rejected.
  --
  -- NOTE:  When this code gets called, all rows with the same customer_trx_id
  --        must be rejected regardless of the batch source setting for failed
  --        lines.  The batch source setting is only relevant to early
  --        validations (pre grouping ones).

  -- First delete from the child rows

  DELETE
  FROM    ar_line_conts
  WHERE   customer_trx_line_id IN
  (
    SELECT  customer_trx_line_id
    FROM    ar_deferred_lines
    WHERE   customer_trx_id IN
    (
      SELECT DISTINCT il.customer_trx_id
      FROM   ra_interface_errors ie,
             ra_interface_lines  il
      WHERE  ie.interface_line_id = il.interface_line_id
      AND    il.request_id = p_request_id
    )
  );

  debug('contingencies deleted : ' || SQL%ROWCOUNT);

  -- Now delete from the parent rows

  DELETE
  FROM  ar_deferred_lines
  WHERE customer_trx_id IN
  (
    SELECT DISTINCT il.customer_trx_id
    FROM   ra_interface_errors ie,
           ra_interface_lines  il
    WHERE  ie.interface_line_id = il.interface_line_id
    AND    il.request_id = p_request_id
  );

  debug('lines deleted : ' || SQL%ROWCOUNT);
  debug('ar_revenue_management_pvt.delete_rejected_rows()-');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    debug('NO_DATA_FOUND: delete_rejected_rows');
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('OTHERS: delete_rejected_rows');
    debug(sqlerrm);
    RAISE;

END delete_rejected_rows;


/*========================================================================
 | PUBLIC FUNCTION acceptance_allowed
 |
 | DESCRIPTION
 |
 |   This functions checks to see if a acceptance is required for this
 |   transaction.  The users should not be able to record acceptance
 |   if the transaction is not being monitored by revenue management engine,
 |   or it is already collectible, or it is manually over ridden, and finally
 |   if acceptance is not an issue.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   RAM Wizard.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   monitored_transaction
 |
 | PARAMETERS
 |   p_customer_trx_id
 |   p_customer_trx_line_id
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 23-SEP-2002           ORASHID           Subroutine Created
 |
 *===========================================================================*/

FUNCTION acceptance_allowed (
  p_customer_trx_id 	 IN NUMBER,
  p_customer_trx_line_id IN NUMBER)
  RETURN NUMBER IS

  -- This cursor checks to see acceptance is required
  -- for this transaction or line

  CURSOR contingencies IS
    SELECT 1
    FROM   ar_deferred_lines  dl,
           ar_line_conts      lc,
           ar_deferral_reasons  dl
    WHERE  dl.customer_trx_line_id = lc.customer_trx_line_id
    AND    lc.contingency_id = dl.contingency_id
    AND    lc.completed_flag = 'N'
    AND    dl.customer_trx_id  = p_customer_trx_id
    AND    dl.customer_trx_line_id = nvl(p_customer_trx_line_id,
                                         dl.customer_trx_line_id)
    AND    dl.revrec_event_code = 'CUSTOMER_ACCEPTANCE';

  l_return_value NUMBER DEFAULT c_acceptance_allowed;
  l_dummy	 NUMBER;

BEGIN

  /*------------------------------------------------------------------------
  | This functions determines if the user using the RAM wizard will be
  | allowed to "Early Accept".  The user can NOT do that, if the transaction
  | is not being monitored by revenue management engine and/or if the line(s)
  | do not have an acceptance problem.
  +------------------------------------------------------------------------*/

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.acceptance_allowed()+');
     debug('** acceptance_allowed parameters **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
  END IF;


  IF NOT monitored_transaction(p_customer_trx_id) THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('Not A RAMC Transaction');
    END IF;
    l_return_value := c_transaction_not_monitored;

  ELSE

    IF pg_debug IN ('Y', 'C') THEN
       debug('It is a RAMC Transaction');
    END IF;
    OPEN contingencies;
    FETCH contingencies INTO l_dummy;
    IF contingencies%NOTFOUND THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('acceptance not required');
      END IF;
      l_return_value := c_acceptance_not_required;
    END IF;
    CLOSE contingencies;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('Acceptance Allowed? : ' || l_return_value);
     debug('ar_revenue_management_pvt.acceptance_allowed()-');
  END IF;

  RETURN l_return_value;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: acceptance_allowed');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: acceptance_allowed');
       debug(sqlerrm);
    END IF;
    RAISE;

END acceptance_allowed;


/*========================================================================
 | PUBLIC FUNCTION cash_based
 |
 | DESCRIPTION
 |   This functions determines if the invoice being credited is cash based
 |   invoice.  If so then the credit memo being created should
 |   hit the un-earned bucket only.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Credit Memo Module.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   None.
 |
 | PARAMETERS
 |   p_customer_trx_id
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 07-OCT-2002           ORASHID           Subroutine Created
 |
 *===========================================================================*/

FUNCTION cash_based (p_customer_trx_id IN NUMBER)
  RETURN NUMBER IS

  CURSOR contingencies IS
    SELECT 1
    FROM   ar_deferred_lines   dl,
           ar_line_conts       lc,
           ar_deferral_reasons dr
    WHERE  dl.customer_trx_line_id = lc.customer_trx_line_id
    AND    lc.contingency_id     = dr.contingency_id
    AND    lc.completed_flag       = 'N'
    AND    dr.revrec_event_code     = 'RECEIPT_APPLICATION'
    AND    dl.customer_trx_id      = p_customer_trx_id;

  l_dummy	 NUMBER;

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.cash_based()+');
     debug('** cash_based parameters **');
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
  END IF;

  IF NOT monitored_transaction (p_customer_trx_id) THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug  ('*** This Transaction Is Not Being Monitored ***');
    END IF;
    RETURN c_no;
  END IF;

  OPEN  contingencies;
  FETCH contingencies INTO l_dummy;

  IF contingencies%FOUND THEN
    RETURN c_yes;
  ELSE
    RETURN c_no;
  END IF;

  CLOSE contingencies;

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.cash_based()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: cash_based');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: cash_based');
       debug(sqlerrm);
    END IF;
    RAISE;

END cash_based;


/*========================================================================
 | PUBLIC PROCEDURE process_event

 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 |
 *=======================================================================*/

PROCEDURE process_event (
  p_cust_trx_line_id    IN  NUMBER,
  p_event_date		IN  DATE,
  p_event_code          IN  VARCHAR2) IS

  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/

  l_fully_recognized		BOOLEAN DEFAULT TRUE;
  l_not_recognized		BOOLEAN DEFAULT TRUE;
  l_first_adjustment 		BOOLEAN DEFAULT TRUE;
  l_partially_recognized	BOOLEAN;
  l_last_fetch                  BOOLEAN;
  l_line_status 		NUMBER;
  l_adjustment_number 		NUMBER;
  l_rev_adj_rec       		ar_revenue_adjustment_pvt.rev_adj_rec_type;
  l_ram_desc_flexfield          desc_flexfield;

  l_customer_trx_id	   NUMBER;
  l_amount_due_original	   NUMBER;
  l_amount_recognized	   NUMBER;
  l_amount_pending  	   NUMBER;
  l_acctd_amount_due_orig  NUMBER;
  l_acctd_amt_recognized   NUMBER;
  l_acctd_amount_pending   NUMBER;

  l_return_status     		VARCHAR2(30);
  l_msg_count         		NUMBER;
  l_msg_data          		VARCHAR2(150);

  CURSOR lines IS
    SELECT customer_trx_id,
           amount_due_original,
           acctd_amount_due_original,
      	   amount_recognized,
      	   acctd_amount_recognized,
      	   amount_pending,
      	   acctd_amount_pending
    FROM   ar_deferred_lines
    WHERE  customer_trx_line_id = p_cust_trx_line_id;

BEGIN

  -- this subroutine is equivalent of revenue synchronizer for RAM Wizard.
  -- In other words, when an event happens we need to know what is the
  -- latest on this line and adjust revenue accordingly.

  update_for_event(
    p_cust_trx_line_id => p_cust_trx_line_id,
    p_event_date       => p_event_date,
    p_event_code       => p_event_code);

  OPEN lines;
  FETCH lines
  INTO
    l_customer_trx_id,
    l_amount_due_original,
    l_acctd_amount_due_orig,
    l_amount_recognized,
    l_acctd_amt_recognized,
    l_amount_pending,
    l_acctd_amount_pending;
  CLOSE lines;

  ----------------------------------------------------------------------
  -- This is a call to a procedure that will look into each
  -- line level deferral reason and compare the current
  -- date with expiry date for each.  This will return
  -- current status of each deferral reason, and give
  -- overall verdict for this line.
  ----------------------------------------------------------------------

  l_line_status := get_line_status (
    p_cust_trx_line_id => p_cust_trx_line_id);

  IF (l_line_status = c_recognizable) THEN

    IF pg_debug IN ('Y', 'C') THEN
      debug('no issues remain');
    END IF;

    l_rev_adj_rec.line_selection_mode   := 'S';
    l_rev_adj_rec.from_cust_trx_line_id := p_cust_trx_line_id;
    l_rev_adj_rec.customer_trx_id       := l_customer_trx_id;
    l_rev_adj_rec.gl_date               := p_event_date; -- 7556149
    l_rev_adj_rec.reason_code           := 'REV_MGMT_ENGINE';
    l_rev_adj_rec.amount_mode           := 'A';
    l_rev_adj_rec.amount                := l_amount_due_original;

    adjust_revenue(
      p_mode 			=> c_earn_revenue,
      p_customer_trx_id 	=> l_customer_trx_id,
      p_customer_trx_line_id 	=> p_cust_trx_line_id,
      p_acctd_amount            => l_acctd_amount_due_orig,
      p_ram_desc_flexfield	=> l_ram_desc_flexfield,
      p_rev_adj_rec 		=> l_rev_adj_rec,
      p_gl_date                 => p_event_date, -- 7556149
      x_adjustment_number       => l_adjustment_number,
      x_return_status           => l_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data);

    IF pg_debug IN ('Y', 'C') THEN
      debug('Revenue adjusted and now updating rvmg tables');
    END IF;

    update_deferred_lines (
      p_customer_trx_line_id 	=> p_cust_trx_line_id,
      p_line_status 		=> l_line_status,
      p_amount_recognized	=> l_amount_due_original,
      p_acctd_amount_recognized => l_acctd_amount_due_orig,
      p_amount_pending		=> 0,
      p_acctd_amount_pending	=> 0);

    ELSIF (l_line_status = c_cash_based) THEN

      --------------------------------------------------------------------
      -- acceptance was the only hang up or some line level problems
      -- along with acceptance were the problems, but they are now
      -- alleviated, so we can now recognize reveneue for this line.
      -- However, credit problem still remain, so we can recognize only
      -- upto the amount already applied. So, if there is anything in the
      -- pending column we should recognize that much.           |
      --------------------------------------------------------------------

      IF pg_debug IN ('Y', 'C') THEN
        debug('only header issues remain');
      END IF;

      IF (l_amount_pending > 0) THEN

        IF pg_debug IN ('Y', 'C') THEN
          debug('amount pending is greater than zero');
        END IF;

        l_rev_adj_rec.line_selection_mode   := 'S';
        l_rev_adj_rec.from_cust_trx_line_id := p_cust_trx_line_id;
        l_rev_adj_rec.customer_trx_id    := l_customer_trx_id;
        l_rev_adj_rec.gl_date            := p_event_date;
        l_rev_adj_rec.reason_code        := 'REV_MGMT_ENGINE';
        l_rev_adj_rec.amount_mode        := 'A';
        l_rev_adj_rec.amount             := l_amount_pending;

        adjust_revenue(
          p_mode 		  => c_earn_revenue,
          p_customer_trx_id 	  => l_customer_trx_id,
          p_customer_trx_line_id  => p_cust_trx_line_id,
          p_acctd_amount          => l_acctd_amount_pending,
          p_ram_desc_flexfield    => l_ram_desc_flexfield,
          p_rev_adj_rec 	  => l_rev_adj_rec,
          p_gl_date               => p_event_date,
          x_adjustment_number     => l_adjustment_number,
          x_return_status         => l_return_status,
          x_msg_count             => l_msg_count,
          x_msg_data              => l_msg_data);

      END IF;

      update_deferred_lines (
        p_customer_trx_line_id 	  => p_cust_trx_line_id,
        p_line_status 	  	  => l_line_status,
        p_amount_recognized	  => l_amount_pending,
        p_acctd_amount_recognized => l_acctd_amount_pending,
        p_amount_pending	  => 0,
        p_acctd_amount_pending	  => 0);

    END IF;

END process_event;


/*========================================================================
 | PUBLIC PROCEDURE revenue_synchronizer
 |
 | DESCRIPTION
 |   This procedure takes care of all the manual revenue events such as
 |   acceptance and manual revenue adjustments from the RAM screens. This way
 |   our revenue management tables are never out of sync. Here, the mode
 |   indicates which event has occurred e.g. Acceptance or Manual adjustments.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |
 |   This is called from RAM Wizard in the application.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   manual_overide
 |   review_line_collectibility
 |   adjust_revenue
 |   update_deferred_lines
 |
 | PARAMETERS
 |   p_mode
 |   p_customer_trx_id
 |   p_customer_trx_line_id
 |   p_gl_date
 |   p_comments
 |   p_ram_desc_flexfield
 |
 | NOTES
 |   This procedure will be called for any RAM adjustments done any where in
 |   the system.  A new field has been added to RAM record structure called
 |   source.  If the source is not this package
 |   (c_source_revenue_management_source) then a call will be placed here
 |   to indicate manual override.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 | 26-APR-2006           MRAYMOND       5043785 - Added logic to prevent
 |                                        child insert and OM call when
 |                                        acceptance contingency is not
 |                                        sourced from OM
 |
 *=======================================================================*/

PROCEDURE revenue_synchronizer (
  p_mode 			IN  NUMBER,
  p_customer_trx_id 		IN  NUMBER,
  p_customer_trx_line_id 	IN  NUMBER,
  p_gl_date			IN  DATE,
  p_comments			IN  VARCHAR2,
  p_ram_desc_flexfield          IN  desc_flexfield,
  x_scenario 			OUT NOCOPY NUMBER,
  x_first_adjustment_number 	OUT NOCOPY NUMBER,
  x_last_adjustment_number 	OUT NOCOPY NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2,
  x_msg_count                   OUT NOCOPY NUMBER,
  x_msg_data                    OUT NOCOPY VARCHAR2) IS


 /*-----------------------------------------------------------------------+
  | Cursor Declarations                                                   |
  +-----------------------------------------------------------------------*/

  -- This cursor retrieves all the valid rows from the revenue
  -- management tables.

  CURSOR rev_lines IS
    SELECT customer_trx_line_id,
           customer_trx_id,
           amount_due_original,
           acctd_amount_due_original,
      	   amount_recognized,
      	   acctd_amount_recognized,
      	   amount_pending,
      	   acctd_amount_pending
    FROM   ar_reviewed_lines_gt
    WHERE  request_id = nvl(p_customer_trx_line_id, -- 7328069
                        nvl(p_customer_trx_id,
                        request_id));


  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/

  lr_customer_trx_id_tbl 	number_table;
  lr_customer_trx_line_id_tbl	number_table;
  lr_line_collectible_tbl 	varchar_table;
  lr_amount_due_original_tbl 	number_table;
  lr_amount_recognized_tbl 	number_table;
  lr_amount_pending_tbl   	number_table;
  lr_acctd_amount_due_orig_tbl	number_table;
  lr_acctd_amt_recognized_tbl	number_table;
  lr_acctd_amount_pending_tbl 	number_table;

  l_partially_recognized	BOOLEAN;
  l_fully_recognized		BOOLEAN DEFAULT TRUE;
  l_not_recognized		BOOLEAN DEFAULT TRUE;

  l_first_adjustment 		BOOLEAN DEFAULT TRUE;
  l_last_fetch                  BOOLEAN;
  l_line_status 		NUMBER;
  l_adjustment_number 		NUMBER;
  l_rev_adj_rec       		ar_revenue_adjustment_pvt.rev_adj_rec_type;

  l_return_status     		VARCHAR2(30);
  l_msg_count         		NUMBER;
  l_msg_data          		VARCHAR2(150);

BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.revenue_synchronizer +');
     debug('** revenue_synchronizer parameters **');
     debug('  p_mode                 : ' || p_mode);
     debug('  p_customer_trx_id      : ' || p_customer_trx_id);
     debug('  p_customer_trx_line_id : ' ||
       p_customer_trx_line_id);
     debug('  p_gl_date              : ' || p_gl_date);
     debug('  p_comments             : ' || p_comments);
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

  IF (p_mode = c_manual_override_mode) THEN

    IF pg_debug IN ('Y', 'C') THEN
       debug('called in manual override mode');
    END IF;

    manual_override(
      p_customer_trx_id => p_customer_trx_id,
      p_customer_trx_line_id => p_customer_trx_line_id);

  ELSE

    IF (p_mode = c_acceptance_obtained_mode) THEN

      IF pg_debug IN ('Y', 'C') THEN
        debug('called in acceptance obtained mode');
      END IF;

      populate_acceptance_rows(
        p_customer_trx_id      => p_customer_trx_id,
        p_customer_trx_line_id => p_customer_trx_line_id,
        p_mode                 => 'RECORD');

      /* 5043785 - Both populate_child_rows and record_acceptance_with_om
         are now smart enough to not process when the lines
         did not originate from Oracle's Order Management
         product */

      populate_child_rows(
        p_customer_trx_id      => p_customer_trx_id,
        p_customer_trx_line_id => p_customer_trx_line_id);

      record_acceptance_with_om(
        p_called_from          => 'WIZARD',
        p_customer_trx_id      => p_customer_trx_id,
        p_cust_trx_line_id     => p_customer_trx_line_id,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data);

    ELSE

      -- populate expiring contingencies for this line(s)
      -- this is called from RAM Wizard when user modifies
      -- contingencies. RAM Wizard would call the subroutine
      -- update_line_conts first before calling the synchornize

      populate_other_rows(
        p_customer_trx_id      => p_customer_trx_id,
        p_customer_trx_line_id => p_customer_trx_line_id,
        p_mode                 => 'UPDATE');

      -- if the user deletes the last contingency
      populate_no_contingency_rows(
        p_customer_trx_id      => p_customer_trx_id,
        p_customer_trx_line_id => p_customer_trx_line_id);


    END IF;

    -- open the lines identified to have updated contingencies
    OPEN rev_lines;
    LOOP

        debug('inside loop');

      -- otherwise the row count may not be zero
      -- and we will be stuck in an infinite loop.

      lr_customer_trx_line_id_tbl.delete;
      lr_customer_trx_id_tbl.delete;
      lr_amount_due_original_tbl.delete;
      lr_acctd_amount_due_orig_tbl.delete;
      lr_amount_recognized_tbl.delete;
      lr_acctd_amt_recognized_tbl.delete;
      lr_amount_pending_tbl.delete;
      lr_acctd_amount_pending_tbl.delete;

      FETCH rev_lines BULK COLLECT INTO
        lr_customer_trx_line_id_tbl,
        lr_customer_trx_id_tbl,
        lr_amount_due_original_tbl,
        lr_acctd_amount_due_orig_tbl,
        lr_amount_recognized_tbl,
        lr_acctd_amt_recognized_tbl,
        lr_amount_pending_tbl,
        lr_acctd_amount_pending_tbl
      LIMIT c_max_bulk_fetch_size;

      IF rev_lines%NOTFOUND THEN
        IF pg_debug IN ('Y', 'C') THEN
          debug('rev_lines%NOTFOUND');
        END IF;
        l_last_fetch := TRUE;
      END IF;

        debug('inside loop: ' || lr_customer_trx_line_id_tbl.COUNT);
      IF lr_customer_trx_line_id_tbl.COUNT = 0 AND l_last_fetch THEN
        IF pg_debug IN ('Y', 'C') THEN
           debug('No more rows');
        END IF;
        EXIT;
      END IF;

      FOR i IN lr_customer_trx_line_id_tbl.FIRST ..
               lr_customer_trx_line_id_tbl.LAST LOOP

        IF pg_debug IN ('Y', 'C') THEN
           debug('Revenue Synchronizer Loop - Line ID: ' ||
          lr_customer_trx_line_id_tbl(i));
        END IF;

        IF (p_mode = c_acceptance_obtained_mode) THEN
          update_for_event(
            p_cust_trx_line_id => lr_customer_trx_line_id_tbl(i),
            p_event_date       => sysdate,
            p_event_code       => 'CUSTOMER_ACCEPTANCE');
        END IF;

        ----------------------------------------------------------------------
        -- This is a call to a procedure that will look into each
        -- line level deferral reason and compare the current
        -- date with expiry date for each.  This will return
        -- current status of each deferral reason, and give
        -- overall verdict for this line.
        ----------------------------------------------------------------------

        l_line_status := get_line_status (
          p_cust_trx_line_id => lr_customer_trx_line_id_tbl(i));

        debug('line status: ' || l_line_status);

        IF (l_line_status = c_recognizable) THEN

          -- acceptance was the only hang up after all the expirations have
          -- been re-evaluated, so we can now recognize reveneue for this
          -- line.

          IF pg_debug IN ('Y', 'C') THEN
             debug('no issues remain');
          END IF;

          l_rev_adj_rec.line_selection_mode   := 'S';
          l_rev_adj_rec.from_cust_trx_line_id :=
            lr_customer_trx_line_id_tbl(i);
          l_rev_adj_rec.customer_trx_id    := p_customer_trx_id;
          l_rev_adj_rec.gl_date            := p_gl_date; -- 7158075
          l_rev_adj_rec.reason_code        := 'REV_MGMT_ENGINE';
          l_rev_adj_rec.amount_mode        := 'A';
          l_rev_adj_rec.amount             := lr_amount_due_original_tbl(i);

          adjust_revenue(
            p_mode 			=> c_earn_revenue,
            p_customer_trx_id 		=> p_customer_trx_id,
            p_customer_trx_line_id 	=> p_customer_trx_line_id,
            p_acctd_amount              => lr_acctd_amount_due_orig_tbl(i),
            p_ram_desc_flexfield	=> p_ram_desc_flexfield,
            p_gl_date                   => p_gl_date, -- 7158075
            p_rev_adj_rec 		=> l_rev_adj_rec,
            x_adjustment_number         => l_adjustment_number,
            x_return_status             => x_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data);

          IF pg_debug IN ('Y', 'C') THEN
           debug('Revenue adjusted and now updating rvmg tables');
          END IF;

          update_deferred_lines (
            p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
            p_line_status 		=> l_line_status,
            p_amount_recognized		=> lr_amount_due_original_tbl(i),
            p_acctd_amount_recognized 	=> lr_acctd_amount_due_orig_tbl(i),
            p_amount_pending		=> 0,
            p_acctd_amount_pending	=> 0);

          -- since at least one line of this invoice is recognized, the
          -- flag that says nothing is recognized should be turned off.
          l_not_recognized := FALSE;

        ELSIF (l_line_status = c_cash_based) THEN

          --------------------------------------------------------------------
          -- acceptance was the only hang up or some line level problems
          -- along with acceptance were the problems, but they are now
          -- alleviated, so we can now recognize reveneue for this line.
          -- However, credit problem still remain, so we can recognize only
          -- upto the amount already applied. So, if there is anything in the
          -- pending column we should recognize that much.           |
          --------------------------------------------------------------------

          IF pg_debug IN ('Y', 'C') THEN
             debug('only header issues remain');
          END IF;

          IF (lr_amount_pending_tbl(i) > 0) THEN

            IF pg_debug IN ('Y', 'C') THEN
               debug('amount pending is greater than zero');
            END IF;

            l_rev_adj_rec.line_selection_mode   := 'S';
            l_rev_adj_rec.from_cust_trx_line_id :=
              lr_customer_trx_line_id_tbl(i);
            l_rev_adj_rec.customer_trx_id    := p_customer_trx_id;
            l_rev_adj_rec.gl_date            := p_gl_date; -- 7158075
            l_rev_adj_rec.reason_code        := 'REV_MGMT_ENGINE';
            l_rev_adj_rec.amount_mode        := 'A';
            l_rev_adj_rec.amount             := lr_amount_pending_tbl(i);

            adjust_revenue(
              p_mode 			=> c_earn_revenue,
              p_customer_trx_id 	=> p_customer_trx_id,
              p_customer_trx_line_id 	=> p_customer_trx_line_id,
              p_acctd_amount            => lr_acctd_amount_pending_tbl(i),
              p_ram_desc_flexfield	=> p_ram_desc_flexfield,
              p_gl_date                 => p_gl_date, -- 7158075
              p_rev_adj_rec 		=> l_rev_adj_rec,
              x_adjustment_number       => l_adjustment_number,
              x_return_status           => x_return_status,
              x_msg_count               => x_msg_count,
              x_msg_data                => x_msg_data);

            -- since at least one line of this invoice is recognized, the
            -- flag that says nothing is recognized should be turned off.
            l_not_recognized := FALSE;

            IF NOT (lr_amount_pending_tbl(i) =
                    lr_amount_due_original_tbl(i) ) THEN

              -- since a partial amount of a line is recognized then
              -- flags indicating all or nothing is recognized should be
              -- turned off and instead the partial flag must be turned on.
              l_not_recognized := FALSE;
              l_fully_recognized := FALSE;
              l_partially_recognized := TRUE;

            END IF;

          ELSE

            -- since at least one line of this invoice was not fully
            -- recognized, the flag that says all recognized should be
            -- turned off.

            IF pg_debug IN ('Y', 'C') THEN
               debug('amount pending is NOT greater than zero');
            END IF;
            l_fully_recognized := FALSE;

          END IF;

          update_deferred_lines (
            p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
            p_line_status 	  	=> l_line_status,
            p_amount_recognized	  	=> lr_amount_pending_tbl(i),
            p_acctd_amount_recognized   => lr_acctd_amount_pending_tbl(i),
            p_amount_pending	        => 0,
            p_acctd_amount_pending	=> 0);

        ELSE

          -- Simply record acceptance any other line level updates.
          -- we can not recognize revenue because there exists at least
          -- one reason for deferral.

          IF pg_debug IN ('Y', 'C') THEN
             debug('other line level issues remain');
          END IF;

          l_fully_recognized := FALSE;

        END IF;


        -- We need to track the first and the last adjustment number
        -- because this will be used in RAM results window. These values
        -- serve as the lower and upper limit values for the BETWEEN clause.

        -- l_adjustment_number is will not be null when a revenue adjustment
        -- actually takes place.

        IF (l_adjustment_number IS NOT NULL) THEN

          IF (l_first_adjustment) THEN

            -- for the first time we want to make sure the last one has the
            -- value same as the first one, so that if this is the last
            -- adjustment in this run, the between clause will still work.

            IF pg_debug IN ('Y', 'C') THEN
               debug('first adjustment' || l_adjustment_number);
            END IF;
            x_first_adjustment_number := l_adjustment_number;
            x_last_adjustment_number := l_adjustment_number;
            l_first_adjustment := FALSE;

          ELSE

            -- from now on simply move the upper limit along.

            IF pg_debug IN ('Y', 'C') THEN
               debug('last adjustment' || l_adjustment_number);
            END IF;
            x_last_adjustment_number := l_adjustment_number;

          END IF;

          -- reset the variable to null, we will keep getting in and re-assign
          -- same number over and over again.

          l_adjustment_number := null;

        END IF;

      END LOOP;

    END LOOP;

    -- it is possible that there are no rows in ar_reviewed_lines_gt
    -- in that no revenue will be recognized.
    IF (x_first_adjustment_number IS NULL) AND
       (x_last_adjustment_number IS NULL) THEN
      x_scenario := c_not_recognized;
      RETURN;
    END IF;

    IF (l_partially_recognized) THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('partially recognized');
      END IF;
      x_scenario := c_partially_recognized;
    ELSIF (l_fully_recognized) THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('fully recognized');
      END IF;
      x_scenario := c_fully_recognized;
    ELSE
      IF pg_debug IN ('Y', 'C') THEN
         debug('not recognized');
      END IF;
      x_scenario := c_not_recognized;
    END IF;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.revenue_synchronizer()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('NO_DATA_FOUND: revenue_synchronizer');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('OTHERS: revenue_synchronizer');
       debug(sqlerrm);
    END IF;
    RAISE;

END revenue_synchronizer;

/*========================================================================
 | PUBLIC PROCEDURE periodic_sweeper
 |
 | DESCRIPTION
 |   This procedure re-evaluates collectibility for alrady deferred invoices.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |   This procedure is called from a concurrent program named ARREVSWP.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |   review_line_collectibility
 |   get_line_status
 |   adjust_revenue
 |   update_deferred_lines
 |
 | PARAMETERS
 |   None.
 |
 | NOTES
 |   Note that creditworthiness of a customer will be never be checked again.
 |   This function only checks for expiration.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 |
 | 31-OCT-2005           APANDIT           Enabling this conc program to
 |                                         be run as multi-org
 | 03-FEB-2006  	 JBECKETT  	   Bug 4757939 - Added org_id parameter
 *=======================================================================*/

PROCEDURE periodic_sweeper (
  errbuf   OUT NOCOPY VARCHAR2,
  retcode  OUT NOCOPY VARCHAR2,
  p_org_id IN NUMBER) IS

 /*-----------------------------------------------------------------------+
  | Cursor Declarations                                                   |
  +-----------------------------------------------------------------------*/

  -- This cursor retrieves all the lines which are contingency based
  CURSOR expiring_lines (p_request_id NUMBER) IS
    SELECT customer_trx_line_id,
           MAX(customer_trx_id),
           MAX(amount_due_original),
           MAX(acctd_amount_due_original),
      	   MAX(amount_recognized),
      	   MAX(acctd_amount_recognized),
      	   MAX(amount_pending),
      	   MAX(acctd_amount_pending),
           MAX(expiration_date)
    FROM   ar_reviewed_lines_gt
    WHERE  request_id = p_request_id
    GROUP  BY customer_trx_line_id;

 /*Bug 4675710  */
  CURSOR cur_orgs IS
  SELECT org_id FROM ar_system_parameters
  WHERE  org_id = NVL(p_org_id,org_id);

  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/

  l_return_status     		VARCHAR2(30);
  l_msg_count         		NUMBER;
  l_msg_data          		VARCHAR2(150);

  l_last_fetch                  BOOLEAN;
  l_line_status 		NUMBER;
  l_adjustment_number		NUMBER;

  l_rev_adj_rec       		ar_revenue_adjustment_pvt.rev_adj_rec_type;
  l_ram_desc_flexfield          desc_flexfield;

  lr_customer_trx_line_id_tbl	number_table;
  lr_customer_trx_id_tbl 	number_table;
  lr_line_collectible_tbl 	varchar_table;
  lr_amount_due_original_tbl 	number_table;
  lr_amount_recognized_tbl 	number_table;
  lr_amount_pending_tbl 	number_table;
  lr_acctd_amount_due_orig_tbl	number_table;
  lr_acctd_amt_recognized_tbl	number_table;
  lr_acctd_amount_pending_tbl 	number_table;
  lr_expiration_date_tbl        date_table;


  l_request_id                  NUMBER;
  l_hold_trx_id                 NUMBER;
  l_trx_number                  NUMBER;
  return_warning                BOOLEAN;
  error_message                 VARCHAR2(50);

BEGIN

  debug('ar_revenue_management_pvt.periodic_sweeper +');

  retcode := SUCCESS;

  l_request_id := fnd_global.conc_request_id;

  /**allows to skip certain steps like rounding from the standard flow and
     process the same in bulk mode for better performance.  */
  AR_RAAPI_UTIL.g_called_from := 'SWEEPER';

 FOR morgs in cur_orgs
  LOOP
  mo_global.set_policy_context('S',morgs.org_id);
  /* Bug fix 5351734
     Delete the data in the global temporary tables */
  delete from ar_rdr_parameters_gt;
  delete from ar_trx_errors_gt;
  delete from ar_trx_header_gt;
  delete from ar_trx_lines_gt;
  delete from ar_reviewed_lines_gt;
  delete from fun_rule_bulk_result_gt;
  delete from ar_trx_contingencies_gt;

  populate_acceptance_rows;
  populate_child_rows;

  record_acceptance_with_om (
    p_called_from      => 'SWEEPER',
    p_request_id       => l_request_id,
    x_return_status    => l_return_status,
    x_msg_count        => l_msg_count,
    x_msg_data         => l_msg_data);

  populate_other_rows;

  debug('about to open deferred lines');

  OPEN expiring_lines(l_request_id);
  LOOP

    -- this table must be deleted for re-entry
    -- otherwise the row count may not be zero
    -- and we will be stuck in an infinite loop.

    lr_customer_trx_line_id_tbl.delete;
    lr_customer_trx_id_tbl.delete;
    lr_amount_due_original_tbl.delete;
    lr_acctd_amount_due_orig_tbl.delete;
    lr_amount_recognized_tbl.delete;
    lr_acctd_amt_recognized_tbl.delete;
    lr_amount_pending_tbl.delete;
    lr_acctd_amount_pending_tbl.delete;
    lr_expiration_date_tbl.delete;

    FETCH expiring_lines BULK COLLECT INTO
      lr_customer_trx_line_id_tbl,
      lr_customer_trx_id_tbl,
      lr_amount_due_original_tbl,
      lr_acctd_amount_due_orig_tbl,
      lr_amount_recognized_tbl,
      lr_acctd_amt_recognized_tbl,
      lr_amount_pending_tbl,
      lr_acctd_amount_pending_tbl,
      lr_expiration_date_tbl
    LIMIT c_max_bulk_fetch_size;

    IF expiring_lines%NOTFOUND THEN
      l_last_fetch := TRUE;
    END IF;

    IF lr_customer_trx_line_id_tbl.COUNT = 0 AND l_last_fetch THEN
      debug('last fetch and COUNT equals zero');
      EXIT;
    END IF;

    debug('Periodic Sweeper: about to enter the loop');
    debug('Count: ' || lr_customer_trx_line_id_tbl.COUNT);
    debug('First: ' || lr_customer_trx_line_id_tbl.FIRST);
    debug('Last:  ' || lr_customer_trx_line_id_tbl.LAST);

    FOR i IN lr_customer_trx_line_id_tbl.FIRST ..
             lr_customer_trx_line_id_tbl.LAST LOOP

      debug('Periodic Sweeper Loop - Line ID: ' ||
        lr_customer_trx_line_id_tbl(i));

      -- re-evaluate each reason for line level and determine
      -- line level collectibility.  The following function
      -- determines the status of line.  It will
      -- indicate what kind of issues remain.

       savepoint s1;

      l_line_status := get_line_status (
        p_cust_trx_line_id => lr_customer_trx_line_id_tbl(i));

      debug('scenario : ' || l_line_status);

      l_rev_adj_rec.from_cust_trx_line_id := lr_customer_trx_line_id_tbl(i);
      l_rev_adj_rec.customer_trx_id 	  := lr_customer_trx_id_tbl(i);
      l_rev_adj_rec.line_selection_mode   := 'S';
      l_rev_adj_rec.reason_code 	  := 'REV_MGMT_ENGINE';
      l_rev_adj_rec.amount_mode 	  := 'A';

      /* 7449886 - lr_expiration_date_tbl(i) will only have a value if
         there was a contingency with an expiration date
         that was <= sysdate.  If this is the case, use
         the expiration_date as the gl_date */
      IF lr_expiration_date_tbl(i) IS NOT NULL
      THEN
         l_rev_adj_rec.gl_date := lr_expiration_date_tbl(i);
         debug('  expiration date = ' || lr_expiration_date_tbl(i));
      ELSE
         l_rev_adj_rec.gl_date := trunc(sysdate);
      END IF;

      IF (l_line_status = c_recognizable) THEN

        debug('no issues remain');

        l_rev_adj_rec.amount := lr_amount_due_original_tbl(i);

        debug('Amount Adjusted: ' || lr_amount_due_original_tbl(i));
        debug('Acctd Amount Adjusted: ' || lr_acctd_amount_due_orig_tbl(i));

        lr_amount_recognized_tbl(i)    := lr_amount_due_original_tbl(i);
        lr_acctd_amt_recognized_tbl(i) := lr_acctd_amount_due_orig_tbl(i);
        lr_amount_pending_tbl(i)       := 0;
        lr_acctd_amount_pending_tbl(i) := 0;

	BEGIN

        debug('calling RAM API');

        adjust_revenue(
          p_mode 			=> c_earn_revenue,
          p_customer_trx_id 		=> lr_customer_trx_id_tbl(i),
          p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
          p_acctd_amount                => lr_acctd_amount_due_orig_tbl(i),
          p_ram_desc_flexfield	        => l_ram_desc_flexfield,
          p_rev_adj_rec 		=> l_rev_adj_rec,
          p_gl_date                     => l_rev_adj_rec.gl_date,
          x_adjustment_number           => l_adjustment_number,
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data);

        debug('returned from RAM API');

EXCEPTION
	     WHEN OTHERS THEN
		return_warning := TRUE;
		rollback to s1;

		IF nvl(l_hold_trx_id,-99) <> lr_customer_trx_id_tbl(i)
		THEN
		   /* get trx_number */
		   select trx_number
		   into   l_trx_number
		   from   ra_customer_trx
		   where  customer_trx_id = lr_customer_trx_id_tbl(i);

		   l_hold_trx_id := lr_customer_trx_id_tbl(i);

		   fnd_file.put_line(FND_FILE.LOG, 'trx_number ' ||
       l_trx_number
		     || ' had problems generating revenue.');
		END IF;
		GOTO continue_loop;
	  END;

      ELSIF (l_line_status = c_cash_based) THEN

        debug('cash based scenario');

        IF (lr_amount_pending_tbl(i) > 0) THEN

          -- now the only hang up is header level.  So, whatever is sitting
          -- in the pending column, must now be recognized.

          debug('pending amount being recognized');

          l_rev_adj_rec.amount := lr_amount_pending_tbl(i);

          debug('Amount Adjusted: ' || lr_amount_pending_tbl(i));

          lr_amount_recognized_tbl(i)    := lr_amount_pending_tbl(i);
          lr_acctd_amt_recognized_tbl(i) := lr_acctd_amount_pending_tbl(i);
          lr_amount_pending_tbl(i)       := 0;
          lr_acctd_amount_pending_tbl(i) := 0;

	  BEGIN
              savepoint s2;
          debug('calling RAM API');

          adjust_revenue(
            p_mode 			=> c_earn_revenue,
            p_customer_trx_id 		=> lr_customer_trx_id_tbl(i),
            p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
            p_acctd_amount              => lr_acctd_amount_due_orig_tbl(i),
            p_ram_desc_flexfield	=> l_ram_desc_flexfield,
            p_rev_adj_rec 		=> l_rev_adj_rec,
            p_gl_date                   => l_rev_adj_rec.gl_date,
            x_adjustment_number         => l_adjustment_number,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data);

          debug('returned from RAM API');

EXCEPTION
	     WHEN OTHERS THEN


		        return_warning := TRUE;
		        rollback to s2;

		IF nvl(l_hold_trx_id,-99) <> lr_customer_trx_id_tbl(i)
		THEN
		   /* get trx_number */
		   select trx_number
		   into   l_trx_number
		   from   ra_customer_trx
		   where  customer_trx_id = lr_customer_trx_id_tbl(i);

		   l_hold_trx_id := lr_customer_trx_id_tbl(i);

		   fnd_file.put_line(FND_FILE.LOG, 'trx_number ' ||
       l_trx_number
		     || ' had problems generating revenue.' );
		END IF;
		GOTO continue_loop;
	  END;

        END IF;

      END IF;

      debug('update rvmg table');

      update_deferred_lines (
        p_customer_trx_line_id 	  => lr_customer_trx_line_id_tbl(i),
        p_line_status   	  => l_line_status,
        p_amount_recognized  	  => lr_amount_recognized_tbl(i),
        p_acctd_amount_recognized => lr_acctd_amt_recognized_tbl(i),
        p_amount_pending  	  => lr_amount_pending_tbl(i),
        p_acctd_amount_pending    => lr_acctd_amount_pending_tbl(i));

      -- l_old_customer_trx_id := lr_customer_trx_id_tbl(i);
          <<continue_loop>>
      debug('done for the line');

    END LOOP; -- FIRST .. lr_customer_trx_line_id_tbl.LAST

  END LOOP; -- bulk collect

  CLOSE expiring_lines;

  /** Revenue Adjustment API will not call rounding logic if the call is from sweeper program (based
      on package global value AR_RAAPI_UTIL.g_called_from passed as SWEEPER),this call will round
      each adjustment that is recorded in ar_rev_line_adj_gt */
  IF (arp_rounding.correct_rev_adj_by_line = 0) THEN
    arp_util.debug('ERROR:  arp_rounding.correct_rev_adj_by_line');
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  END LOOP; -- cur_orgs Bug4675710

  retcode := SUCCESS;

    IF (return_warning)
     THEN
	 debug('Attempting to set WARNING return status');
	 error_message := FND_MESSAGE.GET_STRING('AR','AR_UNABLE_TO_GEN_DEF_ACCG');

	 IF (FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING', error_message) = FALSE)
	 THEN
	       debug('Unable to set WARNING return status');
	 END IF;
     END IF;

  debug('ar_revenue_management_pvt.periodic_sweeper -');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    retcode := FAILURE;
    errbuf  := 'EXCEPTION: NO_DATA_FOUND: periodic_sweeper';
    debug('EXCEPTION: NO_DATA_FOUND: periodic_sweeper');
    debug(sqlerrm);

    RAISE;

  WHEN OTHERS THEN
    retcode := FAILURE;
    errbuf  := 'EXCEPTION: OTHERS: periodic_sweeper';
    debug('EXCEPTION: OTHERS: periodic_sweeper');
    debug(sqlerrm);

    RAISE;

END periodic_sweeper;


/*========================================================================
 | PUBLIC PROCEDURE receipt_analyzer
 |
 | DESCRIPTION
 |   This procedure takes care of receipt applications from collectibility
 |   perspective.  When a receipt is applied, which is an event for
 |   revenue management engine, this procedure determines if this receipt
 |   can trigger revenue recognition.  In cases where creditworthiness and/or
 |   payment term was the reason for revenue deferra, it would recognize the
 |   revenue upto the receipt amount.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |   This procedure is called from all the places where receipt is applied.
 |     1. receipts api
 |     2. receipt application form
 |     3. auto receipts
 |     4. post batch (lock box)
 |     5. confirmation
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 |   get_receipt_parameters
 |   get_total_application
 |   get_acctd_total_application
 |   get_line_status
 |   compute_line_amount
 |   update_deferred_lines
 |   adjust_revenue
 |
 | PARAMETERS
 |
 |   p_mode
 |   p_customer_trx_id
 |   p_acctd_amount_applied
 |   p_exchange_rate
 |   p_invoice_currency_code
 |   p_tax_applied
 |   p_charges_applied
 |   p_freight_applied
 |   p_line_applied
 |   p_receivable_application_id
 |
 | KNOWN ISSUES
 |   Enter business functionality which was de-scoped as part of the
 |   implementation. Ideally this should never be used.
 |
 | NOTES
 |   The receipt analyzer does a variety of things depending on what
 |   is the scenation it is handling.  Below, I give a matrix of what
 |   it does for future use.
 |
 |    SCENARIO		  	ACTION
 |
 |    Cash Based         	Recognize Up To The Receipt Amount
 |    Combination               Put In The Pending Column Up to The
 |                              Receipt Amount
 |    Contingency Based         No action, it will be recognized by the
 |                              Peridioc Sweeper.
 |    Recognize                 Recognize Fully.
 |
 |    Let me try to give the functional reasoning behind each one of the
 |    scenario above.  The first case is where only problem is a credit
 |    problem and/or payment term problem.  In both cases, the we are
 |    doubtfult that we may not collect money for it.  So, when money
 |    arrives, we can immediately recognize it.
 |
 |    In the second scneario, it is the very similar to the first one
 |    however, there may be a non-standard refund clause so we can not
 |    recognize any revenue until that has expired.  At the same time,
 |    we do not lose track of this receipt. So, we put in pending, and
 |    as soon as the expiration happens this pending amount will be
 |    recognized.
 |
 |    Third scenario is the simplest, we do not do anything.  Simply because
 |    when all expire the periodic sweeper is smart enough to recognize the
 |    entire amount.
 |
 |    The fourth scenario happens when intially there was a non-standard
 |    refund policy for this line. And just before this receipt arrived,
 |    this expired, so now we should do the periodc sweeper's job and
 |    recognize all revenue.
 |
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 |
 *=======================================================================*/

PROCEDURE receipt_analyzer (
  p_mode 			IN  VARCHAR2 DEFAULT NULL,
  p_customer_trx_id 		IN  NUMBER   DEFAULT NULL,
  p_acctd_amount_applied        IN  NUMBER   DEFAULT NULL,
  p_exchange_rate		IN  NUMBER   DEFAULT NULL,
  p_invoice_currency_code       IN  VARCHAR2 DEFAULT NULL,
  p_tax_applied			IN  NUMBER   DEFAULT NULL,
  p_charges_applied		IN  NUMBER   DEFAULT NULL,
  p_freight_applied		IN  NUMBER   DEFAULT NULL,
  p_line_applied 		IN  NUMBER   DEFAULT NULL,
  p_receivable_application_id   IN  NUMBER   DEFAULT NULL,
  p_gl_date                     IN  DATE     DEFAULT NULL) IS

 /*-----------------------------------------------------------------------+
  | Cursor Declarations                                                   |
  +-----------------------------------------------------------------------*/

  -- This cursor retrieves all the deferred lines
  /* 9320279 - added CM amounts to cursor */
  CURSOR rev_lines (p_trx_id NUMBER) IS
    SELECT adl.customer_trx_line_id,
           adl.customer_trx_id,
           adl.line_collectible_flag,
           adl.amount_due_original,
           adl.acctd_amount_due_original,
      	   adl.amount_recognized,
      	   adl.acctd_amount_recognized,
      	   adl.amount_pending,
      	   adl.acctd_amount_pending,
           SUM(NVL(gld.amount,0)), SUM(NVL(gld.acctd_amount,0))
    FROM   ar_deferred_lines adl,
           ra_customer_trx_lines ctrl,
           ra_cust_trx_line_gl_dist gld
    WHERE  adl.customer_trx_id = p_trx_id
    AND    adl.customer_trx_id = ctrl.previous_customer_trx_id (+)
    AND    adl.customer_trx_line_id = ctrl.previous_customer_trx_line_id (+)
    AND    ctrl.customer_trx_line_id = gld.customer_trx_line_id (+)
    GROUP BY adl.customer_trx_line_id, adl.customer_trx_id,
             adl.line_collectible_flag, adl.amount_due_original,
             adl.acctd_amount_due_original, adl.amount_recognized,
             adl.acctd_amount_recognized, adl.amount_pending,
             adl.acctd_amount_pending;

  -- This cursor computes the total balance across lines.

  CURSOR amounts (p_trx_id NUMBER) IS
    SELECT sum(amount_due_original),
           sum(acctd_amount_due_original)
    FROM   ar_deferred_lines
    WHERE  customer_trx_id = p_trx_id;

  /* 9320279 - added to fetch total CM amounts for proration */
  CURSOR cm_amounts (p_trx_id NUMBER) IS
    SELECT sum(nvl(amount,0)), sum(nvl(acctd_amount,0))
    FROM   ra_cust_trx_line_gl_dist gld,
           ra_customer_trx ctrx
    WHERE  ctrx.previous_customer_trx_id = p_trx_id
    AND    ctrx.customer_trx_id = gld.customer_trx_id
    AND    account_class in ('REV','UNEARN');

  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/

  l_acctd_freight_applied ar_receivable_applications.freight_applied%TYPE;
  l_acctd_line_applied    ar_receivable_applications.line_applied%TYPE;
  l_acctd_tax_applied     ar_receivable_applications.tax_applied%TYPE;
  l_acctd_charges_applied
    ar_receivable_applications.receivables_charges_applied%TYPE;

  l_freight_applied       ar_receivable_applications.freight_applied%TYPE;
  l_line_applied          ar_receivable_applications.line_applied%TYPE;
  l_tax_applied           ar_receivable_applications.tax_applied%TYPE;
  l_gl_date               ar_receivable_applications.gl_date%TYPE;
  l_charges_applied
    ar_receivable_applications.receivables_charges_applied%TYPE;
  l_acctd_amount_applied
    ar_receivable_applications.acctd_amount_applied_to%TYPE;

  ----------------------
  -- rounding related --
  ----------------------

  l_total_application	        NUMBER;
  l_computed_line_amount	NUMBER;
  l_current_line_balance	NUMBER;
  l_sum_of_all_lines 		NUMBER DEFAULT 0;
  l_running_lines_balance	NUMBER DEFAULT 0;
  l_running_allocated_balance 	NUMBER DEFAULT 0;

  l_acctd_total_application	NUMBER;
  l_acctd_computed_line_amount	NUMBER;
  l_acctd_current_line_balance	NUMBER;
  l_acctd_sum_of_all_lines 	NUMBER DEFAULT 0;
  l_acctd_running_lines_balance	NUMBER DEFAULT 0;
  l_acctd_running_allocated_bal	NUMBER DEFAULT 0;
  l_applied_cm_lines            NUMBER;
  l_applied_acctd_cm_lines      NUMBER;

  -----------------
  -- all flags   --
  -----------------

  l_line_status			NUMBER;
  l_last_fetch                  BOOLEAN;

  ----------------
  -- RAM related
  ----------------

  l_amount_adjusted		NUMBER;
  l_acctd_amount_adjusted	NUMBER;
  l_ram_amount		        NUMBER;
  l_acctd_ram_amount	        NUMBER;
  l_adjustment_number		NUMBER;
  l_rev_adj_rec                 ar_revenue_adjustment_pvt.rev_adj_rec_type;
  l_ram_desc_flexfield          desc_flexfield;

  ------------------------------
  -- columns from the rvmg table
  ------------------------------

  lr_customer_trx_line_id_tbl	number_table;
  lr_customer_trx_id_tbl 	number_table;
  lr_line_collectible_tbl 	varchar_table;
  lr_amount_due_original_tbl 	number_table;
  lr_acctd_amount_due_orig_tbl 	number_table;
  lr_amount_recognized_tbl 	number_table;
  lr_acctd_amt_recognized_tbl   number_table;
  lr_amount_pending_tbl 	number_table;
  lr_acctd_amount_pending_tbl 	number_table;
  lr_cm_amount_tbl              number_table;
  lr_cm_acctd_amount_tbl        number_table;

  ---------
  -- Misc
  ---------

  l_customer_trx_id             ra_customer_trx.customer_trx_id%TYPE;
  l_exchange_rate               ra_customer_trx.exchange_rate%TYPE;
  l_invoice_currency_code       fnd_currencies.currency_code%TYPE;
  l_return_status     	        VARCHAR2(30);
  l_msg_count         	        NUMBER;
  l_msg_data          	        VARCHAR2(150);
  l_delta_amount		NUMBER;  /*6157033*/
  l_acctd_delta_amount		NUMBER;
BEGIN

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.receipt_analyzer +');
  END IF;

  get_receipt_parameters (
    p_mode 				=> p_mode,
    p_customer_trx_id 			=> p_customer_trx_id,
    p_acctd_amount_applied 		=> p_acctd_amount_applied,
    p_exchange_rate 			=> p_exchange_rate,
    p_invoice_currency_code 		=> p_invoice_currency_code,
    p_tax_applied 			=> p_tax_applied,
    p_charges_applied 			=> p_charges_applied,
    p_freight_applied 			=> p_freight_applied,
    p_line_applied 			=> p_line_applied,
    p_gl_date                           => p_gl_date,
    p_receivable_application_id 	=> p_receivable_application_id,
    x_customer_trx_id 			=> l_customer_trx_id,
    x_acctd_amount_applied 		=> l_acctd_amount_applied,
    x_exchange_rate 			=> l_exchange_rate,
    x_invoice_currency_code 		=> l_invoice_currency_code,
    x_tax_applied 			=> l_tax_applied,
    x_charges_applied 			=> l_charges_applied,
    x_freight_applied 			=> l_freight_applied,
    x_line_applied 			=> l_line_applied,
    x_gl_date                           => l_gl_date);

  IF NOT monitored_transaction (l_customer_trx_id) THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug('receipt_analyzer: ' ||
         '*** This Transaction Is Not Being Monitored ***');
    END IF;
    RETURN;
  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('Functional Currency Code    : ' || g_currency_code_f);
     debug('           Precision        : ' || g_precision_f);
     debug('           accountable unit : ' ||
    g_minimum_accountable_unit_f);
     debug('Invoice Currency Code       : ' ||
    p_invoice_currency_code);
  END IF;

  -- sum of all lines for this transaction

  OPEN  amounts(l_customer_trx_id);
  FETCH amounts INTO l_sum_of_all_lines, l_acctd_sum_of_all_lines;
  CLOSE amounts;

  OPEN  cm_amounts(l_customer_trx_id);
  FETCH cm_amounts INTO l_applied_cm_lines, l_applied_acctd_cm_lines;
  CLOSE cm_amounts;

  IF pg_debug IN ('Y', 'C') THEN
     debug('Sum of All INV Lines             : ' ||
       l_sum_of_all_lines);
     debug('Sum of All INV Lines (Accounted) : ' ||
       l_acctd_sum_of_all_lines);

     debug('Sum of All CM Lines             : ' ||
       l_applied_cm_lines);
     debug('Sum of All CM Lines (Accounted) : ' ||
       l_applied_acctd_cm_lines);
  END IF;

  /* 9320279 - Reduce the total allocatable amount by any applied CMs */
  l_sum_of_all_lines := l_sum_of_all_lines + NVL(l_applied_cm_lines,0);
  l_acctd_sum_of_all_lines := l_acctd_sum_of_all_lines +
                              NVL(l_applied_acctd_cm_lines,0);

  -- get total receipt application to this transaction so far
  -- before this receipt
  l_total_application :=
    get_total_application (
      p_customer_trx_id => l_customer_trx_id);

  IF pg_debug IN ('Y', 'C') THEN
     debug('Total Application Amount: ' || l_total_application);
  END IF;

  IF (g_currency_code_f <> p_invoice_currency_code) THEN

    -- INVOICE CURRENCY DOES NOT EQUAL FUNCTIONAL CURRENCY, so we must
    -- do something special.  The l_acctd_amount_applied is the total
    -- application amount.  It is not divided into freight, charges, line,
    -- and tax buckets. So, a call is placed to distribute the amount into the
    -- buckets. So that we can figure out what the acctd_line_amount would be.

    IF pg_debug IN ('Y', 'C') THEN
       debug('Invoice currency and functional currency DIFFER');
    END IF;

    arp_util.set_buckets(
      p_header_acctd_amt   => l_acctd_amount_applied,
      p_base_currency      => g_currency_code_f,
      p_exchange_rate      => l_exchange_rate,
      p_base_precision     => g_precision_f,
      p_base_min_acc_unit  => g_minimum_accountable_unit_f,
      p_tax_amt            => l_tax_applied,
      p_charges_amt        => l_charges_applied,
      p_line_amt           => l_line_applied,
      p_freight_amt        => l_freight_applied,
      p_tax_acctd_amt      => l_acctd_tax_applied,
      p_charges_acctd_amt  => l_acctd_charges_applied,
      p_line_acctd_amt     => l_acctd_line_applied,
      p_freight_acctd_amt  => l_acctd_freight_applied);

    IF pg_debug IN ('Y', 'C') THEN
       debug('Acctd Tax Applied     : ' || l_acctd_tax_applied);
       debug('Acctd Charges Applied : ' ||
         l_acctd_charges_applied);
       debug('Acctd Freight Applied : ' ||
         l_acctd_freight_applied);
    END IF;

    -- get acctd total application to this transaction so far.
    l_acctd_total_application :=
      get_acctd_total_application (
        p_customer_trx_id => l_customer_trx_id);

    IF pg_debug IN ('Y', 'C') THEN
       debug('Total Application Amount (acctd): ' ||
      l_acctd_total_application);
    END IF;

  ELSE

    IF pg_debug IN ('Y', 'C') THEN
       debug('Invoice currency and functional currency MATCH');
    END IF;

    l_acctd_line_applied := l_line_applied;
    l_acctd_total_application := l_total_application;

  END IF;

  IF pg_debug IN ('Y', 'C') THEN
     debug('Acctd Line Applied    : ' || l_acctd_line_applied);
  END IF;

  OPEN rev_lines(l_customer_trx_id);
  LOOP

    -- this table must be deleted for re-entry
    -- otherwise the row count may not be zero
    -- and we will be stuck in an infinite loop.

    lr_customer_trx_line_id_tbl.delete;
    lr_customer_trx_id_tbl.delete;
    lr_line_collectible_tbl.delete;
    lr_amount_due_original_tbl.delete;
    lr_acctd_amount_due_orig_tbl.delete;
    lr_amount_recognized_tbl.delete;
    lr_acctd_amt_recognized_tbl.delete;
    lr_amount_pending_tbl.delete;
    lr_acctd_amount_pending_tbl.delete;
    lr_cm_amount_tbl.delete;
    lr_cm_acctd_amount_tbl.delete;

    FETCH rev_lines BULK COLLECT INTO
      lr_customer_trx_line_id_tbl,
      lr_customer_trx_id_tbl,
      lr_line_collectible_tbl,
      lr_amount_due_original_tbl,
      lr_acctd_amount_due_orig_tbl,
      lr_amount_recognized_tbl,
      lr_acctd_amt_recognized_tbl,
      lr_amount_pending_tbl,
      lr_acctd_amount_pending_tbl,
      lr_cm_amount_tbl,
      lr_cm_acctd_amount_tbl
    LIMIT c_max_bulk_fetch_size;

    IF rev_lines%NOTFOUND THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('rev_lines%NOTFOUND');
      END IF;
      l_last_fetch := TRUE;
    END IF;

    IF lr_customer_trx_line_id_tbl.COUNT = 0 AND l_last_fetch THEN
      IF pg_debug IN ('Y', 'C') THEN
         debug('No more rows');
      END IF;
      EXIT;
    END IF;

    FOR i IN lr_customer_trx_line_id_tbl.FIRST ..
             lr_customer_trx_line_id_tbl.LAST LOOP

      IF pg_debug IN ('Y', 'C') THEN
         debug('Receipt Analyzer Loop - Line ID: ' ||
        lr_customer_trx_line_id_tbl(i));
      END IF;


      -- at all times one of the columns would always have zero
      l_current_line_balance := lr_amount_pending_tbl(i) +
                                lr_amount_recognized_tbl(i);

      ------------------------------------------------------------------------
      -- Here we will call the function compute_line_amount to determine what
      -- is the exact amount (in invoice currency) that should be applied to
      -- the current line.  This function takes care of the rounding issues.
      -- There are two potential rounding issues here which this function takes
      -- care of.  First, if we simply prorate an amount across the number of
      -- lines, then there is a potential for losing a cent here and there.
      -- So, the this function has to make sure the total amount applied equals
      -- the total amount applied across lines.  Another rounding issue that
      -- this function takes care of has to do with the fact, if we continue
      -- to apply and apply to these lines, there is a potential for a cent or
      -- two to spill over to other lines.  As a result, when you reverse
      -- receipts completely, you may have lines having -0.01, -0.01, and
      -- +0.02.  Although, the this balances across lines, this is not right.
      -- The compute_line_amount is now smart enough to handle this as well.
      -- Please note that the same function will be called in the entered
      -- entered currency if this is a cross currency transaction.
      -------------------------------------------------------------------------

      l_computed_line_amount := compute_line_amount (
        p_mode                      => p_mode,
        p_amount_previously_applied => l_total_application,
        p_current_amount_applied    => l_line_applied,
        p_line_balance_orig         =>
            lr_amount_due_original_tbl(i) + lr_cm_amount_tbl(i),
        p_currency_code             => l_invoice_currency_code,
        p_sum_of_all_lines          => l_sum_of_all_lines,
        p_current_line_balance      => l_current_line_balance,
        p_running_lines_balance     => l_running_lines_balance,
        p_running_allocated_balance => l_running_allocated_balance);


      IF pg_debug IN ('Y', 'C') THEN
         debug('l_computed_line_amount: ' ||
           l_computed_line_amount);
      END IF;

      IF (g_currency_code_f <> p_invoice_currency_code) THEN

        -- INVOICE CURRENCY DOES NOT EQUAL FUNCTIONAL CURRENCY

        IF pg_debug IN ('Y', 'C') THEN
          debug('Invoice and functional currency DIFFER');
        END IF;
        -- at all times one of the columns would always have to be zero
        l_acctd_current_line_balance := lr_acctd_amount_pending_tbl(i) +
                                        lr_acctd_amt_recognized_tbl(i);

        l_acctd_computed_line_amount := compute_line_amount (
          p_mode                      => p_mode,
          p_amount_previously_applied => l_acctd_total_application,
          p_current_amount_applied    => l_line_applied,
          p_line_balance_orig         =>
             lr_acctd_amount_due_orig_tbl(i) + lr_cm_acctd_amount_tbl(i),
          p_currency_code             => g_currency_code_f,
          p_sum_of_all_lines          => l_acctd_sum_of_all_lines,
          p_current_line_balance      => l_acctd_current_line_balance,
          p_running_lines_balance     => l_acctd_running_lines_balance,
          p_running_allocated_balance => l_acctd_running_allocated_bal);

      ELSE

        IF pg_debug IN ('Y', 'C') THEN
           debug('Invoice and functional currency MATCH');
        END IF;
        l_acctd_computed_line_amount := l_computed_line_amount;

      END IF;

      IF pg_debug IN ('Y', 'C') THEN
         debug('l_acctd_computed_line_amount: ' ||
           l_acctd_computed_line_amount);
      END IF;


      ------------------------------------------------------------------------
      -- This is almost like a real time call to periodic sweeper.  This way,
      -- we get the latest line status taking into account all the expirations
      -- as of now. This allows us to recognize revenue as soon as possible.
      -- The following function determines the status of line.  It will
      -- indicate what kind of issues remain: header level only, line level
      -- only, header and line level or no issues remain.
      ------------------------------------------------------------------------

      /* 9320279 - Prevent any REV/UNEARN if the line is
         fully credited */
      IF  l_computed_line_amount = 0
      AND lr_amount_due_original_tbl(i) + lr_cm_amount_tbl(i) = 0
      THEN
          /* Line is fully credited */
          l_line_status := c_fully_credited;
      ELSE
          /* do the normal line_status call */
          l_line_status := get_line_status (
             p_cust_trx_line_id => lr_customer_trx_line_id_tbl(i));
      END IF;

      IF pg_debug IN ('Y', 'C') THEN
         debug('Scenario : ' || l_line_status);
      END IF;

      -- set the common attributes for the revenue adjustment

      l_rev_adj_rec.line_selection_mode := 'S';
      l_rev_adj_rec.from_cust_trx_line_id := lr_customer_trx_line_id_tbl(i);
      l_rev_adj_rec.customer_trx_id := l_customer_trx_id;
      l_rev_adj_rec.gl_date := sysdate;
      l_rev_adj_rec.reason_code := 'REV_MGMT_ENGINE';
      l_rev_adj_rec.amount_mode := 'A';

      IF (p_mode = c_receipt_application_mode AND
          l_line_status = c_recognizable) THEN

        IF pg_debug IN ('Y', 'C') THEN
           debug('No Issues Remain- Recognizing The Whole Amount '
             || lr_customer_trx_line_id_tbl(i));
        END IF;

        l_amount_adjusted := lr_amount_due_original_tbl(i);
        l_acctd_amount_adjusted := lr_acctd_amount_due_orig_tbl(i);

        update_deferred_lines (
          p_customer_trx_line_id    => lr_customer_trx_line_id_tbl(i),
          p_line_status 	    => l_line_status,
          p_amount_recognized       => l_amount_adjusted,
          p_acctd_amount_recognized => l_acctd_amount_adjusted,
          p_amount_pending	    => 0,
          p_acctd_amount_pending    => 0);

        l_rev_adj_rec.amount := l_amount_adjusted;

        adjust_revenue(
          p_mode 			=> c_earn_revenue,
          p_customer_trx_id 		=> l_customer_trx_id,
          p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
          p_acctd_amount                => l_acctd_computed_line_amount,
          p_gl_date                     => l_gl_date,
          p_ram_desc_flexfield	        => l_ram_desc_flexfield,
          p_rev_adj_rec 		=> l_rev_adj_rec,
          x_adjustment_number           => l_adjustment_number,
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data);

      ELSIF (p_mode = c_receipt_application_mode AND
          l_line_status = c_cash_based) THEN

        -----------------------------------------------------------------------
        -- This is receipt application scenario # 1 where only
        -- hang up is header level, in this case receipt application
        -- equals revenue recognition up to the amount received and the
        -- pending amount can be recognized.  The reason we may have
        -- something in pending bucket is because previously this line may
        -- have had a line level collectibility issue and that could have
        -- removed by the periodic sweeper engine.
        -----------------------------------------------------------------------

        IF pg_debug IN ('Y', 'C') THEN
          debug('Cash Based Scenario- Recognizing For Line ' ||
            lr_customer_trx_line_id_tbl(i));
        END IF;

        l_amount_adjusted := (lr_amount_recognized_tbl(i) +
                              lr_amount_pending_tbl(i) +
                              l_computed_line_amount);

        l_acctd_amount_adjusted := (lr_acctd_amt_recognized_tbl(i) +
                                    lr_acctd_amount_pending_tbl(i) +
                                    l_acctd_computed_line_amount);

	/*6157033 Need to pass delta amount in adjust revenue for calculating
	  Correct adjustable revenue in case amount recogonized is changed when amount
	  amount adjusted is more than amount to be recogonized*/
	l_delta_amount := 0;
	l_acctd_delta_amount := 0;
        IF (ABS(l_amount_adjusted) >= ABS(lr_amount_due_original_tbl(i))) THEN

	  l_delta_amount := l_amount_adjusted - lr_amount_due_original_tbl(i);
	  l_acctd_delta_amount := l_acctd_amount_adjusted - lr_acctd_amount_due_orig_tbl(i);
          l_amount_adjusted := lr_amount_due_original_tbl(i);
          l_acctd_amount_adjusted := lr_acctd_amount_due_orig_tbl(i);
        END IF;

        debug('Amount: ' || l_amount_adjusted);
        debug('Acctd Amount: ' || l_acctd_amount_adjusted);

        update_deferred_lines (
          p_customer_trx_line_id    => lr_customer_trx_line_id_tbl(i),
          p_line_status  	    => l_line_status,
          p_amount_recognized       => l_amount_adjusted,
          p_acctd_amount_recognized => l_acctd_amount_adjusted,
          p_amount_pending	    => 0,
          p_acctd_amount_pending    => 0);

        -- The RAM should be called for only recent receipt amount,
        -- so, l_computed_line_amount and l_acctd_computed_line_amount
        -- is what should be used.
        --
        -- Bug # 2763669 - It should add the pending amount as well,
        -- since that should be RAM-ed as well.

        l_ram_amount := l_computed_line_amount + lr_amount_pending_tbl(i);
        l_acctd_ram_amount := l_acctd_computed_line_amount +
                              lr_acctd_amount_pending_tbl(i);

        l_rev_adj_rec.amount := l_ram_amount;

        debug('RAM Amount : ' || l_ram_amount);
        debug('Acctd RAM Amount: ' || l_acctd_ram_amount);

	/*6157033 Passing delta to adjust_revenue default value for delta is 0*/
        adjust_revenue(
          p_mode 			=> c_earn_revenue,
          p_customer_trx_id 		=> l_customer_trx_id,
          p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
          p_acctd_amount                => l_acctd_ram_amount,
          p_gl_date                     => l_gl_date,
          p_ram_desc_flexfield	        => l_ram_desc_flexfield,
          p_rev_adj_rec 		=> l_rev_adj_rec,
	  p_delta_amount		=> l_delta_amount,
	  p_acctd_delta_amount		=> l_acctd_delta_amount,
          x_adjustment_number           => l_adjustment_number,
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data);

      ELSIF (p_mode = c_receipt_reversal_mode AND
          l_line_status = c_cash_based) THEN

        ----------------------------------------------------------------------
        -- This is receipt reversal scenario # 1 where previously
        -- earned revenue must be un-earned. Previously, when
        -- this receipt was applied we must have pulled everything
        -- from pending and added to the current amount and called RAM
        -- for that amount.  Now, we should un-earn the recognized
        -- amount - reversed receipt amount. Nothing should be put back
        -- to pending. Anything that was recognized other than this receipt
        -- should still be considered recognized.
        ----------------------------------------------------------------------

        IF pg_debug IN ('Y', 'C') THEN
           debug('Header Only Scenario - Reversing For Line ' ||
          lr_customer_trx_line_id_tbl(i));
        END IF;

        l_amount_adjusted := (lr_amount_recognized_tbl(i) -
                              l_computed_line_amount);
        l_acctd_amount_adjusted := (lr_acctd_amt_recognized_tbl(i) -
                                    l_acctd_computed_line_amount);

/*        IF (l_computed_line_amount >= lr_amount_due_original_tbl(i)) THEN*/
          IF ABS(lr_amount_recognized_tbl(i)) < ABS( l_computed_line_amount) THEN

          -- if the original receipt amount was more than the line amount
          -- we would have recognized upto the line amount, so the same
          -- should happen when the same receipt is unapplied.

           l_amount_adjusted := 0;  /* 6157033 amount recogonized reduces to zero */
           l_acctd_amount_adjusted := 0;

	   IF lr_amount_recognized_tbl(i) <> 0 THEN
           /* 6157113/6008164 - set ram amounts equal to ado amounts */
           /* 7413816 - Revised to lr_amount_recognized_tbl */
             l_ram_amount       := lr_amount_recognized_tbl(i);
             l_acctd_ram_amount := lr_acctd_amt_recognized_tbl(i);
	   ELSE
             l_ram_amount       := 0;
             l_acctd_ram_amount := 0;
	   END IF;
        ELSE
           -- Bug # 2763669 - RAM should be called for only recent receipt amount,
           -- so, l_computed_line_amount and l_acctd_computed_line_amount
           -- is what should be used.

           /* 6157113/6008164 - set ram amounts equal to computed amounts */
           l_ram_amount := l_computed_line_amount;
           l_acctd_ram_amount := l_acctd_computed_line_amount;
        END IF;

        debug('Amount        : ' || l_amount_adjusted);
        debug('Acctd. Amount : ' || l_acctd_amount_adjusted);

        update_deferred_lines (
          p_customer_trx_line_id    => lr_customer_trx_line_id_tbl(i),
          p_line_status 	    => l_line_status,
          p_amount_recognized       => l_amount_adjusted,
          p_acctd_amount_recognized => l_acctd_amount_adjusted);

        l_rev_adj_rec.amount := l_ram_amount;

        debug('RAM Amount : ' || l_ram_amount);
        debug('Acctd RAM Amount: ' || l_acctd_ram_amount);

        adjust_revenue(
          p_mode 			=> c_unearn_revenue,
          p_customer_trx_id 		=> l_customer_trx_id,
          p_customer_trx_line_id 	=> lr_customer_trx_line_id_tbl(i),
          p_acctd_amount                => l_acctd_ram_amount,
          p_gl_date                     => l_gl_date,
          p_ram_desc_flexfield	        => l_ram_desc_flexfield,
          p_rev_adj_rec 		=> l_rev_adj_rec,
          x_adjustment_number           => l_adjustment_number,
          x_return_status               => l_return_status,
          x_msg_count                   => l_msg_count,
          x_msg_data                    => l_msg_data);

      ELSIF (p_mode = c_receipt_application_mode AND
          l_line_status = c_combination) THEN

        -----------------------------------------------------------------------
        -- This is receipt application scenario # 2 where both line level
        -- and header level have problems, in this case, receipt
        -- application does not tie to revenue recognition.  However, we
        -- must keep track of the receipt that was attempted to be
        -- recognized.  So that when the line level concern is removed
        -- the sweeper can recognize this amount. So, we put it in pending.
        -----------------------------------------------------------------------

        IF pg_debug IN ('Y', 'C') THEN
           debug('Move the pending amount to recognized for line '
             || lr_customer_trx_line_id_tbl(i));
        END IF;

        l_amount_adjusted := (lr_amount_pending_tbl(i) +
                              l_computed_line_amount);

        l_acctd_amount_adjusted := (lr_acctd_amount_pending_tbl(i) +
                                    l_acctd_computed_line_amount);

        IF (lr_amount_pending_tbl(i) + l_computed_line_amount >=
            lr_amount_due_original_tbl(i)) THEN

          l_amount_adjusted := lr_amount_due_original_tbl(i);
          l_acctd_amount_adjusted := lr_acctd_amount_due_orig_tbl(i);

        END IF;

        update_deferred_lines (
          p_customer_trx_line_id    => lr_customer_trx_line_id_tbl(i),
          p_amount_pending          => l_amount_adjusted,
          p_acctd_amount_pending    => l_acctd_amount_adjusted);

      ELSIF (p_mode = c_receipt_reversal_mode AND
          l_line_status = c_combination) THEN

        /*--------------------------------------------------------------------
        | This is receipt reversal scenario # 2 where pending column
        | should go back to the amount as it was before this receipt
        | was applied.
        +--------------------------------------------------------------------*/

        IF pg_debug IN ('Y', 'C') THEN
           debug('Reversing The Pending Amount For Line ' ||
          lr_customer_trx_line_id_tbl(i));
        END IF;

        l_amount_adjusted := (lr_amount_pending_tbl(i) -
                              l_computed_line_amount);

        l_acctd_amount_adjusted := (lr_acctd_amount_pending_tbl(i) -
                                    l_acctd_computed_line_amount);

        IF (l_computed_line_amount >= lr_amount_due_original_tbl(i)) THEN

          -- if the original receipt amount was more than the line amount
          -- we would have updated the pending amount upto the line amount,
          -- so the same should happen when the same receipt is unapplied.

          l_amount_adjusted := lr_amount_due_original_tbl(i);
          l_acctd_amount_adjusted := lr_acctd_amount_due_orig_tbl(i);

        END IF;

        update_deferred_lines (
          p_customer_trx_line_id    => lr_customer_trx_line_id_tbl(i),
          p_amount_pending          => l_amount_adjusted,
          p_acctd_amount_pending    => l_acctd_amount_adjusted);


      END IF; -- (scenario #)

      IF pg_debug IN ('Y', 'C') THEN
         debug('amount adjusted      : ' || l_amount_adjusted);
         debug('acctd amount adjusted: ' ||
           l_acctd_amount_adjusted);
         debug('Done for the line');
      END IF;

    END LOOP; -- FOR i IN l_customer_trx_line_id_tbl.FIRST ..LAST

  END LOOP;  -- (rev_lines  => bulk collect)

  IF pg_debug IN ('Y', 'C') THEN
     debug('ar_revenue_management_pvt.receipt_analyzer()-');
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug(' (1) NO_DATLR_FOUND: receipt_analyzer)');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug(' (1) OTHERS: receipt_analyzer');
       debug(sqlerrm);
    END IF;
    RAISE;

END receipt_analyzer;


/*========================================================================
 | PUBLIC PROCEDURE receipt_analyzer
 |
 | DESCRIPTION
 |   This is a overloaded function. This one takes in request is as the only
 |   parameter, then bulk processes the receipts.  This procedure takes care
 |   of receipt applications from collectibility perspective. When a receipt
 |   is applied, which is an event for revenue management engine, this
 |   procedure determines if this receipt can trigger revenue recognition.
 |   In cases where creditworthiness and/or payment term was the reason for
 |   revenue deferral, it would recognize the revenue upto the receipt amount.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |     1. auto receipts
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   receipt_analyzer
 |
 | PARAMETERS
 |   p_rerquest_id
 |
 | NOTES
 |   None.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 |
 *=======================================================================*/

PROCEDURE receipt_analyzer (p_request_id IN NUMBER) IS

  -- This cursor retrieves all the receipts for a request id

  CURSOR receipts IS
    SELECT ara.rowid,
           ara.applied_customer_trx_id,
           ara.acctd_amount_applied_to,
           ara.tax_applied,
           ara.receivables_charges_applied,
           ara.line_applied,
           ara.freight_applied,
           rct.invoice_currency_code,
           rct.exchange_rate,
           ara.gl_date
    FROM   ar_receivable_applications ara,
           ra_customer_trx rct
    WHERE  ara.request_id = p_request_id
    AND    ara.applied_customer_trx_id = rct.customer_trx_id;

  l_last_fetch                  BOOLEAN;

  l_rowid_tbl			varchar_table;
  l_customer_trx_id_tbl  	number_table;
  l_acctd_amount_applied_tbl	number_table;
  l_exchange_rate_tbl		number_table;
  l_invoice_currency_code_tbl   varchar_table;
  l_tax_applied_tbl             number_table;
  l_charges_applied_tbl         number_table;
  l_freight_applied_tbl         number_table;
  l_line_applied_tbl            number_table;
  l_gl_date_tbl                 date_table;

BEGIN

  debug('ar_revenue_management_pvt.receipt_analyzer()+ ');
  debug(' p_request_id : ' || p_request_id);

  OPEN receipts;
  LOOP

    -- this table must be deleted for re-entry
    -- otherwise the row count may not be zero
    -- and we will be stuck in an infinite loop.

    l_rowid_tbl.delete;

    FETCH receipts BULK COLLECT INTO
      l_rowid_tbl,
      l_customer_trx_id_tbl,
      l_acctd_amount_applied_tbl,
      l_tax_applied_tbl,
      l_charges_applied_tbl,
      l_line_applied_tbl,
      l_freight_applied_tbl,
      l_invoice_currency_code_tbl,
      l_exchange_rate_tbl,
      l_gl_date_tbl
    LIMIT c_max_bulk_fetch_size;

    IF receipts%NOTFOUND THEN

      debug('last fetch');
      l_last_fetch := TRUE;

    END IF;

    IF l_rowid_tbl.COUNT = 0 AND l_last_fetch THEN
      debug('last fetch and COUNT equals zero');
      EXIT;
    END IF;

    FOR i IN l_rowid_tbl.FIRST .. l_rowid_tbl.LAST LOOP

      debug( 'i: '                       || i);
      debug( 'p_customer_trx_id: '       || l_customer_trx_id_tbl(i));
      debug( 'p_acctd_amount_applied: '  || l_acctd_amount_applied_tbl(i));
      debug( 'p_exchange_rate: '         || l_exchange_rate_tbl(i));
      debug( 'p_invoice_currency_code: ' || l_invoice_currency_code_tbl(i));
      debug( 'p_tax_applied: '           || l_tax_applied_tbl(i));
      debug( 'p_charges_applied: '       || l_charges_applied_tbl(i));
      debug( 'p_freight_applied: '       || l_freight_applied_tbl(i));
      debug( 'p_line_applied: '          || l_line_applied_tbl(i));
      debug( 'p_gl_date: '               || l_gl_date_tbl(i));

      receipt_analyzer (
        p_mode 			=> c_receipt_application_mode,
        p_customer_trx_id 	=> l_customer_trx_id_tbl(i),
        p_acctd_amount_applied 	=> l_acctd_amount_applied_tbl(i),
        p_exchange_rate 	=> l_exchange_rate_tbl(i),
        p_invoice_currency_code => l_invoice_currency_code_tbl(i),
        p_tax_applied 		=> l_tax_applied_tbl(i),
        p_charges_applied 	=> l_charges_applied_tbl(i),
        p_freight_applied 	=> l_freight_applied_tbl(i),
        p_line_applied 		=> l_line_applied_tbl(i),
        p_gl_date               => l_gl_date_tbl(i));

      debug('returned from the call to the original analyzer');

    END LOOP;

    debug('End First Loop');

  END LOOP;

  CLOSE receipts;

  debug('ar_revenue_management_pvt.receipt_analyzer()- ');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    debug('EXCEPTION: (2) NO_DATA_FOUND: receipt_analyzer');
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('EXCEPTION: (2) OTHERS: receipt_analyzer');
    debug(sqlerrm);
    RAISE;

END receipt_analyzer;


/*========================================================================
 | PUBLIC FUNCTION line_collectibility
 |
 | DESCRIPTION
 |   This procedure computes collectibility for a given line.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |   This procedure is called from revenue recognition program.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   line_collectible
 |
 | PARAMETERS
 |   p_customer_trx_id
 |   p_customer_trx_line_id
 |
 | NOTES
 |   This function checks if the the line has gone through collectibility
 |   analysis by calling line_collectible, there is not need tocompute it
 |   from scratch.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Subroutine Created
 |
 *=======================================================================*/

FUNCTION line_collectibility(
  p_customer_trx_id NUMBER,
  p_customer_trx_line_id NUMBER)
  RETURN NUMBER IS

  /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/

  l_line_verdict		NUMBER;

BEGIN

  debug('ar_revenue_management_pvt.line_collectibility()+');
  debug('** line_collectibility parameters **');
  debug('     p_customer_trx_id      : ' || p_customer_trx_id);
  debug('     p_customer_trx_line_id : ' || p_customer_trx_line_id);

  l_line_verdict := line_collectible (
    p_customer_trx_id => p_customer_trx_id,
    p_customer_trx_line_id => p_customer_trx_line_id);

  IF (l_line_verdict = not_analyzed) THEN
    RETURN collect;
  END IF;

  debug('ar_revenue_management_pvt.line_collectibility()-');

  RETURN l_line_verdict;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug(' (1) NO_DATA_FOUND: line_collectibility');
       debug(sqlerrm);
    END IF;
    RAISE;

  WHEN OTHERS THEN
    IF pg_debug IN ('Y', 'C') THEN
       debug(' (1) OTHERS: line_collectibility');
       debug(sqlerrm);
    END IF;
    RAISE;

END line_collectibility;


/*=========================================================================
 | PUBLIC FUNCTION line_collectibility
 |
 | DESCRIPTION
 |   This function computes collectibility given the request ID.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS
 |   This function is during auto-invoice. To be specific, it is called
 |   from arp_auto_accounting package (ARTEAACB.pls).
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | PARAMETERS
 |   p_request_id => request_id in the ar_interface_lines_all table
 |
 | NOTES
 |
 *=======================================================================*/

FUNCTION line_collectibility (
  p_request_id  NUMBER,
  p_source      VARCHAR2 DEFAULT NULL,
  x_error_count OUT NOCOPY NUMBER,
  p_customer_trx_line_id ra_customer_trx_lines.customer_trx_line_id%TYPE )
  RETURN long_number_table IS

 /*-----------------------------------------------------------------------+
  | Cursor Declarations                                                   |
  +-----------------------------------------------------------------------*/

  -- This cursor retrieves the revenue management verdicts for each line
  CURSOR verdicts IS
    SELECT  ctl.customer_trx_line_id,
            decode(lrs.line_collectible_flag, NULL, 1, 'Y', 1, 'N', 0) verdict
    FROM    ra_customer_trx_lines ctl,
            ar_deferred_lines lrs
    WHERE   ((p_request_id IS NULL AND
              p_customer_trx_line_id IS NOT NULL AND
              ctl.customer_trx_line_id = p_customer_trx_line_id) OR
             (p_request_id IS NOT NULL AND
              ctl.request_id = p_request_id))
    AND     ctl.line_type = 'LINE'
    AND     ctl.customer_trx_line_id = lrs.customer_trx_line_id (+)
    ORDER BY ctl.customer_trx_line_id;

 /*-----------------------------------------------------------------------+
  | Local Variable Declarations and initializations                       |
  +-----------------------------------------------------------------------*/

  l_line_verdicts_tbl long_number_table;

BEGIN

  g_source := p_source;

  debug('ar_revenue_management_pvt.line_collectibility()+');
  debug(' p_request_id : ' || p_request_id);
  debug(' p_source : ' || p_source);
  debug(' p_customer_trx_line_id : ' || p_customer_trx_line_id);

  -- validate the contingencies and populate the errors table

  IF p_request_id IS NOT NULL THEN
     x_error_count := validate_contingencies( p_request_id => p_request_id);

     debug('validation done');

  -- the following would insert a row in the ar_line_conts table
  -- for each contingency passed in the ra_interface_contingencies_all table.

     IF (g_source = 'AR_INVOICE_API') THEN
       insert_contingencies_from_gt(p_request_id => p_request_id);
     ELSE
       insert_contingencies_from_itf(p_request_id => p_request_id);
       /* 5142216 - copy parent contingencies if necessary */
       copy_parent_contingencies(p_request_id => p_request_id);
     END IF;

     debug('contingency rows inserted: ' || SQL%ROWCOUNT);
  END IF; --p_request_id not null

  default_contingencies (p_request_id => p_request_id
			,p_customer_trx_line_id => p_customer_trx_line_id);

  delete_unwanted_contingencies (p_request_id => p_request_id
				,p_customer_trx_line_id => p_customer_trx_line_id);

  -- now all the contingencies have been inserted we can insert
  -- the deferred lines (parent) into ar_deferred_lines_all table.

  insert_deferred_lines (p_request_id => p_request_id
			,p_customer_trx_line_id => p_customer_trx_line_id);

  debug('deferred rows inserted: ' || SQL%ROWCOUNT);

  FOR revline IN verdicts LOOP
    debug('Line ID: ' || revline.customer_trx_line_id);
    debug('Verdict: ' || revline.verdict);
    l_line_verdicts_tbl(revline.customer_trx_line_id) := revline.verdict;
  END LOOP;

  debug('ar_revenue_management_pvt.line_collectibility()-');

  RETURN l_line_verdicts_tbl;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    debug('(2) NO_DATA_FOUND: line_collectibility');
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug('(2) OTHERS: line_collectibility');
    debug(sqlerrm);
    RAISE;

END line_collectibility;


/*========================================================================
 | INITIALIZATION SECTION
 |
 | DESCRIPTION
 |   Nothing so far.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 26-JUL-2002           ORASHID           Created
 |
 *=======================================================================*/
BEGIN

  -- fetch the details about functional currency.  This does not change
  -- so this should not be fetched multiple times, instead it should
  -- fetched only once when the package is loaded to the db.

  get_base_currency_info;

  /* 5142216 - set g_om_context from profile.  Insure that if the profile
     is not set, the value is not null, but a inoperable constant */
  g_om_context := NVL(fnd_profile.value('ONT_SOURCE_CODE'),'###NOT_SET###');

EXCEPTION

  WHEN NO_DATA_FOUND THEN
    debug(' ar_revenue_management_pvt.initialize');
    debug(sqlerrm);
    RAISE;

  WHEN OTHERS THEN
    debug(' ar_revenue_management_pvt.initialize');
    debug(sqlerrm);
    RAISE;

END ar_revenue_management_pvt;

/
