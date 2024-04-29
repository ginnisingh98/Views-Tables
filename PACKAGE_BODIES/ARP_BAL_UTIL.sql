--------------------------------------------------------
--  DDL for Package Body ARP_BAL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_BAL_UTIL" AS
/* $Header: ARTUBALB.pls 120.10.12010000.8 2010/03/11 07:19:58 rvelidi ship $ */


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_line_balance                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the uncredited amount of a line.                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_line_id                                 |
 |                    p_extended_amount                                      |
 |                    p_cm_customer_trx_line_id                              |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-SEP-95  Charlie Tomberg     Created                                |
 |     19-FEB-96  Martin Johnson      Added parameter                        |
 |                                      p_cm_customer_trx_line_id            |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_line_balance( p_customer_trx_line_id IN number,
                           p_extended_amount IN number
                             DEFAULT NULL,
                           p_cm_customer_trx_line_id IN
                             number
                             DEFAULT NULL )
                           RETURN NUMBER IS

    l_net_amount       number;
    l_original_amount  number;

BEGIN

    IF    ( p_customer_trx_line_id IS NULL )
    THEN  RETURN( NULL );
    ELSE

         /*--------------------------------------------------------+
          |  Get the original line amount if it was not passed in  |
          +--------------------------------------------------------*/
/*
          IF      ( p_extended_amount IS NULL )
          THEN
                 SELECT extended_amount
                 INTO   l_original_amount
                 FROM   ra_customer_trx_lines
                 WHERE  customer_trx_line_id   = p_customer_trx_line_id;
          ELSE   l_original_amount := p_extended_amount;
          END IF;
*/

	  SELECT DECODE(line_type, 'LINE',
			NVL(gross_extended_amount, extended_amount),
			extended_amount)
	  INTO l_original_amount
          FROM ra_customer_trx_lines
          WHERE customer_trx_line_id = p_customer_trx_line_id;


         /*-----------------------------------------------------+
          |  Get the sum of all credit memos against this line  |
          |                                                     |
          |  If p_cm_customer_trx_line_id is passed, include    |
          |  it's extended_amount in the sum even if the CM     |
          |  is not complete.                                   |
          +-----------------------------------------------------*/
--2858276, added gross extended amount below

          SELECT l_original_amount +
                 NVL(
                       SUM(
                             DECODE(ct.complete_flag,
                                    'N', DECODE(ctl.customer_trx_line_id,
                                                  p_cm_customer_trx_line_id,
                                             nvl(ctl.gross_extended_amount,ctl.extended_amount),
                                                  0 ),
                                      nvl(ctl.gross_extended_amount,ctl.extended_amount)
                                   )
                          ), 0
                    )
          INTO   l_net_amount
          FROM   ra_customer_trx       ct,
                 ra_customer_trx_lines ctl
          WHERE  ctl.previous_customer_trx_line_id   = p_customer_trx_line_id
          AND    ctl.customer_trx_id                 = ct.customer_trx_id;

          RETURN(l_net_amount);

    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    get_line_cm                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the total amount credited against a line                          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_prev_customer_trx_line_id                            |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     19-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_line_cm( p_prev_customer_trx_line_id IN Number)
                           RETURN NUMBER IS

    l_credit_amount  number;

BEGIN

      IF ( p_prev_customer_trx_line_id IS NULL )
      THEN  RETURN( null );
      ELSE

           SELECT NVL(
                        SUM( extended_amount ), 0
                     )
           INTO   l_credit_amount
           FROM   ra_customer_trx_lines
           WHERE  previous_customer_trx_line_id = p_prev_customer_trx_line_id;

           RETURN(l_credit_amount);
      END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;


/*===========================================================================+
 | PROCEDURE                                                                 |
 |    transaction_balances						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines the balances for a transaction				     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id         - identifies the transaction |
 |                    p_open_receivables_flag                                |
 |                    p_exchange_rate                                        |
 |                    p_mode           - Can be 'ALL'  or 'SUMMARY'          |
 |                                     - All balances are returned in ALL    |
 |                                       mode. Only the Txn. original and    |
 |                                       remaining balances are returned     |
 |                                       in SUMMARY mode.                    |
 |                                                                           |
 |                    p_currency_mode  - Can be 'E'(ntered) or 'A'(ll)       |
 |                                     - The base currency amounts are only  |
 |                                       calculated and returned in 'A' mode.|
 |              OUT:                                                         |
 |                    < entered currency balances >                          |
 |                    < base currency balances >                             |
 |                                                                           |
 | NOTES                                                                     |
 |     Rounding errors for the base amounts are corrected in this procedure  |
 |     by putting the rounding error on the line balances. This may not be   |
 |     the same as how the rounding errors are corrected on the actual       |
 |     transaction. Therefore, the base line, tax and freight balances may   |
 |     not be accurate. The totals are always accurate, however.             |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     31-AUG-95  Charlie Tomberg     Created                                |
 |     28-MAR-96  Vikas Mahajan       l_base_total_credit not getting the    |
 |                                    right value                            |
 |     12-JAN-98  Debbie Jancis       l_base_total_credit not being converted|
 |                                    to functional amount.  Bug 508560      |
 |                                                                           |
 |     06-OCT-98 Sai Rangarajan       Bug Fix 729221 , credit amounts        |
 |                                    get null values when entered currency  |
 |                                    is the functional currency             |
 |     07-Jan-02 Debbie Jancis	      Fixed Bug 1373449: Separate adjustments|
 |				      into adjustments and assignments       |
 |     19-APR-02  Amit Bhati          Bug 2319665: This is an extension to   |
 |				      the fix for bug 2013601. The accounted |
 |                                    amount adjusted for different type of  |
 |                                    adjustments is now calculated from     |
 |                                    total accounted amount adjusted under  |
 |                                    some condition.                        |
 +===========================================================================*/


PROCEDURE transaction_balances(
                              p_customer_trx_id             IN Number,
                              p_open_receivables_flag       IN Varchar2,
                              p_exchange_rate               IN Number,
                              p_mode                        IN VARCHAR2,
                              p_currency_mode               IN VARCHAR2,
                              p_line_original              OUT NOCOPY NUMBER,
                              p_line_remaining             OUT NOCOPY NUMBER,
                              p_tax_original               OUT NOCOPY NUMBER,
                              p_tax_remaining              OUT NOCOPY NUMBER,
                              p_freight_original           OUT NOCOPY NUMBER,
                              p_freight_remaining          OUT NOCOPY NUMBER,
                              p_charges_original           OUT NOCOPY NUMBER,
                              p_charges_remaining          OUT NOCOPY NUMBER,
                              p_line_discount              OUT NOCOPY NUMBER,
                              p_tax_discount               OUT NOCOPY NUMBER,
                              p_freight_discount           OUT NOCOPY NUMBER,
                              p_charges_discount           OUT NOCOPY NUMBER,
                              p_total_discount             OUT NOCOPY NUMBER,
                              p_total_original             OUT NOCOPY NUMBER,
                              p_total_remaining            OUT NOCOPY NUMBER,
                              p_line_receipts              OUT NOCOPY NUMBER,
                              p_tax_receipts               OUT NOCOPY NUMBER,
                              p_freight_receipts           OUT NOCOPY NUMBER,
                              p_charges_receipts           OUT NOCOPY NUMBER,
                              p_total_receipts             OUT NOCOPY NUMBER,
                              p_line_credits               OUT NOCOPY NUMBER,
                              p_tax_credits                OUT NOCOPY NUMBER,
                              p_freight_credits            OUT NOCOPY NUMBER,
                              p_total_credits              OUT NOCOPY NUMBER,
                              p_line_adjustments           OUT NOCOPY NUMBER,
                              p_tax_adjustments            OUT NOCOPY NUMBER,
                              p_freight_adjustments        OUT NOCOPY NUMBER,
                              p_charges_adjustments        OUT NOCOPY NUMBER,
                              p_total_adjustments          OUT NOCOPY NUMBER,
                              p_aline_adjustments          OUT NOCOPY NUMBER,
                              p_atax_adjustments           OUT NOCOPY NUMBER,
                              p_afreight_adjustments       OUT NOCOPY NUMBER,
                              p_acharges_adjustments       OUT NOCOPY NUMBER,
                              p_atotal_adjustments         OUT NOCOPY NUMBER,
                              p_base_line_original         OUT NOCOPY NUMBER,
                              p_base_line_remaining        OUT NOCOPY NUMBER,
                              p_base_tax_original          OUT NOCOPY NUMBER,
                              p_base_tax_remaining         OUT NOCOPY NUMBER,
                              p_base_freight_original      OUT NOCOPY NUMBER,
                              p_base_freight_remaining     OUT NOCOPY NUMBER,
                              p_base_charges_original      OUT NOCOPY NUMBER,
                              p_base_charges_remaining     OUT NOCOPY NUMBER,
                              p_base_line_discount         OUT NOCOPY NUMBER,
                              p_base_tax_discount          OUT NOCOPY NUMBER,
                              p_base_freight_discount      OUT NOCOPY NUMBER,
                              p_base_total_discount        OUT NOCOPY NUMBER,
                              p_base_total_original        OUT NOCOPY NUMBER,
                              p_base_total_remaining       OUT NOCOPY NUMBER,
                              p_base_line_receipts         OUT NOCOPY NUMBER,
                              p_base_tax_receipts          OUT NOCOPY NUMBER,
                              p_base_freight_receipts      OUT NOCOPY NUMBER,
                              p_base_charges_receipts      OUT NOCOPY NUMBER,
                              p_base_total_receipts        OUT NOCOPY NUMBER,
                              p_base_line_credits          OUT NOCOPY NUMBER,
                              p_base_tax_credits           OUT NOCOPY NUMBER,
                              p_base_freight_credits       OUT NOCOPY NUMBER,
                              p_base_total_credits         OUT NOCOPY NUMBER,
                              p_base_line_adjustments      OUT NOCOPY NUMBER,
                              p_base_tax_adjustments       OUT NOCOPY NUMBER,
                              p_base_freight_adjustments   OUT NOCOPY NUMBER,
                              p_base_charges_adjustments   OUT NOCOPY NUMBER,
                              p_base_total_adjustments     OUT NOCOPY NUMBER,
                              p_base_aline_adjustments     OUT NOCOPY NUMBER,
                              p_base_atax_adjustments      OUT NOCOPY NUMBER,
                              p_base_afreight_adjustments  OUT NOCOPY NUMBER,
                              p_base_acharges_adjustments  OUT NOCOPY NUMBER,
                              p_base_atotal_adjustments    OUT NOCOPY NUMBER
                             ) IS

   l_open_receivables_flag  ra_cust_trx_types.accounting_affect_flag%type;
   l_exchange_rate          ra_customer_trx.exchange_rate%type;
   l_base_curr_code         fnd_currencies.currency_code%type;
   l_base_precision         fnd_currencies.precision%type;
   l_base_min_acc_unit      fnd_currencies.minimum_accountable_unit%type;

   l_line_original             NUMBER;
   l_line_remaining            NUMBER;
   l_tax_original              NUMBER;
   l_tax_remaining             NUMBER;
   l_freight_original          NUMBER;
   l_freight_remaining         NUMBER;
   l_charges_original          NUMBER;
   l_charges_remaining         NUMBER;
   l_line_discount             NUMBER;
   l_tax_discount              NUMBER;
   l_freight_discount          NUMBER;
   l_charges_discount          NUMBER;
   l_total_discount            NUMBER;
   l_total_original            NUMBER;
   l_total_remaining           NUMBER;
   l_line_receipts             NUMBER;
   l_tax_receipts              NUMBER;
   l_freight_receipts          NUMBER;
   l_charges_receipts          NUMBER;
   l_total_receipts            NUMBER;
   l_line_edreceipts           NUMBER;
   l_line_uedreceipts          NUMBER;
   l_tax_edreceipts            NUMBER;
   l_tax_uedreceipts           NUMBER;
   l_freight_edreceipts        NUMBER;
   l_freight_uedreceipts       NUMBER;
   l_charges_edreceipts        NUMBER;
   l_charges_uedreceipts       NUMBER;
   l_line_credits              NUMBER;
   l_tax_credits               NUMBER;
   l_freight_credits           NUMBER;
   l_total_credits             NUMBER;
   l_line_adjustments          NUMBER;
   l_tax_adjustments           NUMBER;
   l_freight_adjustments       NUMBER;
   l_charges_adjustments       NUMBER;
   l_total_adjustments         NUMBER;

   /* added for Bug 1373449 */
   l_aline_adjustments         NUMBER;    /* ASSIGNMENT ADJUSTMENTS */
   l_atax_adjustments          NUMBER;
   l_afreight_adjustments      NUMBER;
   l_acharges_adjustments      NUMBER;
   l_atotal_adjustments        NUMBER;

   l_base_line_original        NUMBER;
   l_base_line_remaining       NUMBER;
   l_base_tax_original         NUMBER;
   l_base_tax_remaining        NUMBER;
   l_base_freight_original     NUMBER;
   l_base_freight_remaining    NUMBER;
   l_base_charges_original     NUMBER;
   l_base_charges_remaining    NUMBER;
   l_base_line_discount        NUMBER;
   l_base_tax_discount         NUMBER;
   l_base_freight_discount     NUMBER;
   l_base_charges_discount     NUMBER;
   l_base_total_discount       NUMBER;
   l_base_total_original       NUMBER;
   l_base_total_remaining      NUMBER;
   l_base_line_receipts        NUMBER;
   l_base_tax_receipts         NUMBER;
   l_base_freight_receipts     NUMBER;
   l_base_charges_receipts     NUMBER;
   l_base_total_receipts       NUMBER;
   l_base_line_credits         NUMBER;
   l_base_tax_credits          NUMBER;
   l_base_freight_credits      NUMBER;
   l_base_total_credits        NUMBER;
   l_base_line_adjustments     NUMBER;
   l_base_tax_adjustments      NUMBER;
   l_base_freight_adjustments  NUMBER;
   l_base_charges_adjustments  NUMBER;
   l_base_total_adjustments    NUMBER;

   /* added for Bug 1373449 */
   l_base_aline_adjustments     NUMBER;    /* BASE ASSIGNMENTS (ADJ) */
   l_base_atax_adjustments      NUMBER;
   l_base_afreight_adjustments  NUMBER;
   l_base_acharges_adjustments  NUMBER;
   l_base_atotal_adjustments    NUMBER;

