--------------------------------------------------------
--  DDL for Package Body ARPT_SQL_FUNC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARPT_SQL_FUNC_UTIL" AS
/* $Header: ARTUSSFB.pls 120.39.12010000.3 2010/04/16 13:01:20 npanchak ship $ */

 pg_reference_column VARCHAR2(240);

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_cb_invoice                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the invoice associated with a Chargeback.                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_class                                                |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : the trx_number of the invoice associated with the chargeback.|
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-OCT-95  Charlie Tomberg     Created                                |
 +===========================================================================*/

FUNCTION get_cb_invoice( p_customer_trx_id IN number,
                         p_class IN varchar2)
                           RETURN VARCHAR2 IS

  l_inv_trx_number ra_customer_trx.trx_number%type;

BEGIN

      IF ( p_class <> 'CB' )
      THEN  RETURN( NULL );
      ELSE

           SELECT MAX( ct.trx_number )
           INTO   l_inv_trx_number
           FROM   ra_customer_trx ct,
                  ar_adjustments_all aa --anuj
           WHERE  aa.chargeback_customer_trx_id = p_customer_trx_id
                  and ct.org_id = aa.org_id
           AND    aa.customer_trx_id            = ct.customer_trx_id;

           RETURN(l_inv_trx_number);

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_dispute_amount                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the amount in dispute for a specific transaction.                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_class                                                |
 |                    p_open_receivable_flag                                 |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The dispute amount                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-OCT-95  Charlie Tomberg	Created
 |     10/10/1996 Harri Kaukovuo	Related to bug 410349, cm, dep and
 |					guarantees can have dispute amounts.
 +===========================================================================*/

FUNCTION get_dispute_amount( p_customer_trx_id IN number,
                             p_class           IN varchar2,
                             p_open_receivable_flag IN varchar2)
                               RETURN NUMBER IS

  l_amount_in_dispute number;

BEGIN

	/*------------------------------------------------------------+
         |  Return NULL immediately if the transaction cannot have a  |
         |  dispute amount.                                           |
 	 +------------------------------------------------------------*/

      IF    ( p_open_receivable_flag = 'N')
      THEN  RETURN( NULL );
      ELSE

            SELECT SUM( NVL( ps.AMOUNT_IN_DISPUTE, 0) )
            INTO   l_amount_in_dispute
            FROM   ar_payment_schedules ps
            WHERE  ps.customer_trx_id = p_customer_trx_id;

            RETURN(l_amount_in_dispute);

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_dispute_date                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the maximum current dispute date for a specific transaction.      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_class                                                |
 |                    p_open_receivable_flag                                 |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The dispute date                                             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-OCT-95  Charlie Tomberg     Created                                |
 |     10/10/1996 Harri Kaukovuo        Related to bug 410349, cm, dep and
 |                                      guarantees can have dispute amounts.
 +===========================================================================*/

FUNCTION get_dispute_date( p_customer_trx_id IN number,
                           p_class           IN varchar2,
                           p_open_receivable_flag IN varchar2)
                               RETURN DATE IS

  l_dispute_date  ar_payment_schedules.dispute_date%type;

BEGIN

	/*------------------------------------------------------------+
         |  Return NULL immediately if the transaction cannot have a  |
         |  dispute amount.                                           |
 	 +------------------------------------------------------------*/

      IF    (p_open_receivable_flag = 'N')
      THEN  RETURN( NULL );
      ELSE

            SELECT MAX(ps.dispute_date )
            INTO   l_dispute_date
            FROM   ar_payment_schedules ps
            WHERE  ps.customer_trx_id   = p_customer_trx_id
            AND    ps.dispute_date     IS NOT NULL;

            RETURN(l_dispute_date);

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_max_dispute_date                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the maximum dispute date for a specific transaction.              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_class                                                |
 |                    p_open_receivable_flag                                 |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The dispute date                                             |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-FEB-95  Charlie Tomberg     Created                                |
 |     10/10/1996 Harri Kaukovuo        Related to bug 410349, cm, dep and
 |                                      guarantees can have dispute amounts.
 +===========================================================================*/

FUNCTION get_max_dispute_date( p_customer_trx_id IN number,
                           p_class           IN varchar2,
                           p_open_receivable_flag IN varchar2)
                               RETURN DATE IS

  l_dispute_date  ar_payment_schedules.dispute_date%type;

BEGIN

	/*------------------------------------------------------------+
         |  Return NULL immediately if the transaction cannot have a  |
         |  dispute amount.                                           |
 	 +------------------------------------------------------------*/

      IF    (p_open_receivable_flag = 'N')
      THEN  RETURN( NULL );
      ELSE

            SELECT  MAX(h.start_date)
            INTO    l_dispute_date
            FROM    ar_dispute_history h,
                    ar_payment_schedules ps
            WHERE   h.payment_schedule_id = ps.payment_schedule_id
            AND     ps.customer_trx_id    = p_customer_trx_id
            AND     end_date IS NULL;

            RETURN(l_dispute_date);

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_revenue_recog_run_flag                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if the revenue recognition program has created any          |
 |    distributions for a specific transaction.                              |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_invoicing_ruke_id                                    |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : TRUE if revenue has been recognized, FALSE if it has not.    |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-OCT-95  Charlie Tomberg     Created                                |
 |     11-Apr-04  Kamsi   Bug3251996 :Modified the function to check for the |
 |                        same conditions for both Invoices and CM's.The     |
 |                        SELECT to determine whether Revenue Recognition is |
 |                        run is also modified.The old code is commented out |
 |                        below the new one.                                 |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_revenue_recog_run_flag( p_customer_trx_id    IN number,
                                     p_invoicing_rule_id  IN number)
                                   RETURN VARCHAR2 IS
l_rule_flag varchar2(1)  := 'N';

BEGIN

  /* Check for invoicing_rule_id to ensure whether the Transactions have
     Rules attached to them. */

     IF  ( p_invoicing_rule_id  IS NULL )
     THEN  RETURN( 'N' );
     END IF;

  /* Check whether Revenue Recognition is run . */

     Select decode(max(DUMMY), null , 'N','Y')
     Into   l_rule_flag
     From   dual
     Where  Exists ( Select 'Revenue recognition has been run'
                     From   ra_cust_trx_line_gl_dist d
                     Where  d.customer_trx_id = p_customer_trx_id
                     and    d.account_class   = 'REC'
                     and    d.account_set_flag = 'N');

    IF (l_rule_flag = 'N')
    THEN  RETURN( 'N' );
    ELSE
          RETURN('Y');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
            RAISE;

END;

/*FUNCTION get_revenue_recog_run_flag( p_customer_trx_id    IN number,
                                     p_invoicing_rule_id  IN number)
                               RETURN VARCHAR2 IS

  l_temp_flag varchar2(1);
  l_rule_flag varchar2(1);
  l_cm_flag   varchar2(1);

BEGIN

        Check  if it is a credit memo

       SELECT decode(previous_customer_trx_id,NULL,'N','Y')
       INTO l_cm_flag
       FROM ra_customer_trx
       WHERE  customer_trx_id   = p_customer_trx_id;

       IF ( l_cm_flag ='Y')
           THEN
                Portion added so that we can see the
                  distributions on credit memo
            SELECT decode( max(d.customer_trx_id),
                           null, 'N',
                           'Y')
            INTO   l_rule_flag
            FROM   ra_customer_trx trx,
                   ra_cust_trx_line_gl_dist d
            WHERE  trx.customer_trx_id   = p_customer_trx_id
            and    trx.previous_customer_trx_id = d.customer_trx_id
            and    d.account_class in ('UNEARN', 'UNBILL')
            and    d.account_set_flag='N';       Added for bug 559954

  Modified for Bug 559954
            IF (l_rule_flag = 'N')
             THEN  RETURN( 'N' );
            ELSE
                RETURN('Y');
            END IF;
 End modifications for Bug 559954
      END IF;

      IF    ( p_invoicing_rule_id  IS NULL )
      THEN  RETURN( 'N' );
      ELSE

            Changed the search criteria from
            autorule_duration_processed > 0
            to autorule_duration_processed <> 0
            Bug 461391

            SELECT DECODE( MAX(DUMMY),
                           NULL, 'N',
                                 'Y')
            INTO   l_temp_flag
            FROM   DUAL
            WHERE EXISTS (
                           SELECT 'Revenue recognition has been run'
                           FROM   ra_customer_trx_lines
                           WHERE  customer_trx_id = p_customer_trx_id
                           AND    autorule_duration_processed <> 0
                         );

            RETURN(l_temp_flag);

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END; */


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_posted_flag                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if the specified transaction has been posted.               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_post_to_gl_flag                                      |
 |                    p_complete_flag                                        |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : TRUE   if the transaction has been posted,                   |
 |              FALSE  if it has not.                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_posted_flag( p_customer_trx_id    IN number,
                          p_post_to_gl_flag    IN varchar2,
                          p_complete_flag      IN varchar2,
                          p_class              IN varchar2  DEFAULT NULL) RETURN VARCHAR2 IS

  l_temp_flag varchar2(1);

BEGIN

      IF    (
                  NVL(p_post_to_gl_flag, 'Y')     = 'N'
               OR NVL(p_complete_flag,   'N')  = 'N'
            )
      THEN  RETURN( 'N' );
      ELSE

       /*-------------------------------------------------------+
        |  04-AUG-2000 J Rautiainen BR Implementation           |
        |  For Bills Receivable check the posting from table    |
        |  ar_transaction_history, for other types use the      |
        |  existing logic.                                      |
        +-------------------------------------------------------*/
        IF (p_class = 'BR' )THEN

            SELECT DECODE( MAX(DUMMY),
                           NULL, 'N',
                                 'Y')
            INTO   l_temp_flag
            FROM   DUAL
            WHERE EXISTS (
                           SELECT 'transaction has been posted'
                           FROM   ar_transaction_history
                           WHERE  customer_trx_id  = p_customer_trx_id
                           AND    gl_posted_date  IS NOT NULL
                         );

        ELSE
            SELECT DECODE( MAX(DUMMY),
                           NULL, 'N',
                                 'Y')
            INTO   l_temp_flag
            FROM   DUAL
            WHERE EXISTS (
                           SELECT 'transaction has been posted'
                           FROM   ra_cust_trx_line_gl_dist
                           WHERE  customer_trx_id  = p_customer_trx_id
                           AND    gl_posted_date  IS NOT NULL
                         );
         END IF;

         RETURN(l_temp_flag);

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_posted_flag                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if the specified transaction has been posted.               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_post_to_gl_flag                                      |
 |                    p_complete_flag                                        |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : TRUE   if the transaction has been posted,                   |
 |              FALSE  if it has not.                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_selected_for_payment_flag( p_customer_trx_id    IN number,
                          p_open_receivables_flag IN varchar2,
                          p_complete_flag      IN  varchar2)
                               RETURN VARCHAR2 IS

      l_auto_rec_count           integer;
      l_auto_rec_approved_count  integer;

