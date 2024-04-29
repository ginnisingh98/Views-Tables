--------------------------------------------------------
--  DDL for Package Body ARP_PS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PS_UTIL" AS
/* $Header: ARCUPSB.pls 120.27.12010000.4 2010/06/16 21:58:20 rravikir ship $*/
--
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE val_update_rev_actions( p_ps_id IN NUMBER );
--
PROCEDURE validate_args_upd_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE );
--
PROCEDURE validate_args_upd_inv_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_earned_discount IN
                            ar_payment_schedules.discount_taken_earned%TYPE,
                p_unearned_discount IN
                            ar_payment_schedules.discount_taken_unearned%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE );
--
PROCEDURE validate_args_upd_adj_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_line_adjusted  IN
                            ar_receivable_applications.line_applied%TYPE,
                p_tax_adjusted  IN
                            ar_receivable_applications.tax_applied%TYPE,
                p_freight_adjusted  IN
                            ar_receivable_applications.freight_applied%TYPE,
                p_charges_adjusted  IN
                 ar_receivable_applications.receivables_charges_applied%TYPE,
                p_amount_adjusted_pending IN
                 ar_payment_schedules.amount_adjusted_pending%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE );
--
PROCEDURE validate_args_upd_adj_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE );

-- Bug fix 653643 commented out NOCOPY as this procedure is being declared as PUBLIC
--PROCEDURE populate_closed_dates(
--              p_gl_date IN ar_payment_schedules.gl_date%TYPE,
--              p_apply_date IN ar_payment_schedules.gl_date%TYPE,
--              p_app_type  IN VARCHAR2,
--              p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE );

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_reverse_actions                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure performs all actions to modify the passed in            |
 |    user defined application record and prepares to update payment schedule|
 |    table                                                                  |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |      arp_ps_pkg.update_p - Update a row in AR_PAYMENT_SCHEDULES table     |
 |      arp_ps_pkg.fetch_p  - fetch  a row in AR_PAYMENT_SCHEDULES table     |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                  p_app_rec - Application Record structure                 |
 |                  p_module_name _ Name of module that called this procedure|
 |                  p_module_version - Version of module that called this    |
 |                                     procedure                             |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 | 8/2/1996	Harri Kaukovuo	Bug fix 387827, chargebacks did not get      |
 |				closed when receipt was reversed.            |
 | 03/07/1997   Karen Lawrance  Bug fix #446386. Discounts taken where not   |
 |                              included in reversing calculations, should   |
 |                              affect line total.                           |
 | 05/15/1997   Karen Lawrance  Bug fix #464203.  Added to if constructs     |
 |                              using trx_type AR_APP and AR_CM.             |
 |                              Refer to comments in code.                   |
 +===========================================================================*/
PROCEDURE update_reverse_actions(
                p_app_rec         IN arp_global.app_rec_type,
                p_module_name     IN VARCHAR2,
                p_module_version  IN VARCHAR2) IS

  l_ps_rec        ar_payment_schedules%ROWTYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_ps_util.update_reverse_actions()+' );
       arp_debug.debug(   '   p_app_rec.trx_type = ' || p_app_rec.trx_type );
    END IF;

    --
    -- Update payment schedule table
    --
    arp_ps_pkg.fetch_p( p_app_rec.ps_id, l_ps_rec );

    l_ps_rec.amount_due_remaining := NVL( l_ps_rec.amount_due_remaining, 0) -
                        NVL( p_app_rec.amount_applied, 0 ) -
                        NVL( p_app_rec.earned_discount_taken, 0 ) -
                        NVL( p_app_rec.unearned_discount_taken, 0 );

    l_ps_rec.acctd_amount_due_remaining :=
                        NVL( l_ps_rec.acctd_amount_due_remaining, 0 ) -
                        NVL( p_app_rec.acctd_amount_applied, 0 ) -
                        NVL( p_app_rec.acctd_earned_discount_taken, 0 ) -
                        NVL( p_app_rec.acctd_unearned_discount_taken, 0 );
    --
    -- Update status
    --

    IF ( NVL( l_ps_rec.amount_due_remaining,0) = 0)
    THEN
         l_ps_rec.status := 'CL';
         l_ps_rec.gl_date_closed := NVL( p_app_rec.gl_date_closed,
                                         l_ps_rec.gl_date_closed );
         l_ps_rec.actual_date_closed := NVL( p_app_rec.actual_date_closed,
                                             l_ps_rec.actual_date_closed );
    ELSE
         l_ps_rec.status := 'OP';
         l_ps_rec.gl_date_closed := ARP_GLOBAL.G_MAX_DATE;
         l_ps_rec.actual_date_closed := ARP_GLOBAL.G_MAX_DATE;
    END IF;

    /*  Bug fix #464203
        Two values may be passed into this procedure for trx_type
        AR_APP ... Standard application reversal
        AR_CM  ... Credit Memo application reversal

        This procedure is called to update the applied transaction as
        well as the Receipt or Credit Memo in payment schedules.

        When we are updating the Receipt, Credit Memo, or the Transaction
        for the Receipt Application, we want to reset to Amount Applied.

        When we are updating the Transaction for the Credit Memo
        Application, we want to reset the Amount Credited.
    */
    --
    -- Update amount_applied
    --
    IF ( p_app_rec.trx_type = 'AR_APP' ) OR
       ( p_app_rec.trx_type IN ('AR_CM','AR_CM_REF') and
         l_ps_rec.class = 'CM' ) THEN
         l_ps_rec.amount_applied := NVL( l_ps_rec.amount_applied, 0) +
                                    NVL( p_app_rec.amount_applied, 0 );
         l_ps_rec.selected_for_receipt_batch_id := NULL;
    END IF;
    --
    -- Update amount_credited
    --
    IF ( p_app_rec.trx_type = 'AR_CM' and
         l_ps_rec.class <> 'CM' ) OR
       ( p_app_rec.trx_type = 'AR_CM_REF' ) THEN
         l_ps_rec.amount_credited :=  NVL( l_ps_rec.amount_credited, 0) -
                                      NVL( p_app_rec.amount_applied, 0 );
    END IF;
    --
    -- Update amount_adjusted
    --
    IF ( p_app_rec.trx_type = 'AR_ADJ'  OR
         p_app_rec.trx_type = 'AR_CHG' ) THEN
         l_ps_rec.amount_adjusted := NVL( l_ps_rec.amount_adjusted, 0 ) -
                                     NVL( p_app_rec.amount_applied, 0 );
    END IF;

    l_ps_rec.amount_adjusted_pending := NVL( p_app_rec.amount_adjusted_pending,
                                             l_ps_rec.amount_adjusted_pending );

    -- ------------------------------------------------------------------
    -- Update receivables_charges_remaining  and freight_remaining and
    -- tax_remaining and discount_taken_earned and discount_remaining and
    -- discount_taken_unearned and receivables_charges_charged and
    -- amount_line_items_remaining
    -- ------------------------------------------------------------------

    IF ( l_ps_rec.class = 'PMT' ) THEN
         l_ps_rec.receivables_charges_charged := NULL;
         l_ps_rec.receivables_charges_remaining := NULL;
         l_ps_rec.freight_remaining := NULL;
         l_ps_rec.tax_remaining := NULL;
         l_ps_rec.discount_remaining := NULL;
         l_ps_rec.discount_taken_earned := NULL;
         l_ps_rec.discount_taken_unearned := NULL;
         l_ps_rec.amount_line_items_remaining := NULL;
    ELSE
         /*  Bug fix #446386
             Add any discount taken back to the line amount.
             In rel11 we now will know the respective discounted
             parts so we will add them accordingly  */

         l_ps_rec.amount_line_items_remaining :=
                NVL( l_ps_rec.amount_line_items_remaining, 0 ) -
                NVL( p_app_rec.line_applied, 0) -
                NVL( p_app_rec.line_ediscounted, 0 ) -
                NVL( p_app_rec.line_uediscounted, 0 );
         --
         IF ( p_app_rec.trx_type = 'AR_ADJ' ) THEN
              l_ps_rec.receivables_charges_charged :=
                                NVL( l_ps_rec.receivables_charges_charged, 0 ) -
                                NVL( p_app_rec.charges_type_adjusted, 0);
         END IF;
         IF ( p_app_rec.trx_type = 'AR_CHG' ) THEN
              l_ps_rec.receivables_charges_charged :=
                              NVL( l_ps_rec.receivables_charges_charged, 0 )  -
                              NVL( p_app_rec.amount_applied, 0 );
         END IF;
         --
         l_ps_rec.receivables_charges_remaining :=
                        NVL( l_ps_rec.receivables_charges_remaining, 0) -
                        NVL( p_app_rec.receivables_charges_applied, 0) -
                        NVL( p_app_rec.charges_ediscounted, 0 ) -
                        NVL( p_app_rec.charges_uediscounted, 0 );
         --
         --
         --
         l_ps_rec.freight_remaining :=
                        NVL( l_ps_rec.freight_remaining, 0 ) -
                        NVL( p_app_rec.freight_applied, 0 )  -
                        NVL( p_app_rec.freight_ediscounted, 0 ) -
                        NVL( p_app_rec.freight_uediscounted, 0 );
         --
         l_ps_rec.tax_remaining :=
                        NVL( l_ps_rec.tax_remaining, 0 ) -
                        NVL( p_app_rec.tax_applied, 0 ) -
                        NVL( p_app_rec.tax_ediscounted, 0 ) -
                        NVL( p_app_rec.tax_uediscounted, 0 );
         --
         --
         l_ps_rec.discount_remaining := NVL( l_ps_rec.discount_remaining, 0 );
         --
         l_ps_rec.discount_taken_earned :=
                                NVL( l_ps_rec.discount_taken_earned, 0) +
                                NVL( p_app_rec.earned_discount_taken, 0 );
         --
         l_ps_rec.discount_taken_unearned :=
                                NVL( l_ps_rec.discount_taken_unearned, 0 ) +
                                NVL( p_app_rec.unearned_discount_taken, 0 );
    END IF;

    arp_ps_pkg.update_p( l_ps_rec );

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_ps_util.update_reverse_actions()-' );
    END IF;
    EXCEPTION
        WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		  'EXCEPTION: arp_ps_util.update_reverse_actions' );
              END IF;
              RAISE;
END update_reverse_actions;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    val_update_rev_actions                                                 |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure validated arguments passed to update_reverse_actions    |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                    p_ps_id - Payment Schedule Id from user define appln   |
 |                              record                                       |
 |              OUT:                                                         |
 |                                                                           |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY - Created by Ganesh Vaidee - 04/25/95                |
 |                                                                           |
 +===========================================================================*/