-- Bug 931292
   l_base_total_credits1       NUMBER;
   l_base_total_credits2       NUMBER;
   l_line_credits1             NUMBER;
   l_tax_credits1              NUMBER;
   l_freight_credits1          NUMBER;
   l_line_credits2             NUMBER;
   l_tax_credits2              NUMBER;
   l_freight_credits2          NUMBER;
   l_line_act_credits          NUMBER;
   l_tax_act_credits           NUMBER;
   l_freight_act_credits       NUMBER;

   l_trx_type                  ra_cust_trx_types.type%TYPE; /* 07-AUG-2000 J Rautiainen BR Implementation */
   /*Bug 2319665*/
   l_run_adj_tot	       NUMBER;
   l_base_run_adj_tot	       NUMBER;

   /*3374248*/
   l_new_line_acctd_amt	       NUMBER;
   l_new_frt_acctd_amt	       NUMBER;
   l_new_chrg_acctd_amt        NUMBER;
   l_new_tax_acctd_amt          NUMBER;
   l_cm_refunds			NUMBER;
   /*9453136*/
   l_previous_customer_trx_id  NUMBER;
BEGIN
arp_standard.debug('ARP_BAL_UTIL.Transaction_Balances (+)');
  /*---------------------------------------------------+
   |  Get the Open Receivable Flag and Exchange Rate   |
   |  if either was not provided.                      |
   +---------------------------------------------------*/

   IF    ( p_open_receivables_flag IS NULL  OR
           (
             p_exchange_rate       IS NULL  AND
             p_currency_mode <> 'E'
           )
         )
   THEN
         /* 07-AUG-2000 J Rautiainen BR Implementation
          * Need to know the transaction type since
          * the accounting is stored in ar_distributions
          * instead of ra_cust_trx_line_gl_dist for BR */
         SELECT ctt.accounting_affect_flag,
                ct.exchange_rate,
                ctt.type
         INTO   l_open_receivables_flag,
                l_exchange_rate,
                l_trx_type
         FROM   ra_cust_trx_types ctt,
                ra_customer_trx ct
         WHERE  ct.cust_trx_type_id = ctt.cust_trx_type_id
         AND    ct.customer_trx_id  = p_customer_trx_id;
   ELSE
         /* 07-AUG-2000 J Rautiainen BR Implementation
          * Need to know the transaction type since
          * the accounting is stored in ar_distributions
          * instead of ra_cust_trx_line_gl_dist for BR */
         SELECT ctt.type
         INTO   l_trx_type
         FROM   ra_cust_trx_types ctt,
                ra_customer_trx ct
         WHERE  ct.cust_trx_type_id = ctt.cust_trx_type_id
         AND    ct.customer_trx_id  = p_customer_trx_id;

         l_open_receivables_flag := p_open_receivables_flag;
         l_exchange_rate         := p_exchange_rate;
   END IF;

  /*-------------------------------------------------------+
   |  Get the base currency and exchange rate information  |
   +-------------------------------------------------------*/
--bug7025523
   SELECT sob.currency_code,
          precision,
          minimum_accountable_unit
   INTO   l_base_curr_code,
          l_base_precision,
          l_base_min_acc_unit
   FROM   fnd_currencies        fc,
          gl_sets_of_books      sob
   WHERE  sob.set_of_books_id   = arp_global.set_of_books_id
   AND    sob.currency_code     = fc.currency_code;

  /*-----------------------------------------+
   |  Get the credit memo accounted amount   |
   +-----------------------------------------*/

   IF    ( p_currency_mode <> 'E' ) AND
         (
            p_mode = 'ALL'  OR
            p_open_receivables_flag = 'N'    -- needed to calc balance
         )
   THEN
         IF   ( nvl(l_exchange_rate, 1) <> 1 )
             /* 08-AUG-2000 J Rautiainen BR Implementation */
             AND (NVL(l_trx_type,'INV') <> 'BR')
         THEN
   -- for regular CM applied on the invoice