BEGIN

      IF    (
                 NVL(p_open_receivables_flag, 'Y')  = 'N'
              OR NVL(p_complete_flag, 'Y')          = 'N'
            )
      THEN  RETURN( 'N' );
      ELSE
          /*-------------------------------------------+
           | Find out how many payment schedules have  |
           | been selected for automatic receipt.      |
           +-------------------------------------------*/

           SELECT COUNT(*)
           INTO   l_auto_rec_count
           FROM   ar_payment_schedules
           WHERE  customer_trx_id                = p_customer_trx_id
           AND    selected_for_receipt_batch_id  IS NOT NULL;

          /*-----------------------------------------------+
           |  If no payment schedules have been selected   |
           |  for automatic receipt, return 'N'.           |
           +-----------------------------------------------*/

           IF    ( l_auto_rec_count = 0 )
           THEN  RETURN( 'N' );
           ELSE

                /*-------------------------------------------------------+
                 |  Find out how many of the payment schedules selected  |
                 |  for automatic receipt have been approved.            |
                 +-------------------------------------------------------*/

                 SELECT COUNT(DISTINCT ps.payment_schedule_id)
                 INTO   l_auto_rec_approved_count
                 FROM   ar_payment_schedules ps,
                        ar_receivable_applications ra,
                        ar_cash_receipt_history crh
                 WHERE  ps.customer_trx_id             = p_customer_trx_id
                 AND    ra.applied_payment_schedule_id = ps.payment_schedule_id
                 AND    ra.cash_receipt_id             = crh.cash_receipt_id
                 AND    ps.selected_for_receipt_batch_id = crh.batch_id
                 AND    crh.batch_id = ps.selected_for_receipt_batch_id;

                /*---------------------------------------------------------+
                 |  If all of the payment schedules selected for automatic |
                 |  receipt have been approved, then return 'N'.           |
                 |  Otherwise, return 'Y'.                                 |
                 +---------------------------------------------------------*/

                 IF   ( l_auto_rec_count = l_auto_rec_approved_count )
                 THEN RETURN('N');
                 ELSE RETURN('Y');
                 END IF;

           END IF;

      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_activity_flag                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines if the specified transaction has been posted.               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_post_to_gl_flag                                      |
 |                    p_complete_flag                                        |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : TRUE   if the transaction has been posted,                   |
 |              FALSE  if it has not.                                        |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     28-NOV-95  Charlie Tomberg     Created                                |
 |     04-JUN-98  Debbie Jancis       Fixed Bug 677474                       |
 |                                                                           |
 |     04-APR-06  Herve Yu            Bug 4897195 consider posting as a      |
 |                                     activity                              |
 |     23-Aug-06  GGADHAMS	      Bug 5394382 consider collection        |
 |                                    delinquency  as activity               |
 +===========================================================================*/

FUNCTION get_activity_flag( p_customer_trx_id          IN number,
                            p_open_receivables_flag    IN varchar2,
                            p_complete_flag            IN varchar2,
                            p_class                    IN varchar2,
                            p_initial_customer_trx_id  IN number,
                            p_previous_customer_trx_id IN number
                           )
                               RETURN VARCHAR2 IS

  l_activity_flag   varchar2(1);

  --{verif if 1 distribution has been posted 4897195
  CURSOR c IS
  SELECT 'Y' FROM ra_cust_trx_line_gl_dist
  WHERE customer_trx_id = p_customer_trx_id
  AND account_set_flag = 'N'
  AND posting_control_id > 0;

  l_found   VARCHAR2(1);
  --}

  --Bug5394382
  CURSOR col_del IS
  SELECT 'Y' FROM iex_delinquencies
  WHERE transaction_id = p_customer_trx_id;

BEGIN
     --{BUG 4897195
     OPEN c;
     FETCH c INTO l_found;
     IF c%NOTFOUND THEN
        l_found := 'N';
     END IF;
     CLOSE c;
     IF l_found = 'Y' THEN
        RETURN 'Y';
     END IF;
     --}

     --{BUG 5394382
     OPEN col_del;
     FETCH col_del INTO l_found;
     IF col_del%NOTFOUND THEN
        l_found := 'N';
     END IF;
     CLOSE col_del;
     IF l_found = 'Y' THEN
        RETURN 'Y';
     END IF;
     --}




      IF    (
                  NVL(p_open_receivables_flag, 'Y')  = 'N'
            /* Bug 640006: removed comparison to p_complete_flag because
               if the transaction window is open when an activity is applied
               against it, the incomplete button is still enabled and
               p_complete_flag is 'N'. This function will incorrectly pass
               back 'N' even though there is activity
               OR NVL(p_complete_flag,         'Y')  = 'N' */
            )
      THEN  RETURN( 'N' );
      ELSE

           /*--------------------------------------------------------------+
            |  Transaction has activity if it is the child of a Guarantee  |
            +--------------------------------------------------------------*/

            IF ( p_initial_customer_trx_id IS NOT NULL )
            THEN
                   SELECT DECODE(ctt.type,
                                 'GUAR', 'Y',
                                         'N')
                   INTO   l_activity_flag
                   FROM   ra_customer_trx   ct,
                          ra_cust_trx_types ctt
                   WHERE  ct.cust_trx_type_id = ctt.cust_trx_type_id
                   AND    ct.customer_trx_id  = p_initial_customer_trx_id
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
                   AND    ct.org_id  = ctt.org_id;
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
--end anuj


                   /* for invoices applied to guarantees we need to check
                      the complete flag. if it is incomplete then we need
                      to return no activity.  Bug 677474 */
                   IF    (l_activity_flag = 'Y')  THEN
                      IF ( NVL(p_complete_flag, 'Y')  = 'N') THEN
                         RETURN ('N');
                      ELSE
                         RETURN('Y');
                      END IF;
                   END IF;

            END IF;

           /*-------------------------------------------------------+
            |  Transaction has actvity if this is a commitment and  |
            |  child transactions exist.                            |
            +-------------------------------------------------------*/

            IF (p_class IN ('DEP', 'GUAR') )
            THEN

                   SELECT DECODE( MAX(ct.customer_trx_id),
                                  NULL, 'N',
                                        'Y')
                   INTO   l_activity_flag
                   FROM   ra_customer_trx ct
                   WHERE  ct.initial_customer_trx_id = p_customer_trx_id;

                   IF    (l_activity_flag = 'Y')
                   THEN  RETURN('Y');
                   END IF;

            END IF;

           /*------------------------------------------------------+
            |  Check the payment schedule to see if any activity   |
            |  can be detected there.                              |
            +------------------------------------------------------*/

            IF ( p_previous_customer_trx_id IS NULL )
            THEN

                 SELECT  DECODE( MAX(ps.payment_schedule_id),
                                 NULL, 'N',
                                       'Y')
                 INTO    l_activity_flag
                 FROM    ar_payment_schedules ps
                 WHERE   ps.customer_trx_id         = p_customer_trx_id
                 AND    (
                            ps.amount_due_original <> ps.amount_due_remaining
                         OR NVL(ps.amount_applied,0)    <> 0
                         OR NVL(ps.amount_credited,0)   <> 0
                         OR NVL(ps.amount_adjusted,0)   <> 0
                         OR NVL(ps.amount_in_dispute,0) <> 0
                         OR ps.selected_for_receipt_batch_id  IS NOT NULL
                         OR exists
                            (
                               SELECT 'dunned'
                               FROM    ar_correspondence_pay_sched cps
                               WHERE   cps.payment_schedule_id =
                                       ps.payment_schedule_id
                            )
                         );

                 IF    (l_activity_flag = 'Y')
                 THEN  RETURN('Y');
                 END IF;


                /*------------------------------------------------------+
                 |  Check to see if any applications exist against      |
                 |  this transaction. If the sum of these applications  |
                 |  equals zero, they would not have been detected in   |
                 |  the payment schedule check above.                   |
                 +------------------------------------------------------*/

                 SELECT DECODE( MAX( receivable_application_id ),
                                NULL, 'N',
                                      'Y' )
                 INTO   l_activity_flag
                 FROM   ar_receivable_applications app
                 WHERE  app.customer_trx_id         = p_customer_trx_id
                 OR     app.applied_customer_trx_id = p_customer_trx_id;

                 IF    (l_activity_flag = 'Y')
                 THEN  RETURN('Y');
                 END IF;

            ELSE   --  Credit Memo against a specific transaction case

                /*-----------------------------------------------------+
                 |  Check the payment schedule for activity.           |
                 |  This check is more limited than for non-specific   |
                 |  credit memos. If it were not, all specific credit  |
                 |  memos would always have activity since they are    |
                 |  immediately applied to the credited transaction.   |
                 +-----------------------------------------------------*/

                 SELECT DECODE( MAX( payment_schedule_id ),
                                NULL, 'N',
                                      'Y' )
                 INTO    l_activity_flag
                 FROM    ar_payment_schedules ps
                 WHERE   (
                            (
                                 NVL(ps.amount_credited,   0) <> 0
                              OR NVL(ps.amount_adjusted,   0) <> 0
                              OR NVL(ps.amount_in_dispute, 0) <> 0
                            )
                            OR
                            ps.selected_for_receipt_batch_id  IS NOT NULL
                         )
                 AND     ps.customer_trx_id = p_customer_trx_id;

                 IF    (l_activity_flag = 'Y')
                 THEN  RETURN('Y');
                 END IF;

                /*---------------------------------------------------+
                 |  If another CM against the same invoice has been  |
                 |  completed since the current CM was completed,    |
                 |  the current CM will be deemed to have activity.  |
                 |  This is to prevent changes that would make the   |
                 |  other credit memos invalid.                      |
                 +---------------------------------------------------*/

                 SELECT DECODE( MAX( other_ps.payment_schedule_id),
                                NULL, 'N',
                                      'Y')
                 INTO   l_activity_flag
                 FROM   ar_payment_schedules  this_ps,
                        ar_payment_schedules  other_ps,
                        ra_customer_trx       other_ct
                 WHERE  this_ps.customer_trx_id           = p_customer_trx_id
                 AND    other_ct.previous_customer_trx_id =
                                                  p_previous_customer_trx_id
                 AND    other_ct.customer_trx_id = other_ps.customer_trx_id
                 AND    other_ps.creation_date   > this_ps.creation_date;

                 IF    (l_activity_flag = 'Y')
                 THEN  RETURN('Y');
                 END IF;

            END IF;   -- previous_customer_trx_id check


           /*---------------------------------------------------------------+
            |  ** The following checks must be done for all transactions ** |
            +---------------------------------------------------------------*/

           /*-----------------------------------------------------+
            |  Check to see if any adjustments exist against      |
            |  this transaction. If the sum of these adjustments  |
            |  equals zero, they would not have been detected in  |
            |  the payment schedule check above.                  |
            +-----------------------------------------------------*/

            SELECT DECODE( MAX(adjustment_id),
                           NULL, 'N',
                                 'Y')
            INTO   l_activity_flag
            FROM   ar_adjustments
            WHERE  customer_trx_id = p_customer_trx_id;

            IF    (l_activity_flag = 'Y')
            THEN  RETURN('Y');
            END IF;


           /*-------------------------------------------------------------+
            |  If the transaction exists in the postbatch interim tables, |
            |  then consider the transaction to have activity.            |
            +-------------------------------------------------------------*/

            SELECT DECODE( MAX( customer_trx_id ),
                           NULL, 'N',
                                 'Y')
            INTO   l_activity_flag
            FROM   ar_interim_cash_receipts
            WHERE  customer_trx_id = p_customer_trx_id;

            IF    (l_activity_flag = 'Y')
            THEN  RETURN('Y');
            END IF;


            SELECT DECODE( MAX( customer_trx_id ),
                           NULL, 'N',
                                 'Y')
            INTO   l_activity_flag
            FROM   ar_interim_cash_receipt_lines
            WHERE  customer_trx_id = p_customer_trx_id;

            /* Bug 666136: If a transaction is included in a consolidated
               billling invoice, consider it as an activity so that the
               consolidated billling number cannot be overwritten.        */
            SELECT DECODE( MAX( cons_inv_id ),
                           NULL, 'N',
                                 'Y')
            INTO   l_activity_flag
            FROM   ar_payment_schedules
            WHERE  customer_trx_id = p_customer_trx_id;

            IF    (l_activity_flag = 'Y')
            THEN  RETURN('Y');
            END IF;

           /*-------------------------------------------------------+
            |  25-SEP-2000 J Rautiainen BR Implementation           |
            |  Assignements to Bills Receivable are considered as   |
            |  activities.                                          |
            +-------------------------------------------------------*/

            SELECT DECODE( MAX(customer_trx_line_id),
                           NULL, 'N',
                                 'Y')
            INTO   l_activity_flag
            FROM  ra_customer_trx_lines ctl
            WHERE br_ref_customer_trx_id = p_customer_trx_id;

            IF    (l_activity_flag = 'Y')
            THEN  RETURN('Y');
            END IF;

            /* bug 811796 - check if the transaction has been posted to GL */

           /*-------------------------------------------------------+
            |  04-AUG-2000 J Rautiainen BR Implementation           |
            |  For Bills Receivable check the posting from table    |
            |  ar_transaction_history, for other types use the      |
            |  existing logic.                                      |
            +-------------------------------------------------------*/

            IF (p_class = 'BR' ) THEN

              SELECT DECODE( MAX( gl_posted_date ), NULL, 'N', 'Y')
              INTO   l_activity_flag
              FROM   ar_transaction_history
              WHERE  customer_trx_id = p_customer_trx_id;

            ELSE

              SELECT DECODE( MAX( gl_posted_date ), NULL, 'N', 'Y')
              INTO   l_activity_flag
              FROM   ra_cust_trx_line_gl_dist
              WHERE  customer_trx_id = p_customer_trx_id;

            END IF;

            IF    (l_activity_flag = 'Y')
              /* bug 881066: changed the return flag to 'G' to indicate that the GL posting is done */
            THEN
              RETURN('G');
            END IF;

     /* bug 2207354 - Check if the transaction has an incomplete
	    credit memo against it */
	    SELECT decode (MAX(previous_customer_trx_id), NULL, 'N', 'Y')
    	    INTO   l_activity_flag
	    FROM   ra_customer_trx
   	    WHERE  previous_customer_trx_id = p_customer_trx_id;

       	    IF    (l_activity_flag = 'Y')
            THEN  RETURN('Y');
	    END IF;


      END IF;

      RETURN('N');

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |     Get_Reference                                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the value of the column in the transaction flexfield that has  |
 |     been designated the reference column by the AR_PA_CODE profile.       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_trx_rowid                                            |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The value of the reference column                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-OCT-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION Get_Reference( p_trx_rowid IN ROWID)
                        RETURN varchar2 IS

 l_temp varchar2(150);