PROCEDURE val_update_rev_actions( p_ps_id IN NUMBER ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.val_update_rev_actions()+' );
    END IF;
    IF ( p_ps_id IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.val_update_rev_actions()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		  'EXCEPTION: arp_ps_util.val_update_rev_actions' );
              END IF;
              RAISE;
END val_update_rev_actions;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_receipt_related_columns                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the receipt related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a receipt. The procedure |
 |      sets the gl_date and gl_date_closed and amount applied. The procedure|
 |      should be called whenever a receipt is applied to an invoice.        |
 |      The procedure also return the acctd_amount_applied to populate the   |
 |      acctd_amount_applied_from column during AR_RA row insertion          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |         IN : p_payment_schedule_id - payment_schedule_id of payment       |
 |              schedule                                                     |
 |              p_gldate - GL date of the receipt                            |
 |              p_apply_date - Apply Date of the receipt                     |
 |              p_amount_applied - Amount of the receipt applied to the      |
 |                                 invoice.                                  |
 |              p_module_name - Name of module that called this routine      |
 |              p_module_version - Version of module that called this routine|
 |              p_maturity_date - PS.due_date for receipt.
 |        OUT NOCOPY : p_acctd_amount_applied_out - Accounted amount applied used to|
 |                         populate acctd_amount_applied_from in AR_RA table |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_debug.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - Also Calls populate_closed_dates. This procedure is in this file. |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_receipt_related_columns(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied  OUT NOCOPY
                 ar_receivable_applications.acctd_amount_applied_from%TYPE,
                p_ps_rec IN ar_payment_schedules%ROWTYPE,
                p_maturity_date IN ar_payment_schedules.due_date%TYPE DEFAULT NULL,
				p_applied_ps_class IN ar_payment_schedules.class%TYPE DEFAULT NULL ) IS		-- Bug 6924942
--
l_ps_rec                 ar_payment_schedules%ROWTYPE;
--
-- Variable to populate OUT NOCOPY arguments
--
l_acctd_amount_applied
                 ar_receivable_applications.acctd_amount_applied_from%TYPE;

--Introduced For Bug # 2711860
-- ORASHID
--
l_nocopy_amt_due_remain
  ar_payment_schedules.amount_due_remaining%TYPE;
l_nocopy_acctd_amt_due_remain
  ar_payment_schedules.acctd_amount_due_remaining%TYPE;

-- Bug 6924942 - Start
l_rows_accumulate_count number;
current_amt_app         number;
Current_acctd_amt_app   number;
Base_amt_due_rem        number;
Base_acctd_amt_due_rem   number;
l_new_adr               number;
l_new_aadr              number;
l_new_aapf              number;
l_amt_app_from          number;
l_acctd_amt_app_from    number;
-- Bug 6924942 - End

BEGIN
  IF PG_DEBUG IN ('Y','C')
  THEN
    arp_debug.debug( 'arp_ps_util.update_receipt_related_columns()+' );
    arp_debug.debug( 'PS ID                 : '||p_ps_id );
    arp_debug.debug( 'Amount Applied        : '||p_amount_applied );
    arp_debug.debug( 'Apply Date            : '||TO_CHAR( p_apply_date ) );
    arp_debug.debug( 'GL Date               : '||TO_CHAR( p_gl_date ) );
    arp_debug.debug( 'Maturity Date         : '||TO_CHAR( p_maturity_date));
  END IF;

    IF ( p_ps_rec.payment_schedule_id is NOT NULL ) THEN
        l_ps_rec := p_ps_rec;
        validate_args_upd_rel_cols( l_ps_rec.payment_schedule_id,
                                        p_amount_applied,
                                        p_apply_date, p_gl_date );
    ELSE
        validate_args_upd_rel_cols( p_ps_id, p_amount_applied,
                                        p_apply_date, p_gl_date );
        arp_ps_pkg.fetch_p( p_ps_id, l_ps_rec );
    END IF;
    --
    -- Call acctd. amount package, to calculate new ADR, acctd_ADR and
    -- acctd. amount applied. The acctd. amount applied directly updates OUT NOCOPY
    -- variable p_acctd_amount_applied.
    -- Note: Receipt amount passed in negative of receipt amount
    --

    -- Modified For Bug # 2711860
    -- ORASHID
    --
      /*Bug 6924942 get all the unapp rows with corresponding APP pair*/
      select count(*) into l_rows_accumulate_count
      from ar_receivable_applications ra,ar_payment_schedules ps
      where ra.cash_receipt_id=l_ps_rec.cash_receipt_id
      and   ra.status='UNAPP'
      and   nvl(ra.include_in_accumulation,'Y')='Y'
      and   ra.payment_schedule_id=p_ps_id
      and   ra.payment_schedule_id = ps.payment_schedule_id
      and   ps.class='PMT' and ra.application_rule <> '60.2';

/* -- 6924942
   In case of debit item application of invoice changed the way to calculate amount applied.
   1. Get the amount due remaining for all application done after bumping receipt amount by
      CM or PMT or direct updation of receipt amount.
   2. Get total application accounted amount after bumping receipt amount.
   3. Get total accounted amount including this application
   4. Take differenct of amounts in 2 and 3 to get accounted amount for current application
*/
   IF p_applied_ps_class IN ('INV') THEN
    IF l_rows_accumulate_count > 0 then
     /*5473882 as in point 2 above*/
      select nvl(sum(ra.amount_applied),0),nvl(sum(ra.acctd_amount_applied_from),0) into
          current_amt_app,Current_acctd_amt_app
      from ar_receivable_applications ra,ar_payment_schedules ps
      where ra.cash_receipt_id=l_ps_rec.cash_receipt_id
      and   ra.status='UNAPP'
      and   nvl(ra.include_in_accumulation,'Y')='Y'
      and   ra.payment_schedule_id=p_ps_id
      and   ra.payment_schedule_id = ps.payment_schedule_id
      and   ps.class='PMT' and ra.application_rule <> '60.2';

      arp_util.debug( 'arp_ps_util.update_receipt_related_columns : Prev applications exists.' );
      --6924942 :- As in point 1 above

      Base_amt_due_rem      := l_ps_rec.amount_due_remaining + current_amt_app;
      Base_acctd_amt_due_rem := l_ps_rec.acctd_amount_due_remaining + current_acctd_amt_app;

      arp_util.debug( 'Base ADR                 : '||base_amt_due_rem );
      arp_util.debug( 'Base AADR                : '||Base_acctd_amt_due_rem );

      arp_util.debug( 'Current amt app          : '||current_amt_app );
      arp_util.debug( 'Current Acct amt app     : '||current_acctd_amt_app);

      --6924942 as in point 3 above
      arp_util.calc_acctd_amount(NULL,NULL,NULL,
             l_ps_rec.exchange_rate,
             '-',                /** ADR must be reduced by amount_applied */
             Base_amt_due_rem,       /* Current ADR */
             Base_acctd_amt_due_rem, /* Current Acctd. ADR */
             (Current_amt_app-p_amount_applied),                   /* Receipt Amount */
             l_new_adr,l_new_aadr,l_new_aapf);

      arp_util.debug( 'New adr            : '||l_new_adr );
      arp_util.debug( 'New aadr           : '||l_new_aadr );
      arp_util.debug( 'New aapf           : '||l_new_aapf );

             --6924942 as in point 4 above
             l_ps_rec.amount_due_remaining := l_new_adr;
             l_ps_rec.acctd_amount_due_remaining := l_new_aadr;
             l_acctd_amount_applied := l_new_aapf-current_acctd_amt_app;
    else
      --6924942 case of first application
      l_amt_app_from       := -p_amount_applied;
      l_acctd_amt_app_from :=  arp_util.functional_amount(l_amt_app_from,
                                    arpcurr.FunctionalCurrency,
                                    l_ps_rec.exchange_rate,
                                    NULL,
                                    NULL);
      arp_util.debug( 'AAPF                     : '||l_amt_app_from );
      arp_util.debug( 'ACCTD_AAPF               : '||l_acctd_amt_app_from );

      arp_util.debug( 'Amt App                  : '||p_amount_applied );
      l_ps_rec.amount_due_remaining := l_ps_rec.amount_due_remaining - l_amt_app_from;
      l_ps_rec.acctd_amount_due_remaining := l_ps_rec.acctd_amount_due_remaining - l_acctd_amt_app_from;
      l_acctd_amount_applied := l_acctd_amt_app_from;


    end if;
   ELSE

    --6924942 same way calculation apart from Invoice
    l_nocopy_amt_due_remain := l_ps_rec.amount_due_remaining;
    l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;

    arp_util.calc_acctd_amount( NULL, NULL, NULL,
             l_ps_rec.exchange_rate,
             '-',                /** ADR must be reduced by amount_applied */
             l_nocopy_amt_due_remain,       /* Current ADR */
             l_nocopy_acctd_amt_due_remain, /* Current Acctd. ADR */
             -p_amount_applied,                   /* Receipt Amount */
             l_ps_rec.amount_due_remaining,       /* New ADR */
             l_ps_rec.acctd_amount_due_remaining, /* New Acctd. ADR */
             l_acctd_amount_applied );            /* Acct. amount_applied */
   END IF; -- Bug 6924942
    --
    -- Update OUT NOCOPY variables
    --
    p_acctd_amount_applied := l_acctd_amount_applied;
    --
    -- Set the closed dates and status of PS record
    --
    arp_ps_util.populate_closed_dates( p_gl_date, p_apply_date, 'PMT', l_ps_rec );
    --
    -- Update other PS columns
    -- Note: Amount applied added is negative of receipt amount
    -- In reality p_amount_applied will never be NULL at this stage
    --
    l_ps_rec.amount_applied := NVL( l_ps_rec.amount_applied, 0) -
                               NVL( p_amount_applied, 0 );
    l_ps_rec.selected_for_receipt_batch_id := NULL;
    --
    -- Update PS record
    -- Do not CALL the table handler as this will cause the mrc
    -- data to be updated.  The mrc data is needed for processing
    -- Receivable applications information.  Instead we will do
    -- a direct update of changed columns.
    -- arp_ps_pkg.update_p( l_ps_rec );
    --
    /* Bug fix 3583503
       gl_date and receipt_confirmed_flag also needs to be updated */
    /* Bug fix 3721519
       The WHO columns should be updated as in arp_ps_pkg.update_p */

    /* Bug 5569488, do not update payment schedule if the receipt requires
       confirmation. Added the If condition */
    IF NVL(l_ps_rec.receipt_confirmed_flag,'Y') <> 'N' THEN
      UPDATE ar_payment_schedules
      set acctd_amount_due_remaining = l_ps_rec.acctd_amount_due_remaining,
         amount_due_remaining = l_ps_rec.amount_due_remaining,
         amount_applied = l_ps_rec.amount_applied,
         selected_for_receipt_batch_id = l_ps_rec.selected_for_receipt_batch_id,
         status = l_ps_rec.status,
         reserved_type = l_ps_rec.reserved_type,
         reserved_value = l_ps_rec.reserved_value,
         gl_date_closed = l_ps_rec.gl_date_closed,
         actual_date_closed = l_ps_rec.actual_date_closed ,
         gl_date = l_ps_rec.gl_date,
         receipt_confirmed_flag = l_ps_rec.receipt_confirmed_flag,
         last_updated_by = arp_global.last_updated_by,
         last_update_date = SYSDATE,
         last_update_login = NVL(arp_standard.profile.last_update_login,l_ps_rec.last_update_login ),
         request_id = NVL(arp_standard.profile.request_id,l_ps_rec.request_id),
         program_application_id = NVL(arp_standard.profile.program_application_id,
                                      l_ps_rec.program_application_id ),
         program_id = NVL(arp_standard.profile.program_id, l_ps_rec.program_id),
         program_update_date = DECODE(arp_standard.profile.program_id,
                                      NULL, l_ps_rec.program_update_date,SYSDATE),
         due_date = NVL(NVL(p_maturity_date, l_ps_rec.due_date),due_date)
       where
         payment_schedule_id = l_ps_rec.payment_schedule_id;
    END IF ;

    IF PG_DEBUG in ('Y','C')
    THEN
       arp_debug.debug( 'arp_ps_util.update_receipt_related_columns()-' );
    END IF;

    EXCEPTION
         WHEN OTHERS THEN
              arp_debug.debug(
		  'EXCEPTION: arp_ps_util.update_receipt_related_columns' );
              RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_upd_rel_cols                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Validate arguments passed to update_receipt_related_cols,            |
 |      update_cm_related_cols and update_adj_related_cols procedure         |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS : p_payment_schedule_id - payment_schedule_id of payment       |
 |              schedule                                                     |
 |              p_amount_applied - Inout applied amount                      |
 |              p_gldate - GL date of the receipt                            |
 |              p_apply_date - Apply Date of the receipt                     |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_upd_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.validate_args_upd_rel_cols()+' );
    END IF;
    --
    IF ( p_amount_applied IS NULL OR  p_ps_id IS NULL OR
         p_apply_date IS NULL OR p_gl_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.validate_args_upd_rel_cols()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug('validate_args_upd_rel_cols: ' ||
		  'EXCEPTION: arp_ps_util.validate_args_upd_rel_cols' );
              END IF;
              RAISE;
END validate_args_upd_rel_cols;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_invoice_related_columns                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the invoice related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a invoice. The procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever a receipt is applied to an       |
 |      invoice. The procedure also returns the acctd_amount_applied,        |
 |      acctd_earned_discount_taken, acctd_unearned_discount_taken columns,  |
 |      line_applied, tax_applied, freight_applied, charges_applied columns  |
 |      to populate the RA columns during AR_RA row insertion                |
 |      insertion          						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_app_type            - Indicates the type of application         |
 |                                 Valid values are CASH for receipt         |
 |                                 application and CM fro credit memo appln. |
 |         p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_applied      - Amount of the receipt applied to the      |
 |                                 invoice                                   |
 |         p_discount_taken_earned   - Earned discount taken(NULL if CM      |
 |                                     appln                                 |
 |         p_discount_taken_unearned - Unearned discount taken(NULL if CM    |
 |                                     appln                                 |
 |         p_ps_rec                  - Payment Schedule record, If this field|
 |                                     is not null, the PS record is not     |
 |                                     fetched using p_ps_id. This PS record |
 |                                     is used                               |
 |   OUT NOCOPY : p_acctd_amount_applied     - Accounted amount applied used to     |
 |                                      populate acctd_amount_applied_from in|
 |                                      AR_RA table                          |
 |         p_acctd_discount_taken_earned - Accounted discount taken earned to|
 |                                      populate acctd_discount_taken_earned |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_acctd_disc_taken_unearned - Accounted discount taken unearned to|
 |                                      populate acctd_discount_taken_uneard |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_tax_applied              - Part of the applied amount applied to|
 |                                      tax                                  |
 |         p_freight_applied          - Part of the applied amount applied to|
 |                                      freight                              |
 |         p_line_applied             - Part of the applied amount applied to|
 |                                      lines                                |
 |         p_charges_applied          - Part of the applied amount applied to|
 |                                      receivable charges                   |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_debug.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - Also Calls populate_closed_dates. This procedure is in this file. |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 | 06/23/1998   Guat Eng Tan    Bug fix #658876. Added IF conditions before  |
 |                              the three calls to calc_acctd_amount.        |
 |                                                                           |
 | 08/29/2005  M Raymond      4566510 - Modified for etax.  Made discount
 |                              parameters IN/OUT and modified calls
 |                              to calc_amount_and_remaining so that they
 |                              would only happen if discounts were not
 |                              already prorated.
 | 12/18/2006  M Raymond      5677984 - Update l_line_remaining and
 |                              l_tax_remaining after skipping
 |                              calc_applied_and_remaining
 +===========================================================================*/
PROCEDURE update_invoice_related_columns(
                p_app_type  IN VARCHAR2,
                p_ps_id     IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied          IN ar_payment_schedules.amount_applied%TYPE,
                p_discount_taken_earned   IN ar_payment_schedules.discount_taken_earned%TYPE,
                p_discount_taken_unearned IN ar_payment_schedules.discount_taken_unearned%TYPE,
                p_apply_date              IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date                 IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied    OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_acctd_earned_discount_taken OUT NOCOPY ar_receivable_applications.earned_discount_taken%TYPE,
                p_acctd_unearned_disc_taken   OUT NOCOPY ar_receivable_applications.acctd_unearned_discount_taken%TYPE,
                p_line_applied     OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_applied      OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_applied  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_applied  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_ediscounted IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_ediscounted  IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_ediscounted  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_ediscounted  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_uediscounted   IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_uediscounted    IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_uediscounted OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_uediscounted OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_rule_set_id          OUT NOCOPY number,
                p_ps_rec               IN  ar_payment_schedules%ROWTYPE) IS

  l_ra_app_id NUMBER;
  l_gt_id     NUMBER;

BEGIN

  /* original version, just calls other version with additional parameters
         Note that l_ra_app_id and l_gt_id are both junk variables
         and any return values will be ignored.  */

    update_invoice_related_columns(
                p_app_type,
                p_ps_id,
                p_amount_applied,
                p_discount_taken_earned,
                p_discount_taken_unearned,
                p_apply_date,
                p_gl_date,
                p_acctd_amount_applied,
                p_acctd_earned_discount_taken,
                p_acctd_unearned_disc_taken,
                p_line_applied,
                p_tax_applied,
                p_freight_applied,
                p_charges_applied,
                p_line_ediscounted,
                p_tax_ediscounted,
                p_freight_ediscounted,
                p_charges_ediscounted,
                p_line_uediscounted,
                p_tax_uediscounted,
                p_freight_uediscounted,
                p_charges_uediscounted,
                p_rule_set_id,
                p_ps_rec,
                to_number(NULL),
                l_ra_app_id,
                l_gt_id);

END update_invoice_related_columns;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_invoice_related_columns                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the invoice related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a invoice. The procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever a receipt is applied to an       |
 |      invoice. The procedure also returns the acctd_amount_applied,        |
 |      acctd_earned_discount_taken, acctd_unearned_discount_taken columns,  |
 |      line_applied, tax_applied, freight_applied, charges_applied columns  |
 |      to populate the RA columns during AR_RA row insertion                |
 |      insertion          						     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_app_type            - Indicates the type of application         |
 |                                 Valid values are CASH for receipt         |
 |                                 application and CM fro credit memo appln. |
 |         p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_applied      - Amount of the receipt applied to the      |
 |                                 invoice                                   |
 |         p_discount_taken_earned   - Earned discount taken(NULL if CM      |
 |                                     appln                                 |
 |         p_discount_taken_unearned - Unearned discount taken(NULL if CM    |
 |                                     appln                                 |
 |         p_ps_rec                  - Payment Schedule record, If this field|
 |                                     is not null, the PS record is not     |
 |                                     fetched using p_ps_id. This PS record |
 |                                     is used                               |
 |   OUT NOCOPY : p_acctd_amount_applied     - Accounted amount applied used to     |
 |                                      populate acctd_amount_applied_from in|
 |                                      AR_RA table                          |
 |         p_acctd_discount_taken_earned - Accounted discount taken earned to|
 |                                      populate acctd_discount_taken_earned |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_acctd_disc_taken_unearned - Accounted discount taken unearned to|
 |                                      populate acctd_discount_taken_uneard |
 |                                      AR_RA table. This field is not       |
 |                                      populated if application is of type  |
 |                                      CM. It is NULL is app. type is CM.   |
 |         p_tax_applied              - Part of the applied amount applied to|
 |                                      tax                                  |
 |         p_freight_applied          - Part of the applied amount applied to|
 |                                      freight                              |
 |         p_line_applied             - Part of the applied amount applied to|
 |                                      lines                                |
 |         p_charges_applied          - Part of the applied amount applied to|
 |                                      receivable charges                   |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_debug.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - Also Calls populate_closed_dates. This procedure is in this file. |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 | 06/23/1998   Guat Eng Tan    Bug fix #658876. Added IF conditions before  |
 |                              the three calls to calc_acctd_amount.        |
 |                                                                           |
 | 08/29/2005  M Raymond      4566510 - Modified for etax.  Made discount
 |                              parameters IN/OUT and modified calls
 |                              to calc_amount_and_remaining so that they
 |                              would only happen if discounts were not
 |                              already prorated.
 | 12/18/2006  M Raymond      5677984 - Update l_line_remaining and
 |                              l_tax_remaining after skipping
 |                              calc_applied_and_remaining
 +===========================================================================*/
PROCEDURE update_invoice_related_columns(
                p_app_type  IN VARCHAR2,
                p_ps_id     IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied          IN ar_payment_schedules.amount_applied%TYPE,
                p_discount_taken_earned   IN ar_payment_schedules.discount_taken_earned%TYPE,
                p_discount_taken_unearned IN ar_payment_schedules.discount_taken_unearned%TYPE,
                p_apply_date              IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date                 IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied    OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_acctd_earned_discount_taken OUT NOCOPY ar_receivable_applications.earned_discount_taken%TYPE,
                p_acctd_unearned_disc_taken   OUT NOCOPY ar_receivable_applications.acctd_unearned_discount_taken%TYPE,
                p_line_applied     OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_applied      OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_applied  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_applied  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_ediscounted IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_ediscounted  IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_ediscounted  OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_ediscounted  OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_line_uediscounted   IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_uediscounted    IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_uediscounted OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_uediscounted OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_rule_set_id          OUT NOCOPY number,
                p_ps_rec               IN  ar_payment_schedules%ROWTYPE,
                p_cash_receipt_id      IN ar_receivable_applications_all.cash_receipt_id%TYPE,
                p_ra_app_id            OUT NOCOPY ar_receivable_applications.receivable_application_id%TYPE,
                p_gt_id                OUT NOCOPY NUMBER) IS

--
-- Temp variables
--
l_ps_rec                   ar_payment_schedules%ROWTYPE;
l_discount_taken_total     ar_payment_schedules.amount_applied%TYPE:=0;
l_tax_discounted       ar_receivable_applications.tax_applied%TYPE:=0;
l_freight_discounted   ar_receivable_applications.freight_applied%TYPE:=0;
l_line_discounted      ar_receivable_applications.line_applied%TYPE:=0;
l_charges_discounted
              ar_receivable_applications.receivables_charges_applied%TYPE:=0;
l_line_remaining ar_payment_schedules.tax_remaining%TYPE:=0;
l_tax_remaining ar_payment_schedules.tax_remaining%TYPE:=0;
l_rec_charges_remaining ar_payment_schedules.tax_remaining%TYPE:=0;
l_freight_remaining ar_payment_schedules.tax_remaining%TYPE:=0;
--
-- Variable to populate OUT NOCOPY arguments
-- We need these variables, 'cos the remaining LINE, TAX, FREIGHT and CHARGES
-- amounts are calculated based on the applied amounts and applied discounts
--
l_tax_applied       ar_receivable_applications.tax_applied%TYPE:=0;
l_freight_applied   ar_receivable_applications.freight_applied%TYPE:=0;
l_line_applied      ar_receivable_applications.line_applied%TYPE:=0;
l_charges_applied   ar_receivable_applications.receivables_charges_applied%TYPE:=0;
l_tax_ediscounted       ar_receivable_applications.tax_applied%TYPE:=0;
l_freight_ediscounted   ar_receivable_applications.freight_applied%TYPE:=0;
l_line_ediscounted      ar_receivable_applications.line_applied%TYPE:=0;
l_charges_ediscounted
              ar_receivable_applications.receivables_charges_applied%TYPE:=0;
l_tax_uediscounted       ar_receivable_applications.tax_applied%TYPE:=0;
l_freight_uediscounted   ar_receivable_applications.freight_applied%TYPE:=0;
l_line_uediscounted      ar_receivable_applications.line_applied%TYPE:=0;
l_charges_uediscounted
              ar_receivable_applications.receivables_charges_applied%TYPE:=0;
--
l_acctd_amount_applied
                 ar_receivable_applications.acctd_amount_applied_from%TYPE:=0;
l_acctd_earned_discount_taken
                 ar_receivable_applications.earned_discount_taken%TYPE:=0;
l_acctd_unearned_disc_taken
                 ar_receivable_applications.acctd_unearned_discount_taken%TYPE:=0;
--

--Introduced For Bug # 2711860
-- ORASHID
--
l_nocopy_amt_due_remain
  ar_payment_schedules.amount_due_remaining%TYPE;
l_nocopy_acctd_amt_due_remain
  ar_payment_schedules.acctd_amount_due_remaining%TYPE;

-- 5569488
l_receipt_confirmed_flag   ar_payment_schedules.receipt_confirmed_flag%TYPE ;

/* 5677984 - locals for etax calls */
l_ebt_customer_trx_id   ar_payment_schedules.customer_trx_id%TYPE;
l_ebt_discount_amt      NUMBER;
l_ebt_gt_id             NUMBER;
l_ebt_prorated_line     NUMBER;
l_ebt_prorated_tax      NUMBER;
l_ebt_ra_app_id         NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_invoice_related_columns()+' );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'PS ID                 : '||p_ps_id );
       arp_debug.debug(   'Amount Applied        : '||p_amount_applied );
       arp_debug.debug(   'Earned Disc. Taken    : '||p_discount_taken_earned );
       arp_debug.debug(   'Unearned Disc. Taken  : '||p_discount_taken_unearned );
       arp_debug.debug(   'Apply Date            : '||TO_CHAR( p_apply_date ) );
       arp_debug.debug(   'GL Date               : '||TO_CHAR( p_gl_date ) );
    END IF;
    --
    IF ( p_ps_rec.payment_schedule_id is NOT NULL ) THEN
        l_ps_rec := p_ps_rec;
        validate_args_upd_inv_rel_cols( l_ps_rec.payment_schedule_id,
                                        p_amount_applied,
                                        p_discount_taken_earned,
                                        p_discount_taken_unearned,
                                        p_apply_date, p_gl_date );
    ELSE
        validate_args_upd_inv_rel_cols( p_ps_id,
                                        p_amount_applied,
                                        p_discount_taken_earned,
                                        p_discount_taken_unearned,
                                        p_apply_date, p_gl_date );
        arp_ps_pkg.fetch_p( p_ps_id, l_ps_rec );
    END IF;
    --
    -- Init. temp. variables
    --
    l_discount_taken_total := p_discount_taken_earned +
                              p_discount_taken_unearned;

    l_line_remaining := l_ps_rec.amount_line_items_remaining;
    l_tax_remaining := l_ps_rec.tax_remaining;
    l_freight_remaining := l_ps_rec.freight_remaining;
    l_rec_charges_remaining := l_ps_rec.receivables_charges_remaining;

    p_rule_set_id := ARP_APP_CALC_PKG.GET_RULE_SET_ID(l_ps_rec.cust_trx_type_id);

    IF nvl(p_discount_taken_earned,0) <> 0
    THEN

          /* Always call this logic (etax or no) to insure
             that freight and charges receive their fair share */

          ARP_APP_CALC_PKG.calc_applied_and_remaining(
             p_discount_taken_earned
            ,p_rule_set_id
            ,l_ps_rec.invoice_currency_code
            ,l_line_remaining
            ,l_tax_remaining
            ,l_freight_remaining
            ,l_rec_charges_remaining
            ,l_line_ediscounted
            ,l_tax_ediscounted
            ,l_freight_ediscounted
            ,l_charges_ediscounted );

          /* 5677984 - etax needs to be called */
          IF p_cash_receipt_id IS NOT NULL
          THEN
             /* set up local variables for call */
             SELECT customer_trx_id
             INTO   l_ebt_customer_trx_id
             FROM   ar_payment_schedules
             WHERE  payment_schedule_id = p_ps_id;

             l_ebt_discount_amt := l_line_ediscounted + l_tax_ediscounted;

             /* prorate earned discount based on etax */
             arp_etax_util.prorate_recoverable(
                   p_adj_id         => p_cash_receipt_id,
                   p_target_id      => l_ebt_customer_trx_id,
                   p_target_line_id => NULL,
                   p_amount         => l_ebt_discount_amt,
                   p_apply_date     => p_apply_date,
                   p_mode           => 'APP_ED',
                   p_upd_adj_and_ps => 'N',
                   p_gt_id          => l_ebt_gt_id,
                   p_prorated_line  => l_ebt_prorated_line,
                   p_prorated_tax   => l_ebt_prorated_tax,
                   p_ra_app_id      => l_ebt_ra_app_id);

             /* Now sort out the results so that we either
                used the etax or non-etax amounts for line
                and tax discounts */
             IF l_ebt_prorated_tax <> 0
             THEN
                l_line_remaining := l_line_remaining
                   + l_line_ediscounted
                   - l_ebt_prorated_line;
                l_tax_remaining := l_tax_remaining
                   + l_tax_ediscounted
                   - l_ebt_prorated_tax;

                l_line_ediscounted := l_ebt_prorated_line;
                l_tax_ediscounted := l_ebt_prorated_tax;

             END IF;

          END IF;

    END IF;

    IF nvl(p_discount_taken_unearned,0) <> 0
    THEN

         ARP_APP_CALC_PKG.calc_applied_and_remaining(
             p_discount_taken_unearned
            ,p_rule_set_id
            ,l_ps_rec.invoice_currency_code
            ,l_line_remaining
            ,l_tax_remaining
            ,l_freight_remaining
            ,l_rec_charges_remaining
            ,l_line_uediscounted
            ,l_tax_uediscounted
            ,l_freight_uediscounted
            ,l_charges_uediscounted );

          /* 5677984 - etax needs to be called */
          IF p_cash_receipt_id IS NOT NULL
          THEN
             /* set up local variables for call */
             IF l_ebt_customer_trx_id IS NULL
             THEN
                SELECT customer_trx_id
                INTO   l_ebt_customer_trx_id
                FROM   ar_payment_schedules
                WHERE  payment_schedule_id = p_ps_id;
             END IF;

             l_ebt_discount_amt := l_line_uediscounted + l_tax_uediscounted;

             /* prorate unearned discount based on etax */
             arp_etax_util.prorate_recoverable(
                   p_adj_id         => p_cash_receipt_id,
                   p_target_id      => l_ebt_customer_trx_id,
                   p_target_line_id => NULL,
                   p_amount         => l_ebt_discount_amt,
                   p_apply_date     => p_apply_date,
                   p_mode           => 'APP_UED',
                   p_upd_adj_and_ps => 'N',
                   p_gt_id          => l_ebt_gt_id,
                   p_prorated_line  => l_ebt_prorated_line,
                   p_prorated_tax   => l_ebt_prorated_tax,
                   p_ra_app_id      => l_ebt_ra_app_id);

             /* Now sort out the results so that we either
                used the etax or non-etax amounts for line
                and tax discounts */
             IF l_ebt_prorated_tax <> 0
             THEN
                l_line_remaining := l_line_remaining
                   + l_line_uediscounted
                   - l_ebt_prorated_line;
                l_tax_remaining := l_tax_remaining
                   + l_tax_uediscounted
                   - l_ebt_prorated_tax;

                l_line_uediscounted := l_ebt_prorated_line;
                l_tax_uediscounted := l_ebt_prorated_tax;
             END IF;

          END IF;

    END IF;

    IF nvl(p_amount_applied,0) <> 0 THEN

    ARP_APP_CALC_PKG.calc_applied_and_remaining(
             p_amount_applied
            ,p_rule_set_id
            ,l_ps_rec.invoice_currency_code
            ,l_line_remaining
            ,l_tax_remaining
            ,l_freight_remaining
            ,l_rec_charges_remaining
            ,l_line_applied
            ,l_tax_applied
            ,l_freight_applied
            ,l_charges_applied );

    END IF;



             l_line_discounted := l_line_uediscounted + l_line_ediscounted;
             l_tax_discounted := l_tax_uediscounted + l_tax_ediscounted ;
             l_freight_discounted := l_freight_uediscounted + l_freight_ediscounted;
             l_charges_discounted := l_charges_uediscounted + l_charges_ediscounted;
    --
    -- Calc. Acctd. Discount values if trx_type is 'CASH'
    --
    IF ( p_app_type = 'CASH' ) THEN
        --
        -- Call acctd. amount package to get acctd. earned disc. and new ADR.
        -- l_acctd_earned_discount_taken is used to populate AR_RA row
        -- Note: ADR has already been reduced by earned_discount_taken
        --

        IF (p_discount_taken_earned = 0 OR p_discount_taken_earned IS NULL) THEN
          IF (p_discount_taken_earned = 0) THEN
            p_acctd_earned_discount_taken := 0;
          ELSE
            p_acctd_earned_discount_taken := NULL;
          END IF;
        ELSE

          -- Modified For Bug # 2711860
          -- ORASHID
          --
          l_nocopy_amt_due_remain := l_ps_rec.amount_due_remaining;
          l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;

          arp_util.calc_acctd_amount( NULL, NULL, NULL,
              l_ps_rec.exchange_rate,
              '-',   /** ADR must be reduced by amount_applied */
              l_nocopy_amt_due_remain,        /* Current ADR */
              l_nocopy_acctd_amt_due_remain,  /* Current Acctd. ADR */
              p_discount_taken_earned,              /* Earned discount */
              l_ps_rec.amount_due_remaining,        /* New ADR */
              l_ps_rec.acctd_amount_due_remaining,  /* New Acctd. ADR */
              l_acctd_earned_discount_taken );      /* Acct. amount_applied */
        --
        -- Update OUT NOCOPY variable p_acctd_earned_discount_taken
        --
          p_acctd_earned_discount_taken := l_acctd_earned_discount_taken;
        END IF;

        --
        -- Call acctd. amount package to get acctd. unearned discounts and
        -- new ADR. l_acctd_unearned_discount_taken is used to populate RA row
        -- Note: ADR has already been reduced by unearned_discount_taken
        --

        IF (p_discount_taken_unearned = 0 OR p_discount_taken_unearned IS NULL) THEN
          IF (p_discount_taken_unearned = 0) THEN
            p_acctd_unearned_disc_taken := 0;
          ELSE
            p_acctd_unearned_disc_taken := NULL;
          END IF;
        ELSE

          -- Modified For Bug # 2711860
          -- ORASHID
          --
          l_nocopy_amt_due_remain := l_ps_rec.amount_due_remaining;
          l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;

          arp_util.calc_acctd_amount( NULL, NULL, NULL,
             l_ps_rec.exchange_rate,
             '-',   /** ADR must be reduced by amount_applied */
             l_nocopy_amt_due_remain,       /* Current ADR */
             l_nocopy_acctd_amt_due_remain, /* Current Acctd. ADR */
             p_discount_taken_unearned,           /* Unearned discount */
             l_ps_rec.amount_due_remaining,       /* New ADR */
             l_ps_rec.acctd_amount_due_remaining, /* New Acctd. ADR */
             l_acctd_unearned_disc_taken );       /* Acct. amount_applied */
        --
        -- Update OUT NOCOPY variable p_acctd_unearned_disc_taken
        --
          p_acctd_unearned_disc_taken := l_acctd_unearned_disc_taken;
        END IF;

        --
    END IF;

    -- -------------------------------------------------------------------
    -- Call acctd. discounts package to get acctd. amounts and new ADR.
    -- l_acctd_amount_applied is used to populate AR_RA row
    -- If application is of type 'CASH', then ADR has already been reduced by
    -- earned_discount_taken and unearned_discount_taken
    -- Note: This procedure populates the OUT NOCOPY variable p_acctd_amount_applied
    -- directly
    -- -------------------------------------------------------------------

    IF (p_amount_applied IS NOT NULL) THEN

      -- Modified For Bug # 2711860
      -- ORASHID
      --
      l_nocopy_amt_due_remain := l_ps_rec.amount_due_remaining;
      l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;

      arp_util.calc_acctd_amount( NULL, NULL, NULL,
              l_ps_rec.exchange_rate,
              '-',   /** ADR must be reduced by amount_applied */
              l_nocopy_amt_due_remain,        /* Current ADR */
              l_nocopy_acctd_amt_due_remain,  /* Current Acctd. ADR */
              p_amount_applied,                     /* Receipt Amount */
              l_ps_rec.amount_due_remaining,        /* New ADR */
              l_ps_rec.acctd_amount_due_remaining,  /* New Acctd. ADR */
              l_acctd_amount_applied );             /* Acct. amount_applied */
    --
    -- Update OUT NOCOPY variable p_acctd_amount_applied
    --
      p_acctd_amount_applied := l_acctd_amount_applied;
    ELSE
      p_acctd_amount_applied := NULL;
    END IF;

    -- -------------------------------------------------------------------
    -- Update PS record columns
    -- In case of receipt application, amount applied is added to current
    -- amount applied, else it is subtracted
    -- -------------------------------------------------------------------
    IF ( p_app_type = 'CASH' ) THEN
        l_ps_rec.amount_applied := NVL( l_ps_rec.amount_applied, 0 ) +
                                   NVL( p_amount_applied, 0 );

    -- 4/16/1996 H.Kaukovuo	Added this way to make sure we don't brake
    --				anything.
    ELSIF (p_app_type = 'CB')
    THEN
      NULL;

    ELSE  /* Transaction type is 'CM' */
        l_ps_rec.amount_credited := NVL( l_ps_rec.amount_credited, 0 ) -
                                    NVL( p_amount_applied, 0 );

    END IF;


    l_ps_rec.discount_taken_earned :=
                               NVL( l_ps_rec.discount_taken_earned, 0 ) +
                               NVL( p_discount_taken_earned, 0 );
    l_ps_rec.discount_taken_unearned :=
                               NVL( l_ps_rec.discount_taken_unearned, 0 ) +
                               NVL( p_discount_taken_unearned, 0 );
    l_ps_rec.discount_remaining := NVL( l_ps_rec.discount_remaining, 0 ) -
                                   l_discount_taken_total;
    l_ps_rec.amount_line_items_remaining :=
                             NVL( l_ps_rec.amount_line_items_remaining, 0 ) -
                             ( NVL( l_line_applied, 0 ) +
                               NVL( l_line_discounted, 0 ) );
    l_ps_rec.receivables_charges_remaining :=
                             NVL (l_ps_rec.receivables_charges_remaining, 0 ) -
                             ( NVL( l_charges_applied, 0 ) +
                               NVL( l_charges_discounted , 0 ) );
    l_ps_rec.tax_remaining := NVL( l_ps_rec.tax_remaining, 0 ) -
                              ( NVL( l_tax_applied, 0 ) +
                                NVL( l_tax_discounted, 0 ) );
    l_ps_rec.freight_remaining := NVL( l_ps_rec.freight_remaining, 0 ) -
                              ( NVL( l_freight_applied, 0 ) +
                                NVL( l_freight_discounted, 0 ) );
    --
    -- Set the closed dates and status of PS record
    --
    /* 18-MAY-2000 J Rautiainen BR Implementation
     * Modified to pass the class instead of 'INV' since the class can be either 'BR' or 'INV' */
    arp_ps_util.populate_closed_dates( p_gl_date, p_apply_date, l_ps_rec.class, l_ps_rec );
    --
    -- Update PS record
    --
    /* Bug 5569488, do not update payment schedule if the receipt requires
       confirmation. Added the If condition */
    IF p_ps_rec.cash_receipt_id IS NOT NULL THEN
      Select receipt_confirmed_flag
      into   l_receipt_confirmed_flag
      from   ar_payment_schedules_all
      where  cash_receipt_id = p_ps_rec.cash_receipt_id ;
    END IF ;
    IF NVL(l_receipt_confirmed_flag,'Y') <> 'N' THEN
      arp_ps_pkg.update_p( l_ps_rec );
    END IF ;
    --

    -- Populate out variables( 'applied and 'accounted' )
    -- These variables will populate the RA table row
    -- Note: p_acctd_unearned_disc_taken and p_acctd_earned_disc_taken have
    -- already been populated immediately after acctd. discount calculation
    -- Output discounts will be populated only if transaction type is 'CASH'
    -- Also, note that the applied amounts could be NULL
    --
    p_line_applied := l_line_applied;
    p_tax_applied := l_tax_applied;
    p_freight_applied := l_freight_applied;
    p_charges_applied := l_charges_applied;
    p_line_ediscounted := l_line_ediscounted;
    p_tax_ediscounted := l_tax_ediscounted;
    p_freight_ediscounted := l_freight_ediscounted;
    p_charges_ediscounted := l_charges_ediscounted;
    p_line_uediscounted := l_line_uediscounted;
    p_tax_uediscounted := l_tax_uediscounted;
    p_freight_uediscounted := l_freight_uediscounted;
    p_charges_uediscounted := l_charges_uediscounted;

    /* 5677984 - return parameters from etax */
    p_ra_app_id := l_ebt_ra_app_id;
    p_gt_id     := l_ebt_gt_id;

    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_invoice_related_columns()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		  'EXCEPTION: arp_ps_util.update_invoice_related_columns' );
              END IF;
              RAISE;
END update_invoice_related_columns;

--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_upd_inv_rel_columns                                      |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Validate arguments passed to update_receipt_related_cols procedure   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS : p_payment_schedule_id - payment_schedule_id of payment       |
 |              schedule                                                     |
 |              p_amount_applied - Inout amount applied                      |
 |              p_earned_discount - Earned discount                          |
 |              p_unearned_discount - Unearned discount                      |
 |              p_gldate - GL date of the receipt                            |
 |              p_apply_date - Apply Date of the receipt                     |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_upd_inv_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_earned_discount IN
                            ar_payment_schedules.discount_taken_earned%TYPE,
                p_unearned_discount IN
                            ar_payment_schedules.discount_taken_unearned%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.validate_args_upd_inv_rel_cols()+' );
    END IF;
    --
    IF ( p_ps_id IS NULL OR p_apply_date IS NULL OR p_gl_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    -- At least one input amount should not be NULL
    --
    IF ( p_amount_applied IS NULL AND p_earned_discount IS NULL AND
         p_unearned_discount IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_util.validate_args_upd_inv_rel_cols()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug('validate_args_upd_inv_rel_cols: ' ||
		  'EXCEPTION: arp_ps_util.validate_args_upd_inv_rel_cols' );
              END IF;
              RAISE;
END validate_args_upd_inv_rel_cols;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_cm_related_columns                                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the CM      related rows of a payment schedule|
 |      The passed in PS ID is assumed to belong to a CM. The procedure      |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever a receipt is applied to an       |
 |      invoice. 							     |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_payment_schedule_id - payment_schedule_id of Credir Memo        |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_applied      - Amount of the CM      applied to the      |
 |                                 invoice                                   |
 |         p_ps_rec                  - Payment Schedule record, If this field|
 |                                     is not null, the PS record is not     |
 |                                     fetched using p_ps_id. This PS record |
 |                                     is used                               |
 |         p_update_credit_flag  - For CM refunds, to indicate if amount     |
 |				   credited should be updated                |
 |   OUT NOCOPY : p_acctd_amount_applied     - Accounted amount applied used to     |
 |                                      populate acctd_amount_applied_from in|
 |                                      AR_RA table                          |
 |         p_tax_applied              - Part of the applied amount applied to|
 |                                      tax, This field will populate        |
 |                                      TAX_REMAINING in RA table            |
 |         p_freight_applied          - Part of the applied amount applied to|
 |                                      freight, This field will populate    |
 |                                      FREIGHT_REMAINING in RA table        |
 |         p_line_applied             - Part of the applied amount applied to|
 |                                      lines, This field will populate      |
 |                                      LINE_REMAINING in RA table           |
 |         p_charges_applied          - Part of the applied amount applied to|
 |                                      receivable charges, This field will  |
 |                                      populate CHARGES_REMAINING in RA     |
 |                                      table                                |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_debug.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - Also Calls populate_closed_dates. This procedure is in this file. |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 +===========================================================================*/
PROCEDURE update_cm_related_columns(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_amount_applied IN ar_payment_schedules.amount_applied%TYPE,
                p_line_applied IN ar_receivable_applications.line_applied%TYPE,
                p_tax_applied IN ar_receivable_applications.tax_applied%TYPE,
                p_freight_applied IN
                            ar_receivable_applications.freight_applied%TYPE,
                p_charges_applied  IN
                   ar_receivable_applications.receivables_charges_applied%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_applied  OUT NOCOPY
                        ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_ps_rec IN ar_payment_schedules%ROWTYPE,
	   	p_update_credit_flag IN VARCHAR2 ) IS
--
l_ps_rec                   ar_payment_schedules%ROWTYPE;
--
-- Variable to populate OUT NOCOPY arguments
--
l_acctd_amount_applied
                 ar_receivable_applications.acctd_amount_applied_from%TYPE;

--Introduced For Bug # 2711860
-- ORASHID
--
l_nocopy_amt_due_remain
  ar_payment_schedules.amount_due_remaining%TYPE;
l_nocopy_acctd_amt_due_remain
  ar_payment_schedules.acctd_amount_due_remaining%TYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_cm_related_columns()+' );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'PS ID                 : '||p_ps_id );
       arp_debug.debug(   'Amount Applied        : '||p_amount_applied );
       arp_debug.debug(   'Apply Date            : '||TO_CHAR( p_apply_date ) );
       arp_debug.debug(   'GL Date               : '||TO_CHAR( p_gl_date ) );
    END IF;
    --
    IF ( p_ps_rec.payment_schedule_id is NOT NULL ) THEN
        l_ps_rec := p_ps_rec;
       validate_args_upd_rel_cols( l_ps_rec.payment_schedule_id,
                                   p_amount_applied,
                                   p_apply_date, p_gl_date );
    ELSE
        validate_args_upd_rel_cols( p_ps_id, p_amount_applied,
                                       p_apply_date, p_gl_date );
        arp_ps_pkg.fetch_p( p_ps_id, l_ps_rec );
    END IF;
    --
    -- Call acctd. amount package to get acctd. amounts. and new ADR.
    -- Note: This procedure populates the OUT NOCOPY variable
    -- p_acctd_amount_applied directly
    --

    -- Modified For Bug # 2711860
    -- ORASHID
    --
    l_nocopy_amt_due_remain := l_ps_rec.amount_due_remaining;
    l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;

    arp_util.calc_acctd_amount( NULL, NULL, NULL,
            l_ps_rec.exchange_rate,
            '+',   /** amount_applied must be added to ADR */
            l_nocopy_amt_due_remain,        /* Current ADR */
            l_nocopy_acctd_amt_due_remain,  /* Current Acctd. ADR */
            p_amount_applied,                     /* Receipt Amount */
            l_ps_rec.amount_due_remaining,        /* New ADR */
            l_ps_rec.acctd_amount_due_remaining,  /* New Acctd. ADR */
            l_acctd_amount_applied );             /* Acct. amount_applied */
    --
    -- Update OUT NOCOPY variable p_acctd_amount_applied
    --
    p_acctd_amount_applied := l_acctd_amount_applied;
    --
    -- Update PS record columns
    -- Note: The amount applied is subtracted from current amount applied
    --
    l_ps_rec.amount_applied  := NVL( l_ps_rec.amount_applied, 0 ) -
                                p_amount_applied ;
    --
    -- Add applied amounts to amounts remaining
    --
    IF ( p_line_applied IS NOT NULL ) THEN
        l_ps_rec.amount_line_items_remaining :=
                             NVL( l_ps_rec.amount_line_items_remaining, 0 ) +
                             p_line_applied;
    END IF;
    --
    IF ( p_charges_applied  IS NOT NULL ) THEN
        l_ps_rec.receivables_charges_remaining :=
                             NVL (l_ps_rec.receivables_charges_remaining, 0 ) +
                             p_charges_applied;
    END IF;
    --
    IF ( p_tax_applied IS NOT NULL ) THEN
        l_ps_rec.tax_remaining := NVL( l_ps_rec.tax_remaining, 0 ) +
                                  p_tax_applied;
    END IF;
    --
    IF ( p_freight_applied  IS NOT NULL ) THEN
        l_ps_rec.freight_remaining := NVL( l_ps_rec.freight_remaining, 0 ) +
                                      p_freight_applied;
    END IF;

    /* Bug 4122494 CM refunds */
    IF ( NVL(p_update_credit_flag,'N') = 'Y' ) THEN
        l_ps_rec.amount_credited  := NVL( l_ps_rec.amount_credited, 0 ) +
                                     p_amount_applied ;
    END IF;

    --
    -- Set the closed dates and status of PS record
    --
    arp_ps_util.populate_closed_dates( p_gl_date, p_apply_date, 'CM', l_ps_rec );
    --
    -- Update PS record
    --
    arp_ps_pkg.update_p( l_ps_rec );
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_cm_related_columns()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
		  'EXCEPTION: arp_ps_util.update_cm_related_columns' );
              END IF;
              RAISE;
END update_cm_related_columns;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_adj_related_columns                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the Adjustments related rows of a PS record   |
 |      The passed in PS ID is assumed to belong to an adjustment. Procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever an invoice is adjusted.          |
 |      In case of an invoice adjustment, the procedure also calculates the  |
 |      line_adjusted, tax_adjusted, charges_adjusted and freight_adjusted   |
 |      amounts.                                                             |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |   IN :  p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_type                - Adjustment type - valid values are        |
 |                                 'INVOICE', 'FREIGHT', 'TAX', 'LINE',      |
 |                                 'CHARGES', NULL(In case of pendings only) |
 |                                 There is no explicit check to make sure   |
 |                                 that the type value is one of the above   |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_amount_adjusted     - Amount adjusted if type is not 'INVOICE'  |
 |         p_amount_adjusted_pending - Amount adjusted pending if any.       |
 |   IN :  p_line_adjusted       - Line adjusted - In case of INVOICE adj.   |
 |         p_tax_adjusted        - Tax  adjusted - In case of INVOICE adj.   |
 |         p_charges_adjusted    - charges adjusted - In case of INVOICE adj.|
 |         p_freight_adjusted    - freight adjusted - In case of INVOICE adj.|
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_debug.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - Also Calls populate_closed_dates. This procedure is in this file. |
 |         At present this is an overloaded procedure                        |
 |
 | HISTORY
 | 8/24/1995	Ganesh Vaidee		Created
 | 4/17/1996	Harri Kaukovuo		Added functionality to handle
 |					chargebacks properly.
 | 02/02/2000   Saloni Shah             Modified the parameter p_freight_Adjusted
 |                                      to IN OUT NOCOPY parameter.
 |                                      Changes made for reverse adjustment:
 |                                      when called from create_adjustments
 |                                      the p_type being sent from create_adjustment
 |                                      is set to REVERSE while updating the
 |                                      payment schedules. When the value is set
 |                                      to 'REVERSE' the amounts being passed
 |                                      for p_amount_adjusted, p_tax_adjusted,
 |                                      p_freight_adjusted and p_line_adjusted
 |                                      should not be modified, they should be
 |                                      set to the values passed by create_adjustment.
 | 06/15/00    Satheesh Nambiar         Bug 1290698- When partial amount is passed,
 |                                      default the line,tax,freight,charges adjusted
 |                                      to actual values instead of taking the full
 |                                      amounts from PS if the those values are not null
 |                                      or zero.
 | 02/13/03    Ajay Pandit              Made the p_ps_rec an IN OUT parameter.
 | 07/21/04    Ravi Sharma              Receivables_charges_charged should be gross charges
 |                                      inclusive of tax component in case of Activity of type
 |					Finance Charges having tax code source attached.
 +===========================================================================*/
PROCEDURE update_adj_related_columns(
                p_ps_id           IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_type            IN ar_adjustments.type%TYPE,
                p_amount_adjusted IN ar_payment_schedules.amount_adjusted%TYPE,
                p_amount_adjusted_pending IN ar_payment_schedules.amount_adjusted_pending%TYPE,
                p_line_adjusted    IN OUT NOCOPY ar_receivable_applications.line_applied%TYPE,
                p_tax_adjusted     IN OUT NOCOPY ar_receivable_applications.tax_applied%TYPE,
                p_freight_adjusted IN OUT NOCOPY ar_receivable_applications.freight_applied%TYPE,
                p_charges_adjusted IN OUT NOCOPY ar_receivable_applications.receivables_charges_applied%TYPE,
                p_apply_date       IN     ar_payment_schedules.gl_date%TYPE,
                p_gl_date          IN     ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_adjusted OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_ps_rec           IN  OUT NOCOPY   ar_payment_schedules%ROWTYPE) IS
--
-- deleted 'DEFAULT NULL' for p_ps_rec Rowtype attribute -bug460979 for Oracle8

l_ps_rec              ar_payment_schedules%ROWTYPE;
l_line_adjusted       ar_payment_schedules.amount_adjusted%TYPE;
l_tax_adjusted        ar_payment_schedules.amount_adjusted%TYPE;
l_freight_adjusted    ar_payment_schedules.amount_adjusted%TYPE;
l_charges_adjusted    ar_payment_schedules.amount_adjusted%TYPE;

-- Bug 1919595
-- Define four variables to hold the amounts remaining for line, tax, freight and charges
l_line_for_adj ar_payment_schedules.amount_line_items_remaining%TYPE;
l_tax_for_adj ar_payment_schedules.tax_remaining%TYPE;
l_freight_for_adj ar_payment_schedules.freight_remaining%TYPE;
l_charges_for_adj ar_payment_schedules.receivables_charges_remaining%TYPE;

--
-- Variable to populate OUT NOCOPY arguments
--
l_acctd_amount_adjusted
                 ar_receivable_applications.acctd_amount_applied_from%TYPE;

rem_adj_amt	NUMBER;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_adj_related_columns()+' );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'PS ID                 : '||p_ps_id );
       arp_debug.debug(   'PS REC ID             : '||to_char(p_ps_rec.payment_schedule_id));
       arp_debug.debug(   'Type                  : '||p_type );
       arp_debug.debug(   'Amount adjusted       : '||p_amount_adjusted );
       arp_debug.debug(   'Amount Adjusted Pend  : '||p_amount_adjusted_pending );
       arp_debug.debug(   'Line Adjusted         : '||p_line_adjusted);
       arp_debug.debug(   'Tax Adjusted          : '||p_tax_adjusted);
       arp_debug.debug(   'Freight Adjusted      : '||p_freight_adjusted);
       arp_debug.debug(   'Charges Adjusted      : '||p_charges_adjusted);
       arp_debug.debug(   'Apply Date            : '||TO_CHAR( p_apply_date ) );
       arp_debug.debug(   'GL Date               : '||TO_CHAR( p_gl_date ) );
    END IF;
    --
    IF ( p_ps_rec.payment_schedule_id is NOT NULL ) THEN
       l_ps_rec := p_ps_rec;
       validate_args_upd_adj_rel_cols( l_ps_rec.payment_schedule_id,
                                       p_apply_date, p_gl_date );
    ELSE
        validate_args_upd_adj_rel_cols( p_ps_id, p_apply_date, p_gl_date );
        arp_ps_pkg.fetch_p( p_ps_id, l_ps_rec );
    END IF;


    IF ( p_type = 'INVOICE' ) THEN

          -- 4/16/96 H.Kaukovuo   Just a comment:
          --			This seems to be hard coded ...

          -- Bug 650038: Set all adjusted amounts to zero if
          -- adjustment is rejected

          IF (p_amount_adjusted is NULL) THEN
            l_line_adjusted := 0;
            l_tax_adjusted := 0;
            l_freight_adjusted := 0;
            l_charges_adjusted := 0;

            --
            -- Populate OUT NOCOPY variables
            --
            p_line_adjusted := 0;
            p_tax_adjusted := 0;
            p_freight_adjusted := 0;
            p_charges_adjusted := 0;

          ELSE

           /*----------------------------------------------------------+
            | Bug 1290698- Fetch the PS line,tax,freight,charges  and  |
            | assign to the out NOCOPY variables only if the inputed amounts  |
            | are null or zero                                         |
            +----------------------------------------------------------*/

            /* bug 2389772 : there are cases were amount to adjust is actually
               passed in as zero, in those cases we don't want the amount to
               re-default from remaining amount in ar_payment_schedules

               Define rem_adj_amt to contain total adjustment amount
               passed as parameter, while processing each adjustment type
               keep subtracting amount from rem_adj_amt, once rem_adj_amt hits 0
               that means all remaining adj amounts should stay at zero

               additional info: technically p_adj_type = 'INVOICE' should bring
               remaining amounts to zero, but BR assignments are an exception,
               a BR assignment creates an INVOICE adjustment *BUT* it does not
               have to bring invoice balance to zero
            */

            rem_adj_amt :=  p_amount_adjusted;

            IF NVL(p_line_adjusted,0) <> 0 THEN
               l_line_adjusted    := p_line_adjusted;
               rem_adj_amt        := rem_adj_amt - p_line_adjusted;
            ELSE
               -- issue : will there be cases where user intended p_line_adjusted to be zero ?
               l_line_adjusted := -l_ps_rec.amount_line_items_remaining;
               rem_adj_amt     := rem_adj_amt - l_line_adjusted;
            END IF;

            IF NVL(p_tax_adjusted,0) <> 0 THEN
               l_tax_adjusted     := p_tax_adjusted;
               rem_adj_amt        := rem_adj_amt - p_tax_adjusted;
            ELSE
               if abs(rem_adj_amt) >= abs(l_ps_rec.tax_remaining) then
                  l_tax_adjusted := -l_ps_rec.tax_remaining;
                  rem_adj_amt     := rem_adj_amt - l_tax_adjusted;
               else
                  l_tax_adjusted := 0;
               end if;
            END IF;

            IF NVL(p_freight_adjusted,0) <> 0 THEN
               l_freight_adjusted := p_freight_adjusted;
               rem_adj_amt        := rem_adj_amt - p_freight_adjusted;
            ELSE
               if abs(rem_adj_amt) >= abs(l_ps_rec.freight_remaining) then
                  l_freight_adjusted := -l_ps_rec.freight_remaining;
                  rem_adj_amt     := rem_adj_amt - l_freight_adjusted;
               else
                  l_freight_adjusted := 0;
               end if;
            END IF;

            IF NVL(p_charges_adjusted,0) <> 0 THEN
               l_charges_adjusted := p_charges_adjusted;
               rem_adj_amt        := rem_adj_amt - p_charges_adjusted;
            ELSE
               if abs(rem_adj_amt) >= abs(l_ps_rec.receivables_charges_remaining) then
                  l_charges_adjusted := -l_ps_rec.receivables_charges_remaining;
                  rem_adj_amt     := rem_adj_amt - l_charges_adjusted;
               else
                  l_charges_adjusted := 0;
               end if;
            END IF;

            p_line_adjusted    := l_line_adjusted;
            p_tax_adjusted     := l_tax_adjusted;
            p_freight_adjusted := l_freight_adjusted;
            p_charges_adjusted := l_charges_adjusted;


          END IF;

      -- 4/16/1996 H.Kaukovuo
      -- Added the code to separate Chargeback from normal invoice
    ELSIF (p_type = 'CB')
    THEN
        -- Bug 1919595
        -- Removed the existing logic and added new code which prorates the chargeback amount
        -- (Creates INVOICE type of adjustment)
        /* Bug 2399863 : Commented out NOCOPY the IF condition as it is not required */
        /*IF NVL(l_ps_rec.amount_due_remaining,0) > 0 THEN */
              l_line_for_adj := l_ps_rec.amount_line_items_remaining;
              l_tax_for_adj :=  l_ps_rec.tax_remaining;
              l_freight_for_adj := l_ps_rec.freight_remaining;
              l_charges_for_adj := l_ps_rec.receivables_charges_remaining;

              ARP_APP_CALC_PKG.calc_applied_and_remaining(
                         p_amount_adjusted,
                         3, -- Prorate all
                         l_ps_rec.invoice_currency_code,
                         l_line_for_adj,
                         l_tax_for_adj,
                         l_freight_for_adj,
                         l_charges_for_adj,
                         l_line_adjusted,
                         l_tax_adjusted,
                         l_freight_adjusted,
                         l_charges_adjusted);
           /*END IF; */

          --
          -- Populate OUT NOCOPY variables
          --

          p_line_adjusted := l_line_adjusted;
          p_tax_adjusted :=  l_tax_adjusted;
          p_freight_adjusted := l_freight_adjusted;
          p_charges_adjusted := l_charges_adjusted;

       -- End of changes for bug 1919595

    /* Bug 2399863 :  For reversing the chargeback, the values are directly passed
       to this procedure */
    ELSIF (p_type = 'CBREV')  THEN
          l_tax_adjusted     := p_tax_adjusted;
          l_freight_adjusted := p_freight_adjusted;
          l_line_adjusted    := p_line_adjusted;
          l_charges_adjusted := p_charges_adjusted;
    ELSIF( p_type = 'LINE' ) THEN
          /*Bug 3135248*/
	  IF (p_amount_adjusted is NULL)
	  THEN
            l_line_adjusted := 0;
            l_tax_adjusted := 0;
            p_line_adjusted := 0;
            p_tax_adjusted := 0;

	  /* VAT changes */
	  ELSIF nvl(p_tax_adjusted, 0) = 0
	  THEN
	    l_line_adjusted := p_amount_adjusted;
            p_line_adjusted := p_amount_adjusted;
          ELSE
	    l_line_adjusted := p_line_adjusted;
	    l_tax_adjusted  := p_tax_adjusted;
          END IF;

    ELSIF( p_type = 'CHARGES' ) THEN
        --
        -- Update receivables_charges_charged
        --
        /*Bug 3135248*/
	IF (p_amount_adjusted is NULL)
	THEN
           l_charges_adjusted := 0;
           l_tax_adjusted  :=  0;
           p_charges_adjusted := 0;
           p_tax_adjusted := 0;

	/* VAT changes */
        ELSIF nvl(p_tax_adjusted, 0) = 0 THEN
          l_ps_rec.receivables_charges_charged :=
                          l_ps_rec.receivables_charges_charged +
                          p_amount_adjusted;
          --
          l_charges_adjusted := p_amount_adjusted;
          p_charges_adjusted := p_amount_adjusted;
        ELSE
          l_ps_rec.receivables_charges_charged :=
                          l_ps_rec.receivables_charges_charged +
                          p_charges_adjusted + p_tax_adjusted ; /* Bug 3166012 */
	  l_charges_adjusted := p_charges_adjusted;
          l_tax_adjusted  := p_tax_adjusted;
        END IF;

    ELSIF( p_type = 'TAX' ) THEN
        l_tax_adjusted := p_amount_adjusted;
        p_tax_adjusted := p_amount_adjusted;

    ELSIF( p_type = 'FREIGHT' ) THEN
        l_freight_adjusted := p_amount_adjusted;
        p_freight_adjusted := p_amount_adjusted;
    ELSIF (p_type = 'REVERSE' ) THEN
        l_tax_adjusted := p_tax_adjusted;
        l_freight_adjusted := p_freight_adjusted;
        l_line_adjusted := p_line_adjusted;
        l_charges_adjusted := p_charges_adjusted;
    END IF;
    --

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'Line Adjusted         : '||p_line_adjusted );
       arp_debug.debug(   'TAx  Adjusted         : '||p_tax_adjusted );
       arp_debug.debug(   'Freight Adjusted      : '||p_freight_adjusted );
       arp_debug.debug(   'Charges Adjusted      : '||p_charges_adjusted );
    END IF;

    update_adj_related_columns(
                l_ps_rec.payment_schedule_id,
                l_line_adjusted,
                l_tax_adjusted,
                l_freight_adjusted,
                l_charges_adjusted,
                p_amount_adjusted_pending,
                p_apply_date,
                p_gl_date,
                l_acctd_amount_adjusted,
                l_ps_rec);
    --
    p_acctd_amount_adjusted := l_acctd_amount_adjusted;
    --ajay assigning back the value to p_ps_rec as it has been made a IN OUT
    p_ps_rec := l_ps_rec;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_adj_related_columns()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
                  'EXCEPTION: arp_ps_util.update_adj_related_columns' );
              END IF;
              RAISE;
END update_adj_related_columns;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_upd_adj_rel_cols                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Validate arguments passed to update_receipt_related_cols procedure   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |   IN :  p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 | NOTES - At present this is an overloaded procedure                        |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_upd_adj_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_ps_util.validate_args_upd_adj_rel_cols()+' );
    END IF;
    --
    IF ( p_ps_id IS NULL OR p_apply_date IS NULL OR p_gl_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'arp_util.validate_args_upd_adj_rel_cols()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
                  'EXCEPTION: arp_ps_util.validate_args_upd_adj_rel_cols' );
              END IF;
              RAISE;
END validate_args_upd_adj_rel_cols;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    update_adj_related_columns                                             |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure updates the Adjustments related rows of a PS record   |
 |      The passed in PS ID is assumed to belong to an adjustment. Procedure |
 |      sets the gl_date and gl_date_closed and amount(s) applied. The       |
 |      procedure should be called whenever an invoice is adjusted.          |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |   IN :  p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_tax_adjusted        - Part of the adjusted amount to be applied |
 |                                 to tax                                    |
 |         p_freight_applied     - Part of the adjusted amount to be applied |
 |                                 to freight                                |
 |         p_line_applied        - Part of the adjusted amount to be applied |
 |                                 to lines                                  |
 |         p_charges_applied     - Part of the adjusted amount to be applied |
 |                                 to receivable charges                     |
 |         p_amount_adjusted_pending - Amount adjsuted pending if any.       |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION						     |
 |        arp_util.calc_acctd_amount and arp_debug.debug                      |
 |        arp_ps_pkg.fetch_p and arp_ps_pkg.update_p                         |
 |                                                                           |
 | NOTES - Also Calls populate_closed_dates. This procedure is in this file. |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 |02/13/03    Ajay Pandit              Made the p_ps_rec an IN OUT parameter |
 +===========================================================================*/

PROCEDURE update_adj_related_columns(
                p_ps_id                   IN  ar_payment_schedules.payment_schedule_id%TYPE,
                p_line_adjusted           IN  ar_receivable_applications.line_applied%TYPE,
                p_tax_adjusted            IN  ar_receivable_applications.tax_applied%TYPE,
                p_freight_adjusted        IN  ar_receivable_applications.freight_applied%TYPE,
                p_charges_adjusted        IN  ar_receivable_applications.receivables_charges_applied%TYPE,
                p_amount_adjusted_pending IN  ar_payment_schedules.amount_adjusted_pending%TYPE,
                p_apply_date              IN  ar_payment_schedules.gl_date%TYPE,
                p_gl_date                 IN  ar_payment_schedules.gl_date%TYPE,
                p_acctd_amount_adjusted   OUT NOCOPY ar_receivable_applications.acctd_amount_applied_to%TYPE,
                p_ps_rec                  IN  OUT NOCOPY ar_payment_schedules%ROWTYPE) IS
--
-- deleted 'DEFAULT NULL' for p_ps_rec Rowtype attribute -bug460979 for Oracle8

 l_ps_rec                   ar_payment_schedules%ROWTYPE;
 l_amount_adjusted          ar_payment_schedules.amount_adjusted%TYPE;

--
-- Variable to populate OUT NOCOPY arguments
--
 l_acctd_amount_adjusted   ar_receivable_applications.acctd_amount_applied_from%TYPE;


--Introduced For Bug # 2711860
-- ORASHID
--
l_nocopy_amt_due_remain
  ar_payment_schedules.amount_due_remaining%TYPE;
l_nocopy_acctd_amt_due_remain
  ar_payment_schedules.acctd_amount_due_remaining%TYPE;

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_adj_related_columns()+' );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug(   'PS ID                 : '||p_ps_id );
       arp_debug.debug(   'Line Adjusted         : '||p_line_adjusted );
       arp_debug.debug(   'TAx  Adjusted         : '||p_tax_adjusted );
       arp_debug.debug(   'Freight Adjusted      : '||p_freight_adjusted );
       arp_debug.debug(   'Charges Adjusted      : '||p_charges_adjusted );
       arp_debug.debug(   'Amount Adjusted Pend  : '||p_amount_adjusted_pending );
       arp_debug.debug(   'Apply Date            : '||TO_CHAR( p_apply_date ) );
       arp_debug.debug(   'GL Date               : '||TO_CHAR( p_gl_date ) );
    END IF;

    IF ( p_ps_rec.payment_schedule_id is NOT NULL ) THEN
       l_ps_rec := p_ps_rec;
       validate_args_upd_adj_rel_cols( l_ps_rec.payment_schedule_id,
                                   p_line_adjusted, p_tax_adjusted,
                                   p_freight_adjusted, p_charges_adjusted,
                                   p_amount_adjusted_pending,
                                   p_apply_date, p_gl_date );
    ELSE
        validate_args_upd_adj_rel_cols( p_ps_id, p_line_adjusted,
                                        p_tax_adjusted, p_freight_adjusted,
                                        p_charges_adjusted,
                                        p_amount_adjusted_pending,
                                        p_apply_date, p_gl_date );
        arp_ps_pkg.fetch_p( p_ps_id, l_ps_rec );
    END IF;
    --

    l_amount_adjusted := NVL( p_line_adjusted, 0 ) +
                         NVL( p_tax_adjusted, 0 ) +
                         NVL( p_freight_adjusted, 0 ) +
                         NVL( p_charges_adjusted, 0 );
    --
    -- Call acctd. amount package to get acctd. amounts. and new ADR.
    -- Note: This procedure populates the OUT NOCOPY variable
    -- p_acctd_amount_applied directly
    --

    -- Modified For Bug # 2711860
    -- ORASHID
          --
    l_nocopy_amt_due_remain := l_ps_rec.amount_due_remaining;
    l_nocopy_acctd_amt_due_remain := l_ps_rec.acctd_amount_due_remaining;

    arp_util.calc_acctd_amount( NULL, NULL, NULL,
            l_ps_rec.exchange_rate,
            '+',                     /* amount_applied must be added to ADR */
            l_nocopy_amt_due_remain,        /* Current ADR */
            l_nocopy_acctd_amt_due_remain,  /* Current Acctd. ADR */
            l_amount_adjusted,                    /* Amount adjusted */
            l_ps_rec.amount_due_remaining,        /* New ADR */
            l_ps_rec.acctd_amount_due_remaining,  /* New Acctd. ADR */
            l_acctd_amount_adjusted );            /* Acct. amount_applied */
    --
    -- Update OUT NOCOPY variable p_acctd_amount_adjusted
    --
    p_acctd_amount_adjusted := l_acctd_amount_adjusted;
    --
    -- Add amount adjusted to current amount_adjusted and subtract
    -- adjusted amounts from amounts remaining
    --
    l_ps_rec.amount_adjusted := nvl(l_ps_rec.amount_adjusted, 0) +
                                l_amount_adjusted;
    --
    IF ( p_line_adjusted IS NOT NULL ) THEN
        l_ps_rec.amount_line_items_remaining :=
                             NVL( l_ps_rec.amount_line_items_remaining, 0 ) +
                             p_line_adjusted;
    END IF;
    --
    IF ( p_charges_adjusted IS NOT NULL ) THEN
        l_ps_rec.receivables_charges_remaining :=
                             NVL (l_ps_rec.receivables_charges_remaining, 0 ) +
                             p_charges_adjusted;
    END IF;
    --
    IF ( p_tax_adjusted IS NOT NULL ) THEN
        l_ps_rec.tax_remaining := NVL( l_ps_rec.tax_remaining, 0 ) +
                                  p_tax_adjusted;
    END IF;
    --
    IF ( p_freight_adjusted IS NOT NULL ) THEN
        l_ps_rec.freight_remaining := NVL( l_ps_rec.freight_remaining, 0 ) +
                                      p_freight_adjusted;
    END IF;
    --
    IF ( p_amount_adjusted_pending IS NOT NULL ) THEN
        l_ps_rec.amount_adjusted_pending :=
                           NVL( l_ps_rec.amount_adjusted_pending, 0 ) +
                           p_amount_adjusted_pending;
    END IF;
    --
    -- Set the closed dates and status of PS record
    --
    arp_ps_util.populate_closed_dates( p_gl_date, p_apply_date, 'ADJ', l_ps_rec );
    --
    -- Update PS record
    --
    arp_ps_pkg.update_p( l_ps_rec );
    --

    --ajay assigning back the value to p_ps_rec as it has been made a IN OUT
    p_ps_rec := l_ps_rec;

    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.update_adj_related_columns()-' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug(
                  'EXCEPTION: arp_ps_util.update_adj_related_columns' );
              END IF;
              RAISE;
END update_adj_related_columns;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_args_upd_adj_rel_cols                                         |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Validate arguments passed to update_receipt_related_cols procedure   |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |   IN :  p_payment_schedule_id - payment_schedule_id of payment            |
 |                                 schedule                                  |
 |         p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_tax_adjusted        - Part of the adjusted amount to be applied |
 |                                 to tax                                    |
 |         p_freight_applied     - Part of the adjusted amount to be applied |
 |                                 to freight                                |
 |         p_line_applied        - Part of the adjusted amount to be applied |
 |                                 to lines                                  |
 |         p_charges_applied     - Part of the adjusted amount to be applied |
 |                                 to receivable charges                     |
 |         p_amount_adjusted_pending - Amount adjsuted pending if any.       |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 |                                                                           |
 | NOTES -                                                                   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE validate_args_upd_adj_rel_cols(
                p_ps_id   IN ar_payment_schedules.payment_schedule_id%TYPE,
                p_line_adjusted  IN
                            ar_receivable_applications.line_applied%TYPE,
                p_tax_adjusted  IN
                            ar_receivable_applications.tax_applied%TYPE,
                p_freight_adjusted  IN
                            ar_receivable_applications.freight_applied%TYPE,
                p_charges_adjusted  IN
                 ar_receivable_applications.receivables_charges_applied%TYPE,
                p_amount_adjusted_pending IN
                 ar_payment_schedules.amount_adjusted_pending%TYPE,
                p_apply_date IN ar_payment_schedules.gl_date%TYPE,
                p_gl_date IN ar_payment_schedules.gl_date%TYPE ) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_ps_util.validate_args_upd_adj_rel_cols()+' );
    END IF;
    --
    IF ( p_ps_id IS NULL OR p_apply_date IS NULL OR p_gl_date IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    -- At least one input amount should not be NULL
    --
    IF ( p_line_adjusted IS NULL AND p_tax_adjusted IS NULL AND
         p_freight_adjusted IS NULL AND p_charges_adjusted IS NULL AND
         p_amount_adjusted_pending IS NULL ) THEN
         FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
         APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_util.validate_args_upd_adj_rel_cols()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug('validate_args_upd_adj_rel_cols: ' ||
                  'EXCEPTION: arp_ps_util.validate_args_upd_adj_rel_cols' );
              END IF;
              RAISE;
END validate_args_upd_adj_rel_cols;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    populate_closed_dates                                                  |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      This procedure takes in a payment schedule record structure, gl_date |
 |      apply_date, application type and populates the payment schedule      |
 |      record structure with gl_date_closed and   actual_date_closed        |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS :                                                              |
 |    IN : p_gldate              - GL date of the receipt                    |
 |         p_apply_date          - Apply Date of the receipt                 |
 |         p_app_type            - Application Type - 'CASH', 'CM', 'INV'    |
 |                                 'ADJ'                                     |
 | IN/OUT: p_ps_rec               - Payment Schedule record                  |
 |                                 PS id to be populated in input PS record  |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTION                                              |
 |        get_closed_dates - This procedure is in this package               |
 |                                                                           |
 | NOTES - Expectes PS id to be populated in input PS record                 |
 |                                                                           |
 | HISTORY - Created By - Ganesh Vaidee - 08/24/1995                         |
 | 16-APR-98 GJWANG       Bug fix #653643 declare this as public procedure   |
 +===========================================================================*/
PROCEDURE populate_closed_dates(
              p_gl_date IN ar_payment_schedules.gl_date%TYPE,
              p_apply_date IN ar_payment_schedules.gl_date%TYPE,
              p_app_type  IN VARCHAR2,
              p_ps_rec IN OUT NOCOPY ar_payment_schedules%ROWTYPE ) IS
--
l_gl_date_closed           ar_payment_schedules.gl_date%TYPE;
l_actual_date_closed       ar_payment_schedules.gl_date%TYPE;
--
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_util.populate_closed_dates()+' );
    END IF;
    --
    IF( p_ps_rec.payment_schedule_id IS NULL ) THEN
        FND_MESSAGE.set_name ('AR', 'AR_ARGUEMENTS_FAIL' );
        APP_EXCEPTION.raise_exception;
    END IF;
    --
    IF ( p_ps_rec.amount_due_remaining = 0 ) THEN
        --
        -- Get gl closing dates
        --
        arp_ps_util.get_closed_dates( p_ps_rec.payment_schedule_id,
                                      p_gl_date, p_apply_date,
                                      l_gl_date_closed, l_actual_date_closed,
                                      p_app_type );
        --
        p_ps_rec.status := 'CL';

       /* 08-JUL-2000 J Rautiainen BR Implementation
        * Set the reserved_value and reserved_type to NULL if closing the BR */
        p_ps_rec.reserved_type  := NULL;
        p_ps_rec.reserved_value := NULL;

        p_ps_rec.gl_date_closed := NVL( l_gl_date_closed,
                                        p_ps_rec.gl_date_closed );
        p_ps_rec.actual_date_closed := NVL( l_actual_date_closed,
                                             p_ps_rec.actual_date_closed );
    ELSE
        p_ps_rec.status := 'OP';
        p_ps_rec.gl_date_closed := ARP_GLOBAL.G_MAX_DATE;
        p_ps_rec.actual_date_closed := ARP_GLOBAL.G_MAX_DATE;
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( 'arp_util.populate_closed_dates()-' );
    END IF;
    EXCEPTION
         WHEN OTHERS THEN
              IF PG_DEBUG in ('Y', 'C') THEN
                 arp_debug.debug('populate_closed_dates: ' ||
                  'EXCEPTION: arp_ps_util.populate_closed_dates' );
              END IF;
              RAISE;
END populate_closed_dates;

/*===========================================================================+
 | PROCEDURE                                                                 |
 |    Get gl_date_closed and actual_date_closed                              |
 |                                                                           |
 | DESCRIPTION                                                               |
 |      Determines gl_date_closed and actual_date_closed for a payment       |
 |      schedule. For each of the two, it returns the greatest date from     |
 |      ar_receivable_applications, ar_adjustments, and the input current    |
 |      date. If it finds no values for a date, a null string is returned.   |
 |                                                                           |
 |      NOTE: This function does not correctly handle applications for future|
 |      items or future cash receipts. If an application or adjustment that  |
 |      closes an item has gl_date/apply_date less than the item's           |
 |      gl_date/trx_date or the cash receipt's gl_date/deposit_date, then the|
 |      gl_date_closed/actual_date_closed should be the greatest dates - the |
 |      ones from the item or cash receipt. The dates returned by armclps    |
 |      will be less than the correct ones because this function selects     |
 |      only from ar_receivable_applications, ar_adjustments and the input   |
 |      "current" dates.
 |                                                                           |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | PARAMETERS : p_payment_schedule_id - payment_schedule_id of payment       |
 |              schedule                                                     |
 |              p_gl_reversal_date - gl_date of current uncommitted          |
 |                                   transaction                             |
 |              p_reversal_date - apply date of current uncommitted xtion    |
 |              p_gl_date_closed - greatest of ar_adjustments.gl_date,       |
 |                                ar_receivable_applications.gl_date, and    |
 |                                current_gl_date.                           |
 |              p_actual_date_closed - (output) greatest of                  |
 |                                   ar_adjustments.apply_date,              |
 |                                   ar_receivable_applications.apply_date,  |
 |                                   and current_apply_date.                 |
 |                                                                           |
 | MODIFICATION HISTORY -                                                    |
 |                                                                           |
 | 08/18/98    Sushama Borde       Fixed bug 705906. Modified select statment|
 |                                 that gets the max gl_date and apply_date  |
 |                                 from ar_receivable_applications. Now check|
 |                                 s the reversal_gl_date, while selecting   |
 |                                 apply_date, and excludes applications that|
 |                                 have been reversed.
 | 07/04/04    S.A.P.N.Sarma	   The actual_date_closed and gl_date_Closed |
 |				   values have to be retrieved only for those|
 |				   txns whose payment_Schedule_id > 0. We    |
 | 				   need not retrieve the values for activity |
 |				   aplications. Bug 3382570.		     |
 +===========================================================================*/
PROCEDURE get_closed_dates( p_ps_id IN NUMBER,
                           p_gl_reversal_date IN DATE,
                           p_reversal_date IN DATE,
                           p_gl_date_closed OUT NOCOPY DATE,
                           p_actual_date_closed OUT NOCOPY DATE ,
                           p_app_type IN CHAR ) IS
l_gl_adj                        DATE;
l_act_adj                       DATE;
l_gl_app                        DATE;
l_act_app                       DATE;
l_max_gl_date                   DATE;
l_max_actual_date               DATE;
BEGIN
--
   IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug( '>>>>>>> arp_util.get_closed_dates' );
   END IF;
   --
   -- Get max dates from ar_receivable_applications
   --

   IF PG_DEBUG in ('Y', 'C') THEN
      arp_debug.debug('get_closed_dates: ' ||  '>>>P_PS_ID: ' || p_ps_id );
   END IF;

   IF p_ps_id > 0 THEN  /* Bug 3382570 */

    SELECT MAX(gl_date),
           MAX(DECODE(reversal_gl_date, NULL, apply_date, NULL)) -- Bug 705906: Not to include
                                                                 -- application reversals while
                                                                 -- getting the max apply_date.
    INTO l_gl_app,
         l_act_app
    FROM ar_receivable_applications
    WHERE ( applied_payment_schedule_id = p_ps_id -- "Trx" that was applied

            or payment_schedule_id = p_ps_id )    -- "Payment" or "Credit Memo" being
                                                  -- applied.
    AND  nvl( confirmed_flag, 'Y' ) = 'Y';
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug('get_closed_dates: ' || ' after select appln' );
    END IF;
    --
    -- Get max dates from ar_adjustments
    --
    /* 18-MAY-2000 J Rautiainen BR Implementation
     * Added Bills Receivable transaction */
    /* Bug fix 3243565 : Deposits, Debit Memos and Chargebacks can also be
       adjusted through the receipt application window.*/
    IF ( p_app_type IN ( 'INV', 'BR', 'CM', 'ADJ','CB','DEP','DM' ) ) THEN
         SELECT MAX(gl_date),
                MAX(apply_date)
         INTO   l_gl_adj,
                l_act_adj
         FROM   ar_adjustments
         WHERE  status = 'A'
         AND    payment_schedule_id = p_ps_id;
    END IF;
    --
    p_gl_date_closed := GREATEST( NVL( p_gl_reversal_date,
                                       NVL( l_gl_app, l_gl_adj)
                                     ),
                                  NVL( l_gl_app,
                                       NVL( l_gl_adj, p_gl_reversal_date )
                                     ),
                                  NVL( l_gl_adj,
                                       NVL( p_gl_reversal_date, l_gl_app )
                                     )
                                );

    p_actual_date_closed := GREATEST( NVL( p_reversal_date,
                                           NVL( l_act_app, l_act_adj )
                                         ),
                                      NVL( l_act_app,
                                           NVL( l_act_adj, p_reversal_date )
                                         ),
                                      NVL( l_act_adj,
                                           NVL( p_reversal_date, l_act_app )
                                         )
                                    );
    END IF;
    --
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_debug.debug( '<<<<<<< arp_util.get_closed_dates' );
    END IF;
    --
    EXCEPTION
         WHEN OTHERS THEN
          IF PG_DEBUG in ('Y', 'C') THEN
             arp_debug.debug( 'EXCEPTION: arp_util.get_closed_dates' );
          END IF;
          RAISE;
END get_closed_dates;
--
END ARP_PS_UTIL;

/