/*  bug2324069 added nvl */
              SELECT nvl(SUM( acctd_amount ),0)
              INTO   l_base_total_credits1
              FROM   ra_cust_trx_line_gl_dist  lgd,
                     ra_customer_trx           ct
              WHERE  ct.customer_trx_id            = lgd.customer_trx_id
              AND    lgd.account_class             = 'REC'
              AND    lgd.latest_rec_flag           = 'Y'
              AND    ct.previous_customer_trx_id   = p_customer_trx_id;

    -- get the on-account credit applied on the transaction
    -- Fix for bug 931292
              select nvl(sum(rec.acctd_amount_applied_from),0)*(-1)
              into l_base_total_credits2
              from ar_receivable_applications rec,
                   ra_customer_trx trx
               where rec.applied_customer_trx_id = p_customer_trx_id
                 and rec.customer_trx_id = trx.customer_trx_id
                 and rec.status = 'APP'
                 and rec.application_type = 'CM'
                 and trx.previous_customer_trx_id is null;

          l_base_total_credits := NVL(l_base_total_credits1,0) +
                                  NVL(l_base_total_credits2,0);
         END IF;

   END IF;

  /*------------------------------------------------------------------+
   |  IF    the transaction is Open Receivable = Yes,                 |
   |  THEN  get the transaction balances from the payment schedules   |
   |  ELSE  get the original and uncredited amounts from the lines    |
   +------------------------------------------------------------------*/

   IF ( l_open_receivables_flag = 'Y' )
   THEN
         SELECT SUM( NVL( amount_line_items_original, 0 ) ),
                SUM( NVL( amount_line_items_remaining, 0 ) ),
                SUM( NVL( tax_original, 0 ) ),
                SUM( NVL( tax_remaining, 0 ) ),
                SUM( NVL( freight_original, 0 ) ),
                SUM( NVL( freight_remaining, 0 ) ),
                SUM( NVL( receivables_charges_charged, 0 ) ),
                SUM( NVL( receivables_charges_remaining, 0 ) ),
                SUM( NVL( amount_due_original, 0 ) ),
                SUM( NVL( amount_due_remaining, 0 ) ),
                DECODE(
                         p_currency_mode,
                        'E', null,
                             SUM( NVL( acctd_amount_due_remaining, 0 ) )
                      ),
                DECODE(
                         p_mode,
                         'ALL', SUM( NVL( amount_applied, 0 ) ),
                                null
                      ),
                DECODE(
                         p_mode,
                         'ALL', SUM( NVL( amount_credited, 0 ) ),
                                null
                      )
       --         DECODE(
       --                  p_mode,
       --                  'ALL', SUM( NVL( amount_adjusted, 0 ) ),
       --                         null
       --               )
         INTO
                l_line_original,
                l_line_remaining,
                l_tax_original,
                l_tax_remaining,
                l_freight_original,
                l_freight_remaining,
                l_charges_original,
                l_charges_remaining,
                l_total_original,
                l_total_remaining,
                l_base_total_remaining,
                l_total_receipts,
                l_total_credits
            --    l_total_adjustments
         FROM   ar_payment_schedules ps
         WHERE  ps.customer_trx_id   = p_customer_trx_id;

         /* 08-AUG-2000 J Rautiainen BR Implementation
          * Bills Receivable transaction does not have accounting in ra_cust_trx_gl_dist table */

         IF (NVL(l_trx_type,'INV') = 'BR') THEN

           SELECT DECODE(
                         p_currency_mode,
                        'E', null,
                         MAX( dist.acctd_amount_dr )
                      )
           INTO   l_base_total_original
           FROM   ar_transaction_history trh,
                  ar_distributions       dist
           WHERE  trh.customer_trx_id           = p_customer_trx_id
           AND    trh.first_posted_record_flag  = 'Y'
           AND    dist.source_id                = trh.transaction_history_id
           AND    dist.source_table             = 'TH'
           AND    dist.source_type              = 'REC'
           AND    dist.source_type_secondary    IS NULL
           AND    dist.source_id_secondary      IS NULL
           AND    dist.source_table_secondary   IS NULL;

         ELSE

           SELECT DECODE(
                         p_currency_mode,
                        'E', null,
                             MAX( lgd.acctd_amount )
                      )
           INTO   l_base_total_original
           FROM   ra_cust_trx_line_gl_dist lgd
           WHERE  lgd.customer_trx_id  = p_customer_trx_id
           AND    lgd.account_class    = 'REC'
           AND    lgd.latest_rec_flag  = 'Y';

         END IF;

        /*---------------------------------------------------+
         |  If all amounts are required,                     |
         |  get the receipt, credit and adjustment amounts   |
         +---------------------------------------------------*/

         IF ( p_mode = 'ALL' )
         THEN

            /*-------------------------------+
             |  Determine the credit amounts |
             +-------------------------------*/

            /* 08-AUG-2000 J Rautiainen BR Implementation
             * No impact for BR since no credit memoes exist against BR */
             SELECT SUM(
                           DECODE(
                                   ct.complete_flag,
                                   'N', 0,
                                        DECODE(
                                                 ctl.line_type,
                                                 'TAX',     0,
                                                 'FREIGHT', 0,
                                                            ctl.extended_amount
                                               )
                                 )
                       ),                               -- line_credited
                    SUM(
                           DECODE(
                                   ct.complete_flag,
                                   'N', 0,
                                        DECODE(
                                                 ctl.line_type,
                                                 'TAX',   ctl.extended_amount,
                                                          0
                                               )
                                 )
                       ),                               -- tax_credited
                    SUM(
                           DECODE(
                                   ct.complete_flag,
                                   'N', 0,
                                        DECODE(
                                                ctl.line_type,
                                                'FREIGHT', ctl.extended_amount,
                                                           0
                                               )
                                 )
                       )                                -- freight_credited
             INTO   l_line_credits1,
                    l_tax_credits1,
                    l_freight_credits1
             FROM   ra_customer_trx_lines    ctl,
                    ra_cust_trx_line_gl_dist rec,
                    ra_customer_trx          ct
             WHERE  ct.customer_trx_id           = ctl.customer_trx_id
             AND    ct.customer_trx_id           = rec.customer_trx_id
             AND    rec.account_class            = 'REC'
             AND    rec.latest_rec_flag          = 'Y'
             AND    ct.previous_customer_trx_id  = p_customer_trx_id;

    -- get the on-account credit applied on the transaction
    -- Fix for bug 931292
              select nvl(sum(rec.line_applied),0)*(-1),
                     nvl(sum(rec.tax_applied),0)*(-1),
                     nvl(sum(rec.freight_applied),0)*(-1)
              into  l_line_credits2,
                    l_tax_credits2,
                    l_freight_credits2
              from ar_receivable_applications rec,
                   ra_customer_trx trx
               where rec.applied_customer_trx_id = p_customer_trx_id
                 and rec.customer_trx_id = trx.customer_trx_id
                 and rec.status = 'APP'
                 and rec.application_type = 'CM'
                 and trx.previous_customer_trx_id is null;

       /* Bug 4112494 CM refund total */
              SELECT NVL(SUM(DECODE(rec.line_applied,null,rec.amount_applied,0)),0),
	             NVL(SUM(NVL(rec.line_applied,rec.amount_applied)),0),
                     NVL(SUM(rec.tax_applied),0),
                     NVL(SUM(rec.freight_applied),0)
              into  l_cm_refunds,
	            l_line_act_credits,
                    l_tax_act_credits,
                    l_freight_act_credits
              FROM   ar_receivable_applications rec
              WHERE  rec.customer_trx_id = p_customer_trx_id
	      AND    rec.status = 'ACTIVITY';


          l_line_credits := NVL(l_line_credits1,0) +
                                  NVL(l_line_credits2,0) +
				  NVL(l_line_act_credits,0);

          l_tax_credits := NVL(l_tax_credits1,0) +
                                  NVL(l_tax_credits2,0) +
				  NVL(l_tax_act_credits,0);

          l_freight_credits := NVL(l_freight_credits1,0) +
                                  NVL(l_freight_credits2,0) +
				  NVL(l_freight_act_credits,0);

            /*-----------------------------------+
             |  Determine the adjustment amounts |
             +-----------------------------------*/

             /* Bug 1373449: don't include assignments in amount */
             SELECT SUM( NVL( line_adjusted, 0) ),
                    SUM( NVL( tax_adjusted, 0) ),
                    SUM( NVL( freight_adjusted, 0) ),
                    SUM( NVL( receivables_charges_adjusted, 0) ),
                    DECODE(
                             p_currency_mode,
                            'E', null,
                                 SUM( acctd_amount )
                          ),
                    SUM(NVL(amount,0))
		    /*3374248*/
		    ,SUM(DECODE(type,'LINE',NVL(acctd_amount,0),0))
		    ,SUM(DECODE(type,'FREIGHT',NVL(acctd_amount,0),0))
		    ,SUM(DECODE(type,'CHARGES',NVL(acctd_amount,0),0))
		    ,SUM(DECODE(type,'TAX',NVL(acctd_amount,0),0))
             INTO   l_line_adjustments,
                    l_tax_adjustments,
                    l_freight_adjustments,
                    l_charges_adjustments,
                    l_base_total_adjustments,
                    l_total_adjustments
		    /*3374248*/
		    ,l_new_line_acctd_amt
		    ,l_new_frt_acctd_amt
		    ,l_new_chrg_acctd_amt
		    ,l_new_tax_acctd_amt
             FROM   ar_adjustments
             WHERE  customer_trx_id = p_customer_trx_id
             AND    status = 'A'
             AND    receivables_trx_id <> -15;

            /*-----------------------------------+
             |  Bug 1373449:                     |
             |  Determine the assignment amounts |
             +-----------------------------------*/

             SELECT SUM( NVL( line_adjusted, 0) ),
                    SUM( NVL( tax_adjusted, 0) ),
                    SUM( NVL( freight_adjusted, 0) ),
                    SUM( NVL( receivables_charges_adjusted, 0) ),
                    DECODE(
                             p_currency_mode,
                            'E', null,
                                 SUM( acctd_amount )
                          ),
                    SUM(NVL(amount,0))
             INTO   l_aline_adjustments,
                    l_atax_adjustments,
                    l_afreight_adjustments,
                    l_acharges_adjustments,
                    l_base_atotal_adjustments,
                    l_atotal_adjustments
             FROM   ar_adjustments
             WHERE  customer_trx_id = p_customer_trx_id
             AND    status = 'A'
             AND    receivables_trx_id = -15;


            /*--------------------------------+
             |  Determine the receipt amounts |
             +--------------------------------*/

             SELECT SUM( NVL( line_applied, 0 )),
                    SUM( NVL( tax_applied, 0 )),
                    SUM( NVL( freight_applied, 0 )),
                    SUM( NVL( receivables_charges_applied, 0 )),
                    SUM( NVL( amount_applied, 0 )),
                    SUM( NVL( line_ediscounted, 0)),
                    SUM( NVL( line_uediscounted, 0)),
                    SUM( NVL( tax_ediscounted, 0)),
                    SUM( NVL( tax_uediscounted, 0)),
                    SUM( NVL( freight_ediscounted, 0)),
                    SUM( NVL( freight_uediscounted, 0)),
                    SUM( NVL( charges_ediscounted, 0)),
                    SUM( NVL( charges_uediscounted, 0)),
                    DECODE(
                             p_currency_mode,
                            'E', null,
                                 SUM( NVL( acctd_amount_applied_to, 0 ))
                          ),
                    SUM(
                         NVL( earned_discount_taken,   0)  +
                         NVL( unearned_discount_taken, 0 )
                       ),
                    DECODE(
                             p_currency_mode,
                            'E', null,
                                 SUM(
                                      NVL( acctd_earned_discount_taken,   0)  +
                                      NVL( acctd_unearned_discount_taken, 0 )
                                    )
                          )
             INTO   l_line_receipts,
                    l_tax_receipts,
                    l_freight_receipts,
                    l_charges_receipts,
                    l_total_receipts,
                    l_line_edreceipts,
                    l_line_uedreceipts,
                    l_tax_edreceipts,
                    l_tax_uedreceipts,
                    l_freight_edreceipts,
                    l_freight_uedreceipts,
                    l_charges_edreceipts,
                    l_charges_uedreceipts,
                    l_base_total_receipts,
                    l_total_discount,
                    l_base_total_discount
             FROM   ar_receivable_applications
             WHERE  applied_customer_trx_id   = p_customer_trx_id
             AND    application_type          = 'CASH'
             AND    NVL( confirmed_flag, 'Y' ) = 'Y';

         END IF;  -- End ALL mode


   ELSE    -- Open Receivables No case
        /* 08-AUG-2000 J Rautiainen BR Implementation
         * No impact for BR since the open receivable flag is always Y BR */
         SELECT SUM(
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   DECODE(  -- only use the original lines
                                            ctl.customer_trx_line_id,
                                            orig_ctl.customer_trx_line_id,
                                                    orig_ctl.extended_amount,
                                                    0
                                         )
                           )
                   ),                            -- total original
                SUM(
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                              ctl.extended_amount
                           )
                   ),                           -- total remaining
                SUM(
                     DECODE(   -- only use LINE, CHARGES + CB lines
                              ctl.line_type,
                              'TAX',     0,
                              'FREIGHT', 0,
                                         1
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   DECODE(
                                            ctl.customer_trx_line_id,
                                            orig_ctl.customer_trx_line_id,
                                                   orig_ctl.extended_amount,
                                                   0
                                         )
                           )
                   ),                           -- line original
                SUM(
                     DECODE(
                              ctl.line_type,
                              'TAX',     0,
                              'FREIGHT', 0,
                                         1
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   ctl.extended_amount
                           )
                   ),                          -- line remaining
                SUM(
                     DECODE(   -- only use TAX lines
                             ctl.line_type,
                            'TAX', 1,
                                   0
                           ) *
                     DECODE(
                             ct.complete_flag,
                             'N', 0,
                                  DECODE(
                                          ctl.customer_trx_line_id,
                                          orig_ctl.customer_trx_line_id,
                                                  orig_ctl.extended_amount,
                                                  0
                                        )
                           )
                   ),                          -- tax original
                SUM(
                     DECODE(
                              ctl.line_type,
                              'TAX', 1,
                                     0
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   ctl.extended_amount
                           )
                   ),                          -- tax remaining
                SUM(
                     DECODE(   -- only use FREIGHT lines
                             ctl.line_type,
                            'FREIGHT', 1,
                                       0
                           ) *
                     DECODE(
                             ct.complete_flag,
                             'N', 0,
                                  DECODE(
                                          ctl.customer_trx_line_id,
                                          orig_ctl.customer_trx_line_id,
                                                  orig_ctl.extended_amount,
                                                  0
                                        )
                           )
                   ),                          -- freight original
                SUM(
                     DECODE(
                              ctl.line_type,
                              'FREIGHT', 1,
                                         0
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   ctl.extended_amount
                           )
                   ),                          -- freight remaining
                SUM(
                     DECODE(  -- Only get credits in ALL mode
                              p_mode, 'ALL',
                                      1,
                                      null
                           ) *
                     DECODE(   -- only use LINE, CHARGES + CB lines
                              ctl.line_type,
                              'TAX',     0,
                              'FREIGHT', 0,
                                         1
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   DECODE(
                                            ctl.customer_trx_line_id,
                                            orig_ctl.customer_trx_line_id,
                                                   0,
                                                   ctl.extended_amount
                                         )
                           )
                   ),                           -- line credits
                SUM(
                     DECODE(  -- Only get credits in ALL mode
                              p_mode, 'ALL',
                                      1,
                                      null
                           ) *
                     DECODE(   -- only use TAX lines
                              ctl.line_type,
                              'TAX',  1,
                                      0
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   DECODE(
                                            ctl.customer_trx_line_id,
                                            orig_ctl.customer_trx_line_id,
                                                   0,
                                                   ctl.extended_amount
                                         )
                           )
                   ),                           -- tax credits
                SUM(
                     DECODE(  -- Only get credits in ALL mode
                              p_mode, 'ALL',
                                      1,
                                      null
                           ) *
                     DECODE(   -- only use FREIGHT lines
                              ctl.line_type,
                              'FREIGHT',   1,
                                           0
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   DECODE(
                                            ctl.customer_trx_line_id,
                                            orig_ctl.customer_trx_line_id,
                                                   0,
                                                   ctl.extended_amount
                                         )
                           )
                   ),                           -- freight credits
                SUM(
                     DECODE(  -- Only get credits in ALL mode
                              p_mode, 'ALL',
                                      1,
                                      null
                           ) *
                     DECODE(
                              ct.complete_flag,
                              'N', 0,
                                   DECODE(  -- only use the credit lines
                                            ctl.customer_trx_line_id,
                                            orig_ctl.customer_trx_line_id,
                                                    0,
                                                    ctl.extended_amount
                                         )
                           )
                   ),                            -- total credits
                   DECODE(
                            p_currency_mode,
                           'E', null,
                                max( lgd.acctd_amount )
                         )                       -- total base amount
         INTO   l_total_original,
                l_total_remaining,
                l_line_original,
                l_line_remaining,
                l_tax_original,
                l_tax_remaining,
                l_freight_original,
                l_freight_remaining,
                l_line_credits,
                l_tax_credits,
                l_freight_credits,
                l_total_credits,
                l_base_total_original
         FROM   ra_cust_trx_line_gl_dist  lgd,
                ra_customer_trx_lines     orig_ctl,
                ra_customer_trx_lines     ctl,
                ra_customer_trx           ct
         WHERE  (
                  ctl.customer_trx_line_id     = orig_ctl.customer_trx_line_id
                 OR
                  ctl.previous_customer_trx_line_id
                                               = orig_ctl.customer_trx_line_id
                )
         AND    ctl.customer_trx_id      = ct.customer_trx_id
         AND    orig_ctl.customer_trx_id = lgd.customer_trx_id
         AND    lgd.account_class        = 'REC'
         AND    lgd.latest_rec_flag      = 'Y'
         AND    orig_ctl.customer_trx_id = p_customer_trx_id;