BEGIN
  IF  p_trx_rowid IS NOT NULL

  THEN
       SELECT DECODE(DEFAULT_REFERENCE,
                      '1', ct.interface_header_attribute1,
                      '2', ct.interface_header_attribute2,
                      '3', ct.interface_header_attribute3,
                      '4', ct.interface_header_attribute4,
                      '5', ct.interface_header_attribute5,
                      '6', ct.interface_header_attribute6,
                      '7', ct.interface_header_attribute7,
                      '8', ct.interface_header_attribute8,
                      '9', ct.interface_header_attribute9,
                      '10', ct.interface_header_attribute10,
                      '11', ct.interface_header_attribute11,
                      '12', ct.interface_header_attribute12,
                      '13', ct.interface_header_attribute13,
                      '14', ct.interface_header_attribute14,
                      '15', ct.interface_header_attribute15,
                      NULL )
        INTO   l_temp
        FROM   ra_customer_trx ct,
               ra_batch_sources bs
        WHERE  ct.rowid = p_trx_rowid and
               bs.batch_source_id = ct.batch_source_id;
  END IF;

  RETURN(l_temp);

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |     Get_Line_Reference                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the value of the column in the transaction flexfield that has  |
 |     been designated the reference column by the AR_PA_CODE profile.       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_line_trx_rowid                                       |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The value of the reference column                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     11-Dec-03  Surendra Rajan      Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION Get_Line_Reference( p_line_trx_rowid IN ROWID)
                        RETURN varchar2 IS

 l_line_temp varchar2(150);

BEGIN
  IF  p_line_trx_rowid IS NOT NULL

  THEN
       SELECT DECODE(DEFAULT_REFERENCE,
                      '1', ctl.interface_line_attribute1,
                      '2', ctl.interface_line_attribute2,
                      '3', ctl.interface_line_attribute3,
                      '4', ctl.interface_line_attribute4,
                      '5', ctl.interface_line_attribute5,
                      '6', ctl.interface_line_attribute6,
                      '7', ctl.interface_line_attribute7,
                      '8', ctl.interface_line_attribute8,
                      '9', ctl.interface_line_attribute9,
                      '10', ctl.interface_line_attribute10,
                      '11', ctl.interface_line_attribute11,
                      '12', ctl.interface_line_attribute12,
                      '13', ctl.interface_line_attribute13,
                      '14', ctl.interface_line_attribute14,
                      '15', ctl.interface_line_attribute15,
                      NULL )
        INTO   l_line_temp
        FROM   ra_customer_trx_lines  ctl,
               ra_customer_trx  ct,
               ra_batch_sources bs
        WHERE  bs.batch_source_id  =  ct.batch_source_id  and
               ctl.customer_trx_id =  ct.customer_trx_id  and
               ctl.rowid           =  p_line_trx_rowid    ;
  END IF;

  RETURN(l_line_temp);

END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Set_Reference_Column                                                   |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Sets a package variable with the value of the AR_PA_CODE profile.      |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_reference column                                     |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-OCT-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Set_Reference_Column(p_reference_column IN varchar2 ) AS

BEGIN
   pg_reference_column := p_reference_column;

END;




/*===========================================================================+
 | FUNCTION                                                                  |
 |    Get_First_Due_Date                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the first due date given the term and the transaction date        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_term_id                                               |
 |                   p_trx_date                                              |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     06-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION Get_First_Due_Date( p_term_id   IN  number,
                             p_trx_date  IN  date)
                       RETURN DATE IS

   l_term_due_date DATE;
   l_bill_cycle    	   NUMBER;
   l_bill_date	   	   DATE;
   l_bill_cycle_type       VARCHAR2(30);

BEGIN

 IF    (
               p_term_id   IS NOT NULL
          AND  p_trx_date  IS NOT NULL
       )
 THEN

             IF ar_bfb_utils_pvt.is_payment_term_bfb(p_term_id) = 'Y' then

                   l_bill_cycle := ar_bfb_utils_pvt.get_billing_cycle(p_term_id);

                   l_bill_cycle_type := ar_bfb_utils_pvt.get_cycle_type(l_bill_cycle);

                   IF (l_bill_cycle_type is NOT NULL AND l_bill_cycle_type <> 'EVENT') THEN
                     l_bill_date := ar_bfb_utils_pvt.get_billing_date
                                            (l_bill_cycle,
                                             p_trx_date);

		     l_term_due_date := ar_bfb_utils_pvt.get_due_date
						(l_bill_date, p_term_id);

                     RETURN( l_term_due_date );
                   END IF;
             END IF;

       SELECT
        DECODE( tl.due_days,
         NULL, NVL( tl.due_date,
                    DECODE ( LEAST(
                                    TO_NUMBER(
                                            TO_CHAR(p_trx_date,
                                                    'DD') ),
                                    NVL(t.due_cutoff_day, 32)
                                  ),
                              t.due_cutoff_day,
                                LAST_DAY(
                                 ADD_MONTHS(
                                             p_trx_date,
                                             tl.due_months_forward
                                           ) )
                                + LEAST(tl.due_day_of_month,
                                        TO_NUMBER(
                                          TO_CHAR(
                                           LAST_DAY(
                                            ADD_MONTHS(p_trx_date,
                                                      tl.due_months_forward +
                                                      1 )
                                                   ), 'DD'
                                                 ) ) ),
                  	/*BUG 1702687 --ADDED decode(tl.due....)*/
                            /* BUG 2019477 -- ADDED the decode(sign(trunc(t */

                              LAST_DAY( ADD_MONTHS(p_trx_date,
                                                   (tl.due_months_forward +decode(tl.due_months_forward-trunc(tl.due_months_forward),0,-1,0)))+
              decode(sign(trunc(tl.due_months_forward)-tl.due_months_forward),-1,
		decode(sign(((TO_NUMBER(TO_CHAR(p_trx_date,'DD')))+
			(tl.due_months_forward-trunc(tl.due_months_forward))*30)-t.due_cutoff_day),-1,-30,0),0)

			      /*BUG 1702687 ends */
                                      ) +
                              LEAST( tl.due_day_of_month,
                                     TO_NUMBER(
                                       TO_CHAR(
                                        LAST_DAY(
                                         ADD_MONTHS(p_trx_date,
                                                   tl.due_months_forward)
                                                ), 'DD'
                                              ) )
                                   )
                           )
                  ),
               p_trx_date + tl.due_days
              )
       INTO   l_term_due_date
       FROM   ra_terms_lines tl,
              ra_terms t
       WHERE  tl.term_id       = p_term_id
       AND    t.term_id        = tl.term_id
       AND    tl.sequence_num  = (
                                    SELECT MIN(sequence_num)
                                    FROM   ra_terms_lines
                                    WHERE term_id = p_term_id
                                 );
 END IF;

 RETURN( l_term_due_date );

 EXCEPTION
   WHEN NO_DATA_FOUND THEN NULL;
   WHEN OTHERS THEN RAISE;

END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    Get_First_Real_Due_Date                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   Gets the first real due date given the customer_trx_id, based on the    |
 |   payment schedule record for the first due installment.  If there is no  |
 |   payment schedule record, it calculates the first due date by calling    |
 |   the function Get_First_Due_Date in this package.                        |
 |   									     |
 |    This function is used in view ra_customer_trx_partial_v                |
 |    and was created in response to bug 486822.			     |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		     p_customer_trx_id					     |
 |                   p_term_id                                               |
 |                   p_trx_date                                              |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     01-MAY-97  OSTEINME	Created		                             |
 |                                                                           |
 +===========================================================================*/

FUNCTION Get_First_Real_Due_Date( p_customer_trx_id IN  number,
				p_term_id   IN  number,
                             p_trx_date  IN  date)
                       RETURN DATE IS

   l_term_due_date DATE;

BEGIN
--Bug fix form 5589303, if the billing_date is not null, billing date shall be passed to calculate due date

 SELECT NVL(MIN(ps.due_date),
	arpt_sql_func_util.get_first_due_date(p_term_id, nvl(ct.billing_date, p_trx_date)))
 INTO l_term_due_date
 FROM ar_payment_schedules ps,
      ra_customer_trx ct
 WHERE ct.customer_trx_id=ps.customer_trx_id(+)
   AND ct.customer_trx_id = p_customer_trx_id
   group by ct.billing_date;

 RETURN( l_term_due_date );

 EXCEPTION
   WHEN NO_DATA_FOUND THEN RETURN NULL;
   WHEN OTHERS THEN RAISE;

END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    Get_Number_Of_Due_Dates                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the number of due dates on a payment term.                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_term_id                                               |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     16-NOV-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION Get_Number_Of_Due_Dates( p_term_id   IN  number)
                       RETURN NUMBER IS

 l_count  number;

BEGIN

 IF    (  p_term_id   IS NOT NULL )
 THEN

        SELECT COUNT(*)
        INTO   l_count
        FROM   ra_terms_lines
        WHERE  term_id = p_term_id;

 END IF;

 RETURN( l_count );

 EXCEPTION
   WHEN OTHERS THEN RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_period_name                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the period name based on the incoming gl date.                    |
 |    Used by the ra_batches_v view.                                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_gl_date                                               |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-JUN-96  Simon Leung		Created.                             |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_period_name( p_gl_date IN DATE )
			RETURN VARCHAR2 IS

   l_period_name	gl_period_statuses.period_name%TYPE;

   CURSOR	c_period_name IS
		select /*+use_nl(sp,gps) index(gps gl_period_statuses_u1)*/
                        gps.period_name
		from	gl_period_statuses gps,
			ar_system_parameters sp
		where	gps.application_id = 222
		and	gps.adjustment_period_flag = 'N'
		and	gps.set_of_books_id = sp.set_of_books_id
		and	p_gl_date between gps.start_date and gps.end_date;
BEGIN
   l_period_name := NULL;
   IF ( p_gl_date IS NOT NULL ) THEN
      OPEN c_period_name;
      FETCH c_period_name INTO l_period_name;
      CLOSE c_period_name;
   END IF;
   RETURN( l_period_name );

EXCEPTION
   WHEN OTHERS THEN RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_territory                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the territory name based on the incoming address id.              |
 |    Used by the ra_customer_trx_cr_trx_v view.                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_address_id                                            |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-JUN-96  Simon Leung           Created.                             |
 +===========================================================================*/

FUNCTION get_territory( p_address_id IN NUMBER )
                        RETURN VARCHAR2 IS

   l_territory	fnd_territories_vl.territory_short_name%TYPE;

   /* modified for tca uptake */
   CURSOR       c_territory IS
		select  ft.territory_short_name
		from	fnd_territories_vl ft,
			hz_cust_acct_sites acct_site,
                        hz_party_sites party_site,
                        hz_locations loc
		where	loc.country = ft.territory_code
                and     acct_site.party_site_id = party_site.party_site_id
                and     loc.location_id = party_site.location_id
		and	acct_site.cust_acct_site_id = p_address_id;

BEGIN
   l_territory := NULL;
   IF ( p_address_id IS NOT NULL ) THEN
      OPEN c_territory;
      FETCH c_territory INTO l_territory;
      CLOSE c_territory;
   END IF;
   RETURN (l_territory);

EXCEPTION
   WHEN OTHERS THEN RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_territory_rowid                                                    |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the territory row id based on the incoming address id.            |
 |    Used by the ra_customer_trx_cm_v view.                                 |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_address_id                                            |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     04-JUN-96  Simon Leung           Created.                             |
 +===========================================================================*/

FUNCTION get_territory_rowid( p_address_id IN NUMBER )
                        RETURN ROWID IS

   l_territory_rowid ROWID;

   /* modified for tca uptake */
   CURSOR       c_territory IS
		select  ft.rowid
		from	fnd_territories_vl ft,
			hz_cust_acct_sites acct_site,
                        hz_party_sites party_site,
                        hz_locations loc
		where	loc.country = ft.territory_code
                and     acct_site.party_site_id = party_site.party_site_id
                and     loc.location_id = party_site.location_id
		and	acct_site.cust_acct_site_id = p_address_id;

BEGIN
   l_territory_rowid := NULL;
   IF ( p_address_id IS NOT NULL ) THEN
      OPEN c_territory;
      FETCH c_territory INTO l_territory_rowid;
      CLOSE c_territory;
   END IF;
   RETURN (l_territory_rowid);

EXCEPTION
   WHEN OTHERS THEN RAISE;
END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_commitments_exist_flag                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines whether any commitments can be used for a customer.         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_bill_to_customer_id                                   |
 |                   p_invoice_currency_code                                 |
 |                   p_previous_customer_trx_id                              |
 |                   p_ct_prev_initial_cust_trx_id                           |
 |                   p_trx_date                                              |
 |                   p_code_combination_id_gain                              |
 |                   p_base_currency                                         |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-JUN-96  Charlie Tomberg       Created.                             |
 +===========================================================================*/

FUNCTION get_commitments_exist_flag(
                                     p_bill_to_customer_id         IN number,
                                     p_invoice_currency_code       IN varchar2,
                                     p_previous_customer_trx_id    IN number,
                                     p_trx_date                    IN date,
                                     p_ct_prev_initial_cust_trx_id IN number
                                                             DEFAULT NULL,
                                     p_code_combination_id_gain    IN number
                                                             DEFAULT NULL,
                                     p_base_currency               IN varchar2
                                                             DEFAULT NULL)
                        RETURN varchar2 IS

      l_commitments_exist_flag       varchar2(1);
      l_code_combination_id_gain     number;
      l_base_currency                varchar2(15);
      l_ct_prev_initial_cust_trx_id  number;
      l_trx_date		     date;
BEGIN

      IF    (
                 p_code_combination_id_gain  IS NULL
              OR p_base_currency             IS NULL
            )
      THEN
            SELECT sp.code_combination_id_gain,
                   sb.currency_code
            INTO   l_code_combination_id_gain,
                   l_base_currency
            FROM   ar_system_parameters sp,
                   gl_sets_of_books     sb
            WHERE  sp.set_of_books_id = sb.set_of_books_id;

      ELSE
            l_code_combination_id_gain := p_code_combination_id_gain;
            l_base_currency            := p_base_currency;
      END IF;


      IF (
               p_previous_customer_trx_id     IS NOT NULL
           AND p_ct_prev_initial_cust_trx_id  IS NULL
         )
      THEN
            SELECT MAX(initial_customer_trx_id)
            INTO   l_ct_prev_initial_cust_trx_id
            FROM   ra_customer_trx
            WHERE  customeR_trx_id = p_previous_customer_trx_id;
      ELSE
            l_ct_prev_initial_cust_trx_id := p_ct_prev_initial_cust_trx_id;
      END IF;

    l_trx_date := NVL(p_trx_date, trunc(sysdate));

    SELECT DECODE( MAX(dummy),
                   NULL, 'N',
                         'Y' )
    INTO   l_commitments_exist_flag
    FROM   DUAL
    WHERE  EXISTS
    (
      SELECT 'commitments_exist'
      FROM   hz_cust_accounts cust_acct,
             so_agreements soa,
             hz_cust_acct_sites acct_site,
             ra_cust_trx_types inv_type,
             ra_cust_trx_types type,
             ra_customer_trx trx
      WHERE  trx.cust_trx_type_id         = type.cust_trx_type_id
      AND    trx.bill_to_customer_id      = cust_acct.cust_account_id
      AND    trx.remit_to_address_id      = acct_site.cust_acct_site_id(+)
      AND    'A'                          = acct_site.status(+)
      AND    trx.agreement_id             = soa.agreement_id(+)
      AND    type.subsequent_trx_type_id  = inv_type.cust_trx_type_id(+)
      AND    'A'                          = inv_type.status(+)
      AND    type.type                    in ('DEP','GUAR')
      AND    trx.complete_flag            = 'Y'
      AND    trx.bill_to_customer_id
              in (
                  select distinct cr.cust_account_id
                  from   hz_cust_acct_relate cr
                  where  cr.related_cust_account_id = p_bill_to_customer_id
                  AND    status = 'A'
                  union
                  select to_number(p_bill_to_customer_id)
                  from   dual
                  UNION
                  SELECT acc.cust_account_id
                    FROM ar_paying_relationships_v rel,
                         hz_cust_accounts acc
                   WHERE rel.party_id = acc.party_id
                     AND rel.related_cust_account_id = p_bill_to_customer_id
                     AND l_trx_date BETWEEN effective_start_date
                                          AND effective_end_date

                 )
      AND    trx.invoice_currency_code =
                  DECODE(l_code_combination_id_gain,
                         NULL,   l_base_currency,
                                 p_invoice_currency_code
                        ) /* non-on account credit memos must have the same
                           commitment as the transactions that they are
                           crediting. */
      AND    (
                  p_previous_customer_trx_id is NULL
               or trx.customer_trx_id = l_ct_prev_initial_cust_trx_id
             )
            /* check effectivity dates */
      AND    l_trx_date
             BETWEEN NVL(trx.start_date_commitment, l_trx_date)
                 AND NVL(trx.end_date_commitment, l_trx_date)
      AND    l_trx_date
             BETWEEN NVL( soa.start_date_active(+), l_trx_date)
                 AND NVL( soa.end_date_active(+), l_trx_date)
      AND    l_trx_date
             BETWEEN NVL( inv_type.start_date(+), l_trx_date)
                 AND NVL( inv_type.end_date(+), l_trx_date)
   );

      RETURN( l_commitments_exist_flag );


EXCEPTION
   WHEN OTHERS THEN RAISE;
END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_agreements_exist_flag                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines whether any agreements can be used for a customer.         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_bill_to_customer_id                                   |
 |                   p_trx_date                                              |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     20-JUN-96  Charlie Tomberg       Created.                             |
 | 10/10/1996 Harri Kaukovuo	Changed UNION to UNION ALL to get little
 |				better performance.
 +===========================================================================*/

FUNCTION get_agreements_exist_flag(
                                     p_bill_to_customer_id         IN number,
                                     p_trx_date                    IN date )
                        RETURN varchar2 IS

      l_agreements_exist_flag       varchar2(1);