/*  bug2324069 added nvl */
         l_base_total_remaining := nvl(l_base_total_original,0) +
                                   nvl(l_base_total_credits,0);

         /* bug 9453136 , set the balance of regular CM to 0, since it will always be 0 */
 	          if NVL(l_trx_type,'INV')='CM' THEN
 	                 select nvl(PREVIOUS_CUSTOMER_TRX_ID,0)  into l_previous_customer_trx_id  from ra_customer_trx where customer_trx_id=p_customer_trx_id;
 	                 IF l_previous_customer_trx_id <> 0 THEN
 	                         l_total_remaining:=0;
 	                         l_line_remaining:=0;
 	                         l_tax_remaining:=0;
 	                         l_freight_remaining:=0;
 	                         l_tax_remaining:=0;
 	                 END IF;
 	         END IF;
 	 /*End bug 9453136 */

   END IF;

   --  l_base_total_credits should remain as entered currency only if
   --  we are not switching to functional currency.  Bug 508560
 /*   if ( p_currency_mode <> 'A') then
      l_base_total_credits :=  l_total_credits;
   end if; */

/* Bug Fix 729221 - Functional Credit amounts disappear when the transaction
   entered currency is the same as base currency ,
   commented out NOCOPY check for p_currency_mode above (for bug fix 508560)
   should be checking for exchange rate instead                        */

      If   ( nvl(l_exchange_rate, 1) = 1 ) then
      l_base_total_credits := l_total_credits;
      end if;

  /*----------------------------------------------------+
   |  Convert the entered amounts to the base currency  |
   |  if the base currency amounts are required         |
   +----------------------------------------------------*/

   IF ( p_currency_mode <> 'E' )
   THEN

       IF    ( l_line_original IS NOT NULL )
       THEN  l_base_line_original	:= arpcurr.functional_amount(
                                                       l_line_original,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);

       END IF;

       /* Bug 4112494 add CM refunds to line balance */
       /* Bug 5877375 added NVL to l_cm_refunds */
       l_line_remaining := l_line_remaining + NVL(l_cm_refunds,0);

       IF    ( l_line_remaining IS NOT NULL )
       THEN  l_base_line_remaining	:= arpcurr.functional_amount(
                                                       l_line_remaining,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;


       IF    ( l_tax_original IS NOT NULL )
       THEN  l_base_tax_original	:= arpcurr.functional_amount(
                                                       l_tax_original,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_tax_remaining IS NOT NULL )
       THEN  l_base_tax_remaining	:= arpcurr.functional_amount(
                                                       l_tax_remaining,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_freight_original IS NOT NULL )
       THEN  l_base_freight_original	:= arpcurr.functional_amount(
                                                       l_freight_original,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_freight_remaining IS NOT NULL )
       THEN  l_base_freight_remaining	:= arpcurr.functional_amount(
                                                       l_freight_remaining,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_charges_original IS NOT NULL )
       THEN  l_base_charges_original	:= arpcurr.functional_amount(
                                                       l_charges_original,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_charges_remaining IS NOT NULL )
       THEN  l_base_charges_remaining	:= arpcurr.functional_amount(
                                                       l_charges_remaining,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;


       IF    ( l_line_receipts IS NOT NULL )
       THEN  l_base_line_receipts	:= arpcurr.functional_amount(
                                                       l_line_receipts,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_tax_receipts IS NOT NULL )
       THEN  l_base_tax_receipts	:= arpcurr.functional_amount(
                                                       l_tax_receipts,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_freight_receipts IS NOT NULL )
       THEN  l_base_freight_receipts	:= arpcurr.functional_amount(
                                                       l_freight_receipts,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_charges_receipts IS NOT NULL )
       THEN  l_base_charges_receipts	:= arpcurr.functional_amount(
                                                       l_charges_receipts,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;


       IF    ( l_line_credits IS NOT NULL )
       THEN  l_base_line_credits	:= arpcurr.functional_amount(
                                                       l_line_credits,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_tax_credits IS NOT NULL )
       THEN  l_base_tax_credits		:= arpcurr.functional_amount(
                                                       l_tax_credits,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_freight_credits IS NOT NULL )
       THEN  l_base_freight_credits	:= arpcurr.functional_amount(
                                                       l_freight_credits,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_line_adjustments IS NOT NULL )
       THEN  l_base_line_adjustments	:= arpcurr.functional_amount(
                                                       l_line_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       /* Bug 1373449 */
       IF    ( l_aline_adjustments IS NOT NULL )
       THEN  l_base_aline_adjustments	:= arpcurr.functional_amount(
                                                       l_aline_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_tax_adjustments IS NOT NULL )
       THEN  l_base_tax_adjustments	:= arpcurr.functional_amount(
                                                       l_tax_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       /* Bug 1373449 */
       IF    ( l_atax_adjustments IS NOT NULL )
       THEN  l_base_atax_adjustments	:= arpcurr.functional_amount(
                                                       l_atax_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_freight_adjustments IS NOT NULL )
       THEN  l_base_freight_adjustments	:= arpcurr.functional_amount(
                                                       l_freight_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       /* Bug 1373449 */
       IF    ( l_afreight_adjustments IS NOT NULL )
       THEN  l_base_afreight_adjustments	:= arpcurr.functional_amount(
                                                       l_afreight_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_charges_adjustments IS NOT NULL )
       THEN  l_base_charges_adjustments	:= arpcurr.functional_amount(
                                                       l_charges_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       /* Bug 1373449 */
       IF    ( l_acharges_adjustments IS NOT NULL )
       THEN  l_base_acharges_adjustments	:= arpcurr.functional_amount(
                                                       l_acharges_adjustments,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

/*Bug 2319665: When different types of accounted amount adjusted are calculated
               by multiplication of amount adjusted with the rate and their sum
	       is not equal to the total accounted amount adjusted then recalculate
	       the values from the total accounted amount adjusted. This is an
	       extension to the fix for bug 2013601.*/

	IF (l_base_total_adjustments <>
                        (l_base_line_adjustments +
                        l_base_tax_adjustments +
                        l_base_freight_adjustments +
                        l_base_charges_adjustments))
		/*Bug3374248*/
		AND NVL(l_total_adjustments,0) <> 0
        THEN
		l_run_adj_tot := 0;
		l_base_run_adj_tot := 0;

                l_run_adj_tot := l_run_adj_tot + l_line_adjustments;
                l_base_line_adjustments := arpcurr.Currround(
                                (l_run_adj_tot/l_total_adjustments)*
                                l_base_total_adjustments ,l_base_curr_code) -
                                l_base_run_adj_tot;
                l_base_run_adj_tot := l_base_run_adj_tot + l_base_line_adjustments;

                l_run_adj_tot := l_run_adj_tot + l_tax_adjustments;
                l_base_tax_adjustments := arpcurr.Currround(
                                (l_run_adj_tot/l_total_adjustments)*
                                l_base_total_adjustments ,l_base_curr_code) -
                                l_base_run_adj_tot;
                l_base_run_adj_tot := l_base_run_adj_tot + l_base_tax_adjustments;

                l_run_adj_tot := l_run_adj_tot + l_freight_adjustments;
                l_base_freight_adjustments := arpcurr.Currround(
                                (l_run_adj_tot/l_total_adjustments)*
                                l_base_total_adjustments ,l_base_curr_code) -
                                l_base_run_adj_tot;
                l_base_run_adj_tot := l_base_run_adj_tot + l_base_freight_adjustments;

                l_run_adj_tot := l_run_adj_tot + l_charges_adjustments;
                l_base_charges_adjustments := arpcurr.Currround(
                                (l_run_adj_tot/l_total_adjustments)*
                                l_base_total_adjustments ,l_base_curr_code) -
                                l_base_run_adj_tot;
                l_base_run_adj_tot := l_base_run_adj_tot + l_base_charges_adjustments;
       /*3374248*/
       ELSIF    (NVL(l_total_adjustments,0) = 0
		AND NVL(l_base_total_adjustments,0) <> 0
		AND (l_base_total_adjustments = l_new_line_acctd_amt +
						l_new_tax_acctd_amt  +
						l_new_frt_acctd_amt  +
						l_new_chrg_acctd_amt))
		THEN
		l_run_adj_tot := 0;
		l_base_run_adj_tot := 0;
		l_base_line_adjustments:=l_new_line_acctd_amt;
		l_base_tax_adjustments:=l_new_tax_acctd_amt;
		l_base_freight_adjustments:=l_new_frt_acctd_amt;
		l_base_charges_adjustments:=l_new_chrg_acctd_amt;
		l_base_run_adj_tot:=l_base_total_adjustments;
       END IF;
/* Bug 2319665 fix ends */

     /*-----------------------------------------------------------------+
      |  Correct rounding errors by putting the difference on the line  |
      +-----------------------------------------------------------------*/

      l_base_line_receipts := l_base_line_receipts +
                              (
                                 l_base_total_receipts -
                                 l_base_line_receipts -
                                 l_base_tax_receipts -
                                 l_base_freight_receipts -
                                 l_base_charges_receipts
                              );

      l_base_line_adjustments := l_base_line_adjustments +
                              (
                                 l_base_total_adjustments -
                                 l_base_line_adjustments -
                                 l_base_tax_adjustments -
                                 l_base_freight_adjustments -
                                 l_base_charges_adjustments
                              );

     /* Bug 1373449 */
     l_base_aline_adjustments := l_base_aline_adjustments +
                              (
                                 l_base_atotal_adjustments -
                                 l_base_aline_adjustments -
                                 l_base_atax_adjustments -
                                 l_base_afreight_adjustments -
                                 l_base_acharges_adjustments
                              );


      l_base_line_credits := l_base_line_credits +
                              (
                                 l_base_total_credits -
                                 l_base_line_credits -
                                 l_base_tax_credits -
                                 l_base_freight_credits
                              );

/*
122958 fbreslin: Remove the charges portion of the Original total calculation
*/
      l_base_line_original := l_base_line_original +
                              (
                                 l_base_total_original -
                                 l_base_line_original -
                                 l_base_tax_original -
                                 l_base_freight_original
                              );

      l_base_line_remaining := l_base_line_remaining +
                              (
                                 l_base_total_remaining -
                                 l_base_line_remaining -
                                 l_base_tax_remaining -
                                 l_base_freight_remaining -
                                 NVL( l_base_charges_remaining, 0 )
                              );

   END IF;  -- not entered mode only case

  /*------------------------------------------------------------------------+
   |  If p_mode <> 'ALL' but the Open Receivable Flag was set to N,         |
   |  the base total credits values was selected in order to determine      |
   |  the base total balance. This value should not be returned,            |
   |  however, since the p_mode <> 'ALL'. Null the value out NOCOPY in this case.  |
   +------------------------------------------------------------------------*/

   IF    ( p_mode <> 'ALL' )
   THEN  l_base_total_credits := null;
   END IF;

  /*----------------------------------------------------------------------+
   |  Calculate discount on line, tax and freight                         |
   |  The discount could have been partially used by receipts             |
   |  The discounted amounts are stored in ra_receivable_applications     |
   +----------------------------------------------------------------------*/

   l_line_discount := l_line_edreceipts + l_line_uedreceipts ;

   l_tax_discount := l_tax_edreceipts + l_tax_uedreceipts ;

   l_freight_discount := l_freight_edreceipts + l_freight_uedreceipts ;

   l_charges_discount := l_charges_edreceipts + l_charges_uedreceipts ;

  /*-----------------------------------------------------+
   |  Convert the discount amounts to the base currency  |
   +-----------------------------------------------------*/

   IF ( p_currency_mode <> 'E' )
   THEN


       IF    ( l_line_discount IS NOT NULL )
       THEN  l_base_line_discount	:= arpcurr.functional_amount(
                                                       l_line_discount,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;


       IF    ( l_tax_discount IS NOT NULL )
       THEN  l_base_tax_discount	:= arpcurr.functional_amount(
                                                       l_tax_discount,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;


       IF    ( l_freight_discount IS NOT NULL )
       THEN  l_base_freight_discount	:= arpcurr.functional_amount(
                                                       l_freight_discount,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;

       IF    ( l_charges_discount IS NOT NULL )
       THEN  l_base_charges_discount	:= arpcurr.functional_amount(
                                                       l_charges_discount,
                                                       l_base_curr_code,
                                                       l_exchange_rate,
                                                       l_base_precision,
                                                       l_base_min_acc_unit);
       END IF;


   END IF;

  /*-----------------------------------------------------------------------+
   |  Copy the local variables to the OUT NOCOPY parameters.                      |
   |  Local variables were used because the values need to be read         |
   |  after they are calculated. I did not use IN/OUT parameters because   |
   |  I want to insure that no old values are passed into this function.   |
   +-----------------------------------------------------------------------*/

   p_line_original		:= l_line_original;
   p_line_remaining		:= l_line_remaining;
   p_tax_original		:= l_tax_original;
   p_tax_remaining		:= l_tax_remaining;
   p_freight_original		:= l_freight_original;
   p_freight_remaining		:= l_freight_remaining;
   p_charges_original		:= l_charges_original;
   p_charges_remaining		:= l_charges_remaining;
   p_line_discount		:= l_line_discount;
   p_tax_discount		:= l_tax_discount;
   p_freight_discount		:= l_freight_discount;
   p_charges_discount		:= l_charges_discount;
   p_total_discount		:= l_total_discount;
   p_total_original		:= l_total_original;
   p_total_remaining		:= l_total_remaining;
   p_line_receipts		:= l_line_receipts;
   p_tax_receipts		:= l_tax_receipts;
   p_freight_receipts		:= l_freight_receipts;
   p_charges_receipts		:= l_charges_receipts;
   p_total_receipts		:= l_total_receipts;
   p_line_credits		:= l_line_credits;
   p_tax_credits		:= l_tax_credits;
   p_freight_credits		:= l_freight_credits;
   p_total_credits		:= l_total_credits;
   p_line_adjustments		:= l_line_adjustments;
   p_tax_adjustments		:= l_tax_adjustments;
   p_freight_adjustments	:= l_freight_adjustments;
   p_charges_adjustments	:= l_charges_adjustments;
   p_total_adjustments		:= l_total_adjustments;

   /* Bug 1373449 */
   p_aline_adjustments		:= l_aline_adjustments;
   p_atax_adjustments		:= l_atax_adjustments;
   p_afreight_adjustments	:= l_afreight_adjustments;
   p_acharges_adjustments	:= l_acharges_adjustments;
   p_atotal_adjustments		:= l_atotal_adjustments;

   p_base_line_original         := l_base_line_original;
   p_base_line_remaining        := l_base_line_remaining;
   p_base_tax_original          := l_base_tax_original;
   p_base_tax_remaining         := l_base_tax_remaining;
   p_base_freight_original      := l_base_freight_original;
   p_base_freight_remaining     := l_base_freight_remaining;
   p_base_charges_original      := l_base_charges_original;
   p_base_charges_remaining     := l_base_charges_remaining;
   p_base_line_discount         := l_base_line_discount;
   p_base_tax_discount          := l_base_tax_discount;
   p_base_freight_discount      := l_base_freight_discount;
   p_base_total_discount        := l_base_total_discount;
   p_base_total_original        := l_base_total_original;
   p_base_total_remaining       := l_base_total_remaining;
   p_base_line_receipts         := l_base_line_receipts;
   p_base_tax_receipts          := l_base_tax_receipts;
   p_base_freight_receipts      := l_base_freight_receipts;
   p_base_charges_receipts      := l_base_charges_receipts;
   p_base_total_receipts        := l_base_total_receipts;
   p_base_line_credits          := l_base_line_credits;
   p_base_tax_credits           := l_base_tax_credits;
   p_base_freight_credits       := l_base_freight_credits;
   p_base_total_credits         := l_base_total_credits;
   p_base_line_adjustments      := l_base_line_adjustments;
   p_base_tax_adjustments       := l_base_tax_adjustments;
   p_base_freight_adjustments   := l_base_freight_adjustments;
   p_base_charges_adjustments   := l_base_charges_adjustments;
   p_base_total_adjustments     := l_base_total_adjustments;

   /* Bug 1373449 */
   p_base_aline_adjustments      := l_base_aline_adjustments;
   p_base_atax_adjustments       := l_base_atax_adjustments;
   p_base_afreight_adjustments   := l_base_afreight_adjustments;
   p_base_acharges_adjustments   := l_base_acharges_adjustments;
   p_base_atotal_adjustments     := l_base_atotal_adjustments;

EXCEPTION
 WHEN OTHERS THEN
   RAISE;
arp_standard.debug('ARP_BAL_UTIL.Transaction_Balances (-)');
END;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    get_summary_trx_balances      	                                     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns the original and remaining balances for a transaction.         |
 |    This procedure does not provide the line type breakdown for credits,   |
 |    adjustments, receipts or discounts. It also does not provide base      |
 |    currency amounts.                                                      |
 |									     |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |		      p_customer_trx_id					     |
 |                    p_open_receivables_flag                                |
 |                    p_exchange_rate                                        |
 |              OUT:                                                         |
 |                    p_line_original                                        |
 |                    p_line_remaining                                       |
 |                    p_tax_original                                         |
 |                    p_tax_remaining                                        |
 |                    p_freight_original                                     |
 |                    p_freight_remaining                                    |
 |                    p_charges_original                                     |
 |                    p_charges_remaining                                    |
 |                    p_total_original                                       |
 |                    p_total_remaining                                      |
 |                                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     05-SEP-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/


PROCEDURE get_summary_trx_balances( p_customer_trx_id       IN Number,
                              p_open_receivables_flag       IN Varchar2,
                              p_line_original              OUT NOCOPY NUMBER,
                              p_line_remaining             OUT NOCOPY NUMBER,
                              p_tax_original               OUT NOCOPY NUMBER,
                              p_tax_remaining              OUT NOCOPY NUMBER,
                              p_freight_original           OUT NOCOPY NUMBER,
                              p_freight_remaining          OUT NOCOPY NUMBER,
                              p_charges_original           OUT NOCOPY NUMBER,
                              p_charges_remaining          OUT NOCOPY NUMBER,
                              p_total_original             OUT NOCOPY NUMBER,
                              p_total_remaining            OUT NOCOPY NUMBER )
                      IS
   l_dummy  NUMBER;


BEGIN

   arp_bal_util.transaction_balances(p_customer_trx_id,
                                     p_open_receivables_flag,
                                     1,
                                    'SUMMARY',
                                    'E',
                                     p_line_original,
                                     p_line_remaining,
                                     p_tax_original,
                                     p_tax_remaining,
                                     p_freight_original,
                                     p_freight_remaining,
                                     p_charges_original,
                                     p_charges_remaining,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     p_total_original,
                                     p_total_remaining,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy,
                                     l_dummy
                             );


EXCEPTION
 WHEN OTHERS THEN
   RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 |    Get_trx_balance                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the balance due for a transaction.                                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_open_receivables_flag                                |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The transaction balance                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     11-DEC-95  Charlie Tomberg     Created                                |
 |                                                                           |
 +===========================================================================*/

FUNCTION get_trx_balance( p_customer_trx_id        IN  Number,
                          p_open_receivables_flag  IN  Varchar2)
                           RETURN NUMBER IS
   l_balance number;
   l_dummy   number;

BEGIN

         IF   (p_customer_trx_id  IS NULL)
         THEN RETURN(NULL);
         ELSE
              arp_bal_util.get_summary_trx_balances( p_customer_trx_id,
                                                     p_open_receivables_flag,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_dummy,
                                                     l_balance);

              RETURN(l_balance);

         END IF;

         EXCEPTION
            WHEN OTHERS THEN RAISE;

END;



/*===========================================================================+
 | FUNCTION                                                                  |
 |    Get_commitment_balance                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the commitment balance for a deposit or Guarantee.                |
 |    This is a cover for calc_commitment_balance().                         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_class                                                |
 |                    p_oe_installed_flag                                    |
 |                    p_so_source_code     - value of profile SO_SOURCE_CODE |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The commitment balance                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-95  Charlie Tomberg     Created                                |
 |     02-FEB-98  Debbie Jancis       Changed the order of the               |
 |                                    p_oe_installed_flag and                |
 |                                    p_so_source_code in the calling seq    |
 |                                    because they were reversed.            |
 +===========================================================================*/

FUNCTION get_commitment_balance( p_customer_trx_id      IN  Number,
                                 p_class                IN  Varchar2,
                                 p_so_source_code       IN  varchar2,
                                 p_oe_installed_flag    IN  varchar2)
                           RETURN NUMBER IS

BEGIN

    RETURN(
             arp_bal_util.calc_commitment_balance( p_customer_trx_id,
                                                   p_class,
                                                   'Y',
                                                   p_oe_installed_flag,
                                                   p_so_source_code )
          );
END;


/*===========================================================================+
 | FUNCTION                                                                  |
 |    calc_commitment_balance                                                |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Gets the commitment balance for a deposit or Guarantee.                |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_class                                                |
 |                    p_include_oe_trx_flag                                  |
 |                    p_oe_installed_flag                                    |
 |                    p_so_source_code     - value of profile SO_SOURCE_CODE |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : The commitment balance                                       |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     10-NOV-95  Charlie Tomberg     Created                                |
 |     12-JAN-01  Michael Raymond     Fixed select over ra_interface_lines
 |                                    table to properly test trx_type
 |                                    for commitment invoices.  OM
 |                                    is using a little-known method where
 |                                    the trx_type is defaulted from the
 |                                    commitment trx_type.
 |                                    See bug 1580737 for details.
 |     11-APR-01  Michael Raymond     Implemented promised_commitment_amount
 |                                    and allocate_tax_freight logic for
 |                                    commitment-related lines in
 |                                    ra_interface_lines table.
 |                                    See bugs 1483656 and 1645425 for details.
 +===========================================================================*/

FUNCTION calc_commitment_balance( p_customer_trx_id      IN  Number,
                                 p_class                IN Varchar2,
                                 p_include_oe_trx_flag  IN  varchar2,
                                 p_oe_installed_flag    IN  varchar2,
                                 p_so_source_code       IN  varchar2 )
                           RETURN NUMBER IS

    l_commitment_bal  number;
    l_commitment_class  ra_cust_trx_types.type%type;
    l_currency_code     fnd_currencies.currency_code%type;
/* 1580737 - holds subsequent_trx_type_id */
    l_sub_inv_trx_type_id  ra_cust_trx_types.subsequent_trx_type_id%type;
/* 1483656 - holds the allocation flag */
    l_allocate_t_f         ra_cust_trx_types.allocate_tax_freight%type;

BEGIN

      IF    (
                  p_customer_trx_id IS NULL
              OR  NVL(p_class, 'DEP')  NOT IN ('DEP', 'GUAR')
            )
      THEN  RETURN( null );
      ELSE

          /*-----------------------------------------------------------+
           |  Get the Commitment Balance and the type of Transaction.  |
           +-----------------------------------------------------------*/

           BEGIN
                 /* 1580737 - added subsequent_trx_type_id */
                 /* modified for tca uptake */
                 SELECT lines.extended_amount,
                        type.type,
                        trx.invoice_currency_code,
                        type.subsequent_trx_type_id,
                        type.allocate_tax_freight
                 INTO   l_commitment_bal,
                        l_commitment_class,
                        l_currency_code,
                        l_sub_inv_trx_type_id,
                        l_allocate_t_f
                 FROM   hz_cust_accounts         cust_acct,
                        ra_customer_trx_lines    lines,
                        ra_customer_trx          trx,
                        ra_cust_trx_types        type
                 WHERE  trx.customer_trx_id      = p_customer_trx_id
                 AND    trx.cust_trx_type_id     = type.cust_trx_type_id
                 AND    trx.customer_trx_id      = lines.customer_trx_id
                 AND    trx.bill_to_customer_id  = cust_acct.cust_account_id
                 AND    type.type                IN ('DEP','GUAR')
                 ORDER BY trx.trx_number;

          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  RETURN( null );
             WHEN OTHERS THEN RAISE;
          END;
          /*-------------------------------------------------------------+
           |  ** If OE is installed and the include_oe_trx_flag          |
           |     is set to true,  get the uninvoiced commitment balance  |
           +-------------------------------------------------------------*/

           IF (
                      p_include_oe_trx_flag  = 'Y'
                 AND  p_oe_installed_flag    = 'I'
              )
           THEN

          /*---------------------------------------------------------------+
           |  ** Get uninvoiced commitment balance and subtract from total |
           |  ** commitment balance                                        |
           +---------------------------------------------------------------*/


                 -- replace OE_ACCOUNTING with OE_Payments_Util
                 SELECT NVL( l_commitment_bal, 0 ) -
			NVL(OE_Payments_Util.Get_Uninvoiced_Commitment_Bal(p_customer_trx_id), 0)
                 INTO   l_commitment_bal
                 FROM   dual;

               /*------------------------------------------------------------+
                |  Include OE transactions that are in the AutoInvoice       |
                |  interface tables and have not yet been transferred to AR. |
                +------------------------------------------------------------*/

                 /* 1580737 - Restructured where clause for
                      better performance and included logic
                      for commitment invoices from OE (null trx_type) */
                 /* 1483656 - Implemented logic for promised_commitment_amt
                      and allocate_tax_freight */

                 SELECT NVL( l_commitment_bal, 0 ) -
                        NVL( SUM(NVL(i.promised_commitment_amount,
                                     i.amount)), 0)
                 INTO   l_commitment_bal
                 FROM   ra_interface_lines    i,
                        ra_customer_trx_lines l
                 WHERE  NVL(interface_status,
                            'A')                <> 'P'
                 AND   (i.line_type              = 'LINE'
                  OR    i.line_type  = DECODE(l_allocate_t_f,'Y','FREIGHT','LINE'))
                 AND    i.reference_line_id      = l.customer_trx_line_id
                 AND    l.customer_trx_id        = p_customer_trx_id
                 AND    i.interface_line_context = p_so_source_code
                 AND    (EXISTS
                         ( select 'valid_trx_type'
                           from ra_cust_trx_types ty
                           where (i.cust_trx_type_name = ty.name OR
                                  i.cust_trx_type_id   = ty.cust_trx_type_id)
                           AND   ty.type = 'INV')
                 OR      (i.cust_trx_type_name is null AND
                          i.cust_trx_type_id is null AND
                          l_sub_inv_trx_type_id is not null));

           END IF;   -- end OE is installed case

          /*-------------------------------------------+
           |  If the commitment type is for a DEPOSIT, |
           |  then add in commitment adjustments       |
           +-------------------------------------------*/

           IF    ( l_commitment_class = 'DEP' )
           THEN

                SELECT NVL( l_commitment_bal, 0)
                           -
                              (
                                 NVL(
                                      SUM( ADJ.AMOUNT),
                                      0
                                    ) * -1
                              )
                INTO   l_commitment_bal
                FROM   ra_customer_trx      trx,
                       ra_cust_trx_types    type,
                       ar_adjustments       adj
                WHERE  trx.cust_trx_type_id         = type.cust_trx_type_id
                AND    trx.initial_customer_trx_id  = p_customer_trx_id
                AND    trx.complete_flag            = 'Y'
                AND    adj.adjustment_type          = 'C'
                AND    type.type                    IN ('INV', 'CM')
                AND    adj.customer_trx_id =
                                     DECODE(type.type,
                                            'INV', trx.customer_trx_id,
                                            'CM', trx.previous_customer_trx_id)
                AND NVL( adj.subsequent_trx_id, -111) =
                                     DECODE(type.type,
                                            'INV', -111,
                                            'CM', trx.customer_trx_id);

               /*-------------------------------------------------------+
                |  Subtract out NOCOPY credit memos against the deposit itself |
                +-------------------------------------------------------*/

                SELECT NVL( l_commitment_bal, 0)
                        -
                       NVL(
                            SUM(
                                 -1 * line.extended_amount
                               ),
                            0
                          )
                INTO   l_commitment_bal
                FROM   ra_customer_trx        trx,
                       ra_customer_trx_lines  line
                WHERE  trx.customer_trx_id           = line.customer_trx_id
                AND    trx.previous_customer_trx_id  = p_customer_trx_id
                AND    trx.complete_flag             = 'Y';

           ELSE    -- Guarantee case

                SELECT NVL( l_commitment_bal, 0) -
                       (
                         NVL(
                              SUM(
                                    amount_line_items_original
                                 ),
                              0
                            ) -
                         NVL(
                              SUM(
                                   amount_due_remaining
                                 ),
                              0
                            )
                       )
                INTO   l_commitment_bal
                FROM   ar_payment_schedules
                WHERE  customer_trx_id = p_customer_trx_id;


               /*------------------------------------------------------------+
                |  We do not want to adjust the commitment balance by the    |
                |  amount of any manual adjustments against the commitment.  |
                |  The following statement backs out NOCOPY these manual            |
                |  adjustments from the commitment balance.                  |
                +------------------------------------------------------------*/

               SELECT NVL( l_commitment_bal, 0) -
                      NVL(
                           SUM( amount ),
                           0
                         )
               INTO   l_commitment_bal
               FROM   ar_adjustments
               WHERE  customer_trx_id  =  p_customer_trx_id
               AND    adjustment_type <> 'C';

           END IF;    -- end Guarantee case


           RETURN(
                    arpcurr.CurrRound(
                                       GREATEST(
                                                  l_commitment_bal,
                                                  0
                                               ),
                                       l_currency_code
                                     )
                 );

      END IF;  -- end processing required case

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END;

/*===========================================================================+
 | FUNCTION                                                                  |
 | DESCRIPTION                                                               |
 |    Gets the Balance for Child of Commitment .                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                    p_mode('E'-Entered ,'F'-Functional)                    |
 |              OUT:                                                         |
 |                    None                                                   |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |     27-JAN-96  Vikas  Mahajan      Created                                |
 |                                                                           |
 |     12-MAR-02  Michael Raymond    Bug 2237126 - Added logic to account    |
 |                                   for changes to commitment applied amount|
 |                                   caused by credit memo applications.     |
 |                                                                           |
 |     18-DEC-03  Pravin Pawar       Bug3252481 - Divided the the SQL into   |
 |                                                3 SQLs , for better        |
 |                                                performance.               |
 |
 |     30-JUN-04  Obaidur Rashid     Bug 3702956 - The previous fix
 |                                                 introduced a bug wherein
 |                                                 if more than one of the
 |                                                 OR condition is TRUE then
 |                                                 the same row will be
 |                                                 returned more than once.
 |                                                 Which results into
 |                                                 displaying wrong amount to
 |                                                 the user. This is corrected
 |                                                 in this fix.
 |
 +===========================================================================*/

FUNCTION get_applied_com_balance( p_customer_trx_id IN Number,
                                  p_mode IN VARCHAR2)
                                 RETURN NUMBER IS


    l_actual_amount       number := 0 ;
    l_acctd_amount        number := 0 ;
    l_actual_amount1      number := 0 ;
    l_acctd_amount1       number := 0 ;

BEGIN
    IF ( p_customer_trx_id IS NULL ) THEN
       RETURN( NULL );
    ELSE

           /* Bug3252481 : Divided main SQL into following 3 SQLs */

            SELECT NVL(SUM(amount),0),
                   NVL(SUM(acctd_amount),0)
            INTO   l_actual_amount1,
                   l_acctd_amount1
            FROM   ra_customer_trx t,
                   ra_cust_trx_types ty,
                   ar_adjustments a
            WHERE t.cust_trx_type_id = ty.cust_trx_type_id
                  and t.customer_trx_id = a.customer_trx_id
                  and ty.type not in ('DEP', 'GUAR')
                  and a.adjustment_type = 'C'
                  and t.customer_trx_id = p_customer_trx_id;

            l_actual_amount := l_actual_amount + l_actual_amount1;
            l_acctd_amount  := l_acctd_amount + l_acctd_amount1;

            SELECT NVL(SUM(amount),0),
                   NVL(SUM(acctd_amount),0)
            INTO   l_actual_amount1,
                   l_acctd_amount1
            FROM   ra_customer_trx t,
                   ra_cust_trx_types ty,
                   ar_adjustments a
            WHERE t.cust_trx_type_id = ty.cust_trx_type_id
                  and t.customer_trx_id = a.subsequent_trx_id
                  and ty.type not in ('DEP', 'GUAR')
                  and a.adjustment_type = 'C'
                  and t.customer_trx_id = p_customer_trx_id;

            l_actual_amount := l_actual_amount + l_actual_amount1;
            l_acctd_amount  := l_acctd_amount + l_acctd_amount1;

            SELECT NVL(SUM(amount),0),
                   NVL(SUM(acctd_amount),0)
            INTO   l_actual_amount1,
                   l_acctd_amount1
            FROM   ra_customer_trx t,
                   ra_cust_trx_types ty,
                   ar_adjustments a
            WHERE t.cust_trx_type_id = ty.cust_trx_type_id
                  and a.subsequent_trx_id IN
                            (select cma.customer_trx_id
                             from   ar_receivable_applications cma
                             where  cma.applied_customer_trx_id =
                                      t.customer_trx_id
                             and    cma.application_type = 'CM')
                  and ty.type not in ('DEP', 'GUAR')
                  and a.adjustment_type = 'C'
                  and t.customer_trx_id = p_customer_trx_id
             -- following was added for Bug # 3702956
             AND adjustment_id NOT IN
             (
                SELECT adjustment_id
                FROM   ar_adjustments aa1
                WHERE  aa1.customer_trx_id = t.customer_trx_id
                AND    aa1.adjustment_type = 'C'
             )
             AND adjustment_id NOT IN
             (
                SELECT adjustment_id
                FROM   ar_adjustments aa2
                WHERE  aa2.subsequent_trx_id = t.customer_trx_id
                AND    aa2.adjustment_type = 'C'
              );


            l_actual_amount := l_actual_amount + l_actual_amount1;
            l_acctd_amount  := l_acctd_amount + l_acctd_amount1;

            /* Bug3252481 End */

            IF (p_mode='E')
            THEN
                return(l_actual_amount);
            ELSIF (p_mode='F')
            THEN
                return(l_acctd_amount);
            ELSE
                return(NULL);
            END IF;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END get_applied_com_balance;

/*===========================================================================+
 | FUNCTION LINE_LEVEL_ACTIVTY                                               |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Returns TRUE if there are line Level applications for this             |
 |    customer_trx_id                                                        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED                                   |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_customer_trx_id                                      |
 |                                                                           |
 | RETURNS    : BOOLEAN                                                      |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 | Date		Name			Modification			     |
 | 02-Aug-2005  Debbie Sue Jancis	Original Coding                      |
 |                                                                           |
 +===========================================================================*/
FUNCTION Line_Level_Activity ( p_customer_trx_id IN Number)
                                 RETURN BOOLEAN IS
 l_count   NUMBER;

BEGIN
   arp_util.debug('Line_Level_Activity()+' );

    Select count(customer_Trx_line_id)
     INTO l_count
    from ar_activity_details
    WHERE customer_trx_line_id in
     (SELECT customer_trx_line_id
       FROM RA_CUSTOMER_TRX_LINES
      WHERE customer_trx_id = p_customer_trx_id)
      and nvl(CURRENT_ACTIVITY_FLAG, 'Y') = 'Y'; -- bug 7241111

   IF ( l_count > 0) THEN
      arp_util.debug('Line_Level_Activity Exists()-' );
      RETURN TRUE;
   ELSE
      arp_util.debug('Line_Level_Activity Does Not Exist()-' );
      RETURN FALSE;
   END IF;

END Line_Level_Activity;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    trx_line_balances                                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Determines the line level balances for a trx Line or Group             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |                                                                           |
 | 03-Aug-2005       Debbie Sue Jancis  	Original                     |
 |                                                                           |
 +===========================================================================*/
 PROCEDURE trx_line_balances (
      p_customer_trx_id
           IN RA_CUSTOMER_TRX.CUSTOMER_TRX_ID%TYPE  DEFAULT NULL,
      p_line_num                  IN         NUMBER DEFAULT NULL,
      p_group_id                  IN         NUMBER DEFAULT NULL,
      p_exchange_rate             IN         NUMBER,
      p_line_original             OUT NOCOPY NUMBER,
      p_tax_original              OUT NOCOPY NUMBER,
      p_base_line_original        OUT NOCOPY NUMBER,
      p_base_tax_original         OUT NOCOPY NUMBER,
      p_total_original            OUT NOCOPY NUMBER,
      p_base_total_original       OUT NOCOPY NUMBER,
      p_line_receipts             OUT NOCOPY NUMBER,
      p_tax_receipts              OUT NOCOPY NUMBER,
      p_line_discount             OUT NOCOPY NUMBER,
      p_tax_discount              OUT NOCOPY NUMBER,
      p_base_line_receipts        OUT NOCOPY NUMBER,
      p_base_tax_receipts         OUT NOCOPY NUMBER,
      p_base_line_discount        OUT NOCOPY NUMBER,
      p_base_tax_discount         OUT NOCOPY NUMBER,
      p_freight_original          OUT NOCOPY NUMBER,
      p_base_freight_original     OUT NOCOPY NUMBER,
      p_freight_receipts          OUT NOCOPY NUMBER,
      p_charges_receipts          OUT NOCOPY NUMBER,
      p_base_charges_receipts     OUT NOCOPY NUMBER,
      p_base_freight_receipts     OUT NOCOPY NUMBER,
      p_freight_discount          OUT NOCOPY NUMBER,
      p_base_freight_discount     OUT NOCOPY NUMBER,
      p_total_receipts            OUT NOCOPY NUMBER,
      p_base_total_receipts       OUT NOCOPY NUMBER,
      p_total_discount            OUT NOCOPY NUMBER,
      p_base_total_discount       OUT NOCOPY NUMBER,
      p_line_remaining            OUT NOCOPY NUMBER,
      p_tax_remaining             OUT NOCOPY NUMBER,
      p_freight_remaining         OUT NOCOPY NUMBER,
      p_charges_remaining         OUT NOCOPY NUMBER,
      p_total_remaining           OUT NOCOPY NUMBER,
      p_base_line_remaining       OUT NOCOPY NUMBER,
      p_base_tax_remaining        OUT NOCOPY NUMBER,
      p_base_freight_remaining    OUT NOCOPY NUMBER,
      p_base_charges_remaining    OUT NOCOPY NUMBER,
      p_base_total_remaining      OUT NOCOPY NUMBER,
      p_line_credits              OUT NOCOPY NUMBER,
      p_tax_credits               OUT NOCOPY NUMBER,
      p_freight_credits           OUT NOCOPY NUMBER,
      p_total_credits             OUT NOCOPY NUMBER,
      p_base_line_credits         OUT NOCOPY NUMBER,
      p_base_tax_credits          OUT NOCOPY NUMBER,
      p_base_freight_credits      OUT NOCOPY NUMBER,
      p_base_total_credits        OUT NOCOPY NUMBER,
      p_line_adjustments          OUT NOCOPY NUMBER,
      p_tax_adjustments           OUT NOCOPY NUMBER,
      p_freight_adjustments       OUT NOCOPY NUMBER,
      p_charges_adjustments       OUT NOCOPY NUMBER,
      p_total_adjustments         OUT NOCOPY NUMBER,
      p_base_line_adjustments     OUT NOCOPY NUMBER,
      p_base_tax_adjustments      OUT NOCOPY NUMBER,
      p_base_freight_adjustments  OUT NOCOPY NUMBER,
      p_base_charges_adjustments  OUT NOCOPY NUMBER,
      p_base_total_adjustments    OUT NOCOPY NUMBER
                             ) IS

   l_line_original             NUMBER;
   l_tax_original              NUMBER;
   l_freight_original          NUMBER;
   l_total_original            NUMBER;

   l_line_receipts             NUMBER;
   l_tax_receipts              NUMBER;
   l_freight_receipts          NUMBER;
   l_charges_receipts          NUMBER;
   l_total_receipts            NUMBER;

   l_line_discount             NUMBER;
   l_tax_discount              NUMBER;
   l_freight_discount          NUMBER;
   l_total_discount            NUMBER;

   l_base_line_original        NUMBER;
   l_base_tax_original         NUMBER;
   l_base_freight_original     NUMBER;
   l_base_total_original       NUMBER;

   l_base_line_receipts        NUMBER;
   l_base_tax_receipts         NUMBER;
   l_base_freight_receipts     NUMBER;
   l_base_charges_receipts     NUMBER;
   l_base_total_receipts       NUMBER;

   l_base_line_discount        NUMBER;
   l_base_tax_discount         NUMBER;
   l_base_freight_discount     NUMBER;
   l_base_total_discount       NUMBER;

   l_line_remaining            NUMBER;
   l_tax_remaining             NUMBER;
   l_freight_remaining         NUMBER;
   l_charges_remaining         NUMBER;
   l_total_remaining           NUMBER;

   l_base_line_remaining       NUMBER;
   l_base_tax_remaining        NUMBER;
   l_base_freight_remaining    NUMBER;
   l_base_charges_remaining    NUMBER;
   l_base_total_remaining      NUMBER;

   l_line_credits              NUMBER;
   l_tax_credits               NUMBER;
   l_freight_credits           NUMBER;
   l_total_credits             NUMBER;
   l_base_line_credits         NUMBER;
   l_base_tax_credits          NUMBER;
   l_base_freight_credits      NUMBER;
   l_base_total_credits        NUMBER;

   l_line_adjustments          NUMBER;
   l_tax_adjustments           NUMBER;
   l_freight_adjustments       NUMBER;
   l_total_adjustments         NUMBER;
   l_base_line_adjustments     NUMBER;
   l_base_tax_adjustments      NUMBER;
   l_base_freight_adjustments  NUMBER;
   l_base_total_adjustments    NUMBER;

   l_base_curr_code            fnd_currencies.currency_code%type;
   l_base_precision            fnd_currencies.precision%type;
   l_base_min_acc_unit         fnd_currencies.minimum_accountable_unit%type;

   l_customer_Trx_line_id      ra_customer_Trx_lines.customer_Trx_line_id%type;
 BEGIN

  /* initialize the items */

   l_line_receipts    :=0;
   l_tax_receipts     :=0;
   l_freight_receipts :=0;
   l_charges_receipts := 0;
   l_total_receipts   := 0;

arp_util.debug('l_tax_receipts = ' || l_tax_receipts);

  /*-------------------------------------------------------+
   |  Get the base currency and exchange rate information  |
   +-------------------------------------------------------*/
--bug7025523
   SELECT sob.currency_code,
          precision,
          minimum_accountable_unit
   INTO   l_base_curr_code,
          l_base_precision,
          l_base_min_acc_unit
   FROM   fnd_currencies        fc,
          gl_sets_of_books      sob
   WHERE  sob.set_of_books_id   = arp_global.set_of_books_id
   AND    sob.currency_code     = fc.currency_code;

  -- derive the balances for LINE number:

   IF (p_line_num IS NOT NULL) THEN

      select customer_Trx_line_id
       into l_customer_trx_line_id
     from ra_customer_Trx_lines
    where line_number = p_line_num
     and line_type = 'LINE'
     and customer_trx_id = p_customer_trx_id;

      -- line original, tax original, freight original (entered currencies)
      select sum(DECODE (lines.line_type,
                   'TAX',0,
                   'FREIGHT',0 , 1) *
                 DECODE(ct.complete_flag, 'N',
                        0, lines.extended_amount)), -- line_original
             sum(DECODE (lines.line_type,
                         'TAX',1,0) *
                 DECODE(ct.complete_flag,
                        'N', 0,
                         lines.extended_amount )) tax_original, -- tax_original
             sum(DECODE (lines.line_type,
                        'FREIGHT', 1,0) *
                  DECODE(ct.complete_flag,
                         'N', 0 ,
                         lines.extended_amount)) -- freight_original
         INTO  l_line_original,
               l_tax_original,
               l_freight_original
        from ra_customer_trx ct,
             ra_customer_trx_lines lines
       where (lines.customer_Trx_line_id = l_customer_trx_line_id or
              lines.link_to_cust_trx_line_id = l_customer_trx_line_id)
         and  ct.customer_Trx_id = lines.customer_trx_id
         and  ct.customer_trx_id = p_customer_trx_id;

     --  Derive line_Receipt in entered and base currencies
--Bug6906707
       SELECT NVL(sum(NVL(amount_cr,0) - NVL(amount_dr,0)),0),
              NVL(sum(NVL(acctd_amount_cr,0) - NVL(acctd_amount_dr,0)),0)
        INTO
           l_line_receipts,
           l_base_line_receipts
        FROM ar_distributions
       WHERE source_table = 'RA'
         AND source_id in (select receivable_application_id
                            from ar_receivable_applications
                           where status = 'APP' and
                           applied_customer_Trx_id = p_customer_trx_id and
                           cash_receipt_id is not null )
         AND ref_customer_trx_line_id = l_customer_trx_line_id
         AND activity_bucket = 'APP_LINE'
         AND ref_account_class = 'REV';

     -- Derive tax_receipt in entered and base currencies
--Bug6906707
       SELECT NVL(sum(NVL(amount_cr,0) - NVL(amount_dr,0)),0),
              NVL(sum(NVL(acctd_amount_cr,0) - NVL(acctd_amount_dr,0)),0)
        INTO
           l_tax_receipts,
           l_base_tax_receipts
        FROM ar_distributions
       WHERE source_table = 'RA'
         AND source_id in (select receivable_application_id
                            from ar_receivable_applications
                           where status = 'APP' and
                           applied_customer_Trx_id = p_customer_trx_id and
                           cash_receipt_id is not null )
         AND tax_link_id = l_customer_trx_line_id
         AND activity_bucket = 'APP_TAX'
         AND ref_account_class = 'TAX';



     -- derive freight_receipt,
     -- line_discount, tax_discount, freight_discount amts
     -- in entered currency
 /*Bug6821893 */    /*Bug6906707*/
       SELECT
              nvl(sum(nvl(charges,0)),0),
              nvl(sum(nvl(freight_discount,0)),0)
         INTO
              l_charges_receipts,
              l_freight_discount
         FROM AR_ACTIVITY_DETAILS act,
              ra_customer_trx_lines line
        WHERE line.customer_Trx_id = p_customer_trx_id
          and  line.line_number = p_line_num
          and  line.line_type = 'LINE'
	  and nvl(act.CURRENT_ACTIVITY_FLAG, 'Y') = 'Y'   -- bug 7241111
          and line.customer_Trx_line_id = act.customer_Trx_line_id;

/*Bug6906707, Start */
       SELECT NVL(sum(NVL(amount_cr,0) - NVL(amount_dr,0)),0),
              NVL(sum(NVL(acctd_amount_cr,0) - NVL(acctd_amount_dr,0)),0)
	INTO
	      l_freight_receipts,
	      l_base_freight_receipts
        FROM ar_distributions ard,
        ra_customer_trx_lines ctl
       WHERE ard.source_table = 'RA'
         AND ard.source_id in (select receivable_application_id
                            from ar_receivable_applications
                           where status = 'APP' and
                           applied_customer_Trx_id = p_customer_trx_id and
                           cash_receipt_id is not null )
         AND ctl.link_to_cust_trx_line_id = l_customer_trx_line_id
         AND ard.ref_customer_trx_line_id = ctl.customer_trx_line_id
         AND ctl.line_type = 'FREIGHT'
         AND ard.activity_bucket = 'APP_FRT'
         AND ard.ref_account_class = 'FREIGHT';


       SELECT NVL(sum(NVL(amount_dr,0) - NVL(amount_cr,0)),0),
              NVL(sum(NVL(acctd_amount_dr,0) - NVL(acctd_amount_cr,0)),0)
        INTO
           l_tax_discount,
           l_base_tax_discount
        FROM ar_distributions
       WHERE source_table = 'RA'
         AND source_id in (select receivable_application_id
                            from ar_receivable_applications
                           where status = 'APP' and
                           applied_customer_Trx_id = p_customer_trx_id and
                           cash_receipt_id is not null )
         AND tax_link_id = l_customer_trx_line_id
         AND activity_bucket IN ('ED_TAX', 'UNED_TAX')
         AND ref_account_class = 'TAX';


       SELECT NVL(sum(NVL(amount_dr,0) - NVL(amount_cr,0)),0),
              NVL(sum(NVL(acctd_amount_dr,0) - NVL(acctd_amount_cr,0)),0)
        INTO
           l_line_discount,
           l_base_line_discount
        FROM ar_distributions
       WHERE source_table = 'RA'
         AND source_id in (select receivable_application_id
                            from ar_receivable_applications
                           where status = 'APP' and
                           applied_customer_Trx_id = p_customer_trx_id and
                           cash_receipt_id is not null )
         AND ref_customer_trx_line_id = l_customer_trx_line_id
         AND activity_bucket in ('ED_LINE', 'UNED_LINE')
         AND ref_account_class = 'REV';

/*Bug6906707, End */
     -- derive Line credit in entered and base currencies
      SELECT NVL(sum(NVL(amount_cr,0)),0),
              NVL(sum(NVL(acctd_amount_cr,0)),0)
        INTO
           l_line_credits,
           l_base_line_credits
        from ar_receivable_applications rec,
             ar_distributions dist
       where rec.applied_customer_trx_id =  p_customer_trx_id
         and dist.ref_customer_trx_line_id = l_customer_trx_line_id
         and rec.status = 'APP'
         and rec.application_type = 'CM'
         and dist.source_table = 'RA'
         and dist.source_id = rec.receivable_application_id
         and activity_bucket = 'APP_LINE'
         and ref_account_class = 'REV';

     -- derive tax credit in entered and base currencies
      SELECT NVL(sum(NVL(amount_cr,0)),0),
              NVL(sum(NVL(acctd_amount_cr,0)),0)
        INTO
           l_tax_credits,
           l_base_tax_credits
        from ar_receivable_applications rec,
             ar_distributions dist
       where rec.applied_customer_trx_id =  p_customer_trx_id
         and dist.ref_customer_trx_line_id = l_customer_trx_line_id
         and rec.status = 'APP'
         and rec.application_type = 'CM'
         and dist.source_table = 'RA'
         and dist.source_id = rec.receivable_application_id
         and activity_bucket = 'APP_TAX'
         and ref_account_class = 'REV';


    --  derive line adjustment in entered and base currencies
    /*Bug6821893 */

    SELECT NVL(sum(NVL(amount_cr,0) - NVL(amount_dr,0)),0),
           NVL(sum(NVL(acctd_amount_cr,0) - NVL(acctd_amount_dr,0)),0)
    INTO  l_line_adjustments,
          l_base_line_adjustments
    from ar_distributions dist
    where dist.ref_customer_trx_line_id = l_customer_trx_line_id
      and dist.source_table = 'ADJ'
      and dist.activity_bucket = 'ADJ_LINE';


    SELECT NVL(sum(NVL(amount_cr,0) - NVL(amount_dr,0)),0),
           NVL(sum(NVL(acctd_amount_cr,0) - NVL(acctd_amount_dr,0)),0)
    INTO  l_tax_adjustments,
          l_base_tax_adjustments
    from ar_distributions dist,
    ra_customer_trx_lines lines
    where lines.link_to_cust_trx_line_id = l_customer_trx_line_id
    and lines.line_type = 'TAX'
    and dist.ref_customer_trx_line_id = lines.customer_trx_line_id
    and dist.source_table = 'ADJ'
    and dist.activity_bucket = 'ADJ_TAX';


    SELECT NVL(sum(NVL(amount_cr,0) - NVL(amount_dr,0)),0),
           NVL(sum(NVL(acctd_amount_cr,0) - NVL(acctd_amount_dr,0)),0)
    INTO  l_freight_adjustments,
          l_base_freight_adjustments
    from ar_distributions dist,
         ra_customer_trx_lines lines
    where lines.link_to_cust_trx_line_id = l_customer_trx_line_id
      and dist.ref_customer_trx_line_id = lines.link_to_cust_trx_line_id
      and lines.line_type = 'FREIGHT'
      and dist.source_table = 'ADJ'
      and dist.activity_bucket = 'ADJ_FRT';


   -- derive the balances for the GROUP ID
   ELSIF (p_group_id IS NOT NULL) THEN

      -- line original, tax original, freight original (entered currencies)
      arp_util.debug('group amounts');
   END IF;


   -- get total amounts (entered currency)
   l_total_original := l_line_original + l_tax_original + l_freight_original;

   l_total_receipts := l_line_receipts + l_tax_receipts + l_freight_receipts +
                       l_charges_receipts;
   l_total_discount := l_line_discount + l_tax_discount + l_freight_discount;

   l_total_credits := l_line_credits + l_tax_credits;

   l_total_adjustments := l_line_adjustments + l_tax_adjustments
                          + l_freight_adjustments; /*Bug6821893*/

   l_base_total_adjustments := l_base_line_adjustments + l_base_tax_adjustments
                               + l_base_freight_adjustments; /*Bug6821893*/

   -- get functional currencies.
   IF ( l_line_original IS NOT NULL ) THEN
        l_base_line_original       := arpcurr.functional_amount(
                                          l_line_original,
                                          l_base_curr_code,
                                          p_exchange_rate,
                                          l_base_precision,
                                          l_base_min_acc_unit);
   END IF;

   IF ( l_tax_original IS NOT NULL ) THEN
        l_base_tax_original        := arpcurr.functional_amount(
                                          l_tax_original,
                                          l_base_curr_code,
                                          p_exchange_rate,
                                          l_base_precision,
                                          l_base_min_acc_unit);
   END IF;

   IF ( l_freight_original IS NOT NULL ) THEN
        l_base_freight_original    := arpcurr.functional_amount(
                                          l_freight_original,
                                          l_base_curr_code,
                                          p_exchange_rate,
                                          l_base_precision,
                                          l_base_min_acc_unit);
   END IF;

   IF (l_total_original IS NOT NULL) THEN
       l_base_total_original := l_base_line_original +
                                l_base_tax_original +
                                l_base_freight_original;
   END IF;

   IF (l_tax_receipts IS NOT NULL ) THEN
       l_base_tax_receipts        := arpcurr.functional_amount(
                                         l_tax_receipts,
                                         l_base_curr_code,
                                         p_exchange_rate,
                                         l_base_precision,
                                         l_base_min_acc_unit);
   END IF;

   IF (l_charges_receipts IS NOT NULL ) THEN
       l_base_charges_receipts    := arpcurr.functional_amount(
                                         l_charges_receipts,
                                         l_base_curr_code,
                                         p_exchange_rate,
                                         l_base_precision,
                                         l_base_min_acc_unit);
   END IF;

   IF (l_total_receipts IS NOT NULL) THEN
       l_base_total_receipts := l_base_line_receipts +
                                l_base_tax_receipts +
                                l_base_freight_receipts +
                                l_base_charges_receipts;
   END IF;

   IF (l_freight_discount IS NOT NULL ) THEN
       l_base_freight_discount    := arpcurr.functional_amount(
                                         l_freight_discount,
                                         l_base_curr_code,
                                         p_exchange_rate,
                                         l_base_precision,
                                         l_base_min_acc_unit);
   END IF;

   IF (l_total_discount IS NOT NULL) THEN
       l_base_total_discount := l_base_line_discount +
                                l_base_tax_discount +
                                l_base_freight_discount;
   END IF;

   /*-----------------------------------------+
    | Calculate remaining                     |
    +-----------------------------------------*/
    /*Bug6821893, included adjustment amounts to calculate line_remaining,
      tax_remaining, total_remaining, base_line_remaining, base_tax_remaining
      and base_total_remaining */

    l_line_remaining     := l_line_original - l_line_receipts -
                            l_line_discount + l_line_adjustments;
    l_tax_remaining      := l_tax_original - l_tax_receipts -
                            l_tax_discount + l_tax_adjustments;
    l_freight_remaining  := l_freight_original - l_freight_receipts -
                            l_freight_discount + l_freight_adjustments;
    l_charges_remaining  := l_charges_receipts;
    l_total_remaining    := l_total_original - l_total_receipts -
                            l_total_discount + l_total_adjustments;

    l_base_line_remaining     := l_base_line_original - l_base_line_receipts -
                                 l_base_line_discount + l_base_line_adjustments;
    l_base_tax_remaining      := l_base_tax_original - l_base_tax_receipts -
                                 l_base_tax_discount + l_base_tax_adjustments;
    l_base_freight_remaining  := l_base_freight_original -
                                 l_base_freight_receipts -
                                 l_base_freight_discount +
				 l_base_freight_adjustments;
    l_base_charges_remaining  := l_base_charges_receipts;
    l_base_total_remaining    := l_base_total_original -
                                 l_base_total_receipts -
                                 l_base_total_discount +
				 l_base_total_adjustments;

   /*-----------------------------------------+
    | copy local variables to out variables   |
    +-----------------------------------------*/
    p_line_original         := l_line_original;
    p_tax_original          := l_tax_original;
    p_freight_original      := l_freight_original;
    p_total_original        := l_total_original;

    p_base_line_original    := l_base_line_original;
    p_base_tax_original     := l_base_tax_original;
    p_base_freight_original := l_base_freight_original;
    p_base_total_original   := l_base_total_original;

    p_line_receipts         := l_line_receipts;
    p_tax_receipts          := l_tax_receipts;
    p_freight_receipts      := l_freight_receipts;
    p_charges_receipts      := l_charges_receipts;
    p_total_receipts        := l_total_receipts;

    p_base_line_receipts    := l_base_line_receipts;
    p_base_tax_receipts     := l_base_tax_receipts;
    p_base_freight_receipts := l_base_freight_receipts;
    p_base_charges_receipts := l_base_charges_receipts;
    p_base_total_receipts   := l_base_total_receipts;

    p_line_discount         := l_line_discount;
    p_tax_discount          := l_tax_discount;
    p_freight_discount      := l_freight_discount;
    p_total_discount        := l_total_discount;

    p_base_line_discount    := l_base_line_discount;
    p_base_tax_discount     := l_base_tax_discount;
    p_base_freight_discount := l_base_freight_discount;
    p_base_total_discount   := l_base_total_discount;

    p_line_remaining        := l_line_remaining;
    p_tax_remaining         := l_tax_remaining;
    p_freight_remaining     := l_freight_remaining;
    p_charges_remaining     := l_charges_remaining;
    p_total_remaining       := l_total_remaining;

    p_base_line_remaining    := l_base_line_remaining;
    p_base_tax_remaining     := l_base_tax_remaining;
    p_base_freight_remaining := l_base_freight_remaining;
    p_base_charges_remaining := l_base_charges_remaining;
    p_base_total_remaining   := l_base_total_remaining;

    p_line_credits           := l_line_credits;
    p_base_line_credits      := l_base_line_credits;
    p_tax_credits            := l_tax_credits;
    p_base_tax_credits       := l_base_tax_credits;
    p_total_credits          := l_total_credits;
    p_base_total_credits     := l_base_total_credits;

/*Bug6821893 */
    p_line_adjustments       := l_line_adjustments;
    p_tax_adjustments        := l_tax_adjustments;
    p_freight_adjustments    := l_freight_adjustments;
    p_total_adjustments      := l_total_adjustments;
    p_base_line_adjustments  := l_base_line_adjustments;
    p_base_tax_adjustments   := l_base_tax_adjustments;
    p_base_freight_adjustments := l_base_freight_adjustments;
    p_base_total_adjustments := l_base_total_adjustments;

   --
 END trx_line_balances;

END ARP_BAL_UTIL;

/