BEGIN

    SELECT DECODE( MAX(dummy),
                   NULL, 'N',
                         'Y' )
    INTO   l_agreements_exist_flag
    FROM   DUAL
    WHERE  EXISTS
    (
      SELECT 'agreements_exist'
      FROM   so_agreements a
      WHERE  a.customer_id IN
                (
                    SELECT cr.cust_account_id
                    FROM   hz_cust_acct_relate cr
                    WHERE  cr.related_cust_account_id  = p_bill_to_customer_id
                    AND    cr.status            = 'A'
                   UNION ALL
                    SELECT to_number(p_bill_to_customer_id)
                    FROM   dual
                   UNION ALL
                    SELECT -1   /* no customer case */
                    FROM   dual
                )
      AND    p_trx_date
                BETWEEN NVL( TRUNC( a.start_date_active ), p_trx_date )
                AND     NVL( TRUNC( a.end_date_active   ), p_trx_date )
   );
      RETURN( l_agreements_exist_flag );


EXCEPTION
   WHEN OTHERS THEN RAISE;
END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_override_terms                                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the override_terms value from the customer profile.               |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                   p_customer_id                                           |
 |                   p_site_use_id                                           |
 |                                                                           |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | 19-JUN-96  Charlie Tomberg       Created.
 | 10/10/1996 Harri Kaukovuo	    Removed extra join to ra customers
 |				    table.
 +===========================================================================*/

FUNCTION get_override_terms(
                              p_customer_id  IN number,
                              p_site_use_id  IN NUMBER )
                        RETURN varchar2 IS

l_override_terms  VARCHAR2(1);

BEGIN

      SELECT NVL(site.override_terms, cust.override_terms)
      INTO   l_override_terms
      FROM   hz_customer_profiles         cust,
             hz_customer_profiles         site
      WHERE  cust.cust_account_id      = p_customer_id
      AND    cust.site_use_id      IS NULL
      AND    site.cust_account_id (+)  = cust.cust_account_id
      AND    site.site_use_id (+)  = NVL(p_site_use_id,-44444);

      RETURN( l_override_terms );


EXCEPTION
   WHEN OTHERS THEN RAISE;
END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_bs_name_for_cb_invoice                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the batch source name of the invoice associated with a Chargeback.|
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id of the CB type transaction           |
 |                    p_class                                                |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : Batch Source Name of the Invoice associated with the         |
 |              chargeback.                                                  |
 |                                                                           |
 | NOTES      : Currently being used by -> AR_PAYMENT_SCHEDULES_V            |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     08-MAY-1997  Neeraj Tandon     Created  Bug Fix : 480077              |
 +===========================================================================*/

FUNCTION get_bs_name_for_cb_invoice ( p_class           IN varchar2,
                                      p_customer_trx_id IN number
                                    )
RETURN VARCHAR2 is

  l_bs_name ra_batch_sources.name%type;
  l_customer_trx_id ra_customer_trx.customer_trx_id%type;

BEGIN

  IF ( p_class <> 'CB' ) THEN
    RETURN( NULL );
  ELSE

/*------------------------------------------------------------------------------------+
 | Find the Customer_Trx_Id of the Invoice Related with Transaction of Type 'CB'      |
 | and then pass it as a parameter to the next SQL to determine the Batch Source Name |
 +------------------------------------------------------------------------------------*/

    select bs.name
    into   l_bs_name
    from   ra_customer_trx    ct,
           ra_batch_sources   bs
    where  ct.batch_source_id = bs.batch_source_id
           and ct.org_id = bs.org_id --anuj
    and    ct.customer_trx_id = (select max(ctt.customer_trx_id)
                                 from   ra_customer_trx          ctt,
                                        ar_adjustments           aa
                                 where  aa.chargeback_customer_trx_id = p_customer_trx_id
                                 and aa.org_id = ctt.org_id --anuj
                                 and    aa.customer_trx_id            = ctt.customer_trx_id
                                );

    RETURN l_bs_name;

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_dunning_date_last                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the lastest dunning date of a trsanction                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_payment_schedule_id                                  |
 |                                                                           |
 |              OUT:                                                         |
 |                    none                                                   |
 |                                                                           |
 | RETURNS    : the lastest dunning date                                     |
 |                                                                           |
 |                                                                           |
 | NOTES      : Currently being used by -> AR_PAYMENT_SCHEDULES_V            |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     01-JUN-1998  Yangya Kong       Created  Bug Fix : 627071              |
 +===========================================================================*/
FUNCTION get_dunning_date_last (p_payment_schedule_id
                                  IN ar_correspondence_pay_sched.payment_schedule_id%type)

RETURN DATE  is

  l_dunning_date_last ar_correspondences.correspondence_date%type;

BEGIN

  select MAX(arc.correspondence_date)
  into   l_dunning_date_last
  from   ar_correspondences arc,
         ar_correspondence_pay_sched arcps
  where  arcps.payment_schedule_id = p_payment_schedule_id
  and 	 arc.correspondence_id = arcps.correspondence_id
  and	 nvl(arc.preliminary_flag,'N') = 'N';

  RETURN (l_dunning_date_last);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END;

FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_meaning ar_lookups.meaning%TYPE;
l_hash_value NUMBER;
BEGIN
  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         p_lookup_type||'@*?'||p_lookup_code,
                                         1000,
                                         25000);

    IF pg_ar_lookups_rec.EXISTS(l_hash_value) THEN
        l_meaning := pg_ar_lookups_rec(l_hash_value);
    ELSE

     SELECT meaning
     INTO   l_meaning
     FROM   ar_lookups
     WHERE  lookup_type = p_lookup_type
      AND  lookup_code = p_lookup_code ;

     pg_ar_lookups_rec(l_hash_value) := l_meaning;

    END IF;

  END IF;

  return(l_meaning);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;

--
--The function get_salesrep_name_number would return a null in case if an
--invalid or null salesrep_id being passed in
--
FUNCTION get_salesrep_name_number (p_salesrep_id  IN NUMBER,
                                   p_name_number  IN VARCHAR2,
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
                                   p_org_id       IN NUMBER DEFAULT NULL)
/* Multi-Org Access Control Changes for SSA;End;anukumar;11/01/2002*/
--end anuj
 RETURN VARCHAR2 IS
l_salesrep_name   VARCHAR2(240);
l_salesrep_number VARCHAR2(30);
BEGIN

   IF p_salesrep_id IS NOT NULL THEN
    IF pg_salesrep_rec.EXISTS(p_salesrep_id) THEN

      l_salesrep_name:= pg_salesrep_rec(p_salesrep_id).salesrep_name;
      l_salesrep_number := pg_salesrep_rec(p_salesrep_id).salesrep_number;
    ELSE

     SELECT name, salesrep_number
     INTO   l_salesrep_name, l_salesrep_number
     FROM   ra_salesreps
     WHERE  salesrep_id = p_salesrep_id and
--begin anuj
/* Multi-Org Access Control Changes for SSA;Begin;anukumar;11/01/2002*/
            org_id  = p_org_id;
/* Multi-Org Access Control Changes for SSA;end;anukumar;11/01/2002*/
--end anuj

     pg_salesrep_rec(p_salesrep_id).salesrep_name   := l_salesrep_name;
     pg_salesrep_rec(p_salesrep_id).salesrep_number := l_salesrep_number;

    END IF;
   END IF;

   IF p_name_number = 'NAME'  THEN
     RETURN(l_salesrep_name);
   ELSIF p_name_number = 'NUMBER' THEN
     RETURN(l_salesrep_number);
   ELSE
      RETURN(null);
   END IF;

EXCEPTION
  WHEN no_data_found  THEN
     RETURN(null);
  WHEN others THEN
     raise;

END get_salesrep_name_number;

/* Bug 2544852/2558527 : increase size of l_territory_short_name from 60 to 80 */

FUNCTION get_address_details (p_address_id        IN NUMBER,
                              p_detail_type       IN VARCHAR2
                              )
 RETURN VARCHAR2 IS
l_add1    VARCHAR2(240);
l_add2    VARCHAR2(240);
l_add3    VARCHAR2(240);
l_add4    VARCHAR2(240);
l_city    VARCHAR2(60);
l_state   VARCHAR2(60);
l_province VARCHAR2(60);
l_territory_short_name  VARCHAR2(80);
l_postal_code  VARCHAR2(60);
l_country  VARCHAR2(60);
l_status   VARCHAR2(1);
BEGIN

 IF p_address_id IS NOT NULL THEN

    IF pg_address_rec.EXISTS(p_address_id)  THEN
      l_add1        := pg_address_rec(p_address_id).add1;
      l_add2        := pg_address_rec(p_address_id).add2;
      l_add3        := pg_address_rec(p_address_id).add3;
      l_add4        := pg_address_rec(p_address_id).add4;
      l_city        := pg_address_rec(p_address_id).city;
      l_state       := pg_address_rec(p_address_id).state;
      l_province    := pg_address_rec(p_address_id).province;
      l_postal_code := pg_address_rec(p_address_id).postal_code;
      l_country     := pg_address_rec(p_address_id).country;
      l_status      := pg_address_rec(p_address_id).status;
      l_territory_short_name := pg_address_rec(p_address_id).territory_short_name;
    ELSE

        /* modified for tca uptake */
        SELECT loc.ADDRESS1, loc.ADDRESS2, loc.ADDRESS3, loc.ADDRESS4,
               loc.CITY, loc.STATE, loc.PROVINCE, loc.POSTAL_CODE, loc.COUNTRY,
               acct_site.STATUS
        INTO  l_add1, l_add2, l_add3, l_add4,
              l_city, l_state,l_province, l_postal_code, l_country,
              l_status
        FROM  hz_cust_acct_sites acct_site,
              hz_party_sites party_site,
              hz_locations loc
        WHERE acct_site.party_site_id = party_site.party_site_id
          AND loc.location_id = party_site.location_id
          AND acct_site.cust_acct_site_id = p_address_id;

       BEGIN
         SELECT territory_short_name
         INTO   l_territory_short_name
         FROM   fnd_territories_vl
         WHERE  territory_code = l_country;
       EXCEPTION
         WHEN no_data_found THEN
           l_territory_short_name := null;
       END;

      pg_address_rec(p_address_id).add1 := l_add1;
      pg_address_rec(p_address_id).add2 := l_add2;
      pg_address_rec(p_address_id).add3 := l_add3;
      pg_address_rec(p_address_id).add4 := l_add4;
      pg_address_rec(p_address_id).city := l_city;
      pg_address_rec(p_address_id).state := l_state;
      pg_address_rec(p_address_id).province := l_province;
      pg_address_rec(p_address_id).postal_code := l_postal_code;
      pg_address_rec(p_address_id).country := l_country;
      pg_address_rec(p_address_id).status := l_status;
      pg_address_rec(p_address_id).territory_short_name := l_territory_short_name;
    END IF;

  IF p_detail_type = 'ADD1' THEN
    return(l_add1);
  ELSIF p_detail_type = 'ADD2' THEN
    return(l_add2);
  ELSIF p_detail_type = 'ADD3' THEN
    return(l_add3);
  ELSIF p_detail_type = 'ADD4' THEN
    return(l_add4);
  ELSIF p_detail_type = 'CITY' THEN
    return(l_city);
  ELSIF p_detail_type = 'PROVINCE' THEN
    return(l_province);
  ELSIF p_detail_type = 'STATE' THEN
    return(l_state);
  ELSIF p_detail_type = 'POSTAL_CODE' THEN
    return(l_postal_code);
  ELSIF p_detail_type = 'TER_SHORT_NAME'  THEN
    return(l_territory_short_name);
  ELSIF p_detail_type = 'ALL'  THEN
    return(substrb(l_add1,1,25)||' '|| substrb(l_add2,1,25)
    ||' '|| substrb(l_add3,1,25)||' '|| substrb(l_add4,1,25)
    ||' '|| l_city||','|| ' '||nvl(l_state,
      l_province)||' '|| l_territory_short_name);
  ELSIF p_detail_type = 'STATUS' THEN
    return(l_status);
  END IF;

 ELSE
  return(null);
 END IF;

EXCEPTION
WHEN no_data_found  THEN
 return(null);

END get_address_details;

FUNCTION get_phone_details (p_phone_id    IN NUMBER,
                            p_detail_type  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_ph_num     VARCHAR2(50);
l_area_code  VARCHAR2(10);
l_ext        VARCHAR2(20);
BEGIN

  IF p_phone_id IS NOT NULL THEN

   IF pg_phone_rec.EXISTS(p_phone_id) THEN

      l_ph_num:= pg_phone_rec(p_phone_id).phone_number;
      l_area_code := pg_phone_rec(p_phone_id).area_code;
      l_ext := pg_phone_rec(p_phone_id).extension;
    ELSE

     /* modified for tca uptake */
     SELECT decode(cont_point.contact_point_type, 'TLX',
                   cont_point.telex_number, cont_point.phone_number),
            cont_point.phone_area_code,
            cont_point.phone_extension
     INTO  l_ph_num, l_area_code, l_ext
     FROM  hz_contact_points cont_point
     WHERE cont_point.contact_point_id = p_phone_id;

     pg_phone_rec(p_phone_id).extension    := l_ext;
     pg_phone_rec(p_phone_id).area_code    := l_area_code;
     pg_phone_rec(p_phone_id).phone_number := l_ph_num;

   END IF;
  ELSE
   return(null);
  END IF;

      IF p_detail_type = 'PHONE_NUMBER' THEN
        return(l_ph_num);
      ELSIF p_detail_type = 'AREA_CODE' THEN
        return(l_area_code);
      ELSIF p_detail_type = 'EXTENSION' THEN
        return(l_ext);
      END IF;

EXCEPTION
WHEN no_data_found  THEN
 return(null);

END get_phone_details;

/* Bug fix 3655704 */
FUNCTION is_max_rowid (p_rowid IN ROWID)
 RETURN VARCHAR2 IS
  l_max_rowid  ROWID;
BEGIN
   select max(rowid)
   into l_max_rowid
   from gl_import_references
   where (je_header_id, je_batch_id, je_line_num,
          reference_2, reference_3,
          reference_8, reference_9) = (select je_header_id, je_batch_id,je_line_num,
                                                    reference_2, reference_3,
                                                    reference_8, reference_9
                                                    from gl_import_references
                                                    where rowid = p_rowid);
   IF l_max_rowid = p_rowid THEN
      return 'Y';
   ELSE
      return 'N';
   END IF;
END is_max_rowid;

FUNCTION get_term_details (p_term_id     IN NUMBER,
                           p_detail_type IN VARCHAR2)
 RETURN VARCHAR2 IS
l_name                     VARCHAR2(15);
l_calc_disc_on_lines_flag  VARCHAR2(1);
l_partial_discount_flag    VARCHAR2(1);
BEGIN

  IF p_term_id IS NOT NULL THEN

   IF pg_term_rec.EXISTS(p_term_id) THEN

      l_name:= pg_term_rec(p_term_id).name;
      l_calc_disc_on_lines_flag := pg_term_rec(p_term_id).calc_disc_on_lines_flag;
      l_partial_discount_flag := pg_term_rec(p_term_id).partial_discount_flag;
    ELSE

     SELECT name,calc_discount_on_lines_flag,partial_discount_flag
     INTO  l_name, l_calc_disc_on_lines_flag, l_partial_discount_flag
     FROM  ra_terms
     WHERE term_id = p_term_id;

     pg_term_rec(p_term_id).partial_discount_flag        := l_partial_discount_flag;
     pg_term_rec(p_term_id).calc_disc_on_lines_flag    := l_calc_disc_on_lines_flag;
     pg_term_rec(p_term_id).name                         := l_name;

   END IF;
  ELSE
   return(null);
  END IF;

      IF p_detail_type = 'NAME' THEN
        return(l_name);
      ELSIF p_detail_type = 'CALC_DISCOUNT_ON_LINES_FLAG' THEN
        return(l_calc_disc_on_lines_flag);
      ELSIF p_detail_type = 'PARTIAL_DISCOUNT_FLAG' THEN
        return(l_partial_discount_flag);
      END IF;

EXCEPTION
WHEN no_data_found  THEN
 return(null);

END get_term_details;

FUNCTION is_agreement_date_valid(p_trx_date IN DATE,
                                 p_agreement_id IN NUMBER)
 RETURN VARCHAR2 IS
l_name  so_agreements.name%type;
l_valid_date VARCHAR2(10);
l_start_date_active so_agreements.start_date_active%type;
l_end_date_active so_agreements.end_date_active%type;
BEGIN
  IF p_agreement_id IS NOT NULL THEN
    IF pg_agreement_rec.EXISTS(p_agreement_id)     THEN

      l_name:= pg_agreement_rec(p_agreement_id).name;

       IF pg_agreement_rec(p_agreement_id).is_valid_date IS NOT NULL
        THEN
           l_valid_date := pg_agreement_rec(p_agreement_id).is_valid_date;
       ELSE
           l_start_date_active :=  pg_agreement_rec(p_agreement_id).start_date_active;
           l_end_date_active :=    pg_agreement_rec(p_agreement_id).end_date_active;

         IF  NVL(p_trx_date, trunc(sysdate)) >=
             NVL( l_start_date_active,NVL(p_trx_date, trunc(sysdate)))  AND
             NVL(p_trx_date, trunc(sysdate)) <=
             NVL( l_end_date_active,NVL(p_trx_date, trunc(sysdate)))  THEN --Bug 1522486 typo fixed in l_end_date_active
             l_valid_date := 'YES';
         ELSE
             l_valid_date := 'NO';
         END IF;
          pg_agreement_rec(p_agreement_id).is_valid_date := l_valid_date;
       END IF;

    ELSE
      SELECT name,start_date_active, end_date_active
      INTO   l_name, l_start_date_active, l_end_date_active
      FROM   so_agreements
      WHERE  agreement_id =  p_agreement_id ;

      IF  NVL(p_trx_date, trunc(sysdate)) >=
          NVL( l_start_date_active,NVL(p_trx_date, trunc(sysdate)))  AND
          NVL(p_trx_date, trunc(sysdate)) <=
          NVL( l_end_date_active,NVL(p_trx_date, trunc(sysdate)))  THEN --Bug 1522486 typo fixed in l_end_date_active
          l_valid_date := 'YES';
      ELSE
        l_valid_date := 'NO';
      END IF;

      pg_agreement_rec(p_agreement_id).name := l_name;
      pg_agreement_rec(p_agreement_id).is_valid_date := l_valid_date;
      pg_agreement_rec(p_agreement_id).start_date_active := l_start_date_active;
      pg_agreement_rec(p_agreement_id).end_date_active := l_end_date_active;

    END IF;
      return(l_valid_date);
  ELSE
      return('YES');
  END IF;


EXCEPTION
WHEN no_data_found  THEN
   return('YES');
END is_agreement_date_valid;

FUNCTION get_agreement_name(p_agreement_id IN NUMBER)
 RETURN VARCHAR2 IS
l_name  so_agreements.name%type;
l_start_date_active so_agreements.start_date_active%type;
l_end_date_active so_agreements.end_date_active%type;
BEGIN

  IF p_agreement_id IS NOT NULL THEN
    IF pg_agreement_rec.EXISTS(p_agreement_id) THEN

      l_name:= pg_agreement_rec(p_agreement_id).name;

    ELSE
      SELECT name,start_date_active, end_date_active
      INTO   l_name, l_start_date_active, l_end_date_active
      FROM   so_agreements
      WHERE  agreement_id =  p_agreement_id ;

      pg_agreement_rec(p_agreement_id).name := l_name;
      pg_agreement_rec(p_agreement_id).is_valid_date := NULL;
      pg_agreement_rec(p_agreement_id).start_date_active := l_start_date_active;
      pg_agreement_rec(p_agreement_id).end_date_active := l_end_date_active;

    END IF;
      return(l_name);
  ELSE
    return(null);
  END IF;

EXCEPTION
WHEN no_data_found THEN
 return(null);

END get_agreement_name;

FUNCTION get_trx_type_details(p_trx_type_id IN NUMBER,
                              p_detail_type IN VARCHAR2,
                              p_org_id      IN NUMBER DEFAULT NULL) /* Bug fix 5462362*/
 RETURN VARCHAR2 IS
l_name                            ra_cust_trx_types.name%type;
l_type                            ra_cust_trx_types.type%type;
l_subseq_trx_type_id              ra_cust_trx_types.subsequent_trx_type_id%type;
l_allow_overapplication_flag      ra_cust_trx_types.allow_overapplication_flag%type;
l_natural_application_flag        ra_cust_trx_types.natural_application_only_flag%type;
l_creation_sign                   ra_cust_trx_types.creation_sign%type;
-- Bug 4221745
l_post_to_gl                      ra_cust_trx_types.post_to_gl%type;
BEGIN
   IF p_trx_type_id IS NOT NULL THEN

     IF pg_trx_type_rec.EXISTS(p_trx_type_id)  THEN
       l_name := pg_trx_type_rec(p_trx_type_id).name;
       l_type := pg_trx_type_rec(p_trx_type_id).type;
       l_subseq_trx_type_id := pg_trx_type_rec(p_trx_type_id).subseq_trx_type_id;
       l_allow_overapplication_flag  := pg_trx_type_rec(p_trx_type_id).allow_overapplication_flag;
       l_natural_application_flag := pg_trx_type_rec(p_trx_type_id).natural_application_only_flag;
       l_creation_sign := pg_trx_type_rec(p_trx_type_id).creation_sign;
       l_post_to_gl := pg_trx_type_rec(p_trx_type_id).post_to_gl;
     ELSE
      /* Bug fix 5462362*/
      IF p_org_id IS NOT NULL THEN
       BEGIN
          SELECT name, type, subsequent_trx_type_id ,
                 allow_overapplication_flag ,
                 natural_application_only_flag,
                 creation_sign, post_to_gl
          INTO   l_name, l_type, l_subseq_trx_type_id,
                 l_allow_overapplication_flag ,
                 l_natural_application_flag,
                 l_creation_sign, l_post_to_gl
          FROM   ra_cust_trx_types_all
          WHERE  cust_trx_type_id = p_trx_type_id
           AND   org_id = p_org_id;
       EXCEPTION WHEN OTHERS THEN
           return('-99999999');
       END;
      ELSE
       BEGIN
          SELECT name, type, subsequent_trx_type_id ,
                 allow_overapplication_flag ,
                 natural_application_only_flag,
                 creation_sign, post_to_gl
          INTO   l_name, l_type, l_subseq_trx_type_id,
                 l_allow_overapplication_flag ,
                 l_natural_application_flag,
                 l_creation_sign, l_post_to_gl
          FROM   ra_cust_trx_types
          WHERE  cust_trx_type_id = p_trx_type_id;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
          -- bug 4221745 : when running for Operating Unit, try from _ALL table
          BEGIN
             SELECT name, type, subsequent_trx_type_id ,
                    allow_overapplication_flag ,
                    natural_application_only_flag,
                    creation_sign, post_to_gl
             INTO   l_name, l_type, l_subseq_trx_type_id,
                    l_allow_overapplication_flag ,
                    l_natural_application_flag,
                    l_creation_sign, l_post_to_gl
             FROM   ra_cust_trx_types_all
             WHERE  cust_trx_type_id = p_trx_type_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
             return('-99999999');
          END;
       END;
      END IF;

       pg_trx_type_rec(p_trx_type_id).name := l_name;
       pg_trx_type_rec(p_trx_type_id).type := l_type;
       pg_trx_type_rec(p_trx_type_id).subseq_trx_type_id := l_subseq_trx_type_id;
       pg_trx_type_rec(p_trx_type_id).allow_overapplication_flag := l_allow_overapplication_flag;
       pg_trx_type_rec(p_trx_type_id).natural_application_only_flag := l_natural_application_flag;
       pg_trx_type_rec(p_trx_type_id).creation_sign := l_creation_sign;
       pg_trx_type_rec(p_trx_type_id).post_to_gl := l_post_to_gl;
     END IF;

     IF p_detail_type = 'NAME' THEN
       return(l_name);
     ELSIF p_detail_type = 'TYPE'  THEN
       return(l_type);
     ELSIF p_detail_type = 'SUBSEQ_TRX_TYPE' THEN
       return(to_char(l_subseq_trx_type_id));
     ELSIF p_detail_type = 'ALLOW_OVERAPPLICATION_FLAG'  THEN
       return(l_allow_overapplication_flag);
     ELSIF p_detail_type = 'NATURAL_APPLICATION_ONLY_FLAG'  THEN
       return(l_natural_application_flag);
     ELSIF p_detail_type = 'CREATION_SIGN'  THEN
       return(l_creation_sign);
     ELSIF p_detail_type = 'POST' THEN
       return(l_post_to_gl);
     END IF;

  ELSE
   return(null);
  END IF;
EXCEPTION
WHEN others THEN
 return('-99999999');
END;

FUNCTION check_iclaim_installed
 RETURN VARCHAR2
IS
BEGIN
 IF arp_global.tm_installed_flag = 'Y'
 THEN
   RETURN 'T';
 ELSE
   RETURN 'F';
 END IF;
END;

FUNCTION get_orig_gl_date(p_customer_trx_id IN NUMBER)
 RETURN DATE IS
l_orig_gl_date DATE;
BEGIN

   SELECT gl_date
   INTO   l_orig_gl_date
   FROM   ar_transaction_history h
   WHERE  h.customer_trx_id = p_customer_trx_id
   AND    h.event in ('COMPLETED','ACCEPTED')
   AND    h.transaction_history_id =
     (SELECT max(transaction_history_id)
      FROM   ar_transaction_history h2
      WHERE  h2.customer_trx_id = p_customer_trx_id
      AND    h2.event IN ('COMPLETED','ACCEPTED'));

   return l_orig_gl_date;

EXCEPTION
WHEN NO_DATA_FOUND THEN

   SELECT gl_date
   INTO   l_orig_gl_date
   FROM   ar_transaction_history h
   WHERE  h.customer_trx_id  = p_customer_trx_id
   AND    h.current_record_flag = 'Y';

   return l_orig_gl_date;

END;

FUNCTION get_sum_of_trx_lines(p_customer_trx_id IN NUMBER,
                              p_line_type       IN VARCHAR2)
 RETURN NUMBER IS

   l_total NUMBER;

BEGIN

   SELECT NVL(SUM(extended_amount),0)
   INTO   l_total
   FROM   ra_customer_trx_lines
   WHERE  line_type = p_line_type
   AND    customer_trx_id = p_customer_trx_id;

   return l_total;

EXCEPTION
WHEN NO_DATA_FOUND THEN

   return 0;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_balance_due_as_of_date                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Calculates the amount due in a transaction as on date                  |
 |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_applied_payment_schedule_id                          |
 |                    p_as_of_date                                           |
 |                    p_class                                                |
 |              OUT:                                                         |
 |                    none                                                   |
 |                                                                           |
 | RETURNS    : The amount due in a transaction as on date                   |
 |                                                                           |
 |                                                                           |
 | NOTES      : Currently being used by Q_MAIN query in ARXPDI.rdf           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 |     03-JAN-2002  Smita Parasa     Created  Bug Fix : 2064286              |
 |     10-MAY-2004  SAPN Sarma       Bug 3221397. Discounts also included    |
 |				     while calculating the balance_due of the|
 |				     customer. Also, added the code not to   |
 |				    pick up the APPROVED receipt applications|
 |				     while calculating the balance. 	     |
 |     01-JUL-04    Bhushan Dhotkar  bug3740861: Added paramter p_class to   |
 |                                   get_balance_due_as_of_date to prevent   |
 |                                   unnecessary execution of sql to CM amnt |
 +===========================================================================*/


FUNCTION get_balance_due_as_of_date(
                                p_applied_payment_schedule_id in number,
                                p_as_of_date in date,
                                p_class in varchar2  )
RETURN number IS

p_amount_applied     number;
/*Bug 2453245 */
p_adj_amount_applied number;
p_actual_amount      number;
p_amt_due_original   number;
/* Bug 2610716 */
p_cm_amount_applied  number;

BEGIN
 SELECT nvl(sum(nvl(amount_applied,0) + nvl(earned_discount_taken,0) + nvl(unearned_discount_taken,0)), 0)
 INTO   p_amount_applied
 FROM   ar_receivable_applications
 WHERE  applied_payment_schedule_id = p_applied_payment_schedule_id
 AND	status = 'APP'
 AND	nvl(confirmed_flag,'Y') = 'Y'
 AND    apply_date <= p_as_of_date;

 /* Added the  query to take care of On-Account CM applications Bug 2610716*/
IF p_class = 'CM' THEN
 SELECT nvl(sum(amount_applied),0)
 INTO p_cm_amount_applied
 FROM   ar_receivable_applications
 WHERE  payment_schedule_id = p_applied_payment_schedule_id
 AND apply_date <= p_as_of_date;
END IF;

 /* Bug 2453245 Added the query to retrieve the Adjustment
    Amount applied to the Invoice */
 SELECT nvl(sum(amount),0)
 INTO   p_adj_amount_applied
 FROM   ar_adjustments
 WHERE  payment_schedule_id = p_applied_payment_schedule_id
        AND        status   = 'A'
        AND     apply_date <= p_as_of_date;

 SELECT amount_due_original
 INTO   p_amt_due_original
 FROM   ar_payment_schedules
 WHERE  payment_schedule_id = p_applied_payment_schedule_id;

  /*Bug 2453245 Added p_adj_amount_applied so that
   Adjustment amount is also taken into account while
   computing the Balance */
/* bug4085823: Added nvl for p_cm_amount_applied */
  p_actual_amount := p_amt_due_original
                     + p_adj_amount_applied
                     - p_amount_applied + nvl(p_cm_amount_applied,0) ;
  RETURN(p_actual_amount);
EXCEPTION
  /* bug3544286 added NO_DATA_FOUND */
  WHEN NO_DATA_FOUND THEN
    RETURN(null);
  WHEN OTHERS THEN
    NULL;
END get_balance_due_as_of_date;


FUNCTION bucket_function(p_buck_line_typ        varchar2,
                         p_amt_in_disp          NUMBER,
                         p_amt_adj_pen          NUMBER,
                         p_days_from            NUMBER,
                         p_days_to              NUMBER,
                         p_due_date             DATE,
                         p_bucket_category      VARCHAR2,
                         p_as_of                DATE)

RETURN number IS

bucket_amount    NUMBER;

BEGIN

   select decode(p_buck_line_typ,
                'DISPUTE_ONLY',decode(nvl(p_amt_in_disp,0),0,0,1),
                'PENDADJ_ONLY',decode(nvl(p_amt_adj_pen,0),0,0,1),
                'DISPUTE_PENDADJ',decode(nvl(p_amt_in_disp,0),
                        0,decode(nvl(p_amt_adj_pen,0),0,0,1),
                        1),
                decode( greatest(p_days_from,
                                ceil(p_as_of-p_due_date)),
                        least(p_days_to,
                                ceil(p_as_of-p_due_date)),1,
                        0)
                * decode(nvl(p_amt_in_disp,0), 0, 1,
                        decode(p_bucket_category,
                                'DISPUTE_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1))
                * decode(nvl(p_amt_adj_pen,0), 0, 1,
                        decode(p_bucket_category,
                                'PENDADJ_ONLY', 0, 'DISPUTE_PENDADJ', 0,
                                1)))
   into bucket_amount
   from dual;

   return(bucket_amount);

END;

/* 2362943:given the statement or dunning site_use_id return bill_to id */
/*
   2357301 : After the code changes for bug2335304
             It is now possible to have an hz_customer_profiles cp row
             where site_use_id is for a site with purpose in (STMTS, DUN)

             In such cases, this function will return the following :

             if cp.site_use_id = p_site_use_id exists
                return p_site_use_id
             if cp.site_use_id = p_site_use_id DOES NOT exist
                - return the site_use_id for this same cust_acct_site_id that does
                  have a row in hz_customer_profiles

  So technically, this no longer returns the site_use_id with the BILL_TO purpose
  but rather it returns the site_use_id that exists in hz_customer_profiles
  the function should really be get_site_with_profile

  Bug 4128837 : The whole premise of the new get_bill_id was written under
  the assumption that a distinct cust_acct_site_id, can only have one row
  in hz_customer_profiles. This was based on the current Customer Form behavior

  However, it has been noted that old data actually shows that a cust_acct_site_id
  with 2 or more business purposes can have multiple rows in the profiles table
  and this was causing ORA-1422 error. The fix on the exception block ensures that
  only one row will ever be returned by the select.

*/

FUNCTION get_bill_id(p_site_use_id IN NUMBER)
  RETURN NUMBER IS

l_site_with_profile  NUMBER;

BEGIN

   -- check if there is a row in customer profiles using this site_use_id
   -- if found, regardless of it's site_use_code, return that site_use_id

   SELECT distinct site_use_id
     INTO l_site_with_profile
     FROM hz_customer_profiles
    WHERE site_use_id = p_site_use_id;

   return l_site_with_profile;

EXCEPTION
WHEN NO_DATA_FOUND THEN

   BEGIN

      -- Find site_use_id from hz_customer_profiles,
      -- that uses the same cust_acct_site_id as p_site_use_id

      select site_use_id
        into l_site_with_profile
        from hz_customer_profiles
       where site_use_id in ( select site_use_id
                              from hz_cust_site_uses
                              where cust_acct_site_id =
                                  ( SELECT cust_acct_site_id
                                    FROM hz_cust_site_uses
                                    WHERE site_use_id = p_site_use_id)
                                and status = 'A'
                                and site_use_code in ('BILL_TO','DUN','STMTS'));


     return l_site_with_profile;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- Bug 3763432 / 3722489 : define an exception block to return null when
      -- there are no site level profiles
      return null;
   WHEN TOO_MANY_ROWS THEN
      -- Bug 4128837 : this is the case for historical "bad" data,
      -- wherein one cust_acct_site_id can have multiple rows in hz_customer_profiles
      -- In this case, use the BILL_TO site (since this is the profile that
      -- users can access in the customer standard form)

      BEGIN

      select site_use_id
        into l_site_with_profile
        from hz_customer_profiles
       where site_use_id in ( select site_use_id
                              from hz_cust_site_uses
                              where cust_acct_site_id =
                                  ( SELECT cust_acct_site_id
                                    FROM hz_cust_site_uses
                                    WHERE site_use_id = p_site_use_id)
                                and status = 'A'
                                and site_use_code = 'BILL_TO');
        return l_site_with_profile;      /*4913217 */
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         return null;
      END;

   END;

END;

/* 2362943 : return statement cycle tied to a site_use_id */
FUNCTION get_stmt_cycle(p_site_use_id IN NUMBER)

  RETURN NUMBER IS

l_cycle_id NUMBER;

BEGIN
   SELECT statement_cycle_id
     INTO l_cycle_id
     FROM hz_customer_profiles
    WHERE site_use_id = arpt_sql_func_util.get_bill_id(p_site_use_id);

   RETURN l_cycle_id;
END;

/* 2362943 : return send_statements value of a site_use_id */
FUNCTION get_send_stmt(p_site_use_id IN NUMBER)
  RETURN VARCHAR2 IS

l_send VARCHAR2(1);

BEGIN
   SELECT nvl(send_statements ,'N')
     INTO l_send
     FROM hz_customer_profiles
    WHERE site_use_id = arpt_sql_func_util.get_bill_id(p_site_use_id);

   RETURN l_send;
END;

/* 2362943 : return credit_balance_statements given a site_use_id */
FUNCTION get_cred_bal(p_site_use_id IN NUMBER)
  RETURN VARCHAR2 IS

l_cred_bal VARCHAR2(1);

BEGIN
   SELECT nvl(credit_balance_statements ,'N')
     INTO l_cred_bal
     FROM hz_customer_profiles
    WHERE site_use_id = arpt_sql_func_util.get_bill_id(p_site_use_id);

   RETURN l_cred_bal;
END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_claim_amount                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Retrieves the net amount remaining from Trade management for a given   |
 |    claim                                                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | ARGUMENTS  : IN:   p_claim_id                                             |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : The net amount due in claim currency                         |
 |                                                                           |
 | NOTES      : Used by ARXRWAPP.pld arp_app_folder_item.application_ref_num |
 |                                                                           |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     08-MAY-2002  Jon Beckett     Created  (Bug 2353144)                   |
 |     30-MAY-2002  Jon Beckett     Bug 2381718 - get_amount_remaining       |
 |                                  procedure moved to ams_claim_install     |
 |                                  package from ams_claim_grp.              |
 +===========================================================================*/

FUNCTION get_claim_amount(p_claim_id     IN  NUMBER)
RETURN NUMBER
IS
  l_amount_remaining         NUMBER;
  l_acctd_amount_remaining   NUMBER;
  l_currency_code            VARCHAR2(15);
  l_return_status            VARCHAR2(1);

BEGIN
  arp_standard.debug('ARPT_SQL_FUNC_UTIL.get_claim_amount()+');
  OZF_Claim_Install.get_amount_remaining (
              p_claim_id               => p_claim_id,
              x_amount_remaining       => l_amount_remaining,
              x_acctd_amount_remaining => l_acctd_amount_remaining,
              x_currency_code          => l_currency_code,
              x_return_status          => l_return_status
            );
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RETURN FND_API.G_MISS_NUM;
  ELSE
    RETURN l_amount_remaining;
  END IF;

  arp_standard.debug('ARPT_SQL_FUNC_UTIL.get_claim_amount()-');
EXCEPTION
   WHEN OTHERS THEN
   arp_standard.debug('Unexpected error '||sqlerrm||
                      ' occurred in ARPT_SQL_FUNC_UTIL.get_claim_amount');
   RAISE;
END get_claim_amount;

/* Bug3820605 */
FUNCTION get_org_trx_type_details(p_trx_type_id IN NUMBER, p_org_id IN number)
 RETURN VARCHAR2 IS

          p_concat_segments     varchar2(100);
          tab_indx          BINARY_INTEGER := 0;
          found             BOOLEAN ;
          l_trx_name        ra_cust_trx_types.name%type;
          l_hash_value    NUMBER;
BEGIN
  /*----------------------------------------------------------------+
   |  Search the cache for the concantenated segments.              |
   |  Return the trx name if it is in the cache.                    |
   |                                                                |
   |  If not found in cache, search the linear table (where         |
   |  trx name's will go if collision on the hash table             |
   |  occurs).             			     		    |
   |                                                                |
   |  If not found above then get it from databse                   |
   +----------------------------------------------------------------*/

 -- 4140375 : need to handle case where p_trx_type_id is null
 IF p_trx_type_id is NULL THEN
    return('-99999999');
 ELSE

     /* Bug4400069 : Removed ' org_id IF ' condition and added NVL for org_id below */

    p_concat_segments :=  p_trx_type_id||'@*?'||p_org_id;

    l_hash_value := DBMS_UTILITY.get_hash_value(p_concat_segments,
                                         1000,
                                         25000);
   found := FALSE;
   IF pg_get_hash_name_cache.exists(l_hash_value) THEN
     IF pg_get_hash_name_cache(l_hash_value) = p_concat_segments THEN
        l_trx_name :=  pg_get_hash_id_cache(l_hash_value);
           found := TRUE;

       ELSE     --- collision has occurred
            tab_indx := 1;  -- start at top of linear table and search for match

            WHILE ((tab_indx < 25000) AND (not FOUND))  LOOP
              IF pg_get_line_name_cache(tab_indx) = p_concat_segments THEN
                  l_trx_name := pg_get_line_id_cache(tab_indx);
                    found := TRUE;
              ELSE
                 tab_indx := tab_indx + 1;
              END IF;
            END LOOP;
       END IF;
   END IF;
  IF found THEN
        RETURN(l_trx_name);
  ELSE

     SELECT name
       INTO   l_trx_name
       FROM   ra_cust_trx_types_all
       WHERE  cust_trx_type_id = p_trx_type_id
       AND    NVL(org_id,-99) = NVL(p_org_id,-99);


           IF pg_get_hash_name_cache.exists(l_hash_value) then
              tab_size := tab_size + 1;
              pg_get_line_id_cache(tab_size)           := l_trx_name;
              pg_get_line_name_cache(tab_size)      := p_concat_segments;
           ELSE
              pg_get_hash_id_cache(l_hash_value)   := l_trx_name;
              pg_get_hash_name_cache(l_hash_value)  := p_concat_segments;
              pg_get_line_id_cache(tab_size)       := l_trx_name;
              pg_get_line_name_cache(tab_size)      := p_concat_segments;
           END IF;
          RETURN(l_trx_name);
   END IF;
 END IF;

EXCEPTION
WHEN no_data_found THEN
 return('-99999999');
END get_org_trx_type_details;


-- Bug 4221745
FUNCTION get_rec_trx_type(p_rec_trx_id IN NUMBER,
                          p_detail_type IN VARCHAR2 DEFAULT 'TYPE')
  RETURN VARCHAR2 IS

l_type ar_receivables_trx.type%TYPE;
l_name ar_receivables_trx.name%TYPE;

BEGIN

   select type, name
     into l_type, l_name
     from ar_receivables_trx
    where receivables_trx_id = p_rec_trx_id;

   if p_detail_type = 'TYPE' THEN
      return l_type;
   elsif p_detail_type = 'NAME' THEN
      return l_name;
   else
      return('-99999999');
   end if;

EXCEPTION
WHEN NO_DATA_FOUND THEN
   BEGIN
      select type, name
        into l_type, l_name
        from ar_receivables_trx_all
       where receivables_trx_id = p_rec_trx_id;

      if p_detail_type = 'TYPE' THEN
         return l_type;
      elsif p_detail_type = 'NAME' THEN
         return l_name;
      else
         return('-99999999');
      end if;

   EXCEPTION
   WHEN OTHERS THEN
      return '-99999999';
   END;
WHEN OTHERS THEN
    return '-99999999';
END;

FUNCTION check_BOE_paymeth (p_receipt_method_id IN NUMBER)
  RETURN VARCHAR2 IS

boe_flag     AR_RECEIPT_CLASSES.BILL_OF_EXCHANGE_FLAG%TYPE;

BEGIN
  -- Added the check only for Receipt Classes with the creation method as Automatic
   select decode(rc.creation_method_code,'AUTOMATIC',nvl(rc.bill_of_exchange_flag,'N'),'N')
     into boe_flag
     from ar_receipt_classes rc,
          ar_receipt_methods rm
    where rm.receipt_method_id = p_receipt_method_id
      and rm.receipt_class_id = rc.receipt_class_id;

    RETURN boe_flag;
EXCEPTION
WHEN OTHERS THEN
   RETURN ('N');
END;

/* Bug 4761373 : Transferred from ARTAUTLB.pls
   New function Get_currency_code has been added for the bug 3043128 */

FUNCTION GET_CURRENCY_CODE(p_application_type in varchar2,
                           p_status in varchar2,
                           p_ard_source_type in varchar2,
                           p_cr_currency_code in varchar2,
                           p_inv_currency_code in varchar2) return varchar2 is
l_curr varchar2(5);
Begin

  Select decode(p_application_type, 'CASH',
                         decode(p_status,'APP',
                         decode(substr(p_ard_source_type,1,5),
                        'EXCH_',decode(p_cr_currency_code,
                        arp_global.functional_currency,p_inv_currency_code,
                         p_cr_currency_code),
                        'CURR_',decode(p_cr_currency_code,
                         arp_global.functional_currency,p_inv_currency_Code,
                         p_cr_currency_code),
                        p_inv_currency_code),
                        p_cr_currency_code),
                        'CM',p_inv_currency_code)
  into l_curr from dual;
  return(l_curr);
END GET_CURRENCY_CODE;

END ARPT_SQL_FUNC_UTIL;

/
